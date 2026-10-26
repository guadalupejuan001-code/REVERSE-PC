package com.reversepc.os;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.style.ForegroundColorSpan;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

/**
 * The first visible frame stays black. The boot animation contains no JNI,
 * graphics engine dependency or expensive disk initialization.
 * It hands off to the horizontal OpenGL desktop independently of XI readiness.
 */
public final class BootActivity extends Activity {
    private final Handler handler=new Handler(Looper.getMainLooper());
    private final Runnable go=()->{
        if(isFinishing()||isDestroyed())return;
        try{
            startActivity(new Intent(this,DesktopActivity.class));
            overridePendingTransition(android.R.anim.fade_in,android.R.anim.fade_out);
            finish();
        }catch(Throwable error){
            Log.e("ReverseBoot","Desktop failed",error);
            TextView failure=new TextView(this);
            failure.setText("REVERSE OS\n\nError al abrir escritorio:\n"+error.getMessage());
            failure.setTextColor(0xffffaaaa);
            failure.setPadding(35,40,35,35);
            failure.setBackgroundColor(Color.BLACK);
            setContentView(failure);
        }
    };
    private int dp(float n){return Math.round(n*getResources().getDisplayMetrics().density);}
    private TextView title(String text,int size,int color,boolean bold){
        TextView result=new TextView(this);
        result.setText(text);
        result.setTextSize(size);
        result.setTextColor(color);
        result.setGravity(Gravity.CENTER);
        result.setTypeface(Typeface.create(bold?"sans-serif-light":"sans-serif",
                                          bold?Typeface.BOLD:Typeface.NORMAL));
        return result;
    }
    @Override public void onCreate(Bundle saved){
        super.onCreate(saved);
        getWindow().setStatusBarColor(Color.BLACK);
        getWindow().setNavigationBarColor(Color.BLACK);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                             WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_FULLSCREEN);
        FrameLayout root=new FrameLayout(this);
        root.setBackgroundColor(Color.BLACK);
        LinearLayout stack=new LinearLayout(this);
        stack.setGravity(Gravity.CENTER);
        stack.setOrientation(LinearLayout.VERTICAL);
        stack.setPadding(dp(15),0,dp(15),0);
        TextView lead=title("welcome....",16,0xffd6d5ea,false);
        lead.setLetterSpacing(.30f);
        stack.addView(lead);
        TextView name=title("REVERSE.",39,0xffc1b8ff,true);
        name.setLetterSpacing(.36f);
        name.setShadowLayer(dp(12),0,0,0xff6d44ff);
        SpannableString gradient=new SpannableString("REVERSE.");
        int[] tones={0xff73b4ff,0xffa2aaff,0xffd3a4ff,0xffeee6ff,
                     0xffcfb3ff,0xffa3acff,0xffff8bef,0xffff80da};
        for(int i=0;i<gradient.length();i++){
            gradient.setSpan(new ForegroundColorSpan(tones[i]),i,i+1,
                             Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        }
        name.setText(gradient);
        LinearLayout.LayoutParams titleParams=new LinearLayout.LayoutParams(-1,-2);
        titleParams.topMargin=dp(10);
        stack.addView(name,titleParams);
        View line=new View(this);
        GradientDrawable glow=new GradientDrawable(GradientDrawable.Orientation.LEFT_RIGHT,
            new int[]{0x00000000,0xff6858ff,0xff76abff,0x00000000});
        line.setBackground(glow);
        LinearLayout.LayoutParams rule=new LinearLayout.LayoutParams(dp(280),dp(2));
        rule.topMargin=dp(26);
        stack.addView(line,rule);
        TextView sub=title("ETHER  /  XI  /  PERSONAL COMPUTER",9,0xff626980,false);
        sub.setLetterSpacing(.19f);
        LinearLayout.LayoutParams subParams=new LinearLayout.LayoutParams(-1,-2);
        subParams.topMargin=dp(19);
        stack.addView(sub,subParams);
        root.addView(stack,new FrameLayout.LayoutParams(-1,-2,Gravity.CENTER));
        TextView foot=title("REVERSE SYSTEM • INITIALIZING",9,0xff4b5371,false);
        foot.setLetterSpacing(.16f);
        FrameLayout.LayoutParams footParams=new FrameLayout.LayoutParams(
            -1,dp(30),Gravity.BOTTOM);
        footParams.bottomMargin=dp(16);
        root.addView(foot,footParams);
        setContentView(root);

        lead.setAlpha(0f);name.setAlpha(0f);line.setScaleX(0f);sub.setAlpha(0f);
        lead.animate().alpha(1f).setStartDelay(130).setDuration(610).start();
        name.animate().alpha(1f).setStartDelay(330).setDuration(950).start();
        line.animate().scaleX(1f).setStartDelay(650).setDuration(720).start();
        sub.animate().alpha(1f).setStartDelay(870).setDuration(570).start();
        Log.i("ReverseBoot","WELCOME_SCREEN_SHOWN welcome.... REVERSE.");
        handler.postDelayed(go,2800L);
    }
    @Override protected void onDestroy(){
        handler.removeCallbacks(go);
        super.onDestroy();
    }
}
