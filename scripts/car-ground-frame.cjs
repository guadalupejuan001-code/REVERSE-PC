'use strict';
const {heightXi}=require('./open-terrain.cjs');
function physicsXi(){let s='';for(let i=0;i<4;i++)s+=`load32 r0 100\nsub r0 2000000000\nload32 r2 104\nsub r2 2000000000\n${i<2?'add r0 '+(i===0?-100:100):'add r2 '+(i===2?-200:200)}\n${heightXi('wheel_plane_'+i)}\nlocalset ${3791+i} r1\n`;
return s+`localget r0 3792\nlocalget r1 3791\nsub r0 r1\nmul r0 4096\ndiv r0 200\nadd r0 32768\nstore16 912 r0\nlocalget r0 3794\nlocalget r1 3793\nsub r0 r1\nmul r0 4096\ndiv r0 400\nload32 r1 342\ncmp r1 90000\njgt wheel_plane_ready\nload8 r1 273\ncmp r1 64\njlt wheel_plane_ready\ncmp r1 66\njgt wheel_plane_ready\nmul r1 2\nadd r1 5300\nload16 r0 $r1\nadd r1 2\nload16 r2 $r1\nsub r2 r0\nmul r2 4096\ndiv r2 2000\nmov r0 r2\nlabel wheel_plane_ready\nadd r0 32768\nstore16 914 r0`;}
function readXi(){return `load16 r3 912\nsub r3 32768\nload16 r4 914\nsub r4 32768\nlocalget r5 3331\nmul r5 r3\nlocalget r6 3330\nmul r6 r4\nsub r5 r6\ndiv r5 16384\nlocalset 3332 r5\nlocalget r5 3330\nmul r5 r3\nlocalget r6 3331\nmul r6 r4\nadd r5 r6\ndiv r5 16384\nlocalset 3333 r5`;}
function applyXi(){return 'localget r3 3332\nmul r3 r0\nlocalget r4 3333\nmul r4 r2\nadd r3 r4\ndiv r3 4096\nadd r1 r3';}
module.exports={physicsXi,readXi,applyXi};
