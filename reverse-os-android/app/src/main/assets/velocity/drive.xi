#!reverse-pc-machine-v1
# REVERSE VELOCITY world-space bicycle/tire physics; XI owns every race state.
# cm, cm/s, 50Hz. yaw4096:0=+z,1024=+x. Inputs 128..135; 134=nitro, 135=pneumatic jump. Persistent energy/altitude at 380..391.
# World4096+:81(x,z) vertices; tangent5000+. Rivals6000+32*i.
# XI Cycle 3 Ether 480..489: score, combo, grace, rebufo and current surface.
# No screen projection participates in driving, collision or race progress.
load8 r0 1002
cmp r0 2
jne missing_world
load8 r0 132
cmp r0 1
je initialize
load8 r0 121
cmp r0 1
jne initialize
load8 r0 119
cmp r0 1
je publish
load8 r0 258
cmp r0 0
jne countdown
load8 r1 128
cmp r1 1
jne publish
store8 258 1
label countdown
load8 r0 258
cmp r0 1
jne rivals
load16 r0 259
sub r0 1
cmp r0 0
jgt countdown_store
set r0 0
store8 258 2
label countdown_store
store16 259 r0
jmp rivals
label initialize
store8 133 0
set r0 0
mov r14 r0
add r14 2000000
store32 100 r14
set r0 0
mov r14 r0
add r14 2000000
store32 104 r14
set r0 0
store16 108 r0
set r0 0
store16 110 r0
set r0 0
mov r14 r0
add r14 32768
store16 112 r14
set r0 0
store8 114 r0
set r0 0
store32 115 r0
set r0 0
store8 119 r0
set r0 0
store8 120 r0
set r0 0
mov r14 r0
add r14 1000
store16 122 r14
set r0 0
mov r14 r0
add r14 1000
store16 256 r14
set r0 150
store16 259 r0
set r0 0
mov r14 r0
add r14 32768
store16 261 r14
set r0 0
mov r14 r0
add r14 32768
store16 263 r14
set r0 0
mov r14 r0
add r14 300000
store32 265 r14
set r0 0
store8 273 r0
set r0 0
store32 274 r0
set r0 0
store32 278 r0
set r0 4
store8 282 r0
set r0 0
store8 283 r0
set r0 0
mov r14 r0
add r14 1000
store16 312 r14
set r0 0
mov r14 r0
add r14 1000
store16 314 r14
# Nitro/air suspension lives in durable XI state; not in the Android view.
store16 380 1000
store8 382 0
store16 384 0
store16 386 10000
store8 388 0
store8 389 0
store8 390 0
store8 391 0
# XI effect history is durable Ether state (not host-generated graphics).
store8 393 0
store8 394 0
store8 395 0
store8 396 0
# Driving skills state; HUD reads snapshots only.
store32 480 0
store16 484 100
store8 486 0
store8 487 0
store8 488 0
store8 489 0
store8 410 0
store8 422 0
store8 434 0
store8 446 0
store8 121 1
store8 258 0
set r0 450
store32 6000 r0
set r0 -240
mov r14 r0
add r14 65536
store32 6004 r14
set r0 450
mov r14 r0
add r14 65536
store32 6008 r14
set r0 0
store16 6012 r0
set r0 0
store16 6014 r0
set r0 450
store32 6016 r0
set r0 0
store8 6020 r0
set r0 -240
mov r14 r0
add r14 1000
store16 6021 r14
set r0 0
store8 6023 r0
set r0 0
store32 6024 r0
set r0 900
store32 6032 r0
set r0 0
mov r14 r0
add r14 65536
store32 6036 r14
set r0 900
mov r14 r0
add r14 65536
store32 6040 r14
set r0 0
store16 6044 r0
set r0 0
store16 6046 r0
set r0 900
store32 6048 r0
set r0 0
store8 6052 r0
set r0 0
mov r14 r0
add r14 1000
store16 6053 r14
set r0 0
store8 6055 r0
set r0 0
store32 6056 r0
set r0 1350
store32 6064 r0
set r0 240
mov r14 r0
add r14 65536
store32 6068 r14
set r0 1350
mov r14 r0
add r14 65536
store32 6072 r14
set r0 0
store16 6076 r0
set r0 0
store16 6078 r0
set r0 1350
store32 6080 r0
set r0 0
store8 6084 r0
set r0 240
mov r14 r0
add r14 1000
store16 6085 r14
set r0 0
store8 6087 r0
set r0 0
store32 6088 r0
label rivals
store8 328 0
label rival_loop
load8 r12 328
mul r12 32
add r12 6000
load32 r0 $r12
add r12 4
store32 350 r0
load8 r12 328
mul r12 32
add r12 6020
load8 r1 $r12
add r12 1
store8 354 r1
load8 r12 328
mul r12 32
add r12 6014
load16 r2 $r12
add r12 2
load8 r3 258
cmp r3 2
jne rival_place
cmp r1 3
jge rival_finished_motion
mov r3 r0
div r3 2000
cmp r3 20
jlt rival_fast
cmp r3 40
jlt rival_curve
cmp r3 60
jlt rival_fast
label rival_curve
set r4 2800
jmp rival_target
label rival_fast
set r4 4400
label rival_target
load8 r5 328
mul r5 130
add r4 r5
cmp r2 r4
jge rival_slow
add r2 18
cmp r2 r4
jle rival_speed_ready
mov r2 r4
jmp rival_speed_ready
label rival_slow
sub r2 35
cmp r2 r4
jge rival_speed_ready
mov r2 r4
label rival_speed_ready
mov r3 r2
mul r3 20
div r3 1000
add r0 r3
cmp r0 160000
jlt rival_place
sub r0 160000
add r1 1
cmp r1 3
jlt rival_place
set r1 3
set r0 0
label rival_finished_motion
load8 r3 328
mul r3 500
add r3 2500
set r2 1000
cmp r0 r3
jge rival_parked
add r0 20
cmp r0 r3
jle rival_place
mov r0 r3
label rival_parked
set r2 0
label rival_place
store32 350 r0
store8 354 r1
store16 355 r2
cmp r1 3
jlt rival_not_finished
load8 r12 328
mul r12 32
add r12 6023
load8 r3 $r12
add r12 1
cmp r3 1
je rival_finish_recorded
load32 r3 115
add r3 1
load8 r12 328
mul r12 32
add r12 6024
store32 $r12 r3
add r12 4
set r3 1
load8 r12 328
mul r12 32
add r12 6023
store8 $r12 r3
add r12 1
label rival_finish_recorded
load8 r3 328
mod r3 2
cmp r3 0
je rival_park_left
set r3 780
jmp rival_park_lane
label rival_park_left
set r3 -780
label rival_park_lane
load8 r12 328
mul r12 32
add r12 6021
load16 r4 $r12
add r12 2
sub r4 1000
cmp r4 r3
jge rival_lane_left
add r4 6
cmp r4 r3
jle rival_lane_ready
mov r4 r3
jmp rival_lane_ready
label rival_lane_left
sub r4 6
cmp r4 r3
jge rival_lane_ready
mov r4 r3
label rival_lane_ready
load8 r12 328
mul r12 32
add r12 6021
mov r14 r4
add r14 1000
store16 $r12 r14
add r12 2
label rival_not_finished
load8 r12 328
mul r12 32
add r12 6000
store32 $r12 r0
add r12 4
load8 r12 328
mul r12 32
add r12 6020
store8 $r12 r1
add r12 1
load8 r12 328
mul r12 32
add r12 6014
store16 $r12 r2
add r12 2
mov r3 r1
mul r3 160000
add r3 r0
cmp r3 480000
jle rival_total_ready
set r3 480000
label rival_total_ready
load8 r12 328
mul r12 32
add r12 6016
store32 $r12 r3
add r12 4
mov r4 r0
div r4 2000
mov r5 r0
mod r5 2000
mov r12 r4
mul r12 8
add r12 4096
load32 r6 $r12
add r12 4
sub r6 65536
load32 r7 $r12
add r12 4
sub r7 65536
load32 r8 $r12
add r12 4
sub r8 65536
load32 r9 $r12
add r12 4
sub r9 65536
sub r8 r6
mul r8 r5
div r8 2000
add r6 r8
sub r9 r7
mul r9 r5
div r9 2000
add r7 r9
mov r14 r6
add r14 2000000
store32 358 r14
mov r14 r7
add r14 2000000
store32 362 r14
mov r12 r4
mul r12 2
add r12 5000
load16 r0 $r12
add r12 2
store16 366 r0
load8 r12 328
mul r12 32
add r12 6012
store16 $r12 r0
add r12 2
mod r0 4096
cmp r0 0
jge rival_sin_pos
add r0 4096
label rival_sin_pos
set r4 1
cmp r0 2048
jle rival_sin_fold
sub r0 2048
set r4 -1
label rival_sin_fold
set r2 2048
sub r2 r0
mul r2 r0
mov r3 r2
mul r3 4
set r1 20971520
sub r1 r3
mul r2 262144
div r2 r1
mul r2 r4
mov r1 r2
mov r14 r1
add r14 32768
store16 368 r14
load16 r0 366
add r0 1024
mod r0 4096
cmp r0 0
jge rival_cos_pos
add r0 4096
label rival_cos_pos
set r4 1
cmp r0 2048
jle rival_cos_fold
sub r0 2048
set r4 -1
label rival_cos_fold
set r2 2048
sub r2 r0
mul r2 r0
mov r3 r2
mul r3 4
set r1 20971520
sub r1 r3
mul r2 262144
div r2 r1
mul r2 r4
mov r1 r2
mov r14 r1
add r14 32768
store16 370 r14
load8 r12 328
mul r12 32
add r12 6021
load16 r2 $r12
add r12 2
sub r2 1000
load16 r3 368
sub r3 32768
load16 r4 370
sub r4 32768
load32 r6 358
sub r6 2000000
load32 r7 362
sub r7 2000000
mul r4 r2
div r4 16384
add r6 r4
mul r3 r2
div r3 16384
sub r7 r3
load8 r12 328
mul r12 32
add r12 6004
mov r14 r6
add r14 65536
store32 $r12 r14
add r12 4
load8 r12 328
mul r12 32
add r12 6008
mov r14 r7
add r14 65536
store32 $r12 r14
add r12 4
load8 r0 328
add r0 1
store8 328 r0
cmp r0 3
jlt rival_loop
load8 r0 258
cmp r0 2
jne rank
store8 283 0
# Nitro reservoir: 4 seconds of boost, 10 seconds of normal recharge.
load16 r0 380
load8 r1 134
cmp r1 1
jne nitro_recover
load8 r1 128
cmp r1 1
jne nitro_recover
load8 r1 129
cmp r1 1
je nitro_recover
load8 r1 133
cmp r1 1
je nitro_recover
cmp r0 5
jlt nitro_recover
sub r0 5
store8 382 1
jmp nitro_store
label nitro_recover
store8 382 0
add r0 2
cmp r0 1000
jle nitro_store
set r0 1000
label nitro_store
store16 380 r0
# Debounced single-jump impulse, four compressors and 50Hz ballistic gravity.
load8 r0 389
cmp r0 0
jle jump_cooldown_done
sub r0 1
store8 389 r0
label jump_cooldown_done
load8 r0 388
cmp r0 0
jle air_pulse_done
sub r0 1
store8 388 r0
label air_pulse_done
store8 391 0
load8 r0 135
cmp r0 0
jne jump_button_down
store8 390 0
jmp jump_integrator
label jump_button_down
load8 r0 390
cmp r0 0
jne jump_integrator
store8 390 1
load16 r0 384
cmp r0 0
jne jump_integrator
load8 r0 389
cmp r0 0
jne jump_integrator
store16 386 10700
store8 389 90
store8 388 22
label jump_integrator
load16 r0 386
sub r0 10000
load16 r1 384
cmp r0 0
jne jump_in_flight
cmp r1 0
je jump_complete
label jump_in_flight
sub r0 30
mov r2 r0
div r2 50
add r1 r2
cmp r1 0
jgt jump_still_flying
set r1 0
set r0 0
store8 388 10
store8 391 1
label jump_still_flying
store16 384 r1
add r0 10000
store16 386 r0
label jump_complete
load16 r0 256
sub r0 1000
load8 r1 130
sub r1 1
mul r1 1000
cmp r0 r1
jge steer_down
add r0 100
cmp r0 r1
jle steer_ready
mov r0 r1
jmp steer_ready
label steer_down
sub r0 100
cmp r0 r1
jge steer_ready
mov r0 r1
label steer_ready
mov r14 r0
add r14 1000
store16 256 r14
load16 r1 110
mul r0 r1
# Reduced steering response while airborne.
load16 r6 384
cmp r6 0
je ground_steering
mul r0 35
div r0 100
label ground_steering
load8 r6 133
cmp r6 1
jne reverse_steering_ready
mul r0 -1
label reverse_steering_ready
load32 r3 265
sub r3 300000
add r0 r3
mov r3 r0
mod r3 300000
mov r14 r3
add r14 300000
store32 265 r14
div r0 300000
load16 r2 108
add r2 r0
mod r2 4096
cmp r2 0
jge yaw_ready
add r2 4096
label yaw_ready
store16 108 r2
mov r0 r2
mod r0 4096
cmp r0 0
jge player_sin_pos
add r0 4096
label player_sin_pos
set r4 1
cmp r0 2048
jle player_sin_fold
sub r0 2048
set r4 -1
label player_sin_fold
set r2 2048
sub r2 r0
mul r2 r0
mov r3 r2
mul r3 4
set r1 20971520
sub r1 r3
mul r2 262144
div r2 r1
mul r2 r4
mov r1 r2
mov r14 r1
add r14 32768
store16 304 r14
load16 r0 108
add r0 1024
mod r0 4096
cmp r0 0
jge player_cos_pos
add r0 4096
label player_cos_pos
set r4 1
cmp r0 2048
jle player_cos_fold
sub r0 2048
set r4 -1
label player_cos_fold
set r2 2048
sub r2 r0
mul r2 r0
mov r3 r2
mul r3 4
set r1 20971520
sub r1 r3
mul r2 262144
div r2 r1
mul r2 r4
mov r1 r2
mov r14 r1
add r14 32768
store16 306 r14
load16 r0 261
sub r0 32768
load16 r1 263
sub r1 32768
load16 r2 304
sub r2 32768
load16 r3 306
sub r3 32768
mov r4 r0
mul r4 r2
mov r6 r1
mul r6 r3
add r4 r6
div r4 16384
mov r5 r0
mul r5 r3
mov r6 r1
mul r6 r2
sub r5 r6
div r5 16384
load8 r6 133
cmp r6 1
jne reverse_forward_ready
mul r4 -1
label reverse_forward_ready
cmp r4 0
jge forward_nonnegative
set r4 0
label forward_nonnegative
load8 r0 128
mul r0 1100
load8 r6 382
cmp r6 1
jne turbo_acceleration_done
add r0 2500
label turbo_acceleration_done
load8 r1 129
mul r1 2400
sub r0 r1
set r1 60
mov r6 r4
mul r6 r4
div r6 180000
add r1 r6
# Contact material is projected from the nearest XI circuit boundary.
# 0=tarmac, 1=grass, 2=curb. The stored surface is last tick's footprint.
load8 r6 489
cmp r6 1
jne curb_drag
add r1 900
jmp paved_drag
label curb_drag
cmp r6 2
jne paved_drag
add r1 280
label paved_drag
load8 r6 131
cmp r6 1
jne no_drift_drag
add r1 250
label no_drift_drag
sub r0 r1
mul r0 20
load16 r6 122
sub r6 1000
add r0 r6
mov r6 r0
mod r6 1000
mov r14 r6
add r14 1000
store16 122 r14
div r0 1000
add r4 r0
cmp r4 0
jge speed_min
set r4 0
label speed_min
cmp r4 6500
jle speed_max
set r4 6500
label speed_max
load8 r6 133
cmp r6 1
jne reverse_speed_limit_ready
cmp r4 800
jle reverse_speed_limit_ready
set r4 800
label reverse_speed_limit_ready
set r6 24
load8 r0 489
cmp r0 1
jne curb_grip
set r6 10
jmp paved_grip
label curb_grip
cmp r0 2
jne paved_grip
set r6 17
label paved_grip
load8 r0 131
cmp r0 1
jne no_drift_grip
set r6 7
label no_drift_grip
mov r7 r5
mul r7 -1
cmp r7 r6
jle grip_upper
mov r7 r6
label grip_upper
mov r0 r6
mul r0 -1
cmp r7 r0
jge grip_lower
mov r7 r0
label grip_lower
add r5 r7
load8 r6 133
cmp r6 1
jne reverse_wheel_velocity_ready
mul r4 -1
label reverse_wheel_velocity_ready
mov r0 r4
mul r0 r2
mov r1 r5
mul r1 r3
add r0 r1
div r0 16384
mov r1 r4
mul r1 r3
mov r6 r5
mul r6 r2
sub r1 r6
div r1 16384
mov r14 r0
add r14 32768
store16 261 r14
mov r14 r1
add r14 32768
store16 263 r14
load8 r6 133
cmp r6 1
jne reverse_magnitude_ready
mul r4 -1
label reverse_magnitude_ready
store16 110 r4
mov r14 r5
add r14 32768
store16 112 r14
load16 r0 261
sub r0 32768
mul r0 20
load16 r1 312
sub r1 1000
add r0 r1
mov r1 r0
mod r1 1000
mov r14 r1
add r14 1000
store16 312 r14
div r0 1000
load32 r1 100
sub r1 2000000
add r1 r0
mov r14 r1
add r14 2000000
store32 100 r14
load16 r0 263
sub r0 32768
mul r0 20
load16 r1 314
sub r1 1000
add r0 r1
mov r1 r0
mod r1 1000
mov r14 r1
add r14 1000
store16 314 r14
div r0 1000
load32 r1 104
sub r1 2000000
add r1 r0
mov r14 r1
add r14 2000000
store32 104 r14
# Collisions with ground-based opponents only while grounded.
load16 r0 384
cmp r0 0
jgt skip_ground_contacts
store8 328 0
label contact_loop
load8 r12 328
mul r12 32
add r12 6023
load8 r0 $r12
add r12 1
cmp r0 1
je contact_next
load32 r0 100
sub r0 2000000
load32 r1 104
sub r1 2000000
load8 r12 328
mul r12 32
add r12 6004
load32 r2 $r12
add r12 4
sub r2 65536
load8 r12 328
mul r12 32
add r12 6008
load32 r3 $r12
add r12 4
sub r3 65536
sub r0 r2
sub r1 r3
mov r4 r0
mul r4 r0
mov r5 r1
mul r5 r1
add r4 r5
cmp r4 44100
jge contact_next
cmp r4 1
jge contact_not_zero
set r0 1
set r4 1
label contact_not_zero
mov r5 r0
cmp r5 0
jge contact_absx
mul r5 -1
label contact_absx
mov r6 r1
cmp r6 0
jge contact_absz
mul r6 -1
label contact_absz
add r5 r6
set r7 5
label contact_sqrt
mov r6 r4
div r6 r5
add r5 r6
div r5 2
sub r7 1
cmp r7 0
jgt contact_sqrt
mul r0 210
div r0 r5
add r0 r2
mul r1 210
div r1 r5
add r1 r3
mov r14 r0
add r14 2000000
store32 100 r14
mov r14 r1
add r14 2000000
store32 104 r14
load16 r0 261
sub r0 32768
mul r0 3
div r0 4
mov r14 r0
add r14 32768
store16 261 r14
load16 r0 263
sub r0 32768
mul r0 3
div r0 4
mov r14 r0
add r14 32768
store16 263 r14
label contact_next
load8 r0 328
add r0 1
store8 328 r0
cmp r0 3
jlt contact_loop
label skip_ground_contacts
load32 r0 274
store32 300 r0
set r0 4294967295
store32 342 r0
store8 328 0
label nearest_loop
load32 r0 100
sub r0 2000000
load32 r1 104
sub r1 2000000
load8 r2 273
load8 r13 328
sub r13 4
add r2 r13
mod r2 80
cmp r2 0
jge nearest_index
add r2 80
label nearest_index
mov r12 r2
mul r12 8
add r12 4096
load32 r3 $r12
add r12 4
sub r3 65536
load32 r4 $r12
add r12 4
sub r4 65536
load32 r5 $r12
add r12 4
sub r5 65536
load32 r6 $r12
add r12 4
sub r6 65536
sub r5 r3
sub r6 r4
mov r7 r5
mul r7 r5
mov r8 r6
mul r8 r6
add r7 r8
sub r0 r3
sub r1 r4
mul r0 r5
mul r1 r6
add r0 r1
mul r0 1000000
div r0 r7
cmp r0 0
jge nearest_tmin
set r0 0
label nearest_tmin
cmp r0 1000000
jle nearest_tmax
set r0 1000000
label nearest_tmax
mov r8 r0
mov r9 r5
mul r9 r8
div r9 1000000
add r9 r3
mov r10 r6
mul r10 r8
div r10 1000000
add r10 r4
load32 r0 100
sub r0 2000000
load32 r1 104
sub r1 2000000
sub r0 r9
sub r1 r10
mul r0 r0
mul r1 r1
add r0 r1
load32 r1 342
cmp r0 r1
jge nearest_next
store32 342 r0
store8 329 r2
store32 330 r8
mov r14 r9
add r14 2000000
store32 334 r14
mov r14 r10
add r14 2000000
store32 338 r14
label nearest_next
load8 r0 328
add r0 1
store8 328 r0
cmp r0 9
jlt nearest_loop
load8 r0 329
store8 273 r0
mul r0 2000
load32 r1 330
mul r1 2000
div r1 1000000
add r0 r1
mod r0 160000
store32 274 r0
load32 r0 342
store8 120 0
store8 489 0
cmp r0 360000
jle inside_road
store8 120 1
store8 489 2
cmp r0 448900
jle inside_road
store8 489 1
label inside_road
cmp r0 819025
jle after_wall
load16 r3 384
cmp r3 0
jgt after_wall
store8 283 1
load32 r1 100
sub r1 2000000
load32 r2 104
sub r2 2000000
load32 r3 334
sub r3 2000000
load32 r4 338
sub r4 2000000
sub r1 r3
sub r2 r4
mov r5 r1
cmp r5 0
jge wall_absx
mul r5 -1
label wall_absx
mov r6 r2
cmp r6 0
jge wall_absz
mul r6 -1
label wall_absz
add r5 r6
set r7 5
label wall_sqrt
mov r6 r0
div r6 r5
add r5 r6
div r5 2
sub r7 1
cmp r7 0
jgt wall_sqrt
mov r6 r1
mul r6 905
div r6 r5
add r6 r3
mov r7 r2
mul r7 905
div r7 r5
add r7 r4
mov r14 r6
add r14 2000000
store32 100 r14
mov r14 r7
add r14 2000000
store32 104 r14
load16 r6 261
sub r6 32768
load16 r7 263
sub r7 32768
mov r8 r6
mul r8 r1
mov r9 r7
mul r9 r2
add r8 r9
div r8 r5
cmp r8 0
jle after_wall
mul r8 13
div r8 10
mul r1 r8
div r1 r5
sub r6 r1
mul r2 r8
div r2 r5
sub r7 r2
mov r14 r6
add r14 32768
store16 261 r14
mov r14 r7
add r14 32768
store16 263 r14
label after_wall
load16 r0 261
sub r0 32768
load16 r1 263
sub r1 32768
load16 r2 304
sub r2 32768
load16 r3 306
sub r3 32768
mov r4 r0
mul r4 r2
mov r5 r1
mul r5 r3
add r4 r5
div r4 16384
load8 r6 133
cmp r6 1
jne reverse_final_speed_ready
mul r4 -1
label reverse_final_speed_ready
cmp r4 0
jge final_forward
set r4 0
label final_forward
cmp r4 6500
jle final_forward_max
set r4 6500
label final_forward_max
mov r5 r0
mul r5 r3
mov r6 r1
mul r6 r2
sub r5 r6
div r5 16384
cmp r5 -6500
jge final_slide_min
set r5 -6500
label final_slide_min
cmp r5 6500
jle final_slide_max
set r5 6500
label final_slide_max
store16 110 r4
mov r14 r5
add r14 32768
store16 112 r14
load32 r0 115
add r0 1
store32 115 r0
load32 r0 274
load32 r1 300
mov r2 r0
sub r2 r1
cmp r2 -80000
jge gate_delta_low
add r2 160000
label gate_delta_low
cmp r2 80000
jle gate_delta_ready
sub r2 160000
label gate_delta_ready
cmp r2 0
jle progress_done
cmp r2 1500
jgt progress_done
load8 r3 120
cmp r3 1
je progress_done
load8 r3 114
cmp r3 12
jge progress_done
mov r4 r3
add r4 1
mod r4 4
mul r4 40000
cmp r4 0
je finish_sector
cmp r1 r4
jge progress_done
cmp r0 r4
jlt progress_done
jmp sector_awarded
label finish_sector
cmp r1 158500
jlt progress_done
cmp r0 1500
jgt progress_done
label sector_awarded
add r3 1
store8 114 r3
cmp r3 12
jlt progress_done
store8 119 1
store8 258 3
label progress_done
load8 r3 119
cmp r3 1
je race_distance_finished
load32 r1 278
cmp r2 -1500
jlt distance_ready
cmp r2 1500
jgt distance_ready
add r1 r2
cmp r1 0
jge distance_nonnegative
set r1 0
label distance_nonnegative
cmp r1 480000
jle distance_ready
set r1 480000
jmp distance_ready
label race_distance_finished
set r1 480000
label distance_ready
store32 278 r1
# Cycle 2: physical event history for visible tire marks, wheel smoke
# and spring settling. Four world-space skid samples, each X/Z/Yaw/TTL.
# Slots 400..447 are unused by world, opponents and gameplay ABI.
label effect_history
load8 r0 395
cmp r0 0
jle effect_smoke_faded
sub r0 1
store8 395 r0
label effect_smoke_faded
load8 r0 396
cmp r0 0
jle effect_suspension_rest
sub r0 1
store8 396 r0
label effect_suspension_rest
load8 r0 391
cmp r0 1
jne effect_after_landing
store8 396 18
label effect_after_landing
load8 r0 394
cmp r0 0
jle effect_cooldown_ready
sub r0 1
store8 394 r0
label effect_cooldown_ready
load8 r0 131
cmp r0 1
jne effect_drift_done
load16 r0 110
cmp r0 900
jlt effect_drift_done
load8 r0 120
cmp r0 0
jne effect_drift_done
load16 r0 384
cmp r0 0
jne effect_drift_done
load8 r0 133
cmp r0 0
jne effect_drift_done
store8 395 16
load8 r0 394
cmp r0 0
jne effect_drift_done
load8 r0 393
mov r12 r0
mul r12 12
add r12 400
load32 r1 100
store32 $r12 r1
add r12 4
load32 r1 104
store32 $r12 r1
add r12 4
load16 r1 108
store16 $r12 r1
add r12 2
store8 $r12 120
add r0 1
mod r0 4
store8 393 r0
store8 394 7
label effect_drift_done
set r7 0
label effect_expire_loop
mov r12 r7
mul r12 12
add r12 410
load8 r0 $r12
cmp r0 0
jle effect_expire_next
sub r0 1
store8 $r12 r0
label effect_expire_next
add r7 1
cmp r7 4
jlt effect_expire_loop
label rank
set r0 1
store8 282 r0
store8 328 0
label rank_loop
load32 r0 278
load8 r12 328
mul r12 32
add r12 6016
load32 r1 $r12
add r12 4
cmp r1 r0
jgt rank_behind
jlt rank_next
load8 r2 119
cmp r2 1
jne rank_next
load8 r12 328
mul r12 32
add r12 6023
load8 r2 $r12
add r12 1
cmp r2 1
jne rank_next
load8 r12 328
mul r12 32
add r12 6024
load32 r2 $r12
add r12 4
load32 r3 115
cmp r2 r3
jge rank_next
label rank_behind
load8 r0 282
add r0 1
store8 282 r0
label rank_next
load8 r0 328
add r0 1
store8 328 r0
cmp r0 3
jlt rank_loop
label publish
load32 r0 100
sub r0 2000000
print r0
load32 r1 104
sub r1 2000000
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
halt
label missing_world
set r0 0
div r0 0
halt
