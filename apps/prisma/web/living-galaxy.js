// Audio-clock scenery. No timers, RNG, score mutations or audio sources.
const clamp=(v,a,b)=>Math.max(a,Math.min(b,v));
const TAU=Math.PI*2;
const hues=['#52dcff','#a88bff','#ff69bb','#66ffce','#ffbb79','#7c9dff'];
const hash=n=>{const x=Math.sin(n*127.1+71.3)*43758.5453;return x-Math.floor(x);};
const rgb=hex=>`${parseInt(hex.slice(1,3),16)},${parseInt(hex.slice(3,5),16)},${parseInt(hex.slice(5,7),16)}`;
const after=(xs,t)=>{let a=0,b=xs.length;while(a<b){const m=(a+b)>>>1;if(xs[m].t<=t)a=m+1;else b=m;}return a;};

// Keep the overlay sharp even when the expensive scene reduces its resolution.
export function overlayPixelRatio(w,h,device=1,quality='auto'){
  const ceiling=quality==='battery'?1.5:quality==='high'?3:2.5;
  const budget=quality==='battery'?1600000:quality==='high'?4200000:3200000;
  return Math.max(.5,Math.min(device||1,ceiling,Math.sqrt(budget/Math.max(1,w*h))));
}

export function livingGalaxyFrame(map,time,pose,{quality='auto',reduced=false}={}){
  const t=Number.isFinite(time)?time:0,accents=map?.fallback?[]:map?.accents||[];
  const end=after(accents,t),start=Math.max(0,after(accents,t-1.25));
  let bass=0,mid=0,treble=0;
  const bursts=[];
  for(let i=start;i<end;i++){
    const a=accents[i],age=t-a.t,s=a.strength;
    const weights=a.bands||[a.source==='bass'?.85:.3,a.source==='melody'?.8:.3,a.source==='percussion'?.9:.3];
    bass=Math.max(bass,s*weights[0]*Math.exp(-age*12));
    mid=Math.max(mid,s*weights[1]*Math.exp(-age*9));
    treble=Math.max(treble,s*weights[2]*Math.exp(-age*18));
    if(!reduced&&a.major&&s>=.55&&age<1.1){
      const side=i%2?-1:1,phase=age/1.1;
      bursts.push({t:a.t,side,x:.5+side*(a.drop?.29:.34),y:.29+hash(i+7)*.27,
        phase,alpha:(1-phase)**1.7*s,radius:.02+phase*(a.drop?.22:.15),
        color:hues[i%hues.length],rays:quality==='battery'?6:a.drop?18:12});
    }
  }
  const energy=t<0?0:clamp(pose?.energy||0,0,1),phase=pose?.beat||0;
  const pulse=Math.max(bass,mid,treble);
  const speakers=[-1,1].map((side,i)=>({side,x:side<0?.085:.915,y:.66,
    cone:reduced?0:bass,mid:reduced?0:mid,treble:reduced?0:treble,
    rotation:reduced?0:phase*.23+side*.4,color:hues[(Math.floor(phase/8)+i*3)%6],
    level:reduced?.2:.24+energy*.26+pulse*.45}));
  const rays=[];
  const count=reduced?0:quality==='battery'?6:quality==='high'?28:18;
  for(let i=0;i<count;i++){
    const side=i%2?-1:1,group=Math.floor(i/2),sweep=Math.sin(phase*Math.PI/8+group*.53);
    const roof=group%3===0;
    rays.push({x:side<0?.09:.91,y:.41,
      tx:roof?.5+Math.sin(phase*.21+group)*.48:.5+side*(.30+.19*(.5+sweep*.5)),
      ty:roof?.035:.12+hash(group+30)*.76,
      width:group%4===0?2:1,alpha:.15+energy*.16+pulse*.36,
      color:hues[(group+Math.floor(phase/8))%6]});
  }
  return {time:t,phase,energy,pulse,bass,mid,treble,speakers,rays,
    bursts:bursts.slice(-3),stars:reduced?12:quality==='battery'?24:quality==='high'?100:64};
}

