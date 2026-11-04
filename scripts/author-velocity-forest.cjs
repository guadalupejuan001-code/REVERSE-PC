#!/usr/bin/env node
'use strict';
// Offline authoring of the FOREST route. Android executes only the emitted
// world.xi through the user's native XI runtime; no JS track rules in APK.
const fs=require('node:fs'),path=require('node:path');
const SAMPLES=12000,COUNT=80;
function curve(t){
 const s=Math.sin(t),c=Math.cos(t);
 return [22000*(1-c)+1200*s*s*Math.sin(3*t)+300*s*s*Math.sin(5*t),
         31000*s+700*s*s*Math.sin(4*t)];
}
const dense=Array.from({length:SAMPLES+1},(_,i)=>curve(i*2*Math.PI/SAMPLES));
const arc=[0];
for(let i=1;i<=SAMPLES;i++)
 arc.push(arc[i-1]+Math.hypot(dense[i][0]-dense[i-1][0],dense[i][1]-dense[i-1][1]));
const length=arc[SAMPLES],scale=160000/length;
function locate(d){
 let lo=0,hi=SAMPLES;
 while(lo+1<hi){const mid=(lo+hi)>>1;if(arc[mid]<d)lo=mid;else hi=mid;}
 const f=(d-arc[lo])/(arc[hi]-arc[lo]||1);
 return dense[lo].map((v,k)=>Math.round((v+f*(dense[hi][k]-v))*scale));
}
const points=Array.from({length:COUNT},(_,i)=>locate(length*i/COUNT));
points.push([...points[0]]);
const yaw=(a,b)=>((Math.round(Math.atan2(b[0]-a[0],b[1]-a[1])*4096/(2*Math.PI))%4096)+4096)%4096;
let distance=0,minSegment=Infinity,maxSegment=0,minRadius=Infinity;
for(let i=0;i<COUNT;i++){
 const a=points[i],b=points[i+1],c=points[(i+2)%COUNT];
 const seg=Math.hypot(b[0]-a[0],b[1]-a[1]);distance+=seg;
 minSegment=Math.min(minSegment,seg);maxSegment=Math.max(maxSegment,seg);
 let angle=Math.abs(Math.atan2(b[0]-a[0],b[1]-a[1])-Math.atan2(c[0]-b[0],c[1]-b[1]));
 if(angle>Math.PI)angle=2*Math.PI-angle;
 if(angle>1e-6)minRadius=Math.min(minRadius,seg/angle);
}
if(Math.abs(distance-160000)>300||minSegment<1950||maxSegment>2050||minRadius<9000)
 throw Error('Forest trail fails road length/curvature contract: '+JSON.stringify({distance,minSegment,maxSegment,minRadius}));
if(points[0][0]!==0||points[0][1]!==0||points[80].join()!==points[0].join())
 throw Error('Forest has no exact closed physical start');
const xi=[
 '#!reverse-pc-machine-v1',
 '# BOSQUE DE LOS CEDROS: original winding closed forest road, executed in XI.',
 '# Exact 80 approximately 20m segments; legacy lap and collision ABI retained.',
 '# Units cm; yaw4096 0=+z and 1024=+x; forest spans several S-shaped turns.',
 '# The 81st point is an exact copy of the first, including tangent.',
 '# world mailbox 1000 X, 1001 I, 1002=2, 1004=80.',
 'store8 1000 88','store8 1001 73','store8 1002 2','store8 1004 80'
];
for(let i=0;i<=COUNT;i++){
 const [x,z]=points[i],tangent=yaw(points[i===COUNT?0:i],points[(i===COUNT?0:i)+1]);
 const base=4096+8*i;
 xi.push('store32 '+base+' '+(x+65536));
 xi.push('store32 '+(base+4)+' '+(z+65536));
 xi.push('store16 '+(5000+2*i)+' '+tangent);
 xi.push('set r0 '+x,'set r1 '+z,'print r0','print r1');
}
xi.push('halt');
const output=path.resolve(__dirname,'../reverse-os-android/app/src/main/assets/velocity/world.xi');
fs.writeFileSync(output,xi.join('\n')+'\n');
console.log('FOREST_XI_ROUTE_PASS',JSON.stringify({points:points.length,segments:COUNT,arcCm:Math.round(distance),minSegmentCm:Math.round(minSegment),maxSegmentCm:Math.round(maxSegment),minCurveRadiusCm:Math.round(minRadius),bytes:Buffer.byteLength(xi.join('\n')+'\n')}));
