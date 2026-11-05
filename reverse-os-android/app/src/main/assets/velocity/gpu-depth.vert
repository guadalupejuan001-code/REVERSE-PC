#version 300 es
precision highp float;
invariant gl_Position;
layout(location=0) in vec3 aScreen;
uniform vec2 uProjection;
uniform float uAspect;
void main(){
    float z=max(1.0,aScreen.z);
    vec2 ndc=vec2(aScreen.x/uProjection.x*2.0-1.0,1.0-aScreen.y/uProjection.y*2.0);
    ndc.y*=uAspect/(uProjection.x/uProjection.y);
    float nearPlane=50.0,farPlane=1000001.0;
    gl_Position=vec4(ndc*z,(farPlane+nearPlane)/(farPlane-nearPlane)*z-2.0*farPlane*nearPlane/(farPlane-nearPlane),z);
}
