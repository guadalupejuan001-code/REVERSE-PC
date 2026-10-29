#!reverse-pc-machine-v1
# World source authority: all centerline points are computed in XI, centimeters.
# Each two print lines encode z_cm,x_cm for X Render's read-only observer.
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
print r0
print r1
add r0 1000
cmp r0 155000
jle vertex
halt
