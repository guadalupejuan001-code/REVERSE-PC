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
 * X Render is the only scene renderer. This class merely schedules fixed ticks,
 * copies its packed ARGB output and presents it with Android Canvas.
 */
final class VelocityXSurface extends SurfaceView implements SurfaceHolder.Callback,Runnable {
    interface Hud {
        void update(int speedKmh,int checkpoints,int total,long seconds,
                    boolean offRoad,int slideMmps,boolean finished,int fps,
                    int renderWidth,int renderHeight,String error);
    }
    static { System.loadLibrary("reverse_os"); }
    private static native void renderNative(int[] argb,int width,int height,
                     long xMm,long zMm,int yaw16,int checkpoint,int camera,int paint,
                     float[] xiTrack);

    private final VelocityXiEngine game;
    private final Hud hud;
    private final Paint paint=new Paint(Paint.FILTER_BITMAP_FLAG);
    private final Rect sourceRect=new Rect();
    private final Rect targetRect=new Rect();
    private volatile boolean running;
    private Thread worker;
    private volatile int gas,brake,steer=1;
    private volatile boolean handbrake,resetRequested;
    private volatile int cameraMode,paintId,quality;
    private volatile int surfaceWidth=16,surfaceHeight=9;
    private volatile String error="";
    VelocityXSurface(Context context,VelocityXiEngine game,Hud hud){
        super(context);this.game=game;this.hud=hud;
        getHolder().addCallback(this);
        setKeepScreenOn(true);
    }
    void controls(int gas,int brake,int steer,boolean handbrake){
        if(gas<0||gas>1||brake<0||brake>1||steer<0||steer>2)
            throw new IllegalArgumentException("Control fuera del protocolo XI");
        this.gas=gas;this.brake=brake;this.steer=steer;this.handbrake=handbrake;
    }
    void reset(){resetRequested=true;}
    int cycleCamera(){cameraMode=(cameraMode+1)%3;return cameraMode;}
    int cyclePaint(){paintId=(paintId+1)%5;return paintId;}
    int cycleQuality(){quality=(quality+1)%3;return quality;}

    synchronized void startLoop(){
        if(worker!=null||!getHolder().getSurface().isValid())return;
        running=true;worker=new Thread(this,"REVERSE-VELOCITY-XRENDER");
        worker.start();
    }
    void stopLoop(){
        Thread thread;
        synchronized(this){running=false;thread=worker;}
        if(thread!=null&&thread!=Thread.currentThread()){
            try{thread.join(2500);}catch(InterruptedException ex){Thread.currentThread().interrupt();}
        }
    }
    @Override public void surfaceCreated(SurfaceHolder holder){startLoop();}
    @Override public void surfaceChanged(SurfaceHolder holder,int format,int w,int h){
        surfaceWidth=Math.max(1,w);surfaceHeight=Math.max(1,h);
    }
    @Override public void surfaceDestroyed(SurfaceHolder holder){stopLoop();}

    @Override public void run(){
        long previous=SystemClock.elapsedRealtimeNanos(),lastHud=0,lastFps=previous;
        int accumulator=0,frames=0,fps=0,currentQuality=-1;
        int width=0,height=0;
        int[] pixels=null;
        Bitmap image=null;
        try{
            while(running){
                final long begin=SystemClock.elapsedRealtimeNanos();
                final long delta=Math.min(100L,Math.max(0L,(begin-previous)/1_000_000L));
                previous=begin;accumulator+=(int)delta;
                if(resetRequested){
                    game.step(0,0,1,0,true);
                    resetRequested=false;accumulator=0;
                }
                int ticks=0;
                while(accumulator>=20&&ticks++<5){
                    game.step(gas,brake,steer,handbrake?1:0,false);
                    accumulator-=20;
                }
                if(accumulator>=20)accumulator=0;
                final VelocityXiEngine.Snapshot frame=game.current();
                int selected=Math.max(0,Math.min(2,quality));
                int targetWidth=selected==0?320:selected==1?640:1280;
                double ratio=Math.min(2.7,Math.max(1.2,(double)surfaceWidth/surfaceHeight));
                int targetHeight=Math.max(72,Math.min(720,(int)Math.round(targetWidth/ratio)));
                if(selected!=currentQuality||targetHeight!=height){
                    currentQuality=selected;
                    width=targetWidth;height=targetHeight;
                    pixels=new int[width*height];
                    if(image!=null)image.recycle();
                    image=Bitmap.createBitmap(width,height,Bitmap.Config.ARGB_8888);
                    sourceRect.set(0,0,width,height);
                }
                renderNative(pixels,width,height,frame.xCm*10L,frame.zCm*10L,
                             frame.yaw4096*16,frame.checkpoint,cameraMode,paintId,
                             game.track());
                image.setPixels(pixels,0,width,0,0,width,height);
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
                frames++;
                if(begin-lastFps>=1_000_000_000L){
                    fps=(int)Math.round(frames*1_000_000_000.0/(begin-lastFps));
                    frames=0;lastFps=begin;
                }
                if(begin-lastHud>=250_000_000L){
                    lastHud=begin;
                    hud.update(frame.speedKmh(),frame.checkpoint,
                         6,frame.seconds(),frame.offRoad,frame.slideCmps*10,
                         frame.finished,fps,width,height,error);
                }
                final long cost=SystemClock.elapsedRealtimeNanos()-begin;
                final long remaining=16_666_667L-cost; // up to 60 FPS; actual FPS remains measured
                if(remaining>1_000_000L)Thread.sleep(remaining/1_000_000L);
            }
        }catch(Throwable thrown){
            error="XI / X Render: "+thrown.getClass().getSimpleName()+" — "+thrown.getMessage();
            final VelocityXiEngine.Snapshot last=game.current();
            hud.update(last==null?0:last.speedKmh(),last==null?0:last.checkpoint,6,
                last==null?0:last.seconds(),last!=null&&last.offRoad,
                last==null?0:last.slideCmps*10,last!=null&&last.finished,0,width,height,error);
        }finally{
            if(image!=null&&!image.isRecycled())image.recycle();
            synchronized(this){
                running=false;
                if(Thread.currentThread()==worker)worker=null;
            }
        }
    }
}
