package com.reversepc.os;

import java.io.*;
import java.nio.file.Files;
import java.util.UUID;

/** Bounded, private APK spool. No workspace document or RVPC2 is exposed. */
public final class PackageStaging {
    public static final long MAX_APK=512L*1024*1024;
    public static File stage(File root,InputStream input)throws IOException{return stage(root,input,MAX_APK);}
    static File stage(File root,InputStream input,long limit)throws IOException{
        if(!root.isDirectory()&&!root.mkdirs())throw new IOException("No se pudo preparar el instalador");
        File target=new File(root,UUID.randomUUID()+".apk");boolean complete=false;
        try{
            try(FileOutputStream out=new FileOutputStream(target)){
                byte[] buffer=new byte[65536];long total=0;int n;
                while((n=input.read(buffer))!=-1){total+=n;if(total>limit)throw new IOException("El APK supera el límite de 512 MiB");out.write(buffer,0,n);}
                if(total==0)throw new IOException("El APK está vacío");out.getFD().sync();
            }
            complete=true;return target;
        }finally{if(!complete)Files.deleteIfExists(target.toPath());}
    }
    public static File resolve(File root,String token)throws IOException{
        if(token==null||!token.matches("[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}\\.apk"))throw new FileNotFoundException("Paquete no disponible");
        File file=new File(root,token);
        if(Files.isSymbolicLink(file.toPath())||!file.getCanonicalFile().getParentFile().equals(root.getCanonicalFile())||!file.isFile())throw new FileNotFoundException("Paquete no disponible");
        return file;
    }
}
