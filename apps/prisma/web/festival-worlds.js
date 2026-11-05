// PRISMA Festival: audio-clock worlds and bounded, silent pyrotechnics.
// Pure planning and analytical motion keep pause, replay and seek identical.
const clamp=(v,a,b)=>Math.max(a,Math.min(b,v));
const valid=n=>Number.isFinite(n);
const TAU=Math.PI*2;
const hash=n=>{const x=Math.sin(n*127.1+53.7)*43758.5453;return x-Math.floor(x);};
const upper=(xs,t)=>{let a=0,b=xs.length;while(a<b){const m=(a+b)>>>1;if(xs[m].t<=t)a=m+1;else b=m;}return a;};
export const WORLDS=Object.freeze([
  {id:'galaxy',name:'Galaxia viva',subtitle:'Órbitas y polvo estelar',colors:['#8c89ff','#ff75cc'],base:'#080b24'},
  {id:'neon',name:'Puerto neón',subtitle:'Ciudad, lluvia y reflejos',colors:['#32e6ff','#ff4bb8'],base:'#071827'},
  {id:'aurora',name:'Catedral polar',subtitle:'Auroras, hielo y cristales',colors:['#6dffd6','#97a7ff'],base:'#071e25'},
  {id:'abyss',name:'Templo abisal',subtitle:'Medusas y ruinas sumergidas',colors:['#2fd7e9','#9378ff'],base:'#041a2b'},
  {id:'volcano',name:'Sol de obsidiana',subtitle:'Eclipse, lava y ceniza dorada',colors:['#ffad57','#ff566e'],base:'#220b1b'}
]);
export const WORLD_IDS=WORLDS.map(w=>w.id);
export const FIREWORK_LIMIT=4;
export const FIREWORK_LIFE=1.85;
export const FIREWORK_LEAD=.48;
const world=id=>WORLDS.find(w=>w.id===id)||WORLDS[0];

export function makeFestivalProgram(map,concert={bars:[]}){
  const accents=map?.fallback?[]:(map?.accents||[]).filter(a=>valid(a.t)&&a.t>=0&&valid(a.strength));
  const shells=[];let last=-Infinity;
  for(let i=0;i<accents.length;i++){
    const a=accents[i];
    if(!a.major||a.strength<.5||a.t-last<(a.drop?2.4:3.6))continue;
    shells.push({t:a.t,id:i,kind:a.drop?'willow':['peony','ring','palm'][shells.length%3],power:a.drop?1:.65+a.strength*.25,source:'music'});
    last=a.t;
  }
  const chapters=[{t:0,id:'galaxy'}];
  if(!map?.fallback)for(let i=6;i<(concert.bars||[]).length;i+=6){
    const target=concert.bars[i].t;
    const n=upper(accents,target-.35),a=accents[n];
    if(!a||a.t>target+1.5||a.t-chapters.at(-1).t<10||a.t>(map.duration||60)-4)continue;
    chapters.push({t:a.t,id:WORLD_IDS[chapters.length%WORLD_IDS.length]});
  }
  return {accents,shells,chapters,duration:map?.duration||60};
}

export function worldFrame(program,time,selection='journey',reduced=false){
  const t=valid(time)?Math.max(0,time):0;
  if(selection!=='journey')return {current:world(selection),previous:null,mix:1,index:0};
  const chapters=program?.chapters?.length?program.chapters:[{t:0,id:'galaxy'}];
  const index=Math.max(0,upper(chapters,t)-1),c=chapters[index];
  const phase=clamp((t-c.t)/1.5,0,1),mix=reduced?1:phase*phase*(3-2*phase);
  return {current:world(c.id),previous:index>0&&mix<1?world(chapters[index-1].id):null,mix:index?mix:1,index};
}

export class Constellation {
  constructor(){this.reset();}
  reset(){this.charge=0;this.completed=0;}
  miss(){this.charge=0;}
  hit(base){
    if(!valid(base)||base<120){this.charge=0;return false;}
    if(++this.charge<8)return false;
    this.charge=0;this.completed++;return true;
  }
}

// Rewards may choose a real future accent, never fabricate a beat or XI hit.
export function rewardFirework(program,time,serial=0){
  if(!valid(time)||time<0)return null;
  const i=upper(program.accents,time-1e-6);
  const a=program.accents[i];
  if(!a||a.t-time>.85)return null;
  return {t:a.t,id:100000+serial,kind:'willow',power:1,source:'constellation'};
}

