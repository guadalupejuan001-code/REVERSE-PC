#!/usr/bin/env node
'use strict';
const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process');
const assert=require('node:assert/strict'),crypto=require('node:crypto');
const [apk,badging,output]=process.argv.slice(2);
assert(apk&&badging&&output,'velocity-apk-package.cjs APK BADGING_JSON RESULTS');
function unzip(args){
 const p=cp.spawnSync('unzip',args,{encoding:null,maxBuffer:40*1024*1024,timeout:30000});
 assert.equal(p.status,0,String(p.stderr));return p.stdout;
}
const entries=unzip(['-Z1',apk]).toString('utf8').trim().split(/\r?\n/);
const nativeElf={};
for(const abi of ['arm64-v8a','x86_64']){
 const name='lib/'+abi+'/libreverse_os.so';
 assert(entries.includes(name),'missing native ABI '+abi);
 const elf=unzip(['-p',apk,name]);
 assert.equal(elf.subarray(0,4).toString('hex'),'7f454c46');
 assert.equal(elf[4],2,'ELF must be 64 bit');assert.equal(elf[5],1,'ELF must be little endian');
 const offset=Number(elf.readBigUInt64LE(32)),size=elf.readUInt16LE(54),count=elf.readUInt16LE(56);
 assert(size>=56&&offset+size*count<=elf.length,'invalid ELF program headers');
 const load=[];
 for(let i=0;i<count;i++){
  const at=offset+i*size;if(elf.readUInt32LE(at)!==1)continue;
  const align=elf.readBigUInt64LE(at+48),position=elf.readBigUInt64LE(at+8),address=elf.readBigUInt64LE(at+16);
  assert(align>=16384n&&position%16384n===address%16384n,'native library must support 16 KB load pages');
  load.push(Number(align));
 }
 assert(load.length>0,'ELF lacks load segments');nativeElf[abi]={bytes:elf.length,loadSegmentAlignments:load};
}
const text=fs.readFileSync(badging,'utf8');
assert.match(text,/package: name='com\.reversepc\.velocity'/);
assert.match(text,/launchable-activity: name='com\.reversepc\.os\.VelocityActivity'/);
assert.match(text,/application-label:'REVERSE VELOCITY'/);
assert.match(text,/sdkVersion:'29'/);
assert(!text.includes("uses-permission: name='android.permission.INTERNET'"),'game flavor unexpectedly requests Internet');
const assets={};
for(const name of ['drive.xi','world.xi','render.xi','palette.txt']){
 const bytes=unzip(['-p',apk,'assets/velocity/'+name]);
 const original=fs.readFileSync(path.join('reverse-os-android/app/src/main/assets/velocity',name));
 assert(bytes.equals(original),'APK contains a different '+name);
 assets[name]={bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex')};
}
const report={passed:true,applicationId:'com.reversepc.velocity',launcher:'com.reversepc.os.VelocityActivity',minSdk:29,
 abis:['arm64-v8a','x86_64'],nativeElf,assets,apkBytes:fs.statSync(apk).size,
 apkSha256:crypto.createHash('sha256').update(fs.readFileSync(apk)).digest('hex')};
fs.mkdirSync(path.dirname(output),{recursive:true});fs.writeFileSync(output,JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(report));
