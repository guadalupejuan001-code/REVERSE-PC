package com.reversepc.os;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.net.Uri;
import android.net.http.SslError;
import android.os.Bundle;
import android.view.Gravity;
import android.view.inputmethod.EditorInfo;
import android.webkit.ClientCertRequest;
import android.webkit.CookieManager;
import android.webkit.GeolocationPermissions;
import android.webkit.HttpAuthHandler;
import android.webkit.PermissionRequest;
import android.webkit.RenderProcessGoneDetail;
import android.webkit.SafeBrowsingResponse;
import android.webkit.SslErrorHandler;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebStorage;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;
import java.io.ByteArrayInputStream;

/**
 * REexplorer — native REVERSE browser UI with the maintained Android WebView
 * rendering engine. Not a new TLS stack, not an invented Chromium replacement.
 *
 * Independent :reexplorer process, distinct WebView data directory, NO bridge,
 * NO access to REVERSE's privileged reverse.local WebView, no background scraping.
 * Pages are never inspected or sent to BBY Q / Ether.
 */
public final class ReexplorerActivity extends Activity {
    static final String EXTRA_URL="com.reversepc.os.reexplorer.URL";
    private static final int INK=Color.rgb(231,236,236);
    private static final int MUTED=Color.rgb(154,170,171);
    private static final int PANEL=Color.rgb(24,29,32);
    private static final int BACKGROUND=Color.rgb(13,17,20);
    private static boolean dataDirectoryReady=false;
    private WebView page;
    private EditText address;
    private TextView status;
    private ProgressBar progress;
    private ReexplorerQuantumCore quantum;
    private boolean rendererGone;
    private String lastHost;

