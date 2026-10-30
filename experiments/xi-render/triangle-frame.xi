#!reverse-pc-machine-v1
# X Render XI experiment / version 1.
# The only per-pixel geometry algorithm in this experiment is XI.
# Inputs: InverseMemory bytes 200=width 201=height (multiples of 24, <=192).
# Three pixel classes: background 0, rear triangle 2, front triangle 3.
# XI uses the same 2D projected triangles as native X Render's 3D observer.
# Pixel centers shifted into triangle-local coordinates by (0.2, 0.1)
# to make edge classification unambiguous in fixed-point 1/10 units.
load8 r10 200
load8 r11 201
mov r2 r10
mul r2 10
mov r3 r11
mul r3 10
set r8 0
set r9 0
set r14 0
label pixel
mov r0 r8
mul r0 10
add r0 3
mov r1 r9
mul r1 10
add r1 4
set r12 0
# Rear triangle: (W/8,H/8), (7W/8,H/8), (W/2,7H/8).
mov r4 r1
mul r4 8
cmp r4 r3
jlt front
mov r5 r3
mul r5 7
cmp r4 r5
jgt front
sub r4 r3
mov r5 r0
mul r5 8
mov r6 r2
mul r6 7
sub r5 r6
mov r6 r2
mul r6 3
mul r6 r4
mov r7 r3
mul r7 6
mul r7 r5
add r6 r7
cmp r6 0
jgt front
mov r4 r1
mul r4 8
mov r5 r3
mul r5 7
sub r4 r5
mov r5 r0
mul r5 8
mov r6 r2
mul r6 4
sub r5 r6
mov r6 r2
mul r6 -3
mul r6 r4
mov r7 r3
mul r7 6
mul r7 r5
add r6 r7
cmp r6 0
jlt front
set r12 2
label front
# Front triangle: (W/4,H/3), (3W/4,H/3), (W/2,5H/6).
# Two-sided, closer depth than the rear triangle: front wins overlaps.
mov r4 r1
mul r4 3
cmp r4 r3
jlt output
mov r5 r3
mul r5 5
mov r6 r1
mul r6 6
cmp r6 r5
jgt output
sub r4 r3
mov r5 r0
mul r5 4
mov r6 r2
mul r6 3
sub r5 r6
mov r6 r2
mul r6 2
mul r6 r4
mov r7 r3
mul r7 3
mul r7 r5
add r6 r7
cmp r6 0
jgt output
mov r4 r1
mul r4 6
mov r5 r3
mul r5 5
sub r4 r5
mov r5 r0
mul r5 2
sub r5 r2
mov r6 r2
mul r6 -1
mul r6 r4
mov r7 r3
mul r7 6
mul r7 r5
add r6 r7
cmp r6 0
jlt output
set r12 3
label output
# Serializable framebuffer: one pixel class per XI print, row-major,
# plus a bounded rolling checksum to detect ordering or dropped pixels.
mul r14 131
add r14 r12
mod r14 1000000007
print r12
add r8 1
cmp r8 r10
jlt pixel
set r8 0
add r9 1
cmp r9 r11
jlt pixel
print r14
halt
