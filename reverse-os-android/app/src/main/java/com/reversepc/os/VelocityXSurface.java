package com.reversepc.os;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.os.SystemClock;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * REgraphics is the scene renderer. This class merely schedules fixed ticks,
 * materializes its binary XFS1 regions and presents it with Android Canvas.
 */
final class VelocityXSurface extends SurfaceView implements SurfaceHolder.Callback,Runnable {
    interface Hud {
        void update(int speedKmh,int checkpoints,int total,long seconds,
                    boolean offRoad,int slideMmps,boolean finished,boolean ready,boolean paused,int fps,
                    int renderWidth,int renderHeight,String backend,String error);
    }
    private final VelocityXiEngine game;
    private final Hud hud;
    private final Paint paint=new Paint(Paint.FILTER_BITMAP_FLAG);
    private final Rect sourceRect=new Rect();
    private final Rect targetRect=new Rect();
    private final VelocityLoopLifecycle lifecycle;
    private volatile int gas,brake,steer=1;
    private volatile boolean handbrake,resetRequested,paused;
    private final AtomicBoolean timingReset=new AtomicBoolean();
    private volatile int cameraMode,paintId,quality;
    private volatile int surfaceWidth=16,surfaceHeight=9;
    private volatile String error="";
    VelocityXSurface(Context context,VelocityXiEngine game,Hud hud){
        super(context);this.game=game;this.hud=hud;
        lifecycle=new VelocityLoopLifecycle(this);
        getHolder().addCallback(this);
        setKeepScreenOn(true);
    }
    void controls(int gas,int brake,int steer,boolean handbrake){
        if(gas<0||gas>1||brake<0||brake>1||steer<0||steer>2)
            throw new IllegalArgumentException("Control fuera del protocolo XI");
        this.gas=gas;this.brake=brake;this.steer=steer;this.handbrake=handbrake;
    }
    void reset(){resetRequested=true;paused=false;timingReset.set(true);}
    boolean togglePause(){
        paused=!paused;
        timingReset.set(true);
        if(paused)controls(0,0,1,false);
        return paused;
    }
    int cycleCamera(){cameraMode=(cameraMode+1)%3;return cameraMode;}
    int cyclePaint(){paintId=(paintId+1)%5;return paintId;}
    int cycleQuality(){quality=(quality+1)%3;return quality;}
    void resumeLoop(){error="";lifecycle.resume();}
    void pauseLoop(){
        lifecycle.pause();
        lifecycle.awaitStopped(2500);
    }
    void closeLoop(){
        lifecycle.close();
        lifecycle.awaitStopped(2500);
    }
    @Override public void surfaceCreated(SurfaceHolder holder){
        lifecycle.setSurfaceReady(holder.getSurface().isValid());
    }
    @Override public void surfaceChanged(SurfaceHolder holder,int format,int w,int h){
        surfaceWidth=Math.max(1,w);surfaceHeight=Math.max(1,h);
    }
    @Override public void surfaceDestroyed(SurfaceHolder holder){
        lifecycle.setSurfaceReady(false);
        lifecycle.awaitStopped(2500);
    }

    @Override public void run(){
        long previous=SystemClock.elapsedRealtimeNanos(),lastHud=0,lastFps=previous;
        int accumulator=0,frames=0,fps=0,currentQuality=-1;
        int width=0,height=0;
        int[] pixels=null;
        Bitmap image=null;
        boolean firstFramePosted=false;
        try{
            while(lifecycle.shouldRun()){
                final long begin=SystemClock.elapsedRealtimeNanos();
                final long delta=Math.min(100L,Math.max(0L,(begin-previous)/1_000_000L));
                previous=begin;
                // Pause freezes the scheduler, not a second copy of game rules.
                // Discard paused wall time so resuming cannot advance the race.
                if(timingReset.getAndSet(false)||paused)accumulator=0;
                else accumulator+=(int)delta;
                if(resetRequested){
                    game.step(0,0,1,0,true);
                    resetRequested=false;accumulator=0;
                }
                int ticks=0;
                while(lifecycle.shouldRun()&&!paused&&accumulator>=20&&ticks++<5){
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
                // XI Machine v1 exclusively computes every geometry/color span.
                // Android validates and materializes the bounded binary transport.
                int stride=selected==0?4:selected==1?2:1;
                game.renderFrame(stride,cameraMode,paintId).present(pixels,width,height);
                // Native rendering may outlive a pause/surface-destroy callback.
                // Complete that observation without publishing to the old surface.
                if(!lifecycle.shouldRun())break;
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
                if(canvas!=null&&!firstFramePosted){
                    firstFramePosted=true;
                    Log.i("ReverseVelocity","FRAME_READY "+width+"x"+height+
                        " speed="+frame.speedKmh()+" ticks="+frame.ticks+
                        " camera="+cameraMode+" paint="+paintId);
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
                         frame.finished,frame.ticks==0,paused,fps,width,height,"REgraphics",error);
                }
                final long cost=SystemClock.elapsedRealtimeNanos()-begin;
                // A paused scene needs fewer presentations and remains responsive.
                final long remaining=(paused?100_000_000L:16_666_667L)-cost;
                if(remaining>1_000_000L)Thread.sleep(remaining/1_000_000L);
            }
        }catch(Throwable thrown){
            if(lifecycle.shouldRun()){
                lifecycle.fail();
                error="XI / REgraphics: "+thrown.getClass().getSimpleName()+" — "+thrown.getMessage();
                final VelocityXiEngine.Snapshot last=game.current();
                hud.update(last==null?0:last.speedKmh(),last==null?0:last.checkpoint,6,
                    last==null?0:last.seconds(),last!=null&&last.offRoad,
                    last==null?0:last.slideCmps*10,last!=null&&last.finished,
                    last!=null&&last.ticks==0,paused,0,width,height,
                    "REgraphics",error);
            }
        }finally{
            if(image!=null&&!image.isRecycled())image.recycle();
        }
    }
}