    @Override protected void onCreate(Bundle state){
        super.onCreate(state);
        // This MUST run before any WebView/WebKit access in this process.
        if(!dataDirectoryReady){WebView.setDataDirectorySuffix("reexplorer");dataDirectoryReady=true;}
        WebView.setWebContentsDebuggingEnabled(false);
        getWindow().setStatusBarColor(BACKGROUND);
        getWindow().setNavigationBarColor(BACKGROUND);
        LinearLayout root=new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(BACKGROUND);
        root.setPadding(dp(8),dp(6),dp(8),dp(4));

        LinearLayout heading=new LinearLayout(this);
        heading.setGravity(Gravity.CENTER_VERTICAL);
        TextView brand=new TextView(this);
        brand.setText("REexplorer");
        brand.setTextSize(19);
        brand.setTextColor(INK);
        brand.setTypeface(Typeface.DEFAULT,Typeface.BOLD);
        heading.addView(brand,new LinearLayout.LayoutParams(0,dp(42),1));
        Button clear=button("Borrar datos");
        heading.addView(clear);
        root.addView(heading);

        LinearLayout bar=new LinearLayout(this);
        bar.setGravity(Gravity.CENTER_VERTICAL);
        Button back=button("‹");
        Button forward=button("›");
        Button refresh=button("↻");
        Button home=button("⌂");
        bar.addView(back);
        bar.addView(forward);
        bar.addView(refresh);
        bar.addView(home);
        address=new EditText(this);
        address.setSingleLine(true);
        address.setSelectAllOnFocus(true);
        address.setTextSize(13);
        address.setTextColor(INK);
        address.setHintTextColor(MUTED);
        address.setHint("Sitio HTTPS");
        address.setInputType(android.text.InputType.TYPE_CLASS_TEXT|
                android.text.InputType.TYPE_TEXT_VARIATION_URI);
        address.setImeOptions(EditorInfo.IME_ACTION_GO);
        bar.addView(address,new LinearLayout.LayoutParams(0,dp(49),1));
        Button go=button("Ir");
        bar.addView(go);
        root.addView(bar);

        status=new TextView(this);
        status.setTextColor(MUTED);
        status.setTextSize(11);
        status.setPadding(dp(7),dp(4),dp(7),dp(4));
        status.setText("REexplorer · Q-Core XI/Ether · independiente de BBY Q");
        root.addView(status);
        progress=new ProgressBar(this,null,android.R.attr.progressBarStyleHorizontal);
        progress.setMax(100);
        progress.setVisibility(android.view.View.GONE);
        root.addView(progress,new LinearLayout.LayoutParams(-1,dp(2)));

        page=new WebView(this);
        page.setBackgroundColor(Color.WHITE);
        root.addView(page,new LinearLayout.LayoutParams(-1,0,1));
        setContentView(root);
        // Isolated XI/Ether state: never read any BBY Q / REVERSE checkpoint.
        try{quantum=new ReexplorerQuantumCore(getApplicationContext());}
        catch(Throwable unavailable){
            quantum=null;status.setText("Q-Core XI no disponible. Navegación bloqueada.");
        }

        WebSettings options=page.getSettings();
        options.setJavaScriptEnabled(true); // Modern sites and sign-in require JS.
        options.setDomStorageEnabled(true);
        options.setAllowFileAccess(false);
        options.setAllowContentAccess(false);
        options.setAllowFileAccessFromFileURLs(false);
        options.setAllowUniversalAccessFromFileURLs(false);
        options.setMixedContentMode(WebSettings.MIXED_CONTENT_NEVER_ALLOW);
        options.setSafeBrowsingEnabled(true);
        options.setGeolocationEnabled(false);
        options.setJavaScriptCanOpenWindowsAutomatically(false);
        options.setSupportMultipleWindows(false);
        options.setMediaPlaybackRequiresUserGesture(true);
        options.setBuiltInZoomControls(true);
        options.setDisplayZoomControls(false);
        CookieManager.getInstance().setAcceptCookie(true);
        CookieManager.getInstance().setAcceptThirdPartyCookies(page,false);
        // No JavaScript-to-Java bridge is installed in REexplorer.
        // No WebView bridge and no host script injection, even for Robinhood.
        page.setDownloadListener((url,agent,contentDisposition,mime,length)->{
            inspectSecurityEvent(ReexplorerQuantumCore.DOWNLOAD);
            status.setText("REexplorer bloqueó la descarga");
        });
        page.setWebChromeClient(new WebChromeClient(){
            @Override public void onProgressChanged(WebView view,int value){
                if(progress!=null){progress.setProgress(value);
                    progress.setVisibility(value>=100?android.view.View.GONE:android.view.View.VISIBLE);}
            }
            @Override public void onPermissionRequest(PermissionRequest request){
                request.deny();
                inspectSecurityEvent(ReexplorerQuantumCore.PERMISSION);
            }
            @Override public void onGeolocationPermissionsShowPrompt(String origin,
                    GeolocationPermissions.Callback callback){
                callback.invoke(origin,false,false);
                inspectSecurityEvent(ReexplorerQuantumCore.PERMISSION);
            }
            @Override public boolean onShowFileChooser(WebView view,
                    ValueCallback<Uri[]> files,FileChooserParams params){
                files.onReceiveValue(null);
                inspectSecurityEvent(ReexplorerQuantumCore.PERMISSION);
                return true;
            }
            @Override public boolean onCreateWindow(WebView view,boolean dialog,
                    boolean gesture,android.os.Message resultMsg){
                inspectSecurityEvent(ReexplorerQuantumCore.POPUP);
                return false;
            }
        });
        page.setWebViewClient(new WebViewClient(){
            @Override public boolean shouldOverrideUrlLoading(WebView view,WebResourceRequest request){
                String candidate=request.getUrl().toString();
                if(!ReexplorerPolicy.isSecureUrl(candidate)||
                        !allowNavigationByXi(candidate)){
                    status.setText("REexplorer Q-Core bloqueó la navegación");
                    return true;
                }
                return false;
            }
            @Override public WebResourceResponse shouldInterceptRequest(WebView view,
                    WebResourceRequest request){
                // Defense in depth for subresources; note that WebView does not
                // guarantee interception of every request type.
                Uri uri=request.getUrl();
                String scheme=uri.getScheme();
                if(scheme!=null&&scheme.equalsIgnoreCase("https")&&
                        ReexplorerPolicy.isSecureUrl(uri.toString()))return null;
                if(scheme!=null&&(scheme.equalsIgnoreCase("http")||
                        scheme.equalsIgnoreCase("file")||scheme.equalsIgnoreCase("content")||
                        scheme.equalsIgnoreCase("ftp")||scheme.equalsIgnoreCase("intent")))
                    return denied();
                return null; // Internal blob/data renderer resources are not navigation.
            }
            @Override public void onPageStarted(WebView view,String url,android.graphics.Bitmap icon){
                if("about:blank".equals(url))return;
                if(!ReexplorerPolicy.isSecureUrl(url)||!allowNavigationByXi(url)){
                    view.stopLoading();
                    status.setText("Q-Core impidió cargar el destino");
                    if(quantum==null||!quantum.isQuarantined())view.loadUrl("about:blank");
                    return;
                }
                String currentHost=ReexplorerPolicy.host(url);
                if(lastHost!=null&&!lastHost.equals(currentHost))
                    inspectSecurityEvent(ReexplorerQuantumCore.ORIGIN_CHANGE);
                lastHost=currentHost;
                address.setText(url);
                status.setText("HTTPS · "+ReexplorerPolicy.host(url)+
                        " · no conectado con la memoria Ether");
            }
            @Override public void onPageFinished(WebView view,String url){
                if(ReexplorerPolicy.isSecureUrl(url)){
                    address.setText(url);
                    status.setText("HTTPS · "+ReexplorerPolicy.host(url)+
                            " · verifique el dominio antes de iniciar sesión");
                }
            }
            @Override public void onReceivedSslError(WebView view,SslErrorHandler handler,
                    SslError error){
                handler.cancel();
                inspectSecurityEvent(ReexplorerQuantumCore.TLS);
                view.stopLoading();
                status.setText("Q-Core · certificado TLS rechazado · cuarentena");
            }
            @Override public void onSafeBrowsingHit(WebView view,WebResourceRequest request,
                    int threatType,SafeBrowsingResponse callback){
                callback.backToSafety(true);
                inspectSecurityEvent(ReexplorerQuantumCore.KNOWN_THREAT);
                view.stopLoading();
                status.setText("Q-Core · amenaza conocida bloqueada · cuarentena");
            }
            @Override public void onReceivedHttpAuthRequest(WebView view,
                    HttpAuthHandler handler,String host,String realm){
                handler.cancel();
                inspectSecurityEvent(ReexplorerQuantumCore.PERMISSION);
            }
            @Override public void onReceivedClientCertRequest(WebView view,
                    ClientCertRequest request){
                request.cancel();
                inspectSecurityEvent(ReexplorerQuantumCore.PERMISSION);
            }
            @Override public void onReceivedError(WebView view,WebResourceRequest request,
                    WebResourceError error){
                if(request.isForMainFrame())status.setText("No se pudo cargar la página");
            }
            @Override public boolean onRenderProcessGone(WebView view,
                    RenderProcessGoneDetail detail){
                rendererGone=true;
                inspectSecurityEvent(ReexplorerQuantumCore.RENDERER);
                status.setText("Proceso web detenido. Q-Core puso la sesión en cuarentena.");
                view.destroy();page=null;
                return true; // Renderer crashes must not crash the entire OS.
            }
        });
        back.setOnClickListener(v->{if(page!=null&&page.canGoBack())page.goBack();});
        forward.setOnClickListener(v->{if(page!=null&&page.canGoForward())page.goForward();});
        refresh.setOnClickListener(v->{if(page!=null)page.reload();});
        home.setOnClickListener(v->navigate(ReexplorerPolicy.HOME));
        go.setOnClickListener(v->navigate(address.getText().toString()));
        address.setOnEditorActionListener((v,action,event)->{
            if(action==EditorInfo.IME_ACTION_GO){navigate(address.getText().toString());return true;}
            return false;
        });
        clear.setOnClickListener(v->new AlertDialog.Builder(this)
            .setTitle("Borrar datos de REexplorer")
            .setMessage("Borra cookies, almacenamiento web, caché e historial de REexplorer. " +
                "No revoca sesiones activas en el servidor; cierre sesión en el sitio también.")
            .setNegativeButton("Cancelar",null)
            .setPositiveButton("Borrar",(dialog,which)->clearSession()).show());
        navigate(getIntent().getStringExtra(EXTRA_URL)==null?
                ReexplorerPolicy.HOME:getIntent().getStringExtra(EXTRA_URL));
    }

