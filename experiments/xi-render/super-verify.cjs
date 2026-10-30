#!/usr/bin/env node
'use strict';
// SUPER RENDER XI: external test/presentation adapter only.
// The sole road projection/region generator is super-render.xi.
// JS never feeds coordinates or pixels into XI: it only writes configuration,
// checks output independently, expands immutable spans, and records evidence.
const fs=require('node:fs'),path=require('node:path'),os=require('node:os');
const cp=require('node:child_process'),crypto=require('node:crypto');
const assert=require('node:assert/strict'),{performance}=require('node:perf_hooks');
const exe=path.resolve(process.argv[2]||'build/xi-render/reverse_pc');
const destination=path.resolve(process.argv[3]||'build/xi-render/evidence');
const source=fs.readFileSync(path.resolve('experiments/xi-render/super-render.xi'),'utf8');
assert(source.startsWith('#!reverse-pc-machine-v1\n'),'must be a genuine XI Machine v1 program');
fs.mkdirSync(destination,{recursive:true});
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'super-render-xi-'));
const initial=path.join(dir,'initial.rvp');
const startMem=0;let requests=0;
const tmpHash=crypto.createHash('sha256'),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
function command(args,timeout=60000){
 const start=performance.now();
 const p=cp.spawnSync(exe,args,{encoding:'utf8',timeout,maxBuffer:5*1024*1024});
 if(p.status!==0||p.error)throw Error('XI failed '+args.join(' ')+' '+String(p.stderr).slice(-1600)+' '+String(p.error||''));
 return {output:p.stdout,ms:performance.now()-start};
}
const payload=v=>[0,8,16,24].map(n=>Math.floor(v/Math.pow(2,n))%256);
function request(w,h,start,count,curve,phase){
 const values=[...payload(w),...payload(h),...payload(start),...payload(count),curve,phase];
 const prefix=values.map((v,i)=>'store8 '+(200+i)+' '+v+'\n').join('');
 const xi='#!reverse-pc-machine-v1\n'+prefix+source.slice(source.indexOf('\n')+1);
 const program=path.join(dir,'frame-'+(++requests)+'.xi');
 const next=path.join(dir,'result-'+requests+'.rvp');
 fs.writeFileSync(program,xi);
 return command(['run',program,initial,next]);
}
function calc(w,h,y,curveByte,phase){
 const horizon=Math.max(1,Math.trunc(h*44/100));
 if(y<horizon)return [y,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,Math.trunc(y*12/horizon),0];
 const t=y-horizon+1;
 const half=Math.max(1,Math.trunc(w/75))+Math.trunc((t*w)/(h*4));
 const norm=Math.trunc(t*1000/h);
 const shift=Math.trunc((norm*norm*(curveByte-128)*w)/256000000);
 const center=Math.trunc(w/2)+shift;
 const left=Math.max(0,center-half),right=Math.min(w-1,center+half);
 const shoulder=Math.trunc(w/150)+Math.trunc((t*w)/(h*20));
 const line=Math.max(1,Math.trunc(w/640)),mid=Math.trunc(line/2);
 return [y,1,Math.max(0,left-shoulder),Math.min(w-1,right+shoulder),
  left,right,left,left+line,right-line,right,center-mid,center+mid,
  Math.trunc(t*12/h),((y+phase)%48)<22?1:0];
}
const protocol=['r7','r9','r11','r11','r13','r14','r13','r15','r15','r14','r9','r9','r15','r10'];
function parse(text,start,count,w,h,curve,phase){
 const lines=text.trim().split('\n');
 assert.equal(lines.length,14*count,'14 XI scalar descriptors per row, no missing or duplicate rows');
 const rows=[];
 for(let n=0;n<count;n++){
  const got=[];
  for(let j=0;j<14;j++){
   const row=JSON.parse(lines[n*14+j]);
   assert.equal(row.type,'register');assert.equal(row.register,protocol[j],'XI register provenance');
   assert(Number.isSafeInteger(row.value),'XI 64-bit field beyond JS exact conversion');
   got.push(row.value);
  }
  const expected=calc(w,h,start+n,curve,phase);
  assert.deepEqual(got,expected,'XI projected span differs at row '+(start+n));
  rows.push(got);
 }
 return rows;
}
function fill(buffer,a,b,value){
 if(a===-1||b===-1)return;
 assert(a>=0&&b>=a&&b<buffer.length,'renderer published out-of-frame span');
 buffer.fill(value,a,b+1);
}
function rowPixels(w,row){
 const [,base,shoulderL,shoulderR,roadL,roadR,leftL,leftR,rightL,rightR,midL,midR,,dash]=row;
 const result=Buffer.alloc(w,base===0?0:1);
 if(base===1){
  fill(result,shoulderL,shoulderR,2);
  fill(result,roadL,roadR,3);
  fill(result,leftL,leftR,4);
  fill(result,rightL,rightR,4);
  if(dash)fill(result,midL,midR,5);
 }
 return result;
}
const palette=[[16,41,75],[47,92,49],[103,94,77],[48,54,62],[224,223,204],[242,190,55]];
function rgb(out,w,y,row,pixels){
 for(let x=0;x<w;x++){
  const id=pixels[x],shade=row[12],v=palette[id],offset=(y*w+x)*3;
  const modifier=id===0?Math.min(70,shade*4):id===1?Math.min(18,shade):0;
  out[offset]=Math.min(255,v[0]+modifier);
  out[offset+1]=Math.min(255,v[1]+modifier);
  out[offset+2]=Math.min(255,v[2]+modifier);
 }
}
function render(w,h,curve,phase,chunk,savePreview=false){
 const signature=crypto.createHash('sha256');
 const body=crypto.createHash('sha256');
 const color=savePreview?Buffer.alloc(w*h*3):null;
 let ms=0,count=0,xiOutputBytes=0,foreground=0;
 for(let start=0;start<h;start+=chunk){
  const lines=Math.min(chunk,h-start),res=request(w,h,start,lines,curve,phase);
  ms+=res.ms;xiOutputBytes+=Buffer.byteLength(res.output);
  const rows=parse(res.output,start,lines,w,h,curve,phase);
  for(const row of rows){
   signature.update(row.join(',')+'\n');
   const pixels=rowPixels(w,row);
   body.update(pixels);
   if(savePreview)rgb(color,w,row[0],row,pixels);
   if(row[1])foreground+=row[5]-row[4]+1;
   count++;
  }
 }
 assert.equal(count,h,'frame must cover every scanline');
 if(savePreview){
  const header=Buffer.from('P6\n'+w+' '+h+'\n255\n');
  fs.writeFileSync(path.join(destination,'super-render-xi-'+w+'x'+h+'.ppm'),Buffer.concat([header,color]));
 }
 return {width:w,height:h,pixels:w*h,curve,phase,chunk,rows:count,xiTransactions:Math.ceil(h/chunk),
  xiScalarDescriptors:h*14,xiOutputBytes,xiTimeMs:Number(ms.toFixed(3)),signature:signature.digest('hex'),
  frameSha256:body.digest('hex'),foreground};
}
const result={implementation:'SUPER RENDER XI v1',source:'XI Machine v1, 64-bit integer logic',
  architecture:'XI computes all geometry, horizon, curved road, shoulders, marks, shadows bands and dash phase; host only expands runs',
  testEnvironment:{platform:process.platform,arch:process.arch,cpu:os.cpus()[0]?.model,node:process.version},
  executionLimits:{existingInterpreterStepsPerCall:1000000,chunking:true,widthEncodingBits:32,
   output:'14 scalar descriptors per row, emitted in bounded streaming transactions'},
  scenarios:[],invalidTests:[],allPassed:false};
