#!reverse-pc-machine-v1
# XI is the only owner of driving state and game progress.
# Mailbox: 128 gas,129 brake,130 steer (0/1/2),131 drift,132 reset.
# Memory 122..123 retains sub-cm/s acceleration, biased by 1000.
load8 r9 132
cmp r9 1
je initialize
load8 r9 121
cmp r9 1
jne initialize
load8 r0 100
load8 r10 101
mul r10 256
add r0 r10
load8 r10 102
mul r10 65536
add r0 r10
load8 r10 103
mul r10 16777216
add r0 r10
sub r0 2000000
load8 r1 104
load8 r10 105
mul r10 256
add r1 r10
load8 r10 106
mul r10 65536
add r1 r10
load8 r10 107
mul r10 16777216
add r1 r10
sub r1 2000000
load8 r2 108
load8 r10 109
mul r10 256
add r2 r10
load8 r3 110
load8 r10 111
mul r10 256
add r3 r10
load8 r4 112
load8 r10 113
mul r10 256
add r4 r10
sub r4 32768
load8 r5 114
load8 r6 115
load8 r10 116
mul r10 256
add r6 r10
load8 r10 117
mul r10 65536
add r6 r10
load8 r10 118
mul r10 16777216
add r6 r10
load8 r7 119
load8 r8 120
jmp advance
label initialize
set r0 83
set r1 110000
set r2 0
set r3 0
set r4 0
set r5 0
set r6 0
set r7 0
set r8 0
store8 122 232
store8 123 3
jmp commit
label advance
cmp r7 1
je commit
# The race begins with the first throttle input, not while the player reads
# the controls. After that, the authoritative clock keeps running at rest.
cmp r6 0
jgt race_started
load8 r9 128
cmp r9 1
jne commit
label race_started
load8 r9 130
sub r9 1
load8 r10 128
mul r10 1100
load8 r11 129
mul r11 2500
sub r10 r11
set r11 45
mov r13 r3
mul r13 r3
div r13 160000
add r11 r13
cmp r8 1
jne paved_resistance
add r11 550
label paved_resistance
load8 r12 131
cmp r12 1
jne no_drift_resistance
add r11 300
label no_drift_resistance
sub r10 r11
mul r10 20
# Carry the signed remainder between 20ms ticks. Without it, passive drag
# below 50cm/s² rounds to zero and a slow car would coast forever.
load8 r14 122
load8 r15 123
mul r15 256
add r14 r15
sub r14 1000
add r10 r14
mov r14 r10
mod r14 1000
add r14 1000
mov r15 r14
mod r15 256
store8 122 r15
div r14 256
store8 123 r14
div r10 1000
add r3 r10
cmp r3 0
jge speed_min
set r3 0
store8 122 232
store8 123 3
label speed_min
cmp r3 7800
jle speed_max
set r3 7800
store8 122 232
store8 123 3
label speed_max
mov r13 r3
cmp r13 3500
jle turn_limit
set r13 3500
label turn_limit
div r13 220
mul r13 r9
cmp r12 1
jne normal_turn
mul r13 16
div r13 10
label normal_turn
add r2 r13
mod r2 4096
cmp r2 0
jge yaw_nonnegative
add r2 4096
label yaw_nonnegative
mov r13 r3
mul r13 r9
cmp r12 1
jne normal_slip
mul r13 34
jmp slip_desired
label normal_slip
mul r13 6
label slip_desired
div r13 100
sub r13 r4
cmp r12 1
jne grip_response
mul r13 135
jmp apply_grip
label grip_response
mul r13 290
label apply_grip
div r13 1000
add r4 r13
cmp r4 -2600
jge slip_min
set r4 -2600
label slip_min
cmp r4 2600
jle slip_max
set r4 2600
label slip_max
cmp r3 100
jge speed_move
set r4 0
label speed_move
mov r14 r0
mov r15 r1
mov r13 r2
mod r13 4096
cmp r13 1024
jle sin_a
cmp r13 2048
jle sin_b
cmp r13 3072
jle sin_c
mov r10 r13
sub r10 4096
jmp sin_done
label sin_a
mov r10 r13
jmp sin_done
label sin_b
set r10 2048
sub r10 r13
jmp sin_done
label sin_c
set r10 2048
sub r10 r13
label sin_done
mov r13 r2
add r13 1024
mod r13 4096
cmp r13 1024
jle cos_a
cmp r13 2048
jle cos_b
cmp r13 3072
jle cos_c
mov r11 r13
sub r11 4096
jmp cos_done
label cos_a
mov r11 r13
jmp cos_done
label cos_b
set r11 2048
sub r11 r13
jmp cos_done
label cos_c
set r11 2048
sub r11 r13
label cos_done
mov r12 r3
mul r12 20
div r12 1000
mov r13 r4
mul r13 20
div r13 1000
mov r9 r12
mul r9 r10
mov r8 r13
mul r8 r11
add r9 r8
div r9 1024
add r0 r9
mov r8 r13
mul r8 r10
mov r9 r12
mul r9 r11
sub r8 r9
div r8 1024
add r1 r8
mov r13 r1
mod r13 48000
cmp r13 0
jge road_pos1
add r13 48000
label road_pos1
cmp r13 24000
jle road_up1
set r10 48000
sub r10 r13
mov r13 r10
label road_up1
sub r13 12000
div r13 6
mov r10 r1
mod r10 16000
cmp r10 0
jge road_pos2
add r10 16000
label road_pos2
cmp r10 8000
jle road_up2
set r11 16000
sub r11 r10
mov r10 r11
label road_up2
sub r10 4000
div r10 8
add r13 r10
mov r9 r0
sub r9 r13
cmp r9 -1050
jlt outside_road
cmp r9 1050
jgt outside_road
set r8 0
jmp road_done
label outside_road
set r8 1
label road_done
add r6 1
cmp r5 6
jge commit
cmp r5 0
je gate_0
cmp r5 1
je gate_1
cmp r5 2
je gate_2
cmp r5 3
je gate_3
cmp r5 4
je gate_4
cmp r5 5
je gate_5
jmp commit
label gate_0
set r12 90000
set r13 -750
jmp cross_gate
label gate_1
set r12 60000
set r13 0
jmp cross_gate
label gate_2
set r12 30000
set r13 750
jmp cross_gate
label gate_3
set r12 0
set r13 -2500
jmp cross_gate
label gate_4
set r12 -30000
set r13 750
jmp cross_gate
label gate_5
set r12 -60000
set r13 0
jmp cross_gate
label cross_gate
cmp r15 r12
jle commit
cmp r1 r12
jgt commit
mov r9 r0
sub r9 r14
mov r10 r15
sub r10 r12
mul r9 r10
mov r10 r15
sub r10 r1
cmp r10 0
je commit
div r9 r10
add r9 r14
sub r9 r13
cmp r9 -1500
jlt commit
cmp r9 1500
jgt commit
add r5 1
cmp r5 6
jne commit
set r7 1
label commit
mov r9 r0
add r9 2000000
mov r10 r9
mod r10 256
store8 100 r10
div r9 256
mov r10 r9
mod r10 256
store8 101 r10
div r9 256
mov r10 r9
mod r10 256
store8 102 r10
div r9 256
mov r10 r9
mod r10 256
store8 103 r10
mov r9 r1
add r9 2000000
mov r10 r9
mod r10 256
store8 104 r10
div r9 256
mov r10 r9
mod r10 256
store8 105 r10
div r9 256
mov r10 r9
mod r10 256
store8 106 r10
div r9 256
mov r10 r9
mod r10 256
store8 107 r10
mov r9 r2
mov r10 r9
mod r10 256
store8 108 r10
div r9 256
mov r10 r9
mod r10 256
store8 109 r10
mov r9 r3
mov r10 r9
mod r10 256
store8 110 r10
div r9 256
mov r10 r9
mod r10 256
store8 111 r10
mov r9 r4
add r9 32768
mov r10 r9
mod r10 256
store8 112 r10
div r9 256
mov r10 r9
mod r10 256
store8 113 r10
store8 114 r5
mov r9 r6
mov r10 r9
mod r10 256
store8 115 r10
div r9 256
mov r10 r9
mod r10 256
store8 116 r10
div r9 256
mov r10 r9
mod r10 256
store8 117 r10
div r9 256
mov r10 r9
mod r10 256
store8 118 r10
store8 119 r7
store8 120 r8
store8 121 1
print r0
print r1
print r2
print r3
print r4
print r5
print r6
print r7
print r8
halt
