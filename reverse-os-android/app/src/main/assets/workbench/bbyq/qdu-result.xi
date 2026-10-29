#!reverse-pc-machine-v1
# BBY Q XI result handback for a W4u-verified QdU task.
load8 r0 8440000000000000006
cmp r0 1
jne bad
load8 r0 8300000000000000768
cmp r0 3
jne bad
load8 r0 8300000000000000773
cmp r0 1
jne bad
set r0 0
jmp emit
label bad
set r0 1
label emit
print r0
halt
