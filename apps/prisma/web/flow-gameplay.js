// Live Flow follows the audio clock. Uncut notes leave the live stream after
// a generous grace period and remain available in end-of-song recovery.
export const FLOW_VISIBLE_LIMIT=32;
export const FLOW_LATE_GRACE=1.05;
export const FLOW_EARLY_GRACE=.35;
export const FLOW_RULES='flow-3.0';

export function flowCandidates(chart,time,latency=0,travel=3.4,start=0,recovery=false){
  const notes=[];
  let from=start;
  if(!recovery){
    let lo=start,hi=chart.length;
    while(lo<hi){const mid=(lo+hi)>>>1;if(chart[mid].t+latency<time-FLOW_LATE_GRACE)lo=mid+1;else hi=mid;}
    from=lo;
  }
  for(let i=from;i<chart.length&&notes.length<(recovery?4:FLOW_VISIBLE_LIMIT);i++){
    const n=chart[i];if(n.hit||n.missed)continue;
    if(n.t+latency>time+travel)break;
    notes.push(n);
  }
  return notes;
}

export class FlowPresentation {
  constructor(){this.remaining=new WeakMap();}
  step(notes,time,dt,latency=0,recovery=false){
    if(!recovery)return new Map(notes.map(n=>[n,n.t+latency-time]));
    const positions=new Map(),advance=Math.max(0,Math.min(.1,dt));
    notes.forEach((n,index)=>{
      // Queue followers behind the waiting cube, even after their musical
      // onset. Promotion advances at normal speed instead of popping forward.
      const target=Math.max(n.t+latency-time,index*.85);
      const previous=this.remaining.get(n)??target;
      const remaining=Math.max(target,previous-advance);
      this.remaining.set(n,remaining);positions.set(n,remaining);
    });
    return positions;
  }
  departure(delta,recovery=false){
    if(recovery||delta>=0)return {yShift:0,sizeScale:1};
    const phase=Math.min(1,-delta/FLOW_LATE_GRACE),smooth=phase*phase*(3-2*phase);
    return {yShift:-1.3*smooth,sizeScale:1-.92*phase*phase*phase};
  }
  deferred(chart,time,latency=0){
    let count=0;
    for(const n of chart){if(n.t+latency>=time-FLOW_LATE_GRACE)break;if(!n.hit&&!n.missed)count++;}
    return count;
  }
}

export const scoreRules=level=>level==='flow'?FLOW_RULES:'classic';
export const recordRules=record=>record.rules||(record.level==='flow'?'flow-legacy':'classic');
export function keepRecord(records,record){
  return [...records.filter(r=>!(r.track===record.track&&r.level===record.level&&
    recordRules(r)===recordRules(record)&&r.score<=record.score)),record]
    .sort((a,b)=>b.score-a.score).slice(0,40);
}
