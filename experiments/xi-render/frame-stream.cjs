'use strict';
const crypto=require('node:crypto');
const LIMITS={maxWidth:8192,maxHeight:8192,maxPixels:16777216,maxCommands:1000000,maxBytes:33554432};
function valid(c,m){if(!c)throw Error('XFS1 '+m)}
function number(n,min,max,name){valid(Number.isSafeInteger(n)&&n>=min&&n<=max,'invalid '+name);return n}
function fromXI(text,width,height,revision=1){
 number(width,1,8192,'width');number(height,1,8192,'height');
 number(revision,0,4294967295,'revision');
 valid(width*height<=LIMITS.maxPixels,'pixel budget');
 valid(typeof text==='string'&&text.length<=LIMITS.maxBytes,'XI output size');
 const lines=text.trim().split('\n').filter(Boolean);
 valid(lines.length===4*height,'XI row count');
 // One allocation and one scan: never construct a temporary command object
 // list, then traverse that list again to encode the same XI observation.
 const b=Buffer.alloc(24+28*height);
 b.write('XFS1',0,'ascii');b[4]=1;
 b.writeUInt16LE(width,6);b.writeUInt16LE(height,8);b.writeUInt32LE(revision,10);
 const values=new Int32Array(4);
 let offset=16;
 for(let y=0;y<height;y++){
  for(let i=0;i<4;i++){
   const row=JSON.parse(lines[4*y+i]);
   valid(row.type==='register'&&row.register==='r'+(12+i),'XI register');
   values[i]=number(row.value,-1,width-1,'XI coordinate');
  }
  for(let i=0;i<2;i++){
   const l=values[2*i],r=values[2*i+1];
   if(l===-1&&r===-1)continue;
   valid(l>=0&&r>=l&&r<width,'XI interval');
   b[offset]=2;b[offset+1]=i===0?2:3;
   b.writeUInt16LE(y,offset+2);b.writeUInt16LE(l,offset+4);
   b.writeUInt16LE(r,offset+6);b.writeUInt16LE(i===0?200:100,offset+8);
   b.writeUInt32LE(revision,offset+10);offset+=14;
  }
 }
 b[offset]=3;b.writeUInt32LE(revision,offset+4);
 // Only valid bytes are published; no uninitialized data, no copy.
 return b.subarray(0,offset+8);
}
function encode({width,height,revision,commands}){
 number(width,1,8192,'width');number(height,1,8192,'height');
 number(revision,0,4294967295,'revision');
 valid(width*height<=LIMITS.maxPixels,'pixel budget');
 valid(Array.isArray(commands)&&commands.length<=LIMITS.maxCommands,'command budget');
 const size=24+14*commands.length;
 valid(size<=LIMITS.maxBytes,'byte budget');
 const b=Buffer.alloc(size);
 b.write('XFS1',0,'ascii');b[4]=1;
 b.writeUInt16LE(width,6);b.writeUInt16LE(height,8);b.writeUInt32LE(revision,10);
 let offset=16;
 for(const c of commands){
  number(c.y,0,height-1,'y');number(c.x0,0,width-1,'x0');
  number(c.x1,c.x0,width-1,'x1');number(c.material,0,255,'material');
  number(c.depth,1,65535,'depth');
  b[offset]=2;b[offset+1]=c.material;b.writeUInt16LE(c.y,offset+2);
  b.writeUInt16LE(c.x0,offset+4);b.writeUInt16LE(c.x1,offset+6);
  b.writeUInt16LE(c.depth,offset+8);b.writeUInt32LE(revision,offset+10);
  offset+=14;
 }
 b[offset]=3;b.writeUInt32LE(revision,offset+4);
 return b;
}
function decode(b,{maxPixels=LIMITS.maxPixels,maxBytes=LIMITS.maxBytes}={}){
 valid(Buffer.isBuffer(b)&&b.length>=24&&b.length<=maxBytes,'frame length');
 valid(b.toString('ascii',0,4)==='XFS1'&&b[4]===1,'magic/version');
 valid(b[5]===0&&b.readUInt16LE(14)===0,'reserved');
 const w=b.readUInt16LE(6),h=b.readUInt16LE(8),rev=b.readUInt32LE(10);
 number(w,1,8192,'width');number(h,1,8192,'height');
 valid(w*h<=maxPixels,'pixel budget');
 valid((b.length-24)%14===0,'alignment');
 const count=(b.length-24)/14;
 valid(count<=LIMITS.maxCommands,'command budget');
 const end=b.length-8;
 valid(b[end]===3&&b[end+1]===0&&b.readUInt16LE(end+2)===0&&b.readUInt32LE(end+4)===rev,'frame end');

 // Validate the entire frame before publishing any visible image.
 // Each span is already a *visible-region descriptor*; drawing it with
 // Buffer.fill avoids a redundant uint16 depth allocation and one JS
 // depth comparison for every covered pixel. Far spans are painted first.
 // For equal-depth overlaps the earliest input span must win, so the
 // secondary sort is by descending input offset.
 const rows=Array.from({length:h},()=>[]);
 for(let p=16;p<end;p+=14){
  valid(b[p]===2,'opcode');
  const material=b[p+1],y=b.readUInt16LE(p+2),x0=b.readUInt16LE(p+4),
    x1=b.readUInt16LE(p+6),z=b.readUInt16LE(p+8),revision=b.readUInt32LE(p+10);
  valid((material===2||material===3)&&y<h&&x0<=x1&&x1<w&&z>0&&revision===rev,'invalid span');
  rows[y].push({material,x0,x1,z,offset:p});
 }
 const pixels=Buffer.alloc(w*h);
 for(let y=0;y<h;y++){
  const row=rows[y];
  row.sort((a,b)=>(b.z-a.z)||(b.offset-a.offset));
  const rowBase=y*w;
  for(const c of row)pixels.fill(c.material,rowBase+c.x0,rowBase+c.x1+1);
 }
 return {width:w,height:h,revision:rev,pixels,commands:count,
  sha256:crypto.createHash('sha256').update(pixels).digest('hex')};
}
module.exports={fromXI,encode,decode,LIMITS};
