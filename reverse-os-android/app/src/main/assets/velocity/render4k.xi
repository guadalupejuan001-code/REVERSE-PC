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
set r0 3840
set r1 2160
mov r9 r0
localset 18 r9
mov r9 r1
localset 20 r9
meshbegin r0 r1 4 0
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
meshtexrow 0 0 d7887a8888878887
meshtexrow 0 1 88888d78887a8a88
meshtexrow 0 2 8888777788a8a78a
meshtexrow 0 3 87887a878887d888
meshtexrow 0 4 d8888888a8778888
meshtexrow 0 5 78a87a888a7da888
meshtexrow 0 6 877888a788a78a87
meshtexrow 0 7 7888888888878888
meshtexrow 0 8 8aa88787887a887a
meshtexrow 0 9 8888a88878887a88
meshtexrow 0 10 a8a8888aa88da888
meshtexrow 0 11 8d8888a8787ad888
meshtexrow 0 12 888888a87887888a
meshtexrow 0 13 8888888888887878
meshtexrow 0 14 787788a88888a888
meshtexrow 0 15 888a88a8878d8888
meshtexrow 1 0 bb55bb55bb55bb55
meshtexrow 1 1 b77bb77bb77bb77b
meshtexrow 1 2 55bb55bb55bb55bb
meshtexrow 1 3 7bb77bb77bb77bb7
meshtexrow 1 4 bb55bb55bb55bb55
meshtexrow 1 5 b77bb77bb77bb77b
meshtexrow 1 6 55bb55bb55bb55bb
meshtexrow 1 7 7bb77bb77bb77bb7
meshtexrow 1 8 bb55bb55bb55bb55
meshtexrow 1 9 b77bb77bb77bb77b
meshtexrow 1 10 55bb55bb55bb55bb
meshtexrow 1 11 7bb77bb77bb77bb7
meshtexrow 1 12 bb55bb55bb55bb55
meshtexrow 1 13 b77bb77bb77bb77b
meshtexrow 1 14 55bb55bb55bb55bb
meshtexrow 1 15 7bb77bb77bb77bb7
meshtexrow 2 0 cca8888888888888
meshtexrow 2 1 88888a88888888cc
meshtexrow 2 2 88aa8888888cc88a
meshtexrow 2 3 8888a888cca88888
meshtexrow 2 4 88888cc8a8888888
meshtexrow 2 5 88cc888888888a8a
meshtexrow 2 6 c888888888888888
meshtexrow 2 7 88888a8a88888cc8
meshtexrow 2 8 88888888a8cc8888
meshtexrow 2 9 8888888cc8888888
meshtexrow 2 10 8888cc888888888a
meshtexrow 2 11 8ccaa888a8a88888
meshtexrow 2 12 a88888888888888c
meshtexrow 2 13 888888888888cc88
meshtexrow 2 14 88888a888cc8a888
meshtexrow 2 15 888888cc8888a888
meshtexrow 3 0 449c9c9994499999
meshtexrow 3 1 999999944c999999
meshtexrow 3 2 9999944999999944
meshtexrow 3 3 999449999c99449c
meshtexrow 3 4 944c9c999944c99c
meshtexrow 3 5 4999999944999cc9
meshtexrow 3 6 99999944999c9994
meshtexrow 3 7 999944999c9c9449
meshtexrow 3 8 994499c999c44c99
meshtexrow 3 9 44c9cc99944c9c99
meshtexrow 3 10 9999c9944c999c99
meshtexrow 3 11 9cc9944999999944
meshtexrow 3 12 99944999999944c9
meshtexrow 3 13 9449cc9999449999
meshtexrow 3 14 49999999449c9999
meshtexrow 3 15 9999994499999c94
meshtexrow 4 0 cccccccccccccccc
meshtexrow 4 1 a777777a777777a7
meshtexrow 4 2 a777777a777777a7
meshtexrow 4 3 a777777a777777a7
meshtexrow 4 4 a777777a777777a7
meshtexrow 4 5 cccccccccccccccc
meshtexrow 4 6 a777777a777777a7
meshtexrow 4 7 a777777a777777a7
meshtexrow 4 8 a777777a777777a7
meshtexrow 4 9 a777777a777777a7
meshtexrow 4 10 cccccccccccccccc
meshtexrow 4 11 a777777a777777a7
meshtexrow 4 12 a777777a777777a7
meshtexrow 4 13 a777777a777777a7
meshtexrow 4 14 a777777a777777a7
meshtexrow 4 15 cccccccccccccccc
meshtexrow 5 0 74f48a8a4d7c94df
meshtexrow 5 1 6656fecc57ec4a9e
meshtexrow 5 2 d9c97687adaede9a
meshtexrow 5 3 f8ddad7f74fdd757
meshtexrow 5 4 de8b7d59bc55df68
meshtexrow 5 5 fcddede7cbdb6daf
meshtexrow 5 6 db99ced7ee6794e6
meshtexrow 5 7 ab6dfa685e95465f
meshtexrow 5 8 7d7baa85baa454c6
meshtexrow 5 9 ecb665efdbcf5acc
meshtexrow 5 10 a4d7dff859fcb7e8
meshtexrow 5 11 fdb4ad5566de9a5e
meshtexrow 5 12 77b8bbfc7cf8fae8
meshtexrow 5 13 9588f8a4dc85fb66
meshtexrow 5 14 6deeb8e9dc8c64b9
meshtexrow 5 15 85decccf76bebe5c
meshtexrow 6 0 aaaaaaaaaaaaaaaa
meshtexrow 6 1 aaaa4aaaaaaaaaaa
meshtexrow 6 2 aaaaaaaaaaaaaaaa
meshtexrow 6 3 aaaaaaaa4aaaaaa4
meshtexrow 6 4 aaaaaaaaaaaaaa4a
meshtexrow 6 5 aa4aaaaaaaaaaaaa
meshtexrow 6 6 aaaaaaaaaaaaaaaa
meshtexrow 6 7 44aaaa4aaaaaaaaa
meshtexrow 6 8 aaaaaaaa4aaaaaaa
meshtexrow 6 9 aaaaaaaaaaaaaaaa
meshtexrow 6 10 aaaaaaaaaaaaaaaa
meshtexrow 6 11 a4aaaaaaaaaa44aa
meshtexrow 6 12 aaaaaaaaaaaaaaaa
meshtexrow 6 13 a4aaaaaaaaaaaaaa
meshtexrow 6 14 a4a4aaaaaaa4aaaa
meshtexrow 6 15 aa4aaaaaaaaaaaa4
meshtexrow 7 0 3999399939993999
meshtexrow 7 1 9993999399939993
meshtexrow 7 2 9939993999399939
meshtexrow 7 3 9399939993999399
meshtexrow 7 4 3999399939993999
meshtexrow 7 5 9993999399939993
meshtexrow 7 6 9939993999399939
meshtexrow 7 7 9399939993999399
meshtexrow 7 8 3999399939993999
meshtexrow 7 9 9993999399939993
meshtexrow 7 10 9939993999399939
meshtexrow 7 11 9399939993999399
meshtexrow 7 12 3999399939993999
meshtexrow 7 13 9993999399939993
meshtexrow 7 14 9939993999399939
meshtexrow 7 15 9399939993999399
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
localget r9 28
cmp r9 108
jne road_plain_8
meshvertex 1770 r0 r1 r2
meshvertex 1771 r3 r4 r5
meshvertex 1772 r6 r7 r8
localget r0 8
add r0 0
mul r0 32
localget r1 22
sub r1 32768
div r1 12
meshtexuv 1770 r1 r0
meshshade 1770 128
localget r0 8
add r0 1
mul r0 32
localget r1 22
sub r1 32768
div r1 12
meshtexuv 1771 r1 r0
meshshade 1771 128
localget r0 8
add r0 1
mul r0 32
localget r1 24
sub r1 32768
div r1 12
meshtexuv 1772 r1 r0
meshshade 1772 128
localget r9 18
mov r10 r9
div r10 2
mov r11 r10
mul r11 9
div r11 16
mul r9 85
div r9 100
meshfacegradienttex 1770 1771 1772 40 8 5 12 r9 r10 r11 60
jmp road_done_9
label road_plain_8
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
jne material_skip_13
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 4 r9 r10 r11 60
jmp triangle_emitted_12
label material_skip_13
cmp r9 208
jne material_skip_14
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 5 r9 r10 r11 60
jmp triangle_emitted_12
label material_skip_14
cmp r9 108
jne material_skip_15
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 6 r9 r10 r11 60
jmp triangle_emitted_12
label material_skip_15
cmp r9 206
jne material_skip_16
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 7 r9 r10 r11 60
jmp triangle_emitted_12
label material_skip_16
cmp r9 204
jne material_skip_17
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 8 r9 r10 r11 60
jmp triangle_emitted_12
label material_skip_17
label triangle_emitted_12
label road_done_9
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
localget r9 28
cmp r9 108
jne road_plain_10
meshvertex 1770 r0 r1 r2
meshvertex 1771 r3 r4 r5
meshvertex 1772 r6 r7 r8
localget r0 8
add r0 0
mul r0 32
localget r1 22
sub r1 32768
div r1 12
meshtexuv 1770 r1 r0
meshshade 1770 128
localget r0 8
add r0 1
mul r0 32
localget r1 24
sub r1 32768
div r1 12
meshtexuv 1771 r1 r0
meshshade 1771 128
localget r0 8
add r0 0
mul r0 32
localget r1 24
sub r1 32768
div r1 12
meshtexuv 1772 r1 r0
meshshade 1772 128
localget r9 18
mov r10 r9
div r10 2
mov r11 r10
mul r11 9
div r11 16
mul r9 85
div r9 100
meshfacegradienttex 1770 1771 1772 40 8 5 12 r9 r10 r11 60
jmp road_done_11
label road_plain_10
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
jne material_skip_19
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 4 r9 r10 r11 60
jmp triangle_emitted_18
label material_skip_19
cmp r9 208
jne material_skip_20
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 5 r9 r10 r11 60
jmp triangle_emitted_18
label material_skip_20
cmp r9 108
jne material_skip_21
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 6 r9 r10 r11 60
jmp triangle_emitted_18
label material_skip_21
cmp r9 206
jne material_skip_22
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 7 r9 r10 r11 60
jmp triangle_emitted_18
label material_skip_22
cmp r9 204
jne material_skip_23
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 8 r9 r10 r11 60
jmp triangle_emitted_18
label material_skip_23
label triangle_emitted_18
label road_done_11
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
meshtexuv 0 -14 -37
meshvertex 1 -89 80 -213
meshtexuv 1 -15 -35
meshvertex 2 -73 83 -213
meshtexuv 2 -12 -35
meshvertex 4 -70 74 -223
meshtexuv 4 -12 -37
meshvertex 5 -40 82 -213
meshtexuv 5 -7 -35
meshvertex 7 -38 71 -223
meshtexuv 7 -6 -37
meshvertex 8 0 80 -213
meshtexuv 8 0 -35
meshvertex 9 0 69 -223
meshtexuv 9 0 -37
meshvertex 10 40 82 -213
meshtexuv 10 7 -35
meshvertex 11 38 71 -223
meshtexuv 11 6 -37
meshvertex 12 73 83 -213
meshtexuv 12 12 -35
meshvertex 13 70 74 -223
meshtexuv 13 12 -37
meshvertex 14 89 80 -213
meshtexuv 14 15 -35
meshvertex 15 85 72 -223
meshtexuv 15 14 -37
meshvertex 16 -89 22 -213
meshtexuv 16 -15 -35
meshvertex 18 -85 22 -223
meshtexuv 18 -14 -37
meshvertex 20 89 22 -213
meshtexuv 20 15 -35
meshvertex 21 85 22 -223
meshtexuv 21 14 -37
meshvertex 23 -91 77 -207
meshtexuv 23 -15 -34
meshvertex 24 -75 81 -207
meshtexuv 24 -12 -34
meshvertex 25 -41 78 -207
meshtexuv 25 -7 -34
meshvertex 28 0 76 -207
meshtexuv 28 0 -34
meshvertex 31 41 78 -207
meshtexuv 31 7 -34
meshvertex 33 75 81 -207
meshtexuv 33 13 -34
meshvertex 35 91 77 -207
meshtexuv 35 15 -34
meshvertex 37 -91 22 -207
meshtexuv 37 -15 -34
meshvertex 40 91 22 -207
meshtexuv 40 15 -34
meshvertex 42 -95 79 -181
meshtexuv 42 -16 -30
meshvertex 43 -78 86 -181
meshtexuv 43 -13 -30
meshvertex 44 -43 80 -181
meshtexuv 44 -7 -30
meshvertex 45 0 78 -181
meshtexuv 45 0 -30
meshvertex 46 43 80 -181
meshtexuv 46 7 -30
meshvertex 47 78 86 -181
meshtexuv 47 13 -30
meshvertex 48 95 79 -181
meshtexuv 48 16 -30
meshvertex 51 -95 34 -181
meshtexuv 51 -16 -30
meshvertex 52 95 34 -181
meshtexuv 52 16 -30
meshvertex 53 -95 79 -175
meshtexuv 53 -16 -29
meshvertex 54 -78 87 -175
meshtexuv 54 -13 -29
meshvertex 55 -43 80 -175
meshtexuv 55 -7 -29
meshvertex 56 0 78 -175
meshtexuv 56 0 -29
meshvertex 57 43 80 -175
meshtexuv 57 7 -29
meshvertex 58 78 87 -175
meshtexuv 58 13 -29
meshvertex 59 95 79 -175
meshtexuv 59 16 -29
meshvertex 60 -95 55 -175
meshtexuv 60 -16 -29
meshvertex 62 95 55 -175
meshtexuv 62 16 -29
meshvertex 63 -96 80 -161
meshtexuv 63 -16 -27
meshvertex 64 -79 88 -161
meshtexuv 64 -13 -27
meshvertex 65 -43 80 -161
meshtexuv 65 -7 -27
meshvertex 66 0 78 -161
meshtexuv 66 0 -27
meshvertex 67 43 80 -161
meshtexuv 67 7 -27
meshvertex 68 79 88 -161
meshtexuv 68 13 -27
meshvertex 69 96 80 -161
meshtexuv 69 16 -27
meshvertex 70 -96 68 -161
meshtexuv 70 -16 -27
meshvertex 71 96 68 -161
meshtexuv 71 16 -27
meshvertex 72 -97 80 -142
meshtexuv 72 -16 -24
meshvertex 73 -80 90 -142
meshtexuv 73 -13 -24
meshvertex 74 -44 80 -142
meshtexuv 74 -7 -24
meshvertex 75 0 78 -142
meshtexuv 75 0 -24
meshvertex 76 44 80 -142
meshtexuv 76 7 -24
meshvertex 77 80 90 -142
meshtexuv 77 13 -24
meshvertex 78 97 80 -142
meshtexuv 78 16 -24
meshvertex 79 -97 73 -142
meshtexuv 79 -16 -24
meshvertex 80 97 73 -142
meshtexuv 80 16 -24
meshvertex 81 -95 79 -123
meshtexuv 81 -16 -20
meshvertex 82 -78 87 -123
meshtexuv 82 -13 -20
meshvertex 83 -43 80 -123
meshtexuv 83 -7 -20
meshvertex 84 0 78 -123
meshtexuv 84 0 -20
meshvertex 85 43 80 -123
meshtexuv 85 7 -20
meshvertex 86 78 87 -123
meshtexuv 86 13 -20
meshvertex 87 95 79 -123
meshtexuv 87 16 -20
meshvertex 88 -95 68 -123
meshtexuv 88 -16 -20
meshvertex 89 95 68 -123
meshtexuv 89 16 -20
meshvertex 90 -93 77 -109
meshtexuv 90 -15 -18
meshvertex 91 -76 85 -109
meshtexuv 91 -13 -18
meshvertex 92 -42 79 -109
meshtexuv 92 -7 -18
meshvertex 93 0 77 -109
meshtexuv 93 0 -18
meshvertex 94 42 79 -109
meshtexuv 94 7 -18
meshvertex 95 76 85 -109
meshtexuv 95 13 -18
meshvertex 96 93 77 -109
meshtexuv 96 16 -18
meshvertex 97 -93 55 -109
meshtexuv 97 -15 -18
meshvertex 98 93 55 -109
meshtexuv 98 16 -18
meshvertex 99 -92 77 -103
meshtexuv 99 -15 -17
meshvertex 100 -75 84 -103
meshtexuv 100 -12 -17
meshvertex 101 -41 79 -103
meshtexuv 101 -7 -17
meshvertex 102 0 77 -103
meshtexuv 102 0 -17
meshvertex 103 41 79 -103
meshtexuv 103 7 -17
meshvertex 104 75 84 -103
meshtexuv 104 13 -17
meshvertex 105 92 77 -103
meshtexuv 105 15 -17
meshvertex 106 -92 34 -103
meshtexuv 106 -15 -17
meshvertex 107 92 34 -103
meshtexuv 107 15 -17
meshvertex 108 -87 75 -72
meshtexuv 108 -14 -12
meshvertex 109 -71 80 -72
meshtexuv 109 -12 -12
meshvertex 110 -39 78 -72
meshtexuv 110 -6 -12
meshvertex 111 0 76 -72
meshtexuv 111 0 -12
meshvertex 112 39 78 -72
meshtexuv 112 7 -12
meshvertex 113 71 80 -72
meshtexuv 113 12 -12
meshvertex 114 87 75 -72
meshtexuv 114 15 -12
meshvertex 115 -87 22 -72
meshtexuv 115 -14 -12
meshvertex 116 87 22 -72
meshtexuv 116 15 -12
meshvertex 117 -85 73 0
meshtexuv 117 -14 0
meshvertex 118 -70 78 0
meshtexuv 118 -12 0
meshvertex 119 -38 77 0
meshtexuv 119 -6 0
meshvertex 120 0 75 0
meshtexuv 120 0 0
meshvertex 121 38 77 0
meshtexuv 121 6 0
meshvertex 122 70 78 0
meshtexuv 122 12 0
meshvertex 123 85 73 0
meshtexuv 123 14 0
meshvertex 124 -85 22 0
meshtexuv 124 -14 0
meshvertex 125 85 22 0
meshtexuv 125 14 0
meshvertex 126 -88 74 70
meshtexuv 126 -15 12
meshvertex 127 -72 80 70
meshtexuv 127 -12 12
meshvertex 128 -40 77 70
meshtexuv 128 -7 12
meshvertex 129 0 75 70
meshtexuv 129 0 12
meshvertex 130 40 77 70
meshtexuv 130 7 12
meshvertex 131 72 80 70
meshtexuv 131 12 12
meshvertex 132 88 74 70
meshtexuv 132 15 12
meshvertex 133 -88 22 70
meshtexuv 133 -15 12
meshvertex 134 88 22 70
meshtexuv 134 15 12
meshvertex 135 -92 76 99
meshtexuv 135 -15 17
meshvertex 136 -75 83 99
meshtexuv 136 -12 17
meshvertex 137 -41 74 99
meshtexuv 137 -7 17
meshvertex 138 0 72 99
meshtexuv 138 0 17
meshvertex 139 41 74 99
meshtexuv 139 7 17
meshvertex 140 75 83 99
meshtexuv 140 13 17
meshvertex 141 92 76 99
meshtexuv 141 15 17
meshvertex 142 -92 34 99
meshtexuv 142 -15 17
meshvertex 143 92 34 99
meshtexuv 143 15 17
meshvertex 144 -93 76 105
meshtexuv 144 -15 18
meshvertex 145 -76 83 105
meshtexuv 145 -13 18
meshvertex 146 -42 74 105
meshtexuv 146 -7 18
meshvertex 147 0 72 105
meshtexuv 147 0 18
meshvertex 148 42 74 105
meshtexuv 148 7 18
meshvertex 149 76 83 105
meshtexuv 149 13 18
meshvertex 150 93 76 105
meshtexuv 150 16 18
meshvertex 151 -93 55 105
meshtexuv 151 -15 18
meshvertex 152 93 55 105
meshtexuv 152 16 18
meshvertex 153 -94 76 119
meshtexuv 153 -16 20
meshvertex 154 -77 84 119
meshtexuv 154 -13 20
meshvertex 155 -42 72 119
meshtexuv 155 -7 20
meshvertex 156 0 70 119
meshtexuv 156 0 20
meshvertex 157 42 72 119
meshtexuv 157 7 20
meshvertex 158 77 84 119
meshtexuv 158 13 20
meshvertex 159 94 76 119
meshtexuv 159 16 20
meshvertex 160 -94 68 119
meshtexuv 160 -16 20
meshvertex 161 94 68 119
meshtexuv 161 16 20
meshvertex 162 -96 76 138
meshtexuv 162 -16 23
meshvertex 163 -79 85 138
meshtexuv 163 -13 23
meshvertex 164 -43 71 138
meshtexuv 164 -7 23
meshvertex 165 0 69 138
meshtexuv 165 0 23
meshvertex 166 43 71 138
meshtexuv 166 7 23
meshvertex 167 79 85 138
meshtexuv 167 13 23
meshvertex 168 96 76 138
meshtexuv 168 16 23
meshvertex 169 -96 73 138
meshtexuv 169 -16 23
meshvertex 170 96 73 138
meshtexuv 170 16 23
meshvertex 171 -94 73 157
meshtexuv 171 -16 26
meshvertex 172 -77 81 157
meshtexuv 172 -13 26
meshvertex 173 -42 69 157
meshtexuv 173 -7 26
meshvertex 174 0 67 157
meshtexuv 174 0 26
meshvertex 175 42 69 157
meshtexuv 175 7 26
meshvertex 176 77 81 157
meshtexuv 176 13 26
meshvertex 177 94 73 157
meshtexuv 177 16 26
meshvertex 178 -94 68 157
meshtexuv 178 -16 26
meshvertex 179 94 68 157
meshtexuv 179 16 26
meshvertex 180 -92 70 171
meshtexuv 180 -15 29
meshvertex 181 -75 78 171
meshtexuv 181 -12 29
meshvertex 182 -41 67 171
meshtexuv 182 -7 29
meshvertex 183 0 65 171
meshtexuv 183 0 29
meshvertex 184 41 67 171
meshtexuv 184 7 29
meshvertex 185 75 78 171
meshtexuv 185 13 29
meshvertex 186 92 70 171
meshtexuv 186 15 29
meshvertex 187 -92 55 171
meshtexuv 187 -15 29
meshvertex 188 92 55 171
meshtexuv 188 15 29
meshvertex 189 -91 69 177
meshtexuv 189 -15 30
meshvertex 190 -75 77 177
meshtexuv 190 -12 30
meshvertex 191 -41 66 177
meshtexuv 191 -7 30
meshvertex 192 0 64 177
meshtexuv 192 0 30
meshvertex 193 41 66 177
meshtexuv 193 7 30
meshvertex 194 75 77 177
meshtexuv 194 13 30
meshvertex 195 91 69 177
meshtexuv 195 15 30
meshvertex 196 -91 34 177
meshtexuv 196 -15 30
meshvertex 197 91 34 177
meshtexuv 197 15 30
meshvertex 198 -81 57 207
meshtexuv 198 -13 35
meshvertex 199 -66 63 207
meshtexuv 199 -11 35
meshvertex 200 -36 56 207
meshtexuv 200 -6 35
meshvertex 201 0 54 207
meshtexuv 201 0 35
meshvertex 202 36 56 207
meshtexuv 202 6 35
meshvertex 203 66 63 207
meshtexuv 203 11 35
meshvertex 204 81 57 207
meshtexuv 204 14 35
meshvertex 205 -81 22 207
meshtexuv 205 -13 35
meshvertex 206 81 22 207
meshtexuv 206 14 35
meshvertex 207 -72 48 223
meshtexuv 207 -12 37
meshvertex 208 -59 53 223
meshtexuv 208 -10 37
meshvertex 209 -32 48 223
meshtexuv 209 -5 37
meshvertex 210 0 46 223
meshtexuv 210 0 37
meshvertex 211 32 48 223
meshtexuv 211 5 37
meshvertex 212 59 53 223
meshtexuv 212 10 37
meshvertex 213 72 48 223
meshtexuv 213 12 37
meshvertex 214 -72 22 223
meshtexuv 214 -12 37
meshvertex 215 72 22 223
meshtexuv 215 12 37
meshvertex 216 0 32 -223
meshtexuv 216 0 -37
meshvertex 217 0 32 223
meshtexuv 217 0 37
meshvertex 218 -71 18 -204
meshtexuv 218 -10 -29
meshvertex 219 71 18 197
meshtexuv 219 10 28
meshvertex 220 -71 18 197
meshtexuv 220 -10 28
meshvertex 221 71 18 -204
meshtexuv 221 10 -29
meshvertex 222 -54 73 -150
meshtexuv 222 -6 -17
meshvertex 223 -58 98 -92
meshtexuv 223 -6 -10
meshvertex 224 -29 101 -92
meshtexuv 224 -3 -10
meshvertex 225 -27 75 -150
meshtexuv 225 -3 -17
meshvertex 226 0 102 -92
meshtexuv 226 0 -10
meshvertex 227 0 75 -150
meshtexuv 227 0 -17
meshvertex 228 29 101 -92
meshtexuv 228 3 -10
meshvertex 229 27 75 -150
meshtexuv 229 3 -17
meshvertex 230 58 98 -92
meshtexuv 230 6 -10
meshvertex 231 54 73 -150
meshtexuv 231 6 -17
meshvertex 232 -60 106 -60
meshtexuv 232 -7 -7
meshvertex 233 -30 111 -60
meshtexuv 233 -3 -7
meshvertex 234 0 113 -60
meshtexuv 234 0 -7
meshvertex 235 30 111 -60
meshtexuv 235 3 -7
meshvertex 236 60 106 -60
meshtexuv 236 7 -7
meshvertex 237 -61 108 -15
meshtexuv 237 -7 -2
meshvertex 238 -30 113 -15
meshtexuv 238 -3 -2
meshvertex 239 0 115 -15
meshtexuv 239 0 -2
meshvertex 240 31 113 -15
meshtexuv 240 3 -2
meshvertex 241 61 108 -15
meshtexuv 241 7 -2
meshvertex 242 -57 105 30
meshtexuv 242 -6 3
meshvertex 243 -28 111 30
meshtexuv 243 -3 3
meshvertex 244 0 113 30
meshtexuv 244 0 3
meshvertex 245 29 111 30
meshtexuv 245 3 3
meshvertex 246 57 105 30
meshtexuv 246 6 3
meshvertex 247 -54 101 48
meshtexuv 247 -6 5
meshvertex 248 -27 106 48
meshtexuv 248 -3 5
meshvertex 249 0 108 48
meshtexuv 249 0 5
meshvertex 250 27 106 48
meshtexuv 250 3 5
meshvertex 251 54 101 48
meshtexuv 251 6 5
meshvertex 252 -69 73 108
meshtexuv 252 -8 12
meshvertex 253 -34 75 108
meshtexuv 253 -4 12
meshvertex 254 0 75 108
meshtexuv 254 0 12
meshvertex 255 35 75 108
meshtexuv 255 4 12
meshvertex 256 69 73 108
meshtexuv 256 8 12
meshvertex 257 -78 79 -126
meshtexuv 257 -9 -14
meshvertex 258 -55 101 48
meshtexuv 258 -6 5
meshvertex 259 -61 104 -61
meshtexuv 259 -7 -7
meshvertex 260 -74 78 101
meshtexuv 260 -8 11
meshvertex 261 -81 77 -64
meshtexuv 261 -9 -7
meshvertex 262 -80 77 -141
meshtexuv 262 -13 -23
meshvertex 268 78 79 -126
meshtexuv 268 9 -14
meshvertex 269 61 104 -61
meshtexuv 269 7 -7
meshvertex 270 55 101 48
meshtexuv 270 6 5
meshvertex 271 74 78 101
meshtexuv 271 8 11
meshvertex 272 81 77 -64
meshtexuv 272 9 -7
meshvertex 273 80 77 -141
meshtexuv 273 13 -23
meshvertex 279 -76 34 -108
meshtexuv 279 0 9
meshvertex 280 -97 47 -111
meshtexuv 280 3 8
meshvertex 281 -97 34 -108
meshtexuv 281 0 9
meshvertex 282 -76 47 -111
meshtexuv 282 3 8
meshvertex 283 -97 58 -118
meshtexuv 283 6 6
meshvertex 285 -76 58 -118
meshtexuv 285 6 6
meshvertex 286 -97 65 -129
meshtexuv 286 8 3
meshvertex 288 -76 65 -129
meshtexuv 288 8 3
meshvertex 289 -97 68 -142
meshtexuv 289 9 0
meshvertex 290 -76 68 -142
meshtexuv 290 9 0
meshvertex 291 -97 65 -155
meshtexuv 291 8 -3
meshvertex 292 -76 65 -155
meshtexuv 292 8 -3
meshvertex 293 -97 58 -166
meshtexuv 293 6 -6
meshvertex 295 -76 58 -166
meshtexuv 295 6 -6
meshvertex 296 -97 47 -173
meshtexuv 296 3 -8
meshvertex 298 -76 47 -173
meshtexuv 298 3 -8
meshvertex 299 -97 34 -176
meshtexuv 299 0 -8
meshvertex 300 -76 34 -176
meshtexuv 300 0 -8
meshvertex 301 -97 21 -173
meshtexuv 301 -3 -8
meshvertex 302 -76 21 -173
meshtexuv 302 -3 -8
meshvertex 303 -97 10 -166
meshtexuv 303 -6 -6
meshvertex 305 -76 10 -166
meshtexuv 305 -6 -6
meshvertex 306 -97 3 -155
meshtexuv 306 -8 -3
meshvertex 308 -76 3 -155
meshtexuv 308 -8 -3
meshvertex 309 -97 0 -142
meshtexuv 309 -8 0
meshvertex 310 -76 0 -142
meshtexuv 310 -8 0
meshvertex 311 -97 3 -129
meshtexuv 311 -8 3
meshvertex 312 -76 3 -129
meshtexuv 312 -8 3
meshvertex 313 -97 10 -118
meshtexuv 313 -6 6
meshvertex 315 -76 10 -118
meshtexuv 315 -6 6
meshvertex 316 -97 21 -111
meshtexuv 316 -3 8
meshvertex 318 -76 21 -111
meshtexuv 318 -3 8
meshvertex 320 -100 42 -122
meshtexuv 320 2 5
meshvertex 321 -100 34 -120
meshtexuv 321 0 6
meshvertex 323 -100 50 -126
meshtexuv 323 4 4
meshvertex 327 -100 54 -134
meshtexuv 327 5 2
meshvertex 330 -100 56 -142
meshtexuv 330 6 0
meshvertex 332 -100 54 -150
meshtexuv 332 5 -2
meshvertex 334 -100 50 -158
meshtexuv 334 4 -4
meshvertex 338 -100 42 -162
meshtexuv 338 2 -5
meshvertex 341 -100 34 -164
meshtexuv 341 0 -5
meshvertex 343 -100 26 -162
meshtexuv 343 -2 -5
meshvertex 345 -100 18 -158
meshtexuv 345 -4 -4
meshvertex 349 -100 14 -150
meshtexuv 349 -5 -2
meshvertex 352 -100 12 -142
meshtexuv 352 -5 0
meshvertex 354 -100 14 -134
meshtexuv 354 -5 2
meshvertex 356 -100 18 -126
meshtexuv 356 -4 4
meshvertex 360 -100 26 -122
meshtexuv 360 -2 5
meshvertex 365 -100 47 -129
meshtexuv 365 3 3
meshvertex 366 -100 34 -124
meshtexuv 366 0 5
meshvertex 367 -99 34 -142
meshtexuv 367 -14 -20
meshvertex 368 -99 34 -124
meshtexuv 368 -14 -18
meshvertex 369 -99 47 -129
meshtexuv 369 -14 -18
meshvertex 371 -100 52 -142
meshtexuv 371 5 0
meshvertex 372 -99 52 -142
meshtexuv 372 -14 -20
meshvertex 374 -100 47 -155
meshtexuv 374 3 -3
meshvertex 375 -99 47 -155
meshtexuv 375 -14 -22
meshvertex 377 -100 34 -160
meshtexuv 377 0 -4
meshvertex 378 -99 34 -160
meshtexuv 378 -14 -23
meshvertex 380 -100 21 -155
meshtexuv 380 -3 -3
meshvertex 381 -99 21 -155
meshtexuv 381 -14 -22
meshvertex 383 -100 16 -142
meshtexuv 383 -4 0
meshvertex 384 -99 16 -142
meshtexuv 384 -14 -20
meshvertex 386 -100 21 -129
meshtexuv 386 -3 3
meshvertex 387 -99 21 -129
meshtexuv 387 -14 -18
meshvertex 388 -100 34 -138
meshtexuv 388 0 1
meshvertex 389 -100 35 -122
meshtexuv 389 0 5
meshvertex 390 -100 39 -123
meshtexuv 390 1 5
meshvertex 391 -100 35 -138
meshtexuv 391 0 1
meshvertex 392 -100 38 -140
meshtexuv 392 1 1
meshvertex 393 -100 53 -137
meshtexuv 393 5 1
meshvertex 394 -100 54 -140
meshtexuv 394 5 1
meshvertex 395 -100 38 -142
meshtexuv 395 1 0
meshvertex 396 -100 37 -145
meshtexuv 396 1 -1
meshvertex 397 -100 45 -159
meshtexuv 397 3 -4
meshvertex 398 -100 42 -160
meshtexuv 398 2 -4
meshvertex 399 -100 35 -146
meshtexuv 399 0 -1
meshvertex 400 -100 32 -145
meshtexuv 400 0 -1
meshvertex 401 -100 21 -157
meshtexuv 401 -3 -4
meshvertex 402 -100 19 -155
meshtexuv 402 -4 -3
meshvertex 403 -100 31 -144
meshtexuv 403 -1 0
meshvertex 404 -100 30 -141
meshtexuv 404 -1 0
meshvertex 405 -100 15 -135
meshtexuv 405 -5 2
meshvertex 406 -100 17 -132
meshtexuv 406 -4 3
meshvertex 407 -100 31 -139
meshtexuv 407 -1 1
meshvertex 408 76 34 -108
meshtexuv 408 0 9
meshvertex 409 97 34 -108
meshtexuv 409 0 9
meshvertex 410 97 47 -111
meshtexuv 410 3 8
meshvertex 411 76 47 -111
meshtexuv 411 3 8
meshvertex 413 97 58 -118
meshtexuv 413 6 6
meshvertex 414 76 58 -118
meshtexuv 414 6 6
meshvertex 416 97 65 -129
meshtexuv 416 8 3
meshvertex 417 76 65 -129
meshtexuv 417 8 3
meshvertex 418 97 68 -142
meshtexuv 418 9 0
meshvertex 419 76 68 -142
meshtexuv 419 9 0
meshvertex 420 97 65 -155
meshtexuv 420 8 -3
meshvertex 421 76 65 -155
meshtexuv 421 8 -3
meshvertex 423 97 58 -166
meshtexuv 423 6 -6
meshvertex 424 76 58 -166
meshtexuv 424 6 -6
meshvertex 426 97 47 -173
meshtexuv 426 3 -8
meshvertex 427 76 47 -173
meshtexuv 427 3 -8
meshvertex 428 97 34 -176
meshtexuv 428 0 -8
meshvertex 429 76 34 -176
meshtexuv 429 0 -8
meshvertex 430 97 21 -173
meshtexuv 430 -3 -8
meshvertex 431 76 21 -173
meshtexuv 431 -3 -8
meshvertex 433 97 10 -166
meshtexuv 433 -6 -6
meshvertex 434 76 10 -166
meshtexuv 434 -6 -6
meshvertex 436 97 3 -155
meshtexuv 436 -8 -3
meshvertex 437 76 3 -155
meshtexuv 437 -8 -3
meshvertex 438 97 0 -142
meshtexuv 438 -8 0
meshvertex 439 76 0 -142
meshtexuv 439 -8 0
meshvertex 440 97 3 -129
meshtexuv 440 -8 3
meshvertex 441 76 3 -129
meshtexuv 441 -8 3
meshvertex 443 97 10 -118
meshtexuv 443 -6 6
meshvertex 444 76 10 -118
meshtexuv 444 -6 6
meshvertex 446 97 21 -111
meshtexuv 446 -3 8
meshvertex 447 76 21 -111
meshtexuv 447 -3 8
meshvertex 449 100 34 -120
meshtexuv 449 0 6
meshvertex 450 100 42 -122
meshtexuv 450 2 5
meshvertex 452 100 50 -126
meshtexuv 452 4 4
meshvertex 456 100 54 -134
meshtexuv 456 5 2
meshvertex 459 100 56 -142
meshtexuv 459 6 0
meshvertex 461 100 54 -150
meshtexuv 461 5 -2
meshvertex 463 100 50 -158
meshtexuv 463 4 -4
meshvertex 467 100 42 -162
meshtexuv 467 2 -5
meshvertex 470 100 34 -164
meshtexuv 470 0 -5
meshvertex 472 100 26 -162
meshtexuv 472 -2 -5
meshvertex 474 100 18 -158
meshtexuv 474 -4 -4
meshvertex 478 100 14 -150
meshtexuv 478 -5 -2
meshvertex 481 100 12 -142
meshtexuv 481 -5 0
meshvertex 483 100 14 -134
meshtexuv 483 -5 2
meshvertex 485 100 18 -126
meshtexuv 485 -4 4
meshvertex 489 100 26 -122
meshtexuv 489 -2 5
meshvertex 493 100 47 -129
meshtexuv 493 3 3
meshvertex 495 100 34 -124
meshtexuv 495 0 5
meshvertex 496 99 34 -142
meshtexuv 496 14 -20
meshvertex 497 99 47 -129
meshtexuv 497 14 -18
meshvertex 498 99 34 -124
meshtexuv 498 14 -18
meshvertex 499 100 52 -142
meshtexuv 499 5 0
meshvertex 501 99 52 -142
meshtexuv 501 14 -20
meshvertex 502 100 47 -155
meshtexuv 502 3 -3
meshvertex 504 99 47 -155
meshtexuv 504 14 -22
meshvertex 505 100 34 -160
meshtexuv 505 0 -4
meshvertex 507 99 34 -160
meshtexuv 507 14 -23
meshvertex 508 100 21 -155
meshtexuv 508 -3 -3
meshvertex 510 99 21 -155
meshtexuv 510 14 -22
meshvertex 511 100 16 -142
meshtexuv 511 -4 0
meshvertex 513 99 16 -142
meshtexuv 513 14 -20
meshvertex 514 100 21 -129
meshtexuv 514 -3 3
meshvertex 516 99 21 -129
meshtexuv 516 14 -18
meshvertex 517 100 34 -138
meshtexuv 517 0 1
meshvertex 518 100 39 -123
meshtexuv 518 1 5
meshvertex 519 100 35 -122
meshtexuv 519 0 5
meshvertex 520 100 35 -138
meshtexuv 520 0 1
meshvertex 521 100 38 -140
meshtexuv 521 1 1
meshvertex 522 100 54 -140
meshtexuv 522 5 1
meshvertex 523 100 53 -137
meshtexuv 523 5 1
meshvertex 524 100 38 -142
meshtexuv 524 1 0
meshvertex 525 100 37 -145
meshtexuv 525 1 -1
meshvertex 526 100 42 -160
meshtexuv 526 2 -4
meshvertex 527 100 45 -159
meshtexuv 527 3 -4
meshvertex 528 100 35 -146
meshtexuv 528 0 -1
meshvertex 529 100 32 -145
meshtexuv 529 0 -1
meshvertex 530 100 19 -155
meshtexuv 530 -4 -3
meshvertex 531 100 21 -157
meshtexuv 531 -3 -4
meshvertex 532 100 31 -144
meshtexuv 532 -1 0
meshvertex 533 100 30 -141
meshtexuv 533 -1 0
meshvertex 534 100 17 -132
meshtexuv 534 -4 3
meshvertex 535 100 15 -135
meshtexuv 535 -5 2
meshvertex 536 100 31 -139
meshtexuv 536 -1 1
meshvertex 537 -76 34 172
meshtexuv 537 0 9
meshvertex 538 -97 47 169
meshtexuv 538 3 8
meshvertex 539 -97 34 172
meshtexuv 539 0 9
meshvertex 540 -76 47 169
meshtexuv 540 3 8
meshvertex 541 -97 58 162
meshtexuv 541 6 6
meshvertex 543 -76 58 162
meshtexuv 543 6 6
meshvertex 544 -97 65 151
meshtexuv 544 8 3
meshvertex 546 -76 65 151
meshtexuv 546 8 3
meshvertex 547 -97 68 138
meshtexuv 547 9 0
meshvertex 548 -76 68 138
meshtexuv 548 9 0
meshvertex 549 -97 65 125
meshtexuv 549 8 -3
meshvertex 550 -76 65 125
meshtexuv 550 8 -3
meshvertex 551 -97 58 114
meshtexuv 551 6 -6
meshvertex 553 -76 58 114
meshtexuv 553 6 -6
meshvertex 554 -97 47 107
meshtexuv 554 3 -8
meshvertex 556 -76 47 107
meshtexuv 556 3 -8
meshvertex 557 -97 34 104
meshtexuv 557 0 -8
meshvertex 558 -76 34 104
meshtexuv 558 0 -8
meshvertex 559 -97 21 107
meshtexuv 559 -3 -8
meshvertex 560 -76 21 107
meshtexuv 560 -3 -8
meshvertex 561 -97 10 114
meshtexuv 561 -6 -6
meshvertex 563 -76 10 114
meshtexuv 563 -6 -6
meshvertex 564 -97 3 125
meshtexuv 564 -8 -3
meshvertex 566 -76 3 125
meshtexuv 566 -8 -3
meshvertex 567 -97 0 138
meshtexuv 567 -8 0
meshvertex 568 -76 0 138
meshtexuv 568 -8 0
meshvertex 569 -97 3 151
meshtexuv 569 -8 3
meshvertex 570 -76 3 151
meshtexuv 570 -8 3
meshvertex 571 -97 10 162
meshtexuv 571 -6 6
meshvertex 573 -76 10 162
meshtexuv 573 -6 6
meshvertex 574 -97 21 169
meshtexuv 574 -3 8
meshvertex 576 -76 21 169
meshtexuv 576 -3 8
meshvertex 578 -100 42 158
meshtexuv 578 2 5
meshvertex 579 -100 34 160
meshtexuv 579 0 6
meshvertex 581 -100 50 154
meshtexuv 581 4 4
meshvertex 585 -100 54 146
meshtexuv 585 5 2
meshvertex 588 -100 56 138
meshtexuv 588 6 0
meshvertex 590 -100 54 130
meshtexuv 590 5 -2
meshvertex 592 -100 50 122
meshtexuv 592 4 -4
meshvertex 596 -100 42 118
meshtexuv 596 2 -5
meshvertex 599 -100 34 116
meshtexuv 599 0 -5
meshvertex 601 -100 26 118
meshtexuv 601 -2 -5
meshvertex 603 -100 18 122
meshtexuv 603 -4 -4
meshvertex 607 -100 14 130
meshtexuv 607 -5 -2
meshvertex 610 -100 12 138
meshtexuv 610 -5 0
meshvertex 612 -100 14 146
meshtexuv 612 -5 2
meshvertex 614 -100 18 154
meshtexuv 614 -4 4
meshvertex 618 -100 26 158
meshtexuv 618 -2 5
meshvertex 623 -100 47 151
meshtexuv 623 3 3
meshvertex 624 -100 34 156
meshtexuv 624 0 5
meshvertex 625 -99 34 138
meshtexuv 625 -14 20
meshvertex 626 -99 34 156
meshtexuv 626 -14 22
meshvertex 627 -99 47 151
meshtexuv 627 -14 22
meshvertex 629 -100 52 138
meshtexuv 629 5 0
meshvertex 630 -99 52 138
meshtexuv 630 -14 20
meshvertex 632 -100 47 125
meshtexuv 632 3 -3
meshvertex 633 -99 47 125
meshtexuv 633 -14 18
meshvertex 635 -100 34 120
meshtexuv 635 0 -4
meshvertex 636 -99 34 120
meshtexuv 636 -14 17
meshvertex 638 -100 21 125
meshtexuv 638 -3 -3
meshvertex 639 -99 21 125
meshtexuv 639 -14 18
meshvertex 641 -100 16 138
meshtexuv 641 -4 0
meshvertex 642 -99 16 138
meshtexuv 642 -14 20
meshvertex 644 -100 21 151
meshtexuv 644 -3 3
meshvertex 645 -99 21 151
meshtexuv 645 -14 22
meshvertex 646 -100 34 142
meshtexuv 646 0 1
meshvertex 647 -100 35 158
meshtexuv 647 0 5
meshvertex 648 -100 39 157
meshtexuv 648 1 5
meshvertex 649 -100 35 142
meshtexuv 649 0 1
meshvertex 650 -100 38 140
meshtexuv 650 1 1
meshvertex 651 -100 53 143
meshtexuv 651 5 1
meshvertex 652 -100 54 140
meshtexuv 652 5 1
meshvertex 653 -100 38 138
meshtexuv 653 1 0
meshvertex 654 -100 37 135
meshtexuv 654 1 -1
meshvertex 655 -100 45 121
meshtexuv 655 3 -4
meshvertex 656 -100 42 120
meshtexuv 656 2 -4
meshvertex 657 -100 35 134
meshtexuv 657 0 -1
meshvertex 658 -100 32 135
meshtexuv 658 0 -1
meshvertex 659 -100 21 123
meshtexuv 659 -3 -4
meshvertex 660 -100 19 125
meshtexuv 660 -4 -3
meshvertex 661 -100 31 136
meshtexuv 661 -1 0
meshvertex 662 -100 30 139
meshtexuv 662 -1 0
meshvertex 663 -100 15 145
meshtexuv 663 -5 2
meshvertex 664 -100 17 148
meshtexuv 664 -4 3
meshvertex 665 -100 31 141
meshtexuv 665 -1 1
meshvertex 666 76 34 172
meshtexuv 666 0 9
meshvertex 667 97 34 172
meshtexuv 667 0 9
meshvertex 668 97 47 169
meshtexuv 668 3 8
meshvertex 669 76 47 169
meshtexuv 669 3 8
meshvertex 671 97 58 162
meshtexuv 671 6 6
meshvertex 672 76 58 162
meshtexuv 672 6 6
meshvertex 674 97 65 151
meshtexuv 674 8 3
meshvertex 675 76 65 151
meshtexuv 675 8 3
meshvertex 676 97 68 138
meshtexuv 676 9 0
meshvertex 677 76 68 138
meshtexuv 677 9 0
meshvertex 678 97 65 125
meshtexuv 678 8 -3
meshvertex 679 76 65 125
meshtexuv 679 8 -3
meshvertex 681 97 58 114
meshtexuv 681 6 -6
meshvertex 682 76 58 114
meshtexuv 682 6 -6
meshvertex 684 97 47 107
meshtexuv 684 3 -8
meshvertex 685 76 47 107
meshtexuv 685 3 -8
meshvertex 686 97 34 104
meshtexuv 686 0 -8
meshvertex 687 76 34 104
meshtexuv 687 0 -8
meshvertex 688 97 21 107
meshtexuv 688 -3 -8
meshvertex 689 76 21 107
meshtexuv 689 -3 -8
meshvertex 691 97 10 114
meshtexuv 691 -6 -6
meshvertex 692 76 10 114
meshtexuv 692 -6 -6
meshvertex 694 97 3 125
meshtexuv 694 -8 -3
meshvertex 695 76 3 125
meshtexuv 695 -8 -3
meshvertex 696 97 0 138
meshtexuv 696 -8 0
meshvertex 697 76 0 138
meshtexuv 697 -8 0
meshvertex 698 97 3 151
meshtexuv 698 -8 3
meshvertex 699 76 3 151
meshtexuv 699 -8 3
meshvertex 701 97 10 162
meshtexuv 701 -6 6
meshvertex 702 76 10 162
meshtexuv 702 -6 6
meshvertex 704 97 21 169
meshtexuv 704 -3 8
meshvertex 705 76 21 169
meshtexuv 705 -3 8
meshvertex 707 100 34 160
meshtexuv 707 0 6
meshvertex 708 100 42 158
meshtexuv 708 2 5
meshvertex 710 100 50 154
meshtexuv 710 4 4
meshvertex 714 100 54 146
meshtexuv 714 5 2
meshvertex 717 100 56 138
meshtexuv 717 6 0
meshvertex 719 100 54 130
meshtexuv 719 5 -2
meshvertex 721 100 50 122
meshtexuv 721 4 -4
meshvertex 725 100 42 118
meshtexuv 725 2 -5
meshvertex 728 100 34 116
meshtexuv 728 0 -5
meshvertex 730 100 26 118
meshtexuv 730 -2 -5
meshvertex 732 100 18 122
meshtexuv 732 -4 -4
meshvertex 736 100 14 130
meshtexuv 736 -5 -2
meshvertex 739 100 12 138
meshtexuv 739 -5 0
meshvertex 741 100 14 146
meshtexuv 741 -5 2
meshvertex 743 100 18 154
meshtexuv 743 -4 4
meshvertex 747 100 26 158
meshtexuv 747 -2 5
meshvertex 751 100 47 151
meshtexuv 751 3 3
meshvertex 753 100 34 156
meshtexuv 753 0 5
meshvertex 754 99 34 138
meshtexuv 754 14 20
meshvertex 755 99 47 151
meshtexuv 755 14 22
meshvertex 756 99 34 156
meshtexuv 756 14 22
meshvertex 757 100 52 138
meshtexuv 757 5 0
meshvertex 759 99 52 138
meshtexuv 759 14 20
meshvertex 760 100 47 125
meshtexuv 760 3 -3
meshvertex 762 99 47 125
meshtexuv 762 14 18
meshvertex 763 100 34 120
meshtexuv 763 0 -4
meshvertex 765 99 34 120
meshtexuv 765 14 17
meshvertex 766 100 21 125
meshtexuv 766 -3 -3
meshvertex 768 99 21 125
meshtexuv 768 14 18
meshvertex 769 100 16 138
meshtexuv 769 -4 0
meshvertex 771 99 16 138
meshtexuv 771 14 20
meshvertex 772 100 21 151
meshtexuv 772 -3 3
meshvertex 774 99 21 151
meshtexuv 774 14 22
meshvertex 775 100 34 142
meshtexuv 775 0 1
meshvertex 776 100 39 157
meshtexuv 776 1 5
meshvertex 777 100 35 158
meshtexuv 777 0 5
meshvertex 778 100 35 142
meshtexuv 778 0 1
meshvertex 779 100 38 140
meshtexuv 779 1 1
meshvertex 780 100 54 140
meshtexuv 780 5 1
meshvertex 781 100 53 143
meshtexuv 781 5 1
meshvertex 782 100 38 138
meshtexuv 782 1 0
meshvertex 783 100 37 135
meshtexuv 783 1 -1
meshvertex 784 100 42 120
meshtexuv 784 2 -4
meshvertex 785 100 45 121
meshtexuv 785 3 -4
meshvertex 786 100 35 134
meshtexuv 786 0 -1
meshvertex 787 100 32 135
meshtexuv 787 0 -1
meshvertex 788 100 19 125
meshtexuv 788 -4 -3
meshvertex 789 100 21 123
meshtexuv 789 -3 -4
meshvertex 790 100 31 136
meshtexuv 790 -1 0
meshvertex 791 100 30 139
meshtexuv 791 -1 0
meshvertex 792 100 17 148
meshtexuv 792 -4 3
meshvertex 793 100 15 145
meshtexuv 793 -5 2
meshvertex 794 100 31 141
meshtexuv 794 -1 1
meshvertex 795 -94 36 -91
meshtexuv 795 -13 -13
meshvertex 796 -88 57 -55
meshtexuv 796 -13 -8
meshvertex 797 -91 60 -90
meshtexuv 797 -13 -13
meshvertex 798 -92 39 -63
meshtexuv 798 -13 -9
meshvertex 799 -73 83 75
meshtexuv 799 -10 11
meshvertex 800 -93 86 66
meshtexuv 800 -13 9
meshvertex 801 -93 84 69
meshtexuv 801 -13 10
meshvertex 803 -72 85 72
meshtexuv 803 -10 10
meshvertex 805 -89 85 63
meshtexuv 805 -10 7
meshvertex 806 -100 84 62
meshtexuv 806 -11 7
meshvertex 807 -100 91 66
meshtexuv 807 -11 7
meshvertex 810 -88 92 67
meshtexuv 810 -10 7
meshvertex 813 -98 85 77
meshtexuv 813 -16 13
meshvertex 816 -88 86 79
meshtexuv 816 -15 13
meshvertex 823 94 36 -91
meshtexuv 823 13 -13
meshvertex 824 91 60 -90
meshtexuv 824 13 -13
meshvertex 825 88 57 -55
meshtexuv 825 13 -8
meshvertex 826 92 39 -63
meshtexuv 826 13 -9
meshvertex 827 73 83 75
meshtexuv 827 10 11
meshvertex 828 93 84 69
meshtexuv 828 13 10
meshvertex 829 93 86 66
meshtexuv 829 13 9
meshvertex 832 72 85 72
meshtexuv 832 10 10
meshvertex 833 89 85 63
meshtexuv 833 10 7
meshvertex 834 100 91 66
meshtexuv 834 11 7
meshvertex 835 100 84 62
meshtexuv 835 11 7
meshvertex 837 88 92 67
meshtexuv 837 10 7
meshvertex 840 98 85 77
meshtexuv 840 16 13
meshvertex 843 88 86 79
meshtexuv 843 15 13
meshvertex 851 -80 50 226
meshtexuv 851 -11 32
meshvertex 852 80 50 226
meshtexuv 852 11 32
meshvertex 853 80 53 225
meshtexuv 853 11 32
meshvertex 854 -80 53 225
meshtexuv 854 -11 32
meshvertex 855 -81 63 -227
meshtexuv 855 -12 -32
meshvertex 856 81 67 -226
meshtexuv 856 12 -32
meshvertex 857 81 63 -227
meshtexuv 857 12 -32
meshvertex 858 -81 67 -226
meshtexuv 858 -12 -32
meshvertex 859 -84 39 -227
meshtexuv 859 -17 -45
meshvertex 860 80 57 -225
meshtexuv 860 16 -45
meshvertex 861 84 39 -227
meshtexuv 861 17 -45
meshvertex 862 -80 57 -225
meshtexuv 862 -16 -45
meshvertex 863 -51 24 225
meshtexuv 863 -7 32
meshvertex 864 51 24 225
meshtexuv 864 7 32
meshvertex 865 57 43 225
meshtexuv 865 8 32
meshvertex 866 -57 43 225
meshtexuv 866 -8 32
meshvertex 867 -73 15 -225
meshtexuv 867 -10 -32
meshvertex 868 67 39 -225
meshtexuv 868 10 -32
meshvertex 869 73 15 -225
meshtexuv 869 10 -32
meshvertex 870 -67 39 -225
meshtexuv 870 -10 -32
meshvertex 871 -52 15 -225
meshtexuv 871 -7 -32
meshvertex 872 -50 37 -220
meshtexuv 872 -7 -31
meshvertex 873 -50 15 -225
meshtexuv 873 -7 -32
meshvertex 874 -52 37 -220
meshtexuv 874 -7 -31
meshvertex 875 -18 15 -225
meshtexuv 875 -3 -32
meshvertex 876 -16 37 -220
meshtexuv 876 -2 -31
meshvertex 877 -16 15 -225
meshtexuv 877 -2 -32
meshvertex 878 -18 37 -220
meshtexuv 878 -3 -31
meshvertex 879 16 15 -225
meshtexuv 879 2 -32
meshvertex 880 18 37 -220
meshtexuv 880 3 -31
meshvertex 881 18 15 -225
meshtexuv 881 3 -32
meshvertex 882 16 37 -220
meshtexuv 882 2 -31
meshvertex 883 50 15 -225
meshtexuv 883 7 -32
meshvertex 884 52 37 -220
meshtexuv 884 7 -31
meshvertex 885 52 15 -225
meshtexuv 885 7 -32
meshvertex 886 50 37 -220
meshtexuv 886 7 -31
meshvertex 887 -51 73 108
meshtexuv 887 -7 15
meshvertex 888 -64 76 112
meshtexuv 888 -9 16
meshvertex 889 -66 72 158
meshtexuv 889 -9 23
meshvertex 890 -57 70 157
meshtexuv 890 -8 22
meshvertex 891 51 73 108
meshtexuv 891 7 15
meshvertex 892 66 72 158
meshtexuv 892 9 23
meshvertex 893 64 76 112
meshtexuv 893 9 16
meshvertex 894 57 70 157
meshtexuv 894 8 22
meshvertex 895 -93 29 -103
meshtexuv 895 -19 -21
meshvertex 896 -88 29 -72
meshtexuv 896 -18 -14
meshvertex 897 -88 43 -72
meshtexuv 897 -18 -14
meshvertex 898 -93 43 -103
meshtexuv 898 -19 -21
meshvertex 899 -86 29 0
meshtexuv 899 -17 0
meshvertex 900 -86 43 0
meshtexuv 900 -17 0
meshvertex 901 -89 29 70
meshtexuv 901 -18 14
meshvertex 902 -89 43 70
meshtexuv 902 -18 14
meshvertex 903 -93 29 99
meshtexuv 903 -19 20
meshvertex 904 -93 43 99
meshtexuv 904 -19 20
meshvertex 905 93 29 -103
meshtexuv 905 19 -21
meshvertex 906 88 43 -72
meshtexuv 906 18 -14
meshvertex 907 88 29 -72
meshtexuv 907 18 -14
meshvertex 908 93 43 -103
meshtexuv 908 19 -21
meshvertex 909 86 43 0
meshtexuv 909 17 0
meshvertex 910 86 29 0
meshtexuv 910 17 0
meshvertex 911 89 43 70
meshtexuv 911 18 14
meshvertex 912 89 29 70
meshtexuv 912 18 14
meshvertex 913 93 43 99
meshtexuv 913 19 20
meshvertex 914 93 29 99
meshtexuv 914 19 20
meshvertex 915 -92 44 -88
meshtexuv 915 -13 -13
meshvertex 916 -91 44 -87
meshtexuv 916 -13 -12
meshvertex 917 -91 73 -87
meshtexuv 917 -13 -12
meshvertex 918 -92 73 -88
meshtexuv 918 -13 -13
meshvertex 919 -91 44 80
meshtexuv 919 -13 11
meshvertex 920 -92 44 81
meshtexuv 920 -13 12
meshvertex 921 -92 73 81
meshtexuv 921 -13 12
meshvertex 922 -91 73 80
meshtexuv 922 -13 11
meshvertex 923 -59 106 -60
meshtexuv 923 -8 -9
meshvertex 924 -58 103 30
meshtexuv 924 -8 4
meshvertex 925 -57 106 30
meshtexuv 925 -8 4
meshvertex 926 -60 109 -60
meshtexuv 926 -9 -9
meshvertex 927 -89 67 -64
meshtexuv 927 -13 -9
meshvertex 928 -90 67 65
meshtexuv 928 -13 9
meshvertex 929 -90 69 65
meshtexuv 929 -13 9
meshvertex 930 -89 69 -64
meshtexuv 930 -13 -9
meshvertex 931 92 44 -88
meshtexuv 931 13 -13
meshvertex 932 91 73 -87
meshtexuv 932 13 -12
meshvertex 933 91 44 -87
meshtexuv 933 13 -12
meshvertex 934 92 73 -88
meshtexuv 934 13 -13
meshvertex 935 91 44 80
meshtexuv 935 13 11
meshvertex 936 92 73 81
meshtexuv 936 13 12
meshvertex 937 92 44 81
meshtexuv 937 13 12
meshvertex 938 91 73 80
meshtexuv 938 13 11
meshvertex 939 59 106 -60
meshtexuv 939 8 -9
meshvertex 940 57 106 30
meshtexuv 940 8 4
meshvertex 941 58 103 30
meshtexuv 941 8 4
meshvertex 942 60 109 -60
meshtexuv 942 9 -9
meshvertex 943 89 67 -64
meshtexuv 943 13 -9
meshvertex 944 90 69 65
meshtexuv 944 13 9
meshvertex 945 90 67 65
meshtexuv 945 13 9
meshvertex 946 89 69 -64
meshtexuv 946 13 -9
meshvertex 947 -53 15 -227
meshtexuv 947 -11 -45
meshvertex 948 -49 35 -213
meshtexuv 948 -10 -43
meshvertex 949 -49 15 -227
meshtexuv 949 -10 -45
meshvertex 950 -53 35 -213
meshtexuv 950 -11 -43
meshvertex 951 -19 15 -227
meshtexuv 951 -4 -45
meshvertex 952 -15 35 -213
meshtexuv 952 -3 -43
meshvertex 953 -15 15 -227
meshtexuv 953 -3 -45
meshvertex 954 -19 35 -213
meshtexuv 954 -4 -43
meshvertex 955 15 15 -227
meshtexuv 955 3 -45
meshvertex 956 19 35 -213
meshtexuv 956 4 -43
meshvertex 957 19 15 -227
meshtexuv 957 4 -45
meshvertex 958 15 35 -213
meshtexuv 958 3 -43
meshvertex 959 49 15 -227
meshtexuv 959 10 -45
meshvertex 960 53 35 -213
meshtexuv 960 11 -43
meshvertex 961 53 15 -227
meshtexuv 961 11 -45
meshvertex 962 49 35 -213
meshtexuv 962 10 -43
meshvertex 963 -70 44 -227
meshtexuv 963 -10 -32
meshvertex 964 68 48 -227
meshtexuv 964 10 -32
meshvertex 965 70 44 -227
meshtexuv 965 10 -32
meshvertex 966 -68 48 -227
meshtexuv 966 -10 -32
meshvertex 967 -70 46 -227
meshtexuv 967 -10 -32
meshvertex 968 -80 46 -227
meshtexuv 968 -11 -32
meshvertex 969 -80 49 -227
meshtexuv 969 -11 -32
meshvertex 970 -70 49 -227
meshtexuv 970 -10 -32
meshvertex 971 70 46 -227
meshtexuv 971 10 -32
meshvertex 972 80 49 -227
meshtexuv 972 11 -32
meshvertex 973 80 46 -227
meshtexuv 973 11 -32
meshvertex 974 70 49 -227
meshtexuv 974 10 -32
meshvertex 975 -85 72 -223
meshtexuv 975 -14 -37
meshvertex 976 -95 79 -181
meshtexuv 976 -16 -30
meshvertex 977 0 78 -181
meshtexuv 977 0 -30
meshvertex 978 0 69 -223
meshtexuv 978 0 -37
meshvertex 979 95 79 -181
meshtexuv 979 16 -30
meshvertex 980 85 72 -223
meshtexuv 980 14 -37
meshvertex 982 -95 34 -181
meshtexuv 982 -16 -30
meshvertex 984 -85 22 -223
meshtexuv 984 -14 -37
meshvertex 987 95 34 -181
meshtexuv 987 16 -30
meshvertex 988 85 22 -223
meshtexuv 988 14 -37
meshvertex 989 -96 79 -167
meshtexuv 989 -16 -28
meshvertex 990 0 78 -167
meshtexuv 990 0 -28
meshvertex 991 96 79 -167
meshtexuv 991 16 -28
meshvertex 992 -96 64 -167
meshtexuv 992 -16 -28
meshvertex 995 96 64 -167
meshtexuv 995 16 -28
meshvertex 996 -97 80 -142
meshtexuv 996 -16 -24
meshvertex 997 0 78 -142
meshtexuv 997 0 -24
meshvertex 998 97 80 -142
meshtexuv 998 16 -24
meshvertex 999 -97 73 -142
meshtexuv 999 -16 -24
meshvertex 1002 97 73 -142
meshtexuv 1002 16 -24
meshvertex 1003 -94 78 -117
meshtexuv 1003 -16 -19
meshvertex 1004 0 77 -117
meshtexuv 1004 0 -19
meshvertex 1005 94 78 -117
meshtexuv 1005 16 -19
meshvertex 1006 -94 64 -117
meshtexuv 1006 -16 -19
meshvertex 1009 94 64 -117
meshtexuv 1009 16 -19
meshvertex 1010 -92 77 -103
meshtexuv 1010 -15 -17
meshvertex 1011 0 77 -103
meshtexuv 1011 0 -17
meshvertex 1012 92 77 -103
meshtexuv 1012 15 -17
meshvertex 1013 -92 34 -103
meshtexuv 1013 -15 -17
meshvertex 1016 92 34 -103
meshtexuv 1016 15 -17
meshvertex 1017 -92 76 99
meshtexuv 1017 -15 17
meshvertex 1018 0 72 99
meshtexuv 1018 0 17
meshvertex 1019 92 76 99
meshtexuv 1019 15 17
meshvertex 1020 -92 34 99
meshtexuv 1020 -15 17
meshvertex 1023 92 34 99
meshtexuv 1023 15 17
meshvertex 1024 -93 76 113
meshtexuv 1024 -15 19
meshvertex 1025 0 71 113
meshtexuv 1025 0 19
meshvertex 1026 93 76 113
meshtexuv 1026 16 19
meshvertex 1027 -93 64 113
meshtexuv 1027 -15 19
meshvertex 1030 93 64 113
meshtexuv 1030 16 19
meshvertex 1031 -96 76 138
meshtexuv 1031 -16 23
meshvertex 1032 0 69 138
meshtexuv 1032 0 23
meshvertex 1033 96 76 138
meshtexuv 1033 16 23
meshvertex 1034 -96 73 138
meshtexuv 1034 -16 23
meshvertex 1037 96 73 138
meshtexuv 1037 16 23
meshvertex 1038 -93 72 163
meshtexuv 1038 -15 27
meshvertex 1039 0 66 163
meshtexuv 1039 0 27
meshvertex 1040 93 72 163
meshtexuv 1040 16 27
meshvertex 1041 -93 64 163
meshtexuv 1041 -15 27
meshvertex 1044 93 64 163
meshtexuv 1044 16 27
meshvertex 1045 -91 69 177
meshtexuv 1045 -15 30
meshvertex 1046 0 64 177
meshtexuv 1046 0 30
meshvertex 1047 91 69 177
meshtexuv 1047 15 30
meshvertex 1048 -91 34 177
meshtexuv 1048 -15 30
meshvertex 1051 91 34 177
meshtexuv 1051 15 30
meshvertex 1052 -72 48 223
meshtexuv 1052 -12 37
meshvertex 1053 0 46 223
meshtexuv 1053 0 37
meshvertex 1054 72 48 223
meshtexuv 1054 12 37
meshvertex 1055 -72 22 223
meshtexuv 1055 -12 37
meshvertex 1058 72 22 223
meshtexuv 1058 12 37
meshvertex 1059 0 32 -223
meshtexuv 1059 0 -37
meshvertex 1065 0 32 223
meshtexuv 1065 0 37
meshvertex 1068 -71 18 -204
meshtexuv 1068 -10 -29
meshvertex 1069 71 18 197
meshtexuv 1069 10 28
meshvertex 1070 -71 18 197
meshtexuv 1070 -10 28
meshvertex 1071 71 18 -204
meshtexuv 1071 10 -29
meshvertex 1072 -54 73 -150
meshtexuv 1072 -6 -17
meshvertex 1073 -60 106 -60
meshtexuv 1073 -7 -7
meshvertex 1074 0 113 -60
meshtexuv 1074 0 -7
meshvertex 1075 0 75 -150
meshtexuv 1075 0 -17
meshvertex 1076 60 106 -60
meshtexuv 1076 7 -7
meshvertex 1077 54 73 -150
meshtexuv 1077 6 -17
meshvertex 1078 -61 108 -10
meshtexuv 1078 -7 -1
meshvertex 1079 0 115 -10
meshtexuv 1079 0 -1
meshvertex 1080 61 108 -10
meshtexuv 1080 7 -1
meshvertex 1081 -54 101 48
meshtexuv 1081 -6 5
meshvertex 1082 0 108 48
meshtexuv 1082 0 5
meshvertex 1083 54 101 48
meshtexuv 1083 6 5
meshvertex 1084 -69 73 108
meshtexuv 1084 -8 12
meshvertex 1085 0 75 108
meshtexuv 1085 0 12
meshvertex 1086 69 73 108
meshtexuv 1086 8 12
meshvertex 1087 -78 79 -126
meshtexuv 1087 -9 -14
meshvertex 1088 -55 101 48
meshtexuv 1088 -6 5
meshvertex 1089 -61 104 -61
meshtexuv 1089 -7 -7
meshvertex 1090 -74 78 101
meshtexuv 1090 -8 11
meshvertex 1091 -81 77 -64
meshtexuv 1091 -9 -7
meshvertex 1092 -80 77 -141
meshtexuv 1092 -13 -23
meshvertex 1098 78 79 -126
meshtexuv 1098 9 -14
meshvertex 1099 61 104 -61
meshtexuv 1099 7 -7
meshvertex 1100 55 101 48
meshtexuv 1100 6 5
meshvertex 1101 74 78 101
meshtexuv 1101 8 11
meshvertex 1102 81 77 -64
meshtexuv 1102 9 -7
meshvertex 1103 80 77 -141
meshtexuv 1103 13 -23
meshvertex 1109 -76 34 -108
meshtexuv 1109 0 9
meshvertex 1110 -98 58 -118
meshtexuv 1110 6 6
meshvertex 1111 -98 34 -108
meshtexuv 1111 0 9
meshvertex 1112 -76 58 -118
meshtexuv 1112 6 6
meshvertex 1113 -98 68 -142
meshtexuv 1113 9 0
meshvertex 1114 -76 68 -142
meshtexuv 1114 9 0
meshvertex 1115 -98 58 -166
meshtexuv 1115 6 -6
meshvertex 1116 -76 58 -166
meshtexuv 1116 6 -6
meshvertex 1117 -98 34 -176
meshtexuv 1117 0 -8
meshvertex 1118 -76 34 -176
meshtexuv 1118 0 -8
meshvertex 1119 -98 10 -166
meshtexuv 1119 -6 -6
meshvertex 1120 -76 10 -166
meshtexuv 1120 -6 -6
meshvertex 1121 -98 0 -142
meshtexuv 1121 -8 0
meshvertex 1122 -76 0 -142
meshtexuv 1122 -8 0
meshvertex 1123 -98 10 -118
meshtexuv 1123 -6 6
meshvertex 1124 -76 10 -118
meshtexuv 1124 -6 6
meshvertex 1126 -100 50 -126
meshtexuv 1126 4 4
meshvertex 1127 -100 34 -120
meshtexuv 1127 0 6
meshvertex 1129 -100 56 -142
meshtexuv 1129 6 0
meshvertex 1131 -100 50 -158
meshtexuv 1131 4 -4
meshvertex 1133 -100 34 -164
meshtexuv 1133 0 -5
meshvertex 1135 -100 18 -158
meshtexuv 1135 -4 -4
meshvertex 1137 -100 12 -142
meshtexuv 1137 -5 0
meshvertex 1139 -100 18 -126
meshtexuv 1139 -4 4
meshvertex 1141 -100 34 -142
meshtexuv 1141 0 0
meshvertex 1159 76 34 -108
meshtexuv 1159 0 9
meshvertex 1160 98 34 -108
meshtexuv 1160 0 9
meshvertex 1161 98 58 -118
meshtexuv 1161 6 6
meshvertex 1162 76 58 -118
meshtexuv 1162 6 6
meshvertex 1163 98 68 -142
meshtexuv 1163 9 0
meshvertex 1164 76 68 -142
meshtexuv 1164 9 0
meshvertex 1165 98 58 -166
meshtexuv 1165 6 -6
meshvertex 1166 76 58 -166
meshtexuv 1166 6 -6
meshvertex 1167 98 34 -176
meshtexuv 1167 0 -8
meshvertex 1168 76 34 -176
meshtexuv 1168 0 -8
meshvertex 1169 98 10 -166
meshtexuv 1169 -6 -6
meshvertex 1170 76 10 -166
meshtexuv 1170 -6 -6
meshvertex 1171 98 0 -142
meshtexuv 1171 -8 0
meshvertex 1172 76 0 -142
meshtexuv 1172 -8 0
meshvertex 1173 98 10 -118
meshtexuv 1173 -6 6
meshvertex 1174 76 10 -118
meshtexuv 1174 -6 6
meshvertex 1176 100 34 -120
meshtexuv 1176 0 6
meshvertex 1177 100 50 -126
meshtexuv 1177 4 4
meshvertex 1179 100 56 -142
meshtexuv 1179 6 0
meshvertex 1181 100 50 -158
meshtexuv 1181 4 -4
meshvertex 1183 100 34 -164
meshtexuv 1183 0 -5
meshvertex 1185 100 18 -158
meshtexuv 1185 -4 -4
meshvertex 1187 100 12 -142
meshtexuv 1187 -5 0
meshvertex 1189 100 18 -126
meshtexuv 1189 -4 4
meshvertex 1191 100 34 -142
meshtexuv 1191 0 0
meshvertex 1209 -76 34 172
meshtexuv 1209 0 9
meshvertex 1210 -98 58 162
meshtexuv 1210 6 6
meshvertex 1211 -98 34 172
meshtexuv 1211 0 9
meshvertex 1212 -76 58 162
meshtexuv 1212 6 6
meshvertex 1213 -98 68 138
meshtexuv 1213 9 0
meshvertex 1214 -76 68 138
meshtexuv 1214 9 0
meshvertex 1215 -98 58 114
meshtexuv 1215 6 -6
meshvertex 1216 -76 58 114
meshtexuv 1216 6 -6
meshvertex 1217 -98 34 104
meshtexuv 1217 0 -8
meshvertex 1218 -76 34 104
meshtexuv 1218 0 -8
meshvertex 1219 -98 10 114
meshtexuv 1219 -6 -6
meshvertex 1220 -76 10 114
meshtexuv 1220 -6 -6
meshvertex 1221 -98 0 138
meshtexuv 1221 -8 0
meshvertex 1222 -76 0 138
meshtexuv 1222 -8 0
meshvertex 1223 -98 10 162
meshtexuv 1223 -6 6
meshvertex 1224 -76 10 162
meshtexuv 1224 -6 6
meshvertex 1226 -100 50 154
meshtexuv 1226 4 4
meshvertex 1227 -100 34 160
meshtexuv 1227 0 6
meshvertex 1229 -100 56 138
meshtexuv 1229 6 0
meshvertex 1231 -100 50 122
meshtexuv 1231 4 -4
meshvertex 1233 -100 34 116
meshtexuv 1233 0 -5
meshvertex 1235 -100 18 122
meshtexuv 1235 -4 -4
meshvertex 1237 -100 12 138
meshtexuv 1237 -5 0
meshvertex 1239 -100 18 154
meshtexuv 1239 -4 4
meshvertex 1241 -100 34 138
meshtexuv 1241 0 0
meshvertex 1259 76 34 172
meshtexuv 1259 0 9
meshvertex 1260 98 34 172
meshtexuv 1260 0 9
meshvertex 1261 98 58 162
meshtexuv 1261 6 6
meshvertex 1262 76 58 162
meshtexuv 1262 6 6
meshvertex 1263 98 68 138
meshtexuv 1263 9 0
meshvertex 1264 76 68 138
meshtexuv 1264 9 0
meshvertex 1265 98 58 114
meshtexuv 1265 6 -6
meshvertex 1266 76 58 114
meshtexuv 1266 6 -6
meshvertex 1267 98 34 104
meshtexuv 1267 0 -8
meshvertex 1268 76 34 104
meshtexuv 1268 0 -8
meshvertex 1269 98 10 114
meshtexuv 1269 -6 -6
meshvertex 1270 76 10 114
meshtexuv 1270 -6 -6
meshvertex 1271 98 0 138
meshtexuv 1271 -8 0
meshvertex 1272 76 0 138
meshtexuv 1272 -8 0
meshvertex 1273 98 10 162
meshtexuv 1273 -6 6
meshvertex 1274 76 10 162
meshtexuv 1274 -6 6
meshvertex 1276 100 34 160
meshtexuv 1276 0 6
meshvertex 1277 100 50 154
meshtexuv 1277 4 4
meshvertex 1279 100 56 138
meshtexuv 1279 6 0
meshvertex 1281 100 50 122
meshtexuv 1281 4 -4
meshvertex 1283 100 34 116
meshtexuv 1283 0 -5
meshvertex 1285 100 18 122
meshtexuv 1285 -4 -4
meshvertex 1287 100 12 138
meshtexuv 1287 -5 0
meshvertex 1289 100 18 154
meshtexuv 1289 -4 4
meshvertex 1291 100 34 138
meshtexuv 1291 0 0
meshvertex 1309 -94 36 -91
meshtexuv 1309 -13 -13
meshvertex 1310 -88 57 -55
meshtexuv 1310 -13 -8
meshvertex 1311 -91 60 -90
meshtexuv 1311 -13 -13
meshvertex 1312 94 36 -91
meshtexuv 1312 13 -13
meshvertex 1313 91 60 -90
meshtexuv 1313 13 -13
meshvertex 1314 88 57 -55
meshtexuv 1314 13 -8
meshvertex 1315 -80 50 226
meshtexuv 1315 -11 32
meshvertex 1316 80 50 226
meshtexuv 1316 11 32
meshvertex 1317 80 53 225
meshtexuv 1317 11 32
meshvertex 1318 -80 53 225
meshtexuv 1318 -11 32
meshvertex 1319 -81 63 -227
meshtexuv 1319 -12 -32
meshvertex 1320 81 67 -226
meshtexuv 1320 12 -32
meshvertex 1321 81 63 -227
meshtexuv 1321 12 -32
meshvertex 1322 -81 67 -226
meshtexuv 1322 -12 -32
meshvertex 1323 -84 39 -227
meshtexuv 1323 -17 -45
meshvertex 1324 80 57 -225
meshtexuv 1324 16 -45
meshvertex 1325 84 39 -227
meshtexuv 1325 17 -45
meshvertex 1326 -80 57 -225
meshtexuv 1326 -16 -45
meshvertex 1327 -51 24 225
meshtexuv 1327 -7 32
meshvertex 1328 51 24 225
meshtexuv 1328 7 32
meshvertex 1329 57 43 225
meshtexuv 1329 8 32
meshvertex 1330 -57 43 225
meshtexuv 1330 -8 32
meshvertex 1331 -73 15 -225
meshtexuv 1331 -10 -32
meshvertex 1332 67 39 -225
meshtexuv 1332 10 -32
meshvertex 1333 73 15 -225
meshtexuv 1333 10 -32
meshvertex 1334 -67 39 -225
meshtexuv 1334 -10 -32
meshvertex 1335 -93 29 -103
meshtexuv 1335 -19 -21
meshvertex 1336 -86 29 0
meshtexuv 1336 -17 0
meshvertex 1337 -86 43 0
meshtexuv 1337 -17 0
meshvertex 1338 -93 43 -103
meshtexuv 1338 -19 -21
meshvertex 1339 -93 29 99
meshtexuv 1339 -19 20
meshvertex 1340 -93 43 99
meshtexuv 1340 -19 20
meshvertex 1341 93 29 -103
meshtexuv 1341 19 -21
meshvertex 1342 86 43 0
meshtexuv 1342 17 0
meshvertex 1343 86 29 0
meshtexuv 1343 17 0
meshvertex 1344 93 43 -103
meshtexuv 1344 19 -21
meshvertex 1345 93 43 99
meshtexuv 1345 19 20
meshvertex 1346 93 29 99
meshtexuv 1346 19 20
meshvertex 1347 -85 72 -223
meshtexuv 1347 -14 -37
meshvertex 1348 -97 80 -142
meshtexuv 1348 -16 -24
meshvertex 1349 0 78 -142
meshtexuv 1349 0 -24
meshvertex 1350 0 69 -223
meshtexuv 1350 0 -37
meshvertex 1351 97 80 -142
meshtexuv 1351 16 -24
meshvertex 1352 85 72 -223
meshtexuv 1352 14 -37
meshvertex 1354 -97 22 -142
meshtexuv 1354 -16 -24
meshvertex 1356 -85 22 -223
meshtexuv 1356 -14 -37
meshvertex 1359 97 22 -142
meshtexuv 1359 16 -24
meshvertex 1360 85 22 -223
meshtexuv 1360 14 -37
meshvertex 1361 -87 75 -65
meshtexuv 1361 -14 -11
meshvertex 1362 0 76 -65
meshtexuv 1362 0 -11
meshvertex 1363 87 75 -65
meshtexuv 1363 15 -11
meshvertex 1364 -87 22 -65
meshtexuv 1364 -14 -11
meshvertex 1367 87 22 -65
meshtexuv 1367 15 -11
meshvertex 1368 -88 74 65
meshtexuv 1368 -15 11
meshvertex 1369 0 75 65
meshtexuv 1369 0 11
meshvertex 1370 88 74 65
meshtexuv 1370 15 11
meshvertex 1371 -88 22 65
meshtexuv 1371 -15 11
meshvertex 1374 88 22 65
meshtexuv 1374 15 11
meshvertex 1375 -96 76 138
meshtexuv 1375 -16 23
meshvertex 1376 0 69 138
meshtexuv 1376 0 23
meshvertex 1377 96 76 138
meshtexuv 1377 16 23
meshvertex 1378 -96 22 138
meshtexuv 1378 -16 23
meshvertex 1381 96 22 138
meshtexuv 1381 16 23
meshvertex 1382 -72 48 223
meshtexuv 1382 -12 37
meshvertex 1383 0 46 223
meshtexuv 1383 0 37
meshvertex 1384 72 48 223
meshtexuv 1384 12 37
meshvertex 1385 -72 22 223
meshtexuv 1385 -12 37
meshvertex 1388 72 22 223
meshtexuv 1388 12 37
meshvertex 1395 -71 18 -204
meshtexuv 1395 -10 -29
meshvertex 1396 71 18 197
meshtexuv 1396 10 28
meshvertex 1397 -71 18 197
meshtexuv 1397 -10 28
meshvertex 1398 71 18 -204
meshtexuv 1398 10 -29
meshvertex 1399 -54 74 -145
meshtexuv 1399 -6 -16
meshvertex 1400 -60 106 -55
meshtexuv 1400 -7 -6
meshvertex 1401 0 113 -55
meshtexuv 1401 0 -6
meshvertex 1402 0 77 -145
meshtexuv 1402 0 -16
meshvertex 1403 60 106 -55
meshtexuv 1403 7 -6
meshvertex 1404 54 74 -145
meshtexuv 1404 6 -16
meshvertex 1405 -57 107 30
meshtexuv 1405 -6 3
meshvertex 1406 0 115 30
meshtexuv 1406 0 3
meshvertex 1407 57 107 30
meshtexuv 1407 6 3
meshvertex 1408 -69 73 108
meshtexuv 1408 -8 12
meshvertex 1409 0 75 108
meshtexuv 1409 0 12
meshvertex 1410 69 73 108
meshtexuv 1410 8 12
meshvertex 1411 -78 79 -126
meshtexuv 1411 -9 -14
meshvertex 1412 -55 101 48
meshtexuv 1412 -6 5
meshvertex 1413 -60 107 -15
meshtexuv 1413 -7 -2
meshvertex 1414 -74 78 101
meshtexuv 1414 -8 11
meshvertex 1415 78 79 -126
meshtexuv 1415 9 -14
meshvertex 1416 60 107 -15
meshtexuv 1416 7 -2
meshvertex 1417 55 101 48
meshtexuv 1417 6 5
meshvertex 1418 74 78 101
meshtexuv 1418 8 11
meshvertex 1419 -78 34 -108
meshtexuv 1419 0 9
meshvertex 1420 -100 68 -142
meshtexuv 1420 9 0
meshvertex 1421 -100 34 -108
meshtexuv 1421 0 9
meshvertex 1422 -78 68 -142
meshtexuv 1422 9 0
meshvertex 1424 -100 34 -176
meshtexuv 1424 0 -8
meshvertex 1426 -78 34 -176
meshtexuv 1426 0 -8
meshvertex 1428 -100 0 -142
meshtexuv 1428 -8 0
meshvertex 1430 -78 0 -142
meshtexuv 1430 -8 0
meshvertex 1439 78 34 -108
meshtexuv 1439 0 9
meshvertex 1440 100 34 -108
meshtexuv 1440 0 9
meshvertex 1441 100 68 -142
meshtexuv 1441 9 0
meshvertex 1442 78 68 -142
meshtexuv 1442 9 0
meshvertex 1445 100 34 -176
meshtexuv 1445 0 -8
meshvertex 1446 78 34 -176
meshtexuv 1446 0 -8
meshvertex 1449 100 0 -142
meshtexuv 1449 -8 0
meshvertex 1450 78 0 -142
meshtexuv 1450 -8 0
meshvertex 1459 -78 34 172
meshtexuv 1459 0 9
meshvertex 1460 -100 68 138
meshtexuv 1460 9 0
meshvertex 1461 -100 34 172
meshtexuv 1461 0 9
meshvertex 1462 -78 68 138
meshtexuv 1462 9 0
meshvertex 1464 -100 34 104
meshtexuv 1464 0 -8
meshvertex 1466 -78 34 104
meshtexuv 1466 0 -8
meshvertex 1468 -100 0 138
meshtexuv 1468 -8 0
meshvertex 1470 -78 0 138
meshtexuv 1470 -8 0
meshvertex 1479 78 34 172
meshtexuv 1479 0 9
meshvertex 1480 100 34 172
meshtexuv 1480 0 9
meshvertex 1481 100 68 138
meshtexuv 1481 9 0
meshvertex 1482 78 68 138
meshtexuv 1482 9 0
meshvertex 1485 100 34 104
meshtexuv 1485 0 -8
meshvertex 1486 78 34 104
meshtexuv 1486 0 -8
meshvertex 1489 100 0 138
meshtexuv 1489 -8 0
meshvertex 1490 78 0 138
meshtexuv 1490 -8 0
meshvertex 1499 -80 50 226
meshtexuv 1499 -11 32
meshvertex 1500 80 50 226
meshtexuv 1500 11 32
meshvertex 1501 80 53 225
meshtexuv 1501 11 32
meshvertex 1502 -80 53 225
meshtexuv 1502 -11 32
meshvertex 1503 -81 63 -227
meshtexuv 1503 -12 -32
meshvertex 1504 81 67 -226
meshtexuv 1504 12 -32
meshvertex 1505 81 63 -227
meshtexuv 1505 12 -32
meshvertex 1506 -81 67 -226
meshtexuv 1506 -12 -32
meshvertex 1507 -84 39 -227
meshtexuv 1507 -17 -45
meshvertex 1508 80 57 -225
meshtexuv 1508 16 -45
meshvertex 1509 84 39 -227
meshtexuv 1509 17 -45
meshvertex 1510 -80 57 -225
meshtexuv 1510 -16 -45
meshvertex 1511 12 4 12
meshtexuv 1511 2 2
meshvertex 1512 123 3 12
meshtexuv 1512 18 2
meshvertex 1513 90 3 181
meshtexuv 1513 13 26
meshvertex 1514 12 3 251
meshtexuv 1514 2 36
meshvertex 1515 -66 3 181
meshtexuv 1515 -9 26
meshvertex 1516 -99 3 12
meshtexuv 1516 -14 2
meshvertex 1517 -66 3 -157
meshtexuv 1517 -9 -22
meshvertex 1518 12 3 -227
meshtexuv 1518 2 -32
meshvertex 1519 90 3 -157
meshtexuv 1519 13 -22
meshvertex 1520 155 2 12
meshtexuv 1520 22 2
meshvertex 1521 113 2 201
meshtexuv 1521 16 29
meshvertex 1522 12 2 279
meshtexuv 1522 2 40
meshvertex 1523 -89 2 201
meshtexuv 1523 -13 29
meshvertex 1524 -131 2 12
meshtexuv 1524 -19 2
meshvertex 1525 -89 2 -177
meshtexuv 1525 -13 -25
meshvertex 1526 12 2 -255
meshtexuv 1526 2 -36
meshvertex 1527 113 2 -177
meshtexuv 1527 16 -25
meshvertex 1528 0 820 0
meshtexuv 1528 0 0
meshvertex 1529 215 200 0
meshtexuv 1529 31 0
meshvertex 1530 108 200 186
meshtexuv 1530 15 27
meshvertex 1531 -107 200 186
meshtexuv 1531 -15 27
meshvertex 1532 -215 200 0
meshtexuv 1532 -31 0
meshvertex 1533 -108 200 -186
meshtexuv 1533 -15 -27
meshvertex 1534 108 200 -186
meshtexuv 1534 15 -27
meshvertex 1535 -20 0 0
meshtexuv 1535 -3 0
meshvertex 1536 20 0 0
meshtexuv 1536 3 0
meshvertex 1537 20 280 0
meshtexuv 1537 3 0
meshvertex 1538 -20 280 0
meshtexuv 1538 -3 0
meshvertex 1539 0 0 -20
meshtexuv 1539 0 -3
meshvertex 1540 0 0 20
meshtexuv 1540 0 3
meshvertex 1541 0 280 20
meshtexuv 1541 0 3
meshvertex 1542 0 280 -20
meshtexuv 1542 0 -3
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
jge sin_negative_24
add r3 4096
label sin_negative_24
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
jlt sin_done_25
mul r1 -1
label sin_done_25
mov r3 r1
mov r2 r3
mov r9 r2
add r9 32768
localset 58 r9
mov r4 r6
add r4 1024
mod r4 4096
cmp r4 0
jge sin_negative_26
add r4 4096
label sin_negative_26
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
jlt sin_done_27
mul r1 -1
label sin_done_27
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
jge sin_negative_28
add r3 4096
label sin_negative_28
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
jlt sin_done_29
mul r5 -1
label sin_done_29
mov r3 r5
mov r6 r3
mov r9 r6
add r9 32768
localset 58 r9
mov r4 r8
add r4 1024
mod r4 4096
cmp r4 0
jge sin_negative_30
add r4 4096
label sin_negative_30
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
jlt sin_done_31
mul r5 -1
label sin_done_31
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
jge norm_component_36
mul r10 -1
label norm_component_36
add r9 r10
mov r10 r6
cmp r10 0
jge norm_component_37
mul r10 -1
label norm_component_37
add r9 r10
mov r10 r7
cmp r10 0
jge norm_component_38
mul r10 -1
label norm_component_38
add r9 r10
cmp r9 0
jgt norm_nonzero_35
set r9 1
label norm_nonzero_35
label norm_sqrt_33
mov r10 r8
div r10 r9
add r10 r9
div r10 2
cmp r10 r9
jge norm_done_34
mov r9 r10
cmp r9 0
jgt norm_sqrt_33
set r9 1
label norm_done_34
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
jge norm_component_43
mul r10 -1
label norm_component_43
add r9 r10
mov r10 r6
cmp r10 0
jge norm_component_44
mul r10 -1
label norm_component_44
add r9 r10
mov r10 r7
cmp r10 0
jge norm_component_45
mul r10 -1
label norm_component_45
add r9 r10
cmp r9 0
jgt norm_nonzero_42
set r9 1
label norm_nonzero_42
label norm_sqrt_40
mov r10 r8
div r10 r9
add r10 r9
div r10 2
cmp r10 r9
jge norm_done_41
mov r9 r10
cmp r9 0
jgt norm_sqrt_40
set r9 1
label norm_done_41
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
jge diffuse_positive_48
set r0 0
label diffuse_positive_48
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
jge highlight_positive_49
set r1 0
label highlight_positive_49
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
jle intensity_bounded_50
set r0 255
label intensity_bounded_50
localset 2400 r0
label body_lighting_done_46
localget r3 3030
cmp r3 0
jne body_lighting_done_51
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
jge diffuse_positive_53
set r0 0
label diffuse_positive_53
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
jge highlight_positive_54
set r1 0
label highlight_positive_54
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
jle intensity_bounded_55
set r0 255
label intensity_bounded_55
localset 2401 r0
label body_lighting_done_51
localget r3 3030
cmp r3 0
jne body_lighting_done_56
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
jge diffuse_positive_58
set r0 0
label diffuse_positive_58
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
jge highlight_positive_59
set r1 0
label highlight_positive_59
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
jle intensity_bounded_60
set r0 255
label intensity_bounded_60
localset 2402 r0
label body_lighting_done_56
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
jge glass_low_61
set r0 0
label glass_low_61
cmp r0 255
jle glass_high_62
set r0 255
label glass_high_62
localset 2602 r0
label glass_lighting_done_57
localget r3 3030
cmp r3 0
jne body_lighting_done_63
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
jge diffuse_positive_65
set r0 0
label diffuse_positive_65
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
jge highlight_positive_66
set r1 0
label highlight_positive_66
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
jle intensity_bounded_67
set r0 255
label intensity_bounded_67
localset 2403 r0
label body_lighting_done_63
localget r3 3030
cmp r3 0
jne glass_lighting_done_64
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
jge glass_low_68
set r0 0
label glass_low_68
cmp r0 255
jle glass_high_69
set r0 255
label glass_high_69
localset 2603 r0
label glass_lighting_done_64
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
jge diffuse_positive_72
set r0 0
label diffuse_positive_72
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
jge highlight_positive_73
set r1 0
label highlight_positive_73
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
jle intensity_bounded_74
set r0 255
label intensity_bounded_74
localset 2404 r0
label body_lighting_done_70
localget r3 3030
cmp r3 0
jne body_lighting_done_75
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
jge diffuse_positive_77
set r0 0
label diffuse_positive_77
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
jge highlight_positive_78
set r1 0
label highlight_positive_78
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
jle intensity_bounded_79
set r0 255
label intensity_bounded_79
localset 2405 r0
label body_lighting_done_75
localget r3 3030
cmp r3 2
je body_lighting_done_80
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
jge diffuse_positive_82
set r0 0
label diffuse_positive_82
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
jge highlight_positive_83
set r1 0
label highlight_positive_83
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
jle intensity_bounded_84
set r0 255
label intensity_bounded_84
localset 2406 r0
label body_lighting_done_80
localget r3 3030
cmp r3 2
je body_lighting_done_85
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
jge diffuse_positive_87
set r0 0
label diffuse_positive_87
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
jge highlight_positive_88
set r1 0
label highlight_positive_88
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
jle intensity_bounded_89
set r0 255
label intensity_bounded_89
localset 2407 r0
label body_lighting_done_85
localget r3 3030
cmp r3 0
jne body_lighting_done_90
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
jge diffuse_positive_92
set r0 0
label diffuse_positive_92
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
jge highlight_positive_93
set r1 0
label highlight_positive_93
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
jle intensity_bounded_94
set r0 255
label intensity_bounded_94
localset 2408 r0
label body_lighting_done_90
localget r3 3030
cmp r3 0
jne body_lighting_done_95
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
jge diffuse_positive_97
set r0 0
label diffuse_positive_97
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
jge highlight_positive_98
set r1 0
label highlight_positive_98
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
jle intensity_bounded_99
set r0 255
label intensity_bounded_99
localset 2409 r0
label body_lighting_done_95
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
jge diffuse_positive_102
set r0 0
label diffuse_positive_102
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
jge highlight_positive_103
set r1 0
label highlight_positive_103
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
jle intensity_bounded_104
set r0 255
label intensity_bounded_104
localset 2410 r0
label body_lighting_done_100
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
jge glass_low_105
set r0 0
label glass_low_105
cmp r0 255
jle glass_high_106
set r0 255
label glass_high_106
localset 2610 r0
label glass_lighting_done_101
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
jge diffuse_positive_109
set r0 0
label diffuse_positive_109
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
jge highlight_positive_110
set r1 0
label highlight_positive_110
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
jle intensity_bounded_111
set r0 255
label intensity_bounded_111
localset 2411 r0
label body_lighting_done_107
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
jge diffuse_positive_114
set r0 0
label diffuse_positive_114
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
jge highlight_positive_115
set r1 0
label highlight_positive_115
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
jle intensity_bounded_116
set r0 255
label intensity_bounded_116
localset 2412 r0
label body_lighting_done_112
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
jge glass_low_117
set r0 0
label glass_low_117
cmp r0 255
jle glass_high_118
set r0 255
label glass_high_118
localset 2612 r0
label glass_lighting_done_113
localget r3 3030
cmp r3 0
jne body_lighting_done_119
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
jge diffuse_positive_121
set r0 0
label diffuse_positive_121
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
jge highlight_positive_122
set r1 0
label highlight_positive_122
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
jle intensity_bounded_123
set r0 255
label intensity_bounded_123
localset 2413 r0
label body_lighting_done_119
localget r3 3030
cmp r3 2
je glass_lighting_done_120
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
jge glass_low_124
set r0 0
label glass_low_124
cmp r0 255
jle glass_high_125
set r0 255
label glass_high_125
localset 2613 r0
label glass_lighting_done_120
localget r3 3030
cmp r3 0
jne body_lighting_done_126
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
jge diffuse_positive_128
set r0 0
label diffuse_positive_128
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
jge highlight_positive_129
set r1 0
label highlight_positive_129
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
jle intensity_bounded_130
set r0 255
label intensity_bounded_130
localset 2414 r0
label body_lighting_done_126
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
jge glass_low_131
set r0 0
label glass_low_131
cmp r0 255
jle glass_high_132
set r0 255
label glass_high_132
localset 2614 r0
label glass_lighting_done_127
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
jge diffuse_positive_135
set r0 0
label diffuse_positive_135
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
jge highlight_positive_136
set r1 0
label highlight_positive_136
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
jle intensity_bounded_137
set r0 255
label intensity_bounded_137
localset 2415 r0
label body_lighting_done_133
localget r3 3030
cmp r3 2
je body_lighting_done_138
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
jge diffuse_positive_140
set r0 0
label diffuse_positive_140
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
jge highlight_positive_141
set r1 0
label highlight_positive_141
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
jle intensity_bounded_142
set r0 255
label intensity_bounded_142
localset 2416 r0
label body_lighting_done_138
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
jge glass_low_143
set r0 0
label glass_low_143
cmp r0 255
jle glass_high_144
set r0 255
label glass_high_144
localset 2616 r0
label glass_lighting_done_139
localget r3 3030
cmp r3 2
je body_lighting_done_145
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
jge diffuse_positive_147
set r0 0
label diffuse_positive_147
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
jge highlight_positive_148
set r1 0
label highlight_positive_148
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
jle intensity_bounded_149
set r0 255
label intensity_bounded_149
localset 2417 r0
label body_lighting_done_145
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
jge glass_low_150
set r0 0
label glass_low_150
cmp r0 255
jle glass_high_151
set r0 255
label glass_high_151
localset 2617 r0
label glass_lighting_done_146
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
jge diffuse_positive_154
set r0 0
label diffuse_positive_154
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
jge highlight_positive_155
set r1 0
label highlight_positive_155
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
jle intensity_bounded_156
set r0 255
label intensity_bounded_156
localset 2418 r0
label body_lighting_done_152
localget r3 3030
cmp r3 0
jne body_lighting_done_157
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
jge diffuse_positive_159
set r0 0
label diffuse_positive_159
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
jge highlight_positive_160
set r1 0
label highlight_positive_160
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
jle intensity_bounded_161
set r0 255
label intensity_bounded_161
localset 2419 r0
label body_lighting_done_157
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
jge glass_low_162
set r0 0
label glass_low_162
cmp r0 255
jle glass_high_163
set r0 255
label glass_high_163
localset 2619 r0
label glass_lighting_done_158
localget r3 3030
cmp r3 0
jne body_lighting_done_164
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
jge diffuse_positive_166
set r0 0
label diffuse_positive_166
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
jge highlight_positive_167
set r1 0
label highlight_positive_167
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
jle intensity_bounded_168
set r0 255
label intensity_bounded_168
localset 2420 r0
label body_lighting_done_164
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
jge glass_low_169
set r0 0
label glass_low_169
cmp r0 255
jle glass_high_170
set r0 255
label glass_high_170
localset 2620 r0
label glass_lighting_done_165
localget r3 3030
cmp r3 0
jne body_lighting_done_171
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
jge diffuse_positive_173
set r0 0
label diffuse_positive_173
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
jge highlight_positive_174
set r1 0
label highlight_positive_174
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
jle intensity_bounded_175
set r0 255
label intensity_bounded_175
localset 2421 r0
label body_lighting_done_171
localget r3 3030
cmp r3 0
jne body_lighting_done_176
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
jge diffuse_positive_178
set r0 0
label diffuse_positive_178
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
jge highlight_positive_179
set r1 0
label highlight_positive_179
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
jle intensity_bounded_180
set r0 255
label intensity_bounded_180
localset 2422 r0
label body_lighting_done_176
localget r3 3030
cmp r3 0
jne body_lighting_done_181
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
jge diffuse_positive_183
set r0 0
label diffuse_positive_183
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
jge highlight_positive_184
set r1 0
label highlight_positive_184
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
jle intensity_bounded_185
set r0 255
label intensity_bounded_185
localset 2423 r0
label body_lighting_done_181
localget r3 3030
cmp r3 0
jne body_lighting_done_186
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
jge diffuse_positive_188
set r0 0
label diffuse_positive_188
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
jge highlight_positive_189
set r1 0
label highlight_positive_189
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
jle intensity_bounded_190
set r0 255
label intensity_bounded_190
localset 2424 r0
label body_lighting_done_186
localget r3 3030
cmp r3 0
jne body_lighting_done_191
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
jge diffuse_positive_193
set r0 0
label diffuse_positive_193
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
jge highlight_positive_194
set r1 0
label highlight_positive_194
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
jle intensity_bounded_195
set r0 255
label intensity_bounded_195
localset 2425 r0
label body_lighting_done_191
localget r3 3030
cmp r3 0
jne body_lighting_done_196
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
jge diffuse_positive_198
set r0 0
label diffuse_positive_198
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
jge highlight_positive_199
set r1 0
label highlight_positive_199
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
jle intensity_bounded_200
set r0 255
label intensity_bounded_200
localset 2426 r0
label body_lighting_done_196
localget r3 3030
cmp r3 0
jne glass_lighting_done_197
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
jge glass_low_201
set r0 0
label glass_low_201
cmp r0 255
jle glass_high_202
set r0 255
label glass_high_202
localset 2626 r0
label glass_lighting_done_197
localget r3 3030
cmp r3 0
jne body_lighting_done_203
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
jge diffuse_positive_205
set r0 0
label diffuse_positive_205
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
jge highlight_positive_206
set r1 0
label highlight_positive_206
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
jle intensity_bounded_207
set r0 255
label intensity_bounded_207
localset 2427 r0
label body_lighting_done_203
localget r3 3030
cmp r3 0
jne glass_lighting_done_204
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
jge glass_low_208
set r0 0
label glass_low_208
cmp r0 255
jle glass_high_209
set r0 255
label glass_high_209
localset 2627 r0
label glass_lighting_done_204
localget r3 3030
cmp r3 0
jne body_lighting_done_210
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
jge diffuse_positive_212
set r0 0
label diffuse_positive_212
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
jge highlight_positive_213
set r1 0
label highlight_positive_213
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
jle intensity_bounded_214
set r0 255
label intensity_bounded_214
localset 2428 r0
label body_lighting_done_210
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
jge glass_low_215
set r0 0
label glass_low_215
cmp r0 255
jle glass_high_216
set r0 255
label glass_high_216
localset 2628 r0
label glass_lighting_done_211
localget r3 3030
cmp r3 0
jne body_lighting_done_217
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
jge diffuse_positive_219
set r0 0
label diffuse_positive_219
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
jge highlight_positive_220
set r1 0
label highlight_positive_220
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
jle intensity_bounded_221
set r0 255
label intensity_bounded_221
localset 2429 r0
label body_lighting_done_217
localget r3 3030
cmp r3 1
je body_lighting_done_222
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
jge diffuse_positive_224
set r0 0
label diffuse_positive_224
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
jge highlight_positive_225
set r1 0
label highlight_positive_225
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
jle intensity_bounded_226
set r0 255
label intensity_bounded_226
localset 2430 r0
label body_lighting_done_222
localget r3 3030
cmp r3 2
je glass_lighting_done_223
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
jge glass_low_227
set r0 0
label glass_low_227
cmp r0 255
jle glass_high_228
set r0 255
label glass_high_228
localset 2630 r0
label glass_lighting_done_223
localget r3 3030
cmp r3 2
je body_lighting_done_229
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
jge diffuse_positive_231
set r0 0
label diffuse_positive_231
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
localset 2431 r0
label body_lighting_done_229
localget r3 3030
cmp r3 2
je body_lighting_done_234
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
jge diffuse_positive_236
set r0 0
label diffuse_positive_236
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
localset 2432 r0
label body_lighting_done_234
localget r3 3030
cmp r3 2
je body_lighting_done_239
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
jge diffuse_positive_241
set r0 0
label diffuse_positive_241
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
localset 2433 r0
label body_lighting_done_239
localget r3 3030
cmp r3 0
jne body_lighting_done_244
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
jge diffuse_positive_246
set r0 0
label diffuse_positive_246
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
localset 2434 r0
label body_lighting_done_244
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
jge diffuse_positive_251
set r0 0
label diffuse_positive_251
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
localset 2435 r0
label body_lighting_done_249
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
jge diffuse_positive_256
set r0 0
label diffuse_positive_256
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
localset 2436 r0
label body_lighting_done_254
localget r3 3030
cmp r3 2
je body_lighting_done_259
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
jge diffuse_positive_261
set r0 0
label diffuse_positive_261
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
jge highlight_positive_262
set r1 0
label highlight_positive_262
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
jle intensity_bounded_263
set r0 255
label intensity_bounded_263
localset 2437 r0
label body_lighting_done_259
localget r3 3030
cmp r3 0
jne body_lighting_done_264
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
jge diffuse_positive_266
set r0 0
label diffuse_positive_266
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
jge highlight_positive_267
set r1 0
label highlight_positive_267
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
jle intensity_bounded_268
set r0 255
label intensity_bounded_268
localset 2438 r0
label body_lighting_done_264
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
jge glass_low_269
set r0 0
label glass_low_269
cmp r0 255
jle glass_high_270
set r0 255
label glass_high_270
localset 2638 r0
label glass_lighting_done_265
localget r3 3030
cmp r3 0
jne glass_lighting_done_272
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
jge glass_low_273
set r0 0
label glass_low_273
cmp r0 255
jle glass_high_274
set r0 255
label glass_high_274
localset 2639 r0
label glass_lighting_done_272
localget r3 3030
cmp r3 2
je glass_lighting_done_276
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
jge glass_low_277
set r0 0
label glass_low_277
cmp r0 255
jle glass_high_278
set r0 255
label glass_high_278
localset 2640 r0
label glass_lighting_done_276
localget r3 3030
cmp r3 2
je body_lighting_done_279
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
jge diffuse_positive_281
set r0 0
label diffuse_positive_281
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
jge highlight_positive_282
set r1 0
label highlight_positive_282
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
jle intensity_bounded_283
set r0 255
label intensity_bounded_283
localset 2441 r0
label body_lighting_done_279
localget r3 3030
cmp r3 2
je body_lighting_done_284
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
jge diffuse_positive_286
set r0 0
label diffuse_positive_286
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
jge highlight_positive_287
set r1 0
label highlight_positive_287
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
jle intensity_bounded_288
set r0 255
label intensity_bounded_288
localset 2442 r0
label body_lighting_done_284
localget r3 3030
cmp r3 1
je body_lighting_done_289
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
jge diffuse_positive_291
set r0 0
label diffuse_positive_291
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
jge highlight_positive_292
set r1 0
label highlight_positive_292
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
jle intensity_bounded_293
set r0 255
label intensity_bounded_293
localset 2443 r0
label body_lighting_done_289
localget r3 3030
cmp r3 0
jne body_lighting_done_294
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
jge diffuse_positive_296
set r0 0
label diffuse_positive_296
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
jge highlight_positive_297
set r1 0
label highlight_positive_297
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
jle intensity_bounded_298
set r0 255
label intensity_bounded_298
localset 2444 r0
label body_lighting_done_294
localget r3 3030
cmp r3 0
jne body_lighting_done_299
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
jge diffuse_positive_301
set r0 0
label diffuse_positive_301
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
jge highlight_positive_302
set r1 0
label highlight_positive_302
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
jle intensity_bounded_303
set r0 255
label intensity_bounded_303
localset 2445 r0
label body_lighting_done_299
localget r3 3030
cmp r3 0
jne body_lighting_done_304
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
jge diffuse_positive_306
set r0 0
label diffuse_positive_306
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
jge highlight_positive_307
set r1 0
label highlight_positive_307
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
jle intensity_bounded_308
set r0 255
label intensity_bounded_308
localset 2446 r0
label body_lighting_done_304
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
jge diffuse_positive_311
set r0 0
label diffuse_positive_311
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
jge highlight_positive_312
set r1 0
label highlight_positive_312
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
jle intensity_bounded_313
set r0 255
label intensity_bounded_313
localset 2447 r0
label body_lighting_done_309
localget r3 3030
cmp r3 0
jne body_lighting_done_314
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
jge diffuse_positive_316
set r0 0
label diffuse_positive_316
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
jge highlight_positive_317
set r1 0
label highlight_positive_317
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
jle intensity_bounded_318
set r0 255
label intensity_bounded_318
localset 2448 r0
label body_lighting_done_314
localget r3 3030
cmp r3 0
jne body_lighting_done_319
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
jge diffuse_positive_321
set r0 0
label diffuse_positive_321
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
jge highlight_positive_322
set r1 0
label highlight_positive_322
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
jle intensity_bounded_323
set r0 255
label intensity_bounded_323
localset 2449 r0
label body_lighting_done_319
localget r3 3030
cmp r3 0
jne body_lighting_done_324
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
jge diffuse_positive_326
set r0 0
label diffuse_positive_326
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
jge highlight_positive_327
set r1 0
label highlight_positive_327
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
jle intensity_bounded_328
set r0 255
label intensity_bounded_328
localset 2450 r0
label body_lighting_done_324
localget r3 3030
cmp r3 0
jne body_lighting_done_329
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
jge diffuse_positive_331
set r0 0
label diffuse_positive_331
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
jge highlight_positive_332
set r1 0
label highlight_positive_332
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
jle intensity_bounded_333
set r0 255
label intensity_bounded_333
localset 2451 r0
label body_lighting_done_329
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
jge diffuse_positive_336
set r0 0
label diffuse_positive_336
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
jge highlight_positive_337
set r1 0
label highlight_positive_337
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
jle intensity_bounded_338
set r0 255
label intensity_bounded_338
localset 2452 r0
label body_lighting_done_334
localget r3 3030
cmp r3 0
jne body_lighting_done_339
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
jge diffuse_positive_341
set r0 0
label diffuse_positive_341
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
jge highlight_positive_342
set r1 0
label highlight_positive_342
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
jle intensity_bounded_343
set r0 255
label intensity_bounded_343
localset 2453 r0
label body_lighting_done_339
localget r3 3030
cmp r3 0
jne body_lighting_done_344
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
jge diffuse_positive_346
set r0 0
label diffuse_positive_346
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
jge highlight_positive_347
set r1 0
label highlight_positive_347
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
jle intensity_bounded_348
set r0 255
label intensity_bounded_348
localset 2454 r0
label body_lighting_done_344
localget r3 3030
cmp r3 0
jne body_lighting_done_349
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
jge diffuse_positive_351
set r0 0
label diffuse_positive_351
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
jge highlight_positive_352
set r1 0
label highlight_positive_352
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
jle intensity_bounded_353
set r0 255
label intensity_bounded_353
localset 2455 r0
label body_lighting_done_349
localget r3 3030
cmp r3 0
jne body_lighting_done_354
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
jge diffuse_positive_356
set r0 0
label diffuse_positive_356
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
jge highlight_positive_357
set r1 0
label highlight_positive_357
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
jle intensity_bounded_358
set r0 255
label intensity_bounded_358
localset 2456 r0
label body_lighting_done_354
localget r3 3030
cmp r3 0
jne body_lighting_done_359
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
jge diffuse_positive_361
set r0 0
label diffuse_positive_361
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
jge highlight_positive_362
set r1 0
label highlight_positive_362
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
jle intensity_bounded_363
set r0 255
label intensity_bounded_363
localset 2457 r0
label body_lighting_done_359
localget r3 3030
cmp r3 0
jne body_lighting_done_364
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
jge diffuse_positive_366
set r0 0
label diffuse_positive_366
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
jge highlight_positive_367
set r1 0
label highlight_positive_367
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
jle intensity_bounded_368
set r0 255
label intensity_bounded_368
localset 2458 r0
label body_lighting_done_364
localget r3 3030
cmp r3 0
jne body_lighting_done_369
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
jge diffuse_positive_371
set r0 0
label diffuse_positive_371
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
jge highlight_positive_372
set r1 0
label highlight_positive_372
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
jle intensity_bounded_373
set r0 255
label intensity_bounded_373
localset 2459 r0
label body_lighting_done_369
localget r3 3030
cmp r3 0
jne body_lighting_done_374
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
jge diffuse_positive_376
set r0 0
label diffuse_positive_376
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
jge highlight_positive_377
set r1 0
label highlight_positive_377
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
jle intensity_bounded_378
set r0 255
label intensity_bounded_378
localset 2460 r0
label body_lighting_done_374
localget r3 3030
cmp r3 0
jne body_lighting_done_379
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
jge diffuse_positive_381
set r0 0
label diffuse_positive_381
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
jge highlight_positive_382
set r1 0
label highlight_positive_382
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
jle intensity_bounded_383
set r0 255
label intensity_bounded_383
localset 2461 r0
label body_lighting_done_379
localget r3 3030
cmp r3 0
jne body_lighting_done_384
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
jge diffuse_positive_386
set r0 0
label diffuse_positive_386
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
jge highlight_positive_387
set r1 0
label highlight_positive_387
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
jle intensity_bounded_388
set r0 255
label intensity_bounded_388
localset 2462 r0
label body_lighting_done_384
localget r3 3030
cmp r3 0
jne body_lighting_done_389
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
jge diffuse_positive_391
set r0 0
label diffuse_positive_391
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
jge highlight_positive_392
set r1 0
label highlight_positive_392
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
jle intensity_bounded_393
set r0 255
label intensity_bounded_393
localset 2463 r0
label body_lighting_done_389
localget r3 3030
cmp r3 0
jne body_lighting_done_394
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
jge diffuse_positive_396
set r0 0
label diffuse_positive_396
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
jge highlight_positive_397
set r1 0
label highlight_positive_397
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
jle intensity_bounded_398
set r0 255
label intensity_bounded_398
localset 2464 r0
label body_lighting_done_394
localget r3 3030
cmp r3 0
jne body_lighting_done_399
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
jge diffuse_positive_401
set r0 0
label diffuse_positive_401
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
jge highlight_positive_402
set r1 0
label highlight_positive_402
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
jle intensity_bounded_403
set r0 255
label intensity_bounded_403
localset 2465 r0
label body_lighting_done_399
localget r3 3030
cmp r3 0
jne body_lighting_done_404
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
jge diffuse_positive_406
set r0 0
label diffuse_positive_406
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
jge highlight_positive_407
set r1 0
label highlight_positive_407
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
jle intensity_bounded_408
set r0 255
label intensity_bounded_408
localset 2466 r0
label body_lighting_done_404
localget r3 3030
cmp r3 0
jne body_lighting_done_409
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
jge diffuse_positive_411
set r0 0
label diffuse_positive_411
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
jge highlight_positive_412
set r1 0
label highlight_positive_412
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
jle intensity_bounded_413
set r0 255
label intensity_bounded_413
localset 2467 r0
label body_lighting_done_409
localget r3 3030
cmp r3 0
jne body_lighting_done_414
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
jge diffuse_positive_416
set r0 0
label diffuse_positive_416
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
jge highlight_positive_417
set r1 0
label highlight_positive_417
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
jle intensity_bounded_418
set r0 255
label intensity_bounded_418
localset 2468 r0
label body_lighting_done_414
localget r3 3030
cmp r3 0
jne body_lighting_done_419
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
jge diffuse_positive_421
set r0 0
label diffuse_positive_421
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
jge highlight_positive_422
set r1 0
label highlight_positive_422
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
jle intensity_bounded_423
set r0 255
label intensity_bounded_423
localset 2469 r0
label body_lighting_done_419
localget r3 3030
cmp r3 0
jne body_lighting_done_424
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
jge diffuse_positive_426
set r0 0
label diffuse_positive_426
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
jge highlight_positive_427
set r1 0
label highlight_positive_427
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
jle intensity_bounded_428
set r0 255
label intensity_bounded_428
localset 2470 r0
label body_lighting_done_424
localget r3 3030
cmp r3 0
jne body_lighting_done_429
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
jge diffuse_positive_431
set r0 0
label diffuse_positive_431
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
jge highlight_positive_432
set r1 0
label highlight_positive_432
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
jle intensity_bounded_433
set r0 255
label intensity_bounded_433
localset 2471 r0
label body_lighting_done_429
localget r3 3030
cmp r3 0
jne body_lighting_done_434
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
jge diffuse_positive_436
set r0 0
label diffuse_positive_436
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
jge highlight_positive_437
set r1 0
label highlight_positive_437
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
jle intensity_bounded_438
set r0 255
label intensity_bounded_438
localset 2472 r0
label body_lighting_done_434
localget r3 3030
cmp r3 0
jne body_lighting_done_439
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
jge diffuse_positive_441
set r0 0
label diffuse_positive_441
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
jge highlight_positive_442
set r1 0
label highlight_positive_442
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
jle intensity_bounded_443
set r0 255
label intensity_bounded_443
localset 2473 r0
label body_lighting_done_439
localget r3 3030
cmp r3 0
jne body_lighting_done_444
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
jge diffuse_positive_446
set r0 0
label diffuse_positive_446
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
jge highlight_positive_447
set r1 0
label highlight_positive_447
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
jle intensity_bounded_448
set r0 255
label intensity_bounded_448
localset 2474 r0
label body_lighting_done_444
localget r3 3030
cmp r3 0
jne body_lighting_done_449
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
jge diffuse_positive_451
set r0 0
label diffuse_positive_451
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
jge highlight_positive_452
set r1 0
label highlight_positive_452
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
jle intensity_bounded_453
set r0 255
label intensity_bounded_453
localset 2475 r0
label body_lighting_done_449
localget r3 3030
cmp r3 0
jne body_lighting_done_454
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
jge diffuse_positive_456
set r0 0
label diffuse_positive_456
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
jge highlight_positive_457
set r1 0
label highlight_positive_457
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
jle intensity_bounded_458
set r0 255
label intensity_bounded_458
localset 2476 r0
label body_lighting_done_454
localget r3 3030
cmp r3 0
jne body_lighting_done_459
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
jge diffuse_positive_461
set r0 0
label diffuse_positive_461
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
localset 2477 r0
label body_lighting_done_459
localget r3 3030
cmp r3 0
jne body_lighting_done_464
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
jge diffuse_positive_466
set r0 0
label diffuse_positive_466
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
localset 2478 r0
label body_lighting_done_464
localget r3 3030
cmp r3 2
jne body_lighting_done_469
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
jge diffuse_positive_471
set r0 0
label diffuse_positive_471
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
localset 2479 r0
label body_lighting_done_469
localget r3 3030
cmp r3 2
jne body_lighting_done_476
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
jge diffuse_positive_478
set r0 0
label diffuse_positive_478
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
jge highlight_positive_479
set r1 0
label highlight_positive_479
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
jle intensity_bounded_480
set r0 255
label intensity_bounded_480
localset 2481 r0
label body_lighting_done_476
localget r3 3030
cmp r3 1
jne body_lighting_done_483
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
jge diffuse_positive_485
set r0 0
label diffuse_positive_485
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
jge highlight_positive_486
set r1 0
label highlight_positive_486
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
jle intensity_bounded_487
set r0 255
label intensity_bounded_487
localset 2483 r0
label body_lighting_done_483
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
jge sin_negative_492
add r5 4096
label sin_negative_492
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
jlt sin_done_493
mul r7 -1
label sin_done_493
mov r5 r7
mov r8 r5
mov r9 r8
add r9 32768
localset 58 r9
mov r6 r0
add r6 1024
mod r6 4096
cmp r6 0
jge sin_negative_494
add r6 4096
label sin_negative_494
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
jlt sin_done_495
mul r7 -1
label sin_done_495
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
jlt wheel_next_model_498
cmp r8 795
jge wheel_next_model_498
cmp r8 408
jge wheel_next_wheel_499
localset 3044 -88
localset 3045 -142
localset 3046 0
jmp wheel_transform_496
label wheel_next_wheel_499
cmp r8 537
jge wheel_next_wheel_500
localset 3044 88
localset 3045 -142
localset 3046 0
jmp wheel_transform_496
label wheel_next_wheel_500
cmp r8 666
jge wheel_next_wheel_501
localset 3044 -88
localset 3045 138
localset 3046 1
jmp wheel_transform_496
label wheel_next_wheel_501
cmp r8 795
jge wheel_next_wheel_502
localset 3044 88
localset 3045 138
localset 3046 1
jmp wheel_transform_496
label wheel_next_wheel_502
label wheel_next_model_498
cmp r8 1109
jlt wheel_next_model_503
cmp r8 1309
jge wheel_next_model_503
cmp r8 1159
jge wheel_next_wheel_504
localset 3044 -88
localset 3045 -142
localset 3046 0
jmp wheel_transform_496
label wheel_next_wheel_504
cmp r8 1209
jge wheel_next_wheel_505
localset 3044 88
localset 3045 -142
localset 3046 0
jmp wheel_transform_496
label wheel_next_wheel_505
cmp r8 1259
jge wheel_next_wheel_506
localset 3044 -88
localset 3045 138
localset 3046 1
jmp wheel_transform_496
label wheel_next_wheel_506
cmp r8 1309
jge wheel_next_wheel_507
localset 3044 88
localset 3045 138
localset 3046 1
jmp wheel_transform_496
label wheel_next_wheel_507
label wheel_next_model_503
jmp wheel_transform_done_497
label wheel_transform_496
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
je wheel_rear_508
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
label wheel_rear_508
label wheel_transform_done_497
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
sub r9 2048
add r9 512
localget r9 r9
div r9 512
meshtexcopy r8 r9
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
meshfacegradienttex 2183 2192 2193 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2183 2193 2184 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2184 2193 2194 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2184 2194 2185 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2185 2194 2195 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2185 2195 2186 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2186 2195 2196 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2186 2196 2187 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2187 2196 2197 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2187 2197 2188 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2188 2197 2198 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2188 2198 2189 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2192 2201 2202 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2192 2202 2193 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2193 2202 2203 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2193 2203 2194 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2194 2203 2204 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2194 2204 2195 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2195 2204 2205 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2195 2205 2196 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2196 2205 2206 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2196 2206 2197 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2197 2206 2207 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2197 2207 2198 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2201 2210 2211 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2201 2211 2202 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2202 2211 2212 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2202 2212 2203 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2203 2212 2213 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2203 2213 2204 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2204 2213 2214 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2204 2214 2205 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2205 2214 2215 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2205 2215 2206 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2206 2215 2216 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2206 2216 2207 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2210 2219 2220 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2210 2220 2211 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2211 2220 2221 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2211 2221 2212 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2212 2221 2222 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2212 2222 2213 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2213 2222 2223 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2213 2223 2214 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2214 2223 2224 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2214 2224 2215 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2215 2224 2225 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2215 2225 2216 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2219 2228 2229 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2219 2229 2220 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2220 2229 2230 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2220 2230 2221 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2221 2230 2231 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2221 2231 2222 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2222 2231 2232 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2222 2232 2223 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2223 2232 2233 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2223 2233 2224 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2224 2233 2234 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2224 2234 2225 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2228 2237 2238 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2228 2238 2229 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2229 2238 2239 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2229 2239 2230 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2230 2239 2240 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2230 2240 2231 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2231 2240 2241 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2231 2241 2232 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2232 2241 2242 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2232 2242 2233 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2233 2242 2243 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2233 2243 2234 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2237 2246 2247 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2237 2247 2238 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2238 2247 2248 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2238 2248 2239 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2239 2248 2249 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2239 2249 2240 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2240 2249 2250 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2240 2250 2241 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2241 2250 2251 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2241 2251 2242 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2242 2251 2252 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2242 2252 2243 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2246 2255 2256 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2246 2256 2247 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2247 2256 2257 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2247 2257 2248 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2248 2257 2258 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2248 2258 2249 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2249 2258 2259 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2249 2259 2250 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2250 2259 2260 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2250 2260 2251 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2251 2260 2261 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2251 2261 2252 r12 24 0 10 r9 r10 r11 60
meshface 2935 2936 2937 226 r9 r10 r11 60
meshface 2935 2937 2938 226 r9 r10 r11 60
meshface 2939 2940 2941 226 r9 r10 r11 60
meshface 2939 2942 2940 226 r9 r10 r11 60
jmp next_actor
label emit_high
localget r12 126
meshfacegradienttex 2048 2049 2050 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2048 2051 2052 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2052 2051 2053 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2052 2054 2055 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2055 2054 2056 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2055 2056 2057 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2057 2056 2058 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2057 2058 2059 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2059 2058 2060 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2059 2060 2061 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2061 2060 2062 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2061 2062 2063 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2048 2064 2065 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2048 2066 2064 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2063 2067 2068 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2063 2068 2069 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2070 2071 2072 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2070 2072 2050 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2050 2072 2073 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2074 2073 2075 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2075 2073 2076 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2077 2076 2078 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2078 2076 2079 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2078 2079 2080 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2080 2079 2081 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2082 2081 2060 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2060 2081 2083 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2060 2083 2084 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2065 2085 2086 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2065 2064 2085 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2067 2087 2088 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2067 2088 2068 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2089 2090 2091 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2089 2091 2072 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2072 2091 2092 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2072 2092 2073 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2073 2092 2093 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2073 2093 2076 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2076 2093 2094 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2076 2094 2079 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2079 2094 2095 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2079 2095 2081 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2081 2095 2096 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2081 2097 2098 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2086 2099 2090 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2086 2085 2099 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2087 2096 2100 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2087 2100 2088 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2090 2101 2102 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2090 2102 2091 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2091 2102 2103 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2091 2103 2092 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2092 2103 2104 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2092 2104 2093 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2093 2104 2105 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2093 2105 2094 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2094 2105 2106 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2094 2106 2095 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2095 2106 2107 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2095 2107 2096 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2090 2108 2101 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2090 2099 2108 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2109 2107 2110 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2109 2110 2100 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2101 2111 2112 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2101 2112 2102 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2102 2112 2113 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2102 2113 2103 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2103 2113 2114 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2103 2114 2104 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2104 2114 2115 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2104 2115 2105 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2105 2115 2116 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2105 2116 2106 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2106 2116 2117 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2106 2117 2107 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2101 2118 2111 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2101 2108 2118 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2107 2117 2119 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2107 2119 2110 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2111 2120 2121 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2111 2121 2112 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2112 2121 2122 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2112 2122 2113 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2113 2122 2123 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2113 2123 2114 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2114 2123 2124 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2114 2124 2115 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2115 2124 2125 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2115 2125 2116 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2116 2125 2126 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2116 2126 2117 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2111 2127 2120 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2111 2118 2127 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2117 2126 2128 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2117 2128 2119 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2120 2129 2130 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2120 2130 2121 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2121 2130 2131 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2121 2131 2122 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2122 2131 2132 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2122 2132 2123 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2123 2132 2133 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2123 2133 2124 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2124 2133 2134 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2124 2134 2125 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2125 2134 2135 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2125 2135 2126 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2120 2136 2129 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2120 2127 2136 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2126 2135 2137 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2126 2137 2128 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2129 2138 2139 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2129 2139 2130 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2130 2139 2140 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2130 2140 2131 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2131 2140 2141 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2131 2141 2132 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2132 2141 2142 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2132 2142 2133 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2133 2142 2143 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2133 2143 2134 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2134 2143 2144 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2134 2144 2135 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2129 2145 2138 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2129 2136 2145 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2135 2144 2146 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2135 2146 2137 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2138 2147 2148 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2138 2148 2139 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2139 2148 2149 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2139 2149 2140 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2140 2149 2150 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2140 2150 2141 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2141 2150 2151 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2141 2151 2142 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2142 2151 2152 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2142 2152 2143 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2143 2152 2153 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2143 2153 2144 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2138 2154 2147 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2138 2145 2154 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2144 2153 2155 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2144 2155 2146 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2147 2156 2157 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2147 2157 2148 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2148 2157 2158 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2148 2158 2149 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2149 2158 2159 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2149 2159 2150 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2150 2159 2160 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2150 2160 2151 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2151 2160 2161 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2151 2161 2152 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2152 2161 2162 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2152 2162 2153 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2147 2163 2156 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2147 2154 2163 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2153 2162 2164 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2153 2164 2155 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2156 2165 2166 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2156 2166 2157 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2157 2166 2167 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2157 2167 2158 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2158 2167 2168 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2158 2168 2159 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2159 2168 2169 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2159 2169 2160 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2160 2169 2170 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2160 2170 2161 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2161 2170 2171 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2161 2171 2162 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2156 2172 2165 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2156 2163 2172 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2162 2171 2173 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2162 2173 2164 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2165 2174 2175 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2165 2175 2166 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2166 2175 2176 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2166 2176 2167 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2167 2176 2177 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2167 2177 2168 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2168 2177 2178 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2168 2178 2169 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2169 2178 2179 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2169 2179 2170 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2170 2179 2180 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2170 2180 2171 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2165 2181 2174 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2165 2172 2181 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2171 2180 2182 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2171 2182 2173 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2174 2183 2184 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2174 2184 2175 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2175 2184 2185 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2175 2185 2176 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2176 2185 2186 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2176 2186 2177 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2177 2186 2187 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2177 2187 2178 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2178 2187 2188 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2178 2188 2179 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2179 2188 2189 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2179 2189 2180 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2174 2190 2183 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2174 2181 2190 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2180 2189 2191 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2180 2191 2182 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2183 2192 2193 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2183 2193 2184 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2184 2193 2194 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2184 2194 2185 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2185 2194 2195 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2185 2195 2186 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2186 2195 2196 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2186 2196 2187 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2187 2196 2197 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2187 2197 2188 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2188 2197 2198 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2188 2198 2189 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2183 2199 2192 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2183 2190 2199 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2189 2198 2200 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2189 2200 2191 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2192 2201 2202 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2192 2202 2193 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2193 2202 2203 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2193 2203 2194 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2194 2203 2204 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2194 2204 2195 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2195 2204 2205 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2195 2205 2196 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2196 2205 2206 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2196 2206 2197 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2197 2206 2207 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2197 2207 2198 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2192 2208 2201 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2192 2199 2208 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2198 2207 2209 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2198 2209 2200 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2201 2210 2211 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2201 2211 2202 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2202 2211 2212 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2202 2212 2203 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2203 2212 2213 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2203 2213 2204 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2204 2213 2214 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2204 2214 2205 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2205 2214 2215 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2205 2215 2206 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2206 2215 2216 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2206 2216 2207 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2201 2217 2210 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2201 2208 2217 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2207 2216 2218 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2207 2218 2209 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2210 2219 2220 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2210 2220 2211 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2211 2220 2221 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2211 2221 2212 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2212 2221 2222 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2212 2222 2213 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2213 2222 2223 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2213 2223 2214 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2214 2223 2224 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2214 2224 2215 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2215 2224 2225 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2215 2225 2216 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2210 2226 2219 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2210 2217 2226 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2216 2225 2227 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2216 2227 2218 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2219 2228 2229 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2219 2229 2220 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2220 2229 2230 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2220 2230 2221 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2221 2230 2231 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2221 2231 2222 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2222 2231 2232 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2222 2232 2223 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2223 2232 2233 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2223 2233 2224 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2224 2233 2234 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2224 2234 2225 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2219 2235 2228 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2219 2226 2235 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2225 2234 2236 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2225 2236 2227 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2228 2237 2238 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2228 2238 2229 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2229 2238 2239 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2229 2239 2230 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2230 2239 2240 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2230 2240 2231 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2231 2240 2241 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2231 2241 2232 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2232 2241 2242 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2232 2242 2233 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2233 2242 2243 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2233 2243 2234 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2228 2244 2237 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2228 2235 2244 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2234 2243 2245 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2234 2245 2236 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2237 2246 2247 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2237 2247 2238 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2238 2247 2248 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2238 2248 2239 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2239 2248 2249 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2239 2249 2240 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2240 2249 2250 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2240 2250 2241 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2241 2250 2251 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2241 2251 2242 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2242 2251 2252 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2242 2252 2243 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2237 2253 2246 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2237 2244 2253 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2243 2252 2254 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2243 2254 2245 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2246 2255 2256 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2246 2256 2247 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2247 2256 2257 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2247 2257 2248 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2248 2257 2258 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2248 2258 2249 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2249 2258 2259 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2249 2259 2250 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2250 2259 2260 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2250 2260 2251 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2251 2260 2261 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2251 2261 2252 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2246 2262 2255 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2246 2253 2262 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2252 2261 2263 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2252 2263 2254 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2264 2066 2048 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2264 2048 2052 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2264 2052 2055 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2264 2055 2057 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2264 2057 2059 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2264 2059 2061 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2264 2061 2063 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2264 2063 2069 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2264 2069 2066 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2265 2255 2262 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2265 2256 2255 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2265 2257 2256 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2265 2258 2257 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2265 2259 2258 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2265 2260 2259 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2265 2261 2260 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2265 2263 2261 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2265 2262 2263 r12 24 0 10 r9 r10 r11 60
meshface 2266 2267 2268 227 r9 r10 r11 60
meshface 2266 2269 2267 227 r9 r10 r11 60
set r12 184
meshfacegradienttex 2270 2271 2272 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2270 2272 2273 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2273 2272 2274 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2273 2274 2275 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2275 2274 2276 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2275 2276 2277 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2277 2276 2278 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2277 2278 2279 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2271 2280 2281 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2271 2281 2272 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2272 2281 2282 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2272 2282 2274 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2274 2282 2283 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2274 2283 2276 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2276 2283 2284 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2276 2284 2278 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2280 2285 2286 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2280 2286 2281 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2281 2286 2287 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2281 2287 2282 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2282 2287 2288 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2282 2288 2283 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2283 2288 2289 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2283 2289 2284 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2285 2290 2291 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2285 2291 2286 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2286 2291 2292 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2286 2292 2287 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2287 2292 2293 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2287 2293 2288 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2288 2293 2294 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2288 2294 2289 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2290 2295 2296 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2290 2296 2291 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2291 2296 2297 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2291 2297 2292 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2292 2297 2298 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2292 2298 2293 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2293 2298 2299 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2293 2299 2294 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2295 2300 2301 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2295 2301 2296 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2296 2301 2302 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2296 2302 2297 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2297 2302 2303 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2297 2303 2298 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2298 2303 2304 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2298 2304 2299 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2305 2306 2307 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2305 2308 2306 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2305 2309 2308 r12 24 2 8 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2310 2311 2312 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2313 2314 2315 r12 24 0 10 r9 r10 r11 60
set r12 184
meshfacegradienttex 2316 2317 2318 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2316 2318 2319 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2316 2319 2320 r12 24 2 8 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2321 2322 2323 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2324 2325 2326 r12 24 0 10 r9 r10 r11 60
set r12 208
meshfacegradienttex 2327 2328 2329 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2327 2330 2328 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2330 2331 2332 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2330 2333 2331 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2333 2334 2335 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2333 2336 2334 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2336 2337 2334 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2336 2338 2337 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2338 2339 2337 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2338 2340 2339 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2340 2341 2342 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2340 2343 2341 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2343 2344 2345 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2343 2346 2344 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2346 2347 2344 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2346 2348 2347 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2348 2349 2347 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2348 2350 2349 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2350 2351 2352 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2350 2353 2351 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2353 2354 2355 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2353 2356 2354 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2356 2357 2354 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2356 2358 2357 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2358 2359 2357 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2358 2360 2359 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2360 2361 2362 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2360 2363 2361 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2363 2364 2365 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2363 2366 2364 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2366 2329 2364 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2366 2327 2329 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2367 2368 2369 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2367 2370 2368 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2370 2371 2368 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2372 2373 2371 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2374 2375 2371 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2376 2377 2375 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2377 2378 2375 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2377 2379 2378 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2379 2380 2378 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2379 2381 2380 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2381 2382 2380 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2383 2384 2382 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2385 2386 2382 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2387 2388 2386 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2388 2389 2386 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2388 2390 2389 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2390 2391 2389 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2390 2392 2391 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2392 2393 2391 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2394 2395 2393 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2396 2397 2393 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2398 2399 2397 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2399 2400 2397 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2399 2401 2400 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2401 2402 2400 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2401 2403 2402 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2403 2404 2402 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2405 2406 2404 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2407 2408 2404 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2409 2410 2408 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2410 2369 2408 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2410 2367 2369 r12 4 3 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2411 2412 2413 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2411 2413 2414 r12 12 4 12 r9 r10 r11 60
meshface 2415 2416 2417 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2412 2418 2419 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2412 2419 2413 r12 12 4 12 r9 r10 r11 60
meshface 2415 2417 2420 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2418 2421 2422 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2418 2422 2419 r12 12 4 12 r9 r10 r11 60
meshface 2415 2420 2423 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2421 2424 2425 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2421 2425 2422 r12 12 4 12 r9 r10 r11 60
meshface 2415 2423 2426 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2424 2427 2428 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2424 2428 2425 r12 12 4 12 r9 r10 r11 60
meshface 2415 2426 2429 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2427 2430 2431 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2427 2431 2428 r12 12 4 12 r9 r10 r11 60
meshface 2415 2429 2432 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2430 2433 2434 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2430 2434 2431 r12 12 4 12 r9 r10 r11 60
meshface 2415 2432 2435 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2433 2411 2414 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2433 2414 2434 r12 12 4 12 r9 r10 r11 60
meshface 2415 2435 2416 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2436 2437 2438 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2436 2438 2439 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2440 2441 2442 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2440 2442 2443 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2444 2445 2446 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2444 2446 2447 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2448 2449 2450 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2448 2450 2451 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2452 2453 2454 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2452 2454 2455 r12 12 4 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2456 2457 2458 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2456 2458 2459 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2459 2460 2461 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2459 2461 2462 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2462 2463 2464 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2462 2464 2465 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2465 2464 2466 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2465 2466 2467 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2467 2466 2468 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2467 2468 2469 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2469 2470 2471 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2469 2471 2472 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2472 2473 2474 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2472 2474 2475 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2475 2474 2476 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2475 2476 2477 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2477 2476 2478 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2477 2478 2479 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2479 2480 2481 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2479 2481 2482 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2482 2483 2484 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2482 2484 2485 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2485 2484 2486 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2485 2486 2487 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2487 2486 2488 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2487 2488 2489 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2489 2490 2491 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2489 2491 2492 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2492 2493 2494 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2492 2494 2495 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2495 2494 2457 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2495 2457 2456 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2496 2497 2498 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2496 2498 2499 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2499 2498 2500 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2501 2500 2502 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2503 2500 2504 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2505 2504 2506 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2506 2504 2507 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2506 2507 2508 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2508 2507 2509 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2508 2509 2510 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2510 2509 2511 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2512 2511 2513 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2514 2511 2515 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2516 2515 2517 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2517 2515 2518 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2517 2518 2519 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2519 2518 2520 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2519 2520 2521 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2521 2520 2522 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2523 2522 2524 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2525 2522 2526 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2527 2526 2528 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2528 2526 2529 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2528 2529 2530 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2530 2529 2531 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2530 2531 2532 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2532 2531 2533 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2534 2533 2535 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2536 2533 2537 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2538 2537 2539 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2539 2537 2497 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2539 2497 2496 r12 4 3 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2540 2541 2542 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2540 2543 2541 r12 12 4 12 r9 r10 r11 60
meshface 2544 2545 2546 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2542 2547 2548 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2542 2541 2547 r12 12 4 12 r9 r10 r11 60
meshface 2544 2549 2545 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2548 2550 2551 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2548 2547 2550 r12 12 4 12 r9 r10 r11 60
meshface 2544 2552 2549 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2551 2553 2554 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2551 2550 2553 r12 12 4 12 r9 r10 r11 60
meshface 2544 2555 2552 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2554 2556 2557 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2554 2553 2556 r12 12 4 12 r9 r10 r11 60
meshface 2544 2558 2555 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2557 2559 2560 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2557 2556 2559 r12 12 4 12 r9 r10 r11 60
meshface 2544 2561 2558 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2560 2562 2563 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2560 2559 2562 r12 12 4 12 r9 r10 r11 60
meshface 2544 2564 2561 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2563 2543 2540 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2563 2562 2543 r12 12 4 12 r9 r10 r11 60
meshface 2544 2546 2564 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2565 2566 2567 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2565 2568 2566 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2569 2570 2571 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2569 2572 2570 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2573 2574 2575 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2573 2576 2574 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2577 2578 2579 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2577 2580 2578 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2581 2582 2583 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2581 2584 2582 r12 12 4 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2585 2586 2587 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2585 2588 2586 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2588 2589 2590 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2588 2591 2589 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2591 2592 2593 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2591 2594 2592 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2594 2595 2592 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2594 2596 2595 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2596 2597 2595 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2596 2598 2597 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2598 2599 2600 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2598 2601 2599 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2601 2602 2603 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2601 2604 2602 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2604 2605 2602 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2604 2606 2605 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2606 2607 2605 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2606 2608 2607 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2608 2609 2610 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2608 2611 2609 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2611 2612 2613 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2611 2614 2612 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2614 2615 2612 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2614 2616 2615 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2616 2617 2615 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2616 2618 2617 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2618 2619 2620 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2618 2621 2619 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2621 2622 2623 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2621 2624 2622 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2624 2587 2622 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2624 2585 2587 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2625 2626 2627 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2625 2628 2626 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2628 2629 2626 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2630 2631 2629 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2632 2633 2629 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2634 2635 2633 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2635 2636 2633 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2635 2637 2636 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2637 2638 2636 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2637 2639 2638 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2639 2640 2638 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2641 2642 2640 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2643 2644 2640 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2645 2646 2644 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2646 2647 2644 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2646 2648 2647 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2648 2649 2647 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2648 2650 2649 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2650 2651 2649 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2652 2653 2651 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2654 2655 2651 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2656 2657 2655 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2657 2658 2655 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2657 2659 2658 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2659 2660 2658 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2659 2661 2660 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2661 2662 2660 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2663 2664 2662 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2665 2666 2662 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2667 2668 2666 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2668 2627 2666 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2668 2625 2627 r12 4 3 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2669 2670 2671 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2669 2671 2672 r12 12 4 12 r9 r10 r11 60
meshface 2673 2674 2675 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2670 2676 2677 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2670 2677 2671 r12 12 4 12 r9 r10 r11 60
meshface 2673 2675 2678 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2676 2679 2680 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2676 2680 2677 r12 12 4 12 r9 r10 r11 60
meshface 2673 2678 2681 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2679 2682 2683 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2679 2683 2680 r12 12 4 12 r9 r10 r11 60
meshface 2673 2681 2684 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2682 2685 2686 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2682 2686 2683 r12 12 4 12 r9 r10 r11 60
meshface 2673 2684 2687 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2685 2688 2689 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2685 2689 2686 r12 12 4 12 r9 r10 r11 60
meshface 2673 2687 2690 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2688 2691 2692 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2688 2692 2689 r12 12 4 12 r9 r10 r11 60
meshface 2673 2690 2693 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2691 2669 2672 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2691 2672 2692 r12 12 4 12 r9 r10 r11 60
meshface 2673 2693 2674 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2694 2695 2696 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2694 2696 2697 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2698 2699 2700 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2698 2700 2701 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2702 2703 2704 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2702 2704 2705 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2706 2707 2708 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2706 2708 2709 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2710 2711 2712 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2710 2712 2713 r12 12 4 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2714 2715 2716 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2714 2716 2717 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2717 2718 2719 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2717 2719 2720 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2720 2721 2722 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2720 2722 2723 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2723 2722 2724 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2723 2724 2725 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2725 2724 2726 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2725 2726 2727 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2727 2728 2729 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2727 2729 2730 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2730 2731 2732 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2730 2732 2733 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2733 2732 2734 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2733 2734 2735 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2735 2734 2736 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2735 2736 2737 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2737 2738 2739 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2737 2739 2740 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2740 2741 2742 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2740 2742 2743 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2743 2742 2744 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2743 2744 2745 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2745 2744 2746 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2745 2746 2747 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2747 2748 2749 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2747 2749 2750 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2750 2751 2752 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2750 2752 2753 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2753 2752 2715 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2753 2715 2714 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2754 2755 2756 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2754 2756 2757 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2757 2756 2758 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2759 2758 2760 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2761 2758 2762 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2763 2762 2764 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2764 2762 2765 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2764 2765 2766 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2766 2765 2767 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2766 2767 2768 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2768 2767 2769 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2770 2769 2771 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2772 2769 2773 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2774 2773 2775 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2775 2773 2776 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2775 2776 2777 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2777 2776 2778 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2777 2778 2779 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2779 2778 2780 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2781 2780 2782 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2783 2780 2784 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2785 2784 2786 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2786 2784 2787 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2786 2787 2788 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2788 2787 2789 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2788 2789 2790 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2790 2789 2791 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2792 2791 2793 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2794 2791 2795 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2796 2795 2797 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2797 2795 2755 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 2797 2755 2754 r12 4 3 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2798 2799 2800 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2798 2801 2799 r12 12 4 12 r9 r10 r11 60
meshface 2802 2803 2804 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2800 2805 2806 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2800 2799 2805 r12 12 4 12 r9 r10 r11 60
meshface 2802 2807 2803 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2806 2808 2809 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2806 2805 2808 r12 12 4 12 r9 r10 r11 60
meshface 2802 2810 2807 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2809 2811 2812 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2809 2808 2811 r12 12 4 12 r9 r10 r11 60
meshface 2802 2813 2810 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2812 2814 2815 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2812 2811 2814 r12 12 4 12 r9 r10 r11 60
meshface 2802 2816 2813 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2815 2817 2818 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2815 2814 2817 r12 12 4 12 r9 r10 r11 60
meshface 2802 2819 2816 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2818 2820 2821 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2818 2817 2820 r12 12 4 12 r9 r10 r11 60
meshface 2802 2822 2819 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2821 2801 2798 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2821 2820 2801 r12 12 4 12 r9 r10 r11 60
meshface 2802 2804 2822 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2823 2824 2825 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2823 2826 2824 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2827 2828 2829 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2827 2830 2828 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2831 2832 2833 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2831 2834 2832 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2835 2836 2837 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2835 2838 2836 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2839 2840 2841 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 2839 2842 2840 r12 12 4 12 r9 r10 r11 60
meshface 2843 2844 2845 226 r9 r10 r11 60
meshface 2843 2846 2844 226 r9 r10 r11 60
meshface 2847 2848 2849 226 r9 r10 r11 60
meshface 2850 2851 2852 226 r9 r10 r11 60
set r12 184
meshfacegradienttex 2853 2854 2855 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2856 2857 2858 r12 24 2 8 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2859 2860 2861 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2862 2863 2864 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2865 2866 2867 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2868 2869 2870 r12 24 0 10 r9 r10 r11 60
meshface 2871 2872 2873 226 r9 r10 r11 60
meshface 2871 2873 2874 226 r9 r10 r11 60
meshface 2875 2876 2877 226 r9 r10 r11 60
meshface 2878 2879 2880 226 r9 r10 r11 60
set r12 184
meshfacegradienttex 2881 2882 2883 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 2884 2885 2886 r12 24 2 8 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2887 2888 2889 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2890 2891 2892 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2893 2894 2895 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 2896 2897 2898 r12 24 0 10 r9 r10 r11 60
meshface 2899 2900 2901 225 r9 r10 r11 60
meshface 2899 2901 2902 225 r9 r10 r11 60
meshface 2903 2904 2905 224 r9 r10 r11 60
meshface 2903 2906 2904 224 r9 r10 r11 60
set r12 228
meshfacegradienttex 2907 2908 2909 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 2907 2910 2908 r12 12 1 11 r9 r10 r11 60
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
meshfacegradienttex 2943 2944 2945 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 2943 2945 2946 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 2944 2947 2948 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 2944 2948 2945 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 2947 2949 2950 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 2947 2950 2948 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 2949 2951 2952 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 2949 2952 2950 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 2953 2954 2955 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 2953 2956 2954 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 2955 2957 2958 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 2955 2954 2957 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 2958 2959 2960 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 2958 2957 2959 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 2960 2961 2962 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 2960 2959 2961 r12 12 1 11 r9 r10 r11 60
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
meshfacegradienttex 2995 2996 2997 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 2995 2998 2996 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 2999 3000 3001 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 2999 3002 3000 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 3003 3004 3005 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 3003 3006 3004 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 3007 3008 3009 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 3007 3010 3008 r12 12 1 11 r9 r10 r11 60
meshface 3011 3012 3013 240 r9 r10 r11 60
meshface 3011 3014 3012 240 r9 r10 r11 60
meshface 3015 3016 3017 241 r9 r10 r11 60
meshface 3015 3017 3018 241 r9 r10 r11 60
meshface 3019 3020 3021 241 r9 r10 r11 60
meshface 3019 3022 3020 241 r9 r10 r11 60
jmp emit_shadow
label emit_medium
localget r12 126
meshfacegradienttex 3023 3024 3025 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3023 3025 3026 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3026 3025 3027 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3026 3027 3028 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3029 3030 3031 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3029 3032 3030 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3033 3034 3035 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3033 3035 3036 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3024 3037 3038 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3024 3038 3025 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3025 3038 3039 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3025 3039 3027 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3031 3040 3041 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3031 3030 3040 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3034 3042 3043 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3034 3043 3035 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3037 3044 3045 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3037 3045 3038 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3038 3045 3046 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3038 3046 3039 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3041 3047 3048 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3041 3040 3047 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3042 3049 3050 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3042 3050 3043 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3044 3051 3052 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3044 3052 3045 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3045 3052 3053 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3045 3053 3046 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3048 3054 3055 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3048 3047 3054 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3049 3056 3057 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3049 3057 3050 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3051 3058 3059 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3051 3059 3052 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3052 3059 3060 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3052 3060 3053 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3055 3061 3062 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3055 3054 3061 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3056 3063 3064 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3056 3064 3057 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3058 3065 3066 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3058 3066 3059 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3059 3066 3067 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3059 3067 3060 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3062 3068 3069 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3062 3061 3068 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3063 3070 3071 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3063 3071 3064 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3065 3072 3073 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3065 3073 3066 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3066 3073 3074 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3066 3074 3067 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3069 3075 3076 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3069 3068 3075 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3070 3077 3078 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3070 3078 3071 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3072 3079 3080 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3072 3080 3073 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3073 3080 3081 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3073 3081 3074 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3076 3082 3083 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3076 3075 3082 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3077 3084 3085 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3077 3085 3078 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3079 3086 3087 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3079 3087 3080 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3080 3087 3088 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3080 3088 3081 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3083 3089 3090 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3083 3082 3089 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3084 3091 3092 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3084 3092 3085 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3086 3093 3094 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3086 3094 3087 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3087 3094 3095 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3087 3095 3088 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3090 3096 3097 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3090 3089 3096 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3091 3098 3099 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3091 3099 3092 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3093 3100 3101 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3093 3101 3094 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3094 3101 3102 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3094 3102 3095 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3097 3103 3104 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3097 3096 3103 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3098 3105 3106 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3098 3106 3099 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3107 3108 3109 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3107 3109 3110 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3107 3110 3111 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3107 3111 3112 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3107 3112 3108 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3113 3114 3103 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3113 3101 3114 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3113 3115 3101 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3113 3106 3115 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3113 3103 3106 r12 24 0 10 r9 r10 r11 60
meshface 3116 3117 3118 227 r9 r10 r11 60
meshface 3116 3119 3117 227 r9 r10 r11 60
set r12 184
meshfacegradienttex 3120 3121 3122 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3120 3122 3123 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3123 3122 3124 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3123 3124 3125 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3121 3126 3127 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3121 3127 3122 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3122 3127 3128 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3122 3128 3124 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3126 3129 3130 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3126 3130 3127 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3127 3130 3131 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3127 3131 3128 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3129 3132 3133 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3129 3133 3130 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3130 3133 3134 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3130 3134 3131 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3135 3136 3137 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3135 3138 3136 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3135 3139 3138 r12 24 2 8 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3140 3141 3142 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3143 3144 3145 r12 24 0 10 r9 r10 r11 60
set r12 184
meshfacegradienttex 3146 3147 3148 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3146 3148 3149 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3146 3149 3150 r12 24 2 8 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3151 3152 3153 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3154 3155 3156 r12 24 0 10 r9 r10 r11 60
set r12 208
meshfacegradienttex 3157 3158 3159 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3157 3160 3158 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3160 3161 3158 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3160 3162 3161 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3162 3163 3161 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3162 3164 3163 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3164 3165 3163 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3164 3166 3165 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3166 3167 3165 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3166 3168 3167 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3168 3169 3167 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3168 3170 3169 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3170 3171 3169 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3170 3172 3171 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3172 3159 3171 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3172 3157 3159 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3173 3174 3175 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3173 3176 3174 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3176 3177 3174 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3176 3178 3177 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3178 3179 3177 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3178 3180 3179 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3180 3181 3179 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3180 3182 3181 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3182 3183 3181 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3182 3184 3183 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3184 3185 3183 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3184 3186 3185 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3186 3187 3185 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3186 3188 3187 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3188 3175 3187 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3188 3173 3175 r12 4 3 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 3189 3190 3191 r12 12 4 12 r9 r10 r11 60
meshface 3192 3193 3194 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3189 3195 3196 r12 12 4 12 r9 r10 r11 60
meshface 3192 3197 3198 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3189 3199 3200 r12 12 4 12 r9 r10 r11 60
meshface 3192 3201 3202 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3189 3203 3204 r12 12 4 12 r9 r10 r11 60
meshface 3192 3205 3206 226 r9 r10 r11 60
set r12 208
meshfacegradienttex 3207 3208 3209 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3207 3209 3210 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3210 3209 3211 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3210 3211 3212 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3212 3211 3213 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3212 3213 3214 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3214 3213 3215 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3214 3215 3216 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3216 3215 3217 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3216 3217 3218 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3218 3217 3219 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3218 3219 3220 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3220 3219 3221 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3220 3221 3222 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3222 3221 3208 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3222 3208 3207 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3223 3224 3225 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3223 3225 3226 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3226 3225 3227 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3226 3227 3228 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3228 3227 3229 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3228 3229 3230 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3230 3229 3231 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3230 3231 3232 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3232 3231 3233 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3232 3233 3234 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3234 3233 3235 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3234 3235 3236 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3236 3235 3237 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3236 3237 3238 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3238 3237 3224 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3238 3224 3223 r12 4 3 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 3239 3240 3241 r12 12 4 12 r9 r10 r11 60
meshface 3242 3243 3244 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3239 3245 3246 r12 12 4 12 r9 r10 r11 60
meshface 3242 3247 3248 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3239 3249 3250 r12 12 4 12 r9 r10 r11 60
meshface 3242 3251 3252 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3239 3253 3254 r12 12 4 12 r9 r10 r11 60
meshface 3242 3255 3256 226 r9 r10 r11 60
set r12 208
meshfacegradienttex 3257 3258 3259 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3257 3260 3258 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3260 3261 3258 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3260 3262 3261 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3262 3263 3261 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3262 3264 3263 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3264 3265 3263 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3264 3266 3265 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3266 3267 3265 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3266 3268 3267 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3268 3269 3267 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3268 3270 3269 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3270 3271 3269 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3270 3272 3271 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3272 3259 3271 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3272 3257 3259 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3273 3274 3275 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3273 3276 3274 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3276 3277 3274 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3276 3278 3277 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3278 3279 3277 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3278 3280 3279 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3280 3281 3279 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3280 3282 3281 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3282 3283 3281 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3282 3284 3283 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3284 3285 3283 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3284 3286 3285 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3286 3287 3285 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3286 3288 3287 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3288 3275 3287 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3288 3273 3275 r12 4 3 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 3289 3290 3291 r12 12 4 12 r9 r10 r11 60
meshface 3292 3293 3294 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3289 3295 3296 r12 12 4 12 r9 r10 r11 60
meshface 3292 3297 3298 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3289 3299 3300 r12 12 4 12 r9 r10 r11 60
meshface 3292 3301 3302 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3289 3303 3304 r12 12 4 12 r9 r10 r11 60
meshface 3292 3305 3306 226 r9 r10 r11 60
set r12 208
meshfacegradienttex 3307 3308 3309 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3307 3309 3310 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3310 3309 3311 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3310 3311 3312 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3312 3311 3313 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3312 3313 3314 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3314 3313 3315 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3314 3315 3316 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3316 3315 3317 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3316 3317 3318 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3318 3317 3319 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3318 3319 3320 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3320 3319 3321 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3320 3321 3322 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3322 3321 3308 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3322 3308 3307 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3323 3324 3325 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3323 3325 3326 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3326 3325 3327 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3326 3327 3328 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3328 3327 3329 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3328 3329 3330 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3330 3329 3331 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3330 3331 3332 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3332 3331 3333 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3332 3333 3334 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3334 3333 3335 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3334 3335 3336 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3336 3335 3337 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3336 3337 3338 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3338 3337 3324 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3338 3324 3323 r12 4 3 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 3339 3340 3341 r12 12 4 12 r9 r10 r11 60
meshface 3342 3343 3344 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3339 3345 3346 r12 12 4 12 r9 r10 r11 60
meshface 3342 3347 3348 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3339 3349 3350 r12 12 4 12 r9 r10 r11 60
meshface 3342 3351 3352 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3339 3353 3354 r12 12 4 12 r9 r10 r11 60
meshface 3342 3355 3356 226 r9 r10 r11 60
meshface 3357 3358 3359 226 r9 r10 r11 60
meshface 3360 3361 3362 226 r9 r10 r11 60
meshface 3363 3364 3365 225 r9 r10 r11 60
meshface 3363 3365 3366 225 r9 r10 r11 60
meshface 3367 3368 3369 224 r9 r10 r11 60
meshface 3367 3370 3368 224 r9 r10 r11 60
set r12 228
meshfacegradienttex 3371 3372 3373 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 3371 3374 3372 r12 12 1 11 r9 r10 r11 60
meshface 3375 3376 3377 226 r9 r10 r11 60
meshface 3375 3377 3378 226 r9 r10 r11 60
meshface 3379 3380 3381 226 r9 r10 r11 60
meshface 3379 3382 3380 226 r9 r10 r11 60
set r12 228
meshfacegradienttex 3383 3384 3385 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 3383 3385 3386 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 3384 3387 3388 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 3384 3388 3385 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 3389 3390 3391 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 3389 3392 3390 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 3391 3393 3394 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 3391 3390 3393 r12 12 1 11 r9 r10 r11 60
jmp emit_shadow
label emit_far
localget r12 126
meshfacegradienttex 3395 3396 3397 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3395 3397 3398 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3398 3397 3399 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3398 3399 3400 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3401 3402 3403 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3401 3404 3402 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3405 3406 3407 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3405 3407 3408 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3396 3409 3410 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3396 3410 3397 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3397 3410 3411 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3397 3411 3399 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3403 3412 3413 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3403 3402 3412 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3406 3414 3415 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3406 3415 3407 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3409 3416 3417 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3409 3417 3410 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3410 3417 3418 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3410 3418 3411 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3413 3419 3420 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3413 3412 3419 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3414 3421 3422 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3414 3422 3415 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3416 3423 3424 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3416 3424 3417 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3417 3424 3425 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3417 3425 3418 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3420 3426 3427 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3420 3419 3426 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3421 3428 3429 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3421 3429 3422 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3423 3430 3431 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3423 3431 3424 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3424 3431 3432 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3424 3432 3425 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3427 3433 3434 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3427 3426 3433 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3428 3435 3436 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3428 3436 3429 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3437 3438 3439 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3437 3439 3440 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3433 3441 3442 r12 24 0 10 r9 r10 r11 60
localget r12 126
meshfacegradienttex 3433 3436 3441 r12 24 0 10 r9 r10 r11 60
meshface 3443 3444 3445 227 r9 r10 r11 60
meshface 3443 3446 3444 227 r9 r10 r11 60
set r12 184
meshfacegradienttex 3447 3448 3449 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3447 3449 3450 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3450 3449 3451 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3450 3451 3452 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3448 3453 3454 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3448 3454 3449 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3449 3454 3455 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3449 3455 3451 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3453 3456 3457 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3453 3457 3454 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3454 3457 3458 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3454 3458 3455 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3459 3460 3461 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3459 3462 3460 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3463 3464 3465 r12 24 2 8 r9 r10 r11 60
set r12 184
meshfacegradienttex 3463 3465 3466 r12 24 2 8 r9 r10 r11 60
set r12 208
meshfacegradienttex 3467 3468 3469 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3467 3470 3468 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3471 3472 3473 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3471 3474 3472 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3475 3476 3477 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3475 3478 3476 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3479 3480 3481 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3479 3482 3480 r12 4 3 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 3483 3484 3485 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 3483 3485 3486 r12 12 4 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3487 3488 3489 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3487 3489 3490 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3491 3492 3493 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3491 3493 3494 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3495 3496 3497 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3495 3497 3498 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3499 3500 3501 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3499 3501 3502 r12 4 3 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 3503 3504 3505 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 3503 3506 3504 r12 12 4 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3507 3508 3509 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3507 3510 3508 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3511 3512 3513 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3511 3514 3512 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3515 3516 3517 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3515 3518 3516 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3519 3520 3521 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3519 3522 3520 r12 4 3 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 3523 3524 3525 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 3523 3525 3526 r12 12 4 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3527 3528 3529 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3527 3529 3530 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3531 3532 3533 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3531 3533 3534 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3535 3536 3537 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3535 3537 3538 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3539 3540 3541 r12 4 3 12 r9 r10 r11 60
set r12 208
meshfacegradienttex 3539 3541 3542 r12 4 3 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 3543 3544 3545 r12 12 4 12 r9 r10 r11 60
set r12 212
meshfacegradienttex 3543 3546 3544 r12 12 4 12 r9 r10 r11 60
meshface 3547 3548 3549 225 r9 r10 r11 60
meshface 3547 3549 3550 225 r9 r10 r11 60
meshface 3551 3552 3553 224 r9 r10 r11 60
meshface 3551 3554 3552 224 r9 r10 r11 60
set r12 228
meshfacegradienttex 3555 3556 3557 r12 12 1 11 r9 r10 r11 60
set r12 228
meshfacegradienttex 3555 3558 3556 r12 12 1 11 r9 r10 r11 60
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
