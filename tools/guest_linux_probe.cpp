// Development probe of a real, pinned upstream Linux Image. An unsupported
// instruction/register is a recorded engineering stop, never a claimed boot.
#include "minimal_guest.hpp"
#include <fstream>
#include <iostream>
using namespace reverse_pc::guest;
int main(int argc,char** argv){try{
  require(argc==2,"Expected an uncompressed Linux Image filename");std::ifstream in(argv[1],std::ios::binary);
  require(bool(in),"Cannot open Image");Bytes image((std::istreambuf_iterator<char>(in)),{});
  require(image.size()<=MinimalGuest::max_image,"Linux probe image too large");
  MinimalGuest guest(128*1024*1024,1048576);guest.load_linux_image(image);std::string console,reason="instruction_budget";
  for(unsigned block=0;block<500 && !guest.registers().halted;++block){
    try{auto result=guest.run(1000);console+=result.output;if(result.waiting){reason="waiting_for_device_or_interrupt";break;}}
    catch(const std::exception&){
      for(unsigned step=0;step<1000;++step){try{console+=guest.run(1).output;}catch(const std::exception& error){reason=error.what();break;}}
      break;
    }
  }
  std::cout<<"{\"upstream_linux\":\"6.1/830b3c68c1fb1e9176028d02ef86f3cf76aa2476\",\"guest\":"<<guest.statistics()
    <<",\"stop_reason\":"<<quote(reason)<<",\"console\":"<<quote(console)<<",\"linux_boot_complete\":false,\"android_boot\":false}\n";
  return 0;
}catch(const std::exception& error){std::cerr<<error.what()<<'\n';return 1;}}
