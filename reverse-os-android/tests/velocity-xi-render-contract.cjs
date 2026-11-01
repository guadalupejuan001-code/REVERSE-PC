#!/usr/bin/env node
'use strict';
// Execute the authored XI world, driving reset and 3D renderer in the real VM.
// The host chooses inputs/inspection poses and validates visible XFS1 runs.
const fs=require('node:fs'),os=require('node:os'),path=require('node:path');
const cp=require('node:child_process'),assert=require('node:assert/strict');
const crypto=require('node:crypto'),{performance}=require('node:perf_hooks');
const cli=path.resolve(process.argv[2]||'build/velocity/reverse_pc');
const output=path.resolve(process.argv[3]||'build/velocity/regraphics');
const assets=path.resolve('reverse-os-android/app/src/main/assets/velocity');
const HEADER='#!reverse-pc-machine-v1\n',MAX_FRAME_BYTES=24+14*360*641;
const sizes=new Map([[4,[320,180]],[2,[480,270]],[1,[640,360]]]);
const palette=fs.readFileSync(path.join(assets,'palette.txt'),'utf8').trim().split(/\r?\n/).map(s=>{
 assert.match(s,/^[0-9a-f]{6}$/,'authored palette entry');return parseInt(s,16);
});
assert.equal(palette.length,256,'authored 3D palette');
const renderer=fs.readFileSync(path.join(assets,'render.xi'),'utf8');
const driving=fs.readFileSync(path.join(assets,'drive.xi'),'utf8');
const worldSource=fs.readFileSync(path.join(assets,'world.xi'),'utf8');
fs.mkdirSync(output,{recursive:true});
const temp=fs.mkdtempSync(path.join(os.tmpdir(),'velocity-scene-v3-'));
const sha=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
const median=list=>[...list].sort((a,b)=>a-b)[list.length>>1];
const rounded=n=>+n.toFixed(3);
const inRange=(v,min,max)=>v>=min&&v<=max;
let serial=0;
function execute(args,binary=false){
 const t=performance.now();
 const p=cp.spawnSync(cli,args,{encoding:binary?null:'utf8',timeout:30000,maxBuffer:12*1024*1024});
 assert(!p.error,'XI process failed: '+String(p.error));
 assert.equal(p.status,0,'XI execution failed: '+args.join(' ')+'\n'+String(p.stderr));
 return {bytes:p.stdout,ms:performance.now()-t};
}
function run(...args){return execute(args).bytes;}
function registers(text){
 return text.split('\n').filter(Boolean).map(line=>{
  const m=/^\{"type":"register","register":"r([0-9]+)","value":(-?[0-9]+)\}$/.exec(line);
  assert(m,'unexpected XI observation '+line.slice(0,80));
  const value=Number(m[2]);assert(Number.isSafeInteger(value),'unsafe numeric observation');
  return {register:Number(m[1]),value};
 });
}
function inject(source,inputs){
 assert(source.startsWith(HEADER),'XI source header');return HEADER+inputs+source.slice(HEADER.length);
}
function decode(b,stride){
 assert(sizes.has(stride),'supported quality');
 const [width,height]=sizes.get(stride);
 const maxSpans=width+1;
 assert(Buffer.isBuffer(b)&&b.length>=24&&b.length<=MAX_FRAME_BYTES&&
  b.length<=24+14*height*maxSpans,'frame byte budget');
 assert.equal(b.toString('ascii',0,4),'XFS1');assert.equal(b[4],1);
 assert.equal(b[5],0);assert.equal(b.readUInt16LE(6),width);assert.equal(b.readUInt16LE(8),height);
 assert.equal(b.readUInt32LE(10),2,'3D revision');assert.equal(b.readUInt16LE(14),0);
 assert.equal((b.length-24)%14,0,'aligned commands');
 const commands=(b.length-24)/14;
 assert(Number.isSafeInteger(commands)&&commands<=height*maxSpans,'finite command budget');
 const end=b.length-8;
 assert.equal(b[end],3);assert.equal(b[end+1],0);assert.equal(b.readUInt16LE(end+2),0);
 assert.equal(b.readUInt32LE(end+4),2,'end revision');
 const spans=[];let lastY=-1,expectedY=0,rowCount=0,lastForeground=-1;
 for(let at=16;at<end;at+=14){
  assert.equal(b[at],2,'span opcode');
  const material=b[at+1],y=b.readUInt16LE(at+2),x0=b.readUInt16LE(at+4),
   x1=b.readUInt16LE(at+6),depth=b.readUInt16LE(at+8);
  assert(material<palette.length,'unknown material');
  assert(y<height&&x0<=x1&&x1<width,'bounded visible interval');
  assert.equal(b.readUInt32LE(at+10),2,'span revision');
  if(y!==lastY){
   assert.equal(y,expectedY++,'ordered complete rows');
   assert.equal(x0,0);assert.equal(x1,width-1);assert.equal(depth,100,'full background row');
   lastY=y;rowCount=0;lastForeground=-1;
  }
  assert(++rowCount<=maxSpans,'row command budget');
  if(rowCount>1){assert.equal(depth,1,'final visibility marker');assert(x0>lastForeground,'foreground runs overlap');lastForeground=x1;}
  spans.push({y,x0,x1,material,depth});
 }
 assert.equal(expectedY,height,'frame coverage');return {width,height,spans};
}
function materialize(frame,ids=false){
 const pixels=ids?new Uint8Array(frame.width*frame.height):new Uint32Array(frame.width*frame.height);
 for(const s of frame.spans)pixels.fill(ids?s.material:0xff000000|palette[s.material],
  s.y*frame.width+s.x0,s.y*frame.width+s.x1+1);
 return pixels;
}
function render(state,stride,camera,paint,car=0,yaw=0,pitch=0){
 const id=serial++,source=path.join(temp,'render-'+id+'.xi');
 fs.writeFileSync(source,inject(renderer,'store8 200 '+stride+'\nstore8 201 '+camera+'\nstore8 202 '+paint+'\nstore8 203 '+car+
    '\nstore16 204 '+yaw+'\nstore16 206 '+pitch+'\n'));
 return execute(['run',source,state,path.join(temp,'candidate-'+id+'.rvp')],true);
}
function writeImage(label,frame,pixels,binary){
 const body=Buffer.alloc(pixels.length*3);
 for(let i=0;i<pixels.length;i++){body[i*3]=pixels[i]>>>16;body[i*3+1]=pixels[i]>>>8;body[i*3+2]=pixels[i];}
 const basename=path.join(output,'velocity-regraphics-'+label);
 fs.writeFileSync(basename+'.ppm',Buffer.concat([Buffer.from('P6\n'+frame.width+' '+frame.height+'\n255\n'),body]));
 fs.writeFileSync(basename+'.xfs1',binary);
 if(process.env.VELOCITY_WRITE_PNG==='1'){
  const result=cp.spawnSync('convert',[basename+'.ppm',basename+'.png']);
  assert.equal(result.status,0,String(result.stderr));
 }
}
try{
 const initial=path.join(temp,'initial.rvp'),world=path.join(temp,'world.rvp'),state=path.join(temp,'ready.rvp');
 run('init',initial);
 const worldFile=path.join(temp,'world.xi');fs.writeFileSync(worldFile,worldSource);
 const observed=registers(run('run',worldFile,initial,world));
 assert.equal(observed.length,162,'81 world-space vertices');
 const points=[];
 for(let i=0;i<81;i++){
  assert.equal(observed[2*i].register,0);assert.equal(observed[2*i+1].register,1);
  points.push([observed[2*i].value,observed[2*i+1].value]);
 }
 assert.deepEqual(points[0],[0,0],'track start');assert.deepEqual(points[80],points[0],'closed centerline');
 assert.equal(new Set(points.slice(0,80).map(p=>p.join(','))).size,80,'distinct track vertices');
 const length=points.slice(1).reduce((sum,p,i)=>sum+Math.hypot(p[0]-points[i][0],p[1]-points[i][1]),0);
 assert(length>150000&&length<170000,'stadium course length');
 const reset=path.join(temp,'reset.xi');
 fs.writeFileSync(reset,inject(driving,'store8 128 0\nstore8 129 0\nstore8 130 1\nstore8 131 0\nstore8 132 1\n'));
 const started=registers(run('run',reset,world,state));
 assert.equal(started.length,22,'driving observation ABI');started.forEach((r,i)=>assert.equal(r.register,i%16));
 assert.deepEqual(started.slice(0,9).map(r=>r.value),[0,0,0,0,0,0,0,0,0],'race reset pose');
 assert.equal(started[9].value,4);assert.equal(started[10].value,0);assert.equal(started[13].value,150);
 const retainedHash=sha(fs.readFileSync(state)),measured=[],benchmarks=[],hashes=new Map();
 function observe(source,stride,camera,paint,label){
  const retained=sha(fs.readFileSync(source)),first=render(source,stride,camera,paint);
  const repeat=render(source,stride,camera,paint);
  assert(first.bytes.equals(repeat.bytes),'deterministic scene '+[label,stride,camera,paint].join('/'));
  const frame=decode(first.bytes,stride),pixels=materialize(frame),ids=materialize(frame,true);
  assert.equal(sha(fs.readFileSync(source)),retained,'render mutated retained snapshot');
  const colors=new Set(pixels),visible=new Set(ids),materials=[...visible].sort((a,b)=>a-b);
  assert(colors.size>10,'3D scene lacks authored materials');
  assert(pixels.every(p=>(p>>>24)===255),'unpresented image pixel');
  const count=(lo,hi)=>materials.filter(m=>inRange(m,lo,hi)).length;
  const paintMaterials=count(64+24*paint,87+24*paint);
  if(label==='reset'){
   assert(visible.has(0)&&visible.has(1),'sky and horizon absent');
   assert(visible.has(2),'terrain absent');
   assert(count(40,47)>=1,'real road texture was not visible');
   assert(visible.has(7),'road markings absent');
   if(paintMaterials<(camera===2?1:2)){console.error('XI_TEXTURE_DIAGNOSTIC',JSON.stringify({label,stride,camera,paint,visibleMaterials:materials,colors:colors.size,frameBytes:first.bytes.length}));writeImage('debug-texture-missing-paint',frame,pixels,first.bytes);}
   assert(paintMaterials>=(camera===2?1:2),'selected car/hood paint absent');
  }
  const pixelHash=sha(Buffer.from(pixels.buffer));
  measured.push({label,stride,camera,paint,width:frame.width,height:frame.height,commands:frame.spans.length,
   bytes:first.bytes.length,hostRunMs:rounded(first.ms),uniqueColors:colors.size,
   selectedPaintShades:paintMaterials,glassShades:count(184,207),asphaltTextureShades:count(40,47),visibleMaterials:materials,pixelSha256:pixelHash});
  if(label==='reset')hashes.set(stride+':'+camera+':'+paint,pixelHash);
  if(label==='reset'&&stride===1&&paint===0)writeImage('camera-'+camera,frame,pixels,first.bytes);
  if(label==='reset'&&camera===0&&paint===0){
   const samples=[first.ms,repeat.ms,render(source,stride,camera,paint).ms],decodeMs=[],presentMs=[];
   for(let i=0;i<4;i++)materialize(decode(first.bytes,stride));
   for(let i=0;i<3;i++){
    let begin=performance.now();const parsed=decode(first.bytes,stride);decodeMs.push(performance.now()-begin);
    begin=performance.now();materialize(parsed);presentMs.push(performance.now()-begin);
   }
   benchmarks.push({stride,width:frame.width,height:frame.height,samples:3,
    hostRunMedianMs:rounded(median(samples)),decodeMedianMs:rounded(median(decodeMs)),
    materializeMedianMs:rounded(median(presentMs)),bytes:first.bytes.length,commands:frame.spans.length});
  }
  return pixelHash;
 }
 for(const stride of [4,2,1]){
  for(let camera=0;camera<3;camera++)for(let paint=0;paint<5;paint++)observe(state,stride,camera,paint,'reset');
  for(let camera=0;camera<3;camera++)assert.equal(new Set([0,1,2,3,4].map(p=>hashes.get(stride+':'+camera+':'+p))).size,5,'five paints visible for camera '+camera);
  assert.equal(new Set([0,1,2].map(c=>hashes.get(stride+':'+c+':0'))).size,3,'three distinct camera views');
  console.log('VELOCITY_SCENE_MODES_OK stride='+stride+' cases=15');
 }
 // These are explicitly inspection poses, not simulated driving evidence.
 // Physical lap/checkpoint behavior is covered by the separate gameplay test.
 const poseHashes=[];
 for(const [label,index,offset] of [['curve',25,0],['inbound',45,0],['return',65,0],['yaw',0,320]]){
  const p=points[index],next=points[index+1],stores=[];
  const yaw=(Math.round(Math.atan2(next[0]-p[0],next[1]-p[1])*4096/(2*Math.PI))+4096+offset)%4096;
  function put(address,value,n){for(let i=0;i<n;i++)stores.push('store8 '+(address+i)+' '+((value>>>(8*i))&255));}
  put(100,p[0]+2000000,4);put(104,p[1]+2000000,4);put(108,yaw,2);
  const source=path.join(temp,'pose-'+label+'.xi'),candidate=path.join(temp,'pose-'+label+'.rvp');
  fs.writeFileSync(source,HEADER+stores.join('\n')+'\nhalt\n');run('run',source,state,candidate);
  poseHashes.push(observe(candidate,4,0,0,label));
 }
 assert.equal(new Set(poseHashes).size,4,'world-position/yaw inspection poses must change the scene');

 // The render observes distance and steering without mutating its input state.
 const wheelEvidence=[];
 for(const [name,distance,steer] of [['neutral',0,1000],['rolling',54,1000],['left',54,350],['right',54,1650]]){
  const program=path.join(temp,'wheel-'+name+'.xi'),snapshot=path.join(temp,'wheel-'+name+'.rvp');
  fs.writeFileSync(program,HEADER+'store32 278 '+distance+'\nstore16 256 '+steer+'\nhalt\n');
  run('run',program,state,snapshot);
  const first=render(snapshot,1,1,0),again=render(snapshot,1,1,0);
  assert(first.bytes.equals(again.bytes),'wheel scene deterministic: '+name);
  decode(first.bytes,1);
  wheelEvidence.push({name,distanceCm:distance,steering:steer,frameSha256:sha(first.bytes)});
 }
 assert.equal(sha(fs.readFileSync(state)),retainedHash,'wheel observation changed real race snapshot');
 // Compare actual XI pixel hashes for all three garage configurations.
 const garage=[];
 for(let car=0;car<3;car++){
  const first=render(state,1,0,0,car),repeat=render(state,1,0,0,car);
  assert(first.bytes.equals(repeat.bytes),'deterministic XI car body '+car);
  const frame=decode(first.bytes,1),pixels=materialize(frame);
  garage.push({car,frameSha256:sha(first.bytes),pixelSha256:sha(Buffer.from(pixels.buffer))});
 }
 assert.equal(new Set(garage.map(v=>v.pixelSha256)).size,3,
  'three garages must produce three different real 3D silhouettes');
 assert.equal(sha(fs.readFileSync(state)),retainedHash,
  'car switching must not mutate the authoritative XI race snapshot');
 // A real orbit changes both car and world projection, never the drivetrain.
 const orbit=[];
 for(const [name,yaw,pitch] of [['rear',0,0],['quarter',512,0],
                                ['side',1024,0],['front',2048,0],
                                ['elevated',512,110],['lower',512,422]]){
  const first=render(state,1,0,0,0,yaw,pitch);
  const second=render(state,1,0,0,0,yaw,pitch);
  assert(first.bytes.equals(second.bytes),'deterministic XI orbit '+name);
  const frame=decode(first.bytes,1),pixels=materialize(frame);
  orbit.push({name,yaw,pitch,pixelSha256:sha(Buffer.from(pixels.buffer)),
      packetSha256:sha(first.bytes)});
  if(name==='quarter'||name==='elevated')
   writeImage('camera-orbit-'+name,frame,pixels,first.bytes);
 }
 assert.equal(new Set(orbit.map(o=>o.pixelSha256)).size,orbit.length,
  'camera orbit and elevation must change real projected XI pixels in all poses');
 assert.equal(sha(fs.readFileSync(state)),retainedHash,
  'touch camera orbit must never mutate the physical XI race snapshot');
 assert.equal(sha(fs.readFileSync(state)),retainedHash,'scene campaign changed authoritative reset snapshot');
 const report={passed:true,result:'REVERSE_VELOCITY_REGRAPHICS_V3_SCENE_PASS',language:'XI Machine v1',
  output:'XFS1 revision2 from generic 3D mesh visibility',paletteEntries:256,worldVertexCount:81,
  trackLengthCm:rounded(length),stateRegisters:16,modeCases:45,inspectionPoses:4,
  deterministicCases:measured.length,inputStateUnchanged:true,sourceOnlyRenderer:true,
  androidDeviceMeasured:false,threeCamerasDistinct:true,fivePaintsPerCamera:true,
  rendererSha256:sha(renderer),worldSha256:sha(worldSource),driveSha256:sha(driving),wheelEvidence,
  selectableCars:3,garage,orbitViews:6,orbit,benchmarks,measured};
 fs.writeFileSync(path.join(output,'velocity-regraphics-results.json'),JSON.stringify(report,null,2)+'\n');
 console.log(JSON.stringify({...report,measured:undefined}));
}catch(error){console.error(error.stack||error);process.exitCode=1;}
finally{fs.rmSync(temp,{recursive:true,force:true});}
