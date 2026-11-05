#!reverse-pc-machine-v1
# REgraphics Open Forest 3.0: bounded sectors, one-lane road and world lighting.
# The generic meshtri3 primitive clips/rasterizes; XI owns world geometry and camera.
# Read-only observation: every scratch byte belongs to the discarded render candidate.
load32 r12 100
sub r12 2000000
load32 r13 104
sub r13 2000000
load16 r0 108
load16 r1 204
add r0 r1
mod r0 4096
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
meshbegin r0 r1 5 0
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
load16 r6 206
cmp r6 256
jlt orbit_elevation_decoded
sub r6 512
label orbit_elevation_decoded
add r1 r6
add r2 r6
load16 r4 384
mul r4 3
div r4 5
add r1 r4
load16 r4 520
add r1 r4
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
meshtexrow 5 0 9c9a86ac9a76a7ab
meshtexrow 5 1 ccab88ab9998a788
meshtexrow 5 2 a9aa98aacab9cca9
meshtexrow 5 3 7998b9a9b9b9cc97
meshtexrow 5 4 88ab98aa88a98a87
meshtexrow 5 5 9aaaa9ccb9787898
meshtexrow 5 6 cc66aa9a99977acb
meshtexrow 5 7 ba9797a8a9888899
meshtexrow 5 8 ba7a78998669a9c9
meshtexrow 5 9 ba9a8a988968abb9
meshtexrow 5 10 9ca8aaa897868889
meshtexrow 5 11 bbaa988a6767a867
meshtexrow 5 12 cc89aaaaac89b999
meshtexrow 5 13 cb688ba7ac99a868
meshtexrow 5 14 bc99b98a99897a8b
meshtexrow 5 15 ab7a9b798aa7a799
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
localget r0 4
mul r0 999999
localget r1 6
div r0 r1
meshvertex 1790 -600000 340000 999999
meshvertex 1791 600000 340000 999999
meshvertex 1792 600000 r0 999999
meshvertex 1793 -600000 r0 999999
meshshade 1790 0
meshshade 1791 0
meshshade 1792 255
meshshade 1793 255
localget r9 18
mov r10 r9
div r10 2
mov r11 r10
mul r11 9
div r11 16
mul r9 85
div r9 100
meshfacegradient 1790 1791 1792 0 7 r9 r10 r11 60
meshfacegradient 1790 1792 1793 0 7 r9 r10 r11 60
meshvertex 1794 -600000 r0 999998
meshvertex 1795 600000 r0 999998
meshvertex 1796 600000 -800000 999998
meshvertex 1797 -600000 -800000 999998
meshshade 1794 240
meshshade 1795 240
meshshade 1796 0
meshshade 1797 0
localget r9 18
mov r10 r9
div r10 2
mov r11 r10
mul r11 9
div r11 16
mul r9 85
div r9 100
meshfacegradient 1794 1795 1796 12 8 r9 r10 r11 60
meshfacegradient 1794 1796 1797 12 8 r9 r10 r11 60
load8 r6 108
load8 r7 109
mul r7 256
add r6 r7
load16 r7 204
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
mov r6 r7
mul r6 17
mod r6 5
mul r6 r0
div r6 140
sub r5 r6
meshtri r1 r3 999990 r4 r5 999990 r2 r3 999990 18
add r7 1
cmp r7 8
jlt hills
load8 r0 273
div r0 10
mul r0 10
sub r0 10
cmp r0 0
jge open_sector_start
set r0 0
label open_sector_start
localset 3200 r0
mov r1 r0
add r1 30
cmp r1 80
jle open_sector_end
set r1 80
label open_sector_end
localset 3201 r1
localset 8 r0
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
localget r1 8
mul r1 2
add r1 5300
load16 r1 $r1
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
localget r5 8
mul r5 2
add r5 3600
localset r5 r1
add r5 1
localset r5 r2
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
localget r9 3201
cmp r8 r9
jle transform_track
localget r0 3200
localset 8 r0
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
set r0 -6000
set r1 -300
set r2 300
set r3 0
localset 28 78
jmp band_ready
label band_0_skip
localget r0 9
cmp r0 1
jne band_1_skip
set r0 -300
set r1 -200
set r2 0
set r3 0
localset 28 208
jmp band_ready
label band_1_skip
localget r0 9
cmp r0 2
jne band_2_skip
set r0 -200
set r1 -180
set r2 0
set r3 0
localset 28 206
jmp band_ready
label band_2_skip
localget r0 9
cmp r0 3
jne band_3_skip
set r0 -180
set r1 180
set r2 0
set r3 0
localset 28 108
jmp band_ready
label band_3_skip
localget r0 9
cmp r0 4
jne band_4_skip
set r0 180
set r1 200
set r2 0
set r3 0
localset 28 206
jmp band_ready
label band_4_skip
localget r0 9
cmp r0 5
jne band_5_skip
set r0 200
set r1 300
set r2 0
set r3 0
localset 28 208
jmp band_ready
label band_5_skip
localget r0 9
cmp r0 6
jne band_6_skip
set r0 300
set r1 6000
set r2 0
set r3 350
localset 28 78
jmp band_ready
label band_6_skip
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
localget r0 8
add r0 5500
load8 r0 $r0
cmp r0 1
je open_river_band
cmp r0 5
je open_river_band
cmp r0 2
jne open_road_band_ready
localget r0 9
cmp r0 6
je next_band
jmp open_road_band_ready
label open_river_band
localget r0 9
cmp r0 0
je next_band
cmp r0 6
je next_band
label open_road_band_ready
localget r0 8
add r0 5500
load8 r0 $r0
cmp r0 4
jlt open_edge_ready
localget r0 28
cmp r0 206
jne open_edge_ready
localset 28 208
label open_edge_ready
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
cmp r9 78
je road_verge_10
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
localget r12 8
mod r12 7
cmp r12 3
jle asphalt_darker_12
set r12 42
jmp asphalt_tone_done_13
label asphalt_darker_12
set r12 40
label asphalt_tone_done_13
localget r0 8
add r0 5500
load8 r0 $r0
cmp r0 4
jge wet_road_14
meshfacegradienttex 1770 1771 1772 r12 12 5 3 r9 r10 r11 60
jmp road_done_9
label wet_road_14
meshfacegradienttex 1770 1771 1772 9 3 7 2 r9 r10 r11 60
jmp road_done_9
label road_verge_10
meshvertex 1770 r0 r1 r2
meshvertex 1771 r3 r4 r5
meshvertex 1772 r6 r7 r8
localget r0 8
add r0 0
mul r0 91
localget r1 22
sub r1 32768
div r1 9
meshtexuv 1770 r1 r0
meshread r0 r1 r2 1770
div r2 350
add r2 90
cmp r2 220
jle road_verge_plain_11_1770
set r2 220
label road_verge_plain_11_1770
meshshade 1770 r2
localget r0 8
add r0 1
mul r0 91
localget r1 22
sub r1 32768
div r1 9
meshtexuv 1771 r1 r0
meshread r0 r1 r2 1771
div r2 350
add r2 90
cmp r2 220
jle road_verge_plain_11_1771
set r2 220
label road_verge_plain_11_1771
meshshade 1771 r2
localget r0 8
add r0 1
mul r0 91
localget r1 24
sub r1 32768
div r1 9
meshtexuv 1772 r1 r0
meshread r0 r1 r2 1772
div r2 350
add r2 90
cmp r2 220
jle road_verge_plain_11_1772
set r2 220
label road_verge_plain_11_1772
meshshade 1772 r2
localget r9 18
mov r10 r9
div r10 2
mov r11 r10
mul r11 9
div r11 16
mul r9 85
div r9 100
meshfacegradienttex 1770 1771 1772 12 8 6 3 r9 r10 r11 60
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
jne material_skip_23
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 4 r9 r10 r11 60
jmp triangle_emitted_22
label material_skip_23
cmp r9 208
jne material_skip_24
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 9 r9 r10 r11 60
jmp triangle_emitted_22
label material_skip_24
cmp r9 108
jne material_skip_25
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 6 r9 r10 r11 60
jmp triangle_emitted_22
label material_skip_25
cmp r9 206
jne material_skip_26
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 7 r9 r10 r11 60
jmp triangle_emitted_22
label material_skip_26
cmp r9 204
jne material_skip_27
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 8 r9 r10 r11 60
jmp triangle_emitted_22
label material_skip_27
label triangle_emitted_22
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
cmp r9 78
je road_verge_17
cmp r9 108
jne road_plain_15
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
localget r12 8
mod r12 7
cmp r12 3
jle asphalt_darker_19
set r12 42
jmp asphalt_tone_done_20
label asphalt_darker_19
set r12 40
label asphalt_tone_done_20
localget r0 8
add r0 5500
load8 r0 $r0
cmp r0 4
jge wet_road_21
meshfacegradienttex 1770 1771 1772 r12 12 5 3 r9 r10 r11 60
jmp road_done_16
label wet_road_21
meshfacegradienttex 1770 1771 1772 9 3 7 2 r9 r10 r11 60
jmp road_done_16
label road_verge_17
meshvertex 1770 r0 r1 r2
meshvertex 1771 r3 r4 r5
meshvertex 1772 r6 r7 r8
localget r0 8
add r0 0
mul r0 91
localget r1 22
sub r1 32768
div r1 9
meshtexuv 1770 r1 r0
meshread r0 r1 r2 1770
div r2 350
add r2 90
cmp r2 220
jle road_verge_plain_18_1770
set r2 220
label road_verge_plain_18_1770
meshshade 1770 r2
localget r0 8
add r0 1
mul r0 91
localget r1 24
sub r1 32768
div r1 9
meshtexuv 1771 r1 r0
meshread r0 r1 r2 1771
div r2 350
add r2 90
cmp r2 220
jle road_verge_plain_18_1771
set r2 220
label road_verge_plain_18_1771
meshshade 1771 r2
localget r0 8
add r0 0
mul r0 91
localget r1 24
sub r1 32768
div r1 9
meshtexuv 1772 r1 r0
meshread r0 r1 r2 1772
div r2 350
add r2 90
cmp r2 220
jle road_verge_plain_18_1772
set r2 220
label road_verge_plain_18_1772
meshshade 1772 r2
localget r9 18
mov r10 r9
div r10 2
mov r11 r10
mul r11 9
div r11 16
mul r9 85
div r9 100
meshfacegradienttex 1770 1771 1772 12 8 6 3 r9 r10 r11 60
jmp road_done_16
label road_plain_15
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
jne material_skip_29
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 4 r9 r10 r11 60
jmp triangle_emitted_28
label material_skip_29
cmp r9 208
jne material_skip_30
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 9 r9 r10 r11 60
jmp triangle_emitted_28
label material_skip_30
cmp r9 108
jne material_skip_31
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 6 r9 r10 r11 60
jmp triangle_emitted_28
label material_skip_31
cmp r9 206
jne material_skip_32
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 7 r9 r10 r11 60
jmp triangle_emitted_28
label material_skip_32
cmp r9 204
jne material_skip_33
mov r9 r10
mul r9 170
div r9 100
meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 8 r9 r10 r11 60
jmp triangle_emitted_28
label material_skip_33
label triangle_emitted_28
label road_done_16
label next_band
localget r0 9
add r0 1
localset 9 r0
cmp r0 7
jlt road_band
label next_segment
localget r0 8
add r0 1
localset 8 r0
localget r1 3201
cmp r0 r1
jlt road_segment
load32 r12 100
sub r12 2000000
load32 r13 104
sub r13 2000000
load16 r0 108
mov r3 r0
add r3 0
mod r3 4096
cmp r3 0
jge sin_negative_34
add r3 4096
label sin_negative_34
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
jlt sin_done_35
mul r5 -1
label sin_done_35
mov r3 r5
mov r6 r3
mov r9 r6
add r9 32768
localset 58 r9
mov r4 r0
add r4 1024
mod r4 4096
cmp r4 0
jge sin_negative_36
add r4 4096
label sin_negative_36
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
jlt sin_done_37
mul r5 -1
label sin_done_37
mov r4 r5
localget r3 58
sub r3 32768
localset 3330 r3
localset 3331 r4
localset 3300 0
jmp open_object_dispatch
label open_object_transform
localset 3302 0
label open_object_vertex
localget r8 3302
mov r9 r8
add r9 1900
meshread r0 r1 r2 r9
localget r3 3310
add r0 r3
mov r9 r8
add r9 3400
localget r9 r9
cmp r9 0
je open_object_motion_done
load32 r3 115
mod r3 40
cmp r3 20
jle open_flap_fold
set r4 40
sub r4 r3
mov r3 r4
label open_flap_fold
sub r3 10
cmp r9 1
jne open_leg_motion
mul r3 3
add r1 r3
jmp open_object_motion_done
label open_leg_motion
mul r3 r9
add r2 r3
label open_object_motion_done
localget r3 3312
cmp r3 0
je open_water_vertex_ready
mov r3 r0
div r3 50
load32 r4 115
div r4 8
add r3 r4
mov r4 r2
div r4 35
localget r9 3302
add r9 1900
meshtexuv r9 r3 r4
add r3 r4
mod r3 64
cmp r3 32
jle open_wave_fold
set r4 64
sub r4 r3
mov r3 r4
label open_wave_fold
mul r3 3
add r3 110
localset 3311 r3
label open_water_vertex_ready
localget r3 3315
cmp r3 0
je wetlands_hop_done
load32 r3 115
mod r3 24
cmp r3 12
jle wetlands_hop_fold
set r4 24
sub r4 r3
mov r3 r4
label wetlands_hop_fold
add r1 r3
label wetlands_hop_done
localget r3 3314
cmp r3 0
je wetlands_car_ready
load8 r3 203
cmp r3 1
jne wetlands_car_track
mul r0 96
div r0 100
mul r2 113
div r2 100
cmp r1 74
jle wetlands_car_pose
add r1 18
jmp wetlands_car_pose
label wetlands_car_track
cmp r3 2
jne wetlands_car_pose
mul r0 114
div r0 100
mul r2 92
div r2 100
cmp r1 77
jle wetlands_car_pose
sub r1 14
label wetlands_car_pose
load16 r3 508
sub r3 32768
mov r4 r3
mul r4 r0
div r4 22528
add r1 r4
load16 r4 504
sub r4 32768
mov r5 r4
mul r5 r2
div r5 35840
add r1 r5
load16 r3 512
sub r3 32768
div r3 256
add r1 r3
localget r3 3331
mul r3 r0
localget r4 3330
mul r4 r2
add r3 r4
div r3 16384
localget r4 3331
mul r4 r2
localget r5 3330
mul r5 r0
sub r4 r5
div r4 16384
load32 r0 100
sub r0 2000000
add r0 r3
load32 r2 104
sub r2 2000000
add r2 r4
load16 r3 520
add r1 r3
load16 r3 384
add r1 r3
label wetlands_car_ready
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
localget r8 3302
mov r9 r8
add r9 2000
meshvertex r9 r0 r1 r2
mov r3 r8
add r3 1900
meshtexcopy r9 r3
localget r4 3311
meshshade r9 r4
add r8 1
localset 3302 r8
localget r9 3301
cmp r8 r9
jlt open_object_vertex
jmp open_object_draw
label open_object_dispatch
localget r0 3300
cmp r0 0
jne open_object_skip_38
localget r0 3200
cmp r0 1
jgt open_object_next
localget r0 3201
cmp r0 0
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -650 1 -1200
localset 3400 0
meshtexuv 1900 -26 -48
meshvertex 1901 650 1 -1200
localset 3401 0
meshtexuv 1901 26 -48
meshvertex 1902 650 1 1000
localset 3402 0
meshtexuv 1902 26 40
meshvertex 1903 -650 1 1000
localset 3403 0
meshtexuv 1903 -26 40
localset 3301 4
jmp open_object_transform
label open_object_skip_38
localget r0 3300
cmp r0 1
jne open_object_skip_40
localget r0 3200
cmp r0 66
jgt open_object_next
localget r0 3201
cmp r0 65
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -7704 -95 129696
localset 3400 0
meshtexuv 1900 -308 5188
meshvertex 1901 -7248 -96 131511
localset 3401 0
meshtexuv 1901 -290 5260
meshvertex 1902 4452 -96 128845
localset 3402 0
meshtexuv 1902 178 5154
meshvertex 1903 3936 -95 126780
localset 3403 0
meshtexuv 1903 157 5071
localset 3301 4
jmp open_object_transform
label open_object_skip_40
localget r0 3300
cmp r0 2
jne open_object_skip_42
localget r0 3200
cmp r0 50
jgt open_object_next
localget r0 3201
cmp r0 49
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -4335 0 97037
localset 3400 0
meshtexuv 1900 -173 3881
meshvertex 1901 -4733 0 98959
localset 3401 0
meshtexuv 1901 -189 3958
meshvertex 1902 -178 0 99706
localset 3402 0
meshtexuv 1902 -7 3988
meshvertex 1903 185 0 97973
localset 3403 0
meshtexuv 1903 7 3919
localset 3301 4
jmp open_object_transform
label open_object_skip_42
localget r0 3300
cmp r0 3
jne open_object_skip_44
localget r0 3200
cmp r0 50
jgt open_object_next
localget r0 3201
cmp r0 49
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -4795 184 96942
localset 3400 0
meshtexuv 1900 -192 3878
meshvertex 1901 -5197 180 98883
localset 3401 0
meshtexuv 1901 -208 3955
meshvertex 1902 -4733 0 98959
localset 3402 0
meshtexuv 1902 -189 3958
meshvertex 1903 -4335 0 97037
localset 3403 0
meshtexuv 1903 -173 3881
localset 3301 4
jmp open_object_transform
label open_object_skip_44
localget r0 3300
cmp r0 4
jne open_object_skip_46
localget r0 3200
cmp r0 51
jgt open_object_next
localget r0 3201
cmp r0 50
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -4826 0 98944
localset 3400 0
meshtexuv 1900 -193 3958
meshvertex 1901 -5145 0 100879
localset 3401 0
meshtexuv 1901 -206 4035
meshvertex 1902 -340 0 101442
localset 3402 0
meshtexuv 1902 -14 4058
meshvertex 1903 -53 0 99727
localset 3403 0
meshtexuv 1903 -2 3989
localset 3301 4
jmp open_object_transform
label open_object_skip_46
localget r0 3300
cmp r0 5
jne open_object_skip_48
localget r0 3200
cmp r0 51
jgt open_object_next
localget r0 3201
cmp r0 50
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -5197 180 98883
localset 3400 0
meshtexuv 1900 -208 3955
meshvertex 1901 -5518 174 100835
localset 3401 0
meshtexuv 1901 -221 4033
meshvertex 1902 -5145 0 100879
localset 3402 0
meshtexuv 1902 -206 4035
meshvertex 1903 -4826 0 98944
localset 3403 0
meshtexuv 1903 -193 3958
localset 3301 4
jmp open_object_transform
label open_object_skip_48
localget r0 3300
cmp r0 6
jne open_object_skip_50
localget r0 3200
cmp r0 52
jgt open_object_next
localget r0 3201
cmp r0 51
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -5190 0 100874
localset 3400 0
meshtexuv 1900 -208 4035
meshvertex 1901 -5419 0 102819
localset 3401 0
meshtexuv 1901 -217 4113
meshvertex 1902 -401 0 103143
localset 3402 0
meshtexuv 1902 -16 4126
meshvertex 1903 -196 0 101459
localset 3403 0
meshtexuv 1903 -8 4058
localset 3301 4
jmp open_object_transform
label open_object_skip_50
localget r0 3300
cmp r0 7
jne open_object_skip_52
localget r0 3200
cmp r0 52
jgt open_object_next
localget r0 3201
cmp r0 51
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -5518 174 100835
localset 3400 0
meshtexuv 1900 -221 4033
meshvertex 1901 -5748 167 102798
localset 3401 0
meshtexuv 1901 -230 4112
meshvertex 1902 -5419 0 102819
localset 3402 0
meshtexuv 1902 -217 4113
meshvertex 1903 -5190 0 100874
localset 3403 0
meshtexuv 1903 -208 4035
localset 3301 4
jmp open_object_transform
label open_object_skip_52
localget r0 3300
cmp r0 8
jne open_object_skip_54
localget r0 3200
cmp r0 53
jgt open_object_next
localget r0 3201
cmp r0 52
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -5387 0 102821
localset 3400 0
meshtexuv 1900 -215 4113
meshvertex 1901 -5515 0 104775
localset 3401 0
meshtexuv 1901 -221 4191
meshvertex 1902 -375 0 104838
localset 3402 0
meshtexuv 1902 -15 4194
meshvertex 1903 -257 0 103152
localset 3403 0
meshtexuv 1903 -10 4126
localset 3301 4
jmp open_object_transform
label open_object_skip_54
localget r0 3300
cmp r0 9
jne open_object_skip_56
localget r0 3200
cmp r0 53
jgt open_object_next
localget r0 3201
cmp r0 52
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -5748 167 102798
localset 3400 0
meshtexuv 1900 -230 4112
meshvertex 1901 -5877 157 104771
localset 3401 0
meshtexuv 1901 -235 4191
meshvertex 1902 -5515 0 104775
localset 3402 0
meshtexuv 1902 -221 4191
meshvertex 1903 -5387 0 102821
localset 3403 0
meshtexuv 1903 -215 4113
localset 3301 4
jmp open_object_transform
label open_object_skip_56
localget r0 3300
cmp r0 10
jne open_object_skip_58
localget r0 3200
cmp r0 54
jgt open_object_next
localget r0 3201
cmp r0 53
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -5426 0 104776
localset 3400 0
meshtexuv 1900 -217 4191
meshvertex 1901 -5450 0 106727
localset 3401 0
meshtexuv 1901 -218 4269
meshvertex 1902 -279 0 106512
localset 3402 0
meshtexuv 1902 -11 4260
meshvertex 1903 -251 0 104840
localset 3403 0
meshtexuv 1903 -10 4194
localset 3301 4
jmp open_object_transform
label open_object_skip_58
localget r0 3300
cmp r0 11
jne open_object_skip_60
localget r0 3200
cmp r0 54
jgt open_object_next
localget r0 3201
cmp r0 53
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -5877 157 104771
localset 3400 0
meshtexuv 1900 -235 4191
meshvertex 1901 -5900 146 106745
localset 3401 0
meshtexuv 1901 -236 4270
meshvertex 1902 -5450 0 106727
localset 3402 0
meshtexuv 1902 -218 4269
meshvertex 1903 -5426 0 104776
localset 3403 0
meshtexuv 1903 -217 4191
localset 3301 4
jmp open_object_transform
label open_object_skip_60
localget r0 3300
cmp r0 12
jne open_object_skip_62
localget r0 3200
cmp r0 55
jgt open_object_next
localget r0 3201
cmp r0 54
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -5362 0 106723
localset 3400 0
meshtexuv 1900 -214 4269
meshvertex 1901 -5282 0 108670
localset 3401 0
meshtexuv 1901 -211 4347
meshvertex 1902 -132 0 108186
localset 3402 0
meshtexuv 1902 -5 4327
meshvertex 1903 -193 0 106509
localset 3403 0
meshtexuv 1903 -8 4260
localset 3301 4
jmp open_object_transform
label open_object_skip_62
localget r0 3300
cmp r0 13
jne open_object_skip_64
localget r0 3200
cmp r0 55
jgt open_object_next
localget r0 3201
cmp r0 54
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -5900 146 106745
localset 3400 0
meshtexuv 1900 -236 4270
meshvertex 1901 -5819 135 108720
localset 3401 0
meshtexuv 1901 -233 4349
meshvertex 1902 -5282 0 108670
localset 3402 0
meshtexuv 1902 -211 4347
meshvertex 1903 -5362 0 106723
localset 3403 0
meshtexuv 1903 -214 4269
localset 3301 4
jmp open_object_transform
label open_object_skip_64
localget r0 3300
cmp r0 14
jne open_object_skip_66
localget r0 3200
cmp r0 56
jgt open_object_next
localget r0 3201
cmp r0 55
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -5252 0 108667
localset 3400 0
meshtexuv 1900 -210 4347
meshvertex 1901 -5072 0 110612
localset 3401 0
meshtexuv 1901 -203 4424
meshvertex 1902 58 0 109891
localset 3402 0
meshtexuv 1902 2 4396
meshvertex 1903 -95 0 108183
localset 3403 0
meshtexuv 1903 -4 4327
localset 3301 4
jmp open_object_transform
label open_object_skip_66
localget r0 3300
cmp r0 15
jne open_object_skip_68
localget r0 3200
cmp r0 56
jgt open_object_next
localget r0 3201
cmp r0 55
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -5819 135 108720
localset 3400 0
meshtexuv 1900 -233 4349
meshvertex 1901 -5635 123 110691
localset 3401 0
meshtexuv 1901 -225 4428
meshvertex 1902 -5072 0 110612
localset 3402 0
meshtexuv 1902 -203 4424
meshvertex 1903 -5252 0 108667
localset 3403 0
meshtexuv 1903 -210 4347
localset 3301 4
jmp open_object_transform
label open_object_skip_68
localget r0 3300
cmp r0 16
jne open_object_skip_70
localget r0 3200
cmp r0 57
jgt open_object_next
localget r0 3201
cmp r0 56
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -5118 0 110619
localset 3400 0
meshtexuv 1900 -205 4425
meshvertex 1901 -4847 0 112559
localset 3401 0
meshtexuv 1901 -194 4502
meshvertex 1902 278 0 111621
localset 3402 0
meshtexuv 1902 11 4465
meshvertex 1903 41 0 109894
localset 3403 0
meshtexuv 1903 2 4396
localset 3301 4
jmp open_object_transform
label open_object_skip_70
localget r0 3300
cmp r0 17
jne open_object_skip_72
localget r0 3200
cmp r0 57
jgt open_object_next
localget r0 3201
cmp r0 56
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -5635 123 110691
localset 3400 0
meshtexuv 1900 -225 4428
meshvertex 1901 -5360 112 112653
localset 3401 0
meshtexuv 1901 -214 4506
meshvertex 1902 -4847 0 112559
localset 3402 0
meshtexuv 1902 -194 4502
meshvertex 1903 -5118 0 110619
localset 3403 0
meshtexuv 1903 -205 4425
localset 3301 4
jmp open_object_transform
label open_object_skip_72
localget r0 3300
cmp r0 18
jne open_object_skip_74
localget r0 3200
cmp r0 58
jgt open_object_next
localget r0 3201
cmp r0 57
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -4939 0 112576
localset 3400 0
meshtexuv 1900 -198 4503
meshvertex 1901 -4585 0 114514
localset 3401 0
meshtexuv 1901 -183 4581
meshvertex 1902 531 0 113398
localset 3402 0
meshtexuv 1902 21 4536
meshvertex 1903 211 0 111633
localset 3403 0
meshtexuv 1903 8 4465
localset 3301 4
jmp open_object_transform
label open_object_skip_74
localget r0 3300
cmp r0 19
jne open_object_skip_76
localget r0 3200
cmp r0 58
jgt open_object_next
localget r0 3201
cmp r0 57
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -5360 112 112653
localset 3400 0
meshtexuv 1900 -214 4506
meshvertex 1901 -5003 102 114605
localset 3401 0
meshtexuv 1901 -200 4584
meshvertex 1902 -4585 0 114514
localset 3402 0
meshtexuv 1902 -183 4581
meshvertex 1903 -4939 0 112576
localset 3403 0
meshtexuv 1903 -198 4503
localset 3301 4
jmp open_object_transform
label open_object_skip_76
localget r0 3300
cmp r0 20
jne open_object_skip_78
localget r0 3200
cmp r0 59
jgt open_object_next
localget r0 3201
cmp r0 58
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -4663 0 114531
localset 3400 0
meshtexuv 1900 -187 4581
meshvertex 1901 -4241 0 116463
localset 3401 0
meshtexuv 1901 -170 4659
meshvertex 1902 812 0 115214
localset 3402 0
meshtexuv 1902 32 4609
meshvertex 1903 422 0 113422
localset 3403 0
meshtexuv 1903 17 4537
localset 3301 4
jmp open_object_transform
label open_object_skip_78
localget r0 3300
cmp r0 21
jne open_object_skip_80
localget r0 3200
cmp r0 59
jgt open_object_next
localget r0 3201
cmp r0 58
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -5003 102 114605
localset 3400 0
meshtexuv 1900 -200 4584
meshvertex 1901 -4579 93 116547
localset 3401 0
meshtexuv 1901 -183 4662
meshvertex 1902 -4241 0 116463
localset 3402 0
meshtexuv 1902 -170 4659
meshvertex 1903 -4663 0 114531
localset 3403 0
meshtexuv 1903 -187 4581
localset 3301 4
jmp open_object_transform
label open_object_skip_80
localget r0 3300
cmp r0 22
jne open_object_skip_82
localget r0 3200
cmp r0 60
jgt open_object_next
localget r0 3201
cmp r0 59
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -4254 0 116467
localset 3400 0
meshtexuv 1900 -170 4659
meshvertex 1901 -3778 0 118395
localset 3401 0
meshtexuv 1901 -151 4736
meshvertex 1902 1130 0 117085
localset 3402 0
meshtexuv 1902 45 4683
meshvertex 1903 677 0 115248
localset 3403 0
meshtexuv 1903 27 4610
localset 3301 4
jmp open_object_transform
label open_object_skip_82
localget r0 3300
cmp r0 23
jne open_object_skip_84
localget r0 3200
cmp r0 60
jgt open_object_next
localget r0 3201
cmp r0 59
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -4579 93 116547
localset 3400 0
meshtexuv 1900 -183 4662
meshvertex 1901 -4101 85 118481
localset 3401 0
meshtexuv 1901 -164 4739
meshvertex 1902 -3778 0 118395
localset 3402 0
meshtexuv 1902 -151 4736
meshvertex 1903 -4254 0 116467
localset 3403 0
meshtexuv 1903 -170 4659
localset 3301 4
jmp open_object_transform
label open_object_skip_84
localget r0 3300
cmp r0 24
jne open_object_skip_86
localget r0 3200
cmp r0 61
jgt open_object_next
localget r0 3201
cmp r0 60
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -3719 0 118379
localset 3400 0
meshtexuv 1900 -149 4735
meshvertex 1901 -3206 0 120301
localset 3401 0
meshtexuv 1901 -128 4812
meshvertex 1902 1484 0 118987
localset 3402 0
meshtexuv 1902 59 4759
meshvertex 1903 988 0 117123
localset 3403 0
meshtexuv 1903 40 4685
localset 3301 4
jmp open_object_transform
label open_object_skip_86
localget r0 3300
cmp r0 25
jne open_object_skip_88
localget r0 3200
cmp r0 61
jgt open_object_next
localget r0 3201
cmp r0 60
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -4101 85 118481
localset 3400 0
meshtexuv 1900 -164 4739
meshvertex 1901 -3588 79 120408
localset 3401 0
meshtexuv 1901 -144 4816
meshvertex 1902 -3206 0 120301
localset 3402 0
meshtexuv 1902 -128 4812
meshvertex 1903 -3719 0 118379
localset 3403 0
meshtexuv 1903 -149 4735
localset 3301 4
jmp open_object_transform
label open_object_skip_88
localget r0 3300
cmp r0 26
jne open_object_skip_90
localget r0 3200
cmp r0 62
jgt open_object_next
localget r0 3201
cmp r0 61
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -3113 0 120275
localset 3400 0
meshtexuv 1900 -125 4811
meshvertex 1901 -2576 0 122198
localset 3401 0
meshtexuv 1901 -103 4888
meshvertex 1902 1887 0 120934
localset 3402 0
meshtexuv 1902 75 4837
meshvertex 1903 1353 0 119024
localset 3403 0
meshtexuv 1903 54 4761
localset 3301 4
jmp open_object_transform
label open_object_skip_90
localget r0 3300
cmp r0 27
jne open_object_skip_92
localget r0 3200
cmp r0 62
jgt open_object_next
localget r0 3201
cmp r0 61
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -3588 79 120408
localset 3400 0
meshtexuv 1900 -144 4816
meshvertex 1901 -3050 75 122332
localset 3401 0
meshtexuv 1901 -122 4893
meshvertex 1902 -2576 0 122198
localset 3402 0
meshtexuv 1902 -103 4888
meshvertex 1903 -3113 0 120275
localset 3403 0
meshtexuv 1903 -125 4811
localset 3301 4
jmp open_object_transform
label open_object_skip_92
localget r0 3300
cmp r0 28
jne open_object_skip_94
localget r0 3200
cmp r0 63
jgt open_object_next
localget r0 3201
cmp r0 62
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -2509 0 122179
localset 3400 0
meshtexuv 1900 -100 4887
meshvertex 1901 -1964 0 124109
localset 3401 0
meshtexuv 1901 -79 4964
meshvertex 1902 2335 0 122912
localset 3402 0
meshtexuv 1902 93 4916
meshvertex 1903 1785 0 120962
localset 3403 0
meshtexuv 1903 71 4838
localset 3301 4
jmp open_object_transform
label open_object_skip_94
localget r0 3300
cmp r0 29
jne open_object_skip_96
localget r0 3200
cmp r0 63
jgt open_object_next
localget r0 3201
cmp r0 62
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -3050 75 122332
localset 3400 0
meshtexuv 1900 -122 4893
meshvertex 1901 -2505 72 124259
localset 3401 0
meshtexuv 1901 -100 4970
meshvertex 1902 -1964 0 124109
localset 3402 0
meshtexuv 1902 -79 4964
meshvertex 1903 -2509 0 122179
localset 3403 0
meshtexuv 1903 -100 4887
localset 3301 4
jmp open_object_transform
label open_object_skip_96
localget r0 3300
cmp r0 30
jne open_object_skip_98
localget r0 3200
cmp r0 51
jgt open_object_next
localget r0 3201
cmp r0 50
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -4911 60 98931
localset 3400 0
meshtexuv 1900 -196 3957
meshvertex 1901 -4901 170 98931
localset 3401 0
meshtexuv 1901 -196 3957
meshvertex 1902 -4894 60 98931
localset 3402 0
meshtexuv 1902 -196 3957
meshvertex 1903 -4899 60 98940
localset 3403 0
meshtexuv 1903 -196 3958
meshvertex 1904 -4889 160 98940
localset 3404 0
meshtexuv 1904 -196 3958
meshvertex 1905 -4882 60 98940
localset 3405 0
meshtexuv 1905 -195 3958
meshvertex 1906 -4887 60 98949
localset 3406 0
meshtexuv 1906 -195 3958
meshvertex 1907 -4877 150 98949
localset 3407 0
meshtexuv 1907 -195 3958
meshvertex 1908 -4870 60 98949
localset 3408 0
meshtexuv 1908 -195 3958
localset 3301 9
jmp open_object_transform
label open_object_skip_98
localget r0 3300
cmp r0 31
jne open_object_skip_100
localget r0 3200
cmp r0 55
jgt open_object_next
localget r0 3201
cmp r0 54
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -5611 49 106733
localset 3400 0
meshtexuv 1900 -224 4269
meshvertex 1901 -5601 159 106733
localset 3401 0
meshtexuv 1901 -224 4269
meshvertex 1902 -5594 49 106733
localset 3402 0
meshtexuv 1902 -224 4269
meshvertex 1903 -5599 49 106742
localset 3403 0
meshtexuv 1903 -224 4270
meshvertex 1904 -5589 149 106742
localset 3404 0
meshtexuv 1904 -224 4270
meshvertex 1905 -5582 49 106742
localset 3405 0
meshtexuv 1905 -223 4270
meshvertex 1906 -5587 49 106751
localset 3406 0
meshtexuv 1906 -223 4270
meshvertex 1907 -5577 139 106751
localset 3407 0
meshtexuv 1907 -223 4270
meshvertex 1908 -5570 49 106751
localset 3408 0
meshtexuv 1908 -223 4270
localset 3301 9
jmp open_object_transform
label open_object_skip_100
localget r0 3300
cmp r0 32
jne open_object_skip_102
localget r0 3200
cmp r0 61
jgt open_object_next
localget r0 3201
cmp r0 60
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -3821 28 118404
localset 3400 0
meshtexuv 1900 -153 4736
meshvertex 1901 -3811 138 118404
localset 3401 0
meshtexuv 1901 -152 4736
meshvertex 1902 -3804 28 118404
localset 3402 0
meshtexuv 1902 -152 4736
meshvertex 1903 -3809 28 118413
localset 3403 0
meshtexuv 1903 -152 4737
meshvertex 1904 -3799 128 118413
localset 3404 0
meshtexuv 1904 -152 4737
meshvertex 1905 -3792 28 118413
localset 3405 0
meshtexuv 1905 -152 4737
meshvertex 1906 -3797 28 118422
localset 3406 0
meshtexuv 1906 -152 4737
meshvertex 1907 -3787 118 118422
localset 3407 0
meshtexuv 1907 -151 4737
meshvertex 1908 -3780 28 118422
localset 3408 0
meshtexuv 1908 -151 4737
localset 3301 9
jmp open_object_transform
label open_object_skip_102
localget r0 3300
cmp r0 33
jne open_object_skip_104
localget r0 3200
cmp r0 66
jgt open_object_next
localget r0 3201
cmp r0 65
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -1868 70 128311
localset 3400 0
meshtexuv 1900 -75 5132
meshvertex 1901 -1850 70 128311
localset 3401 0
meshtexuv 1901 -74 5132
meshvertex 1902 -1850 160 128311
localset 3402 0
meshtexuv 1902 -74 5132
meshvertex 1903 -1868 160 128311
localset 3403 0
meshtexuv 1903 -75 5132
meshvertex 1904 -1868 70 130211
localset 3404 0
meshtexuv 1904 -75 5208
meshvertex 1905 -1868 160 130211
localset 3405 0
meshtexuv 1905 -75 5208
meshvertex 1906 -1850 160 130211
localset 3406 0
meshtexuv 1906 -74 5208
meshvertex 1907 -1850 70 130211
localset 3407 0
meshtexuv 1907 -74 5208
meshvertex 1908 -1431 70 128206
localset 3408 0
meshtexuv 1908 -57 5128
meshvertex 1909 -1413 70 128206
localset 3409 0
meshtexuv 1909 -57 5128
meshvertex 1910 -1413 160 128206
localset 3410 0
meshtexuv 1910 -57 5128
meshvertex 1911 -1431 160 128206
localset 3411 0
meshtexuv 1911 -57 5128
meshvertex 1912 -1431 70 130106
localset 3412 0
meshtexuv 1912 -57 5204
meshvertex 1913 -1431 160 130106
localset 3413 0
meshtexuv 1913 -57 5204
meshvertex 1914 -1413 160 130106
localset 3414 0
meshtexuv 1914 -57 5204
meshvertex 1915 -1413 70 130106
localset 3415 0
meshtexuv 1915 -57 5204
localset 3301 16
jmp open_object_transform
label open_object_skip_104
localget r0 3300
cmp r0 34
jne open_object_skip_106
localget r0 3200
cmp r0 13
jgt open_object_next
localget r0 3201
cmp r0 12
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 670 69 24033
localset 3400 0
meshtexuv 1900 27 961
meshvertex 1901 874 70 25972
localset 3401 0
meshtexuv 1901 35 1039
meshvertex 1902 2868 70 25809
localset 3402 0
meshtexuv 1902 115 1032
meshvertex 1903 2659 69 23825
localset 3403 0
meshtexuv 1903 106 953
localset 3301 4
jmp open_object_transform
label open_object_skip_106
localget r0 3300
cmp r0 35
jne open_object_skip_108
localget r0 3200
cmp r0 14
jgt open_object_next
localget r0 3201
cmp r0 13
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 874 70 25972
localset 3400 0
meshtexuv 1900 35 1039
meshvertex 1901 1034 71 27911
localset 3401 0
meshtexuv 1901 41 1116
meshvertex 1902 3030 71 27797
localset 3402 0
meshtexuv 1902 121 1112
meshvertex 1903 2868 70 25809
localset 3403 0
meshtexuv 1903 115 1032
localset 3301 4
jmp open_object_transform
label open_object_skip_108
localget r0 3300
cmp r0 36
jne open_object_skip_110
localget r0 3200
cmp r0 44
jgt open_object_next
localget r0 3201
cmp r0 43
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -1715 177 85385
localset 3400 0
meshtexuv 1900 -69 3415
meshvertex 1901 -2306 180 87297
localset 3401 0
meshtexuv 1901 -92 3492
meshvertex 1902 -397 180 87892
localset 3402 0
meshtexuv 1902 -16 3516
meshvertex 1903 195 177 85978
localset 3403 0
meshtexuv 1903 8 3439
localset 3301 4
jmp open_object_transform
label open_object_skip_110
localget r0 3300
cmp r0 37
jne open_object_skip_112
localget r0 3200
cmp r0 45
jgt open_object_next
localget r0 3201
cmp r0 44
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -2306 180 87297
localset 3400 0
meshtexuv 1900 -92 3492
meshvertex 1901 -2900 183 89204
localset 3401 0
meshtexuv 1901 -116 3568
meshvertex 1902 -987 183 89788
localset 3402 0
meshtexuv 1902 -39 3592
meshvertex 1903 -397 180 87892
localset 3403 0
meshtexuv 1903 -16 3516
localset 3301 4
jmp open_object_transform
label open_object_skip_112
localget r0 3300
cmp r0 38
jne open_object_skip_114
localget r0 3200
cmp r0 77
jgt open_object_next
localget r0 3201
cmp r0 76
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -1751 18 149932
localset 3400 0
meshtexuv 1900 -70 5997
meshvertex 1901 -1834 12 151904
localset 3401 0
meshtexuv 1901 -73 6076
meshvertex 1902 163 12 152011
localset 3402 0
meshtexuv 1902 7 6080
meshvertex 1903 247 18 150015
localset 3403 0
meshtexuv 1903 10 6001
localset 3301 4
jmp open_object_transform
label open_object_skip_114
localget r0 3300
cmp r0 39
jne open_object_skip_116
localget r0 3200
cmp r0 78
jgt open_object_next
localget r0 3201
cmp r0 77
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -1834 12 151904
localset 3400 0
meshtexuv 1900 -73 6076
meshvertex 1901 -1939 6 153884
localset 3401 0
meshtexuv 1901 -78 6155
meshvertex 1902 57 6 154007
localset 3402 0
meshtexuv 1902 2 6160
meshvertex 1903 163 12 152011
localset 3403 0
meshtexuv 1903 7 6080
localset 3301 4
jmp open_object_transform
label open_object_skip_116
localget r0 3300
cmp r0 40
jne open_object_skip_118
localget r0 3200
cmp r0 16
jgt open_object_next
localget r0 3201
cmp r0 15
jle open_object_next
load8 r0 139
cmp r0 1
je open_object_next
load8 r0 526
cmp r0 2
je open_object_next
load32 r0 100
sub r0 2003344
mul r0 r0
load32 r1 104
sub r1 2029783
mul r1 r1
add r0 r1
cmp r0 100000000
jgt open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
load32 r0 115
mod r0 200
cmp r0 100
jle open_object_active_119
set r1 200
sub r1 r0
mov r0 r1
label open_object_active_119
sub r0 50
div r0 2
localset 3310 r0
meshvertex 1900 4173 130 29689
localset 3400 0
meshtexuv 1900 167 1188
meshvertex 1901 4215 130 29689
localset 3401 0
meshtexuv 1901 169 1188
meshvertex 1902 4215 182 29689
localset 3402 0
meshtexuv 1902 169 1188
meshvertex 1903 4173 182 29689
localset 3403 0
meshtexuv 1903 167 1188
meshvertex 1904 4173 130 29819
localset 3404 0
meshtexuv 1904 167 1193
meshvertex 1905 4173 182 29819
localset 3405 0
meshtexuv 1905 167 1193
meshvertex 1906 4215 182 29819
localset 3406 0
meshtexuv 1906 169 1193
meshvertex 1907 4215 130 29819
localset 3407 0
meshtexuv 1907 169 1193
meshvertex 1908 4181 162 29805
localset 3408 0
meshtexuv 1908 167 1192
meshvertex 1909 4207 162 29805
localset 3409 0
meshtexuv 1909 168 1192
meshvertex 1910 4207 207 29805
localset 3410 0
meshtexuv 1910 168 1192
meshvertex 1911 4181 207 29805
localset 3411 0
meshtexuv 1911 167 1192
meshvertex 1912 4181 162 29839
localset 3412 0
meshtexuv 1912 167 1194
meshvertex 1913 4181 207 29839
localset 3413 0
meshtexuv 1913 167 1194
meshvertex 1914 4207 207 29839
localset 3414 0
meshtexuv 1914 168 1194
meshvertex 1915 4207 162 29839
localset 3415 0
meshtexuv 1915 168 1194
meshvertex 1916 4172 138 29711
localset 3416 0
meshtexuv 1916 167 1188
meshvertex 1917 4182 138 29711
localset 3417 0
meshtexuv 1917 167 1188
meshvertex 1918 4181 70 29717
localset 3418 2
meshtexuv 1918 167 1189
meshvertex 1919 4173 70 29717
localset 3419 2
meshtexuv 1919 167 1189
meshvertex 1920 4172 138 29797
localset 3420 0
meshtexuv 1920 167 1192
meshvertex 1921 4182 138 29797
localset 3421 0
meshtexuv 1921 167 1192
meshvertex 1922 4181 70 29803
localset 3422 -2
meshtexuv 1922 167 1192
meshvertex 1923 4173 70 29803
localset 3423 -2
meshtexuv 1923 167 1192
meshvertex 1924 4206 138 29711
localset 3424 0
meshtexuv 1924 168 1188
meshvertex 1925 4216 138 29711
localset 3425 0
meshtexuv 1925 169 1188
meshvertex 1926 4215 70 29717
localset 3426 -2
meshtexuv 1926 169 1189
meshvertex 1927 4207 70 29717
localset 3427 -2
meshtexuv 1927 168 1189
meshvertex 1928 4206 138 29797
localset 3428 0
meshtexuv 1928 168 1192
meshvertex 1929 4216 138 29797
localset 3429 0
meshtexuv 1929 169 1192
meshvertex 1930 4215 70 29803
localset 3430 2
meshtexuv 1930 169 1192
meshvertex 1931 4207 70 29803
localset 3431 2
meshtexuv 1931 168 1192
meshvertex 1932 4185 202 29818
localset 3432 0
meshtexuv 1932 167 1193
meshvertex 1933 4172 225 29813
localset 3433 0
meshtexuv 1933 167 1193
meshvertex 1934 4192 209 29823
localset 3434 0
meshtexuv 1934 168 1193
meshvertex 1935 4203 202 29818
localset 3435 0
meshtexuv 1935 168 1193
meshvertex 1936 4216 225 29813
localset 3436 0
meshtexuv 1936 169 1193
meshvertex 1937 4196 209 29823
localset 3437 0
meshtexuv 1937 168 1193
meshvertex 1938 4156 71 29669
localset 3438 0
meshtexuv 1938 166 1187
meshvertex 1939 4232 71 29669
localset 3439 0
meshtexuv 1939 169 1187
meshvertex 1940 4232 71 29839
localset 3440 0
meshtexuv 1940 169 1194
meshvertex 1941 4156 71 29839
localset 3441 0
meshtexuv 1941 166 1194
localset 3301 42
jmp open_object_transform
label open_object_skip_118
localget r0 3300
cmp r0 41
jne open_object_skip_120
localget r0 3200
cmp r0 44
jgt open_object_next
localget r0 3201
cmp r0 43
jle open_object_next
load8 r0 139
cmp r0 1
je open_object_next
load8 r0 526
cmp r0 2
je open_object_next
load32 r0 100
sub r0 1998094
mul r0 r0
load32 r1 104
sub r1 2085326
mul r1 r1
add r0 r1
cmp r0 100000000
jgt open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
load32 r0 115
mod r0 200
cmp r0 100
jle open_object_active_121
set r1 200
sub r1 r0
mov r0 r1
label open_object_active_121
sub r0 50
div r0 2
localset 3310 r0
meshvertex 1900 -2739 235 85009
localset 3400 0
meshtexuv 1900 -110 3400
meshvertex 1901 -2697 235 85009
localset 3401 0
meshtexuv 1901 -108 3400
meshvertex 1902 -2697 287 85009
localset 3402 0
meshtexuv 1902 -108 3400
meshvertex 1903 -2739 287 85009
localset 3403 0
meshtexuv 1903 -110 3400
meshvertex 1904 -2739 235 85139
localset 3404 0
meshtexuv 1904 -110 3406
meshvertex 1905 -2739 287 85139
localset 3405 0
meshtexuv 1905 -110 3406
meshvertex 1906 -2697 287 85139
localset 3406 0
meshtexuv 1906 -108 3406
meshvertex 1907 -2697 235 85139
localset 3407 0
meshtexuv 1907 -108 3406
meshvertex 1908 -2731 267 85125
localset 3408 0
meshtexuv 1908 -109 3405
meshvertex 1909 -2705 267 85125
localset 3409 0
meshtexuv 1909 -108 3405
meshvertex 1910 -2705 312 85125
localset 3410 0
meshtexuv 1910 -108 3405
meshvertex 1911 -2731 312 85125
localset 3411 0
meshtexuv 1911 -109 3405
meshvertex 1912 -2731 267 85159
localset 3412 0
meshtexuv 1912 -109 3406
meshvertex 1913 -2731 312 85159
localset 3413 0
meshtexuv 1913 -109 3406
meshvertex 1914 -2705 312 85159
localset 3414 0
meshtexuv 1914 -108 3406
meshvertex 1915 -2705 267 85159
localset 3415 0
meshtexuv 1915 -108 3406
meshvertex 1916 -2740 243 85031
localset 3416 0
meshtexuv 1916 -110 3401
meshvertex 1917 -2730 243 85031
localset 3417 0
meshtexuv 1917 -109 3401
meshvertex 1918 -2731 175 85037
localset 3418 2
meshtexuv 1918 -109 3401
meshvertex 1919 -2739 175 85037
localset 3419 2
meshtexuv 1919 -110 3401
meshvertex 1920 -2740 243 85117
localset 3420 0
meshtexuv 1920 -110 3405
meshvertex 1921 -2730 243 85117
localset 3421 0
meshtexuv 1921 -109 3405
meshvertex 1922 -2731 175 85123
localset 3422 -2
meshtexuv 1922 -109 3405
meshvertex 1923 -2739 175 85123
localset 3423 -2
meshtexuv 1923 -110 3405
meshvertex 1924 -2706 243 85031
localset 3424 0
meshtexuv 1924 -108 3401
meshvertex 1925 -2696 243 85031
localset 3425 0
meshtexuv 1925 -108 3401
meshvertex 1926 -2697 175 85037
localset 3426 -2
meshtexuv 1926 -108 3401
meshvertex 1927 -2705 175 85037
localset 3427 -2
meshtexuv 1927 -108 3401
meshvertex 1928 -2706 243 85117
localset 3428 0
meshtexuv 1928 -108 3405
meshvertex 1929 -2696 243 85117
localset 3429 0
meshtexuv 1929 -108 3405
meshvertex 1930 -2697 175 85123
localset 3430 2
meshtexuv 1930 -108 3405
meshvertex 1931 -2705 175 85123
localset 3431 2
meshtexuv 1931 -108 3405
meshvertex 1932 -2727 307 85138
localset 3432 0
meshtexuv 1932 -109 3406
meshvertex 1933 -2740 330 85133
localset 3433 0
meshtexuv 1933 -110 3405
meshvertex 1934 -2720 314 85143
localset 3434 0
meshtexuv 1934 -109 3406
meshvertex 1935 -2709 307 85138
localset 3435 0
meshtexuv 1935 -108 3406
meshvertex 1936 -2696 330 85133
localset 3436 0
meshtexuv 1936 -108 3405
meshvertex 1937 -2716 314 85143
localset 3437 0
meshtexuv 1937 -109 3406
meshvertex 1938 -2756 176 84989
localset 3438 0
meshtexuv 1938 -110 3400
meshvertex 1939 -2680 176 84989
localset 3439 0
meshtexuv 1939 -107 3400
meshvertex 1940 -2680 176 85159
localset 3440 0
meshtexuv 1940 -107 3406
meshvertex 1941 -2756 176 85159
localset 3441 0
meshtexuv 1941 -110 3406
localset 3301 42
jmp open_object_transform
label open_object_skip_120
localget r0 3300
cmp r0 42
jne open_object_skip_122
localget r0 3200
cmp r0 75
jgt open_object_next
localget r0 3201
cmp r0 74
jle open_object_next
load8 r0 139
cmp r0 1
je open_object_next
load8 r0 526
cmp r0 2
je open_object_next
load32 r0 100
sub r0 2000514
mul r0 r0
load32 r1 104
sub r1 2146024
mul r1 r1
add r0 r1
cmp r0 100000000
jgt open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
load32 r0 115
mod r0 200
cmp r0 100
jle open_object_active_123
set r1 200
sub r1 r0
mov r0 r1
label open_object_active_123
sub r0 50
div r0 2
localset 3310 r0
meshvertex 1900 1343 92 145966
localset 3400 0
meshtexuv 1900 54 5839
meshvertex 1901 1385 92 145966
localset 3401 0
meshtexuv 1901 55 5839
meshvertex 1902 1385 144 145966
localset 3402 0
meshtexuv 1902 55 5839
meshvertex 1903 1343 144 145966
localset 3403 0
meshtexuv 1903 54 5839
meshvertex 1904 1343 92 146096
localset 3404 0
meshtexuv 1904 54 5844
meshvertex 1905 1343 144 146096
localset 3405 0
meshtexuv 1905 54 5844
meshvertex 1906 1385 144 146096
localset 3406 0
meshtexuv 1906 55 5844
meshvertex 1907 1385 92 146096
localset 3407 0
meshtexuv 1907 55 5844
meshvertex 1908 1351 124 146082
localset 3408 0
meshtexuv 1908 54 5843
meshvertex 1909 1377 124 146082
localset 3409 0
meshtexuv 1909 55 5843
meshvertex 1910 1377 169 146082
localset 3410 0
meshtexuv 1910 55 5843
meshvertex 1911 1351 169 146082
localset 3411 0
meshtexuv 1911 54 5843
meshvertex 1912 1351 124 146116
localset 3412 0
meshtexuv 1912 54 5845
meshvertex 1913 1351 169 146116
localset 3413 0
meshtexuv 1913 54 5845
meshvertex 1914 1377 169 146116
localset 3414 0
meshtexuv 1914 55 5845
meshvertex 1915 1377 124 146116
localset 3415 0
meshtexuv 1915 55 5845
meshvertex 1916 1342 100 145988
localset 3416 0
meshtexuv 1916 54 5840
meshvertex 1917 1352 100 145988
localset 3417 0
meshtexuv 1917 54 5840
meshvertex 1918 1351 32 145994
localset 3418 2
meshtexuv 1918 54 5840
meshvertex 1919 1343 32 145994
localset 3419 2
meshtexuv 1919 54 5840
meshvertex 1920 1342 100 146074
localset 3420 0
meshtexuv 1920 54 5843
meshvertex 1921 1352 100 146074
localset 3421 0
meshtexuv 1921 54 5843
meshvertex 1922 1351 32 146080
localset 3422 -2
meshtexuv 1922 54 5843
meshvertex 1923 1343 32 146080
localset 3423 -2
meshtexuv 1923 54 5843
meshvertex 1924 1376 100 145988
localset 3424 0
meshtexuv 1924 55 5840
meshvertex 1925 1386 100 145988
localset 3425 0
meshtexuv 1925 55 5840
meshvertex 1926 1385 32 145994
localset 3426 -2
meshtexuv 1926 55 5840
meshvertex 1927 1377 32 145994
localset 3427 -2
meshtexuv 1927 55 5840
meshvertex 1928 1376 100 146074
localset 3428 0
meshtexuv 1928 55 5843
meshvertex 1929 1386 100 146074
localset 3429 0
meshtexuv 1929 55 5843
meshvertex 1930 1385 32 146080
localset 3430 2
meshtexuv 1930 55 5843
meshvertex 1931 1377 32 146080
localset 3431 2
meshtexuv 1931 55 5843
meshvertex 1932 1355 164 146095
localset 3432 0
meshtexuv 1932 54 5844
meshvertex 1933 1342 187 146090
localset 3433 0
meshtexuv 1933 54 5844
meshvertex 1934 1362 171 146100
localset 3434 0
meshtexuv 1934 54 5844
meshvertex 1935 1373 164 146095
localset 3435 0
meshtexuv 1935 55 5844
meshvertex 1936 1386 187 146090
localset 3436 0
meshtexuv 1936 55 5844
meshvertex 1937 1366 171 146100
localset 3437 0
meshtexuv 1937 55 5844
meshvertex 1938 1326 33 145946
localset 3438 0
meshtexuv 1938 53 5838
meshvertex 1939 1402 33 145946
localset 3439 0
meshtexuv 1939 56 5838
meshvertex 1940 1402 33 146116
localset 3440 0
meshtexuv 1940 56 5845
meshvertex 1941 1326 33 146116
localset 3441 0
meshtexuv 1941 53 5845
localset 3301 42
jmp open_object_transform
label open_object_skip_122
localget r0 3300
cmp r0 43
jne open_object_skip_124
localget r0 3200
cmp r0 7
jgt open_object_next
localget r0 3201
cmp r0 6
jle open_object_next
load8 r0 139
cmp r0 1
je open_object_next
load8 r0 526
cmp r0 2
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
load32 r0 115
mod r0 200
cmp r0 100
jle open_object_active_125
set r1 200
sub r1 r0
mov r0 r1
label open_object_active_125
sub r0 50
div r0 2
localset 3310 r0
meshvertex 1900 -26 732 12097
localset 3400 0
meshtexuv 1900 -1 484
meshvertex 1901 -91 739 12116
localset 3401 1
meshtexuv 1901 -4 485
meshvertex 1902 -26 732 12137
localset 3402 0
meshtexuv 1902 -1 485
meshvertex 1903 39 739 12116
localset 3403 1
meshtexuv 1903 2 485
localset 3301 4
jmp open_object_transform
label open_object_skip_124
localget r0 3300
cmp r0 44
jne open_object_skip_126
localget r0 3200
cmp r0 22
jgt open_object_next
localget r0 3201
cmp r0 21
jle open_object_next
load8 r0 139
cmp r0 1
je open_object_next
load8 r0 526
cmp r0 2
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
load32 r0 115
mod r0 200
cmp r0 100
jle open_object_active_127
set r1 200
sub r1 r0
mov r0 r1
label open_object_active_127
sub r0 50
div r0 2
localset 3310 r0
meshvertex 1900 2060 793 41695
localset 3400 0
meshtexuv 1900 82 1668
meshvertex 1901 1995 800 41714
localset 3401 1
meshtexuv 1901 80 1669
meshvertex 1902 2060 793 41735
localset 3402 0
meshtexuv 1902 82 1669
meshvertex 1903 2125 800 41714
localset 3403 1
meshtexuv 1903 85 1669
localset 3301 4
jmp open_object_transform
label open_object_skip_126
localget r0 3300
cmp r0 45
jne open_object_skip_128
localget r0 3200
cmp r0 40
jgt open_object_next
localget r0 3201
cmp r0 39
jle open_object_next
load8 r0 139
cmp r0 1
je open_object_next
load8 r0 526
cmp r0 2
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
load32 r0 115
mod r0 200
cmp r0 100
jle open_object_active_129
set r1 200
sub r1 r0
mov r0 r1
label open_object_active_129
sub r0 50
div r0 2
localset 3310 r0
meshvertex 1900 -878 871 77335
localset 3400 0
meshtexuv 1900 -35 3093
meshvertex 1901 -943 878 77354
localset 3401 1
meshtexuv 1901 -38 3094
meshvertex 1902 -878 871 77375
localset 3402 0
meshtexuv 1902 -35 3095
meshvertex 1903 -813 878 77354
localset 3403 1
meshtexuv 1903 -33 3094
localset 3301 4
jmp open_object_transform
label open_object_skip_128
localget r0 3300
cmp r0 46
jne open_object_skip_130
localget r0 3200
cmp r0 68
jgt open_object_next
localget r0 3201
cmp r0 67
jle open_object_next
load8 r0 139
cmp r0 1
je open_object_next
load8 r0 526
cmp r0 2
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
load32 r0 115
mod r0 200
cmp r0 100
jle open_object_active_131
set r1 200
sub r1 r0
mov r0 r1
label open_object_active_131
sub r0 50
div r0 2
localset 3310 r0
meshvertex 1900 -2034 768 132327
localset 3400 0
meshtexuv 1900 -81 5293
meshvertex 1901 -2099 775 132346
localset 3401 1
meshtexuv 1901 -84 5294
meshvertex 1902 -2034 768 132367
localset 3402 0
meshtexuv 1902 -81 5295
meshvertex 1903 -1969 775 132346
localset 3403 1
meshtexuv 1903 -79 5294
localset 3301 4
jmp open_object_transform
label open_object_skip_130
localget r0 3300
cmp r0 47
jne open_object_skip_132
localget r0 3200
cmp r0 52
jgt open_object_next
localget r0 3201
cmp r0 51
jle open_object_next
load8 r0 139
cmp r0 1
je open_object_next
load32 r0 100
sub r0 1994035
mul r0 r0
load32 r1 104
sub r1 2100783
mul r1 r1
add r0 r1
cmp r0 36000000
jgt open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
load32 r0 115
mod r0 200
cmp r0 100
jle open_object_active_133
set r1 200
sub r1 r0
mov r0 r1
label open_object_active_133
sub r0 50
div r0 2
localset 3310 r0
meshvertex 1900 -4781 3 100899
localset 3400 0
meshtexuv 1900 -191 4036
meshvertex 1901 -4762 3 100923
localset 3401 0
meshtexuv 1901 -190 4037
meshvertex 1902 -4781 3 100947
localset 3402 0
meshtexuv 1902 -191 4038
meshvertex 1903 -4781 3 100941
localset 3403 0
meshtexuv 1903 -191 4038
meshvertex 1904 -4791 3 100957
localset 3404 0
meshtexuv 1904 -192 4038
meshvertex 1905 -4767 3 100952
localset 3405 0
meshtexuv 1905 -191 4038
localset 3301 6
jmp open_object_transform
label open_object_skip_132
localget r0 3300
cmp r0 48
jne open_object_skip_134
localget r0 3200
cmp r0 57
jgt open_object_next
localget r0 3201
cmp r0 56
jle open_object_next
load8 r0 139
cmp r0 1
je open_object_next
load32 r0 100
sub r0 1993919
mul r0 r0
load32 r1 104
sub r1 2110754
mul r1 r1
add r0 r1
cmp r0 36000000
jgt open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
load32 r0 115
mod r0 200
cmp r0 100
jle open_object_active_135
set r1 200
sub r1 r0
mov r0 r1
label open_object_active_135
sub r0 50
div r0 2
localset 3310 r0
meshvertex 1900 -4901 3 110563
localset 3400 0
meshtexuv 1900 -196 4423
meshvertex 1901 -4882 3 110587
localset 3401 0
meshtexuv 1901 -195 4423
meshvertex 1902 -4901 3 110611
localset 3402 0
meshtexuv 1902 -196 4424
meshvertex 1903 -4901 3 110605
localset 3403 0
meshtexuv 1903 -196 4424
meshvertex 1904 -4911 3 110621
localset 3404 0
meshtexuv 1904 -196 4425
meshvertex 1905 -4887 3 110616
localset 3405 0
meshtexuv 1905 -195 4425
localset 3301 6
jmp open_object_transform
label open_object_skip_134
localget r0 3300
cmp r0 49
jne open_object_skip_136
localget r0 3200
cmp r0 61
jgt open_object_next
localget r0 3201
cmp r0 60
jle open_object_next
load8 r0 139
cmp r0 1
je open_object_next
load32 r0 100
sub r0 1995464
mul r0 r0
load32 r1 104
sub r1 2118597
mul r1 r1
add r0 r1
cmp r0 36000000
jgt open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
load32 r0 115
mod r0 200
cmp r0 100
jle open_object_active_137
set r1 200
sub r1 r0
mov r0 r1
label open_object_active_137
sub r0 50
div r0 2
localset 3310 r0
meshvertex 1900 -3385 3 118264
localset 3400 0
meshtexuv 1900 -135 4731
meshvertex 1901 -3366 3 118288
localset 3401 0
meshtexuv 1901 -135 4732
meshvertex 1902 -3385 3 118312
localset 3402 0
meshtexuv 1902 -135 4732
meshvertex 1903 -3385 3 118306
localset 3403 0
meshtexuv 1903 -135 4732
meshvertex 1904 -3395 3 118322
localset 3404 0
meshtexuv 1904 -136 4733
meshvertex 1905 -3371 3 118317
localset 3405 0
meshtexuv 1905 -135 4733
localset 3301 6
jmp open_object_transform
label open_object_skip_136
localget r0 3300
cmp r0 50
jne open_object_skip_138
localget r0 3200
cmp r0 12
jgt open_object_next
localget r0 3201
cmp r0 11
jle open_object_next
load8 r0 139
cmp r0 1
je open_object_next
load8 r0 526
cmp r0 2
je open_object_next
load32 r0 100
sub r0 2002609
mul r0 r0
load32 r1 104
sub r1 2021820
mul r1 r1
add r0 r1
cmp r0 36000000
jgt open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
load32 r0 115
mod r0 200
cmp r0 100
jle open_object_active_139
set r1 200
sub r1 r0
mov r0 r1
label open_object_active_139
sub r0 50
div r0 2
localset 3310 r0
meshvertex 1900 3204 129 21742
localset 3400 0
meshtexuv 1900 128 870
meshvertex 1901 3191 138 21746
localset 3401 1
meshtexuv 1901 128 870
meshvertex 1902 3204 129 21755
localset 3402 0
meshtexuv 1902 128 870
meshvertex 1903 3217 138 21746
localset 3403 1
meshtexuv 1903 129 870
localset 3301 4
jmp open_object_transform
label open_object_skip_138
localget r0 3300
cmp r0 51
jne open_object_skip_140
localget r0 3200
cmp r0 43
jgt open_object_next
localget r0 3201
cmp r0 42
jle open_object_next
load8 r0 139
cmp r0 1
je open_object_next
load8 r0 526
cmp r0 2
je open_object_next
load32 r0 100
sub r0 1998668
mul r0 r0
load32 r1 104
sub r1 2083410
mul r1 r1
add r0 r1
cmp r0 36000000
jgt open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
load32 r0 115
mod r0 200
cmp r0 100
jle open_object_active_141
set r1 200
sub r1 r0
mov r0 r1
label open_object_active_141
sub r0 50
div r0 2
localset 3310 r0
meshvertex 1900 -757 237 83578
localset 3400 0
meshtexuv 1900 -30 3343
meshvertex 1901 -770 246 83582
localset 3401 1
meshtexuv 1901 -31 3343
meshvertex 1902 -757 237 83591
localset 3402 0
meshtexuv 1902 -30 3344
meshvertex 1903 -744 246 83582
localset 3403 1
meshtexuv 1903 -30 3343
localset 3301 4
jmp open_object_transform
label open_object_skip_140
localget r0 3300
cmp r0 52
jne open_object_skip_142
localget r0 3200
cmp r0 76
jgt open_object_next
localget r0 3201
cmp r0 75
jle open_object_next
load8 r0 139
cmp r0 1
je open_object_next
load8 r0 526
cmp r0 2
je open_object_next
load32 r0 100
sub r0 2000500
mul r0 r0
load32 r1 104
sub r1 2148024
mul r1 r1
add r0 r1
cmp r0 36000000
jgt open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
load32 r0 115
mod r0 200
cmp r0 100
jle open_object_active_143
set r1 200
sub r1 r0
mov r0 r1
label open_object_active_143
sub r0 50
div r0 2
localset 3310 r0
meshvertex 1900 1100 89 148036
localset 3400 0
meshtexuv 1900 44 5921
meshvertex 1901 1087 98 148040
localset 3401 1
meshtexuv 1901 43 5922
meshvertex 1902 1100 89 148049
localset 3402 0
meshtexuv 1902 44 5922
meshvertex 1903 1113 98 148040
localset 3403 1
meshtexuv 1903 45 5922
localset 3301 4
jmp open_object_transform
label open_object_skip_142
localget r0 3300
cmp r0 53
jne open_object_skip_144
localget r0 3200
cmp r0 5
jgt open_object_next
localget r0 3201
cmp r0 4
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 598 24 8976
localset 3400 0
meshtexuv 1900 24 359
meshvertex 1901 712 24 8961
localset 3401 0
meshtexuv 1901 28 358
meshvertex 1902 715 24 9246
localset 3402 0
meshtexuv 1902 29 370
meshvertex 1903 650 24 9373
localset 3403 0
meshtexuv 1903 26 375
meshvertex 1904 554 24 9267
localset 3404 0
meshtexuv 1904 22 371
meshvertex 1905 484 24 8991
localset 3405 0
meshtexuv 1905 19 360
meshvertex 1906 481 24 8706
localset 3406 0
meshtexuv 1906 19 348
meshvertex 1907 546 24 8579
localset 3407 0
meshtexuv 1907 22 343
meshvertex 1908 642 24 8685
localset 3408 0
meshtexuv 1908 26 347
localset 3301 9
jmp open_object_transform
label open_object_skip_144
localget r0 3300
cmp r0 54
jne open_object_skip_146
localget r0 3200
cmp r0 9
jgt open_object_next
localget r0 3201
cmp r0 8
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 1818 56 16882
localset 3400 0
meshtexuv 1900 73 675
meshvertex 1901 1932 56 16864
localset 3401 0
meshtexuv 1901 77 675
meshvertex 1902 1944 56 17148
localset 3402 0
meshtexuv 1902 78 686
meshvertex 1903 1882 56 17277
localset 3403 0
meshtexuv 1903 75 691
meshvertex 1904 1783 56 17174
localset 3404 0
meshtexuv 1904 71 687
meshvertex 1905 1704 56 16900
localset 3405 0
meshtexuv 1905 68 676
meshvertex 1906 1692 56 16616
localset 3406 0
meshtexuv 1906 68 665
meshvertex 1907 1754 56 16487
localset 3407 0
meshtexuv 1907 70 659
meshvertex 1908 1853 56 16590
localset 3408 0
meshtexuv 1908 74 664
localset 3301 9
jmp open_object_transform
label open_object_skip_146
localget r0 3300
cmp r0 55
jne open_object_skip_148
localget r0 3200
cmp r0 14
jgt open_object_next
localget r0 3201
cmp r0 13
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 3189 73 26787
localset 3400 0
meshtexuv 1900 128 1071
meshvertex 1901 3304 73 26778
localset 3401 0
meshtexuv 1901 132 1071
meshvertex 1902 3293 73 27062
localset 3402 0
meshtexuv 1902 132 1082
meshvertex 1903 3221 73 27186
localset 3403 0
meshtexuv 1903 129 1087
meshvertex 1904 3131 73 27076
localset 3404 0
meshtexuv 1904 125 1083
meshvertex 1905 3074 73 26796
localset 3405 0
meshtexuv 1905 123 1072
meshvertex 1906 3085 73 26512
localset 3406 0
meshtexuv 1906 123 1060
meshvertex 1907 3157 73 26388
localset 3407 0
meshtexuv 1907 126 1056
meshvertex 1908 3247 73 26498
localset 3408 0
meshtexuv 1908 130 1060
localset 3301 9
jmp open_object_transform
label open_object_skip_148
localget r0 3300
cmp r0 56
jne open_object_skip_150
localget r0 3200
cmp r0 19
jgt open_object_next
localget r0 3201
cmp r0 18
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 3339 81 36780
localset 3400 0
meshtexuv 1900 134 1471
meshvertex 1901 3454 81 36783
localset 3401 0
meshtexuv 1901 138 1471
meshvertex 1902 3412 81 37065
localset 3402 0
meshtexuv 1902 136 1483
meshvertex 1903 3327 81 37180
localset 3403 0
meshtexuv 1903 133 1487
meshvertex 1904 3249 81 37060
localset 3404 0
meshtexuv 1904 130 1482
meshvertex 1905 3224 81 36777
localset 3405 0
meshtexuv 1905 129 1471
meshvertex 1906 3266 81 36495
localset 3406 0
meshtexuv 1906 131 1460
meshvertex 1907 3351 81 36380
localset 3407 0
meshtexuv 1907 134 1455
meshvertex 1908 3429 81 36500
localset 3408 0
meshtexuv 1908 137 1460
localset 3301 9
jmp open_object_transform
label open_object_skip_150
localget r0 3300
cmp r0 57
jne open_object_skip_152
localget r0 3200
cmp r0 22
jgt open_object_next
localget r0 3201
cmp r0 21
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 3139 102 42777
localset 3400 0
meshtexuv 1900 126 1711
meshvertex 1901 3254 102 42784
localset 3401 0
meshtexuv 1901 130 1711
meshvertex 1902 3204 102 43064
localset 3402 0
meshtexuv 1902 128 1723
meshvertex 1903 3116 102 43176
localset 3403 0
meshtexuv 1903 125 1727
meshvertex 1904 3041 102 43055
localset 3404 0
meshtexuv 1904 122 1722
meshvertex 1905 3024 102 42770
localset 3405 0
meshtexuv 1905 121 1711
meshvertex 1906 3074 102 42490
localset 3406 0
meshtexuv 1906 123 1700
meshvertex 1907 3162 102 42378
localset 3407 0
meshtexuv 1907 126 1695
meshvertex 1908 3237 102 42499
localset 3408 0
meshtexuv 1908 129 1700
localset 3301 9
jmp open_object_transform
label open_object_skip_152
localget r0 3300
cmp r0 58
jne open_object_skip_154
localget r0 3200
cmp r0 25
jgt open_object_next
localget r0 3201
cmp r0 24
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 2700 133 48762
localset 3400 0
meshtexuv 1900 108 1950
meshvertex 1901 2815 133 48769
localset 3401 0
meshtexuv 1901 113 1951
meshvertex 1902 2765 133 49049
localset 3402 0
meshtexuv 1902 111 1962
meshvertex 1903 2677 133 49161
localset 3403 0
meshtexuv 1903 107 1966
meshvertex 1904 2603 133 49040
localset 3404 0
meshtexuv 1904 104 1962
meshvertex 1905 2585 133 48755
localset 3405 0
meshtexuv 1905 103 1950
meshvertex 1906 2635 133 48475
localset 3406 0
meshtexuv 1906 105 1939
meshvertex 1907 2723 133 48363
localset 3407 0
meshtexuv 1907 109 1935
meshvertex 1908 2797 133 48484
localset 3408 0
meshtexuv 1908 112 1939
localset 3301 9
jmp open_object_transform
label open_object_skip_154
localget r0 3300
cmp r0 59
jne open_object_skip_156
localget r0 3200
cmp r0 27
jgt open_object_next
localget r0 3201
cmp r0 26
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 2490 135 52756
localset 3400 0
meshtexuv 1900 100 2110
meshvertex 1901 2605 135 52761
localset 3401 0
meshtexuv 1901 104 2110
meshvertex 1902 2558 135 53042
localset 3402 0
meshtexuv 1902 102 2122
meshvertex 1903 2471 135 53156
localset 3403 0
meshtexuv 1903 99 2126
meshvertex 1904 2395 135 53035
localset 3404 0
meshtexuv 1904 96 2121
meshvertex 1905 2375 135 52751
localset 3405 0
meshtexuv 1905 95 2110
meshvertex 1906 2422 135 52470
localset 3406 0
meshtexuv 1906 97 2099
meshvertex 1907 2509 135 52356
localset 3407 0
meshtexuv 1907 100 2094
meshvertex 1908 2585 135 52477
localset 3408 0
meshtexuv 1908 103 2099
localset 3301 9
jmp open_object_transform
label open_object_skip_156
localget r0 3300
cmp r0 60
jne open_object_skip_158
localget r0 3200
cmp r0 33
jgt open_object_next
localget r0 3201
cmp r0 32
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 1929 189 64742
localset 3400 0
meshtexuv 1900 77 2590
meshvertex 1901 2044 189 64750
localset 3401 0
meshtexuv 1901 82 2590
meshvertex 1902 1991 189 65030
localset 3402 0
meshtexuv 1902 80 2601
meshvertex 1903 1903 189 65141
localset 3403 0
meshtexuv 1903 76 2606
meshvertex 1904 1829 189 65019
localset 3404 0
meshtexuv 1904 73 2601
meshvertex 1905 1814 189 64734
localset 3405 0
meshtexuv 1905 73 2589
meshvertex 1906 1867 189 64454
localset 3406 0
meshtexuv 1906 75 2578
meshvertex 1907 1955 189 64343
localset 3407 0
meshtexuv 1907 78 2574
meshvertex 1908 2029 189 64465
localset 3408 0
meshtexuv 1908 81 2579
localset 3301 9
jmp open_object_transform
label open_object_skip_158
localget r0 3300
cmp r0 61
jne open_object_skip_160
localget r0 3200
cmp r0 35
jgt open_object_next
localget r0 3201
cmp r0 34
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 1595 187 68726
localset 3400 0
meshtexuv 1900 64 2749
meshvertex 1901 1709 187 68738
localset 3401 0
meshtexuv 1901 68 2750
meshvertex 1902 1647 187 69016
localset 3402 0
meshtexuv 1902 66 2761
meshvertex 1903 1554 187 69124
localset 3403 0
meshtexuv 1903 62 2765
meshvertex 1904 1485 187 68999
localset 3404 0
meshtexuv 1904 59 2760
meshvertex 1905 1481 187 68714
localset 3405 0
meshtexuv 1905 59 2749
meshvertex 1906 1543 187 68436
localset 3406 0
meshtexuv 1906 62 2737
meshvertex 1907 1636 187 68328
localset 3407 0
meshtexuv 1907 65 2733
meshvertex 1908 1705 187 68453
localset 3408 0
meshtexuv 1908 68 2738
localset 3301 9
jmp open_object_transform
label open_object_skip_160
localget r0 3300
cmp r0 62
jne open_object_skip_162
localget r0 3200
cmp r0 37
jgt open_object_next
localget r0 3201
cmp r0 36
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 1084 181 72690
localset 3400 0
meshtexuv 1900 43 2908
meshvertex 1901 1198 181 72708
localset 3401 0
meshtexuv 1901 48 2908
meshvertex 1902 1121 181 72982
localset 3402 0
meshtexuv 1902 45 2919
meshvertex 1903 1023 181 73085
localset 3403 0
meshtexuv 1903 41 2923
meshvertex 1904 960 181 72957
localset 3404 0
meshtexuv 1904 38 2918
meshvertex 1905 970 181 72672
localset 3405 0
meshtexuv 1905 39 2907
meshvertex 1906 1047 181 72398
localset 3406 0
meshtexuv 1906 42 2896
meshvertex 1907 1145 181 72295
localset 3407 0
meshtexuv 1907 46 2892
meshvertex 1908 1208 181 72423
localset 3408 0
meshtexuv 1908 48 2897
localset 3301 9
jmp open_object_transform
label open_object_skip_162
localget r0 3300
cmp r0 63
jne open_object_skip_164
localget r0 3200
cmp r0 41
jgt open_object_next
localget r0 3201
cmp r0 40
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -567 175 80509
localset 3400 0
meshtexuv 1900 -23 3220
meshvertex 1901 -456 175 80538
localset 3401 0
meshtexuv 1901 -18 3222
meshvertex 1902 -560 175 80803
localset 3402 0
meshtexuv 1902 -22 3232
meshvertex 1903 -669 175 80896
localset 3403 0
meshtexuv 1903 -27 3236
meshvertex 1904 -718 175 80762
localset 3404 0
meshtexuv 1904 -29 3230
meshvertex 1905 -678 175 80480
localset 3405 0
meshtexuv 1905 -27 3219
meshvertex 1906 -574 175 80215
localset 3406 0
meshtexuv 1906 -23 3209
meshvertex 1907 -465 175 80122
localset 3407 0
meshtexuv 1907 -19 3205
meshvertex 1908 -416 175 80256
localset 3408 0
meshtexuv 1908 -17 3210
localset 3301 9
jmp open_object_transform
label open_object_skip_164
localget r0 3300
cmp r0 64
jne open_object_skip_166
localget r0 3200
cmp r0 45
jgt open_object_next
localget r0 3201
cmp r0 44
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -2832 184 88180
localset 3400 0
meshtexuv 1900 -113 3527
meshvertex 1901 -2722 184 88214
localset 3401 0
meshtexuv 1901 -109 3529
meshvertex 1902 -2839 184 88474
localset 3402 0
meshtexuv 1902 -114 3539
meshvertex 1903 -2951 184 88562
localset 3403 0
meshtexuv 1903 -118 3542
meshvertex 1904 -2994 184 88426
localset 3404 0
meshtexuv 1904 -120 3537
meshvertex 1905 -2942 184 88146
localset 3405 0
meshtexuv 1905 -118 3526
meshvertex 1906 -2825 184 87886
localset 3406 0
meshtexuv 1906 -113 3515
meshvertex 1907 -2713 184 87798
localset 3407 0
meshtexuv 1907 -109 3512
meshvertex 1908 -2670 184 87934
localset 3408 0
meshtexuv 1908 -107 3517
localset 3301 9
jmp open_object_transform
label open_object_skip_166
localget r0 3300
cmp r0 65
jne open_object_skip_168
localget r0 3200
cmp r0 48
jgt open_object_next
localget r0 3201
cmp r0 47
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -4462 189 93953
localset 3400 0
meshtexuv 1900 -178 3758
meshvertex 1901 -4351 189 93983
localset 3401 0
meshtexuv 1901 -174 3759
meshvertex 1902 -4458 189 94247
localset 3402 0
meshtexuv 1902 -178 3770
meshvertex 1903 -4567 189 94339
localset 3403 0
meshtexuv 1903 -183 3774
meshvertex 1904 -4615 189 94205
localset 3404 0
meshtexuv 1904 -185 3768
meshvertex 1905 -4573 189 93923
localset 3405 0
meshtexuv 1905 -183 3757
meshvertex 1906 -4466 189 93659
localset 3406 0
meshtexuv 1906 -179 3746
meshvertex 1907 -4357 189 93567
localset 3407 0
meshtexuv 1907 -174 3743
meshvertex 1908 -4309 189 93701
localset 3408 0
meshtexuv 1908 -172 3748
localset 3301 9
jmp open_object_transform
label open_object_skip_168
localget r0 3300
cmp r0 66
jne open_object_skip_170
localget r0 3200
cmp r0 52
jgt open_object_next
localget r0 3201
cmp r0 51
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -6041 175 101780
localset 3400 0
meshtexuv 1900 -242 4071
meshvertex 1901 -5927 175 101793
localset 3401 0
meshtexuv 1901 -237 4072
meshvertex 1902 -5993 175 102070
localset 3402 0
meshtexuv 1902 -240 4083
meshvertex 1903 -6088 175 102177
localset 3403 0
meshtexuv 1903 -244 4087
meshvertex 1904 -6155 175 102051
localset 3404 0
meshtexuv 1904 -246 4082
meshvertex 1905 -6155 175 101767
localset 3405 0
meshtexuv 1905 -246 4071
meshvertex 1906 -6089 175 101490
localset 3406 0
meshtexuv 1906 -244 4060
meshvertex 1907 -5994 175 101383
localset 3407 0
meshtexuv 1907 -240 4055
meshvertex 1908 -5927 175 101509
localset 3408 0
meshtexuv 1908 -237 4060
localset 3301 9
jmp open_object_transform
label open_object_skip_170
localget r0 3300
cmp r0 67
jne open_object_skip_172
localget r0 3200
cmp r0 56
jgt open_object_next
localget r0 3201
cmp r0 55
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -6134 133 109753
localset 3400 0
meshtexuv 1900 -245 4390
meshvertex 1901 -6020 133 109742
localset 3401 0
meshtexuv 1901 -241 4390
meshvertex 1902 -6027 133 110027
localset 3402 0
meshtexuv 1902 -241 4401
meshvertex 1903 -6097 133 110151
localset 3403 0
meshtexuv 1903 -244 4406
meshvertex 1904 -6189 133 110042
localset 3404 0
meshtexuv 1904 -248 4402
meshvertex 1905 -6248 133 109764
localset 3405 0
meshtexuv 1905 -250 4391
meshvertex 1906 -6241 133 109479
localset 3406 0
meshtexuv 1906 -250 4379
meshvertex 1907 -6171 133 109355
localset 3407 0
meshtexuv 1907 -247 4374
meshvertex 1908 -6079 133 109464
localset 3408 0
meshtexuv 1908 -243 4379
localset 3301 9
jmp open_object_transform
label open_object_skip_172
localget r0 3300
cmp r0 68
jne open_object_skip_174
localget r0 3200
cmp r0 60
jgt open_object_next
localget r0 3201
cmp r0 59
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -4737 93 117616
localset 3400 0
meshtexuv 1900 -189 4705
meshvertex 1901 -4625 93 117588
localset 3401 0
meshtexuv 1901 -185 4704
meshvertex 1902 -4590 93 117871
localset 3402 0
meshtexuv 1902 -184 4715
meshvertex 1903 -4641 93 118004
localset 3403 0
meshtexuv 1903 -186 4720
meshvertex 1904 -4748 93 117910
localset 3404 0
meshtexuv 1904 -190 4716
meshvertex 1905 -4849 93 117644
localset 3405 0
meshtexuv 1905 -194 4706
meshvertex 1906 -4884 93 117361
localset 3406 0
meshtexuv 1906 -195 4694
meshvertex 1907 -4833 93 117228
localset 3407 0
meshtexuv 1907 -193 4689
meshvertex 1908 -4726 93 117322
localset 3408 0
meshtexuv 1908 -189 4693
localset 3301 9
jmp open_object_transform
label open_object_skip_174
localget r0 3300
cmp r0 69
jne open_object_skip_176
localget r0 3200
cmp r0 64
jgt open_object_next
localget r0 3201
cmp r0 63
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -2631 76 125333
localset 3400 0
meshtexuv 1900 -105 5013
meshvertex 1901 -2520 76 125302
localset 3401 0
meshtexuv 1901 -101 5012
meshvertex 1902 -2477 76 125584
localset 3402 0
meshtexuv 1902 -99 5023
meshvertex 1903 -2524 76 125718
localset 3403 0
meshtexuv 1903 -101 5029
meshvertex 1904 -2633 76 125627
localset 3404 0
meshtexuv 1904 -105 5025
meshvertex 1905 -2742 76 125364
localset 3405 0
meshtexuv 1905 -110 5015
meshvertex 1906 -2785 76 125082
localset 3406 0
meshtexuv 1906 -111 5003
meshvertex 1907 -2738 76 124948
localset 3407 0
meshtexuv 1907 -110 4998
meshvertex 1908 -2629 76 125039
localset 3408 0
meshtexuv 1908 -105 5002
localset 3301 9
jmp open_object_transform
label open_object_skip_176
localget r0 3300
cmp r0 70
jne open_object_skip_178
localget r0 3200
cmp r0 68
jgt open_object_next
localget r0 3201
cmp r0 67
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -720 72 133102
localset 3400 0
meshtexuv 1900 -29 5324
meshvertex 1901 -607 72 133079
localset 3401 0
meshtexuv 1901 -24 5323
meshvertex 1902 -585 72 133363
localset 3402 0
meshtexuv 1902 -23 5335
meshvertex 1903 -641 72 133494
localset 3403 0
meshtexuv 1903 -26 5340
meshvertex 1904 -744 72 133395
localset 3404 0
meshtexuv 1904 -30 5336
meshvertex 1905 -833 72 133125
localset 3405 0
meshtexuv 1905 -33 5325
meshvertex 1906 -855 72 132841
localset 3406 0
meshtexuv 1906 -34 5314
meshvertex 1907 -799 72 132710
localset 3407 0
meshtexuv 1907 -32 5308
meshvertex 1908 -696 72 132809
localset 3408 0
meshtexuv 1908 -28 5312
localset 3301 9
jmp open_object_transform
label open_object_skip_178
localget r0 3300
cmp r0 71
jne open_object_skip_180
localget r0 3200
cmp r0 72
jgt open_object_next
localget r0 3201
cmp r0 71
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 364 56 141027
localset 3400 0
meshtexuv 1900 15 5641
meshvertex 1901 479 56 141019
localset 3401 0
meshtexuv 1901 19 5641
meshvertex 1902 465 56 141303
localset 3402 0
meshtexuv 1902 19 5652
meshvertex 1903 393 56 141426
localset 3403 0
meshtexuv 1903 16 5657
meshvertex 1904 303 56 141315
localset 3404 0
meshtexuv 1904 12 5653
meshvertex 1905 249 56 141035
localset 3405 0
meshtexuv 1905 10 5641
meshvertex 1906 263 56 140751
localset 3406 0
meshtexuv 1906 11 5630
meshvertex 1907 335 56 140628
localset 3407 0
meshtexuv 1907 13 5625
meshvertex 1908 425 56 140739
localset 3408 0
meshtexuv 1908 17 5630
localset 3301 9
jmp open_object_transform
label open_object_skip_180
localget r0 3300
cmp r0 72
jne open_object_skip_182
localget r0 3200
cmp r0 76
jgt open_object_next
localget r0 3201
cmp r0 75
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 514 24 149025
localset 3400 0
meshtexuv 1900 21 5961
meshvertex 1901 629 24 149028
localset 3401 0
meshtexuv 1901 25 5961
meshvertex 1902 588 24 149310
localset 3402 0
meshtexuv 1902 24 5972
meshvertex 1903 504 24 149425
localset 3403 0
meshtexuv 1903 20 5977
meshvertex 1904 425 24 149306
localset 3404 0
meshtexuv 1904 17 5972
meshvertex 1905 399 24 149022
localset 3405 0
meshtexuv 1905 16 5961
meshvertex 1906 440 24 148740
localset 3406 0
meshtexuv 1906 18 5950
meshvertex 1907 524 24 148625
localset 3407 0
meshtexuv 1907 21 5945
meshvertex 1908 603 24 148744
localset 3408 0
meshtexuv 1908 24 5950
localset 3301 9
jmp open_object_transform
label open_object_skip_182
localget r0 3300
cmp r0 73
jne open_object_skip_184
localget r0 3200
cmp r0 29
jgt open_object_next
localget r0 3201
cmp r0 28
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -3600 35 55507
localset 3400 0
meshtexuv 1900 -144 2220
meshvertex 1901 -3682 35 57505
localset 3401 0
meshtexuv 1901 -147 2300
meshvertex 1902 8308 35 58001
localset 3402 0
meshtexuv 1902 332 2320
meshvertex 1903 8390 35 56003
localset 3403 0
meshtexuv 1903 336 2240
localset 3301 4
jmp open_object_transform
label open_object_skip_184
localget r0 3300
cmp r0 74
jne open_object_skip_186
localget r0 3200
cmp r0 29
jgt open_object_next
localget r0 3201
cmp r0 28
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -3600 82 55507
localset 3400 0
meshtexuv 1900 -144 2220
meshvertex 1901 -3682 82 57505
localset 3401 0
meshtexuv 1901 -147 2300
meshvertex 1902 8308 82 58001
localset 3402 0
meshtexuv 1902 332 2320
meshvertex 1903 8390 82 56003
localset 3403 0
meshtexuv 1903 336 2240
localset 3301 4
jmp open_object_transform
label open_object_skip_186
localget r0 3300
cmp r0 75
jne open_object_skip_188
localget r0 3200
cmp r0 30
jgt open_object_next
localget r0 3201
cmp r0 29
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -3682 35 57505
localset 3400 0
meshtexuv 1900 -147 2300
meshvertex 1901 -3763 35 59485
localset 3401 0
meshtexuv 1901 -151 2379
meshvertex 1902 8225 35 60019
localset 3402 0
meshtexuv 1902 329 2401
meshvertex 1903 8308 35 58001
localset 3403 0
meshtexuv 1903 332 2320
localset 3301 4
jmp open_object_transform
label open_object_skip_188
localget r0 3300
cmp r0 76
jne open_object_skip_190
localget r0 3200
cmp r0 30
jgt open_object_next
localget r0 3201
cmp r0 29
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -3682 82 57505
localset 3400 0
meshtexuv 1900 -147 2300
meshvertex 1901 -3763 82 59485
localset 3401 0
meshtexuv 1901 -151 2379
meshvertex 1902 8225 82 60019
localset 3402 0
meshtexuv 1902 329 2401
meshvertex 1903 8308 82 58001
localset 3403 0
meshtexuv 1903 332 2320
localset 3301 4
jmp open_object_transform
label open_object_skip_190
localget r0 3300
cmp r0 77
jne open_object_skip_192
localget r0 3200
cmp r0 22
jgt open_object_next
localget r0 3201
cmp r0 21
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 962 96 41648
localset 3400 0
meshtexuv 1900 38 1666
meshvertex 1901 844 105 43638
localset 3401 0
meshtexuv 1901 34 1746
meshvertex 1902 2681 105 43751
localset 3402 0
meshtexuv 1902 107 1750
meshvertex 1903 2799 96 41755
localset 3403 0
meshtexuv 1903 112 1670
localset 3301 4
jmp open_object_transform
label open_object_skip_192
localget r0 3300
cmp r0 78
jne open_object_skip_194
localget r0 3200
cmp r0 22
jgt open_object_next
localget r0 3201
cmp r0 21
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 2400 97 41732
localset 3400 0
meshtexuv 1900 96 1669
meshvertex 1901 2409 182 41732
localset 3401 0
meshtexuv 1901 96 1669
meshvertex 1902 2417 97 41732
localset 3402 0
meshtexuv 1902 97 1669
meshvertex 1903 2413 97 41750
localset 3403 0
meshtexuv 1903 97 1670
meshvertex 1904 2422 188 41750
localset 3404 0
meshtexuv 1904 97 1670
meshvertex 1905 2430 97 41750
localset 3405 0
meshtexuv 1905 97 1670
meshvertex 1906 2426 97 41768
localset 3406 0
meshtexuv 1906 97 1671
meshvertex 1907 2435 194 41768
localset 3407 0
meshtexuv 1907 97 1671
meshvertex 1908 2443 97 41768
localset 3408 0
meshtexuv 1908 98 1671
meshvertex 1909 2439 97 41786
localset 3409 0
meshtexuv 1909 98 1671
meshvertex 1910 2448 200 41786
localset 3410 0
meshtexuv 1910 98 1671
meshvertex 1911 2456 97 41786
localset 3411 0
meshtexuv 1911 98 1671
localset 3301 12
jmp open_object_transform
label open_object_skip_194
localget r0 3300
cmp r0 79
jne open_object_skip_196
localget r0 3200
cmp r0 22
jgt open_object_next
localget r0 3201
cmp r0 21
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 3517 96 41797
localset 3400 0
meshtexuv 1900 141 1672
meshvertex 1901 3399 105 43795
localset 3401 0
meshtexuv 1901 136 1752
meshvertex 1902 5236 105 43908
localset 3402 0
meshtexuv 1902 209 1756
meshvertex 1903 5354 96 41904
localset 3403 0
meshtexuv 1903 214 1676
localset 3301 4
jmp open_object_transform
label open_object_skip_196
localget r0 3300
cmp r0 80
jne open_object_skip_198
localget r0 3200
cmp r0 22
jgt open_object_next
localget r0 3201
cmp r0 21
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 3898 97 41820
localset 3400 0
meshtexuv 1900 156 1673
meshvertex 1901 3907 182 41820
localset 3401 0
meshtexuv 1901 156 1673
meshvertex 1902 3915 97 41820
localset 3402 0
meshtexuv 1902 157 1673
meshvertex 1903 3911 97 41838
localset 3403 0
meshtexuv 1903 156 1674
meshvertex 1904 3920 188 41838
localset 3404 0
meshtexuv 1904 157 1674
meshvertex 1905 3928 97 41838
localset 3405 0
meshtexuv 1905 157 1674
meshvertex 1906 3924 97 41856
localset 3406 0
meshtexuv 1906 157 1674
meshvertex 1907 3933 194 41856
localset 3407 0
meshtexuv 1907 157 1674
meshvertex 1908 3941 97 41856
localset 3408 0
meshtexuv 1908 158 1674
meshvertex 1909 3937 97 41874
localset 3409 0
meshtexuv 1909 157 1675
meshvertex 1910 3946 200 41874
localset 3410 0
meshtexuv 1910 158 1675
meshvertex 1911 3954 97 41874
localset 3411 0
meshtexuv 1911 158 1675
localset 3301 12
jmp open_object_transform
label open_object_skip_198
localget r0 3300
cmp r0 81
jne open_object_skip_200
localget r0 3200
cmp r0 25
jgt open_object_next
localget r0 3201
cmp r0 24
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 601 126 47640
localset 3400 0
meshtexuv 1900 24 1906
meshvertex 1901 485 138 49647
localset 3401 0
meshtexuv 1901 19 1986
meshvertex 1902 2322 138 49743
localset 3402 0
meshtexuv 1902 93 1990
meshvertex 1903 2438 126 47745
localset 3403 0
meshtexuv 1903 98 1910
localset 3301 4
jmp open_object_transform
label open_object_skip_200
localget r0 3300
cmp r0 82
jne open_object_skip_202
localget r0 3200
cmp r0 25
jgt open_object_next
localget r0 3201
cmp r0 24
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 2039 127 47722
localset 3400 0
meshtexuv 1900 82 1909
meshvertex 1901 2048 212 47722
localset 3401 0
meshtexuv 1901 82 1909
meshvertex 1902 2056 127 47722
localset 3402 0
meshtexuv 1902 82 1909
meshvertex 1903 2052 127 47740
localset 3403 0
meshtexuv 1903 82 1910
meshvertex 1904 2061 218 47740
localset 3404 0
meshtexuv 1904 82 1910
meshvertex 1905 2069 127 47740
localset 3405 0
meshtexuv 1905 83 1910
meshvertex 1906 2065 127 47758
localset 3406 0
meshtexuv 1906 83 1910
meshvertex 1907 2074 224 47758
localset 3407 0
meshtexuv 1907 83 1910
meshvertex 1908 2082 127 47758
localset 3408 0
meshtexuv 1908 83 1910
meshvertex 1909 2078 127 47776
localset 3409 0
meshtexuv 1909 83 1911
meshvertex 1910 2087 230 47776
localset 3410 0
meshtexuv 1910 83 1911
meshvertex 1911 2095 127 47776
localset 3411 0
meshtexuv 1911 84 1911
localset 3301 12
jmp open_object_transform
label open_object_skip_202
localget r0 3300
cmp r0 83
jne open_object_skip_204
localget r0 3200
cmp r0 25
jgt open_object_next
localget r0 3201
cmp r0 24
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 3156 126 47785
localset 3400 0
meshtexuv 1900 126 1911
meshvertex 1901 3042 138 49781
localset 3401 0
meshtexuv 1901 122 1991
meshvertex 1902 4879 138 49877
localset 3402 0
meshtexuv 1902 195 1995
meshvertex 1903 4993 126 47890
localset 3403 0
meshtexuv 1903 200 1916
localset 3301 4
jmp open_object_transform
label open_object_skip_204
localget r0 3300
cmp r0 84
jne open_object_skip_206
localget r0 3200
cmp r0 25
jgt open_object_next
localget r0 3201
cmp r0 24
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 3537 127 47808
localset 3400 0
meshtexuv 1900 141 1912
meshvertex 1901 3546 212 47808
localset 3401 0
meshtexuv 1901 142 1912
meshvertex 1902 3554 127 47808
localset 3402 0
meshtexuv 1902 142 1912
meshvertex 1903 3550 127 47826
localset 3403 0
meshtexuv 1903 142 1913
meshvertex 1904 3559 218 47826
localset 3404 0
meshtexuv 1904 142 1913
meshvertex 1905 3567 127 47826
localset 3405 0
meshtexuv 1905 143 1913
meshvertex 1906 3563 127 47844
localset 3406 0
meshtexuv 1906 143 1914
meshvertex 1907 3572 224 47844
localset 3407 0
meshtexuv 1907 143 1914
meshvertex 1908 3580 127 47844
localset 3408 0
meshtexuv 1908 143 1914
meshvertex 1909 3576 127 47862
localset 3409 0
meshtexuv 1909 143 1914
meshvertex 1910 3585 230 47862
localset 3410 0
meshtexuv 1910 143 1914
meshvertex 1911 3593 127 47862
localset 3411 0
meshtexuv 1911 144 1914
localset 3301 12
jmp open_object_transform
label open_object_skip_206
localget r0 3300
cmp r0 85
jne open_object_skip_208
localget r0 3200
cmp r0 34
jgt open_object_next
localget r0 3201
cmp r0 33
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -289 188 65560
localset 3400 0
meshtexuv 1900 -12 2622
meshvertex 1901 -450 187 67509
localset 3401 0
meshtexuv 1901 -18 2700
meshvertex 1902 1380 187 67698
localset 3402 0
meshtexuv 1902 55 2708
meshvertex 1903 1544 188 65712
localset 3403 0
meshtexuv 1903 62 2628
localset 3301 4
jmp open_object_transform
label open_object_skip_208
localget r0 3300
cmp r0 86
jne open_object_skip_210
localget r0 3200
cmp r0 34
jgt open_object_next
localget r0 3201
cmp r0 33
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 1147 189 65680
localset 3400 0
meshtexuv 1900 46 2627
meshvertex 1901 1156 274 65680
localset 3401 0
meshtexuv 1901 46 2627
meshvertex 1902 1164 189 65680
localset 3402 0
meshtexuv 1902 47 2627
meshvertex 1903 1160 189 65698
localset 3403 0
meshtexuv 1903 46 2628
meshvertex 1904 1169 280 65698
localset 3404 0
meshtexuv 1904 47 2628
meshvertex 1905 1177 189 65698
localset 3405 0
meshtexuv 1905 47 2628
meshvertex 1906 1173 189 65716
localset 3406 0
meshtexuv 1906 47 2629
meshvertex 1907 1182 286 65716
localset 3407 0
meshtexuv 1907 47 2629
meshvertex 1908 1190 189 65716
localset 3408 0
meshtexuv 1908 48 2629
meshvertex 1909 1186 189 65734
localset 3409 0
meshtexuv 1909 47 2629
meshvertex 1910 1195 292 65734
localset 3410 0
meshtexuv 1910 48 2629
meshvertex 1911 1203 189 65734
localset 3411 0
meshtexuv 1911 48 2629
localset 3301 12
jmp open_object_transform
label open_object_skip_210
localget r0 3300
cmp r0 87
jne open_object_skip_212
localget r0 3200
cmp r0 34
jgt open_object_next
localget r0 3201
cmp r0 33
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 2262 188 65772
localset 3400 0
meshtexuv 1900 90 2631
meshvertex 1901 2096 187 67772
localset 3401 0
meshtexuv 1901 84 2711
meshvertex 1902 3926 187 67961
localset 3402 0
meshtexuv 1902 157 2718
meshvertex 1903 4095 188 65924
localset 3403 0
meshtexuv 1903 164 2637
localset 3301 4
jmp open_object_transform
label open_object_skip_212
localget r0 3300
cmp r0 88
jne open_object_skip_214
localget r0 3200
cmp r0 34
jgt open_object_next
localget r0 3201
cmp r0 33
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 2641 189 65804
localset 3400 0
meshtexuv 1900 106 2632
meshvertex 1901 2650 274 65804
localset 3401 0
meshtexuv 1901 106 2632
meshvertex 1902 2658 189 65804
localset 3402 0
meshtexuv 1902 106 2632
meshvertex 1903 2654 189 65822
localset 3403 0
meshtexuv 1903 106 2633
meshvertex 1904 2663 280 65822
localset 3404 0
meshtexuv 1904 107 2633
meshvertex 1905 2671 189 65822
localset 3405 0
meshtexuv 1905 107 2633
meshvertex 1906 2667 189 65840
localset 3406 0
meshtexuv 1906 107 2634
meshvertex 1907 2676 286 65840
localset 3407 0
meshtexuv 1907 107 2634
meshvertex 1908 2684 189 65840
localset 3408 0
meshtexuv 1908 107 2634
meshvertex 1909 2680 189 65858
localset 3409 0
meshtexuv 1909 107 2634
meshvertex 1910 2689 292 65858
localset 3410 0
meshtexuv 1910 108 2634
meshvertex 1911 2697 189 65858
localset 3411 0
meshtexuv 1911 108 2634
localset 3301 12
jmp open_object_transform
label open_object_skip_214
localget r0 3300
cmp r0 89
jne open_object_skip_216
localget r0 3200
cmp r0 37
jgt open_object_next
localget r0 3201
cmp r0 36
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -897 181 71372
localset 3400 0
meshtexuv 1900 -36 2855
meshvertex 1901 -1193 178 73286
localset 3401 0
meshtexuv 1901 -48 2931
meshvertex 1902 616 178 73620
localset 3402 0
meshtexuv 1902 25 2945
meshvertex 1903 921 181 71653
localset 3403 0
meshtexuv 1903 37 2866
localset 3301 4
jmp open_object_transform
label open_object_skip_216
localget r0 3300
cmp r0 90
jne open_object_skip_218
localget r0 3200
cmp r0 37
jgt open_object_next
localget r0 3201
cmp r0 36
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 527 182 71593
localset 3400 0
meshtexuv 1900 21 2864
meshvertex 1901 536 267 71593
localset 3401 0
meshtexuv 1901 21 2864
meshvertex 1902 544 182 71593
localset 3402 0
meshtexuv 1902 22 2864
meshvertex 1903 540 182 71611
localset 3403 0
meshtexuv 1903 22 2864
meshvertex 1904 549 273 71611
localset 3404 0
meshtexuv 1904 22 2864
meshvertex 1905 557 182 71611
localset 3405 0
meshtexuv 1905 22 2864
meshvertex 1906 553 182 71629
localset 3406 0
meshtexuv 1906 22 2865
meshvertex 1907 562 279 71629
localset 3407 0
meshtexuv 1907 22 2865
meshvertex 1908 570 182 71629
localset 3408 0
meshtexuv 1908 23 2865
meshvertex 1909 566 182 71647
localset 3409 0
meshtexuv 1909 23 2866
meshvertex 1910 575 285 71647
localset 3410 0
meshtexuv 1910 23 2866
meshvertex 1911 583 182 71647
localset 3411 0
meshtexuv 1911 23 2866
localset 3301 12
jmp open_object_transform
label open_object_skip_218
localget r0 3300
cmp r0 91
jne open_object_skip_220
localget r0 3200
cmp r0 37
jgt open_object_next
localget r0 3201
cmp r0 36
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 1633 181 71763
localset 3400 0
meshtexuv 1900 65 2871
meshvertex 1901 1324 178 73750
localset 3401 0
meshtexuv 1901 53 2950
meshvertex 1902 3133 178 74084
localset 3402 0
meshtexuv 1902 125 2963
meshvertex 1903 3451 181 72044
localset 3403 0
meshtexuv 1903 138 2882
localset 3301 4
jmp open_object_transform
label open_object_skip_220
localget r0 3300
cmp r0 92
jne open_object_skip_222
localget r0 3200
cmp r0 37
jgt open_object_next
localget r0 3201
cmp r0 36
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 2009 182 71823
localset 3400 0
meshtexuv 1900 80 2873
meshvertex 1901 2018 267 71823
localset 3401 0
meshtexuv 1901 81 2873
meshvertex 1902 2026 182 71823
localset 3402 0
meshtexuv 1902 81 2873
meshvertex 1903 2022 182 71841
localset 3403 0
meshtexuv 1903 81 2874
meshvertex 1904 2031 273 71841
localset 3404 0
meshtexuv 1904 81 2874
meshvertex 1905 2039 182 71841
localset 3405 0
meshtexuv 1905 82 2874
meshvertex 1906 2035 182 71859
localset 3406 0
meshtexuv 1906 81 2874
meshvertex 1907 2044 279 71859
localset 3407 0
meshtexuv 1907 82 2874
meshvertex 1908 2052 182 71859
localset 3408 0
meshtexuv 1908 82 2874
meshvertex 1909 2048 182 71877
localset 3409 0
meshtexuv 1909 82 2875
meshvertex 1910 2057 285 71877
localset 3410 0
meshtexuv 1910 82 2875
meshvertex 1911 2065 182 71877
localset 3411 0
meshtexuv 1911 83 2875
localset 3301 12
jmp open_object_transform
label open_object_skip_222
localget r0 3300
cmp r0 93
jne open_object_skip_224
localget r0 3200
cmp r0 48
jgt open_object_next
localget r0 3201
cmp r0 47
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -6362 188 92401
localset 3400 0
meshtexuv 1900 -254 3696
meshvertex 1901 -6900 188 94387
localset 3401 0
meshtexuv 1901 -276 3775
meshvertex 1902 -5113 188 94823
localset 3402 0
meshtexuv 1902 -205 3793
meshvertex 1903 -4586 188 92884
localset 3403 0
meshtexuv 1903 -183 3715
localset 3301 4
jmp open_object_transform
label open_object_skip_224
localget r0 3300
cmp r0 94
jne open_object_skip_226
localget r0 3200
cmp r0 48
jgt open_object_next
localget r0 3201
cmp r0 47
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -4972 189 92781
localset 3400 0
meshtexuv 1900 -199 3711
meshvertex 1901 -4963 274 92781
localset 3401 0
meshtexuv 1901 -199 3711
meshvertex 1902 -4955 189 92781
localset 3402 0
meshtexuv 1902 -198 3711
meshvertex 1903 -4959 189 92799
localset 3403 0
meshtexuv 1903 -198 3712
meshvertex 1904 -4950 280 92799
localset 3404 0
meshtexuv 1904 -198 3712
meshvertex 1905 -4942 189 92799
localset 3405 0
meshtexuv 1905 -198 3712
meshvertex 1906 -4946 189 92817
localset 3406 0
meshtexuv 1906 -198 3713
meshvertex 1907 -4937 286 92817
localset 3407 0
meshtexuv 1907 -197 3713
meshvertex 1908 -4929 189 92817
localset 3408 0
meshtexuv 1908 -197 3713
meshvertex 1909 -4933 189 92835
localset 3409 0
meshtexuv 1909 -197 3713
meshvertex 1910 -4924 292 92835
localset 3410 0
meshtexuv 1910 -197 3713
meshvertex 1911 -4916 189 92835
localset 3411 0
meshtexuv 1911 -197 3713
localset 3301 12
jmp open_object_transform
label open_object_skip_226
localget r0 3300
cmp r0 95
jne open_object_skip_228
localget r0 3200
cmp r0 48
jgt open_object_next
localget r0 3201
cmp r0 47
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -3892 188 93072
localset 3400 0
meshtexuv 1900 -156 3723
meshvertex 1901 -4413 188 94993
localset 3401 0
meshtexuv 1901 -177 3800
meshvertex 1902 -2626 188 95429
localset 3402 0
meshtexuv 1902 -105 3817
meshvertex 1903 -2116 188 93555
localset 3403 0
meshtexuv 1903 -85 3742
localset 3301 4
jmp open_object_transform
label open_object_skip_228
localget r0 3300
cmp r0 96
jne open_object_skip_230
localget r0 3200
cmp r0 48
jgt open_object_next
localget r0 3201
cmp r0 47
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -3524 189 93175
localset 3400 0
meshtexuv 1900 -141 3727
meshvertex 1901 -3515 274 93175
localset 3401 0
meshtexuv 1901 -141 3727
meshvertex 1902 -3507 189 93175
localset 3402 0
meshtexuv 1902 -140 3727
meshvertex 1903 -3511 189 93193
localset 3403 0
meshtexuv 1903 -140 3728
meshvertex 1904 -3502 280 93193
localset 3404 0
meshtexuv 1904 -140 3728
meshvertex 1905 -3494 189 93193
localset 3405 0
meshtexuv 1905 -140 3728
meshvertex 1906 -3498 189 93211
localset 3406 0
meshtexuv 1906 -140 3728
meshvertex 1907 -3489 286 93211
localset 3407 0
meshtexuv 1907 -140 3728
meshvertex 1908 -3481 189 93211
localset 3408 0
meshtexuv 1908 -139 3728
meshvertex 1909 -3485 189 93229
localset 3409 0
meshtexuv 1909 -139 3729
meshvertex 1910 -3476 292 93229
localset 3410 0
meshtexuv 1910 -139 3729
meshvertex 1911 -3468 189 93229
localset 3411 0
meshtexuv 1911 -139 3729
localset 3301 12
jmp open_object_transform
label open_object_skip_230
localget r0 3300
cmp r0 97
jne open_object_skip_232
localget r0 3200
cmp r0 64
jgt open_object_next
localget r0 3201
cmp r0 63
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -5058 75 124970
localset 3400 0
meshtexuv 1900 -202 4999
meshvertex 1901 -4527 74 126876
localset 3401 0
meshtexuv 1901 -181 5075
meshvertex 1902 -2750 74 126399
localset 3402 0
meshtexuv 1902 -110 5056
meshvertex 1903 -3286 75 124477
localset 3403 0
meshtexuv 1903 -131 4979
localset 3301 4
jmp open_object_transform
label open_object_skip_232
localget r0 3300
cmp r0 98
jne open_object_skip_234
localget r0 3200
cmp r0 64
jgt open_object_next
localget r0 3201
cmp r0 63
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -3671 76 124581
localset 3400 0
meshtexuv 1900 -147 4983
meshvertex 1901 -3662 161 124581
localset 3401 0
meshtexuv 1901 -146 4983
meshvertex 1902 -3654 76 124581
localset 3402 0
meshtexuv 1902 -146 4983
meshvertex 1903 -3658 76 124599
localset 3403 0
meshtexuv 1903 -146 4984
meshvertex 1904 -3649 167 124599
localset 3404 0
meshtexuv 1904 -146 4984
meshvertex 1905 -3641 76 124599
localset 3405 0
meshtexuv 1905 -146 4984
meshvertex 1906 -3645 76 124617
localset 3406 0
meshtexuv 1906 -146 4985
meshvertex 1907 -3636 173 124617
localset 3407 0
meshtexuv 1907 -145 4985
meshvertex 1908 -3628 76 124617
localset 3408 0
meshtexuv 1908 -145 4985
meshvertex 1909 -3632 76 124635
localset 3409 0
meshtexuv 1909 -145 4985
meshvertex 1910 -3623 179 124635
localset 3410 0
meshtexuv 1910 -145 4985
meshvertex 1911 -3615 76 124635
localset 3411 0
meshtexuv 1911 -145 4985
localset 3301 12
jmp open_object_transform
label open_object_skip_234
localget r0 3300
cmp r0 99
jne open_object_skip_236
localget r0 3200
cmp r0 64
jgt open_object_next
localget r0 3201
cmp r0 63
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -2592 75 124283
localset 3400 0
meshtexuv 1900 -104 4971
meshvertex 1901 -2054 74 126213
localset 3401 0
meshtexuv 1901 -82 5049
meshvertex 1902 -277 74 125736
localset 3402 0
meshtexuv 1902 -11 5029
meshvertex 1903 -820 75 123790
localset 3403 0
meshtexuv 1903 -33 4952
localset 3301 4
jmp open_object_transform
label open_object_skip_236
localget r0 3300
cmp r0 100
jne open_object_skip_238
localget r0 3200
cmp r0 64
jgt open_object_next
localget r0 3201
cmp r0 63
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -2225 76 124179
localset 3400 0
meshtexuv 1900 -89 4967
meshvertex 1901 -2216 161 124179
localset 3401 0
meshtexuv 1901 -89 4967
meshvertex 1902 -2208 76 124179
localset 3402 0
meshtexuv 1902 -88 4967
meshvertex 1903 -2212 76 124197
localset 3403 0
meshtexuv 1903 -88 4968
meshvertex 1904 -2203 167 124197
localset 3404 0
meshtexuv 1904 -88 4968
meshvertex 1905 -2195 76 124197
localset 3405 0
meshtexuv 1905 -88 4968
meshvertex 1906 -2199 76 124215
localset 3406 0
meshtexuv 1906 -88 4969
meshvertex 1907 -2190 173 124215
localset 3407 0
meshtexuv 1907 -88 4969
meshvertex 1908 -2182 76 124215
localset 3408 0
meshtexuv 1908 -87 4969
meshvertex 1909 -2186 76 124233
localset 3409 0
meshtexuv 1909 -87 4969
meshvertex 1910 -2177 179 124233
localset 3410 0
meshtexuv 1910 -87 4969
meshvertex 1911 -2169 76 124233
localset 3411 0
meshtexuv 1911 -87 4969
localset 3301 12
jmp open_object_transform
label open_object_skip_238
localget r0 3300
cmp r0 101
jne open_object_skip_240
localget r0 3200
cmp r0 69
jgt open_object_next
localget r0 3201
cmp r0 68
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -2732 70 134456
localset 3400 0
meshtexuv 1900 -109 5378
meshvertex 1901 -2409 67 136360
localset 3401 0
meshtexuv 1901 -96 5454
meshvertex 1902 -586 67 136110
localset 3402 0
meshtexuv 1902 -23 5444
meshvertex 1903 -918 70 134150
localset 3403 0
meshtexuv 1903 -37 5366
localset 3301 4
jmp open_object_transform
label open_object_skip_240
localget r0 3300
cmp r0 102
jne open_object_skip_242
localget r0 3200
cmp r0 69
jgt open_object_next
localget r0 3201
cmp r0 68
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 -1312 71 134215
localset 3400 0
meshtexuv 1900 -52 5369
meshvertex 1901 -1303 156 134215
localset 3401 0
meshtexuv 1901 -52 5369
meshvertex 1902 -1295 71 134215
localset 3402 0
meshtexuv 1902 -52 5369
meshvertex 1903 -1299 71 134233
localset 3403 0
meshtexuv 1903 -52 5369
meshvertex 1904 -1290 162 134233
localset 3404 0
meshtexuv 1904 -52 5369
meshvertex 1905 -1282 71 134233
localset 3405 0
meshtexuv 1905 -51 5369
meshvertex 1906 -1286 71 134251
localset 3406 0
meshtexuv 1906 -51 5370
meshvertex 1907 -1277 168 134251
localset 3407 0
meshtexuv 1907 -51 5370
meshvertex 1908 -1269 71 134251
localset 3408 0
meshtexuv 1908 -51 5370
meshvertex 1909 -1273 71 134269
localset 3409 0
meshtexuv 1909 -51 5371
meshvertex 1910 -1264 174 134269
localset 3410 0
meshtexuv 1910 -51 5371
meshvertex 1911 -1256 71 134269
localset 3411 0
meshtexuv 1911 -50 5371
localset 3301 12
jmp open_object_transform
label open_object_skip_242
localget r0 3300
cmp r0 103
jne open_object_skip_244
localget r0 3200
cmp r0 69
jgt open_object_next
localget r0 3201
cmp r0 68
jle open_object_next
load8 r0 140
cmp r0 1
je open_object_next
localset 3310 0
localset 3311 150
localset 3312 1
localset 3314 0
localset 3315 0
load32 r0 115
div r0 7
mod r0 60
add r0 145
localset 3311 r0
meshvertex 1900 -208 70 134030
localset 3400 0
meshtexuv 1900 -8 5361
meshvertex 1901 128 67 136012
localset 3401 0
meshtexuv 1901 5 5440
meshvertex 1902 1951 67 135762
localset 3402 0
meshtexuv 1902 78 5430
meshvertex 1903 1606 70 133724
localset 3403 0
meshtexuv 1903 64 5349
localset 3301 4
jmp open_object_transform
label open_object_skip_244
localget r0 3300
cmp r0 104
jne open_object_skip_246
localget r0 3200
cmp r0 69
jgt open_object_next
localget r0 3201
cmp r0 68
jle open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 0
meshvertex 1900 168 71 133965
localset 3400 0
meshtexuv 1900 7 5359
meshvertex 1901 177 156 133965
localset 3401 0
meshtexuv 1901 7 5359
meshvertex 1902 185 71 133965
localset 3402 0
meshtexuv 1902 7 5359
meshvertex 1903 181 71 133983
localset 3403 0
meshtexuv 1903 7 5359
meshvertex 1904 190 162 133983
localset 3404 0
meshtexuv 1904 8 5359
meshvertex 1905 198 71 133983
localset 3405 0
meshtexuv 1905 8 5359
meshvertex 1906 194 71 134001
localset 3406 0
meshtexuv 1906 8 5360
meshvertex 1907 203 168 134001
localset 3407 0
meshtexuv 1907 8 5360
meshvertex 1908 211 71 134001
localset 3408 0
meshtexuv 1908 8 5360
meshvertex 1909 207 71 134019
localset 3409 0
meshtexuv 1909 8 5361
meshvertex 1910 216 174 134019
localset 3410 0
meshtexuv 1910 9 5361
meshvertex 1911 224 71 134019
localset 3411 0
meshtexuv 1911 9 5361
localset 3301 12
jmp open_object_transform
label open_object_skip_246
localget r0 3300
cmp r0 105
jne open_object_skip_248
localget r0 3200
cmp r0 6
jgt open_object_next
localget r0 3201
cmp r0 5
jle open_object_next
load8 r0 139
cmp r0 1
je open_object_next
load8 r0 526
cmp r0 2
je open_object_next
load32 r0 100
sub r0 2000767
mul r0 r0
load32 r1 104
sub r1 2009962
mul r1 r1
add r0 r1
cmp r0 36000000
jgt open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 1
load32 r0 115
mod r0 200
cmp r0 100
jle open_object_active_249
set r1 200
sub r1 r0
mov r0 r1
label open_object_active_249
sub r0 50
div r0 2
localset 3310 r0
meshvertex 1900 331 35 10001
localset 3400 0
meshtexuv 1900 13 400
meshvertex 1901 353 35 10001
localset 3401 0
meshtexuv 1901 14 400
meshvertex 1902 353 59 10001
localset 3402 0
meshtexuv 1902 14 400
meshvertex 1903 331 59 10001
localset 3403 0
meshtexuv 1903 13 400
meshvertex 1904 331 35 10049
localset 3404 0
meshtexuv 1904 13 402
meshvertex 1905 331 59 10049
localset 3405 0
meshtexuv 1905 13 402
meshvertex 1906 353 59 10049
localset 3406 0
meshtexuv 1906 14 402
meshvertex 1907 353 35 10049
localset 3407 0
meshtexuv 1907 14 402
meshvertex 1908 331 53 10036
localset 3408 0
meshtexuv 1908 13 401
meshvertex 1909 353 53 10036
localset 3409 0
meshtexuv 1909 14 401
meshvertex 1910 353 75 10036
localset 3410 0
meshtexuv 1910 14 401
meshvertex 1911 331 75 10036
localset 3411 0
meshtexuv 1911 13 401
meshvertex 1912 331 53 10058
localset 3412 0
meshtexuv 1912 13 402
meshvertex 1913 331 75 10058
localset 3413 0
meshtexuv 1913 13 402
meshvertex 1914 353 75 10058
localset 3414 0
meshtexuv 1914 14 402
meshvertex 1915 353 53 10058
localset 3415 0
meshtexuv 1915 14 402
meshvertex 1916 330 40 9986
localset 3416 0
meshtexuv 1916 13 399
meshvertex 1917 355 40 9986
localset 3417 0
meshtexuv 1917 14 399
meshvertex 1918 355 92 9986
localset 3418 0
meshtexuv 1918 14 399
meshvertex 1919 330 92 9986
localset 3419 0
meshtexuv 1919 13 399
meshvertex 1920 330 40 10006
localset 3420 0
meshtexuv 1920 13 400
meshvertex 1921 330 92 10006
localset 3421 0
meshtexuv 1921 13 400
meshvertex 1922 355 92 10006
localset 3422 0
meshtexuv 1922 14 400
meshvertex 1923 355 40 10006
localset 3423 0
meshtexuv 1923 14 400
meshvertex 1924 330 87 9994
localset 3424 0
meshtexuv 1924 13 400
meshvertex 1925 355 87 9994
localset 3425 0
meshtexuv 1925 14 400
meshvertex 1926 355 105 9994
localset 3426 0
meshtexuv 1926 14 400
meshvertex 1927 330 105 9994
localset 3427 0
meshtexuv 1927 13 400
meshvertex 1928 330 87 10026
localset 3428 0
meshtexuv 1928 13 401
meshvertex 1929 330 105 10026
localset 3429 0
meshtexuv 1929 13 401
meshvertex 1930 355 105 10026
localset 3430 0
meshtexuv 1930 14 401
meshvertex 1931 355 87 10026
localset 3431 0
meshtexuv 1931 14 401
meshvertex 1932 335 72 10046
localset 3432 0
meshtexuv 1932 13 402
meshvertex 1933 333 86 10043
localset 3433 0
meshtexuv 1933 13 402
meshvertex 1934 339 73 10051
localset 3434 0
meshtexuv 1934 14 402
meshvertex 1935 331 39 10012
localset 3435 0
meshtexuv 1935 13 400
meshvertex 1936 337 39 10012
localset 3436 0
meshtexuv 1936 13 400
meshvertex 1937 331 25 10016
localset 3437 2
meshtexuv 1937 13 401
meshvertex 1938 331 39 10040
localset 3438 0
meshtexuv 1938 13 402
meshvertex 1939 337 39 10040
localset 3439 0
meshtexuv 1939 13 402
meshvertex 1940 331 25 10044
localset 3440 -2
meshtexuv 1940 13 402
meshvertex 1941 331 67 10049
localset 3441 0
meshtexuv 1941 13 402
meshvertex 1942 330 67 10053
localset 3442 0
meshtexuv 1942 13 402
meshvertex 1943 331 70 10051
localset 3443 0
meshtexuv 1943 13 402
meshvertex 1944 349 72 10046
localset 3444 0
meshtexuv 1944 14 402
meshvertex 1945 351 86 10043
localset 3445 0
meshtexuv 1945 14 402
meshvertex 1946 345 73 10051
localset 3446 0
meshtexuv 1946 14 402
meshvertex 1947 347 39 10012
localset 3447 0
meshtexuv 1947 14 400
meshvertex 1948 353 39 10012
localset 3448 0
meshtexuv 1948 14 400
meshvertex 1949 353 25 10016
localset 3449 -2
meshtexuv 1949 14 401
meshvertex 1950 347 39 10040
localset 3450 0
meshtexuv 1950 14 402
meshvertex 1951 353 39 10040
localset 3451 0
meshtexuv 1951 14 402
meshvertex 1952 353 25 10044
localset 3452 2
meshtexuv 1952 14 402
meshvertex 1953 353 67 10049
localset 3453 0
meshtexuv 1953 14 402
meshvertex 1954 354 67 10053
localset 3454 0
meshtexuv 1954 14 402
meshvertex 1955 353 70 10051
localset 3455 0
meshtexuv 1955 14 402
localset 3301 56
jmp open_object_transform
label open_object_skip_248
localget r0 3300
cmp r0 106
jne open_object_skip_250
localget r0 3200
cmp r0 19
jgt open_object_next
localget r0 3201
cmp r0 18
jle open_object_next
load8 r0 139
cmp r0 1
je open_object_next
load8 r0 526
cmp r0 2
je open_object_next
load32 r0 100
sub r0 2003407
mul r0 r0
load32 r1 104
sub r1 2035782
mul r1 r1
add r0 r1
cmp r0 36000000
jgt open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 1
load32 r0 115
mod r0 200
cmp r0 100
jle open_object_active_251
set r1 200
sub r1 r0
mov r0 r1
label open_object_active_251
sub r0 50
div r0 2
localset 3310 r0
meshvertex 1900 3826 86 35771
localset 3400 0
meshtexuv 1900 153 1431
meshvertex 1901 3848 86 35771
localset 3401 0
meshtexuv 1901 154 1431
meshvertex 1902 3848 110 35771
localset 3402 0
meshtexuv 1902 154 1431
meshvertex 1903 3826 110 35771
localset 3403 0
meshtexuv 1903 153 1431
meshvertex 1904 3826 86 35819
localset 3404 0
meshtexuv 1904 153 1433
meshvertex 1905 3826 110 35819
localset 3405 0
meshtexuv 1905 153 1433
meshvertex 1906 3848 110 35819
localset 3406 0
meshtexuv 1906 154 1433
meshvertex 1907 3848 86 35819
localset 3407 0
meshtexuv 1907 154 1433
meshvertex 1908 3826 104 35806
localset 3408 0
meshtexuv 1908 153 1432
meshvertex 1909 3848 104 35806
localset 3409 0
meshtexuv 1909 154 1432
meshvertex 1910 3848 126 35806
localset 3410 0
meshtexuv 1910 154 1432
meshvertex 1911 3826 126 35806
localset 3411 0
meshtexuv 1911 153 1432
meshvertex 1912 3826 104 35828
localset 3412 0
meshtexuv 1912 153 1433
meshvertex 1913 3826 126 35828
localset 3413 0
meshtexuv 1913 153 1433
meshvertex 1914 3848 126 35828
localset 3414 0
meshtexuv 1914 154 1433
meshvertex 1915 3848 104 35828
localset 3415 0
meshtexuv 1915 154 1433
meshvertex 1916 3825 91 35756
localset 3416 0
meshtexuv 1916 153 1430
meshvertex 1917 3850 91 35756
localset 3417 0
meshtexuv 1917 154 1430
meshvertex 1918 3850 143 35756
localset 3418 0
meshtexuv 1918 154 1430
meshvertex 1919 3825 143 35756
localset 3419 0
meshtexuv 1919 153 1430
meshvertex 1920 3825 91 35776
localset 3420 0
meshtexuv 1920 153 1431
meshvertex 1921 3825 143 35776
localset 3421 0
meshtexuv 1921 153 1431
meshvertex 1922 3850 143 35776
localset 3422 0
meshtexuv 1922 154 1431
meshvertex 1923 3850 91 35776
localset 3423 0
meshtexuv 1923 154 1431
meshvertex 1924 3825 138 35764
localset 3424 0
meshtexuv 1924 153 1431
meshvertex 1925 3850 138 35764
localset 3425 0
meshtexuv 1925 154 1431
meshvertex 1926 3850 156 35764
localset 3426 0
meshtexuv 1926 154 1431
meshvertex 1927 3825 156 35764
localset 3427 0
meshtexuv 1927 153 1431
meshvertex 1928 3825 138 35796
localset 3428 0
meshtexuv 1928 153 1432
meshvertex 1929 3825 156 35796
localset 3429 0
meshtexuv 1929 153 1432
meshvertex 1930 3850 156 35796
localset 3430 0
meshtexuv 1930 154 1432
meshvertex 1931 3850 138 35796
localset 3431 0
meshtexuv 1931 154 1432
meshvertex 1932 3830 123 35816
localset 3432 0
meshtexuv 1932 153 1433
meshvertex 1933 3828 137 35813
localset 3433 0
meshtexuv 1933 153 1433
meshvertex 1934 3834 124 35821
localset 3434 0
meshtexuv 1934 153 1433
meshvertex 1935 3826 90 35782
localset 3435 0
meshtexuv 1935 153 1431
meshvertex 1936 3832 90 35782
localset 3436 0
meshtexuv 1936 153 1431
meshvertex 1937 3826 76 35786
localset 3437 2
meshtexuv 1937 153 1431
meshvertex 1938 3826 90 35810
localset 3438 0
meshtexuv 1938 153 1432
meshvertex 1939 3832 90 35810
localset 3439 0
meshtexuv 1939 153 1432
meshvertex 1940 3826 76 35814
localset 3440 -2
meshtexuv 1940 153 1433
meshvertex 1941 3826 118 35819
localset 3441 0
meshtexuv 1941 153 1433
meshvertex 1942 3825 118 35823
localset 3442 0
meshtexuv 1942 153 1433
meshvertex 1943 3826 121 35821
localset 3443 0
meshtexuv 1943 153 1433
meshvertex 1944 3844 123 35816
localset 3444 0
meshtexuv 1944 154 1433
meshvertex 1945 3846 137 35813
localset 3445 0
meshtexuv 1945 154 1433
meshvertex 1946 3840 124 35821
localset 3446 0
meshtexuv 1946 154 1433
meshvertex 1947 3842 90 35782
localset 3447 0
meshtexuv 1947 154 1431
meshvertex 1948 3848 90 35782
localset 3448 0
meshtexuv 1948 154 1431
meshvertex 1949 3848 76 35786
localset 3449 -2
meshtexuv 1949 154 1431
meshvertex 1950 3842 90 35810
localset 3450 0
meshtexuv 1950 154 1432
meshvertex 1951 3848 90 35810
localset 3451 0
meshtexuv 1951 154 1432
meshvertex 1952 3848 76 35814
localset 3452 2
meshtexuv 1952 154 1433
meshvertex 1953 3848 118 35819
localset 3453 0
meshtexuv 1953 154 1433
meshvertex 1954 3849 118 35823
localset 3454 0
meshtexuv 1954 154 1433
meshvertex 1955 3848 121 35821
localset 3455 0
meshtexuv 1955 154 1433
localset 3301 56
jmp open_object_transform
label open_object_skip_250
localget r0 3300
cmp r0 107
jne open_object_skip_252
localget r0 3200
cmp r0 25
jgt open_object_next
localget r0 3201
cmp r0 24
jle open_object_next
load8 r0 139
cmp r0 1
je open_object_next
load8 r0 526
cmp r0 2
je open_object_next
load32 r0 100
sub r0 2002797
mul r0 r0
load32 r1 104
sub r1 2047765
mul r1 r1
add r0 r1
cmp r0 36000000
jgt open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 1
load32 r0 115
mod r0 200
cmp r0 100
jle open_object_active_253
set r1 200
sub r1 r0
mov r0 r1
label open_object_active_253
sub r0 50
div r0 2
localset 3310 r0
meshvertex 1900 3215 134 47765
localset 3400 0
meshtexuv 1900 129 1911
meshvertex 1901 3237 134 47765
localset 3401 0
meshtexuv 1901 129 1911
meshvertex 1902 3237 158 47765
localset 3402 0
meshtexuv 1902 129 1911
meshvertex 1903 3215 158 47765
localset 3403 0
meshtexuv 1903 129 1911
meshvertex 1904 3215 134 47813
localset 3404 0
meshtexuv 1904 129 1913
meshvertex 1905 3215 158 47813
localset 3405 0
meshtexuv 1905 129 1913
meshvertex 1906 3237 158 47813
localset 3406 0
meshtexuv 1906 129 1913
meshvertex 1907 3237 134 47813
localset 3407 0
meshtexuv 1907 129 1913
meshvertex 1908 3215 152 47800
localset 3408 0
meshtexuv 1908 129 1912
meshvertex 1909 3237 152 47800
localset 3409 0
meshtexuv 1909 129 1912
meshvertex 1910 3237 174 47800
localset 3410 0
meshtexuv 1910 129 1912
meshvertex 1911 3215 174 47800
localset 3411 0
meshtexuv 1911 129 1912
meshvertex 1912 3215 152 47822
localset 3412 0
meshtexuv 1912 129 1913
meshvertex 1913 3215 174 47822
localset 3413 0
meshtexuv 1913 129 1913
meshvertex 1914 3237 174 47822
localset 3414 0
meshtexuv 1914 129 1913
meshvertex 1915 3237 152 47822
localset 3415 0
meshtexuv 1915 129 1913
meshvertex 1916 3214 139 47750
localset 3416 0
meshtexuv 1916 129 1910
meshvertex 1917 3239 139 47750
localset 3417 0
meshtexuv 1917 130 1910
meshvertex 1918 3239 191 47750
localset 3418 0
meshtexuv 1918 130 1910
meshvertex 1919 3214 191 47750
localset 3419 0
meshtexuv 1919 129 1910
meshvertex 1920 3214 139 47770
localset 3420 0
meshtexuv 1920 129 1911
meshvertex 1921 3214 191 47770
localset 3421 0
meshtexuv 1921 129 1911
meshvertex 1922 3239 191 47770
localset 3422 0
meshtexuv 1922 130 1911
meshvertex 1923 3239 139 47770
localset 3423 0
meshtexuv 1923 130 1911
meshvertex 1924 3214 186 47758
localset 3424 0
meshtexuv 1924 129 1910
meshvertex 1925 3239 186 47758
localset 3425 0
meshtexuv 1925 130 1910
meshvertex 1926 3239 204 47758
localset 3426 0
meshtexuv 1926 130 1910
meshvertex 1927 3214 204 47758
localset 3427 0
meshtexuv 1927 129 1910
meshvertex 1928 3214 186 47790
localset 3428 0
meshtexuv 1928 129 1912
meshvertex 1929 3214 204 47790
localset 3429 0
meshtexuv 1929 129 1912
meshvertex 1930 3239 204 47790
localset 3430 0
meshtexuv 1930 130 1912
meshvertex 1931 3239 186 47790
localset 3431 0
meshtexuv 1931 130 1912
meshvertex 1932 3219 171 47810
localset 3432 0
meshtexuv 1932 129 1912
meshvertex 1933 3217 185 47807
localset 3433 0
meshtexuv 1933 129 1912
meshvertex 1934 3223 172 47815
localset 3434 0
meshtexuv 1934 129 1913
meshvertex 1935 3215 138 47776
localset 3435 0
meshtexuv 1935 129 1911
meshvertex 1936 3221 138 47776
localset 3436 0
meshtexuv 1936 129 1911
meshvertex 1937 3215 124 47780
localset 3437 2
meshtexuv 1937 129 1911
meshvertex 1938 3215 138 47804
localset 3438 0
meshtexuv 1938 129 1912
meshvertex 1939 3221 138 47804
localset 3439 0
meshtexuv 1939 129 1912
meshvertex 1940 3215 124 47808
localset 3440 -2
meshtexuv 1940 129 1912
meshvertex 1941 3215 166 47813
localset 3441 0
meshtexuv 1941 129 1913
meshvertex 1942 3214 166 47817
localset 3442 0
meshtexuv 1942 129 1913
meshvertex 1943 3215 169 47815
localset 3443 0
meshtexuv 1943 129 1913
meshvertex 1944 3233 171 47810
localset 3444 0
meshtexuv 1944 129 1912
meshvertex 1945 3235 185 47807
localset 3445 0
meshtexuv 1945 129 1912
meshvertex 1946 3229 172 47815
localset 3446 0
meshtexuv 1946 129 1913
meshvertex 1947 3231 138 47776
localset 3447 0
meshtexuv 1947 129 1911
meshvertex 1948 3237 138 47776
localset 3448 0
meshtexuv 1948 129 1911
meshvertex 1949 3237 124 47780
localset 3449 -2
meshtexuv 1949 129 1911
meshvertex 1950 3231 138 47804
localset 3450 0
meshtexuv 1950 129 1912
meshvertex 1951 3237 138 47804
localset 3451 0
meshtexuv 1951 129 1912
meshvertex 1952 3237 124 47808
localset 3452 2
meshtexuv 1952 129 1912
meshvertex 1953 3237 166 47813
localset 3453 0
meshtexuv 1953 129 1913
meshvertex 1954 3238 166 47817
localset 3454 0
meshtexuv 1954 130 1913
meshvertex 1955 3237 169 47815
localset 3455 0
meshtexuv 1955 129 1913
localset 3301 56
jmp open_object_transform
label open_object_skip_252
localget r0 3300
cmp r0 108
jne open_object_skip_254
localget r0 3200
cmp r0 34
jgt open_object_next
localget r0 3201
cmp r0 33
jle open_object_next
load8 r0 139
cmp r0 1
je open_object_next
load8 r0 526
cmp r0 2
je open_object_next
load32 r0 100
sub r0 2001903
mul r0 r0
load32 r1 104
sub r1 2065742
mul r1 r1
add r0 r1
cmp r0 36000000
jgt open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 1
load32 r0 115
mod r0 200
cmp r0 100
jle open_object_active_255
set r1 200
sub r1 r0
mov r0 r1
label open_object_active_255
sub r0 50
div r0 2
localset 3310 r0
meshvertex 1900 1463 196 65682
localset 3400 0
meshtexuv 1900 59 2627
meshvertex 1901 1485 196 65682
localset 3401 0
meshtexuv 1901 59 2627
meshvertex 1902 1485 220 65682
localset 3402 0
meshtexuv 1902 59 2627
meshvertex 1903 1463 220 65682
localset 3403 0
meshtexuv 1903 59 2627
meshvertex 1904 1463 196 65730
localset 3404 0
meshtexuv 1904 59 2629
meshvertex 1905 1463 220 65730
localset 3405 0
meshtexuv 1905 59 2629
meshvertex 1906 1485 220 65730
localset 3406 0
meshtexuv 1906 59 2629
meshvertex 1907 1485 196 65730
localset 3407 0
meshtexuv 1907 59 2629
meshvertex 1908 1463 214 65717
localset 3408 0
meshtexuv 1908 59 2629
meshvertex 1909 1485 214 65717
localset 3409 0
meshtexuv 1909 59 2629
meshvertex 1910 1485 236 65717
localset 3410 0
meshtexuv 1910 59 2629
meshvertex 1911 1463 236 65717
localset 3411 0
meshtexuv 1911 59 2629
meshvertex 1912 1463 214 65739
localset 3412 0
meshtexuv 1912 59 2630
meshvertex 1913 1463 236 65739
localset 3413 0
meshtexuv 1913 59 2630
meshvertex 1914 1485 236 65739
localset 3414 0
meshtexuv 1914 59 2630
meshvertex 1915 1485 214 65739
localset 3415 0
meshtexuv 1915 59 2630
meshvertex 1916 1462 201 65667
localset 3416 0
meshtexuv 1916 58 2627
meshvertex 1917 1487 201 65667
localset 3417 0
meshtexuv 1917 59 2627
meshvertex 1918 1487 253 65667
localset 3418 0
meshtexuv 1918 59 2627
meshvertex 1919 1462 253 65667
localset 3419 0
meshtexuv 1919 58 2627
meshvertex 1920 1462 201 65687
localset 3420 0
meshtexuv 1920 58 2627
meshvertex 1921 1462 253 65687
localset 3421 0
meshtexuv 1921 58 2627
meshvertex 1922 1487 253 65687
localset 3422 0
meshtexuv 1922 59 2627
meshvertex 1923 1487 201 65687
localset 3423 0
meshtexuv 1923 59 2627
meshvertex 1924 1462 248 65675
localset 3424 0
meshtexuv 1924 58 2627
meshvertex 1925 1487 248 65675
localset 3425 0
meshtexuv 1925 59 2627
meshvertex 1926 1487 266 65675
localset 3426 0
meshtexuv 1926 59 2627
meshvertex 1927 1462 266 65675
localset 3427 0
meshtexuv 1927 58 2627
meshvertex 1928 1462 248 65707
localset 3428 0
meshtexuv 1928 58 2628
meshvertex 1929 1462 266 65707
localset 3429 0
meshtexuv 1929 58 2628
meshvertex 1930 1487 266 65707
localset 3430 0
meshtexuv 1930 59 2628
meshvertex 1931 1487 248 65707
localset 3431 0
meshtexuv 1931 59 2628
meshvertex 1932 1467 233 65727
localset 3432 0
meshtexuv 1932 59 2629
meshvertex 1933 1465 247 65724
localset 3433 0
meshtexuv 1933 59 2629
meshvertex 1934 1471 234 65732
localset 3434 0
meshtexuv 1934 59 2629
meshvertex 1935 1463 200 65693
localset 3435 0
meshtexuv 1935 59 2628
meshvertex 1936 1469 200 65693
localset 3436 0
meshtexuv 1936 59 2628
meshvertex 1937 1463 186 65697
localset 3437 2
meshtexuv 1937 59 2628
meshvertex 1938 1463 200 65721
localset 3438 0
meshtexuv 1938 59 2629
meshvertex 1939 1469 200 65721
localset 3439 0
meshtexuv 1939 59 2629
meshvertex 1940 1463 186 65725
localset 3440 -2
meshtexuv 1940 59 2629
meshvertex 1941 1463 228 65730
localset 3441 0
meshtexuv 1941 59 2629
meshvertex 1942 1462 228 65734
localset 3442 0
meshtexuv 1942 58 2629
meshvertex 1943 1463 231 65732
localset 3443 0
meshtexuv 1943 59 2629
meshvertex 1944 1481 233 65727
localset 3444 0
meshtexuv 1944 59 2629
meshvertex 1945 1483 247 65724
localset 3445 0
meshtexuv 1945 59 2629
meshvertex 1946 1477 234 65732
localset 3446 0
meshtexuv 1946 59 2629
meshvertex 1947 1479 200 65693
localset 3447 0
meshtexuv 1947 59 2628
meshvertex 1948 1485 200 65693
localset 3448 0
meshtexuv 1948 59 2628
meshvertex 1949 1485 186 65697
localset 3449 -2
meshtexuv 1949 59 2628
meshvertex 1950 1479 200 65721
localset 3450 0
meshtexuv 1950 59 2629
meshvertex 1951 1485 200 65721
localset 3451 0
meshtexuv 1951 59 2629
meshvertex 1952 1485 186 65725
localset 3452 2
meshtexuv 1952 59 2629
meshvertex 1953 1485 228 65730
localset 3453 0
meshtexuv 1953 59 2629
meshvertex 1954 1486 228 65734
localset 3454 0
meshtexuv 1954 59 2629
meshvertex 1955 1485 231 65732
localset 3455 0
meshtexuv 1955 59 2629
localset 3301 56
jmp open_object_transform
label open_object_skip_254
localget r0 3300
cmp r0 109
jne open_object_skip_256
localget r0 3200
cmp r0 47
jgt open_object_next
localget r0 3201
cmp r0 46
jle open_object_next
load8 r0 139
cmp r0 1
je open_object_next
load8 r0 526
cmp r0 2
je open_object_next
load32 r0 100
sub r0 1996324
mul r0 r0
load32 r1 104
sub r1 2091059
mul r1 r1
add r0 r1
cmp r0 36000000
jgt open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 1
load32 r0 115
mod r0 200
cmp r0 100
jle open_object_active_257
set r1 200
sub r1 r0
mov r0 r1
label open_object_active_257
sub r0 50
div r0 2
localset 3310 r0
meshvertex 1900 -3274 195 91156
localset 3400 0
meshtexuv 1900 -131 3646
meshvertex 1901 -3252 195 91156
localset 3401 0
meshtexuv 1901 -130 3646
meshvertex 1902 -3252 219 91156
localset 3402 0
meshtexuv 1902 -130 3646
meshvertex 1903 -3274 219 91156
localset 3403 0
meshtexuv 1903 -131 3646
meshvertex 1904 -3274 195 91204
localset 3404 0
meshtexuv 1904 -131 3648
meshvertex 1905 -3274 219 91204
localset 3405 0
meshtexuv 1905 -131 3648
meshvertex 1906 -3252 219 91204
localset 3406 0
meshtexuv 1906 -130 3648
meshvertex 1907 -3252 195 91204
localset 3407 0
meshtexuv 1907 -130 3648
meshvertex 1908 -3274 213 91191
localset 3408 0
meshtexuv 1908 -131 3648
meshvertex 1909 -3252 213 91191
localset 3409 0
meshtexuv 1909 -130 3648
meshvertex 1910 -3252 235 91191
localset 3410 0
meshtexuv 1910 -130 3648
meshvertex 1911 -3274 235 91191
localset 3411 0
meshtexuv 1911 -131 3648
meshvertex 1912 -3274 213 91213
localset 3412 0
meshtexuv 1912 -131 3649
meshvertex 1913 -3274 235 91213
localset 3413 0
meshtexuv 1913 -131 3649
meshvertex 1914 -3252 235 91213
localset 3414 0
meshtexuv 1914 -130 3649
meshvertex 1915 -3252 213 91213
localset 3415 0
meshtexuv 1915 -130 3649
meshvertex 1916 -3275 200 91141
localset 3416 0
meshtexuv 1916 -131 3646
meshvertex 1917 -3250 200 91141
localset 3417 0
meshtexuv 1917 -130 3646
meshvertex 1918 -3250 252 91141
localset 3418 0
meshtexuv 1918 -130 3646
meshvertex 1919 -3275 252 91141
localset 3419 0
meshtexuv 1919 -131 3646
meshvertex 1920 -3275 200 91161
localset 3420 0
meshtexuv 1920 -131 3646
meshvertex 1921 -3275 252 91161
localset 3421 0
meshtexuv 1921 -131 3646
meshvertex 1922 -3250 252 91161
localset 3422 0
meshtexuv 1922 -130 3646
meshvertex 1923 -3250 200 91161
localset 3423 0
meshtexuv 1923 -130 3646
meshvertex 1924 -3275 247 91149
localset 3424 0
meshtexuv 1924 -131 3646
meshvertex 1925 -3250 247 91149
localset 3425 0
meshtexuv 1925 -130 3646
meshvertex 1926 -3250 265 91149
localset 3426 0
meshtexuv 1926 -130 3646
meshvertex 1927 -3275 265 91149
localset 3427 0
meshtexuv 1927 -131 3646
meshvertex 1928 -3275 247 91181
localset 3428 0
meshtexuv 1928 -131 3647
meshvertex 1929 -3275 265 91181
localset 3429 0
meshtexuv 1929 -131 3647
meshvertex 1930 -3250 265 91181
localset 3430 0
meshtexuv 1930 -130 3647
meshvertex 1931 -3250 247 91181
localset 3431 0
meshtexuv 1931 -130 3647
meshvertex 1932 -3270 232 91201
localset 3432 0
meshtexuv 1932 -131 3648
meshvertex 1933 -3272 246 91198
localset 3433 0
meshtexuv 1933 -131 3648
meshvertex 1934 -3266 233 91206
localset 3434 0
meshtexuv 1934 -131 3648
meshvertex 1935 -3274 199 91167
localset 3435 0
meshtexuv 1935 -131 3647
meshvertex 1936 -3268 199 91167
localset 3436 0
meshtexuv 1936 -131 3647
meshvertex 1937 -3274 185 91171
localset 3437 2
meshtexuv 1937 -131 3647
meshvertex 1938 -3274 199 91195
localset 3438 0
meshtexuv 1938 -131 3648
meshvertex 1939 -3268 199 91195
localset 3439 0
meshtexuv 1939 -131 3648
meshvertex 1940 -3274 185 91199
localset 3440 -2
meshtexuv 1940 -131 3648
meshvertex 1941 -3274 227 91204
localset 3441 0
meshtexuv 1941 -131 3648
meshvertex 1942 -3275 227 91208
localset 3442 0
meshtexuv 1942 -131 3648
meshvertex 1943 -3274 230 91206
localset 3443 0
meshtexuv 1943 -131 3648
meshvertex 1944 -3256 232 91201
localset 3444 0
meshtexuv 1944 -130 3648
meshvertex 1945 -3254 246 91198
localset 3445 0
meshtexuv 1945 -130 3648
meshvertex 1946 -3260 233 91206
localset 3446 0
meshtexuv 1946 -130 3648
meshvertex 1947 -3258 199 91167
localset 3447 0
meshtexuv 1947 -130 3647
meshvertex 1948 -3252 199 91167
localset 3448 0
meshtexuv 1948 -130 3647
meshvertex 1949 -3252 185 91171
localset 3449 -2
meshtexuv 1949 -130 3647
meshvertex 1950 -3258 199 91195
localset 3450 0
meshtexuv 1950 -130 3648
meshvertex 1951 -3252 199 91195
localset 3451 0
meshtexuv 1951 -130 3648
meshvertex 1952 -3252 185 91199
localset 3452 2
meshtexuv 1952 -130 3648
meshvertex 1953 -3252 227 91204
localset 3453 0
meshtexuv 1953 -130 3648
meshvertex 1954 -3251 227 91208
localset 3454 0
meshtexuv 1954 -130 3648
meshvertex 1955 -3252 230 91206
localset 3455 0
meshtexuv 1955 -130 3648
localset 3301 56
jmp open_object_transform
label open_object_skip_256
localget r0 3300
cmp r0 110
jne open_object_skip_258
localget r0 3200
cmp r0 69
jgt open_object_next
localget r0 3201
cmp r0 68
jle open_object_next
load8 r0 139
cmp r0 1
je open_object_next
load8 r0 526
cmp r0 2
je open_object_next
load32 r0 100
sub r0 1999437
mul r0 r0
load32 r1 104
sub r1 2134090
mul r1 r1
add r0 r1
cmp r0 36000000
jgt open_object_next
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 0
localset 3315 1
load32 r0 115
mod r0 200
cmp r0 100
jle open_object_active_259
set r1 200
sub r1 r0
mov r0 r1
label open_object_active_259
sub r0 50
div r0 2
localset 3310 r0
meshvertex 1900 -150 78 133994
localset 3400 0
meshtexuv 1900 -6 5360
meshvertex 1901 -128 78 133994
localset 3401 0
meshtexuv 1901 -5 5360
meshvertex 1902 -128 102 133994
localset 3402 0
meshtexuv 1902 -5 5360
meshvertex 1903 -150 102 133994
localset 3403 0
meshtexuv 1903 -6 5360
meshvertex 1904 -150 78 134042
localset 3404 0
meshtexuv 1904 -6 5362
meshvertex 1905 -150 102 134042
localset 3405 0
meshtexuv 1905 -6 5362
meshvertex 1906 -128 102 134042
localset 3406 0
meshtexuv 1906 -5 5362
meshvertex 1907 -128 78 134042
localset 3407 0
meshtexuv 1907 -5 5362
meshvertex 1908 -150 96 134029
localset 3408 0
meshtexuv 1908 -6 5361
meshvertex 1909 -128 96 134029
localset 3409 0
meshtexuv 1909 -5 5361
meshvertex 1910 -128 118 134029
localset 3410 0
meshtexuv 1910 -5 5361
meshvertex 1911 -150 118 134029
localset 3411 0
meshtexuv 1911 -6 5361
meshvertex 1912 -150 96 134051
localset 3412 0
meshtexuv 1912 -6 5362
meshvertex 1913 -150 118 134051
localset 3413 0
meshtexuv 1913 -6 5362
meshvertex 1914 -128 118 134051
localset 3414 0
meshtexuv 1914 -5 5362
meshvertex 1915 -128 96 134051
localset 3415 0
meshtexuv 1915 -5 5362
meshvertex 1916 -151 83 133979
localset 3416 0
meshtexuv 1916 -6 5359
meshvertex 1917 -126 83 133979
localset 3417 0
meshtexuv 1917 -5 5359
meshvertex 1918 -126 135 133979
localset 3418 0
meshtexuv 1918 -5 5359
meshvertex 1919 -151 135 133979
localset 3419 0
meshtexuv 1919 -6 5359
meshvertex 1920 -151 83 133999
localset 3420 0
meshtexuv 1920 -6 5360
meshvertex 1921 -151 135 133999
localset 3421 0
meshtexuv 1921 -6 5360
meshvertex 1922 -126 135 133999
localset 3422 0
meshtexuv 1922 -5 5360
meshvertex 1923 -126 83 133999
localset 3423 0
meshtexuv 1923 -5 5360
meshvertex 1924 -151 130 133987
localset 3424 0
meshtexuv 1924 -6 5359
meshvertex 1925 -126 130 133987
localset 3425 0
meshtexuv 1925 -5 5359
meshvertex 1926 -126 148 133987
localset 3426 0
meshtexuv 1926 -5 5359
meshvertex 1927 -151 148 133987
localset 3427 0
meshtexuv 1927 -6 5359
meshvertex 1928 -151 130 134019
localset 3428 0
meshtexuv 1928 -6 5361
meshvertex 1929 -151 148 134019
localset 3429 0
meshtexuv 1929 -6 5361
meshvertex 1930 -126 148 134019
localset 3430 0
meshtexuv 1930 -5 5361
meshvertex 1931 -126 130 134019
localset 3431 0
meshtexuv 1931 -5 5361
meshvertex 1932 -146 115 134039
localset 3432 0
meshtexuv 1932 -6 5362
meshvertex 1933 -148 129 134036
localset 3433 0
meshtexuv 1933 -6 5361
meshvertex 1934 -142 116 134044
localset 3434 0
meshtexuv 1934 -6 5362
meshvertex 1935 -150 82 134005
localset 3435 0
meshtexuv 1935 -6 5360
meshvertex 1936 -144 82 134005
localset 3436 0
meshtexuv 1936 -6 5360
meshvertex 1937 -150 68 134009
localset 3437 2
meshtexuv 1937 -6 5360
meshvertex 1938 -150 82 134033
localset 3438 0
meshtexuv 1938 -6 5361
meshvertex 1939 -144 82 134033
localset 3439 0
meshtexuv 1939 -6 5361
meshvertex 1940 -150 68 134037
localset 3440 -2
meshtexuv 1940 -6 5361
meshvertex 1941 -150 110 134042
localset 3441 0
meshtexuv 1941 -6 5362
meshvertex 1942 -151 110 134046
localset 3442 0
meshtexuv 1942 -6 5362
meshvertex 1943 -150 113 134044
localset 3443 0
meshtexuv 1943 -6 5362
meshvertex 1944 -132 115 134039
localset 3444 0
meshtexuv 1944 -5 5362
meshvertex 1945 -130 129 134036
localset 3445 0
meshtexuv 1945 -5 5361
meshvertex 1946 -136 116 134044
localset 3446 0
meshtexuv 1946 -5 5362
meshvertex 1947 -134 82 134005
localset 3447 0
meshtexuv 1947 -5 5360
meshvertex 1948 -128 82 134005
localset 3448 0
meshtexuv 1948 -5 5360
meshvertex 1949 -128 68 134009
localset 3449 -2
meshtexuv 1949 -5 5360
meshvertex 1950 -134 82 134033
localset 3450 0
meshtexuv 1950 -5 5361
meshvertex 1951 -128 82 134033
localset 3451 0
meshtexuv 1951 -5 5361
meshvertex 1952 -128 68 134037
localset 3452 2
meshtexuv 1952 -5 5361
meshvertex 1953 -128 110 134042
localset 3453 0
meshtexuv 1953 -5 5362
meshvertex 1954 -127 110 134046
localset 3454 0
meshtexuv 1954 -5 5362
meshvertex 1955 -128 113 134044
localset 3455 0
meshtexuv 1955 -5 5362
localset 3301 56
jmp open_object_transform
label open_object_skip_258
localget r0 3300
cmp r0 111
jne open_object_skip_260
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 1
localset 3315 0
meshvertex 1900 -92 97 -221
localset 3400 0
meshtexuv 1900 -4 -9
meshvertex 1901 92 97 -221
localset 3401 0
meshtexuv 1901 4 -9
meshvertex 1902 92 102 -221
localset 3402 0
meshtexuv 1902 4 -9
meshvertex 1903 -92 102 -221
localset 3403 0
meshtexuv 1903 -4 -9
meshvertex 1904 -92 97 -194
localset 3404 0
meshtexuv 1904 -4 -8
meshvertex 1905 -92 102 -194
localset 3405 0
meshtexuv 1905 -4 -8
meshvertex 1906 92 102 -194
localset 3406 0
meshtexuv 1906 4 -8
meshvertex 1907 92 97 -194
localset 3407 0
meshtexuv 1907 4 -8
meshvertex 1908 -65 69 -213
localset 3408 0
meshtexuv 1908 -3 -9
meshvertex 1909 -60 69 -213
localset 3409 0
meshtexuv 1909 -2 -9
meshvertex 1910 -60 99 -213
localset 3410 0
meshtexuv 1910 -2 -9
meshvertex 1911 -65 99 -213
localset 3411 0
meshtexuv 1911 -3 -9
meshvertex 1912 -65 69 -201
localset 3412 0
meshtexuv 1912 -3 -8
meshvertex 1913 -65 99 -201
localset 3413 0
meshtexuv 1913 -3 -8
meshvertex 1914 -60 99 -201
localset 3414 0
meshtexuv 1914 -2 -8
meshvertex 1915 -60 69 -201
localset 3415 0
meshtexuv 1915 -2 -8
meshvertex 1916 -94 81 -222
localset 3416 0
meshtexuv 1916 -4 -9
meshvertex 1917 -94 105 -222
localset 3417 0
meshtexuv 1917 -4 -9
meshvertex 1918 -94 105 -194
localset 3418 0
meshtexuv 1918 -4 -8
meshvertex 1919 -94 81 -194
localset 3419 0
meshtexuv 1919 -4 -8
meshvertex 1920 61 69 -213
localset 3420 0
meshtexuv 1920 2 -9
meshvertex 1921 66 69 -213
localset 3421 0
meshtexuv 1921 3 -9
meshvertex 1922 66 99 -213
localset 3422 0
meshtexuv 1922 3 -9
meshvertex 1923 61 99 -213
localset 3423 0
meshtexuv 1923 2 -9
meshvertex 1924 61 69 -201
localset 3424 0
meshtexuv 1924 2 -8
meshvertex 1925 61 99 -201
localset 3425 0
meshtexuv 1925 2 -8
meshvertex 1926 66 99 -201
localset 3426 0
meshtexuv 1926 3 -8
meshvertex 1927 66 69 -201
localset 3427 0
meshtexuv 1927 3 -8
meshvertex 1928 94 81 -222
localset 3428 0
meshtexuv 1928 4 -9
meshvertex 1929 94 105 -222
localset 3429 0
meshtexuv 1929 4 -9
meshvertex 1930 94 105 -194
localset 3430 0
meshtexuv 1930 4 -8
meshvertex 1931 94 81 -194
localset 3431 0
meshtexuv 1931 4 -8
meshvertex 1932 -92 103 -220
localset 3432 0
meshtexuv 1932 -4 -9
meshvertex 1933 92 103 -220
localset 3433 0
meshtexuv 1933 4 -9
meshvertex 1934 92 103 -216
localset 3434 0
meshtexuv 1934 4 -9
meshvertex 1935 -92 103 -216
localset 3435 0
meshtexuv 1935 -4 -9
localset 3301 36
jmp open_object_transform
label open_object_skip_260
localget r0 3300
cmp r0 112
jne open_object_skip_262
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 1
localset 3315 0
meshvertex 1900 -50 26 -234
localset 3400 0
meshtexuv 1900 -2 -9
meshvertex 1901 -53 32 -234
localset 3401 0
meshtexuv 1901 -2 -9
meshvertex 1902 -54 30 -235
localset 3402 0
meshtexuv 1902 -2 -9
meshvertex 1903 -52 26 -235
localset 3403 0
meshtexuv 1903 -2 -9
meshvertex 1904 -50 26 -226
localset 3404 0
meshtexuv 1904 -2 -9
meshvertex 1905 -53 32 -226
localset 3405 0
meshtexuv 1905 -2 -9
meshvertex 1906 -57 26 -234
localset 3406 0
meshtexuv 1906 -2 -9
meshvertex 1907 -60 32 -234
localset 3407 0
meshtexuv 1907 -2 -9
meshvertex 1908 -59 30 -235
localset 3408 0
meshtexuv 1908 -2 -9
meshvertex 1909 -60 32 -226
localset 3409 0
meshtexuv 1909 -2 -9
meshvertex 1910 -64 26 -234
localset 3410 0
meshtexuv 1910 -3 -9
meshvertex 1911 -62 26 -235
localset 3411 0
meshtexuv 1911 -2 -9
meshvertex 1912 -64 26 -226
localset 3412 0
meshtexuv 1912 -3 -9
meshvertex 1913 -60 20 -234
localset 3413 0
meshtexuv 1913 -2 -9
meshvertex 1914 -59 22 -235
localset 3414 0
meshtexuv 1914 -2 -9
meshvertex 1915 -60 20 -226
localset 3415 0
meshtexuv 1915 -2 -9
meshvertex 1916 -53 20 -234
localset 3416 0
meshtexuv 1916 -2 -9
meshvertex 1917 -54 22 -235
localset 3417 0
meshtexuv 1917 -2 -9
meshvertex 1918 -53 20 -226
localset 3418 0
meshtexuv 1918 -2 -9
localset 3301 19
jmp open_object_transform
label open_object_skip_262
localget r0 3300
cmp r0 113
jne open_object_skip_264
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 1
localset 3315 0
meshvertex 1900 -12 26 -234
localset 3400 0
meshtexuv 1900 0 -9
meshvertex 1901 -15 32 -234
localset 3401 0
meshtexuv 1901 -1 -9
meshvertex 1902 -16 30 -235
localset 3402 0
meshtexuv 1902 -1 -9
meshvertex 1903 -14 26 -235
localset 3403 0
meshtexuv 1903 -1 -9
meshvertex 1904 -12 26 -226
localset 3404 0
meshtexuv 1904 0 -9
meshvertex 1905 -15 32 -226
localset 3405 0
meshtexuv 1905 -1 -9
meshvertex 1906 -19 26 -234
localset 3406 0
meshtexuv 1906 -1 -9
meshvertex 1907 -22 32 -234
localset 3407 0
meshtexuv 1907 -1 -9
meshvertex 1908 -21 30 -235
localset 3408 0
meshtexuv 1908 -1 -9
meshvertex 1909 -22 32 -226
localset 3409 0
meshtexuv 1909 -1 -9
meshvertex 1910 -26 26 -234
localset 3410 0
meshtexuv 1910 -1 -9
meshvertex 1911 -24 26 -235
localset 3411 0
meshtexuv 1911 -1 -9
meshvertex 1912 -26 26 -226
localset 3412 0
meshtexuv 1912 -1 -9
meshvertex 1913 -23 20 -234
localset 3413 0
meshtexuv 1913 -1 -9
meshvertex 1914 -22 22 -235
localset 3414 0
meshtexuv 1914 -1 -9
meshvertex 1915 -23 20 -226
localset 3415 0
meshtexuv 1915 -1 -9
meshvertex 1916 -15 20 -234
localset 3416 0
meshtexuv 1916 -1 -9
meshvertex 1917 -16 22 -235
localset 3417 0
meshtexuv 1917 -1 -9
meshvertex 1918 -15 20 -226
localset 3418 0
meshtexuv 1918 -1 -9
localset 3301 19
jmp open_object_transform
label open_object_skip_264
localget r0 3300
cmp r0 114
jne open_object_skip_266
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 1
localset 3315 0
meshvertex 1900 26 26 -234
localset 3400 0
meshtexuv 1900 1 -9
meshvertex 1901 23 32 -234
localset 3401 0
meshtexuv 1901 1 -9
meshvertex 1902 22 30 -235
localset 3402 0
meshtexuv 1902 1 -9
meshvertex 1903 24 26 -235
localset 3403 0
meshtexuv 1903 1 -9
meshvertex 1904 26 26 -226
localset 3404 0
meshtexuv 1904 1 -9
meshvertex 1905 23 32 -226
localset 3405 0
meshtexuv 1905 1 -9
meshvertex 1906 19 26 -234
localset 3406 0
meshtexuv 1906 1 -9
meshvertex 1907 16 32 -234
localset 3407 0
meshtexuv 1907 1 -9
meshvertex 1908 17 30 -235
localset 3408 0
meshtexuv 1908 1 -9
meshvertex 1909 16 32 -226
localset 3409 0
meshtexuv 1909 1 -9
meshvertex 1910 12 26 -234
localset 3410 0
meshtexuv 1910 0 -9
meshvertex 1911 14 26 -235
localset 3411 0
meshtexuv 1911 1 -9
meshvertex 1912 12 26 -226
localset 3412 0
meshtexuv 1912 0 -9
meshvertex 1913 15 20 -234
localset 3413 0
meshtexuv 1913 1 -9
meshvertex 1914 16 22 -235
localset 3414 0
meshtexuv 1914 1 -9
meshvertex 1915 15 20 -226
localset 3415 0
meshtexuv 1915 1 -9
meshvertex 1916 23 20 -234
localset 3416 0
meshtexuv 1916 1 -9
meshvertex 1917 22 22 -235
localset 3417 0
meshtexuv 1917 1 -9
meshvertex 1918 23 20 -226
localset 3418 0
meshtexuv 1918 1 -9
localset 3301 19
jmp open_object_transform
label open_object_skip_266
localget r0 3300
cmp r0 115
jne open_object_skip_268
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 1
localset 3315 0
meshvertex 1900 64 26 -234
localset 3400 0
meshtexuv 1900 3 -9
meshvertex 1901 61 32 -234
localset 3401 0
meshtexuv 1901 2 -9
meshvertex 1902 60 30 -235
localset 3402 0
meshtexuv 1902 2 -9
meshvertex 1903 62 26 -235
localset 3403 0
meshtexuv 1903 2 -9
meshvertex 1904 64 26 -226
localset 3404 0
meshtexuv 1904 3 -9
meshvertex 1905 61 32 -226
localset 3405 0
meshtexuv 1905 2 -9
meshvertex 1906 57 26 -234
localset 3406 0
meshtexuv 1906 2 -9
meshvertex 1907 54 32 -234
localset 3407 0
meshtexuv 1907 2 -9
meshvertex 1908 55 30 -235
localset 3408 0
meshtexuv 1908 2 -9
meshvertex 1909 54 32 -226
localset 3409 0
meshtexuv 1909 2 -9
meshvertex 1910 50 26 -234
localset 3410 0
meshtexuv 1910 2 -9
meshvertex 1911 52 26 -235
localset 3411 0
meshtexuv 1911 2 -9
meshvertex 1912 50 26 -226
localset 3412 0
meshtexuv 1912 2 -9
meshvertex 1913 54 20 -234
localset 3413 0
meshtexuv 1913 2 -9
meshvertex 1914 55 22 -235
localset 3414 0
meshtexuv 1914 2 -9
meshvertex 1915 54 20 -226
localset 3415 0
meshtexuv 1915 2 -9
meshvertex 1916 61 20 -234
localset 3416 0
meshtexuv 1916 2 -9
meshvertex 1917 60 22 -235
localset 3417 0
meshtexuv 1917 2 -9
meshvertex 1918 61 20 -226
localset 3418 0
meshtexuv 1918 2 -9
localset 3301 19
jmp open_object_transform
label open_object_skip_268
localget r0 3300
cmp r0 116
jne open_object_skip_270
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 1
localset 3315 0
meshvertex 1900 -79 52 223
localset 3400 0
meshtexuv 1900 -3 9
meshvertex 1901 -83 55 216
localset 3401 0
meshtexuv 1901 -3 9
meshvertex 1902 -83 65 210
localset 3402 0
meshtexuv 1902 -3 8
meshvertex 1903 -80 63 217
localset 3403 0
meshtexuv 1903 -3 9
meshvertex 1904 -92 45 -95
localset 3404 0
meshtexuv 1904 -4 -4
meshvertex 1905 -94 66 -90
localset 3405 0
meshtexuv 1905 -4 -4
meshvertex 1906 -88 70 -49
localset 3406 0
meshtexuv 1906 -4 -2
meshvertex 1907 -91 48 -59
localset 3407 0
meshtexuv 1907 -4 -2
meshvertex 1908 -88 70 -67
localset 3408 0
meshtexuv 1908 -4 -3
meshvertex 1909 -88 73 -67
localset 3409 0
meshtexuv 1909 -4 -3
meshvertex 1910 -88 73 -46
localset 3410 0
meshtexuv 1910 -4 -2
meshvertex 1911 -88 70 -46
localset 3411 0
meshtexuv 1911 -4 -2
meshvertex 1912 -88 43 -88
localset 3412 0
meshtexuv 1912 -4 -4
meshvertex 1913 -89 43 -86
localset 3413 0
meshtexuv 1913 -4 -3
meshvertex 1914 -88 77 -86
localset 3414 0
meshtexuv 1914 -4 -3
meshvertex 1915 -87 77 -88
localset 3415 0
meshtexuv 1915 -3 -4
meshvertex 1916 -87 43 78
localset 3416 0
meshtexuv 1916 -3 3
meshvertex 1917 -88 43 80
localset 3417 0
meshtexuv 1917 -4 3
meshvertex 1918 -90 73 80
localset 3418 0
meshtexuv 1918 -4 3
meshvertex 1919 -89 73 78
localset 3419 0
meshtexuv 1919 -4 3
meshvertex 1920 79 52 223
localset 3420 0
meshtexuv 1920 3 9
meshvertex 1921 83 55 216
localset 3421 0
meshtexuv 1921 3 9
meshvertex 1922 83 65 210
localset 3422 0
meshtexuv 1922 3 8
meshvertex 1923 80 63 217
localset 3423 0
meshtexuv 1923 3 9
meshvertex 1924 92 45 -95
localset 3424 0
meshtexuv 1924 4 -4
meshvertex 1925 94 66 -90
localset 3425 0
meshtexuv 1925 4 -4
meshvertex 1926 88 70 -49
localset 3426 0
meshtexuv 1926 4 -2
meshvertex 1927 91 48 -59
localset 3427 0
meshtexuv 1927 4 -2
meshvertex 1928 88 70 -67
localset 3428 0
meshtexuv 1928 4 -3
meshvertex 1929 88 73 -67
localset 3429 0
meshtexuv 1929 4 -3
meshvertex 1930 88 73 -46
localset 3430 0
meshtexuv 1930 4 -2
meshvertex 1931 88 70 -46
localset 3431 0
meshtexuv 1931 4 -2
meshvertex 1932 88 43 -88
localset 3432 0
meshtexuv 1932 4 -4
meshvertex 1933 89 43 -86
localset 3433 0
meshtexuv 1933 4 -3
meshvertex 1934 88 77 -86
localset 3434 0
meshtexuv 1934 4 -3
meshvertex 1935 87 77 -88
localset 3435 0
meshtexuv 1935 3 -4
meshvertex 1936 87 43 78
localset 3436 0
meshtexuv 1936 3 3
meshvertex 1937 88 43 80
localset 3437 0
meshtexuv 1937 4 3
meshvertex 1938 90 73 80
localset 3438 0
meshtexuv 1938 4 3
meshvertex 1939 89 73 78
localset 3439 0
meshtexuv 1939 4 3
localset 3301 40
jmp open_object_transform
label open_object_skip_270
localget r0 3300
cmp r0 117
jne open_object_skip_272
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 1
localset 3315 0
meshvertex 1900 -49 75 110
localset 3400 0
meshtexuv 1900 -2 4
meshvertex 1901 -50 75 112
localset 3401 0
meshtexuv 1901 -2 4
meshvertex 1902 -61 66 184
localset 3402 0
meshtexuv 1902 -2 7
meshvertex 1903 -60 66 184
localset 3403 0
meshtexuv 1903 -2 7
meshvertex 1904 49 75 110
localset 3404 0
meshtexuv 1904 2 4
meshvertex 1905 50 75 112
localset 3405 0
meshtexuv 1905 2 4
meshvertex 1906 61 66 184
localset 3406 0
meshtexuv 1906 2 7
meshvertex 1907 60 66 184
localset 3407 0
meshtexuv 1907 2 7
localset 3301 8
jmp open_object_transform
label open_object_skip_272
localget r0 3300
cmp r0 118
jne open_object_skip_274
localset 3310 0
localset 3311 150
localset 3312 0
localset 3314 1
localset 3315 0
meshvertex 1900 -25 45 -229
localset 3400 0
meshtexuv 1900 -1 -9
meshvertex 1901 25 45 -229
localset 3401 0
meshtexuv 1901 1 -9
meshvertex 1902 25 58 -229
localset 3402 0
meshtexuv 1902 1 -9
meshvertex 1903 -25 58 -229
localset 3403 0
meshtexuv 1903 -1 -9
meshvertex 1904 -69 14 -230
localset 3404 0
meshtexuv 1904 -3 -9
meshvertex 1905 -67 14 -230
localset 3405 0
meshtexuv 1905 -3 -9
meshvertex 1906 -67 31 -212
localset 3406 0
meshtexuv 1906 -3 -8
meshvertex 1907 -69 31 -212
localset 3407 0
meshtexuv 1907 -3 -8
meshvertex 1908 -35 14 -230
localset 3408 0
meshtexuv 1908 -1 -9
meshvertex 1909 -33 14 -230
localset 3409 0
meshtexuv 1909 -1 -9
meshvertex 1910 -33 31 -212
localset 3410 0
meshtexuv 1910 -1 -8
meshvertex 1911 -35 31 -212
localset 3411 0
meshtexuv 1911 -1 -8
meshvertex 1912 -1 14 -230
localset 3412 0
meshtexuv 1912 0 -9
meshvertex 1913 1 14 -230
localset 3413 0
meshtexuv 1913 0 -9
meshvertex 1914 1 31 -212
localset 3414 0
meshtexuv 1914 0 -8
meshvertex 1915 -1 31 -212
localset 3415 0
meshtexuv 1915 0 -8
meshvertex 1916 33 14 -230
localset 3416 0
meshtexuv 1916 1 -9
meshvertex 1917 35 14 -230
localset 3417 0
meshtexuv 1917 1 -9
meshvertex 1918 35 31 -212
localset 3418 0
meshtexuv 1918 1 -8
meshvertex 1919 33 31 -212
localset 3419 0
meshtexuv 1919 1 -8
meshvertex 1920 67 14 -230
localset 3420 0
meshtexuv 1920 3 -9
meshvertex 1921 69 14 -230
localset 3421 0
meshtexuv 1921 3 -9
meshvertex 1922 69 31 -212
localset 3422 0
meshtexuv 1922 3 -8
meshvertex 1923 67 31 -212
localset 3423 0
meshtexuv 1923 3 -8
localset 3301 24
jmp open_object_transform
label open_object_skip_274
jmp open_objects_done
label open_object_draw
localget r9 18
mov r10 r9
div r10 2
mov r11 r10
mul r11 9
div r11 16
mul r9 85
div r9 100
localget r0 3300
cmp r0 0
je open_draw_shared_277
cmp r0 34
je open_draw_shared_277
cmp r0 35
je open_draw_shared_277
cmp r0 36
je open_draw_shared_277
cmp r0 37
je open_draw_shared_277
cmp r0 38
je open_draw_shared_277
cmp r0 39
je open_draw_shared_277
cmp r0 73
je open_draw_shared_277
cmp r0 75
je open_draw_shared_277
jmp open_draw_skip_276
label open_draw_shared_277
meshfacegradienttex 2000 2001 2002 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2000 2002 2003 9 3 7 2 r9 r10 r11 60
jmp open_object_next
label open_draw_skip_276
localget r0 3300
cmp r0 1
je open_draw_shared_279
cmp r0 2
je open_draw_shared_279
cmp r0 4
je open_draw_shared_279
cmp r0 6
je open_draw_shared_279
cmp r0 8
je open_draw_shared_279
cmp r0 10
je open_draw_shared_279
cmp r0 12
je open_draw_shared_279
cmp r0 14
je open_draw_shared_279
cmp r0 16
je open_draw_shared_279
cmp r0 18
je open_draw_shared_279
cmp r0 20
je open_draw_shared_279
cmp r0 22
je open_draw_shared_279
cmp r0 24
je open_draw_shared_279
cmp r0 26
je open_draw_shared_279
cmp r0 28
je open_draw_shared_279
cmp r0 74
je open_draw_shared_279
cmp r0 76
je open_draw_shared_279
cmp r0 77
je open_draw_shared_279
cmp r0 79
je open_draw_shared_279
cmp r0 81
je open_draw_shared_279
cmp r0 83
je open_draw_shared_279
cmp r0 85
je open_draw_shared_279
cmp r0 87
je open_draw_shared_279
cmp r0 89
je open_draw_shared_279
cmp r0 91
je open_draw_shared_279
cmp r0 93
je open_draw_shared_279
cmp r0 95
je open_draw_shared_279
cmp r0 97
je open_draw_shared_279
cmp r0 99
je open_draw_shared_279
cmp r0 101
je open_draw_shared_279
cmp r0 103
je open_draw_shared_279
jmp open_draw_skip_278
label open_draw_shared_279
meshfacegradienttex 2000 2001 2002 32 8 0 1 r9 r10 r11 60
meshfacegradienttex 2000 2002 2003 32 8 0 1 r9 r10 r11 60
jmp open_object_next
label open_draw_skip_278
localget r0 3300
cmp r0 3
je open_draw_shared_281
cmp r0 5
je open_draw_shared_281
cmp r0 7
je open_draw_shared_281
cmp r0 9
je open_draw_shared_281
cmp r0 11
je open_draw_shared_281
cmp r0 13
je open_draw_shared_281
cmp r0 15
je open_draw_shared_281
cmp r0 17
je open_draw_shared_281
cmp r0 19
je open_draw_shared_281
cmp r0 21
je open_draw_shared_281
cmp r0 23
je open_draw_shared_281
cmp r0 25
je open_draw_shared_281
cmp r0 27
je open_draw_shared_281
cmp r0 29
je open_draw_shared_281
jmp open_draw_skip_280
label open_draw_shared_281
meshfacegradienttex 2000 2001 2002 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2000 2002 2003 9 3 7 2 r9 r10 r11 60
jmp open_object_next
label open_draw_skip_280
localget r0 3300
cmp r0 30
je open_draw_shared_283
cmp r0 31
je open_draw_shared_283
cmp r0 32
je open_draw_shared_283
jmp open_draw_skip_282
label open_draw_shared_283
meshface 2000 2001 2002 14 r9 r10 r11 60
meshface 2003 2004 2005 14 r9 r10 r11 60
meshface 2006 2007 2008 14 r9 r10 r11 60
jmp open_object_next
label open_draw_skip_282
localget r0 3300
cmp r0 33
je open_draw_shared_285
jmp open_draw_skip_284
label open_draw_shared_285
meshfacegradienttex 2000 2001 2002 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2000 2002 2003 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2004 2005 2006 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2004 2006 2007 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2000 2004 2007 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2000 2007 2001 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2003 2002 2006 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2003 2006 2005 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2000 2003 2005 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2000 2005 2004 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2001 2007 2006 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2001 2006 2002 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2008 2009 2010 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2008 2010 2011 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2012 2013 2014 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2012 2014 2015 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2008 2012 2015 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2008 2015 2009 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2011 2010 2014 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2011 2014 2013 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2008 2011 2013 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2008 2013 2012 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2009 2015 2014 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 2009 2014 2010 9 3 7 2 r9 r10 r11 60
jmp open_object_next
label open_draw_skip_284
localget r0 3300
cmp r0 40
je open_draw_shared_287
cmp r0 41
je open_draw_shared_287
cmp r0 42
je open_draw_shared_287
jmp open_draw_skip_286
label open_draw_shared_287
meshface 2000 2001 2002 10 r9 r10 r11 60
meshface 2000 2002 2003 10 r9 r10 r11 60
meshface 2004 2005 2006 10 r9 r10 r11 60
meshface 2004 2006 2007 10 r9 r10 r11 60
meshface 2000 2004 2007 10 r9 r10 r11 60
meshface 2000 2007 2001 10 r9 r10 r11 60
meshface 2003 2002 2006 10 r9 r10 r11 60
meshface 2003 2006 2005 10 r9 r10 r11 60
meshface 2000 2003 2005 10 r9 r10 r11 60
meshface 2000 2005 2004 10 r9 r10 r11 60
meshface 2001 2007 2006 10 r9 r10 r11 60
meshface 2001 2006 2002 10 r9 r10 r11 60
meshface 2008 2009 2010 11 r9 r10 r11 60
meshface 2008 2010 2011 11 r9 r10 r11 60
meshface 2012 2013 2014 11 r9 r10 r11 60
meshface 2012 2014 2015 11 r9 r10 r11 60
meshface 2008 2012 2015 11 r9 r10 r11 60
meshface 2008 2015 2009 11 r9 r10 r11 60
meshface 2011 2010 2014 11 r9 r10 r11 60
meshface 2011 2014 2013 11 r9 r10 r11 60
meshface 2008 2011 2013 11 r9 r10 r11 60
meshface 2008 2013 2012 11 r9 r10 r11 60
meshface 2009 2015 2014 11 r9 r10 r11 60
meshface 2009 2014 2010 11 r9 r10 r11 60
meshface 2016 2017 2018 9 r9 r10 r11 60
meshface 2016 2018 2019 9 r9 r10 r11 60
meshface 2020 2021 2022 9 r9 r10 r11 60
meshface 2020 2022 2023 9 r9 r10 r11 60
meshface 2024 2025 2026 9 r9 r10 r11 60
meshface 2024 2026 2027 9 r9 r10 r11 60
meshface 2028 2029 2030 9 r9 r10 r11 60
meshface 2028 2030 2031 9 r9 r10 r11 60
meshface 2032 2033 2034 11 r9 r10 r11 60
meshface 2035 2036 2037 11 r9 r10 r11 60
meshface 2038 2039 2040 24 r9 r10 r11 60
meshface 2038 2040 2041 24 r9 r10 r11 60
jmp open_object_next
label open_draw_skip_286
localget r0 3300
cmp r0 43
je open_draw_shared_289
cmp r0 44
je open_draw_shared_289
cmp r0 45
je open_draw_shared_289
cmp r0 46
je open_draw_shared_289
jmp open_draw_skip_288
label open_draw_shared_289
meshface 2000 2001 2002 226 r9 r10 r11 60
meshface 2000 2002 2003 226 r9 r10 r11 60
jmp open_object_next
label open_draw_skip_288
localget r0 3300
cmp r0 47
je open_draw_shared_291
cmp r0 48
je open_draw_shared_291
cmp r0 49
je open_draw_shared_291
jmp open_draw_skip_290
label open_draw_shared_291
meshface 2000 2001 2002 22 r9 r10 r11 60
meshface 2003 2004 2005 22 r9 r10 r11 60
jmp open_object_next
label open_draw_skip_290
localget r0 3300
cmp r0 50
je open_draw_shared_293
cmp r0 51
je open_draw_shared_293
cmp r0 52
je open_draw_shared_293
jmp open_draw_skip_292
label open_draw_shared_293
meshface 2000 2001 2002 243 r9 r10 r11 60
meshface 2000 2002 2003 243 r9 r10 r11 60
jmp open_object_next
label open_draw_skip_292
localget r0 3300
cmp r0 53
je open_draw_shared_295
cmp r0 54
je open_draw_shared_295
cmp r0 55
je open_draw_shared_295
cmp r0 56
je open_draw_shared_295
cmp r0 57
je open_draw_shared_295
cmp r0 58
je open_draw_shared_295
cmp r0 59
je open_draw_shared_295
cmp r0 60
je open_draw_shared_295
cmp r0 61
je open_draw_shared_295
cmp r0 62
je open_draw_shared_295
cmp r0 63
je open_draw_shared_295
cmp r0 64
je open_draw_shared_295
cmp r0 65
je open_draw_shared_295
cmp r0 66
je open_draw_shared_295
cmp r0 67
je open_draw_shared_295
cmp r0 68
je open_draw_shared_295
cmp r0 69
je open_draw_shared_295
cmp r0 70
je open_draw_shared_295
cmp r0 71
je open_draw_shared_295
cmp r0 72
je open_draw_shared_295
jmp open_draw_skip_294
label open_draw_shared_295
meshfacegradienttex 2000 2001 2002 32 8 0 1 r9 r10 r11 60
meshfacegradienttex 2000 2002 2003 32 8 0 1 r9 r10 r11 60
meshfacegradienttex 2000 2003 2004 32 8 0 1 r9 r10 r11 60
meshfacegradienttex 2000 2004 2005 32 8 0 1 r9 r10 r11 60
meshfacegradienttex 2000 2005 2006 32 8 0 1 r9 r10 r11 60
meshfacegradienttex 2000 2006 2007 32 8 0 1 r9 r10 r11 60
meshfacegradienttex 2000 2007 2008 32 8 0 1 r9 r10 r11 60
meshfacegradienttex 2000 2008 2001 32 8 0 1 r9 r10 r11 60
jmp open_object_next
label open_draw_skip_294
localget r0 3300
cmp r0 78
je open_draw_shared_297
cmp r0 80
je open_draw_shared_297
cmp r0 82
je open_draw_shared_297
cmp r0 84
je open_draw_shared_297
cmp r0 86
je open_draw_shared_297
cmp r0 88
je open_draw_shared_297
cmp r0 90
je open_draw_shared_297
cmp r0 92
je open_draw_shared_297
cmp r0 94
je open_draw_shared_297
cmp r0 96
je open_draw_shared_297
cmp r0 98
je open_draw_shared_297
cmp r0 100
je open_draw_shared_297
cmp r0 102
je open_draw_shared_297
cmp r0 104
je open_draw_shared_297
jmp open_draw_skip_296
label open_draw_shared_297
meshface 2000 2001 2002 14 r9 r10 r11 60
meshface 2003 2004 2005 15 r9 r10 r11 60
meshface 2006 2007 2008 16 r9 r10 r11 60
meshface 2009 2010 2011 14 r9 r10 r11 60
jmp open_object_next
label open_draw_skip_296
localget r0 3300
cmp r0 105
je open_draw_shared_299
cmp r0 106
je open_draw_shared_299
cmp r0 107
je open_draw_shared_299
cmp r0 108
je open_draw_shared_299
cmp r0 109
je open_draw_shared_299
cmp r0 110
je open_draw_shared_299
jmp open_draw_skip_298
label open_draw_shared_299
meshface 2000 2001 2002 10 r9 r10 r11 60
meshface 2000 2002 2003 10 r9 r10 r11 60
meshface 2004 2005 2006 10 r9 r10 r11 60
meshface 2004 2006 2007 10 r9 r10 r11 60
meshface 2000 2004 2007 10 r9 r10 r11 60
meshface 2000 2007 2001 10 r9 r10 r11 60
meshface 2003 2002 2006 10 r9 r10 r11 60
meshface 2003 2006 2005 10 r9 r10 r11 60
meshface 2000 2003 2005 10 r9 r10 r11 60
meshface 2000 2005 2004 10 r9 r10 r11 60
meshface 2001 2007 2006 10 r9 r10 r11 60
meshface 2001 2006 2002 10 r9 r10 r11 60
meshface 2008 2009 2010 11 r9 r10 r11 60
meshface 2008 2010 2011 11 r9 r10 r11 60
meshface 2012 2013 2014 11 r9 r10 r11 60
meshface 2012 2014 2015 11 r9 r10 r11 60
meshface 2008 2012 2015 11 r9 r10 r11 60
meshface 2008 2015 2009 11 r9 r10 r11 60
meshface 2011 2010 2014 11 r9 r10 r11 60
meshface 2011 2014 2013 11 r9 r10 r11 60
meshface 2008 2011 2013 11 r9 r10 r11 60
meshface 2008 2013 2012 11 r9 r10 r11 60
meshface 2009 2015 2014 11 r9 r10 r11 60
meshface 2009 2014 2010 11 r9 r10 r11 60
meshface 2016 2017 2018 10 r9 r10 r11 60
meshface 2016 2018 2019 10 r9 r10 r11 60
meshface 2020 2021 2022 10 r9 r10 r11 60
meshface 2020 2022 2023 10 r9 r10 r11 60
meshface 2016 2020 2023 10 r9 r10 r11 60
meshface 2016 2023 2017 10 r9 r10 r11 60
meshface 2019 2018 2022 10 r9 r10 r11 60
meshface 2019 2022 2021 10 r9 r10 r11 60
meshface 2016 2019 2021 10 r9 r10 r11 60
meshface 2016 2021 2020 10 r9 r10 r11 60
meshface 2017 2023 2022 10 r9 r10 r11 60
meshface 2017 2022 2018 10 r9 r10 r11 60
meshface 2024 2025 2026 11 r9 r10 r11 60
meshface 2024 2026 2027 11 r9 r10 r11 60
meshface 2028 2029 2030 11 r9 r10 r11 60
meshface 2028 2030 2031 11 r9 r10 r11 60
meshface 2024 2028 2031 11 r9 r10 r11 60
meshface 2024 2031 2025 11 r9 r10 r11 60
meshface 2027 2026 2030 11 r9 r10 r11 60
meshface 2027 2030 2029 11 r9 r10 r11 60
meshface 2024 2027 2029 11 r9 r10 r11 60
meshface 2024 2029 2028 11 r9 r10 r11 60
meshface 2025 2031 2030 11 r9 r10 r11 60
meshface 2025 2030 2026 11 r9 r10 r11 60
meshface 2032 2033 2034 9 r9 r10 r11 60
meshface 2035 2036 2037 9 r9 r10 r11 60
meshface 2038 2039 2040 9 r9 r10 r11 60
meshface 2041 2042 2043 226 r9 r10 r11 60
meshface 2044 2045 2046 9 r9 r10 r11 60
meshface 2047 2048 2049 9 r9 r10 r11 60
meshface 2050 2051 2052 9 r9 r10 r11 60
meshface 2053 2054 2055 226 r9 r10 r11 60
jmp open_object_next
label open_draw_skip_298
localget r0 3300
cmp r0 111
je open_draw_shared_301
jmp open_draw_skip_300
label open_draw_shared_301
meshfacegradient 2000 2001 2002 228 12 r9 r10 r11 60
meshfacegradient 2000 2002 2003 228 12 r9 r10 r11 60
meshfacegradient 2004 2005 2006 228 12 r9 r10 r11 60
meshfacegradient 2004 2006 2007 228 12 r9 r10 r11 60
meshfacegradient 2000 2004 2007 228 12 r9 r10 r11 60
meshfacegradient 2000 2007 2001 228 12 r9 r10 r11 60
meshfacegradient 2003 2002 2006 228 12 r9 r10 r11 60
meshfacegradient 2003 2006 2005 228 12 r9 r10 r11 60
meshfacegradient 2000 2003 2005 228 12 r9 r10 r11 60
meshfacegradient 2000 2005 2004 228 12 r9 r10 r11 60
meshfacegradient 2001 2007 2006 228 12 r9 r10 r11 60
meshfacegradient 2001 2006 2002 228 12 r9 r10 r11 60
meshface 2008 2009 2010 241 r9 r10 r11 60
meshface 2008 2010 2011 241 r9 r10 r11 60
meshface 2012 2013 2014 241 r9 r10 r11 60
meshface 2012 2014 2015 241 r9 r10 r11 60
meshface 2008 2012 2015 241 r9 r10 r11 60
meshface 2008 2015 2009 241 r9 r10 r11 60
meshface 2011 2010 2014 241 r9 r10 r11 60
meshface 2011 2014 2013 241 r9 r10 r11 60
meshface 2008 2011 2013 241 r9 r10 r11 60
meshface 2008 2013 2012 241 r9 r10 r11 60
meshface 2009 2015 2014 241 r9 r10 r11 60
meshface 2009 2014 2010 241 r9 r10 r11 60
load8 r0 202
mul r0 24
add r0 64
meshfacegradient 2016 2017 2018 r0 24 r9 r10 r11 60
load8 r0 202
mul r0 24
add r0 64
meshfacegradient 2016 2018 2019 r0 24 r9 r10 r11 60
meshface 2020 2021 2022 241 r9 r10 r11 60
meshface 2020 2022 2023 241 r9 r10 r11 60
meshface 2024 2025 2026 241 r9 r10 r11 60
meshface 2024 2026 2027 241 r9 r10 r11 60
meshface 2020 2024 2027 241 r9 r10 r11 60
meshface 2020 2027 2021 241 r9 r10 r11 60
meshface 2023 2022 2026 241 r9 r10 r11 60
meshface 2023 2026 2025 241 r9 r10 r11 60
meshface 2020 2023 2025 241 r9 r10 r11 60
meshface 2020 2025 2024 241 r9 r10 r11 60
meshface 2021 2027 2026 241 r9 r10 r11 60
meshface 2021 2026 2022 241 r9 r10 r11 60
load8 r0 202
mul r0 24
add r0 64
meshfacegradient 2028 2029 2030 r0 24 r9 r10 r11 60
load8 r0 202
mul r0 24
add r0 64
meshfacegradient 2028 2030 2031 r0 24 r9 r10 r11 60
load8 r0 202
mul r0 24
add r0 64
meshfacegradient 2032 2033 2034 r0 24 r9 r10 r11 60
load8 r0 202
mul r0 24
add r0 64
meshfacegradient 2032 2034 2035 r0 24 r9 r10 r11 60
jmp open_object_next
label open_draw_skip_300
localget r0 3300
cmp r0 112
je open_draw_shared_303
cmp r0 113
je open_draw_shared_303
cmp r0 114
je open_draw_shared_303
cmp r0 115
je open_draw_shared_303
jmp open_draw_skip_302
label open_draw_shared_303
meshface 2000 2001 2002 241 r9 r10 r11 60
meshface 2000 2002 2003 241 r9 r10 r11 60
meshfacegradient 2004 2005 2001 228 12 r9 r10 r11 60
meshfacegradient 2004 2001 2000 228 12 r9 r10 r11 60
meshface 2006 2003 2002 226 r9 r10 r11 60
meshface 2001 2007 2008 241 r9 r10 r11 60
meshface 2001 2008 2002 241 r9 r10 r11 60
meshfacegradient 2005 2009 2007 228 12 r9 r10 r11 60
meshfacegradient 2005 2007 2001 228 12 r9 r10 r11 60
meshface 2006 2002 2008 226 r9 r10 r11 60
meshface 2007 2010 2011 241 r9 r10 r11 60
meshface 2007 2011 2008 241 r9 r10 r11 60
meshfacegradient 2009 2012 2010 228 12 r9 r10 r11 60
meshfacegradient 2009 2010 2007 228 12 r9 r10 r11 60
meshface 2006 2008 2011 226 r9 r10 r11 60
meshface 2010 2013 2014 241 r9 r10 r11 60
meshface 2010 2014 2011 241 r9 r10 r11 60
meshfacegradient 2012 2015 2013 228 12 r9 r10 r11 60
meshfacegradient 2012 2013 2010 228 12 r9 r10 r11 60
meshface 2006 2011 2014 226 r9 r10 r11 60
meshface 2013 2016 2017 241 r9 r10 r11 60
meshface 2013 2017 2014 241 r9 r10 r11 60
meshfacegradient 2015 2018 2016 228 12 r9 r10 r11 60
meshfacegradient 2015 2016 2013 228 12 r9 r10 r11 60
meshface 2006 2014 2017 226 r9 r10 r11 60
meshface 2016 2000 2003 241 r9 r10 r11 60
meshface 2016 2003 2017 241 r9 r10 r11 60
meshfacegradient 2018 2004 2000 228 12 r9 r10 r11 60
meshfacegradient 2018 2000 2016 228 12 r9 r10 r11 60
meshface 2006 2017 2003 226 r9 r10 r11 60
jmp open_object_next
label open_draw_skip_302
localget r0 3300
cmp r0 116
je open_draw_shared_305
jmp open_draw_skip_304
label open_draw_shared_305
meshface 2000 2001 2002 225 r9 r10 r11 60
meshface 2000 2002 2003 225 r9 r10 r11 60
meshface 2004 2005 2006 226 r9 r10 r11 60
meshface 2004 2006 2007 226 r9 r10 r11 60
meshface 2008 2009 2010 241 r9 r10 r11 60
meshface 2008 2010 2011 241 r9 r10 r11 60
meshface 2012 2013 2014 240 r9 r10 r11 60
meshface 2012 2014 2015 240 r9 r10 r11 60
meshface 2016 2017 2018 240 r9 r10 r11 60
meshface 2016 2018 2019 240 r9 r10 r11 60
meshface 2020 2021 2022 225 r9 r10 r11 60
meshface 2020 2022 2023 225 r9 r10 r11 60
meshface 2024 2025 2026 226 r9 r10 r11 60
meshface 2024 2026 2027 226 r9 r10 r11 60
meshface 2028 2029 2030 241 r9 r10 r11 60
meshface 2028 2030 2031 241 r9 r10 r11 60
meshface 2032 2033 2034 240 r9 r10 r11 60
meshface 2032 2034 2035 240 r9 r10 r11 60
meshface 2036 2037 2038 240 r9 r10 r11 60
meshface 2036 2038 2039 240 r9 r10 r11 60
jmp open_object_next
label open_draw_skip_304
localget r0 3300
cmp r0 117
je open_draw_shared_307
jmp open_draw_skip_306
label open_draw_shared_307
meshface 2000 2001 2002 240 r9 r10 r11 60
meshface 2000 2002 2003 240 r9 r10 r11 60
meshface 2004 2005 2006 240 r9 r10 r11 60
meshface 2004 2006 2007 240 r9 r10 r11 60
jmp open_object_next
label open_draw_skip_306
localget r0 3300
cmp r0 118
je open_draw_shared_309
jmp open_draw_skip_308
label open_draw_shared_309
meshface 2000 2001 2002 241 r9 r10 r11 60
meshface 2000 2002 2003 241 r9 r10 r11 60
meshfacegradient 2004 2005 2006 228 12 r9 r10 r11 60
meshfacegradient 2004 2006 2007 228 12 r9 r10 r11 60
meshfacegradient 2008 2009 2010 228 12 r9 r10 r11 60
meshfacegradient 2008 2010 2011 228 12 r9 r10 r11 60
meshfacegradient 2012 2013 2014 228 12 r9 r10 r11 60
meshfacegradient 2012 2014 2015 228 12 r9 r10 r11 60
meshfacegradient 2016 2017 2018 228 12 r9 r10 r11 60
meshfacegradient 2016 2018 2019 228 12 r9 r10 r11 60
meshfacegradient 2020 2021 2022 228 12 r9 r10 r11 60
meshfacegradient 2020 2022 2023 228 12 r9 r10 r11 60
jmp open_object_next
label open_draw_skip_308
label open_object_next
localget r0 3300
add r0 1
localset 3300 r0
jmp open_object_dispatch
label open_objects_done
load8 r0 526
cmp r0 0
je open_headlights_done
load16 r0 108
mov r3 r0
add r3 0
mod r3 4096
cmp r3 0
jge sin_negative_310
add r3 4096
label sin_negative_310
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
jlt sin_done_311
mul r5 -1
label sin_done_311
mov r3 r5
mov r6 r3
mov r9 r6
add r9 32768
localset 58 r9
mov r4 r0
add r4 1024
mod r4 4096
cmp r4 0
jge sin_negative_312
add r4 4096
label sin_negative_312
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
jlt sin_done_313
mul r5 -1
label sin_done_313
mov r4 r5
localget r3 58
sub r3 32768
localset 3323 r3
localset 3324 r4
localget r0 3324
mul r0 -65
localget r2 3323
mul r2 190
add r0 r2
div r0 16384
load32 r1 100
sub r1 2000000
add r0 r1
localget r2 3324
mul r2 190
localget r1 3323
mul r1 -65
sub r2 r1
div r2 16384
load32 r1 104
sub r1 2000000
add r2 r1
load16 r1 520
add r1 4
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
meshvertex 2000 r0 r1 r2
meshshade 2000 225
localget r0 3324
mul r0 65
localget r2 3323
mul r2 190
add r0 r2
div r0 16384
load32 r1 100
sub r1 2000000
add r0 r1
localget r2 3324
mul r2 190
localget r1 3323
mul r1 65
sub r2 r1
div r2 16384
load32 r1 104
sub r1 2000000
add r2 r1
load16 r1 520
add r1 4
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
meshvertex 2001 r0 r1 r2
meshshade 2001 225
localget r0 3324
mul r0 360
localget r2 3323
mul r2 1700
add r0 r2
div r0 16384
load32 r1 100
sub r1 2000000
add r0 r1
localget r2 3324
mul r2 1700
localget r1 3323
mul r1 360
sub r2 r1
div r2 16384
load32 r1 104
sub r1 2000000
add r2 r1
load16 r1 520
add r1 4
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
meshvertex 2002 r0 r1 r2
meshshade 2002 0
localget r0 3324
mul r0 -360
localget r2 3323
mul r2 1700
add r0 r2
div r0 16384
load32 r1 100
sub r1 2000000
add r0 r1
localget r2 3324
mul r2 1700
localget r1 3323
mul r1 -360
sub r2 r1
div r2 16384
load32 r1 104
sub r1 2000000
add r2 r1
load16 r1 520
add r1 4
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
meshvertex 2003 r0 r1 r2
meshshade 2003 0
localget r9 18
mov r10 r9
div r10 2
mov r11 r10
mul r11 9
div r11 16
mul r9 85
div r9 100
meshfacegradient 2000 2001 2002 40 16 r9 r10 r11 60
meshfacegradient 2000 2002 2003 40 16 r9 r10 r11 60
label open_headlights_done
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
meshvertex 1511 -91 24 -142
meshtexuv 1511 -13 -20
meshvertex 1512 -91 -75 -142
meshtexuv 1512 -13 -20
meshvertex 1513 -105 -40 -142
meshtexuv 1513 -15 -20
meshvertex 1514 -77 -40 -142
meshtexuv 1514 -11 -20
meshvertex 1515 -91 -40 -125
meshtexuv 1515 -13 -18
meshvertex 1516 -91 -40 -159
meshtexuv 1516 -13 -23
meshvertex 1517 -91 24 138
meshtexuv 1517 -13 20
meshvertex 1518 -91 -75 138
meshtexuv 1518 -13 20
meshvertex 1519 -105 -40 138
meshtexuv 1519 -15 20
meshvertex 1520 -77 -40 138
meshtexuv 1520 -11 20
meshvertex 1521 -91 -40 155
meshtexuv 1521 -13 22
meshvertex 1522 -91 -40 121
meshtexuv 1522 -13 17
meshvertex 1523 91 24 -142
meshtexuv 1523 13 -20
meshvertex 1524 91 -75 -142
meshtexuv 1524 13 -20
meshvertex 1525 77 -40 -142
meshtexuv 1525 11 -20
meshvertex 1526 105 -40 -142
meshtexuv 1526 15 -20
meshvertex 1527 91 -40 -125
meshtexuv 1527 13 -18
meshvertex 1528 91 -40 -159
meshtexuv 1528 13 -23
meshvertex 1529 91 24 138
meshtexuv 1529 13 20
meshvertex 1530 91 -75 138
meshtexuv 1530 13 20
meshvertex 1531 77 -40 138
meshtexuv 1531 11 20
meshvertex 1532 105 -40 138
meshtexuv 1532 15 20
meshvertex 1533 91 -40 155
meshtexuv 1533 13 22
meshvertex 1534 91 -40 121
meshtexuv 1534 13 17
meshvertex 1535 12 4 12
meshtexuv 1535 2 2
meshvertex 1536 123 3 12
meshtexuv 1536 18 2
meshvertex 1537 90 3 181
meshtexuv 1537 13 26
meshvertex 1538 12 3 251
meshtexuv 1538 2 36
meshvertex 1539 -66 3 181
meshtexuv 1539 -9 26
meshvertex 1540 -99 3 12
meshtexuv 1540 -14 2
meshvertex 1541 -66 3 -157
meshtexuv 1541 -9 -22
meshvertex 1542 12 3 -227
meshtexuv 1542 2 -32
meshvertex 1543 90 3 -157
meshtexuv 1543 13 -22
meshvertex 1544 155 2 12
meshtexuv 1544 22 2
meshvertex 1545 113 2 201
meshtexuv 1545 16 29
meshvertex 1546 12 2 279
meshtexuv 1546 2 40
meshvertex 1547 -89 2 201
meshtexuv 1547 -13 29
meshvertex 1548 -131 2 12
meshtexuv 1548 -19 2
meshvertex 1549 -89 2 -177
meshtexuv 1549 -13 -25
meshvertex 1550 12 2 -255
meshtexuv 1550 2 -36
meshvertex 1551 113 2 -177
meshtexuv 1551 16 -25
meshvertex 1552 14 1150 -16
meshtexuv 1552 2 -2
meshvertex 1553 246 315 33
meshtexuv 1553 35 5
meshvertex 1554 100 364 209
meshtexuv 1554 14 30
meshvertex 1555 -161 288 205
meshtexuv 1555 -23 29
meshvertex 1556 -258 330 -61
meshtexuv 1556 -37 -9
meshvertex 1557 -101 292 -217
meshtexuv 1557 -14 -31
meshvertex 1558 -18 0 0
meshtexuv 1558 -3 0
meshvertex 1559 18 0 0
meshtexuv 1559 3 0
meshvertex 1560 18 390 0
meshtexuv 1560 3 0
meshvertex 1561 -18 390 0
meshtexuv 1561 -3 0
meshvertex 1562 0 0 -18
meshtexuv 1562 0 -3
meshvertex 1563 0 0 18
meshtexuv 1563 0 3
meshvertex 1564 0 390 18
meshtexuv 1564 0 3
meshvertex 1565 0 390 -18
meshtexuv 1565 0 -3
meshvertex 1591 -109 26 -151
meshtexuv 1591 -16 -22
meshvertex 1592 -73 27 -154
meshtexuv 1592 -10 -22
meshvertex 1593 -62 88 -212
meshtexuv 1593 -9 -30
meshvertex 1594 -120 82 -204
meshtexuv 1594 -17 -29
meshvertex 1595 -91 25 -134
meshtexuv 1595 -13 -19
meshvertex 1596 -91 24 -168
meshtexuv 1596 -13 -24
meshvertex 1597 -91 96 -198
meshtexuv 1597 -13 -28
meshvertex 1598 -91 90 -124
meshtexuv 1598 -13 -18
meshvertex 1599 73 26 -151
meshtexuv 1599 10 -22
meshvertex 1600 109 27 -154
meshtexuv 1600 16 -22
meshvertex 1601 120 88 -212
meshtexuv 1601 17 -30
meshvertex 1602 62 82 -204
meshtexuv 1602 9 -29
meshvertex 1603 91 25 -134
meshtexuv 1603 13 -19
meshvertex 1604 91 24 -168
meshtexuv 1604 13 -24
meshvertex 1605 91 96 -198
meshtexuv 1605 13 -28
meshvertex 1606 91 90 -124
meshtexuv 1606 13 -18
meshvertex 1607 -62 26 -234
meshtexuv 1607 -9 -33
meshvertex 1608 -52 26 -234
meshtexuv 1608 -7 -33
meshvertex 1609 -43 26 -350
meshtexuv 1609 -6 -50
meshvertex 1610 -71 26 -350
meshtexuv 1610 -10 -50
meshvertex 1611 -57 21 -234
meshtexuv 1611 -8 -33
meshvertex 1612 -57 31 -234
meshtexuv 1612 -8 -33
meshvertex 1613 -57 40 -350
meshtexuv 1613 -8 -50
meshvertex 1614 -57 12 -350
meshtexuv 1614 -8 -50
meshvertex 1615 -24 26 -234
meshtexuv 1615 -3 -33
meshvertex 1616 -14 26 -234
meshtexuv 1616 -2 -33
meshvertex 1617 -5 26 -350
meshtexuv 1617 -1 -50
meshvertex 1618 -33 26 -350
meshtexuv 1618 -5 -50
meshvertex 1619 -19 21 -234
meshtexuv 1619 -3 -33
meshvertex 1620 -19 31 -234
meshtexuv 1620 -3 -33
meshvertex 1621 -19 40 -350
meshtexuv 1621 -3 -50
meshvertex 1622 -19 12 -350
meshtexuv 1622 -3 -50
meshvertex 1623 14 26 -234
meshtexuv 1623 2 -33
meshvertex 1624 24 26 -234
meshtexuv 1624 3 -33
meshvertex 1625 33 26 -350
meshtexuv 1625 5 -50
meshvertex 1626 5 26 -350
meshtexuv 1626 1 -50
meshvertex 1627 19 21 -234
meshtexuv 1627 3 -33
meshvertex 1628 19 31 -234
meshtexuv 1628 3 -33
meshvertex 1629 19 40 -350
meshtexuv 1629 3 -50
meshvertex 1630 19 12 -350
meshtexuv 1630 3 -50
meshvertex 1631 52 26 -234
meshtexuv 1631 7 -33
meshvertex 1632 62 26 -234
meshtexuv 1632 9 -33
meshvertex 1633 71 26 -350
meshtexuv 1633 10 -50
meshvertex 1634 43 26 -350
meshtexuv 1634 6 -50
meshvertex 1635 57 21 -234
meshtexuv 1635 8 -33
meshvertex 1636 57 31 -234
meshtexuv 1636 8 -33
meshvertex 1637 57 40 -350
meshtexuv 1637 8 -50
meshvertex 1638 57 12 -350
meshtexuv 1638 8 -50
meshvertex 1639 -101 3 -250
meshtexuv 1639 -14 -36
meshvertex 1640 -83 3 -250
meshtexuv 1640 -12 -36
meshvertex 1641 -83 3 -15
meshtexuv 1641 -12 -2
meshvertex 1642 -101 3 -15
meshtexuv 1642 -14 -2
meshvertex 1643 83 3 -250
meshtexuv 1643 12 -36
meshvertex 1644 101 3 -250
meshtexuv 1644 14 -36
meshvertex 1645 101 3 -15
meshtexuv 1645 14 -2
meshvertex 1646 83 3 -15
meshtexuv 1646 12 -2
meshvertex 1566 24 105 -8
meshtexuv 1566 3 -1
meshvertex 1567 -183 48 -93
meshtexuv 1567 -26 -13
meshvertex 1568 -72 85 -153
meshtexuv 1568 -10 -22
meshvertex 1569 126 64 -142
meshtexuv 1569 18 -20
meshvertex 1570 215 43 55
meshtexuv 1570 31 8
meshvertex 1571 57 77 155
meshtexuv 1571 8 22
meshvertex 1572 -162 58 132
meshtexuv 1572 -23 19
meshvertex 1573 -183 0 -93
meshtexuv 1573 -26 -13
meshvertex 1574 -72 0 -153
meshtexuv 1574 -10 -22
meshvertex 1575 126 0 -142
meshtexuv 1575 18 -20
meshvertex 1576 215 0 55
meshtexuv 1576 31 8
meshvertex 1577 57 0 155
meshtexuv 1577 8 22
meshvertex 1578 -162 0 132
meshtexuv 1578 -23 19
meshvertex 1579 -42 0 -22
meshtexuv 1579 -6 -3
meshvertex 1580 29 0 17
meshtexuv 1580 4 2
meshvertex 1581 -8 103 -17
meshtexuv 1581 -1 -2
meshvertex 1582 -13 0 -55
meshtexuv 1582 -2 -8
meshvertex 1583 24 0 63
meshtexuv 1583 3 9
meshvertex 1584 5 116 15
meshtexuv 1584 1 2
meshvertex 1585 -61 0 43
meshtexuv 1585 -9 6
meshvertex 1586 45 0 -42
meshtexuv 1586 6 -6
meshvertex 1587 23 77 9
meshtexuv 1587 3 1
meshvertex 1588 -18 63 -6
meshtexuv 1588 -3 -1
meshvertex 1589 16 63 4
meshtexuv 1589 2 1
meshvertex 1590 1 83 -2
meshtexuv 1590 0 0
localset 512 256
localset 513 2305
localset 514 4354
localset 515 4354
localset 516 8451
localset 517 10500
localset 518 10500
localset 519 14595
localset 520 16644
localset 521 18691
localset 522 20740
localset 523 22787
localset 524 24834
localset 525 26883
localset 526 28933
localset 527 30976
localset 528 33030
localset 529 2310
localset 530 37120
localset 531 28933
localset 532 41223
localset 533 43264
localset 534 2312
localset 535 47369
localset 536 49418
localset 537 51466
localset 538 4362
localset 539 10507
localset 540 57610
localset 541 10506
localset 542 16651
localset 543 63754
localset 544 20748
localset 545 67850
localset 546 20738
localset 547 71949
localset 548 28942
localset 549 76038
localset 550 47361
localset 551 71951
localset 552 82183
localset 553 47376
localset 554 86288
localset 555 88330
localset 556 90378
localset 557 92426
localset 558 94474
localset 559 96522
localset 560 98577
localset 561 98565
localset 562 71951
localset 563 104722
localset 564 106767
localset 565 108816
localset 566 110858
localset 567 112906
localset 568 114954
localset 569 117002
localset 570 119050
localset 571 121105
localset 572 123154
localset 573 98577
localset 574 127247
localset 575 129299
localset 576 131338
localset 577 133386
localset 578 135434
localset 579 137482
localset 580 139530
localset 581 141588
localset 582 143634
localset 583 145679
localset 584 147731
localset 585 149770
localset 586 151818
localset 587 153866
localset 588 155914
localset 589 157962
localset 590 160020
localset 591 162066
localset 592 164111
localset 593 166165
localset 594 168202
localset 595 170250
localset 596 172298
localset 597 174346
localset 598 176394
localset 599 178454
localset 600 180498
localset 601 182543
localset 602 184599
localset 603 186634
localset 604 188682
localset 605 190730
localset 606 192778
localset 607 194826
localset 608 196888
localset 609 198930
localset 610 200975
localset 611 203024
localset 612 205066
localset 613 207114
localset 614 209162
localset 615 211210
localset 616 213258
localset 617 215313
localset 618 217362
localset 619 219407
localset 620 221456
localset 621 223498
localset 622 225546
localset 623 227594
localset 624 229642
localset 625 231690
localset 626 233745
localset 627 235794
localset 628 237839
localset 629 239888
localset 630 241930
localset 631 243978
localset 632 246026
localset 633 248074
localset 634 250122
localset 635 252177
localset 636 254226
localset 637 256271
localset 638 258320
localset 639 260362
localset 640 262410
localset 641 264458
localset 642 266506
localset 643 268554
localset 644 270609
localset 645 272658
localset 646 274703
localset 647 276752
localset 648 278794
localset 649 280842
localset 650 282890
localset 651 284938
localset 652 286986
localset 653 289041
localset 654 291090
localset 655 293135
localset 656 295187
localset 657 297226
localset 658 299274
localset 659 301322
localset 660 303370
localset 661 305418
localset 662 307473
localset 663 309522
localset 664 311567
localset 665 313619
localset 666 315658
localset 667 317706
localset 668 319754
localset 669 321817
localset 670 323850
localset 671 325908
localset 672 327954
localset 673 329999
localset 674 332053
localset 675 334090
localset 676 336154
localset 677 338186
localset 678 340249
localset 679 342282
localset 680 344340
localset 681 346386
localset 682 348431
localset 683 350485
localset 684 352522
localset 685 354586
localset 686 356618
localset 687 358683
localset 688 360732
localset 689 362774
localset 690 364818
localset 691 366863
localset 692 368919
localset 693 370956
localset 694 373021
localset 695 375050
localset 696 377115
localset 697 379164
localset 698 381206
localset 699 383250
localset 700 385295
localset 701 387351
localset 702 389406
localset 703 391454
localset 704 393484
localset 705 395548
localset 706 397580
localset 707 399640
localset 708 401695
localset 709 403744
localset 710 405783
localset 711 407820
localset 712 409886
localset 713 411916
localset 714 413980
localset 715 416012
localset 716 418072
localset 717 420127
localset 718 422176
localset 719 424225
localset 720 426274
localset 721 428299
localset 722 430347
localset 723 432395
localset 724 434443
localset 725 436513
localset 726 438563
localset 727 440612
localset 728 442624
localset 729 444705
localset 730 446757
localset 731 448805
localset 732 450853
localset 733 452901
localset 734 455078
localset 735 457126
localset 736 459138
localset 737 461186
localset 738 463234
localset 739 465282
localset 740 467330
localset 741 469378
localset 742 471438
localset 743 473474
localset 744 475530
localset 745 477578
localset 746 479626
localset 747 481703
localset 748 483751
localset 749 485770
localset 750 487818
localset 751 489866
localset 752 491914
localset 753 493962
localset 754 496027
localset 755 498058
localset 756 500106
localset 757 502154
localset 758 504218
localset 759 506268
localset 760 508316
localset 761 510348
localset 762 512414
localset 763 514462
localset 764 516492
localset 765 518540
localset 766 520588
localset 767 522636
localset 768 524702
localset 769 526739
localset 770 528787
localset 771 530832
localset 772 532883
localset 773 534952
localset 774 536848
localset 775 526608
localset 776 530704
localset 777 528681
localset 778 516393
localset 779 532777
localset 780 549268
localset 781 551313
localset 782 553364
localset 783 555412
localset 784 557453
localset 785 559377
localset 786 551185
localset 787 549137
localset 788 553258
localset 789 555306
localset 790 524586
localset 791 571937
localset 792 573986
localset 793 576033
localset 794 578082
localset 795 580139
localset 796 573986
localset 797 584203
localset 798 586252
localset 799 580107
localset 800 590348
localset 801 592394
localset 802 594442
localset 803 596482
localset 804 598530
localset 805 600620
localset 806 596518
localset 807 604676
localset 808 606723
localset 809 600580
localset 810 610819
localset 811 612864
localset 812 614912
localset 813 617005
localset 814 619053
localset 815 621102
localset 816 617005
localset 817 625199
localset 818 627248
localset 819 621103
localset 820 631344
localset 821 633381
localset 822 635429
localset 823 637489
localset 824 639537
localset 825 641586
localset 826 637491
localset 827 645684
localset 828 647733
localset 829 641588
localset 830 651829
localset 831 576031
localset 832 655903
localset 833 657951
localset 834 573983
localset 835 662034
localset 836 574006
localset 837 580150
localset 838 580117
localset 839 670224
localset 840 580114
localset 841 586256
localset 842 676368
localset 843 592400
localset 844 680464
localset 845 596496
localset 846 684562
localset 847 596535
localset 848 600632
localset 849 600633
localset 850 692742
localset 851 600594
localset 852 606726
localset 853 698886
localset 854 612870
localset 855 702982
localset 856 616966
localset 857 707090
localset 858 617018
localset 859 621114
localset 860 621115
localset 861 715324
localset 862 621074
localset 863 627260
localset 864 721468
localset 865 633404
localset 866 725564
localset 867 637500
localset 868 729618
localset 869 637501
localset 870 641598
localset 871 641599
localset 872 737823
localset 873 641554
localset 874 647711
localset 875 658066
localset 876 662162
localset 877 748178
localset 878 750226
localset 879 751890
localset 880 753938
localset 881 755986
localset 882 676498
localset 883 760466
localset 884 762130
localset 885 684690
localset 886 766610
localset 887 768274
localset 888 699026
localset 889 772754
localset 890 774418
localset 891 707218
localset 892 778898
localset 893 780562
localset 894 721554
localset 895 785042
localset 896 786706
localset 897 729746
localset 898 791186
localset 899 792850
localset 900 795282
localset 901 797330
localset 902 799378
localset 903 801426
localset 904 803474
localset 905 805522
localset 906 807570
localset 907 809618
localset 908 811666
localset 909 813714
localset 910 815762
localset 911 817810
localset 912 819858
localset 913 821906
localset 914 823954
localset 915 826002
localset 916 828050
localset 917 830098
localset 918 832146
localset 919 834194
localset 920 836129
localset 921 838177
localset 922 840226
localset 923 842274
localset 924 840226
localset 925 846400
localset 926 848395
localset 927 846347
localset 928 852492
localset 929 854540
localset 930 856586
localset 931 858634
localset 932 860674
localset 933 862722
localset 934 860686
localset 935 866881
localset 936 868868
localset 937 866820
localset 938 872963
localset 939 875011
localset 940 877056
localset 941 879104
localset 942 881197
localset 943 883245
localset 944 881197
localset 945 887362
localset 946 889391
localset 947 887343
localset 948 893488
localset 949 895536
localset 950 897573
localset 951 899621
localset 952 901681
localset 953 903729
localset 954 901699
localset 955 907844
localset 956 909876
localset 957 907828
localset 958 913973
localset 959 916021
localset 960 838176
localset 961 920096
localset 962 922144
localset 963 840224
localset 964 926223
localset 965 840261
localset 966 846405
localset 967 846358
localset 968 934417
localset 969 846351
localset 970 852497
localset 971 940561
localset 972 856593
localset 973 944657
localset 974 860689
localset 975 948751
localset 976 860742
localset 977 866887
localset 978 866888
localset 979 956935
localset 980 866831
localset 981 872967
localset 982 963079
localset 983 877063
localset 984 967175
localset 985 881159
localset 986 971279
localset 987 881225
localset 988 887369
localset 989 887370
localset 990 979531
localset 991 887311
localset 992 893515
localset 993 985675
localset 994 897611
localset 995 989771
localset 996 901707
localset 997 993807
localset 998 901708
localset 999 907853
localset 1000 907854
localset 1001 1002016
localset 1002 907791
localset 1003 913952
localset 1004 920207
localset 1005 1010319
localset 1006 926351
localset 1007 1014415
localset 1008 1016079
localset 1009 1018127
localset 1010 1020175
localset 1011 1022607
localset 1012 940687
localset 1013 1026319
localset 1014 1028751
localset 1015 948879
localset 1016 1032463
localset 1017 1034895
localset 1018 963215
localset 1019 1038607
localset 1020 1041039
localset 1021 971407
localset 1022 1044751
localset 1023 1047183
localset 1024 985743
localset 1025 1050895
localset 1026 1053327
localset 1027 993935
localset 1028 1057039
localset 1029 1059471
localset 1030 1061519
localset 1031 1063567
localset 1032 1065615
localset 1033 1067663
localset 1034 1069711
localset 1035 1071759
localset 1036 1073807
localset 1037 1075855
localset 1038 1077903
localset 1039 1079951
localset 1040 1081999
localset 1041 1084047
localset 1042 1086095
localset 1043 1088143
localset 1044 1090191
localset 1045 1092239
localset 1046 1094287
localset 1047 1096335
localset 1048 1098383
localset 1049 1100321
localset 1050 1102370
localset 1051 1104417
localset 1052 1106466
localset 1053 1108523
localset 1054 1102370
localset 1055 1112587
localset 1056 1114636
localset 1057 1108491
localset 1058 1118732
localset 1059 1120778
localset 1060 1122826
localset 1061 1124866
localset 1062 1126914
localset 1063 1129004
localset 1064 1124902
localset 1065 1133060
localset 1066 1135107
localset 1067 1128964
localset 1068 1139203
localset 1069 1141248
localset 1070 1143296
localset 1071 1145389
localset 1072 1147437
localset 1073 1149486
localset 1074 1145389
localset 1075 1153583
localset 1076 1155632
localset 1077 1149487
localset 1078 1159728
localset 1079 1161765
localset 1080 1163813
localset 1081 1165873
localset 1082 1167921
localset 1083 1169970
localset 1084 1165875
localset 1085 1174068
localset 1086 1176117
localset 1087 1169972
localset 1088 1180213
localset 1089 1104415
localset 1090 1184287
localset 1091 1186335
localset 1092 1102367
localset 1093 1190418
localset 1094 1102390
localset 1095 1108534
localset 1096 1108501
localset 1097 1198608
localset 1098 1108498
localset 1099 1114640
localset 1100 1204752
localset 1101 1120784
localset 1102 1208848
localset 1103 1124880
localset 1104 1212946
localset 1105 1124919
localset 1106 1129016
localset 1107 1129017
localset 1108 1221126
localset 1109 1128978
localset 1110 1135110
localset 1111 1227270
localset 1112 1141254
localset 1113 1231366
localset 1114 1145350
localset 1115 1235474
localset 1116 1145402
localset 1117 1149498
localset 1118 1149499
localset 1119 1243708
localset 1120 1149458
localset 1121 1155644
localset 1122 1249852
localset 1123 1161788
localset 1124 1253948
localset 1125 1165884
localset 1126 1258002
localset 1127 1165885
localset 1128 1169982
localset 1129 1169983
localset 1130 1266207
localset 1131 1169938
localset 1132 1176095
localset 1133 1186450
localset 1134 1190546
localset 1135 1276562
localset 1136 1278610
localset 1137 1280274
localset 1138 1282322
localset 1139 1284370
localset 1140 1204882
localset 1141 1288850
localset 1142 1290514
localset 1143 1213074
localset 1144 1294994
localset 1145 1296658
localset 1146 1227410
localset 1147 1301138
localset 1148 1302802
localset 1149 1235602
localset 1150 1307282
localset 1151 1308946
localset 1152 1249938
localset 1153 1313426
localset 1154 1315090
localset 1155 1258130
localset 1156 1319570
localset 1157 1321234
localset 1158 1323666
localset 1159 1325714
localset 1160 1327762
localset 1161 1329810
localset 1162 1331858
localset 1163 1333906
localset 1164 1335954
localset 1165 1338002
localset 1166 1340050
localset 1167 1342098
localset 1168 1344146
localset 1169 1346194
localset 1170 1348242
localset 1171 1350290
localset 1172 1352338
localset 1173 1354386
localset 1174 1356434
localset 1175 1358482
localset 1176 1360530
localset 1177 1362578
localset 1178 1364513
localset 1179 1366561
localset 1180 1368610
localset 1181 1370658
localset 1182 1368610
localset 1183 1374784
localset 1184 1376779
localset 1185 1374731
localset 1186 1380876
localset 1187 1382924
localset 1188 1384970
localset 1189 1387018
localset 1190 1389058
localset 1191 1391106
localset 1192 1389070
localset 1193 1395265
localset 1194 1397252
localset 1195 1395204
localset 1196 1401347
localset 1197 1403395
localset 1198 1405440
localset 1199 1407488
localset 1200 1409581
localset 1201 1411629
localset 1202 1409581
localset 1203 1415746
localset 1204 1417775
localset 1205 1415727
localset 1206 1421872
localset 1207 1423920
localset 1208 1425957
localset 1209 1428005
localset 1210 1430065
localset 1211 1432113
localset 1212 1430083
localset 1213 1436228
localset 1214 1438260
localset 1215 1436212
localset 1216 1442357
localset 1217 1444405
localset 1218 1366560
localset 1219 1448480
localset 1220 1450528
localset 1221 1368608
localset 1222 1454607
localset 1223 1368645
localset 1224 1374789
localset 1225 1374742
localset 1226 1462801
localset 1227 1374735
localset 1228 1380881
localset 1229 1468945
localset 1230 1384977
localset 1231 1473041
localset 1232 1389073
localset 1233 1477135
localset 1234 1389126
localset 1235 1395271
localset 1236 1395272
localset 1237 1485319
localset 1238 1395215
localset 1239 1401351
localset 1240 1491463
localset 1241 1405447
localset 1242 1495559
localset 1243 1409543
localset 1244 1499663
localset 1245 1409609
localset 1246 1415753
localset 1247 1415754
localset 1248 1507915
localset 1249 1415695
localset 1250 1421899
localset 1251 1514059
localset 1252 1425995
localset 1253 1518155
localset 1254 1430091
localset 1255 1522191
localset 1256 1430092
localset 1257 1436237
localset 1258 1436238
localset 1259 1530400
localset 1260 1436175
localset 1261 1442336
localset 1262 1448591
localset 1263 1538703
localset 1264 1454735
localset 1265 1542799
localset 1266 1544463
localset 1267 1546511
localset 1268 1548559
localset 1269 1550991
localset 1270 1469071
localset 1271 1554703
localset 1272 1557135
localset 1273 1477263
localset 1274 1560847
localset 1275 1563279
localset 1276 1491599
localset 1277 1566991
localset 1278 1569423
localset 1279 1499791
localset 1280 1573135
localset 1281 1575567
localset 1282 1514127
localset 1283 1579279
localset 1284 1581711
localset 1285 1522319
localset 1286 1585423
localset 1287 1587855
localset 1288 1589903
localset 1289 1591951
localset 1290 1593999
localset 1291 1596047
localset 1292 1598095
localset 1293 1600143
localset 1294 1602191
localset 1295 1604239
localset 1296 1606287
localset 1297 1608335
localset 1298 1610383
localset 1299 1612431
localset 1300 1614479
localset 1301 1616527
localset 1302 1618575
localset 1303 1620623
localset 1304 1622671
localset 1305 1624719
localset 1306 1626767
localset 1307 1628434
localset 1308 1630482
localset 1309 1632530
localset 1310 1634576
localset 1311 1636651
localset 1312 1638699
localset 1313 1640747
localset 1314 1636636
localset 1315 1644828
localset 1316 1638684
localset 1317 1649027
localset 1318 1651075
localset 1319 1653123
localset 1320 1649027
localset 1321 1653123
localset 1322 1659267
localset 1323 1659164
localset 1324 1653020
localset 1325 1665308
localset 1326 1659164
localset 1327 1665308
localset 1328 1671452
localset 1329 1650981
localset 1330 1671461
localset 1331 1665317
localset 1332 1650965
localset 1333 1671445
localset 1334 1659157
localset 1335 1685775
localset 1336 1687823
localset 1337 1689871
localset 1338 1691921
localset 1339 1694016
localset 1340 1696064
localset 1341 1698112
localset 1342 1693982
localset 1343 1698078
localset 1344 1704222
localset 1345 1706371
localset 1346 1708419
localset 1347 1710467
localset 1348 1706371
localset 1349 1714563
localset 1350 1708419
localset 1351 1714462
localset 1352 1720606
localset 1353 1708318
localset 1354 1714462
localset 1355 1726750
localset 1356 1720606
localset 1357 1710373
localset 1358 1720613
localset 1359 1726757
localset 1360 1710358
localset 1361 1714454
localset 1362 1726742
localset 1363 1743138
localset 1364 1745186
localset 1365 1747234
localset 1366 1749282
localset 1367 1751299
localset 1368 1753347
localset 1369 1755395
localset 1370 1757443
localset 1371 1760000
localset 1372 1762048
localset 1373 1764096
localset 1374 1766144
localset 1375 1767713
localset 1376 1769761
localset 1377 1771809
localset 1378 1773857
localset 1379 1775872
localset 1380 1777920
localset 1381 1779968
localset 1382 1782016
localset 1383 1784067
localset 1384 1786115
localset 1385 1788163
localset 1386 1790211
localset 1387 1792259
localset 1388 1794307
localset 1389 1796355
localset 1390 1798403
localset 1391 1800451
localset 1392 1802499
localset 1393 1804547
localset 1394 1806595
localset 1395 1808643
localset 1396 1810691
localset 1397 1812739
localset 1398 1814787
localset 1399 1816858
localset 1400 1818906
localset 1401 1820954
localset 1402 1823002
localset 1403 1825049
localset 1404 1827097
localset 1405 1829145
localset 1406 1831193
localset 1407 1833746
localset 1408 1835794
localset 1409 1837842
localset 1410 1839890
localset 1411 1841938
localset 1412 1843986
localset 1413 1846034
localset 1414 1848082
localset 1415 1850130
localset 1416 1852178
localset 1417 1854223
localset 1418 1856271
localset 1419 1858319
localset 1420 1860367
localset 1421 1862415
localset 1422 1864463
localset 1423 1866511
localset 1424 1868559
localset 1425 1870607
localset 1426 1872655
localset 1427 1874255
localset 1428 1876303
localset 1429 1878351
localset 1430 1880399
localset 1431 1882448
localset 1432 1884496
localset 1433 1886544
localset 1434 1888592
localset 1435 1890578
localset 1436 1892624
localset 1437 1894674
localset 1438 1896764
localset 1439 1898770
localset 1440 1900818
localset 1441 1902866
localset 1442 1904914
localset 1443 1907025
localset 1444 1909073
localset 1445 1911121
localset 1446 1913169
localset 1447 1915218
localset 1448 1917266
localset 1449 1919314
localset 1450 1921362
localset 1451 1923343
localset 1452 1925391
localset 1453 1927441
localset 1454 1929547
localset 1455 1931535
localset 1456 1933583
localset 1457 1935631
localset 1458 1937679
localset 1459 1940228
localset 1460 1942276
localset 1461 1944324
localset 1462 1946372
localset 1463 1948420
localset 1464 1950468
localset 1465 1952516
localset 1466 1954564
localset 1467 1956612
localset 1468 1958660
localset 1469 1960708
localset 1470 1962756
localset 1471 1964804
localset 1472 1966852
localset 1473 1968900
localset 1474 1970948
localset 1475 1972480
localset 1476 1974528
localset 1477 1976576
localset 1478 1978624
localset 1479 1980672
localset 1480 1982720
localset 1481 1984768
localset 1482 1986816
localset 1483 1988864
localset 1484 1990912
localset 1485 1992960
localset 1486 1995008
localset 2023 3094753
localset 2024 3096598
localset 2025 3098711
localset 2026 3100759
localset 2027 3102811
localset 2028 3104859
localset 2029 3107041
localset 2030 3108886
localset 2031 3110999
localset 2032 3113047
localset 2033 3115099
localset 2034 3117147
localset 2035 3119329
localset 2036 3121174
localset 2037 3123287
localset 2038 3125335
localset 2039 3127387
localset 2040 3129435
localset 2041 3131617
localset 2042 3133462
localset 2043 3135575
localset 2044 3137623
localset 2045 3139675
localset 2046 3141723
localset 2047 3143935
localset 2048 3145903
localset 2049 3147951
localset 2050 3149999
localset 2051 3152047
localset 2052 3154095
localset 2053 3156143
localset 2054 3158191
localset 2055 3160239
localset 2056 3162112
localset 2057 3164160
localset 2058 3166208
localset 2059 3168256
localset 2060 3170304
localset 2061 3172352
localset 2062 3174400
localset 2063 3176448
localset 2064 3178752
localset 2065 3180800
localset 2066 3182848
localset 2067 3184896
localset 2068 3186944
localset 2069 3188992
localset 2070 3191040
localset 2071 3193088
localset 2072 3195136
localset 2073 3197184
localset 2074 3199232
localset 2075 3201280
localset 2076 3203328
localset 2077 3205376
localset 2103 3258413
localset 2104 3260511
localset 2105 3262644
localset 2106 3264627
localset 2107 3266610
localset 2108 3268713
localset 2109 3270851
localset 2110 3272837
localset 2111 3274797
localset 2112 3276895
localset 2113 3279028
localset 2114 3281011
localset 2115 3282994
localset 2116 3285097
localset 2117 3287235
localset 2118 3289221
localset 2119 3291371
localset 2120 3293409
localset 2121 3295257
localset 2122 3297300
localset 2123 3299563
localset 2124 3301601
localset 2125 3303449
localset 2126 3305492
localset 2127 3307755
localset 2128 3309793
localset 2129 3311641
localset 2130 3313684
localset 2131 3315947
localset 2132 3317985
localset 2133 3319833
localset 2134 3321876
localset 2135 3324139
localset 2136 3326177
localset 2137 3328025
localset 2138 3330068
localset 2139 3332331
localset 2140 3334369
localset 2141 3336217
localset 2142 3338260
localset 2143 3340523
localset 2144 3342561
localset 2145 3344409
localset 2146 3346452
localset 2147 3348715
localset 2148 3350753
localset 2149 3352601
localset 2150 3354644
localset 2151 3356892
localset 2152 3358935
localset 2153 3360968
localset 2154 3363036
localset 2155 3365084
localset 2156 3367127
localset 2157 3369160
localset 2158 3371228
localset 3202 124
localset 3203 128
localset 2078 3207168
localset 2079 3209216
localset 2080 3211264
localset 2081 3213312
localset 2082 3215360
localset 2083 3217408
localset 2084 3219456
localset 2085 3221504
localset 2086 3223552
localset 2087 3225600
localset 2088 3227648
localset 2089 3229696
localset 2090 3231744
localset 2091 3233792
localset 2092 3235840
localset 2093 3237888
localset 2094 3239936
localset 2095 3241984
localset 2096 3244032
localset 2097 3246080
localset 2098 3248128
localset 2099 3250176
localset 2100 3252224
localset 2101 3254272
localset 2102 3256320
localset 11 0
label actor
localset 142 0
localset 144 0
localset 145 0
localset 146 0
localget r0 11
cmp r0 124
jge skid_actor
cmp r0 4
jge tree_actor
cmp r0 0
je open_player_actor
jmp next_actor
label open_player_actor
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
localget r0 11
mod r0 10
cmp r0 7
je nature_rock_model
cmp r0 8
je nature_rock_model
cmp r0 9
je nature_grass_model
set r0 1552
mov r9 r0
localset 132 r9
set r0 1566
mov r9 r0
localset 134 r9
jmp nature_model_ready
label nature_rock_model
set r0 1566
mov r9 r0
localset 132 r9
set r0 1579
mov r9 r0
localset 134 r9
jmp nature_model_ready
label nature_grass_model
set r0 1579
mov r9 r0
localset 132 r9
set r0 1591
mov r9 r0
localset 134 r9
label nature_model_ready
localget r5 11
localget r6 3200
mul r6 4
add r5 r6
localset 3120 r5
localget r8 11
sub r8 4
div r8 4
localget r7 3200
add r8 r7
localget r7 3201
cmp r8 r7
jge next_actor
mov r7 r8
add r7 5500
load8 r7 $r7
cmp r7 1
je next_actor
cmp r7 5
je next_actor
cmp r7 2
jne open_tree_bank_ready
localget r7 11
mod r7 2
cmp r7 1
je next_actor
label open_tree_bank_ready
mov r7 r8
mul r7 2
add r7 5000
sub r7 1400
localget r3 r7
add r7 1
localget r4 r7
localget r0 11
mod r0 2
mul r0 2
sub r0 1
localget r1 3120
mul r1 73
mod r1 2500
add r1 470
localget r5 3120
mod r5 10
cmp r5 7
je wetlands_rock_offset
cmp r5 8
jne wetlands_rock_offset_ready
label wetlands_rock_offset
add r1 250
label wetlands_rock_offset_ready
mul r0 r1
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
localget r5 11
sub r5 4
div r5 4
localget r6 3200
add r5 r6
mul r5 2
add r5 5300
load16 r5 $r5
localset 3104 r5
set r8 0
jmp actor_ready
label skid_actor
set r0 1639
mov r9 r0
localset 132 r9
set r0 1647
mov r9 r0
localset 134 r9
localget r7 11
sub r7 124
mul r7 12
add r7 410
load8 r9 $r7
cmp r9 0
jle next_actor
sub r7 10
load32 r0 $r7
sub r0 2000000
add r7 4
load32 r2 $r7
sub r2 2000000
add r7 4
load16 r8 $r7
add r7 3
load8 r5 $r7
localset 3104 r5
label actor_ready
localget r5 11
cmp r5 4
jlt open_actor_heading
cmp r5 124
jge open_actor_heading
set r3 0
set r4 16384
jmp open_actor_heading_ready
label open_actor_heading
mov r3 r8
add r3 0
mod r3 4096
cmp r3 0
jge sin_negative_314
add r3 4096
label sin_negative_314
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
jlt sin_done_315
mul r5 -1
label sin_done_315
mov r3 r5
mov r6 r3
mov r9 r6
add r9 32768
localset 58 r9
mov r4 r8
add r4 1024
mod r4 4096
cmp r4 0
jge sin_negative_316
add r4 4096
label sin_negative_316
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
jlt sin_done_317
mul r5 -1
label sin_done_317
mov r4 r5
localget r3 58
sub r3 32768
label open_actor_heading_ready
localset 3320 -8390
localset 3321 12815
localset 3322 -5796
load8 r5 526
cmp r5 1
je open_sun_dusk
cmp r5 2
je open_sun_night
jmp open_sun_ready
label open_sun_dusk
localset 3320 -13300
localset 3321 5400
localset 3322 -7900
jmp open_sun_ready
label open_sun_night
localset 3320 3800
localset 3321 12600
localset 3322 9700
label open_sun_ready
localget r5 11
cmp r5 4
jge lighting_basis_ready
mov r5 r4
localget r7 3320
mul r5 r7
mov r6 r3
localget r7 3322
mul r6 r7
sub r5 r6
div r5 16384
localset 3000 r5
localget r7 3321
localset 3001 r7
mov r5 r3
localget r7 3320
mul r5 r7
mov r6 r4
localget r7 3322
mul r6 r7
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
jge norm_component_322
mul r10 -1
label norm_component_322
add r9 r10
mov r10 r6
cmp r10 0
jge norm_component_323
mul r10 -1
label norm_component_323
add r9 r10
mov r10 r7
cmp r10 0
jge norm_component_324
mul r10 -1
label norm_component_324
add r9 r10
cmp r9 0
jgt norm_nonzero_321
set r9 1
label norm_nonzero_321
label norm_sqrt_319
mov r10 r8
div r10 r9
add r10 r9
div r10 2
cmp r10 r9
jge norm_done_320
mov r9 r10
cmp r9 0
jgt norm_sqrt_319
set r9 1
label norm_done_320
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
jge norm_component_329
mul r10 -1
label norm_component_329
add r9 r10
mov r10 r6
cmp r10 0
jge norm_component_330
mul r10 -1
label norm_component_330
add r9 r10
mov r10 r7
cmp r10 0
jge norm_component_331
mul r10 -1
label norm_component_331
add r9 r10
cmp r9 0
jgt norm_nonzero_328
set r9 1
label norm_nonzero_328
label norm_sqrt_326
mov r10 r8
div r10 r9
add r10 r9
div r10 2
cmp r10 r9
jge norm_done_327
mov r9 r10
cmp r9 0
jgt norm_sqrt_326
set r9 1
label norm_done_327
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
localget r5 11
cmp r5 0
jne rig_lighting_ready
load16 r5 512
sub r5 32768
div r5 256
localset 3100 r5
load16 r5 508
sub r5 32768
localset 3101 r5
load16 r5 504
sub r5 32768
localset 3102 r5
load16 r5 516
sub r5 32768
div r5 256
localset 3103 r5
localget r5 3000
localget r6 3001
localget r7 3002
load16 r8 508
sub r8 32768
localget r9 3102
mov r10 r8
mul r10 r6
div r10 22528
add r10 r5
mov r11 r9
mul r11 r6
div r11 35840
add r11 r7
mul r8 r5
div r8 22528
sub r6 r8
mul r9 r7
div r9 35840
sub r6 r9
localset 3000 r10
localset 3001 r6
localset 3002 r11
localget r5 3003
localget r6 3004
localget r7 3005
load16 r8 508
sub r8 32768
localget r9 3102
mov r10 r8
mul r10 r6
div r10 22528
add r10 r5
mov r11 r9
mul r11 r6
div r11 35840
add r11 r7
mul r8 r5
div r8 22528
sub r6 r8
mul r9 r7
div r9 35840
sub r6 r9
localset 3003 r10
localset 3004 r6
localset 3005 r11
localget r5 3006
localget r6 3007
localget r7 3008
load16 r8 508
sub r8 32768
localget r9 3102
mov r10 r8
mul r10 r6
div r10 22528
add r10 r5
mov r11 r9
mul r11 r6
div r11 35840
add r11 r7
mul r8 r5
div r8 22528
sub r6 r8
mul r9 r7
div r9 35840
sub r6 r9
localset 3006 r10
localset 3007 r6
localset 3008 r11
label rig_lighting_ready
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
cmp r0 22000
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
jlt nature_fog_ready
localget r0 112
sub r0 1000000
div r0 160
add r0 56
cmp r0 56
jge nature_fog_min
set r0 56
label nature_fog_min
cmp r0 224
jle nature_fog_max
set r0 224
label nature_fog_max
localset 3090 r0
label nature_fog_ready
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
jge diffuse_positive_334
set r0 0
label diffuse_positive_334
mul r0 128
div r0 16384
add r0 66
localset 2816 r0
mov r2 r0
mul r2 4
div r2 5
localset 2560 r2
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
jge highlight_positive_335
set r1 0
label highlight_positive_335
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2688 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 0
localget r2 3007
mul r2 366
add r1 r2
localget r2 3008
mul r2 -16380
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_0
set r1 0
label fresnel_positive_0
cmp r1 16384
jle fresnel_bounded_0
set r1 16384
label fresnel_bounded_0
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2688
mul r2 168
div r2 16384
localget r1 2816
add r2 r1
cmp r2 255
jle metal_bounded_0
set r2 255
label metal_bounded_0
localset 2688 r2
cmp r0 255
jle intensity_bounded_336
set r0 255
label intensity_bounded_336
localset 2304 r0
localget r1 2816
mul r1 3
add r1 r0
div r1 4
localset 2816 r1
label body_lighting_done_332
localget r3 3030
cmp r3 0
jne body_lighting_done_337
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
jge diffuse_positive_339
set r0 0
label diffuse_positive_339
mul r0 128
div r0 16384
add r0 71
localset 2817 r0
mov r2 r0
mul r2 4
div r2 5
localset 2561 r2
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
jge highlight_positive_340
set r1 0
label highlight_positive_340
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2689 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -15205
localget r2 3007
mul r2 4041
add r1 r2
localget r2 3008
mul r2 -4574
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_1
set r1 0
label fresnel_positive_1
cmp r1 16384
jle fresnel_bounded_1
set r1 16384
label fresnel_bounded_1
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2689
mul r2 168
div r2 16384
localget r1 2817
add r2 r1
cmp r2 255
jle metal_bounded_1
set r2 255
label metal_bounded_1
localset 2689 r2
cmp r0 255
jle intensity_bounded_341
set r0 255
label intensity_bounded_341
localset 2305 r0
localget r1 2817
mul r1 3
add r1 r0
div r1 4
localset 2817 r1
label body_lighting_done_337
localget r3 3030
cmp r3 0
jne body_lighting_done_342
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
jge diffuse_positive_344
set r0 0
label diffuse_positive_344
mul r0 128
div r0 16384
add r0 86
localset 2818 r0
mov r2 r0
mul r2 4
div r2 5
localset 2562 r2
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
jge highlight_positive_345
set r1 0
label highlight_positive_345
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2690 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 79
localget r2 3007
mul r2 15183
add r1 r2
localget r2 3008
mul r2 -6156
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_2
set r1 0
label fresnel_positive_2
cmp r1 16384
jle fresnel_bounded_2
set r1 16384
label fresnel_bounded_2
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2690
mul r2 168
div r2 16384
localget r1 2818
add r2 r1
cmp r2 255
jle metal_bounded_2
set r2 255
label metal_bounded_2
localset 2690 r2
cmp r0 255
jle intensity_bounded_346
set r0 255
label intensity_bounded_346
localset 2306 r0
localget r1 2818
mul r1 3
add r1 r0
div r1 4
localset 2818 r1
label body_lighting_done_342
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
jge glass_low_347
set r0 0
label glass_low_347
cmp r0 255
jle glass_high_348
set r0 255
label glass_high_348
localset 2434 r0
label glass_lighting_done_343
localget r3 3030
cmp r3 0
jne body_lighting_done_349
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
jge diffuse_positive_351
set r0 0
label diffuse_positive_351
mul r0 128
div r0 16384
add r0 73
localset 2819 r0
mov r2 r0
mul r2 4
div r2 5
localset 2563 r2
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
jge highlight_positive_352
set r1 0
label highlight_positive_352
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2691 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 4
localget r2 3007
mul r2 5239
add r1 r2
localget r2 3008
mul r2 -15524
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_3
set r1 0
label fresnel_positive_3
cmp r1 16384
jle fresnel_bounded_3
set r1 16384
label fresnel_bounded_3
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2691
mul r2 168
div r2 16384
localget r1 2819
add r2 r1
cmp r2 255
jle metal_bounded_3
set r2 255
label metal_bounded_3
localset 2691 r2
cmp r0 255
jle intensity_bounded_353
set r0 255
label intensity_bounded_353
localset 2307 r0
localget r1 2819
mul r1 3
add r1 r0
div r1 4
localset 2819 r1
label body_lighting_done_349
localget r3 3030
cmp r3 0
jne glass_lighting_done_350
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
jge glass_low_354
set r0 0
label glass_low_354
cmp r0 255
jle glass_high_355
set r0 255
label glass_high_355
localset 2435 r0
label glass_lighting_done_350
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
jge diffuse_positive_358
set r0 0
label diffuse_positive_358
mul r0 128
div r0 16384
add r0 81
localset 2820 r0
mov r2 r0
mul r2 4
div r2 5
localset 2564 r2
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
jge highlight_positive_359
set r1 0
label highlight_positive_359
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2692 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 20
localget r2 3007
mul r2 10974
add r1 r2
localget r2 3008
mul r2 -12166
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_4
set r1 0
label fresnel_positive_4
cmp r1 16384
jle fresnel_bounded_4
set r1 16384
label fresnel_bounded_4
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2692
mul r2 168
div r2 16384
localget r1 2820
add r2 r1
cmp r2 255
jle metal_bounded_4
set r2 255
label metal_bounded_4
localset 2692 r2
cmp r0 255
jle intensity_bounded_360
set r0 255
label intensity_bounded_360
localset 2308 r0
localget r1 2820
mul r1 3
add r1 r0
div r1 4
localset 2820 r1
label body_lighting_done_356
localget r3 3030
cmp r3 0
jne body_lighting_done_361
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
jge diffuse_positive_363
set r0 0
label diffuse_positive_363
mul r0 128
div r0 16384
add r0 73
localset 2821 r0
mov r2 r0
mul r2 4
div r2 5
localset 2565 r2
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
jge highlight_positive_364
set r1 0
label highlight_positive_364
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2693 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 14114
localget r2 3007
mul r2 5535
add r1 r2
localget r2 3008
mul r2 -6211
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_5
set r1 0
label fresnel_positive_5
cmp r1 16384
jle fresnel_bounded_5
set r1 16384
label fresnel_bounded_5
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2693
mul r2 168
div r2 16384
localget r1 2821
add r2 r1
cmp r2 255
jle metal_bounded_5
set r2 255
label metal_bounded_5
localset 2693 r2
cmp r0 255
jle intensity_bounded_365
set r0 255
label intensity_bounded_365
localset 2309 r0
localget r1 2821
mul r1 3
add r1 r0
div r1 4
localset 2821 r1
label body_lighting_done_361
localget r3 3030
cmp r3 2
je body_lighting_done_366
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
jge diffuse_positive_368
set r0 0
label diffuse_positive_368
mul r0 128
div r0 16384
add r0 66
localset 2822 r0
mov r2 r0
mul r2 4
div r2 5
localset 2566 r2
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
jge highlight_positive_369
set r1 0
label highlight_positive_369
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2694 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -15872
localget r2 3007
mul r2 161
add r1 r2
localget r2 3008
mul r2 -4061
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_6
set r1 0
label fresnel_positive_6
cmp r1 16384
jle fresnel_bounded_6
set r1 16384
label fresnel_bounded_6
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2694
mul r2 168
div r2 16384
localget r1 2822
add r2 r1
cmp r2 255
jle metal_bounded_6
set r2 255
label metal_bounded_6
localset 2694 r2
cmp r0 255
jle intensity_bounded_370
set r0 255
label intensity_bounded_370
localset 2310 r0
localget r1 2822
mul r1 3
add r1 r0
div r1 4
localset 2822 r1
label body_lighting_done_366
localget r3 3030
cmp r3 2
je body_lighting_done_371
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
jge diffuse_positive_373
set r0 0
label diffuse_positive_373
mul r0 128
div r0 16384
add r0 66
localset 2823 r0
mov r2 r0
mul r2 4
div r2 5
localset 2567 r2
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
jge highlight_positive_374
set r1 0
label highlight_positive_374
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2695 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 15915
localget r2 3007
mul r2 62
add r1 r2
localget r2 3008
mul r2 -3891
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_7
set r1 0
label fresnel_positive_7
cmp r1 16384
jle fresnel_bounded_7
set r1 16384
label fresnel_bounded_7
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2695
mul r2 168
div r2 16384
localget r1 2823
add r2 r1
cmp r2 255
jle metal_bounded_7
set r2 255
label metal_bounded_7
localset 2695 r2
cmp r0 255
jle intensity_bounded_375
set r0 255
label intensity_bounded_375
localset 2311 r0
localget r1 2823
mul r1 3
add r1 r0
div r1 4
localset 2823 r1
label body_lighting_done_371
localget r3 3030
cmp r3 0
jne body_lighting_done_376
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
jge diffuse_positive_378
set r0 0
label diffuse_positive_378
mul r0 128
div r0 16384
add r0 87
localset 2824 r0
mov r2 r0
mul r2 4
div r2 5
localset 2568 r2
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
jge highlight_positive_379
set r1 0
label highlight_positive_379
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2696 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -3216
localget r2 3007
mul r2 15722
add r1 r2
localget r2 3008
mul r2 -3305
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_8
set r1 0
label fresnel_positive_8
cmp r1 16384
jle fresnel_bounded_8
set r1 16384
label fresnel_bounded_8
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2696
mul r2 168
div r2 16384
localget r1 2824
add r2 r1
cmp r2 255
jle metal_bounded_8
set r2 255
label metal_bounded_8
localset 2696 r2
cmp r0 255
jle intensity_bounded_380
set r0 255
label intensity_bounded_380
localset 2312 r0
localget r1 2824
mul r1 3
add r1 r0
div r1 4
localset 2824 r1
label body_lighting_done_376
localget r3 3030
cmp r3 0
jne body_lighting_done_381
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
jge diffuse_positive_383
set r0 0
label diffuse_positive_383
mul r0 128
div r0 16384
add r0 87
localset 2825 r0
mov r2 r0
mul r2 4
div r2 5
localset 2569 r2
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
jge highlight_positive_384
set r1 0
label highlight_positive_384
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2697 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -5031
localget r2 3007
mul r2 15482
add r1 r2
localget r2 3008
mul r2 -1850
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_9
set r1 0
label fresnel_positive_9
cmp r1 16384
jle fresnel_bounded_9
set r1 16384
label fresnel_bounded_9
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2697
mul r2 168
div r2 16384
localget r1 2825
add r2 r1
cmp r2 255
jle metal_bounded_9
set r2 255
label metal_bounded_9
localset 2697 r2
cmp r0 255
jle intensity_bounded_385
set r0 255
label intensity_bounded_385
localset 2313 r0
localget r1 2825
mul r1 3
add r1 r0
div r1 4
localset 2825 r1
label body_lighting_done_381
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
jge diffuse_positive_388
set r0 0
label diffuse_positive_388
mul r0 128
div r0 16384
add r0 88
localset 2826 r0
mov r2 r0
mul r2 4
div r2 5
localset 2570 r2
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
jge highlight_positive_389
set r1 0
label highlight_positive_389
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2698 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 10
localget r2 3007
mul r2 16382
add r1 r2
localget r2 3008
mul r2 247
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_10
set r1 0
label fresnel_positive_10
cmp r1 16384
jle fresnel_bounded_10
set r1 16384
label fresnel_bounded_10
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2698
mul r2 168
div r2 16384
localget r1 2826
add r2 r1
cmp r2 255
jle metal_bounded_10
set r2 255
label metal_bounded_10
localset 2698 r2
cmp r0 255
jle intensity_bounded_390
set r0 255
label intensity_bounded_390
localset 2314 r0
localget r1 2826
mul r1 3
add r1 r0
div r1 4
localset 2826 r1
label body_lighting_done_386
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
jge glass_low_391
set r0 0
label glass_low_391
cmp r0 255
jle glass_high_392
set r0 255
label glass_high_392
localset 2442 r0
label glass_lighting_done_387
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
jge diffuse_positive_395
set r0 0
label diffuse_positive_395
mul r0 128
div r0 16384
add r0 82
localset 2827 r0
mov r2 r0
mul r2 4
div r2 5
localset 2571 r2
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
jge highlight_positive_396
set r1 0
label highlight_positive_396
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2699 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 54
localget r2 3007
mul r2 11734
add r1 r2
localget r2 3008
mul r2 11434
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_11
set r1 0
label fresnel_positive_11
cmp r1 16384
jle fresnel_bounded_11
set r1 16384
label fresnel_bounded_11
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2699
mul r2 168
div r2 16384
localget r1 2827
add r2 r1
cmp r2 255
jle metal_bounded_11
set r2 255
label metal_bounded_11
localset 2699 r2
cmp r0 255
jle intensity_bounded_397
set r0 255
label intensity_bounded_397
localset 2315 r0
localget r1 2827
mul r1 3
add r1 r0
div r1 4
localset 2827 r1
label body_lighting_done_393
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
jge diffuse_positive_400
set r0 0
label diffuse_positive_400
mul r0 128
div r0 16384
add r0 86
localset 2828 r0
mov r2 r0
mul r2 4
div r2 5
localset 2572 r2
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
jge highlight_positive_401
set r1 0
label highlight_positive_401
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2700 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -120
localget r2 3007
mul r2 15093
add r1 r2
localget r2 3008
mul r2 6373
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_12
set r1 0
label fresnel_positive_12
cmp r1 16384
jle fresnel_bounded_12
set r1 16384
label fresnel_bounded_12
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2700
mul r2 168
div r2 16384
localget r1 2828
add r2 r1
cmp r2 255
jle metal_bounded_12
set r2 255
label metal_bounded_12
localset 2700 r2
cmp r0 255
jle intensity_bounded_402
set r0 255
label intensity_bounded_402
localset 2316 r0
localget r1 2828
mul r1 3
add r1 r0
div r1 4
localset 2828 r1
label body_lighting_done_398
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
jge glass_low_403
set r0 0
label glass_low_403
cmp r0 255
jle glass_high_404
set r0 255
label glass_high_404
localset 2444 r0
label glass_lighting_done_399
localget r3 3030
cmp r3 0
jne body_lighting_done_405
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
jge diffuse_positive_407
set r0 0
label diffuse_positive_407
mul r0 128
div r0 16384
add r0 87
localset 2829 r0
mov r2 r0
mul r2 4
div r2 5
localset 2573 r2
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
jge highlight_positive_408
set r1 0
label highlight_positive_408
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2701 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 5537
localget r2 3007
mul r2 15417
add r1 r2
localget r2 3008
mul r2 277
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_13
set r1 0
label fresnel_positive_13
cmp r1 16384
jle fresnel_bounded_13
set r1 16384
label fresnel_bounded_13
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2701
mul r2 168
div r2 16384
localget r1 2829
add r2 r1
cmp r2 255
jle metal_bounded_13
set r2 255
label metal_bounded_13
localset 2701 r2
cmp r0 255
jle intensity_bounded_409
set r0 255
label intensity_bounded_409
localset 2317 r0
localget r1 2829
mul r1 3
add r1 r0
div r1 4
localset 2829 r1
label body_lighting_done_405
localget r3 3030
cmp r3 2
je glass_lighting_done_406
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
jge glass_low_410
set r0 0
label glass_low_410
cmp r0 255
jle glass_high_411
set r0 255
label glass_high_411
localset 2445 r0
label glass_lighting_done_406
localget r3 3030
cmp r3 0
jne body_lighting_done_412
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
jge diffuse_positive_414
set r0 0
label diffuse_positive_414
mul r0 128
div r0 16384
add r0 86
localset 2830 r0
mov r2 r0
mul r2 4
div r2 5
localset 2574 r2
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
jge highlight_positive_415
set r1 0
label highlight_positive_415
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2702 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 2016
localget r2 3007
mul r2 15210
add r1 r2
localget r2 3008
mul r2 -5748
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_14
set r1 0
label fresnel_positive_14
cmp r1 16384
jle fresnel_bounded_14
set r1 16384
label fresnel_bounded_14
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2702
mul r2 168
div r2 16384
localget r1 2830
add r2 r1
cmp r2 255
jle metal_bounded_14
set r2 255
label metal_bounded_14
localset 2702 r2
cmp r0 255
jle intensity_bounded_416
set r0 255
label intensity_bounded_416
localset 2318 r0
localget r1 2830
mul r1 3
add r1 r0
div r1 4
localset 2830 r1
label body_lighting_done_412
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
jge glass_low_417
set r0 0
label glass_low_417
cmp r0 255
jle glass_high_418
set r0 255
label glass_high_418
localset 2446 r0
label glass_lighting_done_413
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
jge diffuse_positive_421
set r0 0
label diffuse_positive_421
mul r0 128
div r0 16384
add r0 66
localset 2831 r0
mov r2 r0
mul r2 4
div r2 5
localset 2575 r2
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
jge highlight_positive_422
set r1 0
label highlight_positive_422
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2703 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 16384
localget r2 3007
mul r2 71
add r1 r2
localget r2 3008
mul r2 18
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_15
set r1 0
label fresnel_positive_15
cmp r1 16384
jle fresnel_bounded_15
set r1 16384
label fresnel_bounded_15
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2703
mul r2 168
div r2 16384
localget r1 2831
add r2 r1
cmp r2 255
jle metal_bounded_15
set r2 255
label metal_bounded_15
localset 2703 r2
cmp r0 255
jle intensity_bounded_423
set r0 255
label intensity_bounded_423
localset 2319 r0
localget r1 2831
mul r1 3
add r1 r0
div r1 4
localset 2831 r1
label body_lighting_done_419
localget r3 3030
cmp r3 2
je body_lighting_done_424
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
jge diffuse_positive_426
set r0 0
label diffuse_positive_426
mul r0 128
div r0 16384
add r0 73
localset 2832 r0
mov r2 r0
mul r2 4
div r2 5
localset 2576 r2
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
jge highlight_positive_427
set r1 0
label highlight_positive_427
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2704 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -15542
localget r2 3007
mul r2 5184
add r1 r2
localget r2 3008
mul r2 152
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_16
set r1 0
label fresnel_positive_16
cmp r1 16384
jle fresnel_bounded_16
set r1 16384
label fresnel_bounded_16
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2704
mul r2 168
div r2 16384
localget r1 2832
add r2 r1
cmp r2 255
jle metal_bounded_16
set r2 255
label metal_bounded_16
localset 2704 r2
cmp r0 255
jle intensity_bounded_428
set r0 255
label intensity_bounded_428
localset 2320 r0
localget r1 2832
mul r1 3
add r1 r0
div r1 4
localset 2832 r1
label body_lighting_done_424
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
jge glass_low_429
set r0 0
label glass_low_429
cmp r0 255
jle glass_high_430
set r0 255
label glass_high_430
localset 2448 r0
label glass_lighting_done_425
localget r3 3030
cmp r3 2
je body_lighting_done_431
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
jge diffuse_positive_433
set r0 0
label diffuse_positive_433
mul r0 128
div r0 16384
add r0 73
localset 2833 r0
mov r2 r0
mul r2 4
div r2 5
localset 2577 r2
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
jge highlight_positive_434
set r1 0
label highlight_positive_434
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2705 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 15486
localget r2 3007
mul r2 5348
add r1 r2
localget r2 3008
mul r2 111
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_17
set r1 0
label fresnel_positive_17
cmp r1 16384
jle fresnel_bounded_17
set r1 16384
label fresnel_bounded_17
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2705
mul r2 168
div r2 16384
localget r1 2833
add r2 r1
cmp r2 255
jle metal_bounded_17
set r2 255
label metal_bounded_17
localset 2705 r2
cmp r0 255
jle intensity_bounded_435
set r0 255
label intensity_bounded_435
localset 2321 r0
localget r1 2833
mul r1 3
add r1 r0
div r1 4
localset 2833 r1
label body_lighting_done_431
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
jge glass_low_436
set r0 0
label glass_low_436
cmp r0 255
jle glass_high_437
set r0 255
label glass_high_437
localset 2449 r0
label glass_lighting_done_432
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
jge diffuse_positive_440
set r0 0
label diffuse_positive_440
mul r0 128
div r0 16384
add r0 66
localset 2834 r0
mov r2 r0
mul r2 4
div r2 5
localset 2578 r2
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
jge highlight_positive_441
set r1 0
label highlight_positive_441
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2706 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -16384
localget r2 3007
mul r2 50
add r1 r2
localget r2 3008
mul r2 40
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_18
set r1 0
label fresnel_positive_18
cmp r1 16384
jle fresnel_bounded_18
set r1 16384
label fresnel_bounded_18
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2706
mul r2 168
div r2 16384
localget r1 2834
add r2 r1
cmp r2 255
jle metal_bounded_18
set r2 255
label metal_bounded_18
localset 2706 r2
cmp r0 255
jle intensity_bounded_442
set r0 255
label intensity_bounded_442
localset 2322 r0
localget r1 2834
mul r1 3
add r1 r0
div r1 4
localset 2834 r1
label body_lighting_done_438
localget r3 3030
cmp r3 0
jne body_lighting_done_443
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
jge diffuse_positive_445
set r0 0
label diffuse_positive_445
mul r0 128
div r0 16384
add r0 80
localset 2835 r0
mov r2 r0
mul r2 4
div r2 5
localset 2579 r2
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
jge highlight_positive_446
set r1 0
label highlight_positive_446
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2707 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -12536
localget r2 3007
mul r2 10548
add r1 r2
localget r2 3008
mul r2 109
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_19
set r1 0
label fresnel_positive_19
cmp r1 16384
jle fresnel_bounded_19
set r1 16384
label fresnel_bounded_19
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2707
mul r2 168
div r2 16384
localget r1 2835
add r2 r1
cmp r2 255
jle metal_bounded_19
set r2 255
label metal_bounded_19
localset 2707 r2
cmp r0 255
jle intensity_bounded_447
set r0 255
label intensity_bounded_447
localset 2323 r0
localget r1 2835
mul r1 3
add r1 r0
div r1 4
localset 2835 r1
label body_lighting_done_443
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
jge glass_low_448
set r0 0
label glass_low_448
cmp r0 255
jle glass_high_449
set r0 255
label glass_high_449
localset 2451 r0
label glass_lighting_done_444
localget r3 3030
cmp r3 0
jne body_lighting_done_450
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
jge diffuse_positive_452
set r0 0
label diffuse_positive_452
mul r0 128
div r0 16384
add r0 81
localset 2836 r0
mov r2 r0
mul r2 4
div r2 5
localset 2580 r2
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
jge highlight_positive_453
set r1 0
label highlight_positive_453
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2708 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 12291
localget r2 3007
mul r2 10833
add r1 r2
localget r2 3008
mul r2 168
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_20
set r1 0
label fresnel_positive_20
cmp r1 16384
jle fresnel_bounded_20
set r1 16384
label fresnel_bounded_20
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2708
mul r2 168
div r2 16384
localget r1 2836
add r2 r1
cmp r2 255
jle metal_bounded_20
set r2 255
label metal_bounded_20
localset 2708 r2
cmp r0 255
jle intensity_bounded_454
set r0 255
label intensity_bounded_454
localset 2324 r0
localget r1 2836
mul r1 3
add r1 r0
div r1 4
localset 2836 r1
label body_lighting_done_450
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
jge glass_low_455
set r0 0
label glass_low_455
cmp r0 255
jle glass_high_456
set r0 255
label glass_high_456
localset 2452 r0
label glass_lighting_done_451
localget r3 3030
cmp r3 0
jne body_lighting_done_457
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
jge diffuse_positive_459
set r0 0
label diffuse_positive_459
mul r0 128
div r0 16384
add r0 81
localset 2837 r0
mov r2 r0
mul r2 4
div r2 5
localset 2581 r2
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
jge highlight_positive_460
set r1 0
label highlight_positive_460
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2709 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -11041
localget r2 3007
mul r2 11088
add r1 r2
localget r2 3008
mul r2 4856
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_21
set r1 0
label fresnel_positive_21
cmp r1 16384
jle fresnel_bounded_21
set r1 16384
label fresnel_bounded_21
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2709
mul r2 168
div r2 16384
localget r1 2837
add r2 r1
cmp r2 255
jle metal_bounded_21
set r2 255
label metal_bounded_21
localset 2709 r2
cmp r0 255
jle intensity_bounded_461
set r0 255
label intensity_bounded_461
localset 2325 r0
localget r1 2837
mul r1 3
add r1 r0
div r1 4
localset 2837 r1
label body_lighting_done_457
localget r3 3030
cmp r3 0
jne body_lighting_done_462
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
jge diffuse_positive_464
set r0 0
label diffuse_positive_464
mul r0 128
div r0 16384
add r0 80
localset 2838 r0
mov r2 r0
mul r2 4
div r2 5
localset 2582 r2
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
jge highlight_positive_465
set r1 0
label highlight_positive_465
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2710 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 11383
localget r2 3007
mul r2 10631
add r1 r2
localget r2 3008
mul r2 5082
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_22
set r1 0
label fresnel_positive_22
cmp r1 16384
jle fresnel_bounded_22
set r1 16384
label fresnel_bounded_22
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2710
mul r2 168
div r2 16384
localget r1 2838
add r2 r1
cmp r2 255
jle metal_bounded_22
set r2 255
label metal_bounded_22
localset 2710 r2
cmp r0 255
jle intensity_bounded_466
set r0 255
label intensity_bounded_466
localset 2326 r0
localget r1 2838
mul r1 3
add r1 r0
div r1 4
localset 2838 r1
label body_lighting_done_462
localget r3 3030
cmp r3 0
jne body_lighting_done_467
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
jge diffuse_positive_469
set r0 0
label diffuse_positive_469
mul r0 128
div r0 16384
add r0 75
localset 2839 r0
mov r2 r0
mul r2 4
div r2 5
localset 2583 r2
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
jge highlight_positive_470
set r1 0
label highlight_positive_470
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2711 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -14031
localget r2 3007
mul r2 6476
add r1 r2
localget r2 3008
mul r2 5443
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_23
set r1 0
label fresnel_positive_23
cmp r1 16384
jle fresnel_bounded_23
set r1 16384
label fresnel_bounded_23
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2711
mul r2 168
div r2 16384
localget r1 2839
add r2 r1
cmp r2 255
jle metal_bounded_23
set r2 255
label metal_bounded_23
localset 2711 r2
cmp r0 255
jle intensity_bounded_471
set r0 255
label intensity_bounded_471
localset 2327 r0
localget r1 2839
mul r1 3
add r1 r0
div r1 4
localset 2839 r1
label body_lighting_done_467
localget r3 3030
cmp r3 0
jne body_lighting_done_472
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
jge diffuse_positive_474
set r0 0
label diffuse_positive_474
mul r0 128
div r0 16384
add r0 74
localset 2840 r0
mov r2 r0
mul r2 4
div r2 5
localset 2584 r2
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
jge highlight_positive_475
set r1 0
label highlight_positive_475
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2712 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 14057
localget r2 3007
mul r2 6081
add r1 r2
localget r2 3008
mul r2 5819
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_24
set r1 0
label fresnel_positive_24
cmp r1 16384
jle fresnel_bounded_24
set r1 16384
label fresnel_bounded_24
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2712
mul r2 168
div r2 16384
localget r1 2840
add r2 r1
cmp r2 255
jle metal_bounded_24
set r2 255
label metal_bounded_24
localset 2712 r2
cmp r0 255
jle intensity_bounded_476
set r0 255
label intensity_bounded_476
localset 2328 r0
localget r1 2840
mul r1 3
add r1 r0
div r1 4
localset 2840 r1
label body_lighting_done_472
localget r3 3030
cmp r3 0
jne body_lighting_done_477
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
jge diffuse_positive_479
set r0 0
label diffuse_positive_479
mul r0 128
div r0 16384
add r0 87
localset 2841 r0
mov r2 r0
mul r2 4
div r2 5
localset 2585 r2
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
jge highlight_positive_480
set r1 0
label highlight_positive_480
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2713 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -3668
localget r2 3007
mul r2 15902
add r1 r2
localget r2 3008
mul r2 1457
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_25
set r1 0
label fresnel_positive_25
cmp r1 16384
jle fresnel_bounded_25
set r1 16384
label fresnel_bounded_25
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2713
mul r2 168
div r2 16384
localget r1 2841
add r2 r1
cmp r2 255
jle metal_bounded_25
set r2 255
label metal_bounded_25
localset 2713 r2
cmp r0 255
jle intensity_bounded_481
set r0 255
label intensity_bounded_481
localset 2329 r0
localget r1 2841
mul r1 3
add r1 r0
div r1 4
localset 2841 r1
label body_lighting_done_477
localget r3 3030
cmp r3 0
jne body_lighting_done_482
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
jge diffuse_positive_484
set r0 0
label diffuse_positive_484
mul r0 128
div r0 16384
add r0 87
localset 2842 r0
mov r2 r0
mul r2 4
div r2 5
localset 2586 r2
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
jge highlight_positive_485
set r1 0
label highlight_positive_485
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2714 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 3588
localget r2 3007
mul r2 15913
add r1 r2
localget r2 3008
mul r2 1526
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_26
set r1 0
label fresnel_positive_26
cmp r1 16384
jle fresnel_bounded_26
set r1 16384
label fresnel_bounded_26
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2714
mul r2 168
div r2 16384
localget r1 2842
add r2 r1
cmp r2 255
jle metal_bounded_26
set r2 255
label metal_bounded_26
localset 2714 r2
cmp r0 255
jle intensity_bounded_486
set r0 255
label intensity_bounded_486
localset 2330 r0
localget r1 2842
mul r1 3
add r1 r0
div r1 4
localset 2842 r1
label body_lighting_done_482
localget r3 3030
cmp r3 0
jne glass_lighting_done_483
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
jge glass_low_487
set r0 0
label glass_low_487
cmp r0 255
jle glass_high_488
set r0 255
label glass_high_488
localset 2458 r0
label glass_lighting_done_483
localget r3 3030
cmp r3 0
jne body_lighting_done_489
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
jge diffuse_positive_491
set r0 0
label diffuse_positive_491
mul r0 128
div r0 16384
add r0 87
localset 2843 r0
mov r2 r0
mul r2 4
div r2 5
localset 2587 r2
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
jge highlight_positive_492
set r1 0
label highlight_positive_492
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2715 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -2808
localget r2 3007
mul r2 15981
add r1 r2
localget r2 3008
mul r2 2272
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_27
set r1 0
label fresnel_positive_27
cmp r1 16384
jle fresnel_bounded_27
set r1 16384
label fresnel_bounded_27
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2715
mul r2 168
div r2 16384
localget r1 2843
add r2 r1
cmp r2 255
jle metal_bounded_27
set r2 255
label metal_bounded_27
localset 2715 r2
cmp r0 255
jle intensity_bounded_493
set r0 255
label intensity_bounded_493
localset 2331 r0
localget r1 2843
mul r1 3
add r1 r0
div r1 4
localset 2843 r1
label body_lighting_done_489
localget r3 3030
cmp r3 0
jne glass_lighting_done_490
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
jge glass_low_494
set r0 0
label glass_low_494
cmp r0 255
jle glass_high_495
set r0 255
label glass_high_495
localset 2459 r0
label glass_lighting_done_490
localget r3 3030
cmp r3 0
jne body_lighting_done_496
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
jge diffuse_positive_498
set r0 0
label diffuse_positive_498
mul r0 128
div r0 16384
add r0 86
localset 2844 r0
mov r2 r0
mul r2 4
div r2 5
localset 2588 r2
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
jge highlight_positive_499
set r1 0
label highlight_positive_499
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2716 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -2008
localget r2 3007
mul r2 14844
add r1 r2
localget r2 3008
mul r2 6638
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_28
set r1 0
label fresnel_positive_28
cmp r1 16384
jle fresnel_bounded_28
set r1 16384
label fresnel_bounded_28
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2716
mul r2 168
div r2 16384
localget r1 2844
add r2 r1
cmp r2 255
jle metal_bounded_28
set r2 255
label metal_bounded_28
localset 2716 r2
cmp r0 255
jle intensity_bounded_500
set r0 255
label intensity_bounded_500
localset 2332 r0
localget r1 2844
mul r1 3
add r1 r0
div r1 4
localset 2844 r1
label body_lighting_done_496
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
jge glass_low_501
set r0 0
label glass_low_501
cmp r0 255
jle glass_high_502
set r0 255
label glass_high_502
localset 2460 r0
label glass_lighting_done_497
localget r3 3030
cmp r3 0
jne body_lighting_done_503
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
jge diffuse_positive_505
set r0 0
label diffuse_positive_505
mul r0 128
div r0 16384
add r0 87
localset 2845 r0
mov r2 r0
mul r2 4
div r2 5
localset 2589 r2
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
jge highlight_positive_506
set r1 0
label highlight_positive_506
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2717 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 3130
localget r2 3007
mul r2 15906
add r1 r2
localget r2 3008
mul r2 2376
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_29
set r1 0
label fresnel_positive_29
cmp r1 16384
jle fresnel_bounded_29
set r1 16384
label fresnel_bounded_29
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2717
mul r2 168
div r2 16384
localget r1 2845
add r2 r1
cmp r2 255
jle metal_bounded_29
set r2 255
label metal_bounded_29
localset 2717 r2
cmp r0 255
jle intensity_bounded_507
set r0 255
label intensity_bounded_507
localset 2333 r0
localget r1 2845
mul r1 3
add r1 r0
div r1 4
localset 2845 r1
label body_lighting_done_503
localget r3 3030
cmp r3 1
je body_lighting_done_508
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
jge diffuse_positive_510
set r0 0
label diffuse_positive_510
mul r0 128
div r0 16384
add r0 86
localset 2846 r0
mov r2 r0
mul r2 4
div r2 5
localset 2590 r2
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
jge highlight_positive_511
set r1 0
label highlight_positive_511
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2718 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 2076
localget r2 3007
mul r2 14806
add r1 r2
localget r2 3008
mul r2 6701
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_30
set r1 0
label fresnel_positive_30
cmp r1 16384
jle fresnel_bounded_30
set r1 16384
label fresnel_bounded_30
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2718
mul r2 168
div r2 16384
localget r1 2846
add r2 r1
cmp r2 255
jle metal_bounded_30
set r2 255
label metal_bounded_30
localset 2718 r2
cmp r0 255
jle intensity_bounded_512
set r0 255
label intensity_bounded_512
localset 2334 r0
localget r1 2846
mul r1 3
add r1 r0
div r1 4
localset 2846 r1
label body_lighting_done_508
localget r3 3030
cmp r3 2
je glass_lighting_done_509
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
jge glass_low_513
set r0 0
label glass_low_513
cmp r0 255
jle glass_high_514
set r0 255
label glass_high_514
localset 2462 r0
label glass_lighting_done_509
localget r3 3030
cmp r3 2
je body_lighting_done_515
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
jge diffuse_positive_517
set r0 0
label diffuse_positive_517
mul r0 128
div r0 16384
add r0 66
localset 2847 r0
mov r2 r0
mul r2 4
div r2 5
localset 2591 r2
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
jge highlight_positive_518
set r1 0
label highlight_positive_518
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2719 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -15833
localget r2 3007
mul r2 -66
add r1 r2
localget r2 3008
mul r2 4211
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_31
set r1 0
label fresnel_positive_31
cmp r1 16384
jle fresnel_bounded_31
set r1 16384
label fresnel_bounded_31
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2719
mul r2 168
div r2 16384
localget r1 2847
add r2 r1
cmp r2 255
jle metal_bounded_31
set r2 255
label metal_bounded_31
localset 2719 r2
cmp r0 255
jle intensity_bounded_519
set r0 255
label intensity_bounded_519
localset 2335 r0
localget r1 2847
mul r1 3
add r1 r0
div r1 4
localset 2847 r1
label body_lighting_done_515
localget r3 3030
cmp r3 2
je body_lighting_done_520
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
jge diffuse_positive_522
set r0 0
label diffuse_positive_522
mul r0 128
div r0 16384
add r0 66
localset 2848 r0
mov r2 r0
mul r2 4
div r2 5
localset 2592 r2
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
jge highlight_positive_523
set r1 0
label highlight_positive_523
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2720 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 15833
localget r2 3007
mul r2 -66
add r1 r2
localget r2 3008
mul r2 4211
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_32
set r1 0
label fresnel_positive_32
cmp r1 16384
jle fresnel_bounded_32
set r1 16384
label fresnel_bounded_32
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2720
mul r2 168
div r2 16384
localget r1 2848
add r2 r1
cmp r2 255
jle metal_bounded_32
set r2 255
label metal_bounded_32
localset 2720 r2
cmp r0 255
jle intensity_bounded_524
set r0 255
label intensity_bounded_524
localset 2336 r0
localget r1 2848
mul r1 3
add r1 r0
div r1 4
localset 2848 r1
label body_lighting_done_520
localget r3 3030
cmp r3 2
je body_lighting_done_525
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
jge diffuse_positive_527
set r0 0
label diffuse_positive_527
mul r0 128
div r0 16384
add r0 66
localset 2849 r0
mov r2 r0
mul r2 4
div r2 5
localset 2593 r2
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
jge highlight_positive_528
set r1 0
label highlight_positive_528
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2721 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 11
localget r2 3007
mul r2 127
add r1 r2
localget r2 3008
mul r2 16384
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_33
set r1 0
label fresnel_positive_33
cmp r1 16384
jle fresnel_bounded_33
set r1 16384
label fresnel_bounded_33
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2721
mul r2 168
div r2 16384
localget r1 2849
add r2 r1
cmp r2 255
jle metal_bounded_33
set r2 255
label metal_bounded_33
localset 2721 r2
cmp r0 255
jle intensity_bounded_529
set r0 255
label intensity_bounded_529
localset 2337 r0
localget r1 2849
mul r1 3
add r1 r0
div r1 4
localset 2849 r1
label body_lighting_done_525
localget r3 3030
cmp r3 0
jne body_lighting_done_530
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
jge diffuse_positive_532
set r0 0
label diffuse_positive_532
mul r0 128
div r0 16384
add r0 74
localset 2850 r0
mov r2 r0
mul r2 4
div r2 5
localset 2594 r2
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
jge highlight_positive_533
set r1 0
label highlight_positive_533
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2722 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -38
localget r2 3007
mul r2 5750
add r1 r2
localget r2 3008
mul r2 15342
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_34
set r1 0
label fresnel_positive_34
cmp r1 16384
jle fresnel_bounded_34
set r1 16384
label fresnel_bounded_34
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2722
mul r2 168
div r2 16384
localget r1 2850
add r2 r1
cmp r2 255
jle metal_bounded_34
set r2 255
label metal_bounded_34
localset 2722 r2
cmp r0 255
jle intensity_bounded_534
set r0 255
label intensity_bounded_534
localset 2338 r0
localget r1 2850
mul r1 3
add r1 r0
div r1 4
localset 2850 r1
label body_lighting_done_530
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
jge diffuse_positive_537
set r0 0
label diffuse_positive_537
mul r0 128
div r0 16384
add r0 66
localset 2851 r0
mov r2 r0
mul r2 4
div r2 5
localset 2595 r2
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
jge highlight_positive_538
set r1 0
label highlight_positive_538
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2723 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -6445
localget r2 3007
mul r2 0
add r1 r2
localget r2 3008
mul r2 15063
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_35
set r1 0
label fresnel_positive_35
cmp r1 16384
jle fresnel_bounded_35
set r1 16384
label fresnel_bounded_35
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2723
mul r2 168
div r2 16384
localget r1 2851
add r2 r1
cmp r2 255
jle metal_bounded_35
set r2 255
label metal_bounded_35
localset 2723 r2
cmp r0 255
jle intensity_bounded_539
set r0 255
label intensity_bounded_539
localset 2339 r0
localget r1 2851
mul r1 3
add r1 r0
div r1 4
localset 2851 r1
label body_lighting_done_535
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
jge diffuse_positive_542
set r0 0
label diffuse_positive_542
mul r0 128
div r0 16384
add r0 66
localset 2852 r0
mov r2 r0
mul r2 4
div r2 5
localset 2596 r2
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
jge highlight_positive_543
set r1 0
label highlight_positive_543
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2724 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 5670
localget r2 3007
mul r2 0
add r1 r2
localget r2 3008
mul r2 15372
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_36
set r1 0
label fresnel_positive_36
cmp r1 16384
jle fresnel_bounded_36
set r1 16384
label fresnel_bounded_36
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2724
mul r2 168
div r2 16384
localget r1 2852
add r2 r1
cmp r2 255
jle metal_bounded_36
set r2 255
label metal_bounded_36
localset 2724 r2
cmp r0 255
jle intensity_bounded_544
set r0 255
label intensity_bounded_544
localset 2340 r0
localget r1 2852
mul r1 3
add r1 r0
div r1 4
localset 2852 r1
label body_lighting_done_540
localget r3 3030
cmp r3 2
je body_lighting_done_545
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
jge diffuse_positive_547
set r0 0
label diffuse_positive_547
mul r0 128
div r0 16384
add r0 44
localset 2853 r0
mov r2 r0
mul r2 4
div r2 5
localset 2597 r2
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
jge highlight_positive_548
set r1 0
label highlight_positive_548
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2725 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 0
localget r2 3007
mul r2 -16383
add r1 r2
localget r2 3008
mul r2 158
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_37
set r1 0
label fresnel_positive_37
cmp r1 16384
jle fresnel_bounded_37
set r1 16384
label fresnel_bounded_37
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2725
mul r2 168
div r2 16384
localget r1 2853
add r2 r1
cmp r2 255
jle metal_bounded_37
set r2 255
label metal_bounded_37
localset 2725 r2
cmp r0 255
jle intensity_bounded_549
set r0 255
label intensity_bounded_549
localset 2341 r0
localget r1 2853
mul r1 3
add r1 r0
div r1 4
localset 2853 r1
label body_lighting_done_545
localget r3 3030
cmp r3 0
jne body_lighting_done_550
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
jge diffuse_positive_552
set r0 0
label diffuse_positive_552
mul r0 128
div r0 16384
add r0 87
localset 2854 r0
mov r2 r0
mul r2 4
div r2 5
localset 2598 r2
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
jge highlight_positive_553
set r1 0
label highlight_positive_553
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2726 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -1968
localget r2 3007
mul r2 15353
add r1 r2
localget r2 3008
mul r2 -5370
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_38
set r1 0
label fresnel_positive_38
cmp r1 16384
jle fresnel_bounded_38
set r1 16384
label fresnel_bounded_38
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2726
mul r2 168
div r2 16384
localget r1 2854
add r2 r1
cmp r2 255
jle metal_bounded_38
set r2 255
label metal_bounded_38
localset 2726 r2
cmp r0 255
jle intensity_bounded_554
set r0 255
label intensity_bounded_554
localset 2342 r0
localget r1 2854
mul r1 3
add r1 r0
div r1 4
localset 2854 r1
label body_lighting_done_550
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
jge glass_low_555
set r0 0
label glass_low_555
cmp r0 255
jle glass_high_556
set r0 255
label glass_high_556
localset 2470 r0
label glass_lighting_done_551
localget r3 3030
cmp r3 0
jne glass_lighting_done_558
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
jge glass_low_559
set r0 0
label glass_low_559
cmp r0 255
jle glass_high_560
set r0 255
label glass_high_560
localset 2471 r0
label glass_lighting_done_558
localget r3 3030
cmp r3 2
je glass_lighting_done_562
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
jge glass_low_563
set r0 0
label glass_low_563
cmp r0 255
jle glass_high_564
set r0 255
label glass_high_564
localset 2472 r0
label glass_lighting_done_562
localget r3 3030
cmp r3 2
je body_lighting_done_565
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
jge diffuse_positive_567
set r0 0
label diffuse_positive_567
mul r0 128
div r0 16384
add r0 47
localset 2857 r0
mov r2 r0
mul r2 4
div r2 5
localset 2601 r2
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
jge highlight_positive_568
set r1 0
label highlight_positive_568
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2729 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -3689
localget r2 3007
mul r2 -14118
add r1 r2
localget r2 3008
mul r2 -7449
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_41
set r1 0
label fresnel_positive_41
cmp r1 16384
jle fresnel_bounded_41
set r1 16384
label fresnel_bounded_41
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2729
mul r2 168
div r2 16384
localget r1 2857
add r2 r1
cmp r2 255
jle metal_bounded_41
set r2 255
label metal_bounded_41
localset 2729 r2
cmp r0 255
jle intensity_bounded_569
set r0 255
label intensity_bounded_569
localset 2345 r0
localget r1 2857
mul r1 3
add r1 r0
div r1 4
localset 2857 r1
label body_lighting_done_565
localget r3 3030
cmp r3 2
je body_lighting_done_570
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
jge diffuse_positive_572
set r0 0
label diffuse_positive_572
mul r0 128
div r0 16384
add r0 47
localset 2858 r0
mov r2 r0
mul r2 4
div r2 5
localset 2602 r2
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
jge highlight_positive_573
set r1 0
label highlight_positive_573
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2730 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 3689
localget r2 3007
mul r2 -14118
add r1 r2
localget r2 3008
mul r2 -7449
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_42
set r1 0
label fresnel_positive_42
cmp r1 16384
jle fresnel_bounded_42
set r1 16384
label fresnel_bounded_42
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2730
mul r2 168
div r2 16384
localget r1 2858
add r2 r1
cmp r2 255
jle metal_bounded_42
set r2 255
label metal_bounded_42
localset 2730 r2
cmp r0 255
jle intensity_bounded_574
set r0 255
label intensity_bounded_574
localset 2346 r0
localget r1 2858
mul r1 3
add r1 r0
div r1 4
localset 2858 r1
label body_lighting_done_570
localget r3 3030
cmp r3 1
je body_lighting_done_575
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
jge diffuse_positive_577
set r0 0
label diffuse_positive_577
mul r0 128
div r0 16384
add r0 82
localset 2859 r0
mov r2 r0
mul r2 4
div r2 5
localset 2603 r2
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
jge highlight_positive_578
set r1 0
label highlight_positive_578
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2731 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -2574
localget r2 3007
mul r2 12209
add r1 r2
localget r2 3008
mul r2 10619
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_43
set r1 0
label fresnel_positive_43
cmp r1 16384
jle fresnel_bounded_43
set r1 16384
label fresnel_bounded_43
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2731
mul r2 168
div r2 16384
localget r1 2859
add r2 r1
cmp r2 255
jle metal_bounded_43
set r2 255
label metal_bounded_43
localset 2731 r2
cmp r0 255
jle intensity_bounded_579
set r0 255
label intensity_bounded_579
localset 2347 r0
localget r1 2859
mul r1 3
add r1 r0
div r1 4
localset 2859 r1
label body_lighting_done_575
localget r3 3030
cmp r3 0
jne body_lighting_done_580
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
jge diffuse_positive_582
set r0 0
label diffuse_positive_582
mul r0 128
div r0 16384
add r0 83
localset 2860 r0
mov r2 r0
mul r2 4
div r2 5
localset 2604 r2
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
jge highlight_positive_583
set r1 0
label highlight_positive_583
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2732 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -2759
localget r2 3007
mul r2 12302
add r1 r2
localget r2 3008
mul r2 -10463
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_44
set r1 0
label fresnel_positive_44
cmp r1 16384
jle fresnel_bounded_44
set r1 16384
label fresnel_bounded_44
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2732
mul r2 168
div r2 16384
localget r1 2860
add r2 r1
cmp r2 255
jle metal_bounded_44
set r2 255
label metal_bounded_44
localset 2732 r2
cmp r0 255
jle intensity_bounded_584
set r0 255
label intensity_bounded_584
localset 2348 r0
localget r1 2860
mul r1 3
add r1 r0
div r1 4
localset 2860 r1
label body_lighting_done_580
localget r3 3030
cmp r3 0
jne body_lighting_done_585
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
jge diffuse_positive_587
set r0 0
label diffuse_positive_587
mul r0 128
div r0 16384
add r0 58
localset 2861 r0
mov r2 r0
mul r2 4
div r2 5
localset 2605 r2
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
jge highlight_positive_588
set r1 0
label highlight_positive_588
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2733 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 0
localget r2 3007
mul r2 -6070
add r1 r2
localget r2 3008
mul r2 -15218
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_45
set r1 0
label fresnel_positive_45
cmp r1 16384
jle fresnel_bounded_45
set r1 16384
label fresnel_bounded_45
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2733
mul r2 168
div r2 16384
localget r1 2861
add r2 r1
cmp r2 255
jle metal_bounded_45
set r2 255
label metal_bounded_45
localset 2733 r2
cmp r0 255
jle intensity_bounded_589
set r0 255
label intensity_bounded_589
localset 2349 r0
localget r1 2861
mul r1 3
add r1 r0
div r1 4
localset 2861 r1
label body_lighting_done_585
localget r3 3030
cmp r3 0
jne body_lighting_done_590
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
jge diffuse_positive_592
set r0 0
label diffuse_positive_592
mul r0 128
div r0 16384
add r0 52
localset 2862 r0
mov r2 r0
mul r2 4
div r2 5
localset 2606 r2
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
jge highlight_positive_593
set r1 0
label highlight_positive_593
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2734 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -2759
localget r2 3007
mul r2 -10463
add r1 r2
localget r2 3008
mul r2 -12302
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_46
set r1 0
label fresnel_positive_46
cmp r1 16384
jle fresnel_bounded_46
set r1 16384
label fresnel_bounded_46
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2734
mul r2 168
div r2 16384
localget r1 2862
add r2 r1
cmp r2 255
jle metal_bounded_46
set r2 255
label metal_bounded_46
localset 2734 r2
cmp r0 255
jle intensity_bounded_594
set r0 255
label intensity_bounded_594
localset 2350 r0
localget r1 2862
mul r1 3
add r1 r0
div r1 4
localset 2862 r1
label body_lighting_done_590
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
jge diffuse_positive_597
set r0 0
label diffuse_positive_597
mul r0 128
div r0 16384
add r0 50
localset 2863 r0
mov r2 r0
mul r2 4
div r2 5
localset 2607 r2
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
jge highlight_positive_598
set r1 0
label highlight_positive_598
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2735 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 0
localget r2 3007
mul r2 -11604
add r1 r2
localget r2 3008
mul r2 -11567
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_47
set r1 0
label fresnel_positive_47
cmp r1 16384
jle fresnel_bounded_47
set r1 16384
label fresnel_bounded_47
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2735
mul r2 168
div r2 16384
localget r1 2863
add r2 r1
cmp r2 255
jle metal_bounded_47
set r2 255
label metal_bounded_47
localset 2735 r2
cmp r0 255
jle intensity_bounded_599
set r0 255
label intensity_bounded_599
localset 2351 r0
localget r1 2863
mul r1 3
add r1 r0
div r1 4
localset 2863 r1
label body_lighting_done_595
localget r3 3030
cmp r3 0
jne body_lighting_done_600
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
jge diffuse_positive_602
set r0 0
label diffuse_positive_602
mul r0 128
div r0 16384
add r0 46
localset 2864 r0
mov r2 r0
mul r2 4
div r2 5
localset 2608 r2
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
jge highlight_positive_603
set r1 0
label highlight_positive_603
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2736 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 0
localget r2 3007
mul r2 -15122
add r1 r2
localget r2 3008
mul r2 -6305
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_48
set r1 0
label fresnel_positive_48
cmp r1 16384
jle fresnel_bounded_48
set r1 16384
label fresnel_bounded_48
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2736
mul r2 168
div r2 16384
localget r1 2864
add r2 r1
cmp r2 255
jle metal_bounded_48
set r2 255
label metal_bounded_48
localset 2736 r2
cmp r0 255
jle intensity_bounded_604
set r0 255
label intensity_bounded_604
localset 2352 r0
localget r1 2864
mul r1 3
add r1 r0
div r1 4
localset 2864 r1
label body_lighting_done_600
localget r3 3030
cmp r3 0
jne body_lighting_done_605
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
jge diffuse_positive_607
set r0 0
label diffuse_positive_607
mul r0 128
div r0 16384
add r0 46
localset 2865 r0
mov r2 r0
mul r2 4
div r2 5
localset 2609 r2
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
jge highlight_positive_608
set r1 0
label highlight_positive_608
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2737 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 0
localget r2 3007
mul r2 -15122
add r1 r2
localget r2 3008
mul r2 6305
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_49
set r1 0
label fresnel_positive_49
cmp r1 16384
jle fresnel_bounded_49
set r1 16384
label fresnel_bounded_49
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2737
mul r2 168
div r2 16384
localget r1 2865
add r2 r1
cmp r2 255
jle metal_bounded_49
set r2 255
label metal_bounded_49
localset 2737 r2
cmp r0 255
jle intensity_bounded_609
set r0 255
label intensity_bounded_609
localset 2353 r0
localget r1 2865
mul r1 3
add r1 r0
div r1 4
localset 2865 r1
label body_lighting_done_605
localget r3 3030
cmp r3 0
jne body_lighting_done_610
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
jge diffuse_positive_612
set r0 0
label diffuse_positive_612
mul r0 128
div r0 16384
add r0 49
localset 2866 r0
mov r2 r0
mul r2 4
div r2 5
localset 2610 r2
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
jge highlight_positive_613
set r1 0
label highlight_positive_613
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2738 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -2759
localget r2 3007
mul r2 -12302
add r1 r2
localget r2 3008
mul r2 10463
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_50
set r1 0
label fresnel_positive_50
cmp r1 16384
jle fresnel_bounded_50
set r1 16384
label fresnel_bounded_50
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2738
mul r2 168
div r2 16384
localget r1 2866
add r2 r1
cmp r2 255
jle metal_bounded_50
set r2 255
label metal_bounded_50
localset 2738 r2
cmp r0 255
jle intensity_bounded_614
set r0 255
label intensity_bounded_614
localset 2354 r0
localget r1 2866
mul r1 3
add r1 r0
div r1 4
localset 2866 r1
label body_lighting_done_610
localget r3 3030
cmp r3 0
jne body_lighting_done_615
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
jge diffuse_positive_617
set r0 0
label diffuse_positive_617
mul r0 128
div r0 16384
add r0 46
localset 2867 r0
mov r2 r0
mul r2 4
div r2 5
localset 2611 r2
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
jge highlight_positive_618
set r1 0
label highlight_positive_618
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2739 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -2700
localget r2 3007
mul r2 -15190
add r1 r2
localget r2 3008
mul r2 5514
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_51
set r1 0
label fresnel_positive_51
cmp r1 16384
jle fresnel_bounded_51
set r1 16384
label fresnel_bounded_51
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2739
mul r2 168
div r2 16384
localget r1 2867
add r2 r1
cmp r2 255
jle metal_bounded_51
set r2 255
label metal_bounded_51
localset 2739 r2
cmp r0 255
jle intensity_bounded_619
set r0 255
label intensity_bounded_619
localset 2355 r0
localget r1 2867
mul r1 3
add r1 r0
div r1 4
localset 2867 r1
label body_lighting_done_615
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
jge diffuse_positive_622
set r0 0
label diffuse_positive_622
mul r0 128
div r0 16384
add r0 50
localset 2868 r0
mov r2 r0
mul r2 4
div r2 5
localset 2612 r2
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
jge highlight_positive_623
set r1 0
label highlight_positive_623
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2740 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 0
localget r2 3007
mul r2 -11567
add r1 r2
localget r2 3008
mul r2 11604
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_52
set r1 0
label fresnel_positive_52
cmp r1 16384
jle fresnel_bounded_52
set r1 16384
label fresnel_bounded_52
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2740
mul r2 168
div r2 16384
localget r1 2868
add r2 r1
cmp r2 255
jle metal_bounded_52
set r2 255
label metal_bounded_52
localset 2740 r2
cmp r0 255
jle intensity_bounded_624
set r0 255
label intensity_bounded_624
localset 2356 r0
localget r1 2868
mul r1 3
add r1 r0
div r1 4
localset 2868 r1
label body_lighting_done_620
localget r3 3030
cmp r3 0
jne body_lighting_done_625
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
jge diffuse_positive_627
set r0 0
label diffuse_positive_627
mul r0 128
div r0 16384
add r0 58
localset 2869 r0
mov r2 r0
mul r2 4
div r2 5
localset 2613 r2
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
jge highlight_positive_628
set r1 0
label highlight_positive_628
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2741 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 0
localget r2 3007
mul r2 -6305
add r1 r2
localget r2 3008
mul r2 15122
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_53
set r1 0
label fresnel_positive_53
cmp r1 16384
jle fresnel_bounded_53
set r1 16384
label fresnel_bounded_53
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2741
mul r2 168
div r2 16384
localget r1 2869
add r2 r1
cmp r2 255
jle metal_bounded_53
set r2 255
label metal_bounded_53
localset 2741 r2
cmp r0 255
jle intensity_bounded_629
set r0 255
label intensity_bounded_629
localset 2357 r0
localget r1 2869
mul r1 3
add r1 r0
div r1 4
localset 2869 r1
label body_lighting_done_625
localget r3 3030
cmp r3 0
jne body_lighting_done_630
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
jge diffuse_positive_632
set r0 0
label diffuse_positive_632
mul r0 128
div r0 16384
add r0 75
localset 2870 r0
mov r2 r0
mul r2 4
div r2 5
localset 2614 r2
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
jge highlight_positive_633
set r1 0
label highlight_positive_633
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2742 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -10412
localget r2 3007
mul r2 6869
add r1 r2
localget r2 3008
mul r2 10622
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_54
set r1 0
label fresnel_positive_54
cmp r1 16384
jle fresnel_bounded_54
set r1 16384
label fresnel_bounded_54
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2742
mul r2 168
div r2 16384
localget r1 2870
add r2 r1
cmp r2 255
jle metal_bounded_54
set r2 255
label metal_bounded_54
localset 2742 r2
cmp r0 255
jle intensity_bounded_634
set r0 255
label intensity_bounded_634
localset 2358 r0
localget r1 2870
mul r1 3
add r1 r0
div r1 4
localset 2870 r1
label body_lighting_done_630
localget r3 3030
cmp r3 0
jne body_lighting_done_635
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
jge diffuse_positive_637
set r0 0
label diffuse_positive_637
mul r0 128
div r0 16384
add r0 79
localset 2871 r0
mov r2 r0
mul r2 4
div r2 5
localset 2615 r2
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
jge highlight_positive_638
set r1 0
label highlight_positive_638
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2743 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -12050
localget r2 3007
mul r2 9611
add r1 r2
localget r2 3008
mul r2 -5555
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_55
set r1 0
label fresnel_positive_55
cmp r1 16384
jle fresnel_bounded_55
set r1 16384
label fresnel_bounded_55
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2743
mul r2 168
div r2 16384
localget r1 2871
add r2 r1
cmp r2 255
jle metal_bounded_55
set r2 255
label metal_bounded_55
localset 2743 r2
cmp r0 255
jle intensity_bounded_639
set r0 255
label intensity_bounded_639
localset 2359 r0
localget r1 2871
mul r1 3
add r1 r0
div r1 4
localset 2871 r1
label body_lighting_done_635
localget r3 3030
cmp r3 0
jne body_lighting_done_640
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
jge diffuse_positive_642
set r0 0
label diffuse_positive_642
mul r0 128
div r0 16384
add r0 81
localset 2872 r0
mov r2 r0
mul r2 4
div r2 5
localset 2616 r2
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
jge highlight_positive_643
set r1 0
label highlight_positive_643
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2744 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -8564
localget r2 3007
mul r2 11418
add r1 r2
localget r2 3008
mul r2 -8045
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_56
set r1 0
label fresnel_positive_56
cmp r1 16384
jle fresnel_bounded_56
set r1 16384
label fresnel_bounded_56
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2744
mul r2 168
div r2 16384
localget r1 2872
add r2 r1
cmp r2 255
jle metal_bounded_56
set r2 255
label metal_bounded_56
localset 2744 r2
cmp r0 255
jle intensity_bounded_644
set r0 255
label intensity_bounded_644
localset 2360 r0
localget r1 2872
mul r1 3
add r1 r0
div r1 4
localset 2872 r1
label body_lighting_done_640
localget r3 3030
cmp r3 0
jne body_lighting_done_645
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
jge diffuse_positive_647
set r0 0
label diffuse_positive_647
mul r0 128
div r0 16384
add r0 75
localset 2873 r0
mov r2 r0
mul r2 4
div r2 5
localset 2617 r2
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
jge highlight_positive_648
set r1 0
label highlight_positive_648
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2745 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -11892
localget r2 3007
mul r2 6396
add r1 r2
localget r2 3008
mul r2 -9279
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_57
set r1 0
label fresnel_positive_57
cmp r1 16384
jle fresnel_bounded_57
set r1 16384
label fresnel_bounded_57
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2745
mul r2 168
div r2 16384
localget r1 2873
add r2 r1
cmp r2 255
jle metal_bounded_57
set r2 255
label metal_bounded_57
localset 2745 r2
cmp r0 255
jle intensity_bounded_649
set r0 255
label intensity_bounded_649
localset 2361 r0
localget r1 2873
mul r1 3
add r1 r0
div r1 4
localset 2873 r1
label body_lighting_done_645
localget r3 3030
cmp r3 0
jne body_lighting_done_650
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
jge diffuse_positive_652
set r0 0
label diffuse_positive_652
mul r0 128
div r0 16384
add r0 57
localset 2874 r0
mov r2 r0
mul r2 4
div r2 5
localset 2618 r2
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
jge highlight_positive_653
set r1 0
label highlight_positive_653
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2746 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -10412
localget r2 3007
mul r2 -6869
add r1 r2
localget r2 3008
mul r2 -10622
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_58
set r1 0
label fresnel_positive_58
cmp r1 16384
jle fresnel_bounded_58
set r1 16384
label fresnel_bounded_58
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2746
mul r2 168
div r2 16384
localget r1 2874
add r2 r1
cmp r2 255
jle metal_bounded_58
set r2 255
label metal_bounded_58
localset 2746 r2
cmp r0 255
jle intensity_bounded_654
set r0 255
label intensity_bounded_654
localset 2362 r0
localget r1 2874
mul r1 3
add r1 r0
div r1 4
localset 2874 r1
label body_lighting_done_650
localget r3 3030
cmp r3 0
jne body_lighting_done_655
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
jge diffuse_positive_657
set r0 0
label diffuse_positive_657
mul r0 128
div r0 16384
add r0 54
localset 2875 r0
mov r2 r0
mul r2 4
div r2 5
localset 2619 r2
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
jge highlight_positive_658
set r1 0
label highlight_positive_658
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2747 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -11892
localget r2 3007
mul r2 -9279
add r1 r2
localget r2 3008
mul r2 -6396
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_59
set r1 0
label fresnel_positive_59
cmp r1 16384
jle fresnel_bounded_59
set r1 16384
label fresnel_bounded_59
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2747
mul r2 168
div r2 16384
localget r1 2875
add r2 r1
cmp r2 255
jle metal_bounded_59
set r2 255
label metal_bounded_59
localset 2747 r2
cmp r0 255
jle intensity_bounded_659
set r0 255
label intensity_bounded_659
localset 2363 r0
localget r1 2875
mul r1 3
add r1 r0
div r1 4
localset 2875 r1
label body_lighting_done_655
localget r3 3030
cmp r3 0
jne body_lighting_done_660
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
jge diffuse_positive_662
set r0 0
label diffuse_positive_662
mul r0 128
div r0 16384
add r0 61
localset 2876 r0
mov r2 r0
mul r2 4
div r2 5
localset 2620 r2
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
jge highlight_positive_663
set r1 0
label highlight_positive_663
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2748 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -15907
localget r2 3007
mul r2 -3923
add r1 r2
localget r2 3008
mul r2 -55
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_60
set r1 0
label fresnel_positive_60
cmp r1 16384
jle fresnel_bounded_60
set r1 16384
label fresnel_bounded_60
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2748
mul r2 168
div r2 16384
localget r1 2876
add r2 r1
cmp r2 255
jle metal_bounded_60
set r2 255
label metal_bounded_60
localset 2748 r2
cmp r0 255
jle intensity_bounded_664
set r0 255
label intensity_bounded_664
localset 2364 r0
localget r1 2876
mul r1 3
add r1 r0
div r1 4
localset 2876 r1
label body_lighting_done_660
localget r3 3030
cmp r3 0
jne body_lighting_done_665
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
jge diffuse_positive_667
set r0 0
label diffuse_positive_667
mul r0 128
div r0 16384
add r0 53
localset 2877 r0
mov r2 r0
mul r2 4
div r2 5
localset 2621 r2
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
jge highlight_positive_668
set r1 0
label highlight_positive_668
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2749 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -12050
localget r2 3007
mul r2 -9611
add r1 r2
localget r2 3008
mul r2 5555
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_61
set r1 0
label fresnel_positive_61
cmp r1 16384
jle fresnel_bounded_61
set r1 16384
label fresnel_bounded_61
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2749
mul r2 168
div r2 16384
localget r1 2877
add r2 r1
cmp r2 255
jle metal_bounded_61
set r2 255
label metal_bounded_61
localset 2749 r2
cmp r0 255
jle intensity_bounded_669
set r0 255
label intensity_bounded_669
localset 2365 r0
localget r1 2877
mul r1 3
add r1 r0
div r1 4
localset 2877 r1
label body_lighting_done_665
localget r3 3030
cmp r3 0
jne body_lighting_done_670
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
jge diffuse_positive_672
set r0 0
label diffuse_positive_672
mul r0 128
div r0 16384
add r0 51
localset 2878 r0
mov r2 r0
mul r2 4
div r2 5
localset 2622 r2
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
jge highlight_positive_673
set r1 0
label highlight_positive_673
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2750 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -8564
localget r2 3007
mul r2 -11418
add r1 r2
localget r2 3008
mul r2 8045
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_62
set r1 0
label fresnel_positive_62
cmp r1 16384
jle fresnel_bounded_62
set r1 16384
label fresnel_bounded_62
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2750
mul r2 168
div r2 16384
localget r1 2878
add r2 r1
cmp r2 255
jle metal_bounded_62
set r2 255
label metal_bounded_62
localset 2750 r2
cmp r0 255
jle intensity_bounded_674
set r0 255
label intensity_bounded_674
localset 2366 r0
localget r1 2878
mul r1 3
add r1 r0
div r1 4
localset 2878 r1
label body_lighting_done_670
localget r3 3030
cmp r3 0
jne body_lighting_done_675
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
jge diffuse_positive_677
set r0 0
label diffuse_positive_677
mul r0 128
div r0 16384
add r0 57
localset 2879 r0
mov r2 r0
mul r2 4
div r2 5
localset 2623 r2
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
jge highlight_positive_678
set r1 0
label highlight_positive_678
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2751 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -11892
localget r2 3007
mul r2 -6396
add r1 r2
localget r2 3008
mul r2 9279
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_63
set r1 0
label fresnel_positive_63
cmp r1 16384
jle fresnel_bounded_63
set r1 16384
label fresnel_bounded_63
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2751
mul r2 168
div r2 16384
localget r1 2879
add r2 r1
cmp r2 255
jle metal_bounded_63
set r2 255
label metal_bounded_63
localset 2751 r2
cmp r0 255
jle intensity_bounded_679
set r0 255
label intensity_bounded_679
localset 2367 r0
localget r1 2879
mul r1 3
add r1 r0
div r1 4
localset 2879 r1
label body_lighting_done_675
localget r3 3030
cmp r3 0
jne body_lighting_done_680
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
jge diffuse_positive_682
set r0 0
label diffuse_positive_682
mul r0 128
div r0 16384
add r0 83
localset 2880 r0
mov r2 r0
mul r2 4
div r2 5
localset 2624 r2
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
jge highlight_positive_683
set r1 0
label highlight_positive_683
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2752 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 2343
localget r2 3007
mul r2 12417
add r1 r2
localget r2 3008
mul r2 10429
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_64
set r1 0
label fresnel_positive_64
cmp r1 16384
jle fresnel_bounded_64
set r1 16384
label fresnel_bounded_64
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2752
mul r2 168
div r2 16384
localget r1 2880
add r2 r1
cmp r2 255
jle metal_bounded_64
set r2 255
label metal_bounded_64
localset 2752 r2
cmp r0 255
jle intensity_bounded_684
set r0 255
label intensity_bounded_684
localset 2368 r0
localget r1 2880
mul r1 3
add r1 r0
div r1 4
localset 2880 r1
label body_lighting_done_680
localget r3 3030
cmp r3 0
jne body_lighting_done_685
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
jge diffuse_positive_687
set r0 0
label diffuse_positive_687
mul r0 128
div r0 16384
add r0 83
localset 2881 r0
mov r2 r0
mul r2 4
div r2 5
localset 2625 r2
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
jge highlight_positive_688
set r1 0
label highlight_positive_688
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2753 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 2759
localget r2 3007
mul r2 12302
add r1 r2
localget r2 3008
mul r2 -10463
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_65
set r1 0
label fresnel_positive_65
cmp r1 16384
jle fresnel_bounded_65
set r1 16384
label fresnel_bounded_65
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2753
mul r2 168
div r2 16384
localget r1 2881
add r2 r1
cmp r2 255
jle metal_bounded_65
set r2 255
label metal_bounded_65
localset 2753 r2
cmp r0 255
jle intensity_bounded_689
set r0 255
label intensity_bounded_689
localset 2369 r0
localget r1 2881
mul r1 3
add r1 r0
div r1 4
localset 2881 r1
label body_lighting_done_685
localget r3 3030
cmp r3 0
jne body_lighting_done_690
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
jge diffuse_positive_692
set r0 0
label diffuse_positive_692
mul r0 128
div r0 16384
add r0 52
localset 2882 r0
mov r2 r0
mul r2 4
div r2 5
localset 2626 r2
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
jge highlight_positive_693
set r1 0
label highlight_positive_693
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2754 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 2759
localget r2 3007
mul r2 -10463
add r1 r2
localget r2 3008
mul r2 -12302
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_66
set r1 0
label fresnel_positive_66
cmp r1 16384
jle fresnel_bounded_66
set r1 16384
label fresnel_bounded_66
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2754
mul r2 168
div r2 16384
localget r1 2882
add r2 r1
cmp r2 255
jle metal_bounded_66
set r2 255
label metal_bounded_66
localset 2754 r2
cmp r0 255
jle intensity_bounded_694
set r0 255
label intensity_bounded_694
localset 2370 r0
localget r1 2882
mul r1 3
add r1 r0
div r1 4
localset 2882 r1
label body_lighting_done_690
localget r3 3030
cmp r3 0
jne body_lighting_done_695
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
jge diffuse_positive_697
set r0 0
label diffuse_positive_697
mul r0 128
div r0 16384
add r0 46
localset 2883 r0
mov r2 r0
mul r2 4
div r2 5
localset 2627 r2
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
jge highlight_positive_698
set r1 0
label highlight_positive_698
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2755 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 2700
localget r2 3007
mul r2 -15190
add r1 r2
localget r2 3008
mul r2 5514
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_67
set r1 0
label fresnel_positive_67
cmp r1 16384
jle fresnel_bounded_67
set r1 16384
label fresnel_bounded_67
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2755
mul r2 168
div r2 16384
localget r1 2883
add r2 r1
cmp r2 255
jle metal_bounded_67
set r2 255
label metal_bounded_67
localset 2755 r2
cmp r0 255
jle intensity_bounded_699
set r0 255
label intensity_bounded_699
localset 2371 r0
localget r1 2883
mul r1 3
add r1 r0
div r1 4
localset 2883 r1
label body_lighting_done_695
localget r3 3030
cmp r3 0
jne body_lighting_done_700
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
jge diffuse_positive_702
set r0 0
label diffuse_positive_702
mul r0 128
div r0 16384
add r0 49
localset 2884 r0
mov r2 r0
mul r2 4
div r2 5
localset 2628 r2
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
jge highlight_positive_703
set r1 0
label highlight_positive_703
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2756 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 2759
localget r2 3007
mul r2 -12302
add r1 r2
localget r2 3008
mul r2 10463
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_68
set r1 0
label fresnel_positive_68
cmp r1 16384
jle fresnel_bounded_68
set r1 16384
label fresnel_bounded_68
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2756
mul r2 168
div r2 16384
localget r1 2884
add r2 r1
cmp r2 255
jle metal_bounded_68
set r2 255
label metal_bounded_68
localset 2756 r2
cmp r0 255
jle intensity_bounded_704
set r0 255
label intensity_bounded_704
localset 2372 r0
localget r1 2884
mul r1 3
add r1 r0
div r1 4
localset 2884 r1
label body_lighting_done_700
localget r3 3030
cmp r3 0
jne body_lighting_done_705
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
jge diffuse_positive_707
set r0 0
label diffuse_positive_707
mul r0 128
div r0 16384
add r0 75
localset 2885 r0
mov r2 r0
mul r2 4
div r2 5
localset 2629 r2
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
jge highlight_positive_708
set r1 0
label highlight_positive_708
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2757 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 10412
localget r2 3007
mul r2 6869
add r1 r2
localget r2 3008
mul r2 10622
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_69
set r1 0
label fresnel_positive_69
cmp r1 16384
jle fresnel_bounded_69
set r1 16384
label fresnel_bounded_69
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2757
mul r2 168
div r2 16384
localget r1 2885
add r2 r1
cmp r2 255
jle metal_bounded_69
set r2 255
label metal_bounded_69
localset 2757 r2
cmp r0 255
jle intensity_bounded_709
set r0 255
label intensity_bounded_709
localset 2373 r0
localget r1 2885
mul r1 3
add r1 r0
div r1 4
localset 2885 r1
label body_lighting_done_705
localget r3 3030
cmp r3 0
jne body_lighting_done_710
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
jge diffuse_positive_712
set r0 0
label diffuse_positive_712
mul r0 128
div r0 16384
add r0 79
localset 2886 r0
mov r2 r0
mul r2 4
div r2 5
localset 2630 r2
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
jge highlight_positive_713
set r1 0
label highlight_positive_713
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2758 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 12050
localget r2 3007
mul r2 9611
add r1 r2
localget r2 3008
mul r2 -5555
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_70
set r1 0
label fresnel_positive_70
cmp r1 16384
jle fresnel_bounded_70
set r1 16384
label fresnel_bounded_70
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2758
mul r2 168
div r2 16384
localget r1 2886
add r2 r1
cmp r2 255
jle metal_bounded_70
set r2 255
label metal_bounded_70
localset 2758 r2
cmp r0 255
jle intensity_bounded_714
set r0 255
label intensity_bounded_714
localset 2374 r0
localget r1 2886
mul r1 3
add r1 r0
div r1 4
localset 2886 r1
label body_lighting_done_710
localget r3 3030
cmp r3 0
jne body_lighting_done_715
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
jge diffuse_positive_717
set r0 0
label diffuse_positive_717
mul r0 128
div r0 16384
add r0 81
localset 2887 r0
mov r2 r0
mul r2 4
div r2 5
localset 2631 r2
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
jge highlight_positive_718
set r1 0
label highlight_positive_718
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2759 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 8564
localget r2 3007
mul r2 11418
add r1 r2
localget r2 3008
mul r2 -8045
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_71
set r1 0
label fresnel_positive_71
cmp r1 16384
jle fresnel_bounded_71
set r1 16384
label fresnel_bounded_71
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2759
mul r2 168
div r2 16384
localget r1 2887
add r2 r1
cmp r2 255
jle metal_bounded_71
set r2 255
label metal_bounded_71
localset 2759 r2
cmp r0 255
jle intensity_bounded_719
set r0 255
label intensity_bounded_719
localset 2375 r0
localget r1 2887
mul r1 3
add r1 r0
div r1 4
localset 2887 r1
label body_lighting_done_715
localget r3 3030
cmp r3 0
jne body_lighting_done_720
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
jge diffuse_positive_722
set r0 0
label diffuse_positive_722
mul r0 128
div r0 16384
add r0 75
localset 2888 r0
mov r2 r0
mul r2 4
div r2 5
localset 2632 r2
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
jge highlight_positive_723
set r1 0
label highlight_positive_723
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2760 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 11892
localget r2 3007
mul r2 6396
add r1 r2
localget r2 3008
mul r2 -9279
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_72
set r1 0
label fresnel_positive_72
cmp r1 16384
jle fresnel_bounded_72
set r1 16384
label fresnel_bounded_72
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2760
mul r2 168
div r2 16384
localget r1 2888
add r2 r1
cmp r2 255
jle metal_bounded_72
set r2 255
label metal_bounded_72
localset 2760 r2
cmp r0 255
jle intensity_bounded_724
set r0 255
label intensity_bounded_724
localset 2376 r0
localget r1 2888
mul r1 3
add r1 r0
div r1 4
localset 2888 r1
label body_lighting_done_720
localget r3 3030
cmp r3 0
jne body_lighting_done_725
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
jge diffuse_positive_727
set r0 0
label diffuse_positive_727
mul r0 128
div r0 16384
add r0 57
localset 2889 r0
mov r2 r0
mul r2 4
div r2 5
localset 2633 r2
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
jge highlight_positive_728
set r1 0
label highlight_positive_728
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2761 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 10412
localget r2 3007
mul r2 -6869
add r1 r2
localget r2 3008
mul r2 -10622
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_73
set r1 0
label fresnel_positive_73
cmp r1 16384
jle fresnel_bounded_73
set r1 16384
label fresnel_bounded_73
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2761
mul r2 168
div r2 16384
localget r1 2889
add r2 r1
cmp r2 255
jle metal_bounded_73
set r2 255
label metal_bounded_73
localset 2761 r2
cmp r0 255
jle intensity_bounded_729
set r0 255
label intensity_bounded_729
localset 2377 r0
localget r1 2889
mul r1 3
add r1 r0
div r1 4
localset 2889 r1
label body_lighting_done_725
localget r3 3030
cmp r3 0
jne body_lighting_done_730
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
jge diffuse_positive_732
set r0 0
label diffuse_positive_732
mul r0 128
div r0 16384
add r0 54
localset 2890 r0
mov r2 r0
mul r2 4
div r2 5
localset 2634 r2
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
jge highlight_positive_733
set r1 0
label highlight_positive_733
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2762 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 11892
localget r2 3007
mul r2 -9279
add r1 r2
localget r2 3008
mul r2 -6396
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_74
set r1 0
label fresnel_positive_74
cmp r1 16384
jle fresnel_bounded_74
set r1 16384
label fresnel_bounded_74
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2762
mul r2 168
div r2 16384
localget r1 2890
add r2 r1
cmp r2 255
jle metal_bounded_74
set r2 255
label metal_bounded_74
localset 2762 r2
cmp r0 255
jle intensity_bounded_734
set r0 255
label intensity_bounded_734
localset 2378 r0
localget r1 2890
mul r1 3
add r1 r0
div r1 4
localset 2890 r1
label body_lighting_done_730
localget r3 3030
cmp r3 0
jne body_lighting_done_735
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
jge diffuse_positive_737
set r0 0
label diffuse_positive_737
mul r0 128
div r0 16384
add r0 61
localset 2891 r0
mov r2 r0
mul r2 4
div r2 5
localset 2635 r2
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
jge highlight_positive_738
set r1 0
label highlight_positive_738
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2763 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 15907
localget r2 3007
mul r2 -3923
add r1 r2
localget r2 3008
mul r2 -55
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_75
set r1 0
label fresnel_positive_75
cmp r1 16384
jle fresnel_bounded_75
set r1 16384
label fresnel_bounded_75
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2763
mul r2 168
div r2 16384
localget r1 2891
add r2 r1
cmp r2 255
jle metal_bounded_75
set r2 255
label metal_bounded_75
localset 2763 r2
cmp r0 255
jle intensity_bounded_739
set r0 255
label intensity_bounded_739
localset 2379 r0
localget r1 2891
mul r1 3
add r1 r0
div r1 4
localset 2891 r1
label body_lighting_done_735
localget r3 3030
cmp r3 0
jne body_lighting_done_740
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
jge diffuse_positive_742
set r0 0
label diffuse_positive_742
mul r0 128
div r0 16384
add r0 53
localset 2892 r0
mov r2 r0
mul r2 4
div r2 5
localset 2636 r2
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
jge highlight_positive_743
set r1 0
label highlight_positive_743
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2764 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 12050
localget r2 3007
mul r2 -9611
add r1 r2
localget r2 3008
mul r2 5555
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_76
set r1 0
label fresnel_positive_76
cmp r1 16384
jle fresnel_bounded_76
set r1 16384
label fresnel_bounded_76
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2764
mul r2 168
div r2 16384
localget r1 2892
add r2 r1
cmp r2 255
jle metal_bounded_76
set r2 255
label metal_bounded_76
localset 2764 r2
cmp r0 255
jle intensity_bounded_744
set r0 255
label intensity_bounded_744
localset 2380 r0
localget r1 2892
mul r1 3
add r1 r0
div r1 4
localset 2892 r1
label body_lighting_done_740
localget r3 3030
cmp r3 0
jne body_lighting_done_745
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
jge diffuse_positive_747
set r0 0
label diffuse_positive_747
mul r0 128
div r0 16384
add r0 51
localset 2893 r0
mov r2 r0
mul r2 4
div r2 5
localset 2637 r2
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
jge highlight_positive_748
set r1 0
label highlight_positive_748
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2765 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 8564
localget r2 3007
mul r2 -11418
add r1 r2
localget r2 3008
mul r2 8045
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_77
set r1 0
label fresnel_positive_77
cmp r1 16384
jle fresnel_bounded_77
set r1 16384
label fresnel_bounded_77
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2765
mul r2 168
div r2 16384
localget r1 2893
add r2 r1
cmp r2 255
jle metal_bounded_77
set r2 255
label metal_bounded_77
localset 2765 r2
cmp r0 255
jle intensity_bounded_749
set r0 255
label intensity_bounded_749
localset 2381 r0
localget r1 2893
mul r1 3
add r1 r0
div r1 4
localset 2893 r1
label body_lighting_done_745
localget r3 3030
cmp r3 0
jne body_lighting_done_750
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
jge diffuse_positive_752
set r0 0
label diffuse_positive_752
mul r0 128
div r0 16384
add r0 57
localset 2894 r0
mov r2 r0
mul r2 4
div r2 5
localset 2638 r2
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
jge highlight_positive_753
set r1 0
label highlight_positive_753
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2766 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 11892
localget r2 3007
mul r2 -6396
add r1 r2
localget r2 3008
mul r2 9279
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_78
set r1 0
label fresnel_positive_78
cmp r1 16384
jle fresnel_bounded_78
set r1 16384
label fresnel_bounded_78
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2766
mul r2 168
div r2 16384
localget r1 2894
add r2 r1
cmp r2 255
jle metal_bounded_78
set r2 255
label metal_bounded_78
localset 2766 r2
cmp r0 255
jle intensity_bounded_754
set r0 255
label intensity_bounded_754
localset 2382 r0
localget r1 2894
mul r1 3
add r1 r0
div r1 4
localset 2894 r1
label body_lighting_done_750
localget r3 3030
cmp r3 2
jne body_lighting_done_755
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
jge diffuse_positive_757
set r0 0
label diffuse_positive_757
mul r0 128
div r0 16384
add r0 66
localset 2895 r0
mov r2 r0
mul r2 4
div r2 5
localset 2639 r2
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
jge highlight_positive_758
set r1 0
label highlight_positive_758
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2767 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -11211
localget r2 3007
mul r2 0
add r1 r2
localget r2 3008
mul r2 11948
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_79
set r1 0
label fresnel_positive_79
cmp r1 16384
jle fresnel_bounded_79
set r1 16384
label fresnel_bounded_79
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2767
mul r2 168
div r2 16384
localget r1 2895
add r2 r1
cmp r2 255
jle metal_bounded_79
set r2 255
label metal_bounded_79
localset 2767 r2
cmp r0 255
jle intensity_bounded_759
set r0 255
label intensity_bounded_759
localset 2383 r0
localget r1 2895
mul r1 3
add r1 r0
div r1 4
localset 2895 r1
label body_lighting_done_755
localget r3 3030
cmp r3 2
jne body_lighting_done_762
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
jge diffuse_positive_764
set r0 0
label diffuse_positive_764
mul r0 128
div r0 16384
add r0 66
localset 2897 r0
mov r2 r0
mul r2 4
div r2 5
localset 2641 r2
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
jge highlight_positive_765
set r1 0
label highlight_positive_765
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2769 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 11794
localget r2 3007
mul r2 0
add r1 r2
localget r2 3008
mul r2 11373
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_81
set r1 0
label fresnel_positive_81
cmp r1 16384
jle fresnel_bounded_81
set r1 16384
label fresnel_bounded_81
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2769
mul r2 168
div r2 16384
localget r1 2897
add r2 r1
cmp r2 255
jle metal_bounded_81
set r2 255
label metal_bounded_81
localset 2769 r2
cmp r0 255
jle intensity_bounded_766
set r0 255
label intensity_bounded_766
localset 2385 r0
localget r1 2897
mul r1 3
add r1 r0
div r1 4
localset 2897 r1
label body_lighting_done_762
localget r3 3030
cmp r3 1
jne body_lighting_done_769
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
jge diffuse_positive_771
set r0 0
label diffuse_positive_771
mul r0 128
div r0 16384
add r0 78
localset 2899 r0
mov r2 r0
mul r2 4
div r2 5
localset 2643 r2
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
jge highlight_positive_772
set r1 0
label highlight_positive_772
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
localset 2771 r1
mul r1 r1
div r1 16384
mul r1 r1
div r1 16384
mul r1 104
div r1 16384
add r0 r1
localget r1 3006
mul r1 -3028
localget r2 3007
mul r2 9083
add r1 r2
localget r2 3008
mul r2 13295
add r1 r2
div r1 16384
cmp r1 0
jge fresnel_positive_83
set r1 0
label fresnel_positive_83
cmp r1 16384
jle fresnel_bounded_83
set r1 16384
label fresnel_bounded_83
set r2 16384
sub r2 r1
mov r1 r2
mul r1 r2
div r1 16384
mul r1 r2
div r1 16384
mul r1 36
div r1 16384
add r0 r1
localget r2 2771
mul r2 168
div r2 16384
localget r1 2899
add r2 r1
cmp r2 255
jle metal_bounded_83
set r2 255
label metal_bounded_83
localset 2771 r2
cmp r0 255
jle intensity_bounded_773
set r0 255
label intensity_bounded_773
localset 2387 r0
localget r1 2899
mul r1 3
add r1 r0
div r1 4
localset 2899 r1
label body_lighting_done_769
label lighting_table_ready
localget r0 11
cmp r0 4
jlt open_forest_lod_ready
cmp r0 124
jge open_forest_lod_ready
mod r0 10
cmp r0 7
jge open_forest_lod_ready
localget r0 112
sub r0 1000000
cmp r0 12000
jle open_forest_lod_ready
localset 134 1558
label open_forest_lod_ready
localget r0 11
cmp r0 4
jge wheel_motion_ready
localget r0 142
cmp r0 2
je wheel_motion_ready
localget r0 11
cmp r0 0
jne wheel_rival_distance
load16 r0 498
jmp wheel_phase_ready
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
label wheel_phase_ready
mov r5 r0
add r5 0
mod r5 4096
cmp r5 0
jge sin_negative_774
add r5 4096
label sin_negative_774
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
jlt sin_done_775
mul r7 -1
label sin_done_775
mov r5 r7
mov r8 r5
mov r9 r8
add r9 32768
localset 58 r9
mov r6 r0
add r6 1024
mod r6 4096
cmp r6 0
jge sin_negative_776
add r6 4096
label sin_negative_776
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
jlt sin_done_777
mul r7 -1
label sin_done_777
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
jge sin_negative_778
add r5 4096
label sin_negative_778
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
jlt sin_done_779
mul r7 -1
label sin_done_779
mov r5 r7
mov r8 r5
mov r9 r8
add r9 32768
localset 58 r9
mov r6 r0
add r6 1024
mod r6 4096
cmp r6 0
jge sin_negative_780
add r6 4096
label sin_negative_780
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
jlt sin_done_781
mul r7 -1
label sin_done_781
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
localset 3070 0
localget r0 11
cmp r0 0
jne car_selection_ready
load8 r0 203
localset 3070 r0
label car_selection_ready
localset 143 0
label actor_vertex
localget r8 132
mov r9 r8
add r9 512
localget r9 r9
div r9 2048
cmp r9 r8
je vertex_transform_position
add r9 2048
meshread r0 r1 r2 r9
jmp vertex_publish_position
label vertex_transform_position
meshread r0 r1 r2 r8
localget r9 11
cmp r9 4
jlt nature_pose_done_782
cmp r9 124
jge nature_pose_done_782
localget r9 3120
localset 3091 r1
mov r5 r9
mul r5 73
mod r5 41
add r5 82
mul r0 r5
div r0 100
mov r5 r9
mul r5 47
mod r5 39
add r5 88
mul r1 r5
div r1 100
mov r5 r9
mul r5 29
mod r5 31
add r5 86
mul r2 r5
div r2 100
mod r9 7
sub r9 3
mul r9 r1
div r9 70
add r0 r9
localget r9 3104
add r1 r9
label nature_pose_done_782
cmp r8 279
jlt wheel_next_model_785
cmp r8 795
jge wheel_next_model_785
cmp r8 408
jge wheel_next_wheel_786
localset 3044 -88
localset 3045 -142
localset 3046 0
jmp wheel_transform_783
label wheel_next_wheel_786
cmp r8 537
jge wheel_next_wheel_787
localset 3044 88
localset 3045 -142
localset 3046 0
jmp wheel_transform_783
label wheel_next_wheel_787
cmp r8 666
jge wheel_next_wheel_788
localset 3044 -88
localset 3045 138
localset 3046 1
jmp wheel_transform_783
label wheel_next_wheel_788
cmp r8 795
jge wheel_next_wheel_789
localset 3044 88
localset 3045 138
localset 3046 1
jmp wheel_transform_783
label wheel_next_wheel_789
label wheel_next_model_785
cmp r8 1109
jlt wheel_next_model_790
cmp r8 1309
jge wheel_next_model_790
cmp r8 1159
jge wheel_next_wheel_791
localset 3044 -88
localset 3045 -142
localset 3046 0
jmp wheel_transform_783
label wheel_next_wheel_791
cmp r8 1209
jge wheel_next_wheel_792
localset 3044 88
localset 3045 -142
localset 3046 0
jmp wheel_transform_783
label wheel_next_wheel_792
cmp r8 1259
jge wheel_next_wheel_793
localset 3044 -88
localset 3045 138
localset 3046 1
jmp wheel_transform_783
label wheel_next_wheel_793
cmp r8 1309
jge wheel_next_wheel_794
localset 3044 88
localset 3045 138
localset 3046 1
jmp wheel_transform_783
label wheel_next_wheel_794
label wheel_next_model_790
jmp wheel_transform_done_784
label wheel_transform_783
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
je wheel_rear_795
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
label wheel_rear_795
label wheel_transform_done_784
localget r9 3070
cmp r9 1
je garage_gt_796
cmp r9 2
je garage_track_797
jmp garage_morph_done_798
label garage_gt_796
mul r0 96
div r0 100
mul r2 113
div r2 100
cmp r1 74
jle garage_morph_done_798
add r1 18
jmp garage_morph_done_798
label garage_track_797
mul r0 114
div r0 100
mul r2 92
div r2 100
cmp r1 77
jle garage_morph_done_798
sub r1 14
label garage_morph_done_798
localget r9 11
cmp r9 0
jne suspension_done_799
cmp r8 1535
jge suspension_done_799
localget r9 3103
add r0 r9
cmp r8 279
jlt suspension_body_800
cmp r8 795
jge suspension_body_800
load16 r9 384
cmp r9 0
je suspension_done_799
sub r1 4
jmp suspension_done_799
label suspension_body_800
mov r5 r1
sub r5 34
localget r6 3101
mov r7 r6
mul r7 r0
div r7 22528
add r1 r7
localget r9 3102
mov r7 r9
mul r7 r2
div r7 35840
add r1 r7
mul r6 r5
div r6 22528
sub r0 r6
mul r9 r5
div r9 35840
sub r2 r9
localget r9 3100
add r1 r9
label suspension_done_799
localget r9 11
cmp r9 0
jne fx_transform_done_801
cmp r8 1591
jlt smoke_transform_done_802
cmp r8 1607
jge smoke_transform_done_802
load8 r9 395
mul r1 r9
div r1 16
label smoke_transform_done_802
cmp r8 1607
jlt nitro_transform_done_803
cmp r8 1639
jge nitro_transform_done_803
load32 r9 115
mod r9 7
sub r9 3
add r2 r9
label nitro_transform_done_803
label fx_transform_done_801
localget r9 11
cmp r9 0
jne pressure_length_done_804
cmp r8 1511
jlt pressure_length_done_804
cmp r8 1535
jge pressure_length_done_804
sub r1 24
load16 r9 384
add r9 24
mul r1 r9
div r1 99
add r1 24
label pressure_length_done_804
localget r9 11
cmp r9 0
jne vertex_no_pneumatic_rise_805
cmp r8 1535
jlt vertex_pneumatic_rise_806
cmp r8 1607
jlt vertex_no_pneumatic_rise_805
cmp r8 1639
jge vertex_no_pneumatic_rise_805
label vertex_pneumatic_rise_806
load16 r9 384
add r1 r9
label vertex_no_pneumatic_rise_805
localget r9 11
cmp r9 0
je open_player_ground_808
cmp r9 124
jlt open_ground_rise_done_807
localget r9 3104
add r1 r9
jmp open_ground_rise_done_807
label open_player_ground_808
load16 r9 520
add r1 r9
label open_ground_rise_done_807
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
div r9 2048
meshtexcopy r8 r9
mov r9 r8
sub r9 1536
localget r9 r9
mod r9 2048
cmp r9 256
jlt vertex_shade_ready
add r9 2048
localget r9 r9
label vertex_shade_ready
localget r6 11
cmp r6 4
jlt nature_vertex_shade_done
cmp r6 124
jge nature_vertex_shade_done
localget r9 3090
localget r6 3091
div r6 30
add r9 r6
cmp r9 255
jle nature_vertex_shade_done
set r9 255
label nature_vertex_shade_done
meshshade r8 r9
sub r8 2047
mov r9 r8
localset 132 r9
localget r0 134
cmp r8 r0
jlt actor_vertex
localget r0 11
cmp r0 0
jne actor_shadow_stage
localget r0 145
cmp r0 1
je actor_nitro_stage
localset 145 1
load8 r0 395
cmp r0 0
jle actor_nitro_stage
set r0 1591
mov r9 r0
localset 132 r9
set r0 1607
mov r9 r0
localset 134 r9
jmp actor_vertex
label actor_nitro_stage
localget r0 146
cmp r0 1
je actor_air_stage
localset 146 1
load8 r0 382
cmp r0 1
jne actor_air_stage
set r0 1607
mov r9 r0
localset 132 r9
set r0 1639
mov r9 r0
localset 134 r9
jmp actor_vertex
label actor_air_stage
localget r0 144
cmp r0 1
je actor_shadow_stage
load8 r0 388
cmp r0 0
jle actor_shadow_stage
localset 144 1
set r0 1511
mov r9 r0
localset 132 r9
set r0 1535
mov r9 r0
localset 134 r9
jmp actor_vertex
label actor_shadow_stage
localget r0 11
cmp r0 4
jge actor_geometry_ready
localget r0 143
cmp r0 1
je actor_geometry_ready
localset 143 1
set r0 1535
mov r9 r0
localset 132 r9
set r0 1552
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
cmp r12 124
jge emit_skid
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
meshfacegradienttex 2327 2328 2329 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2327 2330 2328 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2330 2331 2332 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2330 2333 2331 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2333 2334 2335 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2333 2336 2334 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2336 2337 2334 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2336 2338 2337 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2338 2339 2337 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2338 2340 2339 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2340 2341 2342 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2340 2343 2341 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2343 2344 2345 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2343 2346 2344 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2346 2347 2344 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2346 2348 2347 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2348 2349 2347 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2348 2350 2349 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2350 2351 2352 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2350 2353 2351 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2353 2354 2355 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2353 2356 2354 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2356 2357 2354 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2356 2358 2357 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2358 2359 2357 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2358 2360 2359 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2360 2361 2362 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2360 2363 2361 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2363 2364 2365 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2363 2366 2364 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2366 2329 2364 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2366 2327 2329 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2367 2368 2369 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2367 2370 2368 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2370 2371 2368 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2372 2373 2371 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2374 2375 2371 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2376 2377 2375 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2377 2378 2375 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2377 2379 2378 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2379 2380 2378 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2379 2381 2380 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2381 2382 2380 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2383 2384 2382 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2385 2386 2382 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2387 2388 2386 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2388 2389 2386 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2388 2390 2389 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2390 2391 2389 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2390 2392 2391 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2392 2393 2391 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2394 2395 2393 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2396 2397 2393 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2398 2399 2397 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2399 2400 2397 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2399 2401 2400 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2401 2402 2400 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2401 2403 2402 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2403 2404 2402 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2405 2406 2404 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2407 2408 2404 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2409 2410 2408 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2410 2369 2408 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2410 2367 2369 r12 4 3 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2411 2412 2413 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2411 2413 2414 r12 12 4 2 r9 r10 r11 60
meshface 2415 2416 2417 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2412 2418 2419 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2412 2419 2413 r12 12 4 2 r9 r10 r11 60
meshface 2415 2417 2420 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2418 2421 2422 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2418 2422 2419 r12 12 4 2 r9 r10 r11 60
meshface 2415 2420 2423 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2421 2424 2425 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2421 2425 2422 r12 12 4 2 r9 r10 r11 60
meshface 2415 2423 2426 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2424 2427 2428 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2424 2428 2425 r12 12 4 2 r9 r10 r11 60
meshface 2415 2426 2429 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2427 2430 2431 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2427 2431 2428 r12 12 4 2 r9 r10 r11 60
meshface 2415 2429 2432 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2430 2433 2434 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2430 2434 2431 r12 12 4 2 r9 r10 r11 60
meshface 2415 2432 2435 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2433 2411 2414 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2433 2414 2434 r12 12 4 2 r9 r10 r11 60
meshface 2415 2435 2416 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2436 2437 2438 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2436 2438 2439 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2440 2441 2442 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2440 2442 2443 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2444 2445 2446 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2444 2446 2447 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2448 2449 2450 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2448 2450 2451 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2452 2453 2454 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2452 2454 2455 r12 12 4 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2456 2457 2458 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2456 2458 2459 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2459 2460 2461 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2459 2461 2462 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2462 2463 2464 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2462 2464 2465 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2465 2464 2466 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2465 2466 2467 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2467 2466 2468 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2467 2468 2469 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2469 2470 2471 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2469 2471 2472 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2472 2473 2474 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2472 2474 2475 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2475 2474 2476 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2475 2476 2477 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2477 2476 2478 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2477 2478 2479 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2479 2480 2481 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2479 2481 2482 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2482 2483 2484 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2482 2484 2485 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2485 2484 2486 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2485 2486 2487 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2487 2486 2488 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2487 2488 2489 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2489 2490 2491 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2489 2491 2492 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2492 2493 2494 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2492 2494 2495 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2495 2494 2457 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2495 2457 2456 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2496 2497 2498 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2496 2498 2499 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2499 2498 2500 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2501 2500 2502 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2503 2500 2504 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2505 2504 2506 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2506 2504 2507 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2506 2507 2508 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2508 2507 2509 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2508 2509 2510 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2510 2509 2511 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2512 2511 2513 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2514 2511 2515 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2516 2515 2517 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2517 2515 2518 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2517 2518 2519 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2519 2518 2520 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2519 2520 2521 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2521 2520 2522 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2523 2522 2524 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2525 2522 2526 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2527 2526 2528 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2528 2526 2529 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2528 2529 2530 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2530 2529 2531 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2530 2531 2532 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2532 2531 2533 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2534 2533 2535 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2536 2533 2537 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2538 2537 2539 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2539 2537 2497 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2539 2497 2496 r12 4 3 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2540 2541 2542 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2540 2543 2541 r12 12 4 2 r9 r10 r11 60
meshface 2544 2545 2546 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2542 2547 2548 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2542 2541 2547 r12 12 4 2 r9 r10 r11 60
meshface 2544 2549 2545 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2548 2550 2551 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2548 2547 2550 r12 12 4 2 r9 r10 r11 60
meshface 2544 2552 2549 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2551 2553 2554 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2551 2550 2553 r12 12 4 2 r9 r10 r11 60
meshface 2544 2555 2552 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2554 2556 2557 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2554 2553 2556 r12 12 4 2 r9 r10 r11 60
meshface 2544 2558 2555 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2557 2559 2560 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2557 2556 2559 r12 12 4 2 r9 r10 r11 60
meshface 2544 2561 2558 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2560 2562 2563 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2560 2559 2562 r12 12 4 2 r9 r10 r11 60
meshface 2544 2564 2561 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2563 2543 2540 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2563 2562 2543 r12 12 4 2 r9 r10 r11 60
meshface 2544 2546 2564 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2565 2566 2567 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2565 2568 2566 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2569 2570 2571 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2569 2572 2570 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2573 2574 2575 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2573 2576 2574 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2577 2578 2579 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2577 2580 2578 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2581 2582 2583 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2581 2584 2582 r12 12 4 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2585 2586 2587 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2585 2588 2586 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2588 2589 2590 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2588 2591 2589 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2591 2592 2593 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2591 2594 2592 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2594 2595 2592 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2594 2596 2595 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2596 2597 2595 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2596 2598 2597 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2598 2599 2600 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2598 2601 2599 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2601 2602 2603 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2601 2604 2602 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2604 2605 2602 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2604 2606 2605 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2606 2607 2605 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2606 2608 2607 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2608 2609 2610 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2608 2611 2609 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2611 2612 2613 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2611 2614 2612 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2614 2615 2612 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2614 2616 2615 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2616 2617 2615 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2616 2618 2617 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2618 2619 2620 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2618 2621 2619 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2621 2622 2623 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2621 2624 2622 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2624 2587 2622 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2624 2585 2587 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2625 2626 2627 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2625 2628 2626 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2628 2629 2626 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2630 2631 2629 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2632 2633 2629 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2634 2635 2633 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2635 2636 2633 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2635 2637 2636 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2637 2638 2636 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2637 2639 2638 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2639 2640 2638 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2641 2642 2640 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2643 2644 2640 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2645 2646 2644 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2646 2647 2644 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2646 2648 2647 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2648 2649 2647 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2648 2650 2649 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2650 2651 2649 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2652 2653 2651 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2654 2655 2651 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2656 2657 2655 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2657 2658 2655 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2657 2659 2658 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2659 2660 2658 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2659 2661 2660 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2661 2662 2660 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2663 2664 2662 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2665 2666 2662 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2667 2668 2666 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2668 2627 2666 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2668 2625 2627 r12 4 3 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2669 2670 2671 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2669 2671 2672 r12 12 4 2 r9 r10 r11 60
meshface 2673 2674 2675 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2670 2676 2677 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2670 2677 2671 r12 12 4 2 r9 r10 r11 60
meshface 2673 2675 2678 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2676 2679 2680 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2676 2680 2677 r12 12 4 2 r9 r10 r11 60
meshface 2673 2678 2681 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2679 2682 2683 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2679 2683 2680 r12 12 4 2 r9 r10 r11 60
meshface 2673 2681 2684 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2682 2685 2686 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2682 2686 2683 r12 12 4 2 r9 r10 r11 60
meshface 2673 2684 2687 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2685 2688 2689 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2685 2689 2686 r12 12 4 2 r9 r10 r11 60
meshface 2673 2687 2690 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2688 2691 2692 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2688 2692 2689 r12 12 4 2 r9 r10 r11 60
meshface 2673 2690 2693 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2691 2669 2672 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2691 2672 2692 r12 12 4 2 r9 r10 r11 60
meshface 2673 2693 2674 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2694 2695 2696 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2694 2696 2697 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2698 2699 2700 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2698 2700 2701 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2702 2703 2704 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2702 2704 2705 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2706 2707 2708 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2706 2708 2709 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2710 2711 2712 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2710 2712 2713 r12 12 4 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2714 2715 2716 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2714 2716 2717 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2717 2718 2719 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2717 2719 2720 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2720 2721 2722 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2720 2722 2723 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2723 2722 2724 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2723 2724 2725 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2725 2724 2726 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2725 2726 2727 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2727 2728 2729 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2727 2729 2730 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2730 2731 2732 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2730 2732 2733 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2733 2732 2734 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2733 2734 2735 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2735 2734 2736 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2735 2736 2737 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2737 2738 2739 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2737 2739 2740 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2740 2741 2742 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2740 2742 2743 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2743 2742 2744 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2743 2744 2745 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2745 2744 2746 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2745 2746 2747 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2747 2748 2749 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2747 2749 2750 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2750 2751 2752 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2750 2752 2753 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2753 2752 2715 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2753 2715 2714 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2754 2755 2756 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2754 2756 2757 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2757 2756 2758 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2759 2758 2760 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2761 2758 2762 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2763 2762 2764 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2764 2762 2765 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2764 2765 2766 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2766 2765 2767 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2766 2767 2768 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2768 2767 2769 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2770 2769 2771 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2772 2769 2773 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2774 2773 2775 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2775 2773 2776 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2775 2776 2777 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2777 2776 2778 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2777 2778 2779 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2779 2778 2780 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2781 2780 2782 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2783 2780 2784 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2785 2784 2786 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2786 2784 2787 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2786 2787 2788 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2788 2787 2789 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2788 2789 2790 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2790 2789 2791 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2792 2791 2793 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2794 2791 2795 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2796 2795 2797 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2797 2795 2755 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 2797 2755 2754 r12 4 3 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2798 2799 2800 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2798 2801 2799 r12 12 4 2 r9 r10 r11 60
meshface 2802 2803 2804 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2800 2805 2806 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2800 2799 2805 r12 12 4 2 r9 r10 r11 60
meshface 2802 2807 2803 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2806 2808 2809 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2806 2805 2808 r12 12 4 2 r9 r10 r11 60
meshface 2802 2810 2807 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2809 2811 2812 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2809 2808 2811 r12 12 4 2 r9 r10 r11 60
meshface 2802 2813 2810 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2812 2814 2815 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2812 2811 2814 r12 12 4 2 r9 r10 r11 60
meshface 2802 2816 2813 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2815 2817 2818 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2815 2814 2817 r12 12 4 2 r9 r10 r11 60
meshface 2802 2819 2816 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2818 2820 2821 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2818 2817 2820 r12 12 4 2 r9 r10 r11 60
meshface 2802 2822 2819 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2821 2801 2798 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2821 2820 2801 r12 12 4 2 r9 r10 r11 60
meshface 2802 2804 2822 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 2823 2824 2825 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2823 2826 2824 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2827 2828 2829 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2827 2830 2828 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2831 2832 2833 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2831 2834 2832 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2835 2836 2837 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2835 2838 2836 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2839 2840 2841 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 2839 2842 2840 r12 12 4 2 r9 r10 r11 60
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
localget r0 11
cmp r0 0
jne brake_dim_2903_2904_2905
load8 r0 129
cmp r0 1
jne brake_dim_2903_2904_2905
meshface 2903 2904 2905 224 r9 r10 r11 60
jmp brake_done_2903_2904_2905
label brake_dim_2903_2904_2905
meshface 2903 2904 2905 242 r9 r10 r11 60
label brake_done_2903_2904_2905
localget r0 11
cmp r0 0
jne brake_dim_2903_2906_2904
load8 r0 129
cmp r0 1
jne brake_dim_2903_2906_2904
meshface 2903 2906 2904 224 r9 r10 r11 60
jmp brake_done_2903_2906_2904
label brake_dim_2903_2906_2904
meshface 2903 2906 2904 242 r9 r10 r11 60
label brake_done_2903_2906_2904
set r12 228
meshfacegradienttex 2907 2908 2909 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 2907 2910 2908 r12 12 1 3 r9 r10 r11 60
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
meshfacegradienttex 2943 2944 2945 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 2943 2945 2946 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 2944 2947 2948 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 2944 2948 2945 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 2947 2949 2950 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 2947 2950 2948 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 2949 2951 2952 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 2949 2952 2950 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 2953 2954 2955 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 2953 2956 2954 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 2955 2957 2958 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 2955 2954 2957 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 2958 2959 2960 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 2958 2957 2959 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 2960 2961 2962 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 2960 2959 2961 r12 12 1 3 r9 r10 r11 60
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
meshfacegradienttex 2995 2996 2997 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 2995 2998 2996 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 2999 3000 3001 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 2999 3002 3000 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 3003 3004 3005 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 3003 3006 3004 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 3007 3008 3009 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 3007 3010 3008 r12 12 1 3 r9 r10 r11 60
meshface 3011 3012 3013 240 r9 r10 r11 60
meshface 3011 3014 3012 240 r9 r10 r11 60
meshface 3015 3016 3017 241 r9 r10 r11 60
meshface 3015 3017 3018 241 r9 r10 r11 60
meshface 3019 3020 3021 241 r9 r10 r11 60
meshface 3019 3022 3020 241 r9 r10 r11 60
load8 r0 388
cmp r0 0
jle air_jet_pulse_done_809
meshfacegradient 3559 3561 3560 244 12 r9 r10 r11 60
meshfacegradient 3559 3560 3562 244 12 r9 r10 r11 60
meshfacegradient 3559 3563 3560 244 12 r9 r10 r11 60
meshfacegradient 3559 3560 3564 244 12 r9 r10 r11 60
meshfacegradient 3565 3567 3566 244 12 r9 r10 r11 60
meshfacegradient 3565 3566 3568 244 12 r9 r10 r11 60
meshfacegradient 3565 3569 3566 244 12 r9 r10 r11 60
meshfacegradient 3565 3566 3570 244 12 r9 r10 r11 60
meshfacegradient 3571 3573 3572 244 12 r9 r10 r11 60
meshfacegradient 3571 3572 3574 244 12 r9 r10 r11 60
meshfacegradient 3571 3575 3572 244 12 r9 r10 r11 60
meshfacegradient 3571 3572 3576 244 12 r9 r10 r11 60
meshfacegradient 3577 3579 3578 244 12 r9 r10 r11 60
meshfacegradient 3577 3578 3580 244 12 r9 r10 r11 60
meshfacegradient 3577 3581 3578 244 12 r9 r10 r11 60
meshfacegradient 3577 3578 3582 244 12 r9 r10 r11 60
label air_jet_pulse_done_809
load8 r0 395
cmp r0 0
jle smoke_done_810
load16 r0 384
cmp r0 0
jne smoke_done_810
load16 r0 544
cmp r0 0
je spray_dry_811
meshfacegradient 3639 3640 3641 32 8 r9 r10 r11 60
meshfacegradient 3639 3641 3642 32 8 r9 r10 r11 60
meshfacegradient 3643 3644 3645 32 8 r9 r10 r11 60
meshfacegradient 3643 3645 3646 32 8 r9 r10 r11 60
meshfacegradient 3647 3648 3649 32 8 r9 r10 r11 60
meshfacegradient 3647 3649 3650 32 8 r9 r10 r11 60
meshfacegradient 3651 3652 3653 32 8 r9 r10 r11 60
meshfacegradient 3651 3653 3654 32 8 r9 r10 r11 60
jmp spray_done_812
label spray_dry_811
meshfacegradient 3639 3640 3641 244 12 r9 r10 r11 60
meshfacegradient 3639 3641 3642 244 12 r9 r10 r11 60
meshfacegradient 3643 3644 3645 244 12 r9 r10 r11 60
meshfacegradient 3643 3645 3646 244 12 r9 r10 r11 60
meshfacegradient 3647 3648 3649 244 12 r9 r10 r11 60
meshfacegradient 3647 3649 3650 244 12 r9 r10 r11 60
meshfacegradient 3651 3652 3653 244 12 r9 r10 r11 60
meshfacegradient 3651 3653 3654 244 12 r9 r10 r11 60
label spray_done_812
label smoke_done_810
load8 r0 382
cmp r0 1
jne nitro_done_813
meshfacegradient 3655 3656 3657 56 8 r9 r10 r11 60
meshfacegradient 3655 3657 3658 56 8 r9 r10 r11 60
meshfacegradient 3659 3660 3661 56 8 r9 r10 r11 60
meshfacegradient 3659 3661 3662 56 8 r9 r10 r11 60
meshfacegradient 3663 3664 3665 56 8 r9 r10 r11 60
meshfacegradient 3663 3665 3666 56 8 r9 r10 r11 60
meshfacegradient 3667 3668 3669 56 8 r9 r10 r11 60
meshfacegradient 3667 3669 3670 56 8 r9 r10 r11 60
meshfacegradient 3671 3672 3673 56 8 r9 r10 r11 60
meshfacegradient 3671 3673 3674 56 8 r9 r10 r11 60
meshfacegradient 3675 3676 3677 56 8 r9 r10 r11 60
meshfacegradient 3675 3677 3678 56 8 r9 r10 r11 60
meshfacegradient 3679 3680 3681 56 8 r9 r10 r11 60
meshfacegradient 3679 3681 3682 56 8 r9 r10 r11 60
meshfacegradient 3683 3684 3685 56 8 r9 r10 r11 60
meshfacegradient 3683 3685 3686 56 8 r9 r10 r11 60
label nitro_done_813
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
meshfacegradienttex 3157 3158 3159 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3157 3160 3158 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3160 3161 3158 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3160 3162 3161 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3162 3163 3161 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3162 3164 3163 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3164 3165 3163 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3164 3166 3165 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3166 3167 3165 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3166 3168 3167 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3168 3169 3167 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3168 3170 3169 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3170 3171 3169 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3170 3172 3171 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3172 3159 3171 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3172 3157 3159 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3173 3174 3175 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3173 3176 3174 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3176 3177 3174 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3176 3178 3177 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3178 3179 3177 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3178 3180 3179 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3180 3181 3179 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3180 3182 3181 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3182 3183 3181 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3182 3184 3183 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3184 3185 3183 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3184 3186 3185 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3186 3187 3185 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3186 3188 3187 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3188 3175 3187 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3188 3173 3175 r12 4 3 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 3189 3190 3191 r12 12 4 2 r9 r10 r11 60
meshface 3192 3193 3194 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3189 3195 3196 r12 12 4 2 r9 r10 r11 60
meshface 3192 3197 3198 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3189 3199 3200 r12 12 4 2 r9 r10 r11 60
meshface 3192 3201 3202 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3189 3203 3204 r12 12 4 2 r9 r10 r11 60
meshface 3192 3205 3206 226 r9 r10 r11 60
set r12 208
meshfacegradienttex 3207 3208 3209 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3207 3209 3210 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3210 3209 3211 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3210 3211 3212 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3212 3211 3213 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3212 3213 3214 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3214 3213 3215 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3214 3215 3216 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3216 3215 3217 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3216 3217 3218 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3218 3217 3219 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3218 3219 3220 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3220 3219 3221 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3220 3221 3222 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3222 3221 3208 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3222 3208 3207 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3223 3224 3225 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3223 3225 3226 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3226 3225 3227 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3226 3227 3228 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3228 3227 3229 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3228 3229 3230 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3230 3229 3231 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3230 3231 3232 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3232 3231 3233 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3232 3233 3234 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3234 3233 3235 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3234 3235 3236 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3236 3235 3237 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3236 3237 3238 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3238 3237 3224 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3238 3224 3223 r12 4 3 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 3239 3240 3241 r12 12 4 2 r9 r10 r11 60
meshface 3242 3243 3244 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3239 3245 3246 r12 12 4 2 r9 r10 r11 60
meshface 3242 3247 3248 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3239 3249 3250 r12 12 4 2 r9 r10 r11 60
meshface 3242 3251 3252 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3239 3253 3254 r12 12 4 2 r9 r10 r11 60
meshface 3242 3255 3256 226 r9 r10 r11 60
set r12 208
meshfacegradienttex 3257 3258 3259 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3257 3260 3258 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3260 3261 3258 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3260 3262 3261 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3262 3263 3261 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3262 3264 3263 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3264 3265 3263 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3264 3266 3265 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3266 3267 3265 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3266 3268 3267 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3268 3269 3267 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3268 3270 3269 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3270 3271 3269 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3270 3272 3271 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3272 3259 3271 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3272 3257 3259 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3273 3274 3275 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3273 3276 3274 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3276 3277 3274 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3276 3278 3277 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3278 3279 3277 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3278 3280 3279 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3280 3281 3279 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3280 3282 3281 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3282 3283 3281 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3282 3284 3283 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3284 3285 3283 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3284 3286 3285 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3286 3287 3285 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3286 3288 3287 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3288 3275 3287 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3288 3273 3275 r12 4 3 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 3289 3290 3291 r12 12 4 2 r9 r10 r11 60
meshface 3292 3293 3294 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3289 3295 3296 r12 12 4 2 r9 r10 r11 60
meshface 3292 3297 3298 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3289 3299 3300 r12 12 4 2 r9 r10 r11 60
meshface 3292 3301 3302 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3289 3303 3304 r12 12 4 2 r9 r10 r11 60
meshface 3292 3305 3306 226 r9 r10 r11 60
set r12 208
meshfacegradienttex 3307 3308 3309 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3307 3309 3310 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3310 3309 3311 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3310 3311 3312 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3312 3311 3313 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3312 3313 3314 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3314 3313 3315 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3314 3315 3316 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3316 3315 3317 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3316 3317 3318 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3318 3317 3319 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3318 3319 3320 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3320 3319 3321 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3320 3321 3322 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3322 3321 3308 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3322 3308 3307 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3323 3324 3325 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3323 3325 3326 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3326 3325 3327 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3326 3327 3328 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3328 3327 3329 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3328 3329 3330 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3330 3329 3331 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3330 3331 3332 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3332 3331 3333 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3332 3333 3334 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3334 3333 3335 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3334 3335 3336 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3336 3335 3337 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3336 3337 3338 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3338 3337 3324 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3338 3324 3323 r12 4 3 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 3339 3340 3341 r12 12 4 2 r9 r10 r11 60
meshface 3342 3343 3344 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3339 3345 3346 r12 12 4 2 r9 r10 r11 60
meshface 3342 3347 3348 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3339 3349 3350 r12 12 4 2 r9 r10 r11 60
meshface 3342 3351 3352 226 r9 r10 r11 60
set r12 212
meshfacegradienttex 3339 3353 3354 r12 12 4 2 r9 r10 r11 60
meshface 3342 3355 3356 226 r9 r10 r11 60
meshface 3357 3358 3359 226 r9 r10 r11 60
meshface 3360 3361 3362 226 r9 r10 r11 60
meshface 3363 3364 3365 225 r9 r10 r11 60
meshface 3363 3365 3366 225 r9 r10 r11 60
localget r0 11
cmp r0 0
jne brake_dim_3367_3368_3369
load8 r0 129
cmp r0 1
jne brake_dim_3367_3368_3369
meshface 3367 3368 3369 224 r9 r10 r11 60
jmp brake_done_3367_3368_3369
label brake_dim_3367_3368_3369
meshface 3367 3368 3369 242 r9 r10 r11 60
label brake_done_3367_3368_3369
localget r0 11
cmp r0 0
jne brake_dim_3367_3370_3368
load8 r0 129
cmp r0 1
jne brake_dim_3367_3370_3368
meshface 3367 3370 3368 224 r9 r10 r11 60
jmp brake_done_3367_3370_3368
label brake_dim_3367_3370_3368
meshface 3367 3370 3368 242 r9 r10 r11 60
label brake_done_3367_3370_3368
set r12 228
meshfacegradienttex 3371 3372 3373 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 3371 3374 3372 r12 12 1 3 r9 r10 r11 60
meshface 3375 3376 3377 226 r9 r10 r11 60
meshface 3375 3377 3378 226 r9 r10 r11 60
meshface 3379 3380 3381 226 r9 r10 r11 60
meshface 3379 3382 3380 226 r9 r10 r11 60
set r12 228
meshfacegradienttex 3383 3384 3385 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 3383 3385 3386 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 3384 3387 3388 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 3384 3388 3385 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 3389 3390 3391 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 3389 3392 3390 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 3391 3393 3394 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 3391 3390 3393 r12 12 1 3 r9 r10 r11 60
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
meshfacegradienttex 3467 3468 3469 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3467 3470 3468 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3471 3472 3473 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3471 3474 3472 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3475 3476 3477 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3475 3478 3476 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3479 3480 3481 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3479 3482 3480 r12 4 3 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 3483 3484 3485 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 3483 3485 3486 r12 12 4 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3487 3488 3489 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3487 3489 3490 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3491 3492 3493 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3491 3493 3494 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3495 3496 3497 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3495 3497 3498 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3499 3500 3501 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3499 3501 3502 r12 4 3 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 3503 3504 3505 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 3503 3506 3504 r12 12 4 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3507 3508 3509 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3507 3510 3508 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3511 3512 3513 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3511 3514 3512 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3515 3516 3517 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3515 3518 3516 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3519 3520 3521 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3519 3522 3520 r12 4 3 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 3523 3524 3525 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 3523 3525 3526 r12 12 4 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3527 3528 3529 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3527 3529 3530 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3531 3532 3533 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3531 3533 3534 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3535 3536 3537 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3535 3537 3538 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3539 3540 3541 r12 4 3 2 r9 r10 r11 60
set r12 208
meshfacegradienttex 3539 3541 3542 r12 4 3 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 3543 3544 3545 r12 12 4 2 r9 r10 r11 60
set r12 212
meshfacegradienttex 3543 3546 3544 r12 12 4 2 r9 r10 r11 60
meshface 3547 3548 3549 225 r9 r10 r11 60
meshface 3547 3549 3550 225 r9 r10 r11 60
localget r0 11
cmp r0 0
jne brake_dim_3551_3552_3553
load8 r0 129
cmp r0 1
jne brake_dim_3551_3552_3553
meshface 3551 3552 3553 224 r9 r10 r11 60
jmp brake_done_3551_3552_3553
label brake_dim_3551_3552_3553
meshface 3551 3552 3553 242 r9 r10 r11 60
label brake_done_3551_3552_3553
localget r0 11
cmp r0 0
jne brake_dim_3551_3554_3552
load8 r0 129
cmp r0 1
jne brake_dim_3551_3554_3552
meshface 3551 3554 3552 224 r9 r10 r11 60
jmp brake_done_3551_3554_3552
label brake_dim_3551_3554_3552
meshface 3551 3554 3552 242 r9 r10 r11 60
label brake_done_3551_3554_3552
set r12 228
meshfacegradienttex 3555 3556 3557 r12 12 1 3 r9 r10 r11 60
set r12 228
meshfacegradienttex 3555 3558 3556 r12 12 1 3 r9 r10 r11 60
jmp emit_shadow
label emit_skid
meshfacegradient 3687 3688 3689 24 8 r9 r10 r11 60
meshfacegradient 3687 3689 3690 24 8 r9 r10 r11 60
meshfacegradient 3691 3692 3693 24 8 r9 r10 r11 60
meshfacegradient 3691 3693 3694 24 8 r9 r10 r11 60
jmp next_actor
label emit_shadow
set r12 24
localget r0 11
cmp r0 0
jne shadow_base_ready
load8 r0 120
cmp r0 0
je shadow_base_ready
set r12 24
label shadow_base_ready
meshfacegradient 3583 3584 3585 r12 8 r9 r10 r11 60
meshfacegradient 3584 3592 3593 r12 8 r9 r10 r11 60
meshfacegradient 3584 3593 3585 r12 8 r9 r10 r11 60
meshfacegradient 3583 3585 3586 r12 8 r9 r10 r11 60
meshfacegradient 3585 3593 3594 r12 8 r9 r10 r11 60
meshfacegradient 3585 3594 3586 r12 8 r9 r10 r11 60
meshfacegradient 3583 3586 3587 r12 8 r9 r10 r11 60
meshfacegradient 3586 3594 3595 r12 8 r9 r10 r11 60
meshfacegradient 3586 3595 3587 r12 8 r9 r10 r11 60
meshfacegradient 3583 3587 3588 r12 8 r9 r10 r11 60
meshfacegradient 3587 3595 3596 r12 8 r9 r10 r11 60
meshfacegradient 3587 3596 3588 r12 8 r9 r10 r11 60
meshfacegradient 3583 3588 3589 r12 8 r9 r10 r11 60
meshfacegradient 3588 3596 3597 r12 8 r9 r10 r11 60
meshfacegradient 3588 3597 3589 r12 8 r9 r10 r11 60
meshfacegradient 3583 3589 3590 r12 8 r9 r10 r11 60
meshfacegradient 3589 3597 3598 r12 8 r9 r10 r11 60
meshfacegradient 3589 3598 3590 r12 8 r9 r10 r11 60
meshfacegradient 3583 3590 3591 r12 8 r9 r10 r11 60
meshfacegradient 3590 3598 3599 r12 8 r9 r10 r11 60
meshfacegradient 3590 3599 3591 r12 8 r9 r10 r11 60
meshfacegradient 3583 3591 3584 r12 8 r9 r10 r11 60
meshfacegradient 3591 3599 3592 r12 8 r9 r10 r11 60
meshfacegradient 3591 3592 3584 r12 8 r9 r10 r11 60
jmp next_actor
label emit_tree
localget r0 11
mod r0 10
cmp r0 7
je nature_emit_rock
cmp r0 8
je nature_emit_rock
cmp r0 9
je nature_emit_grass
meshfacegradienttex 3600 3601 3602 12 8 6 2 r9 r10 r11 60
meshfacegradienttex 3600 3602 3603 12 8 6 2 r9 r10 r11 60
meshfacegradienttex 3600 3603 3604 12 8 6 2 r9 r10 r11 60
meshfacegradienttex 3600 3604 3605 12 8 6 2 r9 r10 r11 60
meshfacegradienttex 3600 3605 3601 12 8 6 2 r9 r10 r11 60
localget r0 112
sub r0 1000000
cmp r0 12000
jgt next_actor
meshfacegradienttex 3606 3607 3608 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 3606 3608 3609 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 3610 3611 3612 9 3 7 2 r9 r10 r11 60
meshfacegradienttex 3610 3612 3613 9 3 7 2 r9 r10 r11 60
jmp next_actor
label nature_emit_rock
meshfacegradienttex 3614 3615 3616 22 2 7 3 r9 r10 r11 60
meshfacegradienttex 3615 3621 3616 22 2 7 3 r9 r10 r11 60
meshfacegradienttex 3614 3616 3617 22 2 7 3 r9 r10 r11 60
meshfacegradienttex 3616 3622 3617 22 2 7 3 r9 r10 r11 60
meshfacegradienttex 3614 3617 3618 22 2 7 3 r9 r10 r11 60
meshfacegradienttex 3617 3623 3618 22 2 7 3 r9 r10 r11 60
meshfacegradienttex 3614 3618 3619 22 2 7 3 r9 r10 r11 60
meshfacegradienttex 3618 3624 3619 22 2 7 3 r9 r10 r11 60
meshfacegradienttex 3614 3619 3620 22 2 7 3 r9 r10 r11 60
meshfacegradienttex 3619 3625 3620 22 2 7 3 r9 r10 r11 60
meshfacegradienttex 3614 3620 3615 22 2 7 3 r9 r10 r11 60
meshfacegradienttex 3620 3626 3615 22 2 7 3 r9 r10 r11 60
jmp next_actor
label nature_emit_grass
meshfacegradienttex 3627 3628 3629 12 8 6 2 r9 r10 r11 60
meshfacegradienttex 3629 3628 3627 12 8 6 2 r9 r10 r11 60
meshfacegradienttex 3630 3631 3632 12 8 6 2 r9 r10 r11 60
meshfacegradienttex 3632 3631 3630 12 8 6 2 r9 r10 r11 60
meshfacegradienttex 3633 3634 3635 12 8 6 2 r9 r10 r11 60
meshfacegradienttex 3635 3634 3633 12 8 6 2 r9 r10 r11 60
meshface 3636 3637 3638 243 r9 r10 r11 60
meshface 3638 3637 3636 243 r9 r10 r11 60
label next_actor
load32 r12 100
sub r12 2000000
localget r0 11
add r0 1
localset 11 r0
cmp r0 128
jlt actor
meshend
halt
