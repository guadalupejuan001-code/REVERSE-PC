#!reverse-pc-machine-v1
# Qd v1: commit one reviewed coding pattern to BBY Q's OWN RVPC2.
# The host may stage typed input, but ONLY XI accepts and copies it.
# v2 requires full 32/32 assessed cases; stored template format unchanged.
# B=8440000000000000000, M=8410000000000000000.
load8 r0 8410000000000000000
cmp r0 81
jne invalid
load8 r0 8410000000000000001
cmp r0 1
jne invalid
load8 r10 8410000000000000004
cmp r10 32
jne invalid
load8 r10 8410000000000000005
cmp r10 32
jne invalid
load8 r1 8410000000000000002
cmp r1 1
jlt invalid
cmp r1 4
jgt invalid
load8 r2 8410000000000000003
cmp r2 1
jlt invalid
cmp r2 192
jgt invalid
set r3 8440000000000000000
mov r4 r1
mul r4 1024
add r3 r4
set r6 0
label copy
cmp r6 r2
jge finish
set r7 8410000000000000016
add r7 r6
load8 r8 $r7
cmp r8 10
je ascii_ok
cmp r8 32
jlt invalid
cmp r8 126
jgt invalid
label ascii_ok
mov r9 r3
add r9 1
add r9 r6
store8 $r9 r8
add r6 1
jmp copy
label finish
store8 $r3 r2
store8 8440000000000000000 81
store8 8440000000000000001 1
load8 r10 8440000000000000016
cmp r10 250
jge no_increment
add r10 1
store8 8440000000000000016 r10
label no_increment
store8 8410000000000000000 0
store8 8410000000000000001 0
print r1
print r2
halt
label invalid
div r0 0
