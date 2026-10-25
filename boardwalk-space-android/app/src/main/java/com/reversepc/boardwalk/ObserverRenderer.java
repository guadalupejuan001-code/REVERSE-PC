package com.reversepc.boardwalk;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.opengl.GLES30;
import android.opengl.GLSurfaceView;
import android.opengl.GLUtils;
import android.os.Handler;
import android.os.Looper;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.charset.StandardCharsets;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

/** Offline procedural local Boardwalk + NASA Earth map + altitude ray tracing. */
public final class ObserverRenderer implements GLSurfaceView.Renderer {
    public interface Listener {
        void onFrameRate(int fps, float scale);
        void onPhoto(Bitmap photo);
        void onError(String error);
    }

    private final Context context;
    private final Listener listener;
    private final Handler handler = new Handler(Looper.getMainLooper());
    private final FloatBuffer quad = ByteBuffer.allocateDirect(8*4)
            .order(ByteOrder.nativeOrder()).asFloatBuffer();
    private final float[] basis = ObserverMath.tangentBasis();
    private final float[] sun = ObserverMath.sunlight(250.,22.);

    volatile float progress = 0f;
    volatile float heading = 128f;
    volatile float pitch = -3.5f;
    volatile int quality = 0; // AUTO, ECO, ULTRA
    volatile boolean photoRequested;

    private int earthTexture;
    private int sceneProgram,blitProgram,framebuffer,frameTexture;
    private int screenWidth,screenHeight,internalWidth,internalHeight;
    private long startNs,frameIntervalStartNs;
    private int count;
    private float adaptiveScale=.72f,finalScale=.72f;
    private int consecutiveSlow,consecutiveFast;

    public ObserverRenderer(Context context,Listener listener) {
        this.context=context.getApplicationContext();
        this.listener=listener;
        quad.put(new float[]{-1f,-1f,1f,-1f,-1f,1f,1f,1f}).position(0);
    }

    private String asset(String name) {
        try(InputStream in=context.getAssets().open(name);
            ByteArrayOutputStream out=new ByteArrayOutputStream()) {
            byte[] buffer=new byte[8192];
            int count;
            while((count=in.read(buffer))!=-1)out.write(buffer,0,count);
            return out.toString(StandardCharsets.UTF_8.name());
        }catch(IOException e){throw new IllegalStateException("Asset: "+name,e);}
    }

    private int shader(int type,String source) {
        int shader=GLES30.glCreateShader(type);
        if(shader==0)throw new IllegalStateException("No se pudo crear shader OpenGL");
        GLES30.glShaderSource(shader,source);
        GLES30.glCompileShader(shader);
        int[] state=new int[1];
        GLES30.glGetShaderiv(shader,GLES30.GL_COMPILE_STATUS,state,0);
        if(state[0]==0){
            String info=GLES30.glGetShaderInfoLog(shader);
            GLES30.glDeleteShader(shader);
            throw new IllegalStateException("Shader: "+info);
        }
        return shader;
    }

    private int program(String fragment) {
        int v=shader(GLES30.GL_VERTEX_SHADER,asset("observer.vert"));
        int f=shader(GLES30.GL_FRAGMENT_SHADER,asset(fragment));
        int program=GLES30.glCreateProgram();
        GLES30.glAttachShader(program,v);
        GLES30.glAttachShader(program,f);
        GLES30.glLinkProgram(program);
        int[] success=new int[1];
        GLES30.glGetProgramiv(program,GLES30.GL_LINK_STATUS,success,0);
        GLES30.glDeleteShader(v);GLES30.glDeleteShader(f);
        if(success[0]==0){
            String info=GLES30.glGetProgramInfoLog(program);
            GLES30.glDeleteProgram(program);
            throw new IllegalStateException("Link: "+info);
        }
        return program;
    }

