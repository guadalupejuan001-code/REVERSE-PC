#!reverse-pc-machine-v1
# SUPER RENDER XI: general triangle scanline without another graphics engine.
# Each invocation renders ONE arbitrary triangle in a configurable row window.
# Stream any number of triangles: there is no global body/ID array or fixed scene count.
# All edge intersections, half-pixel fill rules, clipping and depth metadata are XI.
# Memory bytes: uint32 LE W @200, H @204, firstRow @208, rowCount @212.
# Signed vertex coords use biased uint32 LE (subtract 2147483648).
# x0 @216 y0 @220 x1 @224 y1 @228 x2 @232 y2 @236.
# depth uint8 @240; material uint8 @241.
# Output each row: y, xLeft, xRight inclusive, depth, material.
# Pixel centers: (x+.5,y+.5). Left edge inclusive; right exclusive.
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
load8 r15 217
mul r15 256
add r4 r15
load8 r15 218
mul r15 65536
add r4 r15
load8 r15 219
mul r15 16777216
add r4 r15
sub r4 2147483648
load8 r5 220
load8 r15 221
mul r15 256
add r5 r15
load8 r15 222
mul r15 65536
add r5 r15
load8 r15 223
mul r15 16777216
add r5 r15
sub r5 2147483648
load8 r6 224
load8 r15 225
mul r15 256
add r6 r15
load8 r15 226
mul r15 65536
add r6 r15
load8 r15 227
mul r15 16777216
add r6 r15
sub r6 2147483648
load8 r7 228
load8 r15 229
mul r15 256
add r7 r15
load8 r15 230
mul r15 65536
add r7 r15
load8 r15 231
mul r15 16777216
add r7 r15
sub r7 2147483648
load8 r8 232
load8 r15 233
mul r15 256
add r8 r15
load8 r15 234
mul r15 65536
add r8 r15
load8 r15 235
mul r15 16777216
add r8 r15
sub r8 2147483648
load8 r9 236
load8 r15 237
mul r15 256
add r9 r15
load8 r15 238
mul r15 65536
add r9 r15
load8 r15 239
mul r15 16777216
add r9 r15
sub r9 2147483648
mov r10 r2
mov r11 r2
add r11 r3
cmp r0 1
jle invalid
cmp r1 1
jle invalid
cmp r3 0
jle invalid
cmp r11 r1
jgt invalid
jmp row
label invalid
set r10 -999
print r10
halt
label row
set r12 9223372036854775807
set r13 -9223372036854775807
# Edge 0: (r4,r5) -> (r6,r7); exact integer ceil of intersection.
cmp r5 r7
jle edge0_forward
cmp r10 r7
jlt edge0_done
cmp r10 r5
jge edge0_done
jmp edge0_solve
label edge0_forward
cmp r10 r5
jlt edge0_done
cmp r10 r7
jge edge0_done
label edge0_solve
mov r15 r7
sub r15 r5
mov r14 r10
mul r14 2
add r14 1
mov r2 r5
mul r2 2
sub r14 r2
mov r2 r6
sub r2 r4
mul r14 r2
mov r3 r4
mul r3 2
sub r3 1
mul r3 r15
add r14 r3
mul r15 2
cmp r15 0
jge edge0_positive
mul r15 -1
mul r14 -1
label edge0_positive
cmp r14 0
jlt edge0_ceil
add r14 r15
sub r14 1
label edge0_ceil
div r14 r15
cmp r14 r12
jge edge0_min_done
mov r12 r14
label edge0_min_done
cmp r14 r13
jle edge0_max_done
mov r13 r14
label edge0_max_done
label edge0_done
# Edge 1: (r6,r7) -> (r8,r9); exact integer ceil of intersection.
cmp r7 r9
jle edge1_forward
cmp r10 r9
jlt edge1_done
cmp r10 r7
jge edge1_done
jmp edge1_solve
label edge1_forward
cmp r10 r7
jlt edge1_done
cmp r10 r9
jge edge1_done
label edge1_solve
mov r15 r9
sub r15 r7
mov r14 r10
mul r14 2
add r14 1
mov r2 r7
mul r2 2
sub r14 r2
mov r2 r8
sub r2 r6
mul r14 r2
mov r3 r6
mul r3 2
sub r3 1
mul r3 r15
add r14 r3
mul r15 2
cmp r15 0
jge edge1_positive
mul r15 -1
mul r14 -1
label edge1_positive
cmp r14 0
jlt edge1_ceil
add r14 r15
sub r14 1
label edge1_ceil
div r14 r15
cmp r14 r12
jge edge1_min_done
mov r12 r14
label edge1_min_done
cmp r14 r13
jle edge1_max_done
mov r13 r14
label edge1_max_done
label edge1_done
# Edge 2: (r8,r9) -> (r4,r5); exact integer ceil of intersection.
cmp r9 r5
jle edge2_forward
cmp r10 r5
jlt edge2_done
cmp r10 r9
jge edge2_done
jmp edge2_solve
label edge2_forward
cmp r10 r9
jlt edge2_done
cmp r10 r5
jge edge2_done
label edge2_solve
mov r15 r5
sub r15 r9
mov r14 r10
mul r14 2
add r14 1
mov r2 r9
mul r2 2
sub r14 r2
mov r2 r4
sub r2 r8
mul r14 r2
mov r3 r8
mul r3 2
sub r3 1
mul r3 r15
add r14 r3
mul r15 2
cmp r15 0
jge edge2_positive
mul r15 -1
mul r14 -1
label edge2_positive
cmp r14 0
jlt edge2_ceil
add r14 r15
sub r14 1
label edge2_ceil
div r14 r15
cmp r14 r12
jge edge2_min_done
mov r12 r14
label edge2_min_done
cmp r14 r13
jle edge2_max_done
mov r13 r14
label edge2_max_done
label edge2_done
# Convert two rational edge bounds into an inclusive pixel run.
cmp r12 9223372036854775807
je empty
sub r13 1
cmp r12 0
jge left_in
set r12 0
label left_in
mov r15 r0
sub r15 1
cmp r13 r15
jle right_in
mov r13 r15
label right_in
cmp r12 r13
jle publish
label empty
set r12 -1
set r13 -1
label publish
load8 r2 240
load8 r3 241
print r10
print r12
print r13
print r2
print r3
add r10 1
cmp r10 r11
jlt row
halt