function perimeter(ctx,w,h,preview){
  if(preview)return;
  // Four disjoint areas leave incoming arrows and the strike plane readable.
  ctx.beginPath();ctx.rect(0,0,w,h*.23);ctx.rect(0,h*.23,w*.29,h*.65);
  ctx.rect(w*.71,h*.23,w*.29,h*.65);ctx.rect(0,h*.88,w,h*.12);ctx.clip();
}
function line(ctx,x,y,tx,ty,color,width,alpha){
  ctx.beginPath();ctx.moveTo(x,y);ctx.lineTo(tx,ty);ctx.strokeStyle=`rgba(${rgb(color)},${alpha})`;ctx.lineWidth=width;ctx.stroke();
}
function speaker(ctx,s,w,h,reduced,battery){
  const sw=Math.min(w*.105,h*.25),sh=sw*2.12,x=s.x*w,y=s.y*h;
  const left=x-sw*.5,top=y-sh*.5,bevel=sw*.15;
  const body=ctx.createLinearGradient(left,top,left+sw,top+sh);
  body.addColorStop(0,'#273147');body.addColorStop(.4,'#0a1121');body.addColorStop(1,'#030714');
  ctx.beginPath();ctx.moveTo(left+bevel,top);ctx.lineTo(left+sw,top+bevel*.5);
  ctx.lineTo(left+sw,top+sh);ctx.lineTo(left,top+sh-bevel);ctx.lineTo(left,top+bevel);ctx.closePath();
  ctx.fillStyle=body;ctx.fill();ctx.strokeStyle='#607089';ctx.lineWidth=1;ctx.stroke();
  // Recessed baffle and polished side strips keep the foreground cabinet solid.
  ctx.fillStyle='#050914';ctx.fillRect(left+sw*.09,top+sw*.16,sw*.8,sh-sw*.29);
  for(const side of [-1,1])line(ctx,x+side*sw*.44,top+sw*.15,x+side*sw*.44,top+sh-sw*.12,s.color,2,s.level*.7);
  for(let driver=0;driver<2;driver++){
    const cy=top+sh*(driver?.68:.31),radius=sw*(driver?.34:.28),cone=radius*(.76+s.cone*.10);
    const g=ctx.createRadialGradient(x-radius*.13,cy-radius*.18,radius*.04,x,cy,radius);
    g.addColorStop(0,'#53647d');g.addColorStop(.27,'#1b263a');g.addColorStop(.68,'#080c18');g.addColorStop(.86,'#293650');g.addColorStop(1,'#080d19');
    ctx.beginPath();ctx.arc(x,cy,cone,0,TAU);ctx.fillStyle=g;ctx.fill();
    ctx.beginPath();ctx.arc(x,cy,radius*.30*(1+s.cone*.2),0,TAU);ctx.fillStyle='#18253a';ctx.fill();
    ctx.save();ctx.globalCompositeOperation='lighter';
    const segments=battery?10:24;
    ctx.lineWidth=Math.max(1.5,sw*.035);ctx.lineCap='round';
    for(let n=0;n<segments;n++){
      const angle=n*TAU/segments+s.rotation;
      const color=hues[(Math.floor(n*6/segments)+driver)%6];
      ctx.beginPath();ctx.arc(x,cy,radius*(1.02+s.cone*.05),angle,angle+TAU/segments*.70);
      ctx.strokeStyle=`rgba(${rgb(color)},${clamp(s.level,.1,.95)})`;ctx.stroke();
    }
    ctx.restore();
    if(!reduced&&s.cone>.05){
      ctx.beginPath();ctx.ellipse(x,cy+radius*.3,radius*(1.2+s.cone*.7),radius*.34,0,0,TAU);
      ctx.strokeStyle=`rgba(${rgb(s.color)},${s.cone*.28})`;ctx.lineWidth=1.5;ctx.stroke();
    }
  }
  for(let i=0;i<5;i++){
    const amplitude=.25+((Math.sin(s.rotation*3+i*.8)+1)*.5)*(s.cone*.6+s.mid*.3+s.treble*.4);
    ctx.fillStyle=`rgba(${rgb(hues[i])},${reduced?.24:.4+amplitude*.4})`;
    ctx.fillRect(x-sw*.27+i*sw*.11,top+sh*.92-sw*.11*amplitude,sw*.065,sw*.11*amplitude);
  }
}

