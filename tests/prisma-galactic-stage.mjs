// node tests/prisma-galactic-stage.mjs
// PRISMA 2.4: deterministic mechanical show, bounded optics and real accent releases.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
const source=async path=>{
  const data=readFileSync(new URL(path,import.meta.url));
  return import('data:text/javascript;base64,'+data.toString('base64'));
};
const rig=await source('../apps/prisma/web/concert-rig.js');
const spectacle=await source('../apps/prisma/web/combo-spectacle.js');
let checks=0;
const check=(v,message)=>{assert.ok(v,message);checks++};
const energy=Array.from({length:128},(_,i)=>{
  const t=i*.25;
  return t<4?.04:t<8?.37:t<12?.58:t<16?.9:t<20?.92:t<24?.13:t<28?.48:.75;
});
const map={bpm:120,duration:32,energyStep:.25,energyBins:energy,
  tempoSegments:[{t:0,bpm:120},{t:18,bpm:145}]};
const program=rig.makeConcertProgram(map);
const styles=['galaxy','club','classic'],times=[1,5,9,13,17,21,25,30];
const snapshots=[];
for(const style of styles)for(const t of times){
  const cue={beat:.82,energy:.74,show:.35};
  const pose=rig.concertPose(program,t,cue,{quality:'high',style});
  check(pose.fixtures.length===6,'Missing a galactic fixture');
  check(pose.fixtures.every(f=>Number.isFinite(f.pan)&&Math.abs(f.pan)<=1.12 &&
    Number.isFinite(f.tilt)&&Math.abs(f.tilt)<=.62),'Motor limit violated');
  check(pose.fixtures.every(f=>Math.abs(f.focus.x)>=.67&&f.focus.z>=2),
    'Moving beam crosses playable center');
  check(pose.fixtures.every(f=>/^#[0-9a-f]{6}$/.test(f.lightColor)),
    'Optical palette missing');
  check(pose.intensity<=.29&&pose.fixtures.every(f=>f.intensity<=.29),
    'Optical brightness cap exceeded');
  check(rig.concertNativeParts(pose,64).length===18,
    'Native rig must preserve fixture budget');
  const again=rig.concertPose(program,t,cue,{quality:'high',style});
  assert.deepEqual(pose,again);checks++;
  snapshots.push(pose);
}
check(new Set(snapshots.map(p=>p.pattern)).size>=4,
  'Measured song sections do not drive distinct choreographies');
const moving=rig.concertPose(program,11,{energy:.65},{quality:'auto'});
const following=rig.concertPose(program,11.3,{energy:.65},{quality:'auto'});
check(moving.fixtures.some((f,i)=>Math.abs(f.pan-following.fixtures[i].pan)>.005),
  'Moving lights are static during music playback');
const club=rig.concertPose(program,11,{energy:.65},{style:'club'});
const classic=rig.concertPose(program,11,{energy:.65},{style:'classic'});
check(Math.abs(club.fixtures[0].pan)>Math.abs(classic.fixtures[0].pan),
  'Club show must increase the real pan range');
const mutedA=rig.concertPose(program,11,{beat:1,energy:1,show:1},{reduced:true});
const mutedB=rig.concertPose(program,11.8,{beat:0,energy:0,show:0},{reduced:true});
check(mutedA.fixtures.every((f,i)=>f.pan===0&&f.tilt===0 &&
  f.head.x===mutedB.fixtures[i].head.x),'Reduced motion must hold every head');
check(mutedA.intensity<=.07,'Reduced-mode brightness cap exceeded');
check(rig.concertPose(program,11,{energy:1},{quality:'battery'}).fixtures.length===2,
  'Battery mode must reduce physical fixtures');
const impact=spectacle.createSpectacleEvent({combo:100,t:4,strength:.95,drop:true});
check(spectacle.spectacleGeometry(impact,3.99)===null,'Nova appears before audio accent');
const full=spectacle.spectacleGeometry(impact,4.1);
check(full?.spokes.length===12&&full.shards.length<=40,
  'Nova rays are missing or violate the effect cap');
check(spectacle.spectacleGeometry(impact,4.1,{battery:true}).spokes.length===0,
  'Battery stage must discard nova rays');
check(spectacle.spectacleGeometry(impact,4.1,{reduced:true}).spokes.length===0,
  'Reduced-motion nova must remain soft');
const html=readFileSync(new URL('../apps/prisma/web/index.html',import.meta.url),'utf8');
const app=readFileSync(new URL('../apps/prisma/web/app.js',import.meta.url),'utf8');
check(html.includes('id="stageStyle"')&&html.includes('value="galaxy"'),
  'Galactic stage selector absent');
check(app.includes('demoEnergyCache=measured.energy'),
  'Demo audio energy not reaching the concert controller');
const shader=readFileSync(new URL('../apps/prisma/web/gpu-scene.js',import.meta.url),'utf8');
check(shader.includes('cloudA=exp(')&&shader.includes('cloudB=exp('),
  'Galactic WebGL backdrop not integrated');
console.log(JSON.stringify({suite:'prisma-galactic-stage',passed:checks,
  patterns:[...new Set(snapshots.map(p=>p.pattern))],fixtures:6,novaSpokes:full.spokes.length}));
