package com.reversepc.os;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
public final class XiObservationPacketTest {
    static int checks;
    static void check(boolean value){if(!value)throw new AssertionError();checks++;}
    static void reject(byte[] bytes){try{XiObservationPacket.parse(bytes);throw new AssertionError("bad observation accepted");}catch(IllegalArgumentException expected){checks++;}}
    public static void main(String[] args){
        byte[] text="{\"value\":123}日本語".getBytes(StandardCharsets.UTF_8);
        byte[] frame={'X','F','G','4',0,(byte)255,1,2};
        ByteBuffer b=ByteBuffer.allocate(20+text.length+frame.length).order(ByteOrder.LITTLE_ENDIAN);
        b.put(new byte[]{'X','I','O','2'}).putInt(text.length).putInt(frame.length).putLong(37).put(text).put(frame);
        byte[] raw=b.array();XiObservationPacket p=XiObservationPacket.parse(raw);
        check(p.output.equals(new String(text,StandardCharsets.UTF_8))&&Arrays.equals(p.frame,frame));
        check(p.publication==37);
        raw[raw.length-1]=99;check(p.frame[p.frame.length-1]==2);
        reject(null);reject(new byte[11]);byte[] bad=raw.clone();bad[0]='?';reject(bad);
        bad=raw.clone();bad[4]=(byte)255;bad[5]=(byte)255;bad[6]=(byte)255;bad[7]=(byte)127;reject(bad);
        reject(Arrays.copyOf(raw,raw.length-1));reject(Arrays.copyOf(raw,raw.length+1));
        bad=raw.clone();bad[19]=(byte)128;reject(bad);
        System.out.println("XI_OBSERVATION_PACKET_PASS checks="+checks);
    }
}
