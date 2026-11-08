package com.reversepc.os;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.Arrays;

/** Pure JVM, no Android: tests actual validated XI XFG4 -> qSSD -> GPU plans. */
public final class VelocityQssdGraphicsBridgeTest {
    static void check(boolean pass,String message){if(!pass)throw new AssertionError(message);}
    static RegraphicsGeometry geometry(int x,int atlasColor){
        ByteBuffer b=ByteBuffer.allocateDirect(2064+60).order(ByteOrder.LITTLE_ENDIAN);
        b.put(0,(byte)'X');b.put(1,(byte)'F');b.put(2,(byte)'G');b.put(3,(byte)'4');
        b.putShort(4,(short)3840);b.putShort(6,(short)2160);b.putInt(8,4);b.putInt(12,1);
        b.put(16+2*256+4*16+3,(byte)atlasColor);
        int at=2064;
        for(int v=0;v<3;v++){
            b.putInt(at+v*12,x+v*16);b.putInt(at+v*12+4,100+v*14);
            b.putInt(at+v*12+8,250000);
            b.putShort(at+48+2*v,(short)32640);
        }
        b.put(at+54,(byte)12);b.put(at+55,(byte)4);b.put(at+56,(byte)2);b.put(at+57,(byte)1);
        return RegraphicsGeometry.decodeShared(b.asReadOnlyBuffer());
    }
    public static void main(String[] args){
        VelocityQssdGraphicsBridge bus=new VelocityQssdGraphicsBridge();
        RegraphicsGeometry firstGeometry=geometry(100,2);
        int[] colors=new int[256];Arrays.fill(colors,0x335577);
        VelocityQssdGraphicsBridge.Frame first=bus.publish(firstGeometry,colors,100,10,1);
        colors[5]=0xabcdef;
        check(first.palette[5]==0x335577,"qSSD palette was not immutable");
        VelocityQssdGraphicsBridge.Plan p=bus.plan(first);
        check(p.geometryDirty&&p.changedPaletteTexels()==256&&p.changedAtlasRows()==16,"first physical upload incomplete");
        check(p.frame.geometry==firstGeometry,"geometry was copied instead of borrowed");
        check(p.frame.atlas[4*128+2*16+3]==2,"atlas layout lost tile coordinate");
        check(bus.plan(first).geometryDirty,"unsuccessful GLES upload must be retried");
        bus.confirm(p);
        check(bus.plan(first).paletteRanges.length==0&&!bus.plan(first).geometryDirty,"identical frame uploaded twice");
        int[] same=new int[256];Arrays.fill(same,0x335577);
        check(bus.publish(firstGeometry,same,100,10,1)==first,"unchanged qSSD lease not reused");
        same[5]=0x776655;same[6]=0x123456;same[15]=0x005522;
        VelocityQssdGraphicsBridge.Frame changed=bus.publish(firstGeometry,same,100,10,1);
        p=bus.plan(changed);
        check(!p.geometryDirty&&p.changedPaletteTexels()==3&&p.paletteRanges.length==4,"palette partial ranges incorrect");
        check(p.paletteRanges[0]==5&&p.paletteRanges[1]==2&&p.paletteRanges[2]==15&&p.paletteRanges[3]==1,
            "palette dirty spans incorrect");
        check(p.changedAtlasRows()==0,"palette changes re-uploaded atlas");
        bus.confirm(p);
        RegraphicsGeometry changedGeometry=geometry(110,3);
        VelocityQssdGraphicsBridge.Frame next=bus.publish(changedGeometry,same,100,10,2);
        p=bus.plan(next);
        check(p.geometryDirty&&p.paletteRanges.length==0&&p.changedAtlasRows()==1&&
              (p.atlasRowsMask&(1<<4))!=0,"atlas row delta did not follow qSSD revision");
        // An interrupted transfer must still compare against the LAST accepted copy.
        check(bus.plan(next).geometryDirty,"incomplete geometry upload was marked resident");
        bus.confirm(p);
        check(bus.plan(next).changedAtlasRows()==0,"same atlas row uploaded twice");
        bus.contextLost();
        check(bus.plan(next).geometryDirty&&bus.plan(next).changedAtlasRows()==16&&
              bus.plan(next).changedPaletteTexels()==256,"context reset failed to force re-upload");
        bus.confirm(bus.plan(next));
        boolean stale=false;
        try{bus.publish(firstGeometry,same,100,10,1);}catch(IllegalArgumentException expected){stale=true;}
        check(stale,"stale native qSSD revision was accepted");
        RegraphicsGeometry restored=geometry(110,3);
        VelocityQssdGraphicsBridge.Frame resumed=bus.publish(restored,same,101,10,1);
        VelocityQssdGraphicsBridge.Plan afterRestart=bus.plan(resumed);
        check(afterRestart.geometryDirty,"new qSSD session reused stale GPU resources");
        bus.confirm(afterRestart);
        boolean oldSession=false;
        try{bus.publish(changedGeometry,same,100,10,3);}catch(IllegalArgumentException expected){oldSession=true;}
        check(oldSession,"qSSD accepted an obsolete native session after restore");
        check(bus.uploadCommits()==5,"unexpected GLES upload commit accounting");
        System.out.println("QSSD_GLES_BRIDGE_PASS paletteDeltas=3 atlasRows=1 rollback=PASS contextReset=PASS revisions=PASS");
    }
}
