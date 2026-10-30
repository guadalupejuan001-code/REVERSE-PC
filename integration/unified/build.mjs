import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import {execFileSync} from 'node:child_process';
import {alignApk,verifyApkAlignment} from './align-apk.mjs';
const [toolsArg,stageArg,keyArg,outputArg]=process.argv.slice(2);if(!outputArg)throw Error('Usage: build.mjs ANDROID35_COMPILER_SUPPORT NEW_BUILD_DIR SIGNING_KEYSTORE OUTPUT_APK');
const [tools,stage,key,output]=[toolsArg,stageArg,keyArg,outputArg].map(x=>path.resolve(x));
const root=path.resolve(import.meta.dirname,'../..'),main=path.join(root,'reverse-os-android/app/src/main'),sdk=path.join(tools,'android.jar');
const run=(cmd,args,opts={})=>execFileSync(cmd,args.map(String),{stdio:'inherit',...opts}),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
if(fs.existsSync(stage)||fs.existsSync(output))throw Error('Choose fresh build and output paths');fs.mkdirSync(stage,{recursive:true});fs.mkdirSync(path.dirname(output),{recursive:true});
for(const n of ['generated','classes','dex'])fs.mkdirSync(path.join(stage,n));
const lock=JSON.parse(fs.readFileSync(path.join(root,'integration/unified/native-lock.json')));
for(const [abi,ref]of Object.entries(lock.jni))for(const [name,h]of [['libreverse_os.so',ref.primary_sha256],['libregraphics.so',ref.sha256]])if(sha(fs.readFileSync(path.join(main,'jniLibs',abi,name)))!==h)throw Error('Native library changed: '+abi+'/'+name);
let manifest=fs.readFileSync(path.join(main,'AndroidManifest.xml'),'utf8').replace('<manifest xmlns:android="http://schemas.android.com/apk/res/android">','<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.reversepc.os">').replace('${appLabel}','REVERSE');
manifest=manifest.replace(/android:name="\.([^\"]+)"/g,'android:name="com.reversepc.os.$1"');fs.writeFileSync(path.join(stage,'AndroidManifest.xml'),manifest);
run(path.join(tools,'aapt2'),['compile','--dir',path.join(main,'res'),'-o',path.join(stage,'resources.zip')]);
run(path.join(tools,'aapt2'),['link','-I',sdk,'--manifest',path.join(stage,'AndroidManifest.xml'),'-R',path.join(stage,'resources.zip'),'--auto-add-overlay','--min-sdk-version','29','--target-sdk-version','35','--version-code','310','--version-name','3.1.0-completo','--rename-manifest-package','com.reversepc.complete.workbench','--custom-package','com.reversepc.os','--java',path.join(stage,'generated'),'-o',path.join(stage,'unsigned.apk')]);
function files(dir,extension){let out=[];for(const n of fs.readdirSync(dir,{withFileTypes:true})){const p=path.join(dir,n.name);if(n.isDirectory())out.push(...files(p,extension));else if(p.endsWith(extension))out.push(p);}return out.sort();}
fs.writeFileSync(path.join(stage,'sources.txt'),[...files(path.join(main,'java'),'.java'),...files(path.join(stage,'generated'),'.java')].join('\n')+'\n');
run('java',['-Djava.io.tmpdir='+stage,'-m','jdk.compiler/com.sun.tools.javac.Main','-source','17','-target','17','-encoding','UTF-8','-classpath',sdk,'-d',path.join(stage,'classes'),'@'+path.join(stage,'sources.txt')]);
fs.writeFileSync(path.join(stage,'classfiles.txt'),files(path.join(stage,'classes'),'.class').join('\n')+'\n');
run('java',['-Djava.io.tmpdir='+stage,'-cp',path.join(tools,'d8.jar'),'com.android.tools.r8.D8','--release','--min-api','29','--lib',sdk,'--output',path.join(stage,'dex'),'@'+path.join(stage,'classfiles.txt')]);
run('zip',['-q','-r',path.join(stage,'unsigned.apk'),'assets'],{cwd:main});
run('zip',['-q','-0','-r',path.join(stage,'unsigned.apk'),'.'],{cwd:path.join(main,'jniLibs')});
// The ZIP paths above must be lib/ABI/..., not top-level ABI entries.
run('zip',['-q','-d',path.join(stage,'unsigned.apk'),'arm64-v8a/*','x86_64/*']);
fs.mkdirSync(path.join(stage,'native'));fs.symlinkSync(path.join(main,'jniLibs'),path.join(stage,'native/lib'),'dir');
run('zip',['-q','-0','-r',path.join(stage,'unsigned.apk'),'lib'],{cwd:path.join(stage,'native')});
for(const p of files(path.join(stage,'dex'),'.dex'))run('zip',['-q','-0',path.join(stage,'unsigned.apk'),path.basename(p)],{cwd:path.dirname(p)});
// Android 11+ rejects a compressed resources.arsc for this target SDK.
fs.writeFileSync(path.join(stage,'resources.arsc'),execFileSync('unzip',['-p',path.join(stage,'unsigned.apk'),'resources.arsc'],{maxBuffer:16*1024*1024}));
run('zip',['-q','-0',path.join(stage,'unsigned.apk'),'resources.arsc'],{cwd:stage});
alignApk(path.join(stage,'unsigned.apk'),path.join(stage,'aligned.apk'));
run('java',['-Djava.io.tmpdir='+stage,'-jar',path.join(tools,'apksigner.jar'),'sign','--ks',key,'--ks-key-alias','reverse-desktop','--ks-pass','env:REVERSE_LOCAL_SIGNING_PASS','--key-pass','env:REVERSE_LOCAL_SIGNING_PASS','--out',output,path.join(stage,'aligned.apk')]);
const cert=execFileSync('java',['-Djava.io.tmpdir='+stage,'-jar',path.join(tools,'apksigner.jar'),'verify','--verbose','--print-certs',output],{encoding:'utf8'});
if(!cert.includes('cd76d2fef0c238b19b7ad679606f3dbecf44affd93fd585cc1a5bcf057d05a7d'))throw Error('Unexpected signing certificate');
verifyApkAlignment(output);run('unzip',['-tq',output]);
const info={file:path.basename(output),bytes:fs.statSync(output).size,sha256:sha(fs.readFileSync(output)),version:'3.1.0-completo',versionCode:310,package:'com.reversepc.complete.workbench',signature_matches_2_9:true,zip_native_alignment_16kb:true,primary_elf_page_alignment:4096,resources_uncompressed:true,native_ab_is:['arm64-v8a','x86_64'],android_device_tested:false};
fs.writeFileSync(output+'.verification.json',JSON.stringify(info,null,2)+'\n');console.log(JSON.stringify(info));
