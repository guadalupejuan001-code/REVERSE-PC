#!/usr/bin/env node
'use strict';
const fs=require('node:fs');
const path=require('node:path');
const assert=require('node:assert/strict');
const java='reverse-os-android/app/src/main/java/com/reversepc/os/';
const files=['VelocityActivity.java','VelocityXSurface.java','VelocityXiEngine.java'];
const src=Object.fromEntries(files.map(n=>[n,fs.readFileSync(path.join(java,n),'utf8')]));
const game=Object.values(src).join('\n');
assert(!/\bandroid\.opengl\b|EGL14|GLES30|GLSurfaceView|VelocityGpuPresenter|VelocityGpuFrame|VelocityMaterialShader|attachGpuSurface/.test(game),
 'REVERSE VELOCITY must not invoke an external GPU rasterizer');
assert(src['VelocityXSurface.java'].includes('game.observeFrame(stride,selectedCamera,selectedPaint,selectedCar)'),
 'REgraphics XI source must own scene rendering');
assert(src['VelocityXSurface.java'].includes('frame.present(pixels,width,height)'),
 'Only XI XFS1/XFB5 pixels may be handed to Android');
assert(src['VelocityActivity.java'].includes('Motor XI'),
 'in-game renderer capabilities dialog must be reachable');
assert(src['VelocityActivity.java'].includes('XFB5 escala el trabajo por resolución'),
 '4K renderer limits must be clearly explained in the application');
assert(fs.existsSync('reverse-os-android/app/src/main/assets/velocity/render.xi'),
 'XI original scene asset missing');
// Original 3840x2160 geometry capture is retained as XI research, not as an active
// graphics API. The playable Android renderer never consumes XFG4.
assert(src['VelocityXiEngine.java'].includes('render-native4k.xi'),
 'Native 4K must execute its own XI raster program');
assert(src['VelocityXSurface.java'].includes('observeNative4KFrame(') &&
  src['VelocityXSurface.java'].includes('selectedCamera,selectedPaint,selectedCar'),
  'Original XI car camera/material/carbodies must render in both paths');
assert(src['VelocityXSurface.java'].includes('observeNative4KFrame('),
 'Native 4K frame request must go through XI, not GPU');
assert(!src['VelocityXiEngine.java'].includes('render4k.xi'),
 'render4k geometry capture should not masquerade as playable 4K raster');
const leftOver=['VelocityGpuPresenter.java','VelocityMaterialShader.java','VelocityGpuFrame.java'];
for(const n of leftOver)
 assert(!fs.existsSync(path.join(java,n)),
  'No GLES3 game backend may be compiled: '+n);
console.log('REVERSE_VELOCITY_OWN_RENDERER_PASS',JSON.stringify({
 engine:'XI / REgraphics',frameTransport:'XFS1/XFB5',maxNativeRaster:[3840,2160],
 thirdPartyGpuRasterizer:false,androidDisplayOnly:true}));
