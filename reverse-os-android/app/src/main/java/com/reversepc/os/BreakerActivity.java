package com.reversepc.os;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Color;
import android.graphics.RectF;
import android.graphics.Typeface;
import android.view.Choreographer;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.widget.FrameLayout;
import android.util.Log;
import java.util.Locale;

/** Android draws and transports input. Positions, collisions and score come from XI. */
public final class BreakerActivity extends Activity {
    private final Handler main=new Handler(Looper.getMainLooper());
    private GameView view;
    private volatile BreakerSession session;
    private BreakerSession.Frame frame;
    private boolean active,closed,busy,paused=true;
    private int paddle=500,lastPaddle=-1,command;
    private long lastFrame,accumulator,lastSave,lastMeasure;
    private int draws,ticksMeasured,fps,tps;
    private double xiMs=-1;
    private String error="",saveStatus="Abriendo partida…";
    private static final long TICK=16666667L;
    private final Choreographer.FrameCallback animate=new Choreographer.FrameCallback(){@Override public void doFrame(long now){
        if(!active||closed)return;
        if(lastFrame!=0&&!paused)accumulator=Math.min(accumulator+Math.max(0,now-lastFrame),TICK*4);else accumulator=0;
        lastFrame=now;
        if(frame!=null&&!busy&&error.isEmpty()){
            int count=paused?0:(int)(accumulator/TICK);
            if(count>0)accumulator-=count*TICK;
            if(count>0||command!=0||paddle!=lastPaddle){int requested=command;command=0;lastPaddle=paddle;step(paddle,requested,count);}
        }
        if(now-lastMeasure>=1000000000L){double seconds=(now-lastMeasure)/1e9;if(lastMeasure!=0){fps=(int)Math.round(draws/seconds);tps=(int)Math.round(ticksMeasured/seconds);}draws=0;ticksMeasured=0;lastMeasure=now;view.invalidate();}
        if(!paused||busy)view.invalidate();Choreographer.getInstance().postFrameCallback(this);
    }};
    @Override public void onCreate(Bundle saved){
        super.onCreate(saved);getWindow().setStatusBarColor(0xff090d13);getWindow().setNavigationBarColor(0xff090d13);
        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_FULLSCREEN|View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
        FrameLayout root=new FrameLayout(this);root.setBackgroundColor(0xff090d13);view=new GameView();root.addView(view,new FrameLayout.LayoutParams(-1,-1));setContentView(root);
        RuntimeExecutor.INSTANCE.execute(()->{try{session=new BreakerSession(this);BreakerSession.Frame initial=session.step(500,0,0);main.post(()->{if(!closed){frame=initial;paddle=initial.get(4);saveStatus="Partida lista · RXE / XI";view.invalidate();}});}catch(Throwable fault){fail(fault);}});
    }
    private void fail(Throwable fault){Log.e("ReverseBreaker","GAME_FAILED",fault);main.post(()->{error=fault.getClass().getSimpleName()+": "+fault.getMessage();paused=true;view.invalidate();});}
    private void step(int x,int cmd,int count){
        busy=true;
        RuntimeExecutor.INSTANCE.execute(()->{try{
            long begin=SystemClock.elapsedRealtimeNanos();BreakerSession.Frame next=session.step(x,cmd,count);double millis=(SystemClock.elapsedRealtimeNanos()-begin)/1e6;
            boolean save=cmd!=0||next.get(11)>=3||SystemClock.elapsedRealtime()-lastSave>=2000;
            if(save){session.save();lastSave=SystemClock.elapsedRealtime();}
            main.post(()->{busy=false;if(closed)return;int previous=frame==null?next.get(17):frame.get(17);ticksMeasured+=(next.get(17)-previous+65536)%65536;frame=next;xiMs=millis;if(next.get(7)!=1&&command!=1)paused=true;if(save)saveStatus="Guardado · "+session.stateBytes()+" bytes";view.invalidate();});
        }catch(Throwable fault){main.post(()->busy=false);fail(fault);}});
    }
    private void play(){if(frame==null||!error.isEmpty())return;if(frame.get(7)>=2){command=2;paused=true;}else{if(frame.get(7)==0)command=1;paused=false;}lastFrame=0;accumulator=0;view.invalidate();}
    private void pause(){paused=!paused;lastFrame=0;accumulator=0;if(paused)save();view.invalidate();}
    private void save(){RuntimeExecutor.INSTANCE.execute(()->{try{if(session!=null){session.save();main.post(()->{if(!closed)saveStatus="Guardado · "+session.stateBytes()+" bytes";});}}catch(Throwable fault){fail(fault);}});}
    @Override protected void onResume(){super.onResume();active=true;lastFrame=0;if(view!=null)Choreographer.getInstance().postFrameCallback(animate);}
    @Override protected void onPause(){active=false;paused=true;lastFrame=0;Choreographer.getInstance().removeFrameCallback(animate);save();super.onPause();}
    @Override protected void onDestroy(){closed=true;Choreographer.getInstance().removeFrameCallback(animate);super.onDestroy();}
    @Override public boolean onKeyDown(int key,KeyEvent event){if(key==KeyEvent.KEYCODE_DPAD_LEFT||key==KeyEvent.KEYCODE_A){paddle=Math.max(0,paddle-45);return true;}if(key==KeyEvent.KEYCODE_DPAD_RIGHT||key==KeyEvent.KEYCODE_D){paddle=Math.min(1000,paddle+45);return true;}if(key==KeyEvent.KEYCODE_SPACE||key==KeyEvent.KEYCODE_BUTTON_A){if(paused)play();else pause();return true;}if(key==KeyEvent.KEYCODE_R){command=2;paused=true;return true;}return super.onKeyDown(key,event);}
    public View testingView(){return view;}
    public int[] testingSnapshot(){return frame==null?null:frame.values.clone();}
    public boolean testingPaused(){return paused;}
    public RectF testingPlayRect(){return new RectF(view.playRect);}
    public RectF testingPauseRect(){return new RectF(view.pauseRect);}
    public RectF testingBoard(){return new RectF(view.board);}
    private final class GameView extends View {
        final Paint p=new Paint(Paint.ANTI_ALIAS_FLAG);
        final RectF board=new RectF(),playRect=new RectF(),backRect=new RectF(),pauseRect=new RectF(),resetRect=new RectF();
        final int[] colors={0xffff8f91,0xffe9b989,0xffd9dcbe,0xff95d3d1,0xff72bda7};
        float scale,startX,startY;boolean moved;
        final float density=getResources().getDisplayMetrics().density;
        GameView(){super(BreakerActivity.this);setFocusable(true);setClickable(true);setContentDescription("REVERSE BREAKER. Arrastra para mover la barra. Toca Jugar para lanzar. Pausa arriba a la derecha.");}
        float dp(float value){return value*density;}
        void fill(Canvas c,int color){p.setColor(color);p.setStyle(Paint.Style.FILL);c.drawRect(0,0,getWidth(),getHeight(),p);}
        void text(Canvas c,String value,float x,float y,float size,int color,boolean bold){p.setColor(color);p.setStyle(Paint.Style.FILL);p.setTypeface(Typeface.create(bold?"sans-serif-medium":"sans-serif",Typeface.NORMAL));p.setTextSize(size);c.drawText(value,x,y,p);}
        void round(Canvas c,RectF r,float radius,int color){p.setColor(color);p.setStyle(Paint.Style.FILL);c.drawRoundRect(r,radius,radius,p);}
        void button(Canvas c,RectF r,String label,boolean primary){round(c,r,dp(5),primary?0xffc4e4d4:0xff1a232d);p.setTextSize(dp(11));p.setTypeface(Typeface.create("sans-serif-medium",Typeface.NORMAL));float width=p.measureText(label);text(c,label,r.centerX()-width/2,r.centerY()+dp(4),dp(11),primary?0xff13241d:0xffd4dce5,true);}
        @Override protected void onDraw(Canvas c){
            draws++;fill(c,0xff090d13);float w=getWidth(),h=getHeight(),margin=dp(16);
            backRect.set(margin,dp(12),margin+dp(64),dp(48));pauseRect.set(w-dp(170),dp(12),w-dp(94),dp(48));resetRect.set(w-dp(86),dp(12),w-margin,dp(48));
            button(c,backRect,"‹ Mesa",false);button(c,pauseRect,paused?"Seguir":"Pausa",false);button(c,resetRect,"Nueva",false);
            text(c,"REVERSE  /  BREAKER",dp(95),dp(34),dp(13),0xffe8efef,true);
            if(frame!=null){String stats=String.format(Locale.ROOT,"%05d  ·  RÉCORD %05d  ·  %d/5  ·  %d VIDAS",frame.get(5),frame.get(10),frame.get(8),frame.get(6));if(w>dp(700))text(c,stats,w/2-dp(120),dp(34),dp(11),0xffa1b1bb,false);}
            float availableH=Math.max(dp(90),h-dp(100));scale=Math.min((w-dp(36))/1000,availableH/600);float bw=scale*1000,bh=scale*600;board.set((w-bw)/2,dp(58),(w+bw)/2,dp(58)+bh);
            round(c,board,dp(6),0xff111b25);c.save();c.translate(board.left,board.top);c.scale(scale,scale);p.setStrokeWidth(1);p.setColor(0xff1b2b35);for(int x=24;x<=976;x+=44)c.drawLine(x,58,x,574,p);for(int y=58;y<578;y+=36)c.drawLine(24,y,976,y,p);
            p.setColor(0xff395d62);p.setStrokeWidth(2);c.drawLine(24,58,976,58,p);c.drawLine(24,58,24,576,p);c.drawLine(976,58,976,576,p);
            if(frame!=null){
                text(c,"SECTOR 0"+frame.get(8),48,40,15,0xff819da9,true);
                text(c,frame.get(9)+" BLOQUES",812,40,15,0xff819da9,false);
                for(int row=0;row<5;row++)for(int col=0;col<10;col++)if((frame.get(12+row)&(1<<col))!=0){float x=60+col*88,y=100+row*36;round(c,new RectF(x,y,x+82,y+28),4,colors[(row+frame.get(8)-1)%5]);p.setColor(0x44ffffff);p.setStrokeWidth(1);c.drawLine(x+5,y+3,x+77,y+3,p);}
                int bx=frame.get(0),by=frame.get(1),px=frame.get(4);p.setColor(0x126de8c2);c.drawCircle(bx,by,22,p);p.setColor(0x3572dbbd);c.drawCircle(bx,by,13,p);p.setColor(0xfff2f6e6);c.drawCircle(bx,by,8,p);
                round(c,new RectF(px-66,530,px+66,542),5,0xffcde5dc);round(c,new RectF(px-20,530,px+20,542),3,0xff79bba3);text(c,"ARRASTRA PARA MOVER",384,582,12,0xff5f7c89,false);
            }
            c.restore();playRect.set(board.centerX()-dp(95),board.centerY()-dp(7),board.centerX()+dp(95),board.centerY()+dp(37));
            if(frame==null||paused||!error.isEmpty()){
                round(c,new RectF(board.centerX()-dp(150),board.centerY()-dp(65),board.centerX()+dp(150),board.centerY()+dp(70)),dp(9),0xf00e1721);
                String title=frame==null?"Cargando XI…":frame.get(7)==2?"Fin de la partida":frame.get(7)==3?"Cinco sectores completos":frame.get(7)==0?"Rompe el primer bloque":"Partida en pausa";
                p.setTextSize(dp(16));float tx=board.centerX()-p.measureText(title)/2;text(c,title,tx,board.centerY()-dp(32),dp(16),0xffe1eceb,true);
                if(frame!=null&&error.isEmpty())button(c,playRect,frame.get(7)>=2?"Nueva partida":frame.get(7)==0?"Jugar":"Continuar",true);
                if(!error.isEmpty()){text(c,"Error al ejecutar el programa",board.centerX()-dp(110),board.centerY()+dp(10),dp(12),0xffffaaa6,true);}
            }
            if(frame!=null){String stats=w<=dp(700)?String.format(Locale.ROOT,"%05d · RÉCORD %05d · %d VIDAS",frame.get(5),frame.get(10),frame.get(6)):saveStatus;text(c,stats,margin,h-dp(20),dp(10),0xff81949f,false);}
            String measured=frame==null||xiMs<0?"XI / Ether":String.format(Locale.ROOT,"XI %.2f ms · %d ticks/s · %d dibujos/s",xiMs,tps,fps);p.setTextSize(dp(9));text(c,measured,w-margin-p.measureText(measured),h-dp(20),dp(9),0xff72a38f,false);
        }
        @Override public boolean onTouchEvent(MotionEvent event){float x=event.getX(),y=event.getY();if(event.getActionMasked()==MotionEvent.ACTION_DOWN){startX=x;startY=y;moved=false;return true;}if(event.getActionMasked()==MotionEvent.ACTION_MOVE){if(Math.abs(x-startX)+Math.abs(y-startY)>dp(8))moved=true;if(y>=board.top&&scale>0)paddle=Math.max(0,Math.min(1000,Math.round((x-board.left)/scale)));return true;}if(event.getActionMasked()==MotionEvent.ACTION_UP){if(!moved){if(backRect.contains(x,y)){finish();return true;}if(resetRect.contains(x,y)){command=2;paused=true;return true;}if(pauseRect.contains(x,y)){if(paused)play();else pause();return true;}if(paused&&playRect.contains(x,y)){play();return true;}if(board.contains(x,y)&&scale>0)paddle=Math.max(0,Math.min(1000,Math.round((x-board.left)/scale)));}performClick();return true;}return true;}
        @Override public boolean performClick(){super.performClick();return true;}
    }
}
