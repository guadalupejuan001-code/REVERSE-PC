'use strict';
module.exports=function({object,tri,quad,box}){
 const front=object(-1,'car');box(front,[0,52,228],[164,7,3],223);
 const rear=object(-1,'car');box(rear,[0,65,-229],[164,6,3],221);
 // Invisible XFG4 anchor: XI supplies the exact posed lamp coordinate frame.
 const marker=object(-1,'car');marker.gpuOnly=true;tri(marker,[0,52,230],[0,52,330],[25,52,230],57);
 for(const side of [-1,1]){
  const o=object(-1,'car');o.gpuOnly=true;o.nightOnly=true;
  const near=Array.from({length:6},(_,k)=>{const a=k*Math.PI/3;return [side*56+Math.cos(a)*2,52+Math.sin(a)*2,230];});
  const far=Array.from({length:6},(_,k)=>{const a=k*Math.PI/3;return [side*56+Math.cos(a)*160,4+Math.sin(a)*160,2100];});
  for(let k=0;k<6;k++){const n=(k+1)%6;quad(o,near[k],near[n],far[n],far[k],58);}
 }
};
