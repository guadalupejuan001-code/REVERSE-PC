#!reverse-pc-machine-v1
# REgraphics v4: curved vehicles, smooth XI lighting and bounded 3D raster.
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
meshbegin r0 r1 2 0
load8 r0 201
cmp r0 1
je camera_close
cmp r0 2
je camera_hood
set r0 750
set r1 250
set r2 160
set r3 987
jmp camera_ready
label camera_close
set r0 650
set r1 230
set r2 150
set r3 989
jmp camera_ready
label camera_hood
set r0 0
set r1 115
set r2 100
set r3 995
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
meshtri 0 0 999999 r0 0 999999 r0 r3 999999 0
meshtri 0 0 999999 r0 r3 999999 0 r3 999999 0
meshtri 0 r3 999999 r0 r3 999999 r0 r2 999999 1
meshtri 0 r3 999999 r0 r2 999999 0 r2 999999 1
meshtri 0 r2 999998 r0 r2 999998 r0 r1 999998 2
meshtri 0 r2 999998 r0 r1 999998 0 r1 999998 2
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
meshtri r1 r3 999990 r4 r5 999990 r2 r3 999990 3
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
add r8 1600
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
add r8 1601
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
add r9 1600
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
add r9 1600
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
add r9 1600
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
add r9 1600
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
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 4 r9 r10 r11 60
jmp triangle_emitted_8
label material_skip_9
cmp r9 208
jne material_skip_10
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 5 r9 r10 r11 60
jmp triangle_emitted_8
label material_skip_10
cmp r9 108
jne material_skip_11
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 6 r9 r10 r11 60
jmp triangle_emitted_8
label material_skip_11
cmp r9 206
jne material_skip_12
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 7 r9 r10 r11 60
jmp triangle_emitted_8
label material_skip_12
cmp r9 204
jne material_skip_13
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 8 r9 r10 r11 60
jmp triangle_emitted_8
label material_skip_13
label triangle_emitted_8
localget r9 8
add r9 0
mul r9 2
add r9 1600
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
add r9 1600
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
add r9 1600
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
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 4 r9 r10 r11 60
jmp triangle_emitted_14
label material_skip_15
cmp r9 208
jne material_skip_16
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 5 r9 r10 r11 60
jmp triangle_emitted_14
label material_skip_16
cmp r9 108
jne material_skip_17
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 6 r9 r10 r11 60
jmp triangle_emitted_14
label material_skip_17
cmp r9 206
jne material_skip_18
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 7 r9 r10 r11 60
jmp triangle_emitted_14
label material_skip_18
cmp r9 204
jne material_skip_19
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 8 r9 r10 r11 60
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
# Original detailed car meshes; all world transforms and lighting execute in XI.
meshvertex 0 -85 72 -223
meshvertex 1 -89 80 -213
meshvertex 2 -73 83 -213
meshvertex 4 -70 74 -223
meshvertex 5 -40 82 -213
meshvertex 7 -38 71 -223
meshvertex 8 0 80 -213
meshvertex 9 0 69 -223
meshvertex 10 40 82 -213
meshvertex 11 38 71 -223
meshvertex 12 73 83 -213
meshvertex 13 70 74 -223
meshvertex 14 89 80 -213
meshvertex 15 85 72 -223
meshvertex 16 -89 22 -213
meshvertex 18 -85 22 -223
meshvertex 20 89 22 -213
meshvertex 21 85 22 -223
meshvertex 23 -91 77 -207
meshvertex 24 -75 81 -207
meshvertex 25 -41 78 -207
meshvertex 28 0 76 -207
meshvertex 31 41 78 -207
meshvertex 33 75 81 -207
meshvertex 35 91 77 -207
meshvertex 37 -91 22 -207
meshvertex 40 91 22 -207
meshvertex 42 -95 79 -181
meshvertex 43 -78 86 -181
meshvertex 44 -43 80 -181
meshvertex 45 0 78 -181
meshvertex 46 43 80 -181
meshvertex 47 78 86 -181
meshvertex 48 95 79 -181
meshvertex 51 -95 34 -181
meshvertex 52 95 34 -181
meshvertex 53 -95 79 -175
meshvertex 54 -78 87 -175
meshvertex 55 -43 80 -175
meshvertex 56 0 78 -175
meshvertex 57 43 80 -175
meshvertex 58 78 87 -175
meshvertex 59 95 79 -175
meshvertex 60 -95 55 -175
meshvertex 62 95 55 -175
meshvertex 63 -96 80 -161
meshvertex 64 -79 88 -161
meshvertex 65 -43 80 -161
meshvertex 66 0 78 -161
meshvertex 67 43 80 -161
meshvertex 68 79 88 -161
meshvertex 69 96 80 -161
meshvertex 70 -96 68 -161
meshvertex 71 96 68 -161
meshvertex 72 -97 80 -142
meshvertex 73 -80 90 -142
meshvertex 74 -44 80 -142
meshvertex 75 0 78 -142
meshvertex 76 44 80 -142
meshvertex 77 80 90 -142
meshvertex 78 97 80 -142
meshvertex 79 -97 73 -142
meshvertex 80 97 73 -142
meshvertex 81 -95 79 -123
meshvertex 82 -78 87 -123
meshvertex 83 -43 80 -123
meshvertex 84 0 78 -123
meshvertex 85 43 80 -123
meshvertex 86 78 87 -123
meshvertex 87 95 79 -123
meshvertex 88 -95 68 -123
meshvertex 89 95 68 -123
meshvertex 90 -93 77 -109
meshvertex 91 -76 85 -109
meshvertex 92 -42 79 -109
meshvertex 93 0 77 -109
meshvertex 94 42 79 -109
meshvertex 95 76 85 -109
meshvertex 96 93 77 -109
meshvertex 97 -93 55 -109
meshvertex 98 93 55 -109
meshvertex 99 -92 77 -103
meshvertex 100 -75 84 -103
meshvertex 101 -41 79 -103
meshvertex 102 0 77 -103
meshvertex 103 41 79 -103
meshvertex 104 75 84 -103
meshvertex 105 92 77 -103
meshvertex 106 -92 34 -103
meshvertex 107 92 34 -103
meshvertex 108 -87 75 -72
meshvertex 109 -71 80 -72
meshvertex 110 -39 78 -72
meshvertex 111 0 76 -72
meshvertex 112 39 78 -72
meshvertex 113 71 80 -72
meshvertex 114 87 75 -72
meshvertex 115 -87 22 -72
meshvertex 116 87 22 -72
meshvertex 117 -85 73 0
meshvertex 118 -70 78 0
meshvertex 119 -38 77 0
meshvertex 120 0 75 0
meshvertex 121 38 77 0
meshvertex 122 70 78 0
meshvertex 123 85 73 0
meshvertex 124 -85 22 0
meshvertex 125 85 22 0
meshvertex 126 -88 74 70
meshvertex 127 -72 80 70
meshvertex 128 -40 77 70
meshvertex 129 0 75 70
meshvertex 130 40 77 70
meshvertex 131 72 80 70
meshvertex 132 88 74 70
meshvertex 133 -88 22 70
meshvertex 134 88 22 70
meshvertex 135 -92 76 99
meshvertex 136 -75 83 99
meshvertex 137 -41 74 99
meshvertex 138 0 72 99
meshvertex 139 41 74 99
meshvertex 140 75 83 99
meshvertex 141 92 76 99
meshvertex 142 -92 34 99
meshvertex 143 92 34 99
meshvertex 144 -93 76 105
meshvertex 145 -76 83 105
meshvertex 146 -42 74 105
meshvertex 147 0 72 105
meshvertex 148 42 74 105
meshvertex 149 76 83 105
meshvertex 150 93 76 105
meshvertex 151 -93 55 105
meshvertex 152 93 55 105
meshvertex 153 -94 76 119
meshvertex 154 -77 84 119
meshvertex 155 -42 72 119
meshvertex 156 0 70 119
meshvertex 157 42 72 119
meshvertex 158 77 84 119
meshvertex 159 94 76 119
meshvertex 160 -94 68 119
meshvertex 161 94 68 119
meshvertex 162 -96 76 138
meshvertex 163 -79 85 138
meshvertex 164 -43 71 138
meshvertex 165 0 69 138
meshvertex 166 43 71 138
meshvertex 167 79 85 138
meshvertex 168 96 76 138
meshvertex 169 -96 73 138
meshvertex 170 96 73 138
meshvertex 171 -94 73 157
meshvertex 172 -77 81 157
meshvertex 173 -42 69 157
meshvertex 174 0 67 157
meshvertex 175 42 69 157
meshvertex 176 77 81 157
meshvertex 177 94 73 157
meshvertex 178 -94 68 157
meshvertex 179 94 68 157
meshvertex 180 -92 70 171
meshvertex 181 -75 78 171
meshvertex 182 -41 67 171
meshvertex 183 0 65 171
meshvertex 184 41 67 171
meshvertex 185 75 78 171
meshvertex 186 92 70 171
meshvertex 187 -92 55 171
meshvertex 188 92 55 171
meshvertex 189 -91 69 177
meshvertex 190 -75 77 177
meshvertex 191 -41 66 177
meshvertex 192 0 64 177
meshvertex 193 41 66 177
meshvertex 194 75 77 177
meshvertex 195 91 69 177
meshvertex 196 -91 34 177
meshvertex 197 91 34 177
meshvertex 198 -81 57 207
meshvertex 199 -66 63 207
meshvertex 200 -36 56 207
meshvertex 201 0 54 207
meshvertex 202 36 56 207
meshvertex 203 66 63 207
meshvertex 204 81 57 207
meshvertex 205 -81 22 207
meshvertex 206 81 22 207
meshvertex 207 -72 48 223
meshvertex 208 -59 53 223
meshvertex 209 -32 48 223
meshvertex 210 0 46 223
meshvertex 211 32 48 223
meshvertex 212 59 53 223
meshvertex 213 72 48 223
meshvertex 214 -72 22 223
meshvertex 215 72 22 223
meshvertex 216 0 32 -223
meshvertex 217 0 32 223
meshvertex 218 -71 18 -204
meshvertex 219 71 18 197
meshvertex 220 -71 18 197
meshvertex 221 71 18 -204
meshvertex 222 -54 73 -150
meshvertex 223 -58 98 -92
meshvertex 224 -29 101 -92
meshvertex 225 -27 75 -150
meshvertex 226 0 102 -92
meshvertex 227 0 75 -150
meshvertex 228 29 101 -92
meshvertex 229 27 75 -150
meshvertex 230 58 98 -92
meshvertex 231 54 73 -150
meshvertex 232 -60 106 -60
meshvertex 233 -30 111 -60
meshvertex 234 0 113 -60
meshvertex 235 30 111 -60
meshvertex 236 60 106 -60
meshvertex 237 -61 108 -15
meshvertex 238 -30 113 -15
meshvertex 239 0 115 -15
meshvertex 240 31 113 -15
meshvertex 241 61 108 -15
meshvertex 242 -57 105 30
meshvertex 243 -28 111 30
meshvertex 244 0 113 30
meshvertex 245 29 111 30
meshvertex 246 57 105 30
meshvertex 247 -54 101 48
meshvertex 248 -27 106 48
meshvertex 249 0 108 48
meshvertex 250 27 106 48
meshvertex 251 54 101 48
meshvertex 252 -69 73 108
meshvertex 253 -34 75 108
meshvertex 254 0 75 108
meshvertex 255 35 75 108
meshvertex 256 69 73 108
meshvertex 257 -78 79 -126
meshvertex 258 -55 101 48
meshvertex 259 -61 104 -61
meshvertex 260 -74 78 101
meshvertex 261 -81 77 -64
meshvertex 262 -80 77 -141
meshvertex 268 78 79 -126
meshvertex 269 61 104 -61
meshvertex 270 55 101 48
meshvertex 271 74 78 101
meshvertex 272 81 77 -64
meshvertex 273 80 77 -141
meshvertex 279 -76 34 -108
meshvertex 280 -97 47 -111
meshvertex 281 -97 34 -108
meshvertex 282 -76 47 -111
meshvertex 283 -97 58 -118
meshvertex 285 -76 58 -118
meshvertex 286 -97 65 -129
meshvertex 288 -76 65 -129
meshvertex 289 -97 68 -142
meshvertex 290 -76 68 -142
meshvertex 291 -97 65 -155
meshvertex 292 -76 65 -155
meshvertex 293 -97 58 -166
meshvertex 295 -76 58 -166
meshvertex 296 -97 47 -173
meshvertex 298 -76 47 -173
meshvertex 299 -97 34 -176
meshvertex 300 -76 34 -176
meshvertex 301 -97 21 -173
meshvertex 302 -76 21 -173
meshvertex 303 -97 10 -166
meshvertex 305 -76 10 -166
meshvertex 306 -97 3 -155
meshvertex 308 -76 3 -155
meshvertex 309 -97 0 -142
meshvertex 310 -76 0 -142
meshvertex 311 -97 3 -129
meshvertex 312 -76 3 -129
meshvertex 313 -97 10 -118
meshvertex 315 -76 10 -118
meshvertex 316 -97 21 -111
meshvertex 318 -76 21 -111
meshvertex 320 -100 42 -122
meshvertex 321 -100 34 -120
meshvertex 323 -100 50 -126
meshvertex 327 -100 54 -134
meshvertex 330 -100 56 -142
meshvertex 332 -100 54 -150
meshvertex 334 -100 50 -158
meshvertex 338 -100 42 -162
meshvertex 341 -100 34 -164
meshvertex 343 -100 26 -162
meshvertex 345 -100 18 -158
meshvertex 349 -100 14 -150
meshvertex 352 -100 12 -142
meshvertex 354 -100 14 -134
meshvertex 356 -100 18 -126
meshvertex 360 -100 26 -122
meshvertex 365 -100 47 -129
meshvertex 366 -100 34 -124
meshvertex 367 -99 34 -142
meshvertex 368 -99 34 -124
meshvertex 369 -99 47 -129
meshvertex 371 -100 52 -142
meshvertex 372 -99 52 -142
meshvertex 374 -100 47 -155
meshvertex 375 -99 47 -155
meshvertex 377 -100 34 -160
meshvertex 378 -99 34 -160
meshvertex 380 -100 21 -155
meshvertex 381 -99 21 -155
meshvertex 383 -100 16 -142
meshvertex 384 -99 16 -142
meshvertex 386 -100 21 -129
meshvertex 387 -99 21 -129
meshvertex 388 -100 34 -138
meshvertex 389 -100 35 -122
meshvertex 390 -100 39 -123
meshvertex 391 -100 35 -138
meshvertex 392 -100 38 -140
meshvertex 393 -100 53 -137
meshvertex 394 -100 54 -140
meshvertex 395 -100 38 -142
meshvertex 396 -100 37 -145
meshvertex 397 -100 45 -159
meshvertex 398 -100 42 -160
meshvertex 399 -100 35 -146
meshvertex 400 -100 32 -145
meshvertex 401 -100 21 -157
meshvertex 402 -100 19 -155
meshvertex 403 -100 31 -144
meshvertex 404 -100 30 -141
meshvertex 405 -100 15 -135
meshvertex 406 -100 17 -132
meshvertex 407 -100 31 -139
meshvertex 408 76 34 -108
meshvertex 409 97 34 -108
meshvertex 410 97 47 -111
meshvertex 411 76 47 -111
meshvertex 413 97 58 -118
meshvertex 414 76 58 -118
meshvertex 416 97 65 -129
meshvertex 417 76 65 -129
meshvertex 418 97 68 -142
meshvertex 419 76 68 -142
meshvertex 420 97 65 -155
meshvertex 421 76 65 -155
meshvertex 423 97 58 -166
meshvertex 424 76 58 -166
meshvertex 426 97 47 -173
meshvertex 427 76 47 -173
meshvertex 428 97 34 -176
meshvertex 429 76 34 -176
meshvertex 430 97 21 -173
meshvertex 431 76 21 -173
meshvertex 433 97 10 -166
meshvertex 434 76 10 -166
meshvertex 436 97 3 -155
meshvertex 437 76 3 -155
meshvertex 438 97 0 -142
meshvertex 439 76 0 -142
meshvertex 440 97 3 -129
meshvertex 441 76 3 -129
meshvertex 443 97 10 -118
meshvertex 444 76 10 -118
meshvertex 446 97 21 -111
meshvertex 447 76 21 -111
meshvertex 449 100 34 -120
meshvertex 450 100 42 -122
meshvertex 452 100 50 -126
meshvertex 456 100 54 -134
meshvertex 459 100 56 -142
meshvertex 461 100 54 -150
meshvertex 463 100 50 -158
meshvertex 467 100 42 -162
meshvertex 470 100 34 -164
meshvertex 472 100 26 -162
meshvertex 474 100 18 -158
meshvertex 478 100 14 -150
meshvertex 481 100 12 -142
meshvertex 483 100 14 -134
meshvertex 485 100 18 -126
meshvertex 489 100 26 -122
meshvertex 493 100 47 -129
meshvertex 495 100 34 -124
meshvertex 496 99 34 -142
meshvertex 497 99 47 -129
meshvertex 498 99 34 -124
meshvertex 499 100 52 -142
meshvertex 501 99 52 -142
meshvertex 502 100 47 -155
meshvertex 504 99 47 -155
meshvertex 505 100 34 -160
meshvertex 507 99 34 -160
meshvertex 508 100 21 -155
meshvertex 510 99 21 -155
meshvertex 511 100 16 -142
meshvertex 513 99 16 -142
meshvertex 514 100 21 -129
meshvertex 516 99 21 -129
meshvertex 517 100 34 -138
meshvertex 518 100 39 -123
meshvertex 519 100 35 -122
meshvertex 520 100 35 -138
meshvertex 521 100 38 -140
meshvertex 522 100 54 -140
meshvertex 523 100 53 -137
meshvertex 524 100 38 -142
meshvertex 525 100 37 -145
meshvertex 526 100 42 -160
meshvertex 527 100 45 -159
meshvertex 528 100 35 -146
meshvertex 529 100 32 -145
meshvertex 530 100 19 -155
meshvertex 531 100 21 -157
meshvertex 532 100 31 -144
meshvertex 533 100 30 -141
meshvertex 534 100 17 -132
meshvertex 535 100 15 -135
meshvertex 536 100 31 -139
meshvertex 537 -76 34 172
meshvertex 538 -97 47 169
meshvertex 539 -97 34 172
meshvertex 540 -76 47 169
meshvertex 541 -97 58 162
meshvertex 543 -76 58 162
meshvertex 544 -97 65 151
meshvertex 546 -76 65 151
meshvertex 547 -97 68 138
meshvertex 548 -76 68 138
meshvertex 549 -97 65 125
meshvertex 550 -76 65 125
meshvertex 551 -97 58 114
meshvertex 553 -76 58 114
meshvertex 554 -97 47 107
meshvertex 556 -76 47 107
meshvertex 557 -97 34 104
meshvertex 558 -76 34 104
meshvertex 559 -97 21 107
meshvertex 560 -76 21 107
meshvertex 561 -97 10 114
meshvertex 563 -76 10 114
meshvertex 564 -97 3 125
meshvertex 566 -76 3 125
meshvertex 567 -97 0 138
meshvertex 568 -76 0 138
meshvertex 569 -97 3 151
meshvertex 570 -76 3 151
meshvertex 571 -97 10 162
meshvertex 573 -76 10 162
meshvertex 574 -97 21 169
meshvertex 576 -76 21 169
meshvertex 578 -100 42 158
meshvertex 579 -100 34 160
meshvertex 581 -100 50 154
meshvertex 585 -100 54 146
meshvertex 588 -100 56 138
meshvertex 590 -100 54 130
meshvertex 592 -100 50 122
meshvertex 596 -100 42 118
meshvertex 599 -100 34 116
meshvertex 601 -100 26 118
meshvertex 603 -100 18 122
meshvertex 607 -100 14 130
meshvertex 610 -100 12 138
meshvertex 612 -100 14 146
meshvertex 614 -100 18 154
meshvertex 618 -100 26 158
meshvertex 623 -100 47 151
meshvertex 624 -100 34 156
meshvertex 625 -99 34 138
meshvertex 626 -99 34 156
meshvertex 627 -99 47 151
meshvertex 629 -100 52 138
meshvertex 630 -99 52 138
meshvertex 632 -100 47 125
meshvertex 633 -99 47 125
meshvertex 635 -100 34 120
meshvertex 636 -99 34 120
meshvertex 638 -100 21 125
meshvertex 639 -99 21 125
meshvertex 641 -100 16 138
meshvertex 642 -99 16 138
meshvertex 644 -100 21 151
meshvertex 645 -99 21 151
meshvertex 646 -100 34 142
meshvertex 647 -100 35 158
meshvertex 648 -100 39 157
meshvertex 649 -100 35 142
meshvertex 650 -100 38 140
meshvertex 651 -100 53 143
meshvertex 652 -100 54 140
meshvertex 653 -100 38 138
meshvertex 654 -100 37 135
meshvertex 655 -100 45 121
meshvertex 656 -100 42 120
meshvertex 657 -100 35 134
meshvertex 658 -100 32 135
meshvertex 659 -100 21 123
meshvertex 660 -100 19 125
meshvertex 661 -100 31 136
meshvertex 662 -100 30 139
meshvertex 663 -100 15 145
meshvertex 664 -100 17 148
meshvertex 665 -100 31 141
meshvertex 666 76 34 172
meshvertex 667 97 34 172
meshvertex 668 97 47 169
meshvertex 669 76 47 169
meshvertex 671 97 58 162
meshvertex 672 76 58 162
meshvertex 674 97 65 151
meshvertex 675 76 65 151
meshvertex 676 97 68 138
meshvertex 677 76 68 138
meshvertex 678 97 65 125
meshvertex 679 76 65 125
meshvertex 681 97 58 114
meshvertex 682 76 58 114
meshvertex 684 97 47 107
meshvertex 685 76 47 107
meshvertex 686 97 34 104
meshvertex 687 76 34 104
meshvertex 688 97 21 107
meshvertex 689 76 21 107
meshvertex 691 97 10 114
meshvertex 692 76 10 114
meshvertex 694 97 3 125
meshvertex 695 76 3 125
meshvertex 696 97 0 138
meshvertex 697 76 0 138
meshvertex 698 97 3 151
meshvertex 699 76 3 151
meshvertex 701 97 10 162
meshvertex 702 76 10 162
meshvertex 704 97 21 169
meshvertex 705 76 21 169
meshvertex 707 100 34 160
meshvertex 708 100 42 158
meshvertex 710 100 50 154
meshvertex 714 100 54 146
meshvertex 717 100 56 138
meshvertex 719 100 54 130
meshvertex 721 100 50 122
meshvertex 725 100 42 118
meshvertex 728 100 34 116
meshvertex 730 100 26 118
meshvertex 732 100 18 122
meshvertex 736 100 14 130
meshvertex 739 100 12 138
meshvertex 741 100 14 146
meshvertex 743 100 18 154
meshvertex 747 100 26 158
meshvertex 751 100 47 151
meshvertex 753 100 34 156
meshvertex 754 99 34 138
meshvertex 755 99 47 151
meshvertex 756 99 34 156
meshvertex 757 100 52 138
meshvertex 759 99 52 138
meshvertex 760 100 47 125
meshvertex 762 99 47 125
meshvertex 763 100 34 120
meshvertex 765 99 34 120
meshvertex 766 100 21 125
meshvertex 768 99 21 125
meshvertex 769 100 16 138
meshvertex 771 99 16 138
meshvertex 772 100 21 151
meshvertex 774 99 21 151
meshvertex 775 100 34 142
meshvertex 776 100 39 157
meshvertex 777 100 35 158
meshvertex 778 100 35 142
meshvertex 779 100 38 140
meshvertex 780 100 54 140
meshvertex 781 100 53 143
meshvertex 782 100 38 138
meshvertex 783 100 37 135
meshvertex 784 100 42 120
meshvertex 785 100 45 121
meshvertex 786 100 35 134
meshvertex 787 100 32 135
meshvertex 788 100 19 125
meshvertex 789 100 21 123
meshvertex 790 100 31 136
meshvertex 791 100 30 139
meshvertex 792 100 17 148
meshvertex 793 100 15 145
meshvertex 794 100 31 141
meshvertex 795 -94 36 -91
meshvertex 796 -88 57 -55
meshvertex 797 -91 60 -90
meshvertex 798 -92 39 -63
meshvertex 799 -73 83 75
meshvertex 800 -93 86 66
meshvertex 801 -93 84 69
meshvertex 803 -72 85 72
meshvertex 805 -89 85 63
meshvertex 806 -100 84 62
meshvertex 807 -100 91 66
meshvertex 810 -88 92 67
meshvertex 813 -98 85 77
meshvertex 816 -88 86 79
meshvertex 823 94 36 -91
meshvertex 824 91 60 -90
meshvertex 825 88 57 -55
meshvertex 826 92 39 -63
meshvertex 827 73 83 75
meshvertex 828 93 84 69
meshvertex 829 93 86 66
meshvertex 832 72 85 72
meshvertex 833 89 85 63
meshvertex 834 100 91 66
meshvertex 835 100 84 62
meshvertex 837 88 92 67
meshvertex 840 98 85 77
meshvertex 843 88 86 79
meshvertex 851 -80 50 226
meshvertex 852 80 50 226
meshvertex 853 80 53 225
meshvertex 854 -80 53 225
meshvertex 855 -81 63 -227
meshvertex 856 81 67 -226
meshvertex 857 81 63 -227
meshvertex 858 -81 67 -226
meshvertex 859 -84 39 -227
meshvertex 860 80 57 -225
meshvertex 861 84 39 -227
meshvertex 862 -80 57 -225
meshvertex 863 -51 24 225
meshvertex 864 51 24 225
meshvertex 865 57 43 225
meshvertex 866 -57 43 225
meshvertex 867 -73 15 -225
meshvertex 868 67 39 -225
meshvertex 869 73 15 -225
meshvertex 870 -67 39 -225
meshvertex 871 -52 15 -225
meshvertex 872 -50 37 -220
meshvertex 873 -50 15 -225
meshvertex 874 -52 37 -220
meshvertex 875 -18 15 -225
meshvertex 876 -16 37 -220
meshvertex 877 -16 15 -225
meshvertex 878 -18 37 -220
meshvertex 879 16 15 -225
meshvertex 880 18 37 -220
meshvertex 881 18 15 -225
meshvertex 882 16 37 -220
meshvertex 883 50 15 -225
meshvertex 884 52 37 -220
meshvertex 885 52 15 -225
meshvertex 886 50 37 -220
meshvertex 887 -51 73 108
meshvertex 888 -64 76 112
meshvertex 889 -66 72 158
meshvertex 890 -57 70 157
meshvertex 891 51 73 108
meshvertex 892 66 72 158
meshvertex 893 64 76 112
meshvertex 894 57 70 157
meshvertex 895 -93 29 -103
meshvertex 896 -88 29 -72
meshvertex 897 -88 43 -72
meshvertex 898 -93 43 -103
meshvertex 899 -86 29 0
meshvertex 900 -86 43 0
meshvertex 901 -89 29 70
meshvertex 902 -89 43 70
meshvertex 903 -93 29 99
meshvertex 904 -93 43 99
meshvertex 905 93 29 -103
meshvertex 906 88 43 -72
meshvertex 907 88 29 -72
meshvertex 908 93 43 -103
meshvertex 909 86 43 0
meshvertex 910 86 29 0
meshvertex 911 89 43 70
meshvertex 912 89 29 70
meshvertex 913 93 43 99
meshvertex 914 93 29 99
meshvertex 915 -92 44 -88
meshvertex 916 -91 44 -87
meshvertex 917 -91 73 -87
meshvertex 918 -92 73 -88
meshvertex 919 -91 44 80
meshvertex 920 -92 44 81
meshvertex 921 -92 73 81
meshvertex 922 -91 73 80
meshvertex 923 -59 106 -60
meshvertex 924 -58 103 30
meshvertex 925 -57 106 30
meshvertex 926 -60 109 -60
meshvertex 927 -89 67 -64
meshvertex 928 -90 67 65
meshvertex 929 -90 69 65
meshvertex 930 -89 69 -64
meshvertex 931 92 44 -88
meshvertex 932 91 73 -87
meshvertex 933 91 44 -87
meshvertex 934 92 73 -88
meshvertex 935 91 44 80
meshvertex 936 92 73 81
meshvertex 937 92 44 81
meshvertex 938 91 73 80
meshvertex 939 59 106 -60
meshvertex 940 57 106 30
meshvertex 941 58 103 30
meshvertex 942 60 109 -60
meshvertex 943 89 67 -64
meshvertex 944 90 69 65
meshvertex 945 90 67 65
meshvertex 946 89 69 -64
meshvertex 947 -53 15 -227
meshvertex 948 -49 35 -213
meshvertex 949 -49 15 -227
meshvertex 950 -53 35 -213
meshvertex 951 -19 15 -227
meshvertex 952 -15 35 -213
meshvertex 953 -15 15 -227
meshvertex 954 -19 35 -213
meshvertex 955 15 15 -227
meshvertex 956 19 35 -213
meshvertex 957 19 15 -227
meshvertex 958 15 35 -213
meshvertex 959 49 15 -227
meshvertex 960 53 35 -213
meshvertex 961 53 15 -227
meshvertex 962 49 35 -213
meshvertex 963 -70 44 -227
meshvertex 964 68 48 -227
meshvertex 965 70 44 -227
meshvertex 966 -68 48 -227
meshvertex 967 -70 46 -227
meshvertex 968 -80 46 -227
meshvertex 969 -80 49 -227
meshvertex 970 -70 49 -227
meshvertex 971 70 46 -227
meshvertex 972 80 49 -227
meshvertex 973 80 46 -227
meshvertex 974 70 49 -227
meshvertex 975 -85 72 -223
meshvertex 976 -95 79 -181
meshvertex 977 0 78 -181
meshvertex 978 0 69 -223
meshvertex 979 95 79 -181
meshvertex 980 85 72 -223
meshvertex 982 -95 34 -181
meshvertex 984 -85 22 -223
meshvertex 987 95 34 -181
meshvertex 988 85 22 -223
meshvertex 989 -96 79 -167
meshvertex 990 0 78 -167
meshvertex 991 96 79 -167
meshvertex 992 -96 64 -167
meshvertex 995 96 64 -167
meshvertex 996 -97 80 -142
meshvertex 997 0 78 -142
meshvertex 998 97 80 -142
meshvertex 999 -97 73 -142
meshvertex 1002 97 73 -142
meshvertex 1003 -94 78 -117
meshvertex 1004 0 77 -117
meshvertex 1005 94 78 -117
meshvertex 1006 -94 64 -117
meshvertex 1009 94 64 -117
meshvertex 1010 -92 77 -103
meshvertex 1011 0 77 -103
meshvertex 1012 92 77 -103
meshvertex 1013 -92 34 -103
meshvertex 1016 92 34 -103
meshvertex 1017 -92 76 99
meshvertex 1018 0 72 99
meshvertex 1019 92 76 99
meshvertex 1020 -92 34 99
meshvertex 1023 92 34 99
meshvertex 1024 -93 76 113
meshvertex 1025 0 71 113
meshvertex 1026 93 76 113
meshvertex 1027 -93 64 113
meshvertex 1030 93 64 113
meshvertex 1031 -96 76 138
meshvertex 1032 0 69 138
meshvertex 1033 96 76 138
meshvertex 1034 -96 73 138
meshvertex 1037 96 73 138
meshvertex 1038 -93 72 163
meshvertex 1039 0 66 163
meshvertex 1040 93 72 163
meshvertex 1041 -93 64 163
meshvertex 1044 93 64 163
meshvertex 1045 -91 69 177
meshvertex 1046 0 64 177
meshvertex 1047 91 69 177
meshvertex 1048 -91 34 177
meshvertex 1051 91 34 177
meshvertex 1052 -72 48 223
meshvertex 1053 0 46 223
meshvertex 1054 72 48 223
meshvertex 1055 -72 22 223
meshvertex 1058 72 22 223
meshvertex 1059 0 32 -223
meshvertex 1065 0 32 223
meshvertex 1068 -71 18 -204
meshvertex 1069 71 18 197
meshvertex 1070 -71 18 197
meshvertex 1071 71 18 -204
meshvertex 1072 -54 73 -150
meshvertex 1073 -60 106 -60
meshvertex 1074 0 113 -60
meshvertex 1075 0 75 -150
meshvertex 1076 60 106 -60
meshvertex 1077 54 73 -150
meshvertex 1078 -61 108 -10
meshvertex 1079 0 115 -10
meshvertex 1080 61 108 -10
meshvertex 1081 -54 101 48
meshvertex 1082 0 108 48
meshvertex 1083 54 101 48
meshvertex 1084 -69 73 108
meshvertex 1085 0 75 108
meshvertex 1086 69 73 108
meshvertex 1087 -78 79 -126
meshvertex 1088 -55 101 48
meshvertex 1089 -61 104 -61
meshvertex 1090 -74 78 101
meshvertex 1091 -81 77 -64
meshvertex 1092 -80 77 -141
meshvertex 1098 78 79 -126
meshvertex 1099 61 104 -61
meshvertex 1100 55 101 48
meshvertex 1101 74 78 101
meshvertex 1102 81 77 -64
meshvertex 1103 80 77 -141
meshvertex 1109 -76 34 -108
meshvertex 1110 -98 58 -118
meshvertex 1111 -98 34 -108
meshvertex 1112 -76 58 -118
meshvertex 1113 -98 68 -142
meshvertex 1114 -76 68 -142
meshvertex 1115 -98 58 -166
meshvertex 1116 -76 58 -166
meshvertex 1117 -98 34 -176
meshvertex 1118 -76 34 -176
meshvertex 1119 -98 10 -166
meshvertex 1120 -76 10 -166
meshvertex 1121 -98 0 -142
meshvertex 1122 -76 0 -142
meshvertex 1123 -98 10 -118
meshvertex 1124 -76 10 -118
meshvertex 1126 -100 50 -126
meshvertex 1127 -100 34 -120
meshvertex 1129 -100 56 -142
meshvertex 1131 -100 50 -158
meshvertex 1133 -100 34 -164
meshvertex 1135 -100 18 -158
meshvertex 1137 -100 12 -142
meshvertex 1139 -100 18 -126
meshvertex 1141 -100 34 -142
meshvertex 1159 76 34 -108
meshvertex 1160 98 34 -108
meshvertex 1161 98 58 -118
meshvertex 1162 76 58 -118
meshvertex 1163 98 68 -142
meshvertex 1164 76 68 -142
meshvertex 1165 98 58 -166
meshvertex 1166 76 58 -166
meshvertex 1167 98 34 -176
meshvertex 1168 76 34 -176
meshvertex 1169 98 10 -166
meshvertex 1170 76 10 -166
meshvertex 1171 98 0 -142
meshvertex 1172 76 0 -142
meshvertex 1173 98 10 -118
meshvertex 1174 76 10 -118
meshvertex 1176 100 34 -120
meshvertex 1177 100 50 -126
meshvertex 1179 100 56 -142
meshvertex 1181 100 50 -158
meshvertex 1183 100 34 -164
meshvertex 1185 100 18 -158
meshvertex 1187 100 12 -142
meshvertex 1189 100 18 -126
meshvertex 1191 100 34 -142
meshvertex 1209 -76 34 172
meshvertex 1210 -98 58 162
meshvertex 1211 -98 34 172
meshvertex 1212 -76 58 162
meshvertex 1213 -98 68 138
meshvertex 1214 -76 68 138
meshvertex 1215 -98 58 114
meshvertex 1216 -76 58 114
meshvertex 1217 -98 34 104
meshvertex 1218 -76 34 104
meshvertex 1219 -98 10 114
meshvertex 1220 -76 10 114
meshvertex 1221 -98 0 138
meshvertex 1222 -76 0 138
meshvertex 1223 -98 10 162
meshvertex 1224 -76 10 162
meshvertex 1226 -100 50 154
meshvertex 1227 -100 34 160
meshvertex 1229 -100 56 138
meshvertex 1231 -100 50 122
meshvertex 1233 -100 34 116
meshvertex 1235 -100 18 122
meshvertex 1237 -100 12 138
meshvertex 1239 -100 18 154
meshvertex 1241 -100 34 138
meshvertex 1259 76 34 172
meshvertex 1260 98 34 172
meshvertex 1261 98 58 162
meshvertex 1262 76 58 162
meshvertex 1263 98 68 138
meshvertex 1264 76 68 138
meshvertex 1265 98 58 114
meshvertex 1266 76 58 114
meshvertex 1267 98 34 104
meshvertex 1268 76 34 104
meshvertex 1269 98 10 114
meshvertex 1270 76 10 114
meshvertex 1271 98 0 138
meshvertex 1272 76 0 138
meshvertex 1273 98 10 162
meshvertex 1274 76 10 162
meshvertex 1276 100 34 160
meshvertex 1277 100 50 154
meshvertex 1279 100 56 138
meshvertex 1281 100 50 122
meshvertex 1283 100 34 116
meshvertex 1285 100 18 122
meshvertex 1287 100 12 138
meshvertex 1289 100 18 154
meshvertex 1291 100 34 138
meshvertex 1309 -94 36 -91
meshvertex 1310 -88 57 -55
meshvertex 1311 -91 60 -90
meshvertex 1312 94 36 -91
meshvertex 1313 91 60 -90
meshvertex 1314 88 57 -55
meshvertex 1315 -80 50 226
meshvertex 1316 80 50 226
meshvertex 1317 80 53 225
meshvertex 1318 -80 53 225
meshvertex 1319 -81 63 -227
meshvertex 1320 81 67 -226
meshvertex 1321 81 63 -227
meshvertex 1322 -81 67 -226
meshvertex 1323 -84 39 -227
meshvertex 1324 80 57 -225
meshvertex 1325 84 39 -227
meshvertex 1326 -80 57 -225
meshvertex 1327 -51 24 225
meshvertex 1328 51 24 225
meshvertex 1329 57 43 225
meshvertex 1330 -57 43 225
meshvertex 1331 -73 15 -225
meshvertex 1332 67 39 -225
meshvertex 1333 73 15 -225
meshvertex 1334 -67 39 -225
meshvertex 1335 -93 29 -103
meshvertex 1336 -86 29 0
meshvertex 1337 -86 43 0
meshvertex 1338 -93 43 -103
meshvertex 1339 -93 29 99
meshvertex 1340 -93 43 99
meshvertex 1341 93 29 -103
meshvertex 1342 86 43 0
meshvertex 1343 86 29 0
meshvertex 1344 93 43 -103
meshvertex 1345 93 43 99
meshvertex 1346 93 29 99
meshvertex 1347 -85 72 -223
meshvertex 1348 -97 80 -142
meshvertex 1349 0 78 -142
meshvertex 1350 0 69 -223
meshvertex 1351 97 80 -142
meshvertex 1352 85 72 -223
meshvertex 1354 -97 22 -142
meshvertex 1356 -85 22 -223
meshvertex 1359 97 22 -142
meshvertex 1360 85 22 -223
meshvertex 1361 -87 75 -65
meshvertex 1362 0 76 -65
meshvertex 1363 87 75 -65
meshvertex 1364 -87 22 -65
meshvertex 1367 87 22 -65
meshvertex 1368 -88 74 65
meshvertex 1369 0 75 65
meshvertex 1370 88 74 65
meshvertex 1371 -88 22 65
meshvertex 1374 88 22 65
meshvertex 1375 -96 76 138
meshvertex 1376 0 69 138
meshvertex 1377 96 76 138
meshvertex 1378 -96 22 138
meshvertex 1381 96 22 138
meshvertex 1382 -72 48 223
meshvertex 1383 0 46 223
meshvertex 1384 72 48 223
meshvertex 1385 -72 22 223
meshvertex 1388 72 22 223
meshvertex 1395 -71 18 -204
meshvertex 1396 71 18 197
meshvertex 1397 -71 18 197
meshvertex 1398 71 18 -204
meshvertex 1399 -54 74 -145
meshvertex 1400 -60 106 -55
meshvertex 1401 0 113 -55
meshvertex 1402 0 77 -145
meshvertex 1403 60 106 -55
meshvertex 1404 54 74 -145
meshvertex 1405 -57 107 30
meshvertex 1406 0 115 30
meshvertex 1407 57 107 30
meshvertex 1408 -69 73 108
meshvertex 1409 0 75 108
meshvertex 1410 69 73 108
meshvertex 1411 -78 79 -126
meshvertex 1412 -55 101 48
meshvertex 1413 -60 107 -15
meshvertex 1414 -74 78 101
meshvertex 1415 78 79 -126
meshvertex 1416 60 107 -15
meshvertex 1417 55 101 48
meshvertex 1418 74 78 101
meshvertex 1419 -78 34 -108
meshvertex 1420 -100 68 -142
meshvertex 1421 -100 34 -108
meshvertex 1422 -78 68 -142
meshvertex 1424 -100 34 -176
meshvertex 1426 -78 34 -176
meshvertex 1428 -100 0 -142
meshvertex 1430 -78 0 -142
meshvertex 1439 78 34 -108
meshvertex 1440 100 34 -108
meshvertex 1441 100 68 -142
meshvertex 1442 78 68 -142
meshvertex 1445 100 34 -176
meshvertex 1446 78 34 -176
meshvertex 1449 100 0 -142
meshvertex 1450 78 0 -142
meshvertex 1459 -78 34 172
meshvertex 1460 -100 68 138
meshvertex 1461 -100 34 172
meshvertex 1462 -78 68 138
meshvertex 1464 -100 34 104
meshvertex 1466 -78 34 104
meshvertex 1468 -100 0 138
meshvertex 1470 -78 0 138
meshvertex 1479 78 34 172
meshvertex 1480 100 34 172
meshvertex 1481 100 68 138
meshvertex 1482 78 68 138
meshvertex 1485 100 34 104
meshvertex 1486 78 34 104
meshvertex 1489 100 0 138
meshvertex 1490 78 0 138
meshvertex 1499 -80 50 226
meshvertex 1500 80 50 226
meshvertex 1501 80 53 225
meshvertex 1502 -80 53 225
meshvertex 1503 -81 63 -227
meshvertex 1504 81 67 -226
meshvertex 1505 81 63 -227
meshvertex 1506 -81 67 -226
meshvertex 1507 -84 39 -227
meshvertex 1508 80 57 -225
meshvertex 1509 84 39 -227
meshvertex 1510 -80 57 -225
meshvertex 1511 12 4 12
meshvertex 1512 123 3 12
meshvertex 1513 90 3 181
meshvertex 1514 12 3 251
meshvertex 1515 -66 3 181
meshvertex 1516 -99 3 12
meshvertex 1517 -66 3 -157
meshvertex 1518 12 3 -227
meshvertex 1519 90 3 -157
meshvertex 1520 155 2 12
meshvertex 1521 113 2 201
meshvertex 1522 12 2 279
meshvertex 1523 -89 2 201
meshvertex 1524 -131 2 12
meshvertex 1525 -89 2 -177
meshvertex 1526 12 2 -255
meshvertex 1527 113 2 -177
meshvertex 1528 0 820 0
meshvertex 1529 215 200 0
meshvertex 1530 108 200 186
meshvertex 1531 -107 200 186
meshvertex 1532 -215 200 0
meshvertex 1533 -108 200 -186
meshvertex 1534 108 200 -186
meshvertex 1535 -20 0 0
meshvertex 1536 20 0 0
meshvertex 1537 20 280 0
meshvertex 1538 -20 280 0
meshvertex 1539 0 0 -20
meshvertex 1540 0 0 20
meshvertex 1541 0 280 20
meshvertex 1542 0 280 -20
localset 512 256
localset 513 769
localset 514 1282
localset 515 1282
localset 516 2307
localset 517 2820
localset 518 2820
localset 519 3843
localset 520 4356
localset 521 4867
localset 522 5380
localset 523 5891
localset 524 6402
localset 525 6915
localset 526 7429
localset 527 7936
localset 528 8454
localset 529 774
localset 530 9472
localset 531 7429
localset 532 10503
localset 533 11008
localset 534 776
localset 535 12041
localset 536 12554
localset 537 13066
localset 538 1290
localset 539 2827
localset 540 14602
localset 541 2826
localset 542 4363
localset 543 16138
localset 544 5388
localset 545 17162
localset 546 5378
localset 547 18189
localset 548 7438
localset 549 19206
localset 550 12033
localset 551 18191
localset 552 20743
localset 553 12048
localset 554 21776
localset 555 22282
localset 556 22794
localset 557 23306
localset 558 23818
localset 559 24330
localset 560 24849
localset 561 24837
localset 562 18191
localset 563 26386
localset 564 26895
localset 565 27408
localset 566 27914
localset 567 28426
localset 568 28938
localset 569 29450
localset 570 29962
localset 571 30481
localset 572 30994
localset 573 24849
localset 574 32015
localset 575 32531
localset 576 33034
localset 577 33546
localset 578 34058
localset 579 34570
localset 580 35082
localset 581 35604
localset 582 36114
localset 583 36623
localset 584 37139
localset 585 37642
localset 586 38154
localset 587 38666
localset 588 39178
localset 589 39690
localset 590 40212
localset 591 40722
localset 592 41231
localset 593 41749
localset 594 42250
localset 595 42762
localset 596 43274
localset 597 43786
localset 598 44298
localset 599 44822
localset 600 45330
localset 601 45839
localset 602 46359
localset 603 46858
localset 604 47370
localset 605 47882
localset 606 48394
localset 607 48906
localset 608 49432
localset 609 49938
localset 610 50447
localset 611 50960
localset 612 51466
localset 613 51978
localset 614 52490
localset 615 53002
localset 616 53514
localset 617 54033
localset 618 54546
localset 619 55055
localset 620 55568
localset 621 56074
localset 622 56586
localset 623 57098
localset 624 57610
localset 625 58122
localset 626 58641
localset 627 59154
localset 628 59663
localset 629 60176
localset 630 60682
localset 631 61194
localset 632 61706
localset 633 62218
localset 634 62730
localset 635 63249
localset 636 63762
localset 637 64271
localset 638 64784
localset 639 65290
localset 640 65802
localset 641 66314
localset 642 66826
localset 643 67338
localset 644 67857
localset 645 68370
localset 646 68879
localset 647 69392
localset 648 69898
localset 649 70410
localset 650 70922
localset 651 71434
localset 652 71946
localset 653 72465
localset 654 72978
localset 655 73487
localset 656 74003
localset 657 74506
localset 658 75018
localset 659 75530
localset 660 76042
localset 661 76554
localset 662 77073
localset 663 77586
localset 664 78095
localset 665 78611
localset 666 79114
localset 667 79626
localset 668 80138
localset 669 80665
localset 670 81162
localset 671 81684
localset 672 82194
localset 673 82703
localset 674 83221
localset 675 83722
localset 676 84250
localset 677 84746
localset 678 85273
localset 679 85770
localset 680 86292
localset 681 86802
localset 682 87311
localset 683 87829
localset 684 88330
localset 685 88858
localset 686 89354
localset 687 89883
localset 688 90396
localset 689 90902
localset 690 91410
localset 691 91919
localset 692 92439
localset 693 92940
localset 694 93469
localset 695 93962
localset 696 94491
localset 697 95004
localset 698 95510
localset 699 96018
localset 700 96527
localset 701 97047
localset 702 97566
localset 703 98078
localset 704 98572
localset 705 99100
localset 706 99596
localset 707 100120
localset 708 100639
localset 709 101152
localset 710 101655
localset 711 102156
localset 712 102686
localset 713 103180
localset 714 103708
localset 715 104204
localset 716 104728
localset 717 105247
localset 718 105760
localset 719 106273
localset 720 106786
localset 721 107275
localset 722 107787
localset 723 108299
localset 724 108811
localset 725 109345
localset 726 109859
localset 727 110372
localset 728 110848
localset 729 111393
localset 730 111909
localset 731 112421
localset 732 112933
localset 733 113445
localset 734 114086
localset 735 114598
localset 736 115074
localset 737 115586
localset 738 116098
localset 739 116610
localset 740 117122
localset 741 117634
localset 742 118158
localset 743 118658
localset 744 119178
localset 745 119690
localset 746 120202
localset 747 120743
localset 748 121255
localset 749 121738
localset 750 122250
localset 751 122762
localset 752 123274
localset 753 123786
localset 754 124315
localset 755 124810
localset 756 125322
localset 757 125834
localset 758 126362
localset 759 126876
localset 760 127388
localset 761 127884
localset 762 128414
localset 763 128926
localset 764 129420
localset 765 129932
localset 766 130444
localset 767 130956
localset 768 131486
localset 769 131987
localset 770 132499
localset 771 133008
localset 772 133523
localset 773 134056
localset 774 134416
localset 775 131856
localset 776 132880
localset 777 132393
localset 778 129321
localset 779 133417
localset 780 137620
localset 781 138129
localset 782 138644
localset 783 139156
localset 784 139661
localset 785 140049
localset 786 138001
localset 787 137489
localset 788 138538
localset 789 139050
localset 790 131370
localset 791 143137
localset 792 143650
localset 793 144161
localset 794 144674
localset 795 145195
localset 796 143650
localset 797 146187
localset 798 146700
localset 799 145163
localset 800 147724
localset 801 148234
localset 802 148746
localset 803 149250
localset 804 149762
localset 805 150316
localset 806 149286
localset 807 151300
localset 808 151811
localset 809 150276
localset 810 152835
localset 811 153344
localset 812 153856
localset 813 154413
localset 814 154925
localset 815 155438
localset 816 154413
localset 817 156463
localset 818 156976
localset 819 155439
localset 820 158000
localset 821 158501
localset 822 159013
localset 823 159537
localset 824 160049
localset 825 160562
localset 826 159539
localset 827 161588
localset 828 162101
localset 829 160564
localset 830 163125
localset 831 144159
localset 832 164127
localset 833 164639
localset 834 143647
localset 835 165650
localset 836 143670
localset 837 145206
localset 838 145173
localset 839 167696
localset 840 145170
localset 841 146704
localset 842 169232
localset 843 148240
localset 844 170256
localset 845 149264
localset 846 171282
localset 847 149303
localset 848 150328
localset 849 150329
localset 850 173318
localset 851 150290
localset 852 151814
localset 853 174854
localset 854 153350
localset 855 175878
localset 856 154374
localset 857 176914
localset 858 154426
localset 859 155450
localset 860 155451
localset 861 179004
localset 862 155410
localset 863 156988
localset 864 180540
localset 865 158524
localset 866 181564
localset 867 159548
localset 868 182546
localset 869 159549
localset 870 160574
localset 871 160575
localset 872 184607
localset 873 160530
localset 874 162079
localset 875 164626
localset 876 165650
localset 877 187154
localset 878 187666
localset 879 188178
localset 880 188690
localset 881 189202
localset 882 169234
localset 883 190226
localset 884 190738
localset 885 171282
localset 886 191762
localset 887 192274
localset 888 174866
localset 889 193298
localset 890 193810
localset 891 176914
localset 892 194834
localset 893 195346
localset 894 180498
localset 895 196370
localset 896 196882
localset 897 182546
localset 898 197906
localset 899 198418
localset 900 198930
localset 901 199442
localset 902 199954
localset 903 200466
localset 904 200978
localset 905 201490
localset 906 202002
localset 907 202514
localset 908 203026
localset 909 203538
localset 910 204050
localset 911 204562
localset 912 205074
localset 913 205586
localset 914 206098
localset 915 206610
localset 916 207122
localset 917 207634
localset 918 208146
localset 919 208658
localset 920 209185
localset 921 209697
localset 922 210210
localset 923 210722
localset 924 210210
localset 925 211776
localset 926 212235
localset 927 211723
localset 928 213260
localset 929 213772
localset 930 214282
localset 931 214794
localset 932 215298
localset 933 215810
localset 934 215310
localset 935 216897
localset 936 217348
localset 937 216836
localset 938 218371
localset 939 218883
localset 940 219392
localset 941 219904
localset 942 220461
localset 943 220973
localset 944 220461
localset 945 222018
localset 946 222511
localset 947 221999
localset 948 223536
localset 949 224048
localset 950 224549
localset 951 225061
localset 952 225585
localset 953 226097
localset 954 225603
localset 955 227140
localset 956 227636
localset 957 227124
localset 958 228661
localset 959 229173
localset 960 209696
localset 961 230176
localset 962 230688
localset 963 210208
localset 964 231695
localset 965 210245
localset 966 211781
localset 967 211734
localset 968 233745
localset 969 211727
localset 970 213265
localset 971 235281
localset 972 214289
localset 973 236305
localset 974 215313
localset 975 237327
localset 976 215366
localset 977 216903
localset 978 216904
localset 979 239367
localset 980 216847
localset 981 218375
localset 982 240903
localset 983 219399
localset 984 241927
localset 985 220423
localset 986 242959
localset 987 220489
localset 988 222025
localset 989 222026
localset 990 245067
localset 991 221967
localset 992 223563
localset 993 246603
localset 994 224587
localset 995 247627
localset 996 225611
localset 997 248591
localset 998 225612
localset 999 227149
localset 1000 227150
localset 1001 250656
localset 1002 227087
localset 1003 228640
localset 1004 230159
localset 1005 252687
localset 1006 231695
localset 1007 253711
localset 1008 254223
localset 1009 254735
localset 1010 255247
localset 1011 255759
localset 1012 235279
localset 1013 256783
localset 1014 257295
localset 1015 237327
localset 1016 258319
localset 1017 258831
localset 1018 240911
localset 1019 259855
localset 1020 260367
localset 1021 242959
localset 1022 261391
localset 1023 261903
localset 1024 246543
localset 1025 262927
localset 1026 263439
localset 1027 248591
localset 1028 264463
localset 1029 264975
localset 1030 265487
localset 1031 265999
localset 1032 266511
localset 1033 267023
localset 1034 267535
localset 1035 268047
localset 1036 268559
localset 1037 269071
localset 1038 269583
localset 1039 270095
localset 1040 270607
localset 1041 271119
localset 1042 271631
localset 1043 272143
localset 1044 272655
localset 1045 273167
localset 1046 273679
localset 1047 274191
localset 1048 274703
localset 1049 275233
localset 1050 275746
localset 1051 276257
localset 1052 276770
localset 1053 277291
localset 1054 275746
localset 1055 278283
localset 1056 278796
localset 1057 277259
localset 1058 279820
localset 1059 280330
localset 1060 280842
localset 1061 281346
localset 1062 281858
localset 1063 282412
localset 1064 281382
localset 1065 283396
localset 1066 283907
localset 1067 282372
localset 1068 284931
localset 1069 285440
localset 1070 285952
localset 1071 286509
localset 1072 287021
localset 1073 287534
localset 1074 286509
localset 1075 288559
localset 1076 289072
localset 1077 287535
localset 1078 290096
localset 1079 290597
localset 1080 291109
localset 1081 291633
localset 1082 292145
localset 1083 292658
localset 1084 291635
localset 1085 293684
localset 1086 294197
localset 1087 292660
localset 1088 295221
localset 1089 276255
localset 1090 296223
localset 1091 296735
localset 1092 275743
localset 1093 297746
localset 1094 275766
localset 1095 277302
localset 1096 277269
localset 1097 299792
localset 1098 277266
localset 1099 278800
localset 1100 301328
localset 1101 280336
localset 1102 302352
localset 1103 281360
localset 1104 303378
localset 1105 281399
localset 1106 282424
localset 1107 282425
localset 1108 305414
localset 1109 282386
localset 1110 283910
localset 1111 306950
localset 1112 285446
localset 1113 307974
localset 1114 286470
localset 1115 309010
localset 1116 286522
localset 1117 287546
localset 1118 287547
localset 1119 311100
localset 1120 287506
localset 1121 289084
localset 1122 312636
localset 1123 290620
localset 1124 313660
localset 1125 291644
localset 1126 314642
localset 1127 291645
localset 1128 292670
localset 1129 292671
localset 1130 316703
localset 1131 292626
localset 1132 294175
localset 1133 296722
localset 1134 297746
localset 1135 319250
localset 1136 319762
localset 1137 320274
localset 1138 320786
localset 1139 321298
localset 1140 301330
localset 1141 322322
localset 1142 322834
localset 1143 303378
localset 1144 323858
localset 1145 324370
localset 1146 306962
localset 1147 325394
localset 1148 325906
localset 1149 309010
localset 1150 326930
localset 1151 327442
localset 1152 312594
localset 1153 328466
localset 1154 328978
localset 1155 314642
localset 1156 330002
localset 1157 330514
localset 1158 331026
localset 1159 331538
localset 1160 332050
localset 1161 332562
localset 1162 333074
localset 1163 333586
localset 1164 334098
localset 1165 334610
localset 1166 335122
localset 1167 335634
localset 1168 336146
localset 1169 336658
localset 1170 337170
localset 1171 337682
localset 1172 338194
localset 1173 338706
localset 1174 339218
localset 1175 339730
localset 1176 340242
localset 1177 340754
localset 1178 341281
localset 1179 341793
localset 1180 342306
localset 1181 342818
localset 1182 342306
localset 1183 343872
localset 1184 344331
localset 1185 343819
localset 1186 345356
localset 1187 345868
localset 1188 346378
localset 1189 346890
localset 1190 347394
localset 1191 347906
localset 1192 347406
localset 1193 348993
localset 1194 349444
localset 1195 348932
localset 1196 350467
localset 1197 350979
localset 1198 351488
localset 1199 352000
localset 1200 352557
localset 1201 353069
localset 1202 352557
localset 1203 354114
localset 1204 354607
localset 1205 354095
localset 1206 355632
localset 1207 356144
localset 1208 356645
localset 1209 357157
localset 1210 357681
localset 1211 358193
localset 1212 357699
localset 1213 359236
localset 1214 359732
localset 1215 359220
localset 1216 360757
localset 1217 361269
localset 1218 341792
localset 1219 362272
localset 1220 362784
localset 1221 342304
localset 1222 363791
localset 1223 342341
localset 1224 343877
localset 1225 343830
localset 1226 365841
localset 1227 343823
localset 1228 345361
localset 1229 367377
localset 1230 346385
localset 1231 368401
localset 1232 347409
localset 1233 369423
localset 1234 347462
localset 1235 348999
localset 1236 349000
localset 1237 371463
localset 1238 348943
localset 1239 350471
localset 1240 372999
localset 1241 351495
localset 1242 374023
localset 1243 352519
localset 1244 375055
localset 1245 352585
localset 1246 354121
localset 1247 354122
localset 1248 377163
localset 1249 354063
localset 1250 355659
localset 1251 378699
localset 1252 356683
localset 1253 379723
localset 1254 357707
localset 1255 380687
localset 1256 357708
localset 1257 359245
localset 1258 359246
localset 1259 382752
localset 1260 359183
localset 1261 360736
localset 1262 362255
localset 1263 384783
localset 1264 363791
localset 1265 385807
localset 1266 386319
localset 1267 386831
localset 1268 387343
localset 1269 387855
localset 1270 367375
localset 1271 388879
localset 1272 389391
localset 1273 369423
localset 1274 390415
localset 1275 390927
localset 1276 373007
localset 1277 391951
localset 1278 392463
localset 1279 375055
localset 1280 393487
localset 1281 393999
localset 1282 378639
localset 1283 395023
localset 1284 395535
localset 1285 380687
localset 1286 396559
localset 1287 397071
localset 1288 397583
localset 1289 398095
localset 1290 398607
localset 1291 399119
localset 1292 399631
localset 1293 400143
localset 1294 400655
localset 1295 401167
localset 1296 401679
localset 1297 402191
localset 1298 402703
localset 1299 403215
localset 1300 403727
localset 1301 404239
localset 1302 404751
localset 1303 405263
localset 1304 405775
localset 1305 406287
localset 1306 406799
localset 1307 407314
localset 1308 407826
localset 1309 408338
localset 1310 408848
localset 1311 409387
localset 1312 409899
localset 1313 410411
localset 1314 409372
localset 1315 411420
localset 1316 409884
localset 1317 412547
localset 1318 413059
localset 1319 413571
localset 1320 412547
localset 1321 413571
localset 1322 415107
localset 1323 415004
localset 1324 413468
localset 1325 416540
localset 1326 415004
localset 1327 416540
localset 1328 418076
localset 1329 412965
localset 1330 418085
localset 1331 416549
localset 1332 412949
localset 1333 418069
localset 1334 414997
localset 1335 421647
localset 1336 422159
localset 1337 422671
localset 1338 423185
localset 1339 423744
localset 1340 424256
localset 1341 424768
localset 1342 423710
localset 1343 424734
localset 1344 426270
localset 1345 426883
localset 1346 427395
localset 1347 427907
localset 1348 426883
localset 1349 428931
localset 1350 427395
localset 1351 428830
localset 1352 430366
localset 1353 427294
localset 1354 428830
localset 1355 431902
localset 1356 430366
localset 1357 427813
localset 1358 430373
localset 1359 431909
localset 1360 427798
localset 1361 428822
localset 1362 431894
localset 1363 436002
localset 1364 436514
localset 1365 437026
localset 1366 437538
localset 1367 438019
localset 1368 438531
localset 1369 439043
localset 1370 439555
localset 1371 440064
localset 1372 440576
localset 1373 441088
localset 1374 441600
localset 1375 442145
localset 1376 442657
localset 1377 443169
localset 1378 443681
localset 1379 444160
localset 1380 444672
localset 1381 445184
localset 1382 445696
localset 1383 446211
localset 1384 446723
localset 1385 447235
localset 1386 447747
localset 1387 448259
localset 1388 448771
localset 1389 449283
localset 1390 449795
localset 1391 450307
localset 1392 450819
localset 1393 451331
localset 1394 451843
localset 1395 452355
localset 1396 452867
localset 1397 453379
localset 1398 453891
localset 1399 454426
localset 1400 454938
localset 1401 455450
localset 1402 455962
localset 1403 456473
localset 1404 456985
localset 1405 457497
localset 1406 458009
localset 1407 458514
localset 1408 459026
localset 1409 459538
localset 1410 460050
localset 1411 460562
localset 1412 461074
localset 1413 461586
localset 1414 462098
localset 1415 462610
localset 1416 463122
localset 1417 463631
localset 1418 464143
localset 1419 464655
localset 1420 465167
localset 1421 465679
localset 1422 466191
localset 1423 466703
localset 1424 467215
localset 1425 467727
localset 1426 468239
localset 1427 468815
localset 1428 469327
localset 1429 469839
localset 1430 470351
localset 1431 470864
localset 1432 471376
localset 1433 471888
localset 1434 472400
localset 1435 472850
localset 1436 473360
localset 1437 473874
localset 1438 474428
localset 1439 474898
localset 1440 475410
localset 1441 475922
localset 1442 476434
localset 1443 477009
localset 1444 477521
localset 1445 478033
localset 1446 478545
localset 1447 479058
localset 1448 479570
localset 1449 480082
localset 1450 480594
localset 1451 481039
localset 1452 481551
localset 1453 482065
localset 1454 482635
localset 1455 483087
localset 1456 483599
localset 1457 484111
localset 1458 484623
localset 1459 485124
localset 1460 485636
localset 1461 486148
localset 1462 486660
localset 1463 487172
localset 1464 487684
localset 1465 488196
localset 1466 488708
localset 1467 489220
localset 1468 489732
localset 1469 490244
localset 1470 490756
localset 1471 491268
localset 1472 491780
localset 1473 492292
localset 1474 492804
localset 1475 493312
localset 1476 493824
localset 1477 494336
localset 1478 494848
localset 1479 495360
localset 1480 495872
localset 1481 496384
localset 1482 496896
localset 1483 497408
localset 1484 497920
localset 1485 498432
localset 1486 498944
localset 1487 499466
localset 1488 499978
localset 1489 500490
localset 1490 501002
localset 1491 501514
localset 1492 502026
localset 1493 499462
localset 1494 503046
localset 1495 499986
localset 1496 504070
localset 1497 502023
localset 1498 501519
localset 1499 505607
localset 1500 506119
localset 1501 506634
localset 1502 507146
localset 1503 507658
localset 1504 508178
localset 1505 506642
localset 1506 507663
localset 1507 509711
localset 1508 510218
localset 1509 510730
localset 1510 511242
localset 1511 511762
localset 1512 510226
localset 1513 511247
localset 1514 513295
localset 1515 513802
localset 1516 514314
localset 1517 514826
localset 1518 515346
localset 1519 513810
localset 1520 514831
localset 1521 516879
localset 1522 517386
localset 1523 517898
localset 1524 518410
localset 1525 518930
localset 1526 517394
localset 1527 518415
localset 1528 520463
localset 1529 520970
localset 1530 521482
localset 1531 521994
localset 1532 522514
localset 1533 520978
localset 1534 521999
localset 1535 524047
localset 1536 524554
localset 1537 525066
localset 1538 525578
localset 1539 526098
localset 1540 524562
localset 1541 525583
localset 1542 527631
localset 1543 528138
localset 1544 528650
localset 1545 529162
localset 1546 529682
localset 1547 528146
localset 1548 529167
localset 1549 531215
localset 1550 531722
localset 1551 532234
localset 1552 532746
localset 1553 533266
localset 1554 531730
localset 1555 532751
localset 1556 534799
localset 1557 535308
localset 1558 535820
localset 1559 536332
localset 1560 536863
localset 1561 535327
localset 1562 536352
localset 1563 538400
localset 1564 538891
localset 1565 539404
localset 1566 539915
localset 1567 540451
localset 1568 538915
localset 1569 539940
localset 1570 541988
localset 1571 542464
localset 1572 504064
localset 1573 499456
localset 1574 500992
localset 1575 502016
localset 1576 506112
localset 1577 545569
localset 1578 538963
localset 1579 539915
localset 1580 547109
localset 1581 547621
localset 1582 548133
localset 1583 548645
localset 1584 549250
localset 1585 549798
localset 1586 550274
localset 1587 550786
localset 1588 551310
localset 1589 551810
localset 1590 552330
localset 1591 552842
localset 1592 553354
localset 1593 553884
localset 1594 554380
localset 1595 554910
localset 1596 555404
localset 1597 555916
localset 1598 556428
localset 1599 556947
localset 1600 557459
localset 1601 557968
localset 1602 558483
localset 1603 559016
localset 1604 559376
localset 1605 556816
localset 1606 557840
localset 1607 557353
localset 1608 555305
localset 1609 558377
localset 1610 562580
localset 1611 563089
localset 1612 563604
localset 1613 564116
localset 1614 564621
localset 1615 565009
localset 1616 562961
localset 1617 562449
localset 1618 563498
localset 1619 564010
localset 1620 556330
localset 1621 568097
localset 1622 568587
localset 1623 569121
localset 1624 569611
localset 1625 570122
localset 1626 570634
localset 1627 571140
localset 1628 571652
localset 1629 572160
localset 1630 572672
localset 1631 573231
localset 1632 573743
localset 1633 574245
localset 1634 574757
localset 1635 575284
localset 1636 575796
localset 1637 569106
localset 1638 576786
localset 1639 577298
localset 1640 568594
localset 1641 578322
localset 1642 570130
localset 1643 579346
localset 1644 571154
localset 1645 580370
localset 1646 572178
localset 1647 581394
localset 1648 573202
localset 1649 582418
localset 1650 574226
localset 1651 583442
localset 1652 575250
localset 1653 584466
localset 1654 577298
localset 1655 576786
localset 1656 584466
localset 1657 576786
localset 1658 578322
localset 1659 578322
localset 1660 579346
localset 1661 579346
localset 1662 580370
localset 1663 580370
localset 1664 581394
localset 1665 581394
localset 1666 582418
localset 1667 582418
localset 1668 583442
localset 1669 583442
localset 1670 577298
localset 1671 593697
localset 1672 594209
localset 1673 594699
localset 1674 595211
localset 1675 595722
localset 1676 596234
localset 1677 596740
localset 1678 597252
localset 1679 597760
localset 1680 598272
localset 1681 598831
localset 1682 599343
localset 1683 599845
localset 1684 600357
localset 1685 600884
localset 1686 601396
localset 1687 594191
localset 1688 602383
localset 1689 602895
localset 1690 594703
localset 1691 603919
localset 1692 595727
localset 1693 604943
localset 1694 596751
localset 1695 605967
localset 1696 597775
localset 1697 606991
localset 1698 598799
localset 1699 608015
localset 1700 599823
localset 1701 609039
localset 1702 600847
localset 1703 610063
localset 1704 602895
localset 1705 602383
localset 1706 610063
localset 1707 603919
localset 1708 602895
localset 1709 604943
localset 1710 603919
localset 1711 605967
localset 1712 604943
localset 1713 606991
localset 1714 605967
localset 1715 608015
localset 1716 606991
localset 1717 609039
localset 1718 608015
localset 1719 602383
localset 1720 609039
localset 1721 619297
localset 1722 619787
localset 1723 620321
localset 1724 620811
localset 1725 621322
localset 1726 621834
localset 1727 622340
localset 1728 622852
localset 1729 623360
localset 1730 623872
localset 1731 624431
localset 1732 624943
localset 1733 625445
localset 1734 625957
localset 1735 626484
localset 1736 626996
localset 1737 620306
localset 1738 627986
localset 1739 628498
localset 1740 619794
localset 1741 629522
localset 1742 621330
localset 1743 630546
localset 1744 622354
localset 1745 631570
localset 1746 623378
localset 1747 632594
localset 1748 624402
localset 1749 633618
localset 1750 625426
localset 1751 634642
localset 1752 626450
localset 1753 635666
localset 1754 628498
localset 1755 627986
localset 1756 635666
localset 1757 627986
localset 1758 629522
localset 1759 629522
localset 1760 630546
localset 1761 630546
localset 1762 631570
localset 1763 631570
localset 1764 632594
localset 1765 632594
localset 1766 633618
localset 1767 633618
localset 1768 634642
localset 1769 634642
localset 1770 628498
localset 1771 644897
localset 1772 645409
localset 1773 645899
localset 1774 646411
localset 1775 646922
localset 1776 647434
localset 1777 647940
localset 1778 648452
localset 1779 648960
localset 1780 649472
localset 1781 650031
localset 1782 650543
localset 1783 651045
localset 1784 651557
localset 1785 652084
localset 1786 652596
localset 1787 645391
localset 1788 653583
localset 1789 654095
localset 1790 645903
localset 1791 655119
localset 1792 646927
localset 1793 656143
localset 1794 647951
localset 1795 657167
localset 1796 648975
localset 1797 658191
localset 1798 649999
localset 1799 659215
localset 1800 651023
localset 1801 660239
localset 1802 652047
localset 1803 661263
localset 1804 654095
localset 1805 653583
localset 1806 661263
localset 1807 655119
localset 1808 654095
localset 1809 656143
localset 1810 655119
localset 1811 657167
localset 1812 656143
localset 1813 658191
localset 1814 657167
localset 1815 659215
localset 1816 658191
localset 1817 660239
localset 1818 659215
localset 1819 653583
localset 1820 660239
localset 1821 670482
localset 1822 670994
localset 1823 671506
localset 1824 672015
localset 1825 672527
localset 1826 673039
localset 1827 673570
localset 1828 674082
localset 1829 674594
localset 1830 675106
localset 1831 675587
localset 1832 676099
localset 1833 676611
localset 1834 677123
localset 1835 677632
localset 1836 678144
localset 1837 678656
localset 1838 679168
localset 1839 679713
localset 1840 680225
localset 1841 680737
localset 1842 681249
localset 1843 681728
localset 1844 682240
localset 1845 682752
localset 1846 683264
localset 1847 683794
localset 1848 684306
localset 1849 684818
localset 1850 685330
localset 1851 685842
localset 1852 686354
localset 1853 686863
localset 1854 687375
localset 1855 687887
localset 1856 688399
localset 1857 688911
localset 1858 689423
localset 1859 689930
localset 1860 690442
localset 1861 690954
localset 1862 691466
localset 1863 691978
localset 1864 692490
localset 1865 689938
localset 1866 693522
localset 1867 690450
localset 1868 694546
localset 1869 692495
localset 1870 691983
localset 1871 696079
localset 1872 696591
localset 1873 697098
localset 1874 697610
localset 1875 698122
localset 1876 698642
localset 1877 697106
localset 1878 698127
localset 1879 700175
localset 1880 700682
localset 1881 701194
localset 1882 701706
localset 1883 702226
localset 1884 700690
localset 1885 701711
localset 1886 703759
localset 1887 704286
localset 1888 704778
localset 1889 705290
localset 1890 705810
localset 1891 704274
localset 1892 705295
localset 1893 707343
localset 1894 707851
localset 1895 708364
localset 1896 708875
localset 1897 709455
localset 1898 707875
localset 1899 708900
localset 1900 710993
localset 1901 694528
localset 1902 689920
localset 1903 692480
localset 1904 696576
localset 1905 708875
localset 1906 707883
localset 1907 714533
localset 1908 715045
localset 1909 715557
localset 1910 716069
localset 1911 716710
localset 1912 717194
localset 1913 717698
localset 1914 718210
localset 1915 718734
localset 1916 719234
localset 1917 719772
localset 1918 720268
localset 1919 720778
localset 1920 721292
localset 1921 721804
localset 1922 722316
localset 1923 722835
localset 1924 723347
localset 1925 723856
localset 1926 724371
localset 1927 724884
localset 1928 725393
localset 1929 725908
localset 1930 726420
localset 1931 726795
localset 1932 727307
localset 1933 727819
localset 1934 728331
localset 1935 728324
localset 1936 729348
localset 1937 727300
localset 1938 730372
localset 1939 730415
localset 1940 731439
localset 1941 729391
localset 1942 732463
localset 1943 732468
localset 1944 727860
localset 1945 731444
localset 1946 726836
localset 1947 727826
localset 1948 727314
localset 1949 729362
localset 1950 731410
localset 1951 737035
localset 1952 737547
localset 1953 738059
localset 1954 738571
localset 1955 738564
localset 1956 738052
localset 1957 740100
localset 1958 740612
localset 1959 740655
localset 1960 740143
localset 1961 742191
localset 1962 742703
localset 1963 742708
localset 1964 742196
localset 1965 737588
localset 1966 737076
localset 1967 737551
localset 1968 740111
localset 1969 738063
localset 1970 742159
localset 1971 747275
localset 1972 747787
localset 1973 748299
localset 1974 748811
localset 1975 748804
localset 1976 749828
localset 1977 747780
localset 1978 750852
localset 1979 750895
localset 1980 751919
localset 1981 749871
localset 1982 752943
localset 1983 752948
localset 1984 748340
localset 1985 751924
localset 1986 747316
localset 1987 748306
localset 1988 747794
localset 1989 749842
localset 1990 751890
localset 1991 757515
localset 1992 758027
localset 1993 758539
localset 1994 759051
localset 1995 759044
localset 1996 758532
localset 1997 760580
localset 1998 761092
localset 1999 761135
localset 2000 760623
localset 2001 762671
localset 2002 763183
localset 2003 763188
localset 2004 762676
localset 2005 758068
localset 2006 757556
localset 2007 758031
localset 2008 760591
localset 2009 758543
localset 2010 762639
localset 2011 767778
localset 2012 768290
localset 2013 768802
localset 2014 769314
localset 2015 769795
localset 2016 770307
localset 2017 770819
localset 2018 771331
localset 2019 771840
localset 2020 772352
localset 2021 772864
localset 2022 773376
localset 2023 773887
localset 2024 774319
localset 2025 774831
localset 2026 775343
localset 2027 775855
localset 2028 776367
localset 2029 776879
localset 2030 777391
localset 2031 777903
localset 2032 778240
localset 2033 778752
localset 2034 779264
localset 2035 779776
localset 2036 780288
localset 2037 780800
localset 2038 781312
localset 2039 781824
localset 2040 782592
localset 2041 783104
localset 2042 783616
localset 2043 784128
localset 2044 784640
localset 2045 785152
localset 2046 785664
localset 2047 786176
localset 2048 786688
localset 2049 787200
localset 2050 787712
localset 2051 788224
localset 2052 788736
localset 2053 789248
localset 2054 789760
localset 11 0
label actor
localset 142 0
localget r0 11
cmp r0 4
jge tree_actor
cmp r0 0
jne rival_actor
set r0 0
mov r9 r0
localset 132 r9
set r0 975
mov r9 r0
localset 134 r9
load32 r0 100
sub r0 2000000
load32 r2 104
sub r2 2000000
load16 r8 108
load8 r9 202
mul r9 24
add r9 64
localset 126 r9
load8 r9 201
cmp r9 2
jne player_mesh_ready
localset 142 1
label player_mesh_ready
jmp actor_ready
label rival_actor
set r0 975
mov r9 r0
localset 132 r9
set r0 1347
mov r9 r0
localset 134 r9
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
mul r9 24
add r9 64
localset 126 r9
jmp actor_ready
label tree_actor
set r0 1528
mov r9 r0
localset 132 r9
set r0 1543
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
localget r5 11
cmp r5 4
jge lighting_basis_ready
mov r5 r4
mul r5 -8394
mov r6 r3
mul r6 -5799
sub r5 r6
div r5 16384
localset 3000 r5
localset 3001 12820
mov r5 r3
mul r5 -8394
mov r6 r4
mul r6 -5799
add r5 r6
div r5 16384
localset 3002 r5
localget r7 0
mov r5 r14
mul r5 r7
div r5 16384
mov r6 r12
sub r6 r5
sub r6 r0
mov r5 r15
mul r5 r7
div r5 16384
mov r7 r13
sub r7 r5
sub r7 r2
mov r5 r6
mul r5 r4
mov r8 r7
mul r8 r3
sub r5 r8
div r5 16384
localset 3010 r5
mul r6 r3
mul r7 r4
add r6 r7
div r6 16384
localset 3012 r6
localget r6 2
sub r6 60
localset 3011 r6
localget r5 3010
localget r7 3012
mov r8 r5
mul r8 r5
mov r9 r6
mul r9 r6
add r8 r9
mov r9 r7
mul r9 r7
add r8 r9
set r9 0
mov r10 r5
cmp r10 0
jge norm_component_32
mul r10 -1
label norm_component_32
add r9 r10
mov r10 r6
cmp r10 0
jge norm_component_33
mul r10 -1
label norm_component_33
add r9 r10
mov r10 r7
cmp r10 0
jge norm_component_34
mul r10 -1
label norm_component_34
add r9 r10
cmp r9 0
jgt norm_nonzero_31
set r9 1
label norm_nonzero_31
label norm_sqrt_29
mov r10 r8
div r10 r9
add r10 r9
div r10 2
cmp r10 r9
jge norm_done_30
mov r9 r10
cmp r9 0
jgt norm_sqrt_29
set r9 1
label norm_done_30
mul r5 16384
div r5 r9
mul r6 16384
div r6 r9
mul r7 16384
div r7 r9
localset 3006 r5
localset 3007 r6
localset 3008 r7
localget r8 3000
add r5 r8
localget r8 3001
add r6 r8
localget r8 3002
add r7 r8
mov r8 r5
mul r8 r5
mov r9 r6
mul r9 r6
add r8 r9
mov r9 r7
mul r9 r7
add r8 r9
set r9 0
mov r10 r5
cmp r10 0
jge norm_component_39
mul r10 -1
label norm_component_39
add r9 r10
mov r10 r6
cmp r10 0
jge norm_component_40
mul r10 -1
label norm_component_40
add r9 r10
mov r10 r7
cmp r10 0
jge norm_component_41
mul r10 -1
label norm_component_41
add r9 r10
cmp r9 0
jgt norm_nonzero_38
set r9 1
label norm_nonzero_38
label norm_sqrt_36
mov r10 r8
div r10 r9
add r10 r9
div r10 2
cmp r10 r9
jge norm_done_37
mov r9 r10
cmp r9 0
jgt norm_sqrt_36
set r9 1
label norm_done_37
mul r5 16384
div r5 r9
mul r6 16384
div r6 r9
mul r7 16384
div r7 r9
localset 3003 r5
localset 3004 r6
localset 3005 r7
label lighting_basis_ready
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
cmp r0 30000
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
cmp r0 4000
jle actor_lod_ready
localset 142 2
set r0 1347
mov r9 r0
localset 132 r9
set r0 1511
mov r9 r0
localset 134 r9
label actor_lod_ready
localget r0 11
cmp r0 4
jge lighting_table_ready
cmp r0 0
je lighting_lod_high
localget r0 142
cmp r0 2
je lighting_lod_far
localset 3030 1
jmp lighting_lod_ready
label lighting_lod_far
localset 3030 2
jmp lighting_lod_ready
label lighting_lod_high
localset 3030 0
label lighting_lod_ready
localget r0 3000
mul r0 0
localget r1 3001
mul r1 366
add r0 r1
localget r1 3002
mul r1 -16380
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_44
set r0 0
label diffuse_positive_44
mul r0 128
div r0 16384
add r0 64
localget r1 3003
mul r1 0
localget r2 3004
mul r2 366
add r1 r2
localget r2 3005
mul r2 -16380
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_45
set r1 0
label highlight_positive_45
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_46
set r0 255
label intensity_bounded_46
localset 2400 r0
label body_lighting_done_42
localget r3 3030
cmp r3 0
jne body_lighting_done_47
localget r0 3000
mul r0 -15205
localget r1 3001
mul r1 4041
add r0 r1
localget r1 3002
mul r1 -4574
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_49
set r0 0
label diffuse_positive_49
mul r0 128
div r0 16384
add r0 68
localget r1 3003
mul r1 -15205
localget r2 3004
mul r2 4041
add r1 r2
localget r2 3005
mul r2 -4574
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_50
set r1 0
label highlight_positive_50
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_51
set r0 255
label intensity_bounded_51
localset 2401 r0
label body_lighting_done_47
localget r3 3030
cmp r3 0
jne body_lighting_done_52
localget r0 3000
mul r0 79
localget r1 3001
mul r1 15183
add r0 r1
localget r1 3002
mul r1 -6156
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_54
set r0 0
label diffuse_positive_54
mul r0 128
div r0 16384
add r0 79
localget r1 3003
mul r1 79
localget r2 3004
mul r2 15183
add r1 r2
localget r2 3005
mul r2 -6156
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_55
set r1 0
label highlight_positive_55
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_56
set r0 255
label intensity_bounded_56
localset 2402 r0
label body_lighting_done_52
localget r0 3006
mul r0 79
localget r1 3007
mul r1 15183
add r0 r1
localget r1 3008
mul r1 -6156
add r0 r1
div r0 16384
mul r0 2
mul r0 15183
div r0 16384
localget r1 3007
sub r0 r1
mul r0 100
div r0 16384
add r0 128
cmp r0 0
jge glass_low_57
set r0 0
label glass_low_57
cmp r0 255
jle glass_high_58
set r0 255
label glass_high_58
localset 2602 r0
label glass_lighting_done_53
localget r3 3030
cmp r3 0
jne body_lighting_done_59
localget r0 3000
mul r0 4
localget r1 3001
mul r1 5239
add r0 r1
localget r1 3002
mul r1 -15524
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_61
set r0 0
label diffuse_positive_61
mul r0 128
div r0 16384
add r0 69
localget r1 3003
mul r1 4
localget r2 3004
mul r2 5239
add r1 r2
localget r2 3005
mul r2 -15524
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_62
set r1 0
label highlight_positive_62
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_63
set r0 255
label intensity_bounded_63
localset 2403 r0
label body_lighting_done_59
localget r3 3030
cmp r3 0
jne glass_lighting_done_60
localget r0 3006
mul r0 4
localget r1 3007
mul r1 5239
add r0 r1
localget r1 3008
mul r1 -15524
add r0 r1
div r0 16384
mul r0 2
mul r0 5239
div r0 16384
localget r1 3007
sub r0 r1
mul r0 100
div r0 16384
add r0 128
cmp r0 0
jge glass_low_64
set r0 0
label glass_low_64
cmp r0 255
jle glass_high_65
set r0 255
label glass_high_65
localset 2603 r0
label glass_lighting_done_60
localget r0 3000
mul r0 20
localget r1 3001
mul r1 10974
add r0 r1
localget r1 3002
mul r1 -12166
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_68
set r0 0
label diffuse_positive_68
mul r0 128
div r0 16384
add r0 75
localget r1 3003
mul r1 20
localget r2 3004
mul r2 10974
add r1 r2
localget r2 3005
mul r2 -12166
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_69
set r1 0
label highlight_positive_69
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_70
set r0 255
label intensity_bounded_70
localset 2404 r0
label body_lighting_done_66
localget r3 3030
cmp r3 0
jne body_lighting_done_71
localget r0 3000
mul r0 14114
localget r1 3001
mul r1 5535
add r0 r1
localget r1 3002
mul r1 -6211
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_73
set r0 0
label diffuse_positive_73
mul r0 128
div r0 16384
add r0 69
localget r1 3003
mul r1 14114
localget r2 3004
mul r2 5535
add r1 r2
localget r2 3005
mul r2 -6211
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_74
set r1 0
label highlight_positive_74
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_75
set r0 255
label intensity_bounded_75
localset 2405 r0
label body_lighting_done_71
localget r3 3030
cmp r3 2
je body_lighting_done_76
localget r0 3000
mul r0 -15872
localget r1 3001
mul r1 161
add r0 r1
localget r1 3002
mul r1 -4061
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_78
set r0 0
label diffuse_positive_78
mul r0 128
div r0 16384
add r0 64
localget r1 3003
mul r1 -15872
localget r2 3004
mul r2 161
add r1 r2
localget r2 3005
mul r2 -4061
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_79
set r1 0
label highlight_positive_79
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_80
set r0 255
label intensity_bounded_80
localset 2406 r0
label body_lighting_done_76
localget r3 3030
cmp r3 2
je body_lighting_done_81
localget r0 3000
mul r0 15915
localget r1 3001
mul r1 62
add r0 r1
localget r1 3002
mul r1 -3891
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_83
set r0 0
label diffuse_positive_83
mul r0 128
div r0 16384
add r0 64
localget r1 3003
mul r1 15915
localget r2 3004
mul r2 62
add r1 r2
localget r2 3005
mul r2 -3891
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_84
set r1 0
label highlight_positive_84
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_85
set r0 255
label intensity_bounded_85
localset 2407 r0
label body_lighting_done_81
localget r3 3030
cmp r3 0
jne body_lighting_done_86
localget r0 3000
mul r0 -3216
localget r1 3001
mul r1 15722
add r0 r1
localget r1 3002
mul r1 -3305
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_88
set r0 0
label diffuse_positive_88
mul r0 128
div r0 16384
add r0 79
localget r1 3003
mul r1 -3216
localget r2 3004
mul r2 15722
add r1 r2
localget r2 3005
mul r2 -3305
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_89
set r1 0
label highlight_positive_89
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_90
set r0 255
label intensity_bounded_90
localset 2408 r0
label body_lighting_done_86
localget r3 3030
cmp r3 0
jne body_lighting_done_91
localget r0 3000
mul r0 -5031
localget r1 3001
mul r1 15482
add r0 r1
localget r1 3002
mul r1 -1850
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_93
set r0 0
label diffuse_positive_93
mul r0 128
div r0 16384
add r0 79
localget r1 3003
mul r1 -5031
localget r2 3004
mul r2 15482
add r1 r2
localget r2 3005
mul r2 -1850
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_94
set r1 0
label highlight_positive_94
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_95
set r0 255
label intensity_bounded_95
localset 2409 r0
label body_lighting_done_91
localget r0 3000
mul r0 10
localget r1 3001
mul r1 16382
add r0 r1
localget r1 3002
mul r1 247
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_98
set r0 0
label diffuse_positive_98
mul r0 128
div r0 16384
add r0 80
localget r1 3003
mul r1 10
localget r2 3004
mul r2 16382
add r1 r2
localget r2 3005
mul r2 247
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_99
set r1 0
label highlight_positive_99
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_100
set r0 255
label intensity_bounded_100
localset 2410 r0
label body_lighting_done_96
localget r0 3006
mul r0 10
localget r1 3007
mul r1 16382
add r0 r1
localget r1 3008
mul r1 247
add r0 r1
div r0 16384
mul r0 2
mul r0 16382
div r0 16384
localget r1 3007
sub r0 r1
mul r0 100
div r0 16384
add r0 128
cmp r0 0
jge glass_low_101
set r0 0
label glass_low_101
cmp r0 255
jle glass_high_102
set r0 255
label glass_high_102
localset 2610 r0
label glass_lighting_done_97
localget r0 3000
mul r0 54
localget r1 3001
mul r1 11734
add r0 r1
localget r1 3002
mul r1 11434
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_105
set r0 0
label diffuse_positive_105
mul r0 128
div r0 16384
add r0 75
localget r1 3003
mul r1 54
localget r2 3004
mul r2 11734
add r1 r2
localget r2 3005
mul r2 11434
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_106
set r1 0
label highlight_positive_106
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_107
set r0 255
label intensity_bounded_107
localset 2411 r0
label body_lighting_done_103
localget r0 3000
mul r0 -120
localget r1 3001
mul r1 15093
add r0 r1
localget r1 3002
mul r1 6373
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_110
set r0 0
label diffuse_positive_110
mul r0 128
div r0 16384
add r0 79
localget r1 3003
mul r1 -120
localget r2 3004
mul r2 15093
add r1 r2
localget r2 3005
mul r2 6373
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_111
set r1 0
label highlight_positive_111
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_112
set r0 255
label intensity_bounded_112
localset 2412 r0
label body_lighting_done_108
localget r0 3006
mul r0 -120
localget r1 3007
mul r1 15093
add r0 r1
localget r1 3008
mul r1 6373
add r0 r1
div r0 16384
mul r0 2
mul r0 15093
div r0 16384
localget r1 3007
sub r0 r1
mul r0 100
div r0 16384
add r0 128
cmp r0 0
jge glass_low_113
set r0 0
label glass_low_113
cmp r0 255
jle glass_high_114
set r0 255
label glass_high_114
localset 2612 r0
label glass_lighting_done_109
localget r3 3030
cmp r3 0
jne body_lighting_done_115
localget r0 3000
mul r0 5537
localget r1 3001
mul r1 15417
add r0 r1
localget r1 3002
mul r1 277
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_117
set r0 0
label diffuse_positive_117
mul r0 128
div r0 16384
add r0 79
localget r1 3003
mul r1 5537
localget r2 3004
mul r2 15417
add r1 r2
localget r2 3005
mul r2 277
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_118
set r1 0
label highlight_positive_118
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_119
set r0 255
label intensity_bounded_119
localset 2413 r0
label body_lighting_done_115
localget r3 3030
cmp r3 2
je glass_lighting_done_116
localget r0 3006
mul r0 5537
localget r1 3007
mul r1 15417
add r0 r1
localget r1 3008
mul r1 277
add r0 r1
div r0 16384
mul r0 2
mul r0 15417
div r0 16384
localget r1 3007
sub r0 r1
mul r0 100
div r0 16384
add r0 128
cmp r0 0
jge glass_low_120
set r0 0
label glass_low_120
cmp r0 255
jle glass_high_121
set r0 255
label glass_high_121
localset 2613 r0
label glass_lighting_done_116
localget r3 3030
cmp r3 0
jne body_lighting_done_122
localget r0 3000
mul r0 2016
localget r1 3001
mul r1 15210
add r0 r1
localget r1 3002
mul r1 -5748
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_124
set r0 0
label diffuse_positive_124
mul r0 128
div r0 16384
add r0 79
localget r1 3003
mul r1 2016
localget r2 3004
mul r2 15210
add r1 r2
localget r2 3005
mul r2 -5748
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_125
set r1 0
label highlight_positive_125
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_126
set r0 255
label intensity_bounded_126
localset 2414 r0
label body_lighting_done_122
localget r0 3006
mul r0 2016
localget r1 3007
mul r1 15210
add r0 r1
localget r1 3008
mul r1 -5748
add r0 r1
div r0 16384
mul r0 2
mul r0 15210
div r0 16384
localget r1 3007
sub r0 r1
mul r0 100
div r0 16384
add r0 128
cmp r0 0
jge glass_low_127
set r0 0
label glass_low_127
cmp r0 255
jle glass_high_128
set r0 255
label glass_high_128
localset 2614 r0
label glass_lighting_done_123
localget r0 3000
mul r0 16384
localget r1 3001
mul r1 71
add r0 r1
localget r1 3002
mul r1 18
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_131
set r0 0
label diffuse_positive_131
mul r0 128
div r0 16384
add r0 64
localget r1 3003
mul r1 16384
localget r2 3004
mul r2 71
add r1 r2
localget r2 3005
mul r2 18
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_132
set r1 0
label highlight_positive_132
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_133
set r0 255
label intensity_bounded_133
localset 2415 r0
label body_lighting_done_129
localget r3 3030
cmp r3 2
je body_lighting_done_134
localget r0 3000
mul r0 -15542
localget r1 3001
mul r1 5184
add r0 r1
localget r1 3002
mul r1 152
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_136
set r0 0
label diffuse_positive_136
mul r0 128
div r0 16384
add r0 69
localget r1 3003
mul r1 -15542
localget r2 3004
mul r2 5184
add r1 r2
localget r2 3005
mul r2 152
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_137
set r1 0
label highlight_positive_137
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_138
set r0 255
label intensity_bounded_138
localset 2416 r0
label body_lighting_done_134
localget r0 3006
mul r0 -15542
localget r1 3007
mul r1 5184
add r0 r1
localget r1 3008
mul r1 152
add r0 r1
div r0 16384
mul r0 2
mul r0 5184
div r0 16384
localget r1 3007
sub r0 r1
mul r0 100
div r0 16384
add r0 128
cmp r0 0
jge glass_low_139
set r0 0
label glass_low_139
cmp r0 255
jle glass_high_140
set r0 255
label glass_high_140
localset 2616 r0
label glass_lighting_done_135
localget r3 3030
cmp r3 2
je body_lighting_done_141
localget r0 3000
mul r0 15486
localget r1 3001
mul r1 5348
add r0 r1
localget r1 3002
mul r1 111
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_143
set r0 0
label diffuse_positive_143
mul r0 128
div r0 16384
add r0 69
localget r1 3003
mul r1 15486
localget r2 3004
mul r2 5348
add r1 r2
localget r2 3005
mul r2 111
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_144
set r1 0
label highlight_positive_144
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_145
set r0 255
label intensity_bounded_145
localset 2417 r0
label body_lighting_done_141
localget r0 3006
mul r0 15486
localget r1 3007
mul r1 5348
add r0 r1
localget r1 3008
mul r1 111
add r0 r1
div r0 16384
mul r0 2
mul r0 5348
div r0 16384
localget r1 3007
sub r0 r1
mul r0 100
div r0 16384
add r0 128
cmp r0 0
jge glass_low_146
set r0 0
label glass_low_146
cmp r0 255
jle glass_high_147
set r0 255
label glass_high_147
localset 2617 r0
label glass_lighting_done_142
localget r0 3000
mul r0 -16384
localget r1 3001
mul r1 50
add r0 r1
localget r1 3002
mul r1 40
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_150
set r0 0
label diffuse_positive_150
mul r0 128
div r0 16384
add r0 64
localget r1 3003
mul r1 -16384
localget r2 3004
mul r2 50
add r1 r2
localget r2 3005
mul r2 40
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_151
set r1 0
label highlight_positive_151
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_152
set r0 255
label intensity_bounded_152
localset 2418 r0
label body_lighting_done_148
localget r3 3030
cmp r3 0
jne body_lighting_done_153
localget r0 3000
mul r0 -12536
localget r1 3001
mul r1 10548
add r0 r1
localget r1 3002
mul r1 109
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_155
set r0 0
label diffuse_positive_155
mul r0 128
div r0 16384
add r0 74
localget r1 3003
mul r1 -12536
localget r2 3004
mul r2 10548
add r1 r2
localget r2 3005
mul r2 109
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_156
set r1 0
label highlight_positive_156
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_157
set r0 255
label intensity_bounded_157
localset 2419 r0
label body_lighting_done_153
localget r0 3006
mul r0 -12536
localget r1 3007
mul r1 10548
add r0 r1
localget r1 3008
mul r1 109
add r0 r1
div r0 16384
mul r0 2
mul r0 10548
div r0 16384
localget r1 3007
sub r0 r1
mul r0 100
div r0 16384
add r0 128
cmp r0 0
jge glass_low_158
set r0 0
label glass_low_158
cmp r0 255
jle glass_high_159
set r0 255
label glass_high_159
localset 2619 r0
label glass_lighting_done_154
localget r3 3030
cmp r3 0
jne body_lighting_done_160
localget r0 3000
mul r0 12291
localget r1 3001
mul r1 10833
add r0 r1
localget r1 3002
mul r1 168
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_162
set r0 0
label diffuse_positive_162
mul r0 128
div r0 16384
add r0 75
localget r1 3003
mul r1 12291
localget r2 3004
mul r2 10833
add r1 r2
localget r2 3005
mul r2 168
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_163
set r1 0
label highlight_positive_163
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_164
set r0 255
label intensity_bounded_164
localset 2420 r0
label body_lighting_done_160
localget r0 3006
mul r0 12291
localget r1 3007
mul r1 10833
add r0 r1
localget r1 3008
mul r1 168
add r0 r1
div r0 16384
mul r0 2
mul r0 10833
div r0 16384
localget r1 3007
sub r0 r1
mul r0 100
div r0 16384
add r0 128
cmp r0 0
jge glass_low_165
set r0 0
label glass_low_165
cmp r0 255
jle glass_high_166
set r0 255
label glass_high_166
localset 2620 r0
label glass_lighting_done_161
localget r3 3030
cmp r3 0
jne body_lighting_done_167
localget r0 3000
mul r0 -11041
localget r1 3001
mul r1 11088
add r0 r1
localget r1 3002
mul r1 4856
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_169
set r0 0
label diffuse_positive_169
mul r0 128
div r0 16384
add r0 75
localget r1 3003
mul r1 -11041
localget r2 3004
mul r2 11088
add r1 r2
localget r2 3005
mul r2 4856
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_170
set r1 0
label highlight_positive_170
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_171
set r0 255
label intensity_bounded_171
localset 2421 r0
label body_lighting_done_167
localget r3 3030
cmp r3 0
jne body_lighting_done_172
localget r0 3000
mul r0 11383
localget r1 3001
mul r1 10631
add r0 r1
localget r1 3002
mul r1 5082
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_174
set r0 0
label diffuse_positive_174
mul r0 128
div r0 16384
add r0 74
localget r1 3003
mul r1 11383
localget r2 3004
mul r2 10631
add r1 r2
localget r2 3005
mul r2 5082
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_175
set r1 0
label highlight_positive_175
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_176
set r0 255
label intensity_bounded_176
localset 2422 r0
label body_lighting_done_172
localget r3 3030
cmp r3 0
jne body_lighting_done_177
localget r0 3000
mul r0 -14031
localget r1 3001
mul r1 6476
add r0 r1
localget r1 3002
mul r1 5443
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_179
set r0 0
label diffuse_positive_179
mul r0 128
div r0 16384
add r0 70
localget r1 3003
mul r1 -14031
localget r2 3004
mul r2 6476
add r1 r2
localget r2 3005
mul r2 5443
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_180
set r1 0
label highlight_positive_180
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_181
set r0 255
label intensity_bounded_181
localset 2423 r0
label body_lighting_done_177
localget r3 3030
cmp r3 0
jne body_lighting_done_182
localget r0 3000
mul r0 14057
localget r1 3001
mul r1 6081
add r0 r1
localget r1 3002
mul r1 5819
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_184
set r0 0
label diffuse_positive_184
mul r0 128
div r0 16384
add r0 70
localget r1 3003
mul r1 14057
localget r2 3004
mul r2 6081
add r1 r2
localget r2 3005
mul r2 5819
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_185
set r1 0
label highlight_positive_185
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_186
set r0 255
label intensity_bounded_186
localset 2424 r0
label body_lighting_done_182
localget r3 3030
cmp r3 0
jne body_lighting_done_187
localget r0 3000
mul r0 -3668
localget r1 3001
mul r1 15902
add r0 r1
localget r1 3002
mul r1 1457
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_189
set r0 0
label diffuse_positive_189
mul r0 128
div r0 16384
add r0 80
localget r1 3003
mul r1 -3668
localget r2 3004
mul r2 15902
add r1 r2
localget r2 3005
mul r2 1457
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_190
set r1 0
label highlight_positive_190
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_191
set r0 255
label intensity_bounded_191
localset 2425 r0
label body_lighting_done_187
localget r3 3030
cmp r3 0
jne body_lighting_done_192
localget r0 3000
mul r0 3588
localget r1 3001
mul r1 15913
add r0 r1
localget r1 3002
mul r1 1526
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_194
set r0 0
label diffuse_positive_194
mul r0 128
div r0 16384
add r0 80
localget r1 3003
mul r1 3588
localget r2 3004
mul r2 15913
add r1 r2
localget r2 3005
mul r2 1526
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_195
set r1 0
label highlight_positive_195
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_196
set r0 255
label intensity_bounded_196
localset 2426 r0
label body_lighting_done_192
localget r3 3030
cmp r3 0
jne glass_lighting_done_193
localget r0 3006
mul r0 3588
localget r1 3007
mul r1 15913
add r0 r1
localget r1 3008
mul r1 1526
add r0 r1
div r0 16384
mul r0 2
mul r0 15913
div r0 16384
localget r1 3007
sub r0 r1
mul r0 100
div r0 16384
add r0 128
cmp r0 0
jge glass_low_197
set r0 0
label glass_low_197
cmp r0 255
jle glass_high_198
set r0 255
label glass_high_198
localset 2626 r0
label glass_lighting_done_193
localget r3 3030
cmp r3 0
jne body_lighting_done_199
localget r0 3000
mul r0 -2808
localget r1 3001
mul r1 15981
add r0 r1
localget r1 3002
mul r1 2272
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_201
set r0 0
label diffuse_positive_201
mul r0 128
div r0 16384
add r0 80
localget r1 3003
mul r1 -2808
localget r2 3004
mul r2 15981
add r1 r2
localget r2 3005
mul r2 2272
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_202
set r1 0
label highlight_positive_202
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_203
set r0 255
label intensity_bounded_203
localset 2427 r0
label body_lighting_done_199
localget r3 3030
cmp r3 0
jne glass_lighting_done_200
localget r0 3006
mul r0 -2808
localget r1 3007
mul r1 15981
add r0 r1
localget r1 3008
mul r1 2272
add r0 r1
div r0 16384
mul r0 2
mul r0 15981
div r0 16384
localget r1 3007
sub r0 r1
mul r0 100
div r0 16384
add r0 128
cmp r0 0
jge glass_low_204
set r0 0
label glass_low_204
cmp r0 255
jle glass_high_205
set r0 255
label glass_high_205
localset 2627 r0
label glass_lighting_done_200
localget r3 3030
cmp r3 0
jne body_lighting_done_206
localget r0 3000
mul r0 -2008
localget r1 3001
mul r1 14844
add r0 r1
localget r1 3002
mul r1 6638
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_208
set r0 0
label diffuse_positive_208
mul r0 128
div r0 16384
add r0 78
localget r1 3003
mul r1 -2008
localget r2 3004
mul r2 14844
add r1 r2
localget r2 3005
mul r2 6638
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_209
set r1 0
label highlight_positive_209
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_210
set r0 255
label intensity_bounded_210
localset 2428 r0
label body_lighting_done_206
localget r0 3006
mul r0 -2008
localget r1 3007
mul r1 14844
add r0 r1
localget r1 3008
mul r1 6638
add r0 r1
div r0 16384
mul r0 2
mul r0 14844
div r0 16384
localget r1 3007
sub r0 r1
mul r0 100
div r0 16384
add r0 128
cmp r0 0
jge glass_low_211
set r0 0
label glass_low_211
cmp r0 255
jle glass_high_212
set r0 255
label glass_high_212
localset 2628 r0
label glass_lighting_done_207
localget r3 3030
cmp r3 0
jne body_lighting_done_213
localget r0 3000
mul r0 3130
localget r1 3001
mul r1 15906
add r0 r1
localget r1 3002
mul r1 2376
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_215
set r0 0
label diffuse_positive_215
mul r0 128
div r0 16384
add r0 80
localget r1 3003
mul r1 3130
localget r2 3004
mul r2 15906
add r1 r2
localget r2 3005
mul r2 2376
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_216
set r1 0
label highlight_positive_216
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_217
set r0 255
label intensity_bounded_217
localset 2429 r0
label body_lighting_done_213
localget r3 3030
cmp r3 1
je body_lighting_done_218
localget r0 3000
mul r0 2076
localget r1 3001
mul r1 14806
add r0 r1
localget r1 3002
mul r1 6701
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_220
set r0 0
label diffuse_positive_220
mul r0 128
div r0 16384
add r0 78
localget r1 3003
mul r1 2076
localget r2 3004
mul r2 14806
add r1 r2
localget r2 3005
mul r2 6701
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_221
set r1 0
label highlight_positive_221
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_222
set r0 255
label intensity_bounded_222
localset 2430 r0
label body_lighting_done_218
localget r3 3030
cmp r3 2
je glass_lighting_done_219
localget r0 3006
mul r0 2076
localget r1 3007
mul r1 14806
add r0 r1
localget r1 3008
mul r1 6701
add r0 r1
div r0 16384
mul r0 2
mul r0 14806
div r0 16384
localget r1 3007
sub r0 r1
mul r0 100
div r0 16384
add r0 128
cmp r0 0
jge glass_low_223
set r0 0
label glass_low_223
cmp r0 255
jle glass_high_224
set r0 255
label glass_high_224
localset 2630 r0
label glass_lighting_done_219
localget r3 3030
cmp r3 2
je body_lighting_done_225
localget r0 3000
mul r0 -15833
localget r1 3001
mul r1 -66
add r0 r1
localget r1 3002
mul r1 4211
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_227
set r0 0
label diffuse_positive_227
mul r0 128
div r0 16384
add r0 64
localget r1 3003
mul r1 -15833
localget r2 3004
mul r2 -66
add r1 r2
localget r2 3005
mul r2 4211
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_228
set r1 0
label highlight_positive_228
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_229
set r0 255
label intensity_bounded_229
localset 2431 r0
label body_lighting_done_225
localget r3 3030
cmp r3 2
je body_lighting_done_230
localget r0 3000
mul r0 15833
localget r1 3001
mul r1 -66
add r0 r1
localget r1 3002
mul r1 4211
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_232
set r0 0
label diffuse_positive_232
mul r0 128
div r0 16384
add r0 64
localget r1 3003
mul r1 15833
localget r2 3004
mul r2 -66
add r1 r2
localget r2 3005
mul r2 4211
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_233
set r1 0
label highlight_positive_233
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_234
set r0 255
label intensity_bounded_234
localset 2432 r0
label body_lighting_done_230
localget r3 3030
cmp r3 2
je body_lighting_done_235
localget r0 3000
mul r0 11
localget r1 3001
mul r1 127
add r0 r1
localget r1 3002
mul r1 16384
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_237
set r0 0
label diffuse_positive_237
mul r0 128
div r0 16384
add r0 64
localget r1 3003
mul r1 11
localget r2 3004
mul r2 127
add r1 r2
localget r2 3005
mul r2 16384
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_238
set r1 0
label highlight_positive_238
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_239
set r0 255
label intensity_bounded_239
localset 2433 r0
label body_lighting_done_235
localget r3 3030
cmp r3 0
jne body_lighting_done_240
localget r0 3000
mul r0 -38
localget r1 3001
mul r1 5750
add r0 r1
localget r1 3002
mul r1 15342
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_242
set r0 0
label diffuse_positive_242
mul r0 128
div r0 16384
add r0 70
localget r1 3003
mul r1 -38
localget r2 3004
mul r2 5750
add r1 r2
localget r2 3005
mul r2 15342
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_243
set r1 0
label highlight_positive_243
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_244
set r0 255
label intensity_bounded_244
localset 2434 r0
label body_lighting_done_240
localget r0 3000
mul r0 -6445
localget r1 3001
mul r1 0
add r0 r1
localget r1 3002
mul r1 15063
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_247
set r0 0
label diffuse_positive_247
mul r0 128
div r0 16384
add r0 64
localget r1 3003
mul r1 -6445
localget r2 3004
mul r2 0
add r1 r2
localget r2 3005
mul r2 15063
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_248
set r1 0
label highlight_positive_248
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_249
set r0 255
label intensity_bounded_249
localset 2435 r0
label body_lighting_done_245
localget r0 3000
mul r0 5670
localget r1 3001
mul r1 0
add r0 r1
localget r1 3002
mul r1 15372
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_252
set r0 0
label diffuse_positive_252
mul r0 128
div r0 16384
add r0 64
localget r1 3003
mul r1 5670
localget r2 3004
mul r2 0
add r1 r2
localget r2 3005
mul r2 15372
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_253
set r1 0
label highlight_positive_253
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_254
set r0 255
label intensity_bounded_254
localset 2436 r0
label body_lighting_done_250
localget r3 3030
cmp r3 2
je body_lighting_done_255
localget r0 3000
mul r0 0
localget r1 3001
mul r1 -16383
add r0 r1
localget r1 3002
mul r1 158
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_257
set r0 0
label diffuse_positive_257
mul r0 128
div r0 16384
add r0 48
localget r1 3003
mul r1 0
localget r2 3004
mul r2 -16383
add r1 r2
localget r2 3005
mul r2 158
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_258
set r1 0
label highlight_positive_258
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_259
set r0 255
label intensity_bounded_259
localset 2437 r0
label body_lighting_done_255
localget r3 3030
cmp r3 0
jne body_lighting_done_260
localget r0 3000
mul r0 -1968
localget r1 3001
mul r1 15353
add r0 r1
localget r1 3002
mul r1 -5370
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_262
set r0 0
label diffuse_positive_262
mul r0 128
div r0 16384
add r0 79
localget r1 3003
mul r1 -1968
localget r2 3004
mul r2 15353
add r1 r2
localget r2 3005
mul r2 -5370
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_263
set r1 0
label highlight_positive_263
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_264
set r0 255
label intensity_bounded_264
localset 2438 r0
label body_lighting_done_260
localget r0 3006
mul r0 -1968
localget r1 3007
mul r1 15353
add r0 r1
localget r1 3008
mul r1 -5370
add r0 r1
div r0 16384
mul r0 2
mul r0 15353
div r0 16384
localget r1 3007
sub r0 r1
mul r0 100
div r0 16384
add r0 128
cmp r0 0
jge glass_low_265
set r0 0
label glass_low_265
cmp r0 255
jle glass_high_266
set r0 255
label glass_high_266
localset 2638 r0
label glass_lighting_done_261
localget r3 3030
cmp r3 0
jne glass_lighting_done_268
localget r0 3006
mul r0 2111
localget r1 3007
mul r1 16005
add r0 r1
localget r1 3008
mul r1 -2799
add r0 r1
div r0 16384
mul r0 2
mul r0 16005
div r0 16384
localget r1 3007
sub r0 r1
mul r0 100
div r0 16384
add r0 128
cmp r0 0
jge glass_low_269
set r0 0
label glass_low_269
cmp r0 255
jle glass_high_270
set r0 255
label glass_high_270
localset 2639 r0
label glass_lighting_done_268
localget r3 3030
cmp r3 2
je glass_lighting_done_272
localget r0 3006
mul r0 -6369
localget r1 3007
mul r1 15094
add r0 r1
localget r1 3008
mul r1 179
add r0 r1
div r0 16384
mul r0 2
mul r0 15094
div r0 16384
localget r1 3007
sub r0 r1
mul r0 100
div r0 16384
add r0 128
cmp r0 0
jge glass_low_273
set r0 0
label glass_low_273
cmp r0 255
jle glass_high_274
set r0 255
label glass_high_274
localset 2640 r0
label glass_lighting_done_272
localget r3 3030
cmp r3 2
je body_lighting_done_275
localget r0 3000
mul r0 -3689
localget r1 3001
mul r1 -14118
add r0 r1
localget r1 3002
mul r1 -7449
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_277
set r0 0
label diffuse_positive_277
mul r0 128
div r0 16384
add r0 50
localget r1 3003
mul r1 -3689
localget r2 3004
mul r2 -14118
add r1 r2
localget r2 3005
mul r2 -7449
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_278
set r1 0
label highlight_positive_278
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_279
set r0 255
label intensity_bounded_279
localset 2441 r0
label body_lighting_done_275
localget r3 3030
cmp r3 2
je body_lighting_done_280
localget r0 3000
mul r0 3689
localget r1 3001
mul r1 -14118
add r0 r1
localget r1 3002
mul r1 -7449
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_282
set r0 0
label diffuse_positive_282
mul r0 128
div r0 16384
add r0 50
localget r1 3003
mul r1 3689
localget r2 3004
mul r2 -14118
add r1 r2
localget r2 3005
mul r2 -7449
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_283
set r1 0
label highlight_positive_283
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_284
set r0 255
label intensity_bounded_284
localset 2442 r0
label body_lighting_done_280
localget r3 3030
cmp r3 1
je body_lighting_done_285
localget r0 3000
mul r0 -2574
localget r1 3001
mul r1 12209
add r0 r1
localget r1 3002
mul r1 10619
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_287
set r0 0
label diffuse_positive_287
mul r0 128
div r0 16384
add r0 76
localget r1 3003
mul r1 -2574
localget r2 3004
mul r2 12209
add r1 r2
localget r2 3005
mul r2 10619
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_288
set r1 0
label highlight_positive_288
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_289
set r0 255
label intensity_bounded_289
localset 2443 r0
label body_lighting_done_285
localget r3 3030
cmp r3 0
jne body_lighting_done_290
localget r0 3000
mul r0 -2759
localget r1 3001
mul r1 12302
add r0 r1
localget r1 3002
mul r1 -10463
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_292
set r0 0
label diffuse_positive_292
mul r0 128
div r0 16384
add r0 76
localget r1 3003
mul r1 -2759
localget r2 3004
mul r2 12302
add r1 r2
localget r2 3005
mul r2 -10463
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_293
set r1 0
label highlight_positive_293
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_294
set r0 255
label intensity_bounded_294
localset 2444 r0
label body_lighting_done_290
localget r3 3030
cmp r3 0
jne body_lighting_done_295
localget r0 3000
mul r0 0
localget r1 3001
mul r1 -6070
add r0 r1
localget r1 3002
mul r1 -15218
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_297
set r0 0
label diffuse_positive_297
mul r0 128
div r0 16384
add r0 58
localget r1 3003
mul r1 0
localget r2 3004
mul r2 -6070
add r1 r2
localget r2 3005
mul r2 -15218
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_298
set r1 0
label highlight_positive_298
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_299
set r0 255
label intensity_bounded_299
localset 2445 r0
label body_lighting_done_295
localget r3 3030
cmp r3 0
jne body_lighting_done_300
localget r0 3000
mul r0 -2759
localget r1 3001
mul r1 -10463
add r0 r1
localget r1 3002
mul r1 -12302
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_302
set r0 0
label diffuse_positive_302
mul r0 128
div r0 16384
add r0 54
localget r1 3003
mul r1 -2759
localget r2 3004
mul r2 -10463
add r1 r2
localget r2 3005
mul r2 -12302
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_303
set r1 0
label highlight_positive_303
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_304
set r0 255
label intensity_bounded_304
localset 2446 r0
label body_lighting_done_300
localget r0 3000
mul r0 0
localget r1 3001
mul r1 -11604
add r0 r1
localget r1 3002
mul r1 -11567
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_307
set r0 0
label diffuse_positive_307
mul r0 128
div r0 16384
add r0 53
localget r1 3003
mul r1 0
localget r2 3004
mul r2 -11604
add r1 r2
localget r2 3005
mul r2 -11567
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_308
set r1 0
label highlight_positive_308
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_309
set r0 255
label intensity_bounded_309
localset 2447 r0
label body_lighting_done_305
localget r3 3030
cmp r3 0
jne body_lighting_done_310
localget r0 3000
mul r0 0
localget r1 3001
mul r1 -15122
add r0 r1
localget r1 3002
mul r1 -6305
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_312
set r0 0
label diffuse_positive_312
mul r0 128
div r0 16384
add r0 49
localget r1 3003
mul r1 0
localget r2 3004
mul r2 -15122
add r1 r2
localget r2 3005
mul r2 -6305
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_313
set r1 0
label highlight_positive_313
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_314
set r0 255
label intensity_bounded_314
localset 2448 r0
label body_lighting_done_310
localget r3 3030
cmp r3 0
jne body_lighting_done_315
localget r0 3000
mul r0 0
localget r1 3001
mul r1 -15122
add r0 r1
localget r1 3002
mul r1 6305
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_317
set r0 0
label diffuse_positive_317
mul r0 128
div r0 16384
add r0 49
localget r1 3003
mul r1 0
localget r2 3004
mul r2 -15122
add r1 r2
localget r2 3005
mul r2 6305
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_318
set r1 0
label highlight_positive_318
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_319
set r0 255
label intensity_bounded_319
localset 2449 r0
label body_lighting_done_315
localget r3 3030
cmp r3 0
jne body_lighting_done_320
localget r0 3000
mul r0 -2759
localget r1 3001
mul r1 -12302
add r0 r1
localget r1 3002
mul r1 10463
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_322
set r0 0
label diffuse_positive_322
mul r0 128
div r0 16384
add r0 52
localget r1 3003
mul r1 -2759
localget r2 3004
mul r2 -12302
add r1 r2
localget r2 3005
mul r2 10463
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_323
set r1 0
label highlight_positive_323
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_324
set r0 255
label intensity_bounded_324
localset 2450 r0
label body_lighting_done_320
localget r3 3030
cmp r3 0
jne body_lighting_done_325
localget r0 3000
mul r0 -2700
localget r1 3001
mul r1 -15190
add r0 r1
localget r1 3002
mul r1 5514
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_327
set r0 0
label diffuse_positive_327
mul r0 128
div r0 16384
add r0 49
localget r1 3003
mul r1 -2700
localget r2 3004
mul r2 -15190
add r1 r2
localget r2 3005
mul r2 5514
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_328
set r1 0
label highlight_positive_328
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_329
set r0 255
label intensity_bounded_329
localset 2451 r0
label body_lighting_done_325
localget r0 3000
mul r0 0
localget r1 3001
mul r1 -11567
add r0 r1
localget r1 3002
mul r1 11604
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_332
set r0 0
label diffuse_positive_332
mul r0 128
div r0 16384
add r0 53
localget r1 3003
mul r1 0
localget r2 3004
mul r2 -11567
add r1 r2
localget r2 3005
mul r2 11604
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_333
set r1 0
label highlight_positive_333
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_334
set r0 255
label intensity_bounded_334
localset 2452 r0
label body_lighting_done_330
localget r3 3030
cmp r3 0
jne body_lighting_done_335
localget r0 3000
mul r0 0
localget r1 3001
mul r1 -6305
add r0 r1
localget r1 3002
mul r1 15122
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_337
set r0 0
label diffuse_positive_337
mul r0 128
div r0 16384
add r0 58
localget r1 3003
mul r1 0
localget r2 3004
mul r2 -6305
add r1 r2
localget r2 3005
mul r2 15122
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_338
set r1 0
label highlight_positive_338
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_339
set r0 255
label intensity_bounded_339
localset 2453 r0
label body_lighting_done_335
localget r3 3030
cmp r3 0
jne body_lighting_done_340
localget r0 3000
mul r0 -10412
localget r1 3001
mul r1 6869
add r0 r1
localget r1 3002
mul r1 10622
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_342
set r0 0
label diffuse_positive_342
mul r0 128
div r0 16384
add r0 71
localget r1 3003
mul r1 -10412
localget r2 3004
mul r2 6869
add r1 r2
localget r2 3005
mul r2 10622
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_343
set r1 0
label highlight_positive_343
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_344
set r0 255
label intensity_bounded_344
localset 2454 r0
label body_lighting_done_340
localget r3 3030
cmp r3 0
jne body_lighting_done_345
localget r0 3000
mul r0 -12050
localget r1 3001
mul r1 9611
add r0 r1
localget r1 3002
mul r1 -5555
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_347
set r0 0
label diffuse_positive_347
mul r0 128
div r0 16384
add r0 73
localget r1 3003
mul r1 -12050
localget r2 3004
mul r2 9611
add r1 r2
localget r2 3005
mul r2 -5555
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_348
set r1 0
label highlight_positive_348
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_349
set r0 255
label intensity_bounded_349
localset 2455 r0
label body_lighting_done_345
localget r3 3030
cmp r3 0
jne body_lighting_done_350
localget r0 3000
mul r0 -8564
localget r1 3001
mul r1 11418
add r0 r1
localget r1 3002
mul r1 -8045
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_352
set r0 0
label diffuse_positive_352
mul r0 128
div r0 16384
add r0 75
localget r1 3003
mul r1 -8564
localget r2 3004
mul r2 11418
add r1 r2
localget r2 3005
mul r2 -8045
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_353
set r1 0
label highlight_positive_353
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_354
set r0 255
label intensity_bounded_354
localset 2456 r0
label body_lighting_done_350
localget r3 3030
cmp r3 0
jne body_lighting_done_355
localget r0 3000
mul r0 -11892
localget r1 3001
mul r1 6396
add r0 r1
localget r1 3002
mul r1 -9279
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_357
set r0 0
label diffuse_positive_357
mul r0 128
div r0 16384
add r0 70
localget r1 3003
mul r1 -11892
localget r2 3004
mul r2 6396
add r1 r2
localget r2 3005
mul r2 -9279
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_358
set r1 0
label highlight_positive_358
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_359
set r0 255
label intensity_bounded_359
localset 2457 r0
label body_lighting_done_355
localget r3 3030
cmp r3 0
jne body_lighting_done_360
localget r0 3000
mul r0 -10412
localget r1 3001
mul r1 -6869
add r0 r1
localget r1 3002
mul r1 -10622
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_362
set r0 0
label diffuse_positive_362
mul r0 128
div r0 16384
add r0 57
localget r1 3003
mul r1 -10412
localget r2 3004
mul r2 -6869
add r1 r2
localget r2 3005
mul r2 -10622
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_363
set r1 0
label highlight_positive_363
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_364
set r0 255
label intensity_bounded_364
localset 2458 r0
label body_lighting_done_360
localget r3 3030
cmp r3 0
jne body_lighting_done_365
localget r0 3000
mul r0 -11892
localget r1 3001
mul r1 -9279
add r0 r1
localget r1 3002
mul r1 -6396
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_367
set r0 0
label diffuse_positive_367
mul r0 128
div r0 16384
add r0 55
localget r1 3003
mul r1 -11892
localget r2 3004
mul r2 -9279
add r1 r2
localget r2 3005
mul r2 -6396
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_368
set r1 0
label highlight_positive_368
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_369
set r0 255
label intensity_bounded_369
localset 2459 r0
label body_lighting_done_365
localget r3 3030
cmp r3 0
jne body_lighting_done_370
localget r0 3000
mul r0 -15907
localget r1 3001
mul r1 -3923
add r0 r1
localget r1 3002
mul r1 -55
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_372
set r0 0
label diffuse_positive_372
mul r0 128
div r0 16384
add r0 60
localget r1 3003
mul r1 -15907
localget r2 3004
mul r2 -3923
add r1 r2
localget r2 3005
mul r2 -55
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_373
set r1 0
label highlight_positive_373
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_374
set r0 255
label intensity_bounded_374
localset 2460 r0
label body_lighting_done_370
localget r3 3030
cmp r3 0
jne body_lighting_done_375
localget r0 3000
mul r0 -12050
localget r1 3001
mul r1 -9611
add r0 r1
localget r1 3002
mul r1 5555
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_377
set r0 0
label diffuse_positive_377
mul r0 128
div r0 16384
add r0 55
localget r1 3003
mul r1 -12050
localget r2 3004
mul r2 -9611
add r1 r2
localget r2 3005
mul r2 5555
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_378
set r1 0
label highlight_positive_378
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_379
set r0 255
label intensity_bounded_379
localset 2461 r0
label body_lighting_done_375
localget r3 3030
cmp r3 0
jne body_lighting_done_380
localget r0 3000
mul r0 -8564
localget r1 3001
mul r1 -11418
add r0 r1
localget r1 3002
mul r1 8045
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_382
set r0 0
label diffuse_positive_382
mul r0 128
div r0 16384
add r0 53
localget r1 3003
mul r1 -8564
localget r2 3004
mul r2 -11418
add r1 r2
localget r2 3005
mul r2 8045
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_383
set r1 0
label highlight_positive_383
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_384
set r0 255
label intensity_bounded_384
localset 2462 r0
label body_lighting_done_380
localget r3 3030
cmp r3 0
jne body_lighting_done_385
localget r0 3000
mul r0 -11892
localget r1 3001
mul r1 -6396
add r0 r1
localget r1 3002
mul r1 9279
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_387
set r0 0
label diffuse_positive_387
mul r0 128
div r0 16384
add r0 58
localget r1 3003
mul r1 -11892
localget r2 3004
mul r2 -6396
add r1 r2
localget r2 3005
mul r2 9279
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_388
set r1 0
label highlight_positive_388
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_389
set r0 255
label intensity_bounded_389
localset 2463 r0
label body_lighting_done_385
localget r3 3030
cmp r3 0
jne body_lighting_done_390
localget r0 3000
mul r0 2343
localget r1 3001
mul r1 12417
add r0 r1
localget r1 3002
mul r1 10429
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_392
set r0 0
label diffuse_positive_392
mul r0 128
div r0 16384
add r0 76
localget r1 3003
mul r1 2343
localget r2 3004
mul r2 12417
add r1 r2
localget r2 3005
mul r2 10429
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_393
set r1 0
label highlight_positive_393
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_394
set r0 255
label intensity_bounded_394
localset 2464 r0
label body_lighting_done_390
localget r3 3030
cmp r3 0
jne body_lighting_done_395
localget r0 3000
mul r0 2759
localget r1 3001
mul r1 12302
add r0 r1
localget r1 3002
mul r1 -10463
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_397
set r0 0
label diffuse_positive_397
mul r0 128
div r0 16384
add r0 76
localget r1 3003
mul r1 2759
localget r2 3004
mul r2 12302
add r1 r2
localget r2 3005
mul r2 -10463
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_398
set r1 0
label highlight_positive_398
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_399
set r0 255
label intensity_bounded_399
localset 2465 r0
label body_lighting_done_395
localget r3 3030
cmp r3 0
jne body_lighting_done_400
localget r0 3000
mul r0 2759
localget r1 3001
mul r1 -10463
add r0 r1
localget r1 3002
mul r1 -12302
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_402
set r0 0
label diffuse_positive_402
mul r0 128
div r0 16384
add r0 54
localget r1 3003
mul r1 2759
localget r2 3004
mul r2 -10463
add r1 r2
localget r2 3005
mul r2 -12302
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_403
set r1 0
label highlight_positive_403
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_404
set r0 255
label intensity_bounded_404
localset 2466 r0
label body_lighting_done_400
localget r3 3030
cmp r3 0
jne body_lighting_done_405
localget r0 3000
mul r0 2700
localget r1 3001
mul r1 -15190
add r0 r1
localget r1 3002
mul r1 5514
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_407
set r0 0
label diffuse_positive_407
mul r0 128
div r0 16384
add r0 49
localget r1 3003
mul r1 2700
localget r2 3004
mul r2 -15190
add r1 r2
localget r2 3005
mul r2 5514
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_408
set r1 0
label highlight_positive_408
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_409
set r0 255
label intensity_bounded_409
localset 2467 r0
label body_lighting_done_405
localget r3 3030
cmp r3 0
jne body_lighting_done_410
localget r0 3000
mul r0 2759
localget r1 3001
mul r1 -12302
add r0 r1
localget r1 3002
mul r1 10463
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_412
set r0 0
label diffuse_positive_412
mul r0 128
div r0 16384
add r0 52
localget r1 3003
mul r1 2759
localget r2 3004
mul r2 -12302
add r1 r2
localget r2 3005
mul r2 10463
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_413
set r1 0
label highlight_positive_413
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_414
set r0 255
label intensity_bounded_414
localset 2468 r0
label body_lighting_done_410
localget r3 3030
cmp r3 0
jne body_lighting_done_415
localget r0 3000
mul r0 10412
localget r1 3001
mul r1 6869
add r0 r1
localget r1 3002
mul r1 10622
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_417
set r0 0
label diffuse_positive_417
mul r0 128
div r0 16384
add r0 71
localget r1 3003
mul r1 10412
localget r2 3004
mul r2 6869
add r1 r2
localget r2 3005
mul r2 10622
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_418
set r1 0
label highlight_positive_418
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_419
set r0 255
label intensity_bounded_419
localset 2469 r0
label body_lighting_done_415
localget r3 3030
cmp r3 0
jne body_lighting_done_420
localget r0 3000
mul r0 12050
localget r1 3001
mul r1 9611
add r0 r1
localget r1 3002
mul r1 -5555
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_422
set r0 0
label diffuse_positive_422
mul r0 128
div r0 16384
add r0 73
localget r1 3003
mul r1 12050
localget r2 3004
mul r2 9611
add r1 r2
localget r2 3005
mul r2 -5555
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_423
set r1 0
label highlight_positive_423
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_424
set r0 255
label intensity_bounded_424
localset 2470 r0
label body_lighting_done_420
localget r3 3030
cmp r3 0
jne body_lighting_done_425
localget r0 3000
mul r0 8564
localget r1 3001
mul r1 11418
add r0 r1
localget r1 3002
mul r1 -8045
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_427
set r0 0
label diffuse_positive_427
mul r0 128
div r0 16384
add r0 75
localget r1 3003
mul r1 8564
localget r2 3004
mul r2 11418
add r1 r2
localget r2 3005
mul r2 -8045
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_428
set r1 0
label highlight_positive_428
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_429
set r0 255
label intensity_bounded_429
localset 2471 r0
label body_lighting_done_425
localget r3 3030
cmp r3 0
jne body_lighting_done_430
localget r0 3000
mul r0 11892
localget r1 3001
mul r1 6396
add r0 r1
localget r1 3002
mul r1 -9279
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_432
set r0 0
label diffuse_positive_432
mul r0 128
div r0 16384
add r0 70
localget r1 3003
mul r1 11892
localget r2 3004
mul r2 6396
add r1 r2
localget r2 3005
mul r2 -9279
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_433
set r1 0
label highlight_positive_433
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_434
set r0 255
label intensity_bounded_434
localset 2472 r0
label body_lighting_done_430
localget r3 3030
cmp r3 0
jne body_lighting_done_435
localget r0 3000
mul r0 10412
localget r1 3001
mul r1 -6869
add r0 r1
localget r1 3002
mul r1 -10622
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_437
set r0 0
label diffuse_positive_437
mul r0 128
div r0 16384
add r0 57
localget r1 3003
mul r1 10412
localget r2 3004
mul r2 -6869
add r1 r2
localget r2 3005
mul r2 -10622
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_438
set r1 0
label highlight_positive_438
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_439
set r0 255
label intensity_bounded_439
localset 2473 r0
label body_lighting_done_435
localget r3 3030
cmp r3 0
jne body_lighting_done_440
localget r0 3000
mul r0 11892
localget r1 3001
mul r1 -9279
add r0 r1
localget r1 3002
mul r1 -6396
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_442
set r0 0
label diffuse_positive_442
mul r0 128
div r0 16384
add r0 55
localget r1 3003
mul r1 11892
localget r2 3004
mul r2 -9279
add r1 r2
localget r2 3005
mul r2 -6396
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_443
set r1 0
label highlight_positive_443
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_444
set r0 255
label intensity_bounded_444
localset 2474 r0
label body_lighting_done_440
localget r3 3030
cmp r3 0
jne body_lighting_done_445
localget r0 3000
mul r0 15907
localget r1 3001
mul r1 -3923
add r0 r1
localget r1 3002
mul r1 -55
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_447
set r0 0
label diffuse_positive_447
mul r0 128
div r0 16384
add r0 60
localget r1 3003
mul r1 15907
localget r2 3004
mul r2 -3923
add r1 r2
localget r2 3005
mul r2 -55
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_448
set r1 0
label highlight_positive_448
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_449
set r0 255
label intensity_bounded_449
localset 2475 r0
label body_lighting_done_445
localget r3 3030
cmp r3 0
jne body_lighting_done_450
localget r0 3000
mul r0 12050
localget r1 3001
mul r1 -9611
add r0 r1
localget r1 3002
mul r1 5555
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_452
set r0 0
label diffuse_positive_452
mul r0 128
div r0 16384
add r0 55
localget r1 3003
mul r1 12050
localget r2 3004
mul r2 -9611
add r1 r2
localget r2 3005
mul r2 5555
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_453
set r1 0
label highlight_positive_453
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_454
set r0 255
label intensity_bounded_454
localset 2476 r0
label body_lighting_done_450
localget r3 3030
cmp r3 0
jne body_lighting_done_455
localget r0 3000
mul r0 8564
localget r1 3001
mul r1 -11418
add r0 r1
localget r1 3002
mul r1 8045
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_457
set r0 0
label diffuse_positive_457
mul r0 128
div r0 16384
add r0 53
localget r1 3003
mul r1 8564
localget r2 3004
mul r2 -11418
add r1 r2
localget r2 3005
mul r2 8045
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_458
set r1 0
label highlight_positive_458
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_459
set r0 255
label intensity_bounded_459
localset 2477 r0
label body_lighting_done_455
localget r3 3030
cmp r3 0
jne body_lighting_done_460
localget r0 3000
mul r0 11892
localget r1 3001
mul r1 -6396
add r0 r1
localget r1 3002
mul r1 9279
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_462
set r0 0
label diffuse_positive_462
mul r0 128
div r0 16384
add r0 58
localget r1 3003
mul r1 11892
localget r2 3004
mul r2 -6396
add r1 r2
localget r2 3005
mul r2 9279
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_463
set r1 0
label highlight_positive_463
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_464
set r0 255
label intensity_bounded_464
localset 2478 r0
label body_lighting_done_460
localget r3 3030
cmp r3 2
jne body_lighting_done_465
localget r0 3000
mul r0 -11211
localget r1 3001
mul r1 0
add r0 r1
localget r1 3002
mul r1 11948
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_467
set r0 0
label diffuse_positive_467
mul r0 128
div r0 16384
add r0 64
localget r1 3003
mul r1 -11211
localget r2 3004
mul r2 0
add r1 r2
localget r2 3005
mul r2 11948
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_468
set r1 0
label highlight_positive_468
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_469
set r0 255
label intensity_bounded_469
localset 2479 r0
label body_lighting_done_465
localget r3 3030
cmp r3 2
jne body_lighting_done_472
localget r0 3000
mul r0 11794
localget r1 3001
mul r1 0
add r0 r1
localget r1 3002
mul r1 11373
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_474
set r0 0
label diffuse_positive_474
mul r0 128
div r0 16384
add r0 64
localget r1 3003
mul r1 11794
localget r2 3004
mul r2 0
add r1 r2
localget r2 3005
mul r2 11373
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_475
set r1 0
label highlight_positive_475
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_476
set r0 255
label intensity_bounded_476
localset 2481 r0
label body_lighting_done_472
localget r3 3030
cmp r3 1
jne body_lighting_done_479
localget r0 3000
mul r0 -3028
localget r1 3001
mul r1 9083
add r0 r1
localget r1 3002
mul r1 13295
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_481
set r0 0
label diffuse_positive_481
mul r0 128
div r0 16384
add r0 73
localget r1 3003
mul r1 -3028
localget r2 3004
mul r2 9083
add r1 r2
localget r2 3005
mul r2 13295
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_482
set r1 0
label highlight_positive_482
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
cmp r0 255
jle intensity_bounded_483
set r0 255
label intensity_bounded_483
localset 2483 r0
label body_lighting_done_479
label lighting_table_ready
localget r0 11
cmp r0 4
jge wheel_motion_ready
localget r0 142
cmp r0 2
je wheel_motion_ready
localget r0 11
cmp r0 0
jne wheel_rival_distance
load32 r0 278
jmp wheel_distance_ready
label wheel_rival_distance
localget r7 11
sub r7 1
mul r7 32
add r7 6016
load32 r0 $r7
label wheel_distance_ready
mod r0 214
mul r0 4096
div r0 214
mov r5 r0
add r5 0
mod r5 4096
cmp r5 0
jge sin_negative_484
add r5 4096
label sin_negative_484
mov r7 r5
mod r7 2048
set r8 2048
sub r8 r7
mul r7 r8
mov r8 r7
mul r8 4
set r6 20971520
sub r6 r8
mul r7 262144
div r7 r6
cmp r5 2048
jlt sin_done_485
mul r7 -1
label sin_done_485
mov r5 r7
mov r8 r5
mov r9 r8
add r9 32768
localset 58 r9
mov r6 r0
add r6 1024
mod r6 4096
cmp r6 0
jge sin_negative_486
add r6 4096
label sin_negative_486
mov r7 r6
mod r7 2048
set r8 2048
sub r8 r7
mul r7 r8
mov r8 r7
mul r8 4
set r5 20971520
sub r5 r8
mul r7 262144
div r7 r5
cmp r6 2048
jlt sin_done_487
mul r7 -1
label sin_done_487
mov r6 r7
localget r5 58
sub r5 32768
localset 3040 r5
localset 3041 r6
localget r0 11
cmp r0 0
jne wheel_steer_neutral
load16 r0 256
sub r0 1000
mul r0 320
div r0 1000
add r0 4096
mod r0 4096
mov r5 r0
add r5 0
mod r5 4096
cmp r5 0
jge sin_negative_488
add r5 4096
label sin_negative_488
mov r7 r5
mod r7 2048
set r8 2048
sub r8 r7
mul r7 r8
mov r8 r7
mul r8 4
set r6 20971520
sub r6 r8
mul r7 262144
div r7 r6
cmp r5 2048
jlt sin_done_489
mul r7 -1
label sin_done_489
mov r5 r7
mov r8 r5
mov r9 r8
add r9 32768
localset 58 r9
mov r6 r0
add r6 1024
mod r6 4096
cmp r6 0
jge sin_negative_490
add r6 4096
label sin_negative_490
mov r7 r6
mod r7 2048
set r8 2048
sub r8 r7
mul r7 r8
mov r8 r7
mul r8 4
set r5 20971520
sub r5 r8
mul r7 262144
div r7 r5
cmp r6 2048
jlt sin_done_491
mul r7 -1
label sin_done_491
mov r6 r7
localget r5 58
sub r5 32768
localset 3042 r5
localset 3043 r6
jmp wheel_motion_ready
label wheel_steer_neutral
localset 3042 0
localset 3043 16384
label wheel_motion_ready
localset 143 0
label actor_vertex
localget r8 132
mov r9 r8
add r9 512
localget r9 r9
div r9 512
cmp r9 r8
je vertex_transform_position
add r9 2048
meshread r0 r1 r2 r9
jmp vertex_publish_position
label vertex_transform_position
meshread r0 r1 r2 r8
cmp r8 279
jlt wheel_next_model_494
cmp r8 795
jge wheel_next_model_494
cmp r8 408
jge wheel_next_wheel_495
localset 3044 -88
localset 3045 -142
localset 3046 0
jmp wheel_transform_492
label wheel_next_wheel_495
cmp r8 537
jge wheel_next_wheel_496
localset 3044 88
localset 3045 -142
localset 3046 0
jmp wheel_transform_492
label wheel_next_wheel_496
cmp r8 666
jge wheel_next_wheel_497
localset 3044 -88
localset 3045 138
localset 3046 1
jmp wheel_transform_492
label wheel_next_wheel_497
cmp r8 795
jge wheel_next_wheel_498
localset 3044 88
localset 3045 138
localset 3046 1
jmp wheel_transform_492
label wheel_next_wheel_498
label wheel_next_model_494
cmp r8 1109
jlt wheel_next_model_499
cmp r8 1309
jge wheel_next_model_499
cmp r8 1159
jge wheel_next_wheel_500
localset 3044 -88
localset 3045 -142
localset 3046 0
jmp wheel_transform_492
label wheel_next_wheel_500
cmp r8 1209
jge wheel_next_wheel_501
localset 3044 88
localset 3045 -142
localset 3046 0
jmp wheel_transform_492
label wheel_next_wheel_501
cmp r8 1259
jge wheel_next_wheel_502
localset 3044 -88
localset 3045 138
localset 3046 1
jmp wheel_transform_492
label wheel_next_wheel_502
cmp r8 1309
jge wheel_next_wheel_503
localset 3044 88
localset 3045 138
localset 3046 1
jmp wheel_transform_492
label wheel_next_wheel_503
label wheel_next_model_499
jmp wheel_transform_done_493
label wheel_transform_492
sub r1 34
localget r9 3045
sub r2 r9
localget r5 3041
localget r6 3040
mov r7 r1
mul r7 r5
mov r9 r2
mul r9 r6
sub r7 r9
div r7 16384
mul r1 r6
mul r2 r5
add r1 r2
div r1 16384
mov r2 r1
localget r9 3045
add r2 r9
mov r1 r7
add r1 34
localget r9 3046
cmp r9 0
je wheel_rear_504
localget r9 3044
sub r0 r9
localget r9 3045
sub r2 r9
localget r5 3042
localget r6 3043
mov r7 r0
mul r7 r6
mov r9 r2
mul r9 r5
add r7 r9
div r7 16384
mov r9 r2
mul r9 r6
mov r10 r0
mul r10 r5
sub r9 r10
div r9 16384
mov r0 r7
localget r10 3044
add r0 r10
mov r2 r9
localget r10 3045
add r2 r10
label wheel_rear_504
label wheel_transform_done_493
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
label vertex_publish_position
localget r8 132
add r8 2048
meshvertex r8 r0 r1 r2
mov r9 r8
sub r9 1536
localget r9 r9
mod r9 512
cmp r9 384
jge vertex_glass_lookup
cmp r9 256
jge vertex_lighting_lookup
jmp vertex_shade_ready
label vertex_glass_lookup
add r9 2216
localget r9 r9
jmp vertex_shade_ready
label vertex_lighting_lookup
add r9 2144
localget r9 r9
label vertex_shade_ready
meshshade r8 r9
sub r8 2047
mov r9 r8
localset 132 r9
localget r0 134
cmp r8 r0
jlt actor_vertex
localget r0 11
cmp r0 4
jge actor_geometry_ready
localget r0 143
cmp r0 1
je actor_geometry_ready
localset 143 1
set r0 1511
mov r9 r0
localset 132 r9
set r0 1528
mov r9 r0
localset 134 r9
jmp actor_vertex
label actor_geometry_ready
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
cmp r12 2
je emit_far
localget r12 11
cmp r12 0
je emit_high
jmp emit_medium
label emit_hood
localget r12 126
meshfacegradient 2183 2192 2193 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2183 2193 2184 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2184 2193 2194 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2184 2194 2185 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2185 2194 2195 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2185 2195 2186 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2186 2195 2196 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2186 2196 2187 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2187 2196 2197 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2187 2197 2188 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2188 2197 2198 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2188 2198 2189 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2192 2201 2202 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2192 2202 2193 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2193 2202 2203 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2193 2203 2194 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2194 2203 2204 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2194 2204 2195 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2195 2204 2205 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2195 2205 2196 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2196 2205 2206 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2196 2206 2197 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2197 2206 2207 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2197 2207 2198 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2201 2210 2211 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2201 2211 2202 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2202 2211 2212 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2202 2212 2203 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2203 2212 2213 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2203 2213 2204 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2204 2213 2214 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2204 2214 2205 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2205 2214 2215 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2205 2215 2206 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2206 2215 2216 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2206 2216 2207 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2210 2219 2220 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2210 2220 2211 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2211 2220 2221 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2211 2221 2212 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2212 2221 2222 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2212 2222 2213 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2213 2222 2223 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2213 2223 2214 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2214 2223 2224 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2214 2224 2215 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2215 2224 2225 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2215 2225 2216 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2219 2228 2229 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2219 2229 2220 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2220 2229 2230 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2220 2230 2221 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2221 2230 2231 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2221 2231 2222 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2222 2231 2232 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2222 2232 2223 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2223 2232 2233 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2223 2233 2224 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2224 2233 2234 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2224 2234 2225 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2228 2237 2238 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2228 2238 2229 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2229 2238 2239 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2229 2239 2230 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2230 2239 2240 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2230 2240 2231 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2231 2240 2241 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2231 2241 2232 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2232 2241 2242 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2232 2242 2233 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2233 2242 2243 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2233 2243 2234 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2237 2246 2247 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2237 2247 2238 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2238 2247 2248 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2238 2248 2239 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2239 2248 2249 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2239 2249 2240 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2240 2249 2250 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2240 2250 2241 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2241 2250 2251 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2241 2251 2242 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2242 2251 2252 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2242 2252 2243 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2246 2255 2256 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2246 2256 2247 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2247 2256 2257 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2247 2257 2248 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2248 2257 2258 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2248 2258 2249 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2249 2258 2259 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2249 2259 2250 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2250 2259 2260 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2250 2260 2251 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2251 2260 2261 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2251 2261 2252 r12 24 r9 r10 r11 60
meshface 2935 2936 2937 226 r9 r10 r11 60
meshface 2935 2937 2938 226 r9 r10 r11 60
meshface 2939 2940 2941 226 r9 r10 r11 60
meshface 2939 2942 2940 226 r9 r10 r11 60
jmp next_actor
label emit_high
localget r12 126
meshfacegradient 2048 2049 2050 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2048 2051 2052 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2052 2051 2053 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2052 2054 2055 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2055 2054 2056 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2055 2056 2057 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2057 2056 2058 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2057 2058 2059 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2059 2058 2060 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2059 2060 2061 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2061 2060 2062 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2061 2062 2063 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2048 2064 2065 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2048 2066 2064 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2063 2067 2068 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2063 2068 2069 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2070 2071 2072 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2070 2072 2050 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2050 2072 2073 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2074 2073 2075 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2075 2073 2076 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2077 2076 2078 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2078 2076 2079 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2078 2079 2080 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2080 2079 2081 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2082 2081 2060 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2060 2081 2083 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2060 2083 2084 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2065 2085 2086 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2065 2064 2085 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2067 2087 2088 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2067 2088 2068 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2089 2090 2091 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2089 2091 2072 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2072 2091 2092 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2072 2092 2073 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2073 2092 2093 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2073 2093 2076 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2076 2093 2094 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2076 2094 2079 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2079 2094 2095 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2079 2095 2081 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2081 2095 2096 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2081 2097 2098 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2086 2099 2090 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2086 2085 2099 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2087 2096 2100 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2087 2100 2088 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2090 2101 2102 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2090 2102 2091 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2091 2102 2103 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2091 2103 2092 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2092 2103 2104 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2092 2104 2093 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2093 2104 2105 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2093 2105 2094 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2094 2105 2106 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2094 2106 2095 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2095 2106 2107 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2095 2107 2096 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2090 2108 2101 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2090 2099 2108 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2109 2107 2110 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2109 2110 2100 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2101 2111 2112 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2101 2112 2102 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2102 2112 2113 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2102 2113 2103 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2103 2113 2114 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2103 2114 2104 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2104 2114 2115 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2104 2115 2105 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2105 2115 2116 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2105 2116 2106 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2106 2116 2117 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2106 2117 2107 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2101 2118 2111 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2101 2108 2118 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2107 2117 2119 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2107 2119 2110 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2111 2120 2121 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2111 2121 2112 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2112 2121 2122 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2112 2122 2113 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2113 2122 2123 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2113 2123 2114 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2114 2123 2124 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2114 2124 2115 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2115 2124 2125 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2115 2125 2116 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2116 2125 2126 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2116 2126 2117 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2111 2127 2120 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2111 2118 2127 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2117 2126 2128 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2117 2128 2119 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2120 2129 2130 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2120 2130 2121 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2121 2130 2131 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2121 2131 2122 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2122 2131 2132 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2122 2132 2123 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2123 2132 2133 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2123 2133 2124 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2124 2133 2134 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2124 2134 2125 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2125 2134 2135 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2125 2135 2126 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2120 2136 2129 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2120 2127 2136 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2126 2135 2137 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2126 2137 2128 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2129 2138 2139 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2129 2139 2130 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2130 2139 2140 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2130 2140 2131 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2131 2140 2141 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2131 2141 2132 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2132 2141 2142 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2132 2142 2133 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2133 2142 2143 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2133 2143 2134 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2134 2143 2144 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2134 2144 2135 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2129 2145 2138 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2129 2136 2145 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2135 2144 2146 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2135 2146 2137 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2138 2147 2148 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2138 2148 2139 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2139 2148 2149 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2139 2149 2140 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2140 2149 2150 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2140 2150 2141 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2141 2150 2151 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2141 2151 2142 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2142 2151 2152 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2142 2152 2143 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2143 2152 2153 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2143 2153 2144 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2138 2154 2147 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2138 2145 2154 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2144 2153 2155 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2144 2155 2146 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2147 2156 2157 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2147 2157 2148 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2148 2157 2158 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2148 2158 2149 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2149 2158 2159 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2149 2159 2150 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2150 2159 2160 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2150 2160 2151 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2151 2160 2161 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2151 2161 2152 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2152 2161 2162 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2152 2162 2153 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2147 2163 2156 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2147 2154 2163 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2153 2162 2164 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2153 2164 2155 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2156 2165 2166 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2156 2166 2157 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2157 2166 2167 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2157 2167 2158 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2158 2167 2168 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2158 2168 2159 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2159 2168 2169 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2159 2169 2160 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2160 2169 2170 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2160 2170 2161 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2161 2170 2171 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2161 2171 2162 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2156 2172 2165 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2156 2163 2172 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2162 2171 2173 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2162 2173 2164 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2165 2174 2175 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2165 2175 2166 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2166 2175 2176 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2166 2176 2167 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2167 2176 2177 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2167 2177 2168 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2168 2177 2178 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2168 2178 2169 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2169 2178 2179 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2169 2179 2170 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2170 2179 2180 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2170 2180 2171 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2165 2181 2174 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2165 2172 2181 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2171 2180 2182 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2171 2182 2173 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2174 2183 2184 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2174 2184 2175 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2175 2184 2185 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2175 2185 2176 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2176 2185 2186 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2176 2186 2177 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2177 2186 2187 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2177 2187 2178 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2178 2187 2188 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2178 2188 2179 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2179 2188 2189 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2179 2189 2180 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2174 2190 2183 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2174 2181 2190 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2180 2189 2191 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2180 2191 2182 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2183 2192 2193 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2183 2193 2184 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2184 2193 2194 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2184 2194 2185 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2185 2194 2195 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2185 2195 2186 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2186 2195 2196 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2186 2196 2187 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2187 2196 2197 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2187 2197 2188 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2188 2197 2198 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2188 2198 2189 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2183 2199 2192 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2183 2190 2199 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2189 2198 2200 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2189 2200 2191 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2192 2201 2202 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2192 2202 2193 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2193 2202 2203 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2193 2203 2194 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2194 2203 2204 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2194 2204 2195 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2195 2204 2205 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2195 2205 2196 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2196 2205 2206 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2196 2206 2197 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2197 2206 2207 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2197 2207 2198 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2192 2208 2201 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2192 2199 2208 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2198 2207 2209 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2198 2209 2200 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2201 2210 2211 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2201 2211 2202 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2202 2211 2212 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2202 2212 2203 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2203 2212 2213 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2203 2213 2204 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2204 2213 2214 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2204 2214 2205 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2205 2214 2215 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2205 2215 2206 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2206 2215 2216 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2206 2216 2207 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2201 2217 2210 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2201 2208 2217 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2207 2216 2218 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2207 2218 2209 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2210 2219 2220 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2210 2220 2211 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2211 2220 2221 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2211 2221 2212 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2212 2221 2222 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2212 2222 2213 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2213 2222 2223 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2213 2223 2214 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2214 2223 2224 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2214 2224 2215 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2215 2224 2225 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2215 2225 2216 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2210 2226 2219 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2210 2217 2226 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2216 2225 2227 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2216 2227 2218 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2219 2228 2229 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2219 2229 2220 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2220 2229 2230 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2220 2230 2221 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2221 2230 2231 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2221 2231 2222 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2222 2231 2232 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2222 2232 2223 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2223 2232 2233 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2223 2233 2224 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2224 2233 2234 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2224 2234 2225 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2219 2235 2228 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2219 2226 2235 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2225 2234 2236 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2225 2236 2227 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2228 2237 2238 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2228 2238 2229 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2229 2238 2239 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2229 2239 2230 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2230 2239 2240 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2230 2240 2231 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2231 2240 2241 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2231 2241 2232 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2232 2241 2242 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2232 2242 2233 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2233 2242 2243 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2233 2243 2234 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2228 2244 2237 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2228 2235 2244 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2234 2243 2245 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2234 2245 2236 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2237 2246 2247 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2237 2247 2238 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2238 2247 2248 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2238 2248 2239 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2239 2248 2249 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2239 2249 2240 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2240 2249 2250 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2240 2250 2241 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2241 2250 2251 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2241 2251 2242 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2242 2251 2252 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2242 2252 2243 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2237 2253 2246 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2237 2244 2253 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2243 2252 2254 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2243 2254 2245 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2246 2255 2256 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2246 2256 2247 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2247 2256 2257 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2247 2257 2248 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2248 2257 2258 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2248 2258 2249 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2249 2258 2259 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2249 2259 2250 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2250 2259 2260 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2250 2260 2251 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2251 2260 2261 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2251 2261 2252 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2246 2262 2255 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2246 2253 2262 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2252 2261 2263 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2252 2263 2254 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2264 2066 2048 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2264 2048 2052 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2264 2052 2055 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2264 2055 2057 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2264 2057 2059 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2264 2059 2061 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2264 2061 2063 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2264 2063 2069 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2264 2069 2066 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2265 2255 2262 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2265 2256 2255 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2265 2257 2256 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2265 2258 2257 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2265 2259 2258 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2265 2260 2259 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2265 2261 2260 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2265 2263 2261 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2265 2262 2263 r12 24 r9 r10 r11 60
meshface 2266 2267 2268 227 r9 r10 r11 60
meshface 2266 2269 2267 227 r9 r10 r11 60
set r12 184
meshfacegradient 2270 2271 2272 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2270 2272 2273 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2273 2272 2274 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2273 2274 2275 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2275 2274 2276 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2275 2276 2277 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2277 2276 2278 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2277 2278 2279 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2271 2280 2281 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2271 2281 2272 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2272 2281 2282 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2272 2282 2274 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2274 2282 2283 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2274 2283 2276 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2276 2283 2284 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2276 2284 2278 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2280 2285 2286 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2280 2286 2281 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2281 2286 2287 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2281 2287 2282 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2282 2287 2288 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2282 2288 2283 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2283 2288 2289 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2283 2289 2284 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2285 2290 2291 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2285 2291 2286 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2286 2291 2292 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2286 2292 2287 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2287 2292 2293 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2287 2293 2288 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2288 2293 2294 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2288 2294 2289 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2290 2295 2296 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2290 2296 2291 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2291 2296 2297 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2291 2297 2292 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2292 2297 2298 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2292 2298 2293 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2293 2298 2299 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2293 2299 2294 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2295 2300 2301 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2295 2301 2296 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2296 2301 2302 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2296 2302 2297 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2297 2302 2303 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2297 2303 2298 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2298 2303 2304 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2298 2304 2299 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2305 2306 2307 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2305 2308 2306 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2305 2309 2308 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2310 2311 2312 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2313 2314 2315 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2316 2317 2318 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2316 2318 2319 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2316 2319 2320 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2321 2322 2323 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2324 2325 2326 r12 24 r9 r10 r11 60
set r12 208
meshfacegradient 2327 2328 2329 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2327 2330 2328 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2330 2331 2332 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2330 2333 2331 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2333 2334 2335 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2333 2336 2334 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2336 2337 2334 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2336 2338 2337 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2338 2339 2337 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2338 2340 2339 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2340 2341 2342 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2340 2343 2341 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2343 2344 2345 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2343 2346 2344 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2346 2347 2344 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2346 2348 2347 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2348 2349 2347 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2348 2350 2349 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2350 2351 2352 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2350 2353 2351 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2353 2354 2355 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2353 2356 2354 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2356 2357 2354 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2356 2358 2357 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2358 2359 2357 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2358 2360 2359 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2360 2361 2362 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2360 2363 2361 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2363 2364 2365 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2363 2366 2364 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2366 2329 2364 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2366 2327 2329 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2367 2368 2369 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2367 2370 2368 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2370 2371 2368 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2372 2373 2371 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2374 2375 2371 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2376 2377 2375 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2377 2378 2375 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2377 2379 2378 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2379 2380 2378 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2379 2381 2380 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2381 2382 2380 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2383 2384 2382 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2385 2386 2382 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2387 2388 2386 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2388 2389 2386 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2388 2390 2389 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2390 2391 2389 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2390 2392 2391 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2392 2393 2391 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2394 2395 2393 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2396 2397 2393 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2398 2399 2397 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2399 2400 2397 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2399 2401 2400 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2401 2402 2400 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2401 2403 2402 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2403 2404 2402 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2405 2406 2404 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2407 2408 2404 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2409 2410 2408 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2410 2369 2408 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2410 2367 2369 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 2411 2412 2413 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2411 2413 2414 r12 12 r9 r10 r11 60
meshface 2415 2416 2417 226 r9 r10 r11 60
set r12 212
meshfacegradient 2412 2418 2419 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2412 2419 2413 r12 12 r9 r10 r11 60
meshface 2415 2417 2420 226 r9 r10 r11 60
set r12 212
meshfacegradient 2418 2421 2422 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2418 2422 2419 r12 12 r9 r10 r11 60
meshface 2415 2420 2423 226 r9 r10 r11 60
set r12 212
meshfacegradient 2421 2424 2425 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2421 2425 2422 r12 12 r9 r10 r11 60
meshface 2415 2423 2426 226 r9 r10 r11 60
set r12 212
meshfacegradient 2424 2427 2428 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2424 2428 2425 r12 12 r9 r10 r11 60
meshface 2415 2426 2429 226 r9 r10 r11 60
set r12 212
meshfacegradient 2427 2430 2431 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2427 2431 2428 r12 12 r9 r10 r11 60
meshface 2415 2429 2432 226 r9 r10 r11 60
set r12 212
meshfacegradient 2430 2433 2434 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2430 2434 2431 r12 12 r9 r10 r11 60
meshface 2415 2432 2435 226 r9 r10 r11 60
set r12 212
meshfacegradient 2433 2411 2414 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2433 2414 2434 r12 12 r9 r10 r11 60
meshface 2415 2435 2416 226 r9 r10 r11 60
set r12 212
meshfacegradient 2436 2437 2438 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2436 2438 2439 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2440 2441 2442 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2440 2442 2443 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2444 2445 2446 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2444 2446 2447 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2448 2449 2450 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2448 2450 2451 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2452 2453 2454 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2452 2454 2455 r12 12 r9 r10 r11 60
set r12 208
meshfacegradient 2456 2457 2458 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2456 2458 2459 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2459 2460 2461 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2459 2461 2462 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2462 2463 2464 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2462 2464 2465 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2465 2464 2466 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2465 2466 2467 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2467 2466 2468 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2467 2468 2469 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2469 2470 2471 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2469 2471 2472 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2472 2473 2474 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2472 2474 2475 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2475 2474 2476 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2475 2476 2477 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2477 2476 2478 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2477 2478 2479 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2479 2480 2481 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2479 2481 2482 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2482 2483 2484 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2482 2484 2485 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2485 2484 2486 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2485 2486 2487 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2487 2486 2488 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2487 2488 2489 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2489 2490 2491 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2489 2491 2492 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2492 2493 2494 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2492 2494 2495 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2495 2494 2457 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2495 2457 2456 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2496 2497 2498 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2496 2498 2499 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2499 2498 2500 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2501 2500 2502 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2503 2500 2504 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2505 2504 2506 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2506 2504 2507 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2506 2507 2508 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2508 2507 2509 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2508 2509 2510 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2510 2509 2511 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2512 2511 2513 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2514 2511 2515 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2516 2515 2517 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2517 2515 2518 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2517 2518 2519 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2519 2518 2520 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2519 2520 2521 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2521 2520 2522 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2523 2522 2524 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2525 2522 2526 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2527 2526 2528 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2528 2526 2529 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2528 2529 2530 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2530 2529 2531 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2530 2531 2532 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2532 2531 2533 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2534 2533 2535 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2536 2533 2537 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2538 2537 2539 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2539 2537 2497 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2539 2497 2496 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 2540 2541 2542 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2540 2543 2541 r12 12 r9 r10 r11 60
meshface 2544 2545 2546 226 r9 r10 r11 60
set r12 212
meshfacegradient 2542 2547 2548 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2542 2541 2547 r12 12 r9 r10 r11 60
meshface 2544 2549 2545 226 r9 r10 r11 60
set r12 212
meshfacegradient 2548 2550 2551 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2548 2547 2550 r12 12 r9 r10 r11 60
meshface 2544 2552 2549 226 r9 r10 r11 60
set r12 212
meshfacegradient 2551 2553 2554 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2551 2550 2553 r12 12 r9 r10 r11 60
meshface 2544 2555 2552 226 r9 r10 r11 60
set r12 212
meshfacegradient 2554 2556 2557 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2554 2553 2556 r12 12 r9 r10 r11 60
meshface 2544 2558 2555 226 r9 r10 r11 60
set r12 212
meshfacegradient 2557 2559 2560 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2557 2556 2559 r12 12 r9 r10 r11 60
meshface 2544 2561 2558 226 r9 r10 r11 60
set r12 212
meshfacegradient 2560 2562 2563 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2560 2559 2562 r12 12 r9 r10 r11 60
meshface 2544 2564 2561 226 r9 r10 r11 60
set r12 212
meshfacegradient 2563 2543 2540 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2563 2562 2543 r12 12 r9 r10 r11 60
meshface 2544 2546 2564 226 r9 r10 r11 60
set r12 212
meshfacegradient 2565 2566 2567 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2565 2568 2566 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2569 2570 2571 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2569 2572 2570 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2573 2574 2575 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2573 2576 2574 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2577 2578 2579 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2577 2580 2578 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2581 2582 2583 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2581 2584 2582 r12 12 r9 r10 r11 60
set r12 208
meshfacegradient 2585 2586 2587 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2585 2588 2586 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2588 2589 2590 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2588 2591 2589 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2591 2592 2593 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2591 2594 2592 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2594 2595 2592 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2594 2596 2595 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2596 2597 2595 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2596 2598 2597 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2598 2599 2600 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2598 2601 2599 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2601 2602 2603 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2601 2604 2602 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2604 2605 2602 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2604 2606 2605 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2606 2607 2605 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2606 2608 2607 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2608 2609 2610 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2608 2611 2609 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2611 2612 2613 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2611 2614 2612 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2614 2615 2612 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2614 2616 2615 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2616 2617 2615 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2616 2618 2617 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2618 2619 2620 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2618 2621 2619 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2621 2622 2623 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2621 2624 2622 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2624 2587 2622 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2624 2585 2587 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2625 2626 2627 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2625 2628 2626 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2628 2629 2626 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2630 2631 2629 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2632 2633 2629 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2634 2635 2633 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2635 2636 2633 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2635 2637 2636 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2637 2638 2636 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2637 2639 2638 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2639 2640 2638 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2641 2642 2640 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2643 2644 2640 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2645 2646 2644 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2646 2647 2644 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2646 2648 2647 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2648 2649 2647 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2648 2650 2649 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2650 2651 2649 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2652 2653 2651 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2654 2655 2651 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2656 2657 2655 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2657 2658 2655 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2657 2659 2658 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2659 2660 2658 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2659 2661 2660 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2661 2662 2660 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2663 2664 2662 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2665 2666 2662 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2667 2668 2666 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2668 2627 2666 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2668 2625 2627 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 2669 2670 2671 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2669 2671 2672 r12 12 r9 r10 r11 60
meshface 2673 2674 2675 226 r9 r10 r11 60
set r12 212
meshfacegradient 2670 2676 2677 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2670 2677 2671 r12 12 r9 r10 r11 60
meshface 2673 2675 2678 226 r9 r10 r11 60
set r12 212
meshfacegradient 2676 2679 2680 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2676 2680 2677 r12 12 r9 r10 r11 60
meshface 2673 2678 2681 226 r9 r10 r11 60
set r12 212
meshfacegradient 2679 2682 2683 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2679 2683 2680 r12 12 r9 r10 r11 60
meshface 2673 2681 2684 226 r9 r10 r11 60
set r12 212
meshfacegradient 2682 2685 2686 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2682 2686 2683 r12 12 r9 r10 r11 60
meshface 2673 2684 2687 226 r9 r10 r11 60
set r12 212
meshfacegradient 2685 2688 2689 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2685 2689 2686 r12 12 r9 r10 r11 60
meshface 2673 2687 2690 226 r9 r10 r11 60
set r12 212
meshfacegradient 2688 2691 2692 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2688 2692 2689 r12 12 r9 r10 r11 60
meshface 2673 2690 2693 226 r9 r10 r11 60
set r12 212
meshfacegradient 2691 2669 2672 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2691 2672 2692 r12 12 r9 r10 r11 60
meshface 2673 2693 2674 226 r9 r10 r11 60
set r12 212
meshfacegradient 2694 2695 2696 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2694 2696 2697 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2698 2699 2700 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2698 2700 2701 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2702 2703 2704 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2702 2704 2705 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2706 2707 2708 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2706 2708 2709 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2710 2711 2712 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2710 2712 2713 r12 12 r9 r10 r11 60
set r12 208
meshfacegradient 2714 2715 2716 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2714 2716 2717 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2717 2718 2719 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2717 2719 2720 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2720 2721 2722 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2720 2722 2723 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2723 2722 2724 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2723 2724 2725 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2725 2724 2726 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2725 2726 2727 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2727 2728 2729 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2727 2729 2730 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2730 2731 2732 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2730 2732 2733 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2733 2732 2734 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2733 2734 2735 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2735 2734 2736 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2735 2736 2737 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2737 2738 2739 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2737 2739 2740 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2740 2741 2742 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2740 2742 2743 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2743 2742 2744 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2743 2744 2745 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2745 2744 2746 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2745 2746 2747 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2747 2748 2749 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2747 2749 2750 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2750 2751 2752 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2750 2752 2753 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2753 2752 2715 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2753 2715 2714 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2754 2755 2756 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2754 2756 2757 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2757 2756 2758 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2759 2758 2760 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2761 2758 2762 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2763 2762 2764 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2764 2762 2765 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2764 2765 2766 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2766 2765 2767 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2766 2767 2768 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2768 2767 2769 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2770 2769 2771 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2772 2769 2773 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2774 2773 2775 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2775 2773 2776 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2775 2776 2777 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2777 2776 2778 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2777 2778 2779 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2779 2778 2780 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2781 2780 2782 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2783 2780 2784 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2785 2784 2786 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2786 2784 2787 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2786 2787 2788 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2788 2787 2789 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2788 2789 2790 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2790 2789 2791 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2792 2791 2793 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2794 2791 2795 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2796 2795 2797 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2797 2795 2755 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2797 2755 2754 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 2798 2799 2800 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2798 2801 2799 r12 12 r9 r10 r11 60
meshface 2802 2803 2804 226 r9 r10 r11 60
set r12 212
meshfacegradient 2800 2805 2806 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2800 2799 2805 r12 12 r9 r10 r11 60
meshface 2802 2807 2803 226 r9 r10 r11 60
set r12 212
meshfacegradient 2806 2808 2809 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2806 2805 2808 r12 12 r9 r10 r11 60
meshface 2802 2810 2807 226 r9 r10 r11 60
set r12 212
meshfacegradient 2809 2811 2812 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2809 2808 2811 r12 12 r9 r10 r11 60
meshface 2802 2813 2810 226 r9 r10 r11 60
set r12 212
meshfacegradient 2812 2814 2815 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2812 2811 2814 r12 12 r9 r10 r11 60
meshface 2802 2816 2813 226 r9 r10 r11 60
set r12 212
meshfacegradient 2815 2817 2818 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2815 2814 2817 r12 12 r9 r10 r11 60
meshface 2802 2819 2816 226 r9 r10 r11 60
set r12 212
meshfacegradient 2818 2820 2821 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2818 2817 2820 r12 12 r9 r10 r11 60
meshface 2802 2822 2819 226 r9 r10 r11 60
set r12 212
meshfacegradient 2821 2801 2798 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2821 2820 2801 r12 12 r9 r10 r11 60
meshface 2802 2804 2822 226 r9 r10 r11 60
set r12 212
meshfacegradient 2823 2824 2825 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2823 2826 2824 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2827 2828 2829 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2827 2830 2828 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2831 2832 2833 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2831 2834 2832 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2835 2836 2837 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2835 2838 2836 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2839 2840 2841 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2839 2842 2840 r12 12 r9 r10 r11 60
meshface 2843 2844 2845 226 r9 r10 r11 60
meshface 2843 2846 2844 226 r9 r10 r11 60
meshface 2847 2848 2849 226 r9 r10 r11 60
meshface 2850 2851 2852 226 r9 r10 r11 60
set r12 184
meshfacegradient 2853 2854 2855 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2856 2857 2858 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2859 2860 2861 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2862 2863 2864 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2865 2866 2867 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2868 2869 2870 r12 24 r9 r10 r11 60
meshface 2871 2872 2873 226 r9 r10 r11 60
meshface 2871 2873 2874 226 r9 r10 r11 60
meshface 2875 2876 2877 226 r9 r10 r11 60
meshface 2878 2879 2880 226 r9 r10 r11 60
set r12 184
meshfacegradient 2881 2882 2883 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2884 2885 2886 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2887 2888 2889 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2890 2891 2892 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2893 2894 2895 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2896 2897 2898 r12 24 r9 r10 r11 60
meshface 2899 2900 2901 225 r9 r10 r11 60
meshface 2899 2901 2902 225 r9 r10 r11 60
meshface 2903 2904 2905 224 r9 r10 r11 60
meshface 2903 2906 2904 224 r9 r10 r11 60
set r12 228
meshfacegradient 2907 2908 2909 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 2907 2910 2908 r12 12 r9 r10 r11 60
meshface 2911 2912 2913 226 r9 r10 r11 60
meshface 2911 2913 2914 226 r9 r10 r11 60
meshface 2915 2916 2917 226 r9 r10 r11 60
meshface 2915 2918 2916 226 r9 r10 r11 60
meshface 2919 2920 2921 227 r9 r10 r11 60
meshface 2919 2922 2920 227 r9 r10 r11 60
meshface 2923 2924 2925 227 r9 r10 r11 60
meshface 2923 2926 2924 227 r9 r10 r11 60
meshface 2927 2928 2929 227 r9 r10 r11 60
meshface 2927 2930 2928 227 r9 r10 r11 60
meshface 2931 2932 2933 227 r9 r10 r11 60
meshface 2931 2934 2932 227 r9 r10 r11 60
meshface 2935 2936 2937 226 r9 r10 r11 60
meshface 2935 2937 2938 226 r9 r10 r11 60
meshface 2939 2940 2941 226 r9 r10 r11 60
meshface 2939 2942 2940 226 r9 r10 r11 60
set r12 228
meshfacegradient 2943 2944 2945 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 2943 2945 2946 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 2944 2947 2948 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 2944 2948 2945 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 2947 2949 2950 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 2947 2950 2948 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 2949 2951 2952 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 2949 2952 2950 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 2953 2954 2955 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 2953 2956 2954 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 2955 2957 2958 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 2955 2954 2957 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 2958 2959 2960 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 2958 2957 2959 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 2960 2961 2962 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 2960 2959 2961 r12 12 r9 r10 r11 60
meshface 2963 2964 2965 240 r9 r10 r11 60
meshface 2963 2965 2966 240 r9 r10 r11 60
meshface 2967 2968 2969 240 r9 r10 r11 60
meshface 2967 2969 2970 240 r9 r10 r11 60
meshface 2971 2972 2973 240 r9 r10 r11 60
meshface 2971 2973 2974 240 r9 r10 r11 60
meshface 2975 2976 2977 241 r9 r10 r11 60
meshface 2975 2977 2978 241 r9 r10 r11 60
meshface 2979 2980 2981 240 r9 r10 r11 60
meshface 2979 2982 2980 240 r9 r10 r11 60
meshface 2983 2984 2985 240 r9 r10 r11 60
meshface 2983 2986 2984 240 r9 r10 r11 60
meshface 2987 2988 2989 240 r9 r10 r11 60
meshface 2987 2990 2988 240 r9 r10 r11 60
meshface 2991 2992 2993 241 r9 r10 r11 60
meshface 2991 2994 2992 241 r9 r10 r11 60
set r12 228
meshfacegradient 2995 2996 2997 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 2995 2998 2996 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 2999 3000 3001 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 2999 3002 3000 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 3003 3004 3005 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 3003 3006 3004 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 3007 3008 3009 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 3007 3010 3008 r12 12 r9 r10 r11 60
meshface 3011 3012 3013 240 r9 r10 r11 60
meshface 3011 3014 3012 240 r9 r10 r11 60
meshface 3015 3016 3017 241 r9 r10 r11 60
meshface 3015 3017 3018 241 r9 r10 r11 60
meshface 3019 3020 3021 241 r9 r10 r11 60
meshface 3019 3022 3020 241 r9 r10 r11 60
jmp emit_shadow
label emit_medium
localget r12 126
meshfacegradient 3023 3024 3025 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3023 3025 3026 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3026 3025 3027 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3026 3027 3028 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3029 3030 3031 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3029 3032 3030 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3033 3034 3035 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3033 3035 3036 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3024 3037 3038 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3024 3038 3025 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3025 3038 3039 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3025 3039 3027 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3031 3040 3041 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3031 3030 3040 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3034 3042 3043 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3034 3043 3035 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3037 3044 3045 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3037 3045 3038 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3038 3045 3046 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3038 3046 3039 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3041 3047 3048 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3041 3040 3047 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3042 3049 3050 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3042 3050 3043 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3044 3051 3052 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3044 3052 3045 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3045 3052 3053 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3045 3053 3046 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3048 3054 3055 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3048 3047 3054 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3049 3056 3057 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3049 3057 3050 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3051 3058 3059 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3051 3059 3052 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3052 3059 3060 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3052 3060 3053 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3055 3061 3062 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3055 3054 3061 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3056 3063 3064 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3056 3064 3057 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3058 3065 3066 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3058 3066 3059 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3059 3066 3067 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3059 3067 3060 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3062 3068 3069 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3062 3061 3068 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3063 3070 3071 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3063 3071 3064 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3065 3072 3073 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3065 3073 3066 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3066 3073 3074 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3066 3074 3067 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3069 3075 3076 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3069 3068 3075 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3070 3077 3078 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3070 3078 3071 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3072 3079 3080 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3072 3080 3073 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3073 3080 3081 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3073 3081 3074 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3076 3082 3083 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3076 3075 3082 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3077 3084 3085 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3077 3085 3078 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3079 3086 3087 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3079 3087 3080 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3080 3087 3088 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3080 3088 3081 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3083 3089 3090 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3083 3082 3089 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3084 3091 3092 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3084 3092 3085 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3086 3093 3094 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3086 3094 3087 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3087 3094 3095 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3087 3095 3088 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3090 3096 3097 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3090 3089 3096 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3091 3098 3099 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3091 3099 3092 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3093 3100 3101 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3093 3101 3094 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3094 3101 3102 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3094 3102 3095 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3097 3103 3104 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3097 3096 3103 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3098 3105 3106 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3098 3106 3099 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3107 3108 3109 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3107 3109 3110 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3107 3110 3111 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3107 3111 3112 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3107 3112 3108 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3113 3114 3103 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3113 3101 3114 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3113 3115 3101 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3113 3106 3115 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3113 3103 3106 r12 24 r9 r10 r11 60
meshface 3116 3117 3118 227 r9 r10 r11 60
meshface 3116 3119 3117 227 r9 r10 r11 60
set r12 184
meshfacegradient 3120 3121 3122 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3120 3122 3123 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3123 3122 3124 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3123 3124 3125 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3121 3126 3127 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3121 3127 3122 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3122 3127 3128 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3122 3128 3124 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3126 3129 3130 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3126 3130 3127 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3127 3130 3131 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3127 3131 3128 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3129 3132 3133 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3129 3133 3130 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3130 3133 3134 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3130 3134 3131 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3135 3136 3137 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3135 3138 3136 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3135 3139 3138 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3140 3141 3142 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3143 3144 3145 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3146 3147 3148 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3146 3148 3149 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3146 3149 3150 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3151 3152 3153 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3154 3155 3156 r12 24 r9 r10 r11 60
set r12 208
meshfacegradient 3157 3158 3159 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3157 3160 3158 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3160 3161 3158 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3160 3162 3161 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3162 3163 3161 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3162 3164 3163 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3164 3165 3163 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3164 3166 3165 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3166 3167 3165 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3166 3168 3167 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3168 3169 3167 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3168 3170 3169 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3170 3171 3169 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3170 3172 3171 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3172 3159 3171 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3172 3157 3159 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3173 3174 3175 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3173 3176 3174 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3176 3177 3174 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3176 3178 3177 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3178 3179 3177 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3178 3180 3179 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3180 3181 3179 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3180 3182 3181 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3182 3183 3181 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3182 3184 3183 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3184 3185 3183 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3184 3186 3185 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3186 3187 3185 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3186 3188 3187 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3188 3175 3187 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3188 3173 3175 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 3189 3190 3191 r12 12 r9 r10 r11 60
meshface 3192 3193 3194 226 r9 r10 r11 60
set r12 212
meshfacegradient 3189 3195 3196 r12 12 r9 r10 r11 60
meshface 3192 3197 3198 226 r9 r10 r11 60
set r12 212
meshfacegradient 3189 3199 3200 r12 12 r9 r10 r11 60
meshface 3192 3201 3202 226 r9 r10 r11 60
set r12 212
meshfacegradient 3189 3203 3204 r12 12 r9 r10 r11 60
meshface 3192 3205 3206 226 r9 r10 r11 60
set r12 208
meshfacegradient 3207 3208 3209 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3207 3209 3210 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3210 3209 3211 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3210 3211 3212 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3212 3211 3213 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3212 3213 3214 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3214 3213 3215 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3214 3215 3216 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3216 3215 3217 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3216 3217 3218 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3218 3217 3219 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3218 3219 3220 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3220 3219 3221 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3220 3221 3222 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3222 3221 3208 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3222 3208 3207 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3223 3224 3225 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3223 3225 3226 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3226 3225 3227 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3226 3227 3228 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3228 3227 3229 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3228 3229 3230 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3230 3229 3231 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3230 3231 3232 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3232 3231 3233 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3232 3233 3234 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3234 3233 3235 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3234 3235 3236 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3236 3235 3237 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3236 3237 3238 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3238 3237 3224 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3238 3224 3223 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 3239 3240 3241 r12 12 r9 r10 r11 60
meshface 3242 3243 3244 226 r9 r10 r11 60
set r12 212
meshfacegradient 3239 3245 3246 r12 12 r9 r10 r11 60
meshface 3242 3247 3248 226 r9 r10 r11 60
set r12 212
meshfacegradient 3239 3249 3250 r12 12 r9 r10 r11 60
meshface 3242 3251 3252 226 r9 r10 r11 60
set r12 212
meshfacegradient 3239 3253 3254 r12 12 r9 r10 r11 60
meshface 3242 3255 3256 226 r9 r10 r11 60
set r12 208
meshfacegradient 3257 3258 3259 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3257 3260 3258 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3260 3261 3258 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3260 3262 3261 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3262 3263 3261 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3262 3264 3263 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3264 3265 3263 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3264 3266 3265 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3266 3267 3265 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3266 3268 3267 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3268 3269 3267 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3268 3270 3269 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3270 3271 3269 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3270 3272 3271 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3272 3259 3271 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3272 3257 3259 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3273 3274 3275 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3273 3276 3274 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3276 3277 3274 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3276 3278 3277 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3278 3279 3277 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3278 3280 3279 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3280 3281 3279 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3280 3282 3281 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3282 3283 3281 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3282 3284 3283 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3284 3285 3283 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3284 3286 3285 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3286 3287 3285 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3286 3288 3287 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3288 3275 3287 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3288 3273 3275 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 3289 3290 3291 r12 12 r9 r10 r11 60
meshface 3292 3293 3294 226 r9 r10 r11 60
set r12 212
meshfacegradient 3289 3295 3296 r12 12 r9 r10 r11 60
meshface 3292 3297 3298 226 r9 r10 r11 60
set r12 212
meshfacegradient 3289 3299 3300 r12 12 r9 r10 r11 60
meshface 3292 3301 3302 226 r9 r10 r11 60
set r12 212
meshfacegradient 3289 3303 3304 r12 12 r9 r10 r11 60
meshface 3292 3305 3306 226 r9 r10 r11 60
set r12 208
meshfacegradient 3307 3308 3309 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3307 3309 3310 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3310 3309 3311 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3310 3311 3312 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3312 3311 3313 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3312 3313 3314 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3314 3313 3315 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3314 3315 3316 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3316 3315 3317 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3316 3317 3318 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3318 3317 3319 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3318 3319 3320 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3320 3319 3321 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3320 3321 3322 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3322 3321 3308 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3322 3308 3307 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3323 3324 3325 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3323 3325 3326 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3326 3325 3327 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3326 3327 3328 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3328 3327 3329 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3328 3329 3330 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3330 3329 3331 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3330 3331 3332 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3332 3331 3333 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3332 3333 3334 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3334 3333 3335 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3334 3335 3336 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3336 3335 3337 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3336 3337 3338 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3338 3337 3324 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3338 3324 3323 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 3339 3340 3341 r12 12 r9 r10 r11 60
meshface 3342 3343 3344 226 r9 r10 r11 60
set r12 212
meshfacegradient 3339 3345 3346 r12 12 r9 r10 r11 60
meshface 3342 3347 3348 226 r9 r10 r11 60
set r12 212
meshfacegradient 3339 3349 3350 r12 12 r9 r10 r11 60
meshface 3342 3351 3352 226 r9 r10 r11 60
set r12 212
meshfacegradient 3339 3353 3354 r12 12 r9 r10 r11 60
meshface 3342 3355 3356 226 r9 r10 r11 60
meshface 3357 3358 3359 226 r9 r10 r11 60
meshface 3360 3361 3362 226 r9 r10 r11 60
meshface 3363 3364 3365 225 r9 r10 r11 60
meshface 3363 3365 3366 225 r9 r10 r11 60
meshface 3367 3368 3369 224 r9 r10 r11 60
meshface 3367 3370 3368 224 r9 r10 r11 60
set r12 228
meshfacegradient 3371 3372 3373 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 3371 3374 3372 r12 12 r9 r10 r11 60
meshface 3375 3376 3377 226 r9 r10 r11 60
meshface 3375 3377 3378 226 r9 r10 r11 60
meshface 3379 3380 3381 226 r9 r10 r11 60
meshface 3379 3382 3380 226 r9 r10 r11 60
set r12 228
meshfacegradient 3383 3384 3385 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 3383 3385 3386 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 3384 3387 3388 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 3384 3388 3385 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 3389 3390 3391 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 3389 3392 3390 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 3391 3393 3394 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 3391 3390 3393 r12 12 r9 r10 r11 60
jmp emit_shadow
label emit_far
localget r12 126
meshfacegradient 3395 3396 3397 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3395 3397 3398 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3398 3397 3399 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3398 3399 3400 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3401 3402 3403 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3401 3404 3402 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3405 3406 3407 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3405 3407 3408 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3396 3409 3410 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3396 3410 3397 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3397 3410 3411 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3397 3411 3399 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3403 3412 3413 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3403 3402 3412 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3406 3414 3415 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3406 3415 3407 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3409 3416 3417 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3409 3417 3410 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3410 3417 3418 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3410 3418 3411 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3413 3419 3420 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3413 3412 3419 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3414 3421 3422 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3414 3422 3415 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3416 3423 3424 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3416 3424 3417 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3417 3424 3425 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3417 3425 3418 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3420 3426 3427 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3420 3419 3426 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3421 3428 3429 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3421 3429 3422 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3423 3430 3431 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3423 3431 3424 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3424 3431 3432 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3424 3432 3425 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3427 3433 3434 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3427 3426 3433 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3428 3435 3436 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3428 3436 3429 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3437 3438 3439 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3437 3439 3440 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3433 3441 3442 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3433 3436 3441 r12 24 r9 r10 r11 60
meshface 3443 3444 3445 227 r9 r10 r11 60
meshface 3443 3446 3444 227 r9 r10 r11 60
set r12 184
meshfacegradient 3447 3448 3449 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3447 3449 3450 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3450 3449 3451 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3450 3451 3452 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3448 3453 3454 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3448 3454 3449 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3449 3454 3455 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3449 3455 3451 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3453 3456 3457 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3453 3457 3454 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3454 3457 3458 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3454 3458 3455 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3459 3460 3461 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3459 3462 3460 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3463 3464 3465 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3463 3465 3466 r12 24 r9 r10 r11 60
set r12 208
meshfacegradient 3467 3468 3469 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3467 3470 3468 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3471 3472 3473 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3471 3474 3472 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3475 3476 3477 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3475 3478 3476 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3479 3480 3481 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3479 3482 3480 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 3483 3484 3485 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 3483 3485 3486 r12 12 r9 r10 r11 60
set r12 208
meshfacegradient 3487 3488 3489 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3487 3489 3490 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3491 3492 3493 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3491 3493 3494 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3495 3496 3497 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3495 3497 3498 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3499 3500 3501 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3499 3501 3502 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 3503 3504 3505 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 3503 3506 3504 r12 12 r9 r10 r11 60
set r12 208
meshfacegradient 3507 3508 3509 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3507 3510 3508 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3511 3512 3513 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3511 3514 3512 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3515 3516 3517 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3515 3518 3516 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3519 3520 3521 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3519 3522 3520 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 3523 3524 3525 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 3523 3525 3526 r12 12 r9 r10 r11 60
set r12 208
meshfacegradient 3527 3528 3529 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3527 3529 3530 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3531 3532 3533 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3531 3533 3534 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3535 3536 3537 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3535 3537 3538 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3539 3540 3541 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3539 3541 3542 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 3543 3544 3545 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 3543 3546 3544 r12 12 r9 r10 r11 60
meshface 3547 3548 3549 225 r9 r10 r11 60
meshface 3547 3549 3550 225 r9 r10 r11 60
meshface 3551 3552 3553 224 r9 r10 r11 60
meshface 3551 3554 3552 224 r9 r10 r11 60
set r12 228
meshfacegradient 3555 3556 3557 r12 12 r9 r10 r11 60
set r12 228
meshfacegradient 3555 3558 3556 r12 12 r9 r10 r11 60
jmp emit_shadow
label emit_shadow
set r12 24
localget r0 11
cmp r0 0
jne shadow_base_ready
load8 r0 120
cmp r0 0
je shadow_base_ready
set r12 32
label shadow_base_ready
meshfacegradient 3559 3560 3561 r12 8 r9 r10 r11 60
meshfacegradient 3560 3568 3569 r12 8 r9 r10 r11 60
meshfacegradient 3560 3569 3561 r12 8 r9 r10 r11 60
meshfacegradient 3559 3561 3562 r12 8 r9 r10 r11 60
meshfacegradient 3561 3569 3570 r12 8 r9 r10 r11 60
meshfacegradient 3561 3570 3562 r12 8 r9 r10 r11 60
meshfacegradient 3559 3562 3563 r12 8 r9 r10 r11 60
meshfacegradient 3562 3570 3571 r12 8 r9 r10 r11 60
meshfacegradient 3562 3571 3563 r12 8 r9 r10 r11 60
meshfacegradient 3559 3563 3564 r12 8 r9 r10 r11 60
meshfacegradient 3563 3571 3572 r12 8 r9 r10 r11 60
meshfacegradient 3563 3572 3564 r12 8 r9 r10 r11 60
meshfacegradient 3559 3564 3565 r12 8 r9 r10 r11 60
meshfacegradient 3564 3572 3573 r12 8 r9 r10 r11 60
meshfacegradient 3564 3573 3565 r12 8 r9 r10 r11 60
meshfacegradient 3559 3565 3566 r12 8 r9 r10 r11 60
meshfacegradient 3565 3573 3574 r12 8 r9 r10 r11 60
meshfacegradient 3565 3574 3566 r12 8 r9 r10 r11 60
meshfacegradient 3559 3566 3567 r12 8 r9 r10 r11 60
meshfacegradient 3566 3574 3575 r12 8 r9 r10 r11 60
meshfacegradient 3566 3575 3567 r12 8 r9 r10 r11 60
meshfacegradient 3559 3567 3560 r12 8 r9 r10 r11 60
meshfacegradient 3567 3575 3568 r12 8 r9 r10 r11 60
meshfacegradient 3567 3568 3560 r12 8 r9 r10 r11 60
jmp next_actor
label emit_tree
meshface 3576 3577 3578 14 r9 r10 r11 60
meshface 3576 3578 3579 15 r9 r10 r11 60
meshface 3576 3579 3580 16 r9 r10 r11 60
meshface 3576 3580 3581 14 r9 r10 r11 60
meshface 3576 3581 3582 15 r9 r10 r11 60
meshface 3576 3582 3577 16 r9 r10 r11 60
meshface 3583 3584 3585 9 r9 r10 r11 60
meshface 3583 3585 3586 10 r9 r10 r11 60
meshface 3587 3588 3589 9 r9 r10 r11 60
meshface 3587 3589 3590 10 r9 r10 r11 60
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
