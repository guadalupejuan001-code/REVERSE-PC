#!reverse-pc-machine-v1
# REVERSE VELOCITY world-space bicycle/tire physics; XI owns every race state.
# cm, cm/s, 50Hz. yaw4096:0=+z,1024=+x. Inputs 128..135; 134=nitro, 135=pneumatic jump. Persistent energy/altitude at 380..391.
# World4096+:81(x,z) vertices; tangent5000+. Rivals6000+32*i.
# XI Cycle 3 Ether 480..489: score, combo, grace, rebufo and current surface.
# Forest assistance: input 136 (0=manual,1=lane/brake,2=autopilot).
# Explicit player steering (input130) and braking (input129) always override.
# No screen projection participates in driving, collision or race progress.
load8 r0 1002
cmp r0 3
jne missing_world
# The pilot advances the start countdown without synthetic screen taps.
load8 r0 136
cmp r0 2
jne pilot_throttle_ready
load8 r1 133
cmp r1 1
je pilot_throttle_ready
load8 r1 129
cmp r1 1
je pilot_throttle_ready
store8 128 1
label pilot_throttle_ready
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
add r14 2000000000
store32 100 r14
set r0 0
mov r14 r0
add r14 2000000000
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
set r0 0
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
add r14 4000000
store32 265 r14
store32 564 300000
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
store16 520 0
store16 912 32768
store16 914 32768
store32 900 4294967295
store16 904 65535
store8 522 0
store8 523 0
store16 524 0
store8 526 0
store8 527 0
store32 528 0
store8 138 255
store16 544 0
store16 546 0
store8 548 0
# BEGIN V23 RIG INITIALIZE
# V2.3 secondary-motion state, centimetres in Q8.
store8 496 35
store16 498 0
store16 500 16384
store16 502 0
store16 504 32768
store16 506 32768
store16 508 32768
store16 510 32768
store16 512 32768
store16 514 32768
store16 516 32768
store16 518 32768
# END V23 RIG INITIALIZE
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
store8 258 2
jmp rank
label rivals
label open_after_rivals
load32 r0 100
store32 552 r0
load32 r0 104
store32 556 r0
load8 r0 258
cmp r0 2
jne rank
# Assisted controls are sensor-driven XI commands, never Java driving math.
# Steering tracks a point 40m ahead; the road tangents govern corner speed.
load8 r0 138
cmp r0 200
jle assisted_input_done
load8 r0 136
cmp r0 0
je assisted_input_done
load8 r0 133
cmp r0 1
je assisted_input_done
load32 r0 274
cmp r0 157800
jlt open_pilot_not_end
store8 128 0
store8 129 1
jmp assisted_input_done
label open_pilot_not_end
load8 r0 131
cmp r0 1
je assisted_input_done
load8 r0 130
cmp r0 1
jne assisted_corner_brake
load8 r0 273
add r0 2
cmp r0 79
jle open_lookahead_0
set r0 79
label open_lookahead_0
mov r12 r0
mul r12 8
add r12 4096
load32 r3 $r12
sub r3 65536
add r12 4
load32 r4 $r12
sub r4 65536
load32 r5 100
sub r5 2000000000
sub r3 r5
load32 r5 104
sub r5 2000000000
sub r4 r5
load16 r5 306
sub r5 32768
load16 r6 304
sub r6 32768
mul r3 r5
mul r4 r6
sub r3 r4
div r3 16384
cmp r3 35
jle assisted_check_left
store8 130 2
jmp assisted_corner_brake
label assisted_check_left
cmp r3 -35
jge assisted_corner_brake
store8 130 0
label assisted_corner_brake
load8 r0 129
cmp r0 1
je assisted_input_done
load8 r0 273
add r0 3
cmp r0 79
jle open_lookahead_1
set r0 79
label open_lookahead_1
mul r0 2
add r0 5000
mov r12 r0
load16 r3 $r12
load16 r4 108
sub r3 r4
cmp r3 2048
jle assisted_yaw_low
sub r3 4096
label assisted_yaw_low
cmp r3 -2048
jge assisted_yaw_ready
add r3 4096
label assisted_yaw_ready
cmp r3 0
jge assisted_yaw_abs
mul r3 -1
label assisted_yaw_abs
load16 r4 110
cmp r3 280
jlt assisted_medium_corner
cmp r4 2200
jle assisted_input_done
store8 129 1
store8 128 0
jmp assisted_input_done
label assisted_medium_corner
cmp r3 140
jlt assisted_wide_corner
cmp r4 3000
jle assisted_input_done
store8 129 1
store8 128 0
jmp assisted_input_done
label assisted_wide_corner
cmp r3 75
jlt assisted_input_done
cmp r4 3900
jle assisted_input_done
store8 129 1
store8 128 0
label assisted_input_done
load8 r0 136
cmp r0 2
jne open_pilot_speed_ready
load8 r0 133
cmp r0 1
je open_pilot_speed_ready
load16 r0 110
cmp r0 2600
jle open_pilot_speed_ready
store8 128 0
store8 129 1
label open_pilot_speed_ready
load8 r0 136
cmp r0 2
jne wetlands_pilot_ready
load8 r0 133
cmp r0 1
je wetlands_pilot_ready
load8 r0 523
set r1 1800
cmp r0 5
jne wetlands_pilot_limit
set r1 1000
label wetlands_pilot_limit
load16 r0 110
cmp r0 r1
jle wetlands_pilot_ready
store8 128 0
store8 129 1
label wetlands_pilot_ready
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
cmp r1 0
jle wetlands_air_ready
load8 r3 388
cmp r3 6
jge wetlands_air_ready
load8 r3 389
cmp r3 0
je wetlands_air_ready
store8 388 6
label wetlands_air_ready
store16 384 r1
add r0 10000
store16 386 r0
label jump_complete
load16 r0 256
sub r0 1000
load8 r1 138
cmp r1 200
jle analog_steering_target
load8 r1 130
sub r1 1
mul r1 1000
jmp steering_target_ready
label analog_steering_target
sub r1 100
mul r1 10
label steering_target_ready
cmp r0 r1
jge steer_down
add r0 160
cmp r0 r1
jle steer_ready
mov r0 r1
jmp steer_ready
label steer_down
sub r0 200
cmp r0 r1
jge steer_ready
mov r0 r1
label steer_ready
mov r14 r0
add r14 1000
store16 256 r14
load16 r1 110
mul r0 r1
set r7 300000
load8 r6 138
cmp r6 200
jle steering_manual_ratio
load8 r6 136
cmp r6 0
jne steering_ratio_ready
label steering_manual_ratio
mov r7 r1
mul r7 r1
div r7 40
add r7 50000
label steering_ratio_ready
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
sub r3 4000000
load32 r6 564
cmp r6 0
jle steering_remainder_ready
mul r3 r7
div r3 r6
label steering_remainder_ready
store32 564 r7
add r0 r3
mov r3 r0
mod r3 r7
mov r14 r3
add r14 4000000
store32 265 r14
div r0 r7
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
add r1 450
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
load8 r6 489
cmp r6 3
jne wetlands_ford_drag
add r1 350
jmp open_dry_drag
label wetlands_ford_drag
cmp r6 4
jne open_dry_drag
add r1 480
label open_dry_drag
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
load8 r6 489
cmp r6 4
jne wetlands_speed_ready
cmp r4 1400
jle wetlands_speed_ready
set r4 1400
label wetlands_speed_ready
set r6 38
load8 r0 489
cmp r0 1
jne curb_grip
set r6 22
jmp paved_grip
label curb_grip
cmp r0 2
jne paved_grip
set r6 25
label paved_grip
load8 r0 489
cmp r0 3
jne wetlands_ford_grip
set r6 28
jmp open_dry_grip
label wetlands_ford_grip
cmp r0 4
jne open_dry_grip
set r6 18
label open_dry_grip
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
sub r1 2000000000
add r1 r0
mov r14 r1
add r14 2000000000
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
sub r1 2000000000
add r1 r0
mov r14 r1
add r14 2000000000
store32 104 r14
label skip_ground_contacts
load32 r0 274
store32 300 r0
load8 r0 128
localset 3725 r0
localset 3730 9223372036854775807
localset 3731 9
localset 3732 0
load32 r0 342
cmp r0 25000000
jle nearest_search_ready
load32 r0 115
mod r0 10
cmp r0 0
jne nearest_search_ready
localset 3731 80
localset 3732 1
label nearest_search_ready
store8 328 0
label nearest_loop
load32 r0 100
sub r0 2000000000
load32 r1 104
sub r1 2000000000
load8 r2 328
localget r13 3732
cmp r13 1
je nearest_candidate_ready
load8 r2 273
load8 r13 328
sub r13 4
add r2 r13
label nearest_candidate_ready
cmp r2 79
jle open_nearest_upper
set r2 79
label open_nearest_upper
cmp r2 0
jge nearest_index
set r2 0
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
sub r0 2000000000
load32 r1 104
sub r1 2000000000
sub r0 r9
sub r1 r10
mul r0 r0
mul r1 r1
add r0 r1
localget r1 3730
cmp r0 r1
jge nearest_next
localset 3730 r0
store8 329 r2
store32 330 r8
mov r14 r9
add r14 2000000000
store32 334 r14
mov r14 r10
add r14 2000000000
store32 338 r14
label nearest_next
load8 r0 328
add r0 1
store8 328 r0
localget r1 3731
cmp r0 r1
jlt nearest_loop
localget r0 3730
cmp r0 4294967295
jle nearest_distance_fits
set r0 4294967295
label nearest_distance_fits
store32 342 r0
load8 r0 329
store8 273 r0
mul r0 2000
load32 r1 330
mul r1 2000
div r1 1000000
add r0 r1
cmp r0 159999
jle open_progress_clamped
set r0 159999
label open_progress_clamped
store32 274 r0
load32 r0 342
store8 120 0
store8 489 0
cmp r0 32400
jle inside_road
store8 120 1
store8 489 2
cmp r0 90000
jle inside_road
store8 489 1
label inside_road
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
store32 278 r0
store8 119 0
store8 114 0
# BEGIN OPEN GROUND
# Terrain support uses the same height field as the streamed ground mesh.
load8 r0 273
mov r1 r0
div r1 10
store8 522 r1
add r0 5500
load8 r1 $r0
store8 523 r1
load8 r0 273
mul r0 2
add r0 5300
load16 r1 $r0
add r0 2
load16 r2 $r0
sub r2 r1
load32 r3 330
mul r2 r3
div r2 1000000
add r1 r2
localset 3726 r1
load32 r1 100
load32 r2 334
sub r1 r2
load32 r2 104
load32 r3 338
sub r2 r3
load8 r0 273
mul r0 8
add r0 4096
load32 r3 $r0
add r0 4
load32 r4 $r0
add r0 4
load32 r5 $r0
add r0 4
load32 r6 $r0
sub r5 r3
sub r6 r4
mul r1 r6
mul r2 r5
sub r1 r2
div r1 2000
mov r2 r1
add r2 2000000000
store32 532 r2
load16 r0 520
localset 3728 r0
load32 r2 104
sub r2 2000000000
load32 r0 100
sub r0 2000000000
# Shared terrain query: r0/r2=world x/z, r1=height cm; r3..r7 scratch.
localset 3790 r0
set r0 0
set r1 0
cmp r2 0
jle support_height_done
set r3 0
set r4 80
label support_height_search
mov r5 r3
add r5 1
cmp r5 r4
jge support_height_found
mov r5 r3
add r5 r4
div r5 2
mov r6 r5
mul r6 8
add r6 4100
load32 r7 $r6
sub r7 65536
cmp r2 r7
jle support_height_lower
mov r3 r5
jmp support_height_search
label support_height_lower
mov r4 r5
jmp support_height_search
label support_height_found
mov r6 r3
mul r6 8
add r6 4100
load32 r5 $r6
add r6 8
load32 r7 $r6
sub r5 65536
sub r7 65536
cmp r2 r7
jgt support_height_done
sub r7 r5
mul r3 2
add r3 5800
load16 r1 $r3
add r3 2
load16 r6 $r3
sub r6 r1
mov r4 r2
sub r4 r5
mul r6 r4
div r6 r7
add r1 r6
sub r3 5802
div r3 2
mul r3 8
add r3 4096
load32 r5 $r3
add r3 8
load32 r6 $r3
sub r5 65536
sub r6 65536
sub r6 r5
mul r6 r4
div r6 r7
add r5 r6
mov r0 r5
label support_height_done
localget r3 3790
sub r3 r0
cmp r3 0
jge support_height_abs
mul r3 -1
label support_height_abs
cmp r3 6500
jle support_height_ridge_done
cmp r3 10000
jge support_height_upper
sub r3 6500
mul r3 700
div r3 3500
add r1 r3
jmp support_height_ridge_done
label support_height_upper
cmp r3 16000
jge support_height_plateau
sub r3 10000
mul r3 1100
div r3 6000
add r3 700
add r1 r3
jmp support_height_ridge_done
label support_height_plateau
add r1 1800
label support_height_ridge_done
localget r0 3790
# Ordinary road differs by only a 2cm anti-z-fighting offset. A raised bridge
# supports a car from above; it cannot pull a car up from the river below.
load32 r3 342
cmp r3 90000
jgt open_surface_ready
load8 r3 273
cmp r3 64
jlt open_road_support
cmp r3 66
jgt open_road_support
localget r3 3728
load16 r4 384
add r3 r4
add r3 30
localget r4 3726
cmp r3 r4
jlt open_surface_ready
mov r1 r4
jmp open_surface_ready
label open_road_support
localget r1 3726
label open_surface_ready
store16 520 r1
load32 r0 342
cmp r0 90000
jgt open_mud_ready
load8 r0 523
cmp r0 4
jne open_mud_ready
store8 489 3
label open_mud_ready
store32 900 4294967295
store16 904 65535
localset 3900 0
label trail_query
localget r3 3900
mul r3 24
add r3 12000
load32 r0 100
sub r0 2000000000
load32 r2 104
sub r2 2000000000
localset 3910 r0
localset 3911 r2
load32 r6 $r3
sub r6 2000000000
add r3 4
load32 r7 $r3
sub r7 2000000000
add r3 4
load32 r8 $r3
sub r8 2000000000
sub r8 r6
add r3 4
load32 r9 $r3
sub r9 2000000000
sub r9 r7
mov r10 r8
mul r10 r8
mov r11 r9
mul r11 r9
add r10 r11
sub r0 r6
sub r2 r7
mul r0 r8
mul r2 r9
add r0 r2
mul r0 1000000
div r0 r10
cmp r0 0
jge trail_distance_positive
set r0 0
label trail_distance_positive
cmp r0 1000000
jle trail_distance_bounded
set r0 1000000
label trail_distance_bounded
mov r5 r0
mul r8 r0
div r8 1000000
add r6 r8
mul r9 r0
div r9 1000000
add r7 r9
localget r4 3910
sub r4 r6
mul r4 r4
localget r2 3911
sub r2 r7
mul r2 r2
add r4 r2
load32 r0 900
cmp r4 r0
jge trail_query_next
store32 900 r4
localget r0 3900
store16 904 r0
label trail_query_next
localget r0 3900
add r0 1
localset 3900 r0
load16 r1 908
cmp r0 r1
jlt trail_query
load16 r3 904
cmp r3 65535
je trail_surface_done
load32 r0 900
mul r3 24
add r3 12016
load16 r1 $r3
div r1 2
mul r1 r1
cmp r0 r1
jgt trail_surface_done
store8 489 2
add r3 2
load8 r0 $r3
cmp r0 0
je trail_surface_done
store8 489 3
label trail_surface_done
# Wetlands: physically shallow water, retained wetness and wheel splash.
store16 544 0
load32 r0 532
sub r0 2000000000
cmp r0 -6000
jlt wetlands_wetness
cmp r0 6000
jgt wetlands_wetness
load8 r0 523
cmp r0 4
jne wetlands_check_ford
load32 r1 342
cmp r1 90000
jgt wetlands_check_puddle
store8 489 3
label wetlands_check_ford
cmp r0 2
je wetlands_lake
cmp r0 1
je wetlands_bridge_water
cmp r0 5
jne wetlands_check_puddle
store8 489 4
set r1 82
load16 r2 520
sub r1 r2
cmp r1 0
jge wetlands_depth_positive
set r1 0
label wetlands_depth_positive
cmp r1 40
jle wetlands_depth_bounded
set r1 40
label wetlands_depth_bounded
store16 544 r1
jmp wetlands_wetness
label wetlands_lake
load32 r1 532
sub r1 2000000000
cmp r1 900
jlt wetlands_wetness
cmp r1 5800
jgt wetlands_wetness
localget r1 3726
add r1 9
jmp wetlands_lake_depth
label wetlands_bridge_water
localget r1 3726
sub r1 171
label wetlands_lake_depth
load16 r2 520
sub r1 r2
cmp r1 0
jle wetlands_wetness
cmp r1 40
jle wetlands_lake_bounded
set r1 40
label wetlands_lake_bounded
store16 544 r1
store8 489 4
jmp wetlands_wetness
label wetlands_check_puddle
load32 r1 330
cmp r1 300000
jlt wetlands_wetness
cmp r1 700000
jgt wetlands_wetness
load32 r1 532
sub r1 2000000000
load8 r0 273
mod r0 2
mul r0 80
sub r0 40
sub r1 r0
cmp r1 -115
jlt wetlands_wetness
cmp r1 115
jgt wetlands_wetness
load8 r0 273
cmp r0 4
je wetlands_puddle
cmp r0 8
je wetlands_puddle
cmp r0 13
je wetlands_puddle
cmp r0 18
je wetlands_puddle
cmp r0 21
je wetlands_puddle
cmp r0 24
je wetlands_puddle
cmp r0 26
je wetlands_puddle
cmp r0 32
je wetlands_puddle
cmp r0 34
je wetlands_puddle
cmp r0 36
je wetlands_puddle
cmp r0 40
je wetlands_puddle
cmp r0 44
je wetlands_puddle
cmp r0 47
je wetlands_puddle
cmp r0 51
je wetlands_puddle
cmp r0 55
je wetlands_puddle
cmp r0 59
je wetlands_puddle
cmp r0 63
je wetlands_puddle
cmp r0 67
je wetlands_puddle
cmp r0 71
je wetlands_puddle
cmp r0 75
je wetlands_puddle
jmp wetlands_wetness
label wetlands_puddle
store16 544 4
store8 489 3
label wetlands_wetness
load16 r0 546
load16 r1 544
cmp r1 0
jgt wetlands_wet
load8 r1 489
cmp r1 3
je wetlands_muddy
sub r0 1
jmp wetlands_wetness_bound
label wetlands_muddy
add r0 8
jmp wetlands_wetness_bound
label wetlands_wet
add r0 45
label wetlands_wetness_bound
cmp r0 0
jge wetlands_wetness_min
set r0 0
label wetlands_wetness_min
cmp r0 1000
jle wetlands_wetness_max
set r0 1000
label wetlands_wetness_max
store16 546 r0
load16 r0 544
load16 r1 110
mul r0 r1
div r0 45
cmp r0 255
jle wetlands_splash_bounded
set r0 255
label wetlands_splash_bounded
store8 548 r0
cmp r0 10
jle wetlands_splash_ready
store8 395 16
label wetlands_splash_ready
load32 r1 532
sub r1 2000000000
# Only the actual elevated bridge rails collide. There are no road-corridor,
# lake-bank, ford-bank or end-of-world clamps.
load8 r0 273
cmp r0 65
jne open_water_ready
load32 r1 532
sub r1 2000000000
cmp r1 0
jge open_bridge_abs
mul r1 -1
label open_bridge_abs
cmp r1 110
jlt open_water_ready
cmp r1 340
jgt open_water_ready
load16 r2 520
load16 r3 384
add r2 r3
localget r3 3726
sub r3 30
cmp r2 r3
jlt open_bridge_piers
cmp r1 155
jlt open_water_ready
jmp open_bridge_impact
label open_bridge_piers
load32 r0 330
cmp r0 200000
jle open_bridge_impact
cmp r0 800000
jlt open_water_ready
label open_bridge_impact
load32 r0 552
store32 100 r0
load32 r0 556
store32 104 r0
store16 261 32768
store16 263 32768
store16 110 0
store16 112 32768
store8 283 1
label open_water_ready
load32 r0 100
sub r0 2000000000
load32 r2 104
sub r2 2000000000
add r0 -100
# Shared terrain query: r0/r2=world x/z, r1=height cm; r3..r7 scratch.
localset 3790 r0
set r0 0
set r1 0
cmp r2 0
jle wheel_plane_0_done
set r3 0
set r4 80
label wheel_plane_0_search
mov r5 r3
add r5 1
cmp r5 r4
jge wheel_plane_0_found
mov r5 r3
add r5 r4
div r5 2
mov r6 r5
mul r6 8
add r6 4100
load32 r7 $r6
sub r7 65536
cmp r2 r7
jle wheel_plane_0_lower
mov r3 r5
jmp wheel_plane_0_search
label wheel_plane_0_lower
mov r4 r5
jmp wheel_plane_0_search
label wheel_plane_0_found
mov r6 r3
mul r6 8
add r6 4100
load32 r5 $r6
add r6 8
load32 r7 $r6
sub r5 65536
sub r7 65536
cmp r2 r7
jgt wheel_plane_0_done
sub r7 r5
mul r3 2
add r3 5800
load16 r1 $r3
add r3 2
load16 r6 $r3
sub r6 r1
mov r4 r2
sub r4 r5
mul r6 r4
div r6 r7
add r1 r6
sub r3 5802
div r3 2
mul r3 8
add r3 4096
load32 r5 $r3
add r3 8
load32 r6 $r3
sub r5 65536
sub r6 65536
sub r6 r5
mul r6 r4
div r6 r7
add r5 r6
mov r0 r5
label wheel_plane_0_done
localget r3 3790
sub r3 r0
cmp r3 0
jge wheel_plane_0_abs
mul r3 -1
label wheel_plane_0_abs
cmp r3 6500
jle wheel_plane_0_ridge_done
cmp r3 10000
jge wheel_plane_0_upper
sub r3 6500
mul r3 700
div r3 3500
add r1 r3
jmp wheel_plane_0_ridge_done
label wheel_plane_0_upper
cmp r3 16000
jge wheel_plane_0_plateau
sub r3 10000
mul r3 1100
div r3 6000
add r3 700
add r1 r3
jmp wheel_plane_0_ridge_done
label wheel_plane_0_plateau
add r1 1800
label wheel_plane_0_ridge_done
localget r0 3790
localset 3791 r1
load32 r0 100
sub r0 2000000000
load32 r2 104
sub r2 2000000000
add r0 100
# Shared terrain query: r0/r2=world x/z, r1=height cm; r3..r7 scratch.
localset 3790 r0
set r0 0
set r1 0
cmp r2 0
jle wheel_plane_1_done
set r3 0
set r4 80
label wheel_plane_1_search
mov r5 r3
add r5 1
cmp r5 r4
jge wheel_plane_1_found
mov r5 r3
add r5 r4
div r5 2
mov r6 r5
mul r6 8
add r6 4100
load32 r7 $r6
sub r7 65536
cmp r2 r7
jle wheel_plane_1_lower
mov r3 r5
jmp wheel_plane_1_search
label wheel_plane_1_lower
mov r4 r5
jmp wheel_plane_1_search
label wheel_plane_1_found
mov r6 r3
mul r6 8
add r6 4100
load32 r5 $r6
add r6 8
load32 r7 $r6
sub r5 65536
sub r7 65536
cmp r2 r7
jgt wheel_plane_1_done
sub r7 r5
mul r3 2
add r3 5800
load16 r1 $r3
add r3 2
load16 r6 $r3
sub r6 r1
mov r4 r2
sub r4 r5
mul r6 r4
div r6 r7
add r1 r6
sub r3 5802
div r3 2
mul r3 8
add r3 4096
load32 r5 $r3
add r3 8
load32 r6 $r3
sub r5 65536
sub r6 65536
sub r6 r5
mul r6 r4
div r6 r7
add r5 r6
mov r0 r5
label wheel_plane_1_done
localget r3 3790
sub r3 r0
cmp r3 0
jge wheel_plane_1_abs
mul r3 -1
label wheel_plane_1_abs
cmp r3 6500
jle wheel_plane_1_ridge_done
cmp r3 10000
jge wheel_plane_1_upper
sub r3 6500
mul r3 700
div r3 3500
add r1 r3
jmp wheel_plane_1_ridge_done
label wheel_plane_1_upper
cmp r3 16000
jge wheel_plane_1_plateau
sub r3 10000
mul r3 1100
div r3 6000
add r3 700
add r1 r3
jmp wheel_plane_1_ridge_done
label wheel_plane_1_plateau
add r1 1800
label wheel_plane_1_ridge_done
localget r0 3790
localset 3792 r1
load32 r0 100
sub r0 2000000000
load32 r2 104
sub r2 2000000000
add r2 -200
# Shared terrain query: r0/r2=world x/z, r1=height cm; r3..r7 scratch.
localset 3790 r0
set r0 0
set r1 0
cmp r2 0
jle wheel_plane_2_done
set r3 0
set r4 80
label wheel_plane_2_search
mov r5 r3
add r5 1
cmp r5 r4
jge wheel_plane_2_found
mov r5 r3
add r5 r4
div r5 2
mov r6 r5
mul r6 8
add r6 4100
load32 r7 $r6
sub r7 65536
cmp r2 r7
jle wheel_plane_2_lower
mov r3 r5
jmp wheel_plane_2_search
label wheel_plane_2_lower
mov r4 r5
jmp wheel_plane_2_search
label wheel_plane_2_found
mov r6 r3
mul r6 8
add r6 4100
load32 r5 $r6
add r6 8
load32 r7 $r6
sub r5 65536
sub r7 65536
cmp r2 r7
jgt wheel_plane_2_done
sub r7 r5
mul r3 2
add r3 5800
load16 r1 $r3
add r3 2
load16 r6 $r3
sub r6 r1
mov r4 r2
sub r4 r5
mul r6 r4
div r6 r7
add r1 r6
sub r3 5802
div r3 2
mul r3 8
add r3 4096
load32 r5 $r3
add r3 8
load32 r6 $r3
sub r5 65536
sub r6 65536
sub r6 r5
mul r6 r4
div r6 r7
add r5 r6
mov r0 r5
label wheel_plane_2_done
localget r3 3790
sub r3 r0
cmp r3 0
jge wheel_plane_2_abs
mul r3 -1
label wheel_plane_2_abs
cmp r3 6500
jle wheel_plane_2_ridge_done
cmp r3 10000
jge wheel_plane_2_upper
sub r3 6500
mul r3 700
div r3 3500
add r1 r3
jmp wheel_plane_2_ridge_done
label wheel_plane_2_upper
cmp r3 16000
jge wheel_plane_2_plateau
sub r3 10000
mul r3 1100
div r3 6000
add r3 700
add r1 r3
jmp wheel_plane_2_ridge_done
label wheel_plane_2_plateau
add r1 1800
label wheel_plane_2_ridge_done
localget r0 3790
localset 3793 r1
load32 r0 100
sub r0 2000000000
load32 r2 104
sub r2 2000000000
add r2 200
# Shared terrain query: r0/r2=world x/z, r1=height cm; r3..r7 scratch.
localset 3790 r0
set r0 0
set r1 0
cmp r2 0
jle wheel_plane_3_done
set r3 0
set r4 80
label wheel_plane_3_search
mov r5 r3
add r5 1
cmp r5 r4
jge wheel_plane_3_found
mov r5 r3
add r5 r4
div r5 2
mov r6 r5
mul r6 8
add r6 4100
load32 r7 $r6
sub r7 65536
cmp r2 r7
jle wheel_plane_3_lower
mov r3 r5
jmp wheel_plane_3_search
label wheel_plane_3_lower
mov r4 r5
jmp wheel_plane_3_search
label wheel_plane_3_found
mov r6 r3
mul r6 8
add r6 4100
load32 r5 $r6
add r6 8
load32 r7 $r6
sub r5 65536
sub r7 65536
cmp r2 r7
jgt wheel_plane_3_done
sub r7 r5
mul r3 2
add r3 5800
load16 r1 $r3
add r3 2
load16 r6 $r3
sub r6 r1
mov r4 r2
sub r4 r5
mul r6 r4
div r6 r7
add r1 r6
sub r3 5802
div r3 2
mul r3 8
add r3 4096
load32 r5 $r3
add r3 8
load32 r6 $r3
sub r5 65536
sub r6 65536
sub r6 r5
mul r6 r4
div r6 r7
add r5 r6
mov r0 r5
label wheel_plane_3_done
localget r3 3790
sub r3 r0
cmp r3 0
jge wheel_plane_3_abs
mul r3 -1
label wheel_plane_3_abs
cmp r3 6500
jle wheel_plane_3_ridge_done
cmp r3 10000
jge wheel_plane_3_upper
sub r3 6500
mul r3 700
div r3 3500
add r1 r3
jmp wheel_plane_3_ridge_done
label wheel_plane_3_upper
cmp r3 16000
jge wheel_plane_3_plateau
sub r3 10000
mul r3 1100
div r3 6000
add r3 700
add r1 r3
jmp wheel_plane_3_ridge_done
label wheel_plane_3_plateau
add r1 1800
label wheel_plane_3_ridge_done
localget r0 3790
localset 3794 r1
localget r0 3792
localget r1 3791
sub r0 r1
mul r0 4096
div r0 200
add r0 32768
store16 912 r0
localget r0 3794
localget r1 3793
sub r0 r1
mul r0 4096
div r0 400
load32 r1 342
cmp r1 90000
jgt wheel_plane_ready
load8 r1 273
cmp r1 64
jlt wheel_plane_ready
cmp r1 66
jgt wheel_plane_ready
mul r1 2
add r1 5300
load16 r0 $r1
add r1 2
load16 r2 $r1
sub r2 r0
mul r2 4096
div r2 2000
mov r0 r2
label wheel_plane_ready
add r0 32768
store16 914 r0
# Preserve world-space altitude when the support plane changes in mid-air.
# Driving off a deck starts a fall instead of snapping into the river bed.
localget r0 3728
load16 r1 520
sub r0 r1
load16 r2 384
cmp r2 0
jgt open_air_support
cmp r0 6
jle open_floor_ready
store16 386 10000
label open_air_support
add r2 r0
cmp r2 0
jgt open_air_above_floor
set r2 0
store16 386 10000
store8 391 1
label open_air_above_floor
cmp r2 600
jle open_air_height_bounded
set r2 600
label open_air_height_bounded
store16 384 r2
label open_floor_ready
store8 527 0
load32 r0 274
cmp r0 158000
jlt open_end_ready
store8 527 1
label open_end_ready
# END OPEN GROUND
# BEGIN OPEN PROP COLLISION
load32 r3 100
sub r3 2000000000
cmp r3 0
jge forest_collision_x_floor
sub r3 2499
label forest_collision_x_floor
div r3 2500
load32 r4 104
sub r4 2000000000
cmp r4 0
jge forest_collision_z_floor
sub r4 2499
label forest_collision_z_floor
div r4 2500
localset 3800 r3
localset 3801 r4
localset 3802 0
label forest_contact_cell
localget r3 3800
localget r4 3801
localget r5 3802
mov r6 r5
mod r6 3
sub r6 1
add r3 r6
div r5 3
sub r5 1
add r4 r5
cmp r4 0
jlt trail_forest_clear
cmp r4 80
jge trail_forest_clear
mov r6 r3
add r6 16
cmp r6 0
jlt trail_forest_clear
cmp r6 32
jge trail_forest_clear
mov r7 r4
mul r7 32
add r7 r6
add r7 18000
load8 r7 $r7
cmp r7 1
je forest_contact_next
label trail_forest_clear
mov r5 r3
mul r5 73
mov r6 r4
mul r6 151
add r5 r6
mod r5 4000
add r5 4000
mod r5 4000
mul r5 10
mov r6 r4
mul r6 3
add r6 r3
mod r6 10
add r6 10
mod r6 10
add r5 r6
mov r6 r5
mul r6 73
mod r6 1500
mov r0 r3
mul r0 2500
add r0 500
add r0 r6
mov r6 r5
mul r6 47
mod r6 1500
mov r2 r4
mul r2 2500
add r2 500
add r2 r6
mov r6 r5
mod r6 10
cmp r6 9
je forest_contact_next
set r7 140
cmp r6 7
jlt forest_contact_radius
load16 r7 384
cmp r7 140
jgt forest_contact_next
set r7 360
label forest_contact_radius
localset 3803 r7
localset 3804 r0
localset 3805 r2
# Shared terrain query: r0/r2=world x/z, r1=height cm; r3..r7 scratch.
localset 3790 r0
set r0 0
set r1 0
cmp r2 0
jle forest_contact_support_done
set r3 0
set r4 80
label forest_contact_support_search
mov r5 r3
add r5 1
cmp r5 r4
jge forest_contact_support_found
mov r5 r3
add r5 r4
div r5 2
mov r6 r5
mul r6 8
add r6 4100
load32 r7 $r6
sub r7 65536
cmp r2 r7
jle forest_contact_support_lower
mov r3 r5
jmp forest_contact_support_search
label forest_contact_support_lower
mov r4 r5
jmp forest_contact_support_search
label forest_contact_support_found
mov r6 r3
mul r6 8
add r6 4100
load32 r5 $r6
add r6 8
load32 r7 $r6
sub r5 65536
sub r7 65536
cmp r2 r7
jgt forest_contact_support_done
sub r7 r5
mul r3 2
add r3 5800
load16 r1 $r3
add r3 2
load16 r6 $r3
sub r6 r1
mov r4 r2
sub r4 r5
mul r6 r4
div r6 r7
add r1 r6
sub r3 5802
div r3 2
mul r3 8
add r3 4096
load32 r5 $r3
add r3 8
load32 r6 $r3
sub r5 65536
sub r6 65536
sub r6 r5
mul r6 r4
div r6 r7
add r5 r6
mov r0 r5
label forest_contact_support_done
localget r3 3790
sub r3 r0
cmp r3 0
jge forest_contact_support_abs
mul r3 -1
label forest_contact_support_abs
cmp r3 6500
jle forest_contact_support_ridge_done
cmp r3 10000
jge forest_contact_support_upper
sub r3 6500
mul r3 700
div r3 3500
add r1 r3
jmp forest_contact_support_ridge_done
label forest_contact_support_upper
cmp r3 16000
jge forest_contact_support_plateau
sub r3 10000
mul r3 1100
div r3 6000
add r3 700
add r1 r3
jmp forest_contact_support_ridge_done
label forest_contact_support_plateau
add r1 1800
label forest_contact_support_ridge_done

