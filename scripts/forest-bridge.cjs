'use strict';
const {point,heights,terrainHeight}=require('./open-forest-map.cjs');
module.exports=function({object,quad}){
 const i=65,a=point(i),b=point(i+1),dx=b[0]-a[0],dz=b[2]-a[2],len=Math.hypot(dx,dz),nx=dz/len,nz=-dx/len;
 const pos=(t,side,y)=>[a[0]+dx*t+nx*side,y,a[2]+dz*t+nz*side];
 function beam(start,end,width,height,material=9){
  const o=object(i,'bridge'),ox=nx*width/2,oz=nz*width/2,v=[];
  for(const c of [start,end])for(const [s,y]of [[-1,-1],[1,-1],[1,1],[-1,1]])v.push([c[0]+s*ox,c[1]+y*height/2,c[2]+s*oz]);
  for(const f of [[0,1,2,3],[4,7,6,5],[0,4,5,1],[3,2,6,7],[0,3,7,4],[1,5,6,2]])quad(o,...f.map(k=>v[k]),material);
 }
 beam(pos(0,0,heights[i]-11),pos(1,0,heights[i+1]-11),520,20,9);
 for(const side of [-1,1]){
  for(const t of [0,.33,.66,1]){const y=heights[i]+(heights[i+1]-heights[i])*t;beam(pos(t,side*260,y+50),pos(t+.008,side*260,y+50),13,100,228);}
  for(const y of [38,86])beam(pos(0,side*260,heights[i]+y),pos(1,side*260,heights[i+1]+y),10,10,241);
  for(const t of [.06,.94]){const y=heights[i]+(heights[i+1]-heights[i])*t,base=terrainHeight(pos(t,0,0)[2]);beam(pos(t,side*225,(y+base)/2-8),pos(t+.025,side*225,(y+base)/2-8),40,y-base-16,9);}
 }
};
