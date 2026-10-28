// Deterministic *synthetic container* regression tests; no Android boot is simulated.
import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {execFileSync,spawnSync} from 'node:child_process';
import {readFileSync,writeFileSync,mkdtempSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {fileURLToPath} from 'node:url';
import {inspect,bootParts,vendorParts} from '../tools/aosp_boot_preflight.mjs';
const align=(x,p)=>Math.ceil(x/p)*p;
const sha=x=>createHash('sha256').update(x).digest('hex');
const kernel=Buffer.alloc(140);kernel.write('ARMd',56);kernel.write('NOT_EXECUTABLE',72);
const generic=Buffer.from('not-a-real-init-CPIO');
const vendorRamdisk=Buffer.from('not-a-real-vendor-CPIO');
const dtb=Buffer.alloc(64);dtb.writeUInt32BE(0xd00dfeed,0);
function boot(ver,{k=kernel,r=generic,s=Buffer.alloc(0)}={}){
  const ka=4096,ra=align(ka+k.length,4096),sa=align(ra+r.length,4096);
  const b=Buffer.alloc(Math.max(4096,ka+k.length,ra+r.length,sa+s.length));
  b.write('ANDROID!');b.writeUInt32LE(k.length,8);b.writeUInt32LE(r.length,12);
  b.writeUInt32LE(ver===3?1580:1584,20);b.writeUInt32LE(ver,40);
  if(ver===4)b.writeUInt32LE(s.length,1580);
  k.copy(b,ka);r.copy(b,ra);s.copy(b,sa);return b;
}
function vendor(ver,{r=vendorRamdisk,d=dtb,pg=4096,entries=null,config=Buffer.alloc(0)}={}){
  const pieces=entries??(ver===4?[{size:r.length,offset:0,type:1,name:'platform'}]:[]);
  const t=Buffer.alloc(ver===4?pieces.length*108:0);
  pieces.forEach((x,n)=>{const p=n*108;t.writeUInt32LE(x.size,p);t.writeUInt32LE(x.offset,p+4);
    t.writeUInt32LE(x.type,p+8);t.write(x.name,p+12);});
  const head=ver===3?2112:2128,ra=align(head,pg),da=align(ra+r.length,pg),
    ta=align(da+d.length,pg),ca=align(ta+t.length,pg);
  const b=Buffer.alloc(Math.max(head,ra+r.length,da+d.length,ta+t.length,ca+config.length));
  b.write('VNDRBOOT');b.writeUInt32LE(ver,8);b.writeUInt32LE(pg,12);
  b.writeUInt32LE(0x40080000,16);b.writeUInt32LE(0x41000000,20);
  b.writeUInt32LE(r.length,24);b.write('synthetic',2080);
  b.writeUInt32LE(head,2096);b.writeUInt32LE(d.length,2100);b.writeBigUInt64LE(0x40070000n,2104);
  if(ver===4){b.writeUInt32LE(t.length,2112);b.writeUInt32LE(pieces.length,2116);
    b.writeUInt32LE(108,2120);b.writeUInt32LE(config.length,2124);}
  r.copy(b,ra);d.copy(b,da);t.copy(b,ta);config.copy(b,ca);return b;
}
for(const ver of [3,4]){
  test('v'+ver+' exact AOSP section offsets, raw bytes and hashes',()=>{
    const b=boot(ver,{s:ver===4?Buffer.from('signature-fixture'):Buffer.alloc(0)});
    const v=vendor(ver);
    const x=inspect(b,v);
    assert.equal(x.manifest.android_boot,false);
    assert.equal(x.manifest.boot.sha256,sha(b));
    assert.equal(x.manifest.boot.kernel.offset,4096);
    assert.equal(x.manifest.boot.generic_ramdisk.offset,8192);
    assert.equal(x.manifest.vendor_boot.ramdisk.offset,4096);
    assert.equal(x.manifest.vendor_boot.dtb.offset,8192);
    assert.deepEqual(x.segments.kernel,kernel);
    assert.deepEqual(x.segments.generic_ramdisk,generic);
    assert.deepEqual(x.segments.vendor_ramdisk,vendorRamdisk);
    assert.deepEqual(x.segments.vendor_dtb,dtb);
  });
  test('v'+ver+' rejects truncated kernel or falsely huge payload',()=>{
    const b=boot(ver);b.writeUInt32LE(99999999,8);
    assert.throws(()=>inspect(b,vendor(ver)),/truncated/);
  });
  test('v'+ver+' rejects truncated DTB',()=>{
    const v=vendor(ver);v.writeUInt32LE(99999999,2100);
    assert.throws(()=>inspect(boot(ver),v),/truncated/);
  });
}
test('v4 init_boot supplies separated generic ramdisk',()=>{
  const b=boot(4,{r:Buffer.alloc(0)}),i=boot(4,{k:Buffer.alloc(0)});
  const x=inspect(b,vendor(4),i);
  assert.equal(x.manifest.generic_ramdisk_from,'init_boot');
  assert.deepEqual(x.segments.generic_ramdisk,generic);
  assert.match(inspect(b,vendor(4)).manifest.pending.join(' '),/init_boot/);
});
test('no duplicate ramdisks, no mixing incompatible header versions',()=>{
  assert.throws(()=>inspect(boot(4),vendor(4),boot(4,{k:Buffer.alloc(0)})),/duplicate/);
  assert.throws(()=>inspect(boot(3),vendor(3),boot(4,{k:Buffer.alloc(0)})),/requires v4/);
  assert.throws(()=>inspect(boot(4),vendor(3)),/mismatch/);
});
test('v4 ramdisk fragment ranges fail closed and selection remains explicit',()=>{
  const bad=vendor(4,{entries:[{offset:10,size:9000,type:1,name:'platform'}]});
  assert.throws(()=>inspect(boot(4),bad),/outside/);
  const good=vendor(4,{entries:[{offset:0,size:4,type:1,name:'platform'},
    {offset:4,size:4,type:3,name:'dlkm'}]});
  const x=inspect(boot(4),good);
  assert.deepEqual(x.manifest.vendor_boot.fragments.map(z=>z.type),[1,3]);
  assert.match(x.manifest.pending.join(' '),/selection/);
});
test('invalid magic, header versions, vendor page size and header length rejected',()=>{
  const b=boot(4);b.write('INVALID!',0);
  assert.throws(()=>bootParts(b),/magic/);
  const b2=boot(4);b2.writeUInt32LE(5,40);
  assert.throws(()=>bootParts(b2),/unsupported/);
  assert.throws(()=>vendorParts(vendor(4,{pg:3000})),/page size/);
});
test('CLI extracts exact original bytes, records hashes, never overwrites outputs',()=>{
  const root=mkdtempSync(join(tmpdir(),'reverse-aosp-'));
  const b=join(root,'boot.img'),v=join(root,'vendor_boot.img'),out=join(root,'out');
  const script=fileURLToPath(new URL('../tools/aosp_boot_preflight.mjs',import.meta.url));
  writeFileSync(b,boot(4));writeFileSync(v,vendor(4));
  const result=JSON.parse(execFileSync('node',[script,'--boot',b,'--vendor-boot',v,'--extract-dir',out],{encoding:'utf8'}));
  assert.equal(result.android_boot,false);
  assert.deepEqual(readFileSync(join(out,'kernel.bin')),kernel);
  assert.deepEqual(readFileSync(join(out,'generic_ramdisk.bin')),generic);
  assert.equal(JSON.parse(readFileSync(join(out,'manifest.json'),'utf8')).boot.kernel.sha256,sha(kernel));
  const again=spawnSync('node',[script,'--boot',b,'--vendor-boot',v,'--extract-dir',out],{encoding:'utf8'});
  assert.notEqual(again.status,0);
});
