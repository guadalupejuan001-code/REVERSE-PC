#!reverse-pc-machine-v1
# The baseline prediction was committed before the surprise event.
# The event is inserted at t=19. Forecast does not know this input.
load8 r8 731000000000000000000000001
load8 r9 731000000000000000000000002
mul r9 256
add r9 r8
cmp r9 12620
je baseline_ok
set r15 1
div r15 0
label baseline_ok
set r0 10000
set r1 0
set r2 250
label simulate
mov r3 r1
mul r3 3
add r3 7
add r0 r3
cmp r1 19
jne no_event
add r0 r2
label no_event
add r1 1
cmp r1 40
jlt simulate
# r9: forecast before shock; r0: actual; r4: out-of-sample error.
mov r4 r0
sub r4 r9
print r9
print r0
print r4
# Conditional recalculation if the shock becomes known.
mov r5 r9
add r5 r2
cmp r0 r5
je conditional_ok
set r15 1
div r15 0
label conditional_ok
print r5
set r15 1
print r15
halt
