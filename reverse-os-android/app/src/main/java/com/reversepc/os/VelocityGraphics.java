package com.reversepc.os;

/** Immutable live graphics policy. These are real GPU targets, never upscaled labels. */
final class VelocityGraphics {
    static final VelocityGraphics[] ALL={
        new VelocityGraphics(0,"Ahorro",480,270,30,4,"Menor consumo","270p · efectos mínimos · hasta 30 FPS"),
        new VelocityGraphics(1,"Bajos",640,360,0,4,"Prioriza la fluidez","360p · texturas y efectos básicos"),
        new VelocityGraphics(2,"Medio",960,540,0,2,"El punto de equilibrio","540p · materiales y reflejos"),
        new VelocityGraphics(3,"Alto",1280,720,0,1,"Más detalle en movimiento","720p · iluminación y suavizado"),
        new VelocityGraphics(4,"Ultra",1920,1080,0,1,"Toda la calidad","1080p · suavizado y brillo completos")
    };
    final int id,width,height,maxFps,softwareStride;
    final String name,summary,description;
    private VelocityGraphics(int id,String name,int width,int height,int maxFps,int softwareStride,String summary,String description){
        this.id=id;this.name=name;this.width=width;this.height=height;this.maxFps=maxFps;
        this.softwareStride=softwareStride;this.summary=summary;this.description=description;
    }
    static VelocityGraphics fromId(int id){return ALL[id>=0&&id<ALL.length?id:2];}
    long frameBudgetNanos(){return maxFps==0?0:1_000_000_000L/maxFps;}
}