cmp r2 0
jlt forest_contact_clear
load32 r5 4740
sub r5 65536
cmp r2 r5
jgt forest_contact_clear
localget r5 3804
sub r5 r0
cmp r5 0
jge forest_contact_road_abs
mul r5 -1
label forest_contact_road_abs
cmp r5 750
jlt forest_contact_next
label forest_contact_clear
load32 r0 100
sub r0 2000000000
localget r1 3804
sub r0 r1
mul r0 r0
load32 r1 104
sub r1 2000000000
localget r2 3805
sub r1 r2
mul r1 r1
add r0 r1
localget r1 3803
mul r1 r1
cmp r0 r1
jge forest_contact_next
load32 r0 552
store32 100 r0
load32 r0 556
store32 104 r0
store16 261 32768
store16 263 32768
store16 110 0
store16 112 32768
store8 283 1
jmp forest_contacts_done
label forest_contact_next
localget r0 3802
add r0 1
localset 3802 r0
cmp r0 9
jlt forest_contact_cell
label forest_contacts_done
# END OPEN PROP COLLISION
# BEGIN V23 RIG UPDATE
# V2.3 distance-independent wheel phase and damped body motion.
load8 r0 496
cmp r0 35
je rig_initialized
# V2.3 secondary-motion state, centimetres in Q8.
store8 496 35
store16 498 0
store16 500 16384
store16 502 0
store16 504 32768
store16 506 32768
store16 508 32768
store16 510 32768
store16 512 32768
store16 514 32768
store16 516 32768
store16 518 32768
label rig_initialized
load16 r0 110
load8 r1 133
cmp r1 1
jne rig_forward
mul r0 -1
label rig_forward
mul r0 4096
load16 r1 500
sub r1 16384
add r0 r1
mov r1 r0
mod r1 10700
add r1 16384
store16 500 r1
div r0 10700
load16 r1 498
add r0 r1
add r0 4096
mod r0 4096
store16 498 r0
load16 r0 110
load16 r1 502
store16 502 r0
sub r0 r1
mul r0 48
cmp r0 -2560
jge rig_pitch_target_lo
set r0 -2560
label rig_pitch_target_lo
cmp r0 2048
jle rig_pitch_target_hi
set r0 2048
label rig_pitch_target_hi
load16 r1 504
sub r1 32768
load16 r2 506
sub r2 32768
mov r3 r0
sub r3 r1
mul r3 3
mul r2 11
add r2 r3
div r2 16
cmp r2 -2048
jge rig_pitch_velocity_lo
set r2 -2048
label rig_pitch_velocity_lo
cmp r2 2048
jle rig_pitch_velocity_hi
set r2 2048
label rig_pitch_velocity_hi
add r1 r2
cmp r1 -3072
jge rig_pitch_position_lo
set r1 -3072
label rig_pitch_position_lo
cmp r1 3072
jle rig_pitch_position_hi
set r1 3072
label rig_pitch_position_hi
add r1 32768
store16 504 r1
add r2 32768
store16 506 r2
load16 r0 256
sub r0 1000
load16 r1 110
mul r0 r1
mul r0 r1
div r0 12000000
load16 r1 112
sub r1 32768
div r1 2
add r0 r1
cmp r0 -2560
jge rig_roll_target_lo
set r0 -2560
label rig_roll_target_lo
cmp r0 2560
jle rig_roll_target_hi
set r0 2560
label rig_roll_target_hi
load16 r1 508
sub r1 32768
load16 r2 510
sub r2 32768
mov r3 r0
sub r3 r1
mul r3 3
mul r2 11
add r2 r3
div r2 16
cmp r2 -2048
jge rig_roll_velocity_lo
set r2 -2048
label rig_roll_velocity_lo
cmp r2 2048
jle rig_roll_velocity_hi
set r2 2048
label rig_roll_velocity_hi
add r1 r2
cmp r1 -3072
jge rig_roll_position_lo
set r1 -3072
label rig_roll_position_lo
cmp r1 3072
jle rig_roll_position_hi
set r1 3072
label rig_roll_position_hi
add r1 32768
store16 508 r1
add r2 32768
store16 510 r2
set r0 0
load16 r1 110
cmp r1 100
jlt rig_heave_target
load16 r0 498
mod r0 1024
cmp r0 512
jle rig_rough_fold
set r1 1024
sub r1 r0
mov r0 r1
label rig_rough_fold
sub r0 256
load8 r1 489
cmp r1 1
je rig_rough_grass
cmp r1 2
je rig_rough_curb
div r0 8
jmp rig_heave_target
label rig_rough_grass
div r0 2
jmp rig_heave_target
label rig_rough_curb
mul r0 3
div r0 4
label rig_heave_target
load16 r1 384
cmp r1 0
je rig_grounded
set r0 768
label rig_grounded
load8 r1 391
cmp r1 1
jne rig_no_impact
store16 514 30968
label rig_no_impact
load16 r1 512
sub r1 32768
load16 r2 514
sub r2 32768
mov r3 r0
sub r3 r1
mul r3 3
mul r2 11
add r2 r3
div r2 16
cmp r2 -2048
jge rig_heave_velocity_lo
set r2 -2048
label rig_heave_velocity_lo
cmp r2 2048
jle rig_heave_velocity_hi
set r2 2048
label rig_heave_velocity_hi
add r1 r2
cmp r1 -2560
jge rig_heave_position_lo
set r1 -2560
label rig_heave_position_lo
cmp r1 2560
jle rig_heave_position_hi
set r1 2560
label rig_heave_position_hi
add r1 32768
store16 512 r1
add r2 32768
store16 514 r2
load16 r0 112
sub r0 32768
div r0 -2
cmp r0 -768
jge rig_sway_target_lo
set r0 -768
label rig_sway_target_lo
cmp r0 768
jle rig_sway_target_hi
set r0 768
label rig_sway_target_hi
load16 r1 516
sub r1 32768
load16 r2 518
sub r2 32768
mov r3 r0
sub r3 r1
mul r3 3
mul r2 11
add r2 r3
div r2 16
cmp r2 -2048
jge rig_sway_velocity_lo
set r2 -2048
label rig_sway_velocity_lo
cmp r2 2048
jle rig_sway_velocity_hi
set r2 2048
label rig_sway_velocity_hi
add r1 r2
cmp r1 -896
jge rig_sway_position_lo
set r1 -896
label rig_sway_position_lo
cmp r1 896
jle rig_sway_position_hi
set r1 896
label rig_sway_position_hi
add r1 32768
store16 516 r1
add r2 32768
store16 518 r2
# END V23 RIG UPDATE
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
add r12 1
load16 r1 520
mov r3 r0
mul r3 2
add r3 960
store16 $r3 r1
set r1 0
store8 $r12 r1
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
store8 488 0
# Score requires a real sideslip, speed, handbrake and wheels on asphalt.
store8 487 0
load8 r0 131
cmp r0 1
jne skill_combo_decay
load8 r0 489
cmp r0 0
jne skill_combo_decay
load8 r0 133
cmp r0 0
jne skill_combo_decay
load16 r0 384
cmp r0 0
jne skill_combo_decay
load16 r0 110
cmp r0 900
jlt skill_combo_decay
load16 r0 112
sub r0 32768
cmp r0 0
jge skill_slide_abs
mul r0 -1
label skill_slide_abs
cmp r0 120
jlt skill_combo_decay
store8 487 1
mov r2 r0
div r2 110
add r2 3
cmp r2 55
jle skill_tick_bounded
set r2 55
label skill_tick_bounded
load16 r3 484
add r3 2
cmp r3 400
jle skill_combo_bounded
set r3 400
label skill_combo_bounded
store16 484 r3
mul r2 r3
div r2 100
load32 r1 480
add r1 r2
cmp r1 9999999
jle skill_score_bounded
set r1 9999999
label skill_score_bounded
store32 480 r1
store8 486 80
load16 r0 380
add r0 3
cmp r0 1000
jle skill_charge_bounded
set r0 1000
label skill_charge_bounded
store16 380 r0
jmp skill_done
label skill_combo_decay
load8 r0 486
cmp r0 0
jle skill_combo_reset
sub r0 1
store8 486 r0
cmp r0 0
jgt skill_done
label skill_combo_reset
store16 484 100
label skill_done
label rank
# BEGIN OPEN CLOCK
# Eight-minute daylight cycle. Only physics ticks advance the clock.
load32 r0 528
add r0 1
mod r0 24000
store32 528 r0
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
# END OPEN CLOCK
store8 282 1
jmp publish
label publish
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
halt
label missing_world
set r0 0
div r0 0
halt
