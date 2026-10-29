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
// Geometry is submitted to the canonical EtherRenderEngine; no pixels,
// rays, depth buffers, or lighting are calculated by this game adapter.
void triangle(std::uint32_t& id,V a,V b,V c,Color color){
  if(id>=4096)throw std::length_error("X Render: 4096 body scene limit");
  scene->triangle(id++,a,b,c,color);
}
void quad(std::uint32_t& id,V a,V b,V c,V d,Color color){
  triangle(id,a,b,c,color);
  triangle(id,a,c,d,color);
}
V road_point(double zz,double lateral,double y){
  const double derivative=slope(zz);
  const double inv=1./std::sqrt(1.+derivative*derivative);
  return {route(zz)+lateral*inv,y,zz-derivative*lateral*inv};
}
void road_strip(std::uint32_t& id,double z0,double z1,
                double left,double right,double y,Color color){
  quad(id,road_point(z0,left,y),road_point(z0,right,y),
          road_point(z1,right,y),road_point(z1,left,y),color);
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
  // Flat native X Render ground; a giant tangent sphere made distant roads
  // appear suspended when the vehicle moved hundreds of meters.
  quad(id,{eyeX-3400.,-.18,eyeZ-3400.},{eyeX+3400.,-.18,eyeZ-3400.},
          {eyeX+3400.,-.18,eyeZ+3400.},{eyeX-3400.,-.18,eyeZ+3400.},
          {.24,.41,.23});
  oval(id,{eyeX-470.,-75.,eyeZ-650.},{300.,155.,270.},.1,
       {.30,.39,.34});
  oval(id,{eyeX-670.,-60.,eyeZ-950.},{250.,110.,260.},.2,
       {.30,.38,.42});
  oval(id,{eyeX+710.,-40.,eyeZ-780.},{380.,100.,360.},-.18,
       {.33,.38,.37});
  oval(id,{470.,-.43,z-210.},{290.,.47,700.},0.,
       {.13,.37,.51}); // distant coast

  // Road surfaces are true triangle strips along the original mathematical
  // centerline, with tangent-adjusted lateral borders and stable IDs.
  // Streaming uses world coordinates; the route itself is not a tiled texture.
  constexpr double roadStep=10.;
  const int first=int(std::floor((z+53.)/roadStep));
  for(int k=0;k<62;++k){
    const double z0=(first-k)*roadStep,z1=z0-roadStep;
    road_strip(id,z0,z1,-9.0,9.0,.13,{.087,.103,.122});
    road_strip(id,z0,z1,-8.65,-8.49,.147,{.87,.84,.78});
    road_strip(id,z0,z1,8.49,8.65,.147,{.87,.84,.78});
    if(((first-k)&3)==0)
      road_strip(id,z0,z1,-.13,.13,.159,{.93,.76,.29});
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
  const Color side={body[0]*.74,body[1]*.74,body[2]*.74};
  const Color roof={body[0]*.85,body[1]*.85,body[2]*.85};
  if(camera!=2){
    // Original compact polygonal roadster, all triangles rendered by X Render.
    const auto point=[&](double lateral,double forward,double height){
      return car_point(x,z,yaw,lateral,forward,height);
    };
    // Body: top, front, rear, two sides, and a dark undercarriage.
    quad(id,point(-1.03,2.40,1.02),point(1.03,2.40,1.02),
         point(1.04,-2.40,1.07),point(-1.04,-2.40,1.07),body);
    quad(id,point(-1.03,2.40,.48),point(1.03,2.40,.48),
         point(1.03,2.40,1.02),point(-1.03,2.40,1.02),side);
    quad(id,point(-1.04,-2.40,.49),point(1.04,-2.40,.49),
         point(1.04,-2.40,1.07),point(-1.04,-2.40,1.07),side);
    for(int sideSign=-1;sideSign<=1;sideSign+=2){
      const double l=double(sideSign);
      quad(id,point(l*1.03,2.40,.49),point(l*1.03,2.40,1.02),
           point(l*1.04,-2.40,1.07),point(l*1.04,-2.40,.49),side);
    }
    // Cabin roof and sloping glass, clearly distinct from the paint.
    const Color glass={.10,.23,.31};
    quad(id,point(-.73,.70,1.91),point(.73,.70,1.91),
         point(.75,-.95,1.91),point(-.75,-.95,1.91),roof);
    quad(id,point(-.88,1.32,1.06),point(.88,1.32,1.06),
         point(.73,.70,1.88),point(-.73,.70,1.88),glass);
    quad(id,point(-.73,-.95,1.88),point(.73,-.95,1.88),
         point(.92,-1.50,1.07),point(-.92,-1.50,1.07),glass);
    quad(id,point(-.80,.68,1.86),point(-.82,-1.00,1.86),
         point(-1.01,-1.42,1.08),point(-.92,1.29,1.08),glass);
    quad(id,point(.80,.68,1.86),point(.82,-1.00,1.86),
         point(1.01,-1.42,1.08),point(.92,1.29,1.08),glass);
    quad(id,point(-1.02,2.30,.54),point(1.02,2.30,.54),
         point(1.02,2.30,.66),point(-1.02,2.30,.66),{.11,.12,.14});
    for(int sideSign=-1;sideSign<=1;sideSign+=2){
      oval(id,point(sideSign*.97,1.55,.49),{.28,.47,.49},yaw,{.065,.07,.085});
      oval(id,point(sideSign*.98,-1.55,.49),{.28,.47,.49},yaw,{.065,.07,.085});
      oval(id,point(sideSign*.75,2.39,.92),{.29,.115,.11},yaw,{.97,.92,.70});
      oval(id,point(sideSign*.75,-2.42,.94),{.30,.12,.11},yaw,{.89,.07,.04});
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
    if(!rgba||width<128||height<72||width>1280||height>720||
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
