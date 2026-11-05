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
export function noteGeometry(){
 const vertices=[],indices=[],b=.455;
 const face=(points,n)=>{const start=vertices.length/6;for(const p of points)vertices.push(...p,...n);for(let i=1;i<points.length-1;i++)indices.push(start,start+i,start+i+1);};
 for(let axis=0;axis<3;axis++)for(const sign of [-1,1]){
  const other=[0,1,2].filter(x=>x!==axis),points=[[-b,-b],[b,-b],[b,b],[-b,b]].map(v=>{const p=[0,0,0];p[axis]=sign*.5;p[other[0]]=v[0];p[other[1]]=v[1];return p;});const n=[0,0,0];n[axis]=sign;face(points,n);
 }
 for(let axis=0;axis<3;axis++)for(const sa of [-1,1])for(const sb of [-1,1]){
  const [a,c]=[0,1,2].filter(x=>x!==axis),points=[];
  for(const [end,wide]of [[-b,true],[-b,false],[b,false],[b,true]]){const p=[0,0,0];p[axis]=end;p[a]=sa*(wide?.5:b);p[c]=sb*(wide?b:.5);points.push(p);}const n=[0,0,0];n[a]=sa/Math.sqrt(2);n[c]=sb/Math.sqrt(2);face(points,n);
 }
 for(const x of [-1,1])for(const y of [-1,1])for(const z of [-1,1])face([[x*.5,y*b,z*b],[x*b,y*.5,z*b],[x*b,y*b,z*.5]],[x/Math.sqrt(3),y/Math.sqrt(3),z/Math.sqrt(3)]);
 return {vertices:new Float32Array(vertices),indices:new Uint16Array(indices)};
}
const VERTEX=`#version 300 es
precision highp float;
layout(location=0) in vec3 position;
layout(location=1) in vec3 normal;
layout(location=2) in vec4 centerSize;
layout(location=3) in vec4 colorAlpha;
layout(location=4) in vec4 rotationDirection;
uniform vec4 view;
out vec3 vLocal;out vec3 vNormal;out vec3 vColor;out float vAlpha;
flat out float vDirection;flat out float vHot;flat out float vMaterial;
void main(){
 float a=rotationDirection.x,c=cos(a),s=sin(a),cx=cos(-.11),sx=sin(-.11);
 mat3 ry=mat3(c,0.,-s,0.,1.,0.,s,0.,c);
 mat3 rx=mat3(1.,0.,0.,0.,cx,sx,0.,-sx,cx);
 vec3 p=rx*ry*position*centerSize.w+centerSize.xyz;
 float d=max(.5,p.z+4.8);
 vec2 clip=(view.xy*2.-1.)*d+p.xy*view.zw*2.;clip.y=-clip.y;
 gl_Position=vec4(clip,(60.5/59.5)*d-60./59.5,d);
 vLocal=position;vNormal=rx*ry*normal;vColor=colorAlpha.rgb;vAlpha=colorAlpha.a;
 vDirection=rotationDirection.y;vHot=rotationDirection.z;vMaterial=rotationDirection.w;
}`;
const FRAGMENT=`#version 300 es
precision highp float;
in vec3 vLocal;in vec3 vNormal;in vec3 vColor;in float vAlpha;
flat in float vDirection;flat in float vHot;flat in float vMaterial;out vec4 outColor;
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
 // Reference material approximation. Native Ether Render X resolves actual
 // cube intersections and independently shades the corresponding materials.
 if(vMaterial>.5){
   vec3 n=normalize(vNormal);
   float facing=abs(n.z);
   float fresnel=pow(1.-facing,5.);
   float shine=pow(max(dot(n,normalize(vec3(-.25,-.45,.86))),0.),18.);
   if(vMaterial<1.5){ // faceted prismatic note
     float diffuse=max(dot(n,normalize(vec3(-.4,-.6,-1.))),0.);
     float gloss=pow(max(dot(n,normalize(vec3(-.2,-.35,-1.))),0.),48.);
     color=vColor*(.15+.43*diffuse+.19*fresnel)+vec3(.56,.74,.82)*gloss*.16;
     color=mix(color,mix(vColor*1.05,vec3(.93,1.,.97),vHot*.35),max(edge,inset));
   }else if(vMaterial<2.5){ // brushed metal stage support
     float grain=.5+.5*cos(uv.x*45.);
     color=vColor*(.24+.29*max(n.z,0.)+.36*shine*(.75+.25*grain)+.14*fresnel);
     color=mix(color,vColor*.70,edge);
   }else { // luminous concert lens
     float core=exp(-dot(uv,uv)*8.);
     color=vColor*(.13+.80*core+.12*shine+.10*fresnel);
     color=mix(color,vColor*.33,edge);
   }
 }
 if(vNormal.z<-.9 && vDirection>=0.){
  float a=vDirection*1.570796327;mat2 r=mat2(cos(a),-sin(a),sin(a),cos(a));vec2 p=r*uv;
  float arrow=min(segment(p,vec2(0.,-.155),vec2(0.,.175)),min(segment(p,vec2(-.14,-.015),vec2(0.,-.155)),segment(p,vec2(.14,-.015),vec2(0.,-.155))));
  float ink=1.-smoothstep(.009,.016+aa,arrow);
  color+=vColor*.15*exp(-arrow*34.);color=mix(color,vec3(.93,1.,.96),ink);
  if(vHot>.5){float ring=length(uv);color+=vColor*.025*(1.-smoothstep(.1,.5,ring));}
 }
 // Playable bodies stay opaque: an almost transparent cube must not write
 // invisible depth and erase the next arrival. Alpha modulates its glow.
 outColor=vec4(color*(vDirection>=0.?mix(.70,1.,vAlpha):1.),vDirection>=0.?1.:vAlpha);
}`;
const WORLD_VERTEX=`#version 300 es
precision highp float;
layout(location=0) in vec3 position;layout(location=1) in vec3 normal;
layout(location=2) in vec3 color;layout(location=3) in vec3 surface;
uniform vec4 view;uniform float time;uniform float energy;uniform float quiet;
out vec3 vNormal;out vec3 vColor;out vec3 vPosition;out float vEmission;out float vMotion;
void main(){
 vec3 p=position,n=normal;float t=time*(1.-quiet),mode=surface.y;
 if(mode>1.5&&mode<2.5){float a=sin(t*.13+position.z*.1)*.12,c=cos(a),s=sin(a);p.xz=mat2(c,-s,s,c)*p.xz;n.xz=mat2(c,-s,s,c)*n.xz;}
 if(mode>2.5&&mode<3.5)p.y+=sin(t*.7+p.x)*.12;
 if(mode>3.5&&mode<4.5)p.z-=energy*.05*(1.-quiet);
 if(mode>4.5&&mode<5.5)p.y+=sin(p.x*.3+t*.25)*.24;
 if(mode>5.5&&mode<6.5)p.y+=sin(p.x*.7+p.z*.5+t*.8)*.025;
 float d=max(.5,p.z+4.8);vec2 clip=(vec2(.5,.49)*2.-1.)*d+p.xy*view.zw*2.;clip.y=-clip.y;
 gl_Position=vec4(clip,(120.5/119.5)*d-120./119.5,d);
 vNormal=n;vColor=color;vPosition=p;vEmission=surface.x;vMotion=mode;
}`;
const WORLD_FRAGMENT=`#version 300 es
precision highp float;
in vec3 vNormal;in vec3 vColor;in vec3 vPosition;in float vEmission;in float vMotion;
uniform float time;uniform float energy;uniform float quiet;uniform float opacity;
out vec4 outColor;
void main(){
 vec3 n=normalize(vNormal),v=normalize(vec3(0.,0.,-4.8)-vPosition);
 if(dot(n,v)<0.)n=-n;
 vec3 l=normalize(vec3(-.45,-.7,-1.)),h=normalize(l+v);
 float diffuse=max(dot(n,l),0.),spec=pow(max(dot(n,h),0.),40.);
 float fresnel=pow(1.-max(dot(n,v),0.),3.);
 float pulse=.64+energy*.55;
 if(vMotion>.5&&vMotion<1.5)pulse*=.70+.30*sin(time*4.+vPosition.y*3.+vPosition.x*4.)*(1.-quiet);
 vec3 col=vColor*(.18+diffuse*.64)+vec3(.62,.78,.90)*spec*.35+vColor*fresnel*.14;
 col+=vColor*vEmission*pulse;
 float fog=1.-exp(-max(0.,vPosition.z)*.016);
 col=mix(col,vec3(.012,.020,.043),fog*.65);
 col=col/(vec3(1.)+col*.35);
 float alpha=vMotion>4.5&&vMotion<5.5?.30:1.;
 outColor=vec4(col,opacity*alpha);
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
 // Bounded cosmic cloud and distant stage atmosphere (no stochastic frames).
 vec3 color=vec3(.006,.008,.020)+green*.013*exp(-dot(ray,ray)*1.6);
 vec2 nebulaA=(uv-vec2(.16+.016*sin(time*.05),.19))*vec2(1.1,2.2);
 vec2 nebulaB=(uv-vec2(.87+.012*cos(time*.04),.32))*vec2(1.2,2.6);
 float cloudA=exp(-dot(nebulaA,nebulaA)*4.4);
 float cloudB=exp(-dot(nebulaB,nebulaB)*5.0);
 float veil=(.7+.3*sin(uv.x*11.3-uv.y*9.2+time*.10));
 color+=(vec3(.048,.026,.14)*cloudA+vec3(.01,.07,.13)*cloudB)*veil*(1.-quiet*.82);
 float halo=exp(-pow(length((uv-vec2(.5,.20))*vec2(1.,1.8))-.33,2.)*86.);
 color+=mix(green,coral,.42)*halo*(.006+.009*energy)*(1.-quiet*.65);
 float move=time*.65*(1.-quiet);
 if(ray.y>.025){
  float d=2.4/ray.y;float x=ray.x*d,z=d-4.8;
  if(z>=0.){
   float fade=exp(-z*.065);float lines=max(grid(x/.8,.003)*.10,grid(z/2.8+move,.002)*.08);
   color+=green*lines*fade;
   float rail=exp(-abs(abs(x)-2.8)*30.)*fade;
   color+=mix(green,coral,step(0.,x))*rail*(.24+energy*.09);
   // Bounded floor specular bands / reflections; a stylized backdrop, not
   // reflections traced against the native objects.
   float sheen=exp(-abs(x)*.42)*exp(-z*.09);
   float panels=pow(.5+.5*cos(x*3.14159+z*.46),18.)*fade;
   color+=mix(green,coral,.5+.5*sin(z*.18))*(.014*panels+sheen*(.007+.011*energy));
  }
 }
 if(abs(ray.x)>.05){
  float d=3.6/abs(ray.x),y=ray.y*d,z=d-4.8;
  if(z>=0.&&y> -2.7&&y<2.4)color+=green*grid(z/2.8+move,.002)*exp(-z*.065)*.035;
 }
 vec2 cell=floor(uv*vec2(180.,100.));float noise=fract(sin(dot(cell,vec2(127.1,311.7)))*43758.5453);
 float star=step(.9985,noise)*(1.-smoothstep(.0,.08,length(fract(uv*vec2(180.,100.))-.5)));
 // Tiny stars, tinted by distance; never a full-screen beat flash.
 color+=mix(vec3(.32,.42,.86),vec3(.58,.84,.90),noise)*star*(1.-quiet*.55);
 float vignette=smoothstep(.15,.85,length((uv-.5)*vec2(1.,.8)));
 color*=1.-vignette*.7;outColor=vec4(color,1.);
}`;
export class CubeGPU {
 static create(parent){const canvas=document.createElement('canvas');canvas.className='gpu-canvas';canvas.setAttribute('aria-hidden','true');try{const renderer=new CubeGPU(canvas);parent.insertBefore(canvas,parent.firstChild);return renderer;}catch(error){console.warn('PRISMA: Canvas fallback',error.message);canvas.remove();return null;}}
 constructor(canvas){
  const gl=canvas.getContext('webgl2',{alpha:false,antialias:true,depth:true,powerPreference:'high-performance',preserveDrawingBuffer:false});
  if(!gl)throw new Error('WebGL 2 no disponible');this.gl=gl;this.canvas=canvas;this.capacity=256;this.data=new Float32Array(this.capacity*12);this.count=0;this.lost=false;this.onFailure=null;
  this.program=this.link(VERTEX,FRAGMENT);this.background=this.link(BACK_VERTEX,BACK_FRAGMENT);this.mesh3D=true;this.worlds=new Map();this.worldProgram=this.link(WORLD_VERTEX,WORLD_FRAGMENT);
  this.cubeVao=gl.createVertexArray();gl.bindVertexArray(this.cubeVao);
  const geometry=noteGeometry();this.indexCount=geometry.indices.length;
  const mesh=gl.createBuffer();gl.bindBuffer(gl.ARRAY_BUFFER,mesh);gl.bufferData(gl.ARRAY_BUFFER,geometry.vertices,gl.STATIC_DRAW);
  for(let i=0;i<2;i++){gl.enableVertexAttribArray(i);gl.vertexAttribPointer(i,3,gl.FLOAT,false,24,i*12);}
  const indices=gl.createBuffer();gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER,indices);gl.bufferData(gl.ELEMENT_ARRAY_BUFFER,geometry.indices,gl.STATIC_DRAW);
  this.instances=gl.createBuffer();gl.bindBuffer(gl.ARRAY_BUFFER,this.instances);gl.bufferData(gl.ARRAY_BUFFER,this.data.byteLength,gl.DYNAMIC_DRAW);
  for(let i=2;i<5;i++){gl.enableVertexAttribArray(i);gl.vertexAttribPointer(i,4,gl.FLOAT,false,48,(i-2)*16);gl.vertexAttribDivisor(i,1);}
  this.backgroundVao=gl.createVertexArray();gl.bindVertexArray(null);
  this.uniforms={};for(const name of ['view'])this.uniforms[name]=gl.getUniformLocation(this.program,name);
  this.bgUniforms={};for(const name of ['resolution','view','green','coral','time','energy','quiet'])this.bgUniforms[name]=gl.getUniformLocation(this.background,name);
  this.worldUniforms={};for(const name of ['view','time','energy','quiet','opacity'])this.worldUniforms[name]=gl.getUniformLocation(this.worldProgram,name);
  canvas.addEventListener('webglcontextlost',event=>{event.preventDefault();this.lost=true;this.onFailure?.();});
 }
 link(vertex,fragment){const g=this.gl,shaders=[];try{for(const [type,source]of [[g.VERTEX_SHADER,vertex],[g.FRAGMENT_SHADER,fragment]]){const shader=g.createShader(type);shaders.push(shader);g.shaderSource(shader,source);g.compileShader(shader);if(!g.getShaderParameter(shader,g.COMPILE_STATUS))throw new Error(g.getShaderInfoLog(shader));}const p=g.createProgram();for(const shader of shaders)g.attachShader(p,shader);g.linkProgram(p);if(!g.getProgramParameter(p,g.LINK_STATUS))throw new Error(g.getProgramInfoLog(p));return p;}finally{for(const shader of shaders)g.deleteShader(shader);}}
 resize(width,height){if(this.canvas.width!==width||this.canvas.height!==height){this.canvas.width=width;this.canvas.height=height;}this.gl.viewport(0,0,width,height);}
 begin(time,energy,view,colors,quiet){
  const g=this.gl,u=this.bgUniforms;this.count=0;this.view=view;
  g.disable(g.DEPTH_TEST);g.disable(g.BLEND);g.depthMask(true);g.clearColor(0,0,0,1);g.clear(g.COLOR_BUFFER_BIT|g.DEPTH_BUFFER_BIT);
  g.useProgram(this.background);g.bindVertexArray(this.backgroundVao);g.uniform2f(u.resolution,this.canvas.width,this.canvas.height);g.uniform4fv(u.view,view);g.uniform3fv(u.green,colors[0]);g.uniform3fv(u.coral,colors[1]);g.uniform1f(u.time,time);g.uniform1f(u.energy,energy);g.uniform1f(u.quiet,quiet?1:0);g.drawArrays(g.TRIANGLES,0,3);
  this.quiet=quiet;
 }
 prepareWorld(id,data){
  if(this.worlds.has(id))return;
  const g=this.gl,vao=g.createVertexArray(),buffer=g.createBuffer();g.bindVertexArray(vao);g.bindBuffer(g.ARRAY_BUFFER,buffer);g.bufferData(g.ARRAY_BUFFER,data,g.STATIC_DRAW);
  for(let i=0;i<4;i++){g.enableVertexAttribArray(i);g.vertexAttribPointer(i,3,g.FLOAT,false,48,i*12);}
  this.worlds.set(id,{vao,buffer,count:data.length/12});g.bindVertexArray(null);
 }
 setWorld(current,previous,mix,time,energy){
  const g=this.gl,u=this.worldUniforms;g.useProgram(this.worldProgram);g.uniform4fv(u.view,this.view);g.uniform1f(u.time,time);g.uniform1f(u.energy,energy);g.uniform1f(u.quiet,this.quiet?1:0);
  g.enable(g.DEPTH_TEST);g.depthFunc(g.LEQUAL);g.depthMask(true);g.disable(g.CULL_FACE);
  const draw=(id,alpha)=>{const m=this.worlds.get(id);if(!m||alpha<=0)return;g.clear(g.DEPTH_BUFFER_BIT);g.enable(g.BLEND);g.blendFunc(g.SRC_ALPHA,g.ONE_MINUS_SRC_ALPHA);g.uniform1f(u.opacity,alpha);g.bindVertexArray(m.vao);g.drawArrays(g.TRIANGLES,0,m.count);};
  if(previous>=0)draw(previous,1-mix);draw(current,mix);g.clear(g.DEPTH_BUFFER_BIT);g.bindVertexArray(null);
 }
 cube(x,y,z,size,color,alpha,rotation,direction,hot,material=0){if(this.count>=this.capacity)return;const i=this.count++*12,d=this.data;d[i]=x;d[i+1]=y;d[i+2]=z;d[i+3]=size;d[i+4]=color[0];d[i+5]=color[1];d[i+6]=color[2];d[i+7]=alpha;d[i+8]=rotation;d[i+9]=direction;d[i+10]=hot?1:0;d[i+11]=Number.isInteger(material)&&material>=0&&material<=3?material:0;}
 flush(){const g=this.gl;if(!this.count)return;g.useProgram(this.program);g.bindVertexArray(this.cubeVao);g.bindBuffer(g.ARRAY_BUFFER,this.instances);g.bufferSubData(g.ARRAY_BUFFER,0,this.data,0,this.count*12);g.uniform4fv(this.uniforms.view,this.view);g.enable(g.DEPTH_TEST);g.depthFunc(g.LEQUAL);g.depthMask(true);g.disable(g.CULL_FACE);g.enable(g.BLEND);g.blendFunc(g.SRC_ALPHA,g.ONE_MINUS_SRC_ALPHA);g.drawElementsInstanced(g.TRIANGLES,this.indexCount,g.UNSIGNED_SHORT,0,this.count);g.bindVertexArray(null);}
}
export const SHADERS={VERTEX,FRAGMENT,BACK_VERTEX,BACK_FRAGMENT,WORLD_VERTEX,WORLD_FRAGMENT};
