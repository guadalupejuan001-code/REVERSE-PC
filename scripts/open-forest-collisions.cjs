'use strict';
// Twelve nearby procedural instances. The global seed is shared with XI render.
// Compact circles conservatively enclose the car and each trunk/boulder.
module.exports=function(){return `load8 r0 273
sub r0 1
localset 3500 r0
localset 3501 0
label open_prop_row
localget r0 3500
cmp r0 0
jlt open_prop_next_row
cmp r0 79
jgt open_props_collision_done
mov r1 r0
add r1 5500
load8 r1 $r1
cmp r1 1
je open_prop_next_row
cmp r1 5
je open_prop_next_row
localset 3504 r1
localset 3502 0
label open_prop_slot
localget r0 3500
mul r0 4
localget r1 3502
add r0 r1
add r0 4
mov r1 r0
mod r1 10
cmp r1 9
je open_prop_next_slot
set r2 270
cmp r1 7
je wetlands_rock_collision
cmp r1 8
jne open_prop_radius_ready
label wetlands_rock_collision
load16 r1 384
cmp r1 140
jgt open_prop_next_slot
set r2 500
label open_prop_radius_ready
localset 3503 r2
localget r1 3504
cmp r1 2
jne open_prop_bank_ready
mov r1 r0
mod r1 2
cmp r1 1
je open_prop_next_slot
label open_prop_bank_ready
mul r0 73
mod r0 2500
add r0 470
localget r1 3503
cmp r1 500
jne wetlands_rock_offset_ready
add r0 250
label wetlands_rock_offset_ready
localget r1 3502
mod r1 2
mul r1 2
sub r1 1
mul r0 r1
localset 3505 r0
localget r1 3500
mul r1 8
add r1 4096
load32 r2 $r1
sub r2 65536
add r1 4
load32 r3 $r1
sub r3 65536
add r1 4
load32 r4 $r1
sub r4 65536
add r1 4
load32 r5 $r1
sub r5 65536
sub r4 r2
sub r5 r3
mul r5 r0
div r5 2000
add r2 r5
mul r4 r0
div r4 2000
sub r3 r4
load32 r4 100
sub r4 2000000
sub r4 r2
mul r4 r4
load32 r5 104
sub r5 2000000
sub r5 r3
mul r5 r5
add r4 r5
localget r5 3503
mul r5 r5
cmp r4 r5
jge open_prop_next_slot
load32 r0 552
store32 100 r0
load32 r0 556
store32 104 r0
store16 261 32768
store16 263 32768
store16 110 0
store16 112 32768
store8 283 1
jmp open_props_collision_done
label open_prop_next_slot
localget r0 3502
add r0 1
localset 3502 r0
cmp r0 4
jlt open_prop_slot
label open_prop_next_row
localget r0 3500
add r0 1
localset 3500 r0
localget r0 3501
add r0 1
localset 3501 r0
cmp r0 3
jlt open_prop_row
label open_props_collision_done`;};
