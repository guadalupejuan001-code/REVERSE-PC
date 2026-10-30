package com.reversepc.os;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.Arrays;
public final class RxePacketTest {
    static int checks;
    static void check(boolean value){if(!value)throw new AssertionError("packet "+checks);checks++;}
    static void reject(Runnable action){try{action.run();throw new AssertionError("accepted invalid packet");}catch(IllegalArgumentException expected){checks++;}}
    public static void main(String[] args){
        byte[] state=new byte[209659];for(int i=0;i<state.length;i++)state[i]=(byte)i;
        String metadata="{\"text\":\"Español · memoria 💾\"}";byte[] encoded=ResultPacket.encode(metadata,state);ResultPacket decoded=ResultPacket.parse(encoded);
        check(metadata.equals(decoded.output));check(Arrays.equals(state,decoded.state));check(encoded.length==13+metadata.getBytes(java.nio.charset.StandardCharsets.UTF_8).length+state.length);
        for(int n=0;n<13;n++){final byte[] cut=Arrays.copyOf(encoded,n);reject(()->ResultPacket.parse(cut));}
        for(int at:new int[]{0,4,5,9}){byte[] bad=encoded.clone();bad[at]^=0x40;reject(()->ResultPacket.parse(bad));}
        byte[] bad=encoded.clone();ByteBuffer.wrap(bad).order(ByteOrder.LITTLE_ENDIAN).putInt(9,32*1024*1024+30);reject(()->ResultPacket.parse(bad));
        reject(()->ResultPacket.encode(null,state));reject(()->ResultPacket.encode(metadata,null));
        check(Arrays.equals(encoded,ResultPacket.encode(decoded.output,decoded.state)));
        byte[] poison={(byte)0, (byte)0xff, (byte)0x80, (byte)0xc0, (byte)0xaf, (byte)0xed, (byte)0xa0, (byte)0x80};
        byte[] wire=ByteBuffer.allocate(13+poison.length+state.length).order(ByteOrder.LITTLE_ENDIAN)
            .put(new byte[]{'R','X','O','S','1'}).putInt(poison.length).putInt(state.length).put(poison).put(state).array();
        ResultPacket binary=ResultPacket.parseBinary(wire);
        check(binary.output==null);check(Arrays.equals(poison,binary.outputBytes));check(Arrays.equals(state,binary.state));
        // A byte packet is not round-trippable through replacement-character UTF-8.
        check(!Arrays.equals(poison,new String(poison,java.nio.charset.StandardCharsets.UTF_8)
            .getBytes(java.nio.charset.StandardCharsets.UTF_8)));
        Arrays.fill(wire,(byte)0);check(Arrays.equals(poison,binary.outputBytes));check(Arrays.equals(state,binary.state));
        check(Arrays.equals(metadata.getBytes(java.nio.charset.StandardCharsets.UTF_8),decoded.outputBytes));
        for(int n=0;n<13;n++){final byte[] cut=Arrays.copyOf(encoded,n);reject(()->ResultPacket.parseBinary(cut));}
        reject(()->ResultPacket.parseBinary(null));
        System.out.println("RXE_PACKET_PASS checks="+checks);
    }
}
