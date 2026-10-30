// Scene descriptors only. Cubes are resolved by native Ether Render X.
export class NativeXRender {
 static create(){
  if(!window.ReverseGraphics?.xRender||window.ReverseGraphics.xRender()!=='ether-render-x-cuboids-v1')return null;
  document.documentElement.classList.add('native-xrender');return new NativeXRender();
 }
 constructor(){this.count=0;this.data=new Float32Array(16+64*12);this.native=true;this.quality=0;}
 resize(){}
 begin(time,energy,view,colors,quiet){
  this.count=0;const d=this.data;d[0]=1;d[1]=time;d[2]=energy;d[3]=quiet?1:0;
  d.set(view,4);d.set(colors[0],8);d.set(colors[1],11);d[14]=this.quality;
 }
 cube(x,y,z,size,color,alpha,rotation,direction,hot){
  if(this.count>=64)return;const i=16+this.count++*12,d=this.data;
  d[i]=x;d[i+1]=y;d[i+2]=z;d[i+3]=size;d.set(color,i+4);d[i+7]=alpha;
  d[i+8]=rotation;d[i+9]=direction;d[i+10]=hot?1:0;d[i+11]=0;
 }
 flush(){this.data[15]=this.count;window.ReverseGraphics.frame(Array.from(this.data.subarray(0,16+this.count*12)));}
}
