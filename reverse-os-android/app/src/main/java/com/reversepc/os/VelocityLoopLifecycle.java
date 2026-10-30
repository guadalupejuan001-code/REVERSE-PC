package com.reversepc.os;

/**
 * One render thread, gated independently by Activity and Surface lifetimes.
 * A delayed stop never loses a later resume request or creates a second worker.
 */
final class VelocityLoopLifecycle {
    private final Runnable body;
    private Thread worker;
    private boolean resumed,surfaceReady,closed,failed,runRequested;

    VelocityLoopLifecycle(Runnable body){
        if(body==null)throw new IllegalArgumentException("Render loop body missing");
        this.body=body;
    }
    synchronized void resume(){
        if(closed)return;
        resumed=true;failed=false;
        startIfEligible();
    }
    synchronized void pause(){
        resumed=false;runRequested=false;
    }
    synchronized void close(){
        closed=true;resumed=false;runRequested=false;
    }
    synchronized void setSurfaceReady(boolean ready){
        if(closed)return;
        if(ready&&!surfaceReady)failed=false;
        surfaceReady=ready;
        if(!ready)runRequested=false;
        else startIfEligible();
    }
    synchronized boolean shouldRun(){
        return runRequested&&worker==Thread.currentThread();
    }
    synchronized void fail(){failed=true;runRequested=false;}

    private void startIfEligible(){
        if(worker!=null||!resumed||!surfaceReady||closed||failed)return;
        runRequested=true;
        worker=new Thread(this::work,"REVERSE-VELOCITY-XRENDER");
        worker.start();
    }
    private void work(){
        while(true){
            try{body.run();}
            catch(Throwable failure){synchronized(this){failed=true;}}
            synchronized(this){
                runRequested=false;
                // A stop may have timed out while native rendering was busy.
                // Re-enter the body on this SAME physical thread when a later
                // resume/surface request still wants it, with fresh frame time.
                if(resumed&&surfaceReady&&!closed&&!failed){
                    runRequested=true;
                    continue;
                }
                worker=null;
                return;
            }
        }
    }
    boolean awaitStopped(long timeoutMs){
        if(timeoutMs<0)throw new IllegalArgumentException("Negative stop timeout");
        final Thread thread;
        synchronized(this){thread=worker;}
        if(thread==null)return true;
        if(thread==Thread.currentThread())return false;
        // join(0) would block forever; zero means a nonblocking observation.
        if(timeoutMs==0)return !thread.isAlive();
        try{thread.join(timeoutMs);}
        catch(InterruptedException interrupted){Thread.currentThread().interrupt();}
        return !thread.isAlive();
    }
}
