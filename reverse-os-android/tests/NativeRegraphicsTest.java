package com.reversepc.os;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * Runs the production JNI bridge and the real XI programs on a host JVM.
 * Pass the velocity asset directory, and optionally an evidence directory.
 * This does not exercise Android SurfaceView, packaging or a device display.
 */
public final class NativeRegraphicsTest {
    private static final String HEADER="#!reverse-pc-machine-v1\n";
    private static int checks;
    private static void check(boolean ok,String why){
        if(!ok)throw new AssertionError(why);checks++;
    }
    private static String read(Path path)throws Exception{
        return new String(Files.readAllBytes(path),StandardCharsets.UTF_8);
    }
    private static String inject(String program,String inputs){
        check(program.startsWith(HEADER),"XI source header");
        return HEADER+inputs+program.substring(HEADER.length());
    }
    private static String drive(String program,boolean reset){
        return inject(program,"store8 128 1\nstore8 129 0\nstore8 130 1\n"+
            "store8 131 0\nstore8 132 "+(reset?1:0)+"\n");
    }
    private static String render(String program,int stride,int camera,int paint){
        return inject(program,"store8 200 "+stride+"\nstore8 201 "+camera+
            "\nstore8 202 "+paint+"\n");
    }
    private static byte[] pixelBytes(int[] pixels){
        ByteBuffer b=ByteBuffer.allocate(pixels.length*4).order(ByteOrder.LITTLE_ENDIAN);
        for(int pixel:pixels)b.putInt(pixel);
        return b.array();
    }
    private static String digest(byte[] bytes)throws Exception{
        byte[] hash=MessageDigest.getInstance("SHA-256").digest(bytes);
        StringBuilder text=new StringBuilder();
        for(byte value:hash)text.append(String.format("%02x",value&255));
        return text.toString();
    }
    public static void main(String[] args)throws Exception{
        if(args.length<1||args.length>2)
            throw new IllegalArgumentException("NativeRegraphicsTest VELOCITY_ASSETS [EVIDENCE]");
        Path assets=Path.of(args[0]);
        String world=read(assets.resolve("world.xi")),drive=read(assets.resolve("drive.xi")),
            render=read(assets.resolve("render.xi"));
        String[] entries=read(assets.resolve("palette.txt")).trim().split("\\n");
        check(entries.length==217,"authored palette size");
        int[] palette=new int[entries.length];
        for(int i=0;i<entries.length;i++)palette[i]=Integer.parseInt(entries[i],16);

        byte[] initial=NativeRuntime.initialize(),initialCopy=initial.clone();
        ResultPacket generated=ResultPacket.parse(NativeRuntime.execute(initial,world));
        check(Arrays.equals(initial,initialCopy),"world JNI mutated input snapshot");
        check(generated.output.trim().split("\\n").length==482,"world samples are observable");
        ResultPacket reset=ResultPacket.parse(NativeRuntime.execute(generated.state,drive(drive,true)));
        byte[] state=reset.state,retained=state.clone();
        String inspection=NativeRuntime.inspect(state);
        ResultPacket baselineTick=ResultPacket.parse(NativeRuntime.execute(state,drive(drive,false)));

        StringBuilder records=new StringBuilder();
        int frames=0;long nativeNanos=0,presentationNanos=0;
        for(int stride:new int[]{4,2,1}){
            Set<String> carPaints=new HashSet<>();String noCar=null,car=null;
            for(int camera=0;camera<3;camera++)for(int paint=0;paint<5;paint++){
                String program=render(render,stride,camera,paint);
                long begin=System.nanoTime();
                byte[] packet=NativeRuntime.execute(state,program);
                nativeNanos+=System.nanoTime()-begin;
                ResultPacket result=ResultPacket.parseBinary(packet);
                check(result.output==null,"binary mode decoded UTF-8 text");
                int byteCount=ByteBuffer.wrap(packet).order(ByteOrder.LITTLE_ENDIAN).getInt(5);
                check(Arrays.equals(result.outputBytes,Arrays.copyOfRange(packet,13,13+byteCount)),
                    "JNI binary observation was not retained exactly");
                check(result.outputBytes.length>24&&result.outputBytes[0]=='X',"native XFS1 output");
                begin=System.nanoTime();
                RegraphicsFrame frame=RegraphicsFrame.decode(result.outputBytes,stride,palette);
                int width=1280/stride,height=720/stride;
                int[] pixels=new int[width*height];
                frame.present(pixels,width,height);
                presentationNanos+=System.nanoTime()-begin;
                Set<Integer> colors=new HashSet<>();
                for(int pixel:pixels){
                    check((pixel>>>24)==255,"unpresented/nonopaque pixel");
                    colors.add(pixel);
                }
                check(colors.size()>10,"scene lost its authored materials");
                String hash=digest(pixelBytes(pixels));
                if(camera==0){carPaints.add(hash);if(paint==0)car=hash;}
                if(camera==2){
                    if(noCar==null)noCar=hash;
                    else check(noCar.equals(hash),"paint altered camera without visible car");
                }
                // The same authoritative state produces the same native bytes.
                ResultPacket repeat=ResultPacket.parseBinary(NativeRuntime.execute(state,program));
                check(Arrays.equals(result.outputBytes,repeat.outputBytes),"native frame is nondeterministic");
                check(Arrays.equals(state,retained),"render JNI mutated retained input snapshot");
                if(frames++>0)records.append(',');
                records.append("{\"stride\":").append(stride).append(",\"camera\":")
                    .append(camera).append(",\"paint\":").append(paint)
                    .append(",\"bytes\":").append(result.outputBytes.length)
                    .append(",\"commands\":").append(frame.commands)
                    .append(",\"sha256\":\"").append(hash).append("\"}");
            }
            check(carPaints.size()==5,"visible car paints are not distinct");
            check(car!=null&&!car.equals(noCar),"car camera did not change the image");
        }
        check(inspection.equals(NativeRuntime.inspect(state)),"render changed retained runtime inspection");
        ResultPacket afterTick=ResultPacket.parse(NativeRuntime.execute(state,drive(drive,false)));
        check(afterTick.output.equals(baselineTick.output)&&Arrays.equals(afterTick.state,baselineTick.state),
            "render observations changed the next driving transaction");
        boolean rejected=false;
        try{
            NativeRuntime.execute(state,HEADER+"store8 100 255\nframebegin 1280 720 1\n"+
                "framespan 0 0 1280 0 100\nframeend\nhalt\n");
        }catch(IllegalStateException expected){rejected=true;}
        check(rejected,"JNI accepted out-of-bounds XFS1 span");
        check(Arrays.equals(state,retained),"failed native render changed retained state");

        String report="{\"passed\":true,\"bridge\":\"production JNI\",\"hostJVM\":true,"+
            "\"androidDisplayVerified\":false,\"frames\":"+frames+",\"checks\":"+checks+
            ",\"nativeExecutionTotalMs\":"+(nativeNanos/1_000_000.0)+
            ",\"validationPresentationTotalMs\":"+(presentationNanos/1_000_000.0)+
            ",\"stateIsolated\":true,\"cases\":["+records+"]}\n";
        if(args.length==2){
            Path evidence=Path.of(args[1]);Files.createDirectories(evidence);
            Files.write(evidence.resolve("jni-regraphics-results.json"),report.getBytes(StandardCharsets.UTF_8));
        }
        System.out.println("NATIVE_REGRAPHICS_PASS frames="+frames+" checks="+checks+
            " stateIsolated=true androidDisplayVerified=false");
    }
}
