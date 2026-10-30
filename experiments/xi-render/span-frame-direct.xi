#!reverse-pc-machine-v1
# Compact X Render XI experiment: per-row visible spans instead of per-pixel rays.
# Four little-endian viewport bytes: 200 Wlo, 201 Whi, 202 Hlo, 203 Hhi.
# Output: XFS1 binary frame from the XI Machine directly, with no JSON print.
# All interval math, depth order, bounds and rounding are computed by XI.
load8 r0 200
load8 r6 201
mul r6 256
add r0 r6
load8 r1 202
load8 r6 203
mul r6 256
add r1 r6
mov r2 r0
mul r2 10
mov r3 r1
mul r3 10
frame_begin r0 r1 1
set r4 0
label row
mov r5 r4
mul r5 10
add r5 4
set r12 -1
set r13 -1
set r14 -1
set r15 -1
# Rear triangle: (W/8,H/8), (7W/8,H/8), (W/2,7H/8).
# Integer raster rule: pixel center in tenths minus translation (2,1).
# For row Y, left edge N/D: N=W10*(H10+8Y), D=16H10.
mov r10 r5
mul r10 8
cmp r10 r3
jlt front
mov r11 r3
mul r11 7
cmp r10 r11
jgt front
mov r7 r3
mul r7 16
mov r8 r7
mul r8 10
mov r6 r10
add r6 r3
mul r6 r2
mov r9 r7
mul r9 3
mov r11 r6
sub r11 r9
add r11 r8
sub r11 1
div r11 r8
mov r12 r11
mov r11 r2
mul r11 r7
sub r11 r6
sub r11 r9
div r11 r8
mov r13 r11
label front
# Near triangle: (W/4,H/3), (3W/4,H/3), (W/2,5H/6).
# N=W10*(H10+6Y), D=12H10. Front always occludes rear.
mov r10 r5
mul r10 3
cmp r10 r3
jlt publish
mov r10 r5
mul r10 6
mov r11 r3
mul r11 5
cmp r10 r11
jgt publish
mov r7 r3
mul r7 12
mov r8 r7
mul r8 10
mov r6 r10
add r6 r3
mul r6 r2
mov r9 r7
mul r9 3
mov r11 r6
sub r11 r9
add r11 r8
sub r11 1
div r11 r8
mov r14 r11
mov r11 r2
mul r11 r7
sub r11 r6
sub r11 r9
div r11 r8
mov r15 r11
label publish
cmp r12 -1
je skip_rear_span
frame_span r4 r12 r13 2 200
label skip_rear_span
cmp r14 -1
je skip_near_span
frame_span r4 r14 r15 3 100
label skip_near_span
add r4 1
cmp r4 r1
jlt row
frame_end
halt
