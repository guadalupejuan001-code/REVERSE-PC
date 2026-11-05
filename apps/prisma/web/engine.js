import { CubeGPU } from './gpu-scene.js';
import { NativeXRender } from './native-xrender.js';
import { seeded } from './audio.js';
import { MusicStageDirector, makeIntelligentChart } from './music-stage.js';
import { makeConcertProgram, concertPose, concertNativeParts, RIG_MAX_CUBOIDS } from './concert-rig.js';
import { createSpectacleEvent, pruneSpectacles, spectacleEnvelope, spectacleGeometry, SPECTACLE_MAX_EVENTS } from './combo-spectacle.js';
import { nextVisualQuality, visualBudget } from './performance-policy.js';
import { livingGalaxyFrame, drawLivingGalaxy, overlayPixelRatio } from './living-galaxy.js';
import { approachSeconds, noteMotion, decorateNotes, NOTE_SIZE, arrivalQueue, orderBadgePositions } from './note-flow.js';
import { makeFestivalProgram, worldFrame, drawWorld, fireworkFrame, drawFireworks, rewardFirework } from './festival-worlds.js';
import { worldModel } from './world-model.js';
import { flowCandidates, FlowPresentation } from './flow-gameplay.js';
export const PALETTES = { coral: ['#63ffb4','#ff5074'], violet: ['#63ffb4','#bd8bff'], ice: ['#7aeaff','#ff5074'] };
export const DIRECTIONS = [{x:0,y:-1},{x:1,y:0},{x:0,y:1},{x:-1,y:0}];
export function makeChart(peaks, level, seed = 7721, music = null) {
  const chart=makeIntelligentChart(peaks, level, seed, music);
  return level==='flow'||music?.mechanics?decorateNotes(chart,level):chart.map(n=>({...n,kind:'cut',duration:0}));
}
export function segmentDistance(px, py, ax, ay, bx, by) {
  const dx = bx - ax, dy = by - ay, l = dx * dx + dy * dy;
  const t = l ? Math.max(0, Math.min(1, ((px - ax) * dx + (py - ay) * dy) / l)) : 0;
  return Math.hypot(px - ax - t * dx, py - ay - t * dy);
}
export function visibleRange(chart,time,latency=0,travel=3.6){
  const bound=value=>{let lo=0,hi=chart.length;while(lo<hi){const mid=(lo+hi)>>>1;if(chart[mid].t<value)lo=mid+1;else hi=mid;}return lo;};
  return [bound(time-latency-.9),bound(time-latency+travel+.001)];
}
export class Scene {
  constructor(canvas, getSettings) {
    this.canvas = canvas; this.ctx = canvas.getContext('2d', { alpha:true, desynchronized:true }); this.settings = getSettings;
    this.width = 0; this.height = 0; this.particles = []; this.shards = []; this.cutRings = []; this.trails = new Map(); this.pulse = 0; this.energy = 0; this.flash = 0; this.shake = 0; this.musicStage = null; this.stageExplosions = []; this.concertProgram = makeConcertProgram(null); this.rigPose = null; this.stageShow = null;
    const random = seeded(6631); this.stars = Array.from({length:100}, () => ({x:random(),y:random(),a:.15+random()*.5,s:random()>.9?1.4:.6}));
    this.qualityScale=1;this.frameTotal=0;this.frameCount=0;this.cooldown=0;this.visualState={quality:'balanced',slowFrames:0,fastFrames:0,cooldownUntil:0};this.view=new Float32Array(4);this.paletteKey='';this.rgb=[];this.diagnostics=new URLSearchParams(location.search).has('diagnostics');this.cpuTimes=[];
    this.festivalProgram=makeFestivalProgram(null);this.rewardShells=[];
    this.gpu=NativeXRender.create()||(new URLSearchParams(location.search).get('renderer')==='canvas'?null:CubeGPU.create(canvas.parentElement));
    canvas.dataset.renderer=this.gpu?.native?(this.gpu.mesh3D?'ether-render-x-gpu':'ether-render-x-cpu'):this.gpu?'graphics-cosmic-webgl2':'canvas';
    canvas.dataset.mesh3d=String(!!this.gpu?.mesh3D);
    if(this.gpu)this.gpu.onFailure=()=>{this.gpu.canvas.remove();this.gpu=null;canvas.dataset.renderer='canvas';this.resize();};
    this.resize(); this.observer = new ResizeObserver(() => this.resize()); this.observer.observe(canvas);
  }
  setMusicStage(map,level='flow') {
    this.musicStage = new MusicStageDirector(map);
    this.level=level;this.flowCursor=0;this.flowRecovery=false;this.flowDeferred=0;this.flowPresentation=new FlowPresentation();this.flowPositions=new Map();this.visibleNotes=[];
    this.travel=this.settings().anticipation||approachSeconds(map.bpm,level);this.phraseGlow=0;
    this.concertProgram = makeConcertProgram(map);
    this.festivalProgram=makeFestivalProgram(map,this.concertProgram);this.rewardShells=[];
    this.rigPose = null;
    this.stageExplosions = [];
    this.stageShow = null;
  }
  ensureWorld(id){if(this.gpu?.mesh3D)this.gpu.prepareWorld(id,worldModel(id));}
  async prepareModels(){if(!this.gpu?.mesh3D||this.modelsReady)return;for(let i=0;i<5;i++){this.ensureWorld(i);await new Promise(resolve=>requestAnimationFrame(resolve));}this.modelsReady=true;}
  armCombo(combo, time) { return this.musicStage?.armCombo(combo, time-(this.settings().latency||0)/1000) || false; }
  cancelCombo() { this.musicStage?.cancelCombo(); }
  celebrateConstellation(time,serial){const e=rewardFirework(this.festivalProgram,time,serial);if(e){this.rewardShells.push(e);this.rewardShells=this.rewardShells.slice(-4);}return !!e;}
  clearMusicStage() { this.musicStage = null; this.stageExplosions = []; this.concertProgram = makeConcertProgram(null); this.festivalProgram=makeFestivalProgram(null);this.rewardShells=[];this.rigPose = null; this.stageShow = null; }
  resize() {
    const r=this.canvas.getBoundingClientRect(),quality=this.settings().quality||'auto';
    const budget=this.gpu?(quality==='high'?3000000:1600000):850000;
    const ceiling=quality==='battery'?1:quality==='high'?2:1.5;
    const sceneDpr=Math.min(devicePixelRatio||1,ceiling,Math.sqrt(budget/Math.max(1,r.width*r.height)))*(quality==='auto'?this.qualityScale:1);
    const dpr=overlayPixelRatio(r.width,r.height,devicePixelRatio||1,quality);
    this.width=r.width;this.height=r.height;this.dpr=dpr;
    const w=Math.max(1,Math.round(r.width*dpr)),h=Math.max(1,Math.round(r.height*dpr));
    if(this.canvas.width!==w||this.canvas.height!==h){this.canvas.width=w;this.canvas.height=h;}
    this.gpu?.resize(Math.max(1,Math.round(r.width*sceneDpr)),Math.max(1,Math.round(r.height*sceneDpr)));this.vignette=null;
  }
  adapt(frameSeconds,now){
    if(this.settings().quality!=='auto'||frameSeconds>.1||frameSeconds<=0)return;
    this.frameTotal+=frameSeconds;this.frameCount++;
    if(this.frameCount<90)return;
    const mean=this.frameTotal/this.frameCount;this.frameCount=0;this.frameTotal=0;
    this.visualState=nextVisualQuality({...this.visualState,now,frameMs:mean*1000});
    if(now<this.cooldown)return;
    const next=mean>.022?Math.max(.6,this.qualityScale-.15):mean<.0174?Math.min(1,this.qualityScale+.1):this.qualityScale;
    if(next!==this.qualityScale){this.qualityScale=next;this.cooldown=now+8000;this.resize();}
  }
  projection(x,y,z,preview = false) {
    const mobile = this.width < 580, cx = this.width * (preview ? mobile ? .53 : .725 : .5), cy = this.height * (preview ? mobile ? .79 : .51 : .49);
    const f = Math.min(this.width * 1.29, this.height * 1.22) * (preview && mobile ? .69 : 1);
    const scale = f / Math.max(.7, z + 4.8);
    return {x:cx + x * scale,y:cy + y * scale,s:scale};
  }
  motion(note,t,latency=0){
    const remaining=this.level==='flow'?this.flowPositions?.get(note):undefined;
    const m=noteMotion(note,remaining===undefined?t:note.t+latency-remaining,latency,this.travel||4.8);
    if(this.level==='flow'){
      m.alpha=1;
      const exit=this.flowPresentation.departure(m.delta,this.flowRecovery);
      m.yShift=exit.yShift;m.size*=exit.sizeScale;
    }
    return m;
  }
  noteProjection(note,t,latency=0) { const motion=this.motion(note,t,latency),p=this.projection((note.lane-1)*1.13,(note.row-.5)*1.33+(motion.yShift||0),motion.z);return {...p,s:p.s*motion.size/NOTE_SIZE,size:motion.size}; }
  celebratePhrase(time){this.phraseGlow=time+1.2;}
  drawNoteGuides(ctx,time,chart,latency){
    const colors=PALETTES[this.settings().palette],theme=this.guidance||{colors,base:'#0c1929'};
    const [cue,cue2]=theme.colors;ctx.save();ctx.lineCap='round';
    for(let lane=0;lane<3;lane++)for(let row=0;row<2;row++){
      if(this.level==='flow'&&row===0)continue;
      const p=this.projection((lane-1)*1.13,(row-.5)*1.33,0),r=p.s*NOTE_SIZE*.58;
      ctx.strokeStyle='rgba('+hexRGB(cue)+',.30)';ctx.lineWidth=1.2;
      for(const [x,y]of [[-1,-1],[1,-1],[1,1],[-1,1]]){
        ctx.beginPath();ctx.moveTo(p.x+x*r,p.y+y*r*.6);ctx.lineTo(p.x+x*r,p.y+y*r);ctx.lineTo(p.x+x*r*.6,p.y+y*r);ctx.stroke();
      }
    }
    const [a,b]=visibleRange(chart,time,latency,this.travel||3.6);
    const nearby=this.level==='flow'?[...(this.visibleNotes||[])]:chart.slice(a,b);
    for(const n of this.holdNotes||[])if(n.holding&&!nearby.includes(n))nearby.push(n);
    const badges=orderBadgePositions(this.arrivals||[],n=>this.noteProjection(n,time,latency),this.width);
    nearby.sort((a,b)=>b.t-a.t);
    for(const n of nearby){
      if(n.hit)continue;
      if(n.missed){const age=time-(n.missedAt??-Infinity);if(age>=0&&age<.28){const p=this.noteProjection(n,time,latency),r=p.s*NOTE_SIZE*.52;ctx.globalAlpha=(1-age/.28)*.45;ctx.strokeStyle='#9cb7c3';ctx.lineWidth=1;ctx.strokeRect(p.x-r,p.y-r,r*2,r*2);ctx.font='700 13px sans-serif';ctx.fillStyle='#aec1c8';ctx.textAlign='center';ctx.fillText('×',p.x,p.y+4);}continue;}
      const motion=this.motion(n,time,latency);
      if(motion.delta>(this.travel||3.6))continue;
      const p=this.noteProjection(n,time,latency),color=colors[n.color];
      const badge=badges.get(n),order=badge?.rank;
      if(order&&order<=4){
        const bx=badge.x,by=badge.y;
        if(Math.hypot(bx-badge.bx,by-badge.by)>3){ctx.beginPath();ctx.moveTo(badge.bx,badge.by);ctx.lineTo(bx,by);ctx.strokeStyle=color;ctx.lineWidth=1;ctx.globalAlpha=.35;ctx.stroke();}
        const tint=ctx.createLinearGradient(bx-9,by-9,bx+9,by+9);tint.addColorStop(0,'rgba('+hexRGB(cue)+',.30)');tint.addColorStop(1,'rgba('+hexRGB(cue2)+',.18)');
        ctx.globalAlpha=1;ctx.beginPath();ctx.arc(bx,by,9,0,Math.PI*2);ctx.fillStyle=theme.base;ctx.fill();if(order===1){ctx.fillStyle=tint;ctx.fill();}ctx.strokeStyle=order===1?cue:color;ctx.lineWidth=order===1?2:1.2;ctx.stroke();ctx.fillStyle=order===1?cue:color;ctx.font='700 11px sans-serif';ctx.textAlign='center';ctx.textBaseline='middle';ctx.fillText(String(order),bx,by+.5);ctx.textBaseline='alphabetic';
        if(order===1){const r=p.s*NOTE_SIZE*.58,glow=ctx.createLinearGradient(p.x-r,p.y-r,p.x+r,p.y+r);glow.addColorStop(0,cue);glow.addColorStop(1,cue2);ctx.strokeStyle=glow;ctx.lineWidth=2;ctx.shadowColor=cue;ctx.shadowBlur=this.settings().effects?0:7;ctx.strokeRect(p.x-r,p.y-r,r*2,r*2);ctx.shadowBlur=0;}
      }
      ctx.globalAlpha=motion.alpha;
      if(n.kind==='hold'){
        const tail={...n,t:n.t+n.duration,holding:false},end=this.noteProjection(tail,time,latency);
        ctx.beginPath();ctx.moveTo(p.x,p.y);ctx.lineTo(end.x,end.y);
        ctx.strokeStyle=color;ctx.globalAlpha*=.28;ctx.lineWidth=Math.max(3,p.s*.16);ctx.stroke();ctx.globalAlpha=motion.alpha;
        ctx.beginPath();ctx.arc(p.x,p.y,p.s*.39,-Math.PI/2,-Math.PI/2+Math.PI*2*(n.holdProgress||.025));ctx.strokeStyle=color;ctx.lineWidth=3;ctx.stroke();
        ctx.font='600 11px sans-serif';ctx.textAlign='center';ctx.fillStyle='#e7fff7';
        ctx.fillText(n.holding?'MANTÉN':'SOSTÉN',p.x,p.y-p.s*.64);
      }
      if(this.level!=='flow'&&Number.isInteger(n.chainIndex)){
        const next=nearby.find(v=>v.phrase===n.phrase&&v.chainIndex===n.chainIndex+1&&!v.hit&&!v.missed);
        if(next){const q=this.noteProjection(next,time,latency);ctx.beginPath();ctx.moveTo(p.x,p.y);ctx.lineTo(q.x,q.y);ctx.strokeStyle=color;ctx.lineWidth=1.3;ctx.globalAlpha=.2*motion.alpha;ctx.stroke();}
      }
    }
    ctx.restore();
  }
  addTrail(id,x,y,color) { let trail = this.trails.get(id); if (!trail) { trail = {points:[],color,active:true}; this.trails.set(id,trail); } trail.active = true; trail.points.push({x,y,life:1}); if (trail.points.length > 22) trail.points.shift(); }
  endTrail(id) { const trail = this.trails.get(id); if(trail) trail.active=false; }
  burst(note,p,dx,dy,quality=1) {
    const color = PALETTES[this.settings().palette][note.color], reduced = this.settings().effects;
    this.pulse = Math.max(this.pulse,.65); if (!reduced) {this.shake=2.5;this.flash=.025;}
    const length = Math.hypot(dx,dy) || 1, nx=dx/length, ny=dy/length;
    if(!reduced){this.cutRings.push({x:p.x,y:p.y,r:p.s*.28,life:1,color,perfect:quality>.9});if(this.cutRings.length>14)this.cutRings.shift();}
    for (let side of [-1,1]) this.shards.push({x:p.x,y:p.y,size:p.s*.68,angle:Math.atan2(dy,dx),vx:(-ny*side*150+nx*65),vy:(nx*side*150+ny*45),vr:side*1.8,life:1,color,side});
    // Scale disposable impact particles before touching playable note quality.
    // Quality:auto responds to the existing frame-time governor.
    const qualityMode=this.settings().quality;
    const count=reduced?4:qualityMode==='battery'?6:
      qualityMode==='auto'&&this.qualityScale<.76?9:qualityMode==='high'?27:23;
    for (let i=0;i<count;i++) {const a=Math.random()*Math.PI*2,s=70+Math.random()*270;this.particles.push({x:p.x,y:p.y,vx:Math.cos(a)*s+nx*60,vy:Math.sin(a)*s+ny*40,life:.5+Math.random()*.4,size:1+Math.random()*2,color});}
    const maxParticles=Math.min(reduced||qualityMode==='battery'?90:qualityMode==='auto'&&this.qualityScale<.76?180:330,
      visualBudget(qualityMode==='auto'?this.visualState.quality:qualityMode,reduced).particles);
    if(this.particles.length>maxParticles)this.particles.splice(0,this.particles.length-maxParticles);
    if (this.shards.length>50) this.shards.splice(0,this.shards.length-50);
  }
  cube(x,y,z,size,colorIndex,dir,rot=0,preview=false,hot=false,alpha=1) {
    if(this.gpu){const material=this.settings().quality==='battery'?0:1;
      this.gpu.cube(x,y,z,size,this.rgb[colorIndex],alpha,rot,dir,hot,material);
      return this.projection(x,y,z,preview);}
    const ctx=this.ctx,color=PALETTES[this.settings().palette][colorIndex], h=size/2, cy=Math.cos(rot),sy=Math.sin(rot),rx=-.11,cx=Math.cos(rx),sx=Math.sin(rx);
    const raw=[[-h,-h,-h],[h,-h,-h],[h,h,-h],[-h,h,-h],[-h,-h,h],[h,-h,h],[h,h,h],[-h,h,h]];
    const verts=raw.map(v=>{const xx=v[0]*cy+v[2]*sy,zz=-v[0]*sy+v[2]*cy,yy=v[1]*cx-zz*sx,zr=v[1]*sx+zz*cx;return {...this.projection(x+xx,y+yy,z+zr,preview),z:z+zr};});
    const faces=[{v:[4,5,6,7],l:.12},{v:[0,4,7,3],l:.20},{v:[1,5,6,2],l:.26},{v:[3,2,6,7],l:.09},{v:[0,1,5,4],l:.40},{v:[0,1,2,3],l:.30}].sort((a,b)=>b.v.reduce((s,i)=>s+verts[i].z,0)-a.v.reduce((s,i)=>s+verts[i].z,0));
    const p=this.projection(x,y,z,preview),rgb=hexRGB(color);ctx.save();ctx.globalAlpha=alpha;
    if(hot&&!this.settings().effects){ctx.beginPath();ctx.arc(p.x,p.y,p.s*size*.94,0,Math.PI*2);ctx.lineWidth=1;ctx.strokeStyle=`rgba(${rgb},.20)`;ctx.stroke();ctx.beginPath();ctx.arc(p.x,p.y,p.s*size*1.08,-.3,1.5);ctx.strokeStyle=`rgba(${rgb},.55)`;ctx.stroke();}
    for(const face of faces){
      ctx.beginPath();face.v.forEach((index,k)=>{const v=verts[index];k?ctx.lineTo(v.x,v.y):ctx.moveTo(v.x,v.y);});ctx.closePath();
      const g=ctx.createLinearGradient(p.x-p.s*h,p.y-p.s*h,p.x+p.s*h,p.y+p.s*h);
      g.addColorStop(0,`rgba(${rgb},${face.l+.20})`);g.addColorStop(1,`rgba(${rgb},${face.l*.44})`);
      ctx.fillStyle='#06130e';ctx.fill();ctx.fillStyle=g;ctx.fill();ctx.strokeStyle=`rgba(${rgb},${hot?.98:.66})`;ctx.lineWidth=hot?1.8:1.1;ctx.shadowColor=color;ctx.shadowBlur=this.settings().effects?0:hot?15:7;ctx.stroke();ctx.shadowBlur=0;
    }
    // A front-face inset catches the light without obscuring the direction.
    const front=[0,1,2,3].map(i=>({x:p.x+(verts[i].x-p.x)*.84,y:p.y+(verts[i].y-p.y)*.84}));
    ctx.beginPath();front.forEach((v,k)=>k?ctx.lineTo(v.x,v.y):ctx.moveTo(v.x,v.y));ctx.closePath();ctx.strokeStyle=`rgba(${rgb},.18)`;ctx.lineWidth=.7;ctx.stroke();
    const fc={x:(verts[0].x+verts[2].x)/2,y:(verts[0].y+verts[2].y)/2},a=dir*Math.PI/2,s=p.s*size*.23;
    ctx.translate(fc.x,fc.y);ctx.rotate(a);ctx.strokeStyle=hot?'#effff5':color;ctx.lineWidth=Math.max(1.7,p.s*size*.025);ctx.lineJoin='miter';ctx.shadowColor=color;ctx.shadowBlur=this.settings().effects?0:9;
    ctx.beginPath();ctx.moveTo(-s*.7,s*.12);ctx.lineTo(0,-s*.60);ctx.lineTo(s*.7,s*.12);ctx.moveTo(0,-s*.6);ctx.lineTo(0,s*.85);ctx.stroke();ctx.restore();return p;
  }
  background(time,preview,energy) {
    const ctx=this.ctx,w=this.width,h=this.height,colors=PALETTES[this.settings().palette],green=hexRGB(colors[0]),coral=hexRGB(colors[1]),vp=this.projection(0,0,0,preview);
    ctx.fillStyle='#030707';ctx.fillRect(0,0,w,h);
    const fog=ctx.createRadialGradient(vp.x,vp.y,0,vp.x,vp.y,Math.max(w*.6,h*.9));fog.addColorStop(0,`rgba(${green},${.047+energy*.02})`);fog.addColorStop(.48,`rgba(${green},.012)`);fog.addColorStop(1,'#020504');ctx.fillStyle=fog;ctx.fillRect(0,0,w,h);
    for(const s of this.stars){const px=s.x*w,py=s.y*h;ctx.fillStyle=`rgba(151,199,169,${s.a*.6})`;ctx.fillRect(px,py,s.s,s.s);}
    ctx.lineWidth=.65;
    const phase=this.settings().effects?0:(time*.65)%1;
    for(let i=16;i>=0;i--){const z=(i+phase)*2.8,depth=1-i/17;
      const tl=this.projection(-3.6,-2.7,z,preview),tr=this.projection(3.6,-2.7,z,preview),bl=this.projection(-3.6,2.4,z,preview),br=this.projection(3.6,2.4,z,preview);
      ctx.strokeStyle=`rgba(${green},${.018+depth*.05})`;ctx.beginPath();ctx.moveTo(tl.x,tl.y);ctx.lineTo(bl.x,bl.y);ctx.lineTo(br.x,br.y);ctx.lineTo(tr.x,tr.y);ctx.stroke();
    }
    for(let i=-4;i<=4;i++){const a=this.projection(i*.8,2.4,0,preview),b=this.projection(i*.8,2.4,55,preview);ctx.strokeStyle=`rgba(${green},${i%2===0?.12:.055})`;ctx.beginPath();ctx.moveTo(a.x,a.y);ctx.lineTo(b.x,b.y);ctx.stroke();}
    for(let side of [-1,1]){const color=side<0?green:coral;ctx.strokeStyle=`rgba(${color},${.2+energy*.09})`;ctx.lineWidth=1;ctx.shadowColor=side<0?colors[0]:colors[1];ctx.shadowBlur=this.settings().effects?0:8;ctx.beginPath();for(let i=0;i<25;i++){const p=this.projection(side*2.8,2.15,i*2.1,preview);i?ctx.lineTo(p.x,p.y):ctx.moveTo(p.x,p.y);}ctx.stroke();ctx.shadowBlur=0;}
    // The strike plane gives the incoming notes a clear destination.
    if(!preview){for(let lane=0;lane<3;lane++)for(let row=0;row<2;row++){const p=this.projection((lane-1)*1.13,(row-.5)*1.33,0);const r=p.s*.44;ctx.strokeStyle=`rgba(${green},.075)`;ctx.lineWidth=1;const corner=r*.17;for(const [sx,sy] of [[-1,-1],[1,-1],[1,1],[-1,1]]){ctx.beginPath();ctx.moveTo(p.x+sx*r,p.y+sy*(r-corner));ctx.lineTo(p.x+sx*r,p.y+sy*r);ctx.lineTo(p.x+sx*(r-corner),p.y+sy*r);ctx.stroke();}}}
  }
  // Scene-space armature: true 3D X Render cuboids plus a 2D lighting overlay.
  stageRig(pose) {
    if(this.gpu?.mesh3D){this.canvas.dataset.rigNativeCount='0';return;}
    if (!this.gpu || !pose) return;
    const capacity=this.gpu.native?RIG_MAX_CUBOIDS:(this.gpu.capacity||256);
    const parts=concertNativeParts(pose,Math.max(0,capacity-(this.gpu.count||0)));
    const metal=[.24,.29,.34];
    for(const p of parts) {
      const tint=p.kind==='head'&&pose.style!=='classic'&&p.lightColor
        ? [parseInt(p.lightColor.slice(1,3),16)/255,
           parseInt(p.lightColor.slice(3,5),16)/255,
           parseInt(p.lightColor.slice(5,7),16)/255]
        : p.color<0?metal:this.rgb[p.color];
      this.gpu.cube(p.x,p.y,p.z,p.size,tint,
        p.alpha,p.rotation,p.direction,p.hot,
        pose.quality==='battery'?0:p.kind==='head'?3:2);
    }
    this.canvas.dataset.rigNativeCount=String(parts.length);
  }
  drawStageFX(ctx,time,preview,cue,pose) {
    if (!pose) return;
    const reduced=pose.reduced, colors=PALETTES[this.settings().palette];
    const galaxy=pose.style!=='classic', battery=pose.quality==='battery';
    const project=point=>this.projection(point.x,point.y,point.z,preview);
    const radial=(x,y,r)=>typeof ctx.createRadialGradient==='function'
      ? ctx.createRadialGradient(x,y,0,x,y,r)
      : ctx.createLinearGradient(x-r,y-r,x+r,y+r);
    const finiteTime=Number.isFinite(time)?Math.max(0,time):0;
    ctx.save();
    ctx.globalCompositeOperation='source-over';
    if(galaxy){
      const live=livingGalaxyFrame(this.musicStage?.map,time,pose,{quality:pose.quality,reduced});
      drawLivingGalaxy(ctx,this.width,this.height,live,{preview,reduced,battery,drawSpeakers:!this.gpu?.mesh3D});
      this.canvas.dataset.speakers='2';
      this.canvas.dataset.laserCount=String(live.rays.length);
      this.canvas.dataset.ambientBursts=String(live.bursts.length);
    }
    if(this.gpu?.mesh3D){this.canvas.dataset.speakers='2';this.canvas.dataset.meshSpeakers='2';ctx.restore();return;}
    // The trusses, gimbals and lenses follow six distinct 3D fixture poses.
    // Browser/WebView overlays do not pretend to be volumetric native light.
    const fixtures=pose.fixtures;
    for(let depth=0;depth<3;depth++){
      const left=fixtures.find(f=>f.id===depth),right=fixtures.find(f=>f.id===depth+3);
      if(!left||!right)continue;
      const a=project(left.base),b=project(right.base);
      const rise=Math.max(3,a.s*.11);
      for(let rail=0;rail<2;rail++){
        const shift=rail?rise:-rise;
        ctx.beginPath();ctx.moveTo(a.x,a.y+shift);ctx.lineTo(b.x,b.y+shift);
        ctx.lineWidth=rail?1:2.2;ctx.strokeStyle=rail?'rgba(113,146,188,.19)':'rgba(126,160,193,.35)';
        ctx.stroke();
      }
      for(let k=1;k<7;k++){
        const x=a.x+(b.x-a.x)*k/7,y=a.y+(b.y-a.y)*k/7;
        ctx.beginPath();ctx.moveTo(x-4,y-rise);ctx.lineTo(x+4,y+rise);
        ctx.strokeStyle='rgba(145,174,203,.21)';ctx.lineWidth=1;ctx.stroke();
      }
    }
    for(const f of fixtures){
      const base=project(f.base),elbow=project(f.elbow),head=project(f.head);
      const target=project(f.focus),shade=galaxy?f.lightColor:colors[f.color];
      const rgb=hexRGB(shade),alpha=Math.min(reduced?.07:.29,f.intensity);
      const rayX=target.x-head.x,rayY=target.y-head.y;
      const length=Math.max(1,Math.hypot(rayX,rayY));
      const nx=-rayY/length,ny=rayX/length;
      ctx.lineCap='round';ctx.lineJoin='round';
      // Articulated Y-bracket: dark chassis, two metallic guide rails, motor hubs.
      ctx.beginPath();ctx.moveTo(base.x,base.y);ctx.lineTo(elbow.x,elbow.y);ctx.lineTo(head.x,head.y);
      ctx.strokeStyle='rgba(5,11,22,.98)';ctx.lineWidth=Math.max(4,base.s*.29);ctx.stroke();
      ctx.strokeStyle='rgba(118,148,179,.76)';ctx.lineWidth=Math.max(1.2,base.s*.078);ctx.stroke();
      for(const joint of [base,elbow]){
        const radius=Math.max(2.7,joint.s*.115);
        ctx.beginPath();ctx.arc(joint.x,joint.y,radius,0,Math.PI*2);
        ctx.fillStyle='#0a1520';ctx.fill();
        ctx.lineWidth=1.4;ctx.strokeStyle='rgba(161,194,211,.66)';ctx.stroke();
        ctx.beginPath();ctx.arc(joint.x,joint.y,radius*.39,0,Math.PI*2);
        ctx.fillStyle='rgba(117,152,180,.85)';ctx.fill();
      }
      const lensRadius=Math.max(4,head.s*.18);
      ctx.beginPath();ctx.ellipse(head.x,head.y,lensRadius*1.32,lensRadius*.85,
        f.pan*.45,0,Math.PI*2);
      ctx.fillStyle='#0b1523';ctx.fill();ctx.lineWidth=2.3;
      ctx.strokeStyle='rgba(157,177,212,.83)';ctx.stroke();
      if(!this.gpu){
        const housing=Math.max(6,head.s*.34);
        ctx.fillStyle='rgba(13,25,39,.9)';
        ctx.fillRect(head.x-housing*.5,head.y-housing*.5,housing,housing*.8);
        ctx.strokeStyle='rgba('+rgb+',.65)';ctx.lineWidth=1.2;
        ctx.strokeRect(head.x-housing*.5,head.y-housing*.5,housing,housing*.8);
      }
      // The aperture rotates with pan / tilt; its light is independent of
      // score and only pulses when decoded audio supplies actual beat energy.
      ctx.beginPath();ctx.arc(head.x,head.y,lensRadius*.63,0,Math.PI*2);
      ctx.fillStyle='rgba('+rgb+','+(reduced?.34:.66)+')';ctx.fill();
      ctx.beginPath();ctx.arc(head.x,head.y,lensRadius*.88,0,Math.PI*2);
      ctx.strokeStyle='rgba('+rgb+','+(reduced?.26:.64)+')';
      ctx.lineWidth=1.5;ctx.stroke();
      ctx.save();ctx.globalCompositeOperation='lighter';
      if(!reduced){
        const spread=Math.max(7,Math.min(42,target.s*(f.beamWidth||.34)*2.2));
        const beam=ctx.createLinearGradient(head.x,head.y,target.x,target.y);
        beam.addColorStop(0,'rgba('+rgb+','+Math.min(.38,alpha*.92)+')');
        beam.addColorStop(.54,'rgba('+rgb+','+(alpha*.45)+')');
        beam.addColorStop(1,'rgba('+rgb+',0)');
        // Wide haze silhouette, tapering into a mirrored floor footprint.
        ctx.beginPath();ctx.moveTo(head.x,head.y);
        ctx.lineTo(target.x+nx*spread,target.y+ny*spread);
        ctx.lineTo(target.x-nx*spread,target.y-ny*spread);
        ctx.closePath();ctx.fillStyle=beam;ctx.fill();
        // Twin optics and their soft beam cores. The side rays are weaker
        // than the central ray, so incoming cut arrows remain visible.
        for(const offset of [-1,0,1]){
          const shift=offset*spread*.32;
          ctx.beginPath();ctx.moveTo(head.x+nx*offset*2,head.y+ny*offset*2);
          ctx.lineTo(target.x+nx*shift,target.y+ny*shift);
          ctx.strokeStyle=beam;
          ctx.lineWidth=offset===0?Math.max(3,head.s*.22):Math.max(1.3,head.s*.09);
          ctx.stroke();
        }
      }else{
        ctx.beginPath();ctx.moveTo(head.x,head.y);ctx.lineTo(target.x,target.y);
        ctx.strokeStyle='rgba('+rgb+',.06)';ctx.lineWidth=1.2;ctx.stroke();
      }
      const spotRadius=Math.max(7,target.s*(battery?.14:.22));
      if(!reduced){
        const puddle=radial(target.x,target.y,spotRadius*2.5);
        puddle.addColorStop(0,'rgba('+rgb+','+Math.min(.25,alpha*.68)+')');
        puddle.addColorStop(1,'rgba('+rgb+',0)');
        ctx.fillStyle=puddle;ctx.fillRect(target.x-spotRadius*2.5,target.y-spotRadius*2.5,
          spotRadius*5,spotRadius*5);
        ctx.beginPath();ctx.ellipse(target.x,target.y,spotRadius,Math.max(2,spotRadius*.26),
          f.pan*.12,0,Math.PI*2);
        ctx.strokeStyle='rgba('+rgb+','+Math.min(.42,alpha*.98)+')';
        ctx.lineWidth=1.7;ctx.stroke();
      }
      ctx.restore();
    }
    // Small beat response, not a rapid full-screen strobe.
    if(cue.beat>.10) {
      const center=this.projection(0,2.24,8,preview),rgb=hexRGB(colors[0]);
      ctx.beginPath();ctx.ellipse(center.x,center.y,Math.max(3,center.s*(1.1+cue.beat)),
        Math.max(1,center.s*.14),0,0,Math.PI*2);
      ctx.strokeStyle='rgba('+rgb+','+Math.min(.20,cue.beat*.13)+')';
      ctx.lineWidth=1.5;ctx.stroke();
    }
    // Charging is only visual anticipation for an earned scheduled event.
    // It does not generate another beat or a random explosion.
    if(cue.charge && !reduced){
      const p=this.projection(0,0,2,preview),progress=cue.charge.progress;
      const radius=Math.min(this.width,this.height)*(.035+.035*progress);
      const rgb=hexRGB(colors[cue.charge.combo%20===0?1:0]);
      ctx.beginPath();ctx.arc(p.x,p.y,radius,0,Math.PI*2);
      ctx.strokeStyle='rgba('+rgb+','+(.045+progress*.11)+')';
      ctx.lineWidth=1.4;ctx.stroke();
    }
    // The cut milestone prepares the event, but ONLY the decoded musical
    // accent releases it. Geometry is a function of the exact audio time.
    for(const event of this.stageExplosions){
      const fx=spectacleGeometry(event,time,{
        reduced,battery:pose.quality==='battery'
      });
      if(!fx)continue;
      const center=this.projection(0,0,2,preview);
      const unit=Math.min(this.width,this.height)*.82;
      const rgb=hexRGB(colors[event.combo%20===0?1:0]);
      ctx.save();ctx.globalCompositeOperation='lighter';
      for(const ring of fx.rings){
        ctx.beginPath();ctx.arc(center.x,center.y,Math.max(2,ring.radius*unit),0,Math.PI*2);
        ctx.strokeStyle='rgba('+rgb+','+ring.alpha+')';
        ctx.lineWidth=ring.width;ctx.stroke();
      }
      if(fx.drop && !reduced && fx.phase<.65){
        for(const side of [-1,1]){
          const span=unit*(.16+fx.phase*.34);
          ctx.beginPath();ctx.moveTo(center.x+side*span*.28,center.y-unit*.14);
          ctx.lineTo(center.x+side*span,center.y-unit*.45);
          ctx.lineTo(center.x+side*span*.67,center.y+unit*.26);
          ctx.closePath();
          ctx.fillStyle='rgba('+rgb+','+(fx.opacity*.075)+')';ctx.fill();
        }
      }
      // Nova iris and bounded radial rays, released only by an earned
      // combination + the exact major accent chosen by the music director.
      if(!reduced&&fx.opacity>.015){
        const centerHalo=radial(center.x,center.y,unit*(.12+fx.phase*.29));
        centerHalo.addColorStop(0,'rgba('+rgb+','+Math.min(.20,fx.opacity*.16)+')');
        centerHalo.addColorStop(1,'rgba('+rgb+',0)');
        ctx.fillStyle=centerHalo;
        ctx.fillRect(center.x-unit*.35,center.y-unit*.35,unit*.7,unit*.7);
      }
      for(const ray of fx.spokes||[]){
        const dx=Math.cos(ray.angle),dy=Math.sin(ray.angle);
        ctx.beginPath();
        ctx.moveTo(center.x+dx*ray.from*unit,center.y+dy*ray.from*unit);
        ctx.lineTo(center.x+dx*ray.to*unit,center.y+dy*ray.to*unit);
        ctx.strokeStyle='rgba('+rgb+','+Math.min(.74,ray.alpha)+')';
        ctx.lineWidth=ray.width;ctx.stroke();
      }
      for(const shard of fx.shards){
        const cx=center.x+shard.x*unit,cy=center.y+shard.y*unit;
        const dx=Math.cos(shard.angle),dy=Math.sin(shard.angle);
        const reach=Math.max(2,shard.length*unit),width=Math.max(.7,shard.width*unit);
        ctx.beginPath();
        ctx.moveTo(cx+dx*reach,cy+dy*reach);
        ctx.lineTo(cx-dx*reach*.55-dy*width,cy-dy*reach*.55+dx*width);
        ctx.lineTo(cx-dx*reach*.55+dy*width,cy-dy*reach*.55-dx*width);
        ctx.closePath();
        ctx.fillStyle='rgba('+rgb+','+Math.min(.82,shard.alpha)+')';ctx.fill();
      }
      ctx.restore();
    }
    ctx.restore();
  }
  render(time,dt,chart,preview,audioEnergy=0,latency=0,animate=true) {
    const started=this.diagnostics?performance.now():0;
    const ctx=this.ctx,w=this.width,h=this.height;if(!w||!h)return;
    const key=this.settings().palette;if(key!==this.paletteKey){this.paletteKey=key;this.rgb=PALETTES[key].map(hex=>[parseInt(hex.slice(1,3),16)/255,parseInt(hex.slice(3,5),16)/255,parseInt(hex.slice(5,7),16)/255]);}
    if(this.gpu){const mobile=w<580,f=Math.min(w*1.29,h*1.22)*(preview&&mobile?.69:1);this.view[0]=preview?(mobile?.53:.725):.5;this.view[1]=preview?(mobile?.79:.51):.49;this.view[2]=f/w;this.view[3]=f/h;if(this.gpu.native)this.gpu.quality={auto:0,high:1,battery:2}[this.settings().quality]||0;this.gpu.begin(time,this.energy,this.view,this.rgb,this.settings().effects);ctx.setTransform(1,0,0,1,0,0);ctx.clearRect(0,0,this.canvas.width,this.canvas.height);}
    ctx.setTransform(this.dpr,0,0,this.dpr,0,0);this.energy+=(audioEnergy-this.energy)*.12;this.pulse=Math.max(0,this.pulse-dt*2.7);this.shake=Math.max(0,this.shake-dt*22);
    ctx.save();if(this.shake&&!this.settings().effects)ctx.translate((Math.random()-.5)*this.shake,(Math.random()-.5)*this.shake);
    if(!this.gpu)this.background(time,preview,this.energy);
    const musicTime=time-latency;
    const stageCue = this.musicStage ? this.musicStage.step(musicTime) : { beat: Math.exp(-((time % (60 / 122) + (60 / 122)) % (60 / 122)) * 8) * .55, energy: .28, charge:null, explosion:null };
    if(stageCue.explosion){
      const event=createSpectacleEvent(stageCue.explosion);
      if(event)this.stageExplosions.push(event);
      if(event&&this.gpu?.mesh3D)this.rewardShells.push({t:event.t,id:200000+event.combo,kind:event.combo>=50?'willow':'peony',power:1,source:'combo'});
      if(this.stageExplosions.length>SPECTACLE_MAX_EVENTS)
        this.stageExplosions=this.stageExplosions.slice(-SPECTACLE_MAX_EVENTS);
    }
    this.stageExplosions=pruneSpectacles(this.stageExplosions,musicTime);
    stageCue.show=spectacleEnvelope(this.stageExplosions,musicTime,this.settings().effects);
    if(musicTime<(this.phraseGlow||0))stageCue.show=Math.max(stageCue.show,.4*(this.phraseGlow-musicTime)/1.2);
    this.stageShow={charge:stageCue.charge||null,
      release:stageCue.explosion?stageCue.explosion.combo:null,
      active:this.stageExplosions.length?this.stageExplosions[this.stageExplosions.length-1].tier:null};
    const quality=this.settings().quality==='auto'?(this.qualityScale<.78?'battery':this.visualState.quality==='high'?'high':'auto'):this.settings().quality;
    const rigPose=concertPose(this.concertProgram,musicTime,stageCue,{quality,reduced:this.settings().effects,style:this.settings().stageStyle||'galaxy'});
    this.rigPose=rigPose;
    if(!preview&&this.level==='flow'){
      while(this.flowCursor<chart.length&&(chart[this.flowCursor].hit||chart[this.flowCursor].missed))this.flowCursor++;
      this.visibleNotes=flowCandidates(chart,time,latency,this.travel||3.4,this.flowCursor,this.flowRecovery);
      this.flowPositions=this.flowPresentation.step(this.visibleNotes,time,animate?dt:0,latency,this.flowRecovery);
      this.flowDeferred=this.flowPresentation.deferred(chart,time,latency);
      this.arrivals=this.visibleNotes.filter(n=>this.flowRecovery||n.t+latency-time>=-.12).map((note,i)=>({note,rank:i+1,delta:note.t+latency-time}));
      this.canvas.dataset.deferredNotes=String(this.flowDeferred);
    }else this.arrivals=preview?[]:arrivalQueue(chart,time,latency,this.travel||4.8);
    this.noteRanks=new Map(this.arrivals.map(a=>[a.note,a.rank]));
    const world=worldFrame(this.festivalProgram,preview?0:musicTime,this.settings().world||'journey',this.settings().effects);
    this.guidance=world.current;this.canvas.dataset.cueColor=world.current.colors[0];
    if(this.gpu?.mesh3D){
      const ids=['galaxy','neon','aurora','abyss','volcano'],current=ids.indexOf(world.current.id),previous=world.previous?ids.indexOf(world.previous.id):-1;
      this.ensureWorld(current);if(previous>=0)this.ensureWorld(previous);
      this.gpu.setWorld(current,previous,world.mix,musicTime,Math.min(1,rigPose.energy*.35+stageCue.beat*.65+stageCue.show*.3));
    }else drawWorld(ctx,w,h,world,musicTime,{preview,reduced:this.settings().effects,battery:quality==='battery',energy:rigPose.energy,beat:stageCue.beat});
    this.canvas.dataset.world=world.current.id;this.canvas.dataset.chapter=String(world.index+1);this.canvas.dataset.chapterCount=String(this.festivalProgram.chapters.length);
    if(preview){
      const mobile=w<580,drift=this.settings().effects?0:Math.sin(time*.65)*.1;
      const blocks=[{x:.15,y:-.8,z:7,size:.78,c:0,d:1,r:.3},{x:-1.4,y:.3,z:5.5,size:.78,c:1,d:0,r:-.27},{x:1.3,y:-1.0,z:3.3,size:.88,c:0,d:3,r:.25},{x:.86,y:.74,z:1.65,size:1.03,c:1,d:2,r:-.22},{x:-.8,y:-.15,z:0,size:1.12,c:0,d:0,r:.22}];
      const col=PALETTES[this.settings().palette];
      for(let i=0;i<2;i++){const a=this.projection(i?1.35:-1.65,i?.85:.6,.2,true),b=this.projection(i?.65:-.38,i?-.4:-.8,1,true);ctx.save();ctx.strokeStyle=col[i];ctx.globalAlpha=.35;ctx.lineWidth=mobile?1:1.5;ctx.shadowColor=col[i];ctx.shadowBlur=this.settings().effects?0:18;ctx.beginPath();ctx.moveTo(a.x-25,a.y+40);ctx.bezierCurveTo(a.x-80,a.y+25,b.x+90,b.y+30,b.x,b.y-30);ctx.stroke();ctx.restore();}
      for(const b of blocks)this.cube(b.x,b.y+drift,b.z,b.size,b.c,b.d,b.r+drift*.25,true,false,.96);
    }else{
      const [first,last]=visibleRange(chart,time,latency,this.travel||3.6);
      // Native packets have a strict 64-body cap: submit imminent notes first.
      // Browser WebGL retains far-to-near ordering for alpha blending.
      const held=(this.holdNotes||[]).filter(n=>n.holding&&!n.hit&&!n.missed);
      const incoming=this.level==='flow'?[...this.visibleNotes]:chart.slice(first,last).filter(n=>!n.hit&&!n.missed&&!n.holding);
      if(this.level!=='flow')this.visibleNotes=incoming;
      const notes=this.gpu?.native?[...held,...incoming]:[...incoming.reverse(),...held];
      for(const n of notes){
        const m=this.motion(n,time,latency);
        if(!n.holding&&m.delta>(this.travel||3.6))continue;
        this.cube((n.lane-1)*1.13,(n.row-.5)*1.33+(m.yShift||0),m.z,m.size,n.color,n.dir,0,false,n.holding||this.noteRanks.get(n)===1&&m.delta<.7,m.alpha);
      }
      this.canvas.dataset.noteCount=String(notes.filter(n=>!n.missed).length);this.canvas.dataset.lookAhead=String(this.travel||3.6);
    }
    // Notes are added before decorations: decorative parts never reserve 3D slots.
    this.stageRig(rigPose);
    this.gpu?.flush();this.drawStageFX(ctx,musicTime,preview,stageCue,rigPose);
    this.rewardShells=this.rewardShells.filter(e=>musicTime-e.t<2);
    const shells=fireworkFrame(this.festivalProgram,preview?-1:musicTime,{quality,reduced:this.settings().effects,enabled:this.settings().fireworks!==false,rewards:this.rewardShells});
    drawFireworks(ctx,w,h,shells,world.current,{preview,battery:quality==='battery'});
    this.canvas.dataset.fireworks=String(shells.length);this.canvas.dataset.fireworkSparks=String(shells.reduce((n,e)=>n+e.sparks.length,0));
    this.canvas.dataset.rewardFireworks=String(shells.filter(e=>e.source==='constellation').length);
    if(!preview)this.drawNoteGuides(ctx,time,chart,latency);this.drawEffects(animate?dt:0);ctx.restore();
    if(this.diagnostics){this.cpuTimes.push(performance.now()-started);if(this.cpuTimes.length>240)this.cpuTimes.shift();if(this.cpuTimes.length%30===0){const sorted=[...this.cpuTimes].sort((a,b)=>a-b);this.canvas.dataset.renderMs=(sorted.reduce((a,b)=>a+b,0)/sorted.length).toFixed(3);this.canvas.dataset.renderP95=sorted[Math.floor(sorted.length*.95)].toFixed(3);this.canvas.dataset.visibleCubes=String(this.gpu?.count||0);this.canvas.dataset.pixelRatio=this.dpr.toFixed(2);}}
    if(this.gpu)return;
    if(!this.vignette){this.vignette=ctx.createRadialGradient(w*.5,h*.5,h*.2,w*.5,h*.5,Math.max(w,h)*.72);this.vignette.addColorStop(0,'#0000');this.vignette.addColorStop(1,'#0009');}ctx.fillStyle=this.vignette;ctx.fillRect(0,0,w,h);
  }
  drawEffects(dt){
    const ctx=this.ctx;
    for(let i=this.shards.length-1;i>=0;i--){const s=this.shards[i];s.life-=dt*1.8;if(s.life<=0){this.shards.splice(i,1);continue;}s.x+=s.vx*dt;s.y+=s.vy*dt;s.vy+=180*dt;s.angle+=s.vr*dt;ctx.save();ctx.translate(s.x,s.y);ctx.rotate(s.angle);ctx.globalAlpha=Math.min(1,s.life*1.5);ctx.fillStyle='#0b2116';ctx.strokeStyle=s.color;ctx.lineWidth=1.3;ctx.shadowColor=s.color;ctx.shadowBlur=0;ctx.beginPath();ctx.moveTo(-s.size*.5,s.side*s.size*.05);ctx.lineTo(s.size*.5,s.side*s.size*.05);ctx.lineTo(s.size*.5,s.side*s.size*.48);ctx.lineTo(-s.size*.5,s.side*s.size*.48);ctx.closePath();ctx.fill();ctx.globalAlpha*=.6;ctx.fillStyle=s.color;ctx.fill();ctx.globalAlpha=Math.min(1,s.life);ctx.stroke();ctx.restore();}
    for(let i=this.particles.length-1;i>=0;i--){const p=this.particles[i];p.life-=dt*1.8;if(p.life<=0){this.particles.splice(i,1);continue;}p.x+=p.vx*dt;p.y+=p.vy*dt;p.vy+=140*dt;ctx.globalAlpha=p.life;ctx.strokeStyle=p.color;ctx.lineWidth=p.size;ctx.beginPath();ctx.moveTo(p.x,p.y);ctx.lineTo(p.x-p.vx*.017,p.y-p.vy*.017);ctx.stroke();}ctx.globalAlpha=1;
    for(let i=this.cutRings.length-1;i>=0;i--){
      const r=this.cutRings[i];r.life-=dt*4.8;if(r.life<=0){this.cutRings.splice(i,1);continue;}
      ctx.save();ctx.globalCompositeOperation='lighter';ctx.globalAlpha=r.life*.55;
      ctx.beginPath();ctx.arc(r.x,r.y,r.r*(1+(1-r.life)*1.6),0,Math.PI*2);
      ctx.strokeStyle=r.color;ctx.lineWidth=r.perfect?2.2:1.2;ctx.stroke();ctx.restore();
    }
    for(const [id,trail]of this.trails){
      for(const p of trail.points)p.life-=dt*4.3;
      trail.points=trail.points.filter(p=>p.life>0);
      if(trail.points.length<2){if(!trail.active&&!trail.points.length)this.trails.delete(id);continue;}
      const points=trail.points,last=points[points.length-1];
      ctx.save();ctx.lineJoin='round';ctx.lineCap='round';
      const path=()=>{
        ctx.beginPath();ctx.moveTo(points[0].x,points[0].y);
        for(let i=1;i<points.length-1;i++){
          const p=points[i],n=points[i+1];ctx.quadraticCurveTo(p.x,p.y,(p.x+n.x)*.5,(p.y+n.y)*.5);
        }
        ctx.lineTo(last.x,last.y);
      };
      for(const [width,alpha,color]of [[9,.14,trail.color],[4.4,.8,trail.color],[1.35,1,'#f4ffff']]){
        path();ctx.globalAlpha=last.life*alpha;ctx.strokeStyle=color;ctx.lineWidth=width;ctx.stroke();
      }
      ctx.restore();
    }
  }
  clearEffects(){this.particles=[];this.shards=[];this.cutRings=[];this.holdNotes=[];this.phraseGlow=0;this.rewardShells=[];this.trails.clear();this.stageExplosions=[];this.stageShow=null;this.cancelCombo();}
}
export function hexRGB(hex){return `${parseInt(hex.slice(1,3),16)},${parseInt(hex.slice(3,5),16)},${parseInt(hex.slice(5,7),16)}`;}
