'use strict';
const PUDDLES=Object.freeze([4,8,13,18,21,24,26,32,34,36,40,44,47,51,55,59,63,67,71,75]);
const FORD_LEVEL=82,BRIDGE=65;
function physicsXi(){const s=[
 '# Wetlands: physically shallow water, retained wetness and wheel splash.',
 'store16 544 0','load32 r0 532','sub r0 2000000000','cmp r0 -6000','jlt wetlands_wetness','cmp r0 6000','jgt wetlands_wetness','load8 r0 523','cmp r0 4','jne wetlands_check_ford','load32 r1 342','cmp r1 90000','jgt wetlands_check_puddle','store8 489 3',
 'label wetlands_check_ford','cmp r0 2','je wetlands_lake','cmp r0 1','je wetlands_bridge_water','cmp r0 5','jne wetlands_check_puddle','store8 489 4',
 `set r1 ${FORD_LEVEL}`,'load16 r2 520','sub r1 r2','cmp r1 0','jge wetlands_depth_positive','set r1 0','label wetlands_depth_positive','cmp r1 40','jle wetlands_depth_bounded','set r1 40','label wetlands_depth_bounded','store16 544 r1','jmp wetlands_wetness',
 'label wetlands_lake','load32 r1 532','sub r1 2000000000','cmp r1 900','jlt wetlands_wetness','cmp r1 5800','jgt wetlands_wetness','localget r1 3726','add r1 9','jmp wetlands_lake_depth','label wetlands_bridge_water','localget r1 3726','sub r1 171','label wetlands_lake_depth','load16 r2 520','sub r1 r2','cmp r1 0','jle wetlands_wetness','cmp r1 40','jle wetlands_lake_bounded','set r1 40','label wetlands_lake_bounded','store16 544 r1','store8 489 4','jmp wetlands_wetness','label wetlands_check_puddle','load32 r1 330','cmp r1 300000','jlt wetlands_wetness','cmp r1 700000','jgt wetlands_wetness',
 'load32 r1 532','sub r1 2000000000','load8 r0 273','mod r0 2','mul r0 80','sub r0 40','sub r1 r0','cmp r1 -115','jlt wetlands_wetness','cmp r1 115','jgt wetlands_wetness','load8 r0 273'
 ];
 for(const i of PUDDLES)s.push('cmp r0 '+i,'je wetlands_puddle');
 s.push('jmp wetlands_wetness','label wetlands_puddle','store16 544 4','store8 489 3',
 'label wetlands_wetness','load16 r0 546','load16 r1 544','cmp r1 0','jgt wetlands_wet','load8 r1 489','cmp r1 3','je wetlands_muddy','sub r0 1','jmp wetlands_wetness_bound',
 'label wetlands_muddy','add r0 8','jmp wetlands_wetness_bound','label wetlands_wet','add r0 45',
 'label wetlands_wetness_bound','cmp r0 0','jge wetlands_wetness_min','set r0 0','label wetlands_wetness_min','cmp r0 1000','jle wetlands_wetness_max','set r0 1000','label wetlands_wetness_max','store16 546 r0',
 'load16 r0 544','load16 r1 110','mul r0 r1','div r0 45','cmp r0 255','jle wetlands_splash_bounded','set r0 255','label wetlands_splash_bounded','store8 548 r0','cmp r0 10','jle wetlands_splash_ready','store8 395 16','label wetlands_splash_ready',
 'load32 r1 532','sub r1 2000000000');return s.join('\n');}
module.exports={PUDDLES,FORD_LEVEL,BRIDGE,physicsXi};
