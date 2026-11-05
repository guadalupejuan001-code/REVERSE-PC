'use strict';
// Authoring only. Every integration step below executes as XI at 50 Hz.
// Persistent Ether 496..519 is separate from the 26-register race ABI.
const RIG=Object.freeze({magic:496,phase:498,remainder:500,speed:502,
 pitch:504,pitchVelocity:506,roll:508,rollVelocity:510,
 heave:512,heaveVelocity:514,sway:516,swayVelocity:518});
function initialXi(){return ['# V2.3 secondary-motion state, centimetres in Q8.',
 'store8 496 35','store16 498 0','store16 500 16384','store16 502 0',
 ...[504,506,508,510,512,514,516,518].map(a=>'store16 '+a+' 32768')].join('\n');}
function updateXi(){
 const lines=[],out=s=>lines.push(...s.split('\n'));
 const clamp=(r,lo,hi,name)=>out(`cmp ${r} ${lo}\njge rig_${name}_lo\nset ${r} ${lo}\nlabel rig_${name}_lo\ncmp ${r} ${hi}\njle rig_${name}_hi\nset ${r} ${hi}\nlabel rig_${name}_hi`);
 // Damped second-order spring. Position and velocity are both retained;
 // rendering frequency cannot advance a spring or roll a wheel.
 function spring(name,address,bound){
  out(`load16 r1 ${address}\nsub r1 32768\nload16 r2 ${address+2}\nsub r2 32768\nmov r3 r0\nsub r3 r1\nmul r3 3\nmul r2 11\nadd r2 r3\ndiv r2 16`);
  clamp('r2',-2048,2048,name+'_velocity');
  out('add r1 r2');clamp('r1',-bound,bound,name+'_position');
  out(`add r1 32768\nstore16 ${address} r1\nadd r2 32768\nstore16 ${address+2} r2`);
 }
 out('# V2.3 distance-independent wheel phase and damped body motion.');
 out('load8 r0 496\ncmp r0 35\nje rig_initialized\n'+initialXi()+'\nlabel rig_initialized');
 out('load16 r0 110\nload8 r1 133\ncmp r1 1\njne rig_forward\nmul r0 -1\nlabel rig_forward\nmul r0 4096\nload16 r1 500\nsub r1 16384\nadd r0 r1\nmov r1 r0\nmod r1 10700\nadd r1 16384\nstore16 500 r1\ndiv r0 10700\nload16 r1 498\nadd r0 r1\nadd r0 4096\nmod r0 4096\nstore16 498 r0');
 // Acceleration, not a pressed pedal, produces load transfer.
 out('load16 r0 110\nload16 r1 502\nstore16 502 r0\nsub r0 r1\nmul r0 48');
 clamp('r0',-2560,2048,'pitch_target');spring('pitch',504,3072);
 // Corner load scales with v^2; at rest steering does not rock the body.
 out('load16 r0 256\nsub r0 1000\nload16 r1 110\nmul r0 r1\nmul r0 r1\ndiv r0 12000000\nload16 r1 112\nsub r1 32768\ndiv r1 2\nadd r0 r1');
 clamp('r0',-2560,2560,'roll_target');spring('roll',508,3072);
 // A bounded road irregularity advances only with tyre travel.
 out('set r0 0\nload16 r1 110\ncmp r1 100\njlt rig_heave_target\nload16 r0 498\nmod r0 1024\ncmp r0 512\njle rig_rough_fold\nset r1 1024\nsub r1 r0\nmov r0 r1\nlabel rig_rough_fold\nsub r0 256\nload8 r1 489\ncmp r1 1\nje rig_rough_grass\ncmp r1 2\nje rig_rough_curb\ndiv r0 8\njmp rig_heave_target\nlabel rig_rough_grass\ndiv r0 2\njmp rig_heave_target\nlabel rig_rough_curb\nmul r0 3\ndiv r0 4\nlabel rig_heave_target\nload16 r1 384\ncmp r1 0\nje rig_grounded\nset r0 768\nlabel rig_grounded\nload8 r1 391\ncmp r1 1\njne rig_no_impact\nstore16 514 30968\nlabel rig_no_impact');
 spring('heave',512,2560);
 out('load16 r0 112\nsub r0 32768\ndiv r0 -2');
 clamp('r0',-768,768,'sway_target');spring('sway',516,896);
 return lines.join('\n');
}
module.exports={RIG,initialXi,updateXi};