export function drawLivingGalaxy(ctx,w,h,frame,{preview=false,reduced=false,battery=false,intensity=1}={}){
  ctx.save();ctx.globalAlpha=clamp(intensity,0,1);ctx.lineCap='round';
  ctx.globalCompositeOperation='lighter';
  for(const side of [-1,1]){
    const x=w*(.5+side*.37),y=h*.32,r=Math.min(w*.35,h*.72);
    const g=ctx.createRadialGradient(x,y,0,x,y,r);
    const tint=side<0?'83,88,255':'189,57,204';
    g.addColorStop(0,`rgba(${tint},${.10+frame.energy*.08+frame.bass*.07})`);g.addColorStop(1,`rgba(${tint},0)`);
    ctx.fillStyle=g;ctx.fillRect(x-r,y-r,r*2,r*2);
  }
  ctx.save();perimeter(ctx,w,h,preview);ctx.globalCompositeOperation='lighter';
  // Moving dust has actual depth/parallax; it expands out from the distant core.
  for(let i=0;i<frame.stars;i++){
    const side=i%2?-1:1,z=reduced?hash(i+2):((hash(i+2)+frame.time*.025)%1+1)%1;
    const spread=.13+z*.39,x=w*(.5+side*spread),y=h*(.46+(hash(i+21)-.5)*(1+z)*.83);
    const r=.45+z*1.2;
    ctx.beginPath();ctx.arc(x,y,r,0,TAU);ctx.fillStyle=`rgba(168,202,255,${.17+z*.35+frame.treble*.22})`;ctx.fill();
    if(!battery&&!reduced&&z>.55)line(ctx,x,y,x+side*(1+frame.bass*7),y+(y-h*.46)*.005,'#92bfff',.7,.22);
  }
  for(const ray of frame.rays){
    const x=ray.x*w,y=ray.y*h,tx=ray.tx*w,ty=ray.ty*h;
    if(!battery)line(ctx,x,y,tx,ty,ray.color,ray.width*6,ray.alpha*.045);
    line(ctx,x,y,tx,ty,ray.color,ray.width,ray.alpha);
  }
  for(const e of frame.bursts){
    const x=e.x*w,y=e.y*h,r=e.radius*Math.min(w,h),col=rgb(e.color);
    if(!battery){
      const glow=ctx.createRadialGradient(x,y,0,x,y,r*1.7);
      glow.addColorStop(0,`rgba(238,244,255,${e.alpha*.42})`);
      glow.addColorStop(.12,`rgba(${col},${e.alpha*.48})`);
      glow.addColorStop(.42,`rgba(${col},${e.alpha*.15})`);glow.addColorStop(1,`rgba(${col},0)`);
      ctx.fillStyle=glow;ctx.fillRect(x-r*1.7,y-r*1.7,r*3.4,r*3.4);
    }
    for(let ring=0;ring<(battery?1:3);ring++){
      ctx.beginPath();ctx.ellipse(x,y,r*(1+ring*.16),r*(.70+ring*.11),e.phase*.3,0,TAU);
      ctx.strokeStyle=`rgba(${col},${e.alpha*(.75-ring*.16)})`;ctx.lineWidth=2-ring*.4;ctx.stroke();
    }
    for(let i=0;i<e.rays;i++){
      const angle=i*TAU/e.rays+hash(i+e.t)*.21,dx=Math.cos(angle),dy=Math.sin(angle);
      line(ctx,x+dx*r*.56,y+dy*r*.56,x+dx*r*(1.3+hash(i)*.7),y+dy*r*(1.3+hash(i)*.7),e.color,1.6,e.alpha*.9);
    }
  }
  ctx.restore();ctx.globalCompositeOperation='source-over';
  for(const s of frame.speakers)speaker(ctx,s,w,h,reduced,battery);
  ctx.restore();
}
