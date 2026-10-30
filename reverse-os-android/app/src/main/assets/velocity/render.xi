#!reverse-pc-machine-v1
# REgraphics v3: world-space 3D meshes, perspective, near-plane and Z-buffer.
# The generic meshtri3 primitive clips/rasterizes; XI owns world geometry and camera.
# Read-only observation: every scratch byte belongs to the discarded render candidate.
load32 r12 100
sub r12 2000000
load32 r13 104
sub r13 2000000
load16 r0 108
mov r14 r0
add r14 0
mod r14 4096
cmp r14 0
jge sin_negative_0
add r14 4096
label sin_negative_0
mov r1 r14
mod r1 2048
set r2 2048
sub r2 r1
mul r1 r2
mov r2 r1
mul r2 4
set r15 20971520
sub r15 r2
mul r1 262144
div r1 r15
cmp r14 2048
jlt sin_done_1
mul r1 -1
label sin_done_1
mov r14 r1
mov r2 r14
mov r9 r2
add r9 32768
localset 58 r9
mov r15 r0
add r15 1024
mod r15 4096
cmp r15 0
jge sin_negative_2
add r15 4096
label sin_negative_2
mov r1 r15
mod r1 2048
set r2 2048
sub r2 r1
mul r1 r2
mov r2 r1
mul r2 4
set r14 20971520
sub r14 r2
mul r1 262144
div r1 r14
cmp r15 2048
jlt sin_done_3
mul r1 -1
label sin_done_3
mov r15 r1
localget r14 58
sub r14 32768
load8 r0 200
cmp r0 1
je size_high
cmp r0 2
je size_medium
set r0 320
set r1 180
jmp size_done
label size_medium
set r0 480
set r1 270
jmp size_done
label size_high
set r0 640
set r1 360
label size_done
mov r9 r0
localset 18 r9
mov r9 r1
localset 20 r9
meshbegin r0 r1 2 12
load8 r0 201
cmp r0 1
je camera_close
cmp r0 2
je camera_hood
set r0 900
set r1 360
set r2 200
set r3 980
jmp camera_ready
label camera_close
set r0 650
set r1 260
set r2 210
set r3 978
jmp camera_ready
label camera_hood
set r0 0
set r1 125
set r2 70
set r3 998
label camera_ready
mov r9 r0
localset 0 r9
mov r9 r1
localset 2 r9
mov r9 r2
localset 4 r9
mov r9 r3
localset 6 r9
localget r0 18
localget r1 20
mov r2 r1
div r2 2
mov r3 r0
mul r3 85
div r3 100
localget r4 4
mul r3 r4
localget r4 6
div r3 r4
sub r2 r3
mov r9 r2
localset 46 r9
mov r3 r2
div r3 2
meshtri 0 0 999999 r0 0 999999 r0 r3 999999 8
meshtri 0 0 999999 r0 r3 999999 0 r3 999999 8
meshtri 0 r3 999999 r0 r3 999999 r0 r2 999999 38
meshtri 0 r3 999999 r0 r2 999999 0 r2 999999 38
meshtri 0 r2 999998 r0 r2 999998 r0 r1 999998 72
meshtri 0 r2 999998 r0 r1 999998 0 r1 999998 72
load8 r6 108
load8 r7 109
mul r7 256
add r6 r7
mul r6 5
div r6 16
mod r6 160
localset 44 r6
set r7 0
label hills
localget r0 18
mov r1 r0
mul r1 r7
div r1 5
mov r2 r0
div r2 160
localget r6 44
mul r6 r2
sub r1 r6
mov r2 r0
div r2 3
add r2 r1
mov r4 r1
add r4 r2
div r4 2
localget r3 46
mov r5 r0
div r5 20
mul r5 -1
add r5 r3
meshtri r1 r3 999990 r4 r5 999990 r2 r3 999990 189
add r7 1
cmp r7 8
jlt hills
localset 8 0
label transform_track
localget r8 8
mov r7 r8
mul r7 8
add r7 4096
load32 r0 $r7
sub r0 65536
add r7 4
load32 r2 $r7
sub r2 65536
set r1 0
sub r0 r12
sub r2 r13
mov r9 r0
mul r9 r15
mov r10 r2
mul r10 r14
sub r9 r10
div r9 16384
mov r10 r0
mul r10 r14
mov r11 r2
mul r11 r15
add r10 r11
div r10 16384
mov r0 r9
localget r11 0
add r10 r11
localget r11 2
sub r1 r11
localget r11 4
mul r11 r1
localget r9 6
mov r2 r10
mul r2 r9
sub r2 r11
div r2 1000
mul r1 r9
localget r11 4
mul r11 r10
add r1 r11
div r1 1000
localget r8 8
mul r8 2
add r8 1000
meshvertex r8 r0 r1 r2
localget r7 8
mul r7 2
add r7 5000
load16 r0 $r7
mov r1 r0
add r1 0
mod r1 4096
cmp r1 0
jge sin_negative_4
add r1 4096
label sin_negative_4
mov r3 r1
mod r3 2048
set r4 2048
sub r4 r3
mul r3 r4
mov r4 r3
mul r4 4
set r2 20971520
sub r2 r4
mul r3 262144
div r3 r2
cmp r1 2048
jlt sin_done_5
mul r3 -1
label sin_done_5
mov r1 r3
mov r4 r1
mov r9 r4
add r9 32768
localset 58 r9
mov r2 r0
add r2 1024
mod r2 4096
cmp r2 0
jge sin_negative_6
add r2 4096
label sin_negative_6
mov r3 r2
mod r3 2048
set r4 2048
sub r4 r3
mul r3 r4
mov r4 r3
mul r4 4
set r1 20971520
sub r1 r4
mul r3 262144
div r3 r1
cmp r2 2048
jlt sin_done_7
mul r3 -1
label sin_done_7
mov r2 r3
localget r1 58
sub r1 32768
mov r0 r2
mul r0 r15
mov r3 r1
mul r3 r14
add r0 r3
div r0 16384
mov r10 r2
mul r10 r14
mul r1 r15
sub r10 r1
div r10 16384
set r1 0
set r2 0
localget r11 4
mul r11 r1
localget r9 6
mov r2 r10
mul r2 r9
sub r2 r11
div r2 1000
mul r1 r9
localget r11 4
mul r11 r10
add r1 r11
div r1 1000
localget r8 8
mul r8 2
add r8 1001
meshvertex r8 r0 r1 r2
localget r8 8
add r8 1
localset 8 r8
cmp r8 81
jlt transform_track
localset 8 0
label road_segment
localget r9 8
mul r9 2
add r9 1000
meshread r0 r1 r2 r9
add r9 2
meshread r3 r4 r5 r9
cmp r2 -2000
jge road_front
cmp r5 -2000
jlt next_segment
label road_front
cmp r2 45000
jle road_near
cmp r5 45000
jgt next_segment
label road_near
mov r6 r0
mov r7 r3
cmp r0 0
jge road_a_abs
mul r0 -1
label road_a_abs
mov r4 r2
mul r4 2
add r4 5000
cmp r0 r4
jle road_visible
cmp r3 0
jge road_b_abs
mul r3 -1
label road_b_abs
mov r4 r5
mul r4 2
add r4 5000
cmp r3 r4
jle road_visible
mul r6 r7
cmp r6 0
jge next_segment
label road_visible
localset 9 0
label road_band
localget r0 9
cmp r0 0
jne band_0_skip
set r0 -1000
set r1 -670
set r2 0
set r3 0
localset 28 78
jmp band_ready
label band_0_skip
localget r0 9
cmp r0 1
jne band_1_skip
set r0 -670
set r1 -600
set r2 0
set r3 0
localset 28 208
jmp band_ready
label band_1_skip
localget r0 9
cmp r0 2
jne band_2_skip
set r0 -600
set r1 600
set r2 0
set r3 0
localset 28 108
jmp band_ready
label band_2_skip
localget r0 9
cmp r0 3
jne band_3_skip
set r0 600
set r1 670
set r2 0
set r3 0
localset 28 208
jmp band_ready
label band_3_skip
localget r0 9
cmp r0 4
jne band_4_skip
set r0 670
set r1 1000
set r2 0
set r3 0
localset 28 78
jmp band_ready
label band_4_skip
localget r0 9
cmp r0 5
jne band_5_skip
set r0 -590
set r1 -580
set r2 1
set r3 1
localset 28 206
jmp band_ready
label band_5_skip
localget r0 9
cmp r0 6
jne band_6_skip
set r0 580
set r1 590
set r2 1
set r3 1
localset 28 206
jmp band_ready
label band_6_skip
localget r0 9
cmp r0 7
jne band_7_skip
set r0 -205
set r1 -195
set r2 2
set r3 2
localset 28 206
jmp band_ready
label band_7_skip
localget r0 9
cmp r0 8
jne band_8_skip
set r0 195
set r1 205
set r2 2
set r3 2
localset 28 206
jmp band_ready
label band_8_skip
localget r0 9
cmp r0 9
jne band_9_skip
set r0 -1000
set r1 -1000
set r2 0
set r3 100
localset 28 204
jmp band_ready
label band_9_skip
localget r0 9
cmp r0 10
jne band_10_skip
set r0 1000
set r1 1000
set r2 0
set r3 100
localset 28 204
jmp band_ready
label band_10_skip
jmp next_segment
label band_ready
mov r9 r0
add r9 32768
localset 22 r9
mov r9 r1
add r9 32768
localset 24 r9
mov r9 r2
localset 26 r9
mov r9 r3
localset 30 r9
localget r0 9
cmp r0 7
jlt stripe_ready
cmp r0 8
jgt stripe_ready
localget r0 8
mod r0 2
cmp r0 0
je next_band
label stripe_ready
localget r0 9
cmp r0 1
je curb_color
cmp r0 3
jne curb_ready
label curb_color
localget r0 8
mod r0 2
cmp r0 0
jne curb_ready
localset 28 206
label curb_ready
localget r9 8
add r9 0
mul r9 2
add r9 1000
meshread r0 r1 r2 r9
add r9 1
meshread r9 r10 r11 r9
localget r12 22
sub r12 32768
mul r9 r12
div r9 16384
add r0 r9
mul r10 r12
div r10 16384
add r1 r10
mul r11 r12
div r11 16384
add r2 r11
localget r9 26
localget r10 6
mul r10 r9
div r10 1000
add r1 r10
localget r10 4
mul r10 r9
div r10 1000
sub r2 r10
localget r9 8
add r9 1
mul r9 2
add r9 1000
meshread r3 r4 r5 r9
add r9 1
meshread r9 r10 r11 r9
localget r12 22
sub r12 32768
mul r9 r12
div r9 16384
add r3 r9
mul r10 r12
div r10 16384
add r4 r10
mul r11 r12
div r11 16384
add r5 r11
localget r9 26
localget r10 6
mul r10 r9
div r10 1000
add r4 r10
localget r10 4
mul r10 r9
div r10 1000
sub r5 r10
localget r9 8
add r9 1
mul r9 2
add r9 1000
meshread r6 r7 r8 r9
add r9 1
meshread r9 r10 r11 r9
localget r12 24
sub r12 32768
mul r9 r12
div r9 16384
add r6 r9
mul r10 r12
div r10 16384
add r7 r10
mul r11 r12
div r11 16384
add r8 r11
localget r9 30
localget r10 6
mul r10 r9
div r10 1000
add r7 r10
localget r10 4
mul r10 r9
div r10 1000
sub r8 r10
localget r9 18
mov r10 r9
div r10 2
mov r11 r10
mul r11 9
div r11 16
mul r9 85
div r9 100
localget r9 28
cmp r9 78
jne material_skip_9
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 78 r9 r10 r11 60
jmp triangle_emitted_8
label material_skip_9
cmp r9 208
jne material_skip_10
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 208 r9 r10 r11 60
jmp triangle_emitted_8
label material_skip_10
cmp r9 108
jne material_skip_11
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 108 r9 r10 r11 60
jmp triangle_emitted_8
label material_skip_11
cmp r9 206
jne material_skip_12
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 206 r9 r10 r11 60
jmp triangle_emitted_8
label material_skip_12
cmp r9 204
jne material_skip_13
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 204 r9 r10 r11 60
jmp triangle_emitted_8
label material_skip_13
label triangle_emitted_8
localget r9 8
add r9 0
mul r9 2
add r9 1000
meshread r0 r1 r2 r9
add r9 1
meshread r9 r10 r11 r9
localget r12 22
sub r12 32768
mul r9 r12
div r9 16384
add r0 r9
mul r10 r12
div r10 16384
add r1 r10
mul r11 r12
div r11 16384
add r2 r11
localget r9 26
localget r10 6
mul r10 r9
div r10 1000
add r1 r10
localget r10 4
mul r10 r9
div r10 1000
sub r2 r10
localget r9 8
add r9 1
mul r9 2
add r9 1000
meshread r3 r4 r5 r9
add r9 1
meshread r9 r10 r11 r9
localget r12 24
sub r12 32768
mul r9 r12
div r9 16384
add r3 r9
mul r10 r12
div r10 16384
add r4 r10
mul r11 r12
div r11 16384
add r5 r11
localget r9 30
localget r10 6
mul r10 r9
div r10 1000
add r4 r10
localget r10 4
mul r10 r9
div r10 1000
sub r5 r10
localget r9 8
add r9 0
mul r9 2
add r9 1000
meshread r6 r7 r8 r9
add r9 1
meshread r9 r10 r11 r9
localget r12 24
sub r12 32768
mul r9 r12
div r9 16384
add r6 r9
mul r10 r12
div r10 16384
add r7 r10
mul r11 r12
div r11 16384
add r8 r11
localget r9 30
localget r10 6
mul r10 r9
div r10 1000
add r7 r10
localget r10 4
mul r10 r9
div r10 1000
sub r8 r10
localget r9 18
mov r10 r9
div r10 2
mov r11 r10
mul r11 9
div r11 16
mul r9 85
div r9 100
localget r9 28
cmp r9 78
jne material_skip_15
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 78 r9 r10 r11 60
jmp triangle_emitted_14
label material_skip_15
cmp r9 208
jne material_skip_16
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 208 r9 r10 r11 60
jmp triangle_emitted_14
label material_skip_16
cmp r9 108
jne material_skip_17
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 108 r9 r10 r11 60
jmp triangle_emitted_14
label material_skip_17
cmp r9 206
jne material_skip_18
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 206 r9 r10 r11 60
jmp triangle_emitted_14
label material_skip_18
cmp r9 204
jne material_skip_19
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 204 r9 r10 r11 60
jmp triangle_emitted_14
label material_skip_19
label triangle_emitted_14
label next_band
localget r0 9
add r0 1
localset 9 r0
cmp r0 11
jlt road_band
label next_segment
localget r0 8
add r0 1
localset 8 r0
cmp r0 80
jlt road_segment
load32 r12 100
sub r12 2000000
# XI-authored local meshes live only in the generic ephemeral vertex buffer.
meshvertex 0 -125 3 -245
meshvertex 1 125 3 -245
meshvertex 2 115 3 240
meshvertex 3 -115 3 240
meshvertex 4 -94 24 -212
meshvertex 5 94 24 -212
meshvertex 6 94 62 -212
meshvertex 7 -94 62 -212
meshvertex 8 94 24 207
meshvertex 9 94 62 207
meshvertex 10 -94 24 207
meshvertex 11 -94 62 207
meshvertex 12 98 73 -195
meshvertex 13 -98 73 -195
meshvertex 14 88 81 190
meshvertex 15 -88 81 190
meshvertex 16 87 91 -75
meshvertex 17 -87 91 -75
meshvertex 18 82 91 45
meshvertex 19 -82 91 45
meshvertex 20 -85 91 -115
meshvertex 21 85 91 -115
meshvertex 22 61 136 -75
meshvertex 23 -61 136 -75
meshvertex 24 82 91 86
meshvertex 25 -82 91 86
meshvertex 26 -57 128 46
meshvertex 27 57 128 46
meshvertex 28 -75 75 -200
meshvertex 29 -65 75 -200
meshvertex 30 -65 110 -200
meshvertex 31 -75 110 -200
meshvertex 32 -65 75 -190
meshvertex 33 -65 110 -190
meshvertex 34 -75 75 -190
meshvertex 35 -75 110 -190
meshvertex 36 65 75 -200
meshvertex 37 75 75 -200
meshvertex 38 75 110 -200
meshvertex 39 65 110 -200
meshvertex 40 75 75 -190
meshvertex 41 75 110 -190
meshvertex 42 65 75 -190
meshvertex 43 65 110 -190
meshvertex 44 -112 108 -225
meshvertex 45 112 108 -225
meshvertex 46 112 117 -225
meshvertex 47 -112 117 -225
meshvertex 48 112 108 -195
meshvertex 49 112 117 -195
meshvertex 50 -112 108 -195
meshvertex 51 -112 117 -195
meshvertex 52 -80 27 -214
meshvertex 53 80 27 -214
meshvertex 54 72 57 -214
meshvertex 55 -72 57 -214
meshvertex 56 -82 65 -214
meshvertex 57 -25 65 -214
meshvertex 58 -25 78 -214
meshvertex 59 -82 78 -214
meshvertex 60 25 65 -214
meshvertex 61 82 65 -214
meshvertex 62 82 78 -214
meshvertex 63 25 78 -214
meshvertex 64 -19 38 -215
meshvertex 65 19 38 -215
meshvertex 66 19 54 -215
meshvertex 67 -19 54 -215
meshvertex 68 -72 31 -216
meshvertex 69 -49 31 -216
meshvertex 70 -49 43 -216
meshvertex 71 -72 43 -216
meshvertex 72 49 31 -216
meshvertex 73 72 31 -216
meshvertex 74 72 43 -216
meshvertex 75 49 43 -216
meshvertex 76 -76 71 208
meshvertex 77 -39 71 208
meshvertex 78 -39 81 198
meshvertex 79 -76 81 198
meshvertex 80 39 71 208
meshvertex 81 76 71 208
meshvertex 82 76 81 198
meshvertex 83 39 81 198
meshvertex 84 -82 36 -111
meshvertex 85 -105 36 -111
meshvertex 86 -105 59 -121
meshvertex 87 -82 59 -121
meshvertex 88 -105 36 -144
meshvertex 89 -106 36 -144
meshvertex 90 -106 36 -127
meshvertex 91 -106 48 -132
meshvertex 92 -105 69 -144
meshvertex 93 -82 69 -144
meshvertex 94 -106 53 -144
meshvertex 95 -105 59 -167
meshvertex 96 -82 59 -167
meshvertex 97 -106 48 -156
meshvertex 98 -105 36 -177
meshvertex 99 -82 36 -177
meshvertex 100 -106 36 -161
meshvertex 101 -105 13 -167
meshvertex 102 -82 13 -167
meshvertex 103 -106 24 -156
meshvertex 104 -105 3 -144
meshvertex 105 -82 3 -144
meshvertex 106 -106 19 -144
meshvertex 107 -105 13 -121
meshvertex 108 -82 13 -121
meshvertex 109 -106 24 -132
meshvertex 110 -82 36 175
meshvertex 111 -105 36 175
meshvertex 112 -105 59 165
meshvertex 113 -82 59 165
meshvertex 114 -105 36 142
meshvertex 115 -106 36 142
meshvertex 116 -106 36 159
meshvertex 117 -106 48 154
meshvertex 118 -105 69 142
meshvertex 119 -82 69 142
meshvertex 120 -106 53 142
meshvertex 121 -105 59 119
meshvertex 122 -82 59 119
meshvertex 123 -106 48 130
meshvertex 124 -105 36 109
meshvertex 125 -82 36 109
meshvertex 126 -106 36 125
meshvertex 127 -105 13 119
meshvertex 128 -82 13 119
meshvertex 129 -106 24 130
meshvertex 130 -105 3 142
meshvertex 131 -82 3 142
meshvertex 132 -106 19 142
meshvertex 133 -105 13 165
meshvertex 134 -82 13 165
meshvertex 135 -106 24 154
meshvertex 136 82 36 -111
meshvertex 137 105 36 -111
meshvertex 138 105 59 -121
meshvertex 139 82 59 -121
meshvertex 140 105 36 -144
meshvertex 141 106 36 -144
meshvertex 142 106 36 -127
meshvertex 143 106 48 -132
meshvertex 144 105 69 -144
meshvertex 145 82 69 -144
meshvertex 146 106 53 -144
meshvertex 147 105 59 -167
meshvertex 148 82 59 -167
meshvertex 149 106 48 -156
meshvertex 150 105 36 -177
meshvertex 151 82 36 -177
meshvertex 152 106 36 -161
meshvertex 153 105 13 -167
meshvertex 154 82 13 -167
meshvertex 155 106 24 -156
meshvertex 156 105 3 -144
meshvertex 157 82 3 -144
meshvertex 158 106 19 -144
meshvertex 159 105 13 -121
meshvertex 160 82 13 -121
meshvertex 161 106 24 -132
meshvertex 162 82 36 175
meshvertex 163 105 36 175
meshvertex 164 105 59 165
meshvertex 165 82 59 165
meshvertex 166 105 36 142
meshvertex 167 106 36 142
meshvertex 168 106 36 159
meshvertex 169 106 48 154
meshvertex 170 105 69 142
meshvertex 171 82 69 142
meshvertex 172 106 53 142
meshvertex 173 105 59 119
meshvertex 174 82 59 119
meshvertex 175 106 48 130
meshvertex 176 105 36 109
meshvertex 177 82 36 109
meshvertex 178 106 36 125
meshvertex 179 105 13 119
meshvertex 180 82 13 119
meshvertex 181 106 24 130
meshvertex 182 105 3 142
meshvertex 183 82 3 142
meshvertex 184 106 19 142
meshvertex 185 105 13 165
meshvertex 186 82 13 165
meshvertex 187 106 24 154
meshvertex 188 -20 0 -20
meshvertex 189 20 0 -20
meshvertex 190 20 280 -20
meshvertex 191 -20 280 -20
meshvertex 192 20 0 20
meshvertex 193 20 280 20
meshvertex 194 -20 0 20
meshvertex 195 -20 280 20
meshvertex 196 215 200 0
meshvertex 197 0 650 0
meshvertex 198 152 200 152
meshvertex 199 0 200 215
meshvertex 200 -152 200 152
meshvertex 201 -215 200 0
meshvertex 202 -152 200 -152
meshvertex 203 0 200 -215
meshvertex 204 152 200 -152
meshvertex 205 155 410 0
meshvertex 206 0 820 0
meshvertex 207 110 410 110
meshvertex 208 0 410 155
meshvertex 209 -110 410 110
meshvertex 210 -155 410 0
meshvertex 211 -110 410 -110
meshvertex 212 0 410 -155
meshvertex 213 110 410 -110
localset 11 0
label actor
localset 142 0
localget r0 11
cmp r0 4
jge tree_actor
set r0 0
mov r9 r0
localset 132 r9
set r0 188
mov r9 r0
localset 134 r9
localget r0 11
cmp r0 0
jne rival_actor
load8 r1 201
cmp r1 2
jne player_mesh_ready
localset 142 1
label player_mesh_ready
load32 r0 100
sub r0 2000000
load32 r2 104
sub r2 2000000
load16 r8 108
load8 r9 202
mul r9 6
localset 126 r9
jmp actor_ready
label rival_actor
localget r7 11
sub r7 1
mul r7 32
add r7 6004
load32 r0 $r7
sub r0 65536
add r7 4
load32 r2 $r7
sub r2 65536
add r7 4
load16 r8 $r7
localget r9 11
mul r9 6
localset 126 r9
jmp actor_ready
label tree_actor
set r0 188
mov r9 r0
localset 132 r9
set r0 214
mov r9 r0
localset 134 r9
localget r8 11
sub r8 4
div r8 2
mul r8 4
mov r7 r8
mul r7 2
add r7 5000
load16 r6 $r7
mov r3 r6
add r3 0
mod r3 4096
cmp r3 0
jge sin_negative_20
add r3 4096
label sin_negative_20
mov r1 r3
mod r1 2048
set r2 2048
sub r2 r1
mul r1 r2
mov r2 r1
mul r2 4
set r4 20971520
sub r4 r2
mul r1 262144
div r1 r4
cmp r3 2048
jlt sin_done_21
mul r1 -1
label sin_done_21
mov r3 r1
mov r2 r3
mov r9 r2
add r9 32768
localset 58 r9
mov r4 r6
add r4 1024
mod r4 4096
cmp r4 0
jge sin_negative_22
add r4 4096
label sin_negative_22
mov r1 r4
mod r1 2048
set r2 2048
sub r2 r1
mul r1 r2
mov r2 r1
mul r2 4
set r3 20971520
sub r3 r2
mul r1 262144
div r1 r3
cmp r4 2048
jlt sin_done_23
mul r1 -1
label sin_done_23
mov r4 r1
localget r3 58
sub r3 32768
localget r0 11
mod r0 2
mul r0 2
sub r0 1
mul r0 1650
mul r4 r0
div r4 16384
mul r3 r0
div r3 16384
mul r8 8
add r8 4096
load32 r0 $r8
sub r0 65536
add r0 r4
add r8 4
load32 r2 $r8
sub r2 65536
sub r2 r3
set r8 0
label actor_ready
mov r3 r8
add r3 0
mod r3 4096
cmp r3 0
jge sin_negative_24
add r3 4096
label sin_negative_24
mov r5 r3
mod r5 2048
set r6 2048
sub r6 r5
mul r5 r6
mov r6 r5
mul r6 4
set r4 20971520
sub r4 r6
mul r5 262144
div r5 r4
cmp r3 2048
jlt sin_done_25
mul r5 -1
label sin_done_25
mov r3 r5
mov r6 r3
mov r9 r6
add r9 32768
localset 58 r9
mov r4 r8
add r4 1024
mod r4 4096
cmp r4 0
jge sin_negative_26
add r4 4096
label sin_negative_26
mov r5 r4
mod r5 2048
set r6 2048
sub r6 r5
mul r5 r6
mov r6 r5
mul r6 4
set r3 20971520
sub r3 r6
mul r5 262144
div r5 r3
cmp r4 2048
jlt sin_done_27
mul r5 -1
label sin_done_27
mov r4 r5
localget r3 58
sub r3 32768
mov r1 r3
mul r1 r15
mov r5 r4
mul r5 r14
sub r1 r5
div r1 16384
mov r5 r3
mul r5 r14
mul r4 r15
add r5 r4
div r5 16384
mov r9 r1
add r9 32768
localset 116 r9
mov r9 r5
add r9 32768
localset 118 r9
sub r0 r12
sub r2 r13
mov r1 r0
mul r1 r15
mov r3 r2
mul r3 r14
sub r1 r3
div r1 16384
mul r0 r14
mul r2 r15
add r0 r2
div r0 16384
mov r9 r1
add r9 1000000
localset 108 r9
mov r9 r0
add r9 1000000
localset 112 r9
cmp r0 -1200
jlt next_actor
cmp r0 35000
jgt next_actor
mov r2 r0
mul r2 2
add r2 3500
localget r1 108
sub r1 1000000
cmp r1 0
jge actor_side_absolute
mul r1 -1
label actor_side_absolute
cmp r1 r2
jgt next_actor
localget r1 11
cmp r1 0
je actor_lod_ready
cmp r1 4
jge actor_lod_ready
cmp r0 6500
jle actor_lod_ready
localset 142 2
label actor_lod_ready
label actor_vertex
localget r8 132
meshread r0 r1 r2 r8
localget r9 118
sub r9 32768
mul r9 r0
localget r10 116
sub r10 32768
mul r10 r2
add r9 r10
div r9 16384
mov r10 r9
add r10 1000000
localset 128 r10
localget r9 118
sub r9 32768
mul r9 r2
localget r10 116
sub r10 32768
mul r10 r0
sub r9 r10
div r9 16384
localget r10 112
sub r10 1000000
add r10 r9
localget r0 128
sub r0 1000000
localget r11 108
sub r11 1000000
add r0 r11
localget r11 0
add r10 r11
localget r11 2
sub r1 r11
localget r11 4
mul r11 r1
localget r9 6
mov r2 r10
mul r2 r9
sub r2 r11
div r2 1000
mul r1 r9
localget r11 4
mul r11 r10
add r1 r11
div r1 1000
localget r8 132
add r8 256
meshvertex r8 r0 r1 r2
sub r8 255
mov r9 r8
localset 132 r9
localget r0 134
cmp r8 r0
jlt actor_vertex
localget r9 18
mov r10 r9
div r10 2
mov r11 r10
mul r11 9
div r11 16
mul r9 85
div r9 100
localget r12 11
cmp r12 4
jge emit_tree
localget r12 142
cmp r12 1
je emit_hood
meshface 256 257 258 210 r9 r10 r11 60
meshface 256 258 259 210 r9 r10 r11 60
localget r12 126
add r12 128
meshface 260 261 262 r12 r9 r10 r11 60
localget r12 126
add r12 128
meshface 260 262 263 r12 r9 r10 r11 60
localget r12 126
add r12 129
meshface 261 264 265 r12 r9 r10 r11 60
localget r12 126
add r12 129
meshface 261 265 262 r12 r9 r10 r11 60
localget r12 126
add r12 128
meshface 264 266 267 r12 r9 r10 r11 60
localget r12 126
add r12 128
meshface 264 267 265 r12 r9 r10 r11 60
localget r12 126
add r12 130
meshface 266 260 263 r12 r9 r10 r11 60
localget r12 126
add r12 130
meshface 266 263 267 r12 r9 r10 r11 60
localget r12 126
add r12 131
meshface 263 262 265 r12 r9 r10 r11 60
localget r12 126
add r12 131
meshface 263 265 267 r12 r9 r10 r11 60
localget r12 126
add r12 129
meshface 263 262 268 r12 r9 r10 r11 60
localget r12 126
add r12 129
meshface 263 268 269 r12 r9 r10 r11 60
localget r12 126
add r12 128
meshface 262 265 270 r12 r9 r10 r11 60
localget r12 126
add r12 128
meshface 262 270 268 r12 r9 r10 r11 60
localget r12 126
add r12 130
meshface 267 263 269 r12 r9 r10 r11 60
localget r12 126
add r12 130
meshface 267 269 271 r12 r9 r10 r11 60
label emit_hood
localget r12 126
add r12 132
meshface 265 267 271 r12 r9 r10 r11 60
localget r12 126
add r12 132
meshface 265 271 270 r12 r9 r10 r11 60
localget r12 126
add r12 132
meshface 269 268 272 r12 r9 r10 r11 60
localget r12 126
add r12 132
meshface 269 272 273 r12 r9 r10 r11 60
localget r12 126
add r12 132
meshface 273 272 274 r12 r9 r10 r11 60
localget r12 126
add r12 132
meshface 273 274 275 r12 r9 r10 r11 60
localget r12 126
add r12 133
meshface 275 274 270 r12 r9 r10 r11 60
localget r12 126
add r12 133
meshface 275 270 271 r12 r9 r10 r11 60
localget r12 142
cmp r12 1
je next_actor
meshface 276 277 278 160 r9 r10 r11 60
meshface 276 278 279 160 r9 r10 r11 60
meshface 280 281 282 164 r9 r10 r11 60
meshface 280 282 283 164 r9 r10 r11 60
meshface 276 279 282 158 r9 r10 r11 60
meshface 276 282 281 158 r9 r10 r11 60
meshface 278 277 280 162 r9 r10 r11 60
meshface 278 280 283 162 r9 r10 r11 60
localget r12 126
add r12 133
meshface 279 278 283 r12 r9 r10 r11 60
localget r12 126
add r12 133
meshface 279 283 282 r12 r9 r10 r11 60
meshface 284 285 286 245 r9 r10 r11 60
meshface 284 286 287 245 r9 r10 r11 60
meshface 285 288 289 246 r9 r10 r11 60
meshface 285 289 286 246 r9 r10 r11 60
meshface 288 290 291 245 r9 r10 r11 60
meshface 288 291 289 245 r9 r10 r11 60
meshface 290 284 287 247 r9 r10 r11 60
meshface 290 287 291 247 r9 r10 r11 60
meshface 287 286 289 248 r9 r10 r11 60
meshface 287 289 291 248 r9 r10 r11 60
meshface 292 293 294 245 r9 r10 r11 60
meshface 292 294 295 245 r9 r10 r11 60
meshface 293 296 297 246 r9 r10 r11 60
meshface 293 297 294 246 r9 r10 r11 60
meshface 296 298 299 245 r9 r10 r11 60
meshface 296 299 297 245 r9 r10 r11 60
meshface 298 292 295 247 r9 r10 r11 60
meshface 298 295 299 247 r9 r10 r11 60
meshface 295 294 297 248 r9 r10 r11 60
meshface 295 297 299 248 r9 r10 r11 60
localget r12 126
add r12 128
meshface 300 301 302 r12 r9 r10 r11 60
localget r12 126
add r12 128
meshface 300 302 303 r12 r9 r10 r11 60
localget r12 126
add r12 129
meshface 301 304 305 r12 r9 r10 r11 60
localget r12 126
add r12 129
meshface 301 305 302 r12 r9 r10 r11 60
localget r12 126
add r12 128
meshface 304 306 307 r12 r9 r10 r11 60
localget r12 126
add r12 128
meshface 304 307 305 r12 r9 r10 r11 60
localget r12 126
add r12 130
meshface 306 300 303 r12 r9 r10 r11 60
localget r12 126
add r12 130
meshface 306 303 307 r12 r9 r10 r11 60
localget r12 126
add r12 131
meshface 303 302 305 r12 r9 r10 r11 60
localget r12 126
add r12 131
meshface 303 305 307 r12 r9 r10 r11 60
meshface 308 309 310 209 r9 r10 r11 60
meshface 308 310 311 209 r9 r10 r11 60
meshface 312 313 314 213 r9 r10 r11 60
meshface 312 314 315 213 r9 r10 r11 60
meshface 316 317 318 213 r9 r10 r11 60
meshface 316 318 319 213 r9 r10 r11 60
meshface 320 321 322 211 r9 r10 r11 60
meshface 320 322 323 211 r9 r10 r11 60
meshface 324 325 326 211 r9 r10 r11 60
meshface 324 326 327 211 r9 r10 r11 60
meshface 328 329 330 211 r9 r10 r11 60
meshface 328 330 331 211 r9 r10 r11 60
meshface 332 333 334 212 r9 r10 r11 60
meshface 332 334 335 212 r9 r10 r11 60
meshface 336 337 338 212 r9 r10 r11 60
meshface 336 338 339 212 r9 r10 r11 60
localget r12 142
cmp r12 2
je next_actor
meshface 340 341 342 209 r9 r10 r11 60
meshface 340 342 343 209 r9 r10 r11 60
meshface 344 341 342 245 r9 r10 r11 60
meshface 345 346 347 211 r9 r10 r11 60
meshface 343 342 348 209 r9 r10 r11 60
meshface 343 348 349 209 r9 r10 r11 60
meshface 344 342 348 245 r9 r10 r11 60
meshface 345 347 350 211 r9 r10 r11 60
meshface 349 348 351 209 r9 r10 r11 60
meshface 349 351 352 209 r9 r10 r11 60
meshface 344 348 351 245 r9 r10 r11 60
meshface 345 350 353 211 r9 r10 r11 60
meshface 352 351 354 209 r9 r10 r11 60
meshface 352 354 355 209 r9 r10 r11 60
meshface 344 351 354 245 r9 r10 r11 60
meshface 345 353 356 211 r9 r10 r11 60
meshface 355 354 357 209 r9 r10 r11 60
meshface 355 357 358 209 r9 r10 r11 60
meshface 344 354 357 245 r9 r10 r11 60
meshface 345 356 359 211 r9 r10 r11 60
meshface 358 357 360 209 r9 r10 r11 60
meshface 358 360 361 209 r9 r10 r11 60
meshface 344 357 360 245 r9 r10 r11 60
meshface 345 359 362 211 r9 r10 r11 60
meshface 361 360 363 209 r9 r10 r11 60
meshface 361 363 364 209 r9 r10 r11 60
meshface 344 360 363 245 r9 r10 r11 60
meshface 345 362 365 211 r9 r10 r11 60
meshface 364 363 341 209 r9 r10 r11 60
meshface 364 341 340 209 r9 r10 r11 60
meshface 344 363 341 245 r9 r10 r11 60
meshface 345 365 346 211 r9 r10 r11 60
meshface 366 367 368 209 r9 r10 r11 60
meshface 366 368 369 209 r9 r10 r11 60
meshface 370 367 368 245 r9 r10 r11 60
meshface 371 372 373 211 r9 r10 r11 60
meshface 369 368 374 209 r9 r10 r11 60
meshface 369 374 375 209 r9 r10 r11 60
meshface 370 368 374 245 r9 r10 r11 60
meshface 371 373 376 211 r9 r10 r11 60
meshface 375 374 377 209 r9 r10 r11 60
meshface 375 377 378 209 r9 r10 r11 60
meshface 370 374 377 245 r9 r10 r11 60
meshface 371 376 379 211 r9 r10 r11 60
meshface 378 377 380 209 r9 r10 r11 60
meshface 378 380 381 209 r9 r10 r11 60
meshface 370 377 380 245 r9 r10 r11 60
meshface 371 379 382 211 r9 r10 r11 60
meshface 381 380 383 209 r9 r10 r11 60
meshface 381 383 384 209 r9 r10 r11 60
meshface 370 380 383 245 r9 r10 r11 60
meshface 371 382 385 211 r9 r10 r11 60
meshface 384 383 386 209 r9 r10 r11 60
meshface 384 386 387 209 r9 r10 r11 60
meshface 370 383 386 245 r9 r10 r11 60
meshface 371 385 388 211 r9 r10 r11 60
meshface 387 386 389 209 r9 r10 r11 60
meshface 387 389 390 209 r9 r10 r11 60
meshface 370 386 389 245 r9 r10 r11 60
meshface 371 388 391 211 r9 r10 r11 60
meshface 390 389 367 209 r9 r10 r11 60
meshface 390 367 366 209 r9 r10 r11 60
meshface 370 389 367 245 r9 r10 r11 60
meshface 371 391 372 211 r9 r10 r11 60
meshface 392 393 394 209 r9 r10 r11 60
meshface 392 394 395 209 r9 r10 r11 60
meshface 396 393 394 245 r9 r10 r11 60
meshface 397 398 399 211 r9 r10 r11 60
meshface 395 394 400 209 r9 r10 r11 60
meshface 395 400 401 209 r9 r10 r11 60
meshface 396 394 400 245 r9 r10 r11 60
meshface 397 399 402 211 r9 r10 r11 60
meshface 401 400 403 209 r9 r10 r11 60
meshface 401 403 404 209 r9 r10 r11 60
meshface 396 400 403 245 r9 r10 r11 60
meshface 397 402 405 211 r9 r10 r11 60
meshface 404 403 406 209 r9 r10 r11 60
meshface 404 406 407 209 r9 r10 r11 60
meshface 396 403 406 245 r9 r10 r11 60
meshface 397 405 408 211 r9 r10 r11 60
meshface 407 406 409 209 r9 r10 r11 60
meshface 407 409 410 209 r9 r10 r11 60
meshface 396 406 409 245 r9 r10 r11 60
meshface 397 408 411 211 r9 r10 r11 60
meshface 410 409 412 209 r9 r10 r11 60
meshface 410 412 413 209 r9 r10 r11 60
meshface 396 409 412 245 r9 r10 r11 60
meshface 397 411 414 211 r9 r10 r11 60
meshface 413 412 415 209 r9 r10 r11 60
meshface 413 415 416 209 r9 r10 r11 60
meshface 396 412 415 245 r9 r10 r11 60
meshface 397 414 417 211 r9 r10 r11 60
meshface 416 415 393 209 r9 r10 r11 60
meshface 416 393 392 209 r9 r10 r11 60
meshface 396 415 393 245 r9 r10 r11 60
meshface 397 417 398 211 r9 r10 r11 60
meshface 418 419 420 209 r9 r10 r11 60
meshface 418 420 421 209 r9 r10 r11 60
meshface 422 419 420 245 r9 r10 r11 60
meshface 423 424 425 211 r9 r10 r11 60
meshface 421 420 426 209 r9 r10 r11 60
meshface 421 426 427 209 r9 r10 r11 60
meshface 422 420 426 245 r9 r10 r11 60
meshface 423 425 428 211 r9 r10 r11 60
meshface 427 426 429 209 r9 r10 r11 60
meshface 427 429 430 209 r9 r10 r11 60
meshface 422 426 429 245 r9 r10 r11 60
meshface 423 428 431 211 r9 r10 r11 60
meshface 430 429 432 209 r9 r10 r11 60
meshface 430 432 433 209 r9 r10 r11 60
meshface 422 429 432 245 r9 r10 r11 60
meshface 423 431 434 211 r9 r10 r11 60
meshface 433 432 435 209 r9 r10 r11 60
meshface 433 435 436 209 r9 r10 r11 60
meshface 422 432 435 245 r9 r10 r11 60
meshface 423 434 437 211 r9 r10 r11 60
meshface 436 435 438 209 r9 r10 r11 60
meshface 436 438 439 209 r9 r10 r11 60
meshface 422 435 438 245 r9 r10 r11 60
meshface 423 437 440 211 r9 r10 r11 60
meshface 439 438 441 209 r9 r10 r11 60
meshface 439 441 442 209 r9 r10 r11 60
meshface 422 438 441 245 r9 r10 r11 60
meshface 423 440 443 211 r9 r10 r11 60
meshface 442 441 419 209 r9 r10 r11 60
meshface 442 419 418 209 r9 r10 r11 60
meshface 422 441 419 245 r9 r10 r11 60
meshface 423 443 424 211 r9 r10 r11 60
jmp next_actor
label emit_tree
meshface 444 445 446 202 r9 r10 r11 60
meshface 444 446 447 202 r9 r10 r11 60
meshface 445 448 449 203 r9 r10 r11 60
meshface 445 449 446 203 r9 r10 r11 60
meshface 448 450 451 202 r9 r10 r11 60
meshface 448 451 449 202 r9 r10 r11 60
meshface 450 444 447 204 r9 r10 r11 60
meshface 450 447 451 204 r9 r10 r11 60
meshface 447 446 449 205 r9 r10 r11 60
meshface 447 449 451 205 r9 r10 r11 60
meshface 452 453 454 196 r9 r10 r11 60
meshface 454 453 455 197 r9 r10 r11 60
meshface 455 453 456 198 r9 r10 r11 60
meshface 456 453 457 196 r9 r10 r11 60
meshface 457 453 458 197 r9 r10 r11 60
meshface 458 453 459 198 r9 r10 r11 60
meshface 459 453 460 196 r9 r10 r11 60
meshface 460 453 452 197 r9 r10 r11 60
meshface 461 462 463 198 r9 r10 r11 60
meshface 463 462 464 199 r9 r10 r11 60
meshface 464 462 465 200 r9 r10 r11 60
meshface 465 462 466 198 r9 r10 r11 60
meshface 466 462 467 199 r9 r10 r11 60
meshface 467 462 468 200 r9 r10 r11 60
meshface 468 462 469 198 r9 r10 r11 60
meshface 469 462 461 199 r9 r10 r11 60
label next_actor
load32 r12 100
sub r12 2000000
localget r0 11
add r0 1
localset 11 r0
cmp r0 44
jlt actor
meshend
halt
