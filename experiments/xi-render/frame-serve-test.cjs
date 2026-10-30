#!/usr/bin/env node
'use strict';
// Persistent protocol test only; all scene math is in super-road-direct.xi.
const fs=require('node:fs'),path=require('node:path'),os=require('node:os');
const cp=require('node:child_process'),crypto=require('node:crypto');
const assert=require('node:assert/strict'),{performance}=require('node:perf_hooks');
const {decode}=require('./frame-stream.cjs');
const xi=path.resolve(process.argv[2]||'build/xi-direct/reverse_pc');
const output=path.resolve(process.argv[3]||'build/xi-direct/evidence');
const source=fs.readFileSync('experiments/xi-render/super-road-direct.xi','utf8');
const sourceFile='experiments/xi-render/super-road-direct.xi';
fs.mkdirSync(output,{recursive:true});
const tmp=fs.mkdtempSync(path.join(os.tmpdir(),'xi-frame-serve-'));
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const med=a=>a.slice().sort((a,b)=>a-b)[Math.floor(a.length/2)];
const paletteBase=[[16,41,75],[47,92,49],[103,94,77],[48,54,62],[224,223,204],[242,190,55]];
const palette=Array.from({length:96},(_,code)=>{
 const cls=code>>4,shade=code&15,base=paletteBase[cls];
 const mod=cls===0?Math.min(70,shade*4):cls===1?Math.min(18,shade):0;
 return Buffer.from(base.map(v=>Math.min(255,v+mod)));
});
function config(w,h,curve,phase){
 const b=Buffer.alloc(18);
 b.writeUInt32LE(w,0);b.writeUInt32LE(h,4);
 b.writeUInt32LE(0,8);b.writeUInt32LE(h,12);
 b[16]=curve;b[17]=phase;
 return b;
}
function oneShot(w,h,curve,phase,initial,i){
 const values=config(w,h,curve,phase),program=path.join(tmp,'program-'+(++i)+'-'+w+'.xi');
 const content='#!reverse-pc-machine-v1\n'+Array.from(values,(v,n)=>
  'store8 '+(200+n)+' '+v+'\n').join('')+source.slice(source.indexOf('\n')+1);
 fs.writeFileSync(program,content);
 const stateOut=path.join(tmp,'out-'+i+'.rvp');
 const begin=performance.now();
 const p=cp.spawnSync(xi,['run',program,initial,stateOut],{
  encoding:null,timeout:90000,maxBuffer:16*1024*1024});
 if(p.status!==0||p.error)throw Error('oneShot failed '+String(p.stderr).slice(-1800)+' '+p.error);
 const rgb=decode(p.stdout,{palette}).pixels;
 return {ms:performance.now()-begin,frame:p.stdout,rgb};
}
function service(program,initial){
 const process=cp.spawn(xi,['frame-serve',program,initial],{
   stdio:['pipe','pipe','pipe']});
 let pending=[],buffer=Buffer.alloc(0),size=-1,stderr='',closed=false;
 process.stderr.on('data',data=>{stderr+=data.toString('utf8');});
 process.stdout.on('data',part=>{
  buffer=Buffer.concat([buffer,part]);
  try{
   while(true){
    if(size<0){
     if(buffer.length<4)break;
     size=buffer.readUInt32LE(0);buffer=buffer.subarray(4);
     assert(size<=16*1024*1024,'Frame Stream response byte limit');
    }
    if(buffer.length<size)break;
    const frame=Buffer.from(buffer.subarray(0,size));
    buffer=buffer.subarray(size);size=-1;
    const waiter=pending.shift();
    assert(waiter,'unsolicited service frame');
    waiter.resolve({frame,ms:performance.now()-waiter.time});
   }
  }catch(error){
   for(const w of pending.splice(0))w.reject(error);
   process.kill();
  }
 });
 process.on('exit',(code)=>{
  closed=true;
  for(const w of pending.splice(0))
   w.reject(Error('XI service exited '+code+' '+stderr.slice(-1500)));
 });
 process.on('error',(error)=>{
  for(const w of pending.splice(0))w.reject(error);
 });
 return {
  command(buffer){
   if(closed)throw Error('service is closed');
   return new Promise((resolve,reject)=>{
    pending.push({resolve,reject,time:performance.now()});
    process.stdin.write(buffer);
   });
  },
  async finish(){
   if(closed)return;
   await new Promise((resolve,reject)=>{
    process.once('exit',code=>code===0?resolve():reject(Error('frame-serve exit '+code+' '+stderr)));
    process.stdin.end(Buffer.from([0x51]));
   });
  },
  getStderr:()=>stderr
 };
}
const result={test:'Persistent XI frame service and direct XFS1',
 scopes:'same XI-authored procedural road; host is only mailbox and RGB presentation',
 benchmark:'end-to-end host wall times incl 18-byte XI mailbox update, XFS1 frame, materialization and process startup for one-shot',
 scenes:[],passed:false};
