#!/usr/bin/env node
'use strict';
// Exact XI 1.5 interpreter versus predecoded XI core 1.6, same actual runtime.
// Covers errors and normal/4K game observations. Measured times include host
// process, state restore, execution, rasterization and serialization (not FPS).
const assert=require('node:assert/strict');
const fs=require('node:fs'),os=require('node:os'),path=require('node:path');
const cp=require('node:child_process'),crypto=require('node:crypto');
const [oldName,newName,reportName]=process.argv.slice(2);
assert(oldName&&newName&&reportName,
  'usage: xi-preparation-ab.cjs LEGACY_XI NEW_XI REPORT.json');
const binaries=[path.resolve(oldName),path.resolve(newName)];
const root=path.resolve('reverse-os-android/app/src/main/assets/velocity');
const folder=fs.mkdtempSync(path.join(os.tmpdir(),'xi-preparation-ab-'));
const header='#!reverse-pc-machine-v1\n';
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const median=a=>a.slice().sort((a,b)=>a-b)[Math.floor(a.length/2)];
function invoke(binary,...args){
  const started=process.hrtime.bigint();
  const p=cp.spawnSync(binary,args,{encoding:null,maxBuffer:16*1024*1024,timeout:45000});
  assert.ifError(p.error);
  return {code:p.status,output:p.stdout,stderr:String(p.stderr),
    ms:Number(process.hrtime.bigint()-started)/1e6};
}
function requirePass(binary,...args){
  const r=invoke(binary,...args);
  assert.equal(r.code,0,'XI execution failed: '+r.stderr.slice(-2000));
  return r;
}
function scene(name,src){
  const p=path.join(folder,name+'.xi');fs.writeFileSync(p,header+src);return p;
}
try{
  const initial=path.join(folder,'initial.rvp'),worldState=path.join(folder,'world.rvp'),
    stationary=path.join(folder,'stationary.rvp'),moving=path.join(folder,'moving.rvp');
  requirePass(binaries[0],'init',initial);
  const world=path.join(root,'world.xi');
  requirePass(binaries[0],'run',world,initial,worldState);
  const drive=fs.readFileSync(path.join(root,'drive.xi'),'utf8');
  assert(drive.startsWith(header));
  const reset=scene('reset','store8 128 0\nstore8 129 0\nstore8 130 1\n'+
    'store8 131 0\nstore8 132 1\n'+drive.slice(header.length));
  const accelerate=scene('accelerate','store8 128 1\nstore8 129 0\nstore8 130 1\n'+
    'store8 131 0\nstore8 132 0\n'+drive.slice(header.length));
  requirePass(binaries[0],'run',reset,worldState,stationary);
  fs.copyFileSync(stationary,moving);
  for(let tick=0;tick<160;tick++)
    requirePass(binaries[0],'run',accelerate,moving,moving);
  // Compare exact byte outputs and state snapshots under valid arithmetic,
  // branches, local memory and case-insensitive register/label syntax.
  const good=[
    'set r0 +0005\nmov R15 r0\nmul R15 +3\nprint R15\nhalt\n',
    'set r0 9\nlabel Loop\nsub r0 1\ncmp r0 0\njgt LOOP\nprint r0\nhalt\n',
    'set r0 -17\nmod r0 5\nadd r0 5\nprint r0\nhalt\n',
    'set r0 100\nlocalset +12 r0\nlocalget R01 +12\nprint R01\nhalt\n',
    'store8 220 254\nload8 r0 220\nprint r0\nhalt\n',
    'jmp Done\nset r0 broken_value\nlabel DONE\nset r0 -9223372036854775808\nprint r0\nhalt\n',
    'set r0 +9223372036854775807\nsub r0 9223372036854775807\nprint r0\nhalt\n',
    'set r0 12\nset r1 8\ncmp r0 r1\njle Wrong\nmov r2 7\njmp Done\nlabel Wrong\nmov r2 0\nlabel Done\nprint r2\nhalt\n'
  ];
  const bad=[
    'set r0 9223372036854775807\nadd r0 1\nhalt\n',
    'set r0 -9223372036854775808\nsub r0 1\nhalt\n',
    'set r0 9223372036854775807\nmul r0 2\nhalt\n',
    'set r0 -9223372036854775808\nset r1 -1\ndiv r0 r1\nhalt\n',
    'set r0 5\ndiv r0 0\nhalt\n',
    'set r0 5\nmod r0 0\nhalt\n',
    'set r16 5\nhalt\n',
    'set r0 bad_number\nhalt\n',
    'jmp NoSuchLabel\nhalt\n',
    'label Test\nlabel test\nhalt\n'
  ];
  let smallCases=0;
  for(const [valid,programs] of [[true,good],[false,bad]]){
    for(let i=0;i<programs.length;i++){
      const input=scene((valid?'valid':'invalid')+'-'+i,programs[i]);
      const outputs=binaries.map((binary,j)=>{
        const dst=path.join(folder,(valid?'valid':'invalid')+'-'+i+'-'+j+'.rvp');
        const r=invoke(binary,'run',input,initial,dst);
        return {status:r.code,output:r.output,stderr:r.stderr,
          state:r.code===0?fs.readFileSync(dst):null};
      });
      assert.equal(outputs[0].status,outputs[1].status,'XI exit code changed on case '+i);
      assert.equal(outputs[0].status===0,valid,'unexpected XI outcome on case '+i);
      assert.deepEqual(outputs[0].output,outputs[1].output,'XI text output changed on case '+i);
      if(valid)assert.deepEqual(outputs[0].state,outputs[1].state,
        'XI state mutation changed on case '+i);
      else assert.equal(outputs[0].stderr.trim(),outputs[1].stderr.trim(),
        'XI error semantics changed on case '+i);
      smallCases++;
    }
  }
  // 12 native frames: two physical states, three cameras, two paint IDs.
  const raw=fs.readFileSync(path.join(root,'render-native4k.xi'),'utf8');
  assert(raw.startsWith(header));
  const frames=[];
  for(const [stateLabel,state] of [['stationary',stationary],['moving',moving]]){
    const beforeHash=hash(fs.readFileSync(state));
    for(let camera=0;camera<3;camera++)for(const paint of [0,3]){
      const program=scene('render-'+stateLabel+'-'+camera+'-'+paint,
        'store8 200 1\nstore8 201 '+camera+'\nstore8 202 '+paint+'\n'+raw.slice(header.length));
      const measurements=binaries.map((binary,j)=>{
        const samples=[],hashes=[],stateHashes=[];
        for(let i=0;i<3;i++){
          const dest=path.join(folder,'observe-'+stateLabel+'-'+camera+'-'+paint+'-'+j+'.rvp');
          const result=requirePass(binary,'run',program,state,dest);
          assert.equal(result.output.length,8294416,'Expected full native XI 4K XFB5');
          assert.equal(result.output.toString('ascii',0,4),'XFB5');
          stateHashes.push(hash(fs.readFileSync(dest)));
          assert.equal(hash(fs.readFileSync(state)),beforeHash,
            'Interpreter modified the input Ether snapshot');
          samples.push(result.ms);hashes.push(hash(result.output));
        }
        assert(hashes.every(h=>h===hashes[0]),'Nondeterministic XI result');
        assert(stateHashes.every(h=>h===stateHashes[0]),'Nondeterministic candidate Ether state');
        return {medianMs:median(samples.slice(1)),sha256:hashes[0],
          candidateStateSha256:stateHashes[0]};
      });
      assert.equal(measurements[0].sha256,measurements[1].sha256,
        'Compiled XI changed a 4K pixel on '+stateLabel+' camera '+camera+' paint '+paint);
      assert.equal(measurements[0].candidateStateSha256,measurements[1].candidateStateSha256,
        'Compiled XI changed the candidate Ether state');
      frames.push({state:stateLabel,camera,paint,sha256:measurements[0].sha256,
        legacyMs:measurements[0].medianMs,preparedMs:measurements[1].medianMs});
    }
  }
  const totalLegacyMs=frames.reduce((a,v)=>a+v.legacyMs,0),
    totalPreparedMs=frames.reduce((a,v)=>a+v.preparedMs,0);
  const result={passed:true,core:'XI interpreter predecoded opcodes / operands / jumps',
    smallCases,frames:frames.length,allFramesExact:true,allStateSnapshotsEqual:true,
    totalLegacyMs,totalPreparedMs,relativeChangePct:100*(totalPreparedMs/totalLegacyMs-1),
    note:'Host-process times with full raster/JNI absent; not Android FPS or pure interpreter timings',cases:frames};
  fs.mkdirSync(path.dirname(path.resolve(reportName)),{recursive:true});
  fs.writeFileSync(reportName,JSON.stringify(result,null,2)+'\n');
  console.log('XI_PREP_AB_PASS '+JSON.stringify(result));
}finally{fs.rmSync(folder,{recursive:true,force:true});}
