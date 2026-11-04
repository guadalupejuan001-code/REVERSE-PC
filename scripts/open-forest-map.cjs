'use strict';
// Authoring data only. The APK reads the emitted packed XI world.
const SEGMENTS=80,LENGTH=160000,SECTOR_SEGMENTS=10;
function curve(t){return [Math.sin(Math.PI*t)*(5600*Math.sin(2.2*Math.PI*t)+1600*Math.sin(5*Math.PI*t)),150000*t];}
const dense=Array.from({length:8001},(_,i)=>curve(i/8000)),arc=[0];
for(let i=1;i<dense.length;i++)arc.push(arc[i-1]+Math.hypot(...dense[i].map((v,k)=>v-dense[i-1][k])));
function sample(i){const d=arc.at(-1)*i/SEGMENTS;let lo=0,hi=8000;while(lo+1<hi){const m=(lo+hi)>>1;if(arc[m]<d)lo=m;else hi=m;}const f=(d-arc[lo])/(arc[hi]-arc[lo]||1);return dense[lo].map((v,k)=>Math.round((v+(dense[hi][k]-v)*f)*LENGTH/arc.at(-1)));}
const points=Array.from({length:81},(_,i)=>sample(i));
const heights=points.map((_,i)=>Math.round(85*(1-Math.cos(i*Math.PI/40))+35*Math.sin(i*Math.PI/20)**2));
const headings=points.map((p,i)=>{const a=points[Math.min(i,79)],b=points[Math.min(i+1,80)];return (Math.round(Math.atan2(b[0]-a[0],b[1]-a[1])*4096/(2*Math.PI))+4096)%4096;});
function biome(i){return i===28?1:i>=49&&i<=62?2:[26,32,48,63].includes(i)?4:(i>=11&&i<=16)||(i>=41&&i<=45)||i>=75?3:0;}
function point(i,lateral=0,altitude=null){const a=headings[i]*Math.PI/2048;return [Math.round(points[i][0]+lateral*Math.cos(a)),altitude===null?heights[i]:altitude,Math.round(points[i][1]-lateral*Math.sin(a))];}
function worldXi(){const s=['#!reverse-pc-machine-v1','# OPEN FOREST ROAD 3.0 — finite open road, never wraps to its start.',
 '# 80 ~20 m segments, eight 200 m sectors, 3.6 m one-lane asphalt.',
 '# Packed route4096, headings5000, elevations5300, biome5500.',
 'store8 1000 88','store8 1001 73','store8 1002 3','store8 1004 80'];
 points.forEach(([x,z],i)=>s.push(`store32 ${4096+i*8} ${x+65536}`,`store32 ${4100+i*8} ${z+65536}`,`store16 ${5000+i*2} ${headings[i]}`,`store16 ${5300+i*2} ${heights[i]}`,`store8 ${5500+i} ${biome(i)}`,`set r0 ${x}`,`set r1 ${z}`,'print r0','print r1'));s.push('halt');return s.join('\n')+'\n';}
module.exports={SEGMENTS,LENGTH,SECTOR_SEGMENTS,points,heights,headings,biome,point,worldXi};
if(require.main===module){const fs=require('node:fs'),path=require('node:path');fs.writeFileSync(path.join(__dirname,'../reverse-os-android/app/src/main/assets/velocity/world.xi'),worldXi());console.log('OPEN_FOREST_WORLD_AUTHORED',JSON.stringify({segments:80,sectors:8,lengthCm:LENGTH,roadWidthCm:360,start:points[0],end:points[80]}));}
