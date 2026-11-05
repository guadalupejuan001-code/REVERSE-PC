import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
const load=async name=>import('data:text/javascript;base64,'+readFileSync(new URL('../apps/prisma/web/'+name,import.meta.url)).toString('base64'));
const [flow,music,qa,notes]=await Promise.all(['flow-gameplay.js','music-stage.js','rhythm-qa.js','note-flow.js'].map(load));
let passed=0;const check=(yes,why)=>{assert.ok(yes,why);passed++;};const traces=[];
for(const bpm of [40,60,90,122,185,260]){
 const period=60/bpm,peaks=Array.from({length:120},(_,i)=>({t:.3+i*period,strength:1,source:'percussion',sustain:.9}));
 const map=music.makeMusicStage(peaks,{bpm,duration:peaks.at(-1).t+1,energy:Array(1000).fill(1)});map.mechanics=true;
 const chart=notes.decorateNotes(music.makeIntelligentChart(peaks,'flow',7721,map),'flow'),step=period<.36?2:1;
 check(chart.length===Math.ceil(peaks.length/step),'Flow fails to follow regular imported beats');
 check(chart.every((n,i)=>Math.abs(n.t-peaks[i*step].t)<1e-8),'Flow throttles or shifts the musical beat');
 check(chart.every(n=>n.row===1&&n.kind==='cut'&&!n.duration&&!Number.isInteger(n.phrase)),'Flow reintroduced complex gestures');
 const maxVisible=Math.max(...chart.map(n=>flow.flowCandidates(chart,n.t,0,5.2).length));
 check(maxVisible<=flow.FLOW_VISIBLE_LIMIT,'Flow exceeds its renderer packet budget');
 traces.push({bpm,detected:peaks.length,playable:chart.length,beatStep:step,maxVisible});
}
const changePeaks=[];for(let t=.5;t<10;t+=.5)changePeaks.push({t,strength:1,source:'bass'});for(let i=0;i<30;i++)changePeaks.push({t:10+i/3,strength:1,source:'percussion'});
const variable=music.makeMusicStage(changePeaks,{bpm:120,duration:21,energy:Array(420).fill(1),tempoSegments:[{t:0,bpm:120},{t:10,bpm:180}]});
const variableChart=music.makeIntelligentChart(changePeaks,'flow',7721,variable);
check(variableChart.filter(n=>n.t<10).length===19,'The slow section lost its original beats');
check(variableChart.filter(n=>n.t>=10).length===15,'The fast section did not adapt to the local tempo');
check(variableChart.every(n=>changePeaks.some(p=>p.t===n.t)),'Tempo adaptation invented an onset');
const chart=Array.from({length:100},(_,i)=>({t:1+i*.5,lane:i%3,row:1,dir:0})),presentation=new flow.FlowPresentation();
for(const t of [2,5,20]){
 const current=flow.flowCandidates(chart,t,0,3.4);
 check(current.some(n=>n.t===t),'Uncut old notes block the next musical attack');
 check(current.length>4,'The four-cube queue still throttles the live song');
 check(qa.nearestKeyNote(current,t,0,'flow',0)?.t===t,'Keyboard follows the old queue instead of the current beat');
 check(qa.nearestSwipeNote(current,t,0,'flow',100,100,100,100,()=>({x:100,y:100,s:50}),{isTap:true,precise:true})?.t===t,'Flow tap steals a different musical attack');
}
check(chart.every(n=>!n.hit&&!n.missed),'Advancing the live stream silently judges pending notes');
check(presentation.deferred(chart,20)>0,'Late notes are not retained for recovery');
const recovery=flow.flowCandidates(chart,100,0,3.4,0,true);
check(recovery.length===4&&recovery[0]===chart[0],'End recovery does not preserve the oldest uncut cube');
check(qa.nearestKeyNote(recovery,100,0,'flow',0,3.4,true)===chart[0],'A deferred note cannot be recovered');
check(qa.nearestKeyNote(recovery,100,0,'flow',0)===null,'A deferred note still steals live inputs');
check(qa.nearestKeyNote([{t:5,dir:0}],3,0,'flow',0)===null,'Flow awards a cut seconds before the music');
check(qa.nearestKeyNote([{t:5,dir:0}],4.7,0,'flow',0)!==null,'Flow early grace is too strict');
check(qa.nearestKeyNote([{t:5,dir:0}],5.9,0,'flow',0)!==null,'Flow late grace is too strict');
check(Math.abs(qa.hitWindowFor('flow')-flow.FLOW_LATE_GRACE)<1e-8&&flow.FLOW_EARLY_GRACE===.35,'Live selection and visual grace differ');
for(const fps of [8,15,30,60,120]){
 const mover=new flow.FlowPresentation(),targets=[{t:1},{t:5},{t:5.5}];
 for(let i=0;i<=Math.floor(5.5*fps);i++)mover.step(targets,i/fps,Math.min(.045,1/fps));
 const pose=mover.step(targets,5.5,.045);
 check(pose.get(targets[2])===0,'Low FPS or queue index makes a cube arrive after its musical onset');
 for(const latency of [-.2,0,.2])check(mover.step(targets,5.5+latency,.045,latency).get(targets[2])===0,'Calibration changes the audio-clock crossing');
}
check(presentation.departure(-flow.FLOW_LATE_GRACE).sizeScale*notes.NOTE_SIZE>=.05,'Departing cube violates the native mesh packet size contract');
const exit=presentation.departure(-.5);check(exit.yShift<0&&exit.sizeScale<1&&exit.sizeScale>0,'A late cube blocks the next one or vanishes immediately');
check(presentation.departure(0).sizeScale===1&&presentation.departure(-flow.FLOW_LATE_GRACE).sizeScale>0,'Live cube scale is invalid');
const relaxed=new flow.FlowPresentation(),a=relaxed.step(recovery,100,1/60,0,true);recovery[0].hit=true;
const next=flow.flowCandidates(chart,100,0,3.4,0,true),before=a.get(next[0]);
check(relaxed.step(next,100,1/60,0,true).get(next[0])>=before-1/60-1e-8,'End recovery promotion jumps forward');
const frozen=relaxed.step(next,100,0,0,true).get(next[0]);check(relaxed.step(next,100,0,0,true).get(next[0])===frozen,'Paused recovery advances');
check(qa.nearestKeyNote(chart,200,0,'pulse',0)===null,'Flow recovery leaked into Pulse');
const legacy={track:'A',level:'flow',rules:'flow-2.9',score:300},modern={track:'A',level:'flow',rules:flow.FLOW_RULES,score:500};
check(flow.keepRecord([legacy],modern).includes(legacy)&&flow.recordRules(legacy)!==flow.scoreRules('flow'),'New musical Flow erased or mixed the old practice record');
check(flow.keepRecord([legacy,{track:'A',level:'flow',score:100}],modern).some(r=>!r.rules&&r.score===100),'The older pre-2.9 Flow record was lost');
console.log(JSON.stringify({suite:'prisma-flow-gameplay',passed,audioClockFPS:[8,15,30,60,120],liveGrace:{early:flow.FLOW_EARLY_GRACE,late:flow.FLOW_LATE_GRACE},deferredRecovery:true,density:traces}));
