#!reverse-pc-machine-v1
# w4U XI: independently validate QdU integer arithmetic result after single-use dispatch.
# Typed host transports signed16 little-endian, no host policy for XI verdict.
load8 r0 8300000000000000768
cmp r0 2
jne denied
load8 r0 8300000000000000773
cmp r0 1
jne denied
load8 r0 8460000000000000080
cmp r0 1
jne denied
load8 r1 8460000000000000081
cmp r1 1
jlt denied
cmp r1 5
jgt denied
load8 r2 8460000000000000082
load8 r3 8460000000000000083
cmp r2 99
jgt denied
cmp r3 99
jgt denied
cmp r1 4
je check_zero
cmp r1 5
jne calculate
label check_zero
cmp r3 0
je denied
label calculate
mov r4 r2
cmp r1 1
je do_add
cmp r1 2
je do_sub
cmp r1 3
je do_mul
cmp r1 4
je do_div
cmp r1 5
je do_mod
jmp denied
label do_add
add r4 r3
jmp compare
label do_sub
sub r4 r3
jmp compare
label do_mul
mul r4 r3
jmp compare
label do_div
div r4 r3
jmp compare
label do_mod
mod r4 r3
label compare
load8 r5 8460000000000000084
load8 r6 8460000000000000085
mul r6 256
add r5 r6
cmp r5 32768
jlt decoded
sub r5 65536
label decoded
cmp r4 r5
jne denied
store8 8300000000000000768 3
set r0 0
jmp emit
label denied
store8 8300000000000000768 4
set r0 1
label emit
print r0
halt