async function main(){
 let svc;
 try{
  const state=path.join(tmp,'initial.rvp');
  const init=cp.spawnSync(xi,['init',state],{encoding:'utf8'});
  assert.equal(init.status,0,String(init.stderr));
  const before=sha(fs.readFileSync(state));
  const compiled=path.join(tmp,'road-direct.rxe');
  const packaged=cp.spawnSync(xi,['compile',sourceFile,compiled,'SUPER ROAD STREAM'],{encoding:'utf8'});
  assert.equal(packaged.status,0,String(packaged.stderr));
  svc=service(compiled,state); // prove RXE binary machine input is equally supported
  let counter=0;
  for(const [w,h,curve,phase] of [[1280,720,178,25],[1920,1080,175,17],[3840,2160,155,19]]){
   const old=oneShot(w,h,curve,phase,state,counter++);
   const packet=Buffer.concat([Buffer.from([0x55]),config(w,h,curve,phase)]);
   const setup=await svc.command(packet);assert.equal(setup.frame.length,0,'mailbox ack');
   const seen=await svc.command(Buffer.from([0x46]));
   assert(seen.frame.equals(old.frame),'compiled service frame differs from XI source');
   const pixels=decode(seen.frame,{palette}).pixels;
   assert(pixels.equals(old.rgb),'persistent XI service visual mismatch');
   const oneShotMs=[],persistentMs=[],persistentStaticMs=[];
   for(let i=0;i<7;i++){
    const change=phase+i%2,brightness=curve+i%3;
    const one=oneShot(w,h,brightness,change,state,counter++);
    oneShotMs.push(Number(one.ms.toFixed(4)));
    const begin=performance.now();
    const ack=await svc.command(Buffer.concat([Buffer.from([0x55]),config(w,h,brightness,change)]));
    assert.equal(ack.frame.length,0);
    const reply=await svc.command(Buffer.from([0x46]));
    const rgb=decode(reply.frame,{palette}).pixels;
    assert(rgb.equals(one.rgb),'changing XI mailbox changed road equation');
    persistentMs.push(Number((performance.now()-begin).toFixed(4)));
    const tic=performance.now();
    const repeat=await svc.command(Buffer.from([0x46]));
    const identical=decode(repeat.frame,{palette}).pixels;
    assert(identical.equals(rgb),'static frame nondeterminism');
    persistentStaticMs.push(Number((performance.now()-tic).toFixed(4)));
   }
   const row={width:w,height:h,pixels:w*h,oneShotMedianMs:Number(med(oneShotMs).toFixed(4)),
    persistentDynamicMedianMs:Number(med(persistentMs).toFixed(4)),
    persistentStaticMedianMs:Number(med(persistentStaticMs).toFixed(4)),
    dynamicSpeedup:Number((med(oneShotMs)/med(persistentMs)).toFixed(2)),
    staticSpeedup:Number((med(oneShotMs)/med(persistentStaticMs)).toFixed(2)),
    binaryBytes:old.frame.length,rgbSha256:sha(old.rgb),
    controlBytesPerFrame:19};
   result.scenes.push(row);
   console.log('XI_PERSISTENT_FRAME_EXACT_OK',w,h,
    'oneshot',row.oneShotMedianMs,'dynamic',row.persistentDynamicMedianMs,
    'static',row.persistentStaticMedianMs,'speedup',row.dynamicSpeedup);
  }
  await svc.finish();
  assert.equal(sha(fs.readFileSync(state)),before,'server changed original RVPC2 file');
  result.passed=true;
  fs.writeFileSync(path.join(output,'frame-serve-results.json'),JSON.stringify(result,null,2)+'\n');
  console.log('XI_FRAME_SERVE_ALL_OK scenes='+result.scenes.length+' originalRVPC2=untouched');
 }catch(e){
  result.error=String(e.stack||e);
  fs.writeFileSync(path.join(output,'frame-serve-failure.json'),JSON.stringify(result,null,2)+'\n');
  console.error(result.error);process.exitCode=1;
  if(svc)try{await svc.finish();}catch{}
 }finally{fs.rmSync(tmp,{recursive:true,force:true});}
}
main();
