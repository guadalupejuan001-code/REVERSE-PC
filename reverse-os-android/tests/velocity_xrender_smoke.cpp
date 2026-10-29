#include "mundo_x/ether_render_engine.hpp"
#include <cassert>
#include <cstddef>
#include <cstdint>
#include <iostream>
int main(){
    mundo_x::EtherRenderEngine engine(192,108,16);
    engine.camera({0,3,10},{0,0,0},60);
    engine.add({0,{0,0,0},1.6,{{.9,.2,.1}}});
    engine.add({1,{6,-100,0},100,{{.2,.4,.2}}});
    engine.prepare();
    assert(engine.info().objects==2);
    auto p=engine.observe(96,54);
    assert(p.body>=0);
    std::uint64_t checksum=1469598103934665603ull;
    std::size_t count=0;
    engine.export_image([&](std::size_t x,std::size_t y,mundo_x::EtherRenderEngine::Pixel value){
        ++count;
        checksum^=value.rgba;
        checksum*=1099511628211ull;
        if(x==96&&y==54)assert(value==p);
    });
    assert(count==192*108);
    assert(checksum!=1469598103934665603ull);
    engine.camera({2,4,10},{0,0,0},60);
    engine.prepare();
    assert(engine.info().revision>0);
    std::cout<<"REVERSE_VELOCITY_XRENDER_OK objects="<<engine.info().objects
             <<" pixels="<<count<<" hash="<<checksum<<"\n";
}
