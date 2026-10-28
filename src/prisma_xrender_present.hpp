#pragma once
// GLES draws the procedural backdrop and presents Ether Render X surface colors.
// Backdrop retained from PRISMA 1.1; no cube geometry or intersection shaders.
namespace reverse_pc {
inline constexpr char xrender_present_vertex[]=R"GLSL(#version 300 es
void main(){vec2 p=vec2((gl_VertexID<<1)&2,gl_VertexID&2);gl_Position=vec4(p*2.-1.,0.,1.);})GLSL";
inline constexpr char xrender_present_fragment[]=R"GLSL(#version 300 es
precision highp float;
uniform sampler2D surfaces;uniform vec2 resolution;uniform vec4 view;uniform vec3 green;uniform vec3 coral;
uniform float time;uniform float energy;uniform float quiet;out vec4 outColor;
float grid(float value,float width){float d=abs(fract(value-.5)-.5);return 1.-smoothstep(width,width+fwidth(value)*1.25,d);}
void main(){
 vec2 uv=vec2(gl_FragCoord.x/resolution.x,1.-gl_FragCoord.y/resolution.y);
 vec2 ray=(uv-view.xy)/view.zw;
 vec3 color=vec3(.008,.018,.014)+green*.013*exp(-dot(ray,ray)*1.6);
 float move=time*.65*(1.-quiet);
 if(ray.y>.025){
  float d=2.4/ray.y;float x=ray.x*d,z=d-4.8;
  if(z>=0.){
   float fade=exp(-z*.065);float lines=max(grid(x/.8,.003)*.10,grid(z/2.8+move,.002)*.08);
   color+=green*lines*fade;
   float rail=exp(-abs(abs(x)-2.8)*30.)*fade;
   color+=mix(green,coral,step(0.,x))*rail*(.24+energy*.09);
  }
 }
 if(abs(ray.x)>.05){
  float d=3.6/abs(ray.x),y=ray.y*d,z=d-4.8;
  if(z>=0.&&y> -2.7&&y<2.4)color+=green*grid(z/2.8+move,.002)*exp(-z*.065)*.035;
 }
 vec2 cell=floor(uv*vec2(180.,100.));float noise=fract(sin(dot(cell,vec2(127.1,311.7)))*43758.5453);
 float star=step(.9985,noise)*(1.-smoothstep(.0,.08,length(fract(uv*vec2(180.,100.))-.5)));
 color+=vec3(.2,.32,.24)*star;
 float vignette=smoothstep(.15,.85,length((uv-.5)*vec2(1.,.8)));
 color*=1.-vignette*.7;vec4 pixel=texture(surfaces,uv);outColor=vec4(mix(color,pixel.rgb,pixel.a),1.);
})GLSL";
}
