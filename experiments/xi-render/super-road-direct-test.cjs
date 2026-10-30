#!/usr/bin/env node
'use strict';
// Same SUPER RENDER XI road geometry, but old 14-register JSON chunks versus
// single XI-authored binary XFS1 frame. Only the display adapter maps materials.
const fs=require('node:fs'),path=require('node:path'),os=require('node:os'),cp=require('node:child_process');
const crypto=require('node:crypto'),assert=require('node:assert/strict');
const {performance}=require('node:perf_hooks'),{decode}=require('./frame-stream.cjs');
const xi=path.resolve(process.argv[2]||'build/xi-direct/reverse_pc');
const output=path.resolve(process.argv[3]||'build/xi-direct/evidence');
fs.mkdirSync(output,{recursive:true});
const tmp=fs.mkdtempSync(path.join(os.tmpdir(),'xi-road-binary-'));
const original=fs.readFileSync('experiments/xi-render/super-render.xi','utf8');
const binary=fs.readFileSync('experiments/xi-render/super-road-direct.xi','utf8');
const palette=[[16,41,75],[47,92,49],[103,94,77],[48,54,62],[224,223,204],[242,190,55]];
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const med=a=>a.slice().sort((a,b)=>a-b)[Math.floor(a.length/2)];
let id=0;
function call(program,initial,binaryOutput=false){
 const name='call-'+(++id);
 const input=path.join(tmp,name+'.xi'),dest=path.join(tmp,name+'.rvp');
 fs.writeFileSync(input,program);
 const start=performance.now();
 const p=cp.spawnSync(xi,['run',input,initial,dest],{
   encoding:binaryOutput?null:'utf8',timeout:90000,maxBuffer:16*1024*1024});
 if(p.status!==0||p.error)
   throw Error('XI failed '+name+' '+String(p.stderr).slice(-1600)+' '+p.error);
 return {output:p.stdout,ms:performance.now()-start};
}
function le32(n){return [0,8,16,24].map(s=>Math.floor(n/(2**s))%256);}
function prefix(w,h,start,count,curve,phase){
 const bytes=[...le32(w),...le32(h),...le32(start),...le32(count),curve,phase];
 return '#!reverse-pc-machine-v1\n'+bytes.map((v,i)=>'store8 '+(200+i)+' '+v+'\n').join('');
}
function program(src,w,h,start,count,curve,phase){
 return prefix(w,h,start,count,curve,phase)+src.slice(src.indexOf('\n')+1);
}
function referenceRows(w,h,curve,phase,initial,chunk){
 const rows=[];let ms=0,jsonBytes=0,transactions=0;
 for(let start=0;start<h;start+=chunk){
  const count=Math.min(chunk,h-start);
  const r=call(program(original,w,h,start,count,curve,phase),initial);
  ms+=r.ms;jsonBytes+=Buffer.byteLength(r.output);transactions++;
  const lines=r.output.trim().split('\n');
  assert.equal(lines.length,count*14,'XI must publish all 14 descriptors per row');
  for(let n=0;n<count;n++){
   const values=lines.slice(n*14,(n+1)*14).map(line=>{
    const record=JSON.parse(line);
    assert.equal(record.type,'register');
    return record.value;
   });
   assert.equal(values[0],start+n,'row index');
   rows.push(values);
  }
 }
 return {rows,ms,jsonBytes,transactions};
}
function displayColors(id,shade){
 const base=palette[id];
 assert(base!==undefined,'invalid XI material id '+id);
 const gain=id===0?Math.min(70,shade*4):id===1?Math.min(18,shade):0;
 return [Math.min(255,base[0]+gain),Math.min(255,base[1]+gain),
         Math.min(255,base[2]+gain)];
}
// XI already chose the material and shade; this is only its presentation palette.
const materialPalette=Array.from({length:96},(_,code)=>{
 const color=displayColors(code>>4,code&15);
 return Buffer.from(color);
});
function referenceImage(rows,w,h){
 const image=Buffer.alloc(w*h*3);
 const colors=rows.map(row=>{
  const material=Buffer.alloc(w,row[1]===0?0:1);
  if(row[1]===1){
   const fill=(a,b,id)=>{
    if(a===-1||b===-1)return;
    assert(a>=0&&b>=a&&b<w,'invalid original XI span');
    material.fill(id,a,b+1);
   };
   fill(row[2],row[3],2);fill(row[4],row[5],3);
   fill(row[6],row[7],4);fill(row[8],row[9],4);
   if(row[13])fill(row[10],row[11],5);
  }
  return material;
 });
 for(let y=0;y<h;y++)for(let x=0;x<w;x++){
  const c=displayColors(colors[y][x],rows[y][12]),at=(y*w+x)*3;
  image[at]=c[0];image[at+1]=c[1];image[at+2]=c[2];
 }
 return image;
}
function oldHostRGB(frame){
 const decoded=decode(frame),pixels=decoded.pixels;
 const rgb=Buffer.alloc(pixels.length*3);
 for(let i=0;i<pixels.length;i++){
  const c=displayColors(pixels[i]>>4,pixels[i]&15),at=i*3;
  rgb[at]=c[0];rgb[at+1]=c[1];rgb[at+2]=c[2];
 }
 return rgb;
}
function directImage(w,h,curve,phase,initial){
 const start=performance.now();
 const r=call(program(binary,w,h,0,h,curve,phase),initial,true);
 const decoded=decode(r.output,{palette:materialPalette});
 return {rgb:decoded.pixels,frame:r.output,commands:decoded.commands,
  ms:performance.now()-start,xiMs:r.ms,bytes:r.output.length};
}
const results={suite:'SUPER RENDER XI complete road frame with direct XFS1',
 claim:'same authored XI road and material rules; no JSON, one XI transaction',
 environment:{platform:process.platform,arch:process.arch,node:process.version,cpu:os.cpus()[0]?.model},
 scenarios:[],passed:false};
