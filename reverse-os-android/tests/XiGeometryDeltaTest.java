package com.reversepc.os;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;
public final class XiGeometryDeltaTest {
    static int checks;
    static void check(boolean ok,String why){if(!ok)throw new AssertionError(why);checks++;}
    static void reject(XiGeometryDeltaDecoder d,byte[] b){try{d.parse(b);throw new AssertionError("bad delta accepted");}catch(IllegalArgumentException expected){checks++;}}
    public static void main(String[] args)throws Exception{
        Path root=Path.of(args[0]);XiGeometryDeltaDecoder d=new XiGeometryDeltaDecoder();
        XiObservationPacket previous=null;
        for(int i=0;i<72;i++){
            byte[] encoded=Files.readAllBytes(root.resolve("link-"+i+".xgd"));
            byte[] expected=Files.readAllBytes(root.resolve("link-"+i+".xfg4"));
            if(i==0){reject(d,null);reject(d,new byte[12]);byte[] bad=encoded.clone();bad[0]='?';reject(d,bad);
                bad=encoded.clone();ByteBuffer.wrap(bad).order(ByteOrder.LITTLE_ENDIAN).putLong(20,2);reject(d,bad);}
            if(i>0){
                reject(new XiGeometryDeltaDecoder(),encoded);
                reject(d,Arrays.copyOf(encoded,encoded.length-1));
                byte[] bad=encoded.clone();ByteBuffer.wrap(bad).order(ByteOrder.LITTLE_ENDIAN).putLong(28,Long.MAX_VALUE);reject(d,bad);
            }
            XiObservationPacket p=d.parse(encoded);RegraphicsGeometry.decodeOwned(p.frame);
            check(Arrays.equals(p.frame,expected),"native-to-Java delta is byte exact at "+i);
            check(p.output.equals(Files.readString(root.resolve("link-"+i+".state"))),"shader/physics observations come from the same publication");
            if(previous!=null)check(Arrays.equals(previous.frame,Files.readAllBytes(root.resolve("link-"+(i-1)+".xfg4"))),"previous in-flight frame remains immutable");
            encoded[encoded.length-1]^=1;check(Arrays.equals(p.frame,expected),"wire array does not alias owned geometry");previous=p;
        }
        check(d.deltaFrames>0&&d.wireBytes<d.geometryBytes,"real XI sequence transfers fewer bytes");
        check(d.frames==72,"all serials accounted for");
        check(d.reusedFrames>0&&d.unchangedFrames>=d.reusedFrames,"retained CPU geometry reaches the GPU adapter without another allocation");
        System.out.println("XI_GEOMETRY_DELTA_PASS checks="+checks+" deltaFrames="+d.deltaFrames+" reusedFrames="+d.reusedFrames+" wireBytes="+d.wireBytes+" geometryBytes="+d.geometryBytes);
    }
}
