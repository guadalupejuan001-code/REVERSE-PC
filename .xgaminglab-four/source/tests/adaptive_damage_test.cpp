#include "visual_damage.hpp"
#include <array>
#include <iostream>
#include <stdexcept>
#include <vector>

using xlab::visual::VisualTile;
using xlab::damage::LayeredTileCache;
using xlab::damage::SurfaceHistory;
void check(bool pass,const char* reason){if(!pass)throw std::runtime_error(reason);}
int main(){
 try{
  constexpr int W=480,H=270;
  std::vector<VisualTile> a{
    {0.f,0.f,.75f,6.f,{0,0,255,160}},
    {.01f,0.f,.25f,6.f,{255,0,0,160}}
  };
  LayeredTileCache cache;
  auto first=cache.plan(a,W,H,H,12,77,true);check(first.full,"first frame should be full");cache.commit();
  auto unchanged=cache.plan(a,W,H,H,12,77,true);
  check(!unchanged.full&&unchanged.rect.empty()&&unchanged.unchanged_cells==2,"identical overlapping layers must be reusable");cache.commit();
  a[1].ndc_x+=.012f;
  auto moved=cache.plan(a,W,H,H,12,77,true);
  check(!moved.full&&!moved.rect.empty(),"moving one of two layers requires damage");
  check(moved.rect.x<240&&moved.rect.x+moved.rect.w>244,"damage must contain old/new sprite footprint");
  cache.commit();
  // Changing drawing order changes blending even when positions do not move.
  std::swap(a[0],a[1]);
  const auto reorder=cache.plan(a,W,H,H,12,77,true);
  check(!reorder.rect.empty(),"alpha layer order must invalidate the cell");cache.commit();
  SurfaceHistory age;
  age.presented(first,W,H);age.presented(moved,W,H);
  const auto older=age.required(reorder,2,W,H);
  check(!older.full&&!older.rect.empty(),"valid buffer-age restoration should include historical damage");
  const auto unknown=age.required(reorder,0,W,H);check(unknown.full,"unknown swapchain age must force full redraw");
  cache.reset();
  const auto invalidated=cache.plan(a,W,H,H,12,77,true);check(invalidated.full,"context reset must force full redraw");
  std::cout<<"{\"suite\":\"adaptive_multilayer_damage\",\"passed\":true,\"checks\":7,\"two_layers_one_cell\":true,\"context_fallback\":true}\n";
  return 0;
 }catch(const std::exception&ex){std::cerr<<"ADAPTIVE_DAMAGE_FAIL: "<<ex.what()<<'\n';return 1;}
}
