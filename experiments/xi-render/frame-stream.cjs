'use strict';
const crypto=require('node:crypto');
const LIMITS={maxWidth:8192,maxHeight:8192,maxPixels:16777216,maxCommands:1000000,maxBytes:33554432};
function valid(c,m){if(!c)throw Error('XFS1 '+m)}
function number(n,min,max,name){valid(Number.isSafeInteger(n)&&n>=min&&n<=max,'invalid '+name);return n}
function fromXI(text,width,height,revision=1){
 number(width,1,8192,'width');number(height,1,8192,'height');number(revision,0,4294967295,'revision');
 valid(width*height<=LIMITS.maxPixels,'pixel budget');
 const lines=text.trim().split('\n').filter(Boolean);
 valid(lines.length===4*height,'XI row count');
 const commands=[];
 for(let y=0;y<height;y++){
  const vals=lines.slice(y*4,y*4+4).map((s,i)=>{
   const row=JSON.parse(s);
   valid(row.type==='register'&&row.register==='r'+(12+i),'XI register');
   return number(row.value,-1,width-1,'XI coordinate');
  });
  for(let i=0;i<2;i++){
   const l=vals[2*i],r=vals[2*i+1];
   if(l===-1&&r===-1)continue;
   valid(l>=0&&r>=l&&r<width,'XI interval');
   commands.push({y,x0:l,x1:r,material:i===0?2:3,depth:i===0?200:100});
  }
 }
 return encode({width,height,revision,commands});
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
 const count=(b.length-24)/14;valid(count<=LIMITS.maxCommands,'command budget');
 const end=b.length-8;
 valid(b[end]===3&&b[end+1]===0&&b.readUInt16LE(end+2)===0&&b.readUInt32LE(end+4)===rev,'frame end');
 const pixels=Buffer.alloc(w*h),depth=new Uint16Array(w*h);depth.fill(65535);
 for(let p=16;p<end;p+=14){
  valid(b[p]===2,'opcode');
  const material=b[p+1],y=b.readUInt16LE(p+2),x0=b.readUInt16LE(p+4),
    x1=b.readUInt16LE(p+6),z=b.readUInt16LE(p+8),revision=b.readUInt32LE(p+10);
  valid((material===2||material===3)&&y<h&&x0<=x1&&x1<w&&z>0&&revision===rev,'invalid span');
  for(let x=x0;x<=x1;x++){const i=y*w+x;if(z<depth[i]){depth[i]=z;pixels[i]=material}}
 }
 return {width:w,height:h,revision:rev,pixels,commands:count,
  sha256:crypto.createHash('sha256').update(pixels).digest('hex')};
}
module.exports={fromXI,encode,decode,LIMITS};
