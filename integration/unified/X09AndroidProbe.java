package com.reversepc.os;
import java.nio.file.*;import java.nio.charset.StandardCharsets;import java.util.*;
/** Runs the production Android transport against the real original JNI. */
public final class X09AndroidProbe {
 public static void main(String[] args)throws Exception{
  Path root=Path.of(args[0]);BbyqTextEngine.Backend backend=BbyqTextEngine.JNI;
  if(args.length>1)backend=new BbyqTextEngine.Backend(){
   public byte[] execute(byte[] s,String code)throws Exception{System.out.println("START XI "+code.substring(0,Math.min(code.length(),90)).replace('\n',' ') +" bytes="+s.length);byte[] b=NativeRuntime.execute(s,code);System.out.println("DONE XI");return b;}
   public byte[] executeRxe(byte[] s,byte[] p)throws Exception{System.out.println("START RXE "+BbyqTextEngine.hash(p)+" bytes="+s.length);byte[] b=NativeRuntime.executeRxe(s,p);System.out.println("DONE RXE");return b;}
   public byte[] compile(byte[] s,byte[] t){System.out.println("COMPILE "+new String(s,StandardCharsets.UTF_8));return NativeRuntime.compileRxe(s,t);}
   public byte[] initialize(){return NativeRuntime.initialize();}
  };
  BbyqX09Engine engine=new BbyqX09Engine(n->Files.newInputStream(root.resolve(n)),backend);byte[] seed=engine.seed();String before=BbyqTextEngine.hash(seed);int cases=0;
  String[][] prompts={{"@lex money","money","13250542-n"},{"@lex dinero","dinero"},{"edificio incluye libro?","edificio","libro"},{"cuarto contiene llave?","cuarto","llave"},{"calcula 17 + 25","El resultado es 42."},{"consulta: nomasir caballo","viajeros asociados","clason-F004-B"},{"Escribe y ejecuta en XI un programa que sume 637 y 284.","921"}};
  for(String[] p:prompts){if(args.length>1&&!p[0].startsWith("Escribe"))continue;BbyqTextEngine.Delivery r=engine.turn(seed,p[0],p[0].equals("@lex money")?2:1,null);for(int i=1;i<p.length;i++)if(!r.text.contains(p[i]))throw new AssertionError(p[0]+": "+r.text);if(p[0].startsWith("Escribe")&&(!r.executed||!r.verified))throw new AssertionError("Unverified dispatch");if(!before.equals(BbyqTextEngine.hash(seed)))throw new AssertionError("Seed mutated");System.out.println("PASS "+p[0]+" => "+r.text.substring(0,Math.min(160,r.text.length())));cases++;}
  byte[] state=engine.turn(seed,"mi nombre es Aurora",1,null).state;
  state=engine.turn(state,"@lex dinero",1,null).state;
  BbyqTextEngine.Delivery recall=engine.turn(state,"como me llamo",1,null);
  if(!recall.text.contains("Aurora"))throw new AssertionError("Personal memory lost through dictionary query");
  System.out.println("RETENTION_QUERY "+recall.text);
  System.out.println("X09_PRODUCTION_ANDROID_TRANSPORT_PASS cases="+cases+" seed_preserved=true dictionary_and_campaign=true");
 }
}
