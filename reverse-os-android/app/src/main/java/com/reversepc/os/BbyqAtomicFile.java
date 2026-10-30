package com.reversepc.os;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

/** Caller holds the existing per-session lock. A failed write retains the old
 * state/history packet; cleanup never turns a completed commit into failure. */
public final class BbyqAtomicFile {
    private BbyqAtomicFile(){}
    public static void write(File record,byte[] bytes)throws IOException{
        File parent=record.getParentFile();if(!parent.isDirectory()&&!parent.mkdirs())throw new IOException("No se pudo abrir la memoria");
        File temporary=new File(parent,record.getName()+".pending");boolean committed=false;
        try{try(FileOutputStream out=new FileOutputStream(temporary)){out.write(bytes);out.getFD().sync();}
            Files.move(temporary.toPath(),record.toPath(),StandardCopyOption.ATOMIC_MOVE,StandardCopyOption.REPLACE_EXISTING);committed=true;
        }finally{try{Files.deleteIfExists(temporary.toPath());}catch(IOException cleanup){if(!committed)throw cleanup;}}
    }
}
