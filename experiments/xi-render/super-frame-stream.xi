#!reverse-pc-machine-v1
# SUPER RENDER XI FRAME STREAM v1: XI is the geometric authority.
# Window mailbox: uint32 LE W@200, H@204, firstY@208, rows@212,
# curveByte@216 (128=straight), visual phase@217.
# Output: ONE XFS1 stream with native ARGB rectangles and scanline spans.
# Host performs byte-safe materialization ONLY, never road or pixel geometry.
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
cmp r0 2
jlt invalid
cmp r1 2
jlt invalid
cmp r3 1
jlt invalid
mov r8 r2
add r8 r3
cmp r8 r1
jgt invalid
mov r6 r1
mul r6 44
div r6 100
cmp r6 1
jge horizon_ready
set r6 1
label horizon_ready
# Exact frame descriptor, independent from number of visible scanlines.
frame_begin r0 r1 1 4285243342
# One compact tile covers all grass in the requested viewport window.
mov r9 r2
cmp r9 r6
jge ground_begin
mov r9 r6
label ground_begin
mov r10 r8
sub r10 r9
cmp r10 0
jle begin_rows
frame_tile 0 r9 r0 r10 4282674507 9000
label begin_rows
mov r7 r2
label row
cmp r7 r6
jlt next_row
# Perspective road widening and XY curve are computed from XI integer state.
mov r10 r7
sub r10 r6
add r10 1
mov r11 r0
div r11 75
cmp r11 1
jge min_half
set r11 1
label min_half
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
jge road_left
set r13 0
label road_left
mov r15 r0
sub r15 1
cmp r14 r15
jle road_right
mov r14 r15
label road_right
cmp r13 r14
jgt next_row
# Shoulder extends farther than road, but never outside the viewport.
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
jge shoulder_left
set r9 0
label shoulder_left
mov r11 r14
add r11 r15
mov r15 r0
sub r15 1
cmp r11 r15
jle shoulder_right
mov r11 r15
label shoulder_right
frame_span r7 r9 r11 4286604615 4000
# Surface-depth is owned by XI; nearer materials overwrite the shoulder.
frame_span r7 r13 r14 4281350982 3000
# Two road edge markings, width scales with viewport width.
mov r11 r0
div r11 640
cmp r11 1
jge road_mark
set r11 1
label road_mark
mov r9 r13
add r9 r11
cmp r9 r14
jle edge_left
mov r9 r14
label edge_left
frame_span r7 r13 r9 4293124299 2000
mov r9 r14
sub r9 r11
cmp r9 r13
jge edge_right
mov r9 r13
label edge_right
frame_span r7 r9 r14 4293124299 2000
# Centerline phases depend solely on XI scene phase and current row.
mov r9 r7
add r9 r5
mod r9 48
cmp r9 22
jge next_row
mov r15 r11
div r15 2
mov r9 r12
sub r9 r15
cmp r9 r13
jge center_left
mov r9 r13
label center_left
mov r15 r12
add r15 r11
cmp r15 r14
jle center_right
mov r15 r14
label center_right
cmp r9 r15
jgt next_row
frame_span r7 r9 r15 4293970507 1000
label next_row
add r7 1
cmp r7 r8
jlt row
frame_end
halt
label invalid
# A rejected descriptor must never publish a partial frame or RVPC2 state.
set r0 0
div r0 0
halt
