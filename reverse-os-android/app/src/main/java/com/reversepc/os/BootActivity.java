package com.reversepc.os;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

/**
 * True first frame: this activity intentionally does NOT load the native
 * library, RVPC state, WebView, or program repository. The welcome screen is
 * therefore visible even when the REVERSE-PC engine cannot initialize.
 */
public final class BootActivity extends Activity {
    private final Handler handler = new Handler(Looper.getMainLooper());
    private final Runnable showDesktop = () -> {
        if (isFinishing() || isDestroyed()) return;
        try {
            startActivity(new Intent(this, DesktopActivity.class));
            overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
            finish();
        } catch (RuntimeException failure) {
            Log.e("ReverseBoot", "Desktop activity unavailable", failure);
            TextView error = new TextView(this);
            error.setText("REVERSE OS\n\nNo se pudo abrir el escritorio:\n" + failure.getMessage());
            error.setTextColor(0xffff9696);
            error.setPadding(dp(24), dp(42), dp(24), dp(24));
            error.setBackgroundColor(Color.BLACK);
            setContentView(error);
        }
    };
    private int dp(float value) {
        return Math.round(value * getResources().getDisplayMetrics().density);
    }
    private TextView text(String value, int size, int color, boolean bold) {
        TextView view = new TextView(this);
        view.setText(value);
        view.setTextSize(size);
        view.setTextColor(color);
        view.setGravity(Gravity.CENTER);
        view.setTypeface(Typeface.create(bold ? "sans-serif-medium" : "sans-serif", Typeface.NORMAL));
        return view;
    }
    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        getWindow().setStatusBarColor(Color.BLACK);
        getWindow().setNavigationBarColor(Color.BLACK);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                             WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().getDecorView().setSystemUiVisibility(
            View.SYSTEM_UI_FLAG_FULLSCREEN | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION |
            View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
        final FrameLayout root = new FrameLayout(this);
        root.setBackgroundColor(Color.BLACK);

        final LinearLayout center = new LinearLayout(this);
        center.setOrientation(LinearLayout.VERTICAL);
        center.setGravity(Gravity.CENTER);
        center.setPadding(dp(24), 0, dp(24), 0);

        TextView crest = text("R", 52, 0xff0fe2c2, true);
        crest.setLetterSpacing(-0.05f);
        GradientDrawable frame = new GradientDrawable();
        frame.setColor(0xff071512);
        frame.setCornerRadius(dp(25));
        frame.setStroke(dp(1), 0xff1d826f);
        crest.setBackground(frame);
        LinearLayout.LayoutParams crestParams = new LinearLayout.LayoutParams(dp(92), dp(92));
        crestParams.bottomMargin = dp(38);
        center.addView(crest, crestParams);

        TextView welcome = text("Welcome,", 26, 0xffdcece8, false);
        welcome.setLetterSpacing(0.045f);
        center.addView(welcome);
        TextView title = text("Mr Reverse", 37, Color.WHITE, true);
        title.setLetterSpacing(0.018f);
        LinearLayout.LayoutParams titleParams = new LinearLayout.LayoutParams(-1, -2);
        titleParams.topMargin = dp(4);
        center.addView(title, titleParams);

        View rule = new View(this);
        GradientDrawable ruleColor = new GradientDrawable(
            GradientDrawable.Orientation.LEFT_RIGHT,
            new int[]{Color.BLACK, 0xff24e5c5, Color.BLACK});
        rule.setBackground(ruleColor);
        LinearLayout.LayoutParams line = new LinearLayout.LayoutParams(dp(168), dp(2));
        line.topMargin = dp(29);
        line.bottomMargin = dp(24);
        center.addView(rule, line);

        TextView subtitle = text("REVERSE OS  /  ETHER SYSTEM", 11, 0xff7c9b95, true);
        subtitle.setLetterSpacing(0.16f);
        center.addView(subtitle);

        FrameLayout.LayoutParams centerParams = new FrameLayout.LayoutParams(
            -1, -2, Gravity.CENTER);
        root.addView(center, centerParams);

        TextView foot = text("BOOTING YOUR COMPUTER", 10, 0xff597870, true);
        foot.setLetterSpacing(0.20f);
        FrameLayout.LayoutParams footParams = new FrameLayout.LayoutParams(
            -1, dp(48), Gravity.BOTTOM);
        footParams.bottomMargin = dp(45);
        root.addView(foot, footParams);
        setContentView(root);

        crest.setAlpha(0f);
        crest.animate().alpha(1f).setDuration(650).start();
        welcome.setAlpha(0f);
        welcome.animate().alpha(1f).setStartDelay(220).setDuration(760).start();
        title.setAlpha(0f);
        title.animate().alpha(1f).setStartDelay(420).setDuration(900).start();
        rule.setScaleX(0.0f);
        rule.animate().scaleX(1.0f).setStartDelay(550).setDuration(800).start();
        subtitle.setAlpha(0f);
        subtitle.animate().alpha(1f).setStartDelay(700).setDuration(900).start();

        Log.i("ReverseBoot", "WELCOME_SCREEN_SHOWN Welcome, Mr Reverse");
        handler.postDelayed(showDesktop, 3100L);
    }
    @Override protected void onDestroy() {
        handler.removeCallbacks(showDesktop);
        super.onDestroy();
    }
}
