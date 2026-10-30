package com.reversepc.os;
import java.nio.file.*;import java.util.*;
public final class X09MigrationProbe {
 public static void main(String[] args)throws Exception{
  Path assets=Path.of(args[0]);BbyqX09Engine engine=new BbyqX09Engine(n->Files.newInputStream(assets.resolve("bbyq-x09").resolve(n)),BbyqTextEngine.JNI);
  byte[] capsule=Files.readAllBytes(assets.resolve("native-apps/BBY-Q.rxe")),old=NativeRuntime.appSeed(capsule);String before=BbyqTextEngine.hash(old);
  Properties p=new Properties();try(var in=Files.newBufferedReader(assets.resolve("bbyq-interface/x07/engine.properties"))){p.load(in);}Map<String,String> roles=new HashMap<>();for(String k:p.stringPropertyNames())if(k.startsWith("role."))roles.put(k.substring(5),p.getProperty(k));
  BbyqTextEngine legacy=new BbyqTextEngine(BbyqTextEngine.JNI,n->Files.readAllBytes(assets.resolve("bbyq-interface/x07").resolve(n)),p.getProperty("code_sha256"),roles);
  byte[] learned=legacy.turn(old,"mi nombre es Aurora",1,null).state;System.out.println("X07_PERSONAL_STATE_READY");
  byte[] next=engine.migrate(learned);if(!before.equals(BbyqTextEngine.hash(old)))throw new AssertionError("Original seed changed");
  BbyqTextEngine.Delivery recall=engine.turn(next,"como me llamo",1,null);if(!recall.text.contains("Aurora"))throw new AssertionError("Personal definition lost: "+recall.text);
  BbyqTextEngine.Delivery book=engine.turn(recall.state,"consulta: nomasir caballo",1,null);if(!book.text.contains("viajeros asociados"))throw new AssertionError("Book missing");
  BbyqTextEngine.Delivery c=engine.turn(book.state,"edificio incluye libro?",1,null);if(!c.text.contains("vía sala"))throw new AssertionError("Campaign absent");
  byte[] repeated=engine.migrate(c.state);if(!Arrays.equals(c.state,repeated))throw new AssertionError("Migration was not idempotent");
  try{engine.turn(next,"\ud800",1,null);throw new AssertionError("Malformed UTF16 accepted");}catch(java.nio.charset.CharacterCodingException expected){}
  try{engine.turn(next,"a".repeat(16385),1,null);throw new AssertionError("Size accepted");}catch(java.io.IOException expected){}
  System.out.println("X07_TO_X09_MIGRATION_PASS personal_memory=true book=true campaign=true original_preserved=true idempotent=true invalid_input_rejected=true");
 }
}
