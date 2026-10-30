package com.reversepc.os;

import java.util.Arrays;

/**
 * Bounded presenter for Velocity's XI-generated XFS1 observations.
 * Geometry and material selection already happened in XI. The complete packet
 * is validated before any destination pixels can be touched.
 */
final class RegraphicsFrame {
    static final int LOGICAL_WIDTH=1280,LOGICAL_HEIGHT=720;
    static final int MAX_SPANS_PER_ROW=48;
    final int width,height,stride,commands,revision;
    private final byte[] bytes;
    private final int[] palette;

    private RegraphicsFrame(byte[] bytes,int stride,int[] palette,int commands,int width,int height,int revision){
        this.bytes=bytes;this.stride=stride;this.palette=palette;this.commands=commands;
        this.width=width;this.height=height;this.revision=revision;
    }
    private static void require(boolean ok,String why){
        if(!ok)throw new IllegalArgumentException("REgraphics XFS1: "+why);
    }
    private static int u16(byte[] data,int at){
        return (data[at]&255)|((data[at+1]&255)<<8);
    }
    private static long u32(byte[] data,int at){
        return (data[at]&255L)|((data[at+1]&255L)<<8)|
            ((data[at+2]&255L)<<16)|((data[at+3]&255L)<<24);
    }
    static RegraphicsFrame decode(byte[] source,int stride,int[] colors){
        require(stride==1||stride==2||stride==4,"invalid stride");
        require(colors!=null&&colors.length>0&&colors.length<=256,"invalid palette size");
        int[] palette=colors.clone();
        for(int color:palette)require(color>=0&&color<=0xffffff,"invalid RGB material");
        final int maxCommands=(LOGICAL_HEIGHT/stride)*MAX_SPANS_PER_ROW;
        require(source!=null&&source.length>=24&&source.length<=24+14*maxCommands,
            "invalid frame length");
        require((source.length-24)%14==0,"unaligned spans");
        // Retain a private copy: callers cannot modify a validated observation.
        byte[] frame=source.clone();
        require(frame[0]=='X'&&frame[1]=='F'&&frame[2]=='S'&&frame[3]=='1'&&
            frame[4]==1,"signature/version mismatch");
        require(frame[5]==0&&u16(frame,14)==0,"header reserved fields");
        int width=u16(frame,6),height=u16(frame,8);
        long version=u32(frame,10);
        require(version==1||version==2,"frame revision mismatch");
        final int revision=(int)version;
        final int rowStep=revision==1?stride:1;
        if(revision==1)require(width==LOGICAL_WIDTH&&height==LOGICAL_HEIGHT,"logical dimensions mismatch");
        else require(width==(stride==4?320:stride==2?480:640)&&
            height==(stride==4?180:stride==2?270:360),"3D frame dimensions mismatch");
        require((frame.length-24)/14<=(height/rowStep)*MAX_SPANS_PER_ROW,"frame span budget exceeded");
        final int end=frame.length-8;
        require(frame[end]==3&&frame[end+1]==0&&u16(frame,end+2)==0&&
            u32(frame,end+4)==revision,"invalid frame end");
        int expectedRow=0,lastRow=-1,lastDepth=101,lastForeground=-1,rowCount=0;
        for(int at=16;at<end;at+=14){
            require(frame[at]==2,"invalid span opcode");
            int material=frame[at+1]&255,y=u16(frame,at+2),
                x0=u16(frame,at+4),x1=u16(frame,at+6),depth=u16(frame,at+8);
            require(material<palette.length,"unknown material");
            require(u32(frame,at+10)==revision,"span revision mismatch");
            require(y<height&&y%rowStep==0&&x0<=x1&&x1<width,
                "span coordinates out of bounds");
            require(depth>=1&&depth<=100,"span depth out of bounds");
            if(y!=lastRow){
                require(y==expectedRow,"missing or unordered row");
                require(x0==0&&x1==width-1&&depth==100,
                    "row must begin with full background");
                expectedRow+=rowStep;lastRow=y;lastDepth=101;lastForeground=-1;rowCount=0;
            }
            require(++rowCount<=MAX_SPANS_PER_ROW,"row span budget exceeded");
            if(revision==1)require(depth<lastDepth,"span depths must decrease");
            else if(rowCount>1){
                require(depth==1&&x0>lastForeground,"3D runs overlap or are unordered");
                lastForeground=x1;
            }
            lastDepth=depth;
        }
        require(expectedRow==height,"incomplete frame");
        return new RegraphicsFrame(frame,stride,palette,(frame.length-24)/14,width,height,revision);
    }
    /** Expand exact XI intervals; x1 on the XFS1 wire is inclusive. */
    void present(int[] destination,int width,int height){
        require(destination!=null&&width>0&&width<=8192&&height>0&&height<=8192&&
            (long)width*height<=16_777_216L&&destination.length==(long)width*height,
            "invalid destination dimensions");
        final int end=bytes.length-8;
        for(int at=16;at<end;at+=14){
            int y=u16(bytes,at+2),x0=u16(bytes,at+4),x1=u16(bytes,at+6);
            int left=x0*width/this.width;
            int right=Math.min(width,((x1+1)*width+this.width-1)/this.width);
            int top=y*height/this.height;
            int rowStep=revision==1?stride:1;
            int bottom=Math.min(height,((y+rowStep)*height+this.height-1)/this.height);
            int argb=0xff000000|palette[bytes[at+1]&255];
            for(int row=top;row<bottom;row++)
                Arrays.fill(destination,row*width+left,row*width+right,argb);
        }
    }
}
