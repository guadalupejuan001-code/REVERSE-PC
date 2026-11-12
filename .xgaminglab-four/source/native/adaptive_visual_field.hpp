#pragma once
// REgraphics Adaptive Fidelity: retain splats independently whenever a lossy
// 12-pixel field merge could hide per-object color, coverage or depth.
// This is deliberately a sprite/field capability, not an arbitrary-mesh renderer.
#include "visual_field.hpp"
#include <algorithm>
#include <array>
#include <cmath>
#include <cstddef>
#include <cstdint>
#include <vector>

namespace xlab::adaptive {
struct Policy {
  // A conservative error budget, expressed in physical pixels and alpha units.
  float max_center_delta_px=.125f;
  float max_size_delta_px=.125f;
  float max_depth_delta=.0001f;
  float max_rgb_delta=1.f/255.f;
  float max_alpha_profile_error=.004f;
  std::size_t max_merge_members=8;
};
struct Plan {
  std::vector<visual::VisualTile> tiles;
  std::size_t visible=0, projected=0, merged=0, retained=0;
  std::size_t safe_cells=0, risky_cells=0;
  int cell_px=12;
};
namespace detail {
struct Projected {
  visual::VisualTile tile;
  std::array<float,4> rgba{};
  float xpx=0,ypx=0,size=1;
  std::size_t order=0;
};
inline bool mergeable(const std::vector<Projected>& src,const std::vector<std::size_t>& indices,const Policy& policy){
  if(indices.size()<2||indices.size()>policy.max_merge_members)return false;
  const auto& first=src[indices.front()];
  for(const auto index:indices){
    const auto& x=src[index];
    if(std::abs(x.xpx-first.xpx)>policy.max_center_delta_px||
       std::abs(x.ypx-first.ypx)>policy.max_center_delta_px||
       std::abs(x.size-first.size)>policy.max_size_delta_px||
       std::abs(x.tile.depth-first.tile.depth)>policy.max_depth_delta)return false;
    for(int k=0;k<3;++k)if(std::abs(x.rgba[k]-first.rgba[k])>policy.max_rgb_delta)return false;
  }
  // A single alpha at the center cannot in general reproduce repeated
  // alpha*glow blends away from the center. Check their profile directly.
  double center_transmission=1.0;
  for(auto index:indices)center_transmission*=1.0-src[index].rgba[3];
  const double merged_alpha=1.0-center_transmission;
  for(int i=0;i<=16;++i){
    const double glow=double(i)/16.;
    double transmission=1.0;
    for(auto index:indices)transmission*=1.0-double(src[index].rgba[3])*glow;
    if(std::abs((1.0-transmission)-merged_alpha*glow)>policy.max_alpha_profile_error)return false;
  }
  return true;
}
} // namespace detail

inline Plan build(const std::vector<const xgpu::GraphicsInstance*>& visible,
                  const visual::M4& view_projection,int width,int height,int cell_px=12,
                  const Policy& policy={}){
  Plan out;out.visible=visible.size();out.cell_px=std::max(4,cell_px);
  if(width<=0||height<=0||visible.empty())return out;
  const int cols=(width+out.cell_px-1)/out.cell_px,rows=(height+out.cell_px-1)/out.cell_px;
  std::vector<detail::Projected> projections;projections.reserve(visible.size());
  std::vector<int> heads(std::size_t(cols)*rows,-1),previous;previous.reserve(visible.size());
  for(std::size_t i=0;i<visible.size();++i){
    const auto* item=visible[i];if(!item)continue;
    const auto c=visual::clip(view_projection,*item);
    if(!(c[3]>1.e-5f)||!std::isfinite(c[3]))continue;
    const float nx=c[0]/c[3],ny=c[1]/c[3],ndc_depth=c[2]/c[3];
    if(!std::isfinite(nx)||!std::isfinite(ny)||!std::isfinite(ndc_depth)||
       nx<-1.1f||nx>1.1f||ny<-1.1f||ny>1.1f)continue;
    const auto& q=item->payload;
    if(!std::isfinite(q[3])||!std::isfinite(q[7]))continue;
    bool invalid=false;for(int k=12;k<16;++k)invalid|=!std::isfinite(q[k]);
    if(invalid)continue;
    detail::Projected x;
    x.xpx=(nx*.5f+.5f)*width;x.ypx=(ny*.5f+.5f)*height;
    x.size=std::clamp(std::abs(view_projection[5])*std::max(q[3],q[7])*height/
                        std::max(std::abs(c[3]),.02f),1.f,96.f);
    x.tile.ndc_x=nx;x.tile.ndc_y=ny;
    x.tile.depth=std::clamp(ndc_depth*.5f+.5f,0.f,1.f);
    x.tile.size_px=x.size;x.order=i;
    for(int k=0;k<4;++k){x.rgba[k]=std::clamp(q[12+k],0.f,1.f);x.tile.color[std::size_t(k)]=visual::byte(x.rgba[k]);}
    const int cx=std::clamp(int(x.xpx/out.cell_px),0,cols-1),cy=std::clamp(int(x.ypx/out.cell_px),0,rows-1);
    const auto cell=std::size_t(cy)*cols+cx;
    previous.push_back(heads[cell]);heads[cell]=int(projections.size());
    projections.push_back(x);++out.projected;
  }
  struct Ordered {visual::VisualTile tile;std::size_t index;};
  std::vector<Ordered> sorted;sorted.reserve(projections.size());
  std::vector<std::size_t> indices;indices.reserve(16);
  for(const int head:heads){
    if(head<0)continue;
    indices.clear();
    for(int cursor=head;cursor>=0;cursor=previous[std::size_t(cursor)])indices.push_back(std::size_t(cursor));
    std::reverse(indices.begin(),indices.end());
    if(!detail::mergeable(projections,indices,policy)){
      if(indices.size()>1)++out.risky_cells;
      out.retained+=indices.size();
      for(const auto index:indices)sorted.push_back({projections[index].tile,projections[index].order});
      continue;
    }
    // Very nearly identical weak-alpha splats: only this case is compressed.
    ++out.safe_cells;out.merged+=indices.size()-1;
    double transmission=1.;
    for(auto index:indices)transmission*=1.0-projections[index].rgba[3];
    auto result=projections[indices.front()].tile;
    result.color[3]=visual::byte(float(1.0-transmission));
    sorted.push_back({result,projections[indices.front()].order});
  }
  std::stable_sort(sorted.begin(),sorted.end(),[](const Ordered&a,const Ordered&b){
    if(a.tile.depth!=b.tile.depth)return a.tile.depth>b.tile.depth;
    return a.index<b.index;
  });
  for(const auto& item:sorted)out.tiles.push_back(item.tile);
  return out;
}
} // namespace xlab::adaptive
