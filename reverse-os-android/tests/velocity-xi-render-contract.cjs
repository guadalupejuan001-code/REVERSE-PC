#!/usr/bin/env node
'use strict';
// Differential transport proof. The real XI VM owns every scene equation.
const fs=require('node:fs'),os=require('node:os'),path=require('node:path');
const cp=require('node:child_process'),assert=require('node:assert/strict');
const crypto=require('node:crypto'),{performance}=require('node:perf_hooks');
const cli=path.resolve(process.argv[2]||'build/velocity/reverse_pc');
const output=path.resolve(process.argv[3]||'build/velocity/regraphics');
const assets=path.resolve('reverse-os-android/app/src/main/assets/velocity');
const fixture=path.resolve('reverse-os-android/tests/fixtures/velocity-packed-reference.xi');
const header='#!reverse-pc-machine-v1\n',W=1280,H=720;
const palette=fs.readFileSync(path.join(assets,'palette.txt'),'utf8').trim().split(/\r?\n/).map(s=>{
 assert.match(s,/^[0-9a-f]{6}$/,'authored palette entry');return parseInt(s,16);
});
assert.equal(palette.length,217,'fixed REgraphics palette');
const binaryXi=fs.readFileSync(path.join(assets,'render.xi'),'utf8');
const referenceXi=fs.readFileSync(fixture,'utf8');
fs.mkdirSync(output,{recursive:true});
const temp=fs.mkdtempSync(path.join(os.tmpdir(),'velocity-regraphics-'));
const sha=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
const median=list=>[...list].sort((a,b)=>a-b)[list.length>>1];
const rounded=n=>+n.toFixed(3);
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
function unpack(rows,stride){
 const pixels=new Uint32Array(W*H),coverage=new Set(),colors=new Set();
 let last=-1;
 assert(rows.length>=H/stride&&rows.length<=H/stride*12,'bounded scanline contract');
 for(const {register,value} of rows){
  assert.equal(register,'r4');assert(value>=0n&&value<(1n<<56n),'56-bit span');
  const y=Number(value>>46n),x0=Number((value>>35n)&2047n);
  const x1=Number((value>>24n)&2047n),rgb=Number(value&0xffffffn);
  assert(y>=last&&y<H&&y%stride===0,'ordered sampled rows');
  assert(x0>=0&&x0<x1&&x1<=W,'bounded packed span');
  last=y;coverage.add(y);colors.add(rgb);
  for(let row=y;row<Math.min(H,y+stride);row++)pixels.fill(0xff000000|rgb,row*W+x0,row*W+x1);
 }
 for(let y=0;y<H;y+=stride)assert(coverage.has(y),'missing XI row '+y);
 return {spans:rows.length,colors:colors.size,pixels,sky:pixels[12*W+20],
  grass:pixels[708*W+20],asphalt:pixels[708*W+640],glass:pixels[586*W+640]};
}
function decode(b,stride){
 assert(Buffer.isBuffer(b)&&b.length>=24&&b.length<=24+14*(H/stride)*12,'frame budget');
 assert.equal(b.toString('ascii',0,4),'XFS1');assert.equal(b[4],1);
 assert.equal(b[5],0);assert.equal(b.readUInt16LE(6),W);assert.equal(b.readUInt16LE(8),H);
 assert.equal(b.readUInt32LE(10),1);assert.equal(b.readUInt16LE(14),0);
 assert.equal((b.length-24)%14,0,'command alignment');
 const end=b.length-8;
 assert.equal(b[end],3);assert.equal(b[end+1],0);assert.equal(b.readUInt16LE(end+2),0);
 assert.equal(b.readUInt32LE(end+4),1,'end revision');
 const spans=[],coverage=new Set();let lastY=-1,lastDepth=65535;
 for(let p=16;p<end;p+=14){
  assert.equal(b[p],2,'span opcode');
  const material=b[p+1],y=b.readUInt16LE(p+2),x0=b.readUInt16LE(p+4),
   x1=b.readUInt16LE(p+6),depth=b.readUInt16LE(p+8);
  assert(material<palette.length,'unknown palette material');
  assert(y>=lastY&&y<H&&y%stride===0&&x0<=x1&&x1<W,'span coordinates');
  assert.equal(b.readUInt32LE(p+10),1,'span revision');
  if(y!==lastY){lastDepth=65535;assert.equal(x0,0);assert.equal(x1,W-1,'full background row');}
  assert(depth>0&&depth<lastDepth,'far-to-near XI layer order');
  spans.push({y,x0,x1,material,depth});coverage.add(y);lastY=y;lastDepth=depth;
 }
 for(let y=0;y<H;y+=stride)assert(coverage.has(y),'missing binary row '+y);
 return spans;
}
function materialize(spans,stride){
 const pixels=new Uint32Array(W*H);
 for(const s of spans){
  const argb=0xff000000|palette[s.material];
  for(let y=s.y;y<Math.min(H,s.y+stride);y++)pixels.fill(argb,y*W+s.x0,y*W+s.x1+1);
 }
 return pixels;
}
function toPacked(spans){
 return spans.map(s=>({register:'r4',value:(BigInt(s.y)<<46n)|(BigInt(s.x0)<<35n)|
  (BigInt(s.x1+1)<<24n)|BigInt(palette[s.material])}));
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
 const stateHash=sha(fs.readFileSync(state)),measured=[],benchmarks=[];
 let representative=null;
 function compare(source,stride,camera,paint,label){
  const before=sha(fs.readFileSync(source));
  const old=render(source,stride,camera,paint,false),direct=render(source,stride,camera,paint,true);
  const lines=values(old.stdout),spans=decode(direct.stdout,stride);
  assert.deepEqual(toPacked(spans),lines,'exact spans/RGB changed: '+label);
  const baseline=unpack(lines,stride),pixels=materialize(spans,stride);
  assert.deepEqual(pixels,baseline.pixels,'exact image changed: '+label);
  assert.equal(sha(fs.readFileSync(source)),before,'render observation mutated game input');
  assert(baseline.colors>20,'material/atmosphere variety');
  assert.notEqual(baseline.sky,baseline.grass);
  if(label==='spawn')assert.notEqual(baseline.grass,baseline.asphalt);
  assert(direct.stdout.length<Buffer.byteLength(old.stdout),'binary transport must reduce output');
  const row={label,stride,camera,paint,spans:spans.length,uniqueColors:baseline.colors,
   jsonBytes:Buffer.byteLength(old.stdout),binaryBytes:direct.stdout.length,
   byteReductionPercent:rounded(100*(1-direct.stdout.length/Buffer.byteLength(old.stdout))),
   jsonHostRunMs:rounded(old.ms),binaryHostRunMs:rounded(direct.ms),
   pixelSha256:sha(Buffer.from(pixels.buffer))};
  measured.push(row);
  if(label==='spawn'&&stride===1&&camera===0&&paint===0)representative={pixels,binary:direct.stdout};
  if(label==='spawn'&&camera===0&&paint===0){
   const oldRuns=[old.ms],newRuns=[direct.ms],oldDecode=[],newDecode=[],materializeMs=[];
   // Warm the Node transport/presentation helpers before sampling. The CLI
   // remains a separate process in each end-to-end host-run observation.
   for(let i=0;i<4;i++){values(old.stdout);materialize(decode(direct.stdout,stride),stride);}
   for(let i=0;i<3;i++){
    let t=performance.now();values(old.stdout);oldDecode.push(performance.now()-t);
    t=performance.now();const decoded=decode(direct.stdout,stride);newDecode.push(performance.now()-t);
    t=performance.now();materialize(decoded,stride);materializeMs.push(performance.now()-t);
    if(i<2){oldRuns.push(render(source,stride,camera,paint,false).ms);
     const repeated=render(source,stride,camera,paint,true);newRuns.push(repeated.ms);
     assert(repeated.stdout.equals(direct.stdout),'binary observation not deterministic');}
   }
   benchmarks.push({stride,samples:3,decodeWarmupRuns:4,jsonBytes:row.jsonBytes,binaryBytes:row.binaryBytes,
    jsonHostRunMedianMs:rounded(median(oldRuns)),binaryHostRunMedianMs:rounded(median(newRuns)),
    jsonDecodeMedianMs:rounded(median(oldDecode)),binaryDecodeMedianMs:rounded(median(newDecode)),
    binaryMaterializeMedianMs:rounded(median(materializeMs))});
  }
  return {spans,pixels,baseline};
 }
 for(const stride of [4,2,1])for(let camera=0;camera<3;camera++)for(let paint=0;paint<5;paint++)
  compare(state,stride,camera,paint,'spawn');
 function move(zCm,yaw,xCm=83){
  assert(zCm>=-85000&&zCm<=155000&&yaw>=0&&yaw<4096);
  let script=header;
  for(const [base,value] of [[100,xCm+2000000],[104,zCm+2000000]])
   for(let i=0;i<4;i++)script+='store8 '+(base+i)+' '+((value>>>(8*i))&255)+'\n';
  script+='store8 108 '+(yaw&255)+'\nstore8 109 '+((yaw>>>8)&255)+'\n';
  const id=serial++,file=path.join(temp,'position-'+id+'.xi'),dest=path.join(temp,'position-'+id+'.rvp');
  fs.writeFileSync(file,script);run('run',file,state,dest);return dest;
 }
 const positions=[['start',110000,0,83],['half',110500,0,83],['next',111000,0,83],
  ['steered',110500,1024,83],['offroad-left',65000,3072,-25000],['offroad-right',-45000,512,25000]];
 const centers={};
 for(const [label,z,yaw,x] of positions){
  const result=compare(move(z,yaw,x),4,2,0,label);
  if(!label.startsWith('offroad')){
   const asphalt=result.spans.find(s=>s.y===600&&s.material>=154&&s.material<=202);
   assert(asphalt,'missing road projection at row600');centers[label]=(asphalt.x0+asphalt.x1+1)/2;
  }
 }
 assert.notEqual(centers.start,centers.half,'road snaps within one 10m sample');
 assert(Math.abs(centers.half-centers.start)<=Math.abs(centers.next-centers.start)+2,'road interpolation overshoot');
 assert.notEqual(centers.steered,centers.half,'yaw must affect road perspective');
 const missing=render(initial,4,0,0,true);
 assert.equal(missing.stdout.length,0,'foreign state published a frame');
 assert.equal(sha(fs.readFileSync(state)),stateHash,'game snapshot changed by rendering');
 assert(representative,'missing representative image');
 fs.writeFileSync(path.join(output,'velocity-regraphics-1280x720.ppm'),ppm(representative.pixels));
 fs.writeFileSync(path.join(output,'velocity-regraphics-1280x720.xfs1'),representative.binary);
 const report={result:'REVERSE_VELOCITY_REGRAPHICS_PASS',language:'XI Machine v1',
  output:'direct XFS1 binary 1280x720',paletteEntries:palette.length,
  worldSource:'shared XI InverseMemory',differentialCases:measured.length,
  exactSpanAndRgbEquivalence:true,exactPixelEquivalence:true,inputStateUnchanged:true,
  sourceOnlyRenderer:true,androidDeviceMeasured:false,roadContinuity:centers,benchmarks,measured};
 fs.writeFileSync(path.join(output,'velocity-regraphics-results.json'),JSON.stringify(report,null,2)+'\n');
 console.log(JSON.stringify({...report,measured:undefined}));
}catch(error){console.error(error.stack||error);process.exitCode=1;}
finally{fs.rmSync(temp,{recursive:true,force:true});}
