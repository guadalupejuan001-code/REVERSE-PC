package com.reversepc.os;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.opengl.EGL14;
import android.opengl.EGLConfig;
import android.opengl.EGLContext;
import android.opengl.EGLDisplay;
import android.opengl.EGLSurface;
import android.opengl.GLES20;
import android.opengl.GLUtils;
import android.util.Base64;
import org.json.JSONArray;
import org.json.JSONObject;
import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.ShortBuffer;

/**
 * Native Android EGL/GLES2 route for the exact C08 GPU-VIRTUAL selection.
 * WebView may blocklist WebGL even when the Android GLES driver works.
 * These are real shader/buffer/draw/readback commands, not CPU pixel painting.
 */
public final class ReverseGpuNative {
    private ReverseGpuNative() {}
    private static final int W=640,H=400,ATLAS_W=256,ATLAS_H=256,CHAR_W=16,CHAR_H=24;
    private static final int[] PALETTE={
            0x000000,0x0000aa,0x00aa00,0x00aaaa,0xaa0000,0xaa00aa,0xaa5500,0xaaaaaa,
            0x555555,0x5555ff,0x55ff55,0x55ffff,0xff5555,0xff55ff,0xffff55,0xffffff
    };

    private static void require(boolean yes,String message) {
        if(!yes) throw new IllegalStateException(message);
    }
    private static int shader(int kind,String source) {
        int id=GLES20.glCreateShader(kind);
        require(id!=0,"EGL shader allocation failed");
        GLES20.glShaderSource(id,source);
        GLES20.glCompileShader(id);
        int[] result=new int[1];
        GLES20.glGetShaderiv(id,GLES20.GL_COMPILE_STATUS,result,0);
        if(result[0]==0) {
            String error=GLES20.glGetShaderInfoLog(id);
            GLES20.glDeleteShader(id);
            throw new IllegalStateException("GLES shader compile failed: "+error);
        }
        return id;
    }
    private static int link() {
        final int vs=shader(GLES20.GL_VERTEX_SHADER,
                "attribute vec2 position;attribute vec2 uv;attribute vec3 color;"
              +"varying vec2 vUV;varying vec3 vColor;"
              +"void main(){gl_Position=vec4(position,0.0,1.0);vUV=uv;vColor=color;}");
        final int fs=shader(GLES20.GL_FRAGMENT_SHADER,
                "precision mediump float;uniform sampler2D atlas;"
              +"varying vec2 vUV;varying vec3 vColor;"
              +"void main(){float mask=texture2D(atlas,vUV).a;"
              +"if(mask<0.28)discard;gl_FragColor=vec4(vColor,1.0);}");
        int program=GLES20.glCreateProgram();
        require(program!=0,"GLES program allocation failed");
        GLES20.glAttachShader(program,vs);
        GLES20.glAttachShader(program,fs);
        GLES20.glLinkProgram(program);
        int[] result=new int[1];
        GLES20.glGetProgramiv(program,GLES20.GL_LINK_STATUS,result,0);
        GLES20.glDeleteShader(vs);
        GLES20.glDeleteShader(fs);
        if(result[0]==0) {
            String error=GLES20.glGetProgramInfoLog(program);
            GLES20.glDeleteProgram(program);
            throw new IllegalStateException("GLES link failed: "+error);
        }
        return program;
    }
    private static Bitmap glyphAtlas() {
        Bitmap bitmap=Bitmap.createBitmap(ATLAS_W,ATLAS_H,Bitmap.Config.ARGB_8888);
        Canvas canvas=new Canvas(bitmap);
        canvas.drawColor(Color.TRANSPARENT,android.graphics.PorterDuff.Mode.CLEAR);
        Paint pen=new Paint(Paint.ANTI_ALIAS_FLAG|Paint.FILTER_BITMAP_FLAG);
        pen.setColor(Color.WHITE);
        pen.setTextSize(18f);
        pen.setTypeface(Typeface.create(Typeface.MONOSPACE,Typeface.BOLD));
        pen.setTextAlign(Paint.Align.CENTER);
        for(int ascii=32;ascii<128;ascii++) {
            int slot=ascii-32;
            canvas.drawText(Character.toString((char)ascii),
                    (slot%16)*CHAR_W+CHAR_W/2f,
                    (slot/16)*CHAR_H+CHAR_H-4f,pen);
        }
        return bitmap;
    }

