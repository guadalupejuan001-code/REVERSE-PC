'use strict';
const {buildCarMesh}=require('./velocity-car-mesh.cjs');
const {RAMPS,FLAT}=require('./velocity-materials.cjs');
const {carUV,TEXTURED_MATERIALS}=require('./velocity-textures.cjs');
module.exports=function emitCarScene({out,load,store,trig,pitch,focus,label,openWorld=false}){
 const CAMERA=2048,vertices=[],normalIds=[],groups=[],groupMap=new Map(),modelStats={},canonical=[],normalKinds=[],bodyMasks=new Map(),glassMasks=new Map(),wheelBands=[];
 const norm=v=>{const n=Math.hypot(...v)||1;return v.map(x=>x/n);};
 function normalGroup(n){
  n=norm(n);let az=(Math.round(Math.atan2(n[2],n[0])*16/(Math.PI*2))+16)%16;
  const el=Math.round(Math.asin(Math.max(-1,Math.min(1,n[1])))*8/Math.PI);
  const key=Math.abs(el)===4?'pole'+el:az+':'+el;
  if(!groupMap.has(key)){groupMap.set(key,groups.length);groups.push({sum:[0,0,0],samples:0});}
  const id=groupMap.get(key),g=groups[id];n.forEach((x,k)=>g.sum[k]+=x);g.samples++;return id;
 }
 function appendModel(detail){
  const mesh=buildCarMesh(detail),start=vertices.length,cache=new Map(),positions=new Map(),faces=[],hoodSet=new Set(mesh.groups.hood||[]);
  mesh.faces.forEach((f,fi)=>{
   const indices=f.indices.map((old,corner)=>{
    const n=f.normals[corner],key=old+'|'+f.material+'|'+n.map(x=>Math.round(x*16384)).join(',');
    if(!cache.has(key)){const id=vertices.length,p=mesh.vertices[old],position=p.join(',');if(!positions.has(position))positions.set(position,id);canonical.push(positions.get(position));cache.set(key,id);vertices.push(p);normalIds.push(normalGroup(n)+(f.material==='glass'?128:0));normalKinds.push(f.material);}
    return cache.get(key);
   });faces.push({indices,material:f.material,hood:hoodSet.has(fi)});
  });

  // Wheel intervals are computed from the mesh, not from fixed vertex IDs.
  const wheelSpans=mesh.landmarks.wheelParts.map(part=>{
   const ids=new Set(part.faces.flatMap(fi=>faces[fi].indices));
   const first=Math.min(...ids),last=Math.max(...ids)+1;
   if(ids.size!==last-first)throw Error('Wheel vertices must be contiguous: '+detail);
   return {first,last,side:part.side,z:part.center[2],front:part.axle==='front'};
  });
  if(wheelSpans.length!==4||wheelSpans.some((w,i)=>i>0&&wheelSpans[i-1].last!==w.first))
   throw Error('Unexpected wheel intervals: '+detail);
  wheelBands.push({detail,first:wheelSpans[0].first,last:wheelSpans.at(-1).last,wheels:wheelSpans});
  const mask=detail==='high'?1:detail==='medium'?2:4;
  for(let i=start;i<vertices.length;i++){const kind=normalKinds[i];if(!RAMPS[kind])continue;const map=kind==='glass'?glassMasks:bodyMasks,g=normalIds[i]-(kind==='glass'?128:0);map.set(g,(map.get(g)||0)|mask);}
  modelStats[detail]={sourceVertices:mesh.vertices.length,vertices:vertices.length-start,triangles:faces.length,bounds:mesh.bounds};
  return {detail,start,end:vertices.length,faces};
 }
 const models={high:appendModel('high'),medium:appendModel('medium'),far:appendModel('far')};
 // Four physical wheel pressure nozzles, modelled as crossed 3D XI ribbons.
 const airJetStart=vertices.length,airJetFaces=[];
 function pressureVertex(x,y,z,shade){
  const id=vertices.length;vertices.push([x,y,z]);
  normalIds.push(-shade-1);normalKinds.push('air');canonical.push(id);return id;
 }
 for(const side of [-1,1])for(const z of [-142,138]){
  const x=side*91;
  const top=pressureVertex(x,24,z,225),low=pressureVertex(x,-75,z,22);
  const left=pressureVertex(x-14,-40,z,87),right=pressureVertex(x+14,-40,z,87);
  const fore=pressureVertex(x,-40,z+17,91),aft=pressureVertex(x,-40,z-17,91);
  airJetFaces.push([top,left,low],[top,low,right],[top,fore,low],[top,low,aft]);
 }
 const airJetEnd=vertices.length;
 // Shared soft contact ellipse. Its scalar attribute is authored coverage,
 // independent of directional lighting; it is never a stored world mutation.
 const shadowStart=vertices.length;
 vertices.push([12,4,12]);normalIds.push(-256);
 for(const [rx,rz,height,I]of [[111,239,3,175],[143,267,2,0]])for(let k=0;k<8;k++){
  const t=k*Math.PI/4;vertices.push([Math.round(12+rx*Math.cos(t)),height,Math.round(12+rz*Math.sin(t))]);normalIds.push(-I-1);
 }
 const shadowEnd=vertices.length,shadowFaces=[];for(let i=shadowStart;i<shadowEnd;i++)canonical[i]=i;
 for(let k=0;k<8;k++){
  const j=(k+1)%8,c=shadowStart,a=c+1+k,b=c+1+j,oa=c+9+k,ob=c+9+j;
  shadowFaces.push([c,a,b],[a,oa,ob],[a,ob,b]);
 }
 // 40 distant props retain the original planting density. Six-sided crowns
 // and crossed trunks leave the larger triangle budget available to the cars.
 const treeStart=vertices.length,treeFaces=[];
 function treeTri(a,b,c,m){treeFaces.push({indices:[a,b,c],material:m});}
 const tp=p=>{canonical.push(vertices.length);vertices.push(p);normalIds.push(0);return vertices.length-1;};
 const top=tp([0,820,0]),ring=[];
 for(let k=0;k<5;k++){const t=k*Math.PI*2/5;ring.push(tp([Math.round(215*Math.cos(t)),200,Math.round(215*Math.sin(t))]));}
 for(let k=0;k<5;k++)treeTri(top,ring[k],ring[(k+1)%5],14+k%3);
 for(const axis of [0,2]){const pts=[[-20,0],[20,0],[20,280],[-20,280]].map(([x,y])=>{const p=[0,y,0];p[axis]=x;return tp(p);});treeTri(pts[0],pts[1],pts[2],9);treeTri(pts[0],pts[2],pts[3],10);}
 const treeEnd=vertices.length;
 if(vertices.length!==1566)throw Error('Landscape mesh offset changed');
 for(let i=0;i<25;i++){
  vertices.push([0,0,0]);normalIds.push(0);
  normalKinds.push('reserved');canonical.push(-1);
 }
 const fxVertex=(x,y,z,shade)=>{
  const id=vertices.length;vertices.push([x,y,z]);
  normalIds.push(-shade-1);normalKinds.push('fx');canonical.push(id);return id;
 };
 const smokeStart=vertices.length,smokeFaces=[];
 for(const side of [-1,1]){
  const x=side*91,z=-146;
  const a=fxVertex(x-18,26,z-5,45),b=fxVertex(x+18,27,z-8,95);
  const c=fxVertex(x+29,88,z-66,180),d=fxVertex(x-29,82,z-58,115);
  smokeFaces.push([a,b,c],[a,c,d]);
  const e=fxVertex(x,25,z+12,50),f=fxVertex(x,24,z-22,105);
  const g=fxVertex(x,96,z-52,195),h=fxVertex(x,90,z+22,133);
  smokeFaces.push([e,f,g],[e,g,h]);
 }
 const smokeEnd=vertices.length;
 const nitroStart=vertices.length,nitroFaces=[];
 for(const x of require('./velocity-jet-ports.cjs').rearX){
  const a=fxVertex(x-5,26,-234,235),b=fxVertex(x+5,26,-234,225);
  const c=fxVertex(x+14,26,-350,25),d=fxVertex(x-14,26,-350,20);
  nitroFaces.push([a,b,c],[a,c,d]);
  const e=fxVertex(x,21,-234,235),f=fxVertex(x,31,-234,225);
  const g=fxVertex(x,40,-350,25),h=fxVertex(x,12,-350,20);
  nitroFaces.push([e,f,g],[e,g,h]);
 }
 const nitroEnd=vertices.length;
 const skidStart=vertices.length,skidFaces=[];
 for(const side of [-1,1]){
  const x=side*92,w=9;
  const a=fxVertex(x-w,3,-250,220),b=fxVertex(x+w,3,-250,215);
  const c=fxVertex(x+w,3,-15,200),d=fxVertex(x-w,3,-15,220);
  skidFaces.push([a,b,c],[a,c,d]);
 }
 const skidEnd=vertices.length;
 if(skidEnd>=1900)throw Error('XI local metadata range exceeded');
 const maxTriangles=openWorld?30*7*2+18+models.high.faces.length+shadowFaces.length+120*12+airJetFaces.length+smokeFaces.length+nitroFaces.length+4*skidFaces.length+1024:80*11*2+18+models.high.faces.length+3*models.medium.faces.length+4*shadowFaces.length+40*treeFaces.length+airJetFaces.length+smokeFaces.length+nitroFaces.length+4*skidFaces.length;
 if(maxTriangles>4096)throw Error('Scene triangle budget exceeded: '+maxTriangles);
 if(groups.length>128)throw Error('Normal-group scalar encoding exceeded');
 const groupNormals=groups.map(g=>norm(g.sum).map(x=>Math.round(x*16384)));
 out('# Original detailed car meshes; all world transforms and lighting execute in XI.');
 vertices.forEach((p,i)=>{if(openWorld&&i>=models.medium.start&&i<models.far.end)return;if(canonical[i]===i){const uv=carUV(p,normalKinds[i]);out(`meshvertex ${i} ${p.join(' ')}\nmeshtexuv ${i} ${uv.join(' ')}`);}});
 // Material lighting indices share the existing local descriptor. No new vertices,
 // persistent memory or per-pixel lighting is introduced.
 normalIds.forEach((g,i)=>{if(canonical[i]<0||(openWorld&&i>=models.medium.start&&i<models.far.end))return;const n=g-(normalKinds[i]==='glass'?128:0),base={glass:384,tire:512,rim:640,aero:768}[normalKinds[i]]||256;const code=g>=0?base+n:-g-1;if(code<0||code>=896)throw Error('Scalar metadata range');out(`localset ${512+i} ${canonical[i]*2048+code}`);});
 function range(start,end){out(`set r0 ${start}`);store('r0',8324,2,0);out(`set r0 ${end}`);store('r0',8326,2,0);}
 if(openWorld)out('localset 3202 124\nlocalset 3203 128');
 out('store8 8203 0\nlabel actor\nstore8 8334 0\nstore8 8336 0\nstore8 8337 0\nstore8 8338 0\nload8 r0 8203\ncmp r0 124\njge skid_actor\ncmp r0 4\njge tree_actor\ncmp r0 0\nje open_player_actor\njmp next_actor\nlabel open_player_actor');
 range(models.high.start,models.high.end);
 load('r0',100,4,2000000);load('r2',104,4,2000000);load('r8',108,2,0);
 out('load8 r9 202\nmul r9 24\nadd r9 64\nstore8 8318 r9\nload8 r9 201\ncmp r9 2\njne player_mesh_ready\nstore8 8334 1\nlabel player_mesh_ready\njmp actor_ready\nlabel rival_actor');
 range(models.medium.start,models.medium.end);
 out('load8 r7 8203\nsub r7 1\nmul r7 32\nadd r7 6004');load('r0','r7',4,65536);out('add r7 4');load('r2','r7',4,65536);out('add r7 4');load('r8','r7',2,0);
 out('load8 r9 8203\nmul r9 24\nadd r9 64\nstore8 8318 r9\njmp actor_ready\nlabel tree_actor');
 range(treeStart,treeEnd);
 out('load8 r5 8203\nlocalget r6 3200\nmul r6 4\nadd r5 r6\nlocalset 3120 r5\nload8 r8 8203\nsub r8 4\ndiv r8 4\nlocalget r7 3200\nadd r8 r7\nlocalget r7 3201\ncmp r8 r7\njge next_actor\nmov r7 r8\nadd r7 5500\nload8 r7 $r7\ncmp r7 1\nje next_actor\ncmp r7 5\nje next_actor\ncmp r7 2\njne open_tree_bank_ready\nload8 r7 8203\nmod r7 2\ncmp r7 1\nje next_actor\nlabel open_tree_bank_ready\nmov r7 r8\nmul r7 2\nadd r7 5000');out('sub r7 1400\nlocalget r3 r7\nadd r7 1\nlocalget r4 r7');
 out('load8 r0 8203\nmod r0 2\nmul r0 2\nsub r0 1\nlocalget r1 3120\nmul r1 73\nmod r1 2500\nadd r1 470\nlocalget r5 3120\nmod r5 10\ncmp r5 7\nje wetlands_rock_offset\ncmp r5 8\njne wetlands_rock_offset_ready\nlabel wetlands_rock_offset\nadd r1 250\nlabel wetlands_rock_offset_ready\nmul r0 r1\nmul r4 r0\ndiv r4 16384\nmul r3 r0\ndiv r3 16384\nmul r8 8\nadd r8 4096');load('r0','r8',4,65536);out('add r0 r4\nadd r8 4');load('r2','r8',4,65536);
 out('sub r2 r3\nload8 r5 8203\nsub r5 4\ndiv r5 4\nlocalget r6 3200\nadd r5 r6\nmul r5 2\nadd r5 5300\nload16 r5 $r5\nlocalset 3104 r5\nset r8 0\njmp actor_ready\nlabel skid_actor');
 range(skidStart,skidEnd);
 out('load8 r7 8203\nsub r7 124\nmul r7 12\nadd r7 410\nload8 r9 $r7\ncmp r9 0\njle next_actor\nsub r7 10');
 load('r0','r7',4,2000000);out('add r7 4');
 load('r2','r7',4,2000000);out('add r7 4');
 load('r8','r7',2,0);out('add r7 3\nload8 r5 $r7\nlocalset 3104 r5');
 out('label actor_ready\nload8 r5 8203\ncmp r5 4\njlt open_actor_heading\ncmp r5 124\njge open_actor_heading\nset r3 0\nset r4 16384\njmp open_actor_heading_ready\nlabel open_actor_heading');
 trig('r8','r3','r4','r5','r6');out('label open_actor_heading_ready');
 // Object-local sun and half vector. Values use Q14; the source supplies the
 // material intensity, while the generic engine only interpolates it.
 const sun=norm([-.55,.84,-.38]).map(x=>Math.round(x*16384));
 out('localset 3320 -8390\nlocalset 3321 12815\nlocalset 3322 -5796\nload8 r5 526\ncmp r5 1\nje open_sun_dusk\ncmp r5 2\nje open_sun_night\njmp open_sun_ready\nlabel open_sun_dusk\nlocalset 3320 -13300\nlocalset 3321 5400\nlocalset 3322 -7900\njmp open_sun_ready\nlabel open_sun_night\nlocalset 3320 3800\nlocalset 3321 12600\nlocalset 3322 9700\nlabel open_sun_ready');
 out('load8 r5 8203\ncmp r5 4\njge lighting_basis_ready');
 out(`mov r5 r4\nlocalget r7 3320\nmul r5 r7\nmov r6 r3\nlocalget r7 3322\nmul r6 r7\nsub r5 r6\ndiv r5 16384\nlocalset 3000 r5\nlocalget r7 3321\nlocalset 3001 r7\nmov r5 r3\nlocalget r7 3320\nmul r5 r7\nmov r6 r4\nlocalget r7 3322\nmul r6 r7\nadd r5 r6\ndiv r5 16384\nlocalset 3002 r5`);
 load('r7',8192,2,0);out('mov r5 r14\nmul r5 r7\ndiv r5 16384\nmov r6 r12\nsub r6 r5\nsub r6 r0\nmov r5 r15\nmul r5 r7\ndiv r5 16384\nmov r7 r13\nsub r7 r5\nsub r7 r2\nmov r5 r6\nmul r5 r4\nmov r8 r7\nmul r8 r3\nsub r5 r8\ndiv r5 16384\nlocalset 3010 r5\nmul r6 r3\nmul r7 r4\nadd r6 r7\ndiv r6 16384\nlocalset 3012 r6');load('r6',8194,2,0);out('sub r6 60\nlocalset 3011 r6\nlocalget r5 3010\nlocalget r7 3012');
 function normalize567(){
  const abs=label('norm_abs'),begin=label('norm_sqrt'),done=label('norm_done'),nonzero=label('norm_nonzero');
  out('mov r8 r5\nmul r8 r5\nmov r9 r6\nmul r9 r6\nadd r8 r9\nmov r9 r7\nmul r9 r7\nadd r8 r9\nset r9 0');
  for(const r of ['r5','r6','r7']){const n=label('norm_component');out(`mov r10 ${r}\ncmp r10 0\njge ${n}\nmul r10 -1\nlabel ${n}\nadd r9 r10`);}
  out(`cmp r9 0\njgt ${nonzero}\nset r9 1\nlabel ${nonzero}\nlabel ${begin}\nmov r10 r8\ndiv r10 r9\nadd r10 r9\ndiv r10 2\ncmp r10 r9\njge ${done}\nmov r9 r10\ncmp r9 0\njgt ${begin}\nset r9 1\nlabel ${done}`);
  for(const r of ['r5','r6','r7'])out(`mul ${r} 16384\ndiv ${r} r9`);
 }
 normalize567();out('localset 3006 r5\nlocalset 3007 r6\nlocalset 3008 r7\nlocalget r8 3000\nadd r5 r8\nlocalget r8 3001\nadd r6 r8\nlocalget r8 3002\nadd r7 r8');normalize567();out('localset 3003 r5\nlocalset 3004 r6\nlocalset 3005 r7\nlabel lighting_basis_ready');
 // Observe the same retained pitch/roll for lighting; camera orbit remains
 // independent. Inverse small-angle basis costs nine vector transforms/frame.
 out('load8 r5 8203\ncmp r5 0\njne rig_lighting_ready\nload16 r5 512\nsub r5 32768\ndiv r5 256\nlocalset 3100 r5\nload16 r5 508\nsub r5 32768\nlocalset 3101 r5\nload16 r5 504\nsub r5 32768\nlocalset 3102 r5\nload16 r5 516\nsub r5 32768\ndiv r5 256\nlocalset 3103 r5');
 for(const base of [3000,3003,3006]){
  out(`localget r5 ${base}\nlocalget r6 ${base+1}\nlocalget r7 ${base+2}\nload16 r8 508\nsub r8 32768\nlocalget r9 3102\nmov r10 r8\nmul r10 r6\ndiv r10 22528\nadd r10 r5\nmov r11 r9\nmul r11 r6\ndiv r11 35840\nadd r11 r7\nmul r8 r5\ndiv r8 22528\nsub r6 r8\nmul r9 r7\ndiv r9 35840\nsub r6 r9\nlocalset ${base} r10\nlocalset ${base+1} r6\nlocalset ${base+2} r11`);
 }
 out('label rig_lighting_ready');
 // Preserve the physical camera orientation, then cull before shading/transform.
 out('mov r1 r3\nmul r1 r15\nmov r5 r4\nmul r5 r14\nsub r1 r5\ndiv r1 16384\nmov r5 r3\nmul r5 r14\nmul r4 r15\nadd r5 r4\ndiv r5 16384');store('r1',8308,2,32768);store('r5',8310,2,32768);
 out('sub r0 r12\nsub r2 r13\nmov r1 r0\nmul r1 r15\nmov r3 r2\nmul r3 r14\nsub r1 r3\ndiv r1 16384\nmul r0 r14\nmul r2 r15\nadd r0 r2\ndiv r0 16384');store('r1',8300);store('r0',8304);
 out('cmp r0 -1200\njlt next_actor\ncmp r0 22000\njgt next_actor\nmov r2 r0\nmul r2 2\nadd r2 3500');load('r1',8300);out('cmp r1 0\njge actor_side_absolute\nmul r1 -1\nlabel actor_side_absolute\ncmp r1 r2\njgt next_actor\nload8 r1 8203\ncmp r1 0\nje actor_lod_ready\ncmp r1 4\njge actor_lod_ready\ncmp r0 4000\njle actor_lod_ready\nstore8 8334 2');range(models.far.start,models.far.end);out('label actor_lod_ready\nload8 r0 8203\ncmp r0 4\njlt nature_fog_ready\nload32 r0 8304\nsub r0 1000000\ndiv r0 160\nadd r0 56\ncmp r0 56\njge nature_fog_min\nset r0 56\nlabel nature_fog_min\ncmp r0 224\njle nature_fog_max\nset r0 224\nlabel nature_fog_max\nlocalset 3090 r0\nlabel nature_fog_ready\nload8 r0 8203\ncmp r0 4\njge lighting_table_ready\ncmp r0 0\nje lighting_lod_high\nload8 r0 8334\ncmp r0 2\nje lighting_lod_far\nlocalset 3030 1\njmp lighting_lod_ready\nlabel lighting_lod_far\nlocalset 3030 2\njmp lighting_lod_ready\nlabel lighting_lod_high\nlocalset 3030 0\nlabel lighting_lod_ready');
 function requireLod(mask,skip){
  if(mask===7)return;
  out('localget r3 3030');
  if(mask===1||mask===2||mask===4){const wanted=mask===1?0:mask===2?1:2;out(`cmp r3 ${wanted}\njne ${skip}`);}
  else{const absent=mask===3?2:mask===5?1:0;out(`cmp r3 ${absent}\nje ${skip}`);}
 }
 groupNormals.forEach(([nx,ny,nz],g)=>{
  const bodyMask=bodyMasks.get(g)||0,glassMask=glassMasks.get(g)||0;
  const bodyDone=label('body_lighting_done'),glassDone=label('glass_lighting_done');
  if(bodyMask){requireLod(bodyMask,bodyDone);
  const diffuse=label('diffuse_positive'),highlight=label('highlight_positive'),bounded=label('intensity_bounded');
  out(`localget r0 3000\nmul r0 ${nx}\nlocalget r1 3001\nmul r1 ${ny}\nadd r0 r1\nlocalget r1 3002\nmul r1 ${nz}\nadd r0 r1\ndiv r0 16384\ncmp r0 0\njge ${diffuse}\nset r0 0\nlabel ${diffuse}\nmul r0 128\ndiv r0 16384\nadd r0 ${66+Math.round(ny*22/16384)}\nlocalset ${2816+g} r0\nmov r2 r0\nmul r2 4\ndiv r2 5\nlocalset ${2560+g} r2\nlocalget r1 3003\nmul r1 ${nx}\nlocalget r2 3004\nmul r2 ${ny}\nadd r1 r2\nlocalget r2 3005\nmul r2 ${nz}\nadd r1 r2\ndiv r1 16384\ncmp r1 0\njge ${highlight}\nset r1 0\nlabel ${highlight}`);
  for(let k=0;k<4;k++){out('mul r1 r1\ndiv r1 16384');if(k===1)out(`localset ${2688+g} r1`);}
  // View-angle rim reflection is a bounded Fresnel approximation.
  out(`mul r1 104\ndiv r1 16384\nadd r0 r1\nlocalget r1 3006\nmul r1 ${nx}\nlocalget r2 3007\nmul r2 ${ny}\nadd r1 r2\nlocalget r2 3008\nmul r2 ${nz}\nadd r1 r2\ndiv r1 16384\ncmp r1 0\njge fresnel_positive_${g}\nset r1 0\nlabel fresnel_positive_${g}\ncmp r1 16384\njle fresnel_bounded_${g}\nset r1 16384\nlabel fresnel_bounded_${g}\nset r2 16384\nsub r2 r1\nmov r1 r2\nmul r1 r2\ndiv r1 16384\nmul r1 r2\ndiv r1 16384\nmul r1 36\ndiv r1 16384\nadd r0 r1\nlocalget r2 ${2688+g}\nmul r2 168\ndiv r2 16384\nlocalget r1 ${2816+g}\nadd r2 r1\ncmp r2 255\njle metal_bounded_${g}\nset r2 255\nlabel metal_bounded_${g}\nlocalset ${2688+g} r2\ncmp r0 255\njle ${bounded}\nset r0 255\nlabel ${bounded}\nlocalset ${2304+g} r0\nlocalget r1 ${2816+g}\nmul r1 3\nadd r1 r0\ndiv r1 4\nlocalset ${2816+g} r1`);
  out('label '+bodyDone);}
  if(glassMask){requireLod(glassMask,glassDone);
  const glassLow=label('glass_low'),glassHigh=label('glass_high');
  out(`localget r0 3006\nmul r0 ${nx}\nlocalget r1 3007\nmul r1 ${ny}\nadd r0 r1\nlocalget r1 3008\nmul r1 ${nz}\nadd r0 r1\ndiv r0 16384\nmul r0 2\nmul r0 ${ny}\ndiv r0 16384\nlocalget r1 3007\nsub r0 r1\nmul r0 100\ndiv r0 16384\nadd r0 128\ncmp r0 0\njge ${glassLow}\nset r0 0\nlabel ${glassLow}\ncmp r0 255\njle ${glassHigh}\nset r0 255\nlabel ${glassHigh}\nlocalset ${2432+g} r0`);
  out('label '+glassDone);}
 });

 // XI physics controls the actual steering and road progress. The rig only reads them.

 out('label lighting_table_ready\nload8 r0 8203\ncmp r0 4\njlt open_forest_lod_ready\ncmp r0 124\njge open_forest_lod_ready\nmod r0 10\ncmp r0 7\njge open_forest_lod_ready\nload32 r0 8304\nsub r0 1000000\ncmp r0 12000\njle open_forest_lod_ready\nlocalset 134 1558\nlabel open_forest_lod_ready\nload8 r0 8203\ncmp r0 4\njge wheel_motion_ready\nload8 r0 8334\ncmp r0 2\nje wheel_motion_ready\nload8 r0 8203\ncmp r0 0\njne wheel_rival_distance');
 load('r0',498,2,0);
 out('jmp wheel_phase_ready\nlabel wheel_rival_distance\nload8 r7 8203\nsub r7 1\nmul r7 32\nadd r7 6016');
 load('r0','r7',4,0);
 // 34 cm wheel radius, circumference approximated by 214 cm.
 out('label wheel_distance_ready\nmod r0 214\nmul r0 4096\ndiv r0 214\nlabel wheel_phase_ready');
 trig('r0','r5','r6','r7','r8');
 out('localset 3040 r5\nlocalset 3041 r6\nload8 r0 8203\ncmp r0 0\njne wheel_steer_neutral');
 load('r0',256,2,0);
 out('sub r0 1000\nmul r0 320\ndiv r0 1000\nadd r0 4096\nmod r0 4096');
 trig('r0','r5','r6','r7','r8');
 out('localset 3042 r5\nlocalset 3043 r6\njmp wheel_motion_ready\nlabel wheel_steer_neutral\nlocalset 3042 0\nlocalset 3043 16384\nlabel wheel_motion_ready\nlocalset 3070 0\nload8 r0 8203\ncmp r0 0\njne car_selection_ready\nload8 r0 203\nlocalset 3070 r0\nlabel car_selection_ready\nstore8 8335 0\nlabel actor_vertex');
 function transformVertex(){
  load('r8',8324,2,0);out(`mov r9 r8\nadd r9 512\nlocalget r9 r9\ndiv r9 2048\ncmp r9 r8\nje vertex_transform_position\nadd r9 ${CAMERA}\nmeshread r0 r1 r2 r9\njmp vertex_publish_position\nlabel vertex_transform_position\nmeshread r0 r1 r2 r8`);

  const naturePoseDone=label('nature_pose_done');
  out('load8 r9 8203\ncmp r9 4\njlt '+naturePoseDone+
      '\ncmp r9 124\njge '+naturePoseDone+
      '\nlocalget r9 3120\nlocalset 3091 r1\nmov r5 r9\nmul r5 73\nmod r5 41\nadd r5 82\nmul r0 r5\ndiv r0 100'+
      '\nmov r5 r9\nmul r5 47\nmod r5 39\nadd r5 88\nmul r1 r5\ndiv r1 100'+
      '\nmov r5 r9\nmul r5 29\nmod r5 31\nadd r5 86\nmul r2 r5\ndiv r2 100'+
      '\nmod r9 7\nsub r9 3\nmul r9 r1\ndiv r9 70\nadd r0 r9\nlocalget r9 3104\nadd r1 r9\nlabel '+naturePoseDone);
  // Split-normal vertices reuse the original deformed canonical position.
  const wheelTransform=label('wheel_transform'),wheelDone=label('wheel_transform_done');
  for(const band of wheelBands.filter(b=>b.detail!=='far')){
   const nextModel=label('wheel_next_model');
   out('cmp r8 '+band.first+'\njlt '+nextModel+'\ncmp r8 '+band.last+'\njge '+nextModel);
   for(const wheel of band.wheels){
    const nextWheel=label('wheel_next_wheel');
    out('cmp r8 '+wheel.last+'\njge '+nextWheel+'\nlocalset 3044 '+wheel.side*88+
      '\nlocalset 3045 '+wheel.z+'\nlocalset 3046 '+(wheel.front?1:0)+
      '\njmp '+wheelTransform+'\nlabel '+nextWheel);
   }
   out('label '+nextModel);
  }
  out('jmp '+wheelDone+'\nlabel '+wheelTransform);
  // Roll on X about y=34, z=wheel axle.
  out('sub r1 34\nlocalget r9 3045\nsub r2 r9\nlocalget r5 3041\nlocalget r6 3040\nmov r7 r1\nmul r7 r5\nmov r9 r2\nmul r9 r6\nsub r7 r9\ndiv r7 16384\nmul r1 r6\nmul r2 r5\nadd r1 r2\ndiv r1 16384\nmov r2 r1\nlocalget r9 3045\nadd r2 r9\nmov r1 r7\nadd r1 34');
  const rear=label('wheel_rear');
  out('localget r9 3046\ncmp r9 0\nje '+rear);
  // Front axle steering on Y around the physical hub.
  out('localget r9 3044\nsub r0 r9\nlocalget r9 3045\nsub r2 r9\nlocalget r5 3042\nlocalget r6 3043\nmov r7 r0\nmul r7 r6\nmov r9 r2\nmul r9 r5\nadd r7 r9\ndiv r7 16384\nmov r9 r2\nmul r9 r6\nmov r10 r0\nmul r10 r5\nsub r9 r10\ndiv r9 16384\nmov r0 r7\nlocalget r10 3044\nadd r0 r10\nmov r2 r9\nlocalget r10 3045\nadd r2 r10');
  out('label '+rear+'\nlabel '+wheelDone);
  // Garage models share the exact bounded topology/LOD, but change the real
  // 3D silhouette before projection. No overlay, image swap or Java geometry.
  // X-01 is the original 4.5m Aero. GT X-02 is a longer narrow fastback
  // with a taller roof; Track X-03 is shorter, wider and lower.
  const morphGT=label('garage_gt'),morphTrack=label('garage_track'),
    morphDone=label('garage_morph_done');
  out('localget r9 3070\ncmp r9 1\nje '+morphGT+
      '\ncmp r9 2\nje '+morphTrack+'\njmp '+morphDone+
      '\nlabel '+morphGT+
      '\nmul r0 96\ndiv r0 100\nmul r2 113\ndiv r2 100'+
      '\ncmp r1 74\njle '+morphDone+'\nadd r1 18\njmp '+morphDone+
      '\nlabel '+morphTrack+
      '\nmul r0 114\ndiv r0 100\nmul r2 92\ndiv r2 100'+
      '\ncmp r1 77\njle '+morphDone+'\nsub r1 14'+
      '\nlabel '+morphDone);
  // Centimetre Q8 spring pose from drive.xi. Hubs stay on the road while
  // the body rotates about the axles; chassis rise follows ballistic XI state.
  const suspensionDone=label('suspension_done'),suspensionBody=label('suspension_body');
  out('load8 r9 8203\ncmp r9 0\njne '+suspensionDone+
      '\ncmp r8 '+shadowStart+'\njge '+suspensionDone+
      '\nlocalget r9 3103\nadd r0 r9'+
      '\ncmp r8 '+wheelBands[0].first+'\njlt '+suspensionBody+
      '\ncmp r8 '+wheelBands[0].last+'\njge '+suspensionBody+
      '\nload16 r9 384\ncmp r9 0\nje '+suspensionDone+
      '\nsub r1 4\njmp '+suspensionDone+
      '\nlabel '+suspensionBody+
      '\nmov r5 r1\nsub r5 34'+
      '\nlocalget r6 3101\nmov r7 r6\nmul r7 r0\ndiv r7 22528\nadd r1 r7'+
      '\nlocalget r9 3102\nmov r7 r9\nmul r7 r2\ndiv r7 35840\nadd r1 r7'+
      '\nmul r6 r5\ndiv r6 22528\nsub r0 r6'+
      '\nmul r9 r5\ndiv r9 35840\nsub r2 r9'+
      '\nlocalget r9 3100\nadd r1 r9'+
      '\nlabel '+suspensionDone);
  // FX ribbons change shape with the real XI fade clock, never screen motion.
  const effectsDone=label('fx_transform_done'),smokeDone=label('smoke_transform_done'),
    nitroDone=label('nitro_transform_done');
  out('load8 r9 8203\ncmp r9 0\njne '+effectsDone+
      '\ncmp r8 '+smokeStart+'\njlt '+smokeDone+
      '\ncmp r8 '+smokeEnd+'\njge '+smokeDone+
      '\nload8 r9 395\nmul r1 r9\ndiv r1 16\nlabel '+smokeDone+
      '\ncmp r8 '+nitroStart+'\njlt '+nitroDone+
      '\ncmp r8 '+nitroEnd+'\njge '+nitroDone+
      '\nload32 r9 115\nmod r9 7\nsub r9 3\nadd r2 r9\nlabel '+nitroDone+
      '\nlabel '+effectsDone);
  const airShapeDone=label('pressure_length_done');
  out('load8 r9 8203\ncmp r9 0\njne '+airShapeDone+
      '\ncmp r8 '+airJetStart+'\njlt '+airShapeDone+'\ncmp r8 '+airJetEnd+'\njge '+airShapeDone+
      '\nsub r1 24\nload16 r9 384\nadd r9 24\nmul r1 r9\ndiv r1 99\nadd r1 24\nlabel '+airShapeDone);
  // XI chassis altitude; ground shadow remains at road height.
  const noRise=label('vertex_no_pneumatic_rise'),rise=label('vertex_pneumatic_rise');
  out('load8 r9 8203\ncmp r9 0\njne '+noRise+
      '\ncmp r8 '+shadowStart+'\njlt '+rise+
      '\ncmp r8 '+nitroStart+'\njlt '+noRise+
      '\ncmp r8 '+nitroEnd+'\njge '+noRise+
      '\nlabel '+rise+'\nload16 r9 384\nadd r1 r9\nlabel '+noRise);
  const groundRiseDone=label('open_ground_rise_done');
  const playerGround=label('open_player_ground');
  out('load8 r9 8203\ncmp r9 0\nje '+playerGround+'\ncmp r9 124\njlt '+groundRiseDone+'\nlocalget r9 3104\nadd r1 r9\njmp '+groundRiseDone+'\nlabel '+playerGround+'\nload16 r9 520\nadd r1 r9\nlabel '+groundRiseDone);
  load('r9',8310,2,32768);out('mul r9 r0');load('r10',8308,2,32768);out('mul r10 r2\nadd r9 r10\ndiv r9 16384');store('r9',8320,4,1000000,'r10','r11');
  load('r9',8310,2,32768);out('mul r9 r2');load('r10',8308,2,32768);out('mul r10 r0\nsub r9 r10\ndiv r9 16384');load('r10',8304);out('add r10 r9');load('r0',8320);load('r11',8300);out('add r0 r11');
  load('r11',8192,2,0);out('add r10 r11');load('r11',8194,2,0);out('sub r1 r11');pitch('r0','r1','r2');
  out('label vertex_publish_position');load('r8',8324,2,0);out(`add r8 ${CAMERA}\nmeshvertex r8 r0 r1 r2\nmov r9 r8\nsub r9 ${CAMERA}\nadd r9 512\nlocalget r9 r9\ndiv r9 2048\nmeshtexcopy r8 r9\nmov r9 r8\nsub r9 ${CAMERA-512}\nlocalget r9 r9\nmod r9 2048\ncmp r9 256\njlt vertex_shade_ready\nadd r9 2048\nlocalget r9 r9\nlabel vertex_shade_ready\nload8 r6 8203\ncmp r6 4\njlt nature_vertex_shade_done\ncmp r6 124\njge nature_vertex_shade_done\nlocalget r9 3090\nlocalget r6 3091\ndiv r6 30\nadd r9 r6\ncmp r9 255\njle nature_vertex_shade_done\nset r9 255\nlabel nature_vertex_shade_done\nmeshshade r8 r9\nsub r8 ${CAMERA-1}`);store('r8',8324,2,0);load('r0',8326,2,0);out('cmp r8 r0\njlt actor_vertex');
 }
 transformVertex();
 // Expand the ephemeral smoke and nitro meshes once per frame, only when
 // XI's authoritative event flags are active. Each next pass continues the
 // same actor with a fresh vertex interval (no Java particle overlay).
 out('load8 r0 8203\ncmp r0 0\njne actor_shadow_stage'+
     '\nload8 r0 8337\ncmp r0 1\nje actor_nitro_stage'+
     '\nstore8 8337 1\nload8 r0 395\ncmp r0 0\njle actor_nitro_stage');
 range(smokeStart,smokeEnd);out('jmp actor_vertex\nlabel actor_nitro_stage');
 out('load8 r0 8338\ncmp r0 1\nje actor_air_stage'+
     '\nstore8 8338 1\nload8 r0 382\ncmp r0 1\njne actor_air_stage');
 range(nitroStart,nitroEnd);out('jmp actor_vertex\nlabel actor_air_stage');
 out('load8 r0 8336\ncmp r0 1\nje actor_shadow_stage\nload8 r0 388\ncmp r0 0\njle actor_shadow_stage\nstore8 8336 1');
 range(airJetStart,airJetEnd);out('jmp actor_vertex\nlabel actor_shadow_stage');
 out('load8 r0 8203\ncmp r0 4\njge actor_geometry_ready\nload8 r0 8335\ncmp r0 1\nje actor_geometry_ready\nstore8 8335 1');
 range(shadowStart,shadowEnd);out('jmp actor_vertex\nlabel actor_geometry_ready');
 focus();out('load8 r12 8203\ncmp r12 124\njge emit_skid\ncmp r12 4\njge emit_tree\nload8 r12 8334\ncmp r12 1\nje emit_hood\ncmp r12 2\nje emit_far\nload8 r12 8203\ncmp r12 0\nje emit_high\njmp emit_medium');
 function face(f){
  const [a,b,c]=f.indices.map(i=>i+CAMERA),ramp=RAMPS[f.material];
  if(ramp){if(f.material==='paint')out('load8 r12 8318');else out(`set r12 ${ramp.base}`);const t=TEXTURED_MATERIALS[f.material];out(t?`meshfacegradienttex ${a} ${b} ${c} r12 ${ramp.count} ${t.id} ${t.strength} r9 r10 r11 60`:`meshfacegradient ${a} ${b} ${c} r12 ${ramp.count} r9 r10 r11 60`);}
  else if(f.material==='lampRed'){
   const dim='brake_dim_'+a+'_'+b+'_'+c;
   const done='brake_done_'+a+'_'+b+'_'+c;
   out('load8 r0 8203\ncmp r0 0\njne '+dim+'\nload8 r0 129\ncmp r0 1\njne '+dim+
      `\nmeshface ${a} ${b} ${c} 224 r9 r10 r11 60\njmp `+done+'\nlabel '+dim+
      `\nmeshface ${a} ${b} ${c} 242 r9 r10 r11 60\nlabel `+done);
  }else out(`meshface ${a} ${b} ${c} ${FLAT[f.material]} r9 r10 r11 60`);
 }
 out('label emit_hood');models.high.faces.filter(f=>f.hood).forEach(face);out('jmp next_actor');
 for(const d of ['high','medium','far']){
  out('label emit_'+d);models[d].faces.forEach(face);
  if(d==='high'){
   const airSkip=label('air_jet_pulse_done');
   out('load8 r0 388\ncmp r0 0\njle '+airSkip);
   for(const f of airJetFaces)
    out('meshfacegradient '+f.map(i=>i+CAMERA).join(' ')+' 244 12 r9 r10 r11 60');
   out('label '+airSkip);
   const smokeSkip=label('smoke_done');
   out('load8 r0 395\ncmp r0 0\njle '+smokeSkip+
      '\nload16 r0 384\ncmp r0 0\njne '+smokeSkip);
   const drySmoke=label('spray_dry'),sprayDone=label('spray_done');
   out('load16 r0 544\ncmp r0 0\nje '+drySmoke);
   for(const f of smokeFaces)out('meshfacegradient '+f.map(i=>i+CAMERA).join(' ')+' 32 8 r9 r10 r11 60');
   out('jmp '+sprayDone+'\nlabel '+drySmoke);
   for(const f of smokeFaces)out('meshfacegradient '+f.map(i=>i+CAMERA).join(' ')+' 244 12 r9 r10 r11 60');
   out('label '+sprayDone);
   out('label '+smokeSkip);
   const nitroSkip=label('nitro_done');
   out('load8 r0 382\ncmp r0 1\njne '+nitroSkip);
   for(const f of nitroFaces)
    out('meshfacegradient '+f.map(i=>i+CAMERA).join(' ')+' 56 8 r9 r10 r11 60');
   out('label '+nitroSkip);
  }
  out('jmp emit_shadow');
 }
 out('label emit_skid');
 skidFaces.forEach(f=>out('meshfacegradient '+f.map(i=>i+CAMERA).join(' ')+' 24 8 r9 r10 r11 60'));
 out('jmp next_actor\nlabel emit_shadow\nset r12 24\nload8 r0 8203\ncmp r0 0\njne shadow_base_ready\nload8 r0 120\ncmp r0 0\nje shadow_base_ready\nset r12 24\nlabel shadow_base_ready');
 shadowFaces.forEach(f=>out(`meshfacegradient ${f.map(i=>i+CAMERA).join(' ')} r12 8 r9 r10 r11 60`));out('jmp next_actor\nlabel emit_tree');
 treeFaces.forEach(f=>out(`meshface ${f.indices.map(i=>i+CAMERA).join(' ')} ${f.material} r9 r10 r11 60`));
 out('label next_actor');load('r12',100,4,2000000);out('load8 r0 8203\nadd r0 1\nstore8 8203 r0\ncmp r0 128\njlt actor\nmeshend\nhalt');
 return {modelStats,normalGroups:groups.length,bodyLightingGroups:bodyMasks.size,glassLightingGroups:glassMasks.size,vertices:vertices.length,maxTriangles,airJetTriangles:airJetFaces.length,smokeTriangles:smokeFaces.length,nitroTriangles:nitroFaces.length,skidTriangles:4*skidFaces.length,trianglesPerTree:treeFaces.length,shadowTrianglesPerCar:shadowFaces.length};
};
