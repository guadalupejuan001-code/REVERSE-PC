package com.reversepc.os;

import java.nio.*;
import java.nio.file.*;
import java.util.*;
import java.util.concurrent.*;
import x.gpu.virtual.CompactTriangleStream;

/** Actual production JNI -> XI -> geometry -> shared GPU component, same trace. */
public final class VelocityQssdNativeTrace {
    private static native byte[] checkpoint(long handle);
    static long checks;
    static void check(boolean ok,String message){if(!ok)throw new AssertionError(message);checks++;}
    static double median(List<Long> values){List<Long> sorted=new ArrayList<>(values);Collections.sort(sorted);return sorted.get(sorted.size()/2)/1e6;}
    static byte[] state(byte[] packet){
        check(packet.length>=13&&packet[0]=='R'&&packet[1]=='X'&&packet[2]=='O'&&packet[3]=='S'&&packet[4]=='1',"native CPU packet");
        ByteBuffer b=ByteBuffer.wrap(packet).order(ByteOrder.LITTLE_ENDIAN);int text=b.getInt(5),state=b.getInt(9);
        check(text>=0&&state>=29&&13L+text+state==packet.length,"native state envelope");
        return Arrays.copyOfRange(packet,13+text,packet.length);
    }
    static String command(String drive,boolean reset,boolean reverse,boolean nitro){
        String header="#!reverse-pc-machine-v1\n";
        return header+"store8 128 1\nstore8 129 0\nstore8 130 1\nstore8 131 0\nstore8 132 "+(reset?1:0)+
          "\nstore8 133 "+(reverse?1:0)+"\nstore8 134 "+(nitro?1:0)+"\nstore8 135 0\nstore8 136 0\nstore8 138 255\n"+drive.substring(header.length());
    }
    static byte[] raw(ByteBuffer view){byte[] bytes=new byte[view.limit()];view.duplicate().get(bytes);return bytes;}
    static void step(ExecutorService physics,long session,String command)throws Exception{
        physics.submit(()->{NativeRuntime.sessionStage(session,command);NativeRuntime.sessionCommit(session);}).get();
    }
    static void sameCompact(RegraphicsGeometry geometry,byte[] expected){
        RegraphicsGeometry reference=RegraphicsGeometry.decodeOwned(expected);
        CompactTriangleStream a=new CompactTriangleStream(),b=new CompactTriangleStream();
        reference.compact(a);geometry.compact(b);
        check(a.usedBytes()==b.usedBytes()&&Arrays.equals(a.starts,b.starts)&&Arrays.equals(a.counts,b.counts),"shared GPU draw semantics");
        check(a.view(0,a.usedBytes()).equals(b.view(0,b.usedBytes())),"shared GPU vertex bits");
    }
    public static void main(String[] args)throws Exception{
        Path assets=Path.of(args[0]),fixtures=Path.of(args[1]),out=Path.of(args[2]);boolean shared=args[3].equals("shared");
        Files.createDirectories(out);
        String world=Files.readString(assets.resolve("world.xi")),drive=Files.readString(assets.resolve("drive.xi")),render=Files.readString(assets.resolve("render4k.xi"));
        byte[] initial=state(NativeRuntime.execute(NativeRuntime.initialize(),world));
        long live=NativeRuntime.sessionOpen(initial);XiGeometryDeltaDecoder delta=new XiGeometryDeltaDecoder();
        ExecutorService physics=Executors.newSingleThreadExecutor();
        List<Long> execute=new ArrayList<>(),decode=new ArrayList<>(),pack=new ArrayList<>(),total=new ArrayList<>(),changed=new ArrayList<>(),unchanged=new ArrayList<>();
        long projections=0,geometryBytes=0,wireBytes=0,deliveries=0,nativeExecs=0;
        RegraphicsGeometry retained=null;long retainedIdentity=0,retainedRevision=0;
        CompactTriangleStream gpu=new CompactTriangleStream();ByteBuffer firstView=null;byte[] firstBytes=null;
        try{
            NativeRuntime.sessionSetGeometryProgram(live,render);
            for(int tick=0;tick<200;tick++)step(physics,live,command(drive,tick==0,false,false));
            for(int frame=0;frame<72;frame++){
                if(frame%3==0)step(physics,live,command(drive,false,frame>=48,frame>=60));
                int yaw=(frame/12)%3==0?0:((frame/12)%3==1?700:2200),pitch=(frame/24)*160;
                int[] addresses={141,200,201,202,203,204,205,206,207};
                byte[] values={1,1,0,(byte)((frame/24)%3),(byte)((frame/24)%3),(byte)yaw,(byte)(yaw>>>8),(byte)pitch,(byte)(pitch>>>8)};
                long start=System.nanoTime(),endExecute,endDecode;String output;RegraphicsGeometry geometry;
                XiSharedGeometryPacket projected=null;XiObservationPacket original=null;
                if(shared){
                    projected=NativeRuntime.sessionObserveSharedGeometry(live,addresses,values);endExecute=System.nanoTime();
                    geometry=retained!=null&&retainedIdentity==projected.identity&&retainedRevision==projected.revision?retained:RegraphicsGeometry.decodeShared(projected.frame);
                    retainedIdentity=projected.identity;retainedRevision=projected.revision;output=projected.output;
                    projections+=projected.materializedBytes;geometryBytes+=projected.frame.limit();deliveries+=projected.materializedBytes==0?1:0;nativeExecs+=projected.executed?1:0;
                    wireBytes+=projected.materializedBytes+projected.output.length()+40;
                }else{
                    byte[] packet=NativeRuntime.sessionObservePreparedGeometry(live,addresses,values);endExecute=System.nanoTime();
                    original=delta.parse(packet);geometry=retained!=null&&retained.bytes==original.frame?retained:RegraphicsGeometry.decodeOwned(original.frame);
                    output=original.output;wireBytes+=packet.length;geometryBytes+=original.frame.length;
                }
                endDecode=System.nanoTime();
                if(geometry!=retained)geometry.compact(gpu);
                long end=System.nanoTime();retained=geometry;
                if(frame>=6){
                    execute.add(endExecute-start);decode.add(endDecode-endExecute);pack.add(end-endDecode);total.add(end-start);
                    (frame%3==0?changed:unchanged).add(end-start);
                }
                byte[] expected=Files.readAllBytes(fixtures.resolve("link-"+frame+".xfg4"));
                check(output.equals(Files.readString(fixtures.resolve("link-"+frame+".state"))),"coherent shader-state output");
                byte[] actual=shared?raw(projected.frame):original.frame;
                check(Arrays.equals(actual,expected),"all geometry bytes match original 3.7");
                sameCompact(geometry,expected);
                if(shared){
                    check(projected.frame.isDirect()&&projected.frame.isReadOnly(),"VM-owned read-only projection");
                    try{projected.frame.put(0,(byte)0);throw new AssertionError("shared data became writable");}catch(ReadOnlyBufferException correct){checks++;}
                    if(firstView==null){firstView=projected.frame;firstBytes=actual.clone();}
                }
            }
            check(Arrays.equals(checkpoint(live),Files.readAllBytes(fixtures.resolve("final.rvpc2"))),"native world/RNG checkpoint unchanged");
            if(shared){
                int[] addresses={200,201,202,203,204,205,206,207,141};byte[] values={1,0,2,2,(byte)2200,(byte)(2200>>>8),64,1,1};
                XiSharedGeometryPacket a=NativeRuntime.sessionObserveSharedGeometry(live,addresses,values);
                XiSharedGeometryPacket b=NativeRuntime.sessionObserveSharedGeometry(live,addresses,values);
                check(a.identity==b.identity&&a.revision==b.revision&&a.frame==b.frame&&b.materializedBytes==0&&!b.executed,"same qSSD state is delivered by reference");
                byte[] saved=raw(a.frame);
                values[1]=1;NativeRuntime.sessionObserveSharedGeometry(live,addresses,values);
                check(Arrays.equals(raw(a.frame),saved),"old physical projection remains immutable");
            }
        }finally{NativeRuntime.sessionClose(live);physics.shutdownNow();}
        if(shared){System.gc();check(Arrays.equals(raw(firstView),firstBytes),"session close/GC invalidated an in-flight view");}
        String report="{\"passed\":true,\"mode\":\""+(shared?"qssd":"original-3.7")+"\",\"frames\":72,\"checks\":"+checks+
          ",\"nativeExecuteP50Ms\":"+median(execute)+",\"decodeP50Ms\":"+median(decode)+",\"packP50Ms\":"+median(pack)+
          ",\"pipelineP50Ms\":"+median(total)+",\"changedPublicationP50Ms\":"+median(changed)+",\"unchangedPublicationP50Ms\":"+median(unchanged)+
          ",\"explicitProjectionBytes\":"+projections+",\"geometryBytes\":"+geometryBytes+",\"transportAndProjectionBytes\":"+wireBytes+
          ",\"sharedDeliveries\":"+deliveries+",\"nativeExecutions\":"+nativeExecs+",\"physicalGpuMeasured\":false}";
        Files.writeString(out.resolve("jni-trace.json"),report+"\n");System.out.println(report);
    }
}
