#include <algorithm>
#include <array>
#include <chrono>
#include <cstdint>
#include <cstring>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>
namespace isolated {
#include "../src/integration/xi_mesh_raster.inc"
}
using Mesh=isolated::MachineMeshRaster;
static std::uint16_t u16(const std::string& s,int n){return std::uint8_t(s[n])|(unsigned(std::uint8_t(s[n+1]))<<8);}
static std::uint32_t u32(const std::string& s,int n){
 return std::uint32_t(std::uint8_t(s[n]))|(std::uint32_t(std::uint8_t(s[n+1]))<<8)|
   (std::uint32_t(std::uint8_t(s[n+2]))<<16)|(std::uint32_t(std::uint8_t(s[n+3]))<<24);
}
static void check(bool ok,const char* why){if(!ok)throw std::runtime_error(why);}
static void square(Mesh& m,int w,int h,int z,int material){
 m.triangle({0,0,z},{w,0,z},{0,h,z},material);
 m.triangle({w,0,z},{w,h,z},{0,h,z},material);
}
int main(){
 try{
  Mesh old,wide;
  old.begin(640,360,2,1);wide.begin(640,360,5,1);
  square(old,640,360,100,2);square(wide,640,360,100,2);
  old.triangle({0,18,10},{640,18,10},{100,240,10},4);
  wide.triangle({0,18,10},{640,18,10},{100,240,10},4);
  const auto saved=old.materials();
  const auto pixels=wide.finish();
  check(pixels.substr(0,4)=="XFB5"&&u16(pixels,4)==640&&u16(pixels,6)==360,"native header");
  check(u32(pixels,8)==5&&u32(pixels,12)==640*360&&pixels.size()==16+640*360,"native bytes");
  check(std::memcmp(pixels.data()+16,saved.data(),saved.size())==0,"same pixels as XI revision 2");
  check(wide.materials().size()==1,"strip-only z-buffer");
  Mesh large;large.begin(3840,2160,5,0);
  large.vertex(16383,{1,1,100});
  square(large,3840,2160,100,5);
  large.triangle({0,30,10},{3840,30,10},{3840,34,10},9);
  auto begin=std::chrono::steady_clock::now();
  auto out=large.finish();
  auto ms=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-begin).count();
  check(out.size()==16u+3840u*2160u&&u32(out,12)==3840u*2160u,"real 4K pixel count");
  auto pixel=[&](int x,int y){return std::uint8_t(out[16+std::size_t(y)*3840+x]);};
  check(pixel(3000,31)==9&&pixel(3000,32)==9,"triangle across tile boundary");
  check(pixel(2,100)==5&&pixel(3700,2000)==5,"raster depth and coverage");
  check(large.materials().size()==1,"4K strip-bounded depth allocation");
  bool bounded=false;try{large.begin(7680,4320,5,0);}catch(const std::exception&){bounded=true;}
  check(bounded,"8K transport must be explicitly unsupported until chunking");
  std::cout<<"XI_NATIVE_TILE_4K_PASS width=3840 height=2160 bytes="<<out.size()
           <<" rasterMs="<<ms<<" precision=match-revision-2\n";
 }catch(const std::exception& e){std::cerr<<"XI_NATIVE_TILE_FAIL "<<e.what()<<'\n';return 1;}
}