#version 300 es
precision highp float;
in vec2 vUv;
out vec4 fragColor;

uniform sampler2D uEarth;
uniform vec2 uResolution;
uniform float uAltitudeKm;
uniform float uHeading;
uniform float uPitch;
uniform float uTime;
uniform float uDetail;
uniform vec3 uEast;
uniform vec3 uNorth;
uniform vec3 uUp;
uniform vec3 uSun;

const float PI=3.14159265358979323846;
const float R=6371.0;                  // NASA Earth mean radius, km
const float ATM=6471.0;               // explicit 100 km visual shell
const vec3 SHORE=vec3(.616,.788,0.);  // tangent NE/SW along AC beach
const vec3 SEA=vec3(.788,-.616,0.);   // offshore SE

float hash21(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float n2(vec2 p){
  vec2 i=floor(p), f=fract(p);f=f*f*(3.-2.*f);
  return mix(mix(hash21(i),hash21(i+vec2(1,0)),f.x),
             mix(hash21(i+vec2(0,1)),hash21(i+1.),f.x),f.y);
}
float rndStar(vec3 dir,float count){
  vec2 v=vec2(atan(dir.y,dir.x),asin(clamp(dir.z,-1.,1.)))*count;
  vec2 id=floor(v), f=fract(v)-.5;
  float seed=hash21(id);
  vec2 shift=vec2(hash21(id+8.3),hash21(id+19.7))-.5;
  float d=length(f-shift*.65);
  return step(.993,seed)*(.3+.7*seed)*smoothstep(.07,.005,d);
}
vec2 hitSphere(vec3 ro,vec3 rd,float radius){
  float b=dot(ro,rd);
  float c=dot(ro,ro)-radius*radius;
  float d=b*b-c;
  if(d<0.) return vec2(-1.);
  float q=sqrt(d);
  return vec2(-b-q,-b+q);
}
vec2 tangent(vec2 xy){return vec2(dot(xy,SHORE.xy),dot(xy,SEA.xy));}

float hitBox(vec3 ro,vec3 rd,vec3 mid,vec3 halfSize){
  vec3 inv=1./(rd+vec3(1e-8));
  vec3 t0=(mid-halfSize-ro)*inv;
  vec3 t1=(mid+halfSize-ro)*inv;
  vec3 mn=min(t0,t1),mx=max(t0,t1);
  float nearT=max(max(mn.x,mn.y),mn.z);
  float farT=min(min(mx.x,mx.y),mx.z);
  if(farT < max(nearT,.01))return -1.;
  return nearT>.01?nearT:farT;
}
vec3 nearbyGround(vec3 p){
  vec2 sd=tangent(p.xy*1000.);
  float s=sd.x, d=sd.y;
  float coast=75.+6.*sin(s/340.)+4.*sin(s/1300.);
  float grain=n2(vec2(s*.13,d*.42));
  float seaSide=smoothstep(coast-2.,coast+3.,d);
  vec3 beach=vec3(.63,.56,.39)+vec3(.085,.073,.06)*(grain-.5);
  vec3 ocean=vec3(.016,.125,.19);
  ocean+=vec3(.035,.052,.064)*(n2(vec2(s*.015,d*.018+uTime*.03))-.5);
  float foam=exp(-pow((d-(coast+3.*sin(s*.08+uTime*.65)))/2.6,2.));
  ocean+=vec3(.27,.44,.46)*foam*.4;
  vec3 color=mix(beach,ocean,seaSide);
  if(d < -11.){
    vec2 grid=vec2(s+45.,d+105.);
    float block=n2(floor(grid/20.));
    vec3 road=vec3(.18,.185,.19);
    float street=min(fract(grid.x/74.),fract(grid.y/85.));
    vec3 city=mix(vec3(.26,.285,.295),vec3(.41,.42,.415),block);
    city=mix(road,city,smoothstep(.045,.075,street));
    color=mix(color,city,(1.-smoothstep(-19.,-12.,d)));
  }
  if(d > -11. && d < 1. && abs(s)<2000.){
    float plank=1.-smoothstep(.035,.065,abs(fract(s/.28)-.5));
    float seam=1.-smoothstep(.015,.025,abs(fract(d/2.8)-.5));
    vec3 timber=vec3(.44,.305,.18)+vec3(.09,.068,.033)*(grain-.5);
    color=timber*(1.-.19*plank-.08*seam);
  }
  return color;
}
vec3 earthColor(vec3 hit){
  vec3 normal=normalize(hit);
  vec3 globe=normalize(uEast*normal.x+uNorth*normal.y+uUp*normal.z);
  float longitude=atan(globe.y,globe.x);
  float latitude=asin(clamp(globe.z,-1.,1.));
  vec2 uv=vec2(fract(longitude/(2.*PI)+.5),clamp(.5-latitude/PI,.001,.999));
  vec3 nasa=texture(uEarth,uv).rgb;
  // NASA Blue Marble: coastlines and continents, no detail near pedestrian scale.
  // Local Boardwalk/beach is explicitly stylized and fades smoothly with range.
  float localRange=length(hit.xy);
  float localMask=(1.-smoothstep(1.4,7.0,localRange));
  localMask *= 1.-smoothstep(8.0,25.0,uAltitudeKm);
  return mix(nasa,nearbyGround(hit),localMask);
}

// Geometric local detail in meters, relative to the geodetic observer.
// These recognizable structures are schematic; not surveyed 3D building data.
vec4 localObjects(vec3 ro,vec3 rd,float limitKm){
  if(uAltitudeKm>7.0)return vec4(0.);
  vec3 eye=vec3(tangent(ro.xy)*1000.,uAltitudeKm*1000.);
  vec3 dir=vec3(tangent(rd.xy),rd.z);
  float best=limitKm*1000.;
  vec3 color=vec3(0.);
  bool found=false;
  // Steel Pier, about 300m offshore, elevated above the beach and waves.
  float deck=hitBox(eye,dir,vec3(46.,220.,6.0),vec3(22.,155.,2.2));
  if(deck>0. && deck<best){
    vec3 hp=eye+deck*dir;
    float grain=n2(hp.xy*.16);
    color=vec3(.25,.285,.29)+grain*.095;
    best=deck;found=true;
  }
  // Steel Pier ferris wheel: vertical circular metal framework and spokes.
  float denom=dir.y;
  if(abs(denom)>0.00001){
    float tw=(214.-eye.y)/denom;
    if(tw>0. && tw<best){
      vec3 wp=eye+tw*dir;
      vec2 q=vec2(wp.x-46.,wp.z-40.);
      float r=length(q);
      float a=atan(q.y,q.x);
      float ring=abs(r-24.);
      float spoke=abs(sin(a*12.))*r;
      float center=length(q);
      float steel=min(ring,min(spoke,center));
      float thickness=ring<.95? .95 : (r<24. && spoke<.30)?.30:.0;
      if((ring<.95 || (r<24. && spoke<.30) || center<2.1) && r<=25.){
        float highlight=.6+.4*max(0.,dot(uSun,vec3(0.,-.4,.9)));
        color=mix(vec3(.61,.69,.75),vec3(.92,.98,1.),highlight);
        color*=(1.-smoothstep(.25,1.2,min(steel,thickness)));
        best=tw;found=true;
      }
    }
  }
  // Waterfront hotels and casino skyline, behind the Boardwalk.
  if(uDetail>.25){
    for(int i=0;i<9;i++){
      float f=float(i);
      float bs=(f-4.)*78. + 17.*sin(f*2.7);
      float bd=-95.-32.*mod(f,3.);
      float height=33.+77.*abs(sin(f*1.73+1.8));
      if(i==4)height=116.; // distinct tall glazed tower silhouette
      vec3 mid=vec3(bs,bd,height*.5);
      vec3 half=vec3(19.+8.*mod(f,3.),22.,height*.5);
      float t=hitBox(eye,dir,mid,half);
      if(t>0. && t<best){
        vec3 hp=eye+t*dir;
        float windows=step(.72,hash21(floor(vec2(hp.x*.13,hp.z*.35))));
        float lines=step(.78,fract(hp.z/4.2));
        vec3 glass=mix(vec3(.13,.22,.32),vec3(.37,.44,.45),n2(vec2(f*.23,.2)));
        color=glass*(.82+.13*windows+.12*lines);
        best=t;found=true;
      }
    }
  }
  // Ocean-facing safety rail at boardwalk edge.
  float rail=hitBox(eye,dir,vec3(0.,4.,1.05),vec3(700.,.065,.08));
  if(rail>0. && rail<best){color=vec3(.64,.69,.73);best=rail;found=true;}
  return found?vec4(color,best*.001):vec4(0.);
}

vec3 atmosphere(vec3 ro,vec3 rd,float tStop,out vec3 transmittance){
  const vec3 betaR=vec3(.0058,.0135,.0331);
  const vec3 betaM=vec3(.0080);
  vec2 bounds=hitSphere(ro,rd,ATM);
  float begin=max(0.,bounds.x), end=bounds.y;
  if(bounds.y<0. || end<=begin){transmittance=vec3(1.);return vec3(0.);}
  end=min(end,tStop);
  if(end<=begin){transmittance=vec3(1.);return vec3(0.);}
  float dt=(end-begin)/8.;
  float mu=dot(rd,uSun);
  float phaseR=(3.0/(16.0*PI))*(1.+mu*mu);
  float g=.72;
  float phaseM=(1.-g*g)/(4.*PI*pow(1.+g*g-2.*g*mu,1.5));
  float opticalR=0.,opticalM=0.;
  vec3 scattered=vec3(0.);
  for(int i=0;i<8;i++){
    vec3 pos=ro+rd*(begin+(float(i)+.5)*dt);
    float height=max(0.,length(pos)-R);
    float rhoR=exp(-height/8.5);
    float rhoM=exp(-height/1.4);
    float projected=max(.13,dot(normalize(pos),uSun));
    float sunPath=10./projected;
    vec3 sunTr=exp(-(betaR*rhoR+betaM*rhoM)*sunPath);
    vec3 viewTr=exp(-(betaR*opticalR+betaM*opticalM));
    scattered += (betaR*rhoR*phaseR+betaM*rhoM*phaseM)
                 *dt*sunTr*viewTr*14.;
    opticalR+=rhoR*dt;
    opticalM+=rhoM*dt;
  }
  transmittance=exp(-(betaR*opticalR+betaM*opticalM));
  return scattered;
}
void main(){
  vec2 uv=vUv*2.-1.;
  float aspect=uResolution.x/max(1.,uResolution.y);
  float heading=radians(uHeading);
  float pitch=radians(clamp(uPitch,-87.,81.));
  vec3 flat=vec3(sin(heading),cos(heading),0.);
  vec3 forward=flat*cos(pitch)+vec3(0.,0.,sin(pitch));
  vec3 right=normalize(cross(forward,vec3(0.,0.,1.)));
  vec3 up=cross(right,forward);
  float fov=tan(radians(65.)*.5);
  vec3 rd=normalize(forward+(right*uv.x*aspect+up*uv.y)*fov);
  vec3 ro=vec3(0.,0.,R+uAltitudeKm);
  vec2 intersection=hitSphere(ro,rd,R);
  bool ground=intersection.y>0. && intersection.x>0.;
  float tGround=ground?intersection.x:100000.;

  vec3 base=vec3(.0002,.0005,.0017);
  if(ground){
    vec3 hit=ro+rd*tGround;
    float diffuse=max(0.,dot(normalize(hit),uSun));
    base=earthColor(hit)*(.13+1.18*diffuse);
    // Sunlit sea reflects a broad optical glint without mirror-perfect waves.
    vec2 sd=tangent(hit.xy*1000.);
    if(uAltitudeKm<6. && sd.y>70. && length(hit.xy)<5.){
      float glint=pow(max(0.,dot(reflect(-uSun,normalize(hit)), -rd)),32.);
      base+=vec3(1.,.78,.45)*glint*.29;
    }
  }
  vec4 obj=localObjects(ro,rd,tGround);
  float objectDistance=obj.a;
  if(objectDistance>0. && objectDistance<tGround){
    base=obj.rgb;
    tGround=objectDistance;
    ground=true;
  }
  vec3 transmittance;
  vec3 scat=atmosphere(ro,rd,tGround,transmittance);
  vec3 color=base*transmittance+scat;
  if(!ground){
    vec3 world=normalize(uEast*rd.x+uNorth*rd.y+uUp*rd.z);
    float stars=rndStar(world,310.)+.35*rndStar(world,670.);
    color+=vec3(.55,.65,.88)*stars*(1.-smoothstep(.16,.75,1.-length(transmittance)));
    float sunDisc=smoothstep(.99990,.99997,dot(rd,uSun));
    float sunHalo=pow(max(0.,dot(rd,uSun)),240.);
    color+=vec3(1.0,.76,.48)*(sunDisc*3.5+sunHalo*.45)*transmittance;
  }
  // Atmospheric limb comes from spherical density integration, not a painted sky.
  color=vec3(1.)-exp(-max(color,0.)*1.55);
  color=pow(color,vec3(.89));
  fragColor=vec4(clamp(color,0.,1.),1.);
}
