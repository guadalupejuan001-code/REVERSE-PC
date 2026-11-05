'use strict';
// One piecewise-planar height field for XI physics and streamed terrain.
const WORLD_BIAS=2000000000,TERRAIN_TABLE=5800;
const RIDGES=[[-40000,1800],[-16000,1800],[-10000,700],[-6500,0],[6500,0],[10000,700],[16000,1800],[40000,1800]];
function ridge(x){x=Math.abs(x);return x<=6500?0:x<10000?Math.trunc((x-6500)*700/3500):x<16000?700+Math.trunc((x-10000)*1100/6000):1800;}
function heightXi(prefix,roadX=false){return `# Shared terrain query: r0/r2=world x/z, r1=height cm; r3..r7 scratch.
localset 3790 r0
set r0 0
set r1 0
cmp r2 0
jle ${prefix}_done
set r3 0
set r4 80
label ${prefix}_search
mov r5 r3
add r5 1
cmp r5 r4
jge ${prefix}_found
mov r5 r3
add r5 r4
div r5 2
mov r6 r5
mul r6 8
add r6 4100
load32 r7 $r6
sub r7 65536
cmp r2 r7
jle ${prefix}_lower
mov r3 r5
jmp ${prefix}_search
label ${prefix}_lower
mov r4 r5
jmp ${prefix}_search
label ${prefix}_found
mov r6 r3
mul r6 8
add r6 4100
load32 r5 $r6
add r6 8
load32 r7 $r6
sub r5 65536
sub r7 65536
cmp r2 r7
jgt ${prefix}_done
sub r7 r5
mul r3 2
add r3 ${TERRAIN_TABLE}
load16 r1 $r3
add r3 2
load16 r6 $r3
sub r6 r1
mov r4 r2
sub r4 r5
mul r6 r4
div r6 r7
add r1 r6
sub r3 ${TERRAIN_TABLE+2}\ndiv r3 2\nmul r3 8\nadd r3 4096\nload32 r5 $r3\nadd r3 8\nload32 r6 $r3\nsub r5 65536\nsub r6 65536\nsub r6 r5\nmul r6 r4\ndiv r6 r7\nadd r5 r6\nmov r0 r5
label ${prefix}_done
localget r3 3790
sub r3 r0
cmp r3 0
jge ${prefix}_abs
mul r3 -1
label ${prefix}_abs
cmp r3 6500
jle ${prefix}_ridge_done
cmp r3 10000
jge ${prefix}_upper
sub r3 6500
mul r3 700
div r3 3500
add r1 r3
jmp ${prefix}_ridge_done
label ${prefix}_upper
cmp r3 16000
jge ${prefix}_plateau
sub r3 10000
mul r3 1100
div r3 6000
add r3 700
add r1 r3
jmp ${prefix}_ridge_done
label ${prefix}_plateau
add r1 1800
label ${prefix}_ridge_done
${roadX?'':'localget r0 3790'}`;}
function sample(z,points,heights){if(z<=0||z>=points[80][1])return 0;let i=0;while(i<79&&z>points[i+1][1])i++;return heights[i]+Math.trunc((heights[i+1]-heights[i])*(z-points[i][1])/(points[i+1][1]-points[i][1]));}
function roadCenter(z,points){if(z<=0||z>=points[80][1])return 0;let i=0;while(i<79&&z>points[i+1][1])i++;return points[i][0]+Math.trunc((points[i+1][0]-points[i][0])*(z-points[i][1])/(points[i+1][1]-points[i][1]));}
module.exports={WORLD_BIAS,TERRAIN_TABLE,heightXi,sample,ridge,RIDGES,roadCenter};
