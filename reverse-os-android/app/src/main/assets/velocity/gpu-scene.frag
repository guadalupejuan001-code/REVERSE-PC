#version 300 es
#ifndef REGRAPHICS_CLASS
#define REGRAPHICS_CLASS 0
#endif
precision highp float;
precision highp int;
in vec2 vUv;
in float vShade;
in vec3 vPosition;
flat in vec4 vMaterial;
flat in float vCategory;
uniform sampler2D uPalette;
uniform sampler2D uAtlas;
uniform float uTime,uDay,uWet,uWaterDepth;
uniform vec3 uLampOrigin,uLampDirection,uSunDirection;
uniform float uLampPower;
uniform int uQuality;
out vec4 color;
vec3 palette(float index){return texelFetch(uPalette,ivec2(int(clamp(index,0.0,255.0)),0),0).rgb;}
float hash(vec2 p){p=fract(p*vec2(.1031,.0973));p+=dot(p,p.yx+vec2(19.19,23.17));return fract(p.x*p.y*(p.x+p.y));}
float noise(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1)),f.x),f.y);}
float fbm(vec2 p){return noise(p)*.57+noise(p*2.07)*.28+noise(p*4.13)*.15;}
vec3 environment(vec3 r){
    vec3 sky=mix(vec3(.065,.11,.16),vec3(.55,.72,.79),uDay);
    vec3 forest=mix(vec3(.012,.025,.032),vec3(.055,.105,.075),uDay);
    float trees=sin(r.x*63.0)+sin(r.z*47.0)*.35;
    return mix(forest,sky,smoothstep(-.10,.32,r.y+trees*.035));
}
void main(){
    vec2 uv=vMaterial.w==4.0? vUv/vec2(64.0,16.0):vUv;
    float base=vMaterial.x,count=vMaterial.y,delta=0.0;
    if(vMaterial.w>0.0&&uQuality>0){
        vec2 tileUv=(vec2(vMaterial.z*16.0,0.0)+vec2(.5)+fract(uv/16.0)*15.0)/vec2(128.0,16.0);
        float texel=texture(uAtlas,tileUv).r*255.0;
        delta=(texel-8.0)*vMaterial.w/255.0;
    }
    float level=clamp(vShade+delta,0.0,1.0)*(count-1.0),low=floor(level);
    vec3 rgb=mix(palette(base+low),palette(base+min(low+1.0,count-1.0)),fract(level));
    // Economy/basic modes retain the authored XI colors and event geometry,
    // while avoiding derivative PBR, procedural sky and animated reflections.
    if(uQuality<2){
        float alpha=1.0;
        if(vCategory<.5){color=vec4(rgb,1.0);return;}
        if(vCategory==2.0)alpha=.10+vShade*.42;
        else if(vCategory==3.0)alpha=.76;
        else if(vCategory==9.0)alpha=.22;
        else if(vCategory==11.0)alpha=uQuality==0?0.0:.014*uLampPower;
        else if(vCategory>=4.0&&vCategory<8.0){
            float side=sin(clamp(uv.x/16.0,0.0,1.0)*3.14159265);
            alpha=max(0.0,side)*(.08+vShade*.42);
            if(vCategory==5.0)rgb=vec3(.10,.55,1.0)*(1.0+vShade*.6);
        }
        if(base==224.0||base==225.0)rgb*=1.8;
        float haze=max(0.0,vPosition.z-70.0)*.0036;
        if(vCategory<4.0||vCategory==8.0||vCategory==9.0)rgb=mix(rgb,palette(4.0),haze/(1.0+haze)*.68);
        color=vec4(max(rgb,vec3(0.0)),alpha);return;
    }
#if REGRAPHICS_CLASS == 1
    if(true){
#elif REGRAPHICS_CLASS == 2
    if(false){
#else
    if(vCategory<.5){
#endif
        if(base<7.0&&uQuality>=3){
            vec3 direction=normalize(vPosition);vec2 sky=direction.xz/max(.12,abs(direction.y));
            float clouds=smoothstep(.48,.78,noise(sky*.48+vec2(uTime*.003,0)))*smoothstep(-.02,.35,direction.y);
            rgb=mix(rgb,vec3(.77,.81,.79)*(.22+.78*uDay),clouds*.62);
            vec3 sun=uSunDirection;
            float alignment=max(dot(direction,sun),0.0);float halo=smoothstep(.94,1.0,alignment),disc=smoothstep(.998,1.0,alignment);
            rgb+=vec3(1.0,.83,.58)*(halo*.18+disc*.6)*uDay;
            float stars=step(.9988,hash(floor(direction.xz/max(.05,direction.y)*500.0)))*smoothstep(.12,.5,direction.y)*(1.0-uDay);
            rgb+=stars*.32;
        }color=vec4(rgb,1.0);return;
    }
    // Terrain and foliage use XI's authored light scalar. Save derivative PBR for the car and water.
#if REGRAPHICS_CLASS == 2
    if(true){
#elif REGRAPHICS_CLASS == 1
    if(false){
#else
    if((base>=9.0&&base<24.0)||(base>=40.0&&base<56.0)){
#endif
        vec3 groundNormal=cross(dFdx(vPosition),dFdy(vPosition));float groundLight=abs(dot(groundNormal,uSunDirection))*inversesqrt(max(1e-12,dot(groundNormal,groundNormal)));rgb*=.78+.22*groundLight;
        if(base>=12.0&&base<20.0&&uQuality>=3){float patches=noise(uv*.025);rgb*=.78+patches*.35+hash(floor(uv*1.6))*.055;}
        if(base>=9.0&&base<12.0){
            if(uQuality>=3)rgb*=.78+hash(floor(uv*3.7))*.12+noise(uv*.06)*.25;
            else rgb*=.9+hash(floor(uv*3.7))*.08;
            if(vMaterial.w==4.0){
                float lateral=clamp(uv.x/16.0,0.0,1.0),edge=smoothstep(0.0,.14,lateral)*smoothstep(0.0,.14,1.0-lateral);
                float ruts=(1.0-smoothstep(.01,.10,abs(lateral-.27)))+(1.0-smoothstep(.01,.10,abs(lateral-.73)));
                rgb*=1.0-ruts*.24;rgb=mix(palette(14.0)*.8,rgb,edge);
            }
        }
        if(uLampPower>0.0){vec3 D=vPosition-uLampOrigin,axis=normalize(uLampDirection);float along=dot(D,axis),radial=length(D-axis*along);float cone=(1.0-smoothstep(.35+max(0.0,along)*.10,.8+max(0.0,along)*.22,radial))*step(0.0,along);rgb+=vec3(.75,.88,1.0)*uLampPower*cone*(1.0-smoothstep(9.0,42.0,along))*.55;}
        float haze=max(0.0,vPosition.z-70.0)*.0036;rgb=mix(rgb,palette(4.0),haze/(1.0+haze)*.68);
        color=vec4(max(rgb,vec3(0)),1.0);return;
    }
    vec3 V=normalize(-vPosition),normal=cross(dFdx(vPosition),dFdy(vPosition));
    vec3 N=dot(normal,normal)>1e-12?normalize(normal):vec3(0.0,1.0,0.0);
    if(dot(N,V)<0.0)N=-N;
    vec3 L=uSunDirection;
    float diffuse=max(dot(N,L),0.0),fresnel=pow(1.0-max(dot(N,V),0.0),5.0);
    vec3 R=reflect(-V,N);float alpha=1.0;
    bool paint=base>=64.0&&base<184.0,glass=base>=184.0&&base<208.0;
    bool metal=(base>=212.0&&base<224.0)||base==241.0;
    if(vCategory==9.0){rgb=mix(base==221.0?vec3(.65,.035,.055):vec3(.55,.77,.94),environment(R),.35)+vec3(.15)*fresnel;alpha=.22;}
    else if(vCategory==11.0){rgb=vec3(.64,.83,1.0);alpha=uQuality>=3?.014*uLampPower*(1.0-smoothstep(2.0,22.0,length(vPosition-uLampOrigin))):0.0;}
    else if(paint||glass||metal){
        float rough=paint?mix(.24,.12,uWet):glass?.09:.19;
        float spec=pow(max(dot(N,normalize(L+V)),0.0),mix(24.0,160.0,1.0-rough));
        if(paint){
            rgb=mix(rgb,palette(base+count-4.0),.32)*(.72+diffuse*.28);
            rgb=mix(rgb,environment(R),.13+fresnel*.32+uWet*.08);
        }else if(glass)rgb=mix(rgb*.65,environment(R),.34+fresnel*.55);
        else rgb=rgb*(.6+diffuse*.4)+environment(R)*.16;
        rgb+=vec3(1.0,.97,.9)*spec*(paint?.52:.8)*(.28+.72*uDay);
    }else if(vCategory==3.0){
        float wave=sin(uv.x*.18+uTime*1.7)+cos(uv.y*.21-uTime*1.3);
        N=normalize(N+vec3(wave*.06,0.0,sin(uv.x*.13+uTime)*.09));R=reflect(-V,N);
        fresnel=pow(1.0-max(dot(N,V),0.0),3.0);
        rgb=mix(rgb*.66,environment(R),.3+fresnel*.48);
        rgb+=vec3(.55,.7,.73)*pow(max(dot(N,normalize(L+V)),0.0),110.0)*.5;
        alpha=.76;
    }else if(vCategory==2.0){
        rgb=vec3(.018,.029,.027);alpha=.10+vShade*.42;
    }else if(vCategory>=4.0&&vCategory<8.0){
        float flow=.72+.28*sin(uv.y*.7+uTime*24.0);
        if(vCategory==5.0){
            float side=sin(clamp(uv.x/16.0,0.0,1.0)*3.14159265),tail=1.0-smoothstep(.55,1.0,uv.y/64.0);
            rgb=mix(vec3(.02,.18,.9),vec3(.45,.88,1.0),vShade)*1.65;
            alpha=pow(max(0.0,side),.8)*tail*vShade*.68*flow;
        }else if(vCategory==4.0){
            float side=sin(clamp(uv.x/16.0,0.0,1.0)*3.14159265),tail=1.0-smoothstep(.70,1.0,uv.y/64.0);
            rgb=vec3(.55,.79,.95);alpha=max(0.0,side)*tail*(.06+vShade*.42)*flow;
        }
        else {rgb=vCategory==6.0?mix(vec3(.35,.3,.2),vec3(.7,.86,.9),step(.5,uWaterDepth)):vec3(.43,.36,.26);alpha=(.04+vShade*.34)*flow;}
    }else{
        rgb*=.76+.24*diffuse;

    }
    if(uLampPower>0.0&&(vCategory<4.0||vCategory==8.0)){
        vec3 D=vPosition-uLampOrigin,axis=normalize(uLampDirection);float along=dot(D,axis),radial=length(D-axis*along);
        float cone=(1.0-smoothstep(.35+max(0.0,along)*.10,.8+max(0.0,along)*.22,radial))*step(0.0,along);
        float reach=1.0-smoothstep(9.0,42.0,along);
        rgb+=vec3(.75,.88,1.0)*uLampPower*cone*reach*(.24+.5*abs(dot(N,normalize(-D))));
    }
    if(base==242.0)rgb=vec3(.88,.035,.065);
    if(base==224.0||base==225.0)rgb*=2.3;
    float fog=1.0-exp(-max(0.0,vPosition.z-70.0)*.0036);
    if(vCategory<4.0||vCategory==8.0||vCategory==9.0)rgb=mix(rgb,palette(4.0),fog*.68);
    color=vec4(max(rgb,vec3(0.0)),alpha);
}
