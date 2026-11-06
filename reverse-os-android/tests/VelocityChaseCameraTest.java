package com.reversepc.os;
public final class VelocityChaseCameraTest {
 static void check(boolean ok,String why){if(!ok)throw new AssertionError(why);}
 public static void main(String[] args){
  VelocityChaseCamera c=new VelocityChaseCamera();long t=1_000_000_000L;
  int s=c.update(0,false,false,4090,1800,0,false,t);
  s=c.update(0,false,false,3,1800,0,false,t+=20_000_000);
  check(VelocityOrbitMath.yaw(s)>3900||VelocityOrbitMath.yaw(s)<100,"yaw wraps smoothly through north");
  for(int i=0;i<250;i++)s=c.update(0,false,false,3,1800,0,true,t+=20_000_000);
  check(Math.abs(VelocityOrbitMath.yaw(s)-2048)<5,"reverse camera faces the direction of travel");
  int manual=VelocityOrbitMath.pack(700,-60);
  s=c.update(manual,true,false,3,1800,0,true,t+=20_000_000);check(s==manual,"touch orbit takes immediate priority");
  for(int i=0;i<50;i++)s=c.update(manual,false,true,3,1800,0,false,t+=20_000_000);
  check(s==manual,"paused photo preserves its chosen angle");
  for(int i=0;i<250;i++)s=c.update(manual,false,false,3,1800,0,false,t+=20_000_000);
  check(VelocityOrbitMath.yaw(s)<5||VelocityOrbitMath.yaw(s)>4091,"automatic recenter resumes while driving");
  check(VelocityOrbitMath.pitch(s)>0&&VelocityOrbitMath.pitch(s)<=32,"speed raises camera within bounds");
  c.reset();s=c.update(0,false,false,0,0,0,false,t);check(s==0,"stationary reset is stable");
  System.out.println("VELOCITY_CHASE_CAMERA_PASS wrap=true reverse=true manual=true photo=true recenter=true");
 }
}
