#version 300 es
precision highp float;
in vec2 vUv;
out vec4 fragColor;

uniform vec2 uResolution;
uniform float uTime;
uniform float uMode;
uniform float uGlitch;
uniform float uWarp;
uniform float uSpeed;
uniform vec2 uCamera;
uniform vec2 uTouch;
uniform float uPulse;
uniform float uZoom;

const float PI = 3.14159265358979;
const float TAU = 6.28318530717959;
const vec3 VIOLET = vec3(0.38,0.18,1.00);
const vec3 BLUE   = vec3(0.09,0.35,1.00);

float hash(vec2 p) {
  return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453123);
}
float noise(vec2 p) {
  vec2 i=floor(p),f=fract(p);
  f=f*f*(3.0-2.0*f);
  float a=hash(i),b=hash(i+vec2(1.,0.));
  float c=hash(i+vec2(0.,1.)),d=hash(i+1.);
  return mix(mix(a,b,f.x),mix(c,d,f.x),f.y);
}
mat2 rotate2(float angle) {
  float s=sin(angle),c=cos(angle);
  return mat2(c,-s,s,c);
}
float glow(float d,float k) { return exp(-abs(d)*k); }
float pointGlow(vec2 p,float radius) {
  float r=length(p);
  return exp(-r*r/max(0.00004,radius*radius));
}
float starLayer(vec2 uv,float scale,float t) {
  vec2 g=uv*scale;
  vec2 i=floor(g),f=fract(g)-0.5;
  float id=hash(i);
  vec2 center=vec2(hash(i+15.8),hash(i+29.3))-0.5;
  float d=length(f-center*0.64);
  return (1.0-smoothstep(.016,.053,d))*step(.970,id)*
          (.67+.33*sin(t*(.32+id*.8)+id*30.0));
}
float orbit(vec2 p,vec2 radii,float angle,float speed,float t,float width) {
  vec2 q=rotate2(angle+speed*t)*p;
  float d=length(q/radii)-1.0;
  return exp(-abs(d)*width);
}
float orbitNode(vec2 p,vec2 radii,float phase,float speed,float t) {
  float angle=phase+speed*t;
  vec2 pos=rotate2(0.09)*vec2(radii.x*cos(angle),radii.y*sin(angle));
  return pointGlow(p-pos,.024);
}
void main() {
  vec2 uv=vUv;
  float aspect=uResolution.x/max(uResolution.y,1.0);
  vec2 p=(uv-0.5)*vec2(2.0*aspect,2.0);
  p-=uCamera*.09;
  float t=uTime*(.20+.8*uSpeed);

  // Native procedural field: the same rule describes every pixel;
  // no dense 2D simulation state and no CPU per-pixel painting.
  float radius=length(p-vec2(0.,.015));
  float angle=atan(p.y,p.x);
  vec2 sphereP=p-vec2(0.,.015);
  float n=noise(sphereP*8.8+vec2(.14*t,-.06*t));
  float swirl=sin(sphereP.y*18.0+5.8*sin(sphereP.x*4.8+.24*t)+t*.3);

  vec3 color=vec3(.0024,.0028,.011);
  // Sparse starfield; stable spatial addresses, time-driven only for twinkle.
  color+=vec3(.31,.30,.70)*starLayer(uv,78.0,t)*.24;
  color+=vec3(.16,.27,.74)*starLayer(uv*1.83,49.0,t)*.18;

  // Sparse cosmic arc energy: broad azimuth bands that drift over time.
  vec2 tilt=rotate2(.14)*p;
  float layer=exp(-pow((tilt.y-.20*sin(tilt.x*2.15+.27*t))/.19,2.0));
  float plasma=(.30+.7*noise(tilt*2.8+vec2(t*.16,-t*.07)));
  float sweep=pow(.5+.5*sin(16.0*tilt.x-4.7*tilt.y-t*.92),8.0);
  color+=vec3(.008,.013,.054)*layer*plasma;
  color+=vec3(.027,.020,.115)*layer*sweep;

  // Glowing central orb with an actual evolving atmospheric pattern.
  float disc=1.0-smoothstep(.536,.555,radius);
  float lava=noise(sphereP*12.0+vec2(-.09*t,.12*t));
  float textureMix=clamp(.36*n+.34*lava+.30*(swirl*.5+.5),0.0,1.0);
  float topLight=.25+.75*smoothstep(-.60,.56,sphereP.y);
  vec3 inside=mix(vec3(.008,.012,.053),vec3(.030,.041,.22),textureMix*topLight);
  float midBand=pow(max(.0,1.0-abs(sin(angle*7.0+radius*25.0-.14*t))),14.0);
  inside+=vec3(.027,.014,.115)*midBand*textureMix;
  color=mix(color,inside,disc);

  // Planet rim: sharp physical silhouette, delicate bloom outside.
  float rim=glow(radius-.550,88.0);
  float outer=glow(radius-.555,18.5);
  vec3 electric=mix(BLUE,VIOLET,clamp(.62+.32*sin(angle*1.25+t*.16),0.,1.));
  color+=electric*(rim*.81+outer*.22);
  color+=vec3(.28,.32,1.)*rim*rim*.32;

  // Three distinct, non-copying orbital rule families.
  float ring1=orbit(p,vec2(1.31,.285),.10,.018,t,205.0);
  float ring2=orbit(p,vec2(.99,.71),.035,-.021,t,258.0);
  float ring3=orbit(p,vec2(.77,.83),.0,.025,t,360.0);
  float dust=orbit(p,vec2(1.45,.325),.14,-.011,t,18.0);
  float glint=pow(.5+.5*sin(angle*22.0-t*1.25),38.0);
  color+=vec3(.10,.20,.74)*(ring1*.46+ring2*.16+ring3*.13);
  color+=vec3(.32,.14,.84)*ring1*.23;
  color+=vec3(.15,.10,.50)*dust*(.10+.37*glint);

  // Rules for moving particles riding the same ellipse.
  float satellites=0.0;
  satellites+=orbitNode(p,vec2(1.29,.285),.10,.18,t);
  satellites+=orbitNode(p,vec2(1.29,.285),2.12,.18,t);
  satellites+=orbitNode(p,vec2(1.29,.285),4.26,.18,t);
  satellites+=orbitNode(p,vec2(.96,.70),.32,-.13,t)*.7;
  satellites+=orbitNode(p,vec2(.96,.70),3.32,-.13,t)*.7;
  color+=vec3(.23,.35,1.0)*satellites*1.18;

  // A vertical quantum axis and its nodes, aligned to the user's reference.
  float vertical=exp(-abs(p.x)*340.0)*(1.0-smoothstep(.15,1.18,abs(p.y)));
  color+=vec3(.04,.09,.37)*vertical*.45;
  for(int k=0;k<5;k++){
    float y=float(k-2)*.375;
    float node=pointGlow(p-vec2(0.,y),.012);
    color+=vec3(.22,.26,.85)*node*.58;
  }
  float upper=pointGlow(p-vec2(0.,.55),.03);
  float lower=pointGlow(p-vec2(0.,-.55),.04);
  color+=vec3(.30,.27,.95)*(upper+lower)*.47;

  // Interaction emits a moving optical wave, independent of Ether state.
  vec2 q=(uTouch-.5)*vec2(2.0*aspect,2.0);
  float expansion=(1.0-uPulse)*1.8;
  float pulse=exp(-pow((length(p-q)-expansion)*37.0,2.0))*uPulse;
  color+=vec3(.12,.20,.65)*pulse*.65;

  float vignette=1.0-smoothstep(.55,2.15,length(p))*.40;
  color*=vignette;
  color=1.0-exp(-color*1.52);
  fragColor=vec4(clamp(color,0.0,1.0),1.0);
}
