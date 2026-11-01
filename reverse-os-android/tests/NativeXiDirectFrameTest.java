package com.reversepc.os;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.util.Arrays;

/** Byte-for-byte oracle of the read-only JNI transport on actual XI scenes. */
public final class NativeXiDirectFrameTest {
    private static final String HEADER="#!reverse-pc-machine-v1\n";
    private static int checks;
    private static void check(boolean value,String reason){
        checks++;if(!value)throw new AssertionError(reason);
    }
    private static String read(Path root,String name)throws Exception{
        return Files.readString(root.resolve(name),StandardCharsets.UTF_8);
    }
    private static String inject(String source,String input){
        check(source.startsWith(HEADER),"XI header");
        return HEADER+input+source.substring(HEADER.length());
    }
    private static String digest(byte[] data)throws Exception{
        byte[] bytes=MessageDigest.getInstance("SHA-256").digest(data);
        StringBuilder s=new StringBuilder();
        for(byte b:bytes)s.append(String.format("%02x",b&255));
        return s.toString();
    }
    public static void main(String[] args)throws Exception{
        if(args.length<1||args.length>2)
            throw new IllegalArgumentException("NativeXiDirectFrameTest VELOCITY_ASSETS [JSON_REPORT]");
        Path assets=Path.of(args[0]);
        String world=read(assets,"world.xi"),drive=read(assets,"drive.xi"),
            low=read(assets,"render.xi"),high=read(assets,"render-native4k.xi");
        int[] palette=new int[256];
        String[] hex=read(assets,"palette.txt").trim().split("\\n");
        check(hex.length==256,"palette size");
        for(int i=0;i<256;i++)palette[i]=Integer.parseInt(hex[i],16);
        ResultPacket generated=ResultPacket.parse(NativeRuntime.execute(NativeRuntime.initialize(),world));
        String init=inject(drive,"store8 128 0\nstore8 129 0\nstore8 130 1\n"+
            "store8 131 0\nstore8 132 1\n");
        ResultPacket ready=ResultPacket.parse(NativeRuntime.execute(generated.state,init));
        byte[] snapshot=ready.state,original=snapshot.clone();
        StringBuilder records=new StringBuilder();
        int scenes=0;long legacyBytes=0,directBytes=0;
        for(boolean is4k:new boolean[]{false,true}){
            for(int camera=0;camera<3;camera++){
                for(int paint=0;paint<2;paint++){
                    int stride=is4k?1:(camera==0?2:1);
                    String scene=inject(is4k?high:low,"store8 200 "+stride+"\n"+
                        "store8 201 "+camera+"\nstore8 202 "+paint+"\n");
                    byte[] oldResult=NativeRuntime.execute(snapshot,scene);
                    ResultPacket legacy=ResultPacket.parseBinary(oldResult);
                    byte[] frame=NativeRuntime.observeFrame(snapshot,scene);
                    check(Arrays.equals(legacy.outputBytes,frame),
                        "Direct JNI frame differs from legacy RXOS1 observation camera="+camera);
                    check(Arrays.equals(snapshot,original),"Read-only JNI modified owner state");
                    check(oldResult.length>frame.length,"Direct frame must omit RXOS1 and RVPC2");
                    check(frame.length==(is4k?8294416:frame.length),"4K exact byte count");
                    RegraphicsFrame validated=is4k?
                        RegraphicsFrame.decodeNative4KOwned(frame,palette):
                        RegraphicsFrame.decodeOwned(frame,stride,palette);
                    check(validated.width==(is4k?3840:(stride==2?480:640)),
                        "Native XI frame shape mismatch");
                    legacyBytes+=oldResult.length;directBytes+=frame.length;
                    if(records.length()>0)records.append(',');
                    records.append("{\"camera\":").append(camera)
                        .append(",\"paint\":").append(paint)
                        .append(",\"native4k\":").append(is4k)
                        .append(",\"outputBytes\":").append(frame.length)
                        .append(",\"sha256\":\"").append(digest(frame)).append("\"}");
                    scenes++;
                }
            }
        }
        boolean rejected=false;
        try{NativeRuntime.observeFrame(snapshot,HEADER+"halt\n");}
        catch(IllegalStateException correct){rejected=true;}
        check(rejected,"Direct frame API must reject nonimage output");
        ResultPacket next=ResultPacket.parse(NativeRuntime.execute(snapshot,
            inject(drive,"store8 128 1\nstore8 129 0\nstore8 130 1\n"+
                "store8 131 0\nstore8 132 0\n")));
        check(next.output!=null&&next.state.length>0,
            "Physics transaction after read-only frame must remain available");
        String report="{\"passed\":true,\"scenes\":"+scenes+
            ",\"referenceRXOS1Bytes\":"+legacyBytes+
            ",\"directXIPixelBytes\":"+directBytes+
            ",\"savedTransportBytes\":"+(legacyBytes-directBytes)+
            ",\"sameBytes\":true,\"snapshotUnchanged\":true,\"cases\":["+records+"]}";
        if(args.length==2)Files.writeString(Path.of(args[1]),report+"\n");
        System.out.println("XI_DIRECT_FRAME_PARITY_PASS checks="+checks+" "+report);
    }
}
