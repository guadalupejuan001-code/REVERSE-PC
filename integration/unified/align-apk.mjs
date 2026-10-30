import fs from 'node:fs';
// ZIP32 byte-preserving alignment. Only local extra fields and directory offsets
// change; compressed streams, names, CRCs and sizes retain their exact bytes.
export function alignApk(input,output){
 const b=fs.readFileSync(input);let end=-1;for(let p=b.length-22;p>=Math.max(0,b.length-65557);p--)if(b.readUInt32LE(p)===0x06054b50&&p+22+b.readUInt16LE(p+20)===b.length){end=p;break;}
 if(end<0||b.readUInt16LE(end+4)||b.readUInt16LE(end+6))throw Error('Single-disk ZIP32 required');
 const count=b.readUInt16LE(end+10),offset=b.readUInt32LE(end+16);if(count===65535||offset===0xffffffff)throw Error('ZIP64 requires a separate builder');
 const locals=[],directory=[];let pos=0,p=offset,aligned=0;
 for(let i=0;i<count;i++){
  if(b.readUInt32LE(p)!==0x02014b50)throw Error('Invalid ZIP directory');const n=b.readUInt16LE(p+28),x=b.readUInt16LE(p+30),c=b.readUInt16LE(p+32),central=Buffer.from(b.subarray(p,p+46+n+x+c)),name=b.subarray(p+46,p+46+n).toString(),at=b.readUInt32LE(p+42),size=b.readUInt32LE(p+20),method=b.readUInt16LE(p+10),flags=b.readUInt16LE(p+8);
  if(b.readUInt32LE(at)!==0x04034b50)throw Error('Invalid local ZIP header');const nameBytes=b.readUInt16LE(at+26),extra=b.readUInt16LE(at+28),data=at+30+nameBytes+extra;
  const alignment=method===0?(name.startsWith('lib/')&&name.endsWith('.so')?16384:4):1;
  let added=Buffer.alloc(0);if(alignment>1&&(pos+30+nameBytes+extra)%alignment){const padding=(alignment-(pos+30+nameBytes+extra+6)%alignment)%alignment;added=Buffer.alloc(6+padding);added.writeUInt16LE(0xd935,0);added.writeUInt16LE(2+padding,2);added.writeUInt16LE(alignment,4);aligned++;}
  if(extra+added.length>65535||data+size>b.length)throw Error('ZIP member exceeds its bounds');const head=Buffer.from(b.subarray(at,data));head.writeUInt16LE(extra+added.length,28);central.writeUInt32LE(pos,42);
  let descriptor=0;if(flags&8)descriptor=b.readUInt32LE(data+size)===0x08074b50?16:12;
  locals.push(head,added,b.subarray(data,data+size+descriptor));pos+=head.length+added.length+size+descriptor;directory.push(central);p+=46+n+x+c;
 }
 const cd=Buffer.concat(directory),tail=Buffer.from(b.subarray(end));tail.writeUInt32LE(cd.length,12);tail.writeUInt32LE(pos,16);fs.writeFileSync(output,Buffer.concat([...locals,cd,tail]));return {members:count,padded:aligned,bytes:pos+cd.length+tail.length};
}
export function verifyApkAlignment(file){
 const b=fs.readFileSync(file);let p=b.length-22;while(p>=0&&b.readUInt32LE(p)!==0x06054b50)p--;if(p<0)throw Error('Missing ZIP end');let at=b.readUInt32LE(p+16),count=b.readUInt16LE(p+10),native=0,stored=0;
 for(let i=0;i<count;i++){if(b.readUInt32LE(at)!==0x02014b50)throw Error('Invalid directory');const n=b.readUInt16LE(at+28),x=b.readUInt16LE(at+30),c=b.readUInt16LE(at+32),name=b.subarray(at+46,at+46+n).toString(),method=b.readUInt16LE(at+10),local=b.readUInt32LE(at+42),start=local+30+b.readUInt16LE(local+26)+b.readUInt16LE(local+28);
  if(name==='resources.arsc'&&method!==0)throw Error('resources.arsc must be stored');if(method===0){if(start%4)throw Error('Unaligned stored member: '+name);stored++;if(name.startsWith('lib/')&&name.endsWith('.so')){if(start%16384)throw Error('Unaligned native library: '+name);native++;}}at+=46+n+x+c;
 }if(native!==4)throw Error('Both engines and ABIs are required');return {members:count,stored,native_libraries:native,alignment_16kb:true};
}
if(process.argv[1]&&new URL('file:'+process.argv[1]).pathname===import.meta.filename){console.log(JSON.stringify(process.argv[3]?alignApk(process.argv[2],process.argv[3]):verifyApkAlignment(process.argv[2])));}
