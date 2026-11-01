#pragma once
// Actual Ether Render X sparse observer; GLES only presents the resulting pixels.
#include "mundo_x/ether_render_spatial.hpp"
#include <memory>
#include <sstream>

namespace reverse_pc {
class PrismaXRender {
 public:
  using Spatial=mundo_x::EtherRenderSpatial;
  static constexpr std::size_t header=16,stride=12,max_cubes=64;
  struct Frame {
    std::vector<float> data;
    std::size_t count=0;
    explicit Frame(std::vector<float> values):data(std::move(values)){
      if(data.size()<header||data.size()>header+stride*max_cubes)
        throw std::invalid_argument("invalid X Render frame length");
      for(float value:data)if(!std::isfinite(value))throw std::invalid_argument("nonfinite X Render frame");
      auto in=[&](std::size_t i,float low,float high){if(data[i]<low||data[i]>high)throw std::invalid_argument("X Render frame field outside range");};
      if((data[0]!=1.f&&data[0]!=2.f)||data[15]!=std::floor(data[15]))throw std::invalid_argument("unsupported X Render frame");
      in(1,-1000000.f,1000000.f);in(2,0,2);in(3,0,1);in(4,0,1);in(5,0,1);
      in(6,.01f,8);in(7,.01f,8);for(unsigned i=8;i<14;++i)in(i,0,1);
      if(data[14]!=0.f&&data[14]!=1.f&&data[14]!=2.f)throw std::invalid_argument("invalid X Render quality");
      in(15,0,max_cubes);count=static_cast<std::size_t>(data[15]);
      if(data.size()!=header+count*stride)throw std::invalid_argument("X Render frame count mismatch");
      for(std::size_t n=0;n<count;++n){const auto i=header+n*stride;
        in(i,-100,100);in(i+1,-100,100);in(i+2,-4,100);in(i+3,.05f,5);
        for(unsigned c=4;c<=7;++c)in(i+c,0,1);
        in(i+8,-10,10);in(i+9,-1,3);in(i+10,0,1);
        // -1 denotes an arrowless mechanical body; 0..3 remain playable cut arrows.
        if(data[i+9]!=std::floor(data[i+9]))throw std::invalid_argument("invalid X Render cube direction");
        if(data[0]==1.f){if(data[i+11]!=0.f)throw std::invalid_argument("reserved v1 material field must be zero");}
        else if(data[i+11]<0.f||data[i+11]>3.f||data[i+11]!=std::floor(data[i+11]))
          throw std::invalid_argument("invalid X Render v2 material");
      }
    }
  };
  struct Metrics {
    std::size_t width=0,height=0,cubes=0,surface_pixels=0,candidate_queries=0,nonempty_tiles=0;
    std::size_t faceted=0,alloy=0,lenses=0;
    double cpu_ms=0.;
    std::uint64_t frames=0;
    std::string json()const{
      std::ostringstream s;s<<"{\"renderer\":\"ether-render-x-cpu\",\"presenter\":\"gles3-texture\",\"frames\":"<<frames
        <<",\"width\":"<<width<<",\"height\":"<<height<<",\"cubes\":"<<cubes<<",\"surface_pixels\":"<<surface_pixels
        <<",\"candidate_queries\":"<<candidate_queries<<",\"nonempty_tiles\":"<<nonempty_tiles
        <<",\"faceted\":"<<faceted<<",\"alloy\":"<<alloy<<",\"lenses\":"<<lenses<<",\"cpu_ms\":"<<cpu_ms<<"}";
      return s.str();
    }
  };
  void resize(std::size_t width,std::size_t height){
    if(!width||!height||width>8192||height>8192)throw std::invalid_argument("invalid X Render display size");
    display_w_=width;display_h_=height;
  }
  const Metrics& render(const Frame& f){
    if(!display_w_||!display_h_)throw std::logic_error("X Render display not sized");
    const auto start=std::chrono::steady_clock::now();
    const auto quality=static_cast<unsigned>(f.data[14]);
    const double budget=quality==1?900000.:quality==2?180000.:400000.*auto_scale_*auto_scale_;
    const double scale=std::min(1.,std::sqrt(budget/(double(display_w_)*display_h_)));
    const auto w=std::max<std::size_t>(1,std::lround(display_w_*scale)),h=std::max<std::size_t>(1,std::lround(display_h_*scale));
    if(!spatial_||w!=metrics_.width||h!=metrics_.height){
      spatial_=std::make_unique<Spatial>(w,h,16);rgba_.resize(w*h*4);
      metrics_.width=w;metrics_.height=h;
    }
    auto& scene=*spatial_;scene.clear_bodies();
    metrics_.faceted=metrics_.alloy=metrics_.lenses=0;
    const double fov=2.*std::atan(.5/double(f.data[7]))*180./std::acos(-1.);
    scene.set_camera({0,0,4.8},{0,0,0},fov);
    scene.set_screen_center(f.data[4],f.data[5]);
    for(std::size_t n=0;n<f.count;++n){const auto i=header+n*stride;const auto* p=f.data.data()+i;
      Spatial::Body b;b.id=static_cast<std::uint32_t>(n);b.center={p[0],p[1],-p[2]};
      b.cube_half=p[3]*.5;b.radius=std::sqrt(3.)*b.cube_half;
      b.color={{p[4],p[5],p[6]}};b.alpha=p[7];b.yaw=-p[8];b.pitch=.11;
      b.direction=static_cast<int>(p[9]);b.hot=p[10]>.5;
      b.material=f.data[0]==2.f?static_cast<int>(p[11]):0;
      if(b.material==1)++metrics_.faceted;
      else if(b.material==2)++metrics_.alloy;
      else if(b.material==3)++metrics_.lenses;
      scene.add_body(b);
    }
    // A display texture is necessarily dense. The observer only resolves
    // pixels in conservative surface footprints; no Pixel/depth framebuffer.
    std::fill(rgba_.begin(),rgba_.end(),0);
    const auto stats=scene.render_sparse_surfaces([&](std::size_t x,std::size_t y,const Spatial::Pixel& p){
      const auto i=(y*w+x)*4;rgba_[i]=(p.rgba>>16)&255u;rgba_[i+1]=(p.rgba>>8)&255u;
      rgba_[i+2]=p.rgba&255u;rgba_[i+3]=p.rgba>>24;
    });
    metrics_.cubes=f.count;metrics_.surface_pixels=stats.sparse_surfaces;
    metrics_.candidate_queries=stats.sparse_queries;metrics_.nonempty_tiles=stats.nonempty_tiles;
    metrics_.cpu_ms=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-start).count();++metrics_.frames;
    if(quality==0){
      accumulated_ms_+=metrics_.cpu_ms;
      if(++samples_>=60){const double mean=accumulated_ms_/samples_;
        if(mean>11.)auto_scale_=std::max(.55,auto_scale_-.1);
        else if(mean<5.)auto_scale_=std::min(1.,auto_scale_+.05);
        samples_=0;accumulated_ms_=0.;
      }
    }
    return metrics_;
  }
  const std::vector<std::uint8_t>& rgba()const{return rgba_;}
  const Metrics& metrics()const{return metrics_;}
 private:
  std::unique_ptr<Spatial> spatial_;
  std::vector<std::uint8_t> rgba_;
  std::size_t display_w_=0,display_h_=0,samples_=0;
  double auto_scale_=1.,accumulated_ms_=0.;
  Metrics metrics_;
};
} // namespace reverse_pc
