#!reverse-pc-machine-v1
# REVERSE VELOCITY / X RENDER XI / first native-XI scanline backend
# All visible geometry, perspective positions and colors are computed HERE.
# The host is a dumb packed horizontal-span presenter; no native ray engine.
# Input mailbox 200=vertical sample step 1/2/4, 201=camera 0/1/2,
# 202=paint 0..4. Input RVPC2 contains vehicle state and 241 XI road samples.
# Each print is one packed 56-bit span: y:10 | x0:11 | x1:11 | RGB:24.
# 1280x720 canvas; samples at quality stride can be expanded vertically.
# Bounds are checked in the presenter, never inferred from untrusted output.
# Reject incomplete/foreign states before painting the first span.
load8 r11 1000
cmp r11 88
jne missing_world
load8 r11 1001
cmp r11 73
jne missing_world
load8 r5 200
cmp r5 1
je stride_ready
cmp r5 2
je stride_ready
cmp r5 4
je stride_ready
set r5 4
label stride_ready
load8 r14 202
cmp r14 1
je paint_blue
cmp r14 2
je paint_silver
cmp r14 3
je paint_green
cmp r14 4
je paint_gold
set r14 13513768
jmp paint_done
label paint_blue
set r14 1740738
jmp paint_done
label paint_silver
set r14 11519440
jmp paint_done
label paint_green
set r14 2074983
jmp paint_done
label paint_gold
set r14 14061865
label paint_done
# Read authoritative vehicle xCm/zCm; there is no new driving equation.
load8 r13 100
load8 r11 101
mul r11 256
add r13 r11
load8 r11 102
mul r11 65536
add r13 r11
load8 r11 103
mul r11 16777216
add r13 r11
sub r13 2000000
load8 r15 104
load8 r11 105
mul r11 256
add r15 r11
load8 r11 106
mul r11 65536
add r15 r11
load8 r11 107
mul r11 16777216
add r15 r11
sub r15 2000000
# Interrogate XI world samples from memory, not C++ route()/slope().
mov r11 r15
add r11 85000
div r11 1000
cmp r11 0
jge near_nonnegative
set r11 0
label near_nonnegative
cmp r11 240
jle near_clamped
set r11 240
label near_clamped
mov r9 r11
mul r9 2
add r9 512
load8 r10 $r9
add r9 1
load8 r4 $r9
mul r4 256
add r10 r4
sub r10 8192
sub r13 r10
div r13 4
# Read an XI sample 100 m ahead for the projected bend.
sub r11 10
cmp r11 0
jge far_nonnegative
set r11 0
label far_nonnegative
mul r11 2
add r11 512
load8 r9 $r11
add r11 1
load8 r4 $r11
mul r4 256
add r9 r4
sub r9 8192
sub r9 r10
div r9 12
mov r15 r9
set r0 0
label scanline
cmp r0 720
jge finished
set r1 0
set r2 1280
cmp r0 290
jge grass_color
# Atmospheric sky, all channels integer and bounded.
mov r3 r0
div r3 9
add r3 14
mul r3 65536
mov r11 r0
div r11 6
add r11 55
mul r11 256
add r3 r11
mov r11 r0
div r11 8
add r11 106
add r3 r11
jmp background_ready
label grass_color
mov r6 r0
sub r6 290
mov r3 r6
div r3 16
add r3 47
mul r3 65536
mov r11 r6
div r11 12
add r11 72
mul r11 256
add r3 r11
mov r11 r6
div r11 18
add r11 53
add r3 r11
label background_ready
set r12 0
jmp emit_span
label after_background
# Sun disk approximation is drawn as native XI spans; no fragment shader.
cmp r0 72
jlt mountain_check
cmp r0 165
jge mountain_check
mov r11 r0
sub r11 118
cmp r11 0
jge sun_distance
mul r11 -1
label sun_distance
mov r1 r11
add r1 969
set r2 1085
sub r2 r11
set r3 16439952
set r12 1
jmp emit_span
label after_sun
label mountain_check
cmp r0 225
jlt road_check
cmp r0 290
jge road_check
set r1 0
mov r2 r0
sub r2 225
mul r2 4
add r2 230
set r3 4742249
set r12 2
jmp emit_span
label after_mountain_left
mov r1 r0
sub r1 225
mul r1 6
set r2 1080
sub r2 r1
mov r1 r2
set r2 1280
set r3 3953246
set r12 3
jmp emit_span
label after_mountain_right
label road_check
cmp r0 290
jlt row_complete
# Project a vanishing-point road. Road bend and player offset are sourced
# from the two stored XI world samples and XI vehicle state.
mov r6 r0
sub r6 290
mov r7 r6
mul r7 11
div r7 10
add r7 22
mov r8 720
sub r8 r0
mul r8 r15
div r8 430
sub r8 r13
add r8 640
mov r9 r8
sub r9 r7
mov r10 r8
add r10 r7
cmp r9 0
jge road_left_clamped
set r9 0
label road_left_clamped
cmp r10 1280
jle road_right_clamped
set r10 1280
label road_right_clamped
mov r1 r9
mov r2 r10
mov r3 r6
div r3 28
add r3 39
mul r3 65536
mov r11 r6
div r11 25
add r11 44
mul r11 256
add r3 r11
mov r11 r6
div r11 24
add r11 51
add r3 r11
set r12 4
jmp emit_span
label after_asphalt
mov r1 r9
mov r2 r9
add r2 5
set r3 14867911
set r12 5
jmp emit_span
label after_left_edge
mov r1 r10
sub r1 5
mov r2 r10
set r3 14867911
set r12 6
jmp emit_span
label after_right_edge
# Scrolling lane markings come from the authoritative XI tick counter.
load8 r11 115
add r11 r0
mod r11 37
cmp r11 23
jge car_check
cmp r8 r9
jlt car_check
cmp r8 r10
jge car_check
mov r1 r8
sub r1 2
mov r2 r8
add r2 2
set r3 15453024
set r12 7
jmp emit_span
label after_centerline
label car_check
load8 r11 201
cmp r11 2
je row_complete
cmp r0 540
jlt row_complete
cmp r0 690
jge row_complete
cmp r0 635
jlt car_body_check
set r1 470
set r2 810
set r3 1580837
set r12 8
jmp emit_span
label after_shadow
label car_body_check
cmp r0 666
jge row_complete
mov r7 r0
sub r7 540
div r7 2
add r7 85
set r1 640
sub r1 r7
set r2 640
add r2 r7
mov r3 r14
set r12 9
jmp emit_span
label after_car_body
cmp r0 546
jlt row_complete
cmp r0 574
jge glass_check
set r1 548
set r2 732
set r3 1317150
set r12 10
jmp emit_span
label after_roof
label glass_check
cmp r0 575
jlt light_check
cmp r0 628
jge light_check
set r1 540
set r2 740
set r3 2510434
set r12 11
jmp emit_span
label after_glass
label light_check
cmp r0 640
jlt row_complete
cmp r0 656
jge row_complete
set r1 488
set r2 527
set r3 15212572
set r12 12
jmp emit_span
label after_light_left
set r1 753
set r2 792
set r3 15212572
set r12 13
jmp emit_span
label after_light_right
label row_complete
add r0 r5
jmp scanline
# Single XI packing authority: y(10 bits), x0(11), x1(11), RGB(24).
# Result uses one signed-64 register per horizontal span; <= 2^56.
label emit_span
cmp r1 0
jge clip_start
set r1 0
label clip_start
cmp r2 1280
jle clip_end
set r2 1280
label clip_end
cmp r1 r2
jge return_span
mov r4 r0
mul r4 70368744177664
mov r11 r1
mul r11 34359738368
add r4 r11
mov r11 r2
mul r11 16777216
add r4 r11
add r4 r3
print r4
label return_span
cmp r12 0
je after_background
cmp r12 1
je after_sun
cmp r12 2
je after_mountain_left
cmp r12 3
je after_mountain_right
cmp r12 4
je after_asphalt
cmp r12 5
je after_left_edge
cmp r12 6
je after_right_edge
cmp r12 7
je after_centerline
cmp r12 8
je after_shadow
cmp r12 9
je after_car_body
cmp r12 10
je after_roof
cmp r12 11
je after_glass
cmp r12 12
je after_light_left
cmp r12 13
je after_light_right
halt
label finished
halt
label missing_world
halt
