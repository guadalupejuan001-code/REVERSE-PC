'use strict';
const {RIDGES}=require('./open-terrain.cjs');
module.exports=function({out,cameraPoint,focus}){
 out(`load32 r12 100\nsub r12 2000000000\nload32 r13 104\nsub r13 2000000000\nlocalset 3740 -1\nlabel terrain_row
localget r0 3740\ncmp r0 -1\nje terrain_before\ncmp r0 80\nje terrain_after
mul r0 8\nadd r0 4100\nload32 r1 $r0\nadd r0 8\nload32 r2 $r0\nsub r1 65536\nsub r2 65536
mov r3 r13\nsub r3 26000\ncmp r2 r3\njlt terrain_next\nadd r3 52000\ncmp r1 r3\njgt terrain_next
sub r0 12\nload32 r5 $r0\nadd r0 8\nload32 r6 $r0\nsub r5 65536\nsub r6 65536
localget r0 3740\nmul r0 2\nadd r0 5800\nload16 r3 $r0\nadd r0 2\nload16 r4 $r0\njmp terrain_bounds
label terrain_before\nmov r1 r13\nsub r1 26000\ncmp r1 0\njge terrain_next\nmov r2 r13\nadd r2 26000\ncmp r2 0\njle terrain_before_end\nset r2 0\nlabel terrain_before_end\nset r3 0\nset r4 0\nset r5 0\nset r6 0\njmp terrain_bounds
label terrain_after\nload32 r2 4740\nsub r2 65536\nmov r1 r13\nsub r1 26000\ncmp r1 r2\njge terrain_after_start\nmov r1 r2\nlabel terrain_after_start\nmov r2 r13\nadd r2 26000\ncmp r2 r1\njle terrain_next\nset r3 0\nset r4 0\nset r5 0\nset r6 0
label terrain_bounds\nlocalset 3741 r1\nlocalset 3742 r2\nlocalset 3743 r3\nlocalset 3744 r4\nlocalset 3747 r5\nlocalset 3748 r6
add r5 r6\ndiv r5 2\nsub r5 r12\ncmp r5 0\njge terrain_side_abs\nmul r5 -1\nlabel terrain_side_abs\nlocalset 3751 7\ncmp r5 25000\njle terrain_cells_ready\nlocalset 3751 3\nlabel terrain_cells_ready\nlocalset 3750 0\nlabel terrain_cell`);
 RIDGES.forEach(([x,y],i)=>out(`localset ${3940+i*2} ${x}\nlocalset ${3941+i*2} ${y}`));
 for(let v=0;v<4;v++){
  const right=v===1||v===2;
  out(`localget r1 ${v<2?3743:3744}\nlocalget r2 ${v<2?3741:3742}\nlocalget r3 3750\nadd r3 ${right?1:0}\nlocalget r4 3751\ncmp r4 3\nje terrain_far_${v}
mul r3 2\nadd r3 3940\nlocalget r0 r3\nadd r3 1\nlocalget r4 r3\nadd r1 r4\nlocalget r3 ${v<2?3747:3748}\nadd r0 r3\njmp terrain_vertex_${v}
label terrain_far_${v}\nmov r0 r12\nsub r0 30000\nmul r3 20000\nadd r0 r3\nadd r1 1800\nlabel terrain_vertex_${v}
mov r3 r0\ndiv r3 60\nmod r3 4096\nmov r4 r2\ndiv r4 60\nmod r4 4096\nlocalset 3745 r3\nlocalset 3746 r4`);
  cameraPoint('r0','r1','r2');out(`meshvertex ${1780+v} r0 r1 r2\nlocalget r3 3745\nlocalget r4 3746\nmeshtexuv ${1780+v} r3 r4\nmeshshade ${1780+v} 170`);
 }
 focus();out('meshfacegradienttex 1780 1781 1782 12 8 6 2 r9 r10 r11 60\nmeshfacegradienttex 1780 1782 1783 12 8 6 2 r9 r10 r11 60\nlocalget r0 3750\nadd r0 1\nlocalset 3750 r0\nlocalget r1 3751\ncmp r0 r1\njlt terrain_cell\nlabel terrain_next\nlocalget r0 3740\nadd r0 1\nlocalset 3740 r0\ncmp r0 81\njlt terrain_row');
};
