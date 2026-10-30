#!/usr/bin/env node
'use strict';
// The resident C++ host executes the real XI source at logical 50Hz and
// checks RVPC2 roundtrips. No physics are replicated in this Node wrapper.
const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process');
const assert=require('node:assert/strict'),crypto=require('node:crypto');
const cli=path.resolve(process.argv[2]||'build/velocity/reverse_pc');
const out=path.resolve(process.argv[3]||'build/velocity');
const harness=path.join(path.dirname(cli),'velocity-gameplay-contract');
const assets=path.resolve('reverse-os-android/app/src/main/assets/velocity');
const evidence=path.join(out,'gameplay');
const digest=file=>crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
assert(fs.existsSync(harness),'Compile tests/velocity-gameplay-contract.cpp beside the XI CLI first');
const pin=cp.execFileSync('git',['-C','deps/mundo-x','rev-parse','HEAD'],{encoding:'utf8'}).trim();
assert.equal(pin,'1f925786522aba91f72707ad1638a8edcdd31a8f','Android/host upstream pin must match');
const drive=path.join(assets,'drive.xi'),world=path.join(assets,'world.xi');
const inputs={driveSha256:digest(drive),worldSha256:digest(world)};
fs.mkdirSync(evidence,{recursive:true});
const result=cp.spawnSync(harness,[assets,evidence,'15000'],{stdio:'inherit',timeout:180000});
if(result.error)throw result.error;
assert.equal(result.status,0,'XI full race/physics/persistence test failed');
const file=path.join(evidence,'gameplay-results.json'),report=JSON.parse(fs.readFileSync(file,'utf8'));
assert.equal(digest(drive),inputs.driveSha256,'drive source changed during the test');
assert.equal(digest(world),inputs.worldSha256,'world source changed during the test');
Object.assign(report,inputs,{upstreamPin:pin,harnessSha256:digest(harness),
 hostBuildFlags:process.env.VELOCITY_HOST_BUILD_FLAGS||'not recorded by caller'});
fs.writeFileSync(file,JSON.stringify(report,null,2)+'\n');
console.log('REVERSE_VELOCITY_XI_V3_PASS laps='+report.completedLaps+' sectors='+report.sectors+
 ' residentMsPerTick='+report.residentMsPerTick+' serializedMsPerTick='+report.serializedMsPerTick);