    @Override public void onSurfaceCreated(GL10 ignored,EGLConfig config) {
        try {
            sceneProgram=program("observer.frag");
            blitProgram=program("blit.frag");
            try(InputStream stream=context.getAssets().open("earth_1024.png")) {
                Bitmap map=BitmapFactory.decodeStream(stream);
                if(map==null || map.getWidth()!=1024 || map.getHeight()!=512)
                    throw new IllegalStateException("NASA Earth texture must be 1024x512");
                int[] ids=new int[1];
                GLES30.glGenTextures(1,ids,0);
                earthTexture=ids[0];
                GLES30.glBindTexture(GLES30.GL_TEXTURE_2D,earthTexture);
                GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D,GLES30.GL_TEXTURE_MIN_FILTER,GLES30.GL_LINEAR_MIPMAP_LINEAR);
                GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D,GLES30.GL_TEXTURE_MAG_FILTER,GLES30.GL_LINEAR);
                GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D,GLES30.GL_TEXTURE_WRAP_S,GLES30.GL_REPEAT);
                GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D,GLES30.GL_TEXTURE_WRAP_T,GLES30.GL_CLAMP_TO_EDGE);
                GLUtils.texImage2D(GLES30.GL_TEXTURE_2D,0,map,0);
                GLES30.glGenerateMipmap(GLES30.GL_TEXTURE_2D);
                map.recycle();
            }
            GLES30.glDisable(GLES30.GL_DEPTH_TEST);
            GLES30.glDisable(GLES30.GL_BLEND);
            GLES30.glClearColor(0f,0f,0f,1f);
            framebuffer=frameTexture=internalWidth=internalHeight=0;
            startNs=frameIntervalStartNs=System.nanoTime();
            count=0;
        }catch(Throwable error){
            report(error.toString());
            throw new IllegalStateException("Boardwalk GPU failed",error);
        }
    }

    @Override public void onSurfaceChanged(GL10 ignored,int width,int height){
        screenWidth=Math.max(width,1);
        screenHeight=Math.max(height,1);
        internalWidth=internalHeight=0;
    }

    private void framebuffer(int w,int h) {
        if(framebuffer!=0 && internalWidth==w && internalHeight==h)return;
        if(frameTexture!=0)GLES30.glDeleteTextures(1,new int[]{frameTexture},0);
        if(framebuffer!=0)GLES30.glDeleteFramebuffers(1,new int[]{framebuffer},0);
        int[] id=new int[1];
        GLES30.glGenTextures(1,id,0);
        frameTexture=id[0];
        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D,frameTexture);
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D,GLES30.GL_TEXTURE_MIN_FILTER,GLES30.GL_LINEAR);
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D,GLES30.GL_TEXTURE_MAG_FILTER,GLES30.GL_LINEAR);
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D,GLES30.GL_TEXTURE_WRAP_S,GLES30.GL_CLAMP_TO_EDGE);
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D,GLES30.GL_TEXTURE_WRAP_T,GLES30.GL_CLAMP_TO_EDGE);
        GLES30.glTexImage2D(GLES30.GL_TEXTURE_2D,0,GLES30.GL_RGBA8,w,h,0,
                GLES30.GL_RGBA,GLES30.GL_UNSIGNED_BYTE,null);
        GLES30.glGenFramebuffers(1,id,0);
        framebuffer=id[0];
        GLES30.glBindFramebuffer(GLES30.GL_FRAMEBUFFER,framebuffer);
        GLES30.glFramebufferTexture2D(GLES30.GL_FRAMEBUFFER,
                GLES30.GL_COLOR_ATTACHMENT0,GLES30.GL_TEXTURE_2D,frameTexture,0);
        int result=GLES30.glCheckFramebufferStatus(GLES30.GL_FRAMEBUFFER);
        if(result!=GLES30.GL_FRAMEBUFFER_COMPLETE)
            throw new IllegalStateException("Offscreen buffer: "+Integer.toHexString(result));
        internalWidth=w;internalHeight=h;
        GLES30.glBindFramebuffer(GLES30.GL_FRAMEBUFFER,0);
    }

    private static void uniform1(int program,String name,float value) {
        int location=GLES30.glGetUniformLocation(program,name);
        if(location>=0)GLES30.glUniform1f(location,value);
    }
    private static void uniform2(int program,String name,float a,float b) {
        int location=GLES30.glGetUniformLocation(program,name);
        if(location>=0)GLES30.glUniform2f(location,a,b);
    }
    private static void uniform3(int program,String name,float x,float y,float z) {
        int location=GLES30.glGetUniformLocation(program,name);
        if(location>=0)GLES30.glUniform3f(location,x,y,z);
    }
    private void quad(){
        quad.position(0);
        GLES30.glEnableVertexAttribArray(0);
        GLES30.glVertexAttribPointer(0,2,GLES30.GL_FLOAT,false,0,quad);
        GLES30.glDrawArrays(GLES30.GL_TRIANGLE_STRIP,0,4);
        GLES30.glDisableVertexAttribArray(0);
    }

    private float renderingScale(){
        final float desired = quality==1?.49f:quality==2?1f:adaptiveScale;
        final float cap = (float)Math.sqrt((quality==2?1700000f:1150000f)/
                Math.max(1.,(double)screenWidth*screenHeight));
        return Math.min(desired,Math.max(.38f,cap));
    }

    @Override public void onDrawFrame(GL10 ignored) {
        if(sceneProgram==0 || screenWidth==0 || screenHeight==0)return;
        try {
            finalScale=renderingScale();
            int w=Math.max(2,Math.round(screenWidth*finalScale));
            int h=Math.max(2,Math.round(screenHeight*finalScale));
            framebuffer(w,h);
            GLES30.glBindFramebuffer(GLES30.GL_FRAMEBUFFER,framebuffer);
            GLES30.glViewport(0,0,w,h);
            GLES30.glUseProgram(sceneProgram);
            GLES30.glActiveTexture(GLES30.GL_TEXTURE0);
            GLES30.glBindTexture(GLES30.GL_TEXTURE_2D,earthTexture);
            GLES30.glUniform1i(GLES30.glGetUniformLocation(sceneProgram,"uEarth"),0);
            uniform2(sceneProgram,"uResolution",w,h);
            uniform1(sceneProgram,"uAltitudeKm",(float)ObserverMath.altitudeKm(progress));
            uniform1(sceneProgram,"uHeading",heading);
            uniform1(sceneProgram,"uPitch",pitch);
            uniform1(sceneProgram,"uTime",(System.nanoTime()-startNs)*1e-9f);
            uniform1(sceneProgram,"uDetail",quality==1?0f:1f);
            uniform3(sceneProgram,"uEast",basis[0],basis[1],basis[2]);
            uniform3(sceneProgram,"uNorth",basis[3],basis[4],basis[5]);
            uniform3(sceneProgram,"uUp",basis[6],basis[7],basis[8]);
            uniform3(sceneProgram,"uSun",sun[0],sun[1],sun[2]);
            quad();

            if(photoRequested){
                photoRequested=false;
                capture(w,h);
            }

            GLES30.glBindFramebuffer(GLES30.GL_FRAMEBUFFER,0);
            GLES30.glViewport(0,0,screenWidth,screenHeight);
            GLES30.glUseProgram(blitProgram);
            GLES30.glActiveTexture(GLES30.GL_TEXTURE0);
            GLES30.glBindTexture(GLES30.GL_TEXTURE_2D,frameTexture);
            GLES30.glUniform1i(GLES30.glGetUniformLocation(blitProgram,"uTex"),0);
            quad();
            count++;
            long now=System.nanoTime();
            if(now-frameIntervalStartNs>=1000000000L){
                float elapsed=(now-frameIntervalStartNs)/1e9f;
                int fps=Math.round(count/elapsed);
                float currentScale=finalScale;
                handler.post(()->listener.onFrameRate(fps,currentScale));
                if(quality==0){
                    if(fps<27){consecutiveSlow++;consecutiveFast=0;}
                    else if(fps>52){consecutiveFast++;consecutiveSlow=0;}
                    else{consecutiveSlow=consecutiveFast=0;}
                    if(consecutiveSlow>=2){adaptiveScale=Math.max(.43f,adaptiveScale-.075f);consecutiveSlow=0;}
                    if(consecutiveFast>=4){adaptiveScale=Math.min(.88f,adaptiveScale+.035f);consecutiveFast=0;}
                }
                count=0;
                frameIntervalStartNs=now;
            }
        } catch(Throwable error) {
            report(error.toString());
            throw new IllegalStateException("Boardwalk rendering failed",error);
        }
    }

    private void capture(int width,int height) {
        if((long)width*height>1900000L){report("Imagen demasiado grande");return;}
        ByteBuffer data=ByteBuffer.allocateDirect(width*height*4);
        GLES30.glReadPixels(0,0,width,height,GLES30.GL_RGBA,GLES30.GL_UNSIGNED_BYTE,data);
        int glError=GLES30.glGetError();
        if(glError!=GLES30.GL_NO_ERROR){report("GL capture error "+glError);return;}
        Thread converter=new Thread(()->{
            try {
                int[] pixels=new int[width*height];
                for(int y=0;y<height;y++)for(int x=0;x<width;x++){
                    int offset=((height-1-y)*width+x)*4;
                    pixels[y*width+x]=0xff000000|
                            ((data.get(offset)&255)<<16)|((data.get(offset+1)&255)<<8)|
                            (data.get(offset+2)&255);
                }
                Bitmap image=Bitmap.createBitmap(pixels,width,height,Bitmap.Config.ARGB_8888);
                handler.post(()->listener.onPhoto(image));
            } catch(Throwable e){report("PNG: "+e.getMessage());}
        },"Boardwalk-Frame-Capture");
        converter.setDaemon(true);
        converter.start();
    }
    private void report(String error){handler.post(()->listener.onError(error));}
}
