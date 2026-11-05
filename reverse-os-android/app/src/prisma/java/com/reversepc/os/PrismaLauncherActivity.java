package com.reversepc.os;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.TextView;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import org.json.JSONObject;

/** Standalone game entry; retains the original XI runtime and native X Render. */
public final class PrismaLauncherActivity extends Activity {
    @Override public void onCreate(Bundle saved) {
        super.onCreate(saved);WorkbenchActivity.immersive(this);
        TextView loading=new TextView(this);loading.setText("PRISMA");loading.setTextSize(32);
        loading.setTextColor(0xff81ffe0);loading.setGravity(17);loading.setBackgroundColor(0xff050916);setContentView(loading);
        new Thread(()->{
            try(InputStream in=getAssets().open("native-apps/PRISMA.rxe")){
                byte[] image=WorkbenchPrograms.read(in);
                JSONObject info=new JSONObject(new String(NativeRuntime.inspectRxe(image),StandardCharsets.UTF_8));
                if(!"org.reverse.prisma".equals(info.optString("app_id"))||!"3.0.0".equals(info.optString("app_version")))throw new Exception("Paquete de PRISMA incompatible");
                String identity=RxeGraphicsActivity.identity(image),path="Aplicaciones/PRISMA.rxe";
                new WorkspaceFiles(getFilesDir()).write(path,image,true);
                android.content.SharedPreferences prefs=getSharedPreferences("workbench-programs",0);
                if(!prefs.contains("prisma-ui-origin-sha")&&!prefs.edit().putString("prisma-ui-origin-sha",identity).commit())throw new Exception("No se pudo preparar la partida");
                runOnUiThread(()->{if(isFinishing()||isDestroyed())return;startActivity(new Intent(this,RxeGraphicsActivity.class).putExtra("path",path).putExtra("identity",identity));finish();});
            }catch(Exception error){runOnUiThread(()->loading.setText("No se pudo abrir PRISMA\n"+error.getMessage()));}
        },"prisma-open").start();
    }
}
