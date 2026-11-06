#!/usr/bin/env node
'use strict';
// Current canonical finite map. The 2.2 closed route remains in its release branch.
const fs=require('node:fs'),path=require('node:path'),world=require('./open-forest-map.cjs');
fs.writeFileSync(path.join(__dirname,'../reverse-os-android/app/src/main/assets/velocity/world.xi'),world.worldXi());
fs.writeFileSync(path.join(__dirname,'../reverse-os-android/app/src/main/assets/velocity/forest-atlas.txt'),require('./forest-trails.cjs').atlas());
console.log('OPEN_FOREST_WORLD_PASS segments=80 sectors=8 widthCm=360 closed=false');
