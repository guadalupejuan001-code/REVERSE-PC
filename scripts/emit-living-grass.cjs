'use strict';
const {heightXi}=require('./open-terrain.cjs');
module.exports=function({out,cameraPoint,focus}){
 out('load32 r12 100\nsub r12 2000000000\nload32 r13 104\nsub r13 2000000000\nlocalset 3760 0\nlabel living_grass');
 out(`mov r3 r12\ncmp r3 0\njge grass_x_floor\nsub r3 299\nlabel grass_x_floor\ndiv r3 300\nmov r4 r13\ncmp r4 0\njge grass_z_floor\nsub r4 299\nlabel grass_z_floor\ndiv r4 300\nlocalget r5 3760\nmov r6 r5\nmod r6 8\nsub r6 4\nadd r3 r6\ndiv r5 8\nsub r5 4\nadd r4 r5\nmov r5 r3\nmul r5 37\nmov r6 r4\nmul r6 73\nadd r5 r6\nmod r5 1000\nadd r5 1000\nmod r5 1000\nlocalset 3766 r5\nmov r0 r3\nmul r0 300\nadd r0 65\nmov r6 r5\nmod r6 150\nadd r0 r6\nmov r2 r4\nmul r2 300\nadd r2 80\ndiv r5 3\nmod r5 140\nadd r2 r5\nlocalset 3763 r0\nlocalset 3764 r2\n${heightXi('grass_support',true)}\nlocalset 3765 r1\ncmp r2 0\njlt grass_road_clear\nload32 r5 4740\nsub r5 65536\ncmp r2 r5\njgt grass_road_clear\nlocalget r5 3763\nsub r5 r0\ncmp r5 0\njge grass_road_abs\nmul r5 -1\nlabel grass_road_abs\ncmp r5 420\njlt grass_next\nlabel grass_road_clear\nload32 r3 115\nlocalget r4 3766\nadd r3 r4\nmod r3 120\ncmp r3 60\njle grass_wind_fold\nset r4 120\nsub r4 r3\nmov r3 r4\nlabel grass_wind_fold\nsub r3 30\ndiv r3 4\nlocalset 3767 r3`);
 for(let plane=0;plane<2;plane++){
  for(let v=0;v<4;v++){
   const top=v>=2,side=v===0||v===3?-1:1;
   out(`localget r0 3763\nlocalget r2 3764\nlocalget r1 3765\nadd r1 1`);
   out(`${plane===0?'add r0':'add r2'} ${side*(top?1:9)}`);
   if(top)out('localget r3 3766\nmod r3 22\nadd r1 35\nadd r1 r3\nlocalget r3 3767\nadd r0 r3');
   cameraPoint('r0','r1','r2');out(`meshvertex ${1800+v} r0 r1 r2\nmeshtexuv ${1800+v} ${side<0?0:16} ${top?64:0}\nmeshshade ${1800+v} ${top?205:92}`);
  }
  focus();out('meshfacegradienttex 1800 1801 1802 14 3 6 1 r9 r10 r11 60\nmeshfacegradienttex 1800 1802 1803 14 3 6 1 r9 r10 r11 60');
 }
 out('label grass_next\nlocalget r0 3760\nadd r0 1\nlocalset 3760 r0\ncmp r0 64\njlt living_grass');
};
