// REVERSE VELOCITY: native presentation adapter over the pinned Mundo X engine.
// This file contains NO ray intersection, lighting, projection, or graphics engine.
// Every game pixel is supplied by mundo_x::EtherRenderEngine.
#include "mundo_x/ether_render_engine.hpp"
#include <jni.h>
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <memory>
#include <stdexcept>
#include <vector>
#include <string>

namespace {
using Engine=mundo_x::EtherRenderEngine;
using V=Engine::Vec3;
constexpr double PI=3.1415926535897932384626433832795;
std::unique_ptr<Engine> scene;
std::vector<jint> staging;
int cached_width=0,cached_height=0;

double route(double z){
    return 22.0*std::sin(z/230.0)+8.0*std::sin(z/78.0);
}
void ball(std::uint32_t& id,double x,double y,double z,double r,
          double red,double green,double blue){
    if(id>=4096)throw std::length_error("X Render scene body budget exceeded");
    scene->add({id++,V{x,y,z},r,{{red,green,blue}}});
}
std::uint32_t noise(int seed){
    std::uint32_t x=static_cast<std::uint32_t>(seed);
    x^=x<<13;x^=x>>17;x^=x<<5;
    return x;
}
void build(double x,double z,double yaw,int checkpoint){
    scene->clear();
    const double fx=std::sin(yaw),fz=-std::cos(yaw);
    const double eyeX=x-fx*12.0,eyeZ=z-fz*12.0;
    const V eye{eyeX,6.3,eyeZ},target{x+fx*18.0,1.2,z+fz*18.0};
    scene->camera(eye,target,64.0);
    std::uint32_t id=0;
    // The native background/terrain and all rays remain under one owner.
    ball(id,eyeX,-3000.0,eyeZ,3000.0, .24,.42,.25);
    ball(id,eyeX-500.0,-85.0,eyeZ-450.0,210.0,.27,.39,.32);
    ball(id,eyeX+370.0,-110.0,eyeZ-690.0,250.0,.23,.34,.36);
    // A sphere-only ribbon; genuine road meshes require extending X Render.
    // Keep the center-surface 1.5m above the ground analytic sphere.
    const int first=(int)std::floor((z+30.0)/5.0);
    for(int i=0;i<122;i++){
        double zz=(first-i)*5.0;
        ball(id,route(zz),-40.50,zz,42.0,.11,.13,.17);
    }
    // Fences, green vegetation, rocks, and distant buildings: all native X Render.
    const int first20=(int)std::floor((z+30.0)/20.0);
    for(int i=0;i<26;i++){
        const double zz=(first20-i)*20.0,c=route(zz);
        for(int side=-1;side<=1;side+=2){
            const double edge=c+side*14.5;
            ball(id,edge,.55,zz,0.55,.72,.75,.72);
            if(i%2==0){
                const double xx=c+side*(31.0+(noise(i*827+side*71+(int)zz)&31));
                const double yy=2.0+((noise(i*37+side*15)&15)/8.0);
                ball(id,xx,yy,zz-4.0,2.8,.10,.32,.15);
                ball(id,xx+1.2,yy+2.1,zz-3.0,2.2,.14,.39,.19);
                ball(id,xx,0.65,zz-4.0,0.70,.31,.25,.19);
            }
        }
    }
    const int gates[]={900,600,300,0,-300,-600};
    for(int i=0;i<6;i++){
        if(i<checkpoint)continue;
        const double zz=gates[i];
        if(std::abs(zz-z)>480.0)continue;
        double cx=route(zz);
        ball(id,cx-11.0,3.0,zz,1.05,.13,.64,.81);
        ball(id,cx+11.0,3.0,zz,1.05,.13,.64,.81);
    }
    // Compact original sports car, represented by X Render spheres only.
    // Vehicle silhouettes / wheels need triangle/mesh materials in the next stage.
    const double px=x,py=1.76,pz=z;
    const auto carpart=[&](double lateral,double forward,double up,
                            double radius,double r,double g,double b){
        const double cx=px+lateral*std::cos(yaw)+forward*fx;
        const double cz=pz-lateral*std::sin(yaw)+forward*fz;
        ball(id,cx,py+up,cz,radius,r,g,b);
    };
    carpart(0,0,0,1.55,.87,.13,.09);
    carpart(0,1.05,-.20,1.15,.81,.12,.08);
    carpart(0,-.92,-.13,1.10,.82,.11,.07);
    carpart(0,-.08,.75,.91,.18,.31,.38);
    carpart(-1.2,1.04,-.54,.51,.12,.13,.14);
    carpart(1.2,1.04,-.54,.51,.12,.13,.14);
    carpart(-1.2,-.95,-.54,.51,.12,.13,.14);
    carpart(1.2,-.95,-.54,.51,.12,.13,.14);
    carpart(-.7,1.47,-.16,.32,.92,.81,.57);
    carpart(.7,1.47,-.16,.32,.92,.81,.57);
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
    jlong xMm,jlong zMm,jint yaw16,jint checkpoint) {
  try {
    if(!rgba||width<128||height<72||width>640||height>360||
       static_cast<std::int64_t>(width)*height>env->GetArrayLength(rgba))
        throw std::invalid_argument("Invalid native X Render output buffer");
    if(!scene||cached_width!=width||cached_height!=height){
        scene=std::make_unique<Engine>(std::size_t(width),std::size_t(height),16);
        cached_width=width;cached_height=height;
    }
    const double yaw=double(yaw16&65535)*2.0*PI/65536.0;
    build(double(xMm)/1000.0,double(zMm)/1000.0,yaw,
          std::clamp(int(checkpoint),0,6));
    scene->prepare();
    staging.resize(std::size_t(width)*height);
    scene->export_image([&](std::size_t x,std::size_t y,const Engine::Pixel& pixel){
        staging[y*std::size_t(width)+x]=static_cast<jint>(pixel.rgba);
    });
    env->SetIntArrayRegion(rgba,0,jsize(staging.size()),staging.data());
  } catch(const std::exception& ex){
    java_error(env,ex.what());
  }
}
