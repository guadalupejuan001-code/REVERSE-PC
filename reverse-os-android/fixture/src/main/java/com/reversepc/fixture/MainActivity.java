package com.reversepc.fixture;

public final class MainActivity extends android.app.Activity {
 @Override public void onCreate(android.os.Bundle state){
  super.onCreate(state);
  android.widget.LinearLayout layout=new android.widget.LinearLayout(this);layout.setOrientation(1);layout.setGravity(android.view.Gravity.CENTER);
  android.widget.TextView title=new android.widget.TextView(this);title.setText("Programa instalado desde REVERSE");title.setTextSize(26);layout.addView(title);
  android.widget.Button back=new android.widget.Button(this);back.setText("Volver al escritorio");back.setOnClickListener(v->finish());layout.addView(back);setContentView(layout);
 }
}
