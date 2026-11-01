#!reverse-pc-machine-v1
load8 r6 7500000000000000000
load8 r5 7500000000000000001
set r0 0
set r12 1
set r10 7500000000000000128
set r9 0
label load0
load8 r11 $r10
mul r11 r12
add r0 r11
mul r12 256
add r10 1
add r9 1
cmp r9 4
jlt load0
set r1 0
set r12 1
set r10 7500000000000000132
set r9 0
label load1
load8 r11 $r10
mul r11 r12
add r1 r11
mul r12 256
add r10 1
add r9 1
cmp r9 4
jlt load1
set r2 0
set r12 1
set r10 7500000000000000136
set r9 0
label load2
load8 r11 $r10
mul r11 r12
add r2 r11
mul r12 256
add r10 1
add r9 1
cmp r9 4
jlt load2
set r3 0
set r12 1
set r10 7500000000000000140
set r9 0
label load3
load8 r11 $r10
mul r11 r12
add r3 r11
mul r12 256
add r10 1
add r9 1
cmp r9 4
jlt load3
set r4 0
set r12 1
set r10 7500000000000000144
set r9 0
label load4
load8 r11 $r10
mul r11 r12
add r4 r11
mul r12 256
add r10 1
add r9 1
cmp r9 4
jlt load4
cmp r6 0
je reset
cmp r6 1
je hit
cmp r6 2
je miss
jmp report
label reset
set r0 0
set r1 0
set r2 0
set r3 0
set r4 0
jmp persist
label hit
add r1 1
add r2 1
cmp r1 r4
jle aftermax
mov r4 r1
label aftermax
mov r7 r1
div r7 12
add r7 1
cmp r7 4
jle capped
set r7 4
label capped
mul r5 r7
add r0 r5
jmp persist
label miss
set r1 0
add r3 1
label persist
mov r8 r0
set r10 7500000000000000128
set r9 0
label save0
mov r11 r8
mod r11 256
store8 $r10 r11
div r8 256
add r10 1
add r9 1
cmp r9 4
jlt save0
mov r8 r1
set r10 7500000000000000132
set r9 0
label save1
mov r11 r8
mod r11 256
store8 $r10 r11
div r8 256
add r10 1
add r9 1
cmp r9 4
jlt save1
mov r8 r2
set r10 7500000000000000136
set r9 0
label save2
mov r11 r8
mod r11 256
store8 $r10 r11
div r8 256
add r10 1
add r9 1
cmp r9 4
jlt save2
mov r8 r3
set r10 7500000000000000140
set r9 0
label save3
mov r11 r8
mod r11 256
store8 $r10 r11
div r8 256
add r10 1
add r9 1
cmp r9 4
jlt save3
mov r8 r4
set r10 7500000000000000144
set r9 0
label save4
mov r11 r8
mod r11 256
store8 $r10 r11
div r8 256
add r10 1
add r9 1
cmp r9 4
jlt save4
label report
print r0
print r1
print r2
print r3
print r4
halt
