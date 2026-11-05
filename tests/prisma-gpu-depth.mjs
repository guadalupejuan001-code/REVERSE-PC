import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {execFileSync} from 'node:child_process';
const load=async name=>import('data:text/javascript;base64,'+readFileSync(new URL('../apps/prisma/web/'+name,import.meta.url)).toString('base64'));
const [models,gpu,native,flow,music,qa]=await Promise.all(['world-model.js','gpu-scene.js','native-xrender.js','note-flow.js','music-stage.js','rhythm-qa.js'].map(load));
let passed=0;const check=(v,s)=>{assert.ok(v,s);passed++;};
const stats=[];
for(let world=0;world<5;world++){
 const data=models.worldModel(world);let finite=true,normals=true;const min=[Infinity,Infinity,Infinity],max=[-Infinity,-Infinity,-Infinity];
 for(let i=0;i<data.length;i+=12){for(let j=0;j<12;j++)finite&&=Number.isFinite(data[i+j]);const n=Math.hypot(...data.subarray(i+3,i+6));normals&&=Math.abs(n-1)<.001;for(let j=0;j<3;j++){min[j]=Math.min(min[j],data[i+j]);max[j]=Math.max(max[j],data[i+j]);}}
 check(data===models.worldModel(world),'World model rebuilds every frame');check(data.length<=models.WORLD_MODEL_LIMIT&&data.length%36===0,'Triangle upload budget violated');
 check(finite&&normals,'Invalid mesh coordinates/normals');check(max[2]-min[2]>40&&max[0]-min[0]>10,'World is a flat decorative plane');
 check(data.length/36>5000,'Detailed world geometry is missing');stats.push(models.worldModelStats(world));
}
const mesh=gpu.noteGeometry();check(mesh.vertices.length/6>24&&mesh.indices.length>36,'Notes have no geometric bevels');
check(Math.max(...mesh.indices)<mesh.vertices.length/6,'Broken note mesh index');check([...mesh.vertices].every(Number.isFinite),'Nonfinite beveled note');
execFileSync(process.execPath,['scripts/build-prisma-gpu-shaders.mjs','src/prisma_gpu_shaders.hpp','--check'],{cwd:new URL('..',import.meta.url)});check(true,'Native/WebGL shader parity');
for(const bpm of [60,120,185,260])for(const level of ['flow','pulse','vertigo'])check(flow.approachSeconds(bpm,level)>=2.7,'Fast tempo collapses reading time');
const notes=[{t:4,dir:0},{t:4,dir:2},{t:4.2,dir:1},{t:4.5,dir:3}];
check(flow.arrivalQueue(notes,.41,0,3.6).filter(x=>x.rank===1).length===2,'Simultaneous hits receive different order');
check(flow.arrivalQueue(notes,4.23,0,3.6)[0].note===notes[0],'Pending late note silently disappeared before judgement');
notes[0].hit=true;notes[1].missed=true;check(flow.arrivalQueue(notes,4.23,0,3.6)[0].note===notes[2],'Judged note stayed first in order');
notes[2].holding=true;check(flow.arrivalQueue(notes,4.23,0,3.6)[0].note===notes[3],'Active hold hides the next cut');
const crowded=Array.from({length:8},(_,i)=>({note:{t:i*.1,lane:1},rank:Math.floor(i/2)+1}));
const badges=[...flow.orderBadgePositions(crowded,()=>({x:500,y:220,s:100}),1000).values()];
check(badges.length===8,'Double-note order badge missing');
check(badges.every((a,i)=>badges.every((b,j)=>i===j||Math.hypot(a.x-b.x,a.y-b.y)>=21)),'Order numbers overlap in a dense sequence');
check(badges.every(b=>b.x>=14&&b.x<=986),'Order badge is outside the screen');
const stack=[{t:1,lane:1,row:1,dir:0},{t:1.13,lane:1,row:1,dir:0}],project=()=>({x:100,y:100,s:80});
check(qa.nearestSwipeNote(stack,1.12,0,'flow',100,100,100,100,project,{isTap:true})===stack[0],'Later note stole a tap from the first cube in the same target');
check(qa.nearestKeyNote(stack,1.12,0,'flow',0)===stack[0],'Keyboard order differs from visible order');
stack[0].hit=true;check(qa.nearestKeyNote(stack,1.12,0,'flow',0)===stack[1],'Stack did not advance after the first hit');
for(const t of [0,2,3.8,4,4.23]){const m=flow.noteMotion({t:4},t,0,4);check(m.alpha>=.35&&m.z>=0,'Unjudged note vanishes or passes behind the camera');}
const peaks=Array.from({length:20000},(_,i)=>({t:.025+i*.005,strength:1,source:'percussion'}));
const map=music.makeMusicStage(peaks,{bpm:260,duration:101,energy:Array(2020).fill(1)});
const chart=music.makeIntelligentChart(peaks,'vertigo',7721,map);let worst=0;
for(let t=0;t<80;t+=.1){const count=flow.arrivalQueue(chart,t,0,5.2).length;worst=Math.max(worst,count);}
check(worst>64&&worst<=128,'Dense chart is not representable by the GPU packet');
const old=globalThis.window;const uploads=[];globalThis.window={ReverseGraphics:{model:(id,data)=>uploads.push({id,length:data.length})}};
try{
 const n=new native.NativeXRender(true,true);const view=new Float32Array([.5,.49,.6,1.2]),colors=[[.2,1,.7],[1,.3,.5]];
 n.prepareWorld(0,models.worldModel(0));n.prepareWorld(0,models.worldModel(0));check(uploads.length===1,'Static geometry uploaded again');
 n.begin(1,.5,view,colors,false);n.setWorld(4,2,.4,2,.7);for(let i=0;i<140;i++)n.cube(0,0,3,.64,colors[0],1,0,0,false,1);
 check(n.count===128&&n.data[0]===3,'GPU path kept the legacy 64-note truncation');check(((n.data[14]>>2)&7)===4&&((n.data[14]>>5)&7)===3,'World transition packet damaged');
 const legacy=new native.NativeXRender(true);legacy.begin(1,.5,view,colors,false);for(let i=0;i<140;i++)legacy.cube(0,0,3,.64,colors[0],1,0,0,false,1);check(legacy.count===64&&legacy.data[0]===2,'Legacy CPU packet contract changed');
}finally{if(old===undefined)delete globalThis.window;else globalThis.window=old;}
console.log(JSON.stringify({suite:'prisma-gpu-depth',passed,models:stats,beveledNoteTriangles:mesh.indices.length/3,densestVisibleNotes:worst,nativeCapacity:128,minReadAhead:2.7}));
