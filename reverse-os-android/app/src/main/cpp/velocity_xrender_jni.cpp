// REVERSE VELOCITY native scene adapter.
// Geometry, light transport, camera rays, depth and surface observation are
// implemented exclusively by Mundo X: EtherRenderEngine/EtherSurfaceBuffer.
// No separate renderer or pixel/ray algorithm is implemented in this file.
#include "mundo_x/ether_render_engine.hpp"
#include <jni.h>
#include <algorithm>
#include <array>
#include <cmath>
#include <cstdint>
#include <memory>
#include <mutex>
#include <stdexcept>
#include <vector>

namespace {
using Engine=mundo_x::EtherRenderEngine;
using V=Engine::Vec3;
using Color=std::array<double,3>;
constexpr double PI=3.1415926535897932384626433832795;
std::mutex scene_mutex;
std::unique_ptr<Engine> scene;
std::vector<jint> staging;
int cached_width=0,cached_height=0;

double route(double z){
  return 22.0*std::sin(z/230.0)+8.0*std::sin(z/78.0);
}
double slope(double z){
  return 22.0/230.0*std::cos(z/230.0)+8.0/78.0*std::cos(z/78.0);
}
std::uint32_t noise(std::uint32_t x){
  x^=x<<13;x^=x>>17;x^=x<<5;
  return x;
}
void ball(std::uint32_t& id,V p,double r,Color c){
  if(id>=4096)throw std::length_error("X Render: 4096 body scene limit");
  scene->add({id++,p,r,c});
}
void oval(std::uint32_t& id,V p,V axes,double yaw,Color c){
  if(id>=4096)throw std::length_error("X Render: 4096 body scene limit");
  scene->ellipsoid(id++,p,axes,yaw,c);
}
V car_point(double x,double z,double yaw,double lateral,double forward,double height){
  const double sx=std::sin(yaw),cx=std::cos(yaw);
  return {x+cx*lateral+sx*forward,height,z-sx*lateral-cx*forward};
}

void build(double x,double z,double yaw,int checkpoint,int camera,int paint){
  scene->clear();
  const double fx=std::sin(yaw),fz=-std::cos(yaw);
  const double cameraDistance=camera==1?22.:camera==2?0.:12.;
  const double eyeHeight=camera==1?9.1:camera==2?1.77:6.4;
  const double eyeX=x-fx*cameraDistance,eyeZ=z-fz*cameraDistance;
  const V eye{eyeX,eyeHeight,eyeZ};
  const V target{x+fx*30.,camera==2?1.70:1.2,z+fz*30.};
  scene->camera(eye,target,camera==2?76.:64.0);
  std::uint32_t id=0;

  // Sky and earth are observed by the native same-owner analytic sphere path.
  // Presenting the pixels on Android does not create a new shader or raytracer.
  ball(id,{eyeX,0,eyeZ},6200.,{.31,.57,.82});
  ball(id,{eyeX,-3000.,eyeZ},3000.0,{.24,.41,.23});
  oval(id,{eyeX-470.,-75.,eyeZ-650.},{300.,155.,270.},.1,
       {.30,.39,.34});
  oval(id,{eyeX-670.,-60.,eyeZ-950.},{250.,110.,260.},.2,
       {.30,.38,.42});
  oval(id,{eyeX+710.,-40.,eyeZ-780.},{380.,100.,360.},-.18,
       {.33,.38,.37});
  oval(id,{470.,-.43,z-210.},{290.,.47,700.},0.,
       {.13,.37,.51}); // distant coast

  // Stream only the road ahead; the mathematical road exists independently
  // of this fixed-size body window and keeps precise driving checkpoints.
  const int first=int(std::floor((z+50.)/14.));
  for(int k=0;k<48;++k){
    const double zz=(first-k)*14.,xx=route(zz),angle=std::atan(slope(zz));
    oval(id,{xx,-.055,zz},{11.25,.32,17.8},angle,
         {.095,.115,.14});
    oval(id,{xx-8.9,.15,zz},{.20,.065,13.8},angle,
         {.83,.82,.73});
    oval(id,{xx+8.9,.15,zz},{.20,.065,13.8},angle,
         {.83,.82,.73});
    if((int(std::floor(zz/14.))&3)<2)
      oval(id,{xx,.258,zz},{.15,.045,5.2},angle,{.92,.73,.32});
  }

  // Vegetation / side objects positioned by coordinate hash only;
  // no saved million-object array is required.
  const int first20=int(std::floor((z+38.)/23.));
  for(int i=0;i<30;i++){
    const double zz=(first20-i)*23.,c=route(zz);
    for(int side=-1;side<=1;side+=2){
      const double edge=c+side*12.7;
      if(i%2==0)oval(id,{edge,.74,zz},{.19,.75,.25},0.,{.65,.67,.64});
      if(i%2){
        const std::uint32_t seed=noise(std::uint32_t(int(zz)*329+i*727+side*201));
        const double xx=c+side*(25.+(seed&31));
        const double high=3.0+((seed>>6)&7)*.64;
        oval(id,{xx,high*.35,zz-3.},{.39,high*.55,.37},0.,{.26,.21,.17});
        oval(id,{xx,high,zz-3.},{2.5,high*.68,2.7},0.,{.13,.32,.17});
        oval(id,{xx+1.,high+1.,zz-4.},{2.1,high*.53,2.0},0.,{.17,.40,.21});
      }
    }
    // The original inland city becomes visible as the player approaches.
    if(zz<400&&zz>-700&&i%3==0){
      const double bx=c+78.+(i%5)*7.;
      const double h=14.+(i%4)*9.;
      oval(id,{bx,h*.45,zz-17.},{5.,h*.50,7.},0.,{.32,.38,.44});
      oval(id,{bx+4.,h*.60,zz-17.},{.55,h*.18,3.5},0.,{.47,.62,.68});
    }
  }

  const int gates[]={900,600,300,0,-300,-600};
  for(int i=checkpoint;i<6;i++){
    const double zz=gates[i];
    if(std::abs(zz-z)>480.)continue;
    const double cx=route(zz);
    oval(id,{cx-11.0,3.1,zz},{.40,3.2,.42},0.,{.10,.65,.78});
    oval(id,{cx+11.0,3.1,zz},{.40,3.2,.42},0.,{.10,.65,.78});
    oval(id,{cx,6.3,zz},{11.0,.40,.50},0.,{.13,.68,.81});
  }

  const Color colors[]={
    {.85,.12,.09}, // crimson
    {.12,.60,.79}, // sky blue
    {.67,.73,.77}, // silver
    {.22,.68,.27}, // racing green
    {.93,.60,.13}  // warm gold
  };
  const Color body=colors[std::clamp(paint,0,4)];
  if(camera!=2){
    oval(id,car_point(x,z,yaw,0,0,.96),{1.05,.41,2.52},yaw,body);
    oval(id,car_point(x,z,yaw,0,1.20,.98),{1.00,.31,1.11},yaw,body);
    oval(id,car_point(x,z,yaw,0,-1.10,1.01),{1.00,.34,1.07},yaw,body);
    oval(id,car_point(x,z,yaw,0,-.05,1.56),{.84,.35,1.18},yaw,{.16,.29,.38});
    oval(id,car_point(x,z,yaw,0,-.13,1.89),{.67,.10,.81},yaw,body);
    oval(id,car_point(x,z,yaw,0,2.04,.88),{1.00,.11,.19},yaw,{.14,.15,.16});
    for(int side=-1;side<=1;side+=2){
      oval(id,car_point(x,z,yaw,side*.99,1.55,.50),{.33,.48,.62},yaw,{.06,.07,.09});
      oval(id,car_point(x,z,yaw,side*.99,-1.53,.50),{.33,.48,.62},yaw,{.06,.07,.09});
      oval(id,car_point(x,z,yaw,side*.69,2.35,1.10),{.30,.13,.12},yaw,{.87,.07,.04});
      oval(id,car_point(x,z,yaw,side*.75,-2.36,.97),{.34,.14,.11},yaw,{.96,.91,.66});
    }
  }
}
void java_error(JNIEnv* env,const char* message){
  if(env->ExceptionCheck())return;
  jclass cls=env->FindClass("java/lang/IllegalStateException");
  if(cls)env->ThrowNew(cls,message);
}
} // namespace

