package com.reversepc.os;

import java.nio.*;
import java.nio.file.*;
import java.util.*;

/** Real production JNI full-state persistence, resource bus and fork/rewind. */
public final class VelocityStateSpaceTest {
    private static native byte[] checkpoint(long handle);
    static int checks;
    static void check(boolean ok,String why){if(!ok)throw new AssertionError(why);checks++;}
    static byte[] state(byte[] packet){ByteBuffer b=ByteBuffer.wrap(packet).order(ByteOrder.LITTLE_ENDIAN);return Arrays.copyOfRange(packet,13+b.getInt(5),packet.length);}
    static byte[] raw(ByteBuffer b){byte[] bytes=new byte[b.limit()];b.duplicate().get(bytes);return bytes;}
    static void advance(long session,String command){NativeRuntime.sessionStage(session,command);NativeRuntime.sessionCommit(session);}
    public static void main(String[] args)throws Exception{
        Path assets=Path.of(args[0]),out=Path.of(args[1]);Files.createDirectories(out);
        String[] names;try(var stream=Files.list(assets)){names=stream.filter(Files::isRegularFile).map(p->p.getFileName().toString()).sorted().toArray(String[]::new);}
        byte[][] resources=new byte[names.length][];for(int i=0;i<names.length;i++)resources[i]=Files.readAllBytes(assets.resolve(names[i]));
        byte[] initial=state(NativeRuntime.execute(NativeRuntime.initialize(),Files.readString(assets.resolve("world.xi"))));
        long live=NativeRuntime.sessionOpen(initial),restored=0,branch=0;ByteBuffer retained=null;byte[] retainedBytes=null;
        try{
            NativeRuntime.sessionRegisterResources(live,names,resources);
            NativeRuntime.sessionSetGeometryProgram(live,Files.readString(assets.resolve("render4k.xi")));
            String drive=Files.readString(assets.resolve("drive.xi")),header="#!reverse-pc-machine-v1\n";
            String reset=VelocityQssdNativeTrace.command(drive,true,false,false),step=VelocityQssdNativeTrace.command(drive,false,false,false);
            advance(live,reset);for(int i=0;i<200;i++)advance(live,step);
            int[] viewValues={4,1,2,2,1,VelocityOrbitMath.pack(700,30),VelocityOrbitMath.pack(700,30),0,-1,4,255,1,0,0,3};
            VelocitySessionState view=new VelocitySessionState(viewValues,new long[]{Double.doubleToLongBits(700),Double.doubleToLongBits(30),0,1,20_000_000},123456);
            check(Arrays.equals(view.encode(),VelocitySessionState.decode(view.encode()).encode()),"all logical view fields round trip");
            NativeRuntime.sessionSetComponent(live,"view",view.encode());NativeRuntime.sessionSetComponent(live,"environment",new byte[]{0});
            int[] addresses={141,200,201,202,203,204,205,206,207};byte[] inputs={1,1,0,2,2,(byte)700,2,30,0};
            XiSharedGeometryPacket before=NativeRuntime.sessionObserveSharedGeometryView(live,addresses,inputs,4,view.encode());retained=before.frame;retainedBytes=raw(retained);
            byte[] cpu=checkpoint(live),output=NativeRuntime.sessionStateOutput(live),archive=NativeRuntime.sessionCheckpointSpace(live);
            Files.write(out.resolve("complete-state.qss"),archive);
            restored=NativeRuntime.sessionOpenSpace(archive);
            check(Arrays.equals(cpu,checkpoint(restored))&&Arrays.equals(output,NativeRuntime.sessionStateOutput(restored)),"full native CPU/output/RNG restoration");
            check(Arrays.equals(view.encode(),NativeRuntime.sessionGetComponent(restored,"view")),"complete component state restoration");
            check(VelocitySessionState.decode(NativeRuntime.sessionGetComponent(restored,"view")).values[14]==3,"manual gear selector survives actual QSSD archive restoration");
            for(int i=0;i<names.length;i++)check(Arrays.equals(resources[i],NativeRuntime.sessionReadResource(restored,names[i])),"original resource bytes: "+names[i]);
            XiSharedGeometryPacket after=NativeRuntime.sessionObserveSharedGeometryView(restored,addresses,inputs,4,view.encode());
            check(after.publication==before.publication&&Arrays.equals(raw(after.frame),retainedBytes),"GPU frame/CPU publication restored exactly");
            for(int i=0;i<20;i++){advance(live,step);advance(restored,step);}
            check(Arrays.equals(checkpoint(live),checkpoint(restored)),"future XI driving remains exact after full restore");
            branch=NativeRuntime.sessionForkSpace(restored);byte[] parent=checkpoint(restored);advance(branch,header+"store8 550 73\n");
            check(Arrays.equals(parent,checkpoint(restored))&&!Arrays.equals(parent,checkpoint(branch)),"native fork has independent CPU authority");
            NativeRuntime.sessionBookmark(restored,"saved");advance(restored,header+"store8 550 77\n");long generation=NativeRuntime.sessionRewind(restored,"saved");
            check(generation>before.publication&&Arrays.equals(parent,checkpoint(restored)),"native rewind restores complete CPU state under fresh generation");
            for(int i:new int[]{0,archive.length/2,archive.length-1}){
                byte[] corrupt=archive.clone();corrupt[i]^=1;boolean rejected=false;
                try{long invalid=NativeRuntime.sessionOpenSpace(corrupt);NativeRuntime.sessionClose(invalid);}catch(IllegalStateException expected){rejected=true;}
                check(rejected&&Arrays.equals(parent,checkpoint(restored)),"invalid full checkpoint cannot replace live state");
            }
            String report="{\"passed\":true,\"checks\":"+checks+",\"resources\":"+names.length+",\"checkpointBytes\":"+archive.length+",\"space\":"+NativeRuntime.sessionInspectSpace(restored)+"}";
            Files.writeString(out.resolve("state-space-jni.json"),report+"\n");System.out.println("VELOCITY_STATE_SPACE_JNI_PASS "+report);
        }finally{NativeRuntime.sessionClose(live);if(restored!=0)NativeRuntime.sessionClose(restored);if(branch!=0)NativeRuntime.sessionClose(branch);}
        System.gc();check(Arrays.equals(raw(retained),retainedBytes),"retained GPU view invalid after full authority closes");
    }
}
