'use strict';
const {TABLE,STRIDE}=require('./forest-trail-mesh.cjs');
module.exports=function({out,cameraPoint,focus}){
 out('localset 3920 0\nlocalset 3921 0\nlabel trail_ribbon\nlocalget r3 3920');
 out(`mul r3 ${STRIDE}\nadd r3 ${TABLE}\nlocalset 3922 r3\nload32 r0 $r3\nsub r0 2000000000\nadd r3 4\nload32 r2 $r3\nsub r2 2000000000\nsub r0 r12\nmul r0 r0\nsub r2 r13\nmul r2 r2\nadd r0 r2\ncmp r0 49000000\njgt trail_ribbon_next`);
 for(let v=0;v<3;v++){
  out(`localget r3 3922\nadd r3 ${v*16}\nload32 r0 $r3\nsub r0 2000000000\nadd r3 4\nload32 r2 $r3\nsub r2 2000000000\nadd r3 4\nload16 r1 $r3\nadd r3 2\nload16 r4 $r3\nlocalset 3923 r4\nadd r3 2\nload16 r4 $r3\nlocalset 3924 r4`);
  cameraPoint('r0','r1','r2');out(`meshvertex ${1810+v} r0 r1 r2\nlocalget r3 3923\nlocalget r4 3924\nmeshtexuv ${1810+v} r3 r4\nmeshshade ${1810+v} 170`);
 }
 focus();out('meshfacegradienttex 1810 1811 1812 9 3 7 4 r9 r10 r11 60\nlocalget r0 3921\nadd r0 1\nlocalset 3921 r0\ncmp r0 112\njge trail_ribbons_done');
 out('label trail_ribbon_next\nlocalget r0 3920\nadd r0 1\nlocalset 3920 r0\nload16 r1 910\ncmp r0 r1\njlt trail_ribbon\nlabel trail_ribbons_done');
};
