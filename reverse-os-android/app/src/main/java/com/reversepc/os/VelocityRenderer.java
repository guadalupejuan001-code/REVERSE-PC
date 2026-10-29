package com.reversepc.os;

import android.opengl.GLES30;
import android.opengl.GLSurfaceView;
import android.opengl.Matrix;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

/**
 * Native Android/GLES 3 adapter for the first REVERSE VELOCITY vertical slice.
 *
 * Procedural terrain, road, buildings and vegetation are compact generated
 * scene data, never a preallocated image. The fixed-step vehicle state is
 * read only. This is not Ether Render X GPU acceleration: that backend is
 * not present in the pinned Mundo X version.
 */
final class VelocityRenderer implements GLSurfaceView.Renderer {
    interface Hud { void update(int kmh,int checkpoints,int total,long seconds,boolean offRoad); }
    private static final int CHUNK=128,RADIUS=3;
    private static final int STRIDE=9*4;
    private static final float[] ROAD={0.12f,0.14f,0.16f};
    private static final float[] WHITE={0.80f,0.82f,0.76f};
    private final VelocityPhysics physics;
    private final Hud hud;
    private final Map<Long,Mesh> chunks=new HashMap<>();
    private final float[] projection=new float[16],view=new float[16],vp=new float[16];
    private final float[] model=new float[16],mvp=new float[16];
    private Mesh road,car;
    private int program,uMvp,uModel,uEye;
    private int width=1,height=1;
    private long lastNanos,lastHud;
    private int pendingMs;
    volatile int gas,brake,steer;
    volatile boolean handbrake,resetRequested;

    VelocityRenderer(VelocityPhysics physics,Hud hud){this.physics=physics;this.hud=hud;}

    void controls(int gas,int brake,int steer,boolean handbrake){
        this.gas=gas;this.brake=brake;this.steer=steer;this.handbrake=handbrake;
    }
    void reset(){resetRequested=true;}

    @Override public void onSurfaceCreated(GL10 gl,EGLConfig config){
        chunks.clear(); // A recreated EGL context invalidates the old GL objects.
        program=link(VERTEX,FRAGMENT);
        uMvp=GLES30.glGetUniformLocation(program,"uMvp");
        uModel=GLES30.glGetUniformLocation(program,"uModel");
        uEye=GLES30.glGetUniformLocation(program,"uEye");
        GLES30.glEnable(GLES30.GL_DEPTH_TEST);
        GLES30.glDepthFunc(GLES30.GL_LEQUAL);
        GLES30.glDisable(GLES30.GL_CULL_FACE);
        GLES30.glClearColor(0.49f,0.70f,0.85f,1f);
        road=makeRoad().upload();
        car=makeCar().upload();
        lastNanos=0;lastHud=0;pendingMs=0;
    }

    @Override public void onSurfaceChanged(GL10 gl,int w,int h){
        width=Math.max(1,w);height=Math.max(1,h);
        GLES30.glViewport(0,0,width,height);
        Matrix.perspectiveM(projection,0,66f,(float)width/height,0.2f,1000f);
    }

