// PRISMA 2.3 — deterministic hit selection, independent of animation frames.
// Screen-space picking chooses the best playable note, not the first note in
// chart order, when overlapping events share a hit window.
const clamp=(v,lo,hi)=>Math.max(lo,Math.min(hi,v));
const windows=Object.freeze({flow:.32,pulse:.265,vertigo:.225});
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
 if(isTap && (level!=='flow'||precise))return null;
 if(!isTap&&length<3)return null;
 const [first,last]=range(chart,time,latency,window);
 let winner=null,best=Infinity;
 for(let i=first;i<last;i++){
  const n=chart[i];
  if(n.hit||n.missed||!Number.isFinite(n.t))continue;
  const delta=n.t+latency-time;
  if(Math.abs(delta)>window)continue;
  const p=project(n,time,latency),radius=p.s*.73*.62;
  if(!(radius>0))continue;
  const distance=segmentDistance(p.x,p.y,ax,ay,bx,by);
  if(distance>radius)continue;
  const directions=[[0,-1],[1,0],[0,1],[-1,0]],dir=directions[n.dir];
  if(precise && (!dir||!length||((bx-ax)*dir[0]+(by-ay)*dir[1])/length<=.43))continue;
  // Timing is dominant; when notes are simultaneous choose the closer cube.
  const grade=Math.abs(delta)/window+distance/radius*.20;
  if(grade<best){best=grade;winner=n;}
 }
 return winner;
}
export function nearestKeyNote(chart,time,latency,level,direction) {
 if(!Array.isArray(chart)||!chart.length)return null;
 const window=hitWindowFor(level),[first,last]=range(chart,time,latency,window);
 let note=null,best=Infinity;
 for(let i=first;i<last;i++){
  const n=chart[i],error=Math.abs(n.t+latency-time);
  if(!n.hit&&!n.missed&&n.dir===direction&&error<=window&&error<best){
   best=error;note=n;
  }
 }
 return note;
}
export function timingLabel(delta,perfect,validDirection,isTap=false) {
 if(perfect)return 'PERFECTO';
 if(!validDirection && !isTap)return 'FLUIDO';
 if(isTap)return 'FLUIDO';
 if(delta>.145)return 'ANTICIPADO';
 if(delta<-.145)return 'TARDE';
 return 'A RITMO';
}
