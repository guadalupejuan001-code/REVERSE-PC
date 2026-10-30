#!reverse-pc-machine-v1
# REVERSE VELOCITY / REgraphics direct XFS1 observation.
# XI owns perspective, geometry, depth, palette selection and clipping.
# Coastal shader v2: 256 authored materials; all geometry/shading stays in XI.
# Inputs: 200=stride 1/2/4; 201=camera 0/1/2; 202=paint 0..4.
# World/vehicle state stays in the isolated XI RVPC2 snapshot.
# XFS1 x1 is inclusive; emitted spans are far-to-near, rows ordered.
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
set r14 128
jmp paint_done
label paint_blue
set r14 134
jmp paint_done
label paint_silver
set r14 140
jmp paint_done
label paint_green
set r14 146
jmp paint_done
label paint_gold
set r14 152
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
# Candidate-only observation scratch: road/world phase, slide and tree depth.
mov r11 r15
add r11 85000
mod r11 25600
cmp r11 0
jge phase_positive
add r11 25600
label phase_positive
div r11 100
store8 203 r11
load8 r6 112
load8 r7 113
mul r7 256
add r6 r7
sub r6 32768
div r6 100
add r6 32
store8 204 r6
# Interpolate the XI world samples, every 1 cm of vehicle progress.
# The same XI source generated the 241 x-coordinates; no C++ road formula.
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
# r8=remaining centimeter fraction in the 10-meter cell, [0,1000].
mov r8 r15
add r8 85000
mov r4 r11
mul r4 1000
sub r8 r4
cmp r8 0
jge near_fraction_positive
set r8 0
label near_fraction_positive
cmp r8 1000
jle near_fraction_bounded
set r8 1000
label near_fraction_bounded
# r10=near sample center xCm, reconstructed from InverseMemory bytes.
mov r9 r11
mul r9 2
add r9 512
load8 r10 $r9
add r9 1
load8 r4 $r9
mul r4 256
add r10 r4
sub r10 8192
# x(z)=x_i+(x_(i+1)-x_i)*fraction/1000: all operations XI integers.
cmp r11 240
jge near_interpolated
mov r4 r11
mul r4 2
add r4 514
load8 r6 $r4
add r4 1
load8 r7 $r4
mul r7 256
add r6 r7
sub r6 8192
sub r6 r10
mul r6 r8
div r6 1000
add r10 r6
label near_interpolated
sub r13 r10
div r13 4
# Read and interpolate a second XI road sample 100m ahead.
sub r11 10
cmp r11 0
jge far_nonnegative
set r11 0
label far_nonnegative
mov r6 r11
mul r11 2
add r11 512
load8 r9 $r11
add r11 1
load8 r4 $r11
mul r4 256
add r9 r4
sub r9 8192
cmp r6 240
jge far_interpolated
mov r4 r6
mul r4 2
add r4 514
load8 r7 $r4
add r4 1
load8 r11 $r4
mul r11 256
add r7 r11
sub r7 8192
sub r7 r9
mul r7 r8
div r7 1000
add r9 r7
label far_interpolated
sub r9 r10
div r9 12
mov r15 r9
# Use the XI driving state yaw to align horizon and road heading.
load8 r11 108
load8 r4 109
mul r4 256
add r11 r4
cmp r11 2048
jle renderer_yaw_ready
sub r11 4096
label renderer_yaw_ready
div r11 24
add r15 r11
load8 r6 203
add r6 0
mod r6 256
mul r6 60
set r7 18000
sub r7 r6
set r6 1600000
div r6 r7
add r6 290
mov r11 r6
mod r11 256
store8 220 r11
div r6 256
store8 221 r6
set r6 900000
div r6 r7
mov r11 r6
mod r11 256
store8 222 r11
div r6 256
store8 223 r6
load8 r6 203
add r6 128
mod r6 256
mul r6 60
set r7 18000
sub r7 r6
set r6 1600000
div r6 r7
add r6 290
mov r11 r6
mod r11 256
store8 224 r11
div r6 256
store8 225 r6
set r6 900000
div r6 r7
mov r11 r6
mod r11 256
store8 226 r11
div r6 256
store8 227 r6
framebegin 1280 720 1
set r0 0
label scanline
cmp r0 720
jge finished

# Layer 0: background.
label draw_background
set r1 0
set r2 1280
cmp r0 290
jge background_land
mov r3 r0
mul r3 63
div r3 289
jmp background_emit
label background_land
mov r3 r0
sub r3 290
mul r3 31
div r3 429
add r3 64
label background_emit
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_background_start
set r1 0
label clip_background_start
cmp r2 1280
jle clip_background_end
set r2 1280
label clip_background_end
cmp r1 r2
jge next_background
sub r2 1
framespan r0 r1 r2 r3 100
add r2 1
label next_background

