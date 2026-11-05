#version 300 es
precision highp float;
layout(location=0) in vec3 aScreen;
layout(location=1) in vec2 aUv;
layout(location=2) in float aShade;
layout(location=3) in vec4 aMaterial;
layout(location=4) in float aCategory;
uniform vec2 uProjection;
uniform float uAspect;
out vec2 vUv;
out float vShade;
out vec3 vPosition;
flat out vec4 vMaterial;
flat out float vCategory;
void main(){
    float z=max(1.0,aScreen.z),focal=uProjection.x*.85;
    vec2 ndc=vec2(aScreen.x/uProjection.x*2.0-1.0,1.0-aScreen.y/uProjection.y*2.0);
    ndc.y*=uAspect/(uProjection.x/uProjection.y);
    float nearPlane=50.0,farPlane=1000001.0;
    gl_Position=vec4(ndc*z,(farPlane+nearPlane)/(farPlane-nearPlane)*z-2.0*farPlane*nearPlane/(farPlane-nearPlane),z);
    vPosition=vec3((aScreen.x-uProjection.x*.5)*z/focal,(uProjection.y*.5-aScreen.y)*z/focal,z)*.01;
    vUv=aUv;vShade=aShade;vMaterial=aMaterial;vCategory=aCategory;
}
