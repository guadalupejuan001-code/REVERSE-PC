package com.reversepc.os;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.Collections;

/** Host-JVM verified against XFS1 emitted by the genuine XI runtime. */
public final class XiFrameStreamCodecTest {
    private static void check(boolean ok,String label){
        if(!ok)throw new AssertionError(label);
    }
    private static void rejected(byte[] packet,String label){
        boolean failure=false;
        try{XiFrameStreamCodec.decode(packet);}
        catch(IllegalArgumentException expected){failure=true;}
        check(failure,label);
    }
    public static void main(String[] args)throws Exception{
        check(args.length==1,"expected authentic XI binary packet");
        byte[] input=Files.readAllBytes(Paths.get(args[0]));
        XiFrameStreamCodec.Frame frame=XiFrameStreamCodec.decode(input);
        check(frame.width==64&&frame.height==32&&frame.revision==7&&
              frame.recordCount==4,"header and record contract");
        int[] pixels=XiFrameStreamCodec.materialize(Collections.singletonList(frame),1024L*1024L);
        check(pixels.length==2048,"complete frame");
        check(pixels[0]==0xff00ff00,"tile material");
        check(pixels[10*64+11]==0xffff0000,"front span material");
        check(pixels[10*64+12]==0xffff0000,"near depth wins");
        check(pixels[10*64+14]==0xffffff00,"equal depth later wins");
        boolean budget=false;
        try{XiFrameStreamCodec.materialize(Collections.singletonList(frame),100);}
        catch(IllegalArgumentException expected){budget=true;}
        check(budget,"memory budget");
        byte[] broken=Arrays.copyOf(input,input.length);
        broken[41]^=4;rejected(broken,"checksum mutation");
        rejected(Arrays.copyOf(input,input.length-3),"truncated body");
        broken=Arrays.copyOf(input,input.length);
        broken[0]='Z';rejected(broken,"invalid magic");
        System.out.println("XI_FRAME_STREAM_JAVA_HOST_OK packetBytes="+input.length+" bytes=2048-pixels");
    }
}
