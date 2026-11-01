// node tests/prisma-concert-rig.mjs
// Offline deterministic fixtures: no external audio, browser, or GPU required.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
let passed=0;
function check(value, message) { assert.ok(value,message);passed++; }
async function source(path) {
  const bytes=readFileSync(new URL(path,import.meta.url));
  return import('data:text/javascript;base64,'+bytes.toString('base64'));
}
const stage=await source('../apps/prisma/web/concert-rig.js');
const combo=await source('../apps/prisma/web/combo-spectacle.js');
const {makeConcertProgram, concertSection, concertPose, concertBeat, concertNativeParts,
  RIG_STATIONS, RIG_MAX_CUBOIDS}=stage;

const profile={ bpm:120,duration:24,tempoSegments:[{t:0,bpm:120},{t:12,bpm:140}],
  energyStep:.5,energyBins:Array.from({length:48},(_,i)=>i<12?.08:i<20?.53:i<29?.86:i<37?.24:.81)};
const program=makeConcertProgram(profile);
check(program.bars.length>=10,'Expected measured four-beat sections');
check(concertSection(program,2).kind==='quiet','Low-energy intro should remain quiet');
check(program.bars.some(s=>s.kind==='build'),'Increasing energy should activate build choreography');
check(program.bars.some(s=>s.kind==='peak'||s.kind==='impact'),'High energy should open fixtures');
check(program.bars.some(s=>s.kind==='release'),'Energy decrease should rest the rig');
check(Math.abs(concertBeat(program,12)-24)<1e-8,'Pre-transition tempo integration wrong');
check(Math.abs(concertBeat(program,15)-(24+7))<1e-8,'Tempo discontinuity');
check(concertBeat(program,12.001)>concertBeat(program,12),'Time must increase after tempo transition');

const cue={beat:1,energy:.86};
const auto=concertPose(program,13,cue,{quality:'auto'});
const high=concertPose(program,13,cue,{quality:'high'});
const battery=concertPose(program,13,cue,{quality:'battery'});
const quiet=concertPose(program,2,{beat:0,energy:.08},{quality:'auto'});
check(auto.fixtures.length===6 && high.fixtures.length===6,'Six stage heads missing');
check(battery.fixtures.length===2,'Battery mode must use one stage head per side');
check(quiet.intensity<auto.intensity,'The rig must respond to real musical energy');
check(RIG_STATIONS.length===6,'Incorrect installed fixture map');
check(new Set(auto.fixtures.map(f=>f.id)).size===6,'Duplicate fixture IDs');
check(auto.fixtures.every(f=>Number.isFinite(f.head.x)&&Number.isFinite(f.head.y)&&Number.isFinite(f.head.z)), 'Invalid joint pose');
check(auto.fixtures.every(f=>f.head.z>=0 && f.focus.z>=0),'Stage fixture behind the camera');
check(auto.fixtures.every(f=>Math.abs(f.focus.x)>=.55),'Beams must avoid central hit target');

const replay=concertPose(program,13,cue,{quality:'auto'});
assert.deepEqual(auto,replay);passed++;
const next=concertPose(program,13.2,cue,{quality:'auto'});
check(auto.fixtures.some((f,i)=>Math.abs(f.head.x-next.fixtures[i].head.x)>.0001), 'Moving heads must actually animate');
const reducedA=concertPose(program,13,cue,{quality:'auto',reduced:true});
const reducedB=concertPose(program,14.7,cue,{quality:'auto',reduced:true});
check(reducedA.fixtures.every((f,i)=>Math.abs(f.head.x-reducedB.fixtures[i].head.x)<.000001),'Reduced motion should freeze physical heads');
check(reducedA.intensity<=.07,'Reduced motion keeps light intensity soft');

check(concertNativeParts(auto,64).length===12,'Auto mode needs heads and mounts');
check(concertNativeParts(high,64).length===18,'High mode adds elbow joints');
check(concertNativeParts(battery,64).length===2,'Battery native budget must stay small');
for(const budget of [0,1,2,6,12,18,40,64]) {
  const parts=concertNativeParts(high,budget);
  check(parts.length===Math.min(budget,18),'Rig exceeded render budget '+budget);
  check(parts.every(p=>p.direction===-1),'Mechanical parts must not show arrow textures');
  check(parts.every(p=>p.x>=-100&&p.x<=100&&p.y>=-100&&p.y<=100&&p.z>=-4&&p.z<=100&&p.size>=.05&&p.size<=5&&p.alpha>=0&&p.alpha<=1),'Native body out of bounds');
}
const headFirst=concertNativeParts(high,4);
check(headFirst.every(p=>p.kind==='head'),'Lighting mounts are lower priority than lens heads');
check(RIG_MAX_CUBOIDS===64,'Native RXE3 renderer contract changed');
const fallback=makeConcertProgram({bpm:122,duration:20,fallback:true,energyBins:[.9],energyStep:20});
check(concertSection(fallback,10).kind==='quiet','Synthetic fallback must not stage a dramatic drop');
const previews=makeConcertProgram(null);
check(concertPose(previews,2,{beat:.3,energy:.3},{quality:'auto'}).fixtures.length===6,'Home preview needs functioning stage');

const text=readFileSync(new URL('../apps/prisma/web/engine.js',import.meta.url),'utf8')
  .replace(/^import .*;$/gm,'').replace(/^export /gm,'');