extern "C" JNIEXPORT void JNICALL
Java_com_reversepc_os_VelocityXSurface_renderNative(
  JNIEnv* env,jclass,jintArray rgba,jint width,jint height,
  jlong xMm,jlong zMm,jint yaw16,jint checkpoint,jint cameraMode,jint paintId){
  try{
    if(!rgba||width<128||height<72||width>640||height>360||
       static_cast<std::int64_t>(width)*height>env->GetArrayLength(rgba))
      throw std::invalid_argument("Invalid X Render output buffer");
    std::lock_guard<std::mutex> guard(scene_mutex);
    if(!scene||cached_width!=width||cached_height!=height){
      scene=std::make_unique<Engine>(std::size_t(width),std::size_t(height),16);
      cached_width=width;cached_height=height;
    }
    const double yaw=double(yaw16&65535)*2.0*PI/65536.0;
    build(double(xMm)/1000.0,double(zMm)/1000.0,yaw,
          std::clamp(int(checkpoint),0,6),
          std::clamp(int(cameraMode),0,2),std::clamp(int(paintId),0,4));
    scene->prepare();
    staging.resize(std::size_t(width)*height);
    // Mundo X ray_for uses bottom-up image coordinates; Android Bitmap is
    // top-down. This changes presentation only, never the X Render scene.
    scene->export_image([&](std::size_t xx,std::size_t yy,const Engine::Pixel& pixel){
      staging[(std::size_t(height)-1-yy)*std::size_t(width)+xx]=jint(pixel.rgba);
    });
    env->SetIntArrayRegion(rgba,0,jsize(staging.size()),staging.data());
  }catch(const std::exception& e){
    java_error(env,e.what());
  }
}
