#!/usr/bin/env node
// Host tooling only: raw/sparse partition inputs -> reproducible GPT disk.
// Never creates missing Android systems, bypasses AVB, or claims Android boot.
import {open,readFile,stat,unlink,link} from 'node:fs/promises';
import {createReadStream} from 'node:fs';
import {createHash,randomBytes} from 'node:crypto';
import {crc32} from 'node:zlib';
import {resolve,dirname} from 'node:path';
import {pathToFileURL} from 'node:url';
export const REQUIRED=['boot_a','init_boot_a','metadata','super','vbmeta_a','vbmeta_system_a','vbmeta_system_dlkm_a','vbmeta_vendor_dlkm_a'];
const need=(x,m)=>{if(!x)throw Error('Android GPT: '+m);};
const sha=b=>createHash('sha256').update(b).digest('hex');
const align=(n,a)=>Math.ceil(n/a)*a;
const MAX=2**40,CHUNK=1024*1024,ZERO=Buffer.alloc(CHUNK);
async function hashFile(path){const h=createHash('sha256');for await(const b of createReadStream(path))h.update(b);return h.digest('hex');}
async function exact(file,at,n){const b=Buffer.alloc(n);const r=await file.read(b,0,n,at);need(r.bytesRead===n,'truncated source image');return b;}
async function inspect(path){
 const f=await open(path,'r');try{
  const s=await f.stat();need(s.isFile()&&s.size>0&&s.size<=MAX,'invalid image size');
  const h=await exact(f,0,Math.min(28,s.size));
  if(h.length<4||h.readUInt32LE(0)!==0xed26ff3a)return {path,size:s.size,sparse:false,chunks:[{kind:0xcac1,at:0,length:s.size}]};
  need(h.length===28&&h.readUInt16LE(4)===1&&h.readUInt16LE(6)===0,'unsupported Android sparse version');
  const head=h.readUInt16LE(8),ch=h.readUInt16LE(10),block=h.readUInt32LE(12),blocks=h.readUInt32LE(16),count=h.readUInt32LE(20);
  need(head>=28&&head<=4096&&ch>=12&&ch<=4096&&block>=4&&block%4===0&&count<=1000000,'invalid sparse header');
  const size=blocks*block;need(size>0&&size<=MAX,'expanded sparse image exceeds disk limit');
  let at=head,total=0;const chunks=[];
  for(let i=0;i<count;i++){
   const c=await exact(f,at,ch),kind=c.readUInt16LE(0),n=c.readUInt32LE(4)*block,bytes=c.readUInt32LE(8);at+=ch;
   need([0xcac1,0xcac2,0xcac3,0xcac4].includes(kind)&&bytes>=ch&&at+bytes-ch<=s.size,'invalid sparse chunk');
   const payload=kind===0xcac1?n:kind===0xcac3?0:4;need(bytes-ch===payload&&(kind!==0xcac4||n===0),'sparse chunk size mismatch');
   chunks.push({kind,at,length:n});total+=n;at+=payload;
  }
  need(at===s.size&&total===size,'sparse image extents mismatch');
  return {path,size,sparse:true,chunks,checksum:h.readUInt32LE(24)};
 }finally{await f.close();}
}
async function copyImage(image,out,start){
 const source=await open(image.path,'r');let offset=0,checksum=0;
 try{for(const c of image.chunks){
  if(c.kind===0xcac4){need((await exact(source,c.at,4)).readUInt32LE(0)===checksum,'sparse CRC32 chunk mismatch');continue;}
  const fill=c.kind===0xcac2?await exact(source,c.at,4):null;
  for(let done=0;done<c.length;){const n=Math.min(CHUNK,c.length-done);let b;
   if(c.kind===0xcac1)b=await exact(source,c.at+done,n);
   else if(fill){b=Buffer.alloc(n);for(let i=0;i<n;i+=4)fill.copy(b,i);}
   else b=ZERO.subarray(0,n);
   checksum=crc32(b,checksum);
   if(c.kind!==0xcac3)need((await out.write(b,0,n,start+offset+done)).bytesWritten===n,'short disk write');
   done+=n;
  }offset+=c.length;
 }need(offset===image.size,'expanded copy length mismatch');if(image.checksum)need(image.checksum===checksum,'sparse image checksum mismatch');
 }finally{await source.close();}
}
function guid(text){const b=Buffer.from(sha(Buffer.from(text)).slice(0,32),'hex');b[7]=(b[7]&15)|0x50;b[8]=(b[8]&63)|0x80;return b;}
function header(lba,other,entriesLba,last,diskGuid,entries){const b=Buffer.alloc(512);b.write('EFI PART');b.writeUInt32LE(0x10000,8);b.writeUInt32LE(92,12);b.writeBigUInt64LE(BigInt(lba),24);b.writeBigUInt64LE(BigInt(other),32);b.writeBigUInt64LE(34n,40);b.writeBigUInt64LE(BigInt(last-33),48);diskGuid.copy(b,56);b.writeBigUInt64LE(BigInt(entriesLba),72);b.writeUInt32LE(128,80);b.writeUInt32LE(128,84);b.writeUInt32LE(crc32(entries),88);b.writeUInt32LE(crc32(b.subarray(0,92)),16);return b;}
export async function buildAndroidPartitionDisk(manifest,target,base=process.cwd()){
 need(manifest&&Array.isArray(manifest.partitions)&&manifest.partitions.length>0&&manifest.partitions.length<=128,'manifest needs 1..128 partitions');
 const fixture=manifest.purpose==='protocol-fixture';need(fixture||manifest.purpose==='android','purpose must be android or protocol-fixture');
 const names=new Set();for(const p of manifest.partitions){need(/^[a-z][a-z0-9_]{0,35}$/.test(p.name)&&!names.has(p.name),'invalid or duplicate partition name');names.add(p.name);}
 const missing=REQUIRED.filter(n=>!names.has(n));need(fixture||missing.length===0,'missing Android partitions: '+missing.join(', '));
 const images=[];let sector=2048;
 for(const p of manifest.partitions){
  need(typeof p.path==='string'&&resolve(base,p.path)!==resolve(target),'input/output paths overlap');const path=resolve(base,p.path),image=await inspect(path),hash=await hashFile(path);
  need(fixture||/^[a-f0-9]{64}$/.test(p.sha256??''),'Android images require expected source SHA-256');if(p.sha256)need(p.sha256===hash,'source SHA-256 mismatch for '+p.name);
  const bytes=p.partition_bytes??align(image.size,512);need(Number.isSafeInteger(bytes)&&bytes>=image.size&&bytes%512===0&&bytes<=MAX,'invalid partition capacity');
  const first=sector,last=first+bytes/512-1;images.push({...image,name:p.name,source_sha256:hash,first,last,partition_bytes:bytes});sector=align(last+1,2048);
 }
 const sectors=align(sector+33,2048);need(sectors*512<=MAX,'GPT disk exceeds 1 TiB');
 const identity=images.map(i=>i.name+':'+i.source_sha256+':'+i.partition_bytes).join('\n'),diskGuid=guid(identity),entries=Buffer.alloc(128*128);
 for(let i=0;i<images.length;i++){const p=images[i],at=i*128;Buffer.from('af3dc60f838472478e793d69d8477de4','hex').copy(entries,at);guid(identity+'\n'+p.name).copy(entries,at+16);entries.writeBigUInt64LE(BigInt(p.first),at+32);entries.writeBigUInt64LE(BigInt(p.last),at+40);Buffer.from(p.name,'utf16le').copy(entries,at+56);}
 const mbr=Buffer.alloc(512);mbr[450]=0xee;mbr.writeUInt32LE(1,454);mbr.writeUInt32LE(Math.min(sectors-1,0xffffffff),458);mbr[510]=0x55;mbr[511]=0xaa;
 const temporary=resolve(target)+'.partial-'+randomBytes(8).toString('hex');let f;
 try{f=await open(temporary,'wx');await f.truncate(sectors*512);await f.write(mbr,0,512,0);await f.write(header(1,sectors-1,2,sectors-1,diskGuid,entries),0,512,512);await f.write(entries,0,entries.length,1024);
  for(const image of images)await copyImage(image,f,image.first*512);
  await f.write(entries,0,entries.length,(sectors-33)*512);await f.write(header(sectors-1,1,sectors-33,sectors-1,diskGuid,entries),0,512,(sectors-1)*512);await f.sync();await f.close();f=null;
  const digest=await hashFile(temporary);await link(temporary,resolve(target));await unlink(temporary);
  return {status:fixture?'gpt_protocol_fixture_created':'android_partition_disk_created_avb_not_verified',disk_bytes:sectors*512,disk_sha256:digest,gpt_primary_and_backup:true,source_payloads_preserved:true,missing_android_partitions:missing,fixture,android_boot_verified:false,avb_verified:false,partitions:images.map(i=>({name:i.name,first_lba:i.first,last_lba:i.last,source_bytes:i.size,source_sha256:i.source_sha256,source_sparse:i.sparse}))};
 }catch(e){if(f)await f.close();await unlink(temporary).catch(()=>{});throw e;}
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){try{const [input,output]=process.argv.slice(2);need(input&&output,'usage: manifest.json new-disk.raw');console.log(JSON.stringify(await buildAndroidPartitionDisk(JSON.parse(await readFile(input,'utf8')),resolve(output),dirname(resolve(input))),null,2));}catch(e){console.error(e.message);process.exitCode=1;}}
