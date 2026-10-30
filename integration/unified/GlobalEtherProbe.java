package com.reversepc.os;
import java.nio.file.*;
import java.nio.charset.StandardCharsets;
import java.util.HexFormat;
public final class GlobalEtherProbe {
 public static void main(String[] args)throws Exception{
  Path root=Path.of(args[0]);byte[] bytes=Files.readAllBytes(root.resolve("global.bin"));
  String[] seals=Files.readString(root.resolve("global-seals.txt")).trim().split("\\s+");
  LaplaceGlobalCompiler.Compiled c=LaplaceGlobalCompiler.compileEncoded(bytes,seals[0],seals[1],Files.readString(Path.of(args[1])));
  ResultPacket out=ResultPacket.parse(NativeRuntime.execute(NativeRuntime.initialize(),c.program));
  Files.writeString(root.resolve("global-output.txt"),out.output);
  if(c.records!=684||!out.output.contains("\"hex\":\""+HexFormat.of().formatHex(bytes)+"\"")||!NativeRuntime.inspect(out.state).contains("\"active_qubits\":0"))throw new AssertionError("Global native roundtrip differs");
  System.out.println("GLOBAL_ANDROID_XI_PASS records="+c.records+" bytes="+bytes.length+" program_bytes="+c.program.getBytes(StandardCharsets.UTF_8).length+" exact_roundtrip=true qubits=0");
 }
}
