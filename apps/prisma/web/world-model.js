// Shared triangle models: uploaded once to WebGL or native GLES, never rasterized
// into a CPU image. Positions/normals/colors/emission/motion use 12 floats/vertex.
export const MODEL_STRIDE=12;
export const WORLD_MODEL_LIMIT=384000;
const TAU=Math.PI*2;
const hash=n=>{const x=Math.sin(n*127.1+39.2)*43758.5453;return x-Math.floor(x);};
const color=h=>[1,3,5].map(i=>parseInt(h.slice(i,i+2),16)/255);
const palettes=[['#63cfff','#b18bff'],['#37d9ed','#f454b9'],['#75e8cf','#93a8f4'],['#36cbd7','#9a85ee'],['#ffb667','#ed657f']];
const cache=new Map();
class Model {
  constructor(){this.vertices=[];}
  triangle(a,b,c,rgb,emission=0,motion=0,normals=null){
    const u=b.map((x,i)=>x-a[i]),v=c.map((x,i)=>x-a[i]);
    const n=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]],len=Math.hypot(...n)||1;
    for(let i=0;i<3;i++){const ns=normals?normals[i]:n,l=normals?Math.hypot(...ns)||1:len;this.vertices.push(...[a,b,c][i],...ns.map(x=>x/l),...rgb,emission,motion,0);}
  }
  quad(a,b,c,d,rgb,e=0,m=0){this.triangle(a,b,c,rgb,e,m);this.triangle(a,c,d,rgb,e,m);}
  box(x,y,z,sx,sy,sz,rgb,e=0,m=0){
    const p=[[-1,-1,-1],[1,-1,-1],[1,1,-1],[-1,1,-1],[-1,-1,1],[1,-1,1],[1,1,1],[-1,1,1]].map(v=>[x+v[0]*sx/2,y+v[1]*sy/2,z+v[2]*sz/2]);
    for(const f of [[0,3,2,1],[4,5,6,7],[1,2,6,5],[0,4,7,3],[3,7,6,2],[0,1,5,4]])this.quad(...f.map(i=>p[i]),rgb,e,m);
  }
  sphere(x,y,z,rx,ry,rz,rgb,e=0,m=0,segments=16,rings=8){
    const point=(a,b)=>{const nx=Math.sin(b)*Math.cos(a),ny=Math.cos(b),nz=Math.sin(b)*Math.sin(a);return {p:[x+nx*rx,y+ny*ry,z+nz*rz],n:[nx/rx,ny/ry,nz/rz]};};
    for(let j=0;j<rings;j++)for(let i=0;i<segments;i++){
      const q=[point(i*TAU/segments,j*Math.PI/rings),point((i+1)*TAU/segments,j*Math.PI/rings),point((i+1)*TAU/segments,(j+1)*Math.PI/rings),point(i*TAU/segments,(j+1)*Math.PI/rings)];
      for(const ids of [[0,1,2],[0,2,3]])this.triangle(...ids.map(k=>q[k].p),rgb,e,m,ids.map(k=>q[k].n));
    }
  }
  // Cylinder/cone axis is Z, facing the player. Rims and baffles are actual faces.
  cone(x,y,z,r0,r1,depth,rgb,e=0,m=0,segments=24,caps=true){
    for(let i=0;i<segments;i++){
      const a=i*TAU/segments,b=(i+1)*TAU/segments;
      const p=[x+r0*Math.cos(a),y+r0*Math.sin(a),z-depth/2],q=[x+r0*Math.cos(b),y+r0*Math.sin(b),z-depth/2];
      const r=[x+r1*Math.cos(b),y+r1*Math.sin(b),z+depth/2],s=[x+r1*Math.cos(a),y+r1*Math.sin(a),z+depth/2];
      this.quad(p,q,r,s,rgb,e,m);if(caps&&r0>0)this.triangle([x,y,z-depth/2],q,p,rgb,e,m);
      if(caps&&r1>0)this.triangle([x,y,z+depth/2],s,r,rgb,e,m);
    }
  }
  torus(x,y,z,r,tube,rgb,e=0,m=0,segments=28,sides=6){
    const point=(a,b)=>{const n=[Math.cos(a)*Math.cos(b),Math.sin(a)*Math.cos(b),Math.sin(b)];return {p:[x+(r+tube*Math.cos(b))*Math.cos(a),y+(r+tube*Math.cos(b))*Math.sin(a),z+tube*Math.sin(b)],n};};
    for(let i=0;i<segments;i++)for(let j=0;j<sides;j++){
      const q=[point(i*TAU/segments,j*TAU/sides),point((i+1)*TAU/segments,j*TAU/sides),point((i+1)*TAU/segments,(j+1)*TAU/sides),point(i*TAU/segments,(j+1)*TAU/sides)];
      for(const ids of [[0,1,2],[0,2,3]])this.triangle(...ids.map(k=>q[k].p),rgb,e,m,ids.map(k=>q[k].n));
    }
  }
  crystal(x,y,z,r,height,rgb,e=.1,m=0){
    const top=[x,y-height,z],bottom=[x,y+.12,z],ring=Array.from({length:6},(_,i)=>[x+Math.cos(i*TAU/6)*r,y,z+Math.sin(i*TAU/6)*r]);
    for(let i=0;i<6;i++){this.triangle(top,ring[i],ring[(i+1)%6],rgb,e,m);this.triangle(bottom,ring[(i+1)%6],ring[i],rgb,e,m);}
  }
  finish(){if(this.vertices.length>WORLD_MODEL_LIMIT)throw Error('World triangle budget exceeded');return new Float32Array(this.vertices);}
}
function speakers(model){
  const dark=color('#111d30'),metal=color('#526779'),cone=color('#253c54');
  for(const side of [-1,1]){
    const x=side*3.8,y=.83,z=1.7;
    model.box(x,y,z,1.34,2.86,.88,dark);
    model.box(x,y,z-.46,1.14,2.63,.10,color('#070c16'));
    for(const offset of [-.7,.7]){
      const yy=y+offset,r=offset>0?.47:.40;
      model.torus(x,yy,z-.56,r,.035,metal,0,0,24,5);
      model.cone(x,yy,z-.61,r*.89,r*.28,.17,cone,0,4,24,false);
      model.sphere(x,yy,z-.60,r*.28,r*.28,r*.10,color('#445d78'),.06,4,12,6);
      model.torus(x,yy,z-.63,r*.98,.026,color('#0e1520'),0,0,24,5);
      for(let i=0;i<12;i++){
        const angle=i*TAU/12,rgb=color(['#50d8ff','#9e8bff','#ff76b5','#67e9c5'][i%4]);
        model.sphere(x+Math.cos(angle)*r*1.07,yy+Math.sin(angle)*r*1.07,z-.64,.027,.027,.014,rgb,.9,1,5,3);
      }
    }
    for(const edge of [-1,1])model.box(x+edge*.62,y,z-.44,.035,2.65,.04,color('#73e5e3'),.6,1);
    for(const xx of [-.48,.48])for(const yy of [-1.25,1.25])model.cone(x+xx,y+yy,z-.53,.035,.035,.035,metal,0,0,8);
    model.box(x,y+1.52,z,.97,.15,.72,metal);
    // Rear depth, angled braces, handles and top tweeter make a real cabinet.
    model.box(x+side*.69,y-.6,z,.09,.48,.28,metal);
    model.cone(x,y-1.15,z-.55,.10,.08,.06,color('#6ea3bd'),.3,1,12);
  }
}
function stage(model,a,b){
  const steel=color('#25384c');
  // A solid runway and repeated arches give reference depth through the world.
  model.box(0,2.55,21,5.8,.18,48,color('#0e1d2b'));
  for(const side of [-1,1]){
    model.box(side*2.9,2.42,21,.06,.05,48,a,.75,1);
    for(let i=0;i<8;i++){
      const z=5+i*5,x=side*(3.4+z*.13),yy=-2.5-z*.06;
      model.box(x,1,z,.14,7,.22,steel);if(side>0)model.box(0,yy,z,Math.abs(x)*2,.12,.18,steel);
      model.cone(x,yy+.30,z-.3,.23,.20,.38,a,.65,1,12);
      model.box(x,yy+.17,z,.50,.12,.42,steel);
    }
  }
}
export function worldModel(index=0){
  index=Math.max(0,Math.min(4,Math.trunc(index)||0));if(cache.has(index))return cache.get(index);
  const model=new Model(),[a,b]=palettes[index].map(color);stage(model,a,b);speakers(model);
  for(const side of [-1,1])for(let i=0;i<9;i++){
    const z=4+i*4.2,x=side*(5.2+z*.36+hash(i+73)*2),ground=2.7;
    if(index===1){
      const h=4+hash(i+12)*8,w=1.4+hash(i)*1.8;
      model.box(x,ground-h/2,z,w,h,1.8,color('#17314d'));
      model.box(x-side*w*.49,ground-h/2,z-.93,.055,h,.05,i%2?a:b,.8,1);
      for(let k=0;k<6;k++)model.box(x,ground-h+.4+k*h/6,z-.93,w*.7,.08,.035,k%2?a:b,.4,1);
      model.box(x,ground+.02,z,3,.04,2.9,color('#24445a'),.04,6);
    }else if(index===2){
      model.crystal(x,ground,z,.8+hash(i)*.6,3+hash(i+20)*5,i%2?a:b,.14);
      model.crystal(x+side*1.5,ground,z+1.7,.65,2+hash(i+30)*3,color('#395f88'),.06);
    }else if(index===3){
      model.box(x,ground-2.3,z,.68,4.6,.68,color('#194557'));
      model.box(x,ground-4.7,z,1.13,.28,1.05,a,.06);
      model.box(x,ground-.1,z,1.3,.28,1.3,color('#153342'));
      if(i%2===0){
        const jy=-1.8-hash(i)*2;
        model.sphere(x,jy,z,.8,.38,.8,i%4?a:b,.35,3,12,6);
        for(let tentacle=0;tentacle<4;tentacle++)model.box(x+(tentacle-1.5)*.28,jy+1.05,z,.035,1.8,.04,a,.35,3);
      }
    }else if(index===4){
      model.crystal(x,ground,z,1.9,2.4+hash(i)*4,color('#3a2435'),.025);
      model.crystal(x-side*.25,ground-.8,z-.4,.10,1.9,a,.9,1);
      model.box(x,ground,z,3.8,.04,1.2,b,.22,7);
    }else{
      model.sphere(x,ground-1,z,1.5,1.2,1.2,color('#344564'),.03,2,10,6);
      if(i%3===0)model.torus(x,ground-2,z,2,.045,i%2?a:b,.5,2,20,5);
    }
  }
  if(index===0){
    model.sphere(0,-7,33,3.6,3.6,3.6,color('#354d85'),.15,2,24,12);
    model.torus(0,-7,33,5,.12,b,.7,2,40,6);
  }else if(index===2){
    for(let layer=2;layer>=0;layer--)for(let i=0;i<48;i++){
      const x=(i-24)*1.2,z=26+layer*7,y=-8-layer*.8+Math.sin(i*.23)*1.1,nextY=-8-layer*.8+Math.sin((i+1)*.23)*1.1;
      model.quad([x,y,z],[x+1.2,nextY,z],[x+1.2,nextY+1.7,z+.5],[x,y+1.7,z+.5],layer%2?a:b,.75,5);
    }
  }else if(index===3){
    model.box(0,2.72,20,40,.05,44,color('#173c52'),.04,6);
    model.torus(0,-6,35,4.8,.25,b,.30,3,36,6);
  }else if(index===4){
    model.sphere(0,-7.8,35,3.9,3.9,.8,color('#130e1e'),0,0,24,10);
    model.torus(0,-7.8,34.9,4.05,.16,a,1.1,1,40,6);
  }
  const result=model.finish();cache.set(index,result);return result;
}
export function worldModelStats(index){const model=worldModel(index);return {vertices:model.length/MODEL_STRIDE,triangles:model.length/MODEL_STRIDE/3,bytes:model.byteLength};}
