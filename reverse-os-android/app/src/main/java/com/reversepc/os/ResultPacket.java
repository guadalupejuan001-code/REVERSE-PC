package com.reversepc.os;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;

public final class ResultPacket {
    /** UTF-8 text for parse(); deliberately null for parseBinary(). */
    public final String output;
    /** Exact transport bytes, including NUL and invalid UTF-8 sequences. */
    public final byte[] outputBytes;
    public final byte[] state;
    private ResultPacket(String output,byte[] outputBytes,byte[] state){
        this.output=output;this.outputBytes=outputBytes;this.state=state;
    }
    public static byte[] encode(String output,byte[] state){
        if(output==null||state==null)throw new IllegalArgumentException("Missing packet fields");
        byte[] text=output.getBytes(StandardCharsets.UTF_8);
        if(text.length>16*1024*1024||state.length>32*1024*1024+29)
            throw new IllegalArgumentException("Packet exceeds transport limits");
        ByteBuffer result=ByteBuffer.allocate(13+text.length+state.length).order(ByteOrder.LITTLE_ENDIAN);
        result.put("RXOS1".getBytes(StandardCharsets.US_ASCII)).putInt(text.length).putInt(state.length).put(text).put(state);
        return result.array();
    }
    public static ResultPacket parse(byte[] payload){
        return parse(payload,true);
    }
    /** Parse a binary observation without converting its bytes through UTF-8. */
    public static ResultPacket parseBinary(byte[] payload){
        return parse(payload,false);
    }
    private static ResultPacket parse(byte[] payload,boolean decodeText){
        if(payload==null||payload.length<13)
            throw new IllegalArgumentException("Native runtime returned incomplete result");
        for(int i=0;i<5;i++)if(payload[i]!="RXOS1".charAt(i))
            throw new IllegalArgumentException("Native result signature mismatch");
        ByteBuffer header=ByteBuffer.wrap(payload).order(ByteOrder.LITTLE_ENDIAN);
        int textLen=header.getInt(5),stateLen=header.getInt(9);
        if(textLen<0||stateLen<0||textLen>16*1024*1024||
                stateLen>32*1024*1024+29||
                13L+textLen+stateLen!=payload.length)
            throw new IllegalArgumentException("Invalid native result dimensions");
        byte[] raw=Arrays.copyOfRange(payload,13,13+textLen);
        return new ResultPacket(decodeText?new String(raw,StandardCharsets.UTF_8):null,raw,
            Arrays.copyOfRange(payload,13+textLen,payload.length));
    }
}
