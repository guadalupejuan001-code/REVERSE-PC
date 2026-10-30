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
meshvertex 238 -61 108 -15
meshvertex 239 -30 113 -15
meshvertex 241 0 115 -15
meshvertex 243 31 113 -15
meshvertex 245 61 108 -15
meshvertex 247 -57 105 30
meshvertex 248 -28 111 30
meshvertex 249 0 113 30
meshvertex 250 29 111 30
meshvertex 251 57 105 30
meshvertex 252 -54 101 48
meshvertex 253 -27 106 48
meshvertex 254 0 108 48
meshvertex 255 27 106 48
meshvertex 256 54 101 48
meshvertex 258 -69 73 108
meshvertex 259 -34 75 108
meshvertex 261 0 75 108
meshvertex 263 35 75 108
meshvertex 265 69 73 108
meshvertex 267 -78 79 -126
meshvertex 268 -55 101 48
meshvertex 269 -61 104 -61
meshvertex 270 -74 78 101
meshvertex 271 -81 77 -64
meshvertex 272 -80 77 -141
meshvertex 278 78 79 -126
meshvertex 279 61 104 -61
meshvertex 280 55 101 48
meshvertex 281 74 78 101
meshvertex 282 81 77 -64
meshvertex 283 80 77 -141
meshvertex 289 -76 34 -108
meshvertex 290 -97 47 -111
meshvertex 291 -97 34 -108
meshvertex 292 -76 47 -111
meshvertex 293 -97 58 -118
meshvertex 295 -76 58 -118
meshvertex 296 -97 65 -129
meshvertex 298 -76 65 -129
meshvertex 299 -97 68 -142
meshvertex 300 -76 68 -142
meshvertex 301 -97 65 -155
meshvertex 302 -76 65 -155
meshvertex 303 -97 58 -166
meshvertex 305 -76 58 -166
meshvertex 306 -97 47 -173
meshvertex 308 -76 47 -173
meshvertex 309 -97 34 -176
meshvertex 310 -76 34 -176
meshvertex 311 -97 21 -173
meshvertex 312 -76 21 -173
meshvertex 313 -97 10 -166
meshvertex 315 -76 10 -166
meshvertex 316 -97 3 -155
meshvertex 318 -76 3 -155
meshvertex 319 -97 0 -142
meshvertex 320 -76 0 -142
meshvertex 321 -97 3 -129
meshvertex 322 -76 3 -129
meshvertex 323 -97 10 -118
meshvertex 325 -76 10 -118
meshvertex 326 -97 21 -111
meshvertex 328 -76 21 -111
meshvertex 330 -100 42 -122
meshvertex 331 -100 34 -120
meshvertex 333 -100 50 -126
meshvertex 337 -100 54 -134
meshvertex 340 -100 56 -142
meshvertex 342 -100 54 -150
meshvertex 344 -100 50 -158
meshvertex 348 -100 42 -162
meshvertex 351 -100 34 -164
meshvertex 353 -100 26 -162
meshvertex 355 -100 18 -158
meshvertex 359 -100 14 -150
meshvertex 362 -100 12 -142
meshvertex 364 -100 14 -134
meshvertex 366 -100 18 -126
meshvertex 370 -100 26 -122
meshvertex 375 -100 47 -129
meshvertex 376 -100 34 -124
meshvertex 377 -99 34 -142
meshvertex 378 -99 34 -124
meshvertex 379 -99 47 -129
meshvertex 381 -100 52 -142
meshvertex 382 -99 52 -142
meshvertex 384 -100 47 -155
meshvertex 385 -99 47 -155
meshvertex 387 -100 34 -160
meshvertex 388 -99 34 -160
meshvertex 390 -100 21 -155
meshvertex 391 -99 21 -155
meshvertex 393 -100 16 -142
meshvertex 394 -99 16 -142
meshvertex 396 -100 21 -129
meshvertex 397 -99 21 -129
meshvertex 398 -100 34 -138
meshvertex 399 -100 35 -122
meshvertex 400 -100 39 -123
meshvertex 401 -100 35 -138
meshvertex 402 -100 38 -140
meshvertex 403 -100 53 -137
meshvertex 404 -100 54 -140
meshvertex 405 -100 38 -142
meshvertex 406 -100 37 -145
meshvertex 407 -100 45 -159
meshvertex 408 -100 42 -160
meshvertex 409 -100 35 -146
meshvertex 410 -100 32 -145
meshvertex 411 -100 21 -157
meshvertex 412 -100 19 -155
meshvertex 413 -100 31 -144
meshvertex 414 -100 30 -141
meshvertex 415 -100 15 -135
meshvertex 416 -100 17 -132
meshvertex 417 -100 31 -139
meshvertex 418 76 34 -108
meshvertex 419 97 34 -108
meshvertex 420 97 47 -111
meshvertex 421 76 47 -111
meshvertex 423 97 58 -118
meshvertex 424 76 58 -118
meshvertex 426 97 65 -129
meshvertex 427 76 65 -129
meshvertex 428 97 68 -142
meshvertex 429 76 68 -142
meshvertex 430 97 65 -155
meshvertex 431 76 65 -155
meshvertex 433 97 58 -166
meshvertex 434 76 58 -166
meshvertex 436 97 47 -173
meshvertex 437 76 47 -173
meshvertex 438 97 34 -176
meshvertex 439 76 34 -176
meshvertex 440 97 21 -173
meshvertex 441 76 21 -173
meshvertex 443 97 10 -166
meshvertex 444 76 10 -166
meshvertex 446 97 3 -155
meshvertex 447 76 3 -155
meshvertex 448 97 0 -142
meshvertex 449 76 0 -142
meshvertex 450 97 3 -129
meshvertex 451 76 3 -129
meshvertex 453 97 10 -118
meshvertex 454 76 10 -118
meshvertex 456 97 21 -111
meshvertex 457 76 21 -111
meshvertex 459 100 34 -120
meshvertex 460 100 42 -122
meshvertex 462 100 50 -126
meshvertex 466 100 54 -134
meshvertex 469 100 56 -142
meshvertex 471 100 54 -150
meshvertex 473 100 50 -158
meshvertex 477 100 42 -162
meshvertex 480 100 34 -164
meshvertex 482 100 26 -162
meshvertex 484 100 18 -158
meshvertex 488 100 14 -150
meshvertex 491 100 12 -142
meshvertex 493 100 14 -134
meshvertex 495 100 18 -126
meshvertex 499 100 26 -122
meshvertex 503 100 47 -129
meshvertex 505 100 34 -124
meshvertex 506 99 34 -142
meshvertex 507 99 47 -129
meshvertex 508 99 34 -124
meshvertex 509 100 52 -142
meshvertex 511 99 52 -142
meshvertex 512 100 47 -155
meshvertex 514 99 47 -155
meshvertex 515 100 34 -160
meshvertex 517 99 34 -160
meshvertex 518 100 21 -155
meshvertex 520 99 21 -155
meshvertex 521 100 16 -142
meshvertex 523 99 16 -142
meshvertex 524 100 21 -129
meshvertex 526 99 21 -129
meshvertex 527 100 34 -138
meshvertex 528 100 39 -123
meshvertex 529 100 35 -122
meshvertex 530 100 35 -138
meshvertex 531 100 38 -140
meshvertex 532 100 54 -140
meshvertex 533 100 53 -137
meshvertex 534 100 38 -142
meshvertex 535 100 37 -145
meshvertex 536 100 42 -160
meshvertex 537 100 45 -159
meshvertex 538 100 35 -146
meshvertex 539 100 32 -145
meshvertex 540 100 19 -155
meshvertex 541 100 21 -157
meshvertex 542 100 31 -144
meshvertex 543 100 30 -141
meshvertex 544 100 17 -132
meshvertex 545 100 15 -135
meshvertex 546 100 31 -139
meshvertex 547 -76 34 172
meshvertex 548 -97 47 169
meshvertex 549 -97 34 172
meshvertex 550 -76 47 169
meshvertex 551 -97 58 162
meshvertex 553 -76 58 162
meshvertex 554 -97 65 151
meshvertex 556 -76 65 151
meshvertex 557 -97 68 138
meshvertex 558 -76 68 138
meshvertex 559 -97 65 125
meshvertex 560 -76 65 125
meshvertex 561 -97 58 114
meshvertex 563 -76 58 114
meshvertex 564 -97 47 107
meshvertex 566 -76 47 107
meshvertex 567 -97 34 104
meshvertex 568 -76 34 104
meshvertex 569 -97 21 107
meshvertex 570 -76 21 107
meshvertex 571 -97 10 114
meshvertex 573 -76 10 114
meshvertex 574 -97 3 125
meshvertex 576 -76 3 125
meshvertex 577 -97 0 138
meshvertex 578 -76 0 138
meshvertex 579 -97 3 151
meshvertex 580 -76 3 151
meshvertex 581 -97 10 162
meshvertex 583 -76 10 162
meshvertex 584 -97 21 169
meshvertex 586 -76 21 169
meshvertex 588 -100 42 158
meshvertex 589 -100 34 160
meshvertex 591 -100 50 154
meshvertex 595 -100 54 146
meshvertex 598 -100 56 138
meshvertex 600 -100 54 130
meshvertex 602 -100 50 122
meshvertex 606 -100 42 118
meshvertex 609 -100 34 116
meshvertex 611 -100 26 118
meshvertex 613 -100 18 122
meshvertex 617 -100 14 130
meshvertex 620 -100 12 138
meshvertex 622 -100 14 146
meshvertex 624 -100 18 154
meshvertex 628 -100 26 158
meshvertex 633 -100 47 151
meshvertex 634 -100 34 156
meshvertex 635 -99 34 138
meshvertex 636 -99 34 156
meshvertex 637 -99 47 151
meshvertex 639 -100 52 138
meshvertex 640 -99 52 138
meshvertex 642 -100 47 125
meshvertex 643 -99 47 125
meshvertex 645 -100 34 120
meshvertex 646 -99 34 120
meshvertex 648 -100 21 125
meshvertex 649 -99 21 125
meshvertex 651 -100 16 138
meshvertex 652 -99 16 138
meshvertex 654 -100 21 151
meshvertex 655 -99 21 151
meshvertex 656 -100 34 142
meshvertex 657 -100 35 158
meshvertex 658 -100 39 157
meshvertex 659 -100 35 142
meshvertex 660 -100 38 140
meshvertex 661 -100 53 143
meshvertex 662 -100 54 140
meshvertex 663 -100 38 138
meshvertex 664 -100 37 135
meshvertex 665 -100 45 121
meshvertex 666 -100 42 120
meshvertex 667 -100 35 134
meshvertex 668 -100 32 135
meshvertex 669 -100 21 123
meshvertex 670 -100 19 125
meshvertex 671 -100 31 136
meshvertex 672 -100 30 139
meshvertex 673 -100 15 145
meshvertex 674 -100 17 148
meshvertex 675 -100 31 141
meshvertex 676 76 34 172
meshvertex 677 97 34 172
meshvertex 678 97 47 169
meshvertex 679 76 47 169
meshvertex 681 97 58 162
meshvertex 682 76 58 162
meshvertex 684 97 65 151
meshvertex 685 76 65 151
meshvertex 686 97 68 138
meshvertex 687 76 68 138
meshvertex 688 97 65 125
meshvertex 689 76 65 125
meshvertex 691 97 58 114
meshvertex 692 76 58 114
meshvertex 694 97 47 107
meshvertex 695 76 47 107
meshvertex 696 97 34 104
meshvertex 697 76 34 104
meshvertex 698 97 21 107
meshvertex 699 76 21 107
meshvertex 701 97 10 114
meshvertex 702 76 10 114
meshvertex 704 97 3 125
meshvertex 705 76 3 125
meshvertex 706 97 0 138
meshvertex 707 76 0 138
meshvertex 708 97 3 151
meshvertex 709 76 3 151
meshvertex 711 97 10 162
meshvertex 712 76 10 162
meshvertex 714 97 21 169
meshvertex 715 76 21 169
meshvertex 717 100 34 160
meshvertex 718 100 42 158
meshvertex 720 100 50 154
meshvertex 724 100 54 146
meshvertex 727 100 56 138
meshvertex 729 100 54 130
meshvertex 731 100 50 122
meshvertex 735 100 42 118
meshvertex 738 100 34 116
meshvertex 740 100 26 118
meshvertex 742 100 18 122
meshvertex 746 100 14 130
meshvertex 749 100 12 138
meshvertex 751 100 14 146
meshvertex 753 100 18 154
meshvertex 757 100 26 158
meshvertex 761 100 47 151
meshvertex 763 100 34 156
meshvertex 764 99 34 138
meshvertex 765 99 47 151
meshvertex 766 99 34 156
meshvertex 767 100 52 138
meshvertex 769 99 52 138
meshvertex 770 100 47 125
meshvertex 772 99 47 125
meshvertex 773 100 34 120
meshvertex 775 99 34 120
meshvertex 776 100 21 125
meshvertex 778 99 21 125
meshvertex 779 100 16 138
meshvertex 781 99 16 138
meshvertex 782 100 21 151
meshvertex 784 99 21 151
meshvertex 785 100 34 142
meshvertex 786 100 39 157
meshvertex 787 100 35 158
meshvertex 788 100 35 142
meshvertex 789 100 38 140
meshvertex 790 100 54 140
meshvertex 791 100 53 143
meshvertex 792 100 38 138
meshvertex 793 100 37 135
meshvertex 794 100 42 120
meshvertex 795 100 45 121
meshvertex 796 100 35 134
meshvertex 797 100 32 135
meshvertex 798 100 19 125
meshvertex 799 100 21 123
meshvertex 800 100 31 136
meshvertex 801 100 30 139
meshvertex 802 100 17 148
meshvertex 803 100 15 145
meshvertex 804 100 31 141
meshvertex 805 -30 49 225
meshvertex 806 -68 54 220
meshvertex 807 -64 49 225
meshvertex 808 -32 54 222
meshvertex 809 -20 61 -225
meshvertex 810 -76 61 -224
meshvertex 811 -78 66 -221
meshvertex 812 -20 66 -223
meshvertex 813 -94 36 -91
meshvertex 814 -88 57 -55
meshvertex 815 -91 60 -90
meshvertex 816 -92 39 -63
meshvertex 817 -73 83 75
meshvertex 818 -93 86 66
meshvertex 819 -93 84 69
meshvertex 821 -72 85 72
meshvertex 823 -89 85 63
meshvertex 824 -100 84 62
meshvertex 825 -100 91 66
meshvertex 828 -88 92 67
meshvertex 831 -98 85 77
meshvertex 834 -88 86 79
meshvertex 841 30 49 225
meshvertex 842 64 49 225
meshvertex 843 68 54 220
meshvertex 844 32 54 222
meshvertex 845 20 61 -225
meshvertex 846 78 66 -221
meshvertex 847 76 61 -224
meshvertex 848 20 66 -223
meshvertex 849 94 36 -91
meshvertex 850 91 60 -90
meshvertex 851 88 57 -55
meshvertex 852 92 39 -63
meshvertex 853 73 83 75
meshvertex 854 93 84 69
meshvertex 855 93 86 66
meshvertex 858 72 85 72
meshvertex 859 89 85 63
meshvertex 860 100 91 66
meshvertex 861 100 84 62
meshvertex 863 88 92 67
meshvertex 866 98 85 77
meshvertex 869 88 86 79
meshvertex 877 -51 24 225
meshvertex 878 51 24 225
meshvertex 879 57 43 225
meshvertex 880 -57 43 225
meshvertex 881 -73 15 -225
meshvertex 882 67 39 -225
meshvertex 883 73 15 -225
meshvertex 884 -67 39 -225
meshvertex 885 -52 15 -225
meshvertex 886 -50 37 -220
meshvertex 887 -50 15 -225
meshvertex 888 -52 37 -220
meshvertex 889 -18 15 -225
meshvertex 890 -16 37 -220
meshvertex 891 -16 15 -225
meshvertex 892 -18 37 -220
meshvertex 893 16 15 -225
meshvertex 894 18 37 -220
meshvertex 895 18 15 -225
meshvertex 896 16 37 -220
meshvertex 897 50 15 -225
meshvertex 898 52 37 -220
meshvertex 899 52 15 -225
meshvertex 900 50 37 -220
meshvertex 901 -54 27 -225
meshvertex 902 -58 30 -225
meshvertex 903 -57 31 -225
meshvertex 904 -56 27 -225
meshvertex 905 -61 27 -224
meshvertex 908 -63 30 -225
meshvertex 909 -64 31 -225
meshvertex 911 -66 27 -225
meshvertex 912 -68 27 -225
meshvertex 914 -63 24 -225
meshvertex 915 -64 23 -225
meshvertex 917 -58 24 -225
meshvertex 918 -57 23 -225
meshvertex 920 68 27 -225
meshvertex 921 64 30 -225
meshvertex 922 65 31 -225
meshvertex 923 66 27 -225
meshvertex 924 61 27 -224
meshvertex 927 59 30 -225
meshvertex 928 58 31 -225
meshvertex 930 56 27 -225
meshvertex 931 54 27 -225
meshvertex 933 59 24 -225
meshvertex 934 58 23 -225
meshvertex 936 64 24 -225
meshvertex 937 65 23 -225
meshvertex 939 -51 73 108
meshvertex 940 -64 76 112
meshvertex 941 -66 72 158
meshvertex 942 -57 70 157
meshvertex 943 51 73 108
meshvertex 944 66 72 158
meshvertex 945 64 76 112
meshvertex 946 57 70 157
meshvertex 947 -85 72 -223
meshvertex 948 -95 79 -181
meshvertex 949 0 78 -181
meshvertex 950 0 69 -223
meshvertex 951 95 79 -181
meshvertex 952 85 72 -223
meshvertex 954 -95 34 -181
meshvertex 956 -85 22 -223
meshvertex 959 95 34 -181
meshvertex 960 85 22 -223
meshvertex 961 -96 79 -167
meshvertex 962 0 78 -167
meshvertex 963 96 79 -167
meshvertex 964 -96 64 -167
meshvertex 967 96 64 -167
meshvertex 968 -97 80 -142
meshvertex 969 0 78 -142
meshvertex 970 97 80 -142
meshvertex 971 -97 73 -142
meshvertex 974 97 73 -142
meshvertex 975 -94 78 -117
meshvertex 976 0 77 -117
meshvertex 977 94 78 -117
meshvertex 978 -94 64 -117
meshvertex 981 94 64 -117
meshvertex 982 -92 77 -103
meshvertex 983 0 77 -103
meshvertex 984 92 77 -103
meshvertex 985 -92 34 -103
meshvertex 988 92 34 -103
meshvertex 989 -92 76 99
meshvertex 990 0 72 99
meshvertex 991 92 76 99
meshvertex 992 -92 34 99
meshvertex 995 92 34 99
meshvertex 996 -93 76 113
meshvertex 997 0 71 113
meshvertex 998 93 76 113
meshvertex 999 -93 64 113
meshvertex 1002 93 64 113
meshvertex 1003 -96 76 138
meshvertex 1004 0 69 138
meshvertex 1005 96 76 138
meshvertex 1006 -96 73 138
meshvertex 1009 96 73 138
meshvertex 1010 -93 72 163
meshvertex 1011 0 66 163
meshvertex 1012 93 72 163
meshvertex 1013 -93 64 163
meshvertex 1016 93 64 163
meshvertex 1017 -91 69 177
meshvertex 1018 0 64 177
meshvertex 1019 91 69 177
meshvertex 1020 -91 34 177
meshvertex 1023 91 34 177
meshvertex 1024 -72 48 223
meshvertex 1025 0 46 223
meshvertex 1026 72 48 223
meshvertex 1027 -72 22 223
meshvertex 1030 72 22 223
meshvertex 1031 0 32 -223
meshvertex 1037 0 32 223
meshvertex 1040 -71 18 -204
meshvertex 1041 71 18 197
meshvertex 1042 -71 18 197
meshvertex 1043 71 18 -204
meshvertex 1044 -54 73 -150
meshvertex 1045 -60 106 -60
meshvertex 1046 0 113 -60
meshvertex 1047 0 75 -150
meshvertex 1048 60 106 -60
meshvertex 1049 54 73 -150
meshvertex 1051 -61 108 -10
meshvertex 1052 0 115 -10
meshvertex 1054 61 108 -10
meshvertex 1056 -54 101 48
meshvertex 1057 0 108 48
meshvertex 1058 54 101 48
meshvertex 1060 -69 73 108
meshvertex 1061 0 75 108
meshvertex 1063 69 73 108
meshvertex 1065 -78 79 -126
meshvertex 1066 -55 101 48
meshvertex 1067 -61 104 -61
meshvertex 1068 -74 78 101
meshvertex 1069 -81 77 -64
meshvertex 1070 -80 77 -141
meshvertex 1076 78 79 -126
meshvertex 1077 61 104 -61
meshvertex 1078 55 101 48
meshvertex 1079 74 78 101
meshvertex 1080 81 77 -64
meshvertex 1081 80 77 -141
meshvertex 1087 -76 34 -108
meshvertex 1088 -98 58 -118
meshvertex 1089 -98 34 -108
meshvertex 1090 -76 58 -118
meshvertex 1091 -98 68 -142
meshvertex 1092 -76 68 -142
meshvertex 1093 -98 58 -166
meshvertex 1094 -76 58 -166
meshvertex 1095 -98 34 -176
meshvertex 1096 -76 34 -176
meshvertex 1097 -98 10 -166
meshvertex 1098 -76 10 -166
meshvertex 1099 -98 0 -142
meshvertex 1100 -76 0 -142
meshvertex 1101 -98 10 -118
meshvertex 1102 -76 10 -118
meshvertex 1104 -100 50 -126
meshvertex 1105 -100 34 -120
meshvertex 1107 -100 56 -142
meshvertex 1109 -100 50 -158
meshvertex 1111 -100 34 -164
meshvertex 1113 -100 18 -158
meshvertex 1115 -100 12 -142
meshvertex 1117 -100 18 -126
meshvertex 1119 -100 34 -142
meshvertex 1137 76 34 -108
meshvertex 1138 98 34 -108
meshvertex 1139 98 58 -118
meshvertex 1140 76 58 -118
meshvertex 1141 98 68 -142
meshvertex 1142 76 68 -142
meshvertex 1143 98 58 -166
meshvertex 1144 76 58 -166
meshvertex 1145 98 34 -176
meshvertex 1146 76 34 -176
meshvertex 1147 98 10 -166
meshvertex 1148 76 10 -166
meshvertex 1149 98 0 -142
meshvertex 1150 76 0 -142
meshvertex 1151 98 10 -118
meshvertex 1152 76 10 -118
meshvertex 1154 100 34 -120
meshvertex 1155 100 50 -126
meshvertex 1157 100 56 -142
meshvertex 1159 100 50 -158
meshvertex 1161 100 34 -164
meshvertex 1163 100 18 -158
meshvertex 1165 100 12 -142
meshvertex 1167 100 18 -126
meshvertex 1169 100 34 -142
meshvertex 1187 -76 34 172
meshvertex 1188 -98 58 162
meshvertex 1189 -98 34 172
meshvertex 1190 -76 58 162
meshvertex 1191 -98 68 138
meshvertex 1192 -76 68 138
meshvertex 1193 -98 58 114
meshvertex 1194 -76 58 114
meshvertex 1195 -98 34 104
meshvertex 1196 -76 34 104
meshvertex 1197 -98 10 114
meshvertex 1198 -76 10 114
meshvertex 1199 -98 0 138
meshvertex 1200 -76 0 138
meshvertex 1201 -98 10 162
meshvertex 1202 -76 10 162
meshvertex 1204 -100 50 154
meshvertex 1205 -100 34 160
meshvertex 1207 -100 56 138
meshvertex 1209 -100 50 122
meshvertex 1211 -100 34 116
meshvertex 1213 -100 18 122
meshvertex 1215 -100 12 138
meshvertex 1217 -100 18 154
meshvertex 1219 -100 34 138
meshvertex 1237 76 34 172
meshvertex 1238 98 34 172
meshvertex 1239 98 58 162
meshvertex 1240 76 58 162
meshvertex 1241 98 68 138
meshvertex 1242 76 68 138
meshvertex 1243 98 58 114
meshvertex 1244 76 58 114
meshvertex 1245 98 34 104
meshvertex 1246 76 34 104
meshvertex 1247 98 10 114
meshvertex 1248 76 10 114
meshvertex 1249 98 0 138
meshvertex 1250 76 0 138
meshvertex 1251 98 10 162
meshvertex 1252 76 10 162
meshvertex 1254 100 34 160
meshvertex 1255 100 50 154
meshvertex 1257 100 56 138
meshvertex 1259 100 50 122
meshvertex 1261 100 34 116
meshvertex 1263 100 18 122
meshvertex 1265 100 12 138
meshvertex 1267 100 18 154
meshvertex 1269 100 34 138
meshvertex 1287 -30 49 225
meshvertex 1288 -68 54 220
meshvertex 1289 -64 49 225
meshvertex 1290 -32 54 222
meshvertex 1291 -20 61 -225
meshvertex 1292 -76 61 -224
meshvertex 1293 -78 66 -221
meshvertex 1294 -20 66 -223
meshvertex 1295 -94 36 -91
meshvertex 1296 -88 57 -55
meshvertex 1297 -91 60 -90
meshvertex 1298 30 49 225
meshvertex 1299 64 49 225
meshvertex 1300 68 54 220
meshvertex 1301 32 54 222
meshvertex 1302 20 61 -225
meshvertex 1303 78 66 -221
meshvertex 1304 76 61 -224
meshvertex 1305 20 66 -223
meshvertex 1306 94 36 -91
meshvertex 1307 91 60 -90
meshvertex 1308 88 57 -55
meshvertex 1309 -51 24 225
meshvertex 1310 51 24 225
meshvertex 1311 57 43 225
meshvertex 1312 -57 43 225
meshvertex 1313 -73 15 -225
meshvertex 1314 67 39 -225
meshvertex 1315 73 15 -225
meshvertex 1316 -67 39 -225
meshvertex 1317 -85 72 -223
meshvertex 1318 -97 80 -142
meshvertex 1319 0 78 -142
meshvertex 1320 0 69 -223
meshvertex 1321 97 80 -142
meshvertex 1322 85 72 -223
meshvertex 1324 -97 22 -142
meshvertex 1326 -85 22 -223
meshvertex 1329 97 22 -142
meshvertex 1330 85 22 -223
meshvertex 1331 -87 75 -65
meshvertex 1332 0 76 -65
meshvertex 1333 87 75 -65
meshvertex 1334 -87 22 -65
meshvertex 1337 87 22 -65
meshvertex 1338 -88 74 65
meshvertex 1339 0 75 65
meshvertex 1340 88 74 65
meshvertex 1341 -88 22 65
meshvertex 1344 88 22 65
meshvertex 1345 -96 76 138
meshvertex 1346 0 69 138
meshvertex 1347 96 76 138
meshvertex 1348 -96 22 138
meshvertex 1351 96 22 138
meshvertex 1352 -72 48 223
meshvertex 1353 0 46 223
meshvertex 1354 72 48 223
meshvertex 1355 -72 22 223
meshvertex 1358 72 22 223
meshvertex 1365 -71 18 -204
meshvertex 1366 71 18 197
meshvertex 1367 -71 18 197
meshvertex 1368 71 18 -204
meshvertex 1369 -54 74 -145
meshvertex 1370 -60 106 -55
meshvertex 1371 0 113 -55
meshvertex 1372 0 77 -145
meshvertex 1373 60 106 -55
meshvertex 1374 54 74 -145
meshvertex 1376 -57 107 30
meshvertex 1377 0 115 30
meshvertex 1379 57 107 30
meshvertex 1382 -69 73 108
meshvertex 1383 0 75 108
meshvertex 1385 69 73 108
meshvertex 1387 -78 79 -126
meshvertex 1388 -55 101 48
meshvertex 1389 -60 107 -15
meshvertex 1390 -74 78 101
meshvertex 1391 78 79 -126
meshvertex 1392 60 107 -15
meshvertex 1393 55 101 48
meshvertex 1394 74 78 101
meshvertex 1395 -78 34 -108
meshvertex 1396 -100 68 -142
meshvertex 1397 -100 34 -108
meshvertex 1398 -78 68 -142
meshvertex 1400 -100 34 -176
meshvertex 1402 -78 34 -176
meshvertex 1404 -100 0 -142
meshvertex 1406 -78 0 -142
meshvertex 1415 78 34 -108
meshvertex 1416 100 34 -108
meshvertex 1417 100 68 -142
meshvertex 1418 78 68 -142
meshvertex 1421 100 34 -176
meshvertex 1422 78 34 -176
meshvertex 1425 100 0 -142
meshvertex 1426 78 0 -142
meshvertex 1435 -78 34 172
meshvertex 1436 -100 68 138
meshvertex 1437 -100 34 172
meshvertex 1438 -78 68 138
meshvertex 1440 -100 34 104
meshvertex 1442 -78 34 104
meshvertex 1444 -100 0 138
meshvertex 1446 -78 0 138
meshvertex 1455 78 34 172
meshvertex 1456 100 34 172
meshvertex 1457 100 68 138
meshvertex 1458 78 68 138
meshvertex 1461 100 34 104
meshvertex 1462 78 34 104
meshvertex 1465 100 0 138
meshvertex 1466 78 0 138
meshvertex 1475 -30 49 225
meshvertex 1476 -68 54 220
meshvertex 1477 -64 49 225
meshvertex 1478 -32 54 222
meshvertex 1479 -20 61 -225
meshvertex 1480 -76 61 -224
meshvertex 1481 -78 66 -221
meshvertex 1482 -20 66 -223
meshvertex 1483 30 49 225
meshvertex 1484 64 49 225
meshvertex 1485 68 54 220
meshvertex 1486 32 54 222
meshvertex 1487 20 61 -225
meshvertex 1488 78 66 -221
meshvertex 1489 76 61 -224
meshvertex 1490 20 66 -223
meshvertex 1491 12 4 12
meshvertex 1492 123 3 12
meshvertex 1493 90 3 181
meshvertex 1494 12 3 251
meshvertex 1495 -66 3 181
meshvertex 1496 -99 3 12
meshvertex 1497 -66 3 -157
meshvertex 1498 12 3 -227
meshvertex 1499 90 3 -157
meshvertex 1500 155 2 12
meshvertex 1501 113 2 201
meshvertex 1502 12 2 279
meshvertex 1503 -89 2 201
meshvertex 1504 -131 2 12
meshvertex 1505 -89 2 -177
meshvertex 1506 12 2 -255
meshvertex 1507 113 2 -177
meshvertex 1508 0 820 0
meshvertex 1509 215 200 0
meshvertex 1510 108 200 186
meshvertex 1511 -107 200 186
meshvertex 1512 -215 200 0
meshvertex 1513 -108 200 -186
meshvertex 1514 108 200 -186
meshvertex 1515 -20 0 0
meshvertex 1516 20 0 0
meshvertex 1517 20 280 0
meshvertex 1518 -20 280 0
meshvertex 1519 0 0 -20
meshvertex 1520 0 0 20
meshvertex 1521 0 280 20
meshvertex 1522 0 280 -20
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
localset 744 119206
localset 745 119718
localset 746 120194
localset 747 120718
localset 748 121230
localset 749 119050
localset 750 122122
localset 751 122634
localset 752 119562
localset 753 123658
localset 754 120074
localset 755 124682
localset 756 120586
localset 757 125706
localset 758 121098
localset 759 126747
localset 760 127242
localset 761 127754
localset 762 128266
localset 763 128794
localset 764 129307
localset 765 129820
localset 766 130316
localset 767 130846
localset 768 131357
localset 769 129436
localset 770 132492
localset 771 133004
localset 772 129932
localset 773 134028
localset 774 130444
localset 775 135052
localset 776 130974
localset 777 136094
localset 778 131486
localset 779 137107
localset 780 137619
localset 781 138128
localset 782 138643
localset 783 139175
localset 784 139536
localset 785 136976
localset 786 138000
localset 787 137512
localset 788 132392
localset 789 138536
localset 790 142740
localset 791 143249
localset 792 143764
localset 793 144276
localset 794 144781
localset 795 145169
localset 796 143121
localset 797 142609
localset 798 143657
localset 799 144169
localset 800 135977
localset 801 148257
localset 802 148770
localset 803 149281
localset 804 149794
localset 805 150314
localset 806 148770
localset 807 151307
localset 808 151820
localset 809 150283
localset 810 152844
localset 811 153354
localset 812 153866
localset 813 154370
localset 814 154882
localset 815 155435
localset 816 154406
localset 817 156420
localset 818 156931
localset 819 155396
localset 820 157955
localset 821 158464
localset 822 158976
localset 823 159532
localset 824 160044
localset 825 160557
localset 826 159532
localset 827 161582
localset 828 162095
localset 829 160558
localset 830 163119
localset 831 163621
localset 832 164133
localset 833 164656
localset 834 165168
localset 835 165681
localset 836 164658
localset 837 166707
localset 838 167220
localset 839 165683
localset 840 168244
localset 841 149279
localset 842 169247
localset 843 169759
localset 844 148767
localset 845 170770
localset 846 148789
localset 847 150325
localset 848 150293
localset 849 172816
localset 850 150290
localset 851 151824
localset 852 174352
localset 853 153360
localset 854 175376
localset 855 154384
localset 856 176402
localset 857 154422
localset 858 155447
localset 859 155448
localset 860 178438
localset 861 155410
localset 862 156934
localset 863 179974
localset 864 158470
localset 865 180998
localset 866 159494
localset 867 182034
localset 868 159545
localset 869 160569
localset 870 160570
localset 871 184123
localset 872 160530
localset 873 162107
localset 874 185659
localset 875 163643
localset 876 186683
localset 877 164667
localset 878 187666
localset 879 164668
localset 880 165693
localset 881 165694
localset 882 189727
localset 883 165650
localset 884 167199
localset 885 169746
localset 886 170770
localset 887 192274
localset 888 192786
localset 889 193298
localset 890 193810
localset 891 194322
localset 892 174354
localset 893 195346
localset 894 195858
localset 895 176402
localset 896 196882
localset 897 197394
localset 898 179986
localset 899 198418
localset 900 198930
localset 901 182034
localset 902 199954
localset 903 200466
localset 904 185618
localset 905 201490
localset 906 202002
localset 907 187666
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
localset 920 209170
localset 921 209682
localset 922 210194
localset 923 210706
localset 924 211218
localset 925 211730
localset 926 212242
localset 927 212754
localset 928 213266
localset 929 213778
localset 930 214305
localset 931 214817
localset 932 215330
localset 933 215842
localset 934 215330
localset 935 216895
localset 936 217355
localset 937 216843
localset 938 218380
localset 939 218892
localset 940 219402
localset 941 219914
localset 942 220418
localset 943 220930
localset 944 220430
localset 945 222016
localset 946 222468
localset 947 221956
localset 948 223491
localset 949 224003
localset 950 224512
localset 951 225024
localset 952 225580
localset 953 226092
localset 954 225580
localset 955 227137
localset 956 227630
localset 957 227118
localset 958 228655
localset 959 229167
localset 960 229669
localset 961 230181
localset 962 230704
localset 963 231216
localset 964 230722
localset 965 232259
localset 966 232755
localset 967 232243
localset 968 233780
localset 969 234292
localset 970 214816
localset 971 235296
localset 972 235808
localset 973 215328
localset 974 236815
localset 975 215364
localset 976 216900
localset 977 216854
localset 978 238865
localset 979 216847
localset 980 218385
localset 981 240401
localset 982 219409
localset 983 241425
localset 984 220433
localset 985 242447
localset 986 220485
localset 987 222022
localset 988 222023
localset 989 244487
localset 990 221967
localset 991 223495
localset 992 246023
localset 993 224519
localset 994 247047
localset 995 225543
localset 996 248079
localset 997 225608
localset 998 227144
localset 999 227145
localset 1000 250186
localset 1001 227087
localset 1002 228682
localset 1003 251722
localset 1004 229706
localset 1005 252746
localset 1006 230730
localset 1007 253711
localset 1008 230731
localset 1009 232268
localset 1010 232269
localset 1011 255776
localset 1012 232207
localset 1013 233760
localset 1014 235279
localset 1015 257807
localset 1016 236815
localset 1017 258831
localset 1018 259343
localset 1019 259855
localset 1020 260367
localset 1021 260879
localset 1022 240399
localset 1023 261903
localset 1024 262415
localset 1025 242447
localset 1026 263439
localset 1027 263951
localset 1028 246031
localset 1029 264975
localset 1030 265487
localset 1031 248079
localset 1032 266511
localset 1033 267023
localset 1034 251663
localset 1035 268047
localset 1036 268559
localset 1037 253711
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
localset 1049 275215
localset 1050 275727
localset 1051 276239
localset 1052 276751
localset 1053 277263
localset 1054 277775
localset 1055 278287
localset 1056 278799
localset 1057 279311
localset 1058 279823
localset 1059 280353
localset 1060 280866
localset 1061 281377
localset 1062 281890
localset 1063 282410
localset 1064 280866
localset 1065 283403
localset 1066 283916
localset 1067 282379
localset 1068 284940
localset 1069 285450
localset 1070 285962
localset 1071 286466
localset 1072 286978
localset 1073 287531
localset 1074 286502
localset 1075 288516
localset 1076 289027
localset 1077 287492
localset 1078 290051
localset 1079 290560
localset 1080 291072
localset 1081 291628
localset 1082 292140
localset 1083 292653
localset 1084 291628
localset 1085 293678
localset 1086 294191
localset 1087 292654
localset 1088 295215
localset 1089 295717
localset 1090 296229
localset 1091 296752
localset 1092 297264
localset 1093 297777
localset 1094 296754
localset 1095 298803
localset 1096 299316
localset 1097 297779
localset 1098 300340
localset 1099 281375
localset 1100 301343
localset 1101 301855
localset 1102 280863
localset 1103 302866
localset 1104 280885
localset 1105 282421
localset 1106 282389
localset 1107 304912
localset 1108 282386
localset 1109 283920
localset 1110 306448
localset 1111 285456
localset 1112 307472
localset 1113 286480
localset 1114 308498
localset 1115 286518
localset 1116 287543
localset 1117 287544
localset 1118 310534
localset 1119 287506
localset 1120 289030
localset 1121 312070
localset 1122 290566
localset 1123 313094
localset 1124 291590
localset 1125 314130
localset 1126 291641
localset 1127 292665
localset 1128 292666
localset 1129 316219
localset 1130 292626
localset 1131 294203
localset 1132 317755
localset 1133 295739
localset 1134 318779
localset 1135 296763
localset 1136 319762
localset 1137 296764
localset 1138 297789
localset 1139 297790
localset 1140 321823
localset 1141 297746
localset 1142 299295
localset 1143 301842
localset 1144 302866
localset 1145 324370
localset 1146 324882
localset 1147 325394
localset 1148 325906
localset 1149 326418
localset 1150 306450
localset 1151 327442
localset 1152 327954
localset 1153 308498
localset 1154 328978
localset 1155 329490
localset 1156 312082
localset 1157 330514
localset 1158 331026
localset 1159 314130
localset 1160 332050
localset 1161 332562
localset 1162 317714
localset 1163 333586
localset 1164 334098
localset 1165 319762
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
localset 1178 341266
localset 1179 341778
localset 1180 342290
localset 1181 342802
localset 1182 343314
localset 1183 343826
localset 1184 344338
localset 1185 344850
localset 1186 345362
localset 1187 345874
localset 1188 346401
localset 1189 346913
localset 1190 347426
localset 1191 347938
localset 1192 347426
localset 1193 348991
localset 1194 349451
localset 1195 348939
localset 1196 350476
localset 1197 350988
localset 1198 351498
localset 1199 352010
localset 1200 352514
localset 1201 353026
localset 1202 352526
localset 1203 354112
localset 1204 354564
localset 1205 354052
localset 1206 355587
localset 1207 356099
localset 1208 356608
localset 1209 357120
localset 1210 357676
localset 1211 358188
localset 1212 357676
localset 1213 359233
localset 1214 359726
localset 1215 359214
localset 1216 360751
localset 1217 361263
localset 1218 361765
localset 1219 362277
localset 1220 362800
localset 1221 363312
localset 1222 362818
localset 1223 364355
localset 1224 364851
localset 1225 364339
localset 1226 365876
localset 1227 366388
localset 1228 346912
localset 1229 367392
localset 1230 367904
localset 1231 347424
localset 1232 368911
localset 1233 347460
localset 1234 348996
localset 1235 348950
localset 1236 370961
localset 1237 348943
localset 1238 350481
localset 1239 372497
localset 1240 351505
localset 1241 373521
localset 1242 352529
localset 1243 374543
localset 1244 352581
localset 1245 354118
localset 1246 354119
localset 1247 376583
localset 1248 354063
localset 1249 355591
localset 1250 378119
localset 1251 356615
localset 1252 379143
localset 1253 357639
localset 1254 380175
localset 1255 357704
localset 1256 359240
localset 1257 359241
localset 1258 382282
localset 1259 359183
localset 1260 360778
localset 1261 383818
localset 1262 361802
localset 1263 384842
localset 1264 362826
localset 1265 385807
localset 1266 362827
localset 1267 364364
localset 1268 364365
localset 1269 387872
localset 1270 364303
localset 1271 365856
localset 1272 367375
localset 1273 389903
localset 1274 368911
localset 1275 390927
localset 1276 391439
localset 1277 391951
localset 1278 392463
localset 1279 392975
localset 1280 372495
localset 1281 393999
localset 1282 394511
localset 1283 374543
localset 1284 395535
localset 1285 396047
localset 1286 378127
localset 1287 397071
localset 1288 397583
localset 1289 380175
localset 1290 398607
localset 1291 399119
localset 1292 383759
localset 1293 400143
localset 1294 400655
localset 1295 385807
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
localset 1307 407311
localset 1308 407823
localset 1309 408335
localset 1310 408847
localset 1311 409359
localset 1312 409871
localset 1313 410383
localset 1314 410895
localset 1315 411407
localset 1316 411919
localset 1317 412427
localset 1318 412939
localset 1319 413451
localset 1320 413986
localset 1321 414467
localset 1322 414979
localset 1323 415491
localset 1324 416003
localset 1325 416530
localset 1326 417042
localset 1327 417554
localset 1328 418064
localset 1329 418602
localset 1330 419114
localset 1331 419626
localset 1332 418588
localset 1333 420636
localset 1334 419100
localset 1335 421763
localset 1336 422275
localset 1337 422787
localset 1338 421763
localset 1339 422787
localset 1340 424323
localset 1341 424220
localset 1342 422684
localset 1343 425756
localset 1344 424220
localset 1345 425756
localset 1346 427292
localset 1347 422181
localset 1348 427301
localset 1349 425765
localset 1350 422165
localset 1351 427285
localset 1352 424213
localset 1353 430859
localset 1354 431371
localset 1355 431883
localset 1356 432418
localset 1357 432899
localset 1358 433411
localset 1359 433923
localset 1360 434435
localset 1361 434959
localset 1362 435471
localset 1363 435983
localset 1364 436497
localset 1365 437055
localset 1366 437567
localset 1367 438079
localset 1368 437022
localset 1369 438046
localset 1370 439582
localset 1371 440195
localset 1372 440707
localset 1373 441219
localset 1374 440195
localset 1375 442243
localset 1376 440707
localset 1377 442142
localset 1378 443678
localset 1379 440606
localset 1380 442142
localset 1381 445214
localset 1382 443678
localset 1383 441125
localset 1384 443685
localset 1385 445221
localset 1386 441110
localset 1387 442134
localset 1388 445206
localset 1389 449313
localset 1390 449825
localset 1391 450337
localset 1392 450849
localset 1393 451328
localset 1394 451840
localset 1395 452352
localset 1396 452864
localset 1397 453379
localset 1398 453891
localset 1399 454403
localset 1400 454915
localset 1401 455427
localset 1402 455939
localset 1403 456451
localset 1404 456963
localset 1405 457475
localset 1406 457987
localset 1407 458499
localset 1408 459011
localset 1409 459523
localset 1410 460035
localset 1411 460547
localset 1412 461059
localset 1413 461568
localset 1414 462080
localset 1415 462592
localset 1416 463104
localset 1417 463616
localset 1418 462124
localset 1419 463182
localset 1420 465152
localset 1421 465664
localset 1422 465196
localset 1423 466688
localset 1424 467200
localset 1425 466767
localset 1426 468224
localset 1427 468736
localset 1428 468227
localset 1429 469760
localset 1430 470272
localset 1431 469763
localset 1432 471296
localset 1433 471808
localset 1434 472320
localset 1435 472832
localset 1436 473344
localset 1437 471852
localset 1438 472910
localset 1439 474880
localset 1440 475392
localset 1441 474924
localset 1442 476416
localset 1443 476928
localset 1444 476495
localset 1445 477952
localset 1446 478464
localset 1447 477955
localset 1448 479488
localset 1449 480000
localset 1450 479491
localset 1451 481050
localset 1452 481562
localset 1453 482074
localset 1454 482586
localset 1455 483097
localset 1456 483609
localset 1457 484121
localset 1458 484633
localset 1459 485130
localset 1460 485642
localset 1461 486154
localset 1462 486666
localset 1463 487178
localset 1464 487690
localset 1465 485126
localset 1466 488710
localset 1467 485650
localset 1468 489734
localset 1469 487687
localset 1470 487183
localset 1471 491271
localset 1472 491783
localset 1473 492298
localset 1474 492810
localset 1475 493322
localset 1476 493842
localset 1477 492306
localset 1478 493327
localset 1479 495375
localset 1480 495882
localset 1481 496394
localset 1482 496906
localset 1483 497426
localset 1484 495890
localset 1485 496911
localset 1486 498959
localset 1487 499466
localset 1488 499978
localset 1489 500490
localset 1490 501010
localset 1491 499474
localset 1492 500495
localset 1493 502543
localset 1494 503050
localset 1495 503562
localset 1496 504074
localset 1497 504594
localset 1498 503058
localset 1499 504079
localset 1500 506127
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
localset 1529 520972
localset 1530 521484
localset 1531 521996
localset 1532 522527
localset 1533 520991
localset 1534 522016
localset 1535 524064
localset 1536 524555
localset 1537 525068
localset 1538 525579
localset 1539 526115
localset 1540 524579
localset 1541 525604
localset 1542 527652
localset 1543 528128
localset 1544 489728
localset 1545 485120
localset 1546 486656
localset 1547 487680
localset 1548 491776
localset 1549 531233
localset 1550 524624
localset 1551 525579
localset 1552 532773
localset 1553 533285
localset 1554 533797
localset 1555 534309
localset 1556 534914
localset 1557 535462
localset 1558 535938
localset 1559 536450
localset 1560 536962
localset 1561 537474
localset 1562 535306
localset 1563 538378
localset 1564 538890
localset 1565 535818
localset 1566 539914
localset 1567 536842
localset 1568 540938
localset 1569 541450
localset 1570 541962
localset 1571 541068
localset 1572 543116
localset 1573 543628
localset 1574 541580
localset 1575 544652
localset 1576 542110
localset 1577 545683
localset 1578 546195
localset 1579 546704
localset 1580 547219
localset 1581 547751
localset 1582 548112
localset 1583 545552
localset 1584 546576
localset 1585 546088
localset 1586 543016
localset 1587 547112
localset 1588 551316
localset 1589 551825
localset 1590 552340
localset 1591 552852
localset 1592 553357
localset 1593 553745
localset 1594 551697
localset 1595 551185
localset 1596 552233
localset 1597 552745
localset 1598 544553
localset 1599 556833
localset 1600 557323
localset 1601 557857
localset 1602 558347
localset 1603 558858
localset 1604 559370
localset 1605 559876
localset 1606 560388
localset 1607 560896
localset 1608 561408
localset 1609 561966
localset 1610 562478
localset 1611 562981
localset 1612 563493
localset 1613 564019
localset 1614 564531
localset 1615 557842
localset 1616 565522
localset 1617 566034
localset 1618 557330
localset 1619 567058
localset 1620 558866
localset 1621 568082
localset 1622 559890
localset 1623 569106
localset 1624 560914
localset 1625 570130
localset 1626 561938
localset 1627 571154
localset 1628 562962
localset 1629 572178
localset 1630 563986
localset 1631 573202
localset 1632 566034
localset 1633 565522
localset 1634 573202
localset 1635 565522
localset 1636 567058
localset 1637 567058
localset 1638 568082
localset 1639 568082
localset 1640 569106
localset 1641 569106
localset 1642 570130
localset 1643 570130
localset 1644 571154
localset 1645 571154
localset 1646 572178
localset 1647 572178
localset 1648 566034
localset 1649 582433
localset 1650 582945
localset 1651 583435
localset 1652 583947
localset 1653 584458
localset 1654 584970
localset 1655 585476
localset 1656 585988
localset 1657 586496
localset 1658 587008
localset 1659 587566
localset 1660 588078
localset 1661 588581
localset 1662 589093
localset 1663 589619
localset 1664 590131
localset 1665 582927
localset 1666 591119
localset 1667 591631
localset 1668 583439
localset 1669 592655
localset 1670 584463
localset 1671 593679
localset 1672 585487
localset 1673 594703
localset 1674 586511
localset 1675 595727
localset 1676 587535
localset 1677 596751
localset 1678 588559
localset 1679 597775
localset 1680 589583
localset 1681 598799
localset 1682 591631
localset 1683 591119
localset 1684 598799
localset 1685 592655
localset 1686 591631
localset 1687 593679
localset 1688 592655
localset 1689 594703
localset 1690 593679
localset 1691 595727
localset 1692 594703
localset 1693 596751
localset 1694 595727
localset 1695 597775
localset 1696 596751
localset 1697 591119
localset 1698 597775
localset 1699 608033
localset 1700 608523
localset 1701 609057
localset 1702 609547
localset 1703 610058
localset 1704 610570
localset 1705 611076
localset 1706 611588
localset 1707 612096
localset 1708 612608
localset 1709 613166
localset 1710 613678
localset 1711 614181
localset 1712 614693
localset 1713 615219
localset 1714 615731
localset 1715 609042
localset 1716 616722
localset 1717 617234
localset 1718 608530
localset 1719 618258
localset 1720 610066
localset 1721 619282
localset 1722 611090
localset 1723 620306
localset 1724 612114
localset 1725 621330
localset 1726 613138
localset 1727 622354
localset 1728 614162
localset 1729 623378
localset 1730 615186
localset 1731 624402
localset 1732 617234
localset 1733 616722
localset 1734 624402
localset 1735 616722
localset 1736 618258
localset 1737 618258
localset 1738 619282
localset 1739 619282
localset 1740 620306
localset 1741 620306
localset 1742 621330
localset 1743 621330
localset 1744 622354
localset 1745 622354
localset 1746 623378
localset 1747 623378
localset 1748 617234
localset 1749 633633
localset 1750 634145
localset 1751 634635
localset 1752 635147
localset 1753 635658
localset 1754 636170
localset 1755 636676
localset 1756 637188
localset 1757 637696
localset 1758 638208
localset 1759 638766
localset 1760 639278
localset 1761 639781
localset 1762 640293
localset 1763 640819
localset 1764 641331
localset 1765 634127
localset 1766 642319
localset 1767 642831
localset 1768 634639
localset 1769 643855
localset 1770 635663
localset 1771 644879
localset 1772 636687
localset 1773 645903
localset 1774 637711
localset 1775 646927
localset 1776 638735
localset 1777 647951
localset 1778 639759
localset 1779 648975
localset 1780 640783
localset 1781 649999
localset 1782 642831
localset 1783 642319
localset 1784 649999
localset 1785 643855
localset 1786 642831
localset 1787 644879
localset 1788 643855
localset 1789 645903
localset 1790 644879
localset 1791 646927
localset 1792 645903
localset 1793 647951
localset 1794 646927
localset 1795 648975
localset 1796 647951
localset 1797 642319
localset 1798 648975
localset 1799 659211
localset 1800 659723
localset 1801 660235
localset 1802 660770
localset 1803 661251
localset 1804 661763
localset 1805 662275
localset 1806 662787
localset 1807 663314
localset 1808 663826
localset 1809 664338
localset 1810 664843
localset 1811 665355
localset 1812 665867
localset 1813 666402
localset 1814 666883
localset 1815 667395
localset 1816 667907
localset 1817 668419
localset 1818 668943
localset 1819 669455
localset 1820 669967
localset 1821 670497
localset 1822 671009
localset 1823 671521
localset 1824 672033
localset 1825 672512
localset 1826 673024
localset 1827 673536
localset 1828 674048
localset 1829 674570
localset 1830 675082
localset 1831 675594
localset 1832 676106
localset 1833 676618
localset 1834 677130
localset 1835 674578
localset 1836 678162
localset 1837 675090
localset 1838 679186
localset 1839 677135
localset 1840 676623
localset 1841 680719
localset 1842 681231
localset 1843 681738
localset 1844 682250
localset 1845 682762
localset 1846 683282
localset 1847 681746
localset 1848 682767
localset 1849 684815
localset 1850 685322
localset 1851 685834
localset 1852 686346
localset 1853 686866
localset 1854 685330
localset 1855 686351
localset 1856 688399
localset 1857 688926
localset 1858 689418
localset 1859 689930
localset 1860 690450
localset 1861 688914
localset 1862 689935
localset 1863 691983
localset 1864 692491
localset 1865 693004
localset 1866 693515
localset 1867 694097
localset 1868 692515
localset 1869 693540
localset 1870 695634
localset 1871 679168
localset 1872 674560
localset 1873 677120
localset 1874 681216
localset 1875 693515
localset 1876 692522
localset 1877 699173
localset 1878 699685
localset 1879 700197
localset 1880 700709
localset 1881 701350
localset 1882 701862
localset 1883 702338
localset 1884 702850
localset 1885 703374
localset 1886 703874
localset 1887 701706
localset 1888 704778
localset 1889 705290
localset 1890 702218
localset 1891 706314
localset 1892 703242
localset 1893 704908
localset 1894 707980
localset 1895 708492
localset 1896 705420
localset 1897 709516
localset 1898 706462
localset 1899 710547
localset 1900 711059
localset 1901 711568
localset 1902 712083
localset 1903 712596
localset 1904 713105
localset 1905 713620
localset 1906 714132
localset 1907 714507
localset 1908 715019
localset 1909 715531
localset 1910 716043
localset 1911 716036
localset 1912 717060
localset 1913 715012
localset 1914 718084
localset 1915 718126
localset 1916 719150
localset 1917 717102
localset 1918 720174
localset 1919 720179
localset 1920 715571
localset 1921 719155
localset 1922 714547
localset 1923 715538
localset 1924 715026
localset 1925 717074
localset 1926 719122
localset 1927 724747
localset 1928 725259
localset 1929 725771
localset 1930 726283
localset 1931 726276
localset 1932 725764
localset 1933 727812
localset 1934 728324
localset 1935 728366
localset 1936 727854
localset 1937 729902
localset 1938 730414
localset 1939 730419
localset 1940 729907
localset 1941 725299
localset 1942 724787
localset 1943 725263
localset 1944 727823
localset 1945 725775
localset 1946 729871
localset 1947 734987
localset 1948 735499
localset 1949 736011
localset 1950 736523
localset 1951 736516
localset 1952 737540
localset 1953 735492
localset 1954 738564
localset 1955 738606
localset 1956 739630
localset 1957 737582
localset 1958 740654
localset 1959 740659
localset 1960 736051
localset 1961 739635
localset 1962 735027
localset 1963 736018
localset 1964 735506
localset 1965 737554
localset 1966 739602
localset 1967 745227
localset 1968 745739
localset 1969 746251
localset 1970 746763
localset 1971 746756
localset 1972 746244
localset 1973 748292
localset 1974 748804
localset 1975 748846
localset 1976 748334
localset 1977 750382
localset 1978 750894
localset 1979 750899
localset 1980 750387
localset 1981 745779
localset 1982 745267
localset 1983 745743
localset 1984 748303
localset 1985 746255
localset 1986 750351
localset 1987 755467
localset 1988 755979
localset 1989 756491
localset 1990 757026
localset 1991 757507
localset 1992 758019
localset 1993 758531
localset 1994 759043
localset 1995 759563
localset 1996 760075
localset 1997 760587
localset 1998 761122
localset 1999 761603
localset 2000 762115
localset 2001 762627
localset 2002 763139
localset 2003 763647
localset 2004 764079
localset 2005 764591
localset 2006 765103
localset 2007 765615
localset 2008 766127
localset 2009 766639
localset 2010 767151
localset 2011 767663
localset 2012 768000
localset 2013 768512
localset 2014 769024
localset 2015 769536
localset 2016 770048
localset 2017 770560
localset 2018 771072
localset 2019 771584
localset 2020 772352
localset 2021 772864
localset 2022 773376
localset 2023 773888
localset 2024 774400
localset 2025 774912
localset 2026 775424
localset 2027 775936
localset 2028 776448
localset 2029 776960
localset 2030 777472
localset 2031 777984
localset 2032 778496
localset 2033 779008
localset 2034 779520
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
set r0 947
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
set r0 947
mov r9 r0
localset 132 r9
set r0 1317
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
set r0 1508
mov r9 r0
localset 132 r9
set r0 1523
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
set r0 1317
mov r9 r0
localset 132 r9
set r0 1491
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
mul r1 20
add r0 r1
localget r1 3002
mul r1 -16384
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
mul r2 20
add r1 r2
localget r2 3005
mul r2 -16384
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
mul r0 83
localget r1 3001
mul r1 15136
add r0 r1
localget r1 3002
mul r1 -6272
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
mul r1 83
localget r2 3004
mul r2 15136
add r1 r2
localget r2 3005
mul r2 -6272
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
mul r0 83
localget r1 3007
mul r1 15136
add r0 r1
localget r1 3008
mul r1 -6272
add r0 r1
div r0 16384
mul r0 2
mul r0 15136
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
mul r0 3
localget r1 3001
mul r1 6098
add r0 r1
localget r1 3002
mul r1 -15207
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_61
set r0 0
label diffuse_positive_61
mul r0 128
div r0 16384
add r0 70
localget r1 3003
mul r1 3
localget r2 3004
mul r2 6098
add r1 r2
localget r2 3005
mul r2 -15207
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
mul r0 3
localget r1 3007
mul r1 6098
add r0 r1
localget r1 3008
mul r1 -15207
add r0 r1
div r0 16384
mul r0 2
mul r0 6098
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
mul r0 30
localget r1 3001
mul r1 11625
add r0 r1
localget r1 3002
mul r1 -11546
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
mul r1 30
localget r2 3004
mul r2 11625
add r1 r2
localget r2 3005
mul r2 -11546
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
mul r0 37
localget r1 3001
mul r1 16382
add r0 r1
localget r1 3002
mul r1 267
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
mul r1 37
localget r2 3004
mul r2 16382
add r1 r2
localget r2 3005
mul r2 267
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
localget r0 3000
mul r0 38
localget r1 3001
mul r1 11418
add r0 r1
localget r1 3002
mul r1 11750
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_103
set r0 0
label diffuse_positive_103
mul r0 128
div r0 16384
add r0 75
localget r1 3003
mul r1 38
localget r2 3004
mul r2 11418
add r1 r2
localget r2 3005
mul r2 11750
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_104
set r1 0
label highlight_positive_104
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
jle intensity_bounded_105
set r0 255
label intensity_bounded_105
localset 2411 r0
label body_lighting_done_101
localget r0 3000
mul r0 -186
localget r1 3001
mul r1 15008
add r0 r1
localget r1 3002
mul r1 6569
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_108
set r0 0
label diffuse_positive_108
mul r0 128
div r0 16384
add r0 79
localget r1 3003
mul r1 -186
localget r2 3004
mul r2 15008
add r1 r2
localget r2 3005
mul r2 6569
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_109
set r1 0
label highlight_positive_109
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
jle intensity_bounded_110
set r0 255
label intensity_bounded_110
localset 2412 r0
label body_lighting_done_106
localget r0 3006
mul r0 -186
localget r1 3007
mul r1 15008
add r0 r1
localget r1 3008
mul r1 6569
add r0 r1
div r0 16384
mul r0 2
mul r0 15008
div r0 16384
localget r1 3007
sub r0 r1
mul r0 100
div r0 16384
add r0 128
cmp r0 0
jge glass_low_111
set r0 0
label glass_low_111
cmp r0 255
jle glass_high_112
set r0 255
label glass_high_112
localset 2612 r0
label glass_lighting_done_107
localget r3 3030
cmp r3 0
jne body_lighting_done_113
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
jge diffuse_positive_115
set r0 0
label diffuse_positive_115
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
jge highlight_positive_116
set r1 0
label highlight_positive_116
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
jle intensity_bounded_117
set r0 255
label intensity_bounded_117
localset 2413 r0
label body_lighting_done_113
localget r3 3030
cmp r3 2
je glass_lighting_done_114
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
jge glass_low_118
set r0 0
label glass_low_118
cmp r0 255
jle glass_high_119
set r0 255
label glass_high_119
localset 2613 r0
label glass_lighting_done_114
localget r3 3030
cmp r3 0
jne body_lighting_done_120
localget r0 3000
mul r0 2006
localget r1 3001
mul r1 15178
add r0 r1
localget r1 3002
mul r1 -5833
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_122
set r0 0
label diffuse_positive_122
mul r0 128
div r0 16384
add r0 79
localget r1 3003
mul r1 2006
localget r2 3004
mul r2 15178
add r1 r2
localget r2 3005
mul r2 -5833
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_123
set r1 0
label highlight_positive_123
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
jle intensity_bounded_124
set r0 255
label intensity_bounded_124
localset 2414 r0
label body_lighting_done_120
localget r3 3030
cmp r3 1
je glass_lighting_done_121
localget r0 3006
mul r0 2006
localget r1 3007
mul r1 15178
add r0 r1
localget r1 3008
mul r1 -5833
add r0 r1
div r0 16384
mul r0 2
mul r0 15178
div r0 16384
localget r1 3007
sub r0 r1
mul r0 100
div r0 16384
add r0 128
cmp r0 0
jge glass_low_125
set r0 0
label glass_low_125
cmp r0 255
jle glass_high_126
set r0 255
label glass_high_126
localset 2614 r0
label glass_lighting_done_121
localget r0 3000
mul r0 16384
localget r1 3001
mul r1 78
add r0 r1
localget r1 3002
mul r1 17
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_129
set r0 0
label diffuse_positive_129
mul r0 128
div r0 16384
add r0 64
localget r1 3003
mul r1 16384
localget r2 3004
mul r2 78
add r1 r2
localget r2 3005
mul r2 17
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_130
set r1 0
label highlight_positive_130
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
jle intensity_bounded_131
set r0 255
label intensity_bounded_131
localset 2415 r0
label body_lighting_done_127
localget r3 3030
cmp r3 2
je body_lighting_done_132
localget r0 3000
mul r0 -15542
localget r1 3001
mul r1 5184
add r0 r1
localget r1 3002
mul r1 145
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_134
set r0 0
label diffuse_positive_134
mul r0 128
div r0 16384
add r0 69
localget r1 3003
mul r1 -15542
localget r2 3004
mul r2 5184
add r1 r2
localget r2 3005
mul r2 145
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_135
set r1 0
label highlight_positive_135
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
jle intensity_bounded_136
set r0 255
label intensity_bounded_136
localset 2416 r0
label body_lighting_done_132
localget r0 3006
mul r0 -15542
localget r1 3007
mul r1 5184
add r0 r1
localget r1 3008
mul r1 145
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
jge glass_low_137
set r0 0
label glass_low_137
cmp r0 255
jle glass_high_138
set r0 255
label glass_high_138
localset 2616 r0
label glass_lighting_done_133
localget r3 3030
cmp r3 2
je body_lighting_done_139
localget r0 3000
mul r0 15484
localget r1 3001
mul r1 5353
add r0 r1
localget r1 3002
mul r1 104
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_141
set r0 0
label diffuse_positive_141
mul r0 128
div r0 16384
add r0 69
localget r1 3003
mul r1 15484
localget r2 3004
mul r2 5353
add r1 r2
localget r2 3005
mul r2 104
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_142
set r1 0
label highlight_positive_142
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
jle intensity_bounded_143
set r0 255
label intensity_bounded_143
localset 2417 r0
label body_lighting_done_139
localget r0 3006
mul r0 15484
localget r1 3007
mul r1 5353
add r0 r1
localget r1 3008
mul r1 104
add r0 r1
div r0 16384
mul r0 2
mul r0 5353
div r0 16384
localget r1 3007
sub r0 r1
mul r0 100
div r0 16384
add r0 128
cmp r0 0
jge glass_low_144
set r0 0
label glass_low_144
cmp r0 255
jle glass_high_145
set r0 255
label glass_high_145
localset 2617 r0
label glass_lighting_done_140
localget r0 3000
mul r0 -16384
localget r1 3001
mul r1 55
add r0 r1
localget r1 3002
mul r1 41
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_148
set r0 0
label diffuse_positive_148
mul r0 128
div r0 16384
add r0 64
localget r1 3003
mul r1 -16384
localget r2 3004
mul r2 55
add r1 r2
localget r2 3005
mul r2 41
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_149
set r1 0
label highlight_positive_149
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
jle intensity_bounded_150
set r0 255
label intensity_bounded_150
localset 2418 r0
label body_lighting_done_146
localget r3 3030
cmp r3 0
jne body_lighting_done_151
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
jge diffuse_positive_153
set r0 0
label diffuse_positive_153
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
jge highlight_positive_154
set r1 0
label highlight_positive_154
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
jle intensity_bounded_155
set r0 255
label intensity_bounded_155
localset 2419 r0
label body_lighting_done_151
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
jge glass_low_156
set r0 0
label glass_low_156
cmp r0 255
jle glass_high_157
set r0 255
label glass_high_157
localset 2619 r0
label glass_lighting_done_152
localget r3 3030
cmp r3 0
jne body_lighting_done_158
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
jge diffuse_positive_160
set r0 0
label diffuse_positive_160
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
jge highlight_positive_161
set r1 0
label highlight_positive_161
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
jle intensity_bounded_162
set r0 255
label intensity_bounded_162
localset 2420 r0
label body_lighting_done_158
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
jge glass_low_163
set r0 0
label glass_low_163
cmp r0 255
jle glass_high_164
set r0 255
label glass_high_164
localset 2620 r0
label glass_lighting_done_159
localget r3 3030
cmp r3 0
jne body_lighting_done_165
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
jge diffuse_positive_167
set r0 0
label diffuse_positive_167
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
jge highlight_positive_168
set r1 0
label highlight_positive_168
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
jle intensity_bounded_169
set r0 255
label intensity_bounded_169
localset 2421 r0
label body_lighting_done_165
localget r3 3030
cmp r3 0
jne body_lighting_done_170
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
jge diffuse_positive_172
set r0 0
label diffuse_positive_172
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
jge highlight_positive_173
set r1 0
label highlight_positive_173
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
jle intensity_bounded_174
set r0 255
label intensity_bounded_174
localset 2422 r0
label body_lighting_done_170
localget r3 3030
cmp r3 0
jne body_lighting_done_175
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
jge diffuse_positive_177
set r0 0
label diffuse_positive_177
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
jge highlight_positive_178
set r1 0
label highlight_positive_178
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
jle intensity_bounded_179
set r0 255
label intensity_bounded_179
localset 2423 r0
label body_lighting_done_175
localget r3 3030
cmp r3 0
jne body_lighting_done_180
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
jge diffuse_positive_182
set r0 0
label diffuse_positive_182
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
jge highlight_positive_183
set r1 0
label highlight_positive_183
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
jle intensity_bounded_184
set r0 255
label intensity_bounded_184
localset 2424 r0
label body_lighting_done_180
localget r3 3030
cmp r3 0
jne body_lighting_done_185
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
jge diffuse_positive_187
set r0 0
label diffuse_positive_187
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
jge highlight_positive_188
set r1 0
label highlight_positive_188
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
jle intensity_bounded_189
set r0 255
label intensity_bounded_189
localset 2425 r0
label body_lighting_done_185
localget r3 3030
cmp r3 0
jne body_lighting_done_190
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
jge diffuse_positive_192
set r0 0
label diffuse_positive_192
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
jge highlight_positive_193
set r1 0
label highlight_positive_193
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
jle intensity_bounded_194
set r0 255
label intensity_bounded_194
localset 2426 r0
label body_lighting_done_190
localget r3 3030
cmp r3 0
jne body_lighting_done_195
localget r0 3000
mul r0 -2832
localget r1 3001
mul r1 15911
add r0 r1
localget r1 3002
mul r1 2696
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_197
set r0 0
label diffuse_positive_197
mul r0 128
div r0 16384
add r0 80
localget r1 3003
mul r1 -2832
localget r2 3004
mul r2 15911
add r1 r2
localget r2 3005
mul r2 2696
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_198
set r1 0
label highlight_positive_198
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
jle intensity_bounded_199
set r0 255
label intensity_bounded_199
localset 2427 r0
label body_lighting_done_195
localget r3 3030
cmp r3 0
jne body_lighting_done_200
localget r0 3000
mul r0 -2141
localget r1 3001
mul r1 14819
add r0 r1
localget r1 3002
mul r1 6651
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_202
set r0 0
label diffuse_positive_202
mul r0 128
div r0 16384
add r0 78
localget r1 3003
mul r1 -2141
localget r2 3004
mul r2 14819
add r1 r2
localget r2 3005
mul r2 6651
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_203
set r1 0
label highlight_positive_203
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
jle intensity_bounded_204
set r0 255
label intensity_bounded_204
localset 2428 r0
label body_lighting_done_200
localget r3 3030
cmp r3 0
jne glass_lighting_done_201
localget r0 3006
mul r0 -2141
localget r1 3007
mul r1 14819
add r0 r1
localget r1 3008
mul r1 6651
add r0 r1
div r0 16384
mul r0 2
mul r0 14819
div r0 16384
localget r1 3007
sub r0 r1
mul r0 100
div r0 16384
add r0 128
cmp r0 0
jge glass_low_205
set r0 0
label glass_low_205
cmp r0 255
jle glass_high_206
set r0 255
label glass_high_206
localset 2628 r0
label glass_lighting_done_201
localget r3 3030
cmp r3 0
jne body_lighting_done_207
localget r0 3000
mul r0 3121
localget r1 3001
mul r1 15732
add r0 r1
localget r1 3002
mul r1 3347
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_209
set r0 0
label diffuse_positive_209
mul r0 128
div r0 16384
add r0 79
localget r1 3003
mul r1 3121
localget r2 3004
mul r2 15732
add r1 r2
localget r2 3005
mul r2 3347
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_210
set r1 0
label highlight_positive_210
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
jle intensity_bounded_211
set r0 255
label intensity_bounded_211
localset 2429 r0
label body_lighting_done_207
localget r3 3030
cmp r3 1
je body_lighting_done_212
localget r0 3000
mul r0 2045
localget r1 3001
mul r1 14778
add r0 r1
localget r1 3002
mul r1 6772
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_214
set r0 0
label diffuse_positive_214
mul r0 128
div r0 16384
add r0 78
localget r1 3003
mul r1 2045
localget r2 3004
mul r2 14778
add r1 r2
localget r2 3005
mul r2 6772
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_215
set r1 0
label highlight_positive_215
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
jle intensity_bounded_216
set r0 255
label intensity_bounded_216
localset 2430 r0
label body_lighting_done_212
localget r0 3006
mul r0 2045
localget r1 3007
mul r1 14778
add r0 r1
localget r1 3008
mul r1 6772
add r0 r1
div r0 16384
mul r0 2
mul r0 14778
div r0 16384
localget r1 3007
sub r0 r1
mul r0 100
div r0 16384
add r0 128
cmp r0 0
jge glass_low_217
set r0 0
label glass_low_217
cmp r0 255
jle glass_high_218
set r0 255
label glass_high_218
localset 2630 r0
label glass_lighting_done_213
localget r3 3030
cmp r3 2
je body_lighting_done_219
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
jge diffuse_positive_221
set r0 0
label diffuse_positive_221
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
jge highlight_positive_222
set r1 0
label highlight_positive_222
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
jle intensity_bounded_223
set r0 255
label intensity_bounded_223
localset 2431 r0
label body_lighting_done_219
localget r3 3030
cmp r3 2
je body_lighting_done_224
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
jge diffuse_positive_226
set r0 0
label diffuse_positive_226
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
jge highlight_positive_227
set r1 0
label highlight_positive_227
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
jle intensity_bounded_228
set r0 255
label intensity_bounded_228
localset 2432 r0
label body_lighting_done_224
localget r3 3030
cmp r3 2
je body_lighting_done_229
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
jge diffuse_positive_231
set r0 0
label diffuse_positive_231
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
jge highlight_positive_232
set r1 0
label highlight_positive_232
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
jle intensity_bounded_233
set r0 255
label intensity_bounded_233
localset 2433 r0
label body_lighting_done_229
localget r3 3030
cmp r3 0
jne body_lighting_done_234
localget r0 3000
mul r0 -50
localget r1 3001
mul r1 6894
add r0 r1
localget r1 3002
mul r1 14863
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_236
set r0 0
label diffuse_positive_236
mul r0 128
div r0 16384
add r0 71
localget r1 3003
mul r1 -50
localget r2 3004
mul r2 6894
add r1 r2
localget r2 3005
mul r2 14863
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_237
set r1 0
label highlight_positive_237
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
jle intensity_bounded_238
set r0 255
label intensity_bounded_238
localset 2434 r0
label body_lighting_done_234
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
jge diffuse_positive_241
set r0 0
label diffuse_positive_241
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
jge highlight_positive_242
set r1 0
label highlight_positive_242
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
jle intensity_bounded_243
set r0 255
label intensity_bounded_243
localset 2435 r0
label body_lighting_done_239
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
jge diffuse_positive_246
set r0 0
label diffuse_positive_246
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
jge highlight_positive_247
set r1 0
label highlight_positive_247
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
jle intensity_bounded_248
set r0 255
label intensity_bounded_248
localset 2436 r0
label body_lighting_done_244
localget r3 3030
cmp r3 2
je body_lighting_done_249
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
jge diffuse_positive_251
set r0 0
label diffuse_positive_251
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
jge highlight_positive_252
set r1 0
label highlight_positive_252
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
jle intensity_bounded_253
set r0 255
label intensity_bounded_253
localset 2437 r0
label body_lighting_done_249
localget r3 3030
cmp r3 0
jne body_lighting_done_254
localget r0 3000
mul r0 -1986
localget r1 3001
mul r1 15324
add r0 r1
localget r1 3002
mul r1 -5446
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_256
set r0 0
label diffuse_positive_256
mul r0 128
div r0 16384
add r0 79
localget r1 3003
mul r1 -1986
localget r2 3004
mul r2 15324
add r1 r2
localget r2 3005
mul r2 -5446
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_257
set r1 0
label highlight_positive_257
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
jle intensity_bounded_258
set r0 255
label intensity_bounded_258
localset 2438 r0
label body_lighting_done_254
localget r0 3006
mul r0 -1986
localget r1 3007
mul r1 15324
add r0 r1
localget r1 3008
mul r1 -5446
add r0 r1
div r0 16384
mul r0 2
mul r0 15324
div r0 16384
localget r1 3007
sub r0 r1
mul r0 100
div r0 16384
add r0 128
cmp r0 0
jge glass_low_259
set r0 0
label glass_low_259
cmp r0 255
jle glass_high_260
set r0 255
label glass_high_260
localset 2638 r0
label glass_lighting_done_255
localget r3 3030
cmp r3 2
je glass_lighting_done_262
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
jge glass_low_263
set r0 0
label glass_low_263
cmp r0 255
jle glass_high_264
set r0 255
label glass_high_264
localset 2639 r0
label glass_lighting_done_262
localget r3 3030
cmp r3 2
je body_lighting_done_265
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
jge diffuse_positive_267
set r0 0
label diffuse_positive_267
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
jge highlight_positive_268
set r1 0
label highlight_positive_268
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
jle intensity_bounded_269
set r0 255
label intensity_bounded_269
localset 2440 r0
label body_lighting_done_265
localget r3 3030
cmp r3 2
je body_lighting_done_270
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
jge diffuse_positive_272
set r0 0
label diffuse_positive_272
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
jge highlight_positive_273
set r1 0
label highlight_positive_273
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
jle intensity_bounded_274
set r0 255
label intensity_bounded_274
localset 2441 r0
label body_lighting_done_270
localget r3 3030
cmp r3 1
je body_lighting_done_275
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
jge diffuse_positive_277
set r0 0
label diffuse_positive_277
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
localset 2442 r0
label body_lighting_done_275
localget r3 3030
cmp r3 0
jne body_lighting_done_280
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
jge diffuse_positive_282
set r0 0
label diffuse_positive_282
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
localset 2443 r0
label body_lighting_done_280
localget r3 3030
cmp r3 0
jne body_lighting_done_285
localget r0 3000
mul r0 -2
localget r1 3001
mul r1 -5555
add r0 r1
localget r1 3002
mul r1 -15414
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_287
set r0 0
label diffuse_positive_287
mul r0 128
div r0 16384
add r0 59
localget r1 3003
mul r1 -2
localget r2 3004
mul r2 -5555
add r1 r2
localget r2 3005
mul r2 -15414
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
localset 2444 r0
label body_lighting_done_285
localget r3 3030
cmp r3 0
jne body_lighting_done_290
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
jge diffuse_positive_292
set r0 0
label diffuse_positive_292
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
localset 2445 r0
label body_lighting_done_290
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
jge diffuse_positive_297
set r0 0
label diffuse_positive_297
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
localset 2446 r0
label body_lighting_done_295
localget r3 3030
cmp r3 0
jne body_lighting_done_300
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
jge diffuse_positive_302
set r0 0
label diffuse_positive_302
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
localset 2447 r0
label body_lighting_done_300
localget r3 3030
cmp r3 0
jne body_lighting_done_305
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
jge diffuse_positive_307
set r0 0
label diffuse_positive_307
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
localset 2448 r0
label body_lighting_done_305
localget r3 3030
cmp r3 0
jne body_lighting_done_310
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
jge diffuse_positive_312
set r0 0
label diffuse_positive_312
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
localset 2449 r0
label body_lighting_done_310
localget r3 3030
cmp r3 0
jne body_lighting_done_315
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
jge diffuse_positive_317
set r0 0
label diffuse_positive_317
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
localset 2450 r0
label body_lighting_done_315
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
jge diffuse_positive_322
set r0 0
label diffuse_positive_322
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
localset 2451 r0
label body_lighting_done_320
localget r3 3030
cmp r3 0
jne body_lighting_done_325
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
jge diffuse_positive_327
set r0 0
label diffuse_positive_327
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
localset 2452 r0
label body_lighting_done_325
localget r3 3030
cmp r3 0
jne body_lighting_done_330
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
jge diffuse_positive_332
set r0 0
label diffuse_positive_332
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
localset 2453 r0
label body_lighting_done_330
localget r3 3030
cmp r3 0
jne body_lighting_done_335
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
jge diffuse_positive_337
set r0 0
label diffuse_positive_337
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
localset 2454 r0
label body_lighting_done_335
localget r3 3030
cmp r3 0
jne body_lighting_done_340
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
jge diffuse_positive_342
set r0 0
label diffuse_positive_342
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
localset 2455 r0
label body_lighting_done_340
localget r3 3030
cmp r3 0
jne body_lighting_done_345
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
jge diffuse_positive_347
set r0 0
label diffuse_positive_347
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
localset 2456 r0
label body_lighting_done_345
localget r3 3030
cmp r3 0
jne body_lighting_done_350
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
jge diffuse_positive_352
set r0 0
label diffuse_positive_352
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
localset 2457 r0
label body_lighting_done_350
localget r3 3030
cmp r3 0
jne body_lighting_done_355
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
jge diffuse_positive_357
set r0 0
label diffuse_positive_357
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
localset 2458 r0
label body_lighting_done_355
localget r3 3030
cmp r3 0
jne body_lighting_done_360
localget r0 3000
mul r0 -15933
localget r1 3001
mul r1 -3817
add r0 r1
localget r1 3002
mul r1 -88
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_362
set r0 0
label diffuse_positive_362
mul r0 128
div r0 16384
add r0 60
localget r1 3003
mul r1 -15933
localget r2 3004
mul r2 -3817
add r1 r2
localget r2 3005
mul r2 -88
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
localset 2459 r0
label body_lighting_done_360
localget r3 3030
cmp r3 0
jne body_lighting_done_365
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
jge diffuse_positive_367
set r0 0
label diffuse_positive_367
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
localset 2460 r0
label body_lighting_done_365
localget r3 3030
cmp r3 0
jne body_lighting_done_370
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
jge diffuse_positive_372
set r0 0
label diffuse_positive_372
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
localset 2461 r0
label body_lighting_done_370
localget r3 3030
cmp r3 0
jne body_lighting_done_375
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
jge diffuse_positive_377
set r0 0
label diffuse_positive_377
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
localset 2462 r0
label body_lighting_done_375
localget r3 3030
cmp r3 0
jne body_lighting_done_380
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
jge diffuse_positive_382
set r0 0
label diffuse_positive_382
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
localset 2463 r0
label body_lighting_done_380
localget r3 3030
cmp r3 0
jne body_lighting_done_385
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
jge diffuse_positive_387
set r0 0
label diffuse_positive_387
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
localset 2464 r0
label body_lighting_done_385
localget r3 3030
cmp r3 0
jne body_lighting_done_390
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
jge diffuse_positive_392
set r0 0
label diffuse_positive_392
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
localset 2465 r0
label body_lighting_done_390
localget r3 3030
cmp r3 0
jne body_lighting_done_395
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
jge diffuse_positive_397
set r0 0
label diffuse_positive_397
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
localset 2466 r0
label body_lighting_done_395
localget r3 3030
cmp r3 0
jne body_lighting_done_400
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
jge diffuse_positive_402
set r0 0
label diffuse_positive_402
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
localset 2467 r0
label body_lighting_done_400
localget r3 3030
cmp r3 0
jne body_lighting_done_405
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
jge diffuse_positive_407
set r0 0
label diffuse_positive_407
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
localset 2468 r0
label body_lighting_done_405
localget r3 3030
cmp r3 0
jne body_lighting_done_410
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
jge diffuse_positive_412
set r0 0
label diffuse_positive_412
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
localset 2469 r0
label body_lighting_done_410
localget r3 3030
cmp r3 0
jne body_lighting_done_415
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
jge diffuse_positive_417
set r0 0
label diffuse_positive_417
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
localset 2470 r0
label body_lighting_done_415
localget r3 3030
cmp r3 0
jne body_lighting_done_420
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
jge diffuse_positive_422
set r0 0
label diffuse_positive_422
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
localset 2471 r0
label body_lighting_done_420
localget r3 3030
cmp r3 0
jne body_lighting_done_425
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
jge diffuse_positive_427
set r0 0
label diffuse_positive_427
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
localset 2472 r0
label body_lighting_done_425
localget r3 3030
cmp r3 0
jne body_lighting_done_430
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
jge diffuse_positive_432
set r0 0
label diffuse_positive_432
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
localset 2473 r0
label body_lighting_done_430
localget r3 3030
cmp r3 0
jne body_lighting_done_435
localget r0 3000
mul r0 15933
localget r1 3001
mul r1 -3817
add r0 r1
localget r1 3002
mul r1 -88
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_437
set r0 0
label diffuse_positive_437
mul r0 128
div r0 16384
add r0 60
localget r1 3003
mul r1 15933
localget r2 3004
mul r2 -3817
add r1 r2
localget r2 3005
mul r2 -88
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
localset 2474 r0
label body_lighting_done_435
localget r3 3030
cmp r3 0
jne body_lighting_done_440
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
jge diffuse_positive_442
set r0 0
label diffuse_positive_442
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
localset 2475 r0
label body_lighting_done_440
localget r3 3030
cmp r3 0
jne body_lighting_done_445
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
jge diffuse_positive_447
set r0 0
label diffuse_positive_447
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
localset 2476 r0
label body_lighting_done_445
localget r3 3030
cmp r3 0
jne body_lighting_done_450
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
jge diffuse_positive_452
set r0 0
label diffuse_positive_452
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
localset 2477 r0
label body_lighting_done_450
localget r3 3030
cmp r3 1
jne body_lighting_done_459
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
jge diffuse_positive_461
set r0 0
label diffuse_positive_461
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
jge highlight_positive_462
set r1 0
label highlight_positive_462
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
jle intensity_bounded_463
set r0 255
label intensity_bounded_463
localset 2480 r0
label body_lighting_done_459
localget r3 3030
cmp r3 2
jne body_lighting_done_464
localget r0 3000
mul r0 -9598
localget r1 3001
mul r1 0
add r0 r1
localget r1 3002
mul r1 13279
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_466
set r0 0
label diffuse_positive_466
mul r0 128
div r0 16384
add r0 64
localget r1 3003
mul r1 -9598
localget r2 3004
mul r2 0
add r1 r2
localget r2 3005
mul r2 13279
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_467
set r1 0
label highlight_positive_467
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
jle intensity_bounded_468
set r0 255
label intensity_bounded_468
localset 2481 r0
label body_lighting_done_464
localget r3 3030
cmp r3 2
jne body_lighting_done_469
localget r0 3000
mul r0 12589
localget r1 3001
mul r1 0
add r0 r1
localget r1 3002
mul r1 10486
add r0 r1
div r0 16384
cmp r0 0
jge diffuse_positive_471
set r0 0
label diffuse_positive_471
mul r0 128
div r0 16384
add r0 64
localget r1 3003
mul r1 12589
localget r2 3004
mul r2 0
add r1 r2
localget r2 3005
mul r2 10486
add r1 r2
div r1 16384
cmp r1 0
jge highlight_positive_472
set r1 0
label highlight_positive_472
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
jle intensity_bounded_473
set r0 255
label intensity_bounded_473
localset 2482 r0
label body_lighting_done_469
label lighting_table_ready
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
set r0 1491
mov r9 r0
localset 132 r9
set r0 1508
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
meshface 2987 2988 2989 226 r9 r10 r11 60
meshface 2987 2989 2990 226 r9 r10 r11 60
meshface 2991 2992 2993 226 r9 r10 r11 60
meshface 2991 2994 2992 226 r9 r10 r11 60
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
localget r12 126
meshfacegradient 2285 2286 2287 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2285 2287 2288 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2288 2287 2289 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2288 2289 2290 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2290 2289 2291 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2290 2291 2292 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2292 2291 2293 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2292 2293 2294 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2286 2295 2296 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2286 2296 2287 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2287 2296 2297 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2287 2297 2289 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2289 2297 2298 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2289 2298 2291 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2291 2298 2299 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2291 2299 2293 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2295 2300 2301 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2295 2301 2296 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2296 2301 2302 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2296 2302 2297 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2297 2302 2303 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2297 2303 2298 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2298 2303 2304 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2298 2304 2299 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2305 2306 2307 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2305 2307 2308 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2308 2307 2309 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2308 2309 2310 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2310 2309 2311 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2310 2311 2312 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2312 2311 2313 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2312 2313 2314 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2315 2316 2317 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2315 2318 2316 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2315 2319 2318 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2320 2321 2322 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2323 2324 2325 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2326 2327 2328 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2326 2328 2329 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2326 2329 2330 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2331 2332 2333 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2334 2335 2336 r12 24 r9 r10 r11 60
set r12 208
meshfacegradient 2337 2338 2339 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2337 2340 2338 r12 4 r9 r10 r11 60
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
meshfacegradient 2366 2367 2364 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2366 2368 2367 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2368 2369 2367 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2368 2370 2369 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2370 2371 2372 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2370 2373 2371 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2373 2374 2375 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2373 2376 2374 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2376 2339 2374 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2376 2337 2339 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2377 2378 2379 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2377 2380 2378 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2380 2381 2378 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2382 2383 2381 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2384 2385 2381 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2386 2387 2385 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2387 2388 2385 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2387 2389 2388 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2389 2390 2388 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2389 2391 2390 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2391 2392 2390 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2393 2394 2392 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2395 2396 2392 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2397 2398 2396 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2398 2399 2396 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2398 2400 2399 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2400 2401 2399 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2400 2402 2401 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2402 2403 2401 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2404 2405 2403 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2406 2407 2403 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2408 2409 2407 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2409 2410 2407 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2409 2411 2410 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2411 2412 2410 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2411 2413 2412 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2413 2414 2412 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2415 2416 2414 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2417 2418 2414 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2419 2420 2418 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2420 2379 2418 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2420 2377 2379 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 2421 2422 2423 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2421 2423 2424 r12 12 r9 r10 r11 60
meshface 2425 2426 2427 226 r9 r10 r11 60
set r12 212
meshfacegradient 2422 2428 2429 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2422 2429 2423 r12 12 r9 r10 r11 60
meshface 2425 2427 2430 226 r9 r10 r11 60
set r12 212
meshfacegradient 2428 2431 2432 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2428 2432 2429 r12 12 r9 r10 r11 60
meshface 2425 2430 2433 226 r9 r10 r11 60
set r12 212
meshfacegradient 2431 2434 2435 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2431 2435 2432 r12 12 r9 r10 r11 60
meshface 2425 2433 2436 226 r9 r10 r11 60
set r12 212
meshfacegradient 2434 2437 2438 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2434 2438 2435 r12 12 r9 r10 r11 60
meshface 2425 2436 2439 226 r9 r10 r11 60
set r12 212
meshfacegradient 2437 2440 2441 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2437 2441 2438 r12 12 r9 r10 r11 60
meshface 2425 2439 2442 226 r9 r10 r11 60
set r12 212
meshfacegradient 2440 2443 2444 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2440 2444 2441 r12 12 r9 r10 r11 60
meshface 2425 2442 2445 226 r9 r10 r11 60
set r12 212
meshfacegradient 2443 2421 2424 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2443 2424 2444 r12 12 r9 r10 r11 60
meshface 2425 2445 2426 226 r9 r10 r11 60
set r12 212
meshfacegradient 2446 2447 2448 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2446 2448 2449 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2450 2451 2452 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2450 2452 2453 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2454 2455 2456 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2454 2456 2457 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2458 2459 2460 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2458 2460 2461 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2462 2463 2464 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2462 2464 2465 r12 12 r9 r10 r11 60
set r12 208
meshfacegradient 2466 2467 2468 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2466 2468 2469 r12 4 r9 r10 r11 60
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
meshfacegradient 2495 2494 2496 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2495 2496 2497 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2497 2496 2498 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2497 2498 2499 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2499 2500 2501 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2499 2501 2502 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2502 2503 2504 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2502 2504 2505 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2505 2504 2467 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2505 2467 2466 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2506 2507 2508 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2506 2508 2509 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2509 2508 2510 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2511 2510 2512 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2513 2510 2514 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2515 2514 2516 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2516 2514 2517 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2516 2517 2518 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2518 2517 2519 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2518 2519 2520 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2520 2519 2521 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2522 2521 2523 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2524 2521 2525 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2526 2525 2527 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2527 2525 2528 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2527 2528 2529 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2529 2528 2530 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2529 2530 2531 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2531 2530 2532 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2533 2532 2534 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2535 2532 2536 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2537 2536 2538 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2538 2536 2539 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2538 2539 2540 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2540 2539 2541 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2540 2541 2542 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2542 2541 2543 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2544 2543 2545 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2546 2543 2547 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2548 2547 2549 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2549 2547 2507 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2549 2507 2506 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 2550 2551 2552 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2550 2553 2551 r12 12 r9 r10 r11 60
meshface 2554 2555 2556 226 r9 r10 r11 60
set r12 212
meshfacegradient 2552 2557 2558 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2552 2551 2557 r12 12 r9 r10 r11 60
meshface 2554 2559 2555 226 r9 r10 r11 60
set r12 212
meshfacegradient 2558 2560 2561 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2558 2557 2560 r12 12 r9 r10 r11 60
meshface 2554 2562 2559 226 r9 r10 r11 60
set r12 212
meshfacegradient 2561 2563 2564 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2561 2560 2563 r12 12 r9 r10 r11 60
meshface 2554 2565 2562 226 r9 r10 r11 60
set r12 212
meshfacegradient 2564 2566 2567 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2564 2563 2566 r12 12 r9 r10 r11 60
meshface 2554 2568 2565 226 r9 r10 r11 60
set r12 212
meshfacegradient 2567 2569 2570 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2567 2566 2569 r12 12 r9 r10 r11 60
meshface 2554 2571 2568 226 r9 r10 r11 60
set r12 212
meshfacegradient 2570 2572 2573 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2570 2569 2572 r12 12 r9 r10 r11 60
meshface 2554 2574 2571 226 r9 r10 r11 60
set r12 212
meshfacegradient 2573 2553 2550 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2573 2572 2553 r12 12 r9 r10 r11 60
meshface 2554 2556 2574 226 r9 r10 r11 60
set r12 212
meshfacegradient 2575 2576 2577 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2575 2578 2576 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2579 2580 2581 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2579 2582 2580 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2583 2584 2585 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2583 2586 2584 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2587 2588 2589 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2587 2590 2588 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2591 2592 2593 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2591 2594 2592 r12 12 r9 r10 r11 60
set r12 208
meshfacegradient 2595 2596 2597 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2595 2598 2596 r12 4 r9 r10 r11 60
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
meshfacegradient 2624 2625 2622 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2624 2626 2625 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2626 2627 2625 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2626 2628 2627 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2628 2629 2630 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2628 2631 2629 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2631 2632 2633 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2631 2634 2632 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2634 2597 2632 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2634 2595 2597 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2635 2636 2637 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2635 2638 2636 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2638 2639 2636 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2640 2641 2639 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2642 2643 2639 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2644 2645 2643 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2645 2646 2643 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2645 2647 2646 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2647 2648 2646 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2647 2649 2648 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2649 2650 2648 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2651 2652 2650 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2653 2654 2650 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2655 2656 2654 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2656 2657 2654 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2656 2658 2657 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2658 2659 2657 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2658 2660 2659 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2660 2661 2659 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2662 2663 2661 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2664 2665 2661 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2666 2667 2665 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2667 2668 2665 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2667 2669 2668 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2669 2670 2668 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2669 2671 2670 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2671 2672 2670 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2673 2674 2672 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2675 2676 2672 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2677 2678 2676 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2678 2637 2676 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2678 2635 2637 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 2679 2680 2681 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2679 2681 2682 r12 12 r9 r10 r11 60
meshface 2683 2684 2685 226 r9 r10 r11 60
set r12 212
meshfacegradient 2680 2686 2687 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2680 2687 2681 r12 12 r9 r10 r11 60
meshface 2683 2685 2688 226 r9 r10 r11 60
set r12 212
meshfacegradient 2686 2689 2690 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2686 2690 2687 r12 12 r9 r10 r11 60
meshface 2683 2688 2691 226 r9 r10 r11 60
set r12 212
meshfacegradient 2689 2692 2693 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2689 2693 2690 r12 12 r9 r10 r11 60
meshface 2683 2691 2694 226 r9 r10 r11 60
set r12 212
meshfacegradient 2692 2695 2696 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2692 2696 2693 r12 12 r9 r10 r11 60
meshface 2683 2694 2697 226 r9 r10 r11 60
set r12 212
meshfacegradient 2695 2698 2699 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2695 2699 2696 r12 12 r9 r10 r11 60
meshface 2683 2697 2700 226 r9 r10 r11 60
set r12 212
meshfacegradient 2698 2701 2702 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2698 2702 2699 r12 12 r9 r10 r11 60
meshface 2683 2700 2703 226 r9 r10 r11 60
set r12 212
meshfacegradient 2701 2679 2682 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2701 2682 2702 r12 12 r9 r10 r11 60
meshface 2683 2703 2684 226 r9 r10 r11 60
set r12 212
meshfacegradient 2704 2705 2706 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2704 2706 2707 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2708 2709 2710 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2708 2710 2711 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2712 2713 2714 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2712 2714 2715 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2716 2717 2718 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2716 2718 2719 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2720 2721 2722 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2720 2722 2723 r12 12 r9 r10 r11 60
set r12 208
meshfacegradient 2724 2725 2726 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2724 2726 2727 r12 4 r9 r10 r11 60
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
meshfacegradient 2753 2752 2754 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2753 2754 2755 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2755 2754 2756 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2755 2756 2757 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2757 2758 2759 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2757 2759 2760 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2760 2761 2762 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2760 2762 2763 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2763 2762 2725 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2763 2725 2724 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2764 2765 2766 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2764 2766 2767 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2767 2766 2768 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2769 2768 2770 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2771 2768 2772 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2773 2772 2774 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2774 2772 2775 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2774 2775 2776 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2776 2775 2777 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2776 2777 2778 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2778 2777 2779 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2780 2779 2781 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2782 2779 2783 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2784 2783 2785 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2785 2783 2786 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2785 2786 2787 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2787 2786 2788 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2787 2788 2789 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2789 2788 2790 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2791 2790 2792 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2793 2790 2794 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2795 2794 2796 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2796 2794 2797 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2796 2797 2798 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2798 2797 2799 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2798 2799 2800 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2800 2799 2801 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2802 2801 2803 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2804 2801 2805 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2806 2805 2807 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2807 2805 2765 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 2807 2765 2764 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 2808 2809 2810 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2808 2811 2809 r12 12 r9 r10 r11 60
meshface 2812 2813 2814 226 r9 r10 r11 60
set r12 212
meshfacegradient 2810 2815 2816 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2810 2809 2815 r12 12 r9 r10 r11 60
meshface 2812 2817 2813 226 r9 r10 r11 60
set r12 212
meshfacegradient 2816 2818 2819 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2816 2815 2818 r12 12 r9 r10 r11 60
meshface 2812 2820 2817 226 r9 r10 r11 60
set r12 212
meshfacegradient 2819 2821 2822 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2819 2818 2821 r12 12 r9 r10 r11 60
meshface 2812 2823 2820 226 r9 r10 r11 60
set r12 212
meshfacegradient 2822 2824 2825 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2822 2821 2824 r12 12 r9 r10 r11 60
meshface 2812 2826 2823 226 r9 r10 r11 60
set r12 212
meshfacegradient 2825 2827 2828 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2825 2824 2827 r12 12 r9 r10 r11 60
meshface 2812 2829 2826 226 r9 r10 r11 60
set r12 212
meshfacegradient 2828 2830 2831 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2828 2827 2830 r12 12 r9 r10 r11 60
meshface 2812 2832 2829 226 r9 r10 r11 60
set r12 212
meshfacegradient 2831 2811 2808 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2831 2830 2811 r12 12 r9 r10 r11 60
meshface 2812 2814 2832 226 r9 r10 r11 60
set r12 212
meshfacegradient 2833 2834 2835 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2833 2836 2834 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2837 2838 2839 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2837 2840 2838 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2841 2842 2843 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2841 2844 2842 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2845 2846 2847 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2845 2848 2846 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2849 2850 2851 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2849 2852 2850 r12 12 r9 r10 r11 60
meshface 2853 2854 2855 225 r9 r10 r11 60
meshface 2853 2856 2854 225 r9 r10 r11 60
meshface 2857 2858 2859 224 r9 r10 r11 60
meshface 2857 2859 2860 224 r9 r10 r11 60
meshface 2861 2862 2863 226 r9 r10 r11 60
meshface 2861 2864 2862 226 r9 r10 r11 60
meshface 2865 2866 2867 226 r9 r10 r11 60
meshface 2868 2869 2870 226 r9 r10 r11 60
set r12 184
meshfacegradient 2871 2872 2873 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2874 2875 2876 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2877 2878 2879 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2880 2881 2882 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2883 2884 2885 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2886 2887 2888 r12 24 r9 r10 r11 60
meshface 2889 2890 2891 225 r9 r10 r11 60
meshface 2889 2891 2892 225 r9 r10 r11 60
meshface 2893 2894 2895 224 r9 r10 r11 60
meshface 2893 2896 2894 224 r9 r10 r11 60
meshface 2897 2898 2899 226 r9 r10 r11 60
meshface 2897 2899 2900 226 r9 r10 r11 60
meshface 2901 2902 2903 226 r9 r10 r11 60
meshface 2904 2905 2906 226 r9 r10 r11 60
set r12 184
meshfacegradient 2907 2908 2909 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 2910 2911 2912 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2913 2914 2915 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2916 2917 2918 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2919 2920 2921 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2922 2923 2924 r12 24 r9 r10 r11 60
meshface 2925 2926 2927 226 r9 r10 r11 60
meshface 2925 2927 2928 226 r9 r10 r11 60
meshface 2929 2930 2931 226 r9 r10 r11 60
meshface 2929 2932 2930 226 r9 r10 r11 60
meshface 2933 2934 2935 227 r9 r10 r11 60
meshface 2933 2936 2934 227 r9 r10 r11 60
meshface 2937 2938 2939 227 r9 r10 r11 60
meshface 2937 2940 2938 227 r9 r10 r11 60
meshface 2941 2942 2943 227 r9 r10 r11 60
meshface 2941 2944 2942 227 r9 r10 r11 60
meshface 2945 2946 2947 227 r9 r10 r11 60
meshface 2945 2948 2946 227 r9 r10 r11 60
set r12 212
meshfacegradient 2949 2950 2951 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2949 2952 2950 r12 12 r9 r10 r11 60
meshface 2953 2954 2955 226 r9 r10 r11 60
set r12 212
meshfacegradient 2951 2956 2957 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2951 2950 2956 r12 12 r9 r10 r11 60
meshface 2953 2958 2954 226 r9 r10 r11 60
set r12 212
meshfacegradient 2957 2959 2960 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2957 2956 2959 r12 12 r9 r10 r11 60
meshface 2953 2961 2958 226 r9 r10 r11 60
set r12 212
meshfacegradient 2960 2962 2963 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2960 2959 2962 r12 12 r9 r10 r11 60
meshface 2953 2964 2961 226 r9 r10 r11 60
set r12 212
meshfacegradient 2963 2965 2966 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2963 2962 2965 r12 12 r9 r10 r11 60
meshface 2953 2967 2964 226 r9 r10 r11 60
set r12 212
meshfacegradient 2966 2952 2949 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2966 2965 2952 r12 12 r9 r10 r11 60
meshface 2953 2955 2967 226 r9 r10 r11 60
set r12 212
meshfacegradient 2968 2969 2970 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2968 2971 2969 r12 12 r9 r10 r11 60
meshface 2972 2973 2974 226 r9 r10 r11 60
set r12 212
meshfacegradient 2970 2975 2976 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2970 2969 2975 r12 12 r9 r10 r11 60
meshface 2972 2977 2973 226 r9 r10 r11 60
set r12 212
meshfacegradient 2976 2978 2979 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2976 2975 2978 r12 12 r9 r10 r11 60
meshface 2972 2980 2977 226 r9 r10 r11 60
set r12 212
meshfacegradient 2979 2981 2982 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2979 2978 2981 r12 12 r9 r10 r11 60
meshface 2972 2983 2980 226 r9 r10 r11 60
set r12 212
meshfacegradient 2982 2984 2985 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2982 2981 2984 r12 12 r9 r10 r11 60
meshface 2972 2986 2983 226 r9 r10 r11 60
set r12 212
meshfacegradient 2985 2971 2968 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 2985 2984 2971 r12 12 r9 r10 r11 60
meshface 2972 2974 2986 226 r9 r10 r11 60
meshface 2987 2988 2989 226 r9 r10 r11 60
meshface 2987 2989 2990 226 r9 r10 r11 60
meshface 2991 2992 2993 226 r9 r10 r11 60
meshface 2991 2994 2992 226 r9 r10 r11 60
jmp emit_shadow
label emit_medium
localget r12 126
meshfacegradient 2995 2996 2997 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2995 2997 2998 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2998 2997 2999 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2998 2999 3000 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3001 3002 3003 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3001 3004 3002 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3005 3006 3007 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3005 3007 3008 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2996 3009 3010 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2996 3010 2997 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2997 3010 3011 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 2997 3011 2999 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3003 3012 3013 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3003 3002 3012 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3006 3014 3015 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3006 3015 3007 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3009 3016 3017 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3009 3017 3010 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3010 3017 3018 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3010 3018 3011 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3013 3019 3020 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3013 3012 3019 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3014 3021 3022 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3014 3022 3015 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3016 3023 3024 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3016 3024 3017 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3017 3024 3025 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3017 3025 3018 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3020 3026 3027 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3020 3019 3026 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3021 3028 3029 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3021 3029 3022 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3023 3030 3031 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3023 3031 3024 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3024 3031 3032 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3024 3032 3025 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3027 3033 3034 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3027 3026 3033 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3028 3035 3036 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3028 3036 3029 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3030 3037 3038 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3030 3038 3031 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3031 3038 3039 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3031 3039 3032 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3034 3040 3041 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3034 3033 3040 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3035 3042 3043 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3035 3043 3036 r12 24 r9 r10 r11 60
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
meshfacegradient 3079 3080 3081 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3079 3081 3082 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3079 3082 3083 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3079 3083 3084 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3079 3084 3080 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3085 3086 3075 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3085 3073 3086 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3085 3087 3073 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3085 3078 3087 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3085 3075 3078 r12 24 r9 r10 r11 60
meshface 3088 3089 3090 227 r9 r10 r11 60
meshface 3088 3091 3089 227 r9 r10 r11 60
set r12 184
meshfacegradient 3092 3093 3094 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3092 3094 3095 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3095 3094 3096 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3095 3096 3097 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3098 3099 3100 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3098 3100 3101 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3101 3100 3102 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3101 3102 3103 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3099 3104 3105 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3099 3105 3100 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3100 3105 3106 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3100 3106 3102 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3107 3108 3109 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3107 3109 3110 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3110 3109 3111 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3110 3111 3112 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3113 3114 3115 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3113 3116 3114 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3113 3117 3116 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3118 3119 3120 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3121 3122 3123 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3124 3125 3126 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3124 3126 3127 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3124 3127 3128 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3129 3130 3131 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3132 3133 3134 r12 24 r9 r10 r11 60
set r12 208
meshfacegradient 3135 3136 3137 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3135 3138 3136 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3138 3139 3136 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3138 3140 3139 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3140 3141 3139 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3140 3142 3141 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3142 3143 3141 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3142 3144 3143 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3144 3145 3143 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3144 3146 3145 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3146 3147 3145 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3146 3148 3147 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3148 3149 3147 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3148 3150 3149 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3150 3137 3149 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3150 3135 3137 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3151 3152 3153 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3151 3154 3152 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3154 3155 3152 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3154 3156 3155 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3156 3157 3155 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3156 3158 3157 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3158 3159 3157 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3158 3160 3159 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3160 3161 3159 r12 4 r9 r10 r11 60
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
meshfacegradient 3166 3153 3165 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3166 3151 3153 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 3167 3168 3169 r12 12 r9 r10 r11 60
meshface 3170 3171 3172 226 r9 r10 r11 60
set r12 212
meshfacegradient 3167 3173 3174 r12 12 r9 r10 r11 60
meshface 3170 3175 3176 226 r9 r10 r11 60
set r12 212
meshfacegradient 3167 3177 3178 r12 12 r9 r10 r11 60
meshface 3170 3179 3180 226 r9 r10 r11 60
set r12 212
meshfacegradient 3167 3181 3182 r12 12 r9 r10 r11 60
meshface 3170 3183 3184 226 r9 r10 r11 60
set r12 208
meshfacegradient 3185 3186 3187 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3185 3187 3188 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3188 3187 3189 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3188 3189 3190 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3190 3189 3191 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3190 3191 3192 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3192 3191 3193 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3192 3193 3194 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3194 3193 3195 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3194 3195 3196 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3196 3195 3197 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3196 3197 3198 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3198 3197 3199 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3198 3199 3200 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3200 3199 3186 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3200 3186 3185 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3201 3202 3203 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3201 3203 3204 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3204 3203 3205 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3204 3205 3206 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3206 3205 3207 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3206 3207 3208 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3208 3207 3209 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3208 3209 3210 r12 4 r9 r10 r11 60
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
meshfacegradient 3216 3215 3202 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3216 3202 3201 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 3217 3218 3219 r12 12 r9 r10 r11 60
meshface 3220 3221 3222 226 r9 r10 r11 60
set r12 212
meshfacegradient 3217 3223 3224 r12 12 r9 r10 r11 60
meshface 3220 3225 3226 226 r9 r10 r11 60
set r12 212
meshfacegradient 3217 3227 3228 r12 12 r9 r10 r11 60
meshface 3220 3229 3230 226 r9 r10 r11 60
set r12 212
meshfacegradient 3217 3231 3232 r12 12 r9 r10 r11 60
meshface 3220 3233 3234 226 r9 r10 r11 60
set r12 208
meshfacegradient 3235 3236 3237 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3235 3238 3236 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3238 3239 3236 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3238 3240 3239 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3240 3241 3239 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3240 3242 3241 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3242 3243 3241 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3242 3244 3243 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3244 3245 3243 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3244 3246 3245 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3246 3247 3245 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3246 3248 3247 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3248 3249 3247 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3248 3250 3249 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3250 3237 3249 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3250 3235 3237 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3251 3252 3253 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3251 3254 3252 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3254 3255 3252 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3254 3256 3255 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3256 3257 3255 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3256 3258 3257 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3258 3259 3257 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3258 3260 3259 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3260 3261 3259 r12 4 r9 r10 r11 60
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
meshfacegradient 3266 3253 3265 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3266 3251 3253 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 3267 3268 3269 r12 12 r9 r10 r11 60
meshface 3270 3271 3272 226 r9 r10 r11 60
set r12 212
meshfacegradient 3267 3273 3274 r12 12 r9 r10 r11 60
meshface 3270 3275 3276 226 r9 r10 r11 60
set r12 212
meshfacegradient 3267 3277 3278 r12 12 r9 r10 r11 60
meshface 3270 3279 3280 226 r9 r10 r11 60
set r12 212
meshfacegradient 3267 3281 3282 r12 12 r9 r10 r11 60
meshface 3270 3283 3284 226 r9 r10 r11 60
set r12 208
meshfacegradient 3285 3286 3287 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3285 3287 3288 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3288 3287 3289 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3288 3289 3290 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3290 3289 3291 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3290 3291 3292 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3292 3291 3293 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3292 3293 3294 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3294 3293 3295 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3294 3295 3296 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3296 3295 3297 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3296 3297 3298 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3298 3297 3299 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3298 3299 3300 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3300 3299 3286 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3300 3286 3285 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3301 3302 3303 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3301 3303 3304 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3304 3303 3305 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3304 3305 3306 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3306 3305 3307 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3306 3307 3308 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3308 3307 3309 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3308 3309 3310 r12 4 r9 r10 r11 60
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
meshfacegradient 3316 3315 3302 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3316 3302 3301 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 3317 3318 3319 r12 12 r9 r10 r11 60
meshface 3320 3321 3322 226 r9 r10 r11 60
set r12 212
meshfacegradient 3317 3323 3324 r12 12 r9 r10 r11 60
meshface 3320 3325 3326 226 r9 r10 r11 60
set r12 212
meshfacegradient 3317 3327 3328 r12 12 r9 r10 r11 60
meshface 3320 3329 3330 226 r9 r10 r11 60
set r12 212
meshfacegradient 3317 3331 3332 r12 12 r9 r10 r11 60
meshface 3320 3333 3334 226 r9 r10 r11 60
meshface 3335 3336 3337 225 r9 r10 r11 60
meshface 3335 3338 3336 225 r9 r10 r11 60
meshface 3339 3340 3341 224 r9 r10 r11 60
meshface 3339 3341 3342 224 r9 r10 r11 60
meshface 3343 3344 3345 226 r9 r10 r11 60
meshface 3346 3347 3348 225 r9 r10 r11 60
meshface 3346 3348 3349 225 r9 r10 r11 60
meshface 3350 3351 3352 224 r9 r10 r11 60
meshface 3350 3353 3351 224 r9 r10 r11 60
meshface 3354 3355 3356 226 r9 r10 r11 60
meshface 3357 3358 3359 226 r9 r10 r11 60
meshface 3357 3359 3360 226 r9 r10 r11 60
meshface 3361 3362 3363 226 r9 r10 r11 60
meshface 3361 3364 3362 226 r9 r10 r11 60
jmp emit_shadow
label emit_far
localget r12 126
meshfacegradient 3365 3366 3367 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3365 3367 3368 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3368 3367 3369 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3368 3369 3370 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3371 3372 3373 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3371 3374 3372 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3375 3376 3377 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3375 3377 3378 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3366 3379 3380 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3366 3380 3367 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3367 3380 3381 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3367 3381 3369 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3373 3382 3383 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3373 3372 3382 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3376 3384 3385 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3376 3385 3377 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3379 3386 3387 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3379 3387 3380 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3380 3387 3388 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3380 3388 3381 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3383 3389 3390 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3383 3382 3389 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3384 3391 3392 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3384 3392 3385 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3386 3393 3394 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3386 3394 3387 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3387 3394 3395 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3387 3395 3388 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3390 3396 3397 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3390 3389 3396 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3391 3398 3399 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3391 3399 3392 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3393 3400 3401 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3393 3401 3394 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3394 3401 3402 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3394 3402 3395 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3397 3403 3404 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3397 3396 3403 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3398 3405 3406 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3398 3406 3399 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3407 3408 3409 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3407 3409 3410 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3403 3411 3412 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3403 3406 3411 r12 24 r9 r10 r11 60
meshface 3413 3414 3415 227 r9 r10 r11 60
meshface 3413 3416 3414 227 r9 r10 r11 60
set r12 184
meshfacegradient 3417 3418 3419 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3417 3419 3420 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3420 3419 3421 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3420 3421 3422 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3423 3424 3425 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3423 3425 3426 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3426 3425 3427 r12 24 r9 r10 r11 60
localget r12 126
meshfacegradient 3426 3427 3428 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3429 3430 3431 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3429 3431 3432 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3432 3431 3433 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3432 3433 3434 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3435 3436 3437 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3435 3438 3436 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3439 3440 3441 r12 24 r9 r10 r11 60
set r12 184
meshfacegradient 3439 3441 3442 r12 24 r9 r10 r11 60
set r12 208
meshfacegradient 3443 3444 3445 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3443 3446 3444 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3447 3448 3449 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3447 3450 3448 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3451 3452 3453 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3451 3454 3452 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3455 3456 3457 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3455 3458 3456 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 3459 3460 3461 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 3459 3461 3462 r12 12 r9 r10 r11 60
set r12 208
meshfacegradient 3463 3464 3465 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3463 3465 3466 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3467 3468 3469 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3467 3469 3470 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3471 3472 3473 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3471 3473 3474 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3475 3476 3477 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3475 3477 3478 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 3479 3480 3481 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 3479 3482 3480 r12 12 r9 r10 r11 60
set r12 208
meshfacegradient 3483 3484 3485 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3483 3486 3484 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3487 3488 3489 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3487 3490 3488 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3491 3492 3493 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3491 3494 3492 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3495 3496 3497 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3495 3498 3496 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 3499 3500 3501 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 3499 3501 3502 r12 12 r9 r10 r11 60
set r12 208
meshfacegradient 3503 3504 3505 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3503 3505 3506 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3507 3508 3509 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3507 3509 3510 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3511 3512 3513 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3511 3513 3514 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3515 3516 3517 r12 4 r9 r10 r11 60
set r12 208
meshfacegradient 3515 3517 3518 r12 4 r9 r10 r11 60
set r12 212
meshfacegradient 3519 3520 3521 r12 12 r9 r10 r11 60
set r12 212
meshfacegradient 3519 3522 3520 r12 12 r9 r10 r11 60
meshface 3523 3524 3525 225 r9 r10 r11 60
meshface 3523 3526 3524 225 r9 r10 r11 60
meshface 3527 3528 3529 224 r9 r10 r11 60
meshface 3527 3529 3530 224 r9 r10 r11 60
meshface 3531 3532 3533 225 r9 r10 r11 60
meshface 3531 3533 3534 225 r9 r10 r11 60
meshface 3535 3536 3537 224 r9 r10 r11 60
meshface 3535 3538 3536 224 r9 r10 r11 60
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
meshfacegradient 3539 3540 3541 r12 8 r9 r10 r11 60
meshfacegradient 3540 3548 3549 r12 8 r9 r10 r11 60
meshfacegradient 3540 3549 3541 r12 8 r9 r10 r11 60
meshfacegradient 3539 3541 3542 r12 8 r9 r10 r11 60
meshfacegradient 3541 3549 3550 r12 8 r9 r10 r11 60
meshfacegradient 3541 3550 3542 r12 8 r9 r10 r11 60
meshfacegradient 3539 3542 3543 r12 8 r9 r10 r11 60
meshfacegradient 3542 3550 3551 r12 8 r9 r10 r11 60
meshfacegradient 3542 3551 3543 r12 8 r9 r10 r11 60
meshfacegradient 3539 3543 3544 r12 8 r9 r10 r11 60
meshfacegradient 3543 3551 3552 r12 8 r9 r10 r11 60
meshfacegradient 3543 3552 3544 r12 8 r9 r10 r11 60
meshfacegradient 3539 3544 3545 r12 8 r9 r10 r11 60
meshfacegradient 3544 3552 3553 r12 8 r9 r10 r11 60
meshfacegradient 3544 3553 3545 r12 8 r9 r10 r11 60
meshfacegradient 3539 3545 3546 r12 8 r9 r10 r11 60
meshfacegradient 3545 3553 3554 r12 8 r9 r10 r11 60
meshfacegradient 3545 3554 3546 r12 8 r9 r10 r11 60
meshfacegradient 3539 3546 3547 r12 8 r9 r10 r11 60
meshfacegradient 3546 3554 3555 r12 8 r9 r10 r11 60
meshfacegradient 3546 3555 3547 r12 8 r9 r10 r11 60
meshfacegradient 3539 3547 3540 r12 8 r9 r10 r11 60
meshfacegradient 3547 3555 3548 r12 8 r9 r10 r11 60
meshfacegradient 3547 3548 3540 r12 8 r9 r10 r11 60
jmp next_actor
label emit_tree
meshface 3556 3557 3558 14 r9 r10 r11 60
meshface 3556 3558 3559 15 r9 r10 r11 60
meshface 3556 3559 3560 16 r9 r10 r11 60
meshface 3556 3560 3561 14 r9 r10 r11 60
meshface 3556 3561 3562 15 r9 r10 r11 60
meshface 3556 3562 3557 16 r9 r10 r11 60
meshface 3563 3564 3565 9 r9 r10 r11 60
meshface 3563 3565 3566 10 r9 r10 r11 60
meshface 3567 3568 3569 9 r9 r10 r11 60
meshface 3567 3569 3570 10 r9 r10 r11 60
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