# Layer 1: sun_halo.
label draw_sun_halo
cmp r0 65
jlt next_sun_halo
cmp r0 200
jge next_sun_halo
mov r11 r0
sub r11 132
mul r11 r11
div r11 68
set r1 910
add r1 r11
set r2 1090
sub r2 r11
set r3 218
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_sun_halo_start
set r1 0
label clip_sun_halo_start
cmp r2 1280
jle clip_sun_halo_end
set r2 1280
label clip_sun_halo_end
cmp r1 r2
jge next_sun_halo
sub r2 1
framespan r0 r1 r2 r3 99
add r2 1
label next_sun_halo

# Layer 2: sun.
label draw_sun
cmp r0 94
jlt next_sun
cmp r0 171
jge next_sun
mov r11 r0
sub r11 132
mul r11 r11
div r11 38
set r1 962
add r1 r11
set r2 1038
sub r2 r11
set r3 217
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_sun_start
set r1 0
label clip_sun_start
cmp r2 1280
jle clip_sun_end
set r2 1280
label clip_sun_end
cmp r1 r2
jge next_sun
sub r2 1
framespan r0 r1 r2 r3 98
add r2 1
label next_sun

# Layer 3: cloud_left.
label draw_cloud_left
cmp r0 118
jlt next_cloud_left
cmp r0 133
jge next_cloud_left
mov r11 r0
sub r11 125
mul r11 r11
mul r11 3
set r1 145
add r1 r11
set r2 510
sub r2 r11
set r3 215
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_cloud_left_start
set r1 0
label clip_cloud_left_start
cmp r2 1280
jle clip_cloud_left_end
set r2 1280
label clip_cloud_left_end
cmp r1 r2
jge next_cloud_left
sub r2 1
framespan r0 r1 r2 r3 97
add r2 1
label next_cloud_left

# Layer 4: cloud_right.
label draw_cloud_right
cmp r0 52
jlt next_cloud_right
cmp r0 64
jge next_cloud_right
mov r11 r0
sub r11 58
mul r11 r11
mul r11 3
set r1 650
add r1 r11
set r2 880
sub r2 r11
set r3 216
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_cloud_right_start
set r1 0
label clip_cloud_right_start
cmp r2 1280
jle clip_cloud_right_end
set r2 1280
label clip_cloud_right_end
cmp r1 r2
jge next_cloud_right
sub r2 1
framespan r0 r1 r2 r3 96
add r2 1
label next_cloud_right

# Layer 5: mountain_far_left.
label draw_mountain_far_left
cmp r0 170
jlt next_mountain_far_left
cmp r0 303
jge next_mountain_far_left
set r1 0
mov r2 r0
sub r2 170
mul r2 4
add r2 140
mov r3 r0
sub r3 170
div r3 45
add r3 186
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_mountain_far_left_start
set r1 0
label clip_mountain_far_left_start
cmp r2 1280
jle clip_mountain_far_left_end
set r2 1280
label clip_mountain_far_left_end
cmp r1 r2
jge next_mountain_far_left
sub r2 1
framespan r0 r1 r2 r3 95
add r2 1
label next_mountain_far_left

# Layer 6: mountain_far_right.
label draw_mountain_far_right
cmp r0 190
jlt next_mountain_far_right
cmp r0 303
jge next_mountain_far_right
mov r1 r0
sub r1 190
mul r1 5
set r2 1160
sub r2 r1
mov r1 r2
set r2 1280
set r3 188
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_mountain_far_right_start
set r1 0
label clip_mountain_far_right_start
cmp r2 1280
jle clip_mountain_far_right_end
set r2 1280
label clip_mountain_far_right_end
cmp r1 r2
jge next_mountain_far_right
sub r2 1
framespan r0 r1 r2 r3 94
add r2 1
label next_mountain_far_right

# Layer 7: mountain_near_left.
label draw_mountain_near_left
cmp r0 228
jlt next_mountain_near_left
cmp r0 334
jge next_mountain_near_left
set r1 0
mov r2 r0
sub r2 228
mul r2 5
add r2 95
set r3 191
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_mountain_near_left_start
set r1 0
label clip_mountain_near_left_start
cmp r2 1280
jle clip_mountain_near_left_end
set r2 1280
label clip_mountain_near_left_end
cmp r1 r2
jge next_mountain_near_left
sub r2 1
framespan r0 r1 r2 r3 93
add r2 1
label next_mountain_near_left

