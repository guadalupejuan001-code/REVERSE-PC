package com.reversepc.os;
import java.nio.FloatBuffer;
import java.nio.file.Files;
import java.nio.file.Path;
public final class RegraphicsGeometryTest {
 static int checks;
 static void check(boolean ok,String why){if(!ok)throw new AssertionError(why);checks++;}
 static void reject(byte[] bytes){try{RegraphicsGeometry.decodeOwned(bytes);throw new AssertionError("malformed packet accepted");}catch(IllegalArgumentException expected){checks++;}}
 public static void main(String[] args)throws Exception{
  byte[] packet=Files.readAllBytes(Path.of(args[0]));RegraphicsGeometry g=RegraphicsGeometry.decodeOwned(packet);
  check(g.faces>300&&g.faces<4096,"real XI scene face budget");FloatBuffer v=FloatBuffer.allocate(g.faces*3*11);g.vertices(v);
  check(v.remaining()==g.faces*3*11,"every XI vertex is transported once");int sum=0;for(int n:g.counts)sum+=n;check(sum==g.faces*3,"all render passes cover exact vertices");
  reject(null);reject(new byte[16]);byte[] bad=packet.clone();bad[0]='?';reject(bad);bad=packet.clone();bad[16]=16;reject(bad);
  bad=packet.clone();bad[2064+55]=0;reject(bad);bad=packet.clone();bad[2064+58]=1;reject(bad);
  bad=packet.clone();for(int i=0;i<4;i++)bad[2064+8+i]=0;reject(bad);
  bad=packet.clone();bad[12]=(byte)255;bad[13]=(byte)255;reject(bad);
  System.out.println("REGRAPHICS_GEOMETRY_PASS checks="+checks+" faces="+g.faces);
 }
}
