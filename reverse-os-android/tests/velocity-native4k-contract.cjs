#!/usr/bin/env node
'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),os=require('node:os'),path=require('node:path');
const cp=require('node:child_process'),crypto=require('node:crypto');
const cli=path.resolve(process.argv[2]||'build/velocity/reverse_pc');
const root=path.resolve('reverse-os-android/app/src/main/assets/velocity');
const tmp=fs.mkdtempSync(path.join(os.tmpdir(),'xi-native4k-'));
const header='#!reverse-pc-machine-v1\n';
const hash=x=>crypto.createHash('sha256').update(x).digest('hex');
function run(...args){const p=cp.spawnSync(cli,args,{encoding:null,timeout:45000,maxBuffer:16*1024*1024});
 assert.ifError(p.error);assert.equal(p.status,0,String(p.stderr));return p.stdout;}
try{
 const initial=path.join(tmp,'initial.rvp'),world=path.join(tmp,'world.rvp'),ready=path.join(tmp,'ready.rvp');
 run('init',initial);run('run',path.join(root,'world.xi'),initial,world);
 const drive=fs.readFileSync(path.join(root,'drive.xi'),'utf8');
 const init=path.join(tmp,'start.xi');
 fs.writeFileSync(init,header+'store8 128 0\nstore8 129 0\nstore8 130 1\nstore8 131 0\nstore8 132 1\n'+drive.slice(header.length));
 run('run',init,world,ready);
 const before=hash(fs.readFileSync(ready));
 const scene=fs.readFileSync(path.join(root,'render-native4k.xi'),'utf8');
 assert(scene.startsWith(header)&&scene.includes('meshbegin r0 r1 5 0'),'native XI raster mode required');
 const render=path.join(tmp,'render.xi');
 fs.writeFileSync(render,header+'store8 200 1\nstore8 201 0\nstore8 202 0\n'+scene.slice(header.length));
 const first=run('run',render,ready,path.join(tmp,'candidate-a.rvp'));
 const second=run('run',render,ready,path.join(tmp,'candidate-b.rvp'));
 assert(first.equals(second),'native 4K XI pixels must be deterministic');
 assert.equal(hash(fs.readFileSync(ready)),before,'4K raster must not alter Ether game state');
 assert.equal(first.toString('ascii',0,4),'XFB5');
 const width=first.readUInt16LE(4),height=first.readUInt16LE(6);
 assert.equal(width,3840);assert.equal(height,2160);
 assert.equal(first.readUInt32LE(8),5);
 assert.equal(first.readUInt32LE(12),width*height);
 assert.equal(first.length,16+width*height,'one original indexed XI material per pixel');
 const present=new Set(first.subarray(16));
 assert(present.size>40,'real material palette diversity lost in native raster');
 assert([...present].some(m=>m>=64&&m<88),'car paint geometry absent');
 assert([...present].some(m=>m>=40&&m<48),'asphalt geometry absent');
 const report={passed:true,width,height,pixels:width*height,packetBytes:first.length,
  materialsPresent:present.size,sha256:hash(first),sameImageOnReplay:true,unchangedRaceSnapshot:true,
  renderer:'REgraphics XI native strips',opengl:false};
 console.log('REGRAPHICS_XI_4K_SCENE_PASS '+JSON.stringify(report));
 if(process.argv[3])fs.writeFileSync(process.argv[3],JSON.stringify(report,null,2)+'\n');
}finally{fs.rmSync(tmp,{recursive:true,force:true});}