# Layer 8: mountain_near_right.
label draw_mountain_near_right
cmp r0 252
jlt next_mountain_near_right
cmp r0 322
jge next_mountain_near_right
mov r1 r0
sub r1 252
mul r1 6
set r2 1170
sub r2 r1
mov r1 r2
set r2 1280
set r3 192
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_mountain_near_right_start
set r1 0
label clip_mountain_near_right_start
cmp r2 1280
jle clip_mountain_near_right_end
set r2 1280
label clip_mountain_near_right_end
cmp r1 r2
jge next_mountain_near_right
sub r2 1
framespan r0 r1 r2 r3 92
add r2 1
label next_mountain_near_right

# Layer 9: sea.
label draw_sea
cmp r0 290
jlt next_sea
cmp r0 555
jge next_sea
mov r1 r0
sub r1 290
div r1 3
add r1 895
set r2 1280
mov r3 r0
sub r3 290
mul r3 15
div r3 265
add r3 170
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_sea_start
set r1 0
label clip_sea_start
cmp r2 1280
jle clip_sea_end
set r2 1280
label clip_sea_end
cmp r1 r2
jge next_sea
sub r2 1
framespan r0 r1 r2 r3 91
add r2 1
label next_sea

# Layer 10: shore.
label draw_shore
cmp r0 291
jlt next_shore
cmp r0 555
jge next_shore
mov r1 r0
sub r1 290
div r1 3
add r1 884
mov r2 r1
add r2 14
set r3 203
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_shore_start
set r1 0
label clip_shore_start
cmp r2 1280
jle clip_shore_end
set r2 1280
label clip_shore_end
cmp r1 r2
jge next_shore
sub r2 1
framespan r0 r1 r2 r3 90
add r2 1
label next_shore

# Layer 11: asphalt.
label draw_asphalt
cmp r0 290
jlt next_asphalt
# Projection from the authoritative XI road samples; bounds clipped only at emission.
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
mov r1 r9
mov r2 r10
mov r3 r6
mul r3 30
div r3 429
add r3 96
load8 r11 203
add r11 r0
div r11 11
mod r11 2
add r3 r11
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_asphalt_start
set r1 0
label clip_asphalt_start
cmp r2 1280
jle clip_asphalt_end
set r2 1280
label clip_asphalt_end
cmp r1 r2
jge next_asphalt
sub r2 1
framespan r0 r1 r2 r3 89
add r2 1
label next_asphalt

# Layer 12: road_sheen.
label draw_road_sheen
cmp r0 350
jlt next_road_sheen
mov r1 r7
div r1 5
add r1 r8
mov r2 r7
mul r2 3
div r2 5
add r2 r8
mov r3 r6
mul r3 7
div r3 429
add r3 229
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_road_sheen_start
set r1 0
label clip_road_sheen_start
cmp r2 1280
jle clip_road_sheen_end
set r2 1280
label clip_road_sheen_end
cmp r1 r2
jge next_road_sheen
sub r2 1
framespan r0 r1 r2 r3 88
add r2 1
label next_road_sheen

# Layer 13: curb_left.
label draw_curb_left
cmp r0 290
jlt next_curb_left
mov r11 r6
div r11 30
add r11 6
mov r1 r9
sub r1 r11
mov r2 r9
load8 r3 203
add r3 r0
div r3 18
mod r3 2
mul r3 2
add r3 206
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_curb_left_start
set r1 0
label clip_curb_left_start
cmp r2 1280
jle clip_curb_left_end
set r2 1280
label clip_curb_left_end
cmp r1 r2
jge next_curb_left
sub r2 1
framespan r0 r1 r2 r3 87
add r2 1
label next_curb_left

# Layer 14: curb_right.
label draw_curb_right
cmp r0 290
jlt next_curb_right
mov r11 r6
div r11 30
add r11 6
mov r1 r10
mov r2 r10
add r2 r11
load8 r3 203
add r3 r0
div r3 18
mod r3 2
mul r3 2
add r3 206
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_curb_right_start
set r1 0
label clip_curb_right_start
cmp r2 1280
jle clip_curb_right_end
set r2 1280
label clip_curb_right_end
cmp r1 r2
jge next_curb_right
sub r2 1
framespan r0 r1 r2 r3 86
add r2 1
label next_curb_right

