import fs from 'node:fs';import crypto from 'node:crypto';
export function rebind(input,output){
 const b=fs.readFileSync(input);if(b.subarray(0,5).toString('hex')!=='7f454c4602'||b[5]!==1)throw Error('ELF64 little-endian required');
 const off=Number(b.readBigUInt64LE(40)),stride=b.readUInt16LE(58),count=b.readUInt16LE(60),strings=b.readUInt16LE(62);
 const namesAt=Number(b.readBigUInt64LE(off+stride*strings+24));let dyn,text;const sections=new Map();
 for(let i=0;i<count;i++){const p=off+i*stride,n=namesAt+b.readUInt32LE(p),name=b.subarray(n,b.indexOf(0,n)).toString();const start=Number(b.readBigUInt64LE(p+24)),size=Number(b.readBigUInt64LE(p+32)),entry=Number(b.readBigUInt64LE(p+56));sections.set(name,{start,size,entry});if(name==='.dynstr')dyn={start,size};if(name==='.text')text={start,size};}
 if(!dyn||!text)throw Error('ELF sections unavailable');const sha=x=>crypto.createHash('sha256').update(x).digest('hex'),before=sha(b.subarray(text.start,text.start+text.size));
 const old=Buffer.from('Java_com_reversepc_os_NativeRuntime_'),next=Buffer.from('Java_com_reversepc_os_RenderRuntime_');if(old.length!==next.length)throw Error('Binding length differs');let changed=0;
 for(let p=dyn.start;p<dyn.start+dyn.size;){const end=b.indexOf(0,p);if(end<0||end>=dyn.start+dyn.size)throw Error('Invalid dynamic strings');if(b.subarray(p,p+old.length).equals(old)){next.copy(b,p);changed++;}p=end+1;}
 if(changed<8||sha(b.subarray(text.start,text.start+text.size))!==before)throw Error('Unexpected JNI surface');
 // Dynamic lookup hashes refer to names, so update both supported hash formats.
 // Keep symbol indices and all relocations unchanged. A single GNU bucket makes
 // the existing index order a valid contiguous chain without reordering symbols.
 const symbols=sections.get('.dynsym');if(!symbols||symbols.entry!==24)throw Error('ELF64 symbol table required');const symbolCount=symbols.size/24;
 const symbolName=i=>{const at=dyn.start+b.readUInt32LE(symbols.start+i*24);return b.subarray(at,b.indexOf(0,at));};
 const gnuHash=name=>{let h=5381;for(const c of name)h=(Math.imul(h,33)+c)>>>0;return h;};
 const gh=sections.get('.gnu.hash');if(gh){const start=gh.start,symoffset=b.readUInt32LE(start+4),words=b.readUInt32LE(start+8),shift=b.readUInt32LE(start+12),needed=16+words*8+4+(symbolCount-symoffset)*4;if(!words||(words&(words-1))||symoffset>symbolCount||needed>gh.size)throw Error('Invalid GNU hash dimensions');
  b.fill(0,start,start+gh.size);b.writeUInt32LE(1,start);b.writeUInt32LE(symoffset,start+4);b.writeUInt32LE(words,start+8);b.writeUInt32LE(shift,start+12);const buckets=start+16+words*8,chains=buckets+4;b.writeUInt32LE(symoffset<symbolCount?symoffset:0,buckets);
  for(let i=symoffset;i<symbolCount;i++){const h=gnuHash(symbolName(i)),word=(h>>>6)&(words-1),p=start+16+word*8,bits=(1n<<BigInt(h%64))|(1n<<BigInt((h>>>shift)%64));b.writeBigUInt64LE(b.readBigUInt64LE(p)|bits,p);b.writeUInt32LE(((h&0xfffffffe)|(i===symbolCount-1?1:0))>>>0,chains+(i-symoffset)*4);}
 }
 const sh=sections.get('.hash');if(sh){const start=sh.start,buckets=b.readUInt32LE(start),chains=b.readUInt32LE(start+4);if(!buckets||chains!==symbolCount||8+4*(buckets+chains)>sh.size)throw Error('Invalid SysV hash dimensions');b.fill(0,start+8,start+sh.size);const last=new Uint32Array(buckets);for(let i=1;i<symbolCount;i++){let h=0;for(const c of symbolName(i)){h=((h<<4)+c)>>>0;const g=h&0xf0000000;if(g)h^=g>>>24;h=(h&~g)>>>0;}const slot=h%buckets;if(last[slot])b.writeUInt32LE(i,start+8+4*buckets+4*last[slot]);else b.writeUInt32LE(i,start+8+4*slot);last[slot]=i;}}
 if(!gh&&!sh)throw Error('No dynamic hash table');fs.writeFileSync(output,b);return {bindings:changed,text_sha256:before,code_unchanged:true,dynamic_hashes_updated:true,sha256:sha(b)};
}
if(process.argv[1]&&new URL('file:'+process.argv[1]).pathname===import.meta.filename)console.log(JSON.stringify(rebind(process.argv[2],process.argv[3])));
