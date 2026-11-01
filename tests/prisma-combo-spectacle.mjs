// Run with: node tests/prisma-combo-spectacle.mjs
// Regression gate: no celebration without player milestone + real music accent.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
let checks=0;
const check=(ok,message)=>{assert.ok(ok,message);checks++;};
const moduleFile=async name=>{
  const bytes=readFileSync(new URL('../apps/prisma/web/'+name,import.meta.url));
  return import('data:text/javascript;base64,'+bytes.toString('base64'));
};
const [music,visual,concert]=await Promise.all([
  moduleFile('music-stage.js'),moduleFile('combo-spectacle.js'),moduleFile('concert-rig.js')
]);
const {makeMusicStage,MusicStageDirector}=music;
const {comboTier,createSpectacleEvent,pruneSpectacles,spectacleEnvelope,
  spectacleGeometry,SPECTACLE_MAX_EVENTS}=visual;

const strengths=Array.from({length:24},(_,i)=>({
  t:.5+i*.25,strength:i%2===0?.98:.2
}));
const levels=Float32Array.from({length:300},(_,i)=>i<150?.08:.8);
const map=makeMusicStage(strengths,{bpm:120,duration:7,energy:levels});
const director=new MusicStageDirector(map);
check(director.armCombo(9,1.22)===false,'ordinary hits cannot arm FX');
check(director.step(1.22).explosion===null,'no milestone means no FX');
check(director.armCombo(10,1.22),'milestone should arm an upcoming strong onset');
const before=director.step(1.35);
check(before.charge?.combo===10,'upcoming real accent should charge a milestone');
check(before.charge?.progress>0&&before.charge?.dueIn>0,'charge is timestamp-driven');
check(before.explosion===null,'charge does not trigger early');
const released=director.step(1.51);
check(released.explosion?.t===1.5,'release must occur on a detected accent');
check(released.explosion?.combo===10,'wrong combo on released event');
check(released.charge===null,'charging ends at release');
check(director.step(1.54).explosion===null,'never replay celebration in later frames');
const first=createSpectacleEvent(released.explosion);
check(first?.tier==='spark','x10 tier missing');
check(Object.isFrozen(first),'effect plan should be immutable');
check(spectacleGeometry(first,first.t-.001)===null,'no graphics before beat');
check(spectacleGeometry(first,first.t+first.life+.001)===null,'effect must end');
check(spectacleEnvelope([first],first.t)>spectacleEnvelope([first],first.t+.3),
  'impact envelope must fade');
assert.deepEqual(spectacleGeometry(first,first.t+.12),
  spectacleGeometry(first,first.t+.12));checks++;

const tiers=new Map([[10,'spark'],[20,'surge'],[30,'prism'],[50,'cascade'],
  [100,'finale'],[150,'finale']]);
for(const [combo,tier] of tiers){
  check(comboTier(combo)===tier,'missing combo tier '+combo);
  const event=createSpectacleEvent({t:2,combo,strength:.85,drop:combo>=50});
  const frame=spectacleGeometry(event,2.10);
  check(frame?.tier===tier,'incorrect frame tier '+combo);
  check(frame.shards.length<=40,'unbounded particles '+combo);
  check(frame.rings.length<=3,'unbounded rings '+combo);
  check(frame.shards.every(s=>s.alpha>=0&&s.alpha<=1),'invalid shard alpha');
}
for(const c of [0,9,11,25,31,49,51,80,99,101]){
  check(comboTier(c)===null,'no spectacle at non-milestone '+c);
}
check(createSpectacleEvent({t:1,combo:10,strength:NaN})===null,
  'invalid acoustic input must not create explosion');
check(createSpectacleEvent({t:-1,combo:10,strength:1})===null,
  'invalid song time must not create explosion');

const finale=createSpectacleEvent({t:2,combo:100,strength:.95,drop:true});
const full=spectacleGeometry(finale,2.10);
const battery=spectacleGeometry(finale,2.10,{battery:true});
const reduced=spectacleGeometry(finale,2.10,{reduced:true});
check(full.shards.length===40,'full finale not rendered');
check(battery.shards.length===8&&battery.rings.length===1,'battery FX budget violated');
check(reduced.shards.length===0&&reduced.rings.length===1,'reduced-motion still emits sparks');
check(spectacleEnvelope([finale],2.10,true)<spectacleEnvelope([finale],2.10,false),
  'reduced motion must dim stage show');
check(pruneSpectacles([first,finale],2.11).length===1,'expired events must be culled');
const many=Array.from({length:10},(_,i)=>createSpectacleEvent({
  t:i*.1,combo:100,strength:1
}));
check(pruneSpectacles(many,.9).length<=SPECTACLE_MAX_EVENTS,
  'event queue must be bounded');
check(pruneSpectacles([finale],1.9).length===0,'not-yet-born event must not render');

