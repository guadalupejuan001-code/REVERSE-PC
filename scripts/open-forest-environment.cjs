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
function groundXi(){return `# Terrain support uses the same height field as the streamed ground mesh.
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
localset 3726 r1
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
add r2 2000000000
store32 532 r2
load16 r0 520
localset 3728 r0
load32 r2 104
sub r2 2000000000
${require('./open-terrain.cjs').heightXi('support_height')}
# Ordinary road differs by only a 2cm anti-z-fighting offset. A raised bridge
# supports a car from above; it cannot pull a car up from the river below.
load32 r3 342
cmp r3 90000
jgt open_surface_ready
load8 r3 273
cmp r3 64
jlt open_road_support
cmp r3 66
jgt open_road_support
localget r3 3728
load16 r4 384
add r3 r4
add r3 30
localget r4 3726
cmp r3 r4
jlt open_surface_ready
mov r1 r4
jmp open_surface_ready
label open_road_support
localget r1 3726
label open_surface_ready
store16 520 r1
load32 r0 342
cmp r0 90000
jgt open_mud_ready
load8 r0 523
cmp r0 4
jne open_mud_ready
store8 489 3
label open_mud_ready
${require('./wetlands-environment.cjs').physicsXi()}
# Only the actual elevated bridge rails collide. There are no road-corridor,
# lake-bank, ford-bank or end-of-world clamps.
load8 r0 273
cmp r0 65
jne open_water_ready
load32 r1 532
sub r1 2000000000
cmp r1 0
jge open_bridge_abs
mul r1 -1
label open_bridge_abs
cmp r1 110
jlt open_water_ready
cmp r1 340
jgt open_water_ready
load16 r2 520
load16 r3 384
add r2 r3
localget r3 3726
sub r3 30
cmp r2 r3
jlt open_bridge_piers
cmp r1 155
jlt open_water_ready
jmp open_bridge_impact
label open_bridge_piers
load32 r0 330
cmp r0 200000
jle open_bridge_impact
cmp r0 800000
jlt open_water_ready
label open_bridge_impact
load32 r0 552
store32 100 r0
load32 r0 556
store32 104 r0
store16 261 32768
store16 263 32768
store16 110 0
store16 112 32768
store8 283 1
label open_water_ready
# Preserve world-space altitude when the support plane changes in mid-air.
# Driving off a deck starts a fall instead of snapping into the river bed.
localget r0 3728
load16 r1 520
sub r0 r1
load16 r2 384
cmp r2 0
jgt open_air_support
cmp r0 6
jle open_floor_ready
store16 386 10000
label open_air_support
add r2 r0
cmp r2 0
jgt open_air_above_floor
set r2 0
store16 386 10000
store8 391 1
label open_air_above_floor
cmp r2 600
jle open_air_height_bounded
set r2 600
label open_air_height_bounded
store16 384 r2
label open_floor_ready
store8 527 0
load32 r0 274
cmp r0 158000
jlt open_end_ready
store8 527 1
label open_end_ready`;}
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
print r15
load16 r0 544
print r0
load16 r1 546
print r1
load8 r2 548
print r2`;}
module.exports={timeXi,groundXi,extraObservation};
