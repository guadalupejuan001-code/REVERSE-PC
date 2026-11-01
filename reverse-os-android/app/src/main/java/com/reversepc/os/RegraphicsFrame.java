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
    static final int MAX_FRAME_BYTES=24+14*360*641;
    static final int NATIVE_4K_BYTES=16+3840*2160;
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
        return decodeChecked(source,stride,colors,false);
    }
    /**
     * Ownership-transfer entry point for an exclusive JNI byte[] just returned
     * by NativeRuntime.observeFrame(). No caller may mutate this array after
     * transfer. The legacy decode() keeps its defensive-copy guarantee.
     */
    static RegraphicsFrame decodeOwned(byte[] ownedSource,int stride,int[] colors){
        return decodeChecked(ownedSource,stride,colors,true);
    }
    private static RegraphicsFrame decodeChecked(byte[] source,int stride,int[] colors,boolean owned){
        require(stride==1||stride==2||stride==4,"invalid stride");
        require(colors!=null&&colors.length>0&&colors.length<=256,"invalid palette size");
        int[] palette=colors.clone();
        for(int color:palette)require(color>=0&&color<=0xffffff,"invalid RGB material");
        require(source!=null&&source.length>=24&&source.length<=MAX_FRAME_BYTES,
            "invalid frame length");
        require((source.length-24)%14==0,"unaligned spans");
        // Legacy untrusted callers get their own private defensive copy.
        // JNI ownership-transfer frames can be held without copying the pixels.
        byte[] frame=owned?source:source.clone();
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
        // Visibility runs can alternate at every pixel. Revision 2 therefore
        // needs one full background plus at most width foreground runs.
        final int maxRowSpans=revision==1?MAX_SPANS_PER_ROW:width+1;
        require((frame.length-24)/14<=(height/rowStep)*maxRowSpans,"frame span budget exceeded");
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
            require(++rowCount<=maxRowSpans,"row span budget exceeded");
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
    /** Exact XI native 4K pixels: XFB5, one material index per real pixel. */
    static RegraphicsFrame decodeNative4K(byte[] source,int[] colors){
        return decodeNative4KChecked(source,colors,false);
    }
    /** Take sole ownership of a freshly produced JNI XFB5 frame (8.3 MiB). */
    static RegraphicsFrame decodeNative4KOwned(byte[] source,int[] colors){
        return decodeNative4KChecked(source,colors,true);
    }
    private static RegraphicsFrame decodeNative4KChecked(byte[] source,int[] colors,boolean owned){
        require(colors!=null&&colors.length==256,"native palette must have 256 colors");
        require(source!=null&&source.length==NATIVE_4K_BYTES,"native 4K frame size mismatch");
        require(source[0]=='X'&&source[1]=='F'&&source[2]=='B'&&source[3]=='5',
            "native 4K signature mismatch");
        require(u16(source,4)==3840&&u16(source,6)==2160&&u32(source,8)==5&&
            u32(source,12)==3840L*2160L,"native 4K dimension mismatch");
        for(int color:colors)require(color>=0&&color<=0xffffff,"native palette RGB out of range");
        return new RegraphicsFrame(owned?source:source.clone(),1,colors.clone(),3840*2160,3840,2160,5);
    }
    /** Expand exact XI intervals; x1 on the XFS1 wire is inclusive. */
    void present(int[] destination,int width,int height){
        require(destination!=null&&width>0&&width<=8192&&height>0&&height<=8192&&
            (long)width*height<=16_777_216L&&destination.length==(long)width*height,
            "invalid destination dimensions");
        if(revision==5){
            require(width==this.width&&height==this.height,
                "native 4K pixels cannot be quietly relabeled as another resolution");
            for(int i=0;i<destination.length;i++)
                destination[i]=0xff000000|palette[bytes[16+i]&255];
            return;
        }
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
