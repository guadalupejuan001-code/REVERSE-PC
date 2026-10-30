#!/usr/bin/env node
'use strict';
// Real XI scene execution. Hosts validate and materialize its visible spans.
const fs=require('node:fs'),os=require('node:os'),path=require('node:path');
const cp=require('node:child_process'),assert=require('node:assert/strict');
const crypto=require('node:crypto'),{performance}=require('node:perf_hooks');
const cli=path.resolve(process.argv[2]||'build/velocity/reverse_pc');
const output=path.resolve(process.argv[3]||'build/velocity/regraphics');
const assets=path.resolve('reverse-os-android/app/src/main/assets/velocity');
const fixture=path.resolve('reverse-os-android/tests/fixtures/velocity-packed-reference.xi');
const header='#!reverse-pc-machine-v1\n',W=1280,H=720,MAX_SPANS=48;
const palette=fs.readFileSync(path.join(assets,'palette.txt'),'utf8').trim().split(/\r?\n/).map(s=>{
 assert.match(s,/^[0-9a-f]{6}$/,'authored palette entry');return parseInt(s,16);
});
assert.equal(palette.length,256,'fixed REgraphics scene palette');
const binaryXi=fs.readFileSync(path.join(assets,'render.xi'),'utf8');
const referenceXi=fs.readFileSync(fixture,'utf8');
fs.mkdirSync(output,{recursive:true});
const temp=fs.mkdtempSync(path.join(os.tmpdir(),'velocity-regraphics-'));
const sha=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
const median=list=>[...list].sort((a,b)=>a-b)[list.length>>1];
const rounded=n=>+n.toFixed(3);
const inRange=(value,min,max)=>value>=min&&value<=max;
let serial=0;
function execute(args,binary=false){
 const begin=performance.now();
 const p=cp.spawnSync(cli,args,{encoding:binary?null:'utf8',timeout:30000,maxBuffer:12*1024*1024});
 assert.equal(p.status,0,'XI executable failed: '+args.join(' ')+'\n'+String(p.stderr));
 assert(!p.error,String(p.error));
 return {stdout:p.stdout,ms:performance.now()-begin};
}
function run(...args){return execute(args).stdout;}
function values(text){
 return text.split('\n').filter(Boolean).map(s=>{
  const m=/^\{"type":"register","register":"(r[0-9]+)","value":(-?[0-9]+)\}$/.exec(s);
  assert(m,'invalid XI register JSON: '+s.slice(0,80));
  return {register:m[1],value:BigInt(m[2])};
 });
}
function decode(b,stride){
 assert(Buffer.isBuffer(b)&&b.length>=24&&b.length<=24+14*(H/stride)*MAX_SPANS,'frame budget');
 assert.equal(b.toString('ascii',0,4),'XFS1');assert.equal(b[4],1);
 assert.equal(b[5],0);assert.equal(b.readUInt16LE(6),W);assert.equal(b.readUInt16LE(8),H);
 assert.equal(b.readUInt32LE(10),1);assert.equal(b.readUInt16LE(14),0);
 assert.equal((b.length-24)%14,0,'command alignment');
 const end=b.length-8;
 assert.equal(b[end],3);assert.equal(b[end+1],0);assert.equal(b.readUInt16LE(end+2),0);
 assert.equal(b.readUInt32LE(end+4),1,'end revision');
 const spans=[],coverage=new Set();let lastY=-1,lastDepth=65535,rowCount=0;
 for(let p=16;p<end;p+=14){
  assert.equal(b[p],2,'span opcode');
  const material=b[p+1],y=b.readUInt16LE(p+2),x0=b.readUInt16LE(p+4),
   x1=b.readUInt16LE(p+6),depth=b.readUInt16LE(p+8);
  assert(material<palette.length,'unknown palette material');
  assert(y>=lastY&&y<H&&y%stride===0&&x0<=x1&&x1<W,'span coordinates');
  assert.equal(b.readUInt32LE(p+10),1,'span revision');
  if(y!==lastY){
   lastDepth=101;rowCount=0;assert.equal(x0,0);assert.equal(x1,W-1,'full background row');
   assert.equal(depth,100,'background depth');
  }
  assert(depth>0&&depth<lastDepth,'far-to-near XI layer order');
  assert(++rowCount<=MAX_SPANS,'row command budget');
  spans.push({y,x0,x1,material,depth});coverage.add(y);lastY=y;lastDepth=depth;
 }
 for(let y=0;y<H;y+=stride)assert(coverage.has(y),'missing binary row '+y);
 return spans;
}
function materialize(spans,stride,ids=false){
 const pixels=ids?new Uint8Array(W*H):new Uint32Array(W*H);
 for(const s of spans){
  const value=ids?s.material:0xff000000|palette[s.material];
  for(let y=s.y;y<Math.min(H,s.y+stride);y++)pixels.fill(value,y*W+s.x0,y*W+s.x1+1);
 }
 return pixels;
}
function packedJson(spans){
 return spans.map(s=>'{"type":"register","register":"r4","value":'+
  ((BigInt(s.y)<<46n)|(BigInt(s.x0)<<35n)|(BigInt(s.x1+1)<<24n)|BigInt(palette[s.material]))+'}').join('\n')+'\n';
}
function shader(xi,stride,camera,paint){
 assert(xi.startsWith(header),'XI source header');
 return header+'store8 200 '+stride+'\nstore8 201 '+camera+
  '\nstore8 202 '+paint+'\n'+xi.slice(header.length);
}
function render(source,stride,camera,paint,binary=true){
 const id=serial++,script=path.join(temp,'shader-'+id+'.xi');
 fs.writeFileSync(script,shader(binary?binaryXi:referenceXi,stride,camera,paint));
 return execute(['run',script,source,path.join(temp,'frame-'+id+'.rvp')],binary);
}
function ppm(pixels){
 const body=Buffer.alloc(W*H*3);
 for(let i=0;i<pixels.length;i++){
  body[i*3]=pixels[i]>>>16;body[i*3+1]=pixels[i]>>>8;body[i*3+2]=pixels[i];
 }
 return Buffer.concat([Buffer.from('P6\n'+W+' '+H+'\n255\n'),body]);
}
function writeImage(label,frame){
 fs.writeFileSync(path.join(output,'velocity-regraphics-'+label+'.ppm'),ppm(frame.pixels));
 fs.writeFileSync(path.join(output,'velocity-regraphics-'+label+'.xfs1'),frame.binary);
}
try{
 const initial=path.join(temp,'initial.rvp');run('init',initial);
 const world=path.join(temp,'world.rxe'),drive=path.join(temp,'drive.rxe');
 run('compile',path.join(assets,'world.xi'),world,'XI World');
 run('compile',path.join(assets,'drive.xi'),drive,'XI Driving');
 // Frame instructions execute as source; direct-render RXE compilation is not claimed.
 const generated=path.join(temp,'world.rvp');
 assert.equal(values(run('run',world,initial,generated)).length,482,'241 XI world samples');
 const reset=path.join(temp,'reset.xi'),state=path.join(temp,'game.rvp');
 const driveXi=fs.readFileSync(path.join(assets,'drive.xi'),'utf8');
 fs.writeFileSync(reset,header+'store8 132 1\n'+driveXi.slice(header.length));
 const started=values(run('run',reset,generated,state));
 assert.equal(started.length,9);assert.equal(started[0].value,83n);assert.equal(started[1].value,110000n);
 const stateHash=sha(fs.readFileSync(state)),measured=[],benchmarks=[],modeHashes=new Map();
 function observe(source,stride,camera,paint,label){
  const before=sha(fs.readFileSync(source));
  const direct=render(source,stride,camera,paint,true),spans=decode(direct.stdout,stride);
  assert(render(source,stride,camera,paint,true).stdout.equals(direct.stdout),
   'same-state scene observation not deterministic: '+label+'/'+stride+'/'+camera+'/'+paint);
  const pixels=materialize(spans,stride),ids=materialize(spans,stride,true);
  const colors=new Set(),visible=new Set(),materials=new Set(spans.map(s=>s.material));
  for(let i=0;i<pixels.length;i++){assert.equal(pixels[i]>>>24,255,'unpresented pixel');colors.add(pixels[i]);visible.add(ids[i]);}
  assert.equal(sha(fs.readFileSync(source)),before,'render observation mutated game input');
  assert(colors.size>30,'scene material/atmosphere variety');
  const found=(min,max)=>[...visible].filter(m=>inRange(m,min,max));
  assert(found(0,63).length>5,'sky gradient absent');
  if(label==='spawn'){
   assert(found(96,127).length>3,'shaded asphalt absent');
   assert(found(170,185).length>0,'coastal sea absent');
   assert(found(194,201).length>0,'roadside foliage absent');
   assert(found(219,220).length>0,'guardrail absent');
   assert(found(229,236).length>0,'road sheen absent');
   const body=found(128+paint*6,133+paint*6);
   assert(body.length>=(camera===2?1:3),'paint/body shading absent');
  }
  const equivalentJson=packedJson(spans),pixelSha256=sha(Buffer.from(pixels.buffer));
  assert(direct.stdout.length<Buffer.byteLength(equivalentJson),'same-scene binary transport must reduce output');
  const row={label,stride,camera,paint,spans:spans.length,uniqueColors:colors.size,
   materials:[...materials].sort((a,b)=>a-b),visibleMaterials:[...visible].sort((a,b)=>a-b),
   equivalentJsonBytes:Buffer.byteLength(equivalentJson),binaryBytes:direct.stdout.length,
   sameSceneByteReductionPercent:rounded(100*(1-direct.stdout.length/Buffer.byteLength(equivalentJson))),
   binaryHostRunMs:rounded(direct.ms),pixelSha256};
  measured.push(row);
  if(label==='spawn')modeHashes.set(stride+':'+camera+':'+paint,pixelSha256);
  if(label==='spawn'&&stride===1&&paint===0)writeImage('camera-'+camera,{pixels,binary:direct.stdout});
  if(label==='spawn'&&camera===0&&paint===0){
   const newRuns=[direct.ms],jsonDecode=[],binaryDecode=[],materializeMs=[];
   for(let i=0;i<4;i++){values(equivalentJson);materialize(decode(direct.stdout,stride),stride);}
   for(let i=0;i<3;i++){
    let t=performance.now();values(equivalentJson);jsonDecode.push(performance.now()-t);
    t=performance.now();const decoded=decode(direct.stdout,stride);binaryDecode.push(performance.now()-t);
    t=performance.now();materialize(decoded,stride);materializeMs.push(performance.now()-t);
    if(i<2){
     const repeated=render(source,stride,camera,paint,true);newRuns.push(repeated.ms);
     assert(repeated.stdout.equals(direct.stdout),'same-state binary observation not deterministic');
    }
   }
   // This fixture is a smaller historic scene. Its execution cost is context,
   // not a like-for-like performance comparison with the upgraded scene.
   const historic=render(source,stride,0,0,false);
   benchmarks.push({stride,samples:3,decodeWarmupRuns:4,equivalentJsonBytes:row.equivalentJsonBytes,
    binaryBytes:row.binaryBytes,binaryHostRunMedianMs:rounded(median(newRuns)),
    equivalentJsonDecodeMedianMs:rounded(median(jsonDecode)),binaryDecodeMedianMs:rounded(median(binaryDecode)),
    binaryMaterializeMedianMs:rounded(median(materializeMs)),
    historicalDifferentScene:{jsonBytes:Buffer.byteLength(historic.stdout),hostRunMs:rounded(historic.ms),
     comparableWorkload:false}});
  }
  return {spans,pixels,ids,binary:direct.stdout};
 }
 for(const stride of [4,2,1])for(let camera=0;camera<3;camera++)for(let paint=0;paint<5;paint++)
  observe(state,stride,camera,paint,'spawn');
 for(const stride of [4,2,1]){
  for(let camera=0;camera<3;camera++)assert.equal(new Set([0,1,2,3,4].map(p=>modeHashes.get(stride+':'+camera+':'+p))).size,5,'five visible paints for every camera');
  assert.equal(new Set([0,1,2].map(c=>modeHashes.get(stride+':'+c+':0'))).size,3,'three distinct camera images');
 }
 function patch(source,stores,label){
  const id=serial++,file=path.join(temp,'patch-'+id+'.xi'),dest=path.join(temp,'patched-'+label+'-'+id+'.rvp');
  fs.writeFileSync(file,header+stores.map(([a,v])=>'store8 '+a+' '+v+'\n').join('')+'halt\n');
  run('run',file,source,dest);return dest;
 }
 function move(zCm,yaw,xCm=83){
  assert(zCm>=-85000&&zCm<=155000&&yaw>=0&&yaw<4096);
  const stores=[];
  for(const [base,value] of [[100,xCm+2000000],[104,zCm+2000000]])
   for(let i=0;i<4;i++)stores.push([base+i,(value>>>(8*i))&255]);
  stores.push([108,yaw&255],[109,(yaw>>>8)&255]);return patch(state,stores,'move');
 }
 const positions=[['start',110000,0,83],['half',110500,0,83],['next',111000,0,83],
  ['steered',110500,1024,83],['offroad-left',65000,3072,-25000],['offroad-right',-45000,512,25000]];
 const centers={},movingHashes=[];
 for(const [label,z,yaw,x] of positions){
  const result=observe(move(z,yaw,x),4,2,0,label);movingHashes.push(sha(Buffer.from(result.pixels.buffer)));
  if(!label.startsWith('offroad')){
   const asphalt=result.spans.find(s=>s.y===600&&inRange(s.material,96,127));
   assert(asphalt,'missing road projection at row600');centers[label]=(asphalt.x0+asphalt.x1+1)/2;
  }
 }
 assert.notEqual(centers.start,centers.half,'road snaps within one 10m sample');
 assert(Math.abs(centers.half-centers.start)<=Math.abs(centers.next-centers.start)+2,'road interpolation overshoot');
 assert.notEqual(centers.steered,centers.half,'yaw must affect road perspective');
 assert.equal(new Set(movingHashes.slice(0,4)).size,4,'on-road position/yaw observations must differ');
 // At +/-250m the finite road corridor is completely offscreen on both
 // sides; identical terrain-only images are a valid clipping result.
 for(const hash of movingHashes.slice(4))assert.notEqual(hash,movingHashes[0],
  'extreme off-road observation still shows the on-road view');
 const tickOnly=patch(state,[[115,177],[116,12]],'tick-only');
 assert(render(tickOnly,4,0,0,true).stdout.equals(render(state,4,0,0,true).stdout),
  'stationary scenery moved with race clock instead of world-space position');
 const driveScript=path.join(temp,'driving.xi');
 fs.writeFileSync(driveScript,header+'store8 128 1\nstore8 129 0\nstore8 130 2\nstore8 131 1\nstore8 132 0\n'+driveXi.slice(header.length));
 let driving=state,last;
 for(let i=0;i<40;i++){
  const dest=path.join(temp,'driving-'+i+'.rvp');last=values(run('run',driveScript,driving,dest));driving=dest;
 }
 assert(last[1].value<110000n&&last[3].value>0n,'real XI throttle must advance the vehicle');
 const driven=observe(driving,1,0,0,'driving');writeImage('driving',driven);
 const missing=render(initial,4,0,0,true);assert.equal(missing.stdout.length,0,'foreign state published a frame');
 assert.equal(sha(fs.readFileSync(state)),stateHash,'game snapshot changed by rendering');
 const report={result:'REVERSE_VELOCITY_REGRAPHICS_SCENE_PASS',language:'XI Machine v1',
  output:'direct XFS1 binary 1280x720',paletteEntries:palette.length,worldSource:'shared XI InverseMemory',
  sceneCases:measured.length,modeCases:45,movingCases:6,realDrivingTicks:40,deterministicCases:measured.length,
  inputStateUnchanged:true,sourceOnlyRenderer:true,androidDeviceMeasured:false,
  worldSpacePhaseVerified:true,threeCamerasDistinct:true,fivePaintsPerCamera:true,
  roadContinuity:centers,benchmarks,measured};
 fs.writeFileSync(path.join(output,'velocity-regraphics-results.json'),JSON.stringify(report,null,2)+'\n');
 console.log(JSON.stringify({...report,measured:undefined}));
}catch(error){console.error(error.stack||error);process.exitCode=1;}
finally{fs.rmSync(temp,{recursive:true,force:true});}
