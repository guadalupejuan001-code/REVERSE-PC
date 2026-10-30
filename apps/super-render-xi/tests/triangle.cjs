#!/usr/bin/env node
'use strict';
// Test/oracle only. General triangle intersections are authored in super-triangle.xi.
// Host submits scene bytes, checks scanline descriptors and presents them.
const fs=require('node:fs'),path=require('node:path'),os=require('node:os');
const cp=require('node:child_process'),assert=require('node:assert/strict');
const crypto=require('node:crypto'),{performance}=require('node:perf_hooks');
const exe=path.resolve(process.argv[2]||'build/xi-render/reverse_pc');
const out=path.resolve(process.argv[3]||'build/xi-render/evidence');
const xi=fs.readFileSync('apps/super-render-xi/triangle.xi','utf8');
assert(xi.startsWith('#!reverse-pc-machine-v1\n'));
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'super-xi-triangle-'));
fs.mkdirSync(out,{recursive:true});
const init=path.join(dir,'initial.rvp');let requestId=0;
function run(args,timeout=60000){
 const start=performance.now();
 const p=cp.spawnSync(exe,args,{encoding:'utf8',timeout,maxBuffer:6*1024*1024});
 if(p.status!==0||p.error)throw Error('XI triangle failed '+args.join(' ')+' '+String(p.stderr).slice(-1000)+' '+p.error);
 return {out:p.stdout,ms:performance.now()-start};
}
const enc32=n=>[0,8,16,24].map(i=>Math.floor(n/2**i)%256);
function command(w,h,start,count,triangle,rxefile=null){
 const verts=triangle.p.flat();
 const values=[...enc32(w),...enc32(h),...enc32(start),...enc32(count),
   ...verts.flatMap(v=>enc32(v+2147483648)),triangle.depth,triangle.mat];
 assert.equal(values.length,42);
 const preamble='#!reverse-pc-machine-v1\n'+
   values.map((v,i)=>'store8 '+(200+i)+' '+v+'\n').join('')+'halt\n';
 const config=path.join(dir,'config-'+(++requestId)+'.xi');
 const output=path.join(dir,'out-'+requestId+'.rvp');
 fs.writeFileSync(config,preamble);
 if(rxefile){
  const state=path.join(dir,'input-'+requestId+'.rvp');
  run(['run',config,init,state]);
  return run(['run',rxefile,state,output]);
 }
 const joined='#!reverse-pc-machine-v1\n'+preamble.slice(preamble.indexOf('\n')+1,-5)+
   xi.slice(xi.indexOf('\n')+1);
 const combined=path.join(dir,'source-'+requestId+'.xi');
 fs.writeFileSync(combined,joined);
 return run(['run',combined,init,output]);
}
function ceilDiv(n,d){
 assert(d>0n);
 return n>=0n?(n+d-1n)/d:n/d;
}
function expected(w,h,y,triangle){
 const intersections=[];
 for(let k=0;k<3;k++){
  const [xa,ya]=triangle.p[k],[xb,yb]=triangle.p[(k+1)%3];
  if(!(y>=Math.min(ya,yb)&&y<Math.max(ya,yb)))continue;
  const dy=BigInt(yb-ya),dx=BigInt(xb-xa);
  let n=BigInt(2*xa-1)*dy+BigInt(2*y+1-2*ya)*dx;
  let d=2n*dy;
  if(d<0n){n=-n;d=-d;}
  intersections.push(ceilDiv(n,d));
 }
 if(intersections.length<2)return [y,-1,-1,triangle.depth,triangle.mat];
 const lower=intersections.reduce((a,b)=>a<b?a:b);
 const upper=intersections.reduce((a,b)=>a>b?a:b)-1n;
 const lo=Number(lower<0n?0n:lower);
 const hi=Number(upper>BigInt(w-1)?BigInt(w-1):upper);
 return lo>hi?[y,-1,-1,triangle.depth,triangle.mat]:
   [y,lo,hi,triangle.depth,triangle.mat];
}
function parse(raw,start,count,w,h,t){
 const lines=raw.trim().split('\n');
 assert.equal(lines.length,count*5,'five XI observations per scanline');
 const rows=[];
 for(let k=0;k<count;k++){
  const records=lines.slice(k*5,k*5+5).map(text=>JSON.parse(text));
  assert.deepEqual(records.map(r=>r.register),['r10','r12','r13','r2','r3']);
  assert(records.every(r=>r.type==='register'&&Number.isSafeInteger(r.value)));
  const actual=records.map(r=>r.value);
  assert.deepEqual(actual,expected(w,h,start+k,t),'triangle scanline mismatch at y='+(start+k));
  rows.push(actual);
 }
 return rows;
}
function bruteInterior(w,h,t,rows){
 let checked=0;
 for(let y=0;y<h;y++){
  const [,,end]=rows[y];const start=rows[y][1];
  for(let x=0;x<w;x++){
   const e=t.p.map((v,i)=>{
    const next=t.p[(i+1)%3];
    return (next[0]-v[0])*(2*y+1-2*v[1])-
           (next[1]-v[1])*(2*x+1-2*v[0]);
   });
   if(e.some(v=>v===0))continue; // exact boundary belongs to half-open raster convention.
   const hit=e.every(v=>v>0)||e.every(v=>v<0);
   assert.equal(start>=0&&x>=start&&x<=end,hit,'strict interior test at '+x+','+y);
   checked++;
  }
 }
 return checked;
}
function full(w,h,t,chunk,archive){
 const rows=[],hash=crypto.createHash('sha256');
 let ms=0;
 for(let y=0;y<h;y+=chunk){
  const n=Math.min(chunk,h-y),p=command(w,h,y,n,t);
  ms+=p.ms;
  const observed=parse(p.out,y,n,w,h,t);
  for(const row of observed){rows.push(row);hash.update(row.join(',')+'\n');}
 }
 assert.equal(rows.length,h);
 if(archive)fs.writeFileSync(path.join(out,archive),rows.map(x=>x.join(' ')).join('\n')+'\n');
 return {width:w,height:h,rows,sha256:hash.digest('hex'),xiMs:Number(ms.toFixed(3)),
   chunks:Math.ceil(h/chunk)};
}
const samples=[
 {p:[[22,12],[126,21],[63,84]],depth:4,mat:3},
 {p:[[126,21],[22,12],[63,84]],depth:4,mat:3},
 {p:[[5,30],[5,76],[53,48]],depth:7,mat:4},
 {p:[[30,90],[135,90],[70,-36]],depth:9,mat:12},
 {p:[[-110,-25],[-70,30],[-3,45]],depth:2,mat:5},
 {p:[[0,0],[79,0],[40,81]],depth:0,mat:0},
 {p:[[30,30],[90,90],[150,150]],depth:15,mat:22},
 {p:[[123,80],[-21,-8],[95,-45]],depth:3,mat:16}
];
let seed=20261029;
function rand(){seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed/4294967296;}
for(let n=0;n<12;n++){
 samples.push({p:Array.from({length:3},()=>[Math.floor(rand()*240)-40,Math.floor(rand()*170)-40]),
   depth:Math.floor(rand()*256),mat:Math.floor(rand()*256)});
}
const results={renderer:'SUPER RENDER XI - exact triangle scanlines',
  geometryAuthority:'XI integer edge intersections and clipped row bounds',
  limits:'each program handles one arbitrary primitive; any number of objects may be streamed across calls',
  tests:[],compiledRxe:false};
