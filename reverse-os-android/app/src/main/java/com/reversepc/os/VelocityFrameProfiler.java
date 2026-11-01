package com.reversepc.os;

import java.util.Arrays;
import java.util.Locale;

/**
 * Measured wall-time stages of completed XI frames, independent of Android.
 * Keeps bounded samples, separates 4K from standard mode, and does not add
 * allocations to the per-frame hot path. Not a GPU timestamp or an FPS claim.
 */
final class VelocityFrameProfiler {
    static final int CAPACITY=96;
    private static final int XI=0,VERIFY=1,EXPAND=2,BITMAP=3,PRESENT=4,TOTAL=5,STAGES=6;
    private final Window normal=new Window(),native4k=new Window();

    void record(boolean nativeMode,long xi,long validation,long expand,long bitmap,
                long present,long total,int packetBytes){
        if(xi<0||validation<0||expand<0||bitmap<0||present<0||total<0||
                packetBytes<0)throw new IllegalArgumentException("Invalid XI frame timing");
        (nativeMode?native4k:normal).add(xi,validation,expand,bitmap,present,total,packetBytes);
    }
    /** Returns an empty string if this mode has no completed frames. */
    String drain(boolean nativeMode){
        return (nativeMode?native4k:normal).drain(nativeMode?"XI_4K":"XI_STANDARD");
    }
    private static final class Window{
        private final long[][] nanos=new long[STAGES][CAPACITY];
        private int used,next,lastPacketBytes;
        void add(long xi,long verify,long expand,long bitmap,long present,long total,int bytes){
            nanos[XI][next]=xi;nanos[VERIFY][next]=verify;
            nanos[EXPAND][next]=expand;nanos[BITMAP][next]=bitmap;
            nanos[PRESENT][next]=present;nanos[TOTAL][next]=total;
            next=(next+1)%CAPACITY;used=Math.min(CAPACITY,used+1);
            lastPacketBytes=bytes;
        }
        double quantile(int stage,double p){
            if(used==0)return 0;
            long[] values=Arrays.copyOf(nanos[stage],used);
            Arrays.sort(values);
            int index=Math.max(0,Math.min(used-1,(int)Math.ceil(used*p)-1));
            return values[index]/1_000_000.0;
        }
        String drain(String mode){
            if(used==0)return "";
            String value=String.format(Locale.ROOT,
                "mode=%s samples=%d payloadBytes=%d"+
                " xiP50Ms=%.3f xiP95Ms=%.3f"+
                " verifyP50Ms=%.3f expandP50Ms=%.3f"+
                " bitmapP50Ms=%.3f presentP50Ms=%.3f"+
                " totalP50Ms=%.3f totalP95Ms=%.3f",
                mode,used,lastPacketBytes,quantile(XI,.50),quantile(XI,.95),
                quantile(VERIFY,.50),quantile(EXPAND,.50),
                quantile(BITMAP,.50),quantile(PRESENT,.50),
                quantile(TOTAL,.50),quantile(TOTAL,.95));
            // Reset only the logical window; the fixed buffers are reused.
            used=0;next=0;return value;
        }
    }
}
