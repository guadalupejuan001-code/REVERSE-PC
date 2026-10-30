#!reverse-pc-machine-v1
# BBY Q XI: classify an explicit coding request inside the SAME BBY Q RVPC2 snapshot.
# Only a bounded task-kind classification; NOT BBY Q's general language inference.
load8 r0 8460000000000000000
cmp r0 66
jne invalid
load8 r0 8460000000000000001
cmp r0 1
jne invalid
load8 r8 8460000000000000002
cmp r8 1
jlt invalid
cmp r8 18
jgt invalid
load8 r0 8460000000000000003
cmp r0 2
jne invalid
set r11 0
set r9 0
set r10 0
label loop
cmp r11 r8
jge inspect
set r4 8460000000000000016
mov r5 r11
mul r5 2
add r4 r5
load8 r6 $r4
add r4 1
load8 r5 $r4
mul r5 256
add r6 r5
cmp r6 48992
je found_task
cmp r6 18340
je found_task
cmp r6 7918
je found_task
cmp r6 45215
je found_task
cmp r6 32721
je found_task
cmp r6 3521
je found_neg
cmp r6 43746
je found_neg
cmp r6 10286
je found_neg
cmp r6 9810
je found_neg
cmp r6 48359
je found_neg
jmp advance
label found_task
set r9 1
jmp advance
label found_neg
set r10 1
label advance
add r11 1
jmp loop
label inspect
cmp r10 1
je denied
cmp r9 1
jne denied
store8 8460000000000000006 1
set r0 0
jmp emit
label invalid
set r0 2
jmp fail
label denied
set r0 1
label fail
store8 8460000000000000006 0
label emit
print r0
halt
