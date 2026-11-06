package com.reversepc.os;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.Shader;
import android.graphics.Typeface;
import android.widget.Button;

/** Accessible pressure/boost control; graphics are HUD only, authority remains XI. */
final class VelocityActionButton extends Button {
    private final Paint ink=new Paint(Paint.ANTI_ALIAS_FLAG);
    private final RectF frame=new RectF(),meter=new RectF();
    private final boolean pneumatic;
    private float level=1f;
    private boolean operating;
    VelocityActionButton(Context context,String label,boolean pneumatic){
        super(context);
        this.pneumatic=pneumatic;
        setText(label);setAllCaps(false);setTextColor(Color.WHITE);
        setTextSize(8);setGravity(android.view.Gravity.BOTTOM|android.view.Gravity.CENTER_HORIZONTAL);setTypeface(Typeface.create("sans-serif-medium",Typeface.BOLD));
        setMinWidth(0);setMinimumWidth(0);setMinHeight(0);setMinimumHeight(0);
        setPadding(0,0,0,0);setBackgroundColor(Color.TRANSPARENT);
        setContentDescription(pneumatic?"Saltar: impulso de aire comprimido desde las cuatro ruedas":
            "Activar nitro: consume energía de aceleración");
    }
    void setStatus(float charge,boolean active){
        float clean=Math.max(0f,Math.min(1f,charge));
        if(clean==level&&operating==active)return;
        level=clean;operating=active;postInvalidateOnAnimation();
    }
    @Override protected void onDraw(Canvas c){
        float w=getWidth(),h=getHeight(),cx=w*.5f,cy=h*.36f,r=Math.min(w*.42f,h*.32f);
        boolean held=isPressed()||isSelected();int accent=pneumatic?0xffe3ece3:0xffc4ef82;
        ink.setShader(null);ink.setStyle(Paint.Style.FILL);ink.setColor(held?0xdc354331:0xc9161d1e);c.drawCircle(cx,cy,r,ink);
        ink.setStyle(Paint.Style.STROKE);ink.setStrokeWidth(2f*getResources().getDisplayMetrics().density);ink.setStrokeCap(Paint.Cap.ROUND);
        ink.setColor(0xff435048);frame.set(cx-r,cy-r,cx+r,cy+r);c.drawArc(frame,-90,360,false,ink);
        ink.setColor(accent);c.drawArc(frame,-90,360*level,false,ink);
        ink.setStrokeWidth(Math.max(2,r*.12f));ink.setColor(operating||held?accent:0xffc1cbc2);
        if(pneumatic){
            c.drawLine(cx-r*.32f,cy+r*.2f,cx-r*.32f,cy-r*.25f,ink);
            c.drawLine(cx,cy+r*.4f,cx,cy-r*.4f,ink);
            c.drawLine(cx+r*.32f,cy+r*.2f,cx+r*.32f,cy-r*.25f,ink);
        }else{
            android.graphics.Path bolt=new android.graphics.Path();bolt.moveTo(cx+r*.15f,cy-r*.48f);bolt.lineTo(cx-r*.29f,cy+r*.03f);bolt.lineTo(cx+r*.05f,cy+r*.03f);bolt.lineTo(cx-r*.12f,cy+r*.48f);bolt.lineTo(cx+r*.31f,cy-r*.08f);
            ink.setStyle(Paint.Style.FILL);c.drawPath(bolt,ink);
        }
        ink.setStyle(Paint.Style.FILL);super.onDraw(c);
    }
}
