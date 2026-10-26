package com.reversepc.os;
import java.io.*;
import java.nio.file.*;
import java.util.*;

public final class PackageStagingTest {
 interface Work {void run()throws Exception;}
 static int checks;
 static void yes(boolean test){if(!test)throw new AssertionError("check "+checks);checks++;}
 static void reject(Work work)throws Exception{try{work.run();}catch(IOException e){checks++;return;}throw new AssertionError("invalid package accepted");}
 public static void main(String[] args)throws Exception{
  File root=Files.createTempDirectory("reverse-package-tests").toFile();byte[] input=new byte[65537];new Random(42).nextBytes(input);
  File staged=PackageStaging.stage(root,new ByteArrayInputStream(input),input.length);
  yes(Arrays.equals(input,Files.readAllBytes(staged.toPath())));yes(PackageStaging.resolve(root,staged.getName()).equals(staged));
  reject(()->PackageStaging.stage(root,new ByteArrayInputStream(input),100));yes(root.list().length==1);
  reject(()->PackageStaging.stage(root,new ByteArrayInputStream(new byte[0]),100));yes(root.list().length==1);
  reject(()->PackageStaging.resolve(root,"../session.rvp"));reject(()->PackageStaging.resolve(root,"session.rvp"));
  reject(()->PackageStaging.resolve(root,"00000000-0000-0000-0000-000000000000.apk"));
  File secret=File.createTempFile("reverse-private",".rvp");Path link=new File(root,"11111111-1111-1111-1111-111111111111.apk").toPath();Files.createSymbolicLink(link,secret.toPath());reject(()->PackageStaging.resolve(root,link.getFileName().toString()));
  reject(()->PackageStaging.stage(root,new InputStream(){int count;public int read()throws IOException{if(count++>30)throw new IOException("broken source");return 42;}},1000));yes(root.list().length==2);
  System.out.println("PACKAGE_STAGING_PASS checks="+checks+" bounded_stream=true failed_copies_removed=true traversal_and_links_rejected=true");
 }
}