const Scene=new Function('makeConcertProgram','concertPose','concertNativeParts',
  'RIG_MAX_CUBOIDS','MusicStageDirector','makeIntelligentChart','seeded','CubeGPU','NativeXRender',
  'createSpectacleEvent','pruneSpectacles','spectacleEnvelope','spectacleGeometry','SPECTACLE_MAX_EVENTS',
  text+';return Scene;')(makeConcertProgram,concertPose,concertNativeParts,RIG_MAX_CUBOIDS,
  class{},()=>[],()=>()=>.5,{},{},
  combo.createSpectacleEvent,combo.pruneSpectacles,combo.spectacleEnvelope,
  combo.spectacleGeometry,combo.SPECTACLE_MAX_EVENTS); // Constructor intentionally bypassed.
const scene=Object.create(Scene.prototype);
const drawn=[],canvas={dataset:{}};
scene.gpu={native:true,count:63,cube:(...p)=>{drawn.push(p);scene.gpu.count++;}};
scene.canvas=canvas;scene.rgb=[[.4,1,.7],[1,.4,.7]];
scene.stageRig(high);
check(drawn.length===1 && scene.gpu.count===64,'Notes cannot lose their last native slot to decoration');
check(canvas.dataset.rigNativeCount==='1','Rig metrics should report actual submitted geometry');
check(drawn[0][7]===-1,'Native fixture material code must be arrowless');
scene.gpu.count=64;scene.stageRig(high);
check(drawn.length===1,'Native overflow dropped a note due to lights');
scene.gpu.count=5;scene.stageRig(auto);
check(scene.gpu.count===17,'Preview should use five notes and twelve mechanical parts');
const events=[],gradient={addColorStop:(...args)=>events.push(['gradient',...args])};
const ctx={
  save:()=>{},restore:()=>{},beginPath:()=>{},closePath:()=>{},moveTo:()=>{},lineTo:()=>{},
  arc:()=>{},ellipse:()=>{},fill:()=>events.push('fill'),stroke:()=>events.push('stroke'),
  fillRect:()=>events.push('fillRect'),strokeRect:()=>events.push('strokeRect'),
  createLinearGradient:()=>gradient
};
scene.settings=()=>({palette:'coral'});scene.width=880;scene.height=440;
scene.stageExplosions=[combo.createSpectacleEvent({t:13,combo:20,strength:.9,drop:false})];
scene.drawStageFX(ctx,13.1,false,cue,auto);
check(events.includes('stroke')&&events.some(e=>Array.isArray(e)&&e[0]==='gradient'),'Mechanical arm/beams not drawn');
check(events.every(e=>!Array.isArray(e)||e[0]!=='gradient'||e[2]!==undefined),'Invalid beam gradient');
scene.gpu=null;scene.stageExplosions=[];
scene.drawStageFX(ctx,14,false,cue,battery);
check(events.includes('strokeRect'),'Fallback housing missing without native/WebGL');
scene.stageExplosions=[];
scene.drawStageFX(ctx,14,false,cue,reducedA);
check(events.includes('stroke'),'Reduced-motion drawing path failed');

// Full native render regression: if 80 visible notes compete with the 64-body
// packet, nearest playable notes must win over far notes and every stage body.
const gameplay=Object.create(Scene.prototype);
const submitted=[];
gameplay.gpu={
  native:true,count:0,quality:0,
  begin:()=>{gameplay.gpu.count=0;},
  cube:(...values)=>{if(gameplay.gpu.count>=64)return;
    submitted.push(values);gameplay.gpu.count++;},
  flush:()=>{}
};
gameplay.canvas={width:880,height:440,dataset:{}};
gameplay.ctx={...ctx,clearRect:()=>{},setTransform:()=>{},translate:()=>{}};
gameplay.settings=()=>({palette:'coral',quality:'auto',effects:true});
gameplay.width=880;gameplay.height=440;gameplay.dpr=1;
gameplay.paletteKey='';gameplay.rgb=[];gameplay.view=new Float32Array(4);
gameplay.energy=0;gameplay.pulse=0;gameplay.shake=0;gameplay.diagnostics=false;
gameplay.musicStage=null;gameplay.concertProgram=previews;
// Mocked Scene skips constructor; initialize the exact visual-governor state
// it receives in production before calling render().
gameplay.visualState={quality:'balanced',slowFrames:0,fastFrames:0,cooldownUntil:0};
gameplay.stageExplosions=[];gameplay.particles=[];gameplay.shards=[];gameplay.trails=new Map();
const packed=Array.from({length:80},(_,i)=>({
  t:1+i*.03,lane:1,row:0,color:0,dir:0,hit:false,missed:false
}));
gameplay.render(1,1/60,packed,false,0,0,true);
check(submitted.length===64,'Expected 64 playable native notes');
check(Math.abs(submitted[0][2])<1e-8,'Closest note should render first');
check(submitted.every(n=>n[7]!==-1),'Mechanical decorations displaced playable notes');
check(gameplay.canvas.dataset.rigNativeCount==='0','Decoration should be trimmed at body cap');

console.log(JSON.stringify({suite:'prisma-concert-rig',passed,bars:program.bars.length,
  fixtures:auto.fixtures.length,nativeAuto:concertNativeParts(auto).length,
  nativeHigh:concertNativeParts(high).length,nativeBattery:concertNativeParts(battery).length}));
