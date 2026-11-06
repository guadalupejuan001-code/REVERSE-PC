package com.reversepc.os;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;

/** Original XI frame and register output retained from the same publication. */
final class XiObservationPacket {
    final String output;
    final byte[] frame;
    final long publication;
    private XiObservationPacket(String output,byte[] frame,long publication){this.output=output;this.frame=frame;this.publication=publication;}
    static XiObservationPacket parse(byte[] bytes){
        if(bytes==null||bytes.length<20||bytes[0]!='X'||bytes[1]!='I'||bytes[2]!='O'||bytes[3]!='2')
            throw new IllegalArgumentException("XI observation signature");
        ByteBuffer header=ByteBuffer.wrap(bytes).order(ByteOrder.LITTLE_ENDIAN);
        int text=header.getInt(4),frame=header.getInt(8);
        long publication=header.getLong(12);
        if(publication<0||text<0||text>65536||frame<4||frame>40*1024*1024||20L+text+frame!=bytes.length)
            throw new IllegalArgumentException("XI observation dimensions");
        return new XiObservationPacket(new String(bytes,20,text,StandardCharsets.UTF_8),
            Arrays.copyOfRange(bytes,20+text,bytes.length),publication);
    }
}
