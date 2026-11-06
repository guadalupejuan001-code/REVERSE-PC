#version 300 es
precision highp float;
in vec2 vUv;
uniform sampler2D uImage;
uniform vec2 uTexel;
uniform int uPhoto;
uniform int uQuality;
out vec4 color;
float luma(vec3 c){return dot(c,vec3(.299,.587,.114));}
void main(){
    vec2 uv=uPhoto==1?vec2(vUv.x,1.0-vUv.y):vUv;
    vec3 c=texture(uImage,uv).rgb;
    if(uQuality<3){color=vec4(c,1.0);return;}
    if(uPhoto==0){
        vec3 a=texture(uImage,uv+vec2(uTexel.x,0.0)).rgb,b=texture(uImage,uv-vec2(uTexel.x,0.0)).rgb;
        vec3 d=texture(uImage,uv+vec2(0.0,uTexel.y)).rgb,e=texture(uImage,uv-vec2(0.0,uTexel.y)).rgb;
        float edge=max(max(luma(a),luma(b)),max(luma(d),luma(e)))-min(min(luma(a),luma(b)),min(luma(d),luma(e)));
        c=mix(c,(a+b+d+e+c*2.0)/6.0,smoothstep(.09,.32,edge)*.36);
        vec3 glow=max(a-vec3(.82),vec3(0))+max(b-vec3(.82),vec3(0))+max(d-vec3(.82),vec3(0))+max(e-vec3(.82),vec3(0));
        if(uQuality>=4)c+=glow*.13;
        c*=1.0-.065*dot(vUv-.5,vUv-.5);
    }
    color=vec4(clamp(c,0.0,1.0),1.0);
}
