'use strict';
// Two yaw-aligned ridge layers form continuous silhouettes rather than cones.
module.exports=function({out,load,store,focus}){
 const profile=[22,37,51,90,115,108,73,64,84,58,36,24,39,55,79,111,98,61,44,30,47,70,52,31];
 profile.forEach((h,i)=>out(`localset ${3960+i} ${h}`));
 out('load16 r0 108\nload16 r1 204\nadd r0 r1\nmod r0 4096\nmul r0 24\nlocalset 3990 r0');
 for(let layer=0;layer<2;layer++){
  out(`localset 3991 0\nlabel panorama_${layer}\nlocalget r7 3991\nload16 r0 8210\nmov r1 r0\nmul r1 r7\ndiv r1 5\nlocalget r6 3990\nmod r6 4096\nmul r6 r0\ndiv r6 20480\nsub r1 r6\nsub r1 ${layer?0:0}\nmov r2 r0\ndiv r2 5\nadd r2 r1\nlocalget r6 3990\ndiv r6 4096\nadd r6 r7\nadd r6 ${layer?9:0}\nmod r6 24\nadd r6 3960\nlocalget r4 r6\nsub r6 3960\nadd r6 1\nmod r6 24\nadd r6 3960\nlocalget r5 r6\nmul r4 r0\ndiv r4 ${layer?700:550}\nmul r5 r0\ndiv r5 ${layer?700:550}\nload16 r3 8238\nsub r4 r3\nmul r4 -1\nsub r5 r3\nmul r5 -1\nmov r6 r3\nadd r6 30\nmeshtri r1 r6 999990 r1 r4 999990 r2 r5 999990 ${layer?199:189}\nmeshtri r1 r6 999990 r2 r5 999990 r2 r6 999990 ${layer?199:189}\nlocalget r7 3991\nadd r7 1\nlocalset 3991 r7\ncmp r7 8\njlt panorama_${layer}`);
 }
};
