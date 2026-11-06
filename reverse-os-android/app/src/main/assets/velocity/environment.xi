#!reverse-pc-machine-v1
# Eight-minute daylight cycle. Only physics ticks advance the clock.
load32 r0 528
mul r0 4096
div r0 24000
load8 r1 137
cmp r1 1
je open_time_day
cmp r1 2
je open_time_dusk
cmp r1 3
je open_time_night
jmp open_time_ready
label open_time_day
set r0 0
jmp open_time_ready
label open_time_dusk
set r0 2048
jmp open_time_ready
label open_time_night
set r0 3072
label open_time_ready
store16 524 r0
set r1 0
cmp r0 1792
jlt open_light_ready
cmp r0 2304
jlt open_light_dusk
cmp r0 3584
jlt open_light_night
jmp open_light_dusk
label open_light_dusk
set r1 1
jmp open_light_ready
label open_light_night
set r1 2
label open_light_ready
store8 526 r1
load32 r0 100
sub r0 2000000000
print r0
load32 r1 104
sub r1 2000000000
print r1
load16 r2 108
print r2
load16 r3 110
print r3
load16 r4 112
sub r4 32768
print r4
load8 r5 114
print r5
load32 r6 115
print r6
load8 r7 119
print r7
load8 r8 120
print r8
load8 r9 282
print r9
load8 r10 114
div r10 4
print r10
load32 r11 274
print r11
load8 r12 273
print r12
load16 r13 259
print r13
load8 r14 283
print r14
load32 r0 278
mov r15 r0
print r15
# Observation ABI v0.4: legacy 16 registers untouched.
load16 r0 380
print r0
load8 r1 382
print r1
load16 r2 384
print r2
load8 r3 388
print r3
load8 r4 389
print r4
load8 r5 391
print r5
# Cycle 3: the original 22 ABI observations remain ordered and unchanged.
load32 r6 480
print r6
load16 r7 484
print r7
load8 r8 488
print r8
load8 r9 489
print r9
# Open-world ABI v3: legacy 26 observations followed by environment.
load16 r10 520
print r10
load8 r11 522
print r11
load16 r12 524
print r12
load8 r13 526
print r13
load8 r14 523
print r14
load8 r15 527
print r15
load16 r0 544
print r0
load16 r1 546
print r1
load8 r2 548
print r2
# BEGIN C01 TELEMETRY
load8 r3 568
print r3
load16 r4 572
print r4
load8 r5 569
print r5
# END C01 TELEMETRY
halt
