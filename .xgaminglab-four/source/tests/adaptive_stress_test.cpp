#include "adaptive_visual_field.hpp"
#include <chrono>
#include <cstdint>
#include <iostream>
#include <stdexcept>
#include <vector>
int main(){
  constexpr int N=100000;
  std::vector<xgpu::GraphicsInstance> data(N);
  // Distinct independent visual inputs; NOT 100k independent textured meshes.
  std::vector<const xgpu::GraphicsInstance*> input;
  input.reserve(N);
  std::uint32_t state=0xA04D93u;
  auto rnd=[&](){state^=state<<13;state^=state>>17;state^=state<<5;return state;};
  for(int i=0;i<N;++i){
    auto& p=data[i].payload;
    p[0]=float(int(rnd()%100000)-50000)/50000.f;
    p[1]=float(int(rnd()%100000)-50000)/50000.f;
    p[2]=float(rnd()%1000)/1000.f;
    p[3]=.0025f;p[7]=.0025f;p[11]=1.f;
    p[12]=float(i%251)/250.f;p[13]=float((i/251)%251)/250.f;p[14]=float((i/1021)%251)/250.f;p[15]=.92f;
    input.push_back(&data[i]);
  }
  const xlab::visual::M4 identity={1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1};
  const auto start=std::chrono::steady_clock::now();
  const auto plan=xlab::adaptive::build(input,identity,1920,1080,12);
  const double millis=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-start).count();
  if(plan.projected!=N||plan.tiles.size()!=N||plan.merged!=0||plan.retained!=N)throw std::runtime_error("Independent RGBA/depth sprites were collapsed");
  std::cout<<"{\"suite\":\"adaptive_independent_splats_stress\",\"independent_sources\":"<<N
           <<",\"materialized_splats\":"<<plan.tiles.size()<<",\"collapsed\":"<<plan.merged
           <<",\"cpu_host_ms\":"<<millis<<",\"device_fps_measured\":false}\n";
}
