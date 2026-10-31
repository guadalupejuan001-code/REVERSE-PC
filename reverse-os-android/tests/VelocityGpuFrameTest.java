package com.reversepc.os;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.Arrays;

public final class VelocityGpuFrameTest {
    static void check(boolean condition,String why){if(!condition)throw new AssertionError(why);}
    static void reject(byte[] data,String why){
        boolean thrown=false;try{VelocityGpuFrame.decode(data);}catch(IllegalArgumentException expected){thrown=true;}
        check(thrown,why);
    }
    static byte[] packet(){
        ByteBuffer b=ByteBuffer.allocate(16+2048+60).order(ByteOrder.LITTLE_ENDIAN);
        b.put((byte)'X').put((byte)'F').put((byte)'G').put((byte)'4');
        b.putShort((short)3840).putShort((short)2160).putInt(4).putInt(1);
        for(int i=0;i<2048;i++)b.put((byte)(i%16));
        for(int[] p:new int[][]{{0,0,10},{3840,0,10},{0,2160,10}})
            b.putInt(p[0]).putInt(p[1]).putInt(p[2]);
        for(int[] uv:new int[][]{{0,0},{16,0},{0,16}})
            b.putShort((short)uv[0]).putShort((short)uv[1]);
        b.putShort((short)32768).putShort((short)32768).putShort((short)32768);
        b.put((byte)64).put((byte)24).put((byte)0).put((byte)10).putShort((short)0);
        return b.array();
    }
    public static void main(String[] args){
        byte[] sample=packet();VelocityGpuFrame frame=VelocityGpuFrame.decode(sample);
        check(frame.width==3840&&frame.height==2160&&frame.faces==1,"real 4K geometry");
        check(frame.vertices.capacity()==120&&frame.tiles.capacity()==2048,"GPU memory budget");
        check(frame.tiles.get(15)==15,"tile retained");
        byte[] bad=sample.clone();bad[0]='Z';reject(bad,"bad magic");
        bad=sample.clone();bad[4]=0;reject(bad,"wrong width");
        bad=Arrays.copyOf(sample,sample.length-1);reject(bad,"truncated face");
        bad=sample.clone();bad[16]=(byte)16;reject(bad,"out of range nibble");
        bad=sample.clone();bad[16+2048+54]=(byte)250;reject(bad,"invalid palette span");
        bad=sample.clone();bad[16+2048+56]=(byte)8;reject(bad,"invalid texture ID");
        bad=sample.clone();bad[16+2048+58]=(byte)1;reject(bad,"reserved bytes");
        System.out.println("XFG4_GPU_FRAME_PASS dimensions=3840x2160 faces=1");
    }
}
