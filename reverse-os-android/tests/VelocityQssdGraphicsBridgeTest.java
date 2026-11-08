package com.reversepc.os;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.Arrays;

/** Pure JVM, no Android: tests actual validated XI XFG4 -> qSSD -> GPU plans. */
public final class VelocityQssdGraphicsBridgeTest {
    private static int checks;
    static void check(boolean pass,String message){checks++;if(!pass)throw new AssertionError(message);}
    static void rejects(Runnable action,String message){
        boolean rejected=false;
        try{action.run();}catch(IllegalArgumentException expected){rejected=true;}
        check(rejected,message);
    }
    static RegraphicsGeometry geometry(int x,int atlasColor){
        byte[] atlas=new byte[2048];atlas[2*256+4*16+3]=(byte)atlasColor;
        return geometry(x,atlas);
    }
    static RegraphicsGeometry geometry(int x,byte[] atlas){
        ByteBuffer b=ByteBuffer.allocateDirect(2064+60).order(ByteOrder.LITTLE_ENDIAN);
        b.put(0,(byte)'X');b.put(1,(byte)'F');b.put(2,(byte)'G');b.put(3,(byte)'4');
        b.putShort(4,(short)3840);b.putShort(6,(short)2160);b.putInt(8,4);b.putInt(12,1);
        for(int i=0;i<2048;i++)b.put(16+i,atlas[i]);
        int at=2064;
        for(int v=0;v<3;v++){
            b.putInt(at+v*12,x+v*16);b.putInt(at+v*12+4,100+v*14);
            b.putInt(at+v*12+8,250000);
            b.putShort(at+48+2*v,(short)32640);
        }
        b.put(at+54,(byte)12);b.put(at+55,(byte)4);b.put(at+56,(byte)2);b.put(at+57,(byte)1);
        return RegraphicsGeometry.decodeShared(b.asReadOnlyBuffer());
    }
    private static byte[] shaderAtlas(byte[] source){
        byte[] expected=new byte[2048];
        for(int i=0;i<source.length;i++){
            int tile=i/256,row=(i%256)/16,col=i%16;
            expected[row*128+tile*16+col]=source[i];
        }
        return expected;
    }
    private static byte[] atlasPattern(){
        byte[] source=new byte[2048];
        for(int i=0;i<source.length;i++)source[i]=(byte)((i*7+5)&15);
        return source;
    }
    private static void originalContract(){
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
    }
    private static void exactAtlasVersions(){
        VelocityQssdGraphicsBridge bus=new VelocityQssdGraphicsBridge();
        byte[] source=atlasPattern(),expected=shaderAtlas(source);
        int[] colors=new int[256];
        RegraphicsGeometry original=geometry(100,source);
        long revision=1;
        VelocityQssdGraphicsBridge.Frame first=bus.publish(original,colors,1,1,revision++);
        check(Arrays.equals(first.atlas,expected),"full atlas permutation changed texels");
        bus.confirm(bus.plan(first));
        // Actual vertex changes must not create a new texture version or upload.
        for(int x=101;x<=116;x++){
            VelocityQssdGraphicsBridge.Frame moving=bus.publish(geometry(x,source),colors,1,1,revision++);
            VelocityQssdGraphicsBridge.Plan p=bus.plan(moving);
            check(moving.atlas==first.atlas&&moving.atlasRevision==first.atlasRevision,
                "vertex-only revision rebuilt unchanged atlas");
            check(p.geometryDirty&&p.changedAtlasRows()==0&&p.changedPaletteTexels()==0,
                "vertex-only revision requested texture transfer");
            bus.confirm(p);
        }
        // Every original byte, including the first/last byte of each word and
        // tile, must affect the correct texture row. No checksum can substitute.
        for(int offset=0;offset<source.length;offset++){
            byte[] changed=source.clone();changed[offset]^=1;
            VelocityQssdGraphicsBridge.Frame altered=bus.publish(geometry(100,changed),colors,1,1,revision++);
            VelocityQssdGraphicsBridge.Plan p=bus.plan(altered);
            int row=(offset%256)/16;
            check(Arrays.equals(altered.atlas,shaderAtlas(changed)),"atlas mutation lost at "+offset);
            check(p.atlasRowsMask==(1<<row)&&p.changedPaletteTexels()==0,"wrong atlas row for "+offset);
            bus.confirm(p);
            VelocityQssdGraphicsBridge.Frame restored=bus.publish(original,colors,1,1,revision++);
            p=bus.plan(restored);
            check(p.atlasRowsMask==(1<<row)&&Arrays.equals(restored.atlas,expected),"atlas restore lost at "+offset);
            bus.confirm(p);
        }
        byte[] swapped=source.clone();byte value=swapped[0];swapped[0]=swapped[2047];swapped[2047]=value;
        VelocityQssdGraphicsBridge.Frame collision=bus.publish(geometry(100,swapped),colors,1,1,revision++);
        check(Arrays.equals(collision.atlas,shaderAtlas(swapped))&&bus.plan(collision).atlasRowsMask==0x8001,
            "equal-sum atlas mutation was mistaken for unchanged bytes");
        check(Arrays.equals(first.atlas,expected),"retained atlas lease was mutated");
    }
    private static void skippedPublications(){
        VelocityQssdGraphicsBridge bus=new VelocityQssdGraphicsBridge();
        int[] a=new int[256],b=a.clone(),c=a.clone();b[5]=11;c[7]=22;
        RegraphicsGeometry ga=geometry(100,2),gb=geometry(110,3),gc=geometry(120,2);
        VelocityQssdGraphicsBridge.Frame first=bus.publish(ga,a,1,1,1);
        bus.confirm(bus.plan(first));
        VelocityQssdGraphicsBridge.Frame skipped=bus.publish(gb,b,1,1,2);
        VelocityQssdGraphicsBridge.Frame latest=bus.publish(gc,a,1,1,3);
        VelocityQssdGraphicsBridge.Plan onlyVertices=bus.plan(latest);
        check(onlyVertices.geometryDirty&&onlyVertices.changedPaletteTexels()==0&&onlyVertices.changedAtlasRows()==0,
            "skipped publication changed the resident texture baseline");
        check(latest.paletteRevision>first.paletteRevision&&latest.atlasRevision>first.atlasRevision,
            "test must include texture versions that changed and returned");
        bus.confirm(onlyVertices);
        VelocityQssdGraphicsBridge skipBus=bus;
        rejects(()->skipBus.plan(skipped),"planned a frame older than resident resources");

        // Both plans start from A. If B is accepted first, C must be replanned:
        // its old delta omits reverting B-only texels back to A.
        bus=new VelocityQssdGraphicsBridge();
        first=bus.publish(ga,a,1,1,1);bus.confirm(bus.plan(first));
        VelocityQssdGraphicsBridge.Frame second=bus.publish(gb,b,1,1,2);
        VelocityQssdGraphicsBridge.Plan secondPlan=bus.plan(second);
        VelocityQssdGraphicsBridge.Frame third=bus.publish(gc,c,1,1,3);
        VelocityQssdGraphicsBridge.Plan stale=bus.plan(third);
        check(stale.changedPaletteTexels()==1&&stale.changedAtlasRows()==0,"unexpected initial C delta");
        bus.confirm(secondPlan);
        VelocityQssdGraphicsBridge sameBus=bus;
        rejects(()->sameBus.confirm(stale),"accepted delta calculated against obsolete residency");
        VelocityQssdGraphicsBridge.Plan fresh=bus.plan(third);
        check(fresh.changedPaletteTexels()==2&&fresh.changedAtlasRows()==1,
            "replanned C failed to revert B-only resources");
        check(Arrays.equals(fresh.paletteRanges,new int[]{5,1,7,1}),"replanned palette intervals incorrect");
        // Apply the actual plan to a byte-exact model of B's resident textures.
        int[] gpuPalette=second.palette.clone();byte[] gpuAtlas=second.atlas.clone();
        for(int i=0;i<fresh.paletteRanges.length;i+=2){
            int from=fresh.paletteRanges[i],count=fresh.paletteRanges[i+1];
            System.arraycopy(third.palette,from,gpuPalette,from,count);
        }
        for(int row=0;row<16;row++)if((fresh.atlasRowsMask&(1<<row))!=0)
            System.arraycopy(third.atlas,row*128,gpuAtlas,row*128,128);
        check(Arrays.equals(gpuPalette,third.palette)&&Arrays.equals(gpuAtlas,third.atlas),
            "accepted deltas did not reproduce exact published textures");
        bus.confirm(fresh);
        check(bus.plan(third).changedPaletteTexels()==0&&bus.plan(third).changedAtlasRows()==0,
            "confirmed textures were uploaded again");
    }
    private static void contextAndOwnership(){
        VelocityQssdGraphicsBridge bus=new VelocityQssdGraphicsBridge(),other=new VelocityQssdGraphicsBridge();
        RegraphicsGeometry geometry=geometry(100,2);int[] palette=new int[256];
        VelocityQssdGraphicsBridge.Frame frame=bus.publish(geometry,palette,1,1,1);
        VelocityQssdGraphicsBridge.Frame foreign=other.publish(geometry,palette,1,1,1);
        VelocityQssdGraphicsBridge.Plan pending=bus.plan(frame),foreignPlan=other.plan(foreign);
        rejects(()->bus.plan(foreign),"accepted lease from another qSSD bridge");
        rejects(()->bus.confirm(foreignPlan),"accepted acknowledgment from another qSSD bridge");
        // This plan was based on null residency. Reset to null again, so only
        // the context epoch (not a null comparison) can reject the old plan.
        bus.contextLost();
        rejects(()->bus.confirm(pending),"accepted acknowledgment from lost GL context");
        check(bus.uploadCommits()==0&&bus.sourceSerial()==frame.serial,"rejected plan changed logical state");
        VelocityQssdGraphicsBridge.Plan reset=bus.plan(frame);
        check(reset.geometryDirty&&reset.changedPaletteTexels()==256&&reset.atlasRowsMask==0xffff,
            "new GL context did not request all resources");
        bus.confirm(reset);
        VelocityQssdGraphicsBridge.Plan unchanged=bus.plan(frame);
        check(!unchanged.geometryDirty&&unchanged.paletteRanges.length==0&&unchanged.atlasRowsMask==0,
            "unchanged resources have a transfer plan");
        bus.confirm(unchanged);
        bus.confirm(bus.plan(frame));
        bus.contextLost();
        rejects(()->bus.confirm(unchanged),"no-op acknowledgment survived a context reset");
        check(bus.plan(frame).changedPaletteTexels()==256,"obsolete no-op restored false GPU residency");
        check(bus.uploadCommits()==3,"invalid acknowledgments changed commit accounting");
    }
    private static void paletteRangeBounds(){
        VelocityQssdGraphicsBridge bus=new VelocityQssdGraphicsBridge();
        RegraphicsGeometry geometry=geometry(100,2);
        int[] zero=new int[256],alternating=new int[256],lastOnly=new int[256],all=new int[256];
        for(int i=0;i<256;i+=2)alternating[i]=1;
        lastOnly[255]=9;Arrays.fill(all,2);
        VelocityQssdGraphicsBridge.Frame base=bus.publish(geometry,zero,1,1,1);
        bus.confirm(bus.plan(base));
        VelocityQssdGraphicsBridge.Frame sparse=bus.publish(geometry,alternating,1,1,1);
        VelocityQssdGraphicsBridge.Plan maximal=bus.plan(sparse);
        check(maximal.paletteRanges.length==256&&maximal.changedPaletteTexels()==128,"maximum disjoint palette ranges overflowed");
        for(int i=0;i<128;i++)check(maximal.paletteRanges[2*i]==2*i&&maximal.paletteRanges[2*i+1]==1,"incorrect alternating palette range");
        int[] retained=maximal.paletteRanges.clone();
        VelocityQssdGraphicsBridge.Frame edge=bus.publish(geometry,lastOnly,1,1,1);
        VelocityQssdGraphicsBridge.Plan edgePlan=bus.plan(edge);
        check(Arrays.equals(edgePlan.paletteRanges,new int[]{255,1}),"last palette texel was lost");
        check(Arrays.equals(maximal.paletteRanges,retained),"reused scratch changed an outstanding plan");
        VelocityQssdGraphicsBridge.Frame full=bus.publish(geometry,all,1,1,1);
        VelocityQssdGraphicsBridge.Plan fullPlan=bus.plan(full);
        check(Arrays.equals(fullPlan.paletteRanges,new int[]{0,256}),"contiguous full palette was fragmented");
        check(Arrays.equals(edgePlan.paletteRanges,new int[]{255,1})&&Arrays.equals(maximal.paletteRanges,retained),
            "later palette plan mutated retained ranges");
        bus.confirm(fullPlan);
    }
    public static void main(String[] args){
        originalContract();exactAtlasVersions();skippedPublications();contextAndOwnership();paletteRangeBounds();
        System.out.println("QSSD_GLES_BRIDGE_PASS checks="+checks+" exactAtlasTexels=2048 skippedPublications=PASS stalePlans=REJECTED contextReset=PASS ownership=PASS");
    }
}
