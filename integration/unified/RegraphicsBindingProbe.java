package com.reversepc.os;
import java.nio.file.*;import java.util.*;
public final class RegraphicsBindingProbe {
 static final String H="#!reverse-pc-machine-v1\n";
 public static void main(String[] args)throws Exception{
  Path root=Path.of(args[0]);String world=Files.readString(root.resolve("world.xi")),drive=Files.readString(root.resolve("drive.xi")),render=Files.readString(root.resolve("render.xi"));
  byte[] old=ResultPacket.parse(NativeRuntime.execute(NativeRuntime.initialize(),world)).state;
  byte[] fresh=ResultPacket.parse(RenderRuntime.execute(RenderRuntime.initialize(),world)).state;if(!Arrays.equals(old,fresh))throw new AssertionError("World binding changed");
  for(int i=0;i<12;i++){String program=H+"store8 128 1\nstore8 129 0\nstore8 130 "+(i<5?0:1)+"\nstore8 131 0\nstore8 132 "+(i==0?1:0)+"\n"+drive.substring(H.length());ResultPacket a=ResultPacket.parse(NativeRuntime.execute(old,program)),b=ResultPacket.parse(RenderRuntime.execute(fresh,program));if(!a.output.equals(b.output)||!Arrays.equals(a.state,b.state))throw new AssertionError("Physics changed");old=a.state;fresh=b.state;}
  for(int camera=0;camera<3;camera++){String program=H+"store8 200 2\nstore8 201 "+camera+"\nstore8 202 1\n"+render.substring(H.length());ResultPacket a=ResultPacket.parseBinary(NativeRuntime.execute(old,program)),b=ResultPacket.parseBinary(RenderRuntime.execute(fresh,program));if(!Arrays.equals(a.outputBytes,b.outputBytes))throw new AssertionError("Frame changed");System.out.println("REGRAPHICS_CAMERA_PASS "+camera+" bytes="+b.outputBytes.length);}
  System.out.println("REGRAPHICS_BINDING_PASS physics_steps=12 exact_cameras=3");
 }
}
