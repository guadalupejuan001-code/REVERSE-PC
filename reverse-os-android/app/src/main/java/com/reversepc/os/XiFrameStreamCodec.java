package com.reversepc.os;

import java.util.Arrays;
import java.util.List;

/**
 * Host-side XFS1 binary verifier and framebuffer materializer.
 * Scene geometry, color, depth and order are authored by XI Machine v1.
 * This class NEVER projects geometry or computes game-world rules.
 */
public final class XiFrameStreamCodec {
    private XiFrameStreamCodec() {}
    private static final int HEADER_BYTES=40, RECORD_BYTES=28;
    private static final long FNV_OFFSET=0xcbf29ce484222325L;
    private static final long FNV_PRIME=0x100000001b3L;

    public static final class Frame {
        public final int width,height,background,recordCount;
        public final long revision;
        private final int[] records;
        private Frame(int w,int h,long revision,int bg,int count,int[] records){
            this.width=w;this.height=h;this.revision=revision;
            this.background=bg;this.recordCount=count;this.records=records;
        }
    }
    private static long u32(byte[] p,int offset){
        return ((long)p[offset]&255L)
            |(((long)p[offset+1]&255L)<<8)
            |(((long)p[offset+2]&255L)<<16)
            |(((long)p[offset+3]&255L)<<24);
    }
    private static int i32(byte[] p,int offset){return (int)u32(p,offset);}
    private static long u64(byte[] p,int offset){return u32(p,offset)|(u32(p,offset+4)<<32);}
    private static long checksum(byte[] p){
        long hash=FNV_OFFSET;
        for(int i=0;i<p.length;i++){
            int b=(i>=32&&i<40)?0:p[i]&255;
            hash=(hash^b)*FNV_PRIME;
        }
        return hash;
    }
    public static Frame decode(byte[] packet){
        if(packet==null||packet.length<HEADER_BYTES)
            throw new IllegalArgumentException("Incomplete XFS1 header");
        if(packet[0]!='X'||packet[1]!='F'||packet[2]!='S'||packet[3]!='1'||
           u32(packet,4)!=HEADER_BYTES)
            throw new IllegalArgumentException("Unknown XFS1 format");
        final long unsignedW=u32(packet,8),unsignedH=u32(packet,12);
        if(unsignedW==0||unsignedH==0||unsignedW>Integer.MAX_VALUE||
           unsignedH>Integer.MAX_VALUE)
            throw new IllegalArgumentException("Viewport is outside host integer range");
        int w=(int)unsignedW,h=(int)unsignedH;
        final long count=u32(packet,28);
        if(count!=(packet.length-HEADER_BYTES)/RECORD_BYTES||
           HEADER_BYTES+count*RECORD_BYTES!=packet.length||
           count>Integer.MAX_VALUE/7)
            throw new IllegalArgumentException("XFS1 record length mismatch");
        if(u64(packet,32)!=checksum(packet))
            throw new IllegalArgumentException("XFS1 checksum mismatch");
        int[] words=new int[(int)count*7];
        for(int i=0;i<count;i++){
            int offset=HEADER_BYTES+i*RECORD_BYTES,base=i*7;
            for(int j=0;j<7;j++)words[base+j]=i32(packet,offset+j*4);
            final long type=u32(packet,offset),a=u32(packet,offset+4),
                       b=u32(packet,offset+8),c=u32(packet,offset+12),
                       d=u32(packet,offset+16);
            if(type==1){
                if(a>=h||b>c||c>=w||d!=0)
                    throw new IllegalArgumentException("Frame span outside viewport");
            }else if(type==2){
                if(a>=w||b>=h||c==0||d==0||c>w-a||d>h-b)
                    throw new IllegalArgumentException("Frame tile outside viewport");
            }else throw new IllegalArgumentException("Unknown XFS1 record");
        }
        return new Frame(w,h,u64(packet,16),i32(packet,24),(int)count,words);
    }
    public static int[] materialize(List<Frame> packets,long availableBytes){
        if(packets==null||packets.isEmpty())
            throw new IllegalArgumentException("Missing XFS1 frame windows");
        final Frame first=packets.get(0);
        final long count=(long)first.width*first.height;
        // Two integer arrays (pixels+depth) and one optional Bitmap in caller.
        if(count<=0||count>Integer.MAX_VALUE||availableBytes<=0||
           count>availableBytes/12)
            throw new IllegalArgumentException("Frame exceeds available physical memory budget");
        int[] pixels=new int[(int)count],depths=new int[(int)count];
        Arrays.fill(pixels,first.background);
        Arrays.fill(depths,-1); // maximal unsigned 32-bit depth.
        for(Frame frame:packets){
            if(frame==null||frame.width!=first.width||frame.height!=first.height||
                frame.revision!=first.revision||frame.background!=first.background)
                throw new IllegalArgumentException("Inconsistent XFS1 window");
            for(int i=0;i<frame.recordCount;i++){
                int start=i*7,type=frame.records[start],a=frame.records[start+1],
                    b=frame.records[start+2],c=frame.records[start+3],
                    d=frame.records[start+4],argb=frame.records[start+5],
                    newDepth=frame.records[start+6];
                if(type==1){
                    fill(pixels,depths,frame.width,a,b,c+1,argb,newDepth);
                }else{
                    for(int y=b;y<b+d;y++)
                        fill(pixels,depths,frame.width,y,a,a+c,argb,newDepth);
                }
            }
        }
        return pixels;
    }
    private static void fill(int[] pixels,int[] depths,int width,int y,
                             int left,int exclusiveRight,int argb,int depth){
        int index=y*width+left,end=y*width+exclusiveRight;
        while(index<end){
            if(Integer.compareUnsigned(depth,depths[index])<=0){
                depths[index]=depth;
                pixels[index]=argb;
            }
            index++;
        }
    }
}
