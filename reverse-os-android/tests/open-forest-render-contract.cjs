#!/usr/bin/env node
'use strict';
const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process'),assert=require('node:assert/strict'),crypto=require('node:crypto');
const {performance}=require('node:perf_hooks');
const cli=path.resolve(process.argv[2]||'build/velocity/reverse_pc'),output=path.resolve(process.argv[3]||'build/open-forest'),root=path.resolve('reverse-os-android/app/src/main/assets/velocity');
const HEADER='#!reverse-pc-machine-v1\n',hash=b=>crypto.createHash('sha256').update(b).digest('hex');let serial=0;
fs.mkdirSync(output,{recursive:true});
function run(source,state){const file=path.join(output,'inspection-'+serial+'.xi'),discard=path.join(output,'discard-'+serial+++'.rvp');fs.writeFileSync(file,source);const p=cp.spawnSync(cli,['run',file,state,discard],{timeout:30000,maxBuffer:16*1024*1024});assert.ifError(p.error);assert.equal(p.status,0,String(p.stderr));return {bytes:p.stdout,state:discard};}
const scene=fs.readFileSync(path.join(root,'render.xi'),'utf8'),capture=fs.readFileSync(path.join(root,'render4k.xi'),'utf8'),native=fs.readFileSync(path.join(root,'render-native4k.xi'),'utf8');
for(const s of [scene,capture,native])assert(Buffer.byteLength(s)<512*1024,'bounded executable XI');
function render(state,source=scene,extra=''){return run(HEADER+'store8 200 1\nstore8 201 0\nstore8 202 0\nstore8 203 0\nstore16 204 0\nstore16 206 0\nstore8 139 0\nstore8 140 0\n'+extra+source.slice(HEADER.length),state).bytes;}
function indices(b){assert.equal(b.toString('ascii',0,4),'XFS1');const w=b.readUInt16LE(6),h=b.readUInt16LE(8);assert.equal(w,640);assert.equal(h,360);const p=new Uint8Array(w*h);for(let at=16;at<b.length-8;at+=14){const m=b[at+1],y=b.readUInt16LE(at+2),x0=b.readUInt16LE(at+4),x1=b.readUInt16LE(at+6);assert(y<h&&x0<=x1&&x1<w,'bounded pixel span');p.fill(m,y*w+x0,y*w+x1+1);}return p;}
function ppm(name,pixels,paletteName,w=640,h=360){const palette=fs.readFileSync(path.join(root,'palette-'+paletteName+'.txt'),'utf8').trim().split('\n').map(h=>Buffer.from(h,'hex')),rgb=Buffer.alloc(w*h*3);for(let i=0;i<pixels.length;i++)palette[pixels[i]].copy(rgb,i*3);fs.writeFileSync(path.join(output,name+'.ppm'),Buffer.concat([Buffer.from(`P6\n${w} ${h}\n255\n`),rgb]));}
const env=fs.readFileSync(path.join(root,'environment.xi'),'utf8');
const modes=[],frames=[];
for(const [name,file,mode,yaw] of [['entry','start.rvp',1,0],['bridge','bridge.rvp',1,0],['lake','lake.rvp',1,450],['sunset','lake.rvp',2,450],['night','lake.rvp',3,450],['end','end.rvp',1,0]]){
 const retained=path.join(output,'gameplay',file),before=hash(fs.readFileSync(retained));
 const world=run(HEADER+'store8 137 '+mode+'\n'+env.slice(HEADER.length),retained).state;
 const t=performance.now(),first=render(world,scene,'store16 204 '+yaw+'\n'),ms=performance.now()-t,again=render(world,scene,'store16 204 '+yaw+'\n');
 assert(first.equals(again),'deterministic world frame '+name);const pixels=indices(first);assert(new Set(pixels).size>20,'world material detail '+name);
 assert.equal(hash(fs.readFileSync(retained)),before,'world observation must preserve physical checkpoint');
 const geometry=render(world,capture,'store16 204 '+yaw+'\n');assert.equal(geometry.toString('ascii',0,4),'XFG4');const count=geometry.readUInt32LE(12);assert(count>300&&count<6880,'bounded clipped face transport');
 if(name==='lake'||name==='bridge')assert([...pixels].some(p=>p>=32&&p<40),'real water pixels at '+name);
 ppm(name,pixels,mode===3?'night':mode===2?'dusk':'day');frames.push({name,mode,ms:+ms.toFixed(3),faces:count,frameSha256:hash(first)});modes.push(hash(first));
 if(name==='night'){
  const high=render(world,native,'store16 204 '+yaw+'\n');assert.equal(high.toString('ascii',0,4),'XFB5');assert.equal(high.length,16+3840*2160);ppm('native-4k-night',high.subarray(16),'night',3840,2160);
 }
}
assert(new Set(modes).size===modes.length,'map sectors and illumination produce distinct scenes');
// Fauna and water are actual XI geometry, compared at the same retained pose.
const {points,heights,headings}=require('../../scripts/open-forest-map.cjs');
const initial=path.join(output,'gameplay/start.rvp');
const at=15,inspect=run(HEADER+`store32 100 ${points[at][0]+2000000000}\nstore32 104 ${points[at][1]+2000000000-1200}\nstore16 108 ${headings[at]}\nstore8 273 ${at}\nstore16 520 ${heights[at]}\nstore8 137 1\n`+env.slice(HEADER.length),initial).state;
const fa=indices(render(inspect,scene,'store16 204 400\n')),fb=indices(render(inspect,scene,'store16 204 400\nstore8 139 1\n'));
const faunaPixels=fa.reduce((n,v,i)=>n+(v!==fb[i]),0);assert(faunaPixels>8,'visible bounded fauna has causal pixel coverage');ppm('fauna',fa,'day');
const report={passed:true,world:'Open Forest Road 3.3 Open Terrain',frames,faunaPixels,sourceBytes:Buffer.byteLength(scene),maxWorldTriangles:4086,sectorWindow:3,roadSamplesPreparedAtMost:31,phoneFpsMeasured:false};
fs.writeFileSync(path.join(output,'render-results.json'),JSON.stringify(report,null,2)+'\n');console.log('OPEN_FOREST_RENDER_PASS '+JSON.stringify(report));
