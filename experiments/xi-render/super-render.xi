#!reverse-pc-machine-v1
# SUPER RENDER XI v1: 100% XI screen-space scene geometry and row descriptors.
# No new renderer in C++/Java. The host only expands the published intervals.
# A frame has no fixed resolution/body limit: call once per configurable row chunk.
# Mailbox little endian: 200..203 WIDTH, 204..207 HEIGHT,
# 208..211 ROW_START, 212..215 ROW_COUNT; 216 CURVE (128=straight), 217 PHASE.
# Per row: y,background,shoulderL,shoulderR,roadL,roadR,
# leftStripeL,leftStripeR,rightStripeL,rightStripeR,
# centerStripeL,centerStripeR,shade,dash.
# Y grows top-down. All coordinates are 64-bit integer operations in XI.
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
load8 r2 208
load8 r15 209
mul r15 256
add r2 r15
load8 r15 210
mul r15 65536
add r2 r15
load8 r15 211
mul r15 16777216
add r2 r15
load8 r3 212
load8 r15 213
mul r15 256
add r3 r15
load8 r15 214
mul r15 65536
add r3 r15
load8 r15 215
mul r15 16777216
add r3 r15
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
mov r7 r2
mov r8 r2
add r8 r3
cmp r0 2
jlt reject
cmp r1 2
jlt reject
cmp r3 1
jlt reject
cmp r8 r1
jgt reject
jmp row
label reject
set r0 -999
print r0
halt
label row
cmp r7 r6
jge land
# Sky gradient represented as one base material + a light band index.
set r9 0
set r11 -1
set r12 -1
set r13 -1
set r14 -1
set r10 0
mov r15 r7
mul r15 12
div r15 r6
print r7
print r9
print r11
print r11
print r13
print r14
print r13
set r15 -1
print r15
print r15
print r14
set r9 -1
print r9
print r9
mov r15 r7
mul r15 12
div r15 r6
print r15
print r10
jmp next_row
label land
# Procedural road, horizontal screen-space perspective.
# One constant-size XI state generates every scanline on demand.
set r9 1
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
# Curve displacement evaluated from normalized depth; bounded arithmetic.
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
# Reject an entirely off-screen road only by its visible footprint,
# not by limiting virtual world size or generation distance.
cmp r13 r14
jle visible_road
set r13 -1
set r14 -1
label visible_road
print r7
print r9
# Shoulder span is emitted by XI, not recomputed in the presenter.
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
print r9
mov r9 r14
add r9 r15
mov r15 r0
sub r15 1
cmp r9 r15
jle shoulder_right_ready
mov r9 r15
label shoulder_right_ready
print r9
print r13
print r14
# Road-edge strips, center stripe and material ids are XI-owned.
mov r11 r0
div r11 640
cmp r11 1
jge mark_width_ready
set r11 1
label mark_width_ready
print r13
mov r15 r13
add r15 r11
print r15
mov r15 r14
sub r15 r11
print r15
print r14
mov r15 r11
div r15 2
mov r9 r12
sub r9 r15
print r9
mov r9 r12
add r9 r15
print r9
# Distance/fog band is calculated in XI.
mov r15 r10
mul r15 12
div r15 r1
print r15
# Centerline visibility/phase is calculated in XI.
mov r10 r7
add r10 r5
mod r10 48
cmp r10 22
jlt dash
set r10 0
jmp publish_dash
label dash
set r10 1
label publish_dash
print r10
label next_row
add r7 1
cmp r7 r8
jlt row
halt
