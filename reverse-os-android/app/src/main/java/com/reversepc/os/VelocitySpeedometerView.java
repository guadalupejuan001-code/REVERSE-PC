package com.reversepc.os;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.RectF;
import android.view.View;

/** Small instrument arc; every value comes from the committed XI observation. */
final class VelocitySpeedometerView extends View {
    private final Paint paint=new Paint(Paint.ANTI_ALIAS_FLAG);
    private final RectF arc=new RectF(14,6,162,154);
    private int speed,rpm;
    private boolean braking;
    VelocitySpeedometerView(Context context){super(context);setImportantForAccessibility(IMPORTANT_FOR_ACCESSIBILITY_NO);}
    void update(int speed,int rpm,boolean braking){
        if(this.speed==speed&&this.rpm==rpm&&this.braking==braking)return;
        this.speed=speed;this.rpm=rpm;this.braking=braking;postInvalidateOnAnimation();
    }
    @Override protected void onDraw(Canvas c){
        super.onDraw(c);c.save();c.scale(getWidth()/176f,getHeight()/84f);
        paint.setStyle(Paint.Style.STROKE);paint.setStrokeCap(Paint.Cap.ROUND);paint.setStrokeWidth(3);
        paint.setColor(0xa6384442);c.drawArc(arc,186,168,false,paint);
        paint.setColor(braking?0xffff8b79:0xffc4ef82);c.drawArc(arc,186,168*Math.min(1f,speed/240f),false,paint);
        paint.setStrokeWidth(1);paint.setColor(0xaaabb9b1);
        for(int i=0;i<=8;i++){
            double a=Math.toRadians(186+168*i/8f);
            c.drawLine(88+(float)Math.cos(a)*66,80+(float)Math.sin(a)*66,
                88+(float)Math.cos(a)*71,80+(float)Math.sin(a)*71,paint);
        }
        paint.setStyle(Paint.Style.FILL);
        for(int i=0;i<12;i++){
            paint.setColor(rpm>=800+(i+1)*500?(i>9?0xffff8b79:0xffc4ef82):0x663d4944);
            c.drawRoundRect(40+i*8,76,45+i*8,79,1.5f,1.5f,paint);
        }
        c.restore();
    }
}
