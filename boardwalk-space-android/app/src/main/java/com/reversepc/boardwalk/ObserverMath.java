package com.reversepc.boardwalk;

/** Pure geodetic observer math; no device, GPU or simulator dependencies. */
public final class ObserverMath {
    public static final double EARTH_RADIUS_KM = 6371.0; // NASA mean spherical radius
    public static final double LATITUDE_DEG = 39.3584;   // Approx. Steel Pier landward Boardwalk
    public static final double LONGITUDE_DEG = -74.4214;
    public static final double EYE_ALTITUDE_KM = 0.006;  // Boardwalk height + eyes, nominal
    public static final double MAX_ALTITUDE_KM = 400.0;
    public static final double AIR_SCALE_HEIGHT_KM = 8.5; // NASA reference mean
    private ObserverMath() {}

    public static double altitudeKm(double fraction) {
        double f = Math.max(0.0, Math.min(1.0, fraction));
        final double characteristicKm = .035;
        return EYE_ALTITUDE_KM + characteristicKm *
                Math.expm1(f * Math.log1p((MAX_ALTITUDE_KM - EYE_ALTITUDE_KM) / characteristicKm));
    }

    public static double horizonKm(double altitudeKm) {
        double h = Math.max(0.0, altitudeKm);
        return Math.sqrt(h * (2.0 * EARTH_RADIUS_KM + h));
    }

    public static double gravityMs2(double altitudeKm) {
        double ratio = EARTH_RADIUS_KM / (EARTH_RADIUS_KM + Math.max(0, altitudeKm));
        return 9.80665 * ratio * ratio;
    }

    public static double relativeDensity(double altitudeKm) {
        return Math.exp(-Math.max(0, altitudeKm)/AIR_SCALE_HEIGHT_KM);
    }

    /** Automatic virtual-camera angle, not a trajectory or human motion model. */
    public static double pitchDeg(double fraction) {
        double f = Math.max(0,Math.min(1, fraction));
        double smooth = f*f*(3-2*f);
        return -3.5 - 20.5*smooth;
    }

    /** Earth-centred, Earth-fixed orthonormal basis; columns = East, North, Up. */
    public static float[] tangentBasis() {
        double lat=Math.toRadians(LATITUDE_DEG);
        double lon=Math.toRadians(LONGITUDE_DEG);
        double sLat=Math.sin(lat),cLat=Math.cos(lat);
        double sLon=Math.sin(lon),cLon=Math.cos(lon);
        return new float[]{(float)-sLon,(float)cLon,0f,
                (float)(-sLat*cLon),(float)(-sLat*sLon),(float)cLat,
                (float)(cLat*cLon),(float)(cLat*sLon),(float)sLat};
    }

    /** Local Sun from azimuth (clockwise from North) and elevation. */
    public static float[] sunlight(double azimuthDeg,double elevationDeg) {
        double a=Math.toRadians(azimuthDeg),e=Math.toRadians(elevationDeg);
        return new float[]{(float)(Math.sin(a)*Math.cos(e)),
                (float)(Math.cos(a)*Math.cos(e)),(float)Math.sin(e)};
    }
}
