package com.reversepc.os;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.os.SystemClock;
import android.view.SurfaceHolder;
import android.view.SurfaceView;

/**
 * Only an Android bitmap presenter and fixed-tick driver.
 * Actual ray tracing, depth and materials are produced by Mundo X
 * EtherRenderEngine through velocity_xrender_jni.cpp. Not a GLES renderer.
 */
final class VelocityXSurface extends SurfaceView implements SurfaceHolder.Callback,Runnable {
    interface Hud {
        void update(int speedKmh,int checkpoints,int total,long seconds,boolean offRoad,String error);
    }
    private static final int W=320,H=180;
    static { System.loadLibrary("reverse_os"); }
    private static native void renderNative(int[] argb,int width,int height,
                     long xMm,long zMm,int yaw16,int checkpoint);

    private final VelocityPhysics physics;
    private final Hud hud;
    private final int[] pixels=new int[W*H];
    private final Bitmap image=Bitmap.createBitmap(W,H,Bitmap.Config.ARGB_8888);
    private final Paint paint=new Paint(Paint.FILTER_BITMAP_FLAG);
    private final Rect sourceRect=new Rect(0,0,W,H);
    private final Rect targetRect=new Rect();
    private volatile boolean running;
    private Thread worker;
    private volatile int gas,brake,steer;
    private volatile boolean handbrake,resetRequested;
    private volatile String error="";

    VelocityXSurface(Context context,VelocityPhysics physics,Hud hud){
        super(context);
        this.physics=physics;this.hud=hud;
        getHolder().addCallback(this);
        setKeepScreenOn(true);
    }
    void controls(int gas,int brake,int steer,boolean handbrake){
        this.gas=gas;this.brake=brake;this.steer=steer;this.handbrake=handbrake;
    }
    void reset(){resetRequested=true;}
    synchronized void startLoop(){
        if(worker!=null&&worker.isAlive())return;
        if(!getHolder().getSurface().isValid())return;
        running=true;
        worker=new Thread(this,"REVERSE-VELOCITY-XRENDER");
        worker.start();
    }
    synchronized void stopLoop(){
        running=false;
        Thread previous=worker;
        if(previous!=null&&previous!=Thread.currentThread()){
            try{previous.join(450);}catch(InterruptedException e){Thread.currentThread().interrupt();}
        }
        if(previous!=null&&!previous.isAlive())worker=null;
    }
    @Override public void surfaceCreated(SurfaceHolder holder){startLoop();}
    @Override public void surfaceChanged(SurfaceHolder holder,int format,int width,int height){}
    @Override public void surfaceDestroyed(SurfaceHolder holder){stopLoop();}

    @Override public void run(){
        long previous=SystemClock.elapsedRealtimeNanos(),frame=0;
        int accumulator=0;
        try{
            while(running){
                final long begin=SystemClock.elapsedRealtimeNanos();
                final long delta=Math.min(100L,Math.max(0L,(begin-previous)/1_000_000L));
                previous=begin;accumulator+=(int)delta;
                if(resetRequested){physics.reset();resetRequested=false;accumulator=0;}
                int ticks=0;
                while(accumulator>=VelocityPhysics.TICK_MS&&ticks++<5){
                    physics.step(gas,brake,steer,handbrake);
                    accumulator-=VelocityPhysics.TICK_MS;
                }
                if(accumulator>=VelocityPhysics.TICK_MS)accumulator=0;
                renderNative(pixels,W,H,physics.xMm,physics.zMm,
                             physics.yaw16,physics.checkpoint);
                image.setPixels(pixels,0,W,0,0,W,H);
                Canvas canvas=null;
                try{
                    canvas=getHolder().lockCanvas();
                    if(canvas!=null){
                        canvas.drawColor(0xff0a1018);
                        targetRect.set(0,0,canvas.getWidth(),canvas.getHeight());
                        canvas.drawBitmap(image,sourceRect,targetRect,paint);
                    }
                }finally{
                    if(canvas!=null)getHolder().unlockCanvasAndPost(canvas);
                }
                if(begin-frame>250_000_000L){
                    frame=begin;
                    hud.update((int)Math.round(physics.speedKmh()),physics.checkpoint,
                         physics.checkpointCount(),physics.elapsedMs/1000,
                         physics.offRoad,error);
                }
                final long cost=SystemClock.elapsedRealtimeNanos()-begin;
                final long remaining=42_000_000L-cost; // target <=24 fps; not a guarantee
                if(remaining>1_000_000L)Thread.sleep(remaining/1_000_000L);
            }
        }catch(Throwable thrown){
            error="X Render: "+thrown.getClass().getSimpleName()+" — "+thrown.getMessage();
            hud.update(0,physics.checkpoint,physics.checkpointCount(),
                physics.elapsedMs/1000,physics.offRoad,error);
        }finally{
            running=false;
        }
    }
}
