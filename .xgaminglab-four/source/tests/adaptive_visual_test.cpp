// REgraphics C01/C03 adversarial accuracy probe: intentionally looks for counterexamples.
// Uses exact C03 visual_field.hpp, no synthetic logical-object-count shortcuts.
#include "visual_field.hpp"
#include "adaptive_visual_field.hpp"
#include <algorithm>
#include <array>
#include <cmath>
#include <cstdint>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

using xlab::visual::M4;
using xlab::visual::VisualTile;
using Instance=xgpu::GraphicsInstance;
constexpr int W=192,H=128;
const M4 IDENTITY={1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1};
struct Pixel {float r=0,g=0,b=0,a=0;};
using Image=std::vector<Pixel>;

float coord_x(float px){return px*2.f/W-1.f;}
float coord_y(float py){return py*2.f/H-1.f;}
Instance actor(float px,float py,float depth,float size_px,float r,float g,float b,float a){
 Instance i; i.payload={coord_x(px),coord_y(py),depth*2.f-1.f,size_px/H,
                       1,0,0,size_px/H,0,1,0,1,r,g,b,a};return i;
}
float smoothstep(float low,float high,float x){float t=std::clamp((x-low)/(high-low),0.f,1.f);return t*t*(3.f-2.f*t);}
void draw(Image& pixels,float ndcx,float ndcy,float diameter,float r,float g,float b,float alpha){
 const float centerx=(ndcx*.5f+.5f)*W, centery=(ndcy*.5f+.5f)*H;
 const float radius=std::max(0.5f,diameter*0.5f);
 const int x0=std::max(0,int(std::floor(centerx-radius))), x1=std::min(W-1,int(std::ceil(centerx+radius)));
 const int y0=std::max(0,int(std::floor(centery-radius))), y1=std::min(H-1,int(std::ceil(centery+radius)));
 for(int y=y0;y<=y1;++y)for(int x=x0;x<=x1;++x){
  const float dx=(float(x)+0.5f-centerx)/radius,dy=(float(y)+0.5f-centery)/radius,dist2=dx*dx+dy*dy;
  if(dist2>1.f)continue;
  const float a=std::clamp(alpha*(1.f-smoothstep(.12f,1.f,dist2)),0.f,1.f);
  auto& q=pixels[std::size_t(y)*W+x]; q.r=r*a+q.r*(1-a);q.g=g*a+q.g*(1-a);q.b=b*a+q.b*(1-a);q.a=a+q.a*(1-a);
 }
}
Image exact(const std::vector<Instance>& source){
 Image img(std::size_t(W)*H);
 std::vector<const Instance*> order;for(const auto& a:source)order.push_back(&a);
 // Same back-to-front order used by transparent effects.
 std::stable_sort(order.begin(),order.end(),[](const Instance*a,const Instance*b){return a->payload[2]>b->payload[2];});
 for(const auto* i:order){const auto&q=i->payload;const float size=std::clamp(std::max(q[3],q[7])*H,1.f,96.f);draw(img,q[0],q[1],size,q[12],q[13],q[14],q[15]);}
 return img;
}
Image compact(const std::vector<VisualTile>& field,int fbo_divisor=1){
 Image img(std::size_t(W)*H);
 for(const auto& t:field)draw(img,t.ndc_x,t.ndc_y,t.size_px*fbo_divisor,t.color[0]/255.f,t.color[1]/255.f,t.color[2]/255.f,t.color[3]/255.f);
 return img;
}
struct Error {double total=0,foreground=0;int foreground_pixels=0,ref_covered=0,field_covered=0;};
Error compare(const Image& a,const Image& b){
 Error e;for(size_t i=0;i<a.size();++i){const auto&r=a[i],&c=b[i];
  const double d=(std::abs(r.r-c.r)+std::abs(r.g-c.g)+std::abs(r.b-c.b)+std::abs(r.a-c.a))/4.;e.total+=d;
  const bool fg=r.a>.05f||c.a>.05f; if(fg){e.foreground+=d;++e.foreground_pixels;}
  if(r.a>.05f){++e.ref_covered;} if(c.a>.05f){++e.field_covered;}
 }
 e.total/=a.size();if(e.foreground_pixels)e.foreground/=e.foreground_pixels;return e;
}
struct Result {std::string scenario;Error e;int input=0,compressed=0,collisions=0;float center_ref_r=0,center_field_r=0,center_ref_b=0,center_field_b=0;};
Result run(const std::string& name,const std::vector<Instance>& src,int fbo_divisor=1){
 std::vector<const Instance*> ptr;for(const auto& a:src)ptr.push_back(&a);
 const auto field=xlab::adaptive::build(ptr,IDENTITY,W,H,12);
 const auto ref=exact(src);const auto out=compact(field.tiles,fbo_divisor);const auto err=compare(ref,out);
 const std::size_t center=size_t(H/2)*W+W/2;
 Result x{name,err,int(src.size()),int(field.tiles.size()),int(field.merged),ref[center].r,out[center].r,ref[center].b,out[center].b};
 std::cout<<"{\"scenario\":\""<<name<<"\",\"source\":"<<x.input<<",\"tiles\":"<<x.compressed<<",\"collisions\":"<<x.collisions
   <<",\"full_mae\":"<<err.total<<",\"foreground_mae\":"<<err.foreground<<",\"foreground_pixels\":"<<err.foreground_pixels
   <<",\"reference_coverage\":"<<err.ref_covered<<",\"field_coverage\":"<<err.field_covered
   <<",\"center\":{\"ref_r\":"<<x.center_ref_r<<",\"field_r\":"<<x.center_field_r<<",\"ref_b\":"<<x.center_ref_b<<",\"field_b\":"<<x.center_field_b<<"}}\n";
 return x;
}
int main(){
 try{
  auto lossless=[&](const std::string&name,const std::vector<Instance>&input){
    const auto r=run(name,input);
    if(r.compressed!=int(input.size())||r.e.foreground>.008||r.e.total>.003)
      throw std::runtime_error("unacceptable field loss: "+name);
    return r;
  };
  const auto occlusion=lossless("opaque_depth",{actor(96,64,.8f,7,0,0,1,1),actor(96,64,.2f,7,1,0,0,1)});
  if(occlusion.center_ref_r<.90f||occlusion.center_field_r<.90f||occlusion.center_field_b>.02f)
    throw std::runtime_error("frontmost red surface lost");
  lossless("transparent_depth",{actor(96,64,.8f,7,0,0,1,.6f),actor(96,64,.2f,7,1,0,0,.6f)});
  const auto thin=lossless("thin_distinct",{actor(75,65,.5f,2,1,0,0,.9f),actor(81,65,.5f,2,0,1,0,.9f)});
  if(thin.e.field_covered!=thin.e.ref_covered)throw std::runtime_error("thin silhouette not preserved");
  lossless("small_point_true_fbo",{actor(96,64,.5f,2,1,0,0,.9f)});
  // Co-located almost-identical weak-alpha particles can be merged safely.
  std::vector<Instance> safe={actor(96,64,.5f,7,.5f,.3f,.2f,.035f),actor(96,64,.5f,7,.5f,.3f,.2f,.035f)};
  std::vector<const Instance*> ptr;for(const auto& e:safe)ptr.push_back(&e);
  const auto plan=xlab::adaptive::build(ptr,IDENTITY,W,H,12);
  if(plan.tiles.size()!=1||plan.merged!=1||plan.retained!=0||plan.safe_cells!=1)throw std::runtime_error("safe merging failed");
  const auto delta=compare(exact(safe),compact(plan.tiles));
  if(delta.foreground>.006)throw std::runtime_error("safe merge exceeds error budget");
  const auto risky=xlab::adaptive::build(std::vector<const Instance*>{&safe[0]},IDENTITY,W,H,12);
  if(risky.tiles.size()!=1||risky.tiles[0].size_px<6.9f)throw std::runtime_error("single point loses its physical size");
  // Invalidating identity/motion preserves independent splats at tiny separation.
  std::vector<Instance> moved={actor(96,64,.5f,7,1,0,0,.10f),actor(96.5f,64,.5f,7,1,0,0,.10f)};
  std::vector<const Instance*> moved_ptr;for(const auto& e:moved)moved_ptr.push_back(&e);
  const auto moved_plan=xlab::adaptive::build(moved_ptr,IDENTITY,W,H,12);
  if(moved_plan.tiles.size()!=2||moved_plan.risky_cells!=1)throw std::runtime_error("small moving offset was incorrectly merged");
  std::cout<<"{\"suite\":\"adaptive_visual_field\",\"counterexamples_fixed\":4,\"safe_merged\":1,\"safe_foreground_mae\":"<<delta.foreground<<",\"preserves_original_path\":true,\"physical_gpu_tested\":false}\n";
  return 0;
 }catch(const std::exception& ex){std::cerr<<"ADAPTIVE_FAIL: "<<ex.what()<<'\n';return 1;}
}