# Layer 15: edge_left.
label draw_edge_left
cmp r0 290
jlt next_edge_left
mov r11 r6
div r11 100
add r11 2
mov r1 r9
mov r2 r9
add r2 r11
set r3 206
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_edge_left_start
set r1 0
label clip_edge_left_start
cmp r2 1280
jle clip_edge_left_end
set r2 1280
label clip_edge_left_end
cmp r1 r2
jge next_edge_left
sub r2 1
framespan r0 r1 r2 r3 85
add r2 1
label next_edge_left

# Layer 16: edge_right.
label draw_edge_right
cmp r0 290
jlt next_edge_right
mov r11 r6
div r11 100
add r11 2
mov r1 r10
sub r1 r11
mov r2 r10
set r3 206
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_edge_right_start
set r1 0
label clip_edge_right_start
cmp r2 1280
jle clip_edge_right_end
set r2 1280
label clip_edge_right_end
cmp r1 r2
jge next_edge_right
sub r2 1
framespan r0 r1 r2 r3 84
add r2 1
label next_edge_right

# Layer 17: centerline.
label draw_centerline
cmp r0 290
jlt next_centerline
load8 r11 203
add r11 r0
mod r11 47
cmp r11 29
jge next_centerline
mov r11 r6
div r11 140
add r11 1
mov r1 r8
sub r1 r11
mov r2 r8
add r2 r11
set r3 207
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_centerline_start
set r1 0
label clip_centerline_start
cmp r2 1280
jle clip_centerline_end
set r2 1280
label clip_centerline_end
cmp r1 r2
jge next_centerline
sub r2 1
framespan r0 r1 r2 r3 83
add r2 1
label next_centerline

# Layer 18: rail_left.
label draw_rail_left
cmp r0 310
jlt next_rail_left
mov r11 r6
div r11 12
add r11 18
mov r2 r9
sub r2 r11
mov r1 r2
sub r1 7
mov r3 r0
div r3 4
mod r3 2
add r3 219
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_rail_left_start
set r1 0
label clip_rail_left_start
cmp r2 1280
jle clip_rail_left_end
set r2 1280
label clip_rail_left_end
cmp r1 r2
jge next_rail_left
sub r2 1
framespan r0 r1 r2 r3 82
add r2 1
label next_rail_left

# Layer 19: rail_right.
label draw_rail_right
cmp r0 310
jlt next_rail_right
mov r11 r6
div r11 12
add r11 18
mov r1 r10
add r1 r11
mov r2 r1
add r2 7
mov r3 r0
div r3 4
mod r3 2
add r3 219
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_rail_right_start
set r1 0
label clip_rail_right_start
cmp r2 1280
jle clip_rail_right_end
set r2 1280
label clip_rail_right_end
cmp r1 r2
jge next_rail_right
sub r2 1
framespan r0 r1 r2 r3 81
add r2 1
label next_rail_right

# Layer 20: trunk_left.
label draw_trunk_left
load8 r6 220
load8 r11 221
mul r11 256
add r6 r11
load8 r7 222
load8 r11 223
mul r11 256
add r7 r11
mov r8 r6
sub r8 290
mul r8 11
div r8 10
add r8 100
mul r8 -1
add r8 640
sub r8 r13
mov r11 720
sub r11 r6
mul r11 r15
div r11 430
add r8 r11
mov r11 r7
div r11 2
sub r11 r6
mul r11 -1
cmp r0 r11
jlt next_trunk_left
cmp r0 r6
jgt next_trunk_left
mov r11 r7
div r11 18
add r11 2
mov r1 r8
sub r1 r11
mov r2 r8
add r2 r11
set r3 202
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_trunk_left_start
set r1 0
label clip_trunk_left_start
cmp r2 1280
jle clip_trunk_left_end
set r2 1280
label clip_trunk_left_end
cmp r1 r2
jge next_trunk_left
sub r2 1
framespan r0 r1 r2 r3 80
add r2 1
label next_trunk_left

# Layer 21: crown_left.
label draw_crown_left
mov r11 r6
sub r11 r7
cmp r0 r11
jlt next_crown_left
mov r1 r7
div r1 8
mov r2 r6
sub r2 r1
cmp r0 r2
jge next_crown_left
mov r11 r0
sub r11 r6
add r11 r7
mul r11 3
div r11 5
mov r1 r8
sub r1 r11
mov r2 r8
add r2 r11
mov r3 r0
div r3 18
mod r3 3
add r3 194
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_crown_left_start
set r1 0
label clip_crown_left_start
cmp r2 1280
jle clip_crown_left_end
set r2 1280
label clip_crown_left_end
cmp r1 r2
jge next_crown_left
sub r2 1
framespan r0 r1 r2 r3 79
add r2 1
label next_crown_left