try{
 command(['init',initial]);
 const firstHash=sha(fs.readFileSync(initial));
 const cases=[
  {w:640,h:360,curve:128,phase:0,chunk:127,preview:false,repeat:31},
  {w:1280,h:720,curve:178,phase:25,chunk:128,preview:true,repeat:97},
  {w:1920,h:1080,curve:73,phase:91,chunk:192,preview:false},
  {w:3840,h:2160,curve:190,phase:5,chunk:192,preview:false},
  {w:7680,h:4320,curve:128,phase:34,chunk:256,preview:false,repeat:181},
  {w:15360,h:8640,curve:212,phase:227,chunk:256,preview:false}
 ];
 for(const x of cases){
  const trial=render(x.w,x.h,x.curve,x.phase,x.chunk,x.preview);
  if(x.repeat){
   const alt=render(x.w,x.h,x.curve,x.phase,x.repeat);
   assert.equal(trial.signature,alt.signature,'different chunk sizes changed XI geometry');
   assert.equal(trial.frameSha256,alt.frameSha256,'different chunk sizes changed framebuffer');
   trial.chunkInvariant=true;trial.alternateChunks=alt.xiTransactions;
  }
  result.scenarios.push(trial);
  console.log('SUPER_RENDER_XI_SCENE_OK',x.w+'x'+x.h,'chunks',trial.xiTransactions,
    'rows',trial.rows,'pixels',trial.pixels,'XI process ms',trial.xiTimeMs,
    'SHA',trial.frameSha256.slice(0,16),'chunkInvariant',!!trial.chunkInvariant);
 }
 const invalid=[
  [0,720,0,5],[1280,0,0,5],[1280,720,0,0],[1280,720,718,4]
 ];
 for(const [w,h,start,count] of invalid){
  const record=request(w,h,start,count,128,0);
  assert.deepEqual(JSON.parse(record.output.trim()),{type:'register',register:'r0',value:-999},
    'invalid viewport must reject before publishing any row');
  result.invalidTests.push({width:w,height:h,start,count,rejected:true});
 }
 assert.equal(firstHash,sha(fs.readFileSync(initial)),'immutable initial RVPC2 state was changed');
 result.allPassed=true;
 result.conclusion='Row complexity proportional to visible height; reusable chunk transactions remove single-call raster size caps. No hardware FPS or unlimited physical memory claim.';
 fs.writeFileSync(path.join(destination,'super-results.json'),JSON.stringify(result,null,2)+'\n');
 console.log('SUPER_RENDER_XI_ALL_OK scenarios='+result.scenarios.length+
   ' chunksIndependent=yes invalidWindows='+result.invalidTests.length+
   ' max='+cases[cases.length-1].w+'x'+cases[cases.length-1].h);
}catch(error){
 result.error=String(error.stack||error);
 fs.writeFileSync(path.join(destination,'super-failure.json'),JSON.stringify(result,null,2)+'\n');
 console.error(result.error);process.exitCode=1;
}finally{fs.rmSync(dir,{recursive:true,force:true});}
