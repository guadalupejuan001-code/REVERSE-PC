package com.reversepc.os;
import java.util.Arrays;
public final class RegraphicsNative4KTest {
 private static void check(boolean ok,String why){if(!ok)throw new AssertionError(why);}
 private static void rejects(Runnable r,String why){boolean failed=false;try{r.run();}catch(IllegalArgumentException e){failed=true;}check(failed,why);}
 public static void main(String[] args){
  final int w=3840,h=2160,count=w*h;
  byte[] raw=new byte[16+count];
  raw[0]='X';raw[1]='F';raw[2]='B';raw[3]='5';
  raw[4]=(byte)(w&255);raw[5]=(byte)(w>>8);
  raw[6]=(byte)(h&255);raw[7]=(byte)(h>>8);
  raw[8]=5;
  raw[12]=(byte)count;raw[13]=(byte)(count>>8);raw[14]=(byte)(count>>16);raw[15]=(byte)(count>>24);
  raw[16+32*w+200]=(byte)42;
  int[] palette=new int[256];for(int i=0;i<256;i++)palette[i]=i*65793;
  RegraphicsFrame decoded=RegraphicsFrame.decodeNative4K(raw,palette);
  int[] pixels=new int[count];decoded.present(pixels,w,h);
  check(decoded.revision==5&&decoded.width==3840&&decoded.height==2160,"native frame dimensions");
  check(pixels[32*w+200]==0xff2a2a2a,"exact native pixel color");
  check(pixels[0]==0xff000000,"unmodified background");
  raw[16+32*w+200]=0;
  palette[42]=0;
  decoded.present(pixels,w,h);
  check(pixels[32*w+200]==0xff2a2a2a,"immutable validated frame");
  rejects(()->decoded.present(new int[count],1920,1080),"fake rescale must fail");
  byte[] wrong=Arrays.copyOf(raw,raw.length);wrong[8]=4;
  final byte[] wrongRevision=wrong;
  rejects(()->RegraphicsFrame.decodeNative4K(wrongRevision,new int[256]),"invalid revision must fail");
  wrong=Arrays.copyOf(raw,raw.length-1);
  final byte[] shortRaw=wrong;
  rejects(()->RegraphicsFrame.decodeNative4K(shortRaw,new int[256]),"truncated 4K must fail");
  System.out.println("REGRAPHICS_NATIVE_4K_JAVA_PASS exactPixels="+count);
 }
}