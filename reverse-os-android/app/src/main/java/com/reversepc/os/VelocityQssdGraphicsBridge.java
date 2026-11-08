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
    static final class Frame {
        final long serial,sourceIdentity,sourceRevision,paletteRevision,atlasRevision;
        final RegraphicsGeometry geometry;
        final int[] palette;
        final byte[] atlas; // 128 x 16 texels, unlike XI's tile-major layout.
        private Frame(long serial,long identity,long revision,long paletteRevision,long atlasRevision,
                      RegraphicsGeometry geometry,int[] palette,byte[] atlas) {
            this.serial=serial;sourceIdentity=identity;sourceRevision=revision;
            this.paletteRevision=paletteRevision;this.atlasRevision=atlasRevision;
            this.geometry=geometry;this.palette=palette;this.atlas=atlas;
        }
    }
    static final class Plan {
        final Frame frame;
        final boolean geometryDirty;
        final int[] paletteRanges; // [texelStart,texelCount] pairs
        final int atlasRowsMask;    // row bits, 0..15
        private Plan(Frame frame,boolean geometryDirty,int[] paletteRanges,int atlasRowsMask){
            this.frame=frame;this.geometryDirty=geometryDirty;
            this.paletteRanges=paletteRanges;this.atlasRowsMask=atlasRowsMask;
        }
        int changedPaletteTexels(){int n=0;for(int i=1;i<paletteRanges.length;i+=2)n+=paletteRanges[i];return n;}
        int changedAtlasRows(){return Integer.bitCount(atlasRowsMask);}
    }

    private Frame head,uploaded;
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
    synchronized Frame publish(RegraphicsGeometry geometry,int[] palette,long identity,long revision){
        need(geometry!=null&&palette!=null&&palette.length==PALETTE,"invalid resource bundle");
        need(identity>0&&revision>0,"missing native qSSD source identity/revision");
        if(head!=null&&identity==head.sourceIdentity){
            need(revision>=head.sourceRevision,"source revision moved backwards");
            need(revision!=head.sourceRevision||geometry==head.geometry,
                 "same qSSD geometry revision has different backing");
        }
        boolean newGeometry=head==null||identity!=head.sourceIdentity||revision!=head.sourceRevision;
        int[] colors=head!=null&&Arrays.equals(palette,head.palette)?head.palette:palette.clone();
        byte[] atlas=newGeometry?atlasLayout(geometry):head.atlas;
        if(head!=null&&newGeometry&&Arrays.equals(atlas,head.atlas))atlas=head.atlas;
        if(head!=null&&!newGeometry&&colors==head.palette){
            identical++;return head;
        }
        need(publications<Long.MAX_VALUE,"publication counter exhausted");
        head=new Frame(++publications,identity,revision,
                head==null?1:head.paletteRevision+(colors!=head.palette?1:0),
                head==null?1:head.atlasRevision+(atlas!=head.atlas?1:0),
                geometry,colors,atlas);
        return head;
    }

    /** Compare against what the GL driver actually accepted, not just head. */
    synchronized Plan plan(Frame lease){
        need(lease!=null&&lease.serial>0&&lease.serial<=publications,"invalid qSSD lease");
        boolean vertexDirty=uploaded==null||lease.sourceIdentity!=uploaded.sourceIdentity||
                lease.sourceRevision!=uploaded.sourceRevision;
        int[] ranges=new int[PALETTE*2];int n=0;
        if(uploaded==null||lease.paletteRevision!=uploaded.paletteRevision){
            for(int i=0;i<PALETTE;){
                if(uploaded!=null&&lease.palette[i]==uploaded.palette[i]){i++;continue;}
                int start=i++;
                while(i<PALETTE&&(uploaded==null||lease.palette[i]!=uploaded.palette[i]))i++;
                ranges[n++]=start;ranges[n++]=i-start;
            }
        }
        int rows=0;
        if(uploaded==null||lease.atlasRevision!=uploaded.atlasRevision)
            for(int row=0;row<ATLAS_ROWS;row++){
                int from=row*ATLAS_ROW;
                boolean dirty=uploaded==null;
                for(int x=0;!dirty&&x<ATLAS_ROW;x++)
                    if(lease.atlas[from+x]!=uploaded.atlas[from+x])dirty=true;
                if(dirty)rows|=1<<row;
            }
        return new Plan(lease,vertexDirty,Arrays.copyOf(ranges,n),rows);
    }

    /** A GL context reset invalidates only physical residency, not qSSD state. */
    synchronized void contextLost(){uploaded=null;}

    /** Called after successful glBufferSubData/glTexSubImage2D and glGetError. */
    synchronized void confirm(Plan plan){
        need(plan!=null&&plan.frame.serial<=publications,"invalid acknowledged upload");
        need(uploaded==null||plan.frame.serial>=uploaded.serial,"out-of-order GLES acknowledgment");
        uploaded=plan.frame;applied++;
    }
    synchronized long uploadCommits(){return applied;}
    synchronized long reusedPublications(){return identical;}
    synchronized long sourceSerial(){return head==null?0:head.serial;}
}
