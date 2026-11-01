#include <algorithm>
#include <array>
#include <atomic>
#include <thread>
#include <exception>
#include <cstring>
#include <vector>
#include <limits>
#include <cstdint>
#include <stdexcept>
#include <string>
#include <iostream>
namespace isolated {
#include "../src/integration/xi_mesh_raster.inc"
}
using Mesh=isolated::MachineMeshRaster;
static unsigned calls=0;
static void ok(bool test,const char* message){++calls;if(!test)throw std::runtime_error(message);}
static std::uint32_t u32(const std::string& p,std::size_t at){
 return std::uint8_t(p[at])|(std::uint32_t(std::uint8_t(p[at+1]))<<8)|
 (std::uint32_t(std::uint8_t(p[at+2]))<<16)|(std::uint32_t(std::uint8_t(p[at+3]))<<24);
}
static unsigned u16(const std::string& p,std::size_t at){return std::uint8_t(p[at])|(unsigned(std::uint8_t(p[at+1]))<<8);}
int main(){try{
 Mesh gpu;
 gpu.begin(3840,2160,4,0);
 for(int row=0;row<16;++row)gpu.texture_row(0,row,"0123456789abcdef");
 gpu.vertex(0,{-100,100,100});gpu.vertex(1,{100,100,100});gpu.vertex(2,{-100,-100,100});
 gpu.texcoord(0,0,0);gpu.texcoord(1,16,0);gpu.texcoord(2,0,16);
 gpu.shade(0,10);gpu.shade(1,128);gpu.shade(2,255);
 gpu.textured_gradient_face(0,1,2,64,24,0,10,1000,1920,1080,1);
 const auto packet=gpu.finish();
 ok(packet.substr(0,4)=="XFG4","GPU transport magic");
 ok(u16(packet,4)==3840&&u16(packet,6)==2160,"genuine 4K viewport");
 ok(u32(packet,8)==4,"GPU revision 4");
 ok(u32(packet,12)==1,"one captured face");
 ok(packet.size()==16+2048+60,"bounded packet footprint");
 ok(std::uint8_t(packet[16])==0&&std::uint8_t(packet[31])==15,"texture contents");
 ok(u32(packet,16+2048+8)==100,"camera geometry preserved");
 ok(u16(packet,16+2048+36)==0,"first UV coordinate");
 ok(u16(packet,16+2048+48)==10*256,"XI Q8 shade preserved");
 ok(std::uint8_t(packet[16+2048+54])==64,"base palette preserved");
 ok(std::uint8_t(packet[16+2048+55])==24,"gradient ramp preserved");
 ok(std::uint8_t(packet[16+2048+56])==0,"texture selector preserved");
 ok(std::uint8_t(packet[16+2048+57])==10,"texture strength preserved");
 ok(gpu.pixel_tests()==0,"4K capture must not rasterize CPU pixels");
 bool bad=false;try{gpu.begin(3840,2160,2,0);}catch(const std::out_of_range&){bad=true;}
 ok(bad,"CPU 4K path must remain bounded");
 bad=false;try{gpu.begin(3840,1080,4,0);}catch(const std::out_of_range&){bad=true;}
 ok(bad,"capture requires exact 4K dimensions");
 Mesh ordinary;ordinary.begin(16,16,2,0);
 ordinary.triangle({0,0,10},{16,0,10},{0,16,10},3);
 ok(ordinary.finish().substr(0,4)=="XFS1","legacy raster remains intact");
 std::cout<<"XI_4K_GPU_PACKET_PASS checks="<<calls<<"\n";
 }catch(const std::exception& e){std::cerr<<"XI_4K_GPU_PACKET_FAIL "<<e.what()<<"\n";return 1;}}
