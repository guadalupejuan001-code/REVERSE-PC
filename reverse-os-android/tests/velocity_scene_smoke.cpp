// Native renderer smoke with road points actually computed by world.xi.
// Geometry stays in EtherRenderEngine. This test provides XI observations,
// never computes or duplicates the road equation in its own code.
#include "../app/src/main/cpp/velocity_xrender_jni.cpp"
#include <cassert>
#include <chrono>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <set>
struct Readback {
  std::uint64_t hash=1469598103934665603ull;
  std::size_t count=0,hit=0;
  std::set<std::uint32_t> colors;
};
Readback capture(){
  Readback r;scene->prepare();
  scene->export_image([&](std::size_t,std::size_t,const Engine::Pixel& px){
    r.hash^=px.rgba;r.hash*=1099511628211ull;
    r.colors.insert(px.rgba);++r.count;if(px.body>=0)++r.hit;
  });
  return r;
}
int main(int argc,char** argv){
  assert(argc==2);
  std::ifstream input(argv[1]);
  assert(input);
  for(std::size_t i=0;i<241;++i){
    double z=0,x=0;assert(bool(input>>z>>x));
    assert(std::abs(z-(-850.+10.*i))<.0001);
    xiTrackX[i]=x;
  }
  xiTrackReady=true;
  scene=std::make_unique<Engine>(320,180,16);
  const auto start=std::chrono::steady_clock::now();
  build(route(1100),1100,0,0,0,0);
  auto first=capture();
  const auto elapsed=std::chrono::duration<double,std::milli>(
       std::chrono::steady_clock::now()-start).count();
  assert(first.count==320u*180u&&first.hit>0);
  assert(first.colors.size()>12&&scene->info().objects<4096);
  build(route(1100),1100,0,0,1,3);
  auto alternative=capture();assert(alternative.hash!=first.hash);
  build(route(760),760,.23,1,0,2);
  auto third=capture();assert(third.hash!=first.hash);
  std::cout<<"REVERSE_VELOCITY_XI_SCENE_OK pixels="<<first.count
    <<" objects="<<scene->info().objects
    <<" uniqueColors="<<first.colors.size()
    <<" firstFrameMs="<<elapsed<<"\n";
}
