import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
const source=async name=>import('data:text/javascript;base64,'+readFileSync(new URL('../apps/prisma/web/'+name,import.meta.url)).toString('base64'));
const f=await source('festival-worlds.js'),rig=await source('concert-rig.js');
let passed=0;const check=(value,why)=>{assert.ok(value,why);passed++;};
const accents=Array.from({length:160},(_,i)=>({t:i*.5+1,strength:.9,major:i%2===0,drop:i%16===0}));
const map={duration:84,bpm:120,accents,energyStep:.25,energyBins:Array(336).fill(.8)};
const p=f.makeFestivalProgram(map,rig.makeConcertProgram(map));
check(new Set(p.chapters.map(c=>c.id)).size===5,'Journey did not reach all five worlds');
check(p.chapters.every((c,i)=>!i||accents.some(a=>a.t===c.t)),'Chapter transition invented a musical timestamp');
check(p.chapters.every((c,i)=>!i||c.t-p.chapters[i-1].t>=10),'World changes are too frequent');
check(p.shells.length>8&&p.shells.every(s=>accents.some(a=>a.t===s.t)),'Fireworks are detached from actual accents');
check(new Set(p.shells.map(s=>s.kind)).size===4,'Pyrotechnic shapes are missing');
check(f.makeFestivalProgram({...map,fallback:true},rig.makeConcertProgram(map)).shells.length===0,'Fallback music fakes fireworks');
check(f.makeFestivalProgram({...map,fallback:true},rig.makeConcertProgram(map)).chapters.length===1,'Fallback fakes musical sections');
check(f.fireworkFrame(p,-1).length===0,'Firework before the track');
check(f.fireworkFrame(p,NaN).length===0,'Invalid clock accepted');
for(const quality of ['battery','auto','high'])for(let t=0;t<84;t+=.17){
  const frame=f.fireworkFrame(p,t,{quality});
  check(frame.length<=4,'Concurrent shell cap exceeded');
  check(frame.every(e=>e.sparks.length<=(quality==='battery'?12:quality==='high'?40:26)),'Spark cap exceeded');
  check(frame.every(e=>e.age>=0||e.sparks.length===0),'Shell bursts before musical accent');
  check(frame.every(e=>e.sparks.every(s=>Number.isFinite(s.x)&&Number.isFinite(s.y)&&s.alpha>=0&&s.alpha<=1)),'Invalid particle trajectory');
}
const first=p.shells[0],before=f.fireworkFrame(p,first.t-.2),at=f.fireworkFrame(p,first.t+.1);
check(before[0]?.rocket&&before[0].sparks.length===0,'No rising fuse before the accent');
check(at[0]?.sparks.length===26&&!at[0].rocket,'Shell did not explode at accent');
assert.deepEqual(at,f.fireworkFrame(p,first.t+.1));passed++;
check(f.fireworkFrame(p,first.t+.1,{reduced:true}).length===0,'Soft effects retained fireworks');
check(f.fireworkFrame(p,first.t+.1,{enabled:false}).length===0,'Disabled fireworks remain active');
const reward=f.rewardFirework(p,5.15,3);
check(reward?.t===5.5&&reward.source==='constellation','Reward did not choose next real accent');
check(f.rewardFirework(p,5.52,4)?.t===5.5,'Precise late input lost its actual musical onset');
check(f.rewardFirework({accents:[{t:2}],rewardAccents:[{t:1},{t:1.5},{t:2}]},1.51)?.t===1.5,'Quiet real note cannot trigger its earned celebration');
check(f.rewardFirework({accents:[]},4)===null,'Reward invented an accent in silence');
check(f.rewardFirework({accents:[{t:12}]},4)===null,'Reward scheduled too far from player action');
const dense={...p,shells:Array.from({length:100},(_,i)=>({...first,t:1+i*.001,id:i}))};
check(f.fireworkFrame(dense,1.2,{rewards:[reward]}).length===4,'Dense/reward events escape global cap');
const c=new f.Constellation();for(let i=0;i<7;i++)check(!c.hit(150),'Constellation completed before eight hits');
check(c.charge===7&&c.hit(120)&&c.completed===1&&c.charge===0,'Eighth precise hit did not complete one reward');
c.hit(150);c.hit(90);check(c.charge===0,'Mistimed hit retained precision streak');
c.hit(150);c.miss();check(c.charge===0&&c.completed===1,'Miss did not reset charge/preserve earned total');
c.hit(NaN);check(c.charge===0,'Invalid grade counted');c.reset();check(c.completed===0&&c.charge===0,'Replay retained previous reward');
for(const id of f.WORLD_IDS){
  check(f.worldFrame(p,22,id).current.id===id,'Fixed world selection changed with music');
  check(f.worldFrame(p,80,id).previous===null,'Fixed world crossfades unexpectedly');
}
for(const ch of p.chapters.slice(1)){
  const earlier=f.worldFrame(p,ch.t-.01),transition=f.worldFrame(p,ch.t+.4),after=f.worldFrame(p,ch.t+2);
  check(earlier.current.id!==ch.id,'World changed before accent');
  check(transition.current.id===ch.id&&transition.previous&&transition.mix>0&&transition.mix<1,'Missing world crossfade');
  check(after.current.id===ch.id&&after.mix===1&&!after.previous,'Crossfade never completed');
  check(f.worldFrame(p,ch.t+.1,'journey',true).mix===1,'Reduced mode has a moving transition');
}
const clips=[];const ctx={beginPath(){},rect(...v){clips.push(v)},clip(){clips.push('clip')}};
f.protectPlayfield(ctx,1000,500);check(clips.length===5,'Worlds do not protect the playfield');
check(clips[1][2]===285&&clips[2][0]===715,'Effects invade the central strike zone');
const heads=[],paint={save(){},restore(){},beginPath(){},rect(){},clip(){},moveTo(){},lineTo(){},stroke(){},fillRect(x,y){heads.push([x+.6,y+.6]);}};
f.drawFireworks(paint,1000,500,[{id:0,cx:.16,cy:.3,flash:0,sparks:[{x:.26,y:.3,dx:0,dy:0,alpha:1},{x:.16,y:.4,dx:0,dy:0,alpha:1}]}],f.WORLDS[0]);
check(Math.abs(Math.hypot(heads[0][0]-160,heads[0][1]-150)-Math.hypot(heads[1][0]-160,heads[1][1]-150))<1e-6,'Circular shell became an ellipse on a landscape screen');
const src=readFileSync(new URL('../apps/prisma/web/festival-worlds.js',import.meta.url),'utf8');
check(!/Math\.random|setInterval|setTimeout|AudioContext|createBufferSource/.test(src),'Festival owns a timer, RNG or audio source');
console.log(JSON.stringify({suite:'prisma-festival',passed,worlds:f.WORLD_IDS,chapters:p.chapters.length,shells:p.shells.length,maxSparks:160}));
