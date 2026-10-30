#!/usr/bin/env node
'use strict';
// This is only a test harness: 3D projection, clipping, raster setup and
// geometry state transitions are executed by original XI programs.
const fs=require('node:fs'),path=require('node:path'),os=require('node:os');
const cp=require('node:child_process'),assert=require('node:assert/strict');
const crypto=require('node:crypto'),{performance}=require('node:perf_hooks');
const exe=path.resolve(process.argv[2]||'build/xi-render/reverse_pc');
const out=path.resolve(process.argv[3]||'build/xi-render/evidence');
const project=path.resolve('build/xi-render/executable/SUPER-PROJECT-XI.rxe');
const triangle=path.resolve('build/xi-render/executable/SUPER-TRIANGLE-XI.rxe');
const original=fs.readFileSync('experiments/xi-render/super-project.xi','utf8');
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'super-xi-3d-'));
fs.mkdirSync(out,{recursive:true});
const enc32=n=>[0,8,16,24].map(i=>Math.floor(n/(2**i))%256);
const signed=n=>{assert(Number.isInteger(n)&&n>=-2147483648&&n<=2147483647);return enc32(n+2147483648);};
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
let requestId=0;
function spawn(args,success=true){
 const p=cp.spawnSync(exe,args,{encoding:'utf8',timeout:60000,maxBuffer:8*1024*1024});
 assert.equal(p.status===0,success,'XI result mismatch '+args.join(' ')+' '+p.stderr);
 return p.stdout;
}
function runProgram(source,state,body,expectedSuccess=true){
 const id=++requestId,dst=path.join(dir,'state-'+id+'.rvp');
 if(typeof body==='string'){
  const src=path.join(dir,'script-'+id+'.xi');
  fs.writeFileSync(src,body);source=src;
 }
 const output=spawn(['run',source,state,dst],expectedSuccess);
 return {path:dst,output};
}
function sceneState(initial,c){
 const {w,h,start,count,cam,focal,vertices,depth,mat}=c;
 const segments=[[200,enc32(w)],[204,enc32(h)],[208,enc32(start)],[212,enc32(count)],
   ...vertices.flatMap((v,i)=>v.map((scalar,j)=>[300+i*12+j*4,signed(scalar)])),
   ...cam.map((v,i)=>[336+i*4,signed(v)]),[348,enc32(focal)],
   [240,[depth]],[241,[mat]]];
 let text='#!reverse-pc-machine-v1\n';
 for(const [base,bytes] of segments)for(let i=0;i<bytes.length;i++)
  text+='store8 '+(base+i)+' '+bytes[i]+'\n';
 text+='halt\n';
 return runProgram('',initial,text).path;
}
function reader(){
 let s='#!reverse-pc-machine-v1\n';
 for(let vertex=0;vertex<3;vertex++){
  for(let axis=0;axis<2;axis++){
   const addr=216+vertex*8+axis*4;
   s+='load8 r0 '+addr+'\n';
   for(let i=1;i<4;i++)
    s+='load8 r1 '+(addr+i)+'\nmul r1 '+(256**i)+'\nadd r0 r1\n';
   s+='sub r0 2147483648\nprint r0\n';
  }
 }
 return s+'halt\n';
}
const inspect=reader();
function decode(output){
 const records=output.trim().split('\n').map(s=>JSON.parse(s));
 assert.equal(records.length,6);
 assert(records.every(r=>r.type==='register'&&r.register==='r0'));
 return [[records[0].value,records[1].value],
 [records[2].value,records[3].value],[records[4].value,records[5].value]];
}
function projected(c){
 return c.vertices.map(([x,y,z])=>{
  const d=c.cam[2]-z;
  assert(d>0);
  return [Math.trunc(c.w/2)+Math.trunc((x-c.cam[0])*c.focal/d),
   Math.trunc(c.h/2)-Math.trunc((y-c.cam[1])*c.focal/d)];
 });
}
const scenes=[
 {w:640,h:360,start:20,count:130,cam:[0,0,1000],focal:650,
  vertices:[[-200,-80,0],[210,-90,0],[0,130,250]],depth:7,mat:2},
 {w:1280,h:720,start:150,count:200,cam:[50,-15,1000],focal:800,
  vertices:[[-250,-120,100],[320,-140,150],[70,380,200]],depth:4,mat:13},
 {w:3840,h:2160,start:900,count:128,cam:[500,200,5000],focal:1900,
  vertices:[[-1600,-400,700],[2400,-450,500],[600,1800,1000]],depth:14,mat:43},
 {w:15360,h:8640,start:3300,count:180,cam:[0,0,4000],focal:7800,
  vertices:[[-1800,-1600,400],[2200,-1400,700],[500,2400,1000]],depth:24,mat:150}
];
const summary={module:'SUPER PROJECT XI',model:'XI-authored 3D perspective -> shared memory -> XI triangle',
  camera:'fixed forward -Z; signed32 vertices and independent integer oracle',
  results:[],atomicRollback:false,sourceMatchesBinary:false};
