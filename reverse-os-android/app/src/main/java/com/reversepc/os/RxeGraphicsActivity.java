package com.reversepc.os;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.webkit.JavascriptInterface;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.TextView;
import android.widget.FrameLayout;
import org.json.JSONObject;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.HashMap;
import java.util.Locale;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicInteger;

/** Local RXE3 adapter. Ether Render X draws PRISMA; WebView supplies UI/audio. */
public final class RxeGraphicsActivity extends Activity {
    static final int PICK_AUDIO=7301;
    private final Handler ui=new Handler(Looper.getMainLooper());
    private final ExecutorService events=Executors.newSingleThreadExecutor();
    private final AtomicInteger pending=new AtomicInteger();
    private volatile boolean closed=false,foreground=true;
    private WebView web;
    private XRenderSurface xrender;
    private byte[] image;
    private String originHost;
    private GraphicsSessionStore session;
    private ValueCallback<Uri[]> chooser;
    static String identity(byte[] bytes)throws Exception{
        StringBuilder hex=new StringBuilder();for(byte b:MessageDigest.getInstance("SHA-256").digest(bytes))hex.append(String.format(Locale.ROOT,"%02x",b&255));return hex.toString();
    }
    @Override protected void onCreate(Bundle saved){
        super.onCreate(saved);getWindow().setNavigationBarColor(Color.BLACK);getWindow().setStatusBarColor(Color.BLACK);WorkbenchActivity.immersive(this);
        events.execute(()->{
            try{
                String path=getIntent().getStringExtra("path"),expected=getIntent().getStringExtra("identity");
                if(path==null||!"Aplicaciones".equals(WorkspaceFiles.parent(path))||!path.toLowerCase(Locale.ROOT).endsWith(".rxe"))throw new IOException("Selecciona un ejecutable de Aplicaciones");
                byte[] candidate=new WorkspaceFiles(getFilesDir()).read(path);
                if(expected==null||!identity(candidate).equals(expected))throw new IOException("El ejecutable cambió. Vuelve a abrirlo.");
                JSONObject metadata=new JSONObject(new String(NativeRuntime.inspectRxe(candidate),StandardCharsets.UTF_8));
                if(!"graphics".equals(metadata.optString("ui")))throw new IOException("El archivo no es una aplicación gráfica RXE");
                // Only the exact PRISMA executable bundled with this trusted
                // host may reuse an official predecessor's WebView origin. All
                // custom/imported RXE3 images keep hash-isolated browser data.
                String originIdentity=expected;
                if("org.reverse.prisma".equals(metadata.optString("app_id"))){
                    try(InputStream in=getAssets().open("native-apps/PRISMA.rxe")){
                        String official=identity(WorkbenchPrograms.read(in));
                        if(official.equals(expected)){
                            String savedOrigin=getSharedPreferences("workbench-programs",0)
                                .getString("prisma-ui-origin-sha",expected);
                            if(savedOrigin!=null&&savedOrigin.matches("[0-9a-f]{64}"))
                                originIdentity=savedOrigin;
                        }
                    }catch(Exception unavailable){/* Remain isolated by current SHA. */}
                }
                image=candidate;
                originHost=originIdentity.substring(0,32)+"."+originIdentity.substring(32)+".rxe.reverse.local";
                session=new GraphicsSessionStore(getApplicationContext(),image);
                ui.post(()->{if(!closed)openWeb();});
            }catch(Exception error){ui.post(()->showFailure(error.getMessage()));}
        });
    }
    private void showFailure(String message){if(closed)return;TextView text=new TextView(this);text.setText("No se pudo abrir el ejecutable\n\n"+message);text.setTextColor(Color.WHITE);text.setBackgroundColor(Color.BLACK);text.setPadding(40,50,40,40);setContentView(text);}
    private void openWeb(){
        xrender=new XRenderSurface(this,this::showFailure);
        web=new WebView(this);web.setBackgroundColor(Color.TRANSPARENT);WebSettings settings=web.getSettings();
        settings.setJavaScriptEnabled(true);settings.setDomStorageEnabled(true);settings.setMediaPlaybackRequiresUserGesture(true);
        settings.setAllowFileAccess(false);settings.setAllowContentAccess(true);settings.setAllowFileAccessFromFileURLs(false);settings.setAllowUniversalAccessFromFileURLs(false);
        settings.setMixedContentMode(WebSettings.MIXED_CONTENT_NEVER_ALLOW);settings.setSupportMultipleWindows(false);settings.setJavaScriptCanOpenWindowsAutomatically(false);
        web.addJavascriptInterface(new Bridge(),"ReverseGraphics");
        web.setWebViewClient(new WebViewClient(){
            @Override public boolean shouldOverrideUrlLoading(WebView view,WebResourceRequest request){return true;}
            @Override public WebResourceResponse shouldInterceptRequest(WebView view,WebResourceRequest request){
                Uri uri=request.getUrl();
                if(!"https".equals(uri.getScheme())||!originHost.equals(uri.getHost())||uri.getPort()!=-1||!"GET".equals(request.getMethod()))return denied();
                try{
                    String path=uri.getPath();if(path==null||path.equals("/"))path="/index.html";
                    byte[] bytes=NativeRuntime.graphicsAsset(image,path.substring(1).getBytes(StandardCharsets.UTF_8));
                    String mime=path.endsWith(".html")?"text/html":path.endsWith(".css")?"text/css":path.endsWith(".js")?"application/javascript":path.endsWith(".json")?"application/json":path.endsWith(".svg")?"image/svg+xml":path.endsWith(".png")?"image/png":"application/octet-stream";
                    HashMap<String,String> headers=new HashMap<>();headers.put("Cache-Control","no-store");headers.put("X-Content-Type-Options","nosniff");
                    headers.put("Content-Security-Policy","default-src 'none'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; media-src blob: data:; connect-src 'none'; frame-src 'none'; object-src 'none'; base-uri 'none'; form-action 'none'");
                    return new WebResourceResponse(mime,"UTF-8",200,"OK",headers,new ByteArrayInputStream(bytes));
                }catch(Exception error){return new WebResourceResponse("text/plain","UTF-8",404,"Not Found",new HashMap<>(),new ByteArrayInputStream(new byte[0]));}
            }
        });
        web.setWebChromeClient(new WebChromeClient(){
            @Override public boolean onShowFileChooser(WebView view,ValueCallback<Uri[]> callback,FileChooserParams params){
                if(chooser!=null)chooser.onReceiveValue(null);chooser=callback;
                try{startActivityForResult(new Intent(Intent.ACTION_OPEN_DOCUMENT).addCategory(Intent.CATEGORY_OPENABLE).setType("audio/*"),PICK_AUDIO);}
                catch(Exception error){chooser=null;callback.onReceiveValue(null);}return true;
            }
        });
        FrameLayout root=new FrameLayout(this);root.setBackgroundColor(Color.BLACK);
        root.addView(xrender,new FrameLayout.LayoutParams(-1,-1));root.addView(web,new FrameLayout.LayoutParams(-1,-1));
        setContentView(root);web.loadUrl("https://"+originHost+"/index.html");
    }
    WebView testingWebView(){return web;}
    private static WebResourceResponse denied(){return new WebResourceResponse("text/plain","UTF-8",403,"Forbidden",new HashMap<>(),new ByteArrayInputStream(new byte[0]));}
    public final class Bridge {
        @JavascriptInterface public boolean immersive(){return true;}
        @JavascriptInterface public String xRender(){return "ether-render-x-cuboids-v1";}
        @JavascriptInterface public void frame(float[] data){if(!closed&&foreground&&xrender!=null)xrender.submit(data);}
        @JavascriptInterface public String xRenderInfo(){return xrender==null?"{}":xrender.info();}
        @JavascriptInterface public void event(int serial,int run,int kind,int quality){
            if(closed||serial<1||run<1||kind<0||kind>3||quality<0||quality>150||(kind!=1&&quality!=0))return;
            if(pending.incrementAndGet()>64){pending.decrementAndGet();deliver(serial,run,null,"Demasiados eventos pendientes");return;}
            try{events.execute(()->{
                try{String result=session.event(kind,quality);deliver(serial,run,new JSONObject(result),null);}
                catch(Exception error){deliver(serial,run,null,error.getMessage());}
                finally{pending.decrementAndGet();}
            });}catch(java.util.concurrent.RejectedExecutionException closedQueue){pending.decrementAndGet();}
        }
    }
    private void deliver(int serial,int run,JSONObject value,String error){
        try{JSONObject data=new JSONObject().put("serial",serial).put("run",run).put("ok",error==null);if(error!=null)data.put("error",error);else data.put("state",value);
            final String script="window.dispatchEvent(new CustomEvent('reverse-score',{detail:"+data+"}));";
            ui.post(()->{if(!closed&&web!=null)web.evaluateJavascript(script,null);});
        }catch(Exception ignored){/* JSONObject only contains bounded native values. */}
    }
    @Override protected void onActivityResult(int request,int result,Intent data){super.onActivityResult(request,result,data);if(request==PICK_AUDIO){ValueCallback<Uri[]> callback=chooser;chooser=null;if(callback!=null)callback.onReceiveValue(result==RESULT_OK&&data!=null&&data.getData()!=null?new Uri[]{data.getData()}:null);}}
    @Override protected void onPause(){foreground=false;if(web!=null)web.evaluateJavascript("window.dispatchEvent(new Event('prisma-native-pause'));",ignored->{if(!foreground&&web!=null)web.onPause();});if(xrender!=null)xrender.onPause();super.onPause();}
    @Override protected void onResume(){super.onResume();foreground=true;WorkbenchActivity.immersive(this);if(xrender!=null)xrender.onResume();if(web!=null)web.onResume();}
    @Override public void onWindowFocusChanged(boolean focus){super.onWindowFocusChanged(focus);if(focus)WorkbenchActivity.immersive(this);else if(web!=null)web.evaluateJavascript("window.dispatchEvent(new Event('prisma-native-pause'));",null);}
    @Override protected void onDestroy(){closed=true;if(chooser!=null){chooser.onReceiveValue(null);chooser=null;}if(web!=null){web.removeJavascriptInterface("ReverseGraphics");web.destroy();web=null;}if(xrender!=null){xrender.release();xrender=null;}events.shutdown();super.onDestroy();}
}
