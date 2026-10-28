#!reverse-pc-machine-v1
# Sensitivity experiment, NOT a market model or proof of chaos:
# F(x) = 2*x; initial states differ by only 1.
set r0 1
set r1 2
set r2 0
label evolve
mul r0 2
mul r1 2
add r2 1
cmp r2 15
jlt evolve
mov r3 r1
sub r3 r0
cmp r3 32768
je amplification_ok
set r15 1
div r15 0
label amplification_ok
print r0
print r1
print r3
halt
