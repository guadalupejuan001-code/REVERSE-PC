package com.reversepc.os;

import android.media.AudioAttributes;
import android.media.AudioFormat;
import android.media.AudioTrack;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/** Optional quiet ambient synthesis. World state chooses a presentation layer. */
final class VelocityAmbientAudio {
    private final ExecutorService worker=Executors.newSingleThreadExecutor(r->new Thread(r,"forest-audio"));
    private volatile boolean enabled,active=true,closed;
    private volatile int requested;
    private AudioTrack track;
    private int loaded=-1;
    boolean isEnabled(){return enabled;}
    boolean toggle(){enabled=!enabled;refresh();return enabled;}
    void update(VelocityXiEngine.Snapshot s){int mode=s.biome==1||s.biome==2?2:s.ambientMode==2?1:0;if(mode!=requested){requested=mode;refresh();}}
    void resume(){active=true;refresh();}
    void pause(){active=false;refresh();}
    private void refresh(){if(closed)return;worker.execute(()->{try{
        if(!enabled||!active){if(track!=null)track.pause();return;}
        if(track==null||loaded!=requested){
            if(track!=null)track.release();loaded=requested;
            final int rate=16000,count=rate*8;short[] pcm=new short[count];
            double low=0;int seed=71;
            for(int i=0;i<count;i++){
                seed=1664525*seed+1013904223;
                double noise=((seed>>>8)/8388608.0)-1;
                low=low*.97+noise*.03;
                double t=i/(double)rate,sound=low*.16;
                if(loaded==2)sound+=noise*.045;
                else if(loaded==1){double gate=Math.max(0,Math.sin(t*22));sound+=Math.sin(t*2*Math.PI*2700)*gate*gate*.012;}
                else {double p=t%2.6;if(p<.24){double e=Math.sin(p/.24*Math.PI);sound+=Math.sin(2*Math.PI*(2300*p+1900*p*p))*e*e*.035;}}
                // Fade the loop boundary to avoid an impulse on repeated playback.
                double fade=Math.min(1,Math.min(i,count-1-i)/160.0);
                pcm[i]=(short)(Math.max(-1,Math.min(1,sound*fade))*32767);
            }
            track=new AudioTrack.Builder().setAudioAttributes(new AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_GAME).setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build())
                .setAudioFormat(new AudioFormat.Builder().setEncoding(AudioFormat.ENCODING_PCM_16BIT).setSampleRate(rate).setChannelMask(AudioFormat.CHANNEL_OUT_MONO).build())
                .setTransferMode(AudioTrack.MODE_STATIC).setBufferSizeInBytes(count*2).build();
            track.write(pcm,0,count);track.setLoopPoints(0,count,-1);track.setVolume(.55f);
        }
        if(enabled&&active)track.play();
    }catch(RuntimeException failure){enabled=false;if(track!=null){try{track.release();}catch(RuntimeException ignored){}track=null;}android.util.Log.w("ReverseVelocity","Ambient audio unavailable",failure);}
    });}
    void close(){if(closed)return;closed=true;worker.execute(()->{if(track!=null){track.release();track=null;}});worker.shutdown();}
}
