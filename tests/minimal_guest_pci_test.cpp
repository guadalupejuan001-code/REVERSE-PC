#include "minimal_guest.hpp"
#include "minimal_guest_pci_demo.hpp"
#include <fstream>
#include <iostream>
#include <functional>
#include <filesystem>
using namespace reverse_pc::guest;
namespace {
unsigned checks=0;
void check(bool x,const char* m){++checks;if(!x)throw std::runtime_error(m);}
void rejected(const std::function<void()>& f,const char* m){bool bad=false;try{f();}catch(const std::exception&){bad=true;}check(bad,m);}
void field(Bytes& b,unsigned at,std::uint64_t n,unsigned size){for(unsigned i=0;i<size;i++)b.at(at+i)=std::uint8_t(n>>(8*i));}
void save(const std::string& path,const Bytes& b){std::ofstream f(path,std::ios::binary);f.write(reinterpret_cast<const char*>(b.data()),std::streamsize(b.size()));require(bool(f),"Cannot write fixture");}
void mov(Bytes& code,unsigned rd,std::uint64_t value){for(unsigned i=0;i<4;i++){auto op=(i?0xf2800000u:0xd2800000u)|(i<<21)|(unsigned((value>>(16*i))&65535)<<5)|rd;for(unsigned j=0;j<4;j++)code.push_back(std::uint8_t(op>>(j*8)));}}
std::uint64_t access(MinimalGuest& g,std::uint64_t address,std::uint64_t value,unsigned size,bool writing){
 Bytes code;mov(code,0,address);if(writing)mov(code,1,value);
 const auto op=(writing?(size==1?0x39000001u:size==2?0x79000001u:size==4?0xb9000001u:0xf9000001u):(size==1?0x39400001u:size==2?0x79400001u:size==4?0xb9400001u:0xf9400001u));for(unsigned j=0;j<4;j++)code.push_back(std::uint8_t(op>>(j*8)));
 const auto pc=g.registers().pc;for(unsigned i=0;i<code.size();i+=4)g.write(pc+i,get(code,i,4),4);
 g.run(code.size()/4);return g.registers().x[1];
}
void wr(MinimalGuest& g,std::uint64_t a,std::uint64_t v,unsigned n=4){access(g,a,v,n,true);}
std::uint64_t rd(MinimalGuest& g,std::uint64_t a,unsigned n=4){return access(g,a,0,n,false);}
struct Client {
 MinimalGuest& g;unsigned device,queue=0,available=0;std::uint64_t bar,desc,avail,used,input,output;
 Client(MinimalGuest& guest,unsigned d,unsigned q=0):g(guest),device(d),queue(q),bar(d?0x10010000:0x10000000),desc(0x41000000+std::uint64_t(d*2+q)*0x10000),avail(desc+0x1000),used(desc+0x2000),input(desc+0x3000),output(desc+0x5000){
  const auto config=GuestPciState::ecam+((d+1)*8*4096);
  wr(g,config+4,6,2);wr(g,bar+20,3,1);wr(g,bar,1);check(rd(g,bar+4)==1,"Missing VERSION_1 feature");wr(g,bar+8,1);wr(g,bar+12,1);wr(g,bar+8,0);wr(g,bar+12,d?0:512);wr(g,bar+20,11,1);
  wr(g,bar+22,q,2);wr(g,bar+24,8,2);wr(g,bar+32,desc,8);wr(g,bar+40,avail,8);wr(g,bar+48,used,8);wr(g,bar+28,1,2);wr(g,bar+20,15,1);
 }
 void descriptor(unsigned id,std::uint64_t a,unsigned n,unsigned flags,unsigned next=0){const auto at=desc+id*16;g.write(at,a,8);g.write(at+8,n,4);g.write(at+12,flags,2);g.write(at+14,next,2);}
 void kick(){g.write(avail+4+2*(available%8),0,2);available=(available+1)&65535;g.write(avail+2,available,2);wr(g,bar+0x1000+4*queue,queue,2);check(g.read(used+2,2)==available,"Used ring was not published");}
 unsigned block(unsigned type,std::uint64_t sector,const Bytes& bytes={},unsigned count=512){Bytes h(16);field(h,0,type,4);field(h,8,sector,8);h.insert(h.end(),bytes.begin(),bytes.end());for(unsigned i=0;i<h.size();i++)g.write(input+i,h[i],1);descriptor(0,input,unsigned(h.size()),1,1);if(type==0||type==8){descriptor(1,output,count,3,2);descriptor(2,output+0x1000,1,2);}else descriptor(1,output+0x1000,1,2);g.write(output+0x1000,99,1);kick();return unsigned(g.read(output+0x1000,1));}
 unsigned gpu(Bytes cmd,unsigned capacity=512){for(unsigned i=0;i<cmd.size();i++)g.write(input+i,cmd[i],1);descriptor(0,input,unsigned(cmd.size()),queue?0:1,1);if(!queue)descriptor(1,output,capacity,2);kick();return queue?0:unsigned(g.read(output,4));}
};
Bytes command(unsigned type,unsigned n){Bytes b(n);field(b,0,type,4);return b;}
void setrect(Bytes& b,unsigned w,unsigned h){field(b,32,w,4);field(b,36,h,4);}
}
int main(int argc,char** argv){try{
 std::filesystem::create_directories("build");std::filesystem::create_directories("evidence/c03");
 check(GuestSha256::hash({})=="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855","SHA256 empty vector failed");
 check(GuestSha256::hash(Bytes{'a','b','c'})=="ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad","SHA256 known vector failed");
 Bytes mutableImage(131072,0x35);save("build/c03-mutation.raw",mutableImage);const auto pinned=GuestBlockImage::open("build/c03-mutation.raw");pinned->read(0,16);mutableImage[65536]=0x42;save("build/c03-mutation.raw",mutableImage);rejected([&]{pinned->read(65536,512);},"Changed immutable source block was accepted");
 const std::string path=argc>1?argv[1]:"build/c03-fixture.raw";if(argc==1){Bytes b(65536);for(unsigned i=0;i<b.size();i++)b[i]=std::uint8_t(i*13);save(path,b);}
 const auto disk=GuestBlockImage::open(path);Bytes kernel(4096);field(kernel,0,0xd503201f,4);field(kernel,8,0x80000,8);field(kernel,16,kernel.size(),8);field(kernel,56,0x644d5241,4);
 MinimalGuest g(128*1024*1024,0);g.load_linux_image(kernel,{},"console=ttyAMA0",disk,true);
 check(rd(g,GuestPciState::ecam+0x8000)==0x10421af4,"Block PCI identity failed");check(rd(g,GuestPciState::ecam+0x10000)==0x10501af4,"GPU PCI identity failed");check(rd(g,GuestPciState::ecam+0x18000)==0xffffffff,"Absent PCI function must read all ones");
 wr(g,GuestPciState::ecam+0x8010,0xffffffff);check(rd(g,GuestPciState::ecam+0x8010)==0xffffc000,"PCI BAR probe mask failed");wr(g,GuestPciState::ecam+0x8010,0x10000000);
 Client block(g,0);check(rd(g,block.bar+0x3000,8)==disk->size()/512,"Block capacity is not the attached image");check(block.block(0,0)==0,"Actual disk read failed");const auto sector=disk->read(0,512);for(unsigned i=0;i<512;i++)check(g.read8(block.output+i)==sector[i],"DMA read changed immutable disk payload");
 check(g.machine().pci.irq(0),"Block completion did not assert INTx");check(rd(g,block.bar+0x2000,1)==1&&!g.machine().pci.irq(0),"ISR read did not deassert INTx");
 check(block.block(8,0,{},20)==0&&g.read8(block.output)=='R'&&g.read8(block.output+19)=='1',"Standard 20-byte block device ID failed");
 const std::uint64_t changed=disk->size()>2*1024*1024?2048:32;Bytes data(512,0xa5);check(block.block(1,changed,data)==0,"Guest disk write failed");check(block.block(0,changed)==0,"Written disk sector unreadable");for(unsigned i=0;i<512;i++)check(g.read8(block.output+i)==0xa5,"Disk XI overlay lost data");
 const auto beforeBad=g.snapshot();check(block.block(0,disk->size()/512+1)==1,"Out-of-range I/O did not return IOERR");check(block.block(123,0)==2,"Unknown block operation did not return UNSUPP");
 const auto snapshot=g.snapshot();rejected([&]{MinimalGuest::from_snapshot(snapshot);},"External disk silently missing on restore");auto restored=MinimalGuest::from_snapshot(snapshot,disk);check(restored.snapshot()==snapshot,"PCI queue/register state did not round trip");
 auto wrong=Bytes(65536,0x27);save("build/c03-wrong-disk.raw",wrong);const auto wrongDisk=GuestBlockImage::open("build/c03-wrong-disk.raw");rejected([&]{MinimalGuest::from_snapshot(snapshot,wrongDisk);},"Wrong disk image accepted");
 const auto immutable=GuestBlockImage::open(path);check(immutable->sha256()==disk->sha256(),"Guest writes modified source disk");
 Client gpu(g,1);auto info=command(0x100,24);field(info,4,1,4);field(info,8,0x1122334455667788,8);check(gpu.gpu(info)==0x1101&&g.read(gpu.output+8,8)==0x1122334455667788,"GPU display-info/fence response failed");check(g.read(gpu.output+32,4)==800&&g.read(gpu.output+36,4)==600,"Wrong GPU display geometry");
 const unsigned width=128,height=96;auto create=command(0x101,40);field(create,24,1,4);field(create,28,2,4);field(create,32,width,4);field(create,36,height,4);check(gpu.gpu(create)==0x1100,"GPU resource allocation failed");
 const std::uint64_t pixels=0x42000000;Bytes rgb;
 for(unsigned y=0;y<height;y++)for(unsigned x=0;x<width;x++){const unsigned color=(x<width/2?(y<height/2?0xff4040:0x4080ff):(y<height/2?0x40ff80:0xffffff));g.write(pixels+(y*width+x)*4,color,4);rgb.push_back(std::uint8_t(color>>16));rgb.push_back(std::uint8_t(color>>8));rgb.push_back(std::uint8_t(color));}
 auto attach=command(0x106,48);field(attach,24,1,4);field(attach,28,1,4);field(attach,32,pixels,8);field(attach,40,width*height*4,4);check(gpu.gpu(attach)==0x1100,"GPU physical backing attach failed");
 auto transfer=command(0x105,56);setrect(transfer,width,height);field(transfer,48,1,4);check(gpu.gpu(transfer)==0x1100,"GPU DMA transfer failed");
 auto scanout=command(0x103,48);setrect(scanout,width,height);field(scanout,44,1,4);check(gpu.gpu(scanout)==0x1100&&g.display_rgb()==rgb,"Scanout pixels differ from guest RAM pattern");
 // CPU writes and TRANSFER must not leak into display before RESOURCE_FLUSH.
 g.write(pixels,0,4);check(gpu.gpu(transfer)==0x1100&&g.display_rgb()==rgb,"Unflushed pixels became visible");
 auto flush=command(0x104,48);setrect(flush,1,1);field(flush,40,1,4);check(gpu.gpu(flush)==0x1100,"GPU flush failed");rgb[0]=rgb[1]=rgb[2]=0;check(g.display_rgb()==rgb,"Partial resource flush changed unrelated pixels");
 const auto visible=g.snapshot();auto reload=MinimalGuest::from_snapshot(visible,disk);check(reload.snapshot()==visible&&reload.display_rgb()==rgb,"Graphics lost pixels or queue state on restore");
 auto tiny=create;field(tiny,24,2,4);field(tiny,32,1,4);field(tiny,36,1,4);check(gpu.gpu(tiny)==0x1100,"Second GPU resource allocation failed");
 auto many=command(0x106,32+1000*16);field(many,24,2,4);field(many,28,1000,4);for(unsigned i=0;i<1000;i++){field(many,32+i*16,pixels,8);field(many,40+i*16,4096,4);}check(gpu.gpu(many)==0x1100,"Page-granular framebuffer backing was rejected");
 const auto pagewise=g.snapshot();check(MinimalGuest::from_snapshot(pagewise,disk).snapshot()==pagewise,"Large scatter-gather device state did not restore");
 // A malformed descriptor loop must roll back the complete native run.
 gpu.descriptor(0,gpu.input,24,1,0);g.write(gpu.avail+4+2*(gpu.available%8),0,2);g.write(gpu.avail+2,gpu.available+1,2);
 Bytes code;mov(code,0,gpu.bar+0x1000);mov(code,1,0);for(unsigned j=0;j<4;j++)code.push_back(std::uint8_t(0x79000001u>>(8*j)));const auto pc=g.registers().pc;for(unsigned i=0;i<code.size();i+=4)g.write(pc+i,get(code,i,4),4);const auto bad=g.snapshot();rejected([&]{g.run(code.size()/4);},"Cyclic DMA chain accepted");check(g.snapshot()==bad,"Malformed DMA changed authoritative state");
 // Test-only output is a protocol witness, never an Android screenshot.
 const std::string ppm="P6\n128 96\n255\n";Bytes picture(ppm.begin(),ppm.end());picture.insert(picture.end(),rgb.begin(),rgb.end());save("evidence/c03/pci-gpu-witness.ppm",picture);save("evidence/c03/pci-gpu-witness.rvg",visible);
 MinimalGuest demo(128*1024*1024,0);demo.load_linux_image(pci_graphics_witness_image(),{},"console=ttyAMA0",nullptr,true);const auto fresh=demo.snapshot();save("evidence/c03/pci-graphics-demo.rvg",fresh);save("evidence/c03/pci-machine.dtb",guest_device_tree(128*1024*1024,0,0,"console=ttyAMA0",true));
 const auto executed=demo.run(10000);check(executed.halted&&executed.output=="REVERSE: PCI GPU 2D OK\n"&&demo.machine().pci.scan_w==96&&demo.machine().pci.scan_h==64,"Actual AArch64 PCI graphics program failed");
 const auto finished=demo.snapshot();save("evidence/c03/pci-graphics-finished.rvg",finished);auto sliced=MinimalGuest::from_snapshot(fresh);std::string serial;
 while(!sliced.registers().halted){serial+=sliced.run(29).output;sliced=MinimalGuest::from_snapshot(sliced.snapshot());}
 check(sliced.snapshot()==finished&&serial==executed.output&&sliced.display_rgb()==demo.display_rgb(),"CPU-driven PCI graphics changed across checkpoint boundaries");
 const auto logical=std::to_string(GuestPciState::gpu_pixels+0x10000000),physical=std::to_string(UINT64_C(0x44000000));
 demo.apply_xi_delta("mem_bind "+logical+" 50000\nmem_bind "+physical+" 50000\nmem_store "+logical+" 64\n");demo.write(0x44000000,25,1);
 check(demo.display_rgb().at(2)==25&&demo.read8(0x44000000)==25&&demo.runtime().memory().stats().quantum_bindings==2,"Display pixels do not share the original quantum authority");
 check(MinimalGuest::from_snapshot(demo.snapshot()).snapshot()==demo.snapshot(),"Quantum display state did not persist");demo.apply_xi_delta("h 50000\n");rejected([&]{demo.display_rgb();},"Unresolved quantum display byte was silently materialized");
 std::cout<<"{\"checks\":"<<checks<<",\"pci_ecam\":true,\"virtio_block_read_write\":true,\"immutable_disk_sha256\":"<<quote(disk->sha256())<<",\"gpu_2d_pixels_verified\":true,\"cpu_graphics_program\":true,\"quantum_display_alias\":true,\"width\":128,\"height\":96,\"state_authority\":\"original XI/Ether\",\"android_boot\":false,\"android_games\":false}\n";
 return 0;
}catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 1;}}
