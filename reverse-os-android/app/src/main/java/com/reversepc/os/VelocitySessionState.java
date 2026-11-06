package com.reversepc.os;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/** Portable logical controls and camera; wall clocks are stored as durations. */
final class VelocitySessionState {
    static final int COUNT=14,BYTES=4+4+COUNT*4+8+5*8;
    final int[] values;
    final long[] camera;
    final long manualRemaining;
    VelocitySessionState(int[] values,long[] camera,long manualRemaining){
        if(values==null||values.length!=COUNT||camera==null||camera.length!=5)throw new IllegalArgumentException("Incomplete view state");
        this.values=values.clone();this.camera=camera.clone();this.manualRemaining=manualRemaining;
        int[] v=this.values;
        if(v[0]<0||v[0]>4||v[1]<0||v[1]>2||v[2]<0||v[2]>4||v[3]<0||v[3]>2||v[4]<0||v[4]>2||
           v[7]<0||v[7]>1||v[8]<-1||v[8]>1||v[9]<0||(v[9]&~127)!=0||((v[9]>>>2)&3)>2||
           v[10]<0||(v[10]>200&&v[10]!=255)||v[11]<0||v[11]>1||v[12]<0||v[12]>1||v[13]<0||v[13]>3||manualRemaining<0||manualRemaining>2_600_000_000L)
            throw new IllegalArgumentException("Stored view controls outside protocol");
        for(int i:new int[]{5,6})if((v[i]&0xf000)!=0||VelocityOrbitMath.pitch(v[i])<VelocityOrbitMath.MIN_PITCH||VelocityOrbitMath.pitch(v[i])>VelocityOrbitMath.MAX_PITCH)
            throw new IllegalArgumentException("Stored orbit outside protocol");
        double yaw=Double.longBitsToDouble(camera[0]),pitch=Double.longBitsToDouble(camera[1]);
        if(!Double.isFinite(yaw)||!Double.isFinite(pitch)||Math.abs(yaw)>1e12||Math.abs(pitch)>1e6||camera[2]<0||camera[2]>=4096||camera[3]<0||camera[3]>1||camera[4]<0||camera[4]>80_000_000L)
            throw new IllegalArgumentException("Stored chase camera outside protocol");
    }
    byte[] encode(){
        ByteBuffer b=ByteBuffer.allocate(BYTES).order(ByteOrder.LITTLE_ENDIAN);b.putInt(0x33535156).putInt(1);
        for(int v:values)b.putInt(v);b.putLong(manualRemaining);for(long v:camera)b.putLong(v);return b.array();
    }
    static VelocitySessionState decode(byte[] bytes){
        if(bytes==null||bytes.length!=BYTES)throw new IllegalArgumentException("Stored view length");
        ByteBuffer b=ByteBuffer.wrap(bytes).order(ByteOrder.LITTLE_ENDIAN);
        if(b.getInt()!=0x33535156||b.getInt()!=1)throw new IllegalArgumentException("Stored view version");
        int[] values=new int[COUNT];for(int i=0;i<values.length;i++)values[i]=b.getInt();long remaining=b.getLong();
        long[] camera=new long[5];for(int i=0;i<camera.length;i++)camera[i]=b.getLong();return new VelocitySessionState(values,camera,remaining);
    }
}
