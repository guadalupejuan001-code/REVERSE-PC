#!/usr/bin/env node
'use strict';
// Test-only transport. The *real* XI VM owns surface geometry and RGB.
const fs=require('fs'),os=require('os'),path=require('path'),cp=require('child_process'),assert=require('assert');
const cli=path.resolve(process.argv[2]||'build/velocity/reverse_pc');
const output=path.resolve(process.argv[3]||'build/velocity');
const assets=path.resolve('reverse-os-android/app/src/main/assets/velocity');
fs.mkdirSync(output,{recursive:true});
const temp=fs.mkdtempSync(path.join(os.tmpdir(),'velocity-xi-render-'));
function run(...args){
 const p=cp.spawnSync(cli,args,{encoding:'utf8',timeout:120000,maxBuffer:12*1024*1024});
 if(p.status!==0||p.error)throw Error('XI executable failed: '+args.join(' ')+'\n'+p.stderr+'\n'+p.stdout);
 return p.stdout;
}
function values(output){
 return output.split('\n').filter(Boolean).map(s=>{
  const m=/"type":"register","register":"(r[0-9]+)","value":(-?[0-9]+)/.exec(s);
  assert(m,'XI returned an invalid register JSON record: '+s.slice(0,60));
  return {register:m[1],value:BigInt(m[2])}; // 56-bit spans: never round using JS Number
 });
}
const W=1280,H=720;
function unpack(rows,stride){
 const pixels=new Uint32Array(W*H),coverage=new Set(),colors=new Set();
 let last=-1;
 assert(rows.length>=H/stride&&rows.length<=H/stride*12,'bounded scanline contract');
 for(const {register,value} of rows){
  assert.equal(register,'r4','XI must emit one packed register per span');
  assert(value>=0n&&value<(1n<<56n),'invalid 56-bit span');
  const y=Number(value>>46n),x0=Number((value>>35n)&2047n);
  const x1=Number((value>>24n)&2047n),rgb=Number(value&0xffffffn);
  assert(y>=last&&y>=0&&y<H&&y%stride===0,'unsorted or misaligned scanline');
  assert(x0>=0&&x0<x1&&x1<=W,'invalid span coordinates');
  last=y;coverage.add(y);colors.add(rgb);
  for(let row=y;row<Math.min(H,y+stride);row++)
   pixels.fill(0xff000000|rgb,row*W+x0,row*W+x1);
 }
 for(let y=0;y<H;y+=stride)assert(coverage.has(y),'missing XI row '+y);
 return {spans:rows.length,colors:colors.size,pixels,sky:pixels[12*W+20],
         grass:pixels[708*W+20],asphalt:pixels[708*W+640],glass:pixels[586*W+640]};
}
const header='#!reverse-pc-machine-v1\n';
function shader(stride,camera,paint){
 const xi=fs.readFileSync(path.join(assets,'render.xi'),'utf8');
 assert(xi.startsWith(header),'missing original XI shebang');
 return header+'store8 200 '+stride+'\nstore8 201 '+camera+
  '\nstore8 202 '+paint+'\n'+xi.slice(header.length);
}
try{
 const initial=path.join(temp,'initial.rvp');
 run('init',initial);
 const world=path.join(temp,'world.rxe'),drive=path.join(temp,'drive.rxe'),render=path.join(temp,'render.rxe');
 run('compile',path.join(assets,'world.xi'),world,'XI World');
 run('compile',path.join(assets,'drive.xi'),drive,'XI Driving');
 run('compile',path.join(assets,'render.xi'),render,'XI Render');
 const generated=path.join(temp,'world.rvp');
 assert.equal(values(run('run',world,initial,generated)).length,482,'XI world 241-sample ABI');
 const driveSource=fs.readFileSync(path.join(assets,'drive.xi'),'utf8');
 const reset=path.join(temp,'reset.xi');
 fs.writeFileSync(reset,header+'store8 132 1\n'+driveSource.slice(header.length));
 const state=path.join(temp,'game.rvp');
 const started=values(run('run',reset,generated,state));
 assert.equal(started.length,9);assert.equal(started[0].value,83n);
 assert.equal(started[1].value,110000n);
 const measured=[];
 for(const [stride,camera,paint] of [[4,0,0],[2,0,3],[1,0,4],[4,2,0]]){
  const script=path.join(temp,'shader-'+stride+'-'+camera+'.xi');
  fs.writeFileSync(script,shader(stride,camera,paint));
  const begin=process.hrtime.bigint();
  const lines=values(run('run',script,state,path.join(temp,'frame-'+stride+'-'+camera+'.rvp')));
  const ms=Number(process.hrtime.bigint()-begin)/1e6;
  const frame=unpack(lines,stride);
  assert(frame.colors>20,'XI material and atmosphere color variety insufficient');
  assert.notEqual(frame.sky,frame.grass,'XI sky and terrain must differ');
  assert.notEqual(frame.grass,frame.asphalt,'XI road must differ from terrain');
  if(camera===2)assert.notEqual(frame.glass,measured[0].glass,'XI cockpit must hide chase car');
  if(stride===4&&camera===0){
    const duplicate=values(run('run',script,state,path.join(temp,'repeat.rvp')));
    assert.deepEqual(duplicate,lines,'XI render must be deterministic');
  }
  measured.push({stride,camera,paint,spans:frame.spans,uniqueColors:frame.colors,
    hostRunMs:+ms.toFixed(2),sky:frame.sky,grass:frame.grass,asphalt:frame.asphalt,
    glass:frame.glass});
 }
 const second=path.join(temp,'without-world.xi');
 fs.writeFileSync(second,shader(4,0,0));
 const missing=values(run('run',second,initial,path.join(temp,'missing.rvp')));
 assert.equal(missing.length,0,'XI renderer must reject a state without world.xi geometry');
 console.log(JSON.stringify({result:'REVERSE_VELOCITY_XI_RENDER_PASS',language:'XI Machine v1',
  output:'packed spans 1280x720',worldSource:'shared XI InverseMemory',
  measured,legacyNativeEngineUntouched:true}));
}catch(error){console.error(error.stack||error);process.exitCode=1;}
finally{fs.rmSync(temp,{recursive:true,force:true})}
