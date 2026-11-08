package com.reversepc.os;

import java.nio.FloatBuffer;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.Arrays;
import x.gpu.virtual.CompactTriangleStream;

/** Validated XI XFG4 triangles. This adapter never creates world geometry. */
final class RegraphicsGeometry {
    static final int HEADER=16,ATLAS=2048,FACE_BYTES=60,MAX_FACES=8192,FLOATS=11;
    final byte[] bytes;
    private final ByteBuffer source;
    final int width,height,faces;
    final int[] starts=new int[4],counts=new int[4];
    private final byte[] categories,passes;
    private final int[] categoryCounts=new int[12];
    private int lampFace=-1;
    private int[] opaqueRuns=new int[16];
    private int opaqueRunCount;
    private RegraphicsGeometry(byte[] bytes,ByteBuffer source,int width,int height,int faces){
        this.bytes=bytes;this.source=source;this.width=width;this.height=height;this.faces=faces;
        categories=new byte[faces];passes=new byte[faces];
        int opaqueVertices=0;
        for(int i=0;i<faces;i++){
            int at=HEADER+ATLAS+i*FACE_BYTES,c=category(at);
            categories[i]=(byte)c;passes[i]=(byte)pass(c);categoryCounts[c]++;
            if(c==10&&lampFace<0)lampFace=i;
            if(passes[i]==1){
                int base=byteAt(at+54)&255,kind=(base>=9&&base<24)||(base>=40&&base<56)?1:0;
                opaqueVertices+=3;
                if(opaqueRunCount>0&&(opaqueRuns[opaqueRunCount-1]&1)==kind)opaqueRuns[opaqueRunCount-1]=(opaqueVertices<<1)|kind;
                else{
                    if(opaqueRunCount==opaqueRuns.length)opaqueRuns=Arrays.copyOf(opaqueRuns,opaqueRuns.length*2);
                    opaqueRuns[opaqueRunCount++]=(opaqueVertices<<1)|kind;
                }
            }
        }
    }
    static int u16(byte[] b,int n){return (b[n]&255)|((b[n+1]&255)<<8);}
    static int i32(byte[] b,int n){return (b[n]&255)|((b[n+1]&255)<<8)|((b[n+2]&255)<<16)|(b[n+3]<<24);}
    static void require(boolean ok,String why){if(!ok)throw new IllegalArgumentException("REgraphics XFG4: "+why);}
    ByteBuffer qssdSourceView(){return source.asReadOnlyBuffer().order(ByteOrder.LITTLE_ENDIAN);}
    byte byteAt(int at){return source.get(at);}
    void copyBytes(int from,byte[] target,int offset,int length){
        ByteBuffer view=source.duplicate();view.position(from);view.limit(from+length);view.get(target,offset,length);
    }
    private int word(int at){return source.getInt(at);}
    private int half(int at){return source.getShort(at)&65535;}
    static RegraphicsGeometry decodeOwned(byte[] b){
        require(b!=null,"truncated packet");
        return decode(ByteBuffer.wrap(b).order(ByteOrder.LITTLE_ENDIAN),b);
    }
    static RegraphicsGeometry decodeShared(ByteBuffer b){
        require(b!=null&&b.isReadOnly()&&b.isDirect()&&b.position()==0,"shared immutable projection");
        return decode(b.order(ByteOrder.LITTLE_ENDIAN),null);
    }
    private static RegraphicsGeometry decode(ByteBuffer b,byte[] owned){
        require(b.limit()>=HEADER+ATLAS,"truncated packet");
        require(b.get(0)=='X'&&b.get(1)=='F'&&b.get(2)=='G'&&b.get(3)=='4',"signature");
        int w=b.getShort(4)&65535,h=b.getShort(6)&65535,n=b.getInt(12);
        require(w==3840&&h==2160&&b.getInt(8)==4,"projection revision");
        require(n>=0&&n<=MAX_FACES&&b.limit()==HEADER+ATLAS+n*FACE_BYTES,"face budget or length");
        for(int i=HEADER;i<HEADER+ATLAS;i++)require((b.get(i)&255)<16,"texture nibble");
        for(int i=0;i<n;i++){
            int at=HEADER+ATLAS+i*FACE_BYTES;
            for(int v=0;v<3;v++){
                int x=b.getInt(at+v*12),y=b.getInt(at+v*12+4),z=b.getInt(at+v*12+8);
                require(Math.abs((long)x)<=100_000_000&&Math.abs((long)y)<=100_000_000&&z>0&&z<=1_000_000,"vertex bounds");
                require((b.getShort(at+48+v*2)&65535)<=65280,"lighting scalar");
            }
            int base=b.get(at+54)&255,count=b.get(at+55)&255,tile=b.get(at+56)&255,strength=b.get(at+57)&255;
            require(count>=1&&base+count<=256&&tile<8&&strength<=16&&(b.getShort(at+58)&65535)==0,"material attributes");
        }
        return new RegraphicsGeometry(owned,b,w,h,n);
    }
    private int category(int at){
        int base=byteAt(at+54)&255,count=byteAt(at+55)&255,strength=byteAt(at+57)&255;
        if(word(at+8)>900000&&word(at+20)>900000&&word(at+32)>900000)return 0;
        if(base==57&&count==1)return 10;
        if(base==58&&count==2)return 11;
        if((base==223||base==221)&&count==1)return 9;
        if(base==14&&count==3&&strength==1)return 8;
        if(base>=24&&base<32)return 2;
        if(base==32&&count==8)return strength>0?3:6;
        if(base==244)return strength>0?4:7;
        if(base==56)return 5;
        return 1;
    }
    int categoryFaces(int wanted){return wanted>=0&&wanted<categoryCounts.length?categoryCounts[wanted]:0;}
    int opaqueRunCount(){return opaqueRunCount;}
    int opaqueRunEnd(int run){return opaqueRuns[run]>>>1;}
    int opaqueRunShader(int run){return (opaqueRuns[run]&1)==0?0:2;}
    void compact(CompactTriangleStream stream){
        stream.update(source,categories,passes);
        System.arraycopy(stream.starts,0,starts,0,4);System.arraycopy(stream.counts,0,counts,0,4);
    }
    private static int pass(int category){return category==10?-1:category==0?0:category==1||category==8?1:category==2||category==3||category==9?2:3;}
    boolean lightFrame(float[] frame){
        if(lampFace>=0){int at=HEADER+ATLAS+lampFace*FACE_BYTES;
            for(int v=0;v<2;v++){float z=word(at+v*12+8);frame[v*3]=(word(at+v*12)-width*.5f)*z/(width*.85f)*.01f;frame[v*3+1]=(height*.5f-word(at+v*12+4))*z/(width*.85f)*.01f;frame[v*3+2]=z*.01f;}return true;
        }return false;
    }
    private int depth(int face){int at=HEADER+ATLAS+face*FACE_BYTES;return word(at+8)+word(at+20)+word(at+32);}
    private void sort(int[] ids,int low,int high){int l=low,r=high,pivot=depth(ids[(low+high)>>>1]);while(l<=r){while(depth(ids[l])>pivot)l++;while(depth(ids[r])<pivot)r--;if(l<=r){int t=ids[l];ids[l++]=ids[r];ids[r--]=t;}}if(low<r)sort(ids,low,r);if(l<high)sort(ids,l,high);}
    void vertices(FloatBuffer out){
        out.clear();int emitted=0;
        for(int p=0;p<4;p++){
            starts[p]=emitted;
            int[] order=null;int total=faces;
            if(p==2){order=new int[faces];total=0;for(int i=0;i<faces;i++)if(pass(category(HEADER+ATLAS+i*FACE_BYTES))==2)order[total++]=i;if(total>1)sort(order,0,total-1);}
            for(int f=0;f<total;f++){
                int i=order==null?f:order[f];int at=HEADER+ATLAS+i*FACE_BYTES,c=category(at);if(pass(c)!=p)continue;
                int base=byteAt(at+54)&255,count=byteAt(at+55)&255,tile=byteAt(at+56)&255,strength=byteAt(at+57)&255;
                for(int v=0;v<3;v++){
                    out.put(word(at+v*12)).put(word(at+v*12+4)).put(word(at+v*12+8));
                    out.put((short)half(at+36+v*4)).put((short)half(at+38+v*4));
                    out.put(half(at+48+v*2)/65280f);
                    out.put(base).put(count).put(tile).put(strength).put(c);emitted++;
                }
            }
            counts[p]=emitted-starts[p];
        }
        out.flip();
    }
}
