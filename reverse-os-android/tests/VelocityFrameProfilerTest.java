package com.reversepc.os;

public final class VelocityFrameProfilerTest {
    static int checks;
    static void check(boolean ok,String what){checks++;if(!ok)throw new AssertionError(what);}
    public static void main(String[] args){
        VelocityFrameProfiler p=new VelocityFrameProfiler();
        check(p.drain(false).isEmpty()&&p.drain(true).isEmpty(),"empty windows");
        final long ms=1_000_000L;
        for(int i=1;i<=4;i++)p.record(false,i*ms,ms,2*ms,3*ms,4*ms,12*i*ms,200+i);
        String normal=p.drain(false);
        check(normal.contains("mode=XI_STANDARD samples=4"),"mode and count");
        check(normal.contains("xiP50Ms=2.000"),"lower median convention");
        check(normal.contains("xiP95Ms=4.000"),"p95 worst sample");
        check(normal.contains("payloadBytes=204"),"latest packet length");
        check(p.drain(false).isEmpty(),"window drained");
        for(int i=0;i<110;i++)p.record(true,(i+1)*ms,ms,ms,ms,ms,ms,8294416);
        String four=p.drain(true);
        check(four.contains("mode=XI_4K samples=96"),"ring buffer must be capped");
        check(four.contains("xiP95Ms=106.000"),"p95 over circular data"); // 96 samples: 15..110, position 92 = 106
        check(four.contains("payloadBytes=8294416"),"4K transport metric");
        check(p.drain(true).isEmpty(),"drained 4K");
        boolean rejected=false;
        try{p.record(true,-1,0,0,0,0,0,0);}catch(IllegalArgumentException yes){rejected=true;}
        check(rejected,"negative timer rejected");
        System.out.println("REGRAPHICS_PIPELINE_PROFILER_PASS checks="+checks);
    }
}
