package com.reversepc.os;

/** Display-only interpolation of the authored XI material palettes. */
final class VelocityWorldLight {
    private static final int[] PHASE={0,1536,2048,2560,3584,4096};
    private static final int[] CLOCK={720,1020,1140,1260,1740,2160};
    static int minutes(int phase){
        phase=Math.floorMod(phase,4096);int at=0;
        while(at<4&&phase>=PHASE[at+1])at++;
        return (CLOCK[at]+(CLOCK[at+1]-CLOCK[at])*(phase-PHASE[at])/(PHASE[at+1]-PHASE[at]))%1440;
    }
    static int[] palette(int[] day,int[] dusk,int[] night,int phase){
        if(day.length!=256||dusk.length!=256||night.length!=256)throw new IllegalArgumentException("World palettes require 256 materials");
        phase=Math.floorMod(phase,4096);int at=0;
        while(at<4&&phase>=PHASE[at+1])at++;
        int[][] colors={day,day,dusk,night,night,day};
        int a=phase-PHASE[at],length=PHASE[at+1]-PHASE[at];
        int[] result=new int[256];
        for(int i=0;i<256;i++){
            int rgb=0;
            for(int shift=0;shift<=16;shift+=8){
                int first=(colors[at][i]>>>shift)&255,last=(colors[at+1][i]>>>shift)&255;
                rgb|=(first+(last-first)*a/length)<<shift;
            }
            result[i]=rgb;
        }
        return result;
    }
}
