// Test *the actual game scene* using the canonical native X Render observer.
// This source includes the JNI adapter in a host test translation unit solely
// to inspect its internal scene; production builds compile the adapter once.
#include "../app/src/main/cpp/velocity_xrender_jni.cpp"
#include <cassert>
#include <chrono>
#include <cstdint>
#include <iostream>
#include <set>

struct Readback {
  std::uint64_t hash=1469598103934665603ull;
  std::size_t count=0,hit=0;
  std::set<std::uint32_t> colors;
};
Readback capture(){
  Readback r;
  scene->prepare();
  scene->export_image([&](std::size_t,std::size_t,const Engine::Pixel& px){
    r.hash^=px.rgba;r.hash*=1099511628211ull;
    r.colors.insert(px.rgba);
    ++r.count;
    if(px.body>=0)++r.hit;
  });
  return r;
}
int main(){
  scene=std::make_unique<Engine>(320,180,16);
  const auto start=std::chrono::steady_clock::now();
  build(route(1100),1100,0,0,0,0);
  auto first=capture();
  auto elapsed=std::chrono::duration<double,std::milli>(
       std::chrono::steady_clock::now()-start).count();
  assert(first.count==320u*180u&&first.hit>0);
  assert(first.colors.size()>12);
  assert(scene->info().objects<4096);
  build(route(1100),1100,0,0,1,3);
  auto alternate=capture();
  assert(alternate.count==first.count&&alternate.hash!=first.hash);
  build(route(760),760,.23,1,0,2);
  auto next=capture();
  assert(next.hash!=first.hash);
  // HD 1280x720 native: actual camera rays and spatial surfaces, no upscaler.
  scene=std::make_unique<Engine>(1280,720,16);
  build(route(1100),1100,0,0,0,0);
  auto hd=capture();
  assert(hd.count==1280u*720u&&hd.hit>0&&hd.colors.size()>32);
  std::cout<<"REVERSE_VELOCITY_HD_NATIVE_OK pixels="<<hd.count<<" hash="<<hd.hash<<"\n";
  std::cout<<"REVERSE_VELOCITY_SCENE_OK pixels="<<first.count
           <<" objects="<<scene->info().objects
           <<" uniqueColors="<<first.colors.size()
           <<" firstFrameMs="<<elapsed
           <<" hashes="<<first.hash<<","<<alternate.hash<<","<<next.hash
           <<"\n";
}
