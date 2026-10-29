import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {auditGkiRvg} from '../tools/audit_gki_rvg.mjs';

const sha = bytes => createHash('sha256').update(bytes).digest('hex');
function setFnv(bytes) {
  const mask=0xffffffffffffffffn;
  let h=14695981039346656037n;
  for(let i=0;i<bytes.length-8;i++)
    h=((h^BigInt(bytes[i]))*1099511628211n)&mask;
  bytes.writeBigUInt64LE(h,bytes.length-8);
}
function fixture() {
  // Synthetic *metadata* only; not an Android, Linux or CPU boot.
  const kernel=Buffer.alloc(64);kernel.writeUInt32LE(0x644d5241,56);
  const image=Buffer.alloc(32+kernel.length);
  image.set([82,86,73,49,13,10,26,10]);
  image.writeBigUInt64LE(BigInt(kernel.length),8);kernel.copy(image,32);
  const bytes=Buffer.alloc(8+43*8+image.length+1+8);
  bytes.set([82,86,71,50,13,10,26,10]);
  bytes.writeBigUInt64LE(134217728n,8); // 128 MiB logical RAM
  bytes.writeBigUInt64LE(0n,16); // adaptive InverseMemory
  bytes.writeBigUInt64LE(64n,8+4*8); // instructions
  bytes.writeBigUInt64LE(BigInt(image.length),8+39*8);
  bytes.writeBigUInt64LE(1n,8+42*8); // synthetic state size
  image.copy(bytes,8+43*8);
  setFnv(bytes);
  return {bytes,kernel};
}
test('read-only GKI RVG2/RVI1 kernel and checkpoint provenance',()=>{
  const {bytes,kernel}=fixture();
  const result=auditGkiRvg(bytes,sha(kernel),sha(bytes));
  assert.equal(result.status,'read_only_provenance_verified');
  assert.equal(result.instructions,64);
  assert.equal(result.kernel_bytes,64);
  assert.equal(result.classical_override_limit,'0');
  assert.equal(result.android_init_observed,false);
});
test('reject unexpected kernel identity or wrong checkpoint',()=>{
  const {bytes,kernel}=fixture();
  assert.throws(()=>auditGkiRvg(bytes,'0'.repeat(64),sha(bytes)),
    /kernel SHA256 pin mismatch/);
  assert.throws(()=>auditGkiRvg(bytes,sha(kernel),'0'.repeat(64)),
    /checkpoint SHA256 pin mismatch/);
});
test('reject modified RVG body even with a new external SHA',()=>{
  const {bytes,kernel}=fixture();bytes[bytes.length-9]^=1;
  assert.throws(()=>auditGkiRvg(bytes,sha(kernel),sha(bytes)),
    /RVG internal checksum mismatch/);
});
test('reject forged RVI1 extent with correctly recomputed RVG checksum',()=>{
  const {bytes,kernel}=fixture();
  bytes.writeBigUInt64LE(999n,8+43*8+8);
  setFnv(bytes);
  assert.throws(()=>auditGkiRvg(bytes,sha(kernel),sha(bytes)),
    /RVI1 section extents invalid/);
});
test('reject invalid magic and excessive snapshot',()=>{
  const {bytes,kernel}=fixture();bytes[0]=0;
  assert.throws(()=>auditGkiRvg(bytes,sha(kernel),sha(bytes)),
    /RVG2\/RVG3/);
  assert.throws(()=>auditGkiRvg(Buffer.alloc(256*1024*1024)),
    /snapshot size invalid/);
});
