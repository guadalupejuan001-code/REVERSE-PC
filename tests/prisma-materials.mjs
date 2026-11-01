// Run with: node tests/prisma-materials.mjs
// ABI/material routing tests without a GPU; native geometric exactness is
// separately verified in tests/prisma_xrender.cpp.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
let passed=0;
const check=(truth,why)=>{assert.ok(truth,why);passed++};
async function readModule(name){
 const bytes=readFileSync(new URL('../apps/prisma/web/'+name,import.meta.url));
 return import('data:text/javascript;base64,'+bytes.toString('base64'));
}
const native=await readModule('native-xrender.js');
const stage=await readModule('concert-rig.js');
const modern=new native.NativeXRender(true),legacy=new native.NativeXRender(false);
const view=new Float32Array([.5,.49,.8,1.6]),colors=[[.4,1,.7],[1,.35,.6]];
const append=(renderer,material)=>{renderer.begin(1,.5,view,colors,false);
 renderer.cube(0,0,3,.73,colors[0],.95,.1,0,true,material);
 renderer.data[15]=renderer.count;
 return Array.from(renderer.data.slice(0,28));
};
for(const m of [0,1,2,3]){
 const packet=append(modern,m);
 check(packet.length===28,'12-float descriptor/16-float header changed');
 check(packet[0]===2&&packet[27]===m,'v2 native material not encoded '+m);
 check(packet[25]===0&&packet[26]===1,'cut direction and hot flag changed');
}
const packetLegacy=append(legacy,3);
check(packetLegacy[0]===1&&packetLegacy[27]===0,'legacy host must emit ABI v1 only');
const originalGlobalWindow=globalThis.window,originalGlobalDocument=globalThis.document;
try {
 globalThis.document={documentElement:{classList:{add:()=>{}}}};
 globalThis.window={ReverseGraphics:{xRender:()=> 'ether-render-x-cuboids-v1',
   xRenderMaterials:()=> 'prisma-materials-v2'}};
 check(native.NativeXRender.create()?.version===2,'new host must enable materials');
 globalThis.window={ReverseGraphics:{xRender:()=> 'ether-render-x-cuboids-v1'}};
 check(native.NativeXRender.create()?.version===1,'old host must retain native cubes');
 globalThis.window={ReverseGraphics:{xRender:()=> 'invalid'}};
 check(native.NativeXRender.create()===null,'unsupported host must not claim Ether X');
}finally{
 if(originalGlobalWindow===undefined)delete globalThis.window;else globalThis.window=originalGlobalWindow;
 if(originalGlobalDocument===undefined)delete globalThis.document;else globalThis.document=originalGlobalDocument;
}
const code=readFileSync(new URL('../apps/prisma/web/engine.js',import.meta.url),'utf8')
 .replace(/^import .*;$/gm,'').replace(/^export /gm,'');
const Scene=new Function('CubeGPU','NativeXRender','seeded','MusicStageDirector','makeIntelligentChart',
  'makeConcertProgram','concertPose','concertNativeParts','RIG_MAX_CUBOIDS',
  'createSpectacleEvent','pruneSpectacles','spectacleEnvelope','spectacleGeometry','SPECTACLE_MAX_EVENTS',
  code+';return Scene;')({},{},()=>()=>.5,class{},()=>[],
  stage.makeConcertProgram,stage.concertPose,stage.concertNativeParts,
  stage.RIG_MAX_CUBOIDS,()=>null,()=>[],()=>0,()=>null,3);
const scene=Object.create(Scene.prototype),calls=[];
scene.gpu={native:true,count:0,cube:(...args)=>{calls.push(args);scene.gpu.count++}};
scene.canvas={dataset:{}};scene.rgb=colors;
scene.settings=()=>({palette:'coral',quality:'high'});
scene.width=880;scene.height=440;
scene.cube(0,0,2,.73,0,1,0,false,true,1);
check(calls[0][9]===1,'playable notes must use faceted material');
const pose=stage.concertPose(stage.makeConcertProgram(null),1,{energy:.5,beat:.9},{quality:'high'});
scene.stageRig(pose);
check(calls.filter(c=>c[9]===3).length===6,'concert heads should use emissive lens material');
check(calls.filter(c=>c[9]===2).length===12,'concert arms should use alloy material');
check(calls.every(c=>c[7]>=-1&&c[7]<=3),'invalid cut-material direction');
scene.gpu.count=63;calls.length=0;
scene.stageRig(pose);
check(calls.length===1,'stage body budget exceeded when notes fill native packet');
scene.gpu.count=0;calls.length=0;
scene.settings=()=>({quality:'battery'});
scene.cube(0,0,2,.73,0,1,0,false,true,1);
check(calls[0][9]===0,'battery should skip expensive faceted shader');
const battery=stage.concertPose(stage.makeConcertProgram(null),1,{energy:.5},{quality:'battery'});
scene.stageRig(battery);
check(calls.length===3 && calls.slice(1).every(c=>c[9]===0),
 'battery should use legacy material and two heads');
const shaders=readFileSync(new URL('../apps/prisma/web/gpu-scene.js',import.meta.url),'utf8');
check(shaders.includes('vMaterial=rotationDirection.w;'),'WebGL material instance attribute not bound');
check(shaders.includes('vMaterial<2.5'),'WebGL alloy material missing');
const bridge=readFileSync(new URL('../reverse-os-android/app/src/main/java/com/reversepc/os/RxeGraphicsActivity.java',import.meta.url),'utf8');
check(bridge.includes('xRenderMaterials(){return "prisma-materials-v2";}'),
 'Android host capability negotiation missing');
console.log(JSON.stringify({suite:'prisma-materials',passed,version:2,
 materials:['legacy','faceted','alloy','lens']}));