try{
 run(['init',init]);
 const before=crypto.createHash('sha256').update(fs.readFileSync(init)).digest('hex');
 for(let i=0;i<samples.length;i++){
  const t=samples[i];
  const first=full(160,90,t,31,i===0?'xi-triangle-sample.txt':null);
  const second=full(160,90,t,48,null);
  assert.equal(first.sha256,second.sha256,'triangle chunk divergence');
  const checked=bruteInterior(160,90,t,first.rows);
  results.tests.push({sample:i,sha256:first.sha256,independentPixelsChecked:checked,
    firstBatchMs:first.xiMs,reverseWinding:i===1});
 }
 for(const [w,h,t,chunk] of [
  [1280,720,{p:[[wFix(1280,.25),100],[wFix(1280,.80),120],[640,690]],depth:10,mat:6},160],
  [3840,2160,{p:[[600,20],[3450,110],[1830,2020]],depth:14,mat:8},256],
  [15360,8640,{p:[[3000,120],[12300,900],[7000,8300]],depth:21,mat:10},256]
 ]){
  const first=full(w,h,t,chunk,null);
  results.tests.push({sample:w+'x'+h,sha256:first.sha256,xiMs:first.xiMs,
    chunks:first.chunks,rows:first.rows.length,pixelsLogical:w*h});
  console.log('SUPER_TRIANGLE_XI_OK',w,h,'XI_ms',first.xiMs,'sha',first.sha256.slice(0,16));
 }
 const compiled=path.resolve('build/xi-render/executable/SUPER-TRIANGLE-XI.rxe');
 assert(fs.statSync(compiled).size>0);
 const fromRxe=command(160,90,18,27,samples[0],compiled);
 const fromXi=command(160,90,18,27,samples[0]);
 assert.deepEqual(parse(fromRxe.out,18,27,160,90,samples[0]),
   parse(fromXi.out,18,27,160,90,samples[0]),'RXE/XI triangle mismatch');
 results.compiledRxe=true;
 assert.equal(before,crypto.createHash('sha256').update(fs.readFileSync(init)).digest('hex'),
    'XI scene evaluation changed source state');
 results.allPassed=true;
 fs.writeFileSync(path.join(out,'super-triangle-results.json'),JSON.stringify(results,(key,value)=>key==='rows'?undefined:value,2)+'\n');
 console.log('SUPER_TRIANGLE_XI_ALL_OK triangles='+samples.length+
   ' independentPixels='+results.tests.reduce((n,t)=>n+(t.independentPixelsChecked||0),0)+
   ' XRERuntime=yes');
}catch(e){
 results.error=String(e.stack||e);
 fs.writeFileSync(path.join(out,'super-triangle-failure.json'),JSON.stringify(results,(key,value)=>key==='rows'?undefined:value,2)+'\n');
 console.error(results.error);process.exitCode=1;
}finally{fs.rmSync(dir,{recursive:true,force:true});}
function wFix(w,f){return Math.round(w*f);}
