#!/usr/bin/env node
'use strict';
// This is an authored mesh contract, not an image-generation comparison.
const assert=require('node:assert/strict');
const {buildCarMesh,MATERIALS}=require('./velocity-car-mesh.cjs');
const {buildPalette,RAMPS}=require('./velocity-materials.cjs');
const p=buildPalette();
const luma=h=>{const [r,g,b]=[0,2,4].map(i=>parseInt(h.slice(i,i+2),16));return .2126*r+.7152*g+.0722*b;};
assert.equal(p.length,256,'XFS1 palette stays eight bit');
assert.deepEqual(RAMPS.aero,{base:228,count:12});
assert(luma(p[83])>luma(p[239]),'white pearl should be brighter than dark aero');
assert(luma(p[228])<38,'matte aero must remain dark');
assert.equal(p[240],'343d47','visible panel seam material');
assert.equal(p[241],'596977','bright metallic character line material');
const report={};
for(const detail of ['high','medium','far']){
 const m=buildCarMesh(detail);
 assert.deepEqual(m.bounds.size,[200,115,453],'model scale in centimeters');
 assert.equal(m.landmarks.wheelbase,280);
 assert.equal(m.landmarks.wheelParts.length,4);
 assert.equal(m.landmarks.wheelRadius,34);
 const taillights=m.faces.filter(f=>f.material==='lampRed');
 assert.equal(taillights.length,2,'single continuous rear red blade');
 const coords=taillights.flatMap(f=>f.indices.map(i=>m.vertices[i][0]));
 assert(Math.min(...coords)<=-81&&Math.max(...coords)>=81,'red LED spans rear width');
 assert.equal(m.faces.filter(f=>f.material==='lampWhite').length,2,'continuous front light bar');
 assert((m.groups.canopy||[]).length>0,'fully glazed roof');
 assert(!(m.groups.exhaust||[]).length,'no exhaust for electric car');
 assert(m.faces.filter(f=>f.material==='aero').length>=2,'sculpted dark aero');
 assert.equal((m.groups.sideSills||[]).length,detail==='high'?16:detail==='medium'?8:0);
 const highDetail={doorSeams:8,canopyTrim:4,sideCrease:4,diffuserFins:8,rearVent:2,rearCorner:4};
 for(const [group,expected] of Object.entries(highDetail))
  assert.equal((m.groups[group]||[]).length,detail==='high'?expected:0,
    'actual RV-01 high-LOD detail geometry '+group);
 for(const f of m.faces){
  assert(f.indices.every(i=>i>=0&&i<m.vertices.length),'mesh indices');
  assert(MATERIALS.includes(f.material),'known material');
  assert.equal(f.normals.length,3);
  assert(f.normals.every(n=>n.length===3&&n.every(Number.isFinite)),'finite face normals');
 }
 for(const w of m.landmarks.wheelParts)
  assert(w.faces.length>0&&w.faces.every((idx,i)=>i===0||idx===w.faces[i-1]+1),
    'animated wheel topology must be contiguous');
 report[detail]={triangles:m.faces.length,vertices:m.vertices.length};
}
assert(report.high.triangles<900&&report.medium.triangles<320&&report.far.triangles<120);
console.log('RV01_MODEL_GEOMETRY_PASS',JSON.stringify(report));
