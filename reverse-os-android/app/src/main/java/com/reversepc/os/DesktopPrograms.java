package com.reversepc.os;

import android.content.*;
import android.content.pm.*;
import java.io.*;
import java.nio.ByteBuffer;
import java.nio.charset.*;
import java.util.*;

/** Catalog only: XI runs in the original runtime; Android owns APK execution. */
public final class DesktopPrograms {
    public static final class Entry {
        public final String id,title,xi;public final ComponentName component;public final boolean system;
        Entry(String id,String title,String xi,ComponentName component,boolean system){this.id=id;this.title=title;this.xi=xi;this.component=component;this.system=system;}
        public boolean nativeXi(){return xi!=null;}
    }
    public static List<Entry> catalog(Context context,SessionStore store){
        ArrayList<Entry> result=new ArrayList<>();
        if(store!=null)for(String name:store.listPrograms())result.add(new Entry("xi:"+name,name.substring(0,name.length()-3),name,null,false));
        PackageManager pm=context.getPackageManager();Intent query=new Intent(Intent.ACTION_MAIN);query.addCategory(Intent.CATEGORY_LAUNCHER);
        HashSet<String> seen=new HashSet<>();
        for(ResolveInfo app:pm.queryIntentActivities(query,0)){
            if(app.activityInfo.packageName.equals(context.getPackageName()))continue;
            ComponentName component=new ComponentName(app.activityInfo.packageName,app.activityInfo.name);String id="apk:"+component.flattenToString();
            if(seen.add(id))result.add(new Entry(id,app.loadLabel(pm).toString(),null,component,(app.activityInfo.applicationInfo.flags&ApplicationInfo.FLAG_SYSTEM)!=0));
        }
        result.sort(Comparator.comparing((Entry p)->!p.nativeXi()).thenComparing(p->p.title.toLowerCase(Locale.ROOT)).thenComparing(p->p.id));return result;
    }
    public static String readXi(InputStream input)throws IOException{
        ByteArrayOutputStream bytes=new ByteArrayOutputStream();byte[] buffer=new byte[8192];int n;
        while((n=input.read(buffer))!=-1){if(bytes.size()+n>WorkspaceFiles.MAX_TEXT)throw new IOException("El programa XI supera 256 KiB");bytes.write(buffer,0,n);}
        try{
            String text=StandardCharsets.UTF_8.newDecoder().onMalformedInput(CodingErrorAction.REPORT).onUnmappableCharacter(CodingErrorAction.REPORT).decode(ByteBuffer.wrap(bytes.toByteArray())).toString();
            if(text.trim().isEmpty()||text.indexOf('\0')>=0)throw new IOException("El programa debe contener texto XI");return text;
        }catch(CharacterCodingException e){throw new IOException("El programa debe usar texto UTF-8",e);}
    }
}
