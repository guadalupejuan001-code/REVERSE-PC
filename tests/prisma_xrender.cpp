#include "prisma_xrender.hpp"
#include <iostream>
#include <random>
using R=mundo_x::EtherRenderSpatial;
using V=R::Vec3;
static std::uint64_t checks=0;
static void need(bool ok,const char* message){++checks;if(!ok)throw std::runtime_error(message);}
static V sub(V a,V b){return {a.x-b.x,a.y-b.y,a.z-b.z};}
static V cross(V a,V b){return {a.y*b.z-a.z*b.y,a.z*b.x-a.x*b.z,a.x*b.y-a.y*b.x};}
static double dot(V a,V b){return a.x*b.x+a.y*b.y+a.z*b.z;}
// Independent Moller-Trumbore triangle oracle, not the renderer's slab test.
static double triangle(V origin,V ray,V a,V b,V c){
  auto e1=sub(b,a),e2=sub(c,a),p=cross(ray,e2);double det=dot(e1,p);
  if(std::abs(det)<1e-12)return INFINITY;
  double inv=1./det;auto t=sub(origin,a);double u=dot(t,p)*inv;if(u<0||u>1)return INFINITY;
  auto q=cross(t,e1);double v=dot(ray,q)*inv;if(v<0||u+v>1)return INFINITY;
  double depth=dot(e2,q)*inv;return depth>1e-6?depth:INFINITY;
}
static std::array<V,8> vertices(const R::Body& b){
  std::array<V,8> out;for(unsigned i=0;i<8;++i){
    double x=(i&1?1.:-1.)*b.cube_half,y=(i&2?1.:-1.)*b.cube_half,z=(i&4?1.:-1.)*b.cube_half;
    double xx=x*std::cos(b.yaw)+z*std::sin(b.yaw),zz=-x*std::sin(b.yaw)+z*std::cos(b.yaw);
    out[i]={xx+b.center.x,y*std::cos(b.pitch)-zz*std::sin(b.pitch)+b.center.y,y*std::sin(b.pitch)+zz*std::cos(b.pitch)+b.center.z};
  }return out;
}
int main(){try{
  std::mt19937 rng(20261028);std::uniform_real_distribution<double> unit(0.,1.);
  const std::array<std::array<unsigned,3>,12> faces{{{{0,1,3}},{{0,3,2}},{{4,6,7}},{{4,7,5}},{{0,4,5}},{{0,5,1}},{{2,3,7}},{{2,7,6}},{{0,2,6}},{{0,6,4}},{{1,5,7}},{{1,7,3}}}};
  for(unsigned test=0;test<96;++test){
    constexpr std::size_t w=96,h=54;const double cy=.25+unit(rng)*.5,cx=.20+unit(rng)*.6,tanhalf=.45+unit(rng)*.5;
    R r(w,h,test%2?8:16);r.set_camera({0,0,4.8},{0,0,0},2*std::atan(tanhalf)*180/std::acos(-1.));r.set_screen_center(cx,cy);
    std::vector<std::array<V,8>> mesh;
    for(unsigned n=0;n<8;++n){R::Body b;b.id=n;b.center={(unit(rng)-.5)*10,(unit(rng)-.5)*7,2.-unit(rng)*13};
      b.cube_half=.2+unit(rng)*.9;b.radius=std::sqrt(3.)*b.cube_half;b.yaw=(unit(rng)-.5)*6.28;b.pitch=(unit(rng)-.5)*2.;b.direction=n%4;b.color={{.3,.8,.6}};
      mesh.push_back(vertices(b));r.add_body(b);
    }
    std::vector<bool> sparse(w*h,false);auto stats=r.render_sparse_surfaces([&](std::size_t x,std::size_t y,const R::Pixel& p){need(p.body>=0,"sparse emitted background");sparse[y*w+x]=true;});
    need(stats.sparse_queries<=w*h,"duplicate sparse pixel observations");
    for(std::size_t y=0;y<h;++y)for(std::size_t x=0;x<w;++x){
      V ray{(2*(x+.5)/w-2*cx)*double(w)/h*tanhalf,(2*(y+.5)/h-2*cy)*tanhalf,-1};double len=std::sqrt(dot(ray,ray));ray={ray.x/len,ray.y/len,ray.z/len};
      int id=-1;double depth=INFINITY;for(unsigned n=0;n<mesh.size();++n)for(const auto& face:faces){const auto& v=mesh[n];double t=triangle({0,0,4.8},ray,v[face[0]],v[face[1]],v[face[2]]);if(t<depth){depth=t;id=n;}}
      const auto p=r.pixel(x,y),all=r.pixel_reference(x,y);need(p==all,"region filtering changed ID/depth/RGBA");
      need(p.body==id,"slab differs from independent triangle oracle");
      if(id>=0){need(std::abs(p.depth-depth)<1e-8*std::max(1.,depth),"cube depth differs from triangle oracle");need(sparse[y*w+x],"sparse footprint omitted cube");need(r.depth_for_body(id,x,y)==p.depth,"surface depth reconstruction changed");}
      else need(!sparse[y*w+x],"sparse emitted false surface");
    }
  }
  // Near-plane and camera-inside cases use the same conservative fallback.
  R inside(41,29,8);inside.set_camera({0,0,0},{0,0,-1},80);R::Body b;b.cube_half=2;b.radius=std::sqrt(12.);inside.add_body(b);
  for(unsigned y=0;y<29;++y)for(unsigned x=0;x<41;++x)need(inside.pixel(x,y)==inside.pixel_reference(x,y),"camera-inside cube mismatch");
  using P=reverse_pc::PrismaXRender;std::vector<float> packet{1,0,.2,0,.5,.49,.6,1.2,.39,1,.71,1,.31,.45,0,1,0,0,0,.73,.39,1,.71,1,.1,0,1,0};
  P render;render.resize(1600,720);auto info=render.render(P::Frame(packet));
  need(info.surface_pixels>0&&info.cubes==1,"empty rendered cube");need(info.candidate_queries<info.width*info.height/3,"spatial observation traced the whole screen");
  need(render.rgba().size()==info.width*info.height*4,"invalid display texture extent");
  // Mechanical moving heads have no cutting arrows. Direction -1 is a
  // backward-compatible material choice on the same sparse X Render observer.
  auto machinery=packet;machinery[P::header+9]=-1.f;
  auto mechanicalFrame=P::Frame(machinery);
  need(mechanicalFrame.count==1,"mechanical body packet was not accepted");
  const auto machineInfo=render.render(mechanicalFrame);
  need(machineInfo.cubes==1&&machineInfo.surface_pixels>0,"arrowless body was not rendered");
  // ABI v2 adds material IDs in the formerly reserved 12th descriptor float.
  // ABI v1 retains its original strict validation and visual output.
  const auto baseline=render.rgba();
  for(unsigned material=0;material<=3;++material){
    auto improved=packet;improved[0]=2.f;improved[P::header+11]=static_cast<float>(material);
    const auto frame=P::Frame(improved);
    const auto& metrics=render.render(frame);
    need(metrics.surface_pixels==machineInfo.surface_pixels,
        "material changed conservative surface coverage");
    const auto rgba=render.rgba();
    need(rgba.size()==baseline.size(),"material changed framebuffer dimensions");
    std::size_t differences=0,alphaDifferences=0;
    for(std::size_t byte=0;byte<rgba.size();++byte){
      if(rgba[byte]!=baseline[byte]){
        ++differences;if(byte%4==3)++alphaDifferences;
      }
    }
    need(alphaDifferences==0,"material changed opacity/depth coverage");
    if(material==0)need(differences==0,"v2 legacy material changed old exact pixels");
    else need(differences>100,"material failed to shade native cube");
    need(metrics.faceted==(material==1?1u:0u) &&
         metrics.alloy==(material==2?1u:0u) &&
         metrics.lenses==(material==3?1u:0u),
         "native material selection metrics not grounded");
  }
  for(float wrong:{-1.f,.2f,1.5f,4.f}){
    auto bad=packet;bad[0]=2.f;bad[P::header+11]=wrong;
    bool rejected=false;
    try{P::Frame invalid(bad);}catch(const std::invalid_argument&){rejected=true;}
    need(rejected,"accepted invalid X Render material");
  }
  {
    auto bad=packet;bad[P::header+11]=1.f;
    bool rejected=false;
    try{P::Frame invalid(bad);}catch(const std::invalid_argument&){rejected=true;}
    need(rejected,"v1 reserved field accepted nonzero material");
  }
  {
    auto bad=packet;bad[0]=3.f;
    bool rejected=false;
    try{P::Frame invalid(bad);}catch(const std::invalid_argument&){rejected=true;}
    need(rejected,"unsupported future packet version was accepted");
  }
  for(float wrong:{-2.f,4.f,.5f}){
    auto invalidDirection=packet;invalidDirection[P::header+9]=wrong;
    bool rejected=false;
    try{P::Frame bad(invalidDirection);}catch(const std::invalid_argument&){rejected=true;}
    need(rejected,"invalid stage direction bypassed validation");
  }

  std::cout<<"{\"xrender_exact\":true,\"triangle_oracle_checks\":"<<checks<<",\"display\":"<<info.json()<<"}\n";
  for(unsigned k=0;k<packet.size();++k){auto invalid=packet;invalid[k]=NAN;bool rejected=false;try{P::Frame f(invalid);}catch(const std::invalid_argument&){rejected=true;}need(rejected,"accepted nonfinite packet");}
  return 0;
}catch(const std::exception& error){std::cerr<<error.what()<<'\n';return 1;}}
