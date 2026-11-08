#!/usr/bin/env node
'use strict';
const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process');
const assert=require('node:assert/strict'),crypto=require('node:crypto');
const [apk,badging,output,signature,expectedSigner]=process.argv.slice(2);
assert(apk&&badging&&output&&signature&&expectedSigner,
 'velocity-apk-package.cjs APK BADGING RESULTS SIGNATURE EXPECTED_SIGNER_DER');
function unzip(args){
 const p=cp.spawnSync('unzip',args,{encoding:null,maxBuffer:40*1024*1024,timeout:30000});
 assert.equal(p.status,0,String(p.stderr));return p.stdout;
}
const entries=unzip(['-Z1',apk]).toString('utf8').trim().split(/\r?\n/);
assert(entries.filter(n=>/^classes\d*\.dex$/.test(n)).some(n=>unzip(['-p',apk,n]).includes(Buffer.from('Lx/gpu/virtual/CompactTriangleStream;'))),'the APK must package the actual shared GPU-VIRTUAL runtime');
assert(entries.filter(n=>/^classes\d*\.dex$/.test(n)).some(n=>unzip(['-p',apk,n]).includes(Buffer.from('Lcom/reversepc/os/XiSharedGeometryPacket;'))),'APK must package the qSSD observation used by JNI');
assert(entries.filter(n=>/^classes\d*\.dex$/.test(n)).some(n=>unzip(['-p',apk,n]).includes(Buffer.from('Lcom/reversepc/os/VelocityQssdGraphicsBridge;'))),'APK must package the qSSD GLES resource bridge');
const nativeElf={};
for(const abi of ['arm64-v8a','x86_64']){
 const name='lib/'+abi+'/libreverse_os.so';
 assert(entries.includes(name),'missing native ABI '+abi);
 const elf=unzip(['-p',apk,name]);
 assert(elf.includes(Buffer.from('Java_com_reversepc_os_NativeRuntime_sessionObserveSharedGeometry')),'native qSSD JNI entry must be present');
 assert(elf.includes(Buffer.from('Java_com_reversepc_os_NativeRuntime_velocityC12Frame')),'original GPU C12 per-frame JNI entry must be compiled into APK');
 for(const fn of ['nativePublish','nativePlan','nativeConfirm','nativeInvalidate'])assert(elf.includes(Buffer.from('Java_com_reversepc_os_VelocityQssdGraphicsBridge_'+fn)),'original QSSD native entry missing: '+fn);
 for(const method of ['sessionCheckpointSpace','sessionOpenSpace','sessionRegisterResources','sessionForkSpace'])assert(elf.includes(Buffer.from('Java_com_reversepc_os_NativeRuntime_'+method)),'full-state JNI entry absent: '+method);
 assert.equal(elf.subarray(0,4).toString('hex'),'7f454c46');
 assert.equal(elf[4],2,'ELF must be 64 bit');assert.equal(elf[5],1,'ELF must be little endian');
 assert.equal(elf.readUInt16LE(18),abi==='arm64-v8a'?183:62,'ELF machine must match packaged ABI');
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
assert.match(text,/package: name='com\.reversepc\.velocity\.c04'/);
assert.match(text,/versionCode='46'/,'C02 lab versionCode');
assert.match(text,/versionName='4\.0\.0-c04-native-qssd'/,'C02 lab versionName');
assert.match(text,/launchable-activity: name='com\.reversepc\.os\.VelocityActivity'/);
assert.match(text,/application-label:'REVERSE VELOCITY C04'/);
assert.match(text,/sdkVersion:'29'/);
assert(!text.includes("uses-permission: name='android.permission.INTERNET'"),'game flavor unexpectedly requests Internet');
const assets={};
const assetRoot=path.join('reverse-os-android/app/src/main/assets/velocity');
function sourceAssets(directory,prefix=''){
 return fs.readdirSync(directory,{withFileTypes:true}).flatMap(entry=>{
  const name=prefix+entry.name;
  if(entry.isDirectory())return sourceAssets(path.join(directory,entry.name),name+'/');
  assert(entry.isFile(),'unexpected non-file game asset '+name);return [name];
 }).sort();
}
const names=sourceAssets(assetRoot);
for(const name of ['drive.xi','world.xi','render.xi','render-live.xi'])assert(names.includes(name),'missing XI game source '+name);
assert.deepEqual(entries.filter(name=>name.startsWith('assets/velocity/')&&!name.endsWith('/'))
 .map(name=>name.slice('assets/velocity/'.length)).sort(),names,'packaged game asset inventory differs');
for(const name of names){
 const bytes=unzip(['-p',apk,'assets/velocity/'+name]);
 const original=fs.readFileSync(path.join(assetRoot,name));
 assert(bytes.equals(original),'APK contains a different '+name);
 assets[name]={bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex')};
}
const signed=fs.readFileSync(signature,'utf8');
assert.match(signed,/^Verifies\s*$/m,'apksigner did not verify APK');
assert.match(signed,/Verified using v2 scheme[^\n]*: true/,'APK v2 signature absent');
assert.match(signed,/Number of signers: 1/,'unexpected APK signer count');
const signer=(/Signer #1 certificate SHA-256 digest:\s*([0-9a-f]{64})/i.exec(signed)||[])[1];
const expected=new crypto.X509Certificate(fs.readFileSync(expectedSigner)).fingerprint256.replaceAll(':','').toLowerCase();
assert.equal(signer&&signer.toLowerCase(),expected,'APK signer differs from cached development identity');
if(process.env.VELOCITY_EXPECTED_SIGNER_SHA256){
 assert.match(process.env.VELOCITY_EXPECTED_SIGNER_SHA256,/^[0-9a-f]{64}$/,'invalid pinned signer identity');
 assert.equal(expected,process.env.VELOCITY_EXPECTED_SIGNER_SHA256,
  'APK must keep the signer of the released 0.1 test build for in-place upgrades');
}
const report={passed:true,applicationId:'com.reversepc.velocity.c04',launcher:'com.reversepc.os.VelocityActivity',minSdk:29,
 versionCode:46,versionName:'4.0.0-c04-native-qssd',sourceCommit:process.env.GITHUB_SHA||null,
 signerCertificateSha256:expected,signerVerifiedAgainstBuildCertificate:true,inPlaceUpgradeCompatible:false,
 abis:['arm64-v8a','x86_64'],nativeElf,assets,apkBytes:fs.statSync(apk).size,
 apkSha256:crypto.createHash('sha256').update(fs.readFileSync(apk)).digest('hex')};
fs.mkdirSync(path.dirname(output),{recursive:true});fs.writeFileSync(output,JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(report));
