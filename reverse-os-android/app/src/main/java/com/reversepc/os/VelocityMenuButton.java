package com.reversepc.os;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.view.Gravity;
import android.widget.Button;

final class VelocityMenuButton extends Button {
    private final Paint p=new Paint(Paint.ANTI_ALIAS_FLAG);
    VelocityMenuButton(Context c){
        super(c);setStateListAnimator(null);setElevation(0);setText("MENÚ");setTextColor(0xffdfe6df);setTextSize(7);setGravity(Gravity.BOTTOM|Gravity.CENTER_HORIZONTAL);
        setAllCaps(false);setPadding(0,0,0,5);setMinWidth(0);setMinHeight(0);setMinimumWidth(0);setMinimumHeight(0);
        setBackgroundColor(Color.TRANSPARENT);setContentDescription("Abrir menú");
    }
    @Override protected void onDraw(Canvas c){
        float w=getWidth(),h=getHeight(),d=getResources().getDisplayMetrics().density;
        p.setStyle(Paint.Style.FILL);p.setColor(isPressed()?0xe844523c:0xce151c1e);c.drawRoundRect(0,0,w,h,12*d,12*d,p);
        p.setColor(0xffc4ef82);p.setStrokeWidth(1.6f*d);p.setStrokeCap(Paint.Cap.ROUND);
        c.drawLine(w*.28f,h*.32f,w*.72f,h*.32f,p);c.drawLine(w*.28f,h*.46f,w*.59f,h*.46f,p);super.onDraw(c);
    }
}
