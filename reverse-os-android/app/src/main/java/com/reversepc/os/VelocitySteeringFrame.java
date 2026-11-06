package com.reversepc.os;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.view.View;
import android.view.MotionEvent;
import android.widget.FrameLayout;

/** Visually groups the two accessible steering buttons as one steering wheel. */
final class VelocitySteeringFrame extends FrameLayout {
    interface SteeringListener{void steer(int value);}
    private SteeringListener listener;
    private int pointer=-1,value=100;
    void setSteeringListener(SteeringListener l){listener=l;}
    void resetSteering(){pointer=-1;value=100;if(listener!=null)listener.steer(255);invalidate();}
    @Override public boolean onInterceptTouchEvent(MotionEvent e){return true;}
    private void steer(float x){float axis=Math.max(-1f,Math.min(1f,(x-getWidth()*.5f)/Math.max(1f,getWidth()*.42f)));if(Math.abs(axis)<.06f)axis=0;value=Math.round(100+100*axis);if(listener!=null)listener.steer(value);invalidate();}
    @Override public boolean onTouchEvent(MotionEvent e){
        switch(e.getActionMasked()){
            case MotionEvent.ACTION_DOWN:pointer=e.getPointerId(0);getParent().requestDisallowInterceptTouchEvent(true);steer(e.getX());return true;
            case MotionEvent.ACTION_MOVE:int at=e.findPointerIndex(pointer);if(at>=0)steer(e.getX(at));return true;
            case MotionEvent.ACTION_POINTER_UP:if(e.getPointerId(e.getActionIndex())!=pointer)return true; // release only the steering finger
            case MotionEvent.ACTION_UP:case MotionEvent.ACTION_CANCEL:pointer=-1;value=100;if(listener!=null)listener.steer(255);invalidate();return true;
            default:return true;
        }
    }
    private final Paint paint=new Paint(Paint.ANTI_ALIAS_FLAG);
    VelocitySteeringFrame(Context context) {
        super(context);
        setWillNotDraw(false);setClickable(true);setImportantForAccessibility(IMPORTANT_FOR_ACCESSIBILITY_YES);
        setContentDescription("Volante analógico. Desliza el dedo para dosificar el giro; suelta para centrar");
    }
    @Override protected void onDraw(Canvas c) {
        super.onDraw(c);
        float cx=getWidth()/2f,cy=getHeight()/2f,r=Math.min(getWidth(),getHeight())*.46f;
        paint.setStyle(Paint.Style.FILL);paint.setColor(0xb9161d1e);
        c.drawCircle(cx,cy,r,paint);
        paint.setStyle(Paint.Style.STROKE);paint.setStrokeWidth(Math.max(4,r*.14f));
        paint.setColor(0xff6f8079);c.drawCircle(cx,cy,r*.80f,paint);
        paint.setStrokeWidth(Math.max(3,r*.085f));paint.setColor(0xff36443e);
        for(int angle=30;angle<390;angle+=120){
            double radians=Math.toRadians(angle+(value-100)*.65);
            c.drawLine(cx,cy,cx+(float)Math.cos(radians)*r*.73f,
                cy+(float)Math.sin(radians)*r*.73f,paint);
        }
        paint.setStyle(Paint.Style.FILL);paint.setColor(0xffc4ef82);
        c.drawCircle(cx,cy,r*.19f,paint);
    }
}
