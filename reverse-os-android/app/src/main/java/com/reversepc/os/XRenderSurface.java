package com.reversepc.os;

import android.content.Context;
import android.opengl.GLSurfaceView;
import java.util.concurrent.atomic.AtomicReference;
import java.util.concurrent.atomic.AtomicReferenceArray;
import javax.microedition.khronos.egl.EGL10;
import javax.microedition.khronos.egl.EGLDisplay;
import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

/** Ether Render X mesh GPU path and compatible sparse CPU path. */
final class XRenderSurface extends GLSurfaceView implements GLSurfaceView.Renderer {
    private final AtomicReference<float[]> newest=new AtomicReference<>();
    private final AtomicReferenceArray<float[]> models=new AtomicReferenceArray<>(5);
    private final float[][] uploaded=new float[5][];
    private final java.util.function.Consumer<String> failure;
    private volatile String info="{\"frames\":0}";
    private volatile boolean released=false;
    private long nativeHandle;
    private float[] current;
    XRenderSurface(Context context,java.util.function.Consumer<String> failure){
        super(context);this.failure=failure;
        setEGLContextClientVersion(3);setEGLConfigChooser((egl,display)->chooseConfig(egl,display));
        setPreserveEGLContextOnPause(true);setRenderer(this);setRenderMode(RENDERMODE_WHEN_DIRTY);
    }
    void submit(float[] frame){
        if(released||frame==null||frame.length<16||frame.length>16+128*12)return;
        newest.set(frame);requestRender();
    }
    String info(){return info;}
    void model(int id,float[] vertices){
        if(released||id<0||id>4||vertices==null||vertices.length<36||vertices.length>384000||vertices.length%36!=0)return;
        models.set(id,vertices);requestRender();
    }
    private static EGLConfig chooseConfig(EGL10 egl,EGLDisplay display){
        for(int samples:new int[]{4,0}){
            int[] attrs={EGL10.EGL_RENDERABLE_TYPE,0x40,EGL10.EGL_SURFACE_TYPE,EGL10.EGL_WINDOW_BIT,EGL10.EGL_RED_SIZE,8,EGL10.EGL_GREEN_SIZE,8,EGL10.EGL_BLUE_SIZE,8,EGL10.EGL_ALPHA_SIZE,8,EGL10.EGL_DEPTH_SIZE,24,EGL10.EGL_SAMPLE_BUFFERS,samples>0?1:0,EGL10.EGL_SAMPLES,samples,EGL10.EGL_NONE};
            int[] count={0};if(egl.eglChooseConfig(display,attrs,null,0,count)&&count[0]>0){EGLConfig[] configs=new EGLConfig[count[0]];if(egl.eglChooseConfig(display,attrs,configs,configs.length,count))return configs[0];}
        }
        throw new IllegalArgumentException("GLES 3 depth surface unavailable");
    }
    @Override public void onSurfaceCreated(GL10 unused,EGLConfig config){
        if(released)return;
        try{if(nativeHandle!=0)NativeRuntime.xRenderDestroy(nativeHandle,false);nativeHandle=NativeRuntime.xRenderCreate();java.util.Arrays.fill(uploaded,null);}
        catch(Exception error){fail(error);}
    }
    @Override public void onSurfaceChanged(GL10 unused,int width,int height){
        if(released||nativeHandle==0)return;
        try{NativeRuntime.xRenderResize(nativeHandle,width,height);}
        catch(Exception error){fail(error);}
    }
    @Override public void onDrawFrame(GL10 unused){
        if(released||nativeHandle==0)return;
        float[] next=newest.getAndSet(null);if(next!=null)current=next;
        if(current==null)return;
        try{for(int i=0;i<5;i++){float[] model=models.get(i);if(model!=null&&model!=uploaded[i]){NativeRuntime.xRenderModel(nativeHandle,i,model);uploaded[i]=model;}}info=NativeRuntime.xRenderFrame(nativeHandle,current);}
        catch(Exception error){fail(error);}
    }
    private void fail(Exception error){
        info="{\"frames\":0,\"error\":true}";
        released=true;post(()->failure.accept("X Render: "+error.getMessage()));
        if(nativeHandle!=0){NativeRuntime.xRenderDestroy(nativeHandle,true);nativeHandle=0;}
    }
    void release(){
        released=true;newest.set(null);
        queueEvent(()->{if(nativeHandle!=0){NativeRuntime.xRenderDestroy(nativeHandle,true);nativeHandle=0;}current=null;});
    }
}
