#version 300 es
precision highp float;
invariant gl_Position;
layout(location=0) in vec2 aScreenXY;
layout(location=4) in highp uint aZCategory;
uniform vec2 uProjection;
uniform float uAspect;
void main(){
    vec3 aScreen=vec3(aScreenXY,float(aZCategory&1048575u));
    float z=max(1.0,aScreen.z);
    vec2 ndc=vec2(aScreen.x/uProjection.x*2.0-1.0,1.0-aScreen.y/uProjection.y*2.0);
    ndc.y*=uAspect/(uProjection.x/uProjection.y);
    float nearPlane=50.0,farPlane=1000001.0;
    gl_Position=vec4(ndc*z,(farPlane+nearPlane)/(farPlane-nearPlane)*z-2.0*farPlane*nearPlane/(farPlane-nearPlane),z);
}