# Layer 22: crown_lit_left.
label draw_crown_lit_left
mov r11 r6
sub r11 r7
cmp r0 r11
jlt next_crown_lit_left
mov r1 r7
div r1 8
mov r2 r6
sub r2 r1
cmp r0 r2
jge next_crown_lit_left
mov r11 r0
sub r11 r6
add r11 r7
mul r11 3
div r11 5
mov r1 r8
mov r2 r8
add r2 r11
mov r3 r0
div r3 19
mod r3 3
add r3 198
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_crown_lit_left_start
set r1 0
label clip_crown_lit_left_start
cmp r2 1280
jle clip_crown_lit_left_end
set r2 1280
label clip_crown_lit_left_end
cmp r1 r2
jge next_crown_lit_left
sub r2 1
framespan r0 r1 r2 r3 78
add r2 1
label next_crown_lit_left

# Layer 23: trunk_right.
label draw_trunk_right
load8 r6 224
load8 r11 225
mul r11 256
add r6 r11
load8 r7 226
load8 r11 227
mul r11 256
add r7 r11
mov r8 r6
sub r8 290
mul r8 11
div r8 10
add r8 100
add r8 640
sub r8 r13
mov r11 720
sub r11 r6
mul r11 r15
div r11 430
add r8 r11
mov r11 r7
div r11 2
sub r11 r6
mul r11 -1
cmp r0 r11
jlt next_trunk_right
cmp r0 r6
jgt next_trunk_right
mov r11 r7
div r11 18
add r11 2
mov r1 r8
sub r1 r11
mov r2 r8
add r2 r11
set r3 202
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_trunk_right_start
set r1 0
label clip_trunk_right_start
cmp r2 1280
jle clip_trunk_right_end
set r2 1280
label clip_trunk_right_end
cmp r1 r2
jge next_trunk_right
sub r2 1
framespan r0 r1 r2 r3 77
add r2 1
label next_trunk_right

# Layer 24: crown_right.
label draw_crown_right
mov r11 r6
sub r11 r7
cmp r0 r11
jlt next_crown_right
mov r1 r7
div r1 8
mov r2 r6
sub r2 r1
cmp r0 r2
jge next_crown_right
mov r11 r0
sub r11 r6
add r11 r7
mul r11 3
div r11 5
mov r1 r8
sub r1 r11
mov r2 r8
add r2 r11
mov r3 r0
div r3 18
mod r3 3
add r3 194
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_crown_right_start
set r1 0
label clip_crown_right_start
cmp r2 1280
jle clip_crown_right_end
set r2 1280
label clip_crown_right_end
cmp r1 r2
jge next_crown_right
sub r2 1
framespan r0 r1 r2 r3 76
add r2 1
label next_crown_right

# Layer 25: crown_lit_right.
label draw_crown_lit_right
mov r11 r6
sub r11 r7
cmp r0 r11
jlt next_crown_lit_right
mov r1 r7
div r1 8
mov r2 r6
sub r2 r1
cmp r0 r2
jge next_crown_lit_right
mov r11 r0
sub r11 r6
add r11 r7
mul r11 3
div r11 5
mov r1 r8
mov r2 r8
add r2 r11
mov r3 r0
div r3 19
mod r3 3
add r3 198
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_crown_lit_right_start
set r1 0
label clip_crown_lit_right_start
cmp r2 1280
jle clip_crown_lit_right_end
set r2 1280
label clip_crown_lit_right_end
cmp r1 r2
jge next_crown_lit_right
sub r2 1
framespan r0 r1 r2 r3 75
add r2 1
label next_crown_lit_right

# Layer 26: gate_left.
label draw_gate_left
store8 216 0
load8 r6 114
cmp r6 6
jge next_gate_left
mul r6 30000
set r7 90000
sub r7 r6
load8 r6 104
load8 r11 105
mul r11 256
add r6 r11
load8 r11 106
mul r11 65536
add r6 r11
load8 r11 107
mul r11 16777216
add r6 r11
sub r6 2000000
sub r6 r7
cmp r6 0
jlt next_gate_left
cmp r6 45000
jgt next_gate_left
add r6 5000
set r7 5000000
div r7 r6
add r7 290
set r11 1200000
div r11 r6
mov r6 r7
sub r6 r11
mov r8 720
sub r8 r7
mul r8 r15
div r8 430
sub r8 r13
add r8 640
mov r9 r7
sub r9 290
mul r9 11
div r9 10
add r9 22
mov r10 r8
add r10 r9
sub r8 r9
store8 216 1
cmp r0 r6
jlt next_gate_left
cmp r0 r7
jge next_gate_left
mov r1 r8
sub r1 5
mov r2 r8
add r2 5
set r3 227
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_gate_left_start
set r1 0
label clip_gate_left_start
cmp r2 1280
jle clip_gate_left_end
set r2 1280
label clip_gate_left_end
cmp r1 r2
jge next_gate_left
sub r2 1
framespan r0 r1 r2 r3 74
add r2 1
label next_gate_left

