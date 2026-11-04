#!/usr/bin/env node
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {RIG,initialXi,updateXi}=require('./velocity-dynamics.cjs');
const drive=fs.readFileSync(path.join(__dirname,'../reverse-os-android/app/src/main/assets/velocity/drive.xi'),'utf8');
for(const [name,expected] of [['INITIALIZE',initialXi()],['UPDATE',updateXi()]]){
 const begin='# BEGIN V23 RIG '+name+'\n',end='\n# END V23 RIG '+name;
 assert.equal(drive.split(begin).length,2,'one authored '+name+' block');
 assert.equal(drive.split(begin)[1].split(end)[0],expected,'checked-in XI matches the dynamics author');
}
assert.equal(new Set(Object.values(RIG)).size,Object.keys(RIG).length);
assert(Object.values(RIG).every(a=>a>=496&&a<520),'rig does not overlap legacy race state');
console.log('XI_DYNAMICS_AUTHOR_PASS runtime=XI tickHz=50 springAxes=4 wheelPhase=velocity');
