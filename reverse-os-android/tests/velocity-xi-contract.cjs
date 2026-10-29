#!/usr/bin/env node
'use strict';
// End-to-end XI Machine v1 proof. No simulator/replica of vehicle dynamics.
const fs=require('fs'),path=require('path'),os=require('os'),cp=require('child_process'),assert=require('assert');
const bin=path.resolve(process.argv[2]||'build/reverse_pc');
const worldSrc=path.resolve('reverse-os-android/app/src/main/assets/velocity/world.xi');
const gameSrc=path.resolve('reverse-os-android/app/src/main/assets/velocity/drive.xi');
const outDir=path.resolve(process.argv[3]||'build/velocity');
fs.mkdirSync(outDir,{recursive:true});
const temp=fs.mkdtempSync(path.join(os.tmpdir(),'reverse-velocity-xi-'));
const call=(...args)=>{
 const p=cp.spawnSync(bin,args,{encoding:'utf8',timeout:60000,maxBuffer:4*1024*1024});
 if(p.error||p.status!==0)throw Error('REVERSE XI failed: '+args.join(' ')+'\n'+p.stderr+'\n'+p.stdout);
 return p.stdout;
};
const parse=output=>output.trim().split('\n').filter(Boolean).map(line=>JSON.parse(line));
const values=output=>parse(output).map(r=>{
 assert.equal(r.type,'register','XI output type');
 return r.value;
});
const gameValues=output=>{
 const rows=parse(output);
 assert.equal(rows.length,9,'nine authoritative game registers');
 rows.forEach((r,i)=>assert.equal(r.register,'r'+i,'XI game register order'));
 return values(output);
};
const inputScript=(compiled,gas=0,brake=0,steer=1,drift=0,reset=0)=>
 '#!reverse-pc-machine-v1\n'+
 [128,129,130,131,132].map((address,i)=>'store8 '+address+' '+[gas,brake,steer,drift,reset][i]+'\n').join('')+
 compiled.slice(compiled.indexOf('\n')+1);
const digest=data=>require('crypto').createHash('sha256').update(data).digest('hex');
try{
 const fresh=path.join(temp,'initial.rvp');
 call('init',fresh);
 const worldRxe=path.join(temp,'world.rxe');
 const driveRxe=path.join(temp,'drive.rxe');
 call('compile',worldSrc,worldRxe,'VELOCITY WORLD XI');
 call('compile',gameSrc,driveRxe,'VELOCITY DRIVE XI');
 const disasm=path.join(temp,'drive-disassembled.xi');
 call('disassemble',driveRxe,disasm);
 const canonical=fs.readFileSync(disasm,'utf8');
 assert(canonical.startsWith('#!reverse-pc-machine-v1\n'));
 const worldOut=path.join(temp,'world-out.rvp');
 const world=values(call('run',worldRxe,fresh,worldOut));
 assert.equal(world.length,482,'241 XI generated track points');
 const roadLines=[];
 for(let i=0;i<482;i+=2){
   assert.equal(world[i],-85000+(i/2)*1000,'XI world z sample');
   assert(Math.abs(world[i+1])<=8000,'XI world x bounds');
   roadLines.push((world[i]/100)+' '+(world[i+1]/100));
 }
 const track=path.join(outDir,'velocity-track-from-xi.txt');
 fs.writeFileSync(track,roadLines.join('\n')+'\n');
 let state=fresh,count=0;
 function tick(gas=0,brake=0,steer=1,drift=0,reset=0){
   const script=path.join(temp,'input-'+count+'.xi');
   const dest=path.join(temp,'state-'+count+'.rvp');count++;
   fs.writeFileSync(script,inputScript(canonical,gas,brake,steer,drift,reset));
   const stateValues=gameValues(call('run',script,state,dest));
   assert.equal(stateValues.length,9);
   state=dest;return stateValues;
 }
 let s=tick(0,0,1,0,1);
 assert.equal(s[0],83,'XI spawn x');assert.equal(s[1],110000,'XI spawn z');
 assert.deepEqual(s.slice(2,9),[0,0,0,0,0,0,0],'XI reset state');
 const initialHash=digest(fs.readFileSync(state));
 for(let i=0;i<38;i++)s=tick(1,0,1,0,0);
 assert(s[3]>0&&s[1]<110000&&s[6]===38,'XI throttle and negative-z progress');
 const speed=s[3];
 for(let i=0;i<8;i++)s=tick(0,1,1,0,0);
 assert(s[3]<speed,'XI brake slows down');
 // Demonstrate repeatability from identical isolated RVPC2 snapshots.
 const original=fs.readFileSync(state);
 const command=inputScript(canonical,1,0,2,1,0);
 const script=path.join(temp,'deterministic.xi');fs.writeFileSync(script,command);
 const a=path.join(temp,'a.rvp'),b=path.join(temp,'b.rvp');
 const va=gameValues(call('run',script,state,a)),vb=gameValues(call('run',script,state,b));
 assert.deepEqual(va,vb,'XI deterministic observations');
 assert.equal(digest(fs.readFileSync(a)),digest(fs.readFileSync(b)),'XI deterministic state');
 assert.equal(digest(fs.readFileSync(state)),digest(original),'immutable source state');
 assert(va[2]!==s[2]||va[4]!==s[4],'steering/handbrake alters state');
 // An invalid XI command must not replace an existing snapshot.
 const bad=path.join(temp,'invalid.xi');fs.writeFileSync(bad,
 '#!reverse-pc-machine-v1\nstore8 101 244\nnot_an_instruction\n');
 const before=digest(fs.readFileSync(a));
 const failed=cp.spawnSync(bin,['run',bad,state,a],{encoding:'utf8',timeout:20000});
 assert(failed.status!==0,'invalid XI step must fail');
 assert.equal(digest(fs.readFileSync(a)),before,'atomic rollback');
 s=tick(0,0,1,0,1);
 assert.equal(s[6],0,'XI reset clears progress');
 assert.equal(digest(fs.readFileSync(fresh)),digest(fs.readFileSync(fresh)),'independent initial state');
 console.log(JSON.stringify({result:'REVERSE_VELOCITY_XI_OK',
  gameLanguage:'XI Machine v1',physics:'XI source / original QuantumRuntime',
  worldPoints:world.length/2,frameTests:count,
  initialRVPC2Bytes:fs.statSync(fresh).size,
  gameRVPC2Bytes:fs.statSync(state).size,
  deterministic:true,steering:true,braking:true,rollback:true,
  track:track}));
}catch(e){console.error(e.stack||e);process.exitCode=1}
finally{fs.rmSync(temp,{recursive:true,force:true})}
