'use strict';
// Authoring constants only. XI executes transmission, torque and braking at 50 Hz.
const GEARS=Object.freeze([
 {up:950,down:0,redline:1350,torque:620},
 {up:1700,down:700,redline:2250,torque:580},
 {up:2700,down:1400,redline:3350,torque:540},
 {up:3900,down:2300,redline:4500,torque:500},
 {up:5100,down:3400,redline:5750,torque:460},
 {up:6501,down:4500,redline:6800,torque:420}
]);
const INITIAL=`# C01 powertrain: gear, selector, pedal ramp, wheel-derived RPM, shift timer.
store8 568 1
store8 569 0
store16 570 0
store16 572 800
store8 574 0`;
function forceXi(){
 const a=[],emit=s=>a.push(...s.split('\n'));
 emit(`# C01: r4=longitudinal speed, r5=lateral speed; preserve both.
load8 r0 142
cmp r0 6
jle pt_selector_valid
set r0 0
label pt_selector_valid
store8 569 r0
load8 r6 568
cmp r6 1
jge pt_gear_low_valid
set r6 1
label pt_gear_low_valid
cmp r6 6
jle pt_gear_valid
set r6 6
label pt_gear_valid
load8 r1 133
cmp r1 1
jne pt_forward
set r6 1
jmp pt_selected
label pt_forward
cmp r0 0
je pt_auto
cmp r0 r6
jge pt_manual_apply`);
 // A downshift request is retained, but cannot force an over-rev or delete speed.
 GEARS.forEach((g,i)=>emit(`cmp r0 ${i+1}\njne pt_safe_${i}\ncmp r4 ${g.redline}\njgt pt_selected\njmp pt_manual_apply\nlabel pt_safe_${i}`));
 emit('label pt_manual_apply\nmov r6 r0\njmp pt_selected\nlabel pt_auto');
 GEARS.forEach((g,i)=>{
  emit(`cmp r6 ${i+1}\njne pt_auto_${i}`);
  if(i<5)emit(`cmp r4 ${g.up}\njlt pt_down_${i}\nadd r6 1\njmp pt_selected\nlabel pt_down_${i}`);
  if(i>0)emit(`cmp r4 ${g.down}\njge pt_selected\nsub r6 1`);
  emit(`jmp pt_selected\nlabel pt_auto_${i}`);
 });
 emit(`label pt_selected
load8 r1 568
cmp r1 r6
je pt_same_gear
store8 574 6
label pt_same_gear
store8 568 r6
# Gear-dependent wheel RPM is telemetry, never a cosmetic timer.
set r7 6800
set r0 420`);
 GEARS.forEach((g,i)=>emit(`cmp r6 ${i+1}\njne pt_ratio_${i}\nset r7 ${g.redline}\nset r0 ${g.torque}\nlabel pt_ratio_${i}`));
 emit(`mov r1 r4
mul r1 6000
div r1 r7
add r1 800
cmp r1 7200
jle pt_rpm_ready
set r1 7200
label pt_rpm_ready
store16 572 r1
# Throttle takes half a second to build; brake always cancels engine torque.
load8 r1 129
cmp r1 1
je pt_brake
load8 r1 128
cmp r1 1
jne pt_coast
load16 r1 570
add r1 40
cmp r1 1000
jle pt_ramp_ready
set r1 1000
label pt_ramp_ready
store16 570 r1
mul r0 r1
div r0 1000
cmp r4 r7
jlt pt_power_ready
set r0 0
label pt_power_ready
load8 r1 574
cmp r1 0
je pt_shift_ready
sub r1 1
store8 574 r1
div r0 3
label pt_shift_ready
load8 r1 382
cmp r1 1
jne pt_force_ready
add r0 1300
jmp pt_force_ready
label pt_coast
store16 570 0
# Lower gears slow the wheels more when the accelerator is released.
set r0 7
sub r0 r6
mul r0 -45
sub r0 80
# An unsafe requested downshift adds gradual retardation until it is safe.
load8 r1 569
cmp r1 0
je pt_force_ready
cmp r1 r6
jge pt_force_ready
sub r0 180
jmp pt_force_ready
label pt_brake
store16 570 0
set r0 -3600
load8 r1 489
cmp r1 1
jne pt_brake_curb
set r0 -2400
label pt_brake_curb
cmp r1 2
jne pt_brake_mud
set r0 -2900
label pt_brake_mud
cmp r1 3
jne pt_brake_water
set r0 -1900
label pt_brake_water
cmp r1 4
jne pt_force_ready
set r0 -1600
label pt_force_ready
# Boost cannot bypass a manually selected gear's torque limit.
cmp r0 0
jle pt_force_limited
cmp r4 r7
jlt pt_force_limited
set r0 0
label pt_force_limited`);
 return a.join('\n');
}
const TELEMETRY='load8 r3 568\nprint r3\nload16 r4 572\nprint r4\nload8 r5 569\nprint r5';
module.exports={GEARS,INITIAL,forceXi,TELEMETRY};
