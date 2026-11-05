package com.reversepc.os;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;

/** Original XI frame and register output retained from the same publication. */
final class XiObservationPacket {
    final String output;
    final byte[] frame;
    private XiObservationPacket(String output,byte[] frame){this.output=output;this.frame=frame;}
    static XiObservationPacket parse(byte[] bytes){
        if(bytes==null||bytes.length<12||bytes[0]!='X'||bytes[1]!='I'||bytes[2]!='O'||bytes[3]!='1')
            throw new IllegalArgumentException("XI observation signature");
        ByteBuffer header=ByteBuffer.wrap(bytes).order(ByteOrder.LITTLE_ENDIAN);
        int text=header.getInt(4),frame=header.getInt(8);
        if(text<0||text>65536||frame<4||frame>40*1024*1024||12L+text+frame!=bytes.length)
            throw new IllegalArgumentException("XI observation dimensions");
        return new XiObservationPacket(new String(bytes,12,text,StandardCharsets.UTF_8),
            Arrays.copyOfRange(bytes,12+text,bytes.length));
    }
}