export function fireworkFrame(program,time,{quality='auto',reduced=false,enabled=true,rewards=[]}={}){
  if(reduced||!enabled||!valid(time)||time<0)return [];
  const events=program?.shells||[],lo=upper(events,time-FIREWORK_LIFE),hi=upper(events,time+FIREWORK_LEAD);
  const active=[...events.slice(lo,hi),...rewards.filter(e=>e.t>=time-FIREWORK_LIFE&&e.t<=time+FIREWORK_LEAD)]
    .sort((a,b)=>a.t-b.t||a.id-b.id).slice(-FIREWORK_LIMIT);
  const count=quality==='battery'?12:quality==='high'?40:26;
  return active.map(e=>{
    const age=time-e.t,side=e.id%2?-1:1,cx=side<0?.16:.84,cy=.22+hash(e.id+8)*.13;
    const rocket=age<0?{phase:clamp(1+age/FIREWORK_LEAD,0,1),x:side<0?.08:.92,y:.94,cx,cy}:null;
    const sparks=[];
    if(age>=0&&age<FIREWORK_LIFE){
      for(let i=0;i<count;i++){
        const angle=TAU*i/count+hash(e.id)*TAU,spread=.075+.045*hash(i+e.id);
        const speed=spread*e.power,drag=(1-Math.exp(-age*1.75))/1.75;
        const willow=e.kind==='willow',palm=e.kind==='palm';
        const radius=e.kind==='ring'?.105*age:drag*speed*3;
        const fall=age*age*(willow?.053:.033),squeeze=palm?.56:1;
        sparks.push({x:cx+Math.cos(angle)*radius,y:cy+Math.sin(angle)*radius*squeeze+fall,
          dx:Math.cos(angle)*.008,dy:Math.sin(angle)*.008*squeeze+age*.006,
          alpha:clamp((1-age/FIREWORK_LIFE)**1.3*(.65+hash(i+2)*.35),0,1),gold:willow&&i%3!==0});
      }
    }
    return {...e,age,cx,cy,rocket,sparks,flash:age>=0&&age<.13?(1-age/.13)*.18:0};
  });
}

export function protectPlayfield(ctx,w,h,preview=false){
  if(preview)return;
  ctx.beginPath();ctx.rect(0,0,w,h*.22);ctx.rect(0,h*.22,w*.285,h*.66);
  ctx.rect(w*.715,h*.22,w*.285,h*.66);ctx.rect(0,h*.88,w,h*.12);ctx.clip();
}
const stroke=(ctx,points,color,width=1)=>{ctx.beginPath();points.forEach(([x,y],i)=>i?ctx.lineTo(x,y):ctx.moveTo(x,y));ctx.strokeStyle=color;ctx.lineWidth=width;ctx.stroke();};
function polygon(ctx,points,fill,line){ctx.beginPath();points.forEach(([x,y],i)=>i?ctx.lineTo(x,y):ctx.moveTo(x,y));ctx.closePath();ctx.fillStyle=fill;ctx.fill();if(line){ctx.strokeStyle=line;ctx.lineWidth=1;ctx.stroke();}}