    /**
     * Expects precisely the order-preserving [VGA-cell, ASCII, VGA-attribute]
     * triplets chosen by GPU-VIRTUAL PhysicalWorkAuthority.camera_indices.
     */
    public static JSONObject render(JSONArray selected) throws Exception {
        require(selected!=null&&selected.length()<=2000,"Invalid native GPU work count");
        final int glyphs=selected.length();
        FloatBuffer vertices=ByteBuffer.allocateDirect(glyphs*4*7*4)
                .order(ByteOrder.nativeOrder()).asFloatBuffer();
        ShortBuffer index=ByteBuffer.allocateDirect(glyphs*6*2)
                .order(ByteOrder.nativeOrder()).asShortBuffer();
        int previous=-1;
        for(int i=0;i<glyphs;i++) {
            JSONArray cell=selected.getJSONArray(i);
            require(cell.length()==3,"GPU work cell is not canonical");
            int id=cell.getInt(0),ascii=cell.getInt(1),attribute=cell.getInt(2);
            require(id>previous&&id<2000&&ascii>=33&&ascii<=126
                    &&attribute>=0&&attribute<=255,"Original C08 work index invalid");
            previous=id;
            final int x=(id%80)*8,y=(id/80)*16;
            float left=x*2f/W-1f,right=(x+8)*2f/W-1f;
            float top=1f-y*2f/H,bottom=1f-(y+16)*2f/H;
            int glyph=ascii-32,col=glyph%16,row=glyph/16;
            // GLUtils copies Bitmap pixels with their top-down layout; v=0
            // addresses its first row, unlike WebGL UNPACK_FLIP_Y_WEBGL=true.
            float u0=(col*CHAR_W)/(float)ATLAS_W;
            float u1=((col+1)*CHAR_W)/(float)ATLAS_W;
            float v0=(row*CHAR_H)/(float)ATLAS_H;
            float v1=((row+1)*CHAR_H)/(float)ATLAS_H;
            int rgb=PALETTE[attribute&15];
            float red=((rgb>>16)&255)/255f,green=((rgb>>8)&255)/255f,blue=(rgb&255)/255f;
            float[][] corners={{left,top,u0,v0},{right,top,u1,v0},
                               {right,bottom,u1,v1},{left,bottom,u0,v1}};
            for(float[] p:corners)vertices.put(p[0]).put(p[1]).put(p[2]).put(p[3])
                    .put(red).put(green).put(blue);
            int start=i*4;
            index.put((short)start).put((short)(start+1)).put((short)(start+2))
                 .put((short)start).put((short)(start+2)).put((short)(start+3));
        }
        vertices.position(0);index.position(0);
        EGLDisplay display=EGL14.EGL_NO_DISPLAY;
        EGLContext context=EGL14.EGL_NO_CONTEXT;
        EGLSurface surface=EGL14.EGL_NO_SURFACE;
        int program=0;
        int[] glBuffers={0,0},glTexture={0};
        Bitmap atlas=null,output=null;
        try {
            display=EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY);
            require(display!=EGL14.EGL_NO_DISPLAY,"No EGL display");
            int[] versions=new int[2];
            require(EGL14.eglInitialize(display,versions,0,versions,1),"Unable to initialize EGL");
            int[] configAttributes={
                    EGL14.EGL_SURFACE_TYPE,EGL14.EGL_PBUFFER_BIT,
                    EGL14.EGL_RENDERABLE_TYPE,EGL14.EGL_OPENGL_ES2_BIT,
                    EGL14.EGL_RED_SIZE,8,EGL14.EGL_GREEN_SIZE,8,
                    EGL14.EGL_BLUE_SIZE,8,EGL14.EGL_ALPHA_SIZE,8,
                    EGL14.EGL_NONE
            };
            EGLConfig[] configs=new EGLConfig[1];
            int[] found=new int[1];
            require(EGL14.eglChooseConfig(display,configAttributes,0,configs,0,1,found,0)
                    &&found[0]>0,"No offscreen EGL/GLES2 framebuffer configuration");
            surface=EGL14.eglCreatePbufferSurface(display,configs[0],
                    new int[]{EGL14.EGL_WIDTH,W,EGL14.EGL_HEIGHT,H,EGL14.EGL_NONE},0);
            require(surface!=null&&surface!=EGL14.EGL_NO_SURFACE,"EGL pbuffer creation failed");
            context=EGL14.eglCreateContext(display,configs[0],EGL14.EGL_NO_CONTEXT,
                    new int[]{EGL14.EGL_CONTEXT_CLIENT_VERSION,2,EGL14.EGL_NONE},0);
            require(context!=null&&context!=EGL14.EGL_NO_CONTEXT,"EGL2 context failed");
            require(EGL14.eglMakeCurrent(display,surface,surface,context),
                    "EGL2 make-current failed: "+EGL14.eglGetError());
            program=link();
            GLES20.glViewport(0,0,W,H);
            GLES20.glClearColor(.015f,.026f,.040f,1);
            GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT);
            GLES20.glUseProgram(program);
            atlas=glyphAtlas();
            GLES20.glGenTextures(1,glTexture,0);
            require(glTexture[0]!=0,"GLES glyph atlas texture allocation failed");
            GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D,glTexture[0]);
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D,GLES20.GL_TEXTURE_MIN_FILTER,GLES20.GL_NEAREST);
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D,GLES20.GL_TEXTURE_MAG_FILTER,GLES20.GL_NEAREST);
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D,GLES20.GL_TEXTURE_WRAP_S,GLES20.GL_CLAMP_TO_EDGE);
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D,GLES20.GL_TEXTURE_WRAP_T,GLES20.GL_CLAMP_TO_EDGE);
            GLUtils.texImage2D(GLES20.GL_TEXTURE_2D,0,atlas,0);
            GLES20.glUniform1i(GLES20.glGetUniformLocation(program,"atlas"),0);
            GLES20.glGenBuffers(2,glBuffers,0);
            require(glBuffers[0]!=0&&glBuffers[1]!=0,"GLES work buffers unavailable");
            GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER,glBuffers[0]);
            GLES20.glBufferData(GLES20.GL_ARRAY_BUFFER,vertices.capacity()*4,vertices,
                    GLES20.GL_DYNAMIC_DRAW);
            for(String name:new String[]{"position","uv","color"}){
                int attribute=GLES20.glGetAttribLocation(program,name);
                require(attribute>=0,"GLES shader attribute unavailable: "+name);
                int offset=name.equals("position")?0:name.equals("uv")?8:16;
                int floats=name.equals("color")?3:2;
                GLES20.glEnableVertexAttribArray(attribute);
                GLES20.glVertexAttribPointer(attribute,floats,GLES20.GL_FLOAT,false,28,offset);
            }
            GLES20.glBindBuffer(GLES20.GL_ELEMENT_ARRAY_BUFFER,glBuffers[1]);
            GLES20.glBufferData(GLES20.GL_ELEMENT_ARRAY_BUFFER,index.capacity()*2,index,
                    GLES20.GL_DYNAMIC_DRAW);
            GLES20.glDisable(GLES20.GL_DEPTH_TEST);
            GLES20.glDisable(GLES20.GL_CULL_FACE);
            GLES20.glDisable(GLES20.GL_SCISSOR_TEST);
            GLES20.glDisable(GLES20.GL_BLEND);
            final int calls=glyphs>0?1:0;
            if(calls>0)GLES20.glDrawElements(GLES20.GL_TRIANGLES,index.capacity(),
                    GLES20.GL_UNSIGNED_SHORT,0);
            GLES20.glFinish();
            require(GLES20.glGetError()==GLES20.GL_NO_ERROR,
                    "GLES2 drawElements or buffer upload failed");
            ByteBuffer rgba=ByteBuffer.allocateDirect(W*H*4);
            GLES20.glReadPixels(0,0,W,H,GLES20.GL_RGBA,GLES20.GL_UNSIGNED_BYTE,rgba);
            require(GLES20.glGetError()==GLES20.GL_NO_ERROR,
                    "Native GLES2 glReadPixels failed");
            int[] pixel=new int[W*H];
            int visible=0;
            for(int y=0;y<H;y++)for(int x=0;x<W;x++){
                int p=((H-1-y)*W+x)*4;
                int r=rgba.get(p)&255,g=rgba.get(p+1)&255,b=rgba.get(p+2)&255;
                pixel[y*W+x]=Color.rgb(r,g,b);
                if(r>70||g>70||b>70)++visible;
            }
            if(glyphs>0)require(visible>0,
                    "GLES2 returned blank pixels for real GPU-VIRTUAL selected work");
            output=Bitmap.createBitmap(W,H,Bitmap.Config.ARGB_8888);
            output.setPixels(pixel,0,W,0,0,W,H);
            ByteArrayOutputStream png=new ByteArrayOutputStream(1024*128);
            require(output.compress(Bitmap.CompressFormat.PNG,100,png),
                    "Native GLES framebuffer could not be encoded");
            return new JSONObject()
                    .put("ok",true).put("glyphs",glyphs).put("draw_calls",calls)
                    .put("pixels",visible).put("width",W).put("height",H)
                    .put("uploaded_bytes",(long)vertices.capacity()*4+(long)index.capacity()*2)
                    .put("backend","Android EGL/GLES2 pbuffer")
                    .put("png","data:image/png;base64,"+Base64.encodeToString(png.toByteArray(),Base64.NO_WRAP));
        } finally {
            if(output!=null)output.recycle();
            if(atlas!=null)atlas.recycle();
            if(display!=EGL14.EGL_NO_DISPLAY) {
                if(context!=EGL14.EGL_NO_CONTEXT&&surface!=EGL14.EGL_NO_SURFACE) {
                    GLES20.glDeleteBuffers(2,glBuffers,0);
                    GLES20.glDeleteTextures(1,glTexture,0);
                    if(program!=0)GLES20.glDeleteProgram(program);
                }
                EGL14.eglMakeCurrent(display,EGL14.EGL_NO_SURFACE,EGL14.EGL_NO_SURFACE,
                        EGL14.EGL_NO_CONTEXT);
                if(surface!=EGL14.EGL_NO_SURFACE)EGL14.eglDestroySurface(display,surface);
                if(context!=EGL14.EGL_NO_CONTEXT)EGL14.eglDestroyContext(display,context);
                EGL14.eglTerminate(display);
            }
        }
    }
}
