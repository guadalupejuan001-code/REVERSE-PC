import { CubeGPU } from './gpu-scene.js';
import { NativeXRender } from './native-xrender.js';
import { seeded } from './audio.js';
import { MusicStageDirector, makeIntelligentChart } from './music-stage.js';
import { makeConcertProgram, concertPose, concertNativeParts, RIG_MAX_CUBOIDS } from './concert-rig.js';
import { createSpectacleEvent, pruneSpectacles, spectacleEnvelope, spectacleGeometry, SPECTACLE_MAX_EVENTS } from './combo-spectacle.js';
import { nextVisualQuality, visualBudget } from './performance-policy.js';
export const PALETTES = { coral: ['#63ffb4','#ff5074'], violet: ['#63ffb4','#bd8bff'], ice: ['#7aeaff','#ff5074'] };
export const DIRECTIONS = [{x:0,y:-1},{x:1,y:0},{x:0,y:1},{x:-1,y:0}];
export function makeChart(peaks, level, seed = 7721, music = null) {
  return makeIntelligentChart(peaks, level, seed, music);
}
export function segmentDistance(px, py, ax, ay, bx, by) {
  const dx = bx - ax, dy = by - ay, l = dx * dx + dy * dy;
  const t = l ? Math.max(0, Math.min(1, ((px - ax) * dx + (py - ay) * dy) / l)) : 0;
  return Math.hypot(px - ax - t * dx, py - ay - t * dy);
}
export function visibleRange(chart,time,latency=0){
  const bound=value=>{let lo=0,hi=chart.length;while(lo<hi){const mid=(lo+hi)>>>1;if(chart[mid].t<value)lo=mid+1;else hi=mid;}return lo;};
  return [bound(time-latency-.351),bound(time-latency+3.501)];
}
export class Scene {
  constructor(canvas, getSettings) {
    this.canvas = canvas; this.ctx = canvas.getContext('2d', { alpha:true, desynchronized:true }); this.settings = getSettings;
    this.width = 0; this.height = 0; this.particles = []; this.shards = []; this.trails = new Map(); this.pulse = 0; this.energy = 0; this.flash = 0; this.shake = 0; this.musicStage = null; this.stageExplosions = []; this.concertProgram = makeConcertProgram(null); this.rigPose = null; this.stageShow = null;
    const random = seeded(6631); this.stars = Array.from({length:100}, () => ({x:random(),y:random(),a:.15+random()*.5,s:random()>.9?1.4:.6}));
    this.qualityScale=1;this.frameTotal=0;this.frameCount=0;this.cooldown=0;this.visualState={quality:'balanced',slowFrames:0,fastFrames:0,cooldownUntil:0};this.view=new Float32Array(4);this.paletteKey='';this.rgb=[];this.diagnostics=new URLSearchParams(location.search).has('diagnostics');this.cpuTimes=[];
    this.gpu=NativeXRender.create()||(new URLSearchParams(location.search).get('renderer')==='canvas'?null:CubeGPU.create(canvas.parentElement));
    canvas.dataset.renderer=this.gpu?.native?'ether-render-x-cpu':this.gpu?'graphics-cosmic-webgl2':'canvas';
    if(this.gpu)this.gpu.onFailure=()=>{this.gpu.canvas.remove();this.gpu=null;canvas.dataset.renderer='canvas';this.resize();};
    this.resize(); this.observer = new ResizeObserver(() => this.resize()); this.observer.observe(canvas);
  }
  setMusicStage(map) {
    this.musicStage = new MusicStageDirector(map);
    this.concertProgram = makeConcertProgram(map);
    this.rigPose = null;
    this.stageExplosions = [];
    this.stageShow = null;
  }
  armCombo(combo, time) { return this.musicStage?.armCombo(combo, time) || false; }
  cancelCombo() { this.musicStage?.cancelCombo(); }
  clearMusicStage() { this.musicStage = null; this.stageExplosions = []; this.concertProgram = makeConcertProgram(null); this.rigPose = null; this.stageShow = null; }
  resize() {
    const r=this.canvas.getBoundingClientRect(),quality=this.settings().quality||'auto';
    const budget=this.gpu?(quality==='high'?3000000:1600000):850000;
    const ceiling=quality==='battery'?1:quality==='high'?2:1.5;
    const dpr=Math.min(devicePixelRatio||1,ceiling,Math.sqrt(budget/Math.max(1,r.width*r.height)))*(quality==='auto'?this.qualityScale:1);
    this.width=r.width;this.height=r.height;this.dpr=dpr;
    const w=Math.max(1,Math.round(r.width*dpr)),h=Math.max(1,Math.round(r.height*dpr));
    if(this.canvas.width!==w||this.canvas.height!==h){this.canvas.width=w;this.canvas.height=h;}
    this.gpu?.resize(w,h);this.vignette=null;
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
  noteProjection(note,t,latency=0) { return this.projection((note.lane-1)*1.13,(note.row-.5)*1.33,(note.t+latency-t)*10.6); }
  addTrail(id,x,y,color) { let trail = this.trails.get(id); if (!trail) { trail = {points:[],color,active:true}; this.trails.set(id,trail); } trail.active = true; trail.points.push({x,y,life:1}); if (trail.points.length > 22) trail.points.shift(); }
  endTrail(id) { const trail = this.trails.get(id); if(trail) trail.active=false; }
  burst(note,p,dx,dy,quality=1) {
    const color = PALETTES[this.settings().palette][note.color], reduced = this.settings().effects;
    this.pulse = Math.max(this.pulse,.65); if (!reduced) {this.shake=2.5;this.flash=.025;}
    const length = Math.hypot(dx,dy) || 1, nx=dx/length, ny=dy/length;
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
    if (!this.gpu || !pose) return;
    const capacity=this.gpu.native?RIG_MAX_CUBOIDS:(this.gpu.capacity||256);
    const parts=concertNativeParts(pose,Math.max(0,capacity-(this.gpu.count||0)));
    const metal=[.24,.29,.34];
    for(const p of parts) {
      this.gpu.cube(p.x,p.y,p.z,p.size,p.color<0?metal:this.rgb[p.color],
        p.alpha,p.rotation,p.direction,p.hot,
        pose.quality==='battery'?0:p.kind==='head'?3:2);
    }
    this.canvas.dataset.rigNativeCount=String(parts.length);
  }
  drawStageFX(ctx,time,preview,cue,pose) {
    if (!pose) return;
    const reduced=pose.reduced,colors=PALETTES[this.settings().palette];
    const project=point=>this.projection(point.x,point.y,point.z,preview);
    ctx.save();ctx.globalCompositeOperation='source-over';
    // Metallic overhead trusses and anchored mechanical moving heads.
    const fixtures=pose.fixtures;
    for(let depth=0;depth<3;depth++) {
      const left=fixtures.find(f=>f.id===depth),right=fixtures.find(f=>f.id===depth+3);
      if(!left||!right)continue;
      const a=project(left.base),b=project(right.base);
      ctx.beginPath();ctx.moveTo(a.x,a.y-9);ctx.lineTo(b.x,b.y-9);
      ctx.strokeStyle='rgba(112,140,153,.20)';ctx.lineWidth=1.5;ctx.stroke();
      for(let k=1;k<5;k++) {
        const x=a.x+(b.x-a.x)*k/5,y=a.y+(b.y-a.y)*k/5-9;
        ctx.beginPath();ctx.moveTo(x-5,y-5);ctx.lineTo(x+5,y+5);
        ctx.strokeStyle='rgba(108,129,142,.15)';ctx.lineWidth=1;ctx.stroke();
      }
    }
    for(const f of fixtures) {
      const base=project(f.base),elbow=project(f.elbow),head=project(f.head);
      const target=project(f.focus),rgb=hexRGB(colors[f.color]);
      ctx.lineCap='round';ctx.lineJoin='round';
      ctx.beginPath();ctx.moveTo(base.x,base.y);ctx.lineTo(elbow.x,elbow.y);
      ctx.lineTo(head.x,head.y);
      ctx.strokeStyle='rgba(8,15,24,.88)';
      ctx.lineWidth=Math.max(3,base.s*.22);ctx.stroke();
      ctx.strokeStyle='rgba(120,149,168,.52)';
      ctx.lineWidth=Math.max(1,base.s*.055);ctx.stroke();
      for(const p of [base,elbow]) {
        ctx.beginPath();ctx.arc(p.x,p.y,Math.max(2,p.s*.11),0,Math.PI*2);
        ctx.fillStyle='rgba(7,15,25,.93)';ctx.fill();
        ctx.strokeStyle='rgba(157,183,193,.43)';
        ctx.lineWidth=1;ctx.stroke();
      }
      if(!this.gpu) {
        // Canvas fallback housing: distinct from a native 3D render.
        const size=Math.max(6,head.s*.32);
        ctx.fillStyle='rgba(16,27,33,.9)';
        ctx.strokeStyle='rgba('+rgb+',.5)';ctx.lineWidth=1.2;
        ctx.fillRect(head.x-size*.5,head.y-size*.5,size,size);
        ctx.strokeRect(head.x-size*.5,head.y-size*.5,size,size);
      }
      // Screen-space haze beam, not volumetric tracing or an opaque obstacle.
      const alpha=Math.max(0,Math.min(f.intensity,reduced?.07:.27));
      ctx.save();ctx.globalCompositeOperation='lighter';
      const beam=ctx.createLinearGradient(head.x,head.y,target.x,target.y);
      beam.addColorStop(0,'rgba('+rgb+','+alpha+')');
      beam.addColorStop(.66,'rgba('+rgb+','+(alpha*.38)+')');
      beam.addColorStop(1,'rgba('+rgb+',0)');
      if(!reduced) {
        // A restrained conical wash makes the concert lighting visible.
        // This is screen-space haze, NOT 3D volume sampling, and is transparent
        // enough that incoming cut arrows remain readable.
        const dx=target.x-head.x,dy=target.y-head.y;
        const length=Math.max(1,Math.hypot(dx,dy));
        const px=-dy/length,py=dx/length;
        const spread=Math.max(7,Math.min(28,target.s*.35));
        ctx.beginPath();ctx.moveTo(head.x,head.y);
        ctx.lineTo(target.x+px*spread,target.y+py*spread);
        ctx.lineTo(target.x-px*spread,target.y-py*spread);
        ctx.closePath();ctx.fillStyle=beam;ctx.fill();
      }
      ctx.beginPath();ctx.moveTo(head.x,head.y);ctx.lineTo(target.x,target.y);
      ctx.strokeStyle=beam;ctx.lineWidth=reduced?1.2:Math.max(5,head.s*.45);
      ctx.stroke();
      if(!reduced) {
        ctx.beginPath();ctx.moveTo(head.x,head.y);ctx.lineTo(target.x,target.y);
        ctx.strokeStyle='rgba('+rgb+','+(alpha*.75)+')';
        ctx.lineWidth=Math.max(1,head.s*.05);ctx.stroke();
      }
      if(!reduced && f.intensity>.09) {
        // Grounded projected spot footprint; no full-scene flash.
        ctx.beginPath();ctx.ellipse(target.x,target.y,
          Math.max(3,target.s*.14),Math.max(2,target.s*.05),0,0,Math.PI*2);
        ctx.strokeStyle='rgba('+rgb+','+(alpha*.30)+')';
        ctx.lineWidth=1.3;ctx.stroke();
      }
      ctx.beginPath();ctx.arc(head.x,head.y,Math.max(2,head.s*.10),0,Math.PI*2);
      ctx.fillStyle='rgba('+rgb+','+Math.min(.65,alpha*2.5)+')';ctx.fill();
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
    const stageCue = this.musicStage ? this.musicStage.step(time) : { beat: Math.exp(-((time % (60 / 122) + (60 / 122)) % (60 / 122)) * 8) * .55, energy: .28, charge:null, explosion:null };
    if(stageCue.explosion){
      const event=createSpectacleEvent(stageCue.explosion);
      if(event)this.stageExplosions.push(event);
      if(this.stageExplosions.length>SPECTACLE_MAX_EVENTS)
        this.stageExplosions=this.stageExplosions.slice(-SPECTACLE_MAX_EVENTS);
    }
    this.stageExplosions=pruneSpectacles(this.stageExplosions,time);
    stageCue.show=spectacleEnvelope(this.stageExplosions,time,this.settings().effects);
    this.stageShow={charge:stageCue.charge||null,
      release:stageCue.explosion?stageCue.explosion.combo:null,
      active:this.stageExplosions.length?this.stageExplosions[this.stageExplosions.length-1].tier:null};
    const quality=this.settings().quality==='auto'?(this.qualityScale<.78?'battery':this.visualState.quality==='high'?'high':'auto'):this.settings().quality;
    const rigPose=concertPose(this.concertProgram,time,stageCue,{quality,reduced:this.settings().effects});
    this.rigPose=rigPose;
    if(preview){
      const mobile=w<580,drift=this.settings().effects?0:Math.sin(time*.65)*.1;
      const blocks=[{x:.15,y:-.8,z:7,size:.78,c:0,d:1,r:.3},{x:-1.4,y:.3,z:5.5,size:.78,c:1,d:0,r:-.27},{x:1.3,y:-1.0,z:3.3,size:.88,c:0,d:3,r:.25},{x:.86,y:.74,z:1.65,size:1.03,c:1,d:2,r:-.22},{x:-.8,y:-.15,z:0,size:1.12,c:0,d:0,r:.22}];
      const col=PALETTES[this.settings().palette];
      for(let i=0;i<2;i++){const a=this.projection(i?1.35:-1.65,i?.85:.6,.2,true),b=this.projection(i?.65:-.38,i?-.4:-.8,1,true);ctx.save();ctx.strokeStyle=col[i];ctx.globalAlpha=.35;ctx.lineWidth=mobile?1:1.5;ctx.shadowColor=col[i];ctx.shadowBlur=this.settings().effects?0:18;ctx.beginPath();ctx.moveTo(a.x-25,a.y+40);ctx.bezierCurveTo(a.x-80,a.y+25,b.x+90,b.y+30,b.x,b.y-30);ctx.stroke();ctx.restore();}
      for(const b of blocks)this.cube(b.x,b.y+drift,b.z,b.size,b.c,b.d,b.r+drift*.25,true,false,.96);
    }else{
      const [first,last]=visibleRange(chart,time,latency);
      // Native packets have a strict 64-body cap: submit imminent notes first.
      // Browser WebGL retains far-to-near ordering for alpha blending.
      for(let slot=0;slot<last-first;slot++){const i=this.gpu?.native?first+slot:last-1-slot;const n=chart[i],delta=n.t+latency-time;if(n.hit||n.missed||delta>3.5||delta<-.35)continue;const z=delta*10.6;const alpha=Math.min(1,(3.5-delta)*1.5);this.cube((n.lane-1)*1.13,(n.row-.5)*1.33,z,.73,n.color,n.dir,Math.sin(n.t*4)*.065,false,Math.abs(delta)<.22,alpha);}
    }
    // Notes are added before decorations: decorative parts never reserve 3D slots.
    this.stageRig(rigPose);
    this.gpu?.flush();this.drawStageFX(ctx,time,preview,stageCue,rigPose);this.drawEffects(animate?dt:0);ctx.restore();
    if(this.diagnostics){this.cpuTimes.push(performance.now()-started);if(this.cpuTimes.length>240)this.cpuTimes.shift();if(this.cpuTimes.length%30===0){const sorted=[...this.cpuTimes].sort((a,b)=>a-b);this.canvas.dataset.renderMs=(sorted.reduce((a,b)=>a+b,0)/sorted.length).toFixed(3);this.canvas.dataset.renderP95=sorted[Math.floor(sorted.length*.95)].toFixed(3);this.canvas.dataset.visibleCubes=String(this.gpu?.count||0);this.canvas.dataset.pixelRatio=this.dpr.toFixed(2);}}
    if(this.gpu)return;
    if(!this.vignette){this.vignette=ctx.createRadialGradient(w*.5,h*.5,h*.2,w*.5,h*.5,Math.max(w,h)*.72);this.vignette.addColorStop(0,'#0000');this.vignette.addColorStop(1,'#0009');}ctx.fillStyle=this.vignette;ctx.fillRect(0,0,w,h);
  }
  drawEffects(dt){
    const ctx=this.ctx;
    for(let i=this.shards.length-1;i>=0;i--){const s=this.shards[i];s.life-=dt*1.8;if(s.life<=0){this.shards.splice(i,1);continue;}s.x+=s.vx*dt;s.y+=s.vy*dt;s.vy+=180*dt;s.angle+=s.vr*dt;ctx.save();ctx.translate(s.x,s.y);ctx.rotate(s.angle);ctx.globalAlpha=Math.min(1,s.life*1.5);ctx.fillStyle='#0b2116';ctx.strokeStyle=s.color;ctx.lineWidth=1.3;ctx.shadowColor=s.color;ctx.shadowBlur=0;ctx.beginPath();ctx.moveTo(-s.size*.5,s.side*s.size*.05);ctx.lineTo(s.size*.5,s.side*s.size*.05);ctx.lineTo(s.size*.5,s.side*s.size*.48);ctx.lineTo(-s.size*.5,s.side*s.size*.48);ctx.closePath();ctx.fill();ctx.globalAlpha*=.6;ctx.fillStyle=s.color;ctx.fill();ctx.globalAlpha=Math.min(1,s.life);ctx.stroke();ctx.restore();}
    for(let i=this.particles.length-1;i>=0;i--){const p=this.particles[i];p.life-=dt*1.8;if(p.life<=0){this.particles.splice(i,1);continue;}p.x+=p.vx*dt;p.y+=p.vy*dt;p.vy+=140*dt;ctx.globalAlpha=p.life;ctx.strokeStyle=p.color;ctx.lineWidth=p.size;ctx.beginPath();ctx.moveTo(p.x,p.y);ctx.lineTo(p.x-p.vx*.017,p.y-p.vy*.017);ctx.stroke();}ctx.globalAlpha=1;
    for(const [id,trail]of this.trails){for(const p of trail.points)p.life-=dt*4.3;trail.points=trail.points.filter(p=>p.life>0);if(!trail.points.length){if(!trail.active)this.trails.delete(id);continue;}ctx.save();ctx.strokeStyle=trail.color;ctx.lineJoin='round';ctx.lineCap='round';ctx.shadowColor=trail.color;ctx.shadowBlur=0;for(let i=1;i<trail.points.length;i++){const a=trail.points[i-1],b=trail.points[i];ctx.globalAlpha=b.life*.8;ctx.lineWidth=b.life*5;ctx.beginPath();ctx.moveTo(a.x,a.y);ctx.lineTo(b.x,b.y);ctx.stroke();}ctx.shadowBlur=0;ctx.strokeStyle='#f0fff8';for(let i=1;i<trail.points.length;i++){const a=trail.points[i-1],b=trail.points[i];ctx.globalAlpha=b.life;ctx.lineWidth=b.life*1.4;ctx.beginPath();ctx.moveTo(a.x,a.y);ctx.lineTo(b.x,b.y);ctx.stroke();}ctx.restore();}
  }
  clearEffects(){this.particles=[];this.shards=[];this.trails.clear();this.stageExplosions=[];this.stageShow=null;this.cancelCombo();}
}
export function hexRGB(hex){return `${parseInt(hex.slice(1,3),16)},${parseInt(hex.slice(3,5),16)},${parseInt(hex.slice(5,7),16)}`;}
