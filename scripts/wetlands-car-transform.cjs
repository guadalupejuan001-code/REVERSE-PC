'use strict';
module.exports=()=>`localget r3 3315
cmp r3 0
je wetlands_hop_done
load32 r3 115
mod r3 24
cmp r3 12
jle wetlands_hop_fold
set r4 24
sub r4 r3
mov r3 r4
label wetlands_hop_fold
add r1 r3
label wetlands_hop_done
localget r3 3314
cmp r3 0
je wetlands_car_ready
load8 r3 203
cmp r3 1
jne wetlands_car_track
mul r0 96
div r0 100
mul r2 113
div r2 100
cmp r1 74
jle wetlands_car_pose
add r1 18
jmp wetlands_car_pose
label wetlands_car_track
cmp r3 2
jne wetlands_car_pose
mul r0 114
div r0 100
mul r2 92
div r2 100
cmp r1 77
jle wetlands_car_pose
sub r1 14
label wetlands_car_pose
load16 r3 508
sub r3 32768
mov r4 r3
mul r4 r0
div r4 22528
add r1 r4
load16 r4 504
sub r4 32768
mov r5 r4
mul r5 r2
div r5 35840
add r1 r5
load16 r3 512
sub r3 32768
div r3 256
add r1 r3
localget r3 3331
mul r3 r0
localget r4 3330
mul r4 r2
add r3 r4
div r3 16384
localget r4 3331
mul r4 r2
localget r5 3330
mul r5 r0
sub r4 r5
div r4 16384
load32 r0 100
sub r0 2000000
add r0 r3
load32 r2 104
sub r2 2000000
add r2 r4
load16 r3 520
add r1 r3
load16 r3 384
add r1 r3
label wetlands_car_ready`;
