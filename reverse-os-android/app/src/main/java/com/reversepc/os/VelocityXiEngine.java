package com.reversepc.os;

import android.content.Context;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONObject;

/**
 * Physical input -> XI RXE transaction -> immutable observation.
 *
 * The authoritative game state is the private RVPC2 snapshot owned by
 * QuantumRuntime / InverseMemory. This class implements no driving equations,
 * no road equation, no checkpoint rules, and no graphics engine.
 */
final class VelocityXiEngine {
    static final class Snapshot {
        final long xCm,zCm,ticks,totalProgress;
        final int yaw4096,speedCmps,slideCmps,checkpoint,position,laps,trackS,segment,countdown;
        final boolean finished,offRoad,wallContact;
        Snapshot(long[] values){
            if(values==null||values.length!=16)throw new IllegalArgumentException("XI race output needs sixteen registers");
            for(int i=2;i<values.length;i++)if(values[i]<Integer.MIN_VALUE||values[i]>Integer.MAX_VALUE)
                throw new IllegalArgumentException("XI race register exceeds integer range");
            xCm=values[0];zCm=values[1];yaw4096=(int)values[2];
            speedCmps=(int)values[3];slideCmps=(int)values[4];
            checkpoint=(int)values[5];ticks=values[6];
            finished=values[7]==1;offRoad=values[8]==1;
            position=(int)values[9];laps=(int)values[10];trackS=(int)values[11];
            segment=(int)values[12];countdown=(int)values[13];wallContact=values[14]==1;
            totalProgress=values[15];
            if(xCm< -1_500_000||xCm>1_500_000||zCm< -1_500_000||zCm>1_500_000||
                    yaw4096<0||yaw4096>=4096||speedCmps<0||speedCmps>6500||
                    slideCmps< -6500||slideCmps>6500||checkpoint<0||checkpoint>12||
                    ticks<0||ticks>Integer.MAX_VALUE||values[7]<0||values[7]>1||
                    values[8]<0||values[8]>1||position<1||position>4||laps<0||laps>3||
                    trackS<0||trackS>=160000||segment<0||segment>=80||countdown<0||countdown>150||
                    values[14]<0||values[14]>1||totalProgress<0||totalProgress>1_000_000)
                throw new IllegalArgumentException("XI game output beyond the bounded protocol");
        }
        int speedKmh(){return (int)Math.round(speedCmps*.036);}
        long seconds(){return ticks/50;}
        int displayedLap(){return Math.min(3,laps+1);}
    }

    private byte[] privateState;
    private final String driveXi;
    private final String xiRenderer;
    private final String xiNative4KRenderer;
    private final Object renderSourceLock=new Object();
    private String renderProgramCache,driveProgramCache;
    private int renderProgramKey=-1,driveProgramKey=-1;
    private String native4KProgramCache;
    private int native4KProgramKey=-1;
    private static final String XI_HEADER="#!reverse-pc-machine-v1\n";
    private final float[] worldPoints; // read-only XI generated geometry samples
    private final int[] palette;
    private Snapshot snapshot;
    static final class Observation {
        final RegraphicsFrame frame;
        final Snapshot state;
        Observation(RegraphicsFrame frame,Snapshot state){this.frame=frame;this.state=state;}
    }

    VelocityXiEngine(Context context)throws Exception{
        driveXi=asset(context,"velocity/drive.xi");
        String world=asset(context,"velocity/world.xi");
        xiRenderer=asset(context,"velocity/render.xi");
        xiNative4KRenderer=asset(context,"velocity/render-native4k.xi");
        palette=parsePalette(asset(context,"velocity/palette.txt"));
        if(!xiNative4KRenderer.startsWith(XI_HEADER))
            throw new IllegalStateException("XI native 4K source header missing");
        if(!xiRenderer.startsWith(XI_HEADER))
            throw new IllegalStateException("XI renderer source header missing");
        if(!driveXi.startsWith("#!reverse-pc-machine-v1\n")||
           !world.startsWith("#!reverse-pc-machine-v1\n"))
            throw new IllegalStateException("XI game code header missing");
        ResultPacket generated=ResultPacket.parse(NativeRuntime.execute(NativeRuntime.initialize(),world));
        worldPoints=parseRoute(generated.output);
        // Preserve world.xi's 81 packed circuit vertices in this isolated RVPC2.
        // Reinitializing here would discard the renderer's only geometry source.
        privateState=generated.state; // isolated from REVERSE Desktop/BBY Q
        step(0,0,1,0,false,true);
        if(snapshot.ticks!=0)throw new IllegalStateException("XI game reset consumed a tick");
    }

    private static String asset(Context context,String path)throws Exception{
        try(InputStream in=context.getAssets().open(path)){
            ByteArrayOutputStream out=new ByteArrayOutputStream();
            byte[] buffer=new byte[8192];int n;
            while((n=in.read(buffer))>=0){
                if(out.size()+n>512*1024)throw new IllegalArgumentException("Velocity XI source exceeds limit");
                out.write(buffer,0,n);
            }
            return out.toString("UTF-8");
        }
    }

    private static float[] parseRoute(String text)throws Exception{
        List<Long> numbers=new ArrayList<>();
        for(String line:text.split("\n")){
            if(line.trim().isEmpty())continue;
            JSONObject row=new JSONObject(line);
            if(!"register".equals(row.getString("type")))
                throw new IllegalStateException("Track output is not XI register data");
            numbers.add(row.getLong("value"));
        }
        if(numbers.size()!=162)throw new IllegalStateException("XI circuit requires 81 (x,z) points");
        float[] points=new float[numbers.size()];
        for(int i=0;i<numbers.size();i+=2){
            long x=numbers.get(i),z=numbers.get(i+1);
            if(Math.abs(x)>1_500_000||Math.abs(z)>1_500_000)
                throw new IllegalStateException("XI track samples are out of range");
            points[i]=x/100.f;
            points[i+1]=z/100.f;
        }
        return points;
    }

