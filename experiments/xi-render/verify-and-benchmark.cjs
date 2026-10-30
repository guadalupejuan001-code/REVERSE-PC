#!/usr/bin/env node
'use strict';
// Reproducible A/B benchmark. XI supplies the actual framebuffer; the
// independent oracle uses geometry, and native X Render uses existing API.
const fs=require('node:fs'),os=require('node:os'),cp=require('node:child_process');
const path=require('node:path'),assert=require('node:assert/strict');
const {performance}=require('node:perf_hooks');
const crypto=require('node:crypto');
const root=path.resolve('experiments/xi-render');
const xi=path.join(root,'triangle-frame.xi');
const xiExe=path.resolve(process.argv[2]||'build/xi-render/reverse_pc');
const nativeExe=path.resolve(process.argv[3]||'build/xi-render/xrender-oracle');
const out=path.resolve(process.argv[4]||'build/xi-render/evidence');
const folder=fs.mkdtempSync(path.join(os.tmpdir(),'xi-render-ab-'));
fs.mkdirSync(out,{recursive:true});
const sha=(b)=>crypto.createHash('sha256').update(b).digest('hex');
function execute(exe,args,options={}) {
  const tic=performance.now();
  const p=cp.spawnSync(exe,args,{encoding:'utf8',timeout:options.timeout||90000,maxBuffer:16*1024*1024});
  const elapsed=performance.now()-tic;
  return {code:p.status,stderr:p.stderr||'',stdout:p.stdout||'',ms:elapsed,error:p.error?String(p.error):''};
}
function requireSuccess(p,label){
  assert.equal(p.code,0,label+' '+p.error+' '+p.stderr.slice(-2400));
  return p;
}
function records(text,w,h){
  const rows=text.trim().split('\n').filter(Boolean).map(s=>JSON.parse(s));
  assert.equal(rows.length,w*h+1,'frame must expose every pixel + hash');
  const pixels=[];
  let hash=0;
  for(let i=0;i<w*h;i++){
    const line=rows[i];
    assert.equal(line.type,'register');
    assert.equal(line.register,'r12');
    assert([0,2,3].includes(line.value));
    pixels.push(line.value);
    hash=(hash*131+line.value)%1000000007;
  }
  assert.deepEqual(rows[w*h],{type:'register',register:'r14',value:hash});
  return {pixels,hash};
}
function edge(a,b,p){return (b[0]-a[0])*(p[1]-a[1])-(b[1]-a[1])*(p[0]-a[0]);}
function inside(t,x,y){
  const p=[x+.5,y+.5],a=t.map(v=>[v[0]+.2,v[1]+.1]);
  return a.every((v,i)=>edge(v,a[(i+1)%3],p)>=0);
}
function oracle(w,h){
  const a=[[w/8,h/8],[7*w/8,h/8],[w/2,7*h/8]],
        b=[[w/4,h/3],[3*w/4,h/3],[w/2,5*h/6]];
  const pixels=[];
  for(let y=0;y<h;y++)for(let x=0;x<w;x++)
    pixels.push(inside(b,x,y)?3:inside(a,x,y)?2:0);
  let hash=0;for(const n of pixels)hash=(hash*131+n)%1000000007;
  return {pixels,hash};
}
function image(pixels,w,h,dest){
  const data=Buffer.alloc(w*h*3),palette={0:[9,18,28],2:[34,107,68],3:[231,77,47]};
  for(let y=0;y<h;y++)for(let x=0;x<w;x++){
    const color=palette[pixels[y*w+x]];
    const index=((h-1-y)*w+x)*3;
    data[index]=color[0];data[index+1]=color[1];data[index+2]=color[2];
  }
  fs.writeFileSync(dest,Buffer.concat([Buffer.from('P6\n'+w+' '+h+'\n255\n'),data]));
}
const specs=[[48,24],[96,48]];
const result={hypothesis:'XI Machine v1 faster than existing native X Render for this same triangle scene',
  methodology:'two triangles, exactly matching framebuffer classes, cold CLI startup, RVPC2 state path for XI, serialized JSON pixels for both',
  os:process.platform,architecture:process.arch,cpu:os.cpus()[0]?.model,
  runtimeNode:process.version,maxXIInstructions:1000000,inputs:specs,tests:[],outsideScope:'GPU frames, HD rendering, multiple cars, physical Android performance'};
