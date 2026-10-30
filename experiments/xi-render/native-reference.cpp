// TEST HARNESS ONLY: calls the existing native EtherRenderEngine without
// introducing or changing any C++ rasterizer. The production experiment is XI.
#include "mundo_x/ether_render_engine.hpp"
#include <cassert>
#include <cmath>
#include <cstdint>
#include <iostream>
#include <stdexcept>
using Render=mundo_x::EtherRenderEngine;
using V=Render::Vec3;
static V vertex(double px,double py,int width,int height,double eyeDepth) {
  // Same perspective ray plane mapping as the canonical X Render camera.
  const double sx=(2.*px/width-1.)*(double(width)/height);
  const double sy=2.*py/height-1.;
  return {sx*eyeDepth,sy*eyeDepth,6.-eyeDepth};
}
int main(int argc,char** argv) {
  try {
    if(argc!=3)throw std::invalid_argument("expected width height");
    const int w=std::stoi(argv[1]),h=std::stoi(argv[2]);
    if(w<24||w>192||h<12||h>96||w%24||h%24||w!=2*h)
      throw std::invalid_argument("invalid benchmark dimensions");
    Render e(w,h,16);
    e.camera({0.,0.,6.},{0.,0.,0.},90.);
    const auto rear=[&](double x,double y){return vertex(x+.2,y+.1,w,h,6.);};
    const auto front=[&](double x,double y){return vertex(x+.2,y+.1,w,h,4.);};
    e.triangle(1,rear(w/8,h/8),rear(7*w/8,h/8),rear(w/2,7*h/8),
               {{.25,.75,.25}});
    e.triangle(2,front(w/4,h/3),front(3*w/4,h/3),front(w/2,5*h/6),
               {{.95,.27,.18}});
    e.prepare();
    std::uint64_t hash=0;
    for(int y=0;y<h;++y)for(int x=0;x<w;++x){
      const auto p=e.observe((std::size_t)x,(std::size_t)y);
      const int pixel=p.body<0?0:p.body==1?2:p.body==2?3:-100;
      if(pixel<0)throw std::runtime_error("unexpected primitive");
      hash=(hash*131u+(std::uint64_t)pixel)%1000000007u;
      std::cout<<"{\"type\":\"register\",\"register\":\"r12\",\"value\":"<<pixel<<"}\n";
    }
    std::cout<<"{\"type\":\"register\",\"register\":\"r14\",\"value\":"<<hash<<"}\n";
    return 0;
  } catch(const std::exception& error){
    std::cerr<<"XRENDER_NATIVE_REFERENCE_FAILED "<<error.what()<<"\n";
    return 1;
  }
}
