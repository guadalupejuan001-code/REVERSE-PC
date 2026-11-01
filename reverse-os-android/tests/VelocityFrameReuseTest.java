package com.reversepc.os;

/** Pure Java regression for keeping the original XI pixels while gameplay is frozen. */
public final class VelocityFrameReuseTest {
    private static int checks;
    private static void check(boolean value,String why){
        checks++;
        if(!value)throw new AssertionError(why);
    }
    public static void main(String[] args) {
        VelocityFrameReuse cache=new VelocityFrameReuse();
        Object original=new Object(),updated=new Object();
        check(!cache.canReuse(true,original,0,0,2,true),"cold frame must render");
        cache.framePosted(original,0,0,2,true);
        for(int i=0;i<100;i++)
            check(cache.canReuse(true,original,0,0,2,true),"frozen 4K must be reused");
        check(!cache.canReuse(false,original,0,0,2,true),"active simulation must still render");
        check(!cache.canReuse(true,updated,0,0,2,true),"new XI snapshot needs render");
        check(!cache.canReuse(true,original,1,0,2,true),"camera change needs render");
        check(!cache.canReuse(true,original,0,1,2,true),"material change needs render");
        check(!cache.canReuse(true,original,0,0,1,true),"quality change needs render");
        check(!cache.canReuse(true,original,0,0,2,false),"4K to CPU transition needs render");
        check(!cache.canReuse(true,null,0,0,2,true),"missing XI state must never reuse");
        cache.framePosted(updated,2,3,1,false);
        check(cache.canReuse(true,updated,2,3,1,false),"new low-resolution frame is reusable");
        cache.invalidate();
        check(!cache.canReuse(true,updated,2,3,1,false),"reset/surface invalidates cached pixels");
        boolean rejected=false;
        try{cache.framePosted(null,0,0,1,false);}catch(IllegalArgumentException ignored){rejected=true;}
        check(rejected,"unobserved frame cannot be presented");
        System.out.println("VELOCITY_FRAME_REUSE_PASS checks="+checks+
            " frozen4KReuses=100 semanticSnapshotIdentity=true");
    }
}
