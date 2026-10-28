package com.reversepc.os;

import android.content.Context;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;
import java.nio.channels.FileLock;
import java.nio.channels.OverlappingFileLockException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;

/** One RVPC2 authority for each exact RXE3 image. A turn commits before its UI ack. */
final class GraphicsSessionStore {
    private final File directory,stateFile;
    private final byte[] image;
    GraphicsSessionStore(Context context,byte[] executable)throws Exception{
        image=executable;
        directory=new File(new File(context.getFilesDir(),"graphics-apps"),RxeGraphicsActivity.identity(image));
        if(!directory.isDirectory()&&!directory.mkdirs())throw new IOException("No se pudo abrir la memoria gráfica");
        stateFile=new File(directory,"session.rvp");
    }
    String event(int kind,int quality)throws Exception{
        try(FileChannel channel=FileChannel.open(new File(directory,"writer.lock").toPath(),StandardOpenOption.CREATE,StandardOpenOption.WRITE)){
            FileLock lock;
            try{lock=channel.tryLock();}catch(OverlappingFileLockException error){throw new IOException("Este ejecutable está activo en otra ventana");}
            if(lock==null)throw new IOException("Este ejecutable está activo en otra ventana");
            try(FileLock held=lock){
                if(stateFile.exists()&&(Files.isSymbolicLink(stateFile.toPath())||stateFile.length()>32L*1024*1024))throw new IOException("Memoria gráfica fuera de presupuesto");
                byte[] before=stateFile.exists()?Files.readAllBytes(stateFile.toPath()):new byte[0];
                ResultPacket result=ResultPacket.parse(NativeRuntime.graphicsTurn(before,image,kind,quality));
                File pending=new File(directory,"session.pending");
                try{
                    try(FileOutputStream output=new FileOutputStream(pending)){output.write(result.state);output.getFD().sync();}
                    Files.move(pending.toPath(),stateFile.toPath(),StandardCopyOption.ATOMIC_MOVE,StandardCopyOption.REPLACE_EXISTING);
                }finally{try{Files.deleteIfExists(pending.toPath());}catch(IOException cleanup){android.util.Log.w("GraphicsSession","Pending cleanup failed",cleanup);}}
                return result.output;
            }
        }
    }
}
