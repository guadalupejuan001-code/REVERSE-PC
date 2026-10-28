/* PRISMA GPU path. The indexed 24-vertex/36-index cube mesh and instanced
 * submission follow the owner's Graphics/COSMIC ObjectSceneRenderer:
 * mundo-X c375159fdb17e202e452af7bd0299b16a3ec6fff,
 * app/src/main/java/com/mundox/lab/ObjectSceneRenderer.java.
 * WebGL 2 is the browser binding of the GLES 3 pipeline. This is a port of
 * that mesh/submission design, not execution of QuantumRenderer or Ether. */
export const CUBE_FACES = [
 [-.5,-.5,.5,.5,-.5,.5,.5,.5,.5,-.5,.5,.5,0,0,1],
 [.5,-.5,-.5,-.5,-.5,-.5,-.5,.5,-.5,.5,.5,-.5,0,0,-1],
 [.5,-.5,.5,.5,-.5,-.5,.5,.5,-.5,.5,.5,.5,1,0,0],
 [-.5,-.5,-.5,-.5,-.5,.5,-.5,.5,.5,-.5,.5,-.5,-1,0,0],
 [-.5,.5,.5,.5,.5,.5,.5,.5,-.5,-.5,.5,-.5,0,1,0],
 [-.5,-.5,-.5,.5,-.5,-.5,.5,-.5,.5,-.5,-.5,.5,0,-1,0]
];
export function cubeMesh(){const out=new Float32Array(24*6);let p=0;for(const face of CUBE_FACES)for(let v=0;v<4;v++){out[p++]=face[v*3];out[p++]=face[v*3+1];out[p++]=face[v*3+2];out[p++]=face[12];out[p++]=face[13];out[p++]=face[14];}return out;}
export function cubeIndices(){const out=new Uint16Array(36);let p=0;for(let face=0;face<6;face++)for(const v of [0,1,2,0,2,3])out[p++]=face*4+v;return out;}
const VERTEX=`#version 300 es
precision highp float;
layout(location=0) in vec3 position;
layout(location=1) in vec3 normal;
layout(location=2) in vec4 centerSize;
layout(location=3) in vec4 colorAlpha;
layout(location=4) in vec4 rotationDirection;
uniform vec4 view;
out vec3 vLocal;out vec3 vNormal;out vec3 vColor;out float vAlpha;
flat out float vDirection;flat out float vHot;
void main(){
 float a=rotationDirection.x,c=cos(a),s=sin(a),cx=cos(-.11),sx=sin(-.11);
 mat3 ry=mat3(c,0.,-s,0.,1.,0.,s,0.,c);
 mat3 rx=mat3(1.,0.,0.,0.,cx,sx,0.,-sx,cx);
 vec3 p=rx*ry*position*centerSize.w+centerSize.xyz;
 float d=max(.5,p.z+4.8);
 vec2 clip=(view.xy*2.-1.)*d+p.xy*view.zw*2.;clip.y=-clip.y;
 gl_Position=vec4(clip,(60.5/59.5)*d-60./59.5,d);
 vLocal=position;vNormal=normal;vColor=colorAlpha.rgb;vAlpha=colorAlpha.a;
 vDirection=rotationDirection.y;vHot=rotationDirection.z;
}`;
const FRAGMENT=`#version 300 es
precision highp float;
in vec3 vLocal;in vec3 vNormal;in vec3 vColor;in float vAlpha;
flat in float vDirection;flat in float vHot;out vec4 outColor;
float segment(vec2 p,vec2 a,vec2 b){vec2 d=b-a;return length(p-a-d*clamp(dot(p-a,d)/dot(d,d),0.,1.));}
void main(){
 vec2 uv=abs(vNormal.z)>.5?vLocal.xy:abs(vNormal.x)>.5?vLocal.zy:vLocal.xz;
 float border=.5-max(abs(uv.x),abs(uv.y));
 float aa=max(fwidth(border)*1.2,.0025);
 float edge=1.-smoothstep(.004,.013+aa,border);
 float inset=(1.-smoothstep(.003,.006+aa,abs(border-.055)))*.18;
 float light=.12+max(dot(vNormal,normalize(vec3(-.4,-.6,-1.))),0.)*.20;
 vec3 base=vColor*(light+(.5-uv.y)*.09)+vec3(.003,.010,.006);
 vec3 color=mix(base,vColor*(.75+vHot*.38),max(edge,inset));
 if(vNormal.z<-.5){
  float a=vDirection*1.570796327;mat2 r=mat2(cos(a),-sin(a),sin(a),cos(a));vec2 p=r*uv;
  float arrow=min(segment(p,vec2(0.,-.155),vec2(0.,.175)),min(segment(p,vec2(-.14,-.015),vec2(0.,-.155)),segment(p,vec2(.14,-.015),vec2(0.,-.155))));
  float ink=1.-smoothstep(.009,.016+aa,arrow);
  color+=vColor*.15*exp(-arrow*34.);color=mix(color,mix(vColor,vec3(.93,1.,.96),vHot*.75),ink);
  if(vHot>.5){float ring=length(uv);color+=vColor*.025*(1.-smoothstep(.1,.5,ring));}
 }
 outColor=vec4(color,vAlpha);
}`;
const BACK_VERTEX=`#version 300 es
void main(){vec2 p=vec2((gl_VertexID<<1)&2,gl_VertexID&2);gl_Position=vec4(p*2.-1.,0.,1.);}`;
const BACK_FRAGMENT=`#version 300 es
precision highp float;
uniform vec2 resolution;uniform vec4 view;uniform vec3 green;uniform vec3 coral;
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
 color*=1.-vignette*.7;outColor=vec4(color,1.);
}`;
export class CubeGPU {
 static create(parent){const canvas=document.createElement('canvas');canvas.className='gpu-canvas';canvas.setAttribute('aria-hidden','true');try{const renderer=new CubeGPU(canvas);parent.insertBefore(canvas,parent.firstChild);return renderer;}catch(error){console.warn('PRISMA: Canvas fallback',error.message);canvas.remove();return null;}}
 constructor(canvas){
  const gl=canvas.getContext('webgl2',{alpha:false,antialias:false,depth:true,powerPreference:'high-performance',preserveDrawingBuffer:false});
  if(!gl)throw new Error('WebGL 2 no disponible');this.gl=gl;this.canvas=canvas;this.capacity=256;this.data=new Float32Array(this.capacity*12);this.count=0;this.lost=false;this.onFailure=null;
  this.program=this.link(VERTEX,FRAGMENT);this.background=this.link(BACK_VERTEX,BACK_FRAGMENT);
  this.cubeVao=gl.createVertexArray();gl.bindVertexArray(this.cubeVao);
  const mesh=gl.createBuffer();gl.bindBuffer(gl.ARRAY_BUFFER,mesh);gl.bufferData(gl.ARRAY_BUFFER,cubeMesh(),gl.STATIC_DRAW);
  for(let i=0;i<2;i++){gl.enableVertexAttribArray(i);gl.vertexAttribPointer(i,3,gl.FLOAT,false,24,i*12);}
  const indices=gl.createBuffer();gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER,indices);gl.bufferData(gl.ELEMENT_ARRAY_BUFFER,cubeIndices(),gl.STATIC_DRAW);
  this.instances=gl.createBuffer();gl.bindBuffer(gl.ARRAY_BUFFER,this.instances);gl.bufferData(gl.ARRAY_BUFFER,this.data.byteLength,gl.DYNAMIC_DRAW);
  for(let i=2;i<5;i++){gl.enableVertexAttribArray(i);gl.vertexAttribPointer(i,4,gl.FLOAT,false,48,(i-2)*16);gl.vertexAttribDivisor(i,1);}
  this.backgroundVao=gl.createVertexArray();gl.bindVertexArray(null);
  this.uniforms={};for(const name of ['view'])this.uniforms[name]=gl.getUniformLocation(this.program,name);
  this.bgUniforms={};for(const name of ['resolution','view','green','coral','time','energy','quiet'])this.bgUniforms[name]=gl.getUniformLocation(this.background,name);
  canvas.addEventListener('webglcontextlost',event=>{event.preventDefault();this.lost=true;this.onFailure?.();});
 }
 link(vertex,fragment){const g=this.gl,shaders=[];try{for(const [type,source]of [[g.VERTEX_SHADER,vertex],[g.FRAGMENT_SHADER,fragment]]){const shader=g.createShader(type);shaders.push(shader);g.shaderSource(shader,source);g.compileShader(shader);if(!g.getShaderParameter(shader,g.COMPILE_STATUS))throw new Error(g.getShaderInfoLog(shader));}const p=g.createProgram();for(const shader of shaders)g.attachShader(p,shader);g.linkProgram(p);if(!g.getProgramParameter(p,g.LINK_STATUS))throw new Error(g.getProgramInfoLog(p));return p;}finally{for(const shader of shaders)g.deleteShader(shader);}}
 resize(width,height){if(this.canvas.width!==width||this.canvas.height!==height){this.canvas.width=width;this.canvas.height=height;}this.gl.viewport(0,0,width,height);}
 begin(time,energy,view,colors,quiet){
  const g=this.gl,u=this.bgUniforms;this.count=0;this.view=view;
  g.disable(g.DEPTH_TEST);g.disable(g.BLEND);g.depthMask(true);g.clearColor(0,0,0,1);g.clear(g.COLOR_BUFFER_BIT|g.DEPTH_BUFFER_BIT);
  g.useProgram(this.background);g.bindVertexArray(this.backgroundVao);g.uniform2f(u.resolution,this.canvas.width,this.canvas.height);g.uniform4fv(u.view,view);g.uniform3fv(u.green,colors[0]);g.uniform3fv(u.coral,colors[1]);g.uniform1f(u.time,time);g.uniform1f(u.energy,energy);g.uniform1f(u.quiet,quiet?1:0);g.drawArrays(g.TRIANGLES,0,3);
 }
 cube(x,y,z,size,color,alpha,rotation,direction,hot){if(this.count>=this.capacity)return;const i=this.count++*12,d=this.data;d[i]=x;d[i+1]=y;d[i+2]=z;d[i+3]=size;d[i+4]=color[0];d[i+5]=color[1];d[i+6]=color[2];d[i+7]=alpha;d[i+8]=rotation;d[i+9]=direction;d[i+10]=hot?1:0;d[i+11]=0;}
 flush(){const g=this.gl;if(!this.count)return;g.useProgram(this.program);g.bindVertexArray(this.cubeVao);g.bindBuffer(g.ARRAY_BUFFER,this.instances);g.bufferSubData(g.ARRAY_BUFFER,0,this.data,0,this.count*12);g.uniform4fv(this.uniforms.view,this.view);g.enable(g.DEPTH_TEST);g.depthFunc(g.LEQUAL);g.disable(g.CULL_FACE);g.enable(g.BLEND);g.blendFunc(g.SRC_ALPHA,g.ONE_MINUS_SRC_ALPHA);g.drawElementsInstanced(g.TRIANGLES,36,g.UNSIGNED_SHORT,0,this.count);g.bindVertexArray(null);}
}
export const SHADERS={VERTEX,FRAGMENT,BACK_VERTEX,BACK_FRAGMENT};
