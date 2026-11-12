#include "ejecucion_gpu.hpp"
#include "graphics_gpu.hpp"
#include "visual_field.hpp"
#include <algorithm>
#include <array>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <iostream>
#include <stdexcept>
#include <vector>
namespace {
std::uint32_t bits(float x){std::uint32_t u;std::memcpy(&u,&x,4);return u;}
void need(bool ok,const char* why){if(!ok)throw std::runtime_error(why);}
xgpu::FieldRoot phases(std::uint32_t base,std::uint32_t stride,xgpu::Index count){using O=xgpu::StateOp;xgpu::Execution e(count,{},xgpu::ExecutionProfile::C12);e.initialize_global(xgpu::Field(count,xgpu::Mode({base,stride})));xgpu::Kernel k{{{O::Index,0},{O::LoadGlobal,1,0},{O::Constant,2,0,0,0,4095},{O::BitAnd,3,1,2},{O::FloatFromUnsigned,4,3},{O::Constant,5,0,0,0,bits(1.f/4096.f)},{O::FloatMultiply,6,4,5},{O::Output,6},{O::Halt}}};auto id=e.enqueue(k,count);need(e.run(),"C12 did not finish");auto out=e.dispatch(id).output;need(out&&e.dispatch(id).output_valid.full(),"C12 incomplete");return out;}
struct V3{float x,y,z;};V3 sub(V3 a,V3 b){return {a.x-b.x,a.y-b.y,a.z-b.z};}float dot(V3 a,V3 b){return a.x*b.x+a.y*b.y+a.z*b.z;}V3 cross(V3 a,V3 b){return {a.y*b.z-a.z*b.y,a.z*b.x-a.x*b.z,a.x*b.y-a.y*b.x};}V3 norm(V3 a){float n=std::sqrt(dot(a,a));return {a.x/n,a.y/n,a.z/n};}
using M4=std::array<float,16>;M4 product(const M4&a,const M4&b){M4 o{};for(int c=0;c<4;c++)for(int r=0;r<4;r++)for(int k=0;k<4;k++)o[c*4+r]+=a[k*4+r]*b[c*4+k];return o;}M4 perspective(float aspect){constexpr float pi=3.14159265358979323846f;float f=1/std::tan(52*pi/360),n=.15f,far=260;return {f/aspect,0,0,0,0,f,0,0,0,0,(far+n)/(n-far),-1,0,0,2*far*n/(n-far),0};}M4 look(V3 eye,V3 target){V3 f=norm(sub(target,eye));V3 up=std::abs(f.y)>.97f?V3{0,0,1}:V3{0,1,0};V3 side=norm(cross(f,up)),v=cross(side,f);return {side.x,v.x,-f.x,0,side.y,v.y,-f.y,0,side.z,v.z,-f.z,0,-dot(side,eye),-dot(v,eye),dot(f,eye),1};}
struct Px{float r=0,g=0,b=0,a=0;};
void splat(std::vector<Px>&img,int W,int H,float nx,float ny,float size,float r,float g,float b,float a){float cx=(nx*.5f+.5f)*W,cy=(ny*.5f+.5f)*H;float rad=std::max(.5f,size*.5f*float(H)/996.f);int x0=std::max(0,int(std::floor(cx-rad))),x1=std::min(W-1,int(std::ceil(cx+rad))),y0=std::max(0,int(std::floor(cy-rad))),y1=std::min(H-1,int(std::ceil(cy+rad)));for(int y=y0;y<=y1;++y)for(int x=x0;x<=x1;++x){float dx=(x+.5f-cx)/rad,dy=(y+.5f-cy)/rad,rr=dx*dx+dy*dy;if(rr>1)continue;float glow=1.f-std::clamp((rr-.12f)/.88f,0.f,1.f);float aa=std::clamp(a*glow,0.f,1.f);Px&p=img[std::size_t(y*W+x)];p.r=r*aa+p.r*(1-aa);p.g=g*aa+p.g*(1-aa);p.b=b*aa+p.b*(1-aa);p.a=aa+p.a*(1-aa);}}
}
int main(){try{constexpr int W=160,H=90;constexpr xgpu::Index n=1024;auto p=phases(137,97,n);std::array<float,3> eye{0,6,13};auto stream=xgpu::resolve_effects_graphics(p,n,eye);std::vector<const xgpu::GraphicsInstance*> vis;for(const auto&x:stream.variants[0])vis.push_back(&x);V3 e{0,6,13},t{0,2,0};auto vp=product(perspective(2105.f/996.f),look(e,t));auto field=xlab::visual::build(vis,vp,2105,996,12);std::vector<Px> ref(W*H),tile(W*H);for(const auto*x:vis){auto c=xlab::visual::clip(vp,*x);if(!(c[3]>1e-5f))continue;float nx=c[0]/c[3],ny=c[1]/c[3];if(nx<-1.1f||nx>1.1f||ny<-1.1f||ny>1.1f)continue;auto&q=x->payload;float size=std::clamp(std::abs(vp[5])*std::max(q[3],q[7])*996.f/std::max(std::abs(c[3]),.02f),1.f,96.f);splat(ref,W,H,nx,ny,size,q[12],q[13],q[14],q[15]);}for(const auto&q:field.tiles)splat(tile,W,H,q.ndc_x,q.ndc_y,q.size_px,q.color[0]/255.f,q.color[1]/255.f,q.color[2]/255.f,q.color[3]/255.f);double mae=0;for(size_t i=0;i<ref.size();++i)mae+=(std::abs(ref[i].r-tile[i].r)+std::abs(ref[i].g-tile[i].g)+std::abs(ref[i].b-tile[i].b)+std::abs(ref[i].a-tile[i].a))/4.;mae/=ref.size();need(mae<0.09,"visual MAE too high");std::cout<<"{\"suite\":\"regraphics_c01_visual_diff\",\"mae\":"<<mae<<",\"reference\":"<<n<<",\"tiles\":"<<field.tiles.size()<<"}\n";return 0;}catch(const std::exception&e){std::cerr<<"C01_DIFF_FAIL "<<e.what()<<'\n';return 1;}}
