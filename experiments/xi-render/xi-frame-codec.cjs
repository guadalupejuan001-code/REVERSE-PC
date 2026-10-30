'use strict';
// XFS1 is a byte transport, NOT a second geometry engine.
// The entire scene is defined by XI; the host only checks and materializes
// authored rectangles/spans with deterministic depth testing.
const assert=require('node:assert/strict');
const HEADER_BYTES=40,RECORD_BYTES=28;
const MAX_U64=(1n<<64n)-1n;
function digest(packet){
 let h=14695981039346656037n;
 for(let i=0;i<packet.length;i++){
   const b=i>=32&&i<40?0:packet[i];
   h=((h^BigInt(b))*1099511628211n)&MAX_U64;
 }
 return h;
}
function decodeFrameStream(text){
 const rows=text.split('\n').filter(x=>x.trim()).map(x=>JSON.parse(x));
 assert.equal(rows.length,1,'one committed XI frame per transaction');
 const event=rows[0];
 assert.equal(event.type,'xi_frame_stream');
 assert.equal(event.format,'XFS1');
 assert.equal(event.encoding,'base64');
 assert(typeof event.payload==='string'&&
   /^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$/.test(event.payload),
   'noncanonical frame payload encoding');
 const packet=Buffer.from(event.payload,'base64');
 assert(packet.length>=HEADER_BYTES,'truncated frame header');
 assert.equal(packet.toString('ascii',0,4),'XFS1');
 assert.equal(packet.readUInt32LE(4),HEADER_BYTES);
 const width=packet.readUInt32LE(8),height=packet.readUInt32LE(12);
 const revision=packet.readBigUInt64LE(16);
 const background=packet.readUInt32LE(24),count=packet.readUInt32LE(28);
 assert(width>0&&height>0,'invalid viewport');
 assert(Number.isSafeInteger(width*height),'logical pixel count overflow');
 assert.equal(count,(packet.length-HEADER_BYTES)/RECORD_BYTES,'invalid record count or trailing bytes');
 assert.equal(packet.length,HEADER_BYTES+count*RECORD_BYTES,'packet length mismatch');
 assert.equal(packet.readBigUInt64LE(32),digest(packet),'XFS1 checksum mismatch');
 assert.equal(event.width,width);assert.equal(event.height,height);
 assert.equal(BigInt(event.revision),revision);
 assert.equal(event.records,count);
 const records=[];
 for(let i=0;i<count;i++){
  const p=HEADER_BYTES+i*RECORD_BYTES;
  const kind=packet.readUInt32LE(p),a=packet.readUInt32LE(p+4);
  const b=packet.readUInt32LE(p+8),c=packet.readUInt32LE(p+12);
  const d=packet.readUInt32LE(p+16),argb=packet.readUInt32LE(p+20);
  const depth=packet.readUInt32LE(p+24);
  assert(kind===1||kind===2,'unknown record kind');
  if(kind===1)assert(a<height&&b<=c&&c<width&&d===0,'invalid span bounds');
  else assert(a<width&&b<height&&c>0&&d>0&&c<=width-a&&d<=height-b,
    'invalid tile bounds');
  records.push({kind,a,b,c,d,argb,depth});
 }
 return {width,height,revision,background,recordCount:count,records,packet};
}
function materializeFrameStreams(streams,{maxPixels=2400000}={}){
 assert(Array.isArray(streams)&&streams.length>0);
 const first=streams[0];
 const count=first.width*first.height;
 assert(Number.isSafeInteger(count)&&count>0&&count<=maxPixels,
    'materialization denied by explicit memory budget');
 const rgba=new Uint32Array(count),z=new Uint32Array(count);
 rgba.fill(first.background);z.fill(0xffffffff);
 let records=0;
 for(const frame of streams){
  assert(frame.width===first.width&&frame.height===first.height&&
         frame.revision===first.revision&&frame.background===first.background,
         'incompatible stream fragment');
  for(const r of frame.records){
   const apply=(row,left,right)=>{
    for(let idx=row*frame.width+left,stop=row*frame.width+right;idx<stop;idx++)
      if(r.depth<=z[idx]){z[idx]=r.depth;rgba[idx]=r.argb;}
   };
   if(r.kind===1)apply(r.a,r.b,r.c+1);
   else for(let y=r.b;y<r.b+r.d;y++)apply(y,r.a,r.a+r.c);
   records++;
  }
 }
 return {width:first.width,height:first.height,revision:first.revision,rgba,depth:z,records};
}
module.exports={decodeFrameStream,materializeFrameStreams,digest,HEADER_BYTES,RECORD_BYTES};
