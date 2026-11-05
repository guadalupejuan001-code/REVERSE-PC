import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
const load=async name=>import('data:text/javascript;base64,'+readFileSync(new URL('../apps/prisma/web/'+name,import.meta.url)).toString('base64'));
const [flow,music,qa,notes]=await Promise.all(['flow-gameplay.js','music-stage.js','rhythm-qa.js','note-flow.js'].map(load));
let passed=0;const check=(yes,why)=>{assert.ok(yes,why);passed++;};
const traces=[];
for(const bpm of [40,60,90,122,185,260]){
  const peaks=Array.from({length:12000},(_,i)=>({t:.3+i*.01,strength:1,source:i%2?'percussion':'bass',sustain:.9}));
  const map=music.makeMusicStage(peaks,{bpm,duration:121,energy:Array(2420).fill(1)});map.mechanics=true;
  const chart=notes.decorateNotes(music.makeIntelligentChart(peaks,'flow',7721,map),'flow');
  check(chart.length>10&&chart.length<145,'Flow still floods the player with multiple notes per second');
  check(chart.every((n,i)=>!i||n.t-chart[i-1].t>=.85-1e-6),'Beginner attacks are too close');
  check(chart.slice(0,6).every((n,i)=>!i||n.t-chart[i-1].t>=1.15-1e-6),'Opening is too dense');
  check(chart.every(n=>peaks.some(p=>p.t===n.t)),'Flow invented or shifted a music onset');
  check(chart.every(n=>n.row===1&&n.kind==='cut'&&!n.duration&&!Number.isInteger(n.phrase)),'Flow requires a second row, hold, or numbered phrase');
  traces.push({bpm,notes:chart.length,minGap:Math.min(...chart.slice(1).map((n,i)=>n.t-chart[i].t))});
}
const chart=Array.from({length:100},(_,i)=>({t:1+i,lane:i%3,row:1,dir:0}));
const first=flow.flowCandidates(chart,1,0,4.8);check(first.length===4,'Flow viewport is not bounded to four cubes');
for(const t of [2,5,20,120,10000]){
  const still=flow.flowCandidates(chart,t,0,4.8);
  check(still.length===4&&still.every((n,i)=>n===first[i]),'An uncut cube disappears as music time advances');
  check(qa.nearestKeyNote(still,t,0,'flow',0)===first[0],'An overdue waiting cube cannot be recovered by keyboard');
  check(qa.nearestSwipeNote(still,t,0,'flow',100,100,100,100,()=>({x:100,y:100,s:50}),{isTap:true,precise:true})===first[0],'A waiting cube cannot be tapped after a saved precise setting');
}
first[0].hit=true;check(flow.flowCandidates(chart,20)[0]===chart[1],'A scored cube did not leave the queue');
check(qa.nearestSwipeNote(chart,1,0,'pulse',100,100,100,100,()=>({x:100,y:100,s:50}),{isTap:true})===null,'Flow assistance leaked to Pulse');
check(qa.nearestKeyNote(chart,200,0,'pulse',0)===null,'Advanced timing lost its deadline');
const motion=new flow.FlowPresentation();const visible=flow.flowCandidates(chart,20);
const a=motion.step(visible,20,1/60);check(a.get(visible[0])===0&&a.get(visible[1])>=.85,'Waiting cubes collapse into the same depth');
visible[0].hit=true;const next=flow.flowCandidates(chart,20),before=a.get(next[0]);
const b=motion.step(next,20.017,1/60);check(b.get(next[0])>=before-1/60-1e-8,'Promotion makes the next cube jump forward');
check(motion.step(next,20.017,0).get(next[0])===b.get(next[0]),'Paused cube motion advances');
for(let i=0;i<120;i++)motion.step(next,21+i/60,1/60);
check(motion.step(next,23,0).get(next[0])===0,'The next cube never reaches the strike plane');
const legacy={track:'A',level:'flow',score:300,accuracy:90},modern={track:'A',level:'flow',rules:flow.FLOW_RULES,score:500,accuracy:90};
const records=flow.keepRecord([legacy],modern);check(records.includes(legacy)&&records.includes(modern),'New forgiving Flow overwrites an old-mode record');
check(flow.recordRules(legacy)!==flow.scoreRules('flow'),'Old and new Flow records share a score category');
console.log(JSON.stringify({suite:'prisma-flow-gameplay',passed,flowVisibleLimit:4,automaticMisses:false,defaultHolds:false,density:traces}));
