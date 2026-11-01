#include "prisma_xrender.hpp"
#include <algorithm>
#include <array>
#include <cmath>
#include <iomanip>
#include <iostream>
#include <numeric>
#include <stdexcept>
#include <vector>

// Reproducible render-cost characterization for the Ether Render X CPU core.
// This is isolated CPU work, NOT Android frame time or a proven phone FPS.
int main() {
  using Renderer=reverse_pc::PrismaXRender;
  struct Sample { double median=0.,p95=0.,surface_ratio=0.,queries_ratio=0.;std::size_t pixels=0; };
  std::array<Sample,3> samples;
  for(int quality=0;quality<3;++quality){
    Renderer renderer;
    renderer.resize(960,540);
    constexpr std::size_t bodies=18;
    std::vector<float> data(Renderer::header+Renderer::stride*bodies,0.f);
    data[0]=2;data[1]=0;data[2]=.65f;data[3]=0;
    data[4]=.5f;data[5]=.49f;data[6]=.8f;data[7]=1.25f;
    data[8]=.4f;data[9]=1.f;data[10]=.7f;
    data[11]=1.f;data[12]=.32f;data[13]=.55f;
    data[14]=static_cast<float>(quality);data[15]=static_cast<float>(bodies);
    for(std::size_t i=0;i<bodies;++i){
      auto* p=data.data()+Renderer::header+i*Renderer::stride;
      p[0]=float(int(i%6)-3)*.83f;
      p[1]=float(int(i%3)-1)*.60f;
      p[2]=2.f+float(i%9)*1.9f;
      p[3]=i<12?.62f:.37f;
      p[4]=i%2?.89f:.35f;p[5]=i%2?.30f:1.f;p[6]=.72f;
      p[7]=.94f;
      p[8]=.15f*float(i%4);
      p[9]=i<12?float(i%4):-1.f;
      p[10]=i%7==0?1.f:0.f;
      p[11]=i<12?1.f:i<15?2.f:3.f;
    }
    std::vector<double> durations;
    double surfaceRatio=0.,queriesRatio=0.;
    std::size_t pixels=0;
    for(int frame=0;frame<16;++frame){
      data[1]=float(frame)/60.f;
      data[2]=.55f+.25f*std::sin(float(frame)*.19f);
      const auto& metrics=renderer.render(Renderer::Frame(data));
      if(!std::isfinite(metrics.cpu_ms)||metrics.cpu_ms<0)
        throw std::runtime_error("nonfinite render duration");
      const std::size_t all=metrics.width*metrics.height;
      if(!all||metrics.surface_pixels>all||metrics.candidate_queries>all)
        throw std::runtime_error("sparse observer attempted invalid surface coverage");
      if(metrics.faceted!=12||metrics.alloy!=3||metrics.lenses!=3)
        throw std::runtime_error("material routing was lost during performance test");
      if(frame>=2){
        durations.push_back(metrics.cpu_ms);
        surfaceRatio+=double(metrics.surface_pixels)/double(all);
        queriesRatio+=double(metrics.candidate_queries)/double(all);
      }
      pixels=all;
    }
    std::sort(durations.begin(),durations.end());
    const auto n=durations.size();
    samples[quality]={
      durations[n/2],
      durations[std::min(n-1,std::size_t(std::ceil(n*.95))-1)],
      surfaceRatio/n,queriesRatio/n,pixels
    };
  }
  std::cout<<std::fixed<<std::setprecision(3)
           <<"{\"benchmark\":\"prisma-cycle6-native\",\"resolution\":\"960x540\""
           <<",\"bodies\":18,\"frames_per_quality\":16,\"warmup_frames\":2";
  static constexpr const char* labels[]={"auto","high","battery"};
  for(int q=0;q<3;++q){
    const auto& r=samples[q];
    std::cout<<",\""<<labels[q]<<"\":{\"median_cpu_ms\":"<<r.median
             <<",\"p95_cpu_ms\":"<<r.p95
             <<",\"surface_fraction\":"<<r.surface_ratio
             <<",\"candidate_fraction\":"<<r.queries_ratio
             <<",\"working_pixels\":"<<r.pixels<<"}";
  }
  std::cout<<"}\n";
  return 0;
}