# Layer 27: gate_right.
label draw_gate_right
load8 r11 216
cmp r11 1
jne next_gate_right
load8 r11 114
cmp r11 6
jge next_gate_right
cmp r0 r6
jlt next_gate_right
cmp r0 r7
jge next_gate_right
mov r1 r10
sub r1 5
mov r2 r10
add r2 5
set r3 227
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_gate_right_start
set r1 0
label clip_gate_right_start
cmp r2 1280
jle clip_gate_right_end
set r2 1280
label clip_gate_right_end
cmp r1 r2
jge next_gate_right
sub r2 1
framespan r0 r1 r2 r3 73
add r2 1
label next_gate_right

# Layer 28: gate_crossbar.
label draw_gate_crossbar
load8 r11 216
cmp r11 1
jne next_gate_crossbar
load8 r11 114
cmp r11 6
jge next_gate_crossbar
cmp r0 r6
jlt next_gate_crossbar
mov r11 r6
add r11 6
cmp r0 r11
jge next_gate_crossbar
mov r1 r8
sub r1 5
mov r2 r10
add r2 5
set r3 228
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_gate_crossbar_start
set r1 0
label clip_gate_crossbar_start
cmp r2 1280
jle clip_gate_crossbar_end
set r2 1280
label clip_gate_crossbar_end
cmp r1 r2
jge next_gate_crossbar
sub r2 1
framespan r0 r1 r2 r3 72
add r2 1
label next_gate_crossbar

# Layer 29: car_shadow.
label draw_car_shadow
# Car camera mapping and slip are XI presentation rules.
mov r6 r0
load8 r11 201
cmp r11 1
jne car_row_ready
sub r6 700
mul r6 4
div r6 5
add r6 700
label car_row_ready
load8 r8 204
sub r8 32
add r8 640
load8 r11 201
cmp r11 2
je next_car_shadow
cmp r6 634
jlt next_car_shadow
cmp r6 709
jge next_car_shadow
mov r11 r6
sub r11 674
mul r11 r11
div r11 11
set r7 190
sub r7 r11
mov r1 r8
sub r1 r7
mov r2 r8
add r2 r7
set r3 210
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_car_shadow_start
set r1 0
label clip_car_shadow_start
cmp r2 1280
jle clip_car_shadow_end
set r2 1280
label clip_car_shadow_end
cmp r1 r2
jge next_car_shadow
sub r2 1
framespan r0 r1 r2 r3 71
add r2 1
label next_car_shadow

# Layer 30: tire_left.
label draw_tire_left
load8 r11 201
cmp r11 2
je next_tire_left
cmp r6 607
jlt next_tire_left
cmp r6 689
jge next_tire_left
mov r1 r8
add r1 -166
mov r2 r1
add r2 38
set r3 209
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_tire_left_start
set r1 0
label clip_tire_left_start
cmp r2 1280
jle clip_tire_left_end
set r2 1280
label clip_tire_left_end
cmp r1 r2
jge next_tire_left
sub r2 1
framespan r0 r1 r2 r3 70
add r2 1
label next_tire_left

# Layer 31: tire_right.
label draw_tire_right
load8 r11 201
cmp r11 2
je next_tire_right
cmp r6 607
jlt next_tire_right
cmp r6 689
jge next_tire_right
mov r1 r8
add r1 128
mov r2 r1
add r2 38
set r3 209
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_tire_right_start
set r1 0
label clip_tire_right_start
cmp r2 1280
jle clip_tire_right_end
set r2 1280
label clip_tire_right_end
cmp r1 r2
jge next_tire_right
sub r2 1
framespan r0 r1 r2 r3 69
add r2 1
label next_tire_right

# Layer 32: car_body.
label draw_car_body
load8 r11 201
cmp r11 2
je next_car_body
cmp r6 530
jlt next_car_body
cmp r6 684
jge next_car_body
mov r7 r6
sub r7 530
div r7 2
add r7 85
mov r1 r8
sub r1 r7
mov r2 r8
add r2 r7
mov r3 r14
add r3 2
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_car_body_start
set r1 0
label clip_car_body_start
cmp r2 1280
jle clip_car_body_end
set r2 1280
label clip_car_body_end
cmp r1 r2
jge next_car_body
sub r2 1
framespan r0 r1 r2 r3 68
add r2 1
label next_car_body

