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
        setTextSize(12);setTypeface(Typeface.create("sans-serif-medium",Typeface.BOLD));
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
    @Override protected void onDraw(Canvas canvas){
        float w=getWidth(),h=getHeight();if(w<=0||h<=0)return;
        boolean held=isPressed()||isSelected();
        int edge=pneumatic?0xffb7b9db:0xff48d4ec;
        int base=pneumatic?0xff272c47:0xff0d3543;
        frame.set(2,2,w-2,h-2);
        ink.setStyle(Paint.Style.FILL);
        ink.setShader(new LinearGradient(0,0,0,h,
            held?0xff5c7789:0xff263748,base,Shader.TileMode.CLAMP));
        canvas.drawRoundRect(frame,14,14,ink);
        ink.setShader(null);
        ink.setStyle(Paint.Style.STROKE);
        ink.setStrokeWidth(held?3f:1.8f);
        ink.setColor(held||operating?edge:0xff718c9b);
        canvas.drawRoundRect(frame,14,14,ink);
        ink.setStyle(Paint.Style.FILL);
        // Mechanical pressure vent or turbine motif, not pixel particles.
        ink.setColor(operating||held?edge:0xff7891a1);
        float x=14,cy=h*.36f;
        if(pneumatic){
            for(int i=0;i<3;i++)
                canvas.drawRoundRect(x+i*5,cy-7-i*2,x+i*5+2,cy+5-i,1,1,ink);
        }else{
            android.graphics.Path rotor=new android.graphics.Path();
            rotor.moveTo(x+10,cy-12);rotor.lineTo(x,cy+1);
            rotor.lineTo(x+7,cy+1);rotor.lineTo(x+3,cy+12);
            rotor.lineTo(x+18,cy-4);rotor.lineTo(x+10,cy-4);rotor.close();
            canvas.drawPath(rotor,ink);
        }
        ink.setColor(0x992b3a48);
        meter.set(12,h-12,w-12,h-7);
        canvas.drawRoundRect(meter,3,3,ink);
        ink.setColor(edge);
        meter.set(12,h-12,12+(w-24)*level,h-7);
        if(level>0)canvas.drawRoundRect(meter,3,3,ink);
        ink.setStyle(Paint.Style.FILL);
        super.onDraw(canvas);
    }
}
