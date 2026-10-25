import com.reversepc.boardwalk.ObserverMath;

public final class ObserverMathTest {
    static int checked=0;
    static void yes(boolean value,String message){checked++;if(!value)throw new AssertionError(message);}
    static void close(double value,double expected,double eps,String why){
        yes(Double.isFinite(value)&&Math.abs(value-expected)<=eps,
                why+" actual="+value+" expected="+expected);
    }
    public static void main(String[] ignored){
        double initial=ObserverMath.altitudeKm(0),last=ObserverMath.altitudeKm(1);
        close(initial,.006,1e-12,"boardwalk height");
        close(last,400,1e-9,"orbit height");
        double previous=initial;
        for(int i=1;i<=1000;i++){
            double altitude=ObserverMath.altitudeKm(i/1000.0);
            yes(altitude>previous,"altitude must be strictly monotonic");
            previous=altitude;
        }
        double nearH=ObserverMath.horizonKm(initial);
        yes(nearH>8 && nearH<10,"pedestrian-scale horizon distance");
        close(ObserverMath.horizonKm(400),Math.sqrt(400*(2*6371+400)),1e-6,"orbital horizon");
        yes(ObserverMath.gravityMs2(400)<ObserverMath.gravityMs2(0),"gravity must decrease");
        close(ObserverMath.relativeDensity(0),1,0,"density surface");
        yes(ObserverMath.relativeDensity(400)<1e-15,"exospheric density near zero");
        float[] basis=ObserverMath.tangentBasis();
        for(int i=0;i<3;i++){
            double norm=0;
            for(int k=0;k<3;k++)norm+=basis[3*i+k]*basis[3*i+k];
            close(norm,1,1e-6,"orthonormal column");
            for(int j=i+1;j<3;j++){
                double dot=0;for(int k=0;k<3;k++)dot+=basis[3*i+k]*basis[3*j+k];
                close(dot,0,1e-6,"orthogonal frame");
            }
        }
        float[] sun=ObserverMath.sunlight(135,30);
        close(sun[2],.5,1e-6,"sun elevation");
        close(ObserverMath.pitchDeg(0),-3.5,1e-10,"ground pitch");
        close(ObserverMath.pitchDeg(1),-24,1e-10,"orbit pitch");
        System.out.println("BOARDWALK_GEOMETRY_PASS checks="+checked+" R=6371km destination=400km");
    }
}
