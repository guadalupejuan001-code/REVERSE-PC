#!/usr/bin/env node
'use strict';
// XFS1 integration: authentic XI/QuantumRuntime, binary packet, strict parser,
// independent road oracle, full HD bitmap, chunk invariance, rollback.
const fs=require('node:fs'),path=require('node:path'),os=require('node:os'),
      cp=require('node:child_process'),crypto=require('node:crypto');
const assert=require('node:assert/strict');
const {performance}=require('node:perf_hooks');
const {decodeFrameStream,materializeFrameStreams}=require('./xi-frame-codec.cjs');
const exe=path.resolve(process.argv[2]||'build/xi-render/reverse_pc');
const out=path.resolve(process.argv[3]||'build/xi-render/evidence');
const script=path.resolve('experiments/xi-render/super-frame-stream.xi');
const folder=fs.mkdtempSync(path.join(os.tmpdir(),'xi-frame-stream-'));
fs.mkdirSync(out,{recursive:true});
const sha=x=>crypto.createHash('sha256').update(x).digest('hex');
const hex=s=>Number.parseInt(s,16)>>>0;
const COLORS={
 sky:hex('FF6B9FCE'),grass:hex('FF446D4B'),shoulder:hex('FF806547'),
 road:hex('FF303B46'),edge:hex('FFE3E0CB'),center:hex('FFF0CA4B')
};
let counter=0;
function run(args,{allowFail=false,timeout=90000}={}){
 const start=performance.now();
 const p=cp.spawnSync(exe,args,{encoding:'utf8',timeout,maxBuffer:24*1024*1024});
 const ms=performance.now()-start;
 if(!allowFail)assert.equal(p.status,0,'XI runtime failed: '+String(p.stderr).slice(-1500)+' '+p.error);
 return {stdout:p.stdout||'',stderr:p.stderr||'',status:p.status,ms};
}
const initial=path.join(folder,'initial.rvp');
const source=fs.readFileSync(script,'utf8');
assert(source.startsWith('#!reverse-pc-machine-v1\n'));
const bytes32=n=>[n&255,(n>>>8)&255,(n>>>16)&255,(n>>>24)&255];
function configured(w,h,start,rows,curve,phase){
 const input=path.join(folder,'config-'+(++counter)+'.xi');
 const dest=path.join(folder,'config-'+counter+'.rvp');
 const bytes=[...bytes32(w),...bytes32(h),...bytes32(start),...bytes32(rows),curve,phase];
 fs.writeFileSync(input,'#!reverse-pc-machine-v1\n'+bytes.map((n,i)=>'store8 '+(200+i)+' '+n+'\n').join('')+'halt\n');
 run(['run',input,initial,dest]);
 return dest;
}
function chunk(w,h,start,count,curve,phase,executable=script){
 const state=configured(w,h,start,count,curve,phase);
 const expectedState=sha(fs.readFileSync(state));
 const dest=path.join(folder,'output-'+(++counter)+'.rvp');
 const measurement=run(['run',executable,state,dest]);
 const decoded=decodeFrameStream(measurement.stdout);
 assert.equal(decoded.width,w);
 assert.equal(decoded.height,h);
 assert.equal(decoded.revision,1n);
 assert.equal(decoded.background,COLORS.sky);
 assert.equal(sha(fs.readFileSync(state)),expectedState,'XI read mutated its immutable state input');
 assert.equal(sha(fs.readFileSync(dest)),expectedState,'pure graphics program changed RVPC2');
 return {decoded,ms:measurement.ms,packetBytes:decoded.packet.length,
   transportBytes:Buffer.byteLength(measurement.stdout,'utf8'),
   output:measurement.stdout};
}
function scene(w,h,curve,phase,chunkSize,{preview=false,materialize=true}={}){
 const start=performance.now(),packets=[];
 let xiMs=0,wireBytes=0,records=0;
 for(let y=0;y<h;y+=chunkSize){
   const part=chunk(w,h,y,Math.min(chunkSize,h-y),curve,phase);
   packets.push(part.decoded);
   xiMs+=part.ms;wireBytes+=part.transportBytes;records+=part.decoded.recordCount;
 }
 const result={width:w,height:h,curve,phase,chunkSize,packetCount:packets.length,
   records,wireBytes,xiProcessMs:Number(xiMs.toFixed(3))};
 if(materialize){
   const v=materializeFrameStreams(packets,{maxPixels:2400000});
   const pixelBytes=Buffer.from(v.rgba.buffer,v.rgba.byteOffset,v.rgba.byteLength);
   result.frameSha256=sha(pixelBytes);
   result.frameBytes=pixelBytes.length;
   result.frame=v;
   for(let y=0;y<h;y++)for(let x=0;x<w;x++){
     const actual=v.rgba[y*w+x]>>>0,expected=oracle(w,h,y,x,curve,phase);
     if(actual!==expected)
       throw Error('XI frame mismatch '+w+'x'+h+' @('+x+','+y+'): got '+actual.toString(16)+' expect '+expected.toString(16));
   }
   if(preview){
     const ppm=Buffer.alloc(w*h*3);
     for(let y=0;y<h;y++)for(let x=0;x<w;x++){
       const argb=v.rgba[y*w+x]>>>0;
       const p=((h-1-y)*w+x)*3;
       ppm[p]=(argb>>>16)&255;ppm[p+1]=(argb>>>8)&255;ppm[p+2]=argb&255;
     }
     fs.writeFileSync(path.join(out,'frame-stream-'+w+'x'+h+'.ppm'),
       Buffer.concat([Buffer.from('P6\n'+w+' '+h+'\n255\n'),ppm]));
   }
 }
 result.elapsedMs=Number((performance.now()-start).toFixed(3));
 return result;
}
function oracle(w,h,y,x,curve,phase){
 const horizon=Math.max(1,Math.trunc(h*44/100));
 if(y<horizon)return COLORS.sky;
 const t=y-horizon+1,half=Math.max(1,Math.trunc(w/75))+Math.trunc(t*w/(h*4));
 const norm=Math.trunc(t*1000/h);
 const shift=Math.trunc(norm*norm*(curve-128)*w/256000000);
 const center=Math.trunc(w/2)+shift,left=Math.max(0,center-half);
 const right=Math.min(w-1,center+half);
 let color=COLORS.grass;
 if(left>right)return color;
 const shoulder=Math.trunc(w/150)+Math.trunc(t*w/(h*20));
 if(x>=Math.max(0,left-shoulder)&&x<=Math.min(w-1,right+shoulder))
   color=COLORS.shoulder;
 if(x>=left&&x<=right){
   color=COLORS.road;
   const mark=Math.max(1,Math.trunc(w/640));
   if((x>=left&&x<=Math.min(right,left+mark))||
      (x>=Math.max(left,right-mark)&&x<=right))color=COLORS.edge;
   if((y+phase)%48<22&&x>=Math.max(left,center-Math.trunc(mark/2))&&
      x<=Math.min(right,center+mark))color=COLORS.center;
 }
 return color;
}
function imageDigest(frame){
 const pixels=Buffer.from(frame.rgba.buffer,frame.rgba.byteOffset,frame.rgba.byteLength);
 return sha(pixels);
}
const result={abi:'XFS1',issuer:'XI Machine v1 source under QuantumRuntime',
    renderer:'XI-only scene rules; native transport encoding; host presentation',
    cpu:os.cpus()[0]?.model,node:process.version,caseResults:[],faults:[]};