# Layer 33: car_shadow_side.
label draw_car_shadow_side
load8 r11 201
cmp r11 2
je next_car_shadow_side
cmp r6 530
jlt next_car_shadow_side
cmp r6 684
jge next_car_shadow_side
mov r1 r8
sub r1 r7
mov r2 r7
div r2 4
add r2 r1
mov r3 r14
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_car_shadow_side_start
set r1 0
label clip_car_shadow_side_start
cmp r2 1280
jle clip_car_shadow_side_end
set r2 1280
label clip_car_shadow_side_end
cmp r1 r2
jge next_car_shadow_side
sub r2 1
framespan r0 r1 r2 r3 67
add r2 1
label next_car_shadow_side

# Layer 34: car_highlight.
label draw_car_highlight
load8 r11 201
cmp r11 2
je next_car_highlight
cmp r6 530
jlt next_car_highlight
cmp r6 684
jge next_car_highlight
mov r2 r8
add r2 r7
mov r1 r2
sub r1 13
mov r3 r14
add r3 4
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_car_highlight_start
set r1 0
label clip_car_highlight_start
cmp r2 1280
jle clip_car_highlight_end
set r2 1280
label clip_car_highlight_end
cmp r1 r2
jge next_car_highlight
sub r2 1
framespan r0 r1 r2 r3 66
add r2 1
label next_car_highlight

# Layer 35: roof.
label draw_roof
load8 r11 201
cmp r11 2
je next_roof
cmp r6 535
jlt next_roof
cmp r6 566
jge next_roof
mov r11 r6
sub r11 530
div r11 3
add r11 80
mov r1 r8
sub r1 r11
mov r2 r8
add r2 r11
mov r3 r14
add r3 1
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_roof_start
set r1 0
label clip_roof_start
cmp r2 1280
jle clip_roof_end
set r2 1280
label clip_roof_end
cmp r1 r2
jge next_roof
sub r2 1
framespan r0 r1 r2 r3 65
add r2 1
label next_roof

# Layer 36: rear_window.
label draw_rear_window
load8 r11 201
cmp r11 2
je next_rear_window
cmp r6 566
jlt next_rear_window
cmp r6 620
jge next_rear_window
mov r11 r6
sub r11 566
div r11 3
add r11 85
mov r1 r8
sub r1 r11
mov r2 r8
add r2 r11
mov r3 r6
sub r3 566
div r3 5
add r3 158
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_rear_window_start
set r1 0
label clip_rear_window_start
cmp r2 1280
jle clip_rear_window_end
set r2 1280
label clip_rear_window_end
cmp r1 r2
jge next_rear_window
sub r2 1
framespan r0 r1 r2 r3 64
add r2 1
label next_rear_window

# Layer 37: glass_reflection.
label draw_glass_reflection
load8 r11 201
cmp r11 2
je next_glass_reflection
cmp r6 570
jlt next_glass_reflection
cmp r6 610
jge next_glass_reflection
mov r1 r6
sub r1 570
mul r1 3
sub r1 75
add r1 r8
mov r2 r1
add r2 28
mov r3 r6
sub r3 570
mul r3 7
div r3 40
add r3 237
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_glass_reflection_start
set r1 0
label clip_glass_reflection_start
cmp r2 1280
jle clip_glass_reflection_end
set r2 1280
label clip_glass_reflection_end
cmp r1 r2
jge next_glass_reflection
sub r2 1
framespan r0 r1 r2 r3 63
add r2 1
label next_glass_reflection

# Layer 38: bumper.
label draw_bumper
load8 r11 201
cmp r11 2
je next_bumper
cmp r6 655
jlt next_bumper
cmp r6 681
jge next_bumper
mov r1 r8
sub r1 147
mov r2 r8
add r2 147
mov r3 r14
add r3 1
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_bumper_start
set r1 0
label clip_bumper_start
cmp r2 1280
jle clip_bumper_end
set r2 1280
label clip_bumper_end
cmp r1 r2
jge next_bumper
sub r2 1
framespan r0 r1 r2 r3 62
add r2 1
label next_bumper

