package com.reversepc.os;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.LinearGradient;
import android.graphics.Shader;
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
        boolean down=isPressed()||isSelected();
        paint.setStyle(Paint.Style.FILL);
        int upper=isBrake?0xff71343c:0xff285e64;
        int lower=isBrake?0xff211c27:0xff102630;
        paint.setShader(new LinearGradient(0,2,0,h-2,down?0xff89969b:upper,lower,Shader.TileMode.CLAMP));
        c.drawRoundRect(shape,15,15,paint);
        paint.setShader(null);
        paint.setStyle(Paint.Style.STROKE);paint.setStrokeWidth(down?3.5f:2f);
        paint.setColor(isBrake?0xffe7a5a0:0xff87d8da);
        c.drawRoundRect(shape,15,15,paint);
        // Embossed pedal ribs and top light, never flat color rectangles.
        paint.setStrokeWidth(2);
        paint.setColor(isBrake?0xa9e4b0ab:0xa9b4e4e4);
        float top=h*.22f,low=h*.58f;
        for(int i=0;i<4;i++){
            float x=w*(.25f+i*.165f);
            c.drawLine(x,top,x,low,paint);
        }
        paint.setColor(0x448fffff);paint.setStrokeWidth(1.3f);
        c.drawLine(w*.22f,h*.13f,w*.78f,h*.13f,paint);
        paint.setStyle(Paint.Style.FILL);
        super.onDraw(c);
    }
}
