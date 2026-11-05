#!/usr/bin/env node
'use strict';
// Enforce ownership, not the physical processor selected for rasterization.
const fs=require('node:fs'),assert=require('node:assert/strict');
const java='reverse-os-android/app/src/main/java/com/reversepc/os/';
const read=n=>fs.readFileSync(java+n,'utf8'),engine=read('VelocityXiEngine.java'),surface=read('VelocityXSurface.java'),gpu=read('VelocityGpuSurface.java'),geometry=read('RegraphicsGeometry.java');
assert(engine.includes('NativeRuntime.observeGeometry(')&&engine.includes('render4k.xi'),'GPU geometry must execute XI from an immutable Ether state');
assert(surface.includes('game.observeGpuFrame(')&&surface.includes('selectedGpuSurface.draw(observation.geometry,observation.colors,state'),'GPU may only consume the observed XI packet');
assert(gpu.includes('g.vertices(vertices)')&&gpu.includes('gpu-scene.frag'),'own REgraphics shaders consume XI triangles');
assert(geometry.includes('XFG4')&&geometry.includes('face budget or length')&&geometry.includes('vertex bounds'),'strict bounded geometry validation required');
assert(!/threejs|three\.js|babylon|UnityPlayer|Unreal|filament/i.test(engine+surface+gpu),'no external game engine replaces REgraphics/XI');
assert(surface.includes('game.observeFrame(stride,selectedCamera,selectedPaint,selectedCar,')&&surface.includes('frame.present(pixels,width,height)'),'native XI fallback must remain usable');
assert(surface.includes('game.observeNative4KFrame(')&&gpu.includes('glReadPixels(0,0,w,h')&&gpu.includes('w*h*4')&&gpu.includes('nativePhoto?3840')&&gpu.includes('nativePhoto?2160'),'both photo backends must produce actual 4K pixels');
assert(surface.includes('paused=true;')&&read('VelocityActivity.java').includes('Foto 4K pausa la conducción'),'photo must freeze driving');
assert(engine.includes('render-live.xi')&&engine.includes('render-native4k.xi'),'software oracle and native path retained');
console.log('REVERSE_VELOCITY_OWN_RENDERER_PASS',JSON.stringify({engine:'XI / Ether / REgraphics',gpuTransport:'XFG4',cpuTransport:'XFS1/XFB5',maxPhoto:[3840,2160],thirdPartyGameEngine:false}));
