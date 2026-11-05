// Flow is a practice mode. Music owns its clock; missed beats never delete
// an uncut cube or silently move the scoring timestamp.
export const FLOW_VISIBLE_LIMIT=4;
export const FLOW_RULES='flow-2.9';

export function flowCandidates(chart,time,latency=0,travel=4.8,start=0){
  const notes=[];
  for(let i=start;i<chart.length&&notes.length<FLOW_VISIBLE_LIMIT;i++){
    const n=chart[i];if(n.hit||n.missed)continue;
    if(n.t+latency>time+travel)break;
    notes.push(n);
  }
  return notes;
}

export class FlowPresentation {
  constructor(){this.remaining=new WeakMap();}
  step(notes,time,dt,latency=0){
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
}

export const scoreRules=level=>level==='flow'?FLOW_RULES:'classic';
export const recordRules=record=>record.rules||(record.level==='flow'?'flow-legacy':'classic');
export function keepRecord(records,record){
  return [...records.filter(r=>!(r.track===record.track&&r.level===record.level&&
    recordRules(r)===recordRules(record)&&r.score<=record.score)),record]
    .sort((a,b)=>b.score-a.score).slice(0,40);
}
