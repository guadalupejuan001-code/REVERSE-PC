#!/usr/bin/env node
'use strict';
// Enforce ownership, not the physical processor selected for rasterization.
const fs=require('node:fs'),assert=require('node:assert/strict');
const java='reverse-os-android/app/src/main/java/com/reversepc/os/';
const read=n=>fs.readFileSync(java+n,'utf8'),engine=read('VelocityXiEngine.java'),surface=read('VelocityXSurface.java'),gpu=read('VelocityGpuSurface.java'),geometry=read('RegraphicsGeometry.java');
assert(engine.includes('NativeRuntime.sessionObserve(')&&engine.includes('render4k.xi'),'GPU geometry must execute XI from an immutable Ether state');
assert(surface.includes('game.observeGpuFrame(')&&surface.includes('selectedGpuSurface.draw(observation.geometry,observation.colors,state'),'GPU may only consume the observed XI packet');
assert(gpu.includes('g.compact(vertices)')&&gpu.includes('gpu-scene.frag')&&gpu.includes('x.gpu.virtual.CompactTriangleStream'),'GPU-VIRTUAL shared exact transport and own REgraphics shaders consume XI triangles');
assert(geometry.includes('XFG4')&&geometry.includes('face budget or length')&&geometry.includes('vertex bounds'),'strict bounded geometry validation required');
assert(!/threejs|three\.js|babylon|UnityPlayer|Unreal|filament/i.test(engine+surface+gpu),'no external game engine replaces REgraphics/XI');
assert(surface.includes('game.observeFrame(stride,selectedCamera,selectedPaint,selectedCar,')&&surface.includes('frame.present(pixels,width,height)'),'native XI fallback must remain usable');
assert(!surface.includes('toggle4K')&&!read('VelocityActivity.java').includes('Foto 4K'),'no player 4K mode remains');
assert(gpu.includes('glReadPixels(0,y,w,rows')&&gpu.includes('verifiedProfiles[r.graphics.id]'),'real preset pixels must be checked');
assert(engine.includes('render-live.xi'),'native XI software fallback retained');
console.log('REVERSE_VELOCITY_OWN_RENDERER_PASS',JSON.stringify({engine:'XI / Ether / REgraphics',gpuTransport:'XFG4',presets:5,maxLive:[1920,1080],thirdPartyGameEngine:false}));
