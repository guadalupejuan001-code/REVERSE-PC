package com.reversepc.os;

import java.util.Arrays;

/**
 * qSSD graphics bus between immutable REgraphics/XFG4 observations and GLES.
 * The XI native qSSD projection owns geometry identity/revision. This bridge
 * owns resource versions and only publishes explicit immutable GPU leases.
 * It never generates geometry, changes physics, or calls the GLES driver.
 */
final class VelocityQssdGraphicsBridge {
    private static final int PALETTE=256,ATLAS_ROWS=16,ATLAS_ROW=128;
    private static final int[] NO_PALETTE_RANGES=new int[0];
    static final class Frame {
        private final Object owner;
        final long serial,sourceSession,sourceIdentity,sourceRevision,paletteRevision,atlasRevision;
        final RegraphicsGeometry geometry;
        final int[] palette;
        final byte[] atlas; // 128 x 16 texels, unlike XI's tile-major layout.
        private Frame(Object owner,long serial,long session,long identity,long revision,long paletteRevision,long atlasRevision,
                      RegraphicsGeometry geometry,int[] palette,byte[] atlas) {
            this.owner=owner;this.serial=serial;sourceSession=session;sourceIdentity=identity;sourceRevision=revision;
            this.paletteRevision=paletteRevision;this.atlasRevision=atlasRevision;
            this.geometry=geometry;this.palette=palette;this.atlas=atlas;
        }
    }
    static final class Plan {
        private final Object owner;
        private final long contextEpoch;
        private final Frame resident;
        final Frame frame;
        final boolean geometryDirty;
        final int[] paletteRanges; // [texelStart,texelCount] pairs
        final int atlasRowsMask;    // row bits, 0..15
        private Plan(Object owner,long contextEpoch,Frame resident,Frame frame,boolean geometryDirty,int[] paletteRanges,int atlasRowsMask){
            this.owner=owner;this.contextEpoch=contextEpoch;this.resident=resident;
            this.frame=frame;this.geometryDirty=geometryDirty;
            this.paletteRanges=paletteRanges;this.atlasRowsMask=atlasRowsMask;
        }
        int changedPaletteTexels(){int n=0;for(int i=1;i<paletteRanges.length;i+=2)n+=paletteRanges[i];return n;}
        int changedAtlasRows(){return Integer.bitCount(atlasRowsMask);}
    }

    private final Object owner=new Object();
    private Frame head,uploaded;
    private Plan cachedPlan;
    private int[] paletteRangeScratch;
    private long contextEpoch;
    private long publications,identical,applied;
    private static void need(boolean ok,String reason){
        if(!ok)throw new IllegalArgumentException("QSSD graphics bridge: "+reason);
    }
    private static byte[] atlasLayout(RegraphicsGeometry geometry){
        byte[] result=new byte[ATLAS_ROWS*ATLAS_ROW];
        for(int row=0;row<ATLAS_ROWS;row++)
            for(int tile=0;tile<8;tile++)
                for(int col=0;col<16;col++)
                    result[row*ATLAS_ROW+tile*16+col]=geometry.byteAt(16+tile*256+row*16+col);
        return result;
    }
    /** Only a validated qSSD geometry lease may be published to GLES. */
    synchronized Frame publish(RegraphicsGeometry geometry,int[] palette,long session,long identity,long revision){
        need(geometry!=null&&palette!=null&&palette.length==PALETTE,"invalid resource bundle");
        need(session>0&&identity>0&&revision>0,"missing native qSSD source session/identity/revision");
        if(head!=null)need(session>=head.sourceSession,"stale native session after restore");
        if(head!=null&&session==head.sourceSession&&identity==head.sourceIdentity){
            need(revision>=head.sourceRevision,"source revision moved backwards");
            need(revision!=head.sourceRevision||geometry==head.geometry,
                 "same qSSD geometry revision has different backing");
        }
        boolean newGeometry=head==null||session!=head.sourceSession||identity!=head.sourceIdentity||revision!=head.sourceRevision;
        int[] colors=head!=null&&Arrays.equals(palette,head.palette)?head.palette:palette.clone();
        // Moving vertices do not justify rebuilding an unchanged texture atlas.
        // Compare exact original bytes before allocating or transposing them.
        byte[] atlas=head!=null&&(!newGeometry||geometry.sameAtlas(head.geometry))?
                head.atlas:atlasLayout(geometry);
        if(head!=null&&!newGeometry&&colors==head.palette){
            identical++;return head;
        }
        need(publications<Long.MAX_VALUE,"publication counter exhausted");
        head=new Frame(owner,++publications,session,identity,revision,
                head==null?1:head.paletteRevision+(colors!=head.palette?1:0),
                head==null?1:head.atlasRevision+(atlas!=head.atlas?1:0),
                geometry,colors,atlas);
        return head;
    }

