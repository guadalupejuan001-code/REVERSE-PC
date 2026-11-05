// Musical input and readable note motion. All time values use the audio clock.
const clamp=(v,a,b)=>Math.max(a,Math.min(b,v));
export const NOTE_SIZE=.64;
export function approachSeconds(bpm=120,level='flow'){
  const minimum={flow:3.2,pulse:2.9,vertigo:2.7}[level]||3.2;
  return clamp(({flow:6.5,pulse:6,vertigo:5.5}[level]||6.5)*60/clamp(bpm||120,40,260),minimum,4.8);
}
export function noteMotion(note,time,latency=0,travel=2.25){
  const delta=note.t+latency-time,remaining=clamp(Math.max(0,delta)/travel,0,1);
  // Near-linear apparent growth instead of the former near-camera explosion.
  const scale=.30+.70*(1-remaining),z=4.8*(1/scale-1);
  const alpha=note.holding?1:delta>=0?.55+.45*clamp((travel-delta)/.12,0,1):clamp(1+delta/.6,.35,1);
  return {z:note.holding?0:z,size:NOTE_SIZE,delta,alpha,hot:note.holding||Math.abs(delta)<.095};
}

export function arrivalQueue(chart,time,latency=0,travel=3.6){
  const start=time-latency-.36,end=time-latency+travel;
  let lo=0,hi=chart.length;while(lo<hi){const m=(lo+hi)>>>1;if(chart[m].t<start)lo=m+1;else hi=m;}
  const result=[];let rank=0,last=-Infinity;
  for(let i=lo;i<chart.length&&chart[i].t<=end;i++){
    const n=chart[i];if(n.hit||n.missed||n.holding)continue;
    if(n.t-last>.012){rank++;last=n.t;}
    result.push({note:n,rank,delta:n.t+latency-time});
  }
  return result;
}

// Durations are evidence from the decoded envelope, not invented from BPM.
export function decorateNotes(chart,level='flow'){
  let holdUntil=-Infinity,lastHold=-Infinity;
  const result=[];
  for(let i=0;i<chart.length;i++){
    const n={...chart[i],kind:'cut',duration:0};
    // A beginner can finish the sustain before reading the next gesture.
    if(level==='flow'&&n.t<holdUntil+.10)continue;
    const duration=clamp(Number(n.sustain)||0,0,1.6);
    if(duration>=.38&&n.t-lastHold>=(level==='flow'?5:3)&&
       !chart.some((p,j)=>j!==i&&Math.abs(p.t-n.t)<.005)){
      n.kind='hold';n.duration=duration;n.dir=0;n.row=1;n.lane=1;
      holdUntil=n.t+duration;lastHold=n.t;
    }
    // On faster charts other notes remain playable beside the held finger.
    if(level!=='flow'&&n.kind!=='hold'&&n.t<holdUntil+.12&&n.lane===1&&n.row===1){n.row=0;n.lane=n.color?0:2;}
    result.push(n);
  }
  let phrase=0;
  for(let i=0;i<result.length;){
    const group=[];let end=i;
    while(end<result.length&&group.length<4){
      const n=result[end],prev=group.at(-1);
      if(n.kind==='hold'||n.source==='synthetic'||(end>0&&result[end-1].t===n.t)||
         (result[end+1]&&result[end+1].t===n.t)||
         (prev&&(n.t-prev.t>.70||n.t-prev.t<.12)))break;
      group.push(n);end++;
    }
    if(group.length>=3){
      for(let k=0;k<group.length;k++){
        const n=group[k],lane=[0,1,2,1][k];
        n.phrase=phrase;n.chainIndex=k;n.chainLength=group.length;
        n.lane=phrase%2?2-lane:lane;n.color=k%2;
        if(k>0)n.dir=n.lane>group[k-1].lane?1:3;
      }
      phrase++;
    }
    i=Math.max(i+1,end);
  }
  return result;
}

export class SustainController {
  constructor(){this.active=new Map();}
  clear(){for(const n of this.active.keys())n.holding=false;this.active.clear();}
  begin(note,time,input,grade,latency=0){
    if(note.kind!=='hold'||note.hit||note.missed||note.holding||!input||
       [...this.active.values()].some(h=>h.input.kind===input.kind&&h.input.id===input.id))return false;
    note.holding=true;note.holdProgress=0;
    this.active.set(note,{input,grade,end:note.t+latency+note.duration,suspended:false});return true;
  }
  suspend(){for(const h of this.active.values())h.suspended=true;}
  resume(time){for(const h of this.active.values())if(h.suspended)h.regrabDeadline=Math.min(h.end,time+.65);}
  regrab(input,time,within){
    for(const [n,h]of this.active)if(h.suspended&&time<=h.end&&within(n)){
      h.input=input;h.suspended=false;return true;
    }
    return false;
  }
  step(time,isHeld,within){
    const completed=[],failed=[];
    for(const [note,h]of this.active){
      if(h.suspended){if(time>(h.regrabDeadline??Infinity)){failed.push({note});note.holding=false;this.active.delete(note);}continue;}
      note.holdProgress=clamp(1-(h.end-time)/note.duration,0,1);
      const held=isHeld(h.input)&&within(note,h.input);
      if(time>=h.end-.055&&held){completed.push({note,grade:h.grade});}
      else if(!held){failed.push({note});}
      else continue;
      note.holding=false;this.active.delete(note);
    }
    return {completed,failed};
  }
  release(input,time){
    const completed=[],failed=[];
    for(const [note,h]of this.active)if(!h.suspended&&h.input.kind===input.kind&&h.input.id===input.id){
      (time>=h.end-.055?completed:failed).push({note,grade:h.grade});
      note.holding=false;this.active.delete(note);
    }
    return {completed,failed};
  }
}

export class PhraseController {
  constructor(){this.reset();}
  reset(){this.progress=new Map();this.failed=new Set();this.completed=0;}
  miss(note){if(Number.isInteger(note.phrase)){this.failed.add(note.phrase);this.progress.delete(note.phrase);}}
  hit(note){
    if(!Number.isInteger(note.phrase)||this.failed.has(note.phrase))return false;
    const done=this.progress.get(note.phrase)||new Set();done.add(note.chainIndex);
    if(done.size===note.chainLength){this.failed.add(note.phrase);this.progress.delete(note.phrase);this.completed++;return true;}
    this.progress.set(note.phrase,done);return false;
  }
}
