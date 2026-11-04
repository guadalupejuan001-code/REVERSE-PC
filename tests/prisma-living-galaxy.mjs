import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
const load=async name=>import('data:text/javascript;base64,'+readFileSync(new URL('../apps/prisma/web/'+name,import.meta.url)).toString('base64'));
const live=await load('living-galaxy.js'),analysis=await load('music-analysis.js');
let passed=0;const check=(v,s)=>{assert.ok(v,s);passed++;};
const map={accents:[{t:1,strength:.95,major:true,drop:true,source:'bass',bands:[.9,.06,.04]},
  {t:1.25,strength:.8,major:true,source:'percussion',bands:[.02,.08,.9]}]};
const pose={beat:3,energy:.8};
const before=live.livingGalaxyFrame(map,.99,pose),hit=live.livingGalaxyFrame(map,1.02,pose),late=live.livingGalaxyFrame(map,3,pose);
check(before.bursts.length===0&&before.bass===0,'Explosion before a real accent');
check(hit.bursts.length===1&&hit.bass>.5,'Bass attack did not drive the cone and galaxy');
check(late.bursts.length===0&&late.bass===0,'Scenery kept generating false beats in silence');
check(hit.speakers.length===2&&hit.speakers[0].x<.15&&hit.speakers[1].x>.85,'Speakers must flank the player');
check(hit.rays.length===18&&live.livingGalaxyFrame(map,1.1,pose,{quality:'high'}).rays.length===28,'Laser fan budgets wrong');
check(live.livingGalaxyFrame(map,1.1,pose,{quality:'battery'}).rays.length===6,'Battery light budget wrong');
const soft=live.livingGalaxyFrame(map,1.1,pose,{reduced:true});
check(soft.rays.length===0&&soft.bursts.length===0&&soft.speakers.every(s=>s.cone===0&&s.rotation===0),'Soft effects still animate');
check(live.livingGalaxyFrame({...map,fallback:true},1.1,pose).bursts.length===0,'Synthetic practice must not fake acoustic explosions');
assert.deepEqual(hit,live.livingGalaxyFrame(map,1.02,pose));passed++;
check(live.overlayPixelRatio(900,420,2.5,'auto')===2.5,'Automatic detail blurred the cut overlay');
check(live.overlayPixelRatio(900,420,2.5,'battery')===1.5,'Battery overlay exceeded budget');

// Quiet gaps used to erase all short attacks: the FFT sees an onset before
// the centered time-domain RMS frame contains samples. Verify actual time.
function clicks(sr=48000,opposite=false){
  const duration=7,samples=new Float32Array(sr*duration),times=[];
  for(let t=.3;t<duration-.4;t+=.5){times.push(t);const start=Math.round(t*sr);
    for(let k=0;k<sr*.025;k++)samples[start+k]=.7*Math.sin(2*Math.PI*80*k/sr)*Math.exp(-k/sr*40);
  }
  const channels=opposite?[samples,Float32Array.from(samples,v=>-v)]:[samples];
  return {times,buffer:{sampleRate:sr,length:samples.length,duration,numberOfChannels:channels.length,getChannelData:i=>channels[i]}};
}
const timing=[];
for(const sr of [8000,44100,48000]){
  const f=clicks(sr,sr===48000),r=await analysis.analyseMusicBuffer(f.buffer);
  check(!r.fallback,'Real sparse attacks became artificial practice '+sr);
  const errors=f.times.map(t=>Math.min(...r.peaks.map(p=>Math.abs(t-p.t))));
  check(Math.max(...errors)<.030,'Onset accuracy exceeded 30 ms '+sr);
  check(r.peaks.length<=f.times.length+2,'Sparse song invented extra notes '+sr);
  timing.push({sampleRate:sr,maxOnsetErrorMs:+(Math.max(...errors)*1000).toFixed(2),attacks:r.peaks.length});
}
const app=readFileSync(new URL('../apps/prisma/web/app.js',import.meta.url),'utf8');
const audio=readFileSync(new URL('../apps/prisma/web/audio.js',import.meta.url),'utf8');
check(!app.includes('audio.swish')&&!audio.includes('swishBuffer'),'Cut noise is still connected');
console.log(JSON.stringify({suite:'prisma-living-galaxy',passed,timing,foregroundSpeakers:2,lasers:18}));
