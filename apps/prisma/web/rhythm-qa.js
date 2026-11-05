// PRISMA 2.3 — deterministic hit selection, independent of animation frames.
// Screen-space picking chooses the best playable note, not the first note in
// chart order, when overlapping events share a hit window.
const clamp=(v,lo,hi)=>Math.max(lo,Math.min(hi,v));
const windows=Object.freeze({flow:.24,pulse:.19,vertigo:.16});
export const hitWindowFor=level=>windows[level]||windows.flow;
export const isEndOfSong=(audioTime,duration,level,latencySeconds=0)=>
 Number.isFinite(audioTime)&&Number.isFinite(duration)&&
 audioTime>=duration+hitWindowFor(level)+Math.max(0,latencySeconds)+.07;
export function segmentDistance(px,py,ax,ay,bx,by) {
 const vx=bx-ax,vy=by-ay,d=vx*vx+vy*vy;
 const t=d?clamp(((px-ax)*vx+(py-ay)*vy)/d,0,1):0;
 return Math.hypot(px-ax-t*vx,py-ay-t*vy);
}
const range=(notes,time,latency,window)=>{
 const search=val=>{
  let low=0,high=notes.length;
  while(low<high){const mid=(low+high)>>>1;if(notes[mid].t<val)low=mid+1;else high=mid;}
  return low;
 };
 return [search(time-latency-window-.001),search(time-latency+window+.001)];
};
export function nearestSwipeNote(chart,time,latency,level,
 ax,ay,bx,by,project,{precise=false,isTap=false}={}) {
 if(!Array.isArray(chart)||!chart.length||typeof project!=='function')return null;
 const window=hitWindowFor(level),length=Math.hypot(bx-ax,by-ay);
 if(!isTap&&length<3)return null;
 const [first,last]=range(chart,time,latency,window);
 let winner=null,best=Infinity;const eligible=[];
 for(let i=first;i<last;i++){
  const n=chart[i];
  if(n.hit||n.missed||n.holding||!Number.isFinite(n.t))continue;
  if(isTap&&n.kind!=='hold'&&(level!=='flow'||precise))continue;
  const delta=n.t+latency-time;
  if(Math.abs(delta)>window)continue;
  const p=project(n,time,latency),radius=Math.max(18,p.s*.64*.66);
  if(!(radius>0))continue;
  const distance=segmentDistance(p.x,p.y,ax,ay,bx,by);
  if(distance>radius)continue;
  const directions=[[0,-1],[1,0],[0,1],[-1,0]],dir=directions[n.dir];
  if(precise && n.kind!=='hold' && (!dir||!length||((bx-ax)*dir[0]+(by-ay)*dir[1])/length<=.43))continue;
  eligible.push(n);
  // Timing is dominant; when notes are simultaneous choose the closer cube.
  const grade=Math.abs(delta)/window+distance/radius*.20;
  if(grade<best){best=grade;winner=n;}
 }
 // A later attack in the same target must not steal the visible first cube.
 // Distinct targets still use timing and spatial proximity independently.
 if(winner&&Number.isInteger(winner.lane)&&Number.isInteger(winner.row))return eligible.find(n=>n.lane===winner.lane&&n.row===winner.row&&n.t<winner.t-.012)||winner;
 return winner;
}
export function nearestKeyNote(chart,time,latency,level,direction) {
 if(!Array.isArray(chart)||!chart.length)return null;
 const window=hitWindowFor(level),[first,last]=range(chart,time,latency,window);
 let note=null,best=Infinity;const eligible=[];
 for(let i=first;i<last;i++){
  const n=chart[i],error=Math.abs(n.t+latency-time);
  if(!n.hit&&!n.missed&&!n.holding&&n.dir===direction&&error<=window){
   eligible.push(n);if(error<best){best=error;note=n;}
  }
 }
 if(note&&Number.isInteger(note.lane)&&Number.isInteger(note.row))return eligible.find(n=>n.lane===note.lane&&n.row===note.row&&n.t<note.t-.012)||note;
 return note;
}
export function timingLabel(delta,perfect,validDirection,isTap=false) {
 if(perfect)return 'PERFECTO';
 if(!validDirection && !isTap)return 'FLUIDO';
 if(delta>.11)return 'ANTICIPADO';
 if(delta<-.11)return 'TARDE';
 return 'A RITMO';
}
export function timingGrade(delta,validDirection=true){
 const error=Math.abs(delta),perfect=error<=.055&&validDirection;
 return {delta,perfect,base:perfect?150:error<=.11?120:error<=.17?90:65,
   label:timingLabel(delta,perfect,validDirection)};
}
