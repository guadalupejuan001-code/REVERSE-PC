'use strict';
// Clip joined trail ribbons to the exact piecewise planar terrain cells.
const {segments}=require('./forest-trails.cjs');
const {points,terrainHeights}=require('./open-forest-map.cjs');
const {RIDGES}=require('./open-terrain.cjs');
const TABLE=23000,STRIDE=48;
const clip=(poly,f,positive=true)=>{let out=[];for(let i=0;i<poly.length;i++){const a=poly[i],b=poly[(i+1)%poly.length],fa=f(a)*(positive?1:-1),fb=f(b)*(positive?1:-1);if(fa>=-1e-7)out.push(a);if((fa<0)!=(fb<0)){const t=fa/(fa-fb);out.push(a.map((v,k)=>v+(b[k]-v)*t));}}return out;};
const triangles=[];
function normal(s){const dx=s.b[0]-s.a[0],dz=s.b[1]-s.a[1],l=Math.hypot(dx,dz);return[dz/l,-dx/l];}
function join(s,other){const n=normal(s);if(!other||other.route!==s.route)return n.map(x=>x*s.width/2);const m=normal(other),d=1+n[0]*m[0]+n[1]*m[1],v=[(n[0]+m[0])/Math.max(.5,d),(n[1]+m[1])/Math.max(.5,d)];return v.map(x=>x*s.width/2);}
let arc=0,last=-1;
for(let i=0;i<segments.length;i++){
 const s=segments[i];if(s.route!==last){arc=0;last=s.route;}const a=join(s,segments[i-1]),b=join(s,segments[i+1]),len=Math.hypot(s.b[0]-s.a[0],s.b[1]-s.a[1]);
 const polygon=[[s.a[0]-a[0],s.a[1]-a[1],0,arc/45],[s.a[0]+a[0],s.a[1]+a[1],16,arc/45],[s.b[0]+b[0],s.b[1]+b[1],16,(arc+len)/45],[s.b[0]-b[0],s.b[1]-b[1],0,(arc+len)/45]];arc+=len;
 for(let row=0;row<80;row++){
  const za=points[row][1],zb=points[row+1][1];let poly=clip(clip(polygon,p=>p[1]-za),p=>zb-p[1]);if(poly.length<3)continue;
  const center=z=>points[row][0]+(points[row+1][0]-points[row][0])*(z-za)/(zb-za);
  for(let band=0;band<RIDGES.length-1;band++){
   const [xa,ya]=RIDGES[band],[xb,yb]=RIDGES[band+1];const q=clip(clip(poly,p=>p[0]-center(p[1])-xa),p=>xb-(p[0]-center(p[1])));if(q.length<3)continue;
   const at=p=>{const x=Math.round(p[0]),z=Math.round(p[1]),lat=x-center(z),base=terrainHeights[row]+(terrainHeights[row+1]-terrainHeights[row])*(z-za)/(zb-za),y=Math.ceil(base+ya+(yb-ya)*(lat-xa)/(xb-xa))+3;return{x,z,y,u:Math.round(p[2]*64),v:Math.round(p[3]*16)%65536};};
   for(let k=1;k<q.length-1;k++){const p=[q[0],q[k],q[k+1]];if(Math.abs((p[1][0]-p[0][0])*(p[2][1]-p[0][1])-(p[2][0]-p[0][0])*(p[1][1]-p[0][1]))<1)continue;triangles.push({p:p.map(at),route:s.route});}
  }
 }
}
if(TABLE+STRIDE*triangles.length>=65536)throw Error('Trail mesh overlaps memory bound: '+triangles.length);
function worldXi(){return [`store16 910 ${triangles.length}`,...triangles.flatMap((t,i)=>{const s=[];t.p.forEach((p,j)=>{const a=TABLE+i*STRIDE+j*16;s.push(`store32 ${a} ${p.x+2000000000}`,`store32 ${a+4} ${p.z+2000000000}`,`store16 ${a+8} ${p.y}`,`store16 ${a+10} ${p.u}`,`store16 ${a+12} ${p.v}`);});return s;})];}
module.exports={triangles,TABLE,STRIDE,worldXi};