try{
 assert(fs.statSync(project).size>0&&fs.statSync(triangle).size>0);
 const initial=path.join(dir,'blank.rvp');spawn(['init',initial]);const baseline=sha(fs.readFileSync(initial));
 for(const [i,c] of scenes.entries()){
  const state=sceneState(initial,c);
  const compiled=runProgram(project,state);
  const observed=decode(runProgram('',compiled.path,inspect).output);
  const expected=projected(c);
  assert.deepEqual(observed,expected,'XI perspective differs from projection oracle');
  const source=runProgram('',state,original);
  assert.deepEqual(decode(runProgram('',source.path,inspect).output),observed,
    'compiled RXE differs from identical XI source');
  // The projected vertices must be executable as a triangle without a host
  // geometric conversion or rewriting the shared Ether state.
  const raster=runProgram(triangle,compiled.path);
  const lines=raster.output.trim().split('\n').map(row=>JSON.parse(row));
  assert.equal(lines.length,c.count*5,'projected triangle did not yield every row');
  assert(lines.every((v,j)=>v.register===['r10','r12','r13','r2','r3'][j%5]));
  assert(lines.every((v,j)=>j%5!==3||v.value===c.depth));
  assert(lines.every((v,j)=>j%5!==4||v.value===c.mat));
  const hits=lines.filter((v,j)=>j%5===1&&v.value>=0).length;
  summary.results.push({dimensions:c.w+'x'+c.h,projected:observed,
    rowsRasterized:c.count,visibleRows:hits,material:c.mat,depth:c.depth,
    stateSha256:sha(fs.readFileSync(compiled.path))});
  console.log('SUPER_PROJECT_XI_OK',c.w+'x'+c.h,'p',JSON.stringify(observed),'visibleRows',hits);
 }
 const bad={...scenes[0],vertices:[...scenes[0].vertices.slice(0,2),[0,130,1000]]};
 const input=sceneState(initial,bad);
 const previouslyValid=path.join(dir,'should-not-overwrite.rvp');
 fs.writeFileSync(previouslyValid,Buffer.from('preexisting-protected-output'));
 const before=sha(fs.readFileSync(previouslyValid));
 const failed=cp.spawnSync(exe,['run',project,input,previouslyValid],{encoding:'utf8',timeout:60000});
 assert.notEqual(failed.status,0,'near-plane invalid camera was accepted');
 assert.equal(before,sha(fs.readFileSync(previouslyValid)),'XI rollback changed destination');
 summary.atomicRollback=true;summary.sourceMatchesBinary=true;
 assert.equal(baseline,sha(fs.readFileSync(initial)),'initial Ether state changed');
 summary.allPassed=true;
 fs.writeFileSync(path.join(out,'super-project-results.json'),JSON.stringify(summary,null,2)+'\n');
 console.log('SUPER_PROJECT_XI_ALL_OK scenes='+scenes.length+' viewport=16K rollback=true');
}catch(error){
 summary.error=String(error.stack||error);
 fs.writeFileSync(path.join(out,'super-project-failure.json'),JSON.stringify(summary,null,2)+'\n');
 console.error(summary.error);process.exitCode=1;
}finally{fs.rmSync(dir,{recursive:true,force:true});}
