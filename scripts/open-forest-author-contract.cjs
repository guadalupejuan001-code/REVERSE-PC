#!/usr/bin/env node
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.join(__dirname,'../reverse-os-android/app/src/main/assets/velocity'),env=require('./open-forest-environment.cjs');
const drive=fs.readFileSync(path.join(root,'drive.xi'),'utf8');
assert.equal(fs.readFileSync(path.join(root,'world.xi'),'utf8'),require('./open-forest-map.cjs').worldXi(),'canonical finite world source');
for(const [marker,text] of [['OPEN GROUND',env.groundXi()],['OPEN CLOCK',env.timeXi(true)],['OPEN PROP COLLISION',require('./open-forest-collisions.cjs')()]]){
 assert(drive.includes('# BEGIN '+marker+'\n'+text+'\n# END '+marker),'authored XI '+marker+' remains reproducible');
}
require('./velocity-dynamics-contract.cjs');
assert(drive.includes(env.extraObservation()),'world telemetry is part of the XI executable');
for(const name of ['palette-day.txt','palette-dusk.txt','palette-night.txt'])assert.equal(fs.readFileSync(path.join(root,name),'utf8').trim().split('\n').length,256);
console.log('OPEN_FOREST_AUTHOR_PASS sectors=8 open=true laneWidthCm=360 bounded=true');