    private static Snapshot parseState(String output)throws Exception{
        long[] observed=new long[16];int n=0;
        for(String line:output.split("\n")){
            if(line.trim().isEmpty())continue;
            if(n>=16)throw new IllegalArgumentException("XI game published too many registers");
            JSONObject row=new JSONObject(line);
            if(!"register".equals(row.getString("type"))||
               !("r"+n).equals(row.getString("register")))
                throw new IllegalArgumentException("XI game register order mismatch");
            observed[n++]=row.getLong("value");
        }
        if(n!=16)throw new IllegalArgumentException("Incomplete XI game observation");
        return new Snapshot(observed);
    }

    synchronized Snapshot step(int gas,int brake,int steer,int drift,boolean reverse,boolean reset)throws Exception{
        if(gas<0||gas>1||brake<0||brake>1||steer<0||steer>2||
           drift<0||drift>1)throw new IllegalArgumentException("XI physical control out of range");
        // Execute the XI source through the *existing* generic runtime.
        // There is no game-specific JNI/C++ renderer, physics or instruction API.
        final int programKey=gas|(brake<<1)|(steer<<2)|(drift<<4)|(reset?32:0)|(reverse?64:0);
        if(programKey!=driveProgramKey){
            driveProgramCache=XI_HEADER+
                "store8 128 "+gas+"\nstore8 129 "+brake+
                "\nstore8 130 "+steer+"\nstore8 131 "+drift+
                "\nstore8 132 "+(reset?1:0)+"\nstore8 133 "+(reverse?1:0)+"\n"+
                driveXi.substring(XI_HEADER.length());
            driveProgramKey=programKey;
        }
        ResultPacket result=ResultPacket.parse(NativeRuntime.execute(privateState,driveProgramCache));
        // Validate the observation BEFORE publishing the candidate snapshot.
        Snapshot observed=parseState(result.output);
        privateState=result.state;
        snapshot=observed;
        return observed;
    }
    /**
     * Execute the actual XI renderer on a private snapshot. No Java geometry,
     * projection, shading or collision equations are implemented here.
     * Host validates and unpacks the bounded surface observations only.
     */
    RegraphicsFrame renderFrame(int stride,int camera,int paint)throws Exception{
        return observeFrame(stride,camera,paint).frame;
    }
    Observation observeFrame(int stride,int camera,int paint)throws Exception{
        if(stride!=1&&stride!=2&&stride!=4)throw new IllegalArgumentException("XI frame stride must be 1,2 or 4");
        if(camera<0||camera>2||paint<0||paint>4)throw new IllegalArgumentException("XI visual input out of range");
        final String source;
        final int programKey=(stride*3+camera)*5+paint;
        // Cache one authored program, independently of the physics monitor.
        // Observations and state remain fresh on every execution.
        synchronized(renderSourceLock){
            if(programKey!=renderProgramKey){
                renderProgramCache=XI_HEADER+"store8 200 "+stride+
                    "\nstore8 201 "+camera+"\nstore8 202 "+paint+"\n"+
                    xiRenderer.substring(XI_HEADER.length());
                renderProgramKey=programKey;
            }
            source=renderProgramCache;
        }
        // No UTF-8 conversion or JSON records on the frame path.
        // Returned RVPC2 is discarded: frames observe the private game state.
        final byte[] observation;
        final Snapshot observedState;
        synchronized(this){observation=privateState.clone();observedState=snapshot;}
        // Native observations execute on a private immutable copy. The physics
        // transaction can advance independently while this image is produced.
        ResultPacket packet=ResultPacket.parseBinary(NativeRuntime.execute(observation,source));
        return new Observation(RegraphicsFrame.decode(packet.outputBytes,stride,palette),observedState);
    }
    /** XI performs all native 4K rasterization; Android consumes only XFB5 pixels. */
    Observation observeNative4KFrame(int camera,int paint)throws Exception{
        if(camera<0||camera>2||paint<0||paint>4)
            throw new IllegalArgumentException("Invalid XI native 4K visual input");
        final String program;
        final int key=camera*5+paint;
        synchronized(renderSourceLock){
            if(key!=native4KProgramKey){
                native4KProgramCache=XI_HEADER+"store8 200 1\nstore8 201 "+camera+
                    "\nstore8 202 "+paint+"\n"+
                    xiNative4KRenderer.substring(XI_HEADER.length());
                native4KProgramKey=key;
            }
            program=native4KProgramCache;
        }
        final byte[] observedState;
        final Snapshot observed;
        synchronized(this){observedState=privateState.clone();observed=snapshot;}
        ResultPacket packet=ResultPacket.parseBinary(NativeRuntime.execute(observedState,program));
        return new Observation(RegraphicsFrame.decodeNative4K(packet.outputBytes,palette),observed);
    }
    private static int[] parsePalette(String source){
        String[] entries=source.trim().split("\n");
        if(entries.length!=256)throw new IllegalArgumentException("REgraphics palette size mismatch");
        int[] palette=new int[entries.length];
        for(int i=0;i<entries.length;i++){
            if(!entries[i].matches("[0-9a-f]{6}"))throw new IllegalArgumentException("Invalid palette color");
            palette[i]=Integer.parseInt(entries[i],16);
        }
        return palette;
    }
    synchronized Snapshot current(){return snapshot;}
    float[] track(){return worldPoints.clone();} // Read-only circuit samples for HUD.
}
