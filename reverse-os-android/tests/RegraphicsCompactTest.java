package com.reversepc.os;
import java.nio.*;
import java.nio.file.*;
import java.util.*;
import x.gpu.virtual.CompactTriangleStream;

/** Independent legacy float adapter versus the actual shared compact stream. */
public final class RegraphicsCompactTest {
    static long checks;
    static void check(boolean value,String why){if(!value)throw new AssertionError(why);checks++;}
    static void same(float a,float b){check(Float.floatToRawIntBits(a)==Float.floatToRawIntBits(b),"vertex binary32 attribute differs");}
    public static void main(String[] args)throws Exception{
        CompactTriangleStream compact=new CompactTriangleStream();int cases=0;
        for(String filename:args){
            RegraphicsGeometry g=RegraphicsGeometry.decodeOwned(Files.readAllBytes(Path.of(filename)));
            FloatBuffer reference=FloatBuffer.allocate(g.faces*3*11);g.vertices(reference);
            int[] starts=g.starts.clone(),counts=g.counts.clone();g.compact(compact);
            check(Arrays.equals(starts,g.starts)&&Arrays.equals(counts,g.counts),"draw passes and transparent ordering preserved");
            check(compact.usedBytes()/24==reference.remaining()/11,"same number of vertices");
            ByteBuffer packed=compact.view(0,compact.usedBytes()).order(ByteOrder.nativeOrder());
            for(int at=0;at<compact.usedBytes();at+=24){
                same(reference.get(),(float)packed.getInt(at));same(reference.get(),(float)packed.getInt(at+4));
                int zc=packed.getInt(at+8);same(reference.get(),(float)(zc&1048575));
                same(reference.get(),(float)packed.getShort(at+12));same(reference.get(),(float)packed.getShort(at+14));
                same(reference.get(),packed.getFloat(at+16));
                for(int k=0;k<4;k++)same(reference.get(),(float)(packed.get(at+20+k)&255));
                same(reference.get(),(float)(zc>>>20));
            }
            check(!reference.hasRemaining(),"all reference attributes consumed");
            g.compact(compact);check(compact.uploadedBytes==0,"unchanged scene leaves GPU geometry resident");
            cases++;
        }
        System.out.println("REGRAPHICS_GPU_VIRTUAL_EXACT_PASS cases="+cases+" attributeChecks="+checks);
    }
}
