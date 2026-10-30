// Native REVERSE host entry point. XI owns interpretation, learning and decisions.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {execFileSync} from 'node:child_process';
import {pathToFileURL} from 'node:url';

const profile=JSON.parse(fs.readFileSync(new URL('./profile.json',import.meta.url)));
const [operation,...args]=process.argv.slice(2),options={};
for(let i=0;i<args.length;i++) {
  if(!args[i].startsWith('--')||i+1>=args.length||options[args[i].slice(2)]!==undefined)throw Error('Expected unique --name value arguments');
  options[args[i].slice(2)]=args[++i];
}
const required=name=>{if(!options[name])throw Error('Missing --'+name);return path.resolve(options[name]);};
const sha=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
const source=required('bbyq'),build=required('build');
const ref=execFileSync('git',['-C',source,'rev-parse','HEAD'],{encoding:'utf8'}).trim();
if(ref!==profile.commit)throw Error('BBY Q source revision differs from the pinned REVERSE profile');
execFileSync('git',['-C',source,'diff','--quiet','HEAD','--','ai/personal','integration/x08']);
const load=relative=>import(pathToFileURL(path.join(source,relative)).href);

function validatePrepared() {
  const owner=JSON.parse(fs.readFileSync(path.join(build,'reverse-x08.json')));
  if(owner.bbyq_commit!==profile.commit)throw Error('Prepared build belongs to another BBY Q revision');
  const release=JSON.parse(fs.readFileSync(path.join(build,'release.json')));
  for(const key of ['version','model_sha256','code_sha256','front_sha256'])if(release[key]!==profile[key])throw Error('Prepared release identity differs: '+key);
  const native=path.join(build,'native');
  const metadata=JSON.parse(fs.readFileSync(path.join(native,'build.json')));
  for(const key of ['version','model_sha256','code_sha256','front_sha256'])if(metadata[key]!==profile[key])throw Error('Native metadata differs from the pinned profile: '+key);
  for(const [name,key]of [['front.rxe','front_sha256'],['code.rxe','code_sha256']])if(sha(fs.readFileSync(path.join(native,name)))!==profile[key])throw Error('Prepared native role differs from the pinned profile: '+name);
  for(const [name,digest] of Object.entries(release.archives.native.files))if(sha(fs.readFileSync(path.join(native,name)))!==digest)throw Error('Prepared native asset changed: '+name);
  if(sha(fs.readFileSync(path.join(native,'model.rvp')))!==profile.model_sha256)throw Error('Prepared training seed changed; keep sessions separate');
  return native;
}

let result;
if(operation==='prepare') {
  const {prepare}=await load('integration/x08/prepare.mjs');
  result=prepare(build);
  fs.writeFileSync(path.join(build,'reverse-x08.json'),JSON.stringify({format:1,version:profile.version,bbyq_commit:profile.commit},null,2)+'\n',{flag:'wx'});
} else {
  const native=validatePrepared();
  if(operation==='verify')result={ok:true,version:profile.version,bbyq_commit:profile.commit,model_sha256:profile.model_sha256,android_apk_updated:false};
  else if(operation==='init') {
    const {initialize}=await load('ai/personal/x08/session.mjs');
    result=initialize(required('session'),native);
  } else if(operation==='turn') {
    const {transact}=await load('ai/personal/x08/session.mjs');
    if(!options.id||(!Object.hasOwn(options,'text')&&!options.file)||options.file&&Object.hasOwn(options,'text'))throw Error('Use --id and exactly one of --text or --file');
    const message=options.file?fs.readFileSync(path.resolve(options.file)):options.text;
    result=transact(required('runtime'),native,required('session'),options.id,message);
  } else if(operation==='migrate') {
    result=JSON.parse(execFileSync(process.execPath,[path.join(source,'ai/personal/x08/migrate.mjs'),required('runtime'),native,required('state'),required('output')],{encoding:'utf8',timeout:300000,maxBuffer:16*1024*1024}));
  } else throw Error('Operations: prepare, verify, init, turn, migrate');
}
console.log(JSON.stringify(result));
if(!result.ok)process.exitCode=1;
