package com.reversepc.os;
import java.nio.file.*;
import java.util.*;
public final class VelocityWorldLightTest {
    static void check(boolean value,String why){if(!value)throw new AssertionError(why);}
    static int[] load(Path root,String name)throws Exception{return Files.readAllLines(root.resolve(name)).stream().mapToInt(s->Integer.parseInt(s,16)).toArray();}
    static double luma(int c){return .2126*((c>>16)&255)+.7152*((c>>8)&255)+.0722*(c&255);}
    public static void main(String[] args)throws Exception{
        Path root=Paths.get(args[0]);int[] a=load(root,"palette-day.txt"),b=load(root,"palette-dusk.txt"),c=load(root,"palette-night.txt");
        check(Arrays.equals(a,VelocityWorldLight.palette(a,b,c,0)),"authored daylight retained");
        check(Arrays.equals(b,VelocityWorldLight.palette(a,b,c,2048)),"authored dusk retained");
        check(Arrays.equals(c,VelocityWorldLight.palette(a,b,c,3072)),"authored night retained");
        check(luma(c[83])<luma(a[83])*.5,"car brightness follows world time");
        check(luma(c[225])>200&&luma(c[55])>luma(c[40])*4,"headlights remain visible above night asphalt");
        int[] before=VelocityWorldLight.palette(a,b,c,4095),after=VelocityWorldLight.palette(a,b,c,0);
        for(int i=0;i<256;i++)check(Math.abs(luma(before[i])-luma(after[i]))<2,"day cycle wraps smoothly");
        check(VelocityWorldLight.minutes(0)==720&&VelocityWorldLight.minutes(2048)==1140,"world clock matches noon and sunset");
        System.out.println("OPEN_FOREST_LIGHT_PASS palettes=3 smooth_cycle=true");
    }
}