    @Override public void onDrawFrame(GL10 gl){
        long now=System.nanoTime();
        if(lastNanos!=0){
            long dt=(now-lastNanos)/1_000_000L;
            pendingMs+=(int)Math.min(100L,Math.max(0L,dt));
        }
        lastNanos=now;
        if(resetRequested){physics.reset();pendingMs=0;resetRequested=false;}
        int ticks=0;
        while(pendingMs>=VelocityPhysics.TICK_MS&&ticks++<5){
            physics.step(gas,brake,steer,handbrake);
            pendingMs-=VelocityPhysics.TICK_MS;
        }
        if(pendingMs>=VelocityPhysics.TICK_MS)pendingMs=0; // no spiral of death

        double yaw=physics.headingRadians();
        float fx=(float)Math.sin(yaw),fz=-(float)Math.cos(yaw);
        float x=(float)(physics.xMm/1000.0),z=(float)(physics.zMm/1000.0);
        float carY=(float)ground(x,z)+0.42f;
        float cameraX=x-fx*17.0f,cameraZ=z-fz*17.0f;
        float cameraY=carY+7.3f;

        Matrix.setLookAtM(view,0,cameraX,cameraY,cameraZ,
                x+fx*19f,carY+1.4f,z+fz*19f,0,1,0);
        Matrix.multiplyMM(vp,0,projection,0,view,0);
        GLES30.glClear(GLES30.GL_COLOR_BUFFER_BIT|GLES30.GL_DEPTH_BUFFER_BIT);
        GLES30.glUseProgram(program);
        GLES30.glUniform3f(uEye,cameraX,cameraY,cameraZ);
        Matrix.setIdentityM(model,0);

        stream(x,z);
        for(Mesh chunk:chunks.values())draw(chunk);
        draw(road);

        Matrix.setIdentityM(model,0);
        Matrix.translateM(model,0,x,carY,z);
        Matrix.rotateM(model,0,-(float)Math.toDegrees(yaw),0,1,0);
        draw(car);

        if(now-lastHud>250_000_000L){
            lastHud=now;
            hud.update((int)Math.round(physics.speedKmh()),physics.checkpoint,
                    physics.checkpointCount(),physics.elapsedMs/1000,physics.offRoad);
        }
    }

    private static double ground(double x,double z){
        double ridge=x < -150 ? Math.min(90,(-x-150)*0.19)
                      *(0.72+0.28*Math.sin(z/160.0)) : 0.0;
        return VelocityPhysics.terrainY(x,z)+ridge;
    }

    private void stream(float x,float z){
        int gx=(int)Math.floor(x/CHUNK),gz=(int)Math.floor(z/CHUNK);
        for(int dx=-RADIUS;dx<=RADIUS;dx++)for(int dz=-RADIUS;dz<=RADIUS;dz++){
            int tx=gx+dx,tz=gz+dz;long key=key(tx,tz);
            if(!chunks.containsKey(key))chunks.put(key,makeChunk(tx,tz).upload());
        }
        Iterator<Map.Entry<Long,Mesh>> entries=chunks.entrySet().iterator();
        while(entries.hasNext()){
            Map.Entry<Long,Mesh> entry=entries.next();
            int tx=(int)(entry.getKey()>>32),tz=(int)(long)entry.getKey();
            if(Math.abs(tx-gx)>RADIUS||Math.abs(tz-gz)>RADIUS){
                entry.getValue().dispose();entries.remove();
            }
        }
    }
    private static long key(int gx,int gz){return ((long)gx<<32)|(gz&0xffffffffL);}

    private static Builder makeChunk(int gx,int gz){
        Builder b=new Builder();
        float x0=gx*CHUNK,z0=gz*CHUNK;
        for(int i=0;i<8;i++)for(int j=0;j<8;j++){
            float x=x0+i*16,z=z0+j*16;
            boolean coast=x>440;
            float[] color=coast?new float[]{.12f,.36f,.50f}
                :x>390?new float[]{.62f,.55f,.35f}
                :x<-150?new float[]{.29f,.40f,.30f}
                :new float[]{.24f,.40f,.25f};
            b.quad(new float[]{x,(float)ground(x,z),z},
                    new float[]{x+16,(float)ground(x+16,z),z},
                    new float[]{x+16,(float)ground(x+16,z+16),z+16},
                    new float[]{x,(float)ground(x,z+16),z+16},color);
        }
        int seed=gx*73856093^gz*19349663^0x3152a1;
        for(int i=0;i<18;i++){
            seed=next(seed);float x=x0+((seed&65535)/65535f)*CHUNK;
            seed=next(seed);float z=z0+((seed&65535)/65535f)*CHUNK;
            if(Math.abs(x-VelocityPhysics.roadX(z))<22||x>390)continue;
            float y=(float)ground(x,z);
            seed=next(seed);
            if(z<350&&z>-800&&x>44&&x<180&&(seed&3)==0){
                float h=7+((seed>>>8)&15);
                b.box(x,y,z,7,h,9,.34f,.40f,.43f);
                b.box(x,y+h,z,7,.5f,9,.13f,.18f,.22f);
                // Window band, separate geometry rather than a texture atlas.
                for(int floor=3;floor<h;floor+=4)
                    b.box(x+3.55f,y+floor,z,0.10f,1.2f,6,.45f,.66f,.72f);
            }else{
                float h=3.8f+((seed>>>8)&7)*.44f;
                b.box(x,y,z,.33f,h*.33f,.33f,.27f,.22f,.17f);
                b.pine(x,y+h*.25f,z,h*.95f,1.8f+(seed&3)*.20f);
            }
        }
        return b;
    }

