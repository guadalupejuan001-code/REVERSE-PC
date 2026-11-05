// Scene descriptors only. Cubes are resolved by native Ether Render X.
// Direction -1 denotes plain stage machinery (no cutting arrow), preserving 0..3 for notes.
export class NativeXRender {
 static create(){
  if(!window.ReverseGraphics?.xRender||window.ReverseGraphics.xRender()!=='ether-render-x-cuboids-v1')return null;
  document.documentElement.classList.add('native-xrender');
  const v2=window.ReverseGraphics.xRenderMaterials?.()==='prisma-materials-v2';
  const mesh=window.ReverseGraphics.xRenderMeshes?.()==='prisma-gpu-mesh-v3';
  return new NativeXRender(v2,mesh);
 }
 constructor(v2=false,mesh=false){this.capacity=mesh?128:64;this.count=0;this.data=new Float32Array(16+this.capacity*12);this.native=true;this.mesh3D=mesh;this.quality=0;this.version=mesh?3:v2?2:1;this.worlds=new Set();}
 resize(){}
 begin(time,energy,view,colors,quiet){
  this.count=0;const d=this.data;d[0]=this.version;d[1]=time;d[2]=energy;d[3]=quiet?1:0;
  d.set(view,4);d.set(colors[0],8);d.set(colors[1],11);d[14]=this.mesh3D?this.quality+65280:this.quality;
 }
 prepareWorld(id,data){if(!this.mesh3D||this.worlds.has(id))return;window.ReverseGraphics.model(id,Array.from(data));this.worlds.add(id);}
 setWorld(current,previous,mix,time,energy){if(!this.mesh3D)return;this.data[1]=time;this.data[2]=energy;this.data[14]=this.quality+current*4+(previous>=0?previous+1:0)*32+Math.round(Math.max(0,Math.min(1,mix))*255)*256;}
 cube(x,y,z,size,color,alpha,rotation,direction,hot,material=0){
  if(this.count>=this.capacity)return;const i=16+this.count++*12,d=this.data;
  d[i]=x;d[i+1]=y;d[i+2]=z;d[i+3]=size;d.set(color,i+4);d[i+7]=alpha;
  d[i+8]=rotation;d[i+9]=direction;d[i+10]=hot?1:0;
  d[i+11]=this.version>=2&&Number.isInteger(material)&&material>=0&&material<=3?material:0;
 }
 flush(){this.data[15]=this.count;window.ReverseGraphics.frame(Array.from(this.data.subarray(0,16+this.count*12)));}
}
