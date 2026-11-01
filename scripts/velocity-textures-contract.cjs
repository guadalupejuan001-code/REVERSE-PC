#!/usr/bin/env node
'use strict';
const assert=require('node:assert/strict');
const {TILES,TEXTURED_MATERIALS,carUV}=require('./velocity-textures.cjs');
assert.equal(TILES.length,8);
for(const [id,rows] of TILES.entries()){
 assert.equal(rows.length,16,'all tile rows');
 for(const row of rows)assert.match(row,/^[0-9a-f]{16}$/,'lowercase 4-bit tile');
 assert(new Set(rows.join('')).size>=2,'texture '+id+' must have distinct texels');
}
const bound=Object.values(TEXTURED_MATERIALS);
assert.equal(bound.length,3);
assert(!('paint' in TEXTURED_MATERIALS)&&!('glass' in TEXTURED_MATERIALS),
 'Body and glazing use smooth XI normals; do not reintroduce 16x16 color stippling');
assert.equal(new Set(bound.map(m=>m.id)).size,3,'separate material texture maps');
for(const entry of bound){
 assert(entry.id>=0&&entry.id<8);
 assert(entry.strength>=1&&entry.strength<=16);
}
for(const p of [[0,80,0],[100,34,138],[-100,34,-142],[0,115,-15]])
 for(const kind of Object.keys(TEXTURED_MATERIALS)){
  const uv=carUV(p,kind);
  assert.equal(uv.length,2);
  assert(uv.every(v=>Number.isInteger(v)&&v>=-32768&&v<=32767));
 }
console.log('XI_TEXTURE_ATLAS_PASS tiles=8 cells=2048 materials=3; smooth_paint_glass=true');
