'use strict';
const assert=require('node:assert/strict');
const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process');
const root=path.resolve(__dirname,'../..'),prefix='reverse-os-android/app/src/main/assets/workbench/';
const original={
 'app-icons.css':'0d9f5cfbc915a3510e3b7241afae91c0950cc633',
 'app-icons.js':'fec63c8e0164bbc81ca4f14fd85e5ffa5c4d9ace',
 'assets/pliegue-default.webp':'a073bc3248406af5274fdf59d82286d5e2cc1f6b',
 'desktop.css':'9df3b87878a75a95d04ece54119b2ae50773f92f',
 'icon.svg':'211c4208a0a575cb1d6b6ad35a0c103f1652645e'
};
for(const [file,sha] of Object.entries(original)){
 const current=cp.execFileSync('git',['hash-object',prefix+file],{cwd:root,encoding:'utf8'}).trim();
 assert.equal(current,sha,'Wallpaper/icon artwork differs from REVERSE 2.5.8: '+file);
}
const manifest=fs.readFileSync(path.join(root,'reverse-os-android/app/src/main/AndroidManifest.xml'),'utf8');
for(const name of ['BootActivity','WorkbenchActivity','DesktopActivity','MainActivity']){
 assert.match(manifest,new RegExp('android:name="\\.'+name+'"[^>]*android:screenOrientation="fullUser"'),'Auto-rotation missing for '+name);
}
assert.match(manifest,/android:name="\.RxeGraphicsActivity"[^>]*android:screenOrientation="sensorLandscape"/,'PRISMA remains landscape-only');
const css=fs.readFileSync(path.join(root,prefix+'orientation-adaptive.css'),'utf8');
const index=fs.readFileSync(path.join(root,prefix+'index.html'),'utf8');
assert.ok(index.includes('orientation-adaptive.css'),'Portrait rules are not loaded');
assert.ok(css.includes('@media (orientation:portrait)')&&css.includes('grid-auto-flow:row'),'Portrait CSS missing');
assert.ok(!/wall-image|#wallpaper|background-image|\.app-icon\{/.test(css),'Orientation CSS changes wallpaper or icon art');
console.log(JSON.stringify({suite:'dual_orientation',desktop:['portrait','landscape'],prisma:'landscape',art_assets_verified:Object.keys(original).length,visual_identity:'unchanged'}));
