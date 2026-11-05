import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
const load=async file=>{
  const code=readFileSync(new URL('../apps/prisma/web/'+file,import.meta.url),'utf8').replace(/^export \{.*$/gm,'');
  return import('data:text/javascript;base64,'+Buffer.from(code).toString('base64'));
};
const flow=await load('note-flow.js'),audio=await load('audio.js'),qa=await load('rhythm-qa.js'),analysis=await load('music-analysis.js');
let passed=0;const check=(v,m)=>{assert.ok(v,m);passed++;};
for(const bpm of [70,120,185])for(const level of ['flow','pulse','vertigo']){
  const travel=flow.approachSeconds(bpm,level),note={t:5};
  let prior=Infinity;
  for(let i=0;i<=100;i++){
    const m=flow.noteMotion(note,5-travel+travel*i/100,0,travel);
    check(m.z<=prior+1e-8&&m.z>=0,'Note approach reversed or entered the camera');prior=m.z;
  }
  const at=flow.noteMotion(note,5,0,travel),late=flow.noteMotion(note,5.23,0,travel);
  check(at.z===0&&late.z===0&&at.size===late.size,'A late cube grew beyond the strike plane');
  check(late.alpha<at.alpha,'Late notes must fade rather than hide the next cube');
}
check(qa.timingGrade(.045).perfect&&!qa.timingGrade(.10).perfect,'Perfect grade must mean accurate timing');
check(qa.timingGrade(.18).base<qa.timingGrade(.04).base,'Early hits receive perfect points');
check(qa.timingGrade(.18).label==='ANTICIPADO'&&qa.timingGrade(-.18).label==='TARDE','Timing feedback reversed');
const c={currentTime:10,baseLatency:.01,outputLatency:.12,getOutputTimestamp:()=>({contextTime:9.8,performanceTime:1000})};
check(Math.abs(audio.outputClock(c,1050).time-9.85)<1e-8,'Device timestamp not mapped to presentation time');
check(audio.outputClock(c,1050).mode==='device','Device clock not used');
check(audio.outputClock(c,1050,false).time===10,'Manual clock override failed');
check(Math.abs(audio.outputClock({...c,getOutputTimestamp:()=>({contextTime:0,performanceTime:0})},1050).time-9.87)<1e-8,'Uninitialized timestamp broke fallback');
check(audio.outputClock({...c,getOutputTimestamp:()=>({contextTime:50,performanceTime:1000})},1050).mode==='latency','Invalid device timestamp accepted');

const peaks=Array.from({length:10},(_,i)=>({t:1+i*.5,lane:1,row:0,color:0,dir:0,source:'melody',sustain:i===0?.9:0}));
const beginner=flow.decorateNotes(peaks,'flow'),notes=flow.decorateNotes(peaks,'pulse');
check(beginner.length===peaks.length&&beginner.every(n=>n.kind==='cut'&&!n.duration&&!Number.isInteger(n.phrase)),'Flow added a sustain or an extra sequence mechanic');
check(notes.every(n=>n.kind==='cut'&&!n.duration),'A held tone still forces a hold in ordinary gameplay');
check(notes.some(n=>n.chainLength===4),'Musical sequence missing');
check(notes.every(n=>peaks.some(p=>p.t===n.t)),'A mechanic moved an onset off the music');
const phrase=new flow.PhraseController(),sequence=notes.filter(n=>n.phrase===0);
for(const n of sequence.slice(0,-1))check(!phrase.hit(n),'Phrase completed before its last note');
check(phrase.hit(sequence.at(-1))&&phrase.completed===1,'Complete phrase did not register');
check(!phrase.hit(sequence.at(-1)),'Phrase awarded twice');
phrase.reset();phrase.miss(sequence[1]);check(!sequence.some(n=>phrase.hit(n)),'Broken phrase still completed');

const hold=()=>({t:2,kind:'hold',duration:.8}),grade=qa.timingGrade(.02),input={kind:'pointer',id:1};
const tracker=new flow.SustainController(),n=hold();
check(tracker.begin(n,2,input,grade),'Hold did not arm');
check(!tracker.begin(n,2,input,grade),'Hold began twice');
check(tracker.step(2.4,()=>true,()=>true).completed.length===0,'Hold completed too early');
check(tracker.release(input,2.4).failed.length===1,'Early release was accepted');
check(tracker.release(input,2.8).completed.length===0,'Released hold completed twice');
const n2=hold();tracker.begin(n2,2,input,grade);
check(tracker.step(2.8,()=>true,()=>true).completed.length===1,'Held note did not complete');
check(tracker.step(2.81,()=>true,()=>true).completed.length===0,'Held note scored twice');
const n3=hold();tracker.begin(n3,2,input,grade);tracker.suspend();
check(tracker.step(2.4,()=>false,()=>false).failed.length===0,'Pause broke a held note');
tracker.resume(2.4);
check(tracker.regrab({kind:'pointer',id:2},2.45,()=>true),'Cannot regrab after pause');
check(tracker.step(2.8,()=>true,()=>true).completed.length===1,'Regrab lost hold progress');
const n4=hold();tracker.begin(n4,2,input,grade);tracker.suspend();tracker.resume(2.4);
check(tracker.step(2.9,()=>false,()=>false).failed.length===1,'Abandoned paused note remained stuck');

const hop=.01,frames=500,mid=new Float32Array(frames),bass=new Float32Array(frames),treble=new Float32Array(frames);
for(let i=100;i<205;i++)mid[i]=.6;
let detected=analysis.detectSustains([{t:1,strength:1,source:'melody'}],{bass,mid,treble,hopSeconds:hop},5);
check(detected[0].sustain>=.9,'A sustained tone was treated as a short click');
mid.fill(0);for(let i=100;i<110;i++)mid[i]=.6;
detected=analysis.detectSustains([{t:1,strength:1,source:'melody'}],{bass,mid,treble,hopSeconds:hop},5);
check(!detected[0].sustain,'A short click became an invented sustain');
console.log(JSON.stringify({suite:'prisma-note-flow',passed,noteSize:flow.NOTE_SIZE,perfectWindowMs:55,mechanics:['single-cut','phrase'],legacySustainController:'verified',outputClock:'verified'}));