# Layer 39: tail_light_left.
label draw_tail_light_left
load8 r11 201
cmp r11 2
je next_tail_light_left
cmp r6 641
jlt next_tail_light_left
cmp r6 652
jge next_tail_light_left
mov r1 r8
add r1 -130
mov r2 r1
add r2 65
set r3 213
load8 r11 129
cmp r11 1
jne tail_left_ready
set r3 253
label tail_left_ready
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_tail_light_left_start
set r1 0
label clip_tail_light_left_start
cmp r2 1280
jle clip_tail_light_left_end
set r2 1280
label clip_tail_light_left_end
cmp r1 r2
jge next_tail_light_left
sub r2 1
framespan r0 r1 r2 r3 61
add r2 1
label next_tail_light_left

# Layer 40: tail_light_right.
label draw_tail_light_right
load8 r11 201
cmp r11 2
je next_tail_light_right
cmp r6 641
jlt next_tail_light_right
cmp r6 652
jge next_tail_light_right
mov r1 r8
add r1 65
mov r2 r1
add r2 65
set r3 213
load8 r11 129
cmp r11 1
jne tail_right_ready
set r3 253
label tail_right_ready
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_tail_light_right_start
set r1 0
label clip_tail_light_right_start
cmp r2 1280
jle clip_tail_light_right_end
set r2 1280
label clip_tail_light_right_end
cmp r1 r2
jge next_tail_light_right
sub r2 1
framespan r0 r1 r2 r3 60
add r2 1
label next_tail_light_right

# Layer 41: spoiler.
label draw_spoiler
load8 r11 201
cmp r11 2
je next_spoiler
cmp r6 628
jlt next_spoiler
cmp r6 636
jge next_spoiler
mov r1 r8
sub r1 170
mov r2 r8
add r2 170
mov r3 r14
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_spoiler_start
set r1 0
label clip_spoiler_start
cmp r2 1280
jle clip_spoiler_end
set r2 1280
label clip_spoiler_end
cmp r1 r2
jge next_spoiler
sub r2 1
framespan r0 r1 r2 r3 59
add r2 1
label next_spoiler

# Layer 42: diffuser.
label draw_diffuser
load8 r11 201
cmp r11 2
je next_diffuser
cmp r6 673
jlt next_diffuser
cmp r6 681
jge next_diffuser
mov r1 r8
sub r1 60
mov r2 r8
add r2 60
set r3 211
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_diffuser_start
set r1 0
label clip_diffuser_start
cmp r2 1280
jle clip_diffuser_end
set r2 1280
label clip_diffuser_end
cmp r1 r2
jge next_diffuser
sub r2 1
framespan r0 r1 r2 r3 58
add r2 1
label next_diffuser

# Layer 43: cockpit_hood.
label draw_cockpit_hood
load8 r11 201
cmp r11 2
jne next_cockpit_hood
cmp r0 620
jlt next_cockpit_hood
mov r7 r0
sub r7 620
mul r7 4
add r7 170
mov r1 r8
sub r1 r7
mov r2 r8
add r2 r7
mov r3 r0
sub r3 620
div r3 35
add r3 r14
add r3 2
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_cockpit_hood_start
set r1 0
label clip_cockpit_hood_start
cmp r2 1280
jle clip_cockpit_hood_end
set r2 1280
label clip_cockpit_hood_end
cmp r1 r2
jge next_cockpit_hood
sub r2 1
framespan r0 r1 r2 r3 57
add r2 1
label next_cockpit_hood

# Layer 44: dashboard.
label draw_dashboard
load8 r11 201
cmp r11 2
jne next_dashboard
cmp r0 704
jlt next_dashboard
set r1 0
set r2 1280
set r3 246
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_dashboard_start
set r1 0
label clip_dashboard_start
cmp r2 1280
jle clip_dashboard_end
set r2 1280
label clip_dashboard_end
cmp r1 r2
jge next_dashboard
sub r2 1
framespan r0 r1 r2 r3 56
add r2 1
label next_dashboard

# Layer 45: hood_stripe.
label draw_hood_stripe
load8 r11 201
cmp r11 2
jne next_hood_stripe
cmp r0 626
jlt next_hood_stripe
cmp r0 704
jge next_hood_stripe
mov r1 r8
sub r1 18
mov r2 r8
add r2 18
set r3 247
# Inline emission keeps the hot path free of a 46-way return dispatcher.
cmp r1 0
jge clip_hood_stripe_start
set r1 0
label clip_hood_stripe_start
cmp r2 1280
jle clip_hood_stripe_end
set r2 1280
label clip_hood_stripe_end
cmp r1 r2
jge next_hood_stripe
sub r2 1
framespan r0 r1 r2 r3 55
add r2 1
label next_hood_stripe
add r0 r5
jmp scanline
label finished
frameend
halt
label missing_world
halt
