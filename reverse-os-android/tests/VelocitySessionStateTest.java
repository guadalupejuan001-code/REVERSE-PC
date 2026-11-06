package com.reversepc.os;
import java.nio.*;
import java.util.*;
public final class VelocitySessionStateTest {
    static void check(boolean ok,String why){if(!ok)throw new AssertionError(why);}
    public static void main(String[] args){
        int[] v={2,1,0,0,0,VelocityOrbitMath.pack(0,0),VelocityOrbitMath.pack(0,0),0,-1,4,255,1,0,0,3};
        long[] camera={Double.doubleToLongBits(0),Double.doubleToLongBits(0),0,0,0};
        VelocitySessionState current=new VelocitySessionState(v,camera,0);
        check(VelocitySessionState.decode(current.encode()).values[14]==3,"manual selector survives complete checkpoint");
        ByteBuffer old=ByteBuffer.allocate(VelocitySessionState.BYTES-4).order(ByteOrder.LITTLE_ENDIAN);
        old.putInt(0x33535156).putInt(1);for(int i=0;i<14;i++)old.putInt(v[i]);old.putLong(0);for(long n:camera)old.putLong(n);
        check(VelocitySessionState.decode(old.array()).values[14]==0,"legacy view defaults to automatic");
        byte[] bad=current.encode();ByteBuffer.wrap(bad).order(ByteOrder.LITTLE_ENDIAN).putInt(8+14*4,7);
        boolean rejected=false;try{VelocitySessionState.decode(bad);}catch(IllegalArgumentException expected){rejected=true;}
        check(rejected,"corrupt gear is rejected before a session switch");
        System.out.println("VELOCITY_SESSION_STATE_PASS manualGear=true legacyView=true rejectedCorruption=true");
    }
}
