#!/usr/bin/env node
'use strict';
// This is a *second*, distinct hypothesis: XI publishes compact row intervals;
// an ordinary host decoder expands them to a framebuffer. Not 100% XI pixels.
const fs=require('node:fs'),path=require('node:path'),os=require('node:os');
const cp=require('node:child_process'),crypto=require('node:crypto');
const assert=require('node:assert/strict'),{performance}=require('node:perf_hooks');
const xiExe=path.resolve(process.argv[2]||'build/xi-render/reverse_pc');
const nativeExe=path.resolve(process.argv[3]||'build/xi-render/xrender-oracle');
const out=path.resolve(process.argv[4]||'build/xi-render/evidence');
const spanSource=path.resolve('experiments/xi-render/span-frame.xi');
const temp=fs.mkdtempSync(path.join(os.tmpdir(),'xi-render-span-'));
fs.mkdirSync(out,{recursive:true});
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const med=v=>v.slice().sort((a,b)=>a-b)[Math.floor(v.length/2)];
const specs=[[96,48],[1280,720],[1920,1080]];
const result={hypothesis:'Compact XI row spans and host expansion can beat the existing native X Render on two planar triangles',
  limits:'not a full XI renderer, no reflections/PBR, no GPU, favorable special-case algorithm',
  cpu:os.cpus()[0]?.model,node:process.version,machineStepBudget:1000000,
  sizes:specs,runs:[]};
function run(exe,args,{binary=false,timeout=100000}={}){
  const start=performance.now();
  const p=cp.spawnSync(exe,args,{encoding:binary?null:'utf8',timeout,maxBuffer:24*1024*1024});
  const ms=performance.now()-start;
  if(p.status!==0||p.error)
    throw Error('failed '+exe+' code='+p.status+' '+String(p.stderr).slice(-1800)+' '+p.error);
  return {out:p.stdout,ms};
}
function prepare(w,h){
  const state=path.join(temp,'init-'+w+'.rvp');
  const configured=path.join(temp,'configured-'+w+'.rvp');
  const src=path.join(temp,'dimensions-'+w+'.xi');
  const bytes=[w&255,(w>>8)&255,h&255,(h>>8)&255];
  fs.writeFileSync(src,'#!reverse-pc-machine-v1\n'+bytes.map((v,i)=>'store8 '+(200+i)+' '+v+'\n').join('')+'halt\n');
  run(xiExe,['init',state]);
  run(xiExe,['run',src,state,configured]);
  return configured;
}
function parse(text,w,h){
  const data=text.trim().split('\n').filter(Boolean).map(row=>JSON.parse(row));
  assert.equal(data.length,4*h,'four spans registers per row');
  const frame=Buffer.alloc(w*h);
  for(let y=0;y<h;y++){
    const a=data.slice(4*y,4*y+4);
    assert.deepEqual(a.map(r=>r.register),['r12','r13','r14','r15']);
    a.forEach(row=>assert.equal(row.type,'register'));
    const [backL,backR,frontL,frontR]=a.map(r=>r.value);
    for(const [l,r,value] of [[backL,backR,2],[frontL,frontR,3]]){
      if(l===-1&&r===-1)continue;
      assert(Number.isInteger(l)&&Number.isInteger(r)&&l>=0&&l<=r&&r<w,'invalid XI clip interval');
      frame.fill(value,y*w+l,y*w+r+1);
    }
  }
  return frame;
}
function edge(a,b,p){return (b[0]-a[0])*(p[1]-a[1])-(b[1]-a[1])*(p[0]-a[0]);}
function trueClass(x,y,w,h){
  const p=[x+.5,y+.5];
  const rear=[[w/8,h/8],[7*w/8,h/8],[w/2,7*h/8]];
  const front=[[w/4,h/3],[3*w/4,h/3],[w/2,5*h/6]];
  const inside=v=>{
    const shifted=v.map(q=>[q[0]+.2,q[1]+.1]);
    return shifted.every((a,i)=>edge(a,shifted[(i+1)%3],p)>=0);
  };
  return inside(front)?3:inside(rear)?2:0;
}
function independent(frame,w,h){
  for(let y=0;y<h;y++)for(let x=0;x<w;x++){
    const expected=trueClass(x,y,w,h),actual=frame[y*w+x];
    if(actual!==expected)throw Error('independent geometry mismatch at '+x+','+y+': got '+actual+' expected '+expected);
  }
}
function verifyEqual(a,b,w,h){
  assert.equal(a.length,w*h);assert.equal(b.length,w*h);
  if(a.equals(b))return;
  for(let i=0;i<a.length;i++)if(a[i]!==b[i])
    throw Error('XI vs X Render pixel mismatch at '+(i%w)+','+Math.floor(i/w)+' XI='+a[i]+' native='+b[i]);
}
try{
  for(const [w,h] of specs){
    const state=prepare(w,h),dest=path.join(temp,'out-'+w+'.rvp');
    const xiResult=run(xiExe,['run',spanSource,state,dest]);
    const spanBytes=parse(xiResult.out,w,h);
    const nativeResult=run(nativeExe,[String(w),String(h),'binary'],{binary:true});
    verifyEqual(spanBytes,nativeResult.out,w,h);
    independent(spanBytes,w,h);
    const row={width:w,height:h,pixels:w*h,compressedSource:'XI row intervals',
      xiSpanCount:4*h,xiOutputBytes:Buffer.byteLength(xiResult.out,'utf8'),
      frameBytes:spanBytes.length,sha256:sha(spanBytes),xiMs:[],nativeMs:[]};
    // Validate once, then include decoding cost in every XI timed sample.
    for(let k=0;k<3;k++){
      const order=k%2?['native','xi']:['xi','native'];
      for(const name of order){
        if(name==='native'){
          const p=run(nativeExe,[String(w),String(h),'binary'],{binary:true});
          verifyEqual(spanBytes,p.out,w,h);
          row.nativeMs.push(Number(p.ms.toFixed(3)));
        }else{
          const start=performance.now();
          const p=run(xiExe,['run',spanSource,state,path.join(temp,'xi-'+w+'-'+k+'.rvp')]);
          const decoded=parse(p.out,w,h);
          const elapsed=performance.now()-start;
          verifyEqual(spanBytes,decoded,w,h);
          row.xiMs.push(Number(elapsed.toFixed(3)));
        }
      }
    }
    row.nativeMedianMs=med(row.nativeMs);
    row.xiMedianMs=med(row.xiMs);
    row.xiOverNative=Number((row.xiMedianMs/row.nativeMedianMs).toFixed(2));
    result.runs.push(row);
    console.log('XI_SPAN_EXACT_OK',w,h,'pixels',row.pixels,
       'XI plus host decode ms',row.xiMedianMs,'native ms',row.nativeMedianMs,
       'intervals',row.xiSpanCount,'sha256',row.sha256);
  }
  result.conclusion='Measured compact rule plus presenter: XI/native ratios reported. This is not a language-only or end-to-end Android speed result.';
  fs.writeFileSync(path.join(out,'span-results.json'),JSON.stringify(result,null,2)+'\n');
  console.log('XI_SPAN_A_B_RESULT',JSON.stringify({ratios:result.runs.map(r=>r.xiOverNative),
    fullHDTested:true,comparison:'XI rules plus host decoder vs native X Render per pixel'}));
}catch(error){
  result.error=String(error.stack||error);
  fs.writeFileSync(path.join(out,'span-failure.json'),JSON.stringify(result,null,2)+'\n');
  console.error(result.error);process.exitCode=1;
}finally{fs.rmSync(temp,{recursive:true,force:true});}
