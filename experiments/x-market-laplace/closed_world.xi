#!reverse-pc-machine-v1
# X MARKET Laplace Lab: closed deterministic micro-market.
# Units: integer cents. Rule: P(t+1) = P(t) + 7 + 3*t, t = 0..39.
# Exact arithmetic is possible only because rules and initial state are known.
set r0 10000
set r1 0
label simulate
mov r2 r1
mul r2 3
add r2 7
add r0 r2
add r1 1
cmp r1 40
jlt simulate
# Independent mathematical oracle:
# P(40) = 10000 + 7*40 + 3*40*39/2 = 12620.
set r3 40
mov r4 r3
sub r4 1
mul r4 r3
div r4 2
mul r4 3
mov r5 r3
mul r5 7
add r5 10000
add r5 r4
print r0
print r5
cmp r0 r5
je oracle_ok
# A disagreement aborts the whole transaction: no partial success.
set r15 1
div r15 0
label oracle_ok
# Persist the bounded positive price as two bytes in InverseMemory.
# This is an experiment-specific address range, NOT an isolated namespace.
mov r6 r0
mod r6 256
mov r7 r0
div r7 256
store8 731000000000000000000000001 r6
store8 731000000000000000000000002 r7
load8 r8 731000000000000000000000001
load8 r9 731000000000000000000000002
mul r9 256
add r9 r8
cmp r9 r5
je memory_ok
set r15 1
div r15 0
label memory_ok
print r9
set r15 1
print r15
halt
