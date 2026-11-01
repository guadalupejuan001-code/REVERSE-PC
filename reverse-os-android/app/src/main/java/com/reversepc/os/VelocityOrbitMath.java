package com.reversepc.os;

/**
 * Pure-Java camera orbit state. The render inputs are ephemeral XI controls,
 * never changes to Ether car position, race physics or the 3D scene topology.
 *
 * Packed 32-bit value: lower 12 bits yaw in XI's 4096-angle circle;
 * upper 16 bits a signed camera tilt/height correction in centimeters.
 * Zero means legacy camera, providing backward-compatible XI observations.
 */
final class VelocityOrbitMath {
    static final int FULL_TURN=4096;
    static final int MIN_PITCH=-90,MAX_PITCH=125;
    private VelocityOrbitMath(){}

    static int yaw(int packed){return packed&4095;}
    static int pitch(int packed){return (short)(packed>>>16);}
    static int pack(int yaw,int pitch){
        if(pitch<MIN_PITCH||pitch>MAX_PITCH)throw new IllegalArgumentException("Camera elevation outside range");
        return ((pitch&65535)<<16)|(yaw&4095);
    }
    static int xiPitch(int packed){
        final int signed=pitch(packed);
        // Signed magnitude in a 9-bit wrapping integer, 0 means no offset.
        return signed<0?512+signed:signed;
    }
    static int drag(int packed,float dx,float dy,float viewWidth){
        if(!Float.isFinite(dx)||!Float.isFinite(dy)||!Float.isFinite(viewWidth))
            throw new IllegalArgumentException("Invalid touch delta");
        // Horizontal drag orbits the rendered camera, not the car steering.
        // Symmetric quantization matters: moving the same pixels back must undo
        // an orbit exactly, including half-unit deltas and negative gestures.
        int yawStep=Math.round(Math.abs(dx)*FULL_TURN/
            Math.max(360f,viewWidth*1.2f));
        int pitchStep=Math.round(Math.abs(dy)*.65f);
        int nextYaw=(yaw(packed)+(dx<0?-yawStep:yawStep))&4095;
        int nextPitch=Math.max(MIN_PITCH,Math.min(MAX_PITCH,
            pitch(packed)-(dy<0?-pitchStep:pitchStep)));
        return pack(nextYaw,nextPitch);
    }
}
