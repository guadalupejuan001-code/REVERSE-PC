package com.reversepc.os;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.view.View;
import android.widget.FrameLayout;

/** Visually groups the two accessible steering buttons as one steering wheel. */
final class VelocitySteeringFrame extends FrameLayout {
    private final Paint paint=new Paint(Paint.ANTI_ALIAS_FLAG);
    VelocitySteeringFrame(Context context) {
        super(context);
        setWillNotDraw(false);
        setContentDescription("Control de dirección");
    }
    @Override protected void onDraw(Canvas c) {
        super.onDraw(c);
        float cx=getWidth()/2f,cy=getHeight()/2f,r=Math.min(getWidth(),getHeight())*.46f;
        paint.setStyle(Paint.Style.FILL);paint.setColor(0xd70e1d2c);
        c.drawCircle(cx,cy,r,paint);
        paint.setStyle(Paint.Style.STROKE);paint.setStrokeWidth(Math.max(4,r*.14f));
        paint.setColor(0xff6e91a7);c.drawCircle(cx,cy,r*.80f,paint);
        paint.setStrokeWidth(Math.max(3,r*.085f));paint.setColor(0xff344f62);
        for(int angle=30;angle<390;angle+=120){
            double radians=Math.toRadians(angle);
            c.drawLine(cx,cy,cx+(float)Math.cos(radians)*r*.73f,
                cy+(float)Math.sin(radians)*r*.73f,paint);
        }
        paint.setStyle(Paint.Style.FILL);paint.setColor(0xff9dcbd5);
        c.drawCircle(cx,cy,r*.19f,paint);
    }
}
