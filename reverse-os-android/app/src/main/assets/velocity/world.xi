#!reverse-pc-machine-v1
# REVERSE VELOCITY stadium circuit, authored and generated entirely in XI.
# Centimeters; yaw4096: 0=+z,1024=+x. Radius12732, two40000cm straights.
# 81 centerline vertices close80 segments, about1600m total.
# World mailbox: 1000='X',1001='I',1002=2,1004=80.
# Vertex i at4096+8*i: little-endianu32(x+65536),u32(z+65536).
# Segment tangent yaw at5000+2*i, i0..79 (entry80 repeatsheading0).
# Observer output is exactly81 pairs x_cm,z_cm, printed r0 thenr1.
store8 1000 88
store8 1001 73
store8 1002 2
store8 1004 80
set r2 0
label world_vertex
cmp r2 20
jle world_outbound
cmp r2 40
jle world_arc_one
cmp r2 60
jle world_inbound
# Return semicircle: center(R,0), heading2048..4096.
set r14 2
mov r3 r2
sub r3 60
mul r3 2048
div r3 20
jmp world_arc_trig
label world_outbound
set r0 0
mov r1 r2
mul r1 2000
jmp world_tangent
label world_inbound
set r0 25464
mov r1 r2
sub r1 40
mul r1 2000
set r4 40000
sub r4 r1
mov r1 r4
jmp world_tangent
label world_arc_one
set r14 1
mov r3 r2
sub r3 20
mul r3 2048
div r3 20
label world_arc_trig
mov r4 r3
set r11 0
jmp world_sine
label world_sine_ready
mov r12 r5
mov r4 r3
add r4 1024
set r11 1
jmp world_sine
label world_cosine_ready
mov r13 r5
mul r12 12732
div r12 16384
mul r13 12732
div r13 16384
cmp r14 2
je world_arc_return
set r0 12732
sub r0 r13
set r1 40000
add r1 r12
jmp world_tangent
label world_arc_return
set r0 12732
add r0 r13
set r1 0
sub r1 r12
jmp world_tangent
# Bhaskara rational sine, fixed16384. Range reduction is exact at quadrant
# boundaries; products remain within signed64-bit integer range.
label world_sine
mod r4 4096
set r6 1
cmp r4 2048
jle world_sine_folded
sub r4 2048
set r6 -1
label world_sine_folded
mov r7 r4
set r10 2048
sub r10 r4
mul r7 r10
mov r8 r7
mul r8 16
mul r8 16384
mov r9 r7
mul r9 4
set r10 20971520
sub r10 r9
div r8 r10
mul r8 r6
mov r5 r8
cmp r11 0
je world_sine_ready
jmp world_cosine_ready
label world_tangent
# Tangents use each chord's midpoint heading. They are observations of the
# same stadium parameterization, never a host-side duplicate road function.
cmp r2 20
jlt world_tangent_out
cmp r2 40
jlt world_tangent_arc_one
cmp r2 60
jlt world_tangent_in
cmp r2 80
jge world_tangent_out
mov r3 r2
sub r3 60
mul r3 2
add r3 1
mul r3 2048
div r3 40
add r3 2048
jmp world_publish
label world_tangent_out
set r3 0
jmp world_publish
label world_tangent_in
set r3 2048
jmp world_publish
label world_tangent_arc_one
mov r3 r2
sub r3 20
mul r3 2
add r3 1
mul r3 2048
div r3 40
label world_publish
mov r4 r2
mul r4 8
add r4 4096
mov r5 r0
add r5 65536
set r7 4
label world_store_x
mov r6 r5
mod r6 256
store8 $r4 r6
add r4 1
div r5 256
sub r7 1
cmp r7 0
jgt world_store_x
mov r5 r1
add r5 65536
set r7 4
label world_store_z
mov r6 r5
mod r6 256
store8 $r4 r6
add r4 1
div r5 256
sub r7 1
cmp r7 0
jgt world_store_z
mov r4 r2
mul r4 2
add r4 5000
mov r5 r3
mod r5 256
store8 $r4 r5
add r4 1
div r3 256
store8 $r4 r3
print r0
print r1
add r2 1
cmp r2 80
jle world_vertex
halt
