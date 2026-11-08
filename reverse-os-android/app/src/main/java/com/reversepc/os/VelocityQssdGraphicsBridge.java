package com.reversepc.os;

import java.nio.ByteBuffer;

/** Thin JNI projection of the original qSSD component, not a Java resource manager. */
final class VelocityQssdGraphicsBridge implements AutoCloseable {
    static { System.loadLibrary("reverse_os"); }
    static final class Frame {
        final long serial,sourceSession,sourceIdentity,sourceRevision,paletteRevision,atlasRevision;
        final RegraphicsGeometry geometry;
        final int[] palette;
        final byte[] atlas;
        private final long owner;
        private Frame(long owner,long[] receipt,RegraphicsGeometry geometry,int[] palette,byte[] atlas,
                      long session,long identity,long revision){
            this.owner=owner;serial=receipt[0];paletteRevision=receipt[1];atlasRevision=receipt[2];
            this.geometry=geometry;this.palette=palette;this.atlas=atlas;
            sourceSession=session;sourceIdentity=identity;sourceRevision=revision;
        }
    }
    static final class Plan {
        final Frame frame;
        final boolean geometryDirty;
        final int[] paletteRanges;
        final int atlasRowsMask;
        private final long context;
        private Plan(Frame frame,long[] nativePlan){
            this.frame=frame;context=nativePlan[0];geometryDirty=nativePlan[1]!=0;
            atlasRowsMask=(int)nativePlan[2];int count=(int)nativePlan[3];
            if(count<0||count>256||nativePlan.length!=4+count*2)
                throw new IllegalArgumentException("Invalid qSSD native upload plan");
            paletteRanges=new int[count*2];
            for(int i=0;i<paletteRanges.length;i++)paletteRanges[i]=(int)nativePlan[4+i];
        }
        int changedPaletteTexels(){int n=0;for(int i=1;i<paletteRanges.length;i+=2)n+=paletteRanges[i];return n;}
        int changedAtlasRows(){return Integer.bitCount(atlasRowsMask);}
    }
    private long handle=nativeOpen();
    // Transport objects only. No head/uploaded state, revision calculations,
    // atlas conversion, or dirty-resource decisions are maintained in Java.
    private Frame projection;
    private long confirmations,reused;
    private void requireOpen(){if(handle==0)throw new IllegalStateException("qSSD graphics port is closed");}
    synchronized Frame publish(RegraphicsGeometry geometry,int[] palette,long session,long identity,long revision){
        requireOpen();
        if(geometry==null||palette==null||palette.length!=256)
            throw new IllegalArgumentException("Invalid REgraphics resource projection");
        long[] receipt=nativePublish(handle,session,identity,revision,geometry.qssdSourceView(),palette);
        if(receipt==null||receipt.length!=4)throw new IllegalStateException("Missing qSSD native receipt");
        reused=receipt[3];
        if(projection!=null&&projection.serial==receipt[0])return projection;
        int[] colors=projection!=null&&projection.paletteRevision==receipt[1]?projection.palette:palette.clone();
        byte[] atlas=projection!=null&&projection.atlasRevision==receipt[2]?projection.atlas:nativeAtlas(handle,receipt[0]);
        projection=new Frame(handle,receipt,geometry,colors,atlas,session,identity,revision);
        return projection;
    }
    synchronized Plan plan(Frame frame){
        requireOpen();
        if(frame==null||frame.owner!=handle)throw new IllegalArgumentException("Foreign qSSD graphics projection");
        return new Plan(frame,nativePlan(handle,frame.serial));
    }
    synchronized void confirm(Plan plan){
        requireOpen();
        if(plan==null||plan.frame.owner!=handle)throw new IllegalArgumentException("Foreign qSSD receipt");
        confirmations=nativeConfirm(handle,plan.frame.serial,plan.context);
    }
    synchronized void contextLost(){requireOpen();nativeInvalidate(handle);}
    synchronized void contextCreated(){if(handle==0)handle=nativeOpen();nativeInvalidate(handle);}
    synchronized long uploadCommits(){return confirmations;}
    synchronized long reusedPublications(){return reused;}
    synchronized long sourceSerial(){return projection==null?0:projection.serial;}
    @Override public synchronized void close(){if(handle!=0){nativeClose(handle);handle=0;projection=null;}}
    private static native long nativeOpen();
    private static native void nativeClose(long handle);
    private static native long[] nativePublish(long handle,long session,long identity,long revision,ByteBuffer geometry,int[] palette);
    private static native byte[] nativeAtlas(long handle,long serial);
    private static native long[] nativePlan(long handle,long serial);
    private static native long nativeConfirm(long handle,long serial,long context);
    private static native void nativeInvalidate(long handle);
}