export function drawWorld(ctx,w,h,frame,time,{preview=false,reduced=false,battery=false,energy=0,beat=0}={}){
  const render=(spec,alpha)=>{
    if(alpha<=0)return;ctx.save();ctx.globalAlpha=alpha;protectPlayfield(ctx,w,h,preview);
    const t=reduced?0:Math.max(0,time),motion=reduced?0:clamp(energy,0,1),pulse=reduced?0:clamp(beat,0,1);
    // Transparent scenery shares the underlying stage sky. An opaque exterior
    // would expose the playfield's protective clip as a pasted-on rectangle.
    const [a,b]=spec.colors;
    if(spec.id==='neon'){
      // Layered architecture, independently lit windows and wet reflections.
      for(let layer=0;layer<2;layer++)for(let i=0;i<(battery?9:17);i++){
        const bw=w/(layer?18:11),x=(i/(layer?16:10))*w,bh=h*(.12+hash(i+layer*43)*.35),y=h*.78-bh;
        if(!preview&&x<w*.715&&x+bw*.8>w*.285)continue;
        ctx.fillStyle=layer?'#081023':'#0d2440';ctx.fillRect(x,y,bw*.8,bh);
        stroke(ctx,[[x,y+bh],[x,y],[x+bw*.8,y]],i%2?a+'80':b+'80',1);
        for(let k=0;k<(battery?4:9);k++){
          const yy=y+8+k*bh/11;ctx.fillStyle=(i+k)%3? a+'44':b+'75';
          ctx.globalAlpha=alpha*(.45+.25*pulse+hash(i+k)*.2);ctx.fillRect(x+bw*.15,yy,bw*.44,2);
        }
        ctx.globalAlpha=alpha*.24;ctx.fillStyle=i%2?a:b;ctx.fillRect(x,h*.81,bw*.5,bh*.24);ctx.globalAlpha=alpha;
      }
      if(!reduced)for(let i=0;i<(battery?12:35);i++){
        const x=hash(i+8)*w,y=((hash(i+35)+t*.43)%1)*h;
        stroke(ctx,[[x,y],[x-3,y+10]],'#b6dfff35',.7);
      }
      stroke(ctx,[[0,h*.8],[w,h*.8]],a+'55',1.5);
    }else if(spec.id==='aurora'){
      for(let ribbon=0;ribbon<(battery?2:4);ribbon++){
        ctx.beginPath();for(let k=0;k<=28;k++){const x=k*w/28,y=h*(.07+ribbon*.023+Math.sin(k*.25+t*.14+ribbon)*.034);k?ctx.lineTo(x,y):ctx.moveTo(x,y);}
        ctx.strokeStyle=(ribbon%2?a:b)+(ribbon%2?'40':'55');ctx.lineWidth=h*(.025+motion*.015);ctx.stroke();
      }
      for(let i=0;i<8;i++){
        const side=i%2?-1:1,x=w*(.5+side*(.34+Math.floor(i/2)*.07)),y=h*(.67+hash(i)*.14),r=h*(.13+hash(i+40)*.17),rw=Math.min(r,w*.052);
        polygon(ctx,[[x-rw,y+r*.4],[x,y-r],[x+rw,y+r*.4]],'#132f42',a+'60');
        polygon(ctx,[[x,y-r],[x+rw*.2,y-r*.3],[x-rw*.16,y-r*.13]],'#aff7ec70');
      }
      for(const side of [-1,1])for(let i=0;i<3;i++){
        const x=w*(.5+side*(.34+i*.055)),y=h*.85,r=h*(.04+hash(i)*.09);
        polygon(ctx,[[x-r*.26,y],[x-r*.15,y-r],[x+r*.2,y-r*1.3],[x+r*.32,y-r*.24],[x,y+r*.12]],'#206c7b',a+'a0');
      }
    }else if(spec.id==='abyss'){
      for(let i=0;i<(battery?3:6);i++){
        const side=i%2?-1:1,x=w*(.5+side*(.32+hash(i)*.16)),y=h*(.18+hash(i+30)*.48)+Math.sin(t*.6+i)*h*.013,r=h*(.018+hash(i)*.026);
        ctx.beginPath();ctx.ellipse(x,y,r,r*.53,0,Math.PI,TAU);ctx.closePath();ctx.fillStyle=i%2?a+'65':b+'75';ctx.fill();
        for(let tentacle=0;tentacle<4;tentacle++){
          ctx.beginPath();ctx.moveTo(x-r*.7+tentacle*r*.45,y);ctx.bezierCurveTo(x-r+tentacle*r*.5,y+r,x+Math.sin(t+i+tentacle)*r,y+r*1.7,x+tentacle*r*.18,y+r*2.4);
          ctx.strokeStyle=i%2?a+'65':b+'65';ctx.lineWidth=1;ctx.stroke();
        }
      }
      for(const side of [-1,1])for(let i=0;i<4;i++){
        const x=w*(.5+side*(.32+i*.055)),y=h*.88,hh=h*(.17+hash(i+15)*.15),ww=w*.017;
        ctx.fillStyle='#123444';ctx.fillRect(x-ww/2,y-hh,ww,hh);ctx.fillRect(x-ww*.8,y-hh,ww*1.6,5);
        stroke(ctx,[[x-ww*.2,y],[x-ww*.2,y-hh+8]],a+'50',1);
      }
      for(let i=0;i<(battery?10:24);i++){
        const x=hash(i+40)*w,y=h*(1-((hash(i)+t*.025)%1));ctx.beginPath();ctx.arc(x,y,1+hash(i+7)*2,0,TAU);ctx.strokeStyle=a+'40';ctx.lineWidth=.8;ctx.stroke();
      }
    }else if(spec.id==='volcano'){
      const x=w*.5,y=h*.105,r=h*.067;
      for(let k=3;k>0;k--){ctx.beginPath();ctx.arc(x,y,r+k*5+pulse*3,0,TAU);ctx.strokeStyle=(k%2?a:b)+(k===1?'aa':'40');ctx.lineWidth=k===1?3:1.2;ctx.stroke();}
      ctx.beginPath();ctx.arc(x,y,r,0,TAU);ctx.fillStyle='#080710';ctx.fill();
      for(const side of [-1,1])for(let i=0;i<5;i++){
        const xx=w*(.5+side*(.34+i*.06)),yy=h*.8,rr=h*(.13+hash(i+7)*.12);
        polygon(ctx,[[xx-rr,yy],[xx-rr*.1,yy-rr],[xx+rr*.35,yy-rr*.8],[xx+rr,yy]],'#261525',b+'45');
        stroke(ctx,[[xx-rr*.1,yy-rr],[xx+rr*.02,yy-rr*.5],[xx-rr*.13,yy-rr*.3],[xx+rr*.1,yy]],a+(pulse>.4?'b0':'65'),1.5);
      }
      if(!reduced)for(let i=0;i<(battery?10:28);i++){
        const xx=hash(i+4)*w,yy=h*(1-((hash(i+9)+t*.055)%1));ctx.fillStyle=i%3?a:b;ctx.globalAlpha=alpha*(.25+hash(i)*.5);ctx.fillRect(xx,yy,1.5,2.5);
      }
    }else{
      for(let k=0;k<3;k++){
        ctx.beginPath();ctx.ellipse(w*.5,h*.10,h*(.16+k*.055),h*(.025+k*.008),-.12+Math.sin(t*.04)*.08,0,TAU);ctx.strokeStyle=(k%2?a:b)+'45';ctx.lineWidth=1.2;ctx.stroke();
      }
      for(let i=0;i<(battery?24:65);i++){ctx.fillStyle=i%4?a+'90':'#d1dfff65';ctx.fillRect(hash(i+61)*w,hash(i+89)*h,hash(i)> .8?1.7:1,1);}
    }
    ctx.restore();
  };
  if(frame.previous)render(frame.previous,1-frame.mix);render(frame.current,frame.mix);
}