try{
 const initial=path.join(tmp,'initial.rvp');
 const p=cp.spawnSync(xi,['init',initial],{encoding:'utf8'});
 assert.equal(p.status,0,String(p.stderr));
 for(const spec of [{w:640,h:360,curve:128,phase:0,chunk:127},
                    {w:1280,h:720,curve:178,phase:25,chunk:128},
                    {w:1920,h:1080,curve:175,phase:17,chunk:180},
                    {w:3840,h:2160,curve:155,phase:19,chunk:180}]){
  const {w,h,curve,phase,chunk}=spec;
  const old=referenceRows(w,h,curve,phase,initial,chunk);
  const baseline=referenceImage(old.rows,w,h);
  const fast=directImage(w,h,curve,phase,initial);
  assert(fast.rgb.equals(baseline),'XI road visual mismatch at '+w+'x'+h);
  // Microbenchmark the same XFS1 bytes: old per-pixel palette loop vs
  // depth-ordered contiguous RGB spans. Both include XFS1 validation and SHA.
  const rgbOld=oldHostRGB(fast.frame);
  const rgbNew=decode(fast.frame,{palette:materialPalette}).pixels;
  assert(rgbOld.equals(rgbNew)&&rgbNew.equals(baseline),'RGB palette parity');
  const oldHostTimes=[],newHostTimes=[];
  for(let i=0;i<6;i++){
   for(const kind of i%2?['new','old']:['old','new']){
    const tick=performance.now();
    const result=kind==='old'?oldHostRGB(fast.frame):
      decode(fast.frame,{palette:materialPalette}).pixels;
    assert(result.equals(baseline),'RGB compositor nondeterministic');
    (kind==='old'?oldHostTimes:newHostTimes).push(performance.now()-tick);
   }
  }
  const row={width:w,height:h,pixels:w*h,oldTransactions:old.transactions,
    directTransactions:1,oldJsonBytes:old.jsonBytes,
    directBinaryBytes:fast.bytes,spanCommands:fast.commands,
    sha256:hash(baseline),legacyMs:[],directMs:[],
    oldHostRGBMs:Number(med(oldHostTimes).toFixed(4)),
    optimizedHostRGBMs:Number(med(newHostTimes).toFixed(4))};
  for(let i=0;i<3;i++){
   const ordered=i===1?['direct','legacy']:['legacy','direct'];
   for(const way of ordered){
    if(way==='legacy'){
     const ref=referenceRows(w,h,curve,phase,initial,chunk);
     const start=performance.now();
     const image=referenceImage(ref.rows,w,h);
     assert(image.equals(baseline),'legacy XI nondeterministic');
     row.legacyMs.push(Number((ref.ms+performance.now()-start).toFixed(3)));
    }else{
     const d=directImage(w,h,curve,phase,initial);
     assert(d.rgb.equals(baseline),'direct XI nondeterministic');
     row.directMs.push(Number(d.ms.toFixed(3)));
    }
   }
  }
  row.legacyMedianMs=Number(med(row.legacyMs).toFixed(3));
  row.directMedianMs=Number(med(row.directMs).toFixed(3));
  row.speedup=Number((row.legacyMedianMs/row.directMedianMs).toFixed(2));
  row.rgbCompositorSpeedup=Number((row.oldHostRGBMs/row.optimizedHostRGBMs).toFixed(2));
  row.byteReduction=Number((row.oldJsonBytes/row.directBinaryBytes).toFixed(2));
  results.scenarios.push(row);
  console.log('SUPER_ROAD_XFS1_EXACT_OK',w,h,'old_chunks',old.transactions,
    'binary_chunks=1','json_bytes',old.jsonBytes,'xfs1_bytes',fast.bytes,
    'legacy_ms',row.legacyMedianMs,'direct_ms',row.directMedianMs,
    'speedup',row.speedup,'rgb_compositor_gain',row.rgbCompositorSpeedup,
    'rgb_sha256',row.sha256);
 }
 results.passed=true;
 fs.writeFileSync(path.join(output,'super-road-direct-results.json'),JSON.stringify(results,null,2)+'\n');
 console.log('SUPER_ROAD_DIRECT_XI_ALL_OK scenes='+results.scenarios.length+' pass=true');
}catch(e){
 results.error=String(e.stack||e);
 fs.writeFileSync(path.join(output,'super-road-direct-failure.json'),JSON.stringify(results,null,2)+'\n');
 console.error(results.error);process.exitCode=1;
}finally{fs.rmSync(tmp,{recursive:true,force:true});}