check(director.armCombo(20,2.22),'milestone x20 should arm');
director.cancelCombo();
check(director.step(2.51).explosion===null,'miss cancels charge');
check(director.armCombo(30,3.22),'milestone x30 should arm');
check(director.step(3.73).explosion===null,'late frame must skip off-beat release');
director.reset(1);
check(director.step(1.51).explosion===null,'seek cannot replay past effects');
const ambient=makeMusicStage(strengths,{bpm:120,duration:7,fallback:true});
check(!new MusicStageDirector(ambient).armCombo(10,1.22),
  'synthetic practice pulse must not trigger major FX');
check(!new MusicStageDirector(makeMusicStage([],{bpm:120,duration:7})).armCombo(10,1.22),
  'no acoustic accents means no explosion');

const program=concert.makeConcertProgram(map);
const plain=concert.concertPose(program,1.5,{beat:.9,energy:.6,show:0});
const boosted=concert.concertPose(program,1.5,{beat:.9,energy:.6,show:.8});
const quiet=concert.concertPose(program,1.5,{beat:.9,energy:.6,show:.8},
  {reduced:true});
check(boosted.intensity>plain.intensity,'earned accent must activate stage fixtures');
check(boosted.intensity<=.29,'stage brightness exceeded safe clamp');
check(quiet.intensity<=.07,'reduced-motion show is too bright');

const sceneSource=readFileSync(
  new URL('../apps/prisma/web/engine.js',import.meta.url),'utf8'
).replace(/^import .*;$/gm,'').replace(/^export /gm,'');
const Scene=new Function('CubeGPU','NativeXRender','seeded','MusicStageDirector','makeIntelligentChart',
  'makeConcertProgram','concertPose','concertNativeParts','RIG_MAX_CUBOIDS',
  'createSpectacleEvent','pruneSpectacles','spectacleEnvelope','spectacleGeometry',
  'SPECTACLE_MAX_EVENTS',
  sceneSource+';return Scene;')(
    {},{},()=>()=>.5,MusicStageDirector,()=>[],
    concert.makeConcertProgram,concert.concertPose,concert.concertNativeParts,
    concert.RIG_MAX_CUBOIDS,
    createSpectacleEvent,pruneSpectacles,spectacleEnvelope,spectacleGeometry,
    SPECTACLE_MAX_EVENTS
  );
const metrics={strokes:0,fills:0},gradient={addColorStop:()=>{}};
const ctx={
  setTransform:()=>{},clearRect:()=>{},save:()=>{},restore:()=>{},
  translate:()=>{},rotate:()=>{},beginPath:()=>{},closePath:()=>{},
  moveTo:()=>{},lineTo:()=>{},bezierCurveTo:()=>{},arc:()=>{},ellipse:()=>{},
  fillRect:()=>{},strokeRect:()=>{},stroke:()=>metrics.strokes++,
  fill:()=>metrics.fills++,createLinearGradient:()=>gradient
};
const scene=Object.create(Scene.prototype);
scene.canvas={width:880,height:440,dataset:{}};
scene.ctx=ctx;scene.width=880;scene.height=440;scene.dpr=1;
scene.settings=()=>({quality:'auto',palette:'coral',effects:false});
scene.gpu={native:true,quality:0,count:0,begin(){this.count=0;},
  cube(){this.count++},flush(){}};
scene.paletteKey='';scene.rgb=[];scene.view=new Float32Array(4);
scene.particles=[];scene.shards=[];scene.trails=new Map();
scene.pulse=scene.energy=scene.shake=0;
scene.diagnostics=false;scene.qualityScale=1;scene.stageExplosions=[];
scene.setMusicStage(map);
check(scene.armCombo(10,1.22),'scene integration did not arm');
scene.render(1.35,1/60,[],false,0,0,true);
check(scene.stageShow?.charge?.combo===10,'scene lost charge');
check(scene.stageExplosions.length===0,'scene fired before accent');
scene.render(1.51,1/60,[],false,0,0,true);
check(scene.stageShow?.release===10,'scene did not publish release');
check(scene.stageExplosions.length===1,'scene should hold exactly one new event');
check(metrics.fills>0&&metrics.strokes>0,'no rendered prismatic FX');
const firstShow=scene.rigPose.intensity;
scene.render(1.66,1/60,[],false,0,0,true);
check(scene.stageExplosions.length===1,'active event disappeared too soon');
check(scene.rigPose.intensity<=firstShow,'lights did not decay with score accent');
scene.render(2.6,1/60,[],false,0,0,true);
check(scene.stageExplosions.length===0,'expired event retained');
scene.clearEffects();scene.clearMusicStage();
check(scene.stageExplosions.length===0&&scene.musicStage===null,
  'new session must not replay prior celebrations');

console.log(JSON.stringify({suite:'prisma-cycle4-spectacle',
  passed:checks,tiers:[...tiers.values()],maxShards:40,showEventLimit:SPECTACLE_MAX_EVENTS}));
