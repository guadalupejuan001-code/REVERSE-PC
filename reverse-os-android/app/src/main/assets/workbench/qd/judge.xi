#!reverse-pc-machine-v1
# Qd XI assessor decides whether an evaluated lesson can be consolidated.
# M+4 = number of passed executions, M+5 = total evaluations.
load8 r0 8410000000000000000
cmp r0 81
jne invalid
load8 r0 8410000000000000001
cmp r0 3
jne invalid
load8 r1 8410000000000000004
load8 r2 8410000000000000005
set r0 0
cmp r2 8
jne verdict
cmp r1 r2
jne verdict
set r0 1
label verdict
print r0
halt
label invalid
div r0 0