    private static int next(int x){x^=x<<13;x^=x>>>17;x^=x<<5;return x==0?7:x;}

    private static Builder makeRoad(){
        Builder b=new Builder();
        for(int i=0;i<510;i++){
            float z0=1600-i*9,z1=z0-9;
            float c0=(float)VelocityPhysics.roadX(z0),c1=(float)VelocityPhysics.roadX(z1);
            float[] a={c0-8,.18f,z0},bb={c0+8,.18f,z0},c={c1+8,.18f,z1},d={c1-8,.18f,z1};
            b.quad(a,bb,c,d,ROAD);
            b.quad(new float[]{c0-7.5f,.204f,z0},new float[]{c0-7.3f,.204f,z0},
                   new float[]{c1-7.3f,.204f,z1},new float[]{c1-7.5f,.204f,z1},WHITE);
            b.quad(new float[]{c0+7.3f,.204f,z0},new float[]{c0+7.5f,.204f,z0},
                   new float[]{c1+7.5f,.204f,z1},new float[]{c1+7.3f,.204f,z1},WHITE);
            if(i%7<4){
                b.quad(new float[]{c0-.12f,.210f,z0},new float[]{c0+.12f,.210f,z0},
                      new float[]{c1+.12f,.210f,z1},new float[]{c1-.12f,.210f,z1},
                      new float[]{.79f,.70f,.37f});
            }
        }
        int[] gates={900,600,300,0,-300,-600};
        for(int gate:gates){
            float x=(float)VelocityPhysics.roadX(gate);
            b.box(x-9.7f,.15f,gate,.32f,5.5f,.32f,.16f,.72f,.78f);
            b.box(x+9.7f,.15f,gate,.32f,5.5f,.32f,.16f,.72f,.78f);
            b.box(x,.15f+5.3f,gate,19.7f,.45f,.35f,.15f,.70f,.81f);
        }
        return b;
    }

    private static Builder makeCar(){
        Builder b=new Builder();
        // A small entirely original sports-car silhouette; no licensed model.
        b.box(0,.08f,0,1.95f,.40f,4.50f,.83f,.13f,.09f);   // body
        b.box(0,.46f,.23f,1.70f,.62f,2.16f,.18f,.27f,.30f); // glass cabin
        b.box(0,1.04f,.37f,1.55f,.12f,1.70f,.75f,.11f,.09f);
        b.box(0,.39f,-1.58f,1.85f,.16f,.80f,.90f,.20f,.13f); // bonnet
        b.box(0,.31f,2.14f,1.85f,.12f,.34f,.13f,.14f,.16f); // rear bumper
        b.box(0,1.24f,1.98f,2.13f,.10f,.34f,.12f,.13f,.16f); // wing
        b.box(-.72f,.09f,-1.50f,.38f,.26f,.74f,.08f,.09f,.10f); // wheels
        b.box(.72f,.09f,-1.50f,.38f,.26f,.74f,.08f,.09f,.10f);
        b.box(-.72f,.09f,1.52f,.38f,.26f,.74f,.08f,.09f,.10f);
        b.box(.72f,.09f,1.52f,.38f,.26f,.74f,.08f,.09f,.10f);
        b.box(-.69f,.30f,-2.28f,.40f,.11f,.07f,.95f,.91f,.76f);
        b.box(.69f,.30f,-2.28f,.40f,.11f,.07f,.95f,.91f,.76f);
        b.box(-.70f,.31f,2.29f,.42f,.12f,.09f,.89f,.05f,.04f);
        b.box(.70f,.31f,2.29f,.42f,.12f,.09f,.89f,.05f,.04f);
        return b;
    }

