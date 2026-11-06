'use strict';
const {point,terrainHeight}=require('./open-forest-map.cjs');
module.exports=function({object,tri,quad}){
 const scale=.72;
 for(const i of [5,18,24,33,46,68]){
  const c=point(i,(i%2?-1:1)*430);c[1]=terrainHeight(c[2])+2;
  const at=(x,y,z)=>[c[0]+x*scale,c[1]+y*scale,c[2]+z*scale];
  const body=object(i,'squirrel');
  function oval(o,center,size,slices=6,rings=2,mat=10){
   const r=[];for(let j=0;j<rings;j++){const lat=-Math.PI/2+(j+1)*Math.PI/(rings+1);r.push(Array.from({length:slices},(_,k)=>{const a=k*Math.PI*2/slices;return at(center[0]+Math.cos(lat)*Math.cos(a)*size[0],center[1]+Math.sin(lat)*size[1],center[2]+Math.cos(lat)*Math.sin(a)*size[2]);}));}
   const low=at(center[0],center[1]-size[1],center[2]),high=at(center[0],center[1]+size[1],center[2]);
   for(let k=0;k<slices;k++){const n=(k+1)%slices;tri(o,low,r[0][n],r[0][k],mat);tri(o,high,r.at(-1)[k],r.at(-1)[n],mat===10?11:mat);for(let j=0;j<rings-1;j++)quad(o,r[j][k],r[j][n],r[j+1][n],r[j+1][k],mat);}
  }
  oval(body,[0,23,-3],[13,17,27]);oval(body,[0,40,23],[12,12,15],6,1,11);
  for(const side of [-1,1]){
   quad(body,at(side*6,47,20),at(side*8,60,18),at(side*10,58,23),at(side*10,48,26),10);
   for(const z of [-16,15]){const x=side*8;tri(body,at(x-3,17,z),at(x+4,17,z),at(x+side*4,2,z+7),9,[0,0,side*2]);tri(body,at(x-3,17,z),at(x+side*4,2,z+7),at(x+side*3-5,2,z+10),9,[0,side*2,side*2]);}
   tri(body,at(side*10,44,31),at(side*12,42,29),at(side*12,45,29),226);
  }
  const face=object(i,'squirrel');oval(face,[0,36,36],[6,5,9],4,1,11);
  const tail=object(i,'squirrel');tail.tail=true;
  const path=[[0,25,-23,6],[0,40,-39,10],[0,62,-46,12],[0,79,-34,13],[0,83,-13,12],[0,73,3,9],[0,59,7,3]];
  const ring=path.map(([x,y,z,r])=>Array.from({length:4},(_,k)=>{const t=k*Math.PI/2+.4;return at(x+Math.cos(t)*r,y+Math.sin(t)*r,z);}));
  for(let j=0;j<ring.length-1;j++)for(let k=0;k<4;k++){const n=(k+1)%4;quad(tail,ring[j][k],ring[j][n],ring[j+1][n],ring[j+1][k],k===0||k===3?11:10);}
  for(const j of [0,ring.length-1])quad(tail,...ring[j],10);
 }
};
