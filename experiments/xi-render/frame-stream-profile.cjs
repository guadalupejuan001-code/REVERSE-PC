#!/usr/bin/env node
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const assert=require('node:assert/strict'),{performance}=require('node:perf_hooks');
const {encode,decode,fromXI}=require('./frame-stream.cjs');
const dir=path.resolve(process.argv[2]||'build/xi-render/evidence');
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const median=a=>a.slice().sort((a,b)=>a-b)[Math.floor(a.length/2)];
function oldCompose(b){
 const w=b.readUInt16LE(6),h=b.readUInt16LE(8);
 const pixels=Buffer.alloc(w*h),depth=new Uint16Array(w*h);depth.fill(65535);
 for(let p=16;p<b.length-8;p+=14){
  const m=b[p+1],y=b.readUInt16LE(p+2),l=b.readUInt16LE(p+4),
    r=b.readUInt16LE(p+6),z=b.readUInt16LE(p+8);
  for(let x=l;x<=r;x++){const i=y*w+x;if(z<depth[i]){depth[i]=z;pixels[i]=m;}}
 }
 return {pixels,sha256:hash(pixels)};
}
function recreateXI(b){
 const h=b.readUInt16LE(8),rows=Array.from({length:h},()=>[-1,-1,-1,-1]);
 for(let p=16;p<b.length-8;p+=14){
  const y=b.readUInt16LE(p+2),i=b[p+1]===2?0:2;
  assert.equal(rows[y][i],-1,'only two spans per row in XI sample');
  rows[y][i]=b.readUInt16LE(p+4);rows[y][i+1]=b.readUInt16LE(p+6);
 }
 return rows.map(a=>a.map((v,i)=>JSON.stringify({type:'register',register:'r'+(12+i),value:v})).join('\n')).join('\n')+'\n';
}
let rng=0x58465331;
function random(n){rng^=rng<<13;rng^=rng>>>17;rng^=rng<<5;return (rng>>>0)%n;}
function randomChecks(){
 for(let t=0;t<200;t++){
  const w=12+random(71),h=8+random(49),commands=[];
  for(let i=0,n=15+random(120);i<n;i++){
   const x0=random(w);
   commands.push({y:random(h),x0,x1:x0+random(w-x0),
     material:random(2)?2:3,depth:random(9)===0?65535:1+random(8)});
  }
  const frame=encode({width:w,height:h,revision:t+1,commands});
  assert(decode(frame).pixels.equals(oldCompose(frame).pixels),'random depth mismatch '+t);
 }
 const tie=encode({width:8,height:2,revision:7,commands:[
  {y:0,x0:0,x1:7,material:2,depth:10},
  {y:0,x0:0,x1:7,material:3,depth:10},
  {y:1,x0:0,x1:7,material:3,depth:65535}
 ]});
 assert(decode(tie).pixels.equals(oldCompose(tie).pixels));
 assert.equal(decode(tie).pixels[0],2);assert.equal(decode(tie).pixels[8],0);
}
function bench(fn){
 for(let i=0;i<10;i++)fn();
 const samples=[];
 for(let i=0;i<40;i++){const t=performance.now();fn();samples.push(performance.now()-t);}
 return Number(median(samples).toFixed(4));
}
const result={test:'XFS1 optimized materializer',scope:'warm Node compositor only; not end-to-end XI or Android',
 controls:'identical frame SHA256 and 200 overlapping depth scenarios',
 environment:{node:process.version,platform:process.platform,arch:process.arch},
 cases:[],passed:false};
try{
 randomChecks();
 for(const [w,h] of [[96,48],[1280,720],[1920,1080]]){
  const b=fs.readFileSync(path.join(dir,'xfs1-'+w+'x'+h+'.bin'));
  const old=oldCompose(b),optimized=decode(b);
  assert(old.pixels.equals(optimized.pixels),'pixel mismatch');
  assert.equal(old.sha256,optimized.sha256,'hash mismatch');
  const xiText=recreateXI(b),reencoded=fromXI(xiText,w,h,b.readUInt32LE(10));
  assert(b.equals(reencoded),'XI span emission altered XFS1 format');
  const previousMs=bench(()=>oldCompose(b)),optimizedMs=bench(()=>decode(b));
  const serialMs=bench(()=>fromXI(xiText,w,h,b.readUInt32LE(10)));
  const row={width:w,height:h,pixels:w*h,commands:optimized.commands,
   hash:optimized.sha256,baselineCompositorMs:previousMs,optimizedCompositorMs:optimizedMs,
   compositorSpeedup:Number((previousMs/optimizedMs).toFixed(2)),
   xiToXfs1Ms:serialMs,
   baselinePixelAndDepthBytes:w*h*3,optimizedPixelBytes:w*h};
  result.cases.push(row);
  console.log('XI_FRAME_STREAM_PROFILE_OK',w,h,'reference',previousMs,
    'optimized',optimizedMs,'gain',row.compositorSpeedup,'encode',serialMs);
 }
 result.passed=true;
 fs.writeFileSync(path.join(dir,'frame-stream-profile.json'),JSON.stringify(result,null,2)+'\n');
 console.log('XI_FRAME_STREAM_PROFILE_ALL_OK scenes=3 random=200');
}catch(e){
 result.error=String(e.stack||e);
 fs.writeFileSync(path.join(dir,'frame-stream-profile-failure.json'),JSON.stringify(result,null,2)+'\n');
 console.error(result.error);process.exitCode=1;
}
