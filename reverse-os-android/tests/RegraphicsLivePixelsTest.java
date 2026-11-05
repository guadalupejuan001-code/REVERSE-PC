package com.reversepc.os;
import java.util.Arrays;
public final class RegraphicsLivePixelsTest {
    static void check(boolean ok,String why){if(!ok)throw new AssertionError(why);}
    static void rejects(Runnable r){try{r.run();}catch(IllegalArgumentException good){return;}throw new AssertionError("malformed live pixels accepted");}
    static void put(byte[] b,int at,int value,int count){for(int i=0;i<count;i++)b[at+i]=(byte)(value>>>(8*i));}
    public static void main(String[] args){
        int[] palette=new int[256];for(int i=0;i<256;i++)palette[i]=i*65793;
        for(int stride:new int[]{4,2,1}){
            int w=stride==4?320:stride==2?480:640,h=w*9/16,n=w*h;
            byte[] data=new byte[16+n];data[0]='X';data[1]='F';data[2]='B';data[3]='5';
            put(data,4,w,2);put(data,6,h,2);put(data,8,5,4);put(data,12,n,4);
            data[16+w+3]=(byte)42;
            RegraphicsFrame f=RegraphicsFrame.decodeLiveNative(data,stride,palette);
            int[] pixels=new int[n];f.present(pixels,w,h);
            check(pixels[w+3]==0xff2a2a2a&&f.revision==5&&f.stride==stride,"exact native live presentation");
            data[16+w+3]=0;f.present(pixels,w,h);check(pixels[w+3]==0xff2a2a2a,"untrusted bytes are isolated");
            rejects(()->RegraphicsFrame.decodeLiveNative(Arrays.copyOf(data,data.length-1),stride,palette));
            rejects(()->RegraphicsFrame.decodeNative4K(data,palette));
            rejects(()->RegraphicsFrame.decodeLiveNative(data,stride==1?2:1,palette));
            byte[] corrupt=data.clone();corrupt[12]++;rejects(()->RegraphicsFrame.decodeLiveNative(corrupt,stride,palette));
        }
        System.out.println("REGRAPHICS_LIVE_PIXELS_PASS resolutions=3 strictTransport=true");
    }
}
