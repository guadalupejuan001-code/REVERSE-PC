#!reverse-pc-machine-v1
# SUPER RENDER XI - a full road frame emitted directly as XFS1.
# All projection, curvature, horizon, stripes, shading and visibility are XI.
# The native xframe/xspan/xend instructions only pack validated binary bytes.
# Inputs: WIDTH uint32 @200; HEIGHT uint32 @204; curve byte @216,
# phase byte @217. Materials: sky 0..12, land 16..28,
# shoulders 32, road 48, lines 64, center 80.
load8 r0 200
load8 r15 201
mul r15 256
add r0 r15
load8 r15 202
mul r15 65536
add r0 r15
load8 r15 203
mul r15 16777216
add r0 r15
load8 r1 204
load8 r15 205
mul r15 256
add r1 r15
load8 r15 206
mul r15 65536
add r1 r15
load8 r15 207
mul r15 16777216
add r1 r15
load8 r4 216
sub r4 128
load8 r5 217
mov r6 r1
mul r6 44
div r6 100
cmp r6 1
jge horizon_ready
set r6 1
label horizon_ready
# One original XI transaction for all rows. The framebuffer never enters XI.
xframe r0 r1 1
set r7 0
mov r8 r1
label row
cmp r7 r6
jge land
# Sky light band: the original shade value is the XI material id 0..12.
mov r9 r7
mul r9 12
div r9 r6
mov r15 r0
sub r15 1
xspan r7 0 r15 r9 500
jmp next_row
label land
# Exactly the original SUPER RENDER XI curved-road arithmetic.
mov r10 r7
sub r10 r6
add r10 1
mov r11 r0
div r11 75
cmp r11 1
jge min_half_ready
set r11 1
label min_half_ready
mov r15 r10
mul r15 r0
mov r12 r1
mul r12 4
div r15 r12
add r11 r15
mov r12 r10
mul r12 1000
div r12 r1
mul r12 r12
mul r12 r4
mul r12 r0
div r12 256000000
mov r15 r0
div r15 2
add r12 r15
mov r13 r12
sub r13 r11
mov r14 r12
add r14 r11
cmp r13 0
jge left_clamped
set r13 0
label left_clamped
mov r15 r0
sub r15 1
cmp r14 r15
jle right_clamped
mov r14 r15
label right_clamped
cmp r13 r14
jle visible_road
set r13 -1
set r14 -1
label visible_road
# Ground shade uses the exact original 12-band XI fog expression.
mov r9 r10
mul r9 12
div r9 r1
add r9 16
mov r15 r0
sub r15 1
xspan r7 0 r15 r9 500
# Shoulder projected by XI, not reconstructed by the display adapter.
mov r15 r0
div r15 150
mov r11 r10
mul r11 r0
mov r9 r1
mul r9 20
div r11 r9
add r15 r11
mov r9 r13
sub r9 r15
cmp r9 0
jge shoulder_left_ready
set r9 0
label shoulder_left_ready
mov r3 r9
mov r9 r14
add r9 r15
mov r15 r0
sub r15 1
cmp r9 r15
jle shoulder_right_ready
mov r9 r15
label shoulder_right_ready
cmp r3 r9
jgt skip_shoulder
xspan r7 r3 r9 32 400
label skip_shoulder
cmp r13 0
jlt next_row
cmp r14 r13
jlt next_row
xspan r7 r13 r14 48 300
# Road edge lines are geometric XI spans, constant-size per visible row.
mov r11 r0
div r11 640
cmp r11 1
jge mark_width_ready
set r11 1
label mark_width_ready
mov r15 r13
add r15 r11
xspan r7 r13 r15 64 200
mov r15 r14
sub r15 r11
xspan r7 r15 r14 64 200
# XI computes the centerline dash and applies its phase independently.
mov r10 r7
add r10 r5
mod r10 48
cmp r10 22
jge next_row
mov r15 r11
div r15 2
mov r9 r12
sub r9 r15
mov r3 r12
add r3 r15
cmp r9 0
jlt next_row
mov r15 r0
sub r15 1
cmp r3 r15
jgt next_row
xspan r7 r9 r3 80 100
label next_row
add r7 1
cmp r7 r8
jlt row
xend
halt
