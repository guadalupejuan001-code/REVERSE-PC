package com.reversepc.os;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.Typeface;
import android.widget.Button;

/** Touch button with actual automotive pedal silhouette; remains a native accessible Button. */
final class VelocityPedalButton extends Button {
    private final Paint paint=new Paint(Paint.ANTI_ALIAS_FLAG);
    private final boolean isBrake;
    private final RectF shape=new RectF();
    VelocityPedalButton(Context context,String label,boolean brake) {
        super(context);
        isBrake=brake;
        setText(label);setAllCaps(false);setTextColor(Color.WHITE);
        setTextSize(11);setTypeface(Typeface.create("sans-serif-medium",Typeface.BOLD));
        setMinWidth(0);setMinimumWidth(0);setMinHeight(0);setMinimumHeight(0);
        setPadding(0,0,0,0);setBackgroundColor(Color.TRANSPARENT);
        setContentDescription(label);
    }
    @Override protected void onDraw(Canvas c) {
        float w=getWidth(),h=getHeight();
        shape.set(4,2,w-4,h-2);
        paint.setStyle(Paint.Style.FILL);
        paint.setColor(isBrake?0xff4e262b:0xff1a4852);
        c.drawRoundRect(shape,15,15,paint);
        paint.setStyle(Paint.Style.STROKE);paint.setStrokeWidth(3);
        paint.setColor(isBrake?0xffed8088:0xff72d7dc);
        c.drawRoundRect(shape,15,15,paint);
        paint.setStrokeWidth(2);
        paint.setColor(isBrake?0x99ff8c8c:0x9993dce0);
        float top=h*.22f,low=h*.58f;
        for(int i=0;i<4;i++){
            float x=w*(.25f+i*.165f);
            c.drawLine(x,top,x,low,paint);
        }
        paint.setStyle(Paint.Style.FILL);
        super.onDraw(c);
    }
}
