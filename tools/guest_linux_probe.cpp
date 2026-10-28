// Development probe of a real, pinned upstream Linux Image. An unsupported
// instruction/register is a recorded engineering stop, never a claimed boot.
#include "minimal_guest.hpp"
#include <fstream>
#include <chrono>
#include <iostream>
using namespace reverse_pc::guest;
int main(int argc,char** argv){try{
  require(argc>=2&&argc<=5,"Expected Image [instruction_budget] [checkpoint] [initrd]");
  const auto begin=std::chrono::steady_clock::now();
  const auto budget=argc>=3?std::stoull(argv[2]):500000;require(budget>0&&budget<=100000000,"Probe budget must be 1..100000000");std::ifstream in(argv[1],std::ios::binary);
  require(bool(in),"Cannot open Image");Bytes image((std::istreambuf_iterator<char>(in)),{});
  require(image.size()<=MinimalGuest::max_image,"Linux probe image too large");
  MinimalGuest guest(128*1024*1024,1048576);Bytes initrd;if(argc==5){std::ifstream rd(argv[4],std::ios::binary);require(bool(rd),"Cannot open initrd");initrd.assign(std::istreambuf_iterator<char>(rd),{});}
  guest.load_linux_image(image,initrd);std::string console,reason="instruction_budget";
  for(std::uint64_t step=0;step<budget && !guest.registers().halted;step+=10000){
    const auto count=std::min<std::uint64_t>(10000,budget-step);
    try{auto result=guest.run(count);console+=result.output;if(result.waiting){reason="waiting_for_device_or_interrupt";break;}}
    catch(const std::exception&){
      // Locate the first rejected transition without replaying thousands of
      // one-instruction COW transactions over a large already-written state.
      const auto beginning=guest;auto good=guest;std::string prefix;
      std::uint64_t low=0,high=count;
      while(low+1<high){const auto middle=low+(high-low)/2;auto trial=beginning;
        try{const auto run=trial.run(middle);low=middle;good=std::move(trial);prefix=run.output;}
        catch(const std::exception&){high=middle;}
      }
      guest=std::move(good);console+=prefix;
      try{guest.run(1);reason="probe_localization_error";}catch(const std::exception& error){reason=error.what();}
      break;
    }
  }
  const auto state=guest.snapshot();if(argc>=4){std::ofstream out(argv[3],std::ios::binary);out.write(reinterpret_cast<const char*>(state.data()),state.size());require(bool(out),"Cannot save probe checkpoint");}
  const auto elapsed=std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::steady_clock::now()-begin).count();
  std::cout<<"{\"upstream_linux\":\"6.1/830b3c68c1fb1e9176028d02ef86f3cf76aa2476\",\"guest\":"<<guest.statistics()
    <<",\"host_elapsed_ns\":"<<elapsed<<",\"checkpoint_bytes\":"<<state.size()<<",\"checkpoint_fnv\":"<<quote(hex(digest(state,state.size())))<<",\"stop_reason\":"<<quote(reason)<<",\"console\":"<<quote(console)<<",\"linux_boot_complete\":false,\"android_boot\":false}\n";
  return 0;
}catch(const std::exception& error){std::cerr<<error.what()<<'\n';return 1;}}
