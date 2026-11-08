package com.reversepc.os;

import java.lang.management.ManagementFactory;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.Locale;

/**
 * Desktop-only allocation/timing probe for the actual publish/plan/confirm path.
 * Compile this same source against the baseline and candidate implementations.
 * Fixtures are prepared before timing: these are not JNI, GL or Android FPS.
 * Usage: java ... com.reversepc.os.VelocityQssdGraphicsBridgeBenchmark [iterations]
 */
public final class VelocityQssdGraphicsBridgeBenchmark {
    private static volatile long blackhole;
    private static RegraphicsGeometry geometry(int x,boolean changedAtlas){
        ByteBuffer b=ByteBuffer.allocateDirect(2124).order(ByteOrder.LITTLE_ENDIAN);
        b.put(0,(byte)'X');b.put(1,(byte)'F');b.put(2,(byte)'G');b.put(3,(byte)'4');
        b.putShort(4,(short)3840);b.putShort(6,(short)2160);b.putInt(8,4);b.putInt(12,1);
        for(int i=0;i<2048;i++)b.put(16+i,(byte)((i*7+5)&15));
        if(changedAtlas){b.put(16,(byte)(b.get(16)^1));b.put(2063,(byte)(b.get(2063)^1));}
        for(int v=0;v<3;v++){
            b.putInt(2064+v*12,x+v*16);b.putInt(2068+v*12,100+v*14);
            b.putInt(2072+v*12,250000);b.putShort(2112+2*v,(short)32640);
        }
        b.put(2118,(byte)12);b.put(2119,(byte)4);b.put(2120,(byte)2);b.put(2121,(byte)1);
        return RegraphicsGeometry.decodeShared(b.asReadOnlyBuffer());
    }
    private static final class Trace {
        final int mode;
        final VelocityQssdGraphicsBridge bus=new VelocityQssdGraphicsBridge();
        final RegraphicsGeometry[] geometries;
        final int[][] palettes=new int[2][256];
        long revision=1,sequence;
        Trace(int mode){
            this.mode=mode;
            RegraphicsGeometry first=geometry(100,false);
            geometries=new RegraphicsGeometry[]{first,mode==1?geometry(101,false):mode==3?geometry(100,true):first};
            for(int i=0;i<256;i++)palettes[0][i]=palettes[1][i]=(i*65817)&0xffffff;
            if(mode==2){palettes[1][5]^=17;palettes[1][6]^=29;palettes[1][15]^=53;}
            VelocityQssdGraphicsBridge.Frame frame=bus.publish(first,palettes[0],1,1,revision);
            bus.confirm(bus.plan(frame));
        }
        long run(int iterations){
            long vertices=0,colors=0,rows=0,sum=0;
            for(int i=0;i<iterations;i++){
                int index=mode==0?0:(int)((++sequence)&1);
                if(mode==1||mode==3)revision++;
                VelocityQssdGraphicsBridge.Frame frame=bus.publish(geometries[index],palettes[index],1,1,revision);
                VelocityQssdGraphicsBridge.Plan plan=bus.plan(frame);
                vertices+=plan.geometryDirty?1:0;colors+=plan.changedPaletteTexels();rows+=plan.changedAtlasRows();
                sum+=frame.serial+frame.sourceRevision+plan.paletteRanges.length;
                bus.confirm(plan);
            }
            if(vertices!=((mode==1||mode==3)?iterations:0)||colors!=(mode==2?3L*iterations:0)||rows!=(mode==3?2L*iterations:0))
                throw new AssertionError("benchmark changed the resource contract in mode "+mode);
            return sum;
        }
    }
    public static void main(String[] args){
        int iterations=args.length==0?20000:Integer.parseInt(args[0]);
        if(iterations<1000)throw new IllegalArgumentException("at least 1000 iterations");
        int warmup=20000;
        java.lang.management.ThreadMXBean basic=ManagementFactory.getThreadMXBean();
        com.sun.management.ThreadMXBean allocation=basic instanceof com.sun.management.ThreadMXBean?
                (com.sun.management.ThreadMXBean)basic:null;
        boolean hasAllocation=allocation!=null&&allocation.isThreadAllocatedMemorySupported();
        if(hasAllocation&&!allocation.isThreadAllocatedMemoryEnabled())allocation.setThreadAllocatedMemoryEnabled(true);
        boolean hasCpu=basic.isCurrentThreadCpuTimeSupported();
        if(hasCpu&&!basic.isThreadCpuTimeEnabled())basic.setThreadCpuTimeEnabled(true);
        long thread=Thread.currentThread().getId();
        String[] names={"unchanged","moving_vertices","palette_changes","atlas_changes"};
        StringBuilder json=new StringBuilder("{\"benchmark\":\"qssd_bridge_host_jvm\",\"iterations\":")
                .append(iterations).append(",\"warmup\":").append(warmup)
                .append(",\"allocationSupported\":").append(hasAllocation).append(",\"samples\":[");
        // Warm every path before measuring any path, including the unchanged
        // texture case used by normal moving geometry.
        Trace[] traces=new Trace[names.length];
        for(int mode=0;mode<traces.length;mode++){
            traces[mode]=new Trace(mode);blackhole=traces[mode].run(warmup);
        }
        for(int mode=0;mode<traces.length;mode++){
            Trace trace=traces[mode];
            long allocatedBefore=hasAllocation?allocation.getThreadAllocatedBytes(thread):0;
            long cpuBefore=hasCpu?basic.getCurrentThreadCpuTime():0,start=System.nanoTime();
            long checksum=trace.run(iterations);
            long elapsed=System.nanoTime()-start,cpu=hasCpu?basic.getCurrentThreadCpuTime()-cpuBefore:0;
            long bytes=hasAllocation?allocation.getThreadAllocatedBytes(thread)-allocatedBefore:0;
            blackhole=checksum;
            if(mode!=0)json.append(',');
            json.append(String.format(Locale.ROOT,
                    "{\"trace\":\"%s\",\"wallNsPerFrame\":%.3f,\"threadCpuNsPerFrame\":%.3f,\"allocatedBytesPerFrame\":%.3f,\"checksum\":%d}",
                    names[mode],(double)elapsed/iterations,(double)cpu/iterations,(double)bytes/iterations,checksum));
        }
        System.out.println(json.append("]}"));
    }
}
