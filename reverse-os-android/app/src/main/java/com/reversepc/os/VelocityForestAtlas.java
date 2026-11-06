package com.reversepc.os;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.DashPathEffect;
import android.view.MotionEvent;
import android.view.View;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

/** Presentation of the same immutable trail graph packed into world.xi. */
final class VelocityForestAtlas {
    static final class Trail {String name;float[] xy;}
    static final class Place {String name,kind;float x,z;}
    final List<Trail> trails=new ArrayList<>();
    final List<Place> places=new ArrayList<>();
    final float[] road;
    private final List<MapView> views=new ArrayList<>();
    private float carX,carZ;private int yaw,selected=-1;
    VelocityForestAtlas(Context context,float[] road)throws Exception{
        this.road=road;
        String text;try(InputStream in=context.getAssets().open("velocity/forest-atlas.txt");ByteArrayOutputStream b=new ByteArrayOutputStream()){
            byte[] chunk=new byte[4096];int n;while((n=in.read(chunk))>=0)b.write(chunk,0,n);text=b.toString("UTF-8");
        }
        if(!text.startsWith("RVAT1\n"))throw new IllegalArgumentException("Mapa forestal incompatible");
        for(String line:text.split("\n")){
            String[] a=line.split("\\|");
            if(a[0].equals("T")){Trail t=new Trail();t.name=a[1];String[] nodes=a[3].split(";");t.xy=new float[nodes.length*2];for(int i=0;i<nodes.length;i++){String[] p=nodes[i].split(",");t.xy[i*2]=Float.parseFloat(p[0])/100;t.xy[i*2+1]=Float.parseFloat(p[1])/100;}trails.add(t);}
            if(a[0].equals("P")){Place p=new Place();p.name=a[1];p.x=Float.parseFloat(a[2])/100;p.z=Float.parseFloat(a[3])/100;p.kind=a[4];places.add(p);}
        }
        if(trails.size()!=4||places.size()!=6)throw new IllegalArgumentException("Atlas incompleto");
    }
    void update(VelocityXiEngine.Snapshot s){float x=s.xCm/100f,z=s.zCm/100f;if(x==carX&&z==carZ&&yaw==s.yaw4096)return;carX=x;carZ=z;yaw=s.yaw4096;for(MapView v:views)v.invalidate();}
    String destination(){if(selected<0)return "Toca un lugar para marcar un destino";Place p=places.get(selected);return p.name+" · "+Math.round(Math.hypot(carX-p.x,carZ-p.z))+" m";}
    void select(int i){selected=i;for(MapView v:views)v.invalidate();android.util.Log.i("ReverseVelocity","MAP_WAYPOINT index="+i+" name="+(i<0?"none":places.get(i).name));}
    MapView view(Context context,boolean large){MapView v=new MapView(context,large);views.add(v);return v;}
    void release(MapView v){views.remove(v);}
    final class MapView extends View {
        private final boolean large;
        private final Paint p=new Paint(Paint.ANTI_ALIAS_FLAG);
        private final Path path=new Path();
        private float scale,ox,oy;
        private final float density;
        MapView(Context c,boolean large){super(c);this.large=large;density=c.getResources().getDisplayMetrics().density;setMinimumHeight((int)(large?150:68)*Math.round(density));setClickable(true);setContentDescription(large?"Mapa completo. Carretera, cuatro senderos, laguna y seis destinos":"Abrir mapa forestal. Carretera y senderos cercanos");}
        private float x(float x,float z){return large?ox+z*scale:ox+(x-carX)*scale;}
        private float y(float x,float z){return large?oy+x*scale:oy-(z-carZ)*scale;}
        private void route(Canvas c,float[] nodes,int color,float width,boolean dash){
            path.reset();for(int i=0;i<nodes.length;i+=2){float x=x(nodes[i],nodes[i+1]),y=y(nodes[i],nodes[i+1]);if(i==0)path.moveTo(x,y);else path.lineTo(x,y);}
            p.setStyle(Paint.Style.STROKE);p.setColor(color);p.setStrokeWidth(width*density);p.setStrokeCap(Paint.Cap.ROUND);p.setPathEffect(dash?new DashPathEffect(new float[]{4*density,3*density},0):null);c.drawPath(path,p);p.setPathEffect(null);
        }
        @Override protected void onDraw(Canvas c){
            super.onDraw(c);p.setStyle(Paint.Style.FILL);p.setColor(0xd9161e1d);c.drawRoundRect(0,0,getWidth(),getHeight(),10*density,10*density,p);c.save();c.clipRect(4,4,getWidth()-4,getHeight()-4);
            if(large){scale=Math.min((getWidth()-36*density)/1650f,(getHeight()-48*density)/480f);ox=18*density;oy=getHeight()*.48f;}
            else{scale=Math.min(getWidth(),getHeight())/180f;ox=getWidth()*.5f;oy=getHeight()*.52f;}
            // Muted contour bands communicate the raised valley sides.
            p.setColor(0xff263e31);for(int side:new int[]{-1,1}){path.reset();for(int i=0;i<road.length;i+=2){float px=x(road[i]+side*90,road[i+1]),py=y(road[i]+side*90,road[i+1]);if(i==0)path.moveTo(px,py);else path.lineTo(px,py);}p.setStyle(Paint.Style.STROKE);p.setStrokeWidth(22*scale);c.drawPath(path,p);}
            p.setStyle(Paint.Style.FILL);p.setColor(0xff355f6c);float[] lake=new float[28];for(int i=0;i<14;i++){lake[i*2]=road[(49+i)*2]+34;lake[i*2+1]=road[(49+i)*2+1];}route(c,lake,0xff356576,large?11:7,false);
            route(c,road,0xff0d1a1d,large?6:5,false);route(c,road,0xffd6dfce,large?2.5f:2,false);
            for(Trail t:trails)route(c,t.xy,0xffc09260,large?2.3f:1.8f,true);
            if(selected>=0){Place a=places.get(selected);route(c,new float[]{carX,carZ,a.x,a.z},0xff8ce6d6,1,true);}
            for(int i=0;i<places.size();i++){Place a=places.get(i);float px=x(a.x,a.z),py=y(a.x,a.z);p.setStyle(Paint.Style.FILL);p.setColor(i==selected?0xffffd78c:0xffb7c7af);c.drawCircle(px,py,(i==selected?4:2.8f)*density,p);if(large){p.setTextSize(9*density);p.setShadowLayer(2,0,1,0xff10191a);c.drawText(a.name,px+5*density,py+(a.kind.equals("view")?-7:12)*density,p);p.clearShadowLayer();}}
            float px=x(carX,carZ),py=y(carX,carZ);p.setColor(0xffc4ef82);path.reset();double a=yaw*Math.PI/2048;float dx=(float)Math.sin(a),dz=(float)Math.cos(a);float fx=large?dz:dx,fy=large?dx:-dz,r=6*density;path.moveTo(px+fx*r,py+fy*r);path.lineTo(px-fx*r*.6f-fy*r*.6f,py-fy*r*.6f+fx*r*.6f);path.lineTo(px-fx*r*.6f+fy*r*.6f,py-fy*r*.6f-fx*r*.6f);path.close();c.drawPath(path,p);
            p.setTextSize((large?10:8)*density);p.setColor(0xffd7e7de);c.drawText(large?"N →   Asfalto ━  Tierra ···   Agua azul":"N ↑",8*density,12*density,p);
            if(!large&&selected>=0){p.setTextSize(8*density);c.drawText(Math.round(Math.hypot(carX-places.get(selected).x,carZ-places.get(selected).z))+" m",6*density,getHeight()-5*density,p);}
            c.restore();
        }
        @Override public boolean onTouchEvent(MotionEvent e){if(!large)return super.onTouchEvent(e);if(e.getActionMasked()==MotionEvent.ACTION_UP){int best=-1;float d=34*density;for(int i=0;i<places.size();i++){Place a=places.get(i);float n=(float)Math.hypot(e.getX()-x(a.x,a.z),e.getY()-y(a.x,a.z));if(n<d){d=n;best=i;}}if(best>=0)select(best);performClick();return true;}return true;}
        @Override public boolean performClick(){super.performClick();return true;}
    }
}
