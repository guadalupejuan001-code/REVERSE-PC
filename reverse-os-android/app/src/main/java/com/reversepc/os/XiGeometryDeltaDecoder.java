package com.reversepc.os;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;

/** Single-producer, lossless XI transport. Returned frames remain immutable. */
final class XiGeometryDeltaDecoder {
    static final int HEADER=44,MAX_FRAME=2064+8192*60;
    private byte[] previous;
    private long serial,publication;
    long frames,deltaFrames,reusedFrames,unchangedFrames,wireBytes,geometryBytes;
    private static void require(boolean value,String why){if(!value)throw new IllegalArgumentException("XI geometry delta: "+why);}
    XiObservationPacket parse(byte[] packet){
        require(packet!=null&&packet.length>=HEADER,"truncated header");
        require(packet[0]=='X'&&packet[1]=='G'&&packet[2]=='D'&&packet[3]=='1',"signature");
        ByteBuffer b=ByteBuffer.wrap(packet).order(ByteOrder.LITTLE_ENDIAN);
        int text=b.getInt(4),length=b.getInt(8),encoding=b.getInt(36),body=b.getInt(40);
        long generation=b.getLong(12),next=b.getLong(20),base=b.getLong(28);
        require(text>=0&&text<=65536&&length>=2064&&length<=MAX_FRAME&&length%4==0&&
                body>=0&&body<=length&&HEADER+(long)text+body==packet.length,"dimensions");
        require(generation>=publication&&next>0&&serial<Long.MAX_VALUE&&next==serial+1,"publication or sequence");
        int start=HEADER+text;byte[] frame;
        if(encoding==0){
            require(base==0&&body==length,"full frame bounds");
            frame=Arrays.copyOfRange(packet,start,packet.length);
        }else if(encoding==2){
            require(previous!=null&&base==serial&&length==previous.length&&body==0,"retained frame base");
            frame=previous;
        }else{
            require(encoding==1&&previous!=null&&base==serial,"missing or stale base");
            int words=length/4,mask=(words+7)/8;
            require(body>=mask,"truncated change mask");
            if(words%8!=0)require(((packet[start+mask-1]&255) >>> (words%8))==0,"unused mask bits");
            boolean unchanged=length==previous.length;
            for(int i=0;i<mask&&unchanged;i++)unchanged=packet[start+i]==0;
            frame=unchanged?previous:Arrays.copyOf(previous,length);int cursor=start+mask;
            for(int word=0;word<words;){
                boolean changed=(packet[start+word/8]&(1<<(word%8)))!=0;
                if(changed){
                    int first=word++;
                    while(word<words&&(packet[start+word/8]&(1<<(word%8)))!=0)word++;
                    int bytes=(word-first)*4;
                    require(cursor+bytes<=packet.length,"truncated changed word");
                    System.arraycopy(packet,cursor,frame,first*4,bytes);cursor+=bytes;
                }else{
                    require(word*4+4<=previous.length,"new words must be present");word++;
                }
            }
            require(cursor==packet.length,"trailing changed words");
        }
        require(frame[0]=='X'&&frame[1]=='F'&&frame[2]=='G'&&frame[3]=='4',"original geometry signature");
        // Publish the new base only after every transport check succeeded.
        XiObservationPacket observed=new XiObservationPacket(new String(packet,HEADER,text,StandardCharsets.UTF_8),frame,generation);
        unchangedFrames+=frame==previous?1:0;previous=frame;serial=next;publication=generation;frames++;
        deltaFrames+=encoding>0?1:0;reusedFrames+=encoding==2?1:0;
        wireBytes+=packet.length;geometryBytes+=length;return observed;
    }
}
