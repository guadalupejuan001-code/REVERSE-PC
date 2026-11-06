#!/usr/bin/env node
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),crypto=require('node:crypto');
const lock=JSON.parse(fs.readFileSync('docs/GPU_VIRTUAL_INTEGRATION_LOCK.json','utf8'));
assert.equal(lock.repository,'guadalupejuan001-code/GPU-VIRTUAL');
assert.match(lock.commit,/^[0-9a-f]{40}$/);
const source=fs.readFileSync(lock.vendoredPath);
assert.equal(crypto.createHash('sha256').update(source).digest('hex'),lock.sha256,'shared GPU-VIRTUAL source differs from pinned revision');
if(process.argv[2])assert(source.equals(fs.readFileSync(path.join(process.argv[2],lock.upstreamPath))),'game must execute the exact upstream GPU-VIRTUAL component');
const gpu=fs.readFileSync('reverse-os-android/app/src/main/java/com/reversepc/os/VelocityGpuSurface.java','utf8');
assert(gpu.includes('new CompactTriangleStream()')&&gpu.includes('g.compact(vertices)'),'shared code must run in the drawing path');
assert(gpu.includes('vertices.uploadCount()')&&gpu.includes('vertices.view(offset,length)'),'shared dirty ranges must drive real GPU uploads');
assert(gpu.includes('vertices.invalidateGpuCopy()'),'context restoration must invalidate GPU data');
console.log('VELOCITY_GPU_VIRTUAL_LOCK_PASS '+JSON.stringify({commit:lock.commit,sha256:lock.sha256,vertexBytes:lock.gpuVertexBytes}));
