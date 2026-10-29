// Package the owner's taught XI module into the established E025 Android app.
// The host links sources/transports bytes; inference and teaching remain XI.
import fs from'node:fs';import path from'node:path';import crypto from'node:crypto';import zlib from'node:zlib';import{execFileSync}from'node:child_process';
const[r,b,o,a]=process.argv.slice(2);if(!a)throw Error('usage: install-personal-x01.mjs RUNTIME E025_BUILD NEW_OUTPUT APK_ASSETS');
const[runtime,base,out,assets]=[r,b,o,a].map(x=>path.resolve(x)),here=path.join(path.dirname(new URL(import.meta.url).pathname),'personal-x01');
if(fs.existsSync(out))throw Error('Use a fresh output');fs.mkdirSync(out,{recursive:true});
const hash=b=>crypto.createHash('sha256').update(b).digest('hex'),read=p=>fs.readFileSync(p),run=(...args)=>execFileSync(runtime,args,{encoding:'utf8',timeout:30000,maxBuffer:8*1024*1024});
const module=JSON.parse(read(path.join(here,'module.json'))),parent=read(path.join(base,'BBY-Q.rxe'));
if(hash(parent)!==module.parent_executable_sha256)throw Error('Unreviewed E025 capsule; keep the previous release and review compatibility');
const prefix=zlib.gunzipSync(Buffer.from(read(path.join(here,'prefix.xi.gz.b64')).toString().trim(),'base64')).toString();
const upgrade=zlib.gunzipSync(Buffer.from(read(path.join(here,'upgrade.xi.gz.b64')).toString().trim(),'base64'));
if(hash(prefix)!==module.prefix_sha256||hash(upgrade)!==module.upgrade_source_sha256)throw Error('Personal XI module integrity failed');
// Extract the verified existing code and seed from RXE2, without replacing the
// owner's current installation. Header lengths are verified by inspect-rxe.
const metadata=JSON.parse(run('inspect-rxe',path.join(base,'BBY-Q.rxe')));
if(metadata.app_version!=='E025-Chain-1'||metadata.app_id!=='org.reverse.bbyq')throw Error('Wrong parent identity');
const ni=parent.readUInt32LE(20),nt=parent.readUInt32LE(24),nv=parent.readUInt32LE(28),nc=parent.readUInt32LE(32),ns=parent.readUInt32LE(36),at=64+ni+nt+nv+40;
if(at+nc+ns!==parent.length)throw Error('Invalid RXE2 sections');
fs.writeFileSync(path.join(out,'parent-code.rxe'),parent.subarray(at,at+nc));fs.writeFileSync(path.join(out,'parent.rvp'),parent.subarray(at+nc));
run('disassemble',path.join(out,'parent-code.rxe'),path.join(out,'parent.xi'));
const oldSource=read(path.join(out,'parent.xi')).toString();if(oldSource.includes('label xp_parent'))throw Error('Module already linked');
const source=prefix+'\nlabel xp_parent\n'+oldSource.split('\n').slice(1).join('\n');fs.writeFileSync(path.join(out,'conversation.xi'),source);
fs.writeFileSync(path.join(out,'upgrade-x01.xi'),upgrade);run('compile',path.join(out,'upgrade-x01.xi'),path.join(out,'upgrade-x01.rxe'),'BBY Q X01 guarded lessons');
run('run',path.join(out,'upgrade-x01.rxe'),path.join(out,'parent.rvp'),path.join(out,'controller.rvp'));
run('compile',path.join(out,'conversation.xi'),path.join(out,'code.rxe'),'BBY Q E025 with personal X01');
run('pack-app',path.join(out,'code.rxe'),path.join(out,'controller.rvp'),path.join(out,'BBY-Q.rxe'),'org.reverse.bbyq','BBY Q',module.app_version,crypto.createHash('sha1').update(source).digest('hex'));
const app=read(path.join(out,'BBY-Q.rxe')),migration=read(path.join(out,'upgrade-x01.rxe'));
const manifest=JSON.parse(read(path.join(base,'android/manifest.json')));
const personal={version:'X01',schema:1,parent_executable_sha256:hash(parent),executable_sha256:hash(app),upgrade_file:'upgrade-x01.rxe',upgrade_sha256:hash(migration),module_prefix_sha256:module.prefix_sha256,lessons:module.lessons};
manifest.personalization=personal;manifest.executable_sha256=hash(app);manifest.controller_sha256=hash(read(path.join(out,'controller.rvp')));manifest.metadata=JSON.parse(run('inspect-rxe',path.join(out,'BBY-Q.rxe')));
manifest.compatible_w4u_sha256s=[...new Set([...(manifest.compatible_w4u_sha256s||[]),hash(parent)])];
fs.mkdirSync(path.join(assets,'bbyq-interface'),{recursive:true});fs.mkdirSync(path.join(assets,'native-apps'),{recursive:true});
fs.copyFileSync(path.join(out,'BBY-Q.rxe'),path.join(assets,'native-apps/BBY-Q.rxe'));fs.copyFileSync(path.join(out,'upgrade-x01.rxe'),path.join(assets,'bbyq-interface/upgrade-x01.rxe'));
fs.writeFileSync(path.join(assets,'bbyq-interface/manifest.json'),JSON.stringify(manifest,null,2)+'\n');
fs.writeFileSync(path.join(out,'manifest.json'),JSON.stringify(manifest,null,2)+'\n');
const report={...personal,app_bytes:app.length,parent_preserved:true,w4u_artifact_sha256:manifest.agents.artifact_sha256,inference:'XI',android_device_tested:false};
fs.writeFileSync(path.join(out,'build.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report));