    private int[] paletteRanges(Frame lease,Frame resident){
        if(resident==null)return new int[]{0,PALETTE};
        if(lease.paletteRevision==resident.paletteRevision)return NO_PALETTE_RANGES;
        int first=0;
        while(first<PALETTE&&lease.palette[first]==resident.palette[first])first++;
        if(first==PALETTE)return NO_PALETTE_RANGES;
        // At most 128 disjoint ranges in 256 texels. This private scratch is
        // allocated once, only if needed, and used under plan()'s monitor.
        // Every returned plan owns its exact ranges; later plans cannot mutate it.
        if(paletteRangeScratch==null)paletteRangeScratch=new int[PALETTE];
        int n=0;
        for(int i=first;i<PALETTE;){
            if(lease.palette[i]==resident.palette[i]){i++;continue;}
            int start=i++;
            while(i<PALETTE&&lease.palette[i]!=resident.palette[i])i++;
            paletteRangeScratch[n++]=start;paletteRangeScratch[n++]=i-start;
        }
        return Arrays.copyOf(paletteRangeScratch,n);
    }

    /** Compare against what the GL driver actually accepted, not just head. */
    synchronized Plan plan(Frame lease){
        need(lease!=null&&lease.owner==owner&&lease.serial>0&&lease.serial<=publications,"invalid or foreign qSSD lease");
        need(uploaded==null||lease.serial>=uploaded.serial,"out-of-order qSSD lease");
        if(cachedPlan!=null&&cachedPlan.frame==lease&&cachedPlan.resident==uploaded&&cachedPlan.contextEpoch==contextEpoch)
            return cachedPlan;
        boolean vertexDirty=uploaded==null||lease.sourceSession!=uploaded.sourceSession||lease.sourceIdentity!=uploaded.sourceIdentity||
                lease.sourceRevision!=uploaded.sourceRevision;
        int[] ranges=paletteRanges(lease,uploaded);
        int rows=0;
        if(uploaded==null||lease.atlasRevision!=uploaded.atlasRevision)
            for(int row=0;row<ATLAS_ROWS;row++){
                int from=row*ATLAS_ROW;
                boolean dirty=uploaded==null;
                for(int x=0;!dirty&&x<ATLAS_ROW;x++)
                    if(lease.atlas[from+x]!=uploaded.atlas[from+x])dirty=true;
                if(dirty)rows|=1<<row;
            }
        cachedPlan=new Plan(owner,contextEpoch,uploaded,lease,vertexDirty,ranges,rows);
        return cachedPlan;
    }

    /** A GL context reset invalidates only physical residency, not qSSD state. */
    synchronized void contextLost(){
        need(contextEpoch<Long.MAX_VALUE,"GLES context epoch exhausted");
        contextEpoch++;uploaded=null;cachedPlan=null;
    }

    /** Called after successful glBufferSubData/glTexSubImage2D and glGetError. */
    synchronized void confirm(Plan plan){
        need(plan!=null&&plan.owner==owner&&plan.frame.owner==owner&&plan.frame.serial<=publications,"invalid or foreign acknowledged upload");
        need(plan.contextEpoch==contextEpoch,"acknowledgment from obsolete GLES context");
        need(plan.resident==uploaded,"acknowledgment based on obsolete GLES residency");
        need(uploaded==null||plan.frame.serial>=uploaded.serial,"out-of-order GLES acknowledgment");
        if(uploaded!=plan.frame)cachedPlan=null;
        uploaded=plan.frame;applied++;
    }
    synchronized long uploadCommits(){return applied;}
    synchronized long reusedPublications(){return identical;}
    synchronized long sourceSerial(){return head==null?0:head.serial;}
}