function fails(program,message){
 const file=path.join(folder,'reject-'+(++counter)+'.xi');
 const output=path.join(folder,'reject-'+counter+'.rvp');
 fs.writeFileSync(file,'#!reverse-pc-machine-v1\n'+program+'\n');
 fs.writeFileSync(output,'immutable-target');
 const before=sha(fs.readFileSync(output)),sourceBefore=sha(fs.readFileSync(initial));
 const r=run(['run',file,initial,output],{allowFail:true});
 assert.notEqual(r.status,0,'invalid XI program accepted: '+message);
 assert.equal(sha(fs.readFileSync(output)),before,'frame failure replaced output checkpoint');
 assert.equal(sha(fs.readFileSync(initial)),sourceBefore,'frame failure modified input checkpoint');
 result.faults.push({case:message,rejected:true});
}
try{
 run(['init',initial]);
 // Negative inputs and transactional end-checks cannot produce partial output.
 for(const [name,program] of [
 ['span-before-begin','frame_span 0 0 1 4294967295 0'],
 ['zero-width','frame_begin 0 24 1 4294967295\nframe_end'],
 ['negative-revision','frame_begin 64 32 -1 4294967295\nframe_end'],
 ['span-outside','frame_begin 64 32 1 4294967295\nframe_span 32 0 10 4294967295 1\nframe_end'],
 ['reversed-span','frame_begin 64 32 1 4294967295\nframe_span 0 15 10 4294967295 1\nframe_end'],
 ['overflowing-tile','frame_begin 64 32 1 4294967295\nframe_tile 63 31 2 1 4294967295 1\nframe_end'],
 ['zero-tile','frame_begin 64 32 1 4294967295\nframe_tile 0 0 0 2 4294967295 1\nframe_end'],
 ['unterminated-frame','frame_begin 64 32 1 4294967295\nframe_span 0 0 10 4294967295 1\nhalt'],
 ['double-frame','frame_begin 64 32 1 4294967295\nframe_end\nframe_begin 64 32 2 4294967295\nframe_end'],
 ['duplicate-end','frame_begin 64 32 1 4294967295\nframe_end\nframe_end'],
 ['unknown-after-record','frame_begin 64 32 1 4294967295\nframe_span 1 0 30 4294967295 2\nnot_a_command']
 ])fails(program,name);
 // Material/depth precedence, tile clipping and atomic checksum.
 const simple=path.join(folder,'simple.xi'),simpleDest=path.join(folder,'simple.rvp');
 fs.writeFileSync(simple,'#!reverse-pc-machine-v1\n'+
  'frame_begin 64 32 7 4278190080\n'+
  'frame_tile 0 0 64 32 4278255360 9000\n'+
  'frame_span 10 10 20 4294901760 1000\n'+
  'frame_span 10 12 19 4278190335 2000\n'+
  'frame_span 10 13 18 4294967040 1000\n'+
  'frame_end\nhalt\n');
 const packet=decodeFrameStream(run(['run',simple,initial,simpleDest]).stdout);
 fs.writeFileSync(path.join(out,'frame-stream-packet.xfs1'),packet.packet);
 assert.equal(packet.recordCount,4);
 const pixels=materializeFrameStreams([packet],{maxPixels:2048});
 assert.equal(pixels.rgba[0]>>>0,4278255360);
 assert.equal(pixels.rgba[10*64+11]>>>0,4294901760);
 assert.equal(pixels.rgba[10*64+14]>>>0,4294967040);
 assert.equal(pixels.rgba[10*64+12]>>>0,4294901760);
 assert.equal(pixels.depth[10*64+14],1000);
 const damaged=Buffer.from(packet.packet);damaged[41]^=4;
 const event={type:'xi_frame_stream',format:'XFS1',encoding:'base64',
  width:64,height:32,revision:7,records:4,payload:damaged.toString('base64')};
 assert.throws(()=>decodeFrameStream(JSON.stringify(event)+'\n'),/checksum mismatch/);
 const cut={...event,payload:packet.packet.subarray(0,packet.packet.length-5).toString('base64')};
 assert.throws(()=>decodeFrameStream(JSON.stringify(cut)+'\n'),/count|length|trailing/i);
 result.integrity={checksumVerified:true,depthVerified:true,malformedRejected:true,rollback:true};
 // Compile the authentic XI program and check that RXE publishes identical XFS1.
 const compiled=path.join(folder,'SUPER-FRAME-STREAM-XI.rxe');
 run(['compile',script,compiled,'SUPER FRAME STREAM XI']);
 result.compiledRxeBytes=fs.statSync(compiled).size;
 const verify=chunk(640,360,120,24,178,25,compiled);
 const raw=chunk(640,360,120,24,178,25,script);
 assert.equal(verify.output,raw.output,'compiled RXE vs XI source differs');
 result.compiledRxeIdentical=true;
 for(const c of [
  {w:320,h:180,curve:128,phase:0,chunk:64,materialize:true},
  {w:640,h:360,curve:73,phase:9,chunk:120,materialize:true},
  {w:1280,h:720,curve:178,phase:25,chunk:128,materialize:true,preview:true},
  {w:1920,h:1080,curve:212,phase:72,chunk:192,materialize:true},
  {w:7680,h:4320,curve:190,phase:34,chunk:256,materialize:false}
 ]){
  const x=scene(c.w,c.h,c.curve,c.phase,c.chunk,
    {preview:!!c.preview,materialize:c.materialize});
  const {frame,...stored}=x;
  result.caseResults.push(stored);
  if(c.w===1280){
    const alternate=scene(c.w,c.h,c.curve,c.phase,97,{materialize:true});
    assert.equal(imageDigest(alternate.frame),x.frameSha256,'chunk boundaries changed visual result');
    stored.chunkInvariant=true;
  }
  console.log('XI_XFS1_FRAME_OK',c.w+'x'+c.h,'chunks',stored.packetCount,
   'records',stored.records,'transportBytes',stored.wireBytes,
   'sha256',stored.frameSha256||'descriptor-only');
 }
 // Logical 16K geometry: one viewport window, not a claim of 16K physical pixels.
 const logical=chunk(15360,8640,4210,128,212,227);
 result.logicalWindow={width:logical.decoded.width,height:logical.decoded.height,
  rows:128,records:logical.decoded.recordCount,bytes:logical.packetBytes};
 assert(logical.packetBytes<100000,'16K logical window unexpectedly dense');
 result.passed=true;
 fs.writeFileSync(path.join(out,'frame-stream-results.json'),JSON.stringify(result,null,2)+'\n');
 console.log('XI_FRAME_STREAM_V1_ALL_OK',JSON.stringify({frames:result.caseResults.length,
  faults:result.faults.length,byteTransport:true,rollback:true,
  compiledRxe:true,hd:true,fullHd:true,logical16k:true}));
}catch(error){
 result.passed=false;result.error=String(error.stack||error);
 fs.writeFileSync(path.join(out,'frame-stream-failure.json'),JSON.stringify(result,null,2)+'\n');
 console.error(result.error);process.exitCode=1;
}finally{fs.rmSync(folder,{recursive:true,force:true});}
