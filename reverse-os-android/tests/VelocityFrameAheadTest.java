package com.reversepc.os;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
public final class VelocityFrameAheadTest {
    static void check(boolean ok,String why){if(!ok)throw new AssertionError(why);}
    public static void main(String[] args)throws Exception{
        AtomicInteger calls=new AtomicInteger();CountDownLatch prepared=new CountDownLatch(2);
        try(VelocityFrameAhead<Integer> a=new VelocityFrameAhead<>()){
            check(a.acquire("view-a",()->{int n=calls.incrementAndGet();prepared.countDown();return n;})==1,"first immutable observation");
            check(prepared.await(2,TimeUnit.SECONDS),"next CPU frame progresses while consumer presents");
            check(calls.get()==2&&a.queued()<=1,"production stops after one frame ahead");
            check(a.acquire("view-b",()->100)==100,"camera/quality invalidation never presents stale prepared frame");
            a.invalidate();check(a.queued()==0,"pause removes queued work");
        }
        AtomicInteger active=new AtomicInteger(),max=new AtomicInteger(),produced=new AtomicInteger();CountDownLatch entered=new CountDownLatch(1),release=new CountDownLatch(1);
        try(VelocityFrameAhead<Integer> a=new VelocityFrameAhead<>()){
            check(a.acquire("old",()->{int n=produced.incrementAndGet();max.accumulateAndGet(active.incrementAndGet(),Math::max);
                try{if(n>1){entered.countDown();check(release.await(2,TimeUnit.SECONDS),"old producer released");}return n;}
                finally{active.decrementAndGet();}})==1,"first producer runs before invalidation");
            check(entered.await(2,TimeUnit.SECONDS),"old worker entered");a.invalidate();release.countDown();
            check(a.acquire("new",()->999)==999,"replacement waits for old native producer and returns current view");
            check(max.get()<=1,"single producer retains transport ordering");
        }
        try(VelocityFrameAhead<Integer> a=new VelocityFrameAhead<>()){
            try{a.acquire("bad",()->{throw new IllegalStateException("native failure");});throw new AssertionError("failure hidden");}
            catch(IllegalStateException expected){check(expected.getMessage().equals("native failure"),"native errors are preserved");}
        }
        System.out.println("VELOCITY_FRAME_AHEAD_PASS overlap=true bounded=true invalidation=true");
    }
}
