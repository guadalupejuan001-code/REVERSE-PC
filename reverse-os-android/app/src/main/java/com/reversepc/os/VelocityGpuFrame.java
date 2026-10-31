package com.reversepc.os;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/**
 * Validated 3840x2160 triangle transport authored by XI/REgraphics.
 * This is a presenter packet, not an alternative scene/physics engine.
 */
final class VelocityGpuFrame {
    static final int SOURCE_WIDTH=3840,SOURCE_HEIGHT=2160;
    static final int MAX_FACES=8192,HEADER_BYTES=16,TILE_BYTES=2048,FACE_BYTES=60;
    static final int FLOATS_PER_VERTEX=10;
    final int width,height,faces;
    final ByteBuffer vertices,tiles;

    private VelocityGpuFrame(int w,int h,int n,ByteBuffer verts,ByteBuffer tileBytes) {
        width=w;height=h;faces=n;vertices=verts;tiles=tileBytes;
    }

    static VelocityGpuFrame decode(byte[] packet) {
        if(packet==null||packet.length<HEADER_BYTES+TILE_BYTES)
            throw new IllegalArgumentException("XFG4 packet truncated");
        ByteBuffer src=ByteBuffer.wrap(packet).order(ByteOrder.LITTLE_ENDIAN);
        if(src.get(0)!='X'||src.get(1)!='F'||src.get(2)!='G'||src.get(3)!='4')
            throw new IllegalArgumentException("XFG4 magic mismatch");
        int w=Short.toUnsignedInt(src.getShort(4));
        int h=Short.toUnsignedInt(src.getShort(6));
        long version=Integer.toUnsignedLong(src.getInt(8));
        long count=Integer.toUnsignedLong(src.getInt(12));
        if(w!=SOURCE_WIDTH||h!=SOURCE_HEIGHT||version!=4||count>MAX_FACES||
            packet.length!=HEADER_BYTES+TILE_BYTES+FACE_BYTES*count)
            throw new IllegalArgumentException("XFG4 dimensions or geometry budget invalid");
        ByteBuffer tiles=ByteBuffer.allocateDirect(TILE_BYTES).order(ByteOrder.nativeOrder());
        for(int i=0;i<TILE_BYTES;i++){
            int nibble=Byte.toUnsignedInt(src.get(HEADER_BYTES+i));
            if(nibble>15)throw new IllegalArgumentException("XFG4 texture tile outside 4-bit range");
            tiles.put((byte)nibble);
        }
        tiles.flip();
        ByteBuffer verts=ByteBuffer.allocateDirect((int)count*3*FLOATS_PER_VERTEX*4)
            .order(ByteOrder.nativeOrder());
        int at=HEADER_BYTES+TILE_BYTES;
        for(int face=0;face<count;face++,at+=FACE_BYTES){
            int[] pos=new int[9],uv=new int[6],light=new int[3];
            for(int i=0;i<9;i++)pos[i]=src.getInt(at+4*i);
            for(int i=0;i<6;i++)uv[i]=src.getShort(at+36+2*i);
            for(int i=0;i<3;i++)light[i]=Short.toUnsignedInt(src.getShort(at+48+2*i));
            int base=Byte.toUnsignedInt(src.get(at+54));
            int ramp=Byte.toUnsignedInt(src.get(at+55));
            int texture=Byte.toUnsignedInt(src.get(at+56));
            int strength=Byte.toUnsignedInt(src.get(at+57));
            if(ramp<1||base+ramp>256||texture>7||strength>16||
                (strength!=0&&ramp<2)||src.getShort(at+58)!=0)
                throw new IllegalArgumentException("XFG4 material invalid");
            for(int v=0;v<3;v++){
                int x=pos[v*3],y=pos[v*3+1],z=pos[v*3+2];
                if(Math.abs((long)x)>100000000||Math.abs((long)y)>100000000||
                    z<1||z>1000000||light[v]>65280)
                    throw new IllegalArgumentException("XFG4 projected vertex invalid");
                verts.putFloat(x).putFloat(y).putFloat(z);
                verts.putFloat(uv[v*2]).putFloat(uv[v*2+1]);
                verts.putFloat(light[v]/65280f);
                verts.putFloat(base).putFloat(ramp);
                verts.putFloat(texture).putFloat(strength);
            }
        }
        verts.flip();
        return new VelocityGpuFrame(w,h,(int)count,verts,tiles);
    }
}