try{
  const init=(w,h)=>{
    const state=path.join(folder,'blank-'+w+'.rvp');
    const configured=path.join(folder,'configured-'+w+'.rvp');
    const source=path.join(folder,'configure-'+w+'.xi');
    fs.writeFileSync(source,'#!reverse-pc-machine-v1\nstore8 200 '+w+'\nstore8 201 '+h+'\nhalt\n');
    requireSuccess(execute(xiExe,['init',state]),'XI init');
    requireSuccess(execute(xiExe,['run',source,state,configured]),'XI scene configure');
    return configured;
  };
  for(const [w,h] of specs){
    const initial=init(w,h),oracleFrame=oracle(w,h),measurement={width:w,height:h,pixels:w*h,nativeMs:[],xiMs:[]};
    // First compare exact binary observed classes, then benchmark three cold
    // launch runs each, in alternate order to reduce thermal/scheduling bias.
    const firstXI=requireSuccess(execute(xiExe,['run',xi,initial,path.join(folder,'xi0-'+w+'.rvp')]),'XI image');
    const firstNative=requireSuccess(execute(nativeExe,[String(w),String(h)]),'X Render image');
    const observedXI=records(firstXI.stdout,w,h),observedNative=records(firstNative.stdout,w,h);
    assert.deepEqual(observedXI,oracleFrame,'XI pixels differ from independent triangle geometry');
    assert.deepEqual(observedNative,oracleFrame,'native X Render pixels differ from independent geometry');
    assert.equal(firstXI.stdout,firstNative.stdout,'XI and native JSON framebuffer output differ');
    assert.equal(sha(fs.readFileSync(initial)),sha(fs.readFileSync(initial)),'source state changed');
    image(observedXI.pixels,w,h,path.join(out,'xi-'+w+'x'+h+'.ppm'));
    measurement.frameHash=observedXI.hash;
    measurement.observationSha256=sha(firstXI.stdout);
    measurement.foreground=observedXI.pixels.filter(p=>p!==0).length;
    // Benchmark includes process startup, state load/commit for XI and JSON
    // serialization for both; not a pure per-pixel kernel speed claim.
    for(let repeat=0;repeat<3;repeat++){
      const order=repeat%2?['native','xi']:['xi','native'];
      for(const which of order){
        const p=which==='xi'
          ?execute(xiExe,['run',xi,initial,path.join(folder,'xi-'+w+'-'+repeat+'.rvp')])
          :execute(nativeExe,[String(w),String(h)]);
        requireSuccess(p,which+' benchmark');
        assert.equal(sha(p.stdout),measurement.observationSha256,which+' nondeterministic output');
        measurement[which==='xi'?'xiMs':'nativeMs'].push(Number(p.ms.toFixed(3)));
      }
    }
    const median=a=>a.slice().sort((a,b)=>a-b)[Math.floor(a.length/2)];
    measurement.nativeMedianMs=median(measurement.nativeMs);
    measurement.xiMedianMs=median(measurement.xiMs);
    measurement.xiOverNative=Number((measurement.xiMedianMs/measurement.nativeMedianMs).toFixed(2));
    result.tests.push(measurement);
    console.log('XI_RENDER_EXACT_OK',w,h,'pixels',w*h,'hash',measurement.frameHash,
       'XI median ms',measurement.xiMedianMs,'native median ms',measurement.nativeMedianMs);
  }
  // Step-boundary evidence: a bigger 192x96 image must not be called HD.
  // It may succeed after optimization; record the actual outcome either way.
  const w=192,h=96,initial=init(w,h);
  const p=execute(xiExe,['run',xi,initial,path.join(folder,'xi-large.rvp')],{timeout:90000});
  result.largeCase={width:w,height:h,successful:p.code===0,
    rejectedByStepBudget:p.code!==0&&/instruction-step budget exceeded/.test(p.stderr),
    status:p.code,details:p.code===0?'rendered':p.stderr.slice(-500)};
  if(p.code===0){
    const parsed=records(p.stdout,w,h);
    assert.deepEqual(parsed,oracle(w,h),'XI large image geometry');
  }else if(!result.largeCase.rejectedByStepBudget){
    throw Error('192x96 failed for a reason other than the bounded XI step budget: '+p.stderr);
  }
  result.conclusion=result.tests.every(t=>t.xiMedianMs<t.nativeMedianMs)
    ?'hypothesis supported on tested host workloads (not evidence of HD)'
    :'hypothesis NOT supported on tested host workloads';
  fs.writeFileSync(path.join(out,'results.json'),JSON.stringify(result,null,2)+'\n');
  console.log('XI_RENDER_A_B_RESULT',JSON.stringify({conclusion:result.conclusion,ratios:result.tests.map(t=>t.xiOverNative),
    large:result.largeCase}));
}catch(e){
  result.error=String(e.stack||e);
  fs.writeFileSync(path.join(out,'failure.json'),JSON.stringify(result,null,2)+'\n');
  console.error(result.error);
  process.exitCode=1;
}finally{fs.rmSync(folder,{recursive:true,force:true});}
