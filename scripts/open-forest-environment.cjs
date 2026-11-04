'use strict';
function timeXi(advance){return [
 '# Eight-minute daylight cycle. Only physics ticks advance the clock.',
 'load32 r0 528',...(advance?['add r0 1','mod r0 24000','store32 528 r0']:[]),
 'mul r0 4096','div r0 24000','load8 r1 137','cmp r1 1','je open_time_day','cmp r1 2','je open_time_dusk','cmp r1 3','je open_time_night','jmp open_time_ready',
 'label open_time_day','set r0 0','jmp open_time_ready',
 'label open_time_dusk','set r0 2048','jmp open_time_ready',
 'label open_time_night','set r0 3072','label open_time_ready','store16 524 r0',
 'set r1 0','cmp r0 1792','jlt open_light_ready','cmp r0 2304','jlt open_light_dusk','cmp r0 3584','jlt open_light_night','jmp open_light_dusk',
 'label open_light_dusk','set r1 1','jmp open_light_ready','label open_light_night','set r1 2','label open_light_ready','store8 526 r1'
].join('\n');}
function groundXi(){return `# Road elevation and finite biome; no closed-circuit distance arithmetic.
load8 r0 273
mov r1 r0
div r1 10
store8 522 r1
add r0 5500
load8 r1 $r0
store8 523 r1
load8 r0 273
mul r0 2
add r0 5300
load16 r1 $r0
add r0 2
load16 r2 $r0
sub r2 r1
load32 r3 330
mul r2 r3
div r2 1000000
add r1 r2
store16 520 r1
load8 r0 273
mul r0 2
add r0 5000
load16 r0 $r0
store16 540 r0
load32 r1 100
load32 r2 334
sub r1 r2
load32 r2 104
load32 r3 338
sub r2 r3
load8 r0 273
mul r0 8
add r0 4096
load32 r3 $r0
add r0 4
load32 r4 $r0
add r0 4
load32 r5 $r0
add r0 4
load32 r6 $r0
sub r5 r3
sub r6 r4
mul r1 r6
mul r2 r5
sub r1 r2
div r1 2000
mov r2 r1
add r2 65536
store32 532 r2
load8 r0 523
cmp r0 3
jne open_turnout_ready
mov r2 r1
cmp r2 0
jge open_turnout_abs
mul r2 -1
label open_turnout_abs
cmp r2 250
jle open_turnout_ready
cmp r2 2200
jgt open_turnout_ready
store8 489 2
label open_turnout_ready
load8 r0 523
cmp r0 4
jne open_mud_ready
load8 r0 120
cmp r0 1
jne open_mud_ready
store8 489 3
label open_mud_ready
load16 r0 384
cmp r0 0
jgt open_water_ready
load8 r0 523
cmp r0 1
je open_bridge_limit
cmp r0 2
jne open_water_ready
cmp r1 450
jle open_water_ready
store8 489 3
mov r2 r1
cmp r2 800
jle open_lake_height
set r2 800
label open_lake_height
set r3 900
sub r3 r2
load16 r4 520
mul r4 r3
div r4 450
store16 520 r4
cmp r1 800
jle open_water_ready
set r5 800
jmp open_water_contact
label open_bridge_limit
set r5 120
cmp r1 120
jgt open_water_contact
cmp r1 -120
jge open_water_ready
set r5 -120
label open_water_contact
load8 r0 273
mul r0 2
add r0 5000
load16 r0 $r0
# Reuse the road's authored right normal via its tangent; sine/cos are calculated below.
store16 542 r5
mov r6 r0
add r6 1024
mod r6 4096
set r7 1
cmp r6 2048
jlt open_cos_half
sub r6 2048
set r7 -1
label open_cos_half
set r8 2048
sub r8 r6
mul r8 r6
mov r9 r8
mul r9 4
set r10 20971520
sub r10 r9
mul r8 262144
div r8 r10
mul r8 r7
mul r8 r5
div r8 16384
load32 r9 334
add r9 r8
store32 100 r9
mov r6 r0
set r7 1
cmp r6 2048
jlt open_sin_half
sub r6 2048
set r7 -1
label open_sin_half
set r8 2048
sub r8 r6
mul r8 r6
mov r9 r8
mul r9 4
set r10 20971520
sub r10 r9
mul r8 262144
div r8 r10
mul r8 r7
mul r8 r5
div r8 16384
load32 r9 338
sub r9 r8
store32 104 r9
store16 261 32768
store16 263 32768
store16 110 0
store16 112 32768
store8 283 1
label open_water_ready
store8 527 0
load32 r0 274
cmp r0 158000
jlt open_end_ready
store8 527 1
label open_end_ready`;
}
function extraObservation(){return `# Open-world ABI v3: legacy 26 observations followed by environment.
load16 r10 520
print r10
load8 r11 522
print r11
load16 r12 524
print r12
load8 r13 526
print r13
load8 r14 523
print r14
load8 r15 527
print r15`;}
module.exports={timeXi,groundXi,extraObservation};
