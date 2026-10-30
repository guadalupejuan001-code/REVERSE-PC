package com.reversepc.os;

import java.io.ByteArrayOutputStream;
import java.util.Arrays;

/** Wire-contract regressions for the Android-free bounded XFS1 presenter. */
public final class RegraphicsFrameTest {
    static int checks;
    static final int[] COLORS={0x123456,0xabcdef,0x335577};
    static void check(boolean ok){if(!ok)throw new AssertionError("frame "+checks);checks++;}
    static void reject(Runnable action){
        try{action.run();throw new AssertionError("accepted invalid frame "+checks);}
        catch(IllegalArgumentException expected){checks++;}
    }
    static void put16(ByteArrayOutputStream out,int n){out.write(n);out.write(n>>>8);}
    static void put32(ByteArrayOutputStream out,int n){put16(out,n);put16(out,n>>>16);}
    static void patch16(byte[] bytes,int at,int n){bytes[at]=(byte)n;bytes[at+1]=(byte)(n>>>8);}
    static void patch32(byte[] bytes,int at,int n){patch16(bytes,at,n);patch16(bytes,at+2,n>>>16);}
    static void span(ByteArrayOutputStream out,int y,int x0,int x1,int material,int depth){
        spanRev(out,y,x0,x1,material,depth,1);
    }
    static void spanRev(ByteArrayOutputStream out,int y,int x0,int x1,int material,int depth,int revision){
        out.write(2);out.write(material);put16(out,y);put16(out,x0);put16(out,x1);
        put16(out,depth);put32(out,revision);
    }
    static byte[] sample(int stride){
        ByteArrayOutputStream out=new ByteArrayOutputStream();
        out.write('X');out.write('F');out.write('S');out.write('1');out.write(1);out.write(0);
        put16(out,1280);put16(out,720);put32(out,1);put16(out,0);
        for(int y=0;y<720;y+=stride){
            span(out,y,0,1279,0,100);
            span(out,y,10,19,1,99);
            span(out,y,1279,1279,2,98);
        }
        out.write(3);out.write(0);put16(out,0);put32(out,1);
        return out.toByteArray();
    }
    static byte[] removeRow(byte[] bytes){
        // Three spans in row 4 occupy [58,100); remove exactly that row.
        byte[] result=new byte[bytes.length-42];
        System.arraycopy(bytes,0,result,0,58);
        System.arraycopy(bytes,100,result,58,bytes.length-100);
        return result;
    }
    static byte[] layered(int firstRowSpans){
        ByteArrayOutputStream out=new ByteArrayOutputStream();
        out.write('X');out.write('F');out.write('S');out.write('1');out.write(1);out.write(0);
        put16(out,1280);put16(out,720);put32(out,1);put16(out,0);
        for(int y=0;y<720;y+=4){
            span(out,y,0,1279,0,100);
            if(y==0)for(int layer=1;layer<firstRowSpans;layer++)
                span(out,y,layer*10,1279-layer*10,layer%3,100-layer);
        }
        out.write(3);out.write(0);put16(out,0);put32(out,1);
        return out.toByteArray();
    }
    static byte[] mesh(int stride){
        int width=stride==4?320:stride==2?480:640,height=stride==4?180:stride==2?270:360;
        ByteArrayOutputStream out=new ByteArrayOutputStream();
        out.write('X');out.write('F');out.write('S');out.write('1');out.write(1);out.write(0);
        put16(out,width);put16(out,height);put32(out,2);put16(out,0);
        for(int y=0;y<height;y++){
            spanRev(out,y,0,width-1,0,100,2);
            spanRev(out,y,10,19,1,1,2);
            spanRev(out,y,width-1,width-1,2,1,2);
        }
        out.write(3);out.write(0);put16(out,0);put32(out,2);
        return out.toByteArray();
    }
    public static void main(String[] args){
        byte[] valid=sample(4);
        RegraphicsFrame frame=RegraphicsFrame.decode(valid,4,COLORS);
        check(frame.width==1280&&frame.height==720&&frame.stride==4&&frame.commands==540);
        int[] full=new int[1280*720];Arrays.fill(full,0x77999999);
        frame.present(full,1280,720);
        for(int y=0;y<720;y++){
            check(full[y*1280+9]==(0xff000000|COLORS[0]));
            check(full[y*1280+10]==(0xff000000|COLORS[1]));
            check(full[y*1280+19]==(0xff000000|COLORS[1]));
            check(full[y*1280+20]==(0xff000000|COLORS[0]));
            check(full[y*1280+1279]==(0xff000000|COLORS[2]));
        }
        int[] small=new int[320*180];frame.present(small,320,180);
        check(small[1]==(0xff000000|COLORS[0]));
        check(small[2]==(0xff000000|COLORS[1])&&small[4]==(0xff000000|COLORS[1]));
        check(small[5]==(0xff000000|COLORS[0])&&small[319]==(0xff000000|COLORS[2]));
        int[] palette=COLORS.clone();byte[] mutable=valid.clone();
        RegraphicsFrame independent=RegraphicsFrame.decode(mutable,4,palette);
        Arrays.fill(mutable,(byte)0);Arrays.fill(palette,0);
        int[] again=new int[full.length];independent.present(again,1280,720);
        check(Arrays.equals(full,again));
        reject(()->RegraphicsFrame.decode(null,4,COLORS));
        reject(()->RegraphicsFrame.decode(valid,3,COLORS));
        reject(()->RegraphicsFrame.decode(valid,4,null));
        reject(()->RegraphicsFrame.decode(valid,4,new int[0]));
        reject(()->RegraphicsFrame.decode(valid,4,new int[257]));
        reject(()->RegraphicsFrame.decode(valid,4,new int[]{-1}));
        reject(()->RegraphicsFrame.decode(valid,4,new int[]{0x1000000}));
        reject(()->RegraphicsFrame.decode(Arrays.copyOf(valid,valid.length-1),4,COLORS));
        reject(()->RegraphicsFrame.decode(Arrays.copyOf(valid,24),4,COLORS));
        for(int at:new int[]{0,4,5,14,valid.length-8,valid.length-7,valid.length-6}){
            byte[] bad=valid.clone();bad[at]^=1;
            reject(()->RegraphicsFrame.decode(bad,4,COLORS));
        }
        for(int at:new int[]{10,26,valid.length-4}){
            byte[] bad=valid.clone();patch32(bad,at,2);
            reject(()->RegraphicsFrame.decode(bad,4,COLORS));
        }
        byte[] width=valid.clone();patch16(width,6,1279);
        reject(()->RegraphicsFrame.decode(width,4,COLORS));
        byte[] height=valid.clone();patch16(height,8,719);
        reject(()->RegraphicsFrame.decode(height,4,COLORS));
        byte[] material=valid.clone();material[17]=3;
        reject(()->RegraphicsFrame.decode(material,4,COLORS));
        byte[] opcode=valid.clone();opcode[16]=3;
        reject(()->RegraphicsFrame.decode(opcode,4,COLORS));
        byte[] missing=removeRow(valid);
        reject(()->RegraphicsFrame.decode(missing,4,COLORS));
        byte[] order=valid.clone();patch16(order,58+2,8);
        reject(()->RegraphicsFrame.decode(order,4,COLORS));
        byte[] misaligned=valid.clone();patch16(misaligned,58+2,2);
        reject(()->RegraphicsFrame.decode(misaligned,4,COLORS));
        byte[] beyond=valid.clone();patch16(beyond,16+6,1280);
        reject(()->RegraphicsFrame.decode(beyond,4,COLORS));
        byte[] empty=valid.clone();patch16(empty,30+4,20);
        reject(()->RegraphicsFrame.decode(empty,4,COLORS));
        byte[] background=valid.clone();patch16(background,16+6,1278);
        reject(()->RegraphicsFrame.decode(background,4,COLORS));
        byte[] depth=valid.clone();patch16(depth,30+8,100);
        reject(()->RegraphicsFrame.decode(depth,4,COLORS));
        byte[] sentinel=valid.clone();patch16(sentinel,30+8,65535);
        reject(()->RegraphicsFrame.decode(sentinel,4,COLORS));
        byte[] zeroDepth=valid.clone();patch16(zeroDepth,30+8,0);
        reject(()->RegraphicsFrame.decode(zeroDepth,4,COLORS));
        byte[] minDepth=valid.clone();patch16(minDepth,44+8,1);
        RegraphicsFrame minimum=RegraphicsFrame.decode(minDepth,4,COLORS);
        int[] minimumImage=new int[full.length];minimum.present(minimumImage,1280,720);
        check(Arrays.equals(minimumImage,full));
        byte[] noLast=Arrays.copyOf(valid,valid.length-42);
        System.arraycopy(valid,valid.length-8,noLast,noLast.length-8,8);
        reject(()->RegraphicsFrame.decode(noLast,4,COLORS));
        for(int stride:new int[]{1,2}){
            RegraphicsFrame other=RegraphicsFrame.decode(sample(stride),stride,COLORS);
            int[] rendered=new int[full.length];other.present(rendered,1280,720);
            check(Arrays.equals(rendered,full));
        }
        // The racing shader can emit more than sixteen clipped overlapping
        // regions. The nearest material must win only within its XI interval.
        RegraphicsFrame dense=RegraphicsFrame.decode(layered(48),4,COLORS);
        int[] clipped=new int[1280*720];dense.present(clipped,1280,720);
        check(dense.commands==48+179);
        check(clipped[9]==(0xff000000|COLORS[0]));
        check(clipped[15]==(0xff000000|COLORS[1]));
        check(clipped[25]==(0xff000000|COLORS[2]));
        check(clipped[640]==(0xff000000|COLORS[2]));
        check(clipped[3*1280+640]==clipped[640]);
        check(clipped[4*1280+640]==(0xff000000|COLORS[0]));
        reject(()->RegraphicsFrame.decode(layered(49),4,COLORS));
        for(int stride:new int[]{4,2,1}){
            byte[] wire=mesh(stride);RegraphicsFrame projected=RegraphicsFrame.decode(wire,stride,COLORS);
            int w=stride==4?320:stride==2?480:640,h=stride==4?180:stride==2?270:360;
            check(projected.width==w&&projected.height==h&&projected.revision==2);
            int[] actual=new int[w*h];projected.present(actual,w,h);
            for(int y=0;y<h;y++){
                check(actual[y*w+9]==(0xff000000|COLORS[0]));
                check(actual[y*w+10]==(0xff000000|COLORS[1]));
                check(actual[y*w+19]==(0xff000000|COLORS[1]));
                check(actual[y*w+20]==(0xff000000|COLORS[0]));
                check(actual[y*w+w-1]==(0xff000000|COLORS[2]));
            }
            byte[] overlap=wire.clone();patch16(overlap,44+4,19);
            reject(()->RegraphicsFrame.decode(overlap,stride,COLORS));
            byte[] wrongDepth=wire.clone();patch16(wrongDepth,30+8,2);
            reject(()->RegraphicsFrame.decode(wrongDepth,stride,COLORS));
            byte[] wrongRevision=wire.clone();patch32(wrongRevision,30+10,1);
            reject(()->RegraphicsFrame.decode(wrongRevision,stride,COLORS));
            byte[] wrongRows=wire.clone();patch16(wrongRows,58+2,2);
            reject(()->RegraphicsFrame.decode(wrongRows,stride,COLORS));
            byte[] wrongSize=wire.clone();patch16(wrongSize,6,w+1);
            reject(()->RegraphicsFrame.decode(wrongSize,stride,COLORS));
        }
        int[] untouched={12,34,56};
        reject(()->frame.present(untouched,2,2));
        check(Arrays.equals(untouched,new int[]{12,34,56}));
        reject(()->frame.present(null,320,180));
        reject(()->frame.present(untouched,Integer.MAX_VALUE,2));
        System.out.println("REGRAPHICS_FRAME_PASS checks="+checks);
    }
}
