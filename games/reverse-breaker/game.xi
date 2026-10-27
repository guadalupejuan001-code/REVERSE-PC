#!reverse-pc-machine-v1
# REVERSE BREAKER 1.0.0 — all gameplay runs in XI / Inverse Ether Memory.
# Frame ABI: input LE16 paddle@64, command@66 (0 none,1 serve,2 new), ticks@67 (0..4).
# State: version@0,status@1,lives@2,level@3,x@4,y@6,vx+128@8,vy+128@9,
# paddle@10,score@12,remaining@14,best@15,event@17,tick@18,rows LE16@32..41.
# World 1000x600; 60 fixed ticks/s; 10x5 bricks. No randomness or host physics.
load8 r7 1
load8 r6 2
load8 r8 3
load8 r0 4
load8 r15 5
mul r15 256
add r0 r15
load8 r1 6
load8 r15 7
mul r15 256
add r1 r15
load8 r2 8
sub r2 128
load8 r3 9
sub r3 128
load8 r4 64
load8 r15 65
mul r15 256
add r4 r15
cmp r4 85
jge input_right
set r4 85
label input_right
cmp r4 915
jle input_done
set r4 915
label input_done
load8 r5 12
load8 r15 13
mul r15 256
add r5 r15
load8 r9 14
store8 17 0
load8 r15 0
cmp r15 1
jne new_game
load8 r15 66
cmp r15 2
je new_game
jmp ready_check
label new_game
store8 0 1
set r6 3
set r8 1
set r5 0
jmp reset_wave
label reset_wave
set r9 50
set r7 0
set r11 32
label rows_reset
store8 $r11 255
add r11 1
store8 $r11 3
add r11 1
cmp r11 42
jlt rows_reset
store8 17 4
label ready_check
cmp r7 0
jne tick_setup
mov r0 r4
set r1 510
set r2 4
mov r3 r8
add r3 6
mul r3 -1
load8 r15 66
cmp r15 1
jne output_state
set r7 1
label tick_setup
cmp r7 1
jne output_state
load8 r10 67
cmp r10 0
je output_state
label tick
mov r11 r1
add r0 r2
add r1 r3
cmp r0 24
jge wall_right
set r0 24
cmp r2 0
jge wall_right
mul r2 -1
store8 17 1
label wall_right
cmp r0 976
jle wall_top
set r0 976
cmp r2 0
jle wall_top
mul r2 -1
store8 17 1
label wall_top
cmp r1 58
jge paddle_check
set r1 58
cmp r3 0
jge paddle_check
mul r3 -1
store8 17 1
label paddle_check
cmp r3 0
jle brick_check
cmp r11 522
jgt floor_check
cmp r1 522
jlt brick_check
mov r12 r0
sub r12 r4
cmp r12 -74
jlt floor_check
cmp r12 74
jgt floor_check
set r1 522
mov r2 r12
div r2 9
cmp r2 -10
jge paddle_max
set r2 -10
label paddle_max
cmp r2 10
jle paddle_nonzero
set r2 10
label paddle_nonzero
cmp r2 0
jne paddle_bounce
set r2 2
label paddle_bounce
mov r3 r8
add r3 6
mul r3 -1
store8 17 2
jmp tick_end
label floor_check
cmp r1 594
jle brick_check
sub r6 1
set r7 0
store8 17 3
cmp r6 0
jgt life_ready
set r7 2
store8 17 5
jmp output_state
label life_ready
mov r0 r4
set r1 510
jmp output_state
label brick_check
cmp r0 60
jlt tick_end
cmp r0 940
jge tick_end
cmp r1 100
jlt tick_end
cmp r1 280
jge tick_end
mov r12 r0
sub r12 60
mov r15 r12
mod r15 88
cmp r15 82
jgt tick_end
div r12 88
mov r11 r1
sub r11 100
mov r15 r11
mod r15 36
cmp r15 28
jgt tick_end
div r11 36
# Row index in r11; compute score weight before converting it to a pointer.
set r13 6
sub r13 r11
mul r13 10
store8 90 r13
mul r11 2
add r11 32
load8 r13 $r11
add r11 1
load8 r15 $r11
sub r11 1
mul r15 256
add r13 r15
set r14 1
label bit_power
cmp r12 0
je bit_ready
mul r14 2
sub r12 1
jmp bit_power
label bit_ready
mov r15 r13
div r15 r14
mod r15 2
cmp r15 0
je tick_end
sub r13 r14
mov r15 r13
mod r15 256
store8 $r11 r15
add r11 1
div r13 256
store8 $r11 r13
mul r3 -1
load8 r15 90
add r5 r15
cmp r5 60000
jle score_ok
set r5 60000
label score_ok
sub r9 1
store8 17 6
cmp r9 0
jne tick_end
add r8 1
cmp r8 5
jle next_wave
set r8 5
set r7 3
store8 17 7
jmp output_state
label next_wave
jmp reset_wave
label tick_end
load8 r11 18
load8 r15 19
mul r15 256
add r11 r15
add r11 1
mod r11 65536
mov r15 r11
mod r15 256
store8 18 r15
mov r15 r11
div r15 256
store8 19 r15
sub r10 1
cmp r10 0
jgt tick
label output_state
store8 1 r7
store8 2 r6
store8 3 r8
mov r15 r0
mod r15 256
store8 4 r15
mov r15 r0
div r15 256
store8 5 r15
mov r15 r1
mod r15 256
store8 6 r15
mov r15 r1
div r15 256
store8 7 r15
mov r15 r2
add r15 128
store8 8 r15
mov r15 r3
add r15 128
store8 9 r15
mov r15 r4
mod r15 256
store8 10 r15
mov r15 r4
div r15 256
store8 11 r15
mov r15 r5
mod r15 256
store8 12 r15
mov r15 r5
div r15 256
store8 13 r15
store8 14 r9
load8 r11 15
load8 r15 16
mul r15 256
add r11 r15
cmp r5 r11
jle best_ok
mov r11 r5
mov r15 r11
mod r15 256
store8 15 r15
mov r15 r11
div r15 256
store8 16 r15
label best_ok
print r0
print r1
print r2
print r3
print r4
print r5
print r6
print r7
print r8
print r9
print r11
load8 r12 17
print r12
load8 r12 32
load8 r15 33
mul r15 256
add r12 r15
print r12
load8 r12 34
load8 r15 35
mul r15 256
add r12 r15
print r12
load8 r12 36
load8 r15 37
mul r15 256
add r12 r15
print r12
load8 r12 38
load8 r15 39
mul r15 256
add r12 r15
print r12
load8 r12 40
load8 r15 41
mul r15 256
add r12 r15
print r12
load8 r12 18
load8 r15 19
mul r15 256
add r12 r15
print r12
halt
