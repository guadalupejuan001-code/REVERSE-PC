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
        final long xCm,zCm,ticks;
        final int yaw4096,speedCmps,slideCmps,checkpoint;
        final boolean finished,offRoad;
        Snapshot(long[] values){
            if(values==null||values.length!=9)throw new IllegalArgumentException("XI game output needs nine registers");
            xCm=values[0];zCm=values[1];yaw4096=(int)values[2];
            speedCmps=(int)values[3];slideCmps=(int)values[4];
            checkpoint=(int)values[5];ticks=values[6];
            finished=values[7]==1;offRoad=values[8]==1;
            if(xCm< -1_500_000||xCm>1_500_000||zCm< -1_500_000||zCm>1_500_000||
                    yaw4096<0||yaw4096>=4096||speedCmps<0||speedCmps>7800||
                    slideCmps< -2600||slideCmps>2600||checkpoint<0||checkpoint>6||
                    ticks<0||ticks>Integer.MAX_VALUE||values[7]<0||values[7]>1||
                    values[8]<0||values[8]>1)
                throw new IllegalArgumentException("XI game output beyond the bounded protocol");
        }
        int speedKmh(){return (int)Math.round(speedCmps*.036);}
        long seconds(){return ticks/50;}
    }

    private byte[] privateState;
    private final String driveXi;
    private final String xiRenderer;
    private static final String XI_HEADER="#!reverse-pc-machine-v1\n";
    private final float[] worldPoints; // read-only XI generated geometry samples
    static final class RenderFrame {
        final long[] spans;
        final int stride;
        RenderFrame(long[] values,int scanStep){spans=values;stride=scanStep;}
    }
    private Snapshot snapshot;

    VelocityXiEngine(Context context)throws Exception{
        driveXi=asset(context,"velocity/drive.xi");
        String world=asset(context,"velocity/world.xi");
        xiRenderer=asset(context,"velocity/render.xi");
        if(!xiRenderer.startsWith(XI_HEADER))
            throw new IllegalStateException("XI renderer source header missing");
        if(!driveXi.startsWith("#!reverse-pc-machine-v1\n")||
           !world.startsWith("#!reverse-pc-machine-v1\n"))
            throw new IllegalStateException("XI game code header missing");
        ResultPacket generated=ResultPacket.parse(NativeRuntime.execute(NativeRuntime.initialize(),world));
        worldPoints=parseRoute(generated.output);
        // Preserve world.xi's 241 packed route points in *this* isolated RVPC2.
        // Reinitializing here would discard the renderer's only geometry source.
        privateState=generated.state; // isolated from REVERSE Desktop/BBY Q
        step(0,0,1,0,true);
        if(snapshot.ticks!=0)throw new IllegalStateException("XI game reset consumed a tick");
    }

    private static String asset(Context context,String path)throws Exception{
        try(InputStream in=context.getAssets().open(path)){
            ByteArrayOutputStream out=new ByteArrayOutputStream();
            byte[] buffer=new byte[8192];int n;
            while((n=in.read(buffer))>=0){
                if(out.size()+n>128*1024)throw new IllegalArgumentException("Velocity XI source exceeds limit");
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
        if(numbers.size()!=482)throw new IllegalStateException("XI track requires 241 (z,x) points");
        float[] points=new float[numbers.size()];
        for(int i=0;i<numbers.size();i+=2){
            long z=numbers.get(i),x=numbers.get(i+1);
            if(z!=-85000L+(long)(i/2)*1000L||Math.abs(x)>8000)
                throw new IllegalStateException("XI track samples are out of range");
            points[i]=z/100.f;
            points[i+1]=x/100.f;
        }
        return points;
    }

    private static Snapshot parseState(String output)throws Exception{
        long[] observed=new long[9];int n=0;
        for(String line:output.split("\n")){
            if(line.trim().isEmpty())continue;
            if(n>=9)throw new IllegalArgumentException("XI game published too many registers");
            JSONObject row=new JSONObject(line);
            if(!"register".equals(row.getString("type"))||
               !("r"+n).equals(row.getString("register")))
                throw new IllegalArgumentException("XI game register order mismatch");
            observed[n++]=row.getLong("value");
        }
        if(n!=9)throw new IllegalArgumentException("Incomplete XI game observation");
        return new Snapshot(observed);
    }

    synchronized Snapshot step(int gas,int brake,int steer,int drift,boolean reset)throws Exception{
        if(gas<0||gas>1||brake<0||brake>1||steer<0||steer>2||
           drift<0||drift>1)throw new IllegalArgumentException("XI physical control out of range");
        // Execute the XI source through the *existing* generic runtime.
        // There is no game-specific JNI/C++ renderer, physics or instruction API.
        String program=XI_HEADER+
            "store8 128 "+gas+"\nstore8 129 "+brake+
            "\nstore8 130 "+steer+"\nstore8 131 "+drift+
            "\nstore8 132 "+(reset?1:0)+"\n"+
            driveXi.substring(XI_HEADER.length());
        ResultPacket result=ResultPacket.parse(NativeRuntime.execute(privateState,program));
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
    synchronized RenderFrame renderFrame(int stride,int camera,int paint)throws Exception{
        if(stride!=1&&stride!=2&&stride!=4)throw new IllegalArgumentException("XI frame stride must be 1,2 or 4");
        if(camera<0||camera>2||paint<0||paint>4)throw new IllegalArgumentException("XI visual input out of range");
        final String source=XI_HEADER+"store8 200 "+stride+
            "\nstore8 201 "+camera+"\nstore8 202 "+paint+"\n"+
            xiRenderer.substring(XI_HEADER.length());
        // Return state is deliberately discarded: frames are observations.
        ResultPacket packet=ResultPacket.parse(NativeRuntime.execute(privateState,source));
        final int max=(720/stride)*12;
        long[] packed=new long[max];
        boolean[] covered=new boolean[720/stride];
        int size=0,lastRow=-1;
        for(String line:packet.output.split("\n")){
            if(line.isEmpty())continue;
            if(size>=max)throw new IllegalStateException("XI span budget exceeded");
            JSONObject row=new JSONObject(line);
            if(!"register".equals(row.getString("type"))||!"r4".equals(row.getString("register")))
                throw new IllegalStateException("XI renderer must emit packed register r4");
            // Parse decimal as int64 exactly; never round the 56-bit packet to double.
            // Android's JSONObject number conversion may round 56-bit values
            // through double on some versions: decode the original JSON text.
            int start=line.indexOf("\"value\":");
            if(start<0)throw new IllegalStateException("XI packet without numeric value");
            start+=8;
            int end=line.indexOf('}',start);
            if(end<=start)throw new IllegalStateException("Malformed XI span integer");
            long value=Long.parseLong(line.substring(start,end).trim());
            if(value<0||value>=(1L<<56))throw new IllegalStateException("XI span exceeds 56 bits");
            int y=(int)(value>>>46);
            int x0=(int)((value>>>35)&2047L),x1=(int)((value>>>24)&2047L);
            if(y>=720||y%stride!=0||y<lastRow||x0>=x1||x1>1280)
                throw new IllegalStateException("Malformed XI span coordinates");
            covered[y/stride]=true;lastRow=y;packed[size++]=value;
        }
        if(size==0)throw new IllegalStateException("XI renderer returned no visible geometry");
        for(boolean found:covered)if(!found)
            throw new IllegalStateException("XI renderer omitted a required scanline");
        return new RenderFrame(java.util.Arrays.copyOf(packed,size),stride);
    }
    synchronized Snapshot current(){return snapshot;}
    float[] track(){return worldPoints;} // Existing engine comparison adapter only.
}
