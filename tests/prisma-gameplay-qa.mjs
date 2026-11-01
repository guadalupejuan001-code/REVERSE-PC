// node tests/prisma-gameplay-qa.mjs
// Deterministic gameplay, clock and adaptive-FX regression suite.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {performance} from 'node:perf_hooks';
let passed=0;
const test=(yes,label)=>{assert.ok(yes,label);passed++};
const load=async filename=>{
  const body=readFileSync(new URL('../apps/prisma/web/'+filename,import.meta.url));
  return import('data:text/javascript;base64,'+body.toString('base64'));
};
const qa=await load('rhythm-qa.js');
const {nextVisualQuality,visualBudget}=await load('performance-policy.js');
const demo=readFileSync(new URL('../apps/prisma/web/audio.js',import.meta.url),'utf8')
  .replace(/^export \{.*$/gm,'').replace(/^export /gm,'');
const {RhythmAudio}=new Function(demo+';return {RhythmAudio};')();

test(Math.abs(qa.hitWindowFor('flow')-.32)<1e-8,'Flow timing contract changed');
test(Math.abs(qa.hitWindowFor('pulse')-.265)<1e-8,'Pulse timing contract changed');
test(Math.abs(qa.hitWindowFor('vertigo')-.225)<1e-8,'Vertigo timing contract changed');
test(qa.segmentDistance(0,0,-10,0,10,0)===0,'Segment crossing wrong');
test(qa.segmentDistance(5,5,5,5,5,5)===0,'Degenerate touch point wrong');
const p=n=>({x:n.lane===0?100:220,y:100,s:90});
const first={t:1,dir:0,lane:0,hit:false,missed:false};
const second={t:1.18,dir:0,lane:2,hit:false,missed:false};
const chart=[first,second];
test(qa.nearestSwipeNote(chart,1.17,0,'pulse',220,130,220,80,p,{precise:true})===second,
  'Swipe must pick the closest note rather than the oldest in a busy hit window');
test(qa.nearestSwipeNote(chart,1.03,0,'pulse',100,130,100,80,p,{precise:true})===first,
  'Early swipe picked wrong note');
test(qa.nearestSwipeNote(chart,1.17,0,'pulse',220,100,220,150,p,{precise:true})===null,
  'Precise direction should reject backward strokes');
test(qa.nearestSwipeNote(chart,1.17,0,'pulse',220,100,220,150,p,{precise:false})===second,
  'Non-precise mode should preserve permissive hits');
test(qa.nearestSwipeNote(chart,1.17,0,'pulse',220,100,220,100,p,{isTap:true})===null,
  'Touch taps only allowed in Flow');
test(qa.nearestSwipeNote(chart,1.17,0,'flow',220,100,220,100,p,{isTap:true})===second,
  'Flow tap gesture no longer works');
test(qa.nearestSwipeNote(chart,1.17,0,'flow',220,100,220,100,p,{isTap:true,precise:true})===null,
  'Precise setting must forbid tap shortcuts');
test(qa.nearestSwipeNote(chart,1.17,0,'flow',300,300,320,300,p)===null,
  'Touch outside a note should not count');
test(qa.nearestSwipeNote(chart,1.5,0,'pulse',220,130,220,80,p)===null,
  'Expired note must not be hit');
test(qa.nearestSwipeNote(chart,1.17,-.10,'pulse',220,130,220,80,p,{precise:true})===second,
  'Negative latency calibration misapplied');
second.hit=true;
test(qa.nearestSwipeNote(chart,1.17,0,'pulse',220,130,220,80,p,{precise:true})===null,
  'Already hit note selected again');
second.hit=false;second.missed=true;
test(qa.nearestSwipeNote(chart,1.17,0,'pulse',220,130,220,80,p,{precise:true})===null,
  'Missed note selected again');second.missed=false;
test(qa.nearestKeyNote(chart,1.16,0,'pulse',0)===second,
  'Keyboard picker should prefer the closest timestamp');
test(qa.nearestKeyNote(chart,1.16,0,'pulse',1)===null,
  'Keyboard accepted incorrect arrow');
second.hit=true;
test(qa.nearestKeyNote(chart,1.16,0,'pulse',0)===first,
  'Keyboard did not fall back to next available note');second.hit=false;
test(!qa.isEndOfSong(60.01,60,'flow',0),
  'Session ends before final cut is judged');
test(!qa.isEndOfSong(60.42,60,'vertigo',.20),
  'Positive Bluetooth latency requires more final-song grace');
test(qa.isEndOfSong(60.60,60,'vertigo',.20),
  'Session failed to stop after the permitted tail');
test(qa.isEndOfSong(60.42,60,'vertigo',-.20),
  'Negative latency must not add artificial end delay');
test(qa.timingLabel(.22,false,true)==='ANTICIPADO','Early timing cue wrong');
test(qa.timingLabel(-.22,false,true)==='TARDE','Late timing cue wrong');
test(qa.timingLabel(.02,true,true)==='PERFECTO','Perfect timing cue wrong');
test(qa.timingLabel(.22,false,false)==='FLUIDO','Loose incorrect swipe feedback wrong');

const audio=new RhythmAudio();
const sources=[];
audio.ctx={
  currentTime:2,state:'running',
  createBufferSource:()=>{
    const source={buffer:null,connect:()=>{},disconnect:()=>{},start:(...a)=>source.starts.push(a),
      stop:()=>{source.stopped=true},starts:[]};
    sources.push(source);return source;
  }
};
audio.analyser={};audio.buffer={duration:10};
audio.play(0,2.8);
test(Math.abs(audio.time()+2.8)<1e-8,'Countdown not driven by audio clock');
audio.ctx.currentTime=5.0;
test(Math.abs(audio.time()-.2)<1e-8,'Audio clock did not advance through countdown');
const frozen=audio.pause();
test(Math.abs(frozen-.2)<1e-8&&sources[0].stopped,'Paused playback position wrong');
audio.ctx.currentTime=7;
audio.play(frozen,0);
test(Math.abs(audio.time()-.2)<1e-8,'Resuming shifted the hit clock');
audio.ctx.currentTime=7.15;
test(Math.abs(audio.time()-.35)<1e-8,'Resumed playback time drift');
audio.stop();test(!audio.running,'Audio engine failed to stop');

const cb=await load('concert-rig.js'),effects=await load('combo-spectacle.js'),
  music=await load('music-stage.js');
const engineText=readFileSync(new URL('../apps/prisma/web/engine.js',import.meta.url),'utf8')
  .replace(/^import .*;$/gm,'').replace(/^export /gm,'');
const Scene=new Function('CubeGPU','NativeXRender','seeded','MusicStageDirector','makeIntelligentChart',
  'makeConcertProgram','concertPose','concertNativeParts','RIG_MAX_CUBOIDS',
  'createSpectacleEvent','pruneSpectacles','spectacleEnvelope','spectacleGeometry',
  'SPECTACLE_MAX_EVENTS','nextVisualQuality','visualBudget',engineText+';return Scene;')(
    {},{},()=>()=>.5,music.MusicStageDirector,()=>[],
    cb.makeConcertProgram,cb.concertPose,cb.concertNativeParts,cb.RIG_MAX_CUBOIDS,
    effects.createSpectacleEvent,effects.pruneSpectacles,effects.spectacleEnvelope,
    effects.spectacleGeometry,effects.SPECTACLE_MAX_EVENTS,
    nextVisualQuality,visualBudget
  );
const scene=Object.create(Scene.prototype);
let resizeCalls=0;
scene.resize=()=>{resizeCalls++};
scene.settings=()=>({quality:'auto',palette:'coral',effects:false});
scene.frameTotal=0;scene.frameCount=0;scene.cooldown=0;scene.qualityScale=1;
scene.visualState={quality:'balanced',slowFrames:0,fastFrames:0,cooldownUntil:0};
for(let i=0;i<90;i++)scene.adapt(.034,10000+i*34);
test(scene.qualityScale<1&&resizeCalls===1,'Auto quality did not adapt to expensive frames');
const reduced=scene.qualityScale;
for(let i=0;i<90;i++)scene.adapt(.012,20000+i*12);
test(scene.qualityScale>reduced,'Auto quality did not recover after fast frames');
scene.settings=()=>({quality:'high',palette:'coral',effects:false});
const original=scene.qualityScale;
for(let i=0;i<180;i++)scene.adapt(.034,30000+i*34);
test(scene.qualityScale===original,'Manually selected high quality must not be changed');

scene.particles=[];scene.shards=[];scene.trails=new Map();
scene.qualityScale=1;
scene.settings=()=>({quality:'high',palette:'coral',effects:false});
const point={x:200,y:120,s:70},note={color:0};
scene.burst(note,point,50,-25);
test(scene.particles.length===27,'High-quality impact particle budget changed');
scene.particles=[];scene.shards=[];
scene.settings=()=>({quality:'battery',palette:'coral',effects:false});
for(let i=0;i<30;i++)scene.burst(note,point,50,-25);
test(scene.particles.length<=90,'Battery impact budget not enforced');
scene.particles=[];scene.shards=[];
scene.settings=()=>({quality:'auto',palette:'coral',effects:false});
scene.qualityScale=.65;
scene.burst(note,point,50,-25);
test(scene.particles.length===9,'Auto quality failed to scale down effects');
scene.settings=()=>({quality:'auto',palette:'coral',effects:true});
scene.particles=[];scene.shards=[];
scene.burst(note,point,50,-25);
test(scene.particles.length===4,'Reduced effects should minimize particles');

const analysis=await load('music-analysis.js');
const rate=8000,duration=180,samples=new Float32Array(rate*duration);
for(let t=.3;t<duration-.3;t+=.5){
  const start=Math.floor(t*rate);
  for(let j=0;j<200;j++){
    const index=start+j;
    if(index>=samples.length)break;
    samples[index]=.65*Math.sin(2*Math.PI*80*j/rate)*Math.exp(-j/rate*40);
  }
}
const buffer={sampleRate:rate,length:samples.length,duration,numberOfChannels:1,
 getChannelData:()=>samples};
const started=performance.now();
const parsed=await analysis.analyseMusicBuffer(buffer);
const elapsed=performance.now()-started;
test(!parsed.fallback&&parsed.peaks.length>200,'Three-minute song analysis lost attacks');
test(Math.abs(parsed.bpm-120)<=8,'Three-minute synthetic beat detection drift');
const map=music.makeMusicStage(parsed.peaks,{bpm:parsed.bpm,duration:180,
  energy:parsed.energy,tempoSegments:parsed.tempoSegments,fallback:false});
const longChart=music.makeIntelligentChart(parsed.peaks,'pulse',7721,map);
test(longChart.length>=200&&longChart.every((n,i)=>!i||longChart[i-1].t<=n.t),
  'Long song produced invalid or unordered chart');
test(elapsed<30000,'Three-minute analysis exceeded 30s CI safety budget');
console.log(JSON.stringify({suite:'prisma-cycle6-gameplay',
  passed,analysisMs:+elapsed.toFixed(2),songSeconds:duration,peaks:parsed.peaks.length,
  chartNotes:longChart.length,qualityScale:scene.qualityScale}));
