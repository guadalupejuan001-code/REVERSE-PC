'use strict';
const {heights,point,headings}=require('./open-forest-map.cjs');
const {PUDDLES,FORD_LEVEL}=require('./wetlands-environment.cjs');
const ports=require('./velocity-jet-ports.cjs');
module.exports=function({object,tri,quad,box,strip}){
 // Elliptical standing water lies above the same footprint tested by XI.
 for(const i of PUDDLES){
  const o=object(i,'water'),a=point(i,i%2?40:-40),b=point(i+1,i%2?40:-40),c=a.map((v,k)=>Math.round((v+b[k])/2));c[1]+=4;
  const yaw=headings[i]*Math.PI/2048;
  const ring=Array.from({length:8},(_,k)=>{const t=k*Math.PI/4,x=Math.cos(t)*115,z=Math.sin(t)*400;return [c[0]+Math.round(x*Math.cos(yaw)+z*Math.sin(yaw)),c[1],c[2]+Math.round(z*Math.cos(yaw)-x*Math.sin(yaw))];});
  for(let k=0;k<8;k++)tri(o,c,ring[k],ring[(k+1)%8],32);
 }
 for(const i of [28,29]){
  strip(i,-6000,6000,35,35,'dirt',9);
  strip(i,-6000,6000,FORD_LEVEL,FORD_LEVEL,'water',32);
 }
 for(const i of [21,24,33,36,47,63,68])for(const side of [-1,1]){
  strip(i,side<0?-2200:360,side<0?-360:2200,heights[i]+3,heights[i+1]+3,'water',32);
  const o=object(i,'flora'),c=point(i,side*750,heights[i]+4);
  for(let k=0;k<4;k++)tri(o,[c[0]-9+k*13,c[1],c[2]+k*18],[c[0]+k*13,c[1]+85+k*6,c[2]+k*18],[c[0]+8+k*13,c[1],c[2]+k*18],14+k%3);
 }
 require('./forest-squirrels.cjs')({object,tri,quad});
 // Body-mounted details follow the retained chassis pose in the XI transform.
 const car=()=>object(-1,'car');
 const wing=car();box(wing,[0,99,-208],[184,5,27],228);
 for(const side of [-1,1]){
  box(wing,[side*63,84,-207],[5,30,12],241);
  quad(wing,[side*94,81,-222],[side*94,105,-222],[side*94,105,-194],[side*94,81,-194],64);
 }
 quad(wing,[-92,103,-220],[92,103,-220],[92,103,-216],[-92,103,-216],64);
 for(const x of ports.rearX){
  const o=car(),n=6,ring=(r,z)=>Array.from({length:n},(_,k)=>{const a=k*Math.PI*2/n;return [x+Math.cos(a)*r,ports.rearY+Math.sin(a)*r,z];});
  const outer=ring(7,-234),inner=ring(5,-235),back=ring(7,-226);
  for(let k=0;k<n;k++){
   const j=(k+1)%n;quad(o,outer[k],outer[j],inner[j],inner[k],241);quad(o,back[k],back[j],outer[j],outer[k],228);tri(o,[x,ports.rearY,-234],inner[k],inner[j],226);
  }
 }
 const trim=car();
 for(const side of [-1,1]){
  // Bright corner blades and black side intakes match the supplied silhouette.
  quad(trim,[side*79,52,223],[side*83,55,216],[side*83,65,210],[side*80,63,217],225);
  quad(trim,[side*92,45,-95],[side*94,66,-90],[side*88,70,-49],[side*91,48,-59],226);
  quad(trim,[side*88,70,-67],[side*88,73,-67],[side*88,73,-46],[side*88,70,-46],241);
  quad(trim,[side*88,43,-88],[side*89,43,-86],[side*88,77,-86],[side*87,77,-88],240);
  quad(trim,[side*87,43,78],[side*88,43,80],[side*90,73,80],[side*89,73,78],240);
 }
 const hood=car();
 for(const side of [-1,1])quad(hood,[side*49,75,110],[side*50,75,112],[side*61,66,184],[side*60,66,184],240);
 const rear=car();quad(rear,[-25,45,-229],[25,45,-229],[25,58,-229],[-25,58,-229],241);
 for(const x of [-68,-34,0,34,68])quad(rear,[x-1,14,-230],[x+1,14,-230],[x+1,31,-212],[x-1,31,-212],228);
 return {rearPorts:ports.rearX.length,wheelNozzles:4,squirrels:6,puddles:PUDDLES.length,fordSegments:[28,29]};
};
