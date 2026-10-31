package com.reversepc.os;

import java.util.Collections;
import java.util.HashSet;
import java.util.Set;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

/** Real-thread regression for a native frame that outlives a timed stop. */
public final class VelocityLoopLifecycleTest {
    private static int checks;
    private static void check(boolean condition,String message){
        checks++;
        if(!condition)throw new AssertionError(message);
    }
    private static void await(CountDownLatch latch,String name)throws Exception{
        check(latch.await(2,TimeUnit.SECONDS),"Timed out: "+name);
    }
    public static void main(String[] args)throws Exception{
        AtomicInteger starts=new AtomicInteger(),active=new AtomicInteger(),maxActive=new AtomicInteger();
        CountDownLatch firstEntered=new CountDownLatch(1),releaseFirst=new CountDownLatch(1),
            secondEntered=new CountDownLatch(1),thirdEntered=new CountDownLatch(1);
        Set<Thread> threads=Collections.synchronizedSet(new HashSet<>());
        VelocityLoopLifecycle[] owner=new VelocityLoopLifecycle[1];
        owner[0]=new VelocityLoopLifecycle(()->{
            int iteration=starts.incrementAndGet();
            threads.add(Thread.currentThread());
            int current=active.incrementAndGet();
            maxActive.accumulateAndGet(current,Math::max);
            try{
                if(iteration==1){firstEntered.countDown();releaseFirst.await();}
                if(iteration==2)secondEntered.countDown();
                if(iteration==3)thirdEntered.countDown();
                while(owner[0].shouldRun())Thread.sleep(2);
            }catch(InterruptedException error){
                Thread.currentThread().interrupt();
                throw new AssertionError(error);
            }finally{active.decrementAndGet();}
        });
        VelocityLoopLifecycle loop=owner[0];
        try{
            // A surface callback alone must never resume a paused Activity.
            loop.setSurfaceReady(true);
            check(!firstEntered.await(40,TimeUnit.MILLISECONDS),"Surface started while Activity paused");
            loop.resume();await(firstEntered,"first worker");

            // The first body simulates a long native shader: stop times out,
            // resume arrives before it completes, and a fresh body must follow.
            loop.pause();
            check(!loop.awaitStopped(20),"Blocking native body unexpectedly stopped");
            loop.resume();
            check(!secondEntered.await(40,TimeUnit.MILLISECONDS),"Second worker overlapped blocked renderer");
            releaseFirst.countDown();await(secondEntered,"resumed body after delayed stop");
            check(starts.get()==2,"Lost or duplicated resume");
            check(threads.size()==1,"Delayed resume created a second physical thread");
            check(maxActive.get()==1,"Render bodies overlapped");

            // Destroy/recreate callbacks while paused must remain quiescent.
            loop.pause();loop.setSurfaceReady(false);
            check(loop.awaitStopped(1000),"Worker did not finish after surface destruction");
            loop.setSurfaceReady(true);
            check(!thirdEntered.await(40,TimeUnit.MILLISECONDS),"Surface recreation resumed paused Activity");
            loop.resume();await(thirdEntered,"explicit resumed surface");
            loop.close();
            check(loop.awaitStopped(1000),"Closed worker did not terminate");
            int closedStarts=starts.get();
            loop.resume();loop.setSurfaceReady(true);
            check(loop.awaitStopped(0)&&starts.get()==closedStarts,"Closed view restarted");
            check(maxActive.get()==1&&active.get()==0,"Worker lifecycle leaked or overlapped");
        }finally{
            releaseFirst.countDown();loop.close();loop.awaitStopped(1000);
        }

        // A renderer failure stops instead of entering an automatic retry loop.
        AtomicInteger failures=new AtomicInteger();
        CountDownLatch failed=new CountDownLatch(1);
        VelocityLoopLifecycle broken=new VelocityLoopLifecycle(()->{
            failures.incrementAndGet();failed.countDown();throw new IllegalStateException("test shader failure");
        });
        try{
            broken.setSurfaceReady(true);broken.resume();await(failed,"failing renderer");
            check(broken.awaitStopped(1000),"Failed renderer remained active");
            broken.setSurfaceReady(true);
            check(broken.awaitStopped(1000)&&failures.get()==1,"Failure retried without explicit resume");
            broken.resume();
            check(broken.awaitStopped(1000)&&failures.get()==2,"Explicit resume could not retry renderer");
        }finally{broken.close();broken.awaitStopped(1000);}
        System.out.println("VELOCITY_LOOP_LIFECYCLE_PASS checks="+checks+
            " delayedStopResume=true pausedSurfaceGuard=true maxConcurrentBodies="+maxActive.get());
    }
}
