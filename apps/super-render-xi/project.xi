#!reverse-pc-machine-v1
# SUPER RENDER XI: world-space 3D -> 2D perspective projector in XI.
# Inputs: W uint32 @200, H uint32 @204. Camera signed xyz32 @336,340,344.
# Focal length uint32 @348. Vertex signed XYZ32 @300..335, 12 bytes each.
# Output: three signed projected XY32 @216..239 in the same Ether snapshot.
# Near-plane invalid/overflow causes an atomic XI transaction failure.
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
load8 r2 336
load8 r15 337
mul r15 256
add r2 r15
load8 r15 338
mul r15 65536
add r2 r15
load8 r15 339
mul r15 16777216
add r2 r15
sub r2 2147483648
load8 r3 340
load8 r15 341
mul r15 256
add r3 r15
load8 r15 342
mul r15 65536
add r3 r15
load8 r15 343
mul r15 16777216
add r3 r15
sub r3 2147483648
load8 r4 344
load8 r15 345
mul r15 256
add r4 r15
load8 r15 346
mul r15 65536
add r4 r15
load8 r15 347
mul r15 16777216
add r4 r15
sub r4 2147483648
load8 r5 348
load8 r15 349
mul r15 256
add r5 r15
load8 r15 350
mul r15 65536
add r5 r15
load8 r15 351
mul r15 16777216
add r5 r15
cmp r0 2
jlt invalid
cmp r1 2
jlt invalid
cmp r5 1
jlt invalid
set r6 300
set r7 216
set r8 3
label vertex
load8 r9 $r6
add r6 1
load8 r15 $r6
mul r15 256
add r9 r15
add r6 1
load8 r15 $r6
mul r15 65536
add r9 r15
add r6 1
load8 r15 $r6
mul r15 16777216
add r9 r15
add r6 1
sub r9 2147483648
load8 r10 $r6
add r6 1
load8 r15 $r6
mul r15 256
add r10 r15
add r6 1
load8 r15 $r6
mul r15 65536
add r10 r15
add r6 1
load8 r15 $r6
mul r15 16777216
add r10 r15
add r6 1
sub r10 2147483648
load8 r11 $r6
add r6 1
load8 r15 $r6
mul r15 256
add r11 r15
add r6 1
load8 r15 $r6
mul r15 65536
add r11 r15
add r6 1
load8 r15 $r6
mul r15 16777216
add r11 r15
add r6 1
sub r11 2147483648
mov r12 r4
sub r12 r11
cmp r12 1
jlt invalid
# Screen center + normalized perspective, integer exact truncation.
mov r13 r9
sub r13 r2
mul r13 r5
div r13 r12
mov r15 r0
div r15 2
add r13 r15
mov r14 r10
sub r14 r3
mul r14 r5
div r14 r12
mov r15 r1
div r15 2
sub r15 r14
mov r14 r15
cmp r13 -2147483648
jlt invalid
cmp r13 2147483647
jgt invalid
cmp r14 -2147483648
jlt invalid
cmp r14 2147483647
jgt invalid
add r13 2147483648
add r14 2147483648
mov r15 r13
mod r15 256
store8 $r7 r15
add r7 1
div r13 256
mov r15 r13
mod r15 256
store8 $r7 r15
add r7 1
div r13 256
mov r15 r13
mod r15 256
store8 $r7 r15
add r7 1
div r13 256
mov r15 r13
mod r15 256
store8 $r7 r15
add r7 1
div r13 256
mov r15 r14
mod r15 256
store8 $r7 r15
add r7 1
div r14 256
mov r15 r14
mod r15 256
store8 $r7 r15
add r7 1
div r14 256
mov r15 r14
mod r15 256
store8 $r7 r15
add r7 1
div r14 256
mov r15 r14
mod r15 256
store8 $r7 r15
add r7 1
div r14 256
sub r8 1
cmp r8 0
jgt vertex
halt
label invalid
# Trigger transactional failure. The tentative projected bytes are rolled back.
set r12 0
div r12 0
halt
