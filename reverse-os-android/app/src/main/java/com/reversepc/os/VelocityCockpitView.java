package com.reversepc.os;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.view.View;

/** Instrument panel: data from the authoritative XI race observation, not invented RPM/fuel. */
final class VelocityCockpitView extends View {
    private final Paint paint=new Paint(Paint.ANTI_ALIAS_FLAG);
    private VelocityXiEngine.Snapshot race;
    private boolean reverse,braking,accelerating;
    private final RectF dial=new RectF();
    VelocityCockpitView(Context context) {
        super(context);
        setContentDescription("Tablero de velocidad, transmisión y frenos");
        setImportantForAccessibility(IMPORTANT_FOR_ACCESSIBILITY_YES);
    }
    void update(VelocityXiEngine.Snapshot value,boolean reverse,boolean braking,boolean accelerating) {
        if(value==null)return;
        this.race=value;this.reverse=reverse;this.braking=braking;this.accelerating=accelerating;
        setContentDescription("Velocidad "+value.speedKmh()+" kilómetros por hora, marcha "
            +(reverse?"reversa":"avance")+(braking?", frenando":""));
        postInvalidateOnAnimation();
    }
    private void color(int c){paint.setColor(c);paint.setStyle(Paint.Style.FILL);paint.setStrokeWidth(1);}
    @Override protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        float w=getWidth(),h=getHeight();
        if(w<=0||h<=0)return;
        canvas.save();
        float sx=w/220f,sy=h/120f;
        canvas.scale(sx,sy);
        color(0xe80b1522);
        canvas.drawRoundRect(2,1,218,119,17,17,paint);
        color(0xff415d70);paint.setStyle(Paint.Style.STROKE);paint.setStrokeWidth(1.6f);
        canvas.drawRoundRect(2,1,218,119,17,17,paint);
        color(0xff101e2d);
        canvas.drawCircle(100,61,47,paint);
        dial.set(57,18,143,104);
        color(0xff274355);paint.setStyle(Paint.Style.STROKE);paint.setStrokeWidth(7);
        canvas.drawArc(dial,150,240,false,paint);
        color(braking?0xfffa5962:0xff4ee4c2);paint.setStrokeCap(Paint.Cap.ROUND);
        float speed=race==null?0:race.speedKmh();
        canvas.drawArc(dial,150,240*Math.min(1f,speed/240f),false,paint);
        paint.setStrokeCap(Paint.Cap.BUTT);
        color(0xffeef8ff);paint.setTextAlign(Paint.Align.CENTER);
        paint.setTypeface(android.graphics.Typeface.create("sans-serif-medium",1));
        paint.setTextSize(30);
        // A real Android TextView renders the XI speed here for accessibility.
        paint.setTextSize(9);paint.setColor(0xffa5c8d9);
        // The accessible XI speed TextView overlays this gauge once, without duplicates.
        color(0xff102d38);canvas.drawRoundRect(154,16,205,52,9,9,paint);
        paint.setTextAlign(Paint.Align.CENTER);paint.setTextSize(20);
        paint.setColor(reverse?0xffffd56a:0xff80e8ee);
        canvas.drawText(reverse?"R":"D",180,42,paint);
        color(braking?0xffd9494c:0xff203742);canvas.drawRoundRect(153,64,205,86,6,6,paint);
        paint.setColor(braking?Color.WHITE:0xff78929e);paint.setTextSize(10);
        canvas.drawText("FRENO",179,78,paint);
        color(accelerating?0xff1e8c78:0xff203742);
        canvas.drawRoundRect(153,91,205,111,6,6,paint);
        paint.setColor(accelerating?Color.WHITE:0xff78929e);
        canvas.drawText("MOTOR",179,104,paint);
        paint.setTextAlign(Paint.Align.LEFT);
        paint.setTextSize(9);paint.setColor(0xff8aa9ba);
        canvas.drawText("REVERSE",12,16,paint);
        canvas.restore();
    }
}
