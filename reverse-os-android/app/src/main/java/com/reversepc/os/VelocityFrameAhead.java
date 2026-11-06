package com.reversepc.os;

import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.FutureTask;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

/** One immutable future frame while the GPU presents the current frame. */
final class VelocityFrameAhead<T> implements AutoCloseable {
    private final ThreadPoolExecutor worker=new ThreadPoolExecutor(1,1,0,TimeUnit.MILLISECONDS,
        new ArrayBlockingQueue<Runnable>(1),r->{Thread t=new Thread(r,"Velocity-XI-Prepare");t.setDaemon(true);return t;});
    private FutureTask<T> next;
    private Object key;
    long acquired,discarded,waitNanos;
    T acquire(Object wanted,Callable<T> prepare)throws Exception{
        if(next==null||!wanted.equals(key)){
            invalidate();next=new FutureTask<>(prepare);key=wanted;worker.execute(next);
        }
        FutureTask<T> current=next;next=null;key=null;
        long begin=System.nanoTime();T value;
        try{value=current.get();}
        catch(ExecutionException failure){
            Throwable cause=failure.getCause();if(cause instanceof Exception)throw (Exception)cause;
            if(cause instanceof Error)throw (Error)cause;throw new RuntimeException(cause);
        }
        waitNanos+=System.nanoTime()-begin;acquired++;
        // No GPU queue grows here. Exactly one next CPU observation is allowed.
        next=new FutureTask<>(prepare);key=wanted;worker.execute(next);return value;
    }
    void invalidate(){
        if(next!=null){next.cancel(false);worker.remove(next);next=null;key=null;discarded++;}
    }
    int queued(){return worker.getQueue().size();}
    @Override public void close(){invalidate();worker.shutdownNow();}
}
