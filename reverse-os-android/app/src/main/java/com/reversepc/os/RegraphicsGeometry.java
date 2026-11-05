package com.reversepc.os;

import java.nio.FloatBuffer;

/** Validated XI XFG4 triangles. This adapter never creates world geometry. */
final class RegraphicsGeometry {
    static final int HEADER=16,ATLAS=2048,FACE_BYTES=60,MAX_FACES=8192,FLOATS=11;
    final byte[] bytes;
    final int width,height,faces;
    final int[] starts=new int[4],counts=new int[4];
    private RegraphicsGeometry(byte[] bytes,int width,int height,int faces){
        this.bytes=bytes;this.width=width;this.height=height;this.faces=faces;
    }
    static int u16(byte[] b,int n){return (b[n]&255)|((b[n+1]&255)<<8);}
    static int i32(byte[] b,int n){return (b[n]&255)|((b[n+1]&255)<<8)|((b[n+2]&255)<<16)|(b[n+3]<<24);}
    static void require(boolean ok,String why){if(!ok)throw new IllegalArgumentException("REgraphics XFG4: "+why);}
    static RegraphicsGeometry decodeOwned(byte[] b){
        require(b!=null&&b.length>=HEADER+ATLAS,"truncated packet");
        require(b[0]=='X'&&b[1]=='F'&&b[2]=='G'&&b[3]=='4',"signature");
        int w=u16(b,4),h=u16(b,6),n=i32(b,12);
        require(w==3840&&h==2160&&i32(b,8)==4,"projection revision");
        require(n>=0&&n<=MAX_FACES&&b.length==HEADER+ATLAS+n*FACE_BYTES,"face budget or length");
        for(int i=HEADER;i<HEADER+ATLAS;i++)require((b[i]&255)<16,"texture nibble");
        for(int i=0;i<n;i++){
            int at=HEADER+ATLAS+i*FACE_BYTES;
            for(int v=0;v<3;v++){
                int x=i32(b,at+v*12),y=i32(b,at+v*12+4),z=i32(b,at+v*12+8);
                require(Math.abs((long)x)<=100_000_000&&Math.abs((long)y)<=100_000_000&&z>0&&z<=1_000_000,"vertex bounds");
                require(u16(b,at+48+v*2)<=65280,"lighting scalar");
            }
            int base=b[at+54]&255,count=b[at+55]&255,tile=b[at+56]&255,strength=b[at+57]&255;
            require(count>=1&&base+count<=256&&tile<8&&strength<=16&&u16(b,at+58)==0,"material attributes");
        }
        return new RegraphicsGeometry(b,w,h,n);
    }
    private int category(int at){
        int base=bytes[at+54]&255,count=bytes[at+55]&255,strength=bytes[at+57]&255;
        if(i32(bytes,at+8)>900000&&i32(bytes,at+20)>900000&&i32(bytes,at+32)>900000)return 0;
        if(base>=24&&base<32)return 2;
        if(base==32&&count==8)return strength>0?3:6;
        if(base==244)return 4;
        if(base==56)return 5;
        return 1;
    }
    int categoryFaces(int wanted){int n=0;for(int i=0;i<faces;i++)if(category(HEADER+ATLAS+i*FACE_BYTES)==wanted)n++;return n;}
    private static int pass(int category){return category==0?0:category==1?1:category<=3?2:3;}
    void vertices(FloatBuffer out){
        out.clear();int emitted=0;
        for(int p=0;p<4;p++){
            starts[p]=emitted;
            for(int i=0;i<faces;i++){
                int at=HEADER+ATLAS+i*FACE_BYTES,c=category(at);if(pass(c)!=p)continue;
                int base=bytes[at+54]&255,count=bytes[at+55]&255,tile=bytes[at+56]&255,strength=bytes[at+57]&255;
                for(int v=0;v<3;v++){
                    out.put(i32(bytes,at+v*12)).put(i32(bytes,at+v*12+4)).put(i32(bytes,at+v*12+8));
                    out.put((short)u16(bytes,at+36+v*4)).put((short)u16(bytes,at+38+v*4));
                    out.put(u16(bytes,at+48+v*2)/65280f);
                    out.put(base).put(count).put(tile).put(strength).put(c);emitted++;
                }
            }
            counts[p]=emitted-starts[p];
        }
        out.flip();
    }
}