    private void draw(Mesh mesh){
        if(mesh==null||mesh.count==0)return;
        Matrix.multiplyMM(mvp,0,vp,0,model,0);
        GLES30.glUniformMatrix4fv(uMvp,1,false,mvp,0);
        GLES30.glUniformMatrix4fv(uModel,1,false,model,0);
        GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER,mesh.vbo);
        GLES30.glEnableVertexAttribArray(0);
        GLES30.glEnableVertexAttribArray(1);
        GLES30.glEnableVertexAttribArray(2);
        GLES30.glVertexAttribPointer(0,3,GLES30.GL_FLOAT,false,STRIDE,0);
        GLES30.glVertexAttribPointer(1,3,GLES30.GL_FLOAT,false,STRIDE,12);
        GLES30.glVertexAttribPointer(2,3,GLES30.GL_FLOAT,false,STRIDE,24);
        GLES30.glDrawArrays(GLES30.GL_TRIANGLES,0,mesh.count);
        GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER,0);
    }

    private static int compile(int type,String shader){
        int object=GLES30.glCreateShader(type);
        GLES30.glShaderSource(object,shader);GLES30.glCompileShader(object);
        int[] ok=new int[1];GLES30.glGetShaderiv(object,GLES30.GL_COMPILE_STATUS,ok,0);
        if(ok[0]==0){String error=GLES30.glGetShaderInfoLog(object);
            GLES30.glDeleteShader(object);throw new IllegalStateException(error);}
        return object;
    }

    private static int link(String vertex,String fragment){
        int vs=compile(GLES30.GL_VERTEX_SHADER,vertex),fs=compile(GLES30.GL_FRAGMENT_SHADER,fragment);
        int result=GLES30.glCreateProgram();
        GLES30.glAttachShader(result,vs);GLES30.glAttachShader(result,fs);
        GLES30.glLinkProgram(result);
        GLES30.glDeleteShader(vs);GLES30.glDeleteShader(fs);
        int[] ok=new int[1];GLES30.glGetProgramiv(result,GLES30.GL_LINK_STATUS,ok,0);
        if(ok[0]==0){String error=GLES30.glGetProgramInfoLog(result);
            GLES30.glDeleteProgram(result);throw new IllegalStateException(error);}
        return result;
    }

    private static final class Mesh {
        final int vbo,count;
        Mesh(int vbo,int count){this.vbo=vbo;this.count=count;}
        void dispose(){if(vbo!=0)GLES30.glDeleteBuffers(1,new int[]{vbo},0);}
    }

    private static final class Builder {
        private float[] vertices=new float[1024];
        private int used;
        private void push(float[] p,float nx,float ny,float nz,float[] color){
            if(used+9>vertices.length)vertices=Arrays.copyOf(vertices,vertices.length*2);
            vertices[used++]=p[0];vertices[used++]=p[1];vertices[used++]=p[2];
            vertices[used++]=nx;vertices[used++]=ny;vertices[used++]=nz;
            vertices[used++]=color[0];vertices[used++]=color[1];vertices[used++]=color[2];
        }
        void triangle(float[] a,float[] b,float[] c,float[] color){
            float ux=b[0]-a[0],uy=b[1]-a[1],uz=b[2]-a[2];
            float vx=c[0]-a[0],vy=c[1]-a[1],vz=c[2]-a[2];
            float nx=uy*vz-uz*vy,ny=uz*vx-ux*vz,nz=ux*vy-uy*vx;
            float length=(float)Math.sqrt(nx*nx+ny*ny+nz*nz);
            if(length<.00001f)return;
            nx/=length;ny/=length;nz/=length;
            if(ny<-.2f){nx=-nx;ny=-ny;nz=-nz;}
            push(a,nx,ny,nz,color);push(b,nx,ny,nz,color);push(c,nx,ny,nz,color);
        }
        void quad(float[] a,float[] b,float[] c,float[] d,float[] color){
            triangle(a,b,c,color);triangle(a,c,d,color);
        }
        void box(float x,float y,float z,float w,float h,float d,float r,float g,float blue){
            float l=x-w/2,rr=x+w/2,front=z-d/2,back=z+d/2,top=y+h;
            float[] a={l,y,front},b={rr,y,front},c={rr,y,back},d0={l,y,back};
            float[] e={l,top,front},f={rr,top,front},g0={rr,top,back},h0={l,top,back};
            float[] color={r,g,blue};
            quad(e,f,g0,h0,color);quad(a,b,f,e,color);
            quad(b,c,g0,f,color);quad(c,d0,h0,g0,color);quad(d0,a,e,h0,color);
        }
        void pine(float x,float y,float z,float height,float half){
            float[] top={x,y+height,z};
            float[] p={x-half,y,z-half},q={x+half,y,z-half};
            float[] r={x+half,y,z+half},s={x-half,y,z+half};
            float[] leaf={.11f,.32f,.19f};
            triangle(p,q,top,leaf);triangle(q,r,top,leaf);
            triangle(r,s,top,leaf);triangle(s,p,top,leaf);
        }
        Mesh upload(){
            int count=used/9;
            if(count==0)return new Mesh(0,0);
            int[] id={0};GLES30.glGenBuffers(1,id,0);
            if(id[0]==0)throw new IllegalStateException("GL buffer unavailable");
            FloatBuffer packed=ByteBuffer.allocateDirect(used*4)
                    .order(ByteOrder.nativeOrder()).asFloatBuffer();
            packed.put(vertices,0,used).position(0);
            GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER,id[0]);
            GLES30.glBufferData(GLES30.GL_ARRAY_BUFFER,used*4,packed,GLES30.GL_STATIC_DRAW);
            GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER,0);
            return new Mesh(id[0],count);
        }
    }

    private static final String VERTEX=
        "#version 300 es\n"+
        "layout(location=0) in vec3 aPos;\n"+
        "layout(location=1) in vec3 aNormal;\n"+
        "layout(location=2) in vec3 aColor;\n"+
        "uniform mat4 uMvp; uniform mat4 uModel;\n"+
        "out vec3 vNormal;out vec3 vColor;out vec3 vWorld;\n"+
        "void main(){vec4 wp=uModel*vec4(aPos,1.0); vWorld=wp.xyz;\n"+
        "vNormal=mat3(uModel)*aNormal;vColor=aColor;gl_Position=uMvp*vec4(aPos,1.0);}\n";
    private static final String FRAGMENT=
        "#version 300 es\n"+
        "precision highp float;\n"+
        "in vec3 vNormal;in vec3 vColor;in vec3 vWorld;\n"+
        "uniform vec3 uEye;out vec4 fragColor;\n"+
        "void main(){vec3 n=normalize(vNormal);vec3 light=normalize(vec3(-.35,.94,-.47));\n"+
        "float diffuse=max(dot(n,light),0.0);\n"+
        "float spec=pow(max(dot(reflect(-light,n),normalize(uEye-vWorld)),0.0),36.0);\n"+
        "vec3 shaded=vColor*(.43+.62*diffuse)+.18*spec;\n"+
        "float fog=smoothstep(190.0,870.0,length(vWorld-uEye));\n"+
        "vec3 sky=vec3(.49,.70,.85);fragColor=vec4(mix(shaded,sky,fog),1.0);}\n";
}