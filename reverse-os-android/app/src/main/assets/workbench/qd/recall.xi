#!reverse-pc-machine-v1
# Qd reads one template from BBY Q's private RVPC2. It prints bytes, not JS code.
load8 r0 8410000000000000000
cmp r0 81
jne invalid
load8 r0 8410000000000000001
cmp r0 2
jne invalid
load8 r1 8410000000000000002
cmp r1 1
jlt invalid
cmp r1 4
jgt invalid
set r3 8400000000000000000
mov r4 r1
mul r4 1024
add r3 r4
load8 r2 $r3
cmp r2 0
je done
cmp r2 192
jgt invalid
set r6 0
label emit
cmp r6 r2
jge done
mov r7 r3
add r7 1
add r7 r6
load8 r0 $r7
print r0
add r6 1
jmp emit
label done
halt
label invalid
div r0 0
