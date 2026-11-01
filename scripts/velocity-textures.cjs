'use strict';
// 16x16 four-bit tile patterns emitted into the XI shader, no external renderer.
function hash(x,y,k){let n=(Math.imul(x+23,19349663)^Math.imul(y+31,83492791)^Math.imul(k+3,73856093))>>>0;n^=n>>>16;n=Math.imul(n,0x7feb352d);n^=n>>>15;return n>>>0;}
function tex(x,y,k){const h=hash(x,y,k);switch(k){
case 0:return h%19===0?13:h%7===0?10:h%5===0?7:8;
case 1:return (x+y)%4<2?11:(x-y+64)%4<2?7:5;
case 2:return (x+3*y)%17<2?12:h%13===0?10:8;
case 3:return (x+2*y)%9<2?4:h%7===0?12:9;
case 4:return y%5===0?12:x%7===0?10:7;
case 5:return 4+h%12;
case 6:return h%13===0?4:10;
case 7:return (x+y)%4===0?3:9;}throw Error('unknown texture');}
const TILES=Object.freeze(Array.from({length:8},(_,k)=>Object.freeze(Array.from({length:16},(_,y)=>Array.from({length:16},(_,x)=>tex(x,y,k).toString(16)).join('')))));
const TEXTURED_MATERIALS=Object.freeze({paint:{id:0,strength:10},aero:{id:1,strength:11},glass:{id:2,strength:8},tire:{id:3,strength:12},rim:{id:4,strength:12}});
function carUV([x,y,z],mat){if(mat==='tire'||mat==='rim'){const axle=Math.abs(z-138)<Math.abs(z+142)?138:-142;return [Math.round((y-34)/4),Math.round((z-axle)/4)];}const scale=mat==='glass'?9:mat==='paint'?6:mat==='aero'?5:7;return [Math.round(x/scale),Math.round(z/scale)];}
function emitXiTextures(out){for(let k=0;k<8;++k)for(let y=0;y<16;++y)out('meshtexrow '+k+' '+y+' '+TILES[k][y]);}
module.exports={TILES,TEXTURED_MATERIALS,carUV,emitXiTextures};
