package com.reversepc.os;

import android.content.*;
import android.database.Cursor;
import android.database.MatrixCursor;
import android.net.Uri;
import android.os.ParcelFileDescriptor;
import android.provider.OpenableColumns;
import java.io.*;

/** Temporary read grants to a single staged APK, never to desktop files. */
public final class PackageContentProvider extends ContentProvider {
    public static File root(Context context){return new File(context.getCacheDir(),"install-packages");}
    public static Uri uri(Context context,String token){return new Uri.Builder().scheme("content").authority(context.getPackageName()+".packages").appendPath(token).build();}
    private File file(Uri uri)throws FileNotFoundException{
        try{
            if(!uri.getAuthority().equals(getContext().getPackageName()+".packages")||uri.getPathSegments().size()!=1)throw new FileNotFoundException("Paquete no disponible");
            return PackageStaging.resolve(root(getContext()),uri.getLastPathSegment());
        }catch(IOException e){throw new FileNotFoundException(e.getMessage());}
    }
    @Override public boolean onCreate(){return true;}
    @Override public String getType(Uri uri){return "application/vnd.android.package-archive";}
    @Override public ParcelFileDescriptor openFile(Uri uri,String mode)throws FileNotFoundException{
        if(!"r".equals(mode))throw new FileNotFoundException("Solo lectura");
        return ParcelFileDescriptor.open(file(uri),ParcelFileDescriptor.MODE_READ_ONLY);
    }
    @Override public Cursor query(Uri uri,String[] projection,String selection,String[] args,String sort){
        try{
            File f=file(uri);String[] columns=projection==null?new String[]{OpenableColumns.DISPLAY_NAME,OpenableColumns.SIZE}:projection;
            MatrixCursor result=new MatrixCursor(columns);Object[] row=new Object[columns.length];
            for(int i=0;i<columns.length;i++)if(columns[i].equals(OpenableColumns.DISPLAY_NAME))row[i]="Programa.apk";else if(columns[i].equals(OpenableColumns.SIZE))row[i]=f.length();
            result.addRow(row);return result;
        }catch(FileNotFoundException e){return null;}
    }
    @Override public Uri insert(Uri uri,ContentValues values){throw new UnsupportedOperationException();}
    @Override public int update(Uri uri,ContentValues values,String selection,String[] args){throw new UnsupportedOperationException();}
    @Override public int delete(Uri uri,String selection,String[] args){throw new UnsupportedOperationException();}
}
