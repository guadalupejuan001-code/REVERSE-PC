'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const graph=require('./forest-trails.cjs'),mesh=require('./forest-trail-mesh.cjs'),world=require('./open-forest-map.cjs');
let minGap=Infinity,maxGap=-Infinity,maxVisible=0;
for(const t of mesh.triangles)for(const weights of [[1,0,0],[0,1,0],[0,0,1],[.5,.5,0],[0,.5,.5],[.5,0,.5],[1/3,1/3,1/3]]){
 const x=t.p.reduce((s,p,i)=>s+p.x*weights[i],0),z=t.p.reduce((s,p,i)=>s+p.z*weights[i],0),y=t.p.reduce((s,p,i)=>s+p.y*weights[i],0),gap=y-world.terrainHeight(z,x);minGap=Math.min(minGap,gap);maxGap=Math.max(maxGap,gap);
 assert(gap>=1&&gap<8,'ribbon must follow the physical field without clipping or floating: '+gap);
}
for(const s of graph.segments)for(let n=0;n<=5;n++){
 const x=s.a[0]+(s.b[0]-s.a[0])*n/5,z=s.a[1]+(s.b[1]-s.a[1])*n/5;
 const visible=mesh.triangles.filter(t=>(t.p[0].x-x)**2+(t.p[0].z-z)**2<=49000000).length;maxVisible=Math.max(maxVisible,visible);
}
assert(maxVisible<=112,'all nearby trail geometry must fit without dropped pieces');
assert(graph.TABLE+graph.STRIDE*graph.segments.length<graph.MASK,'trail graph does not overlap mask');
assert(mesh.TABLE+mesh.STRIDE*mesh.triangles.length<65536,'packed trail geometry stays inside the validated world memory');
for(const r of graph.routes){assert(r.points.length>=6);for(const p of [r.points[0],r.points.at(-1)])assert(world.points.some(q=>Math.hypot(q[0]-p[0],q[1]-p[1])<2),'trail reconnects to asphalt');}
const report={passed:true,routes:graph.routes.length,places:graph.pois.length,segments:graph.segments.length,lengthMeters:graph.segments.reduce((n,s)=>n+Math.hypot(s.b[0]-s.a[0],s.b[1]-s.a[1]),0)/100,joinedClippedTriangles:mesh.triangles.length,maxVisibleTriangles:maxVisible,minSurfaceGapCm:minGap,maxSurfaceGapCm:maxGap,blockedForestCells:graph.blocked.length};
if(process.argv[2]){fs.mkdirSync(process.argv[2],{recursive:true});fs.writeFileSync(path.join(process.argv[2],'trail-geometry-results.json'),JSON.stringify(report,null,2)+'\n');}
console.log('FOREST_TRAIL_GEOMETRY_PASS',JSON.stringify(report));
