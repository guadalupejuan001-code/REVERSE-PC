'use strict';
// The atlas, physical footprint, forest clearances and XI ribbon share this graph.
const {point,points,terrainHeight}=require('./open-forest-map.cjs');
const {instance}=require('./streamed-forest.cjs');
const TABLE=12000,STRIDE=24,MASK=18000;
const routes=[
 {name:'Mirador del Alba',mud:0,nodes:[[7,0],[9,2600],[11,7200],[14,12500],[17,11000],[19,5000],[22,0]]},
 {name:'Sendero del Río',mud:1,nodes:[[23,0],[24,-2700],[26,-3500],[28,-300],[30,-2800],[33,-3400],[36,0]]},
 {name:'Pinar de las Rocas',mud:0,nodes:[[39,0],[41,-4200],[44,-10000],[47,-13500],[49,-8500],[52,-3500],[55,0]]},
 {name:'Ribera de los Cedros',mud:1,nodes:[[48,0],[50,620],[54,650],[58,620],[62,0],[64,-2400],[67,-1800],[70,0]]}
].map((r,id)=>({...r,id,width:r.mud?330:360,points:r.nodes.map(([i,x])=>{const p=point(i,x);return[p[0],p[2]];})}));
const segments=[];
for(const r of routes)for(let i=0;i<r.points.length-1;i++){
 const a=r.points[i],b=r.points[i+1],n=Math.ceil(Math.hypot(b[0]-a[0],b[1]-a[1])/2200),t=new Set(Array.from({length:n+1},(_,j)=>j/n));
 for(const [,z]of points){const f=(z-a[1])/(b[1]-a[1]);if(f>0&&f<1)t.add(f);}
 const ts=[...t].sort((a,b)=>a-b);for(let j=0;j<ts.length-1;j++)segments.push({route:r.id,width:r.width,mud:r.mud,a:a.map((v,k)=>Math.round(v+(b[k]-v)*ts[j])),b:a.map((v,k)=>Math.round(v+(b[k]-v)*ts[j+1]))});
}
const pois=[['Campamento',0,0,'camp'],['Mirador del Alba',14,12500,'view'],['Vado del Río',28,-300,'ford'],['Pinar de las Rocas',47,-13500,'rocks'],['Laguna de los Cedros',56,650,'lake'],['Puente del Río',65,0,'bridge']].map(([name,i,lateral,kind])=>{const p=point(i,lateral);return{name,x:p[0],z:p[2],kind};});
function distance(x,z,s){const dx=s.b[0]-s.a[0],dz=s.b[1]-s.a[1],t=Math.max(0,Math.min(1,((x-s.a[0])*dx+(z-s.a[1])*dz)/(dx*dx+dz*dz)));const px=s.a[0]+t*dx,pz=s.a[1]+t*dz;return {squared:(x-px)**2+(z-pz)**2,x:px,z:pz};}
const blocked=[];
for(let z=0;z<80;z++)for(let x=-16;x<16;x++){
 const p=instance(x,z);if(segments.some(s=>distance(p.x,p.z,s).squared<(s.width/2+210)**2))blocked.push((z*32+x+16));
}
function worldXi(){return ['# Packed connected trail graph and vegetation clearance mask.',`store16 908 ${segments.length}`,...segments.flatMap((s,i)=>[...s.a,...s.b].map((v,k)=>`store32 ${TABLE+i*STRIDE+k*4} ${v+2000000000}`).concat([`store16 ${TABLE+i*STRIDE+16} ${s.width}`,`store8 ${TABLE+i*STRIDE+18} ${s.mud}`,`store8 ${TABLE+i*STRIDE+19} ${s.route}`,`store16 ${TABLE+i*STRIDE+20} ${32768+Math.round((s.b[1]-s.a[1])/Math.hypot(s.b[0]-s.a[0],s.b[1]-s.a[1])*s.width/2)}`,`store16 ${TABLE+i*STRIDE+22} ${32768-Math.round((s.b[0]-s.a[0])/Math.hypot(s.b[0]-s.a[0],s.b[1]-s.a[1])*s.width/2)}`])),...blocked.map(i=>`store8 ${MASK+i} 1`)];}
function atlas(){return ['RVAT1',...routes.map(r=>`T|${r.name}|${r.width}|${r.points.map(p=>p.join(',')).join(';')}`),...pois.map(p=>`P|${p.name}|${p.x}|${p.z}|${p.kind}`),`W|Laguna|${Array.from({length:14},(_,j)=>{const a=point(49+j,900),b=point(49+j,5800);return [a[0],a[2],b[0],b[2]].join(',');}).join(';')}`].join('\n')+'\n';}
// r0/r2 query point, r3 segment address; returns squared distance r4, Q20 t r5.
function distanceXi(p){return `localset 3910 r0\nlocalset 3911 r2\nload32 r6 $r3\nsub r6 2000000000\nadd r3 4\nload32 r7 $r3\nsub r7 2000000000\nadd r3 4\nload32 r8 $r3\nsub r8 2000000000\nsub r8 r6\nadd r3 4\nload32 r9 $r3\nsub r9 2000000000\nsub r9 r7\nmov r10 r8\nmul r10 r8\nmov r11 r9\nmul r11 r9\nadd r10 r11\nsub r0 r6\nsub r2 r7\nmul r0 r8\nmul r2 r9\nadd r0 r2\nmul r0 1000000\ndiv r0 r10\ncmp r0 0\njge ${p}_positive\nset r0 0\nlabel ${p}_positive\ncmp r0 1000000\njle ${p}_bounded\nset r0 1000000\nlabel ${p}_bounded\nmov r5 r0\nmul r8 r0\ndiv r8 1000000\nadd r6 r8\nmul r9 r0\ndiv r9 1000000\nadd r7 r9\nlocalget r4 3910\nsub r4 r6\nmul r4 r4\nlocalget r2 3911\nsub r2 r7\nmul r2 r2\nadd r4 r2`;}
function physicsXi(){return `store32 900 4294967295\nstore16 904 65535\nlocalset 3900 0\nlabel trail_query\nlocalget r3 3900\nmul r3 ${STRIDE}\nadd r3 ${TABLE}\nload32 r0 100\nsub r0 2000000000\nload32 r2 104\nsub r2 2000000000\n${distanceXi('trail_distance')}\nload32 r0 900\ncmp r4 r0\njge trail_query_next\nstore32 900 r4\nlocalget r0 3900\nstore16 904 r0\nlabel trail_query_next\nlocalget r0 3900\nadd r0 1\nlocalset 3900 r0\nload16 r1 908\ncmp r0 r1\njlt trail_query\nload16 r3 904\ncmp r3 65535\nje trail_surface_done\nload32 r0 900\nmul r3 ${STRIDE}\nadd r3 ${TABLE+16}\nload16 r1 $r3\ndiv r1 2\nmul r1 r1\ncmp r0 r1\njgt trail_surface_done\nstore8 489 2\nadd r3 2\nload8 r0 $r3\ncmp r0 0\nje trail_surface_done\nstore8 489 3\nlabel trail_surface_done`;}
function clearanceXi(skip){return `cmp r4 0\njlt trail_forest_clear\ncmp r4 80\njge trail_forest_clear\nmov r6 r3\nadd r6 16\ncmp r6 0\njlt trail_forest_clear\ncmp r6 32\njge trail_forest_clear\nmov r7 r4\nmul r7 32\nadd r7 r6\nadd r7 ${MASK}\nload8 r7 $r7\ncmp r7 1\nje ${skip}\nlabel trail_forest_clear`;}
module.exports={routes,segments,pois,distance,TABLE,STRIDE,MASK,worldXi,atlas,physicsXi,distanceXi,clearanceXi,blocked};
