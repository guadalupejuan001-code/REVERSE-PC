#!reverse-pc-machine-v1
# World source authority: all centerline points are computed in XI, centimeters.
# Each two print lines encode z_cm,x_cm for X Render's read-only observer.
# XI renderer requires this two-byte world-source marker.
store8 1000 88
store8 1001 73
set r0 -85000
label vertex
mov r1 r0
mod r1 48000
cmp r1 0
jge w_pos1
add r1 48000
label w_pos1
cmp r1 24000
jle w_up1
set r2 48000
sub r2 r1
mov r1 r2
label w_up1
sub r1 12000
div r1 6
mov r2 r0
mod r2 16000
cmp r2 0
jge w_pos2
add r2 16000
label w_pos2
cmp r2 8000
jle w_up2
set r3 16000
sub r3 r2
mov r2 r3
label w_up2
sub r2 4000
div r2 8
add r1 r2
# Publish each already-computed XI centerline sample in isolated InverseMemory.
# 241 signed x-centimeter coordinates, biased by +8192, low/high byte.
# Renderer reads 512..993; there is no duplicate road equation in the host.
mov r4 r0
add r4 85000
div r4 1000
mul r4 2
add r4 512
mov r5 r1
add r5 8192
mov r6 r5
mod r6 256
store8 $r4 r6
add r4 1
mov r6 r5
div r6 256
store8 $r4 r6
print r0
print r1
add r0 1000
cmp r0 155000
jle vertex
halt