export function drawFireworks(ctx,w,h,events,spec,{preview=false,battery=false}={}){
  if(!events.length)return;ctx.save();protectPlayfield(ctx,w,h,preview);ctx.globalCompositeOperation='lighter';ctx.lineCap='round';
  for(const e of events){
    const color=spec.colors[e.id%2],r=e.rocket;
    if(r){
      const p=r.phase,q=Math.max(0,p-.22),position=u=>[w*(r.x+(r.cx-r.x)*u),h*(r.y+(r.cy-r.y)*(1-(1-u)**2))];
      stroke(ctx,[position(q),position(p)],color,1.7);const [x,y]=position(p);ctx.fillStyle='#fff4d9';ctx.fillRect(x-1,y-2,2,4);
    }
    if(e.flash){ctx.beginPath();ctx.arc(e.cx*w,e.cy*h,7,0,TAU);ctx.fillStyle='#fff6e8';ctx.globalAlpha=e.flash;ctx.fill();}
    for(const p of e.sparks){
      ctx.globalAlpha=p.alpha;const x=p.x*w,y=p.y*h,col=p.gold?'#ffd684':color;
      if(!battery){stroke(ctx,[[x-p.dx*w*2,y-p.dy*h*2],[x,y]],col+'38',3);}
      stroke(ctx,[[x-p.dx*w,y-p.dy*h],[x,y]],col,1.25);ctx.fillStyle='#fff3d8';ctx.fillRect(x-.6,y-.6,1.2,1.2);
    }
  }
  ctx.restore();
}