    private Button button(String text){
        Button b=new Button(this);
        b.setText(text);b.setTextSize(11);b.setAllCaps(false);
        b.setTextColor(INK);b.setBackgroundTintList(
                android.content.res.ColorStateList.valueOf(PANEL));
        b.setMinWidth(0);b.setMinimumWidth(0);
        b.setPadding(dp(8),0,dp(8),0);
        return b;
    }
    private int dp(float n){return Math.round(n*getResources().getDisplayMetrics().density);}
    private static WebResourceResponse denied(){
        return new WebResourceResponse("text/plain","UTF-8",
                new ByteArrayInputStream(new byte[0]));
    }
    /** Programmatic navigation is independently authorized by REexplorer XI,
     * never by a BBY Q model or the JavaScript environment of the page. */
    private boolean allowNavigationByXi(String candidate){
        if(quantum==null||quantum.isQuarantined())return false;
        boolean secure=ReexplorerPolicy.isSecureUrl(candidate);
        int financial=secure&&ReexplorerPolicy.host(candidate).endsWith("robinhood.com")?1:0;
        ReexplorerQuantumCore.Verdict decision=quantum.decide(
                ReexplorerQuantumCore.NAVIGATE,secure?0:1,financial);
        if(!decision.allow())
            status.setText("Q-Core · solicitud denegada ("+decision.reason+")");
        return secure&&decision.allow();
    }
    private void inspectSecurityEvent(int event){
        if(quantum==null)return;
        ReexplorerQuantumCore.Verdict decision=quantum.decide(event,0,0);
        if(decision.quarantined()){
            status.setText("Q-Core · cuarentena activa ("+decision.reason+")");
            if(page!=null)page.stopLoading();
        }
    }
    private void navigate(String raw){
        if(page==null||rendererGone)return;
        try{
            String destination=ReexplorerPolicy.normalize(raw);
            if(!allowNavigationByXi(destination))return;
            address.setText(destination);
            status.setText("XI/Ether · HTTPS · "+ReexplorerPolicy.host(destination));
            page.loadUrl(destination);
        }catch(IllegalArgumentException invalid){
            status.setText("Bloqueado: "+invalid.getMessage());
        }
    }
    private void clearSession(){
        if(page!=null){
            page.stopLoading();page.clearHistory();page.clearCache(true);
            page.clearFormData();
        }
        WebStorage.getInstance().deleteAllData();
        CookieManager.getInstance().removeAllCookies(result->CookieManager.getInstance().flush());
        status.setText("Se solicitaron el borrado de cookies y datos locales");
        if(page!=null)page.loadUrl("about:blank");
        address.setText("");
    }
    @Override protected void onNewIntent(Intent intent){
        super.onNewIntent(intent);
        setIntent(intent);
        if(intent.hasExtra(EXTRA_URL))navigate(intent.getStringExtra(EXTRA_URL));
    }
    @Override public void onBackPressed(){
        if(page!=null&&page.canGoBack()){page.goBack();return;}
        super.onBackPressed();
    }
    @Override protected void onPause(){
        if(page!=null)page.onPause();
        super.onPause();
    }
    @Override protected void onResume(){
        super.onResume();
        if(page!=null)page.onResume();
    }
    @Override protected void onDestroy(){
        if(page!=null){page.stopLoading();page.loadUrl("about:blank");
            page.removeAllViews();page.destroy();page=null;}
        super.onDestroy();
    }
}
