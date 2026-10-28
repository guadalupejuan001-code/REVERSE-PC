// Development probe of a real, pinned upstream Linux Image. An unsupported
// instruction/register is a recorded engineering stop, never a claimed boot.
#include "minimal_guest.hpp"
#include <fstream>
#include <chrono>
#include <iostream>
#include <sstream>
using namespace reverse_pc::guest;
int main(int argc,char** argv){try{
  require(argc>=2&&argc<=5,"Expected Image-or-RVG [additional_instruction_budget] [output_checkpoint] [initrd_for_Image]");
  const auto begin=std::chrono::steady_clock::now();
  const auto budget=argc>=3?std::stoull(argv[2]):500000;require(budget>0&&budget<=100000000,"Probe budget must be 1..100000000");std::ifstream in(argv[1],std::ios::binary);
  require(bool(in),"Cannot open Image");Bytes image((std::istreambuf_iterator<char>(in)),{});
  require(image.size()<=MinimalGuest::max_adaptive_snapshot,"Linux probe input too large");
  const bool checkpoint=image.size()>=4&&image[0]=='R'&&image[1]=='V'&&image[2]=='G';
  MinimalGuest guest(128*1024*1024,1048576);Bytes initrd;if(argc==5){std::ifstream rd(argv[4],std::ios::binary);require(bool(rd),"Cannot open initrd");initrd.assign(std::istreambuf_iterator<char>(rd),{});}
  if(checkpoint){require(argc<5,"A checkpoint already contains its initrd");guest=MinimalGuest::from_snapshot(image);require(guest.machine().enabled&&guest.machine().image_kind==2,"Probe checkpoint must contain a Linux Image");}
  else guest.load_linux_image(image,initrd);
  // Preserve the old input RVG unchanged on disk; explicitly promote only the
  // guest running this development probe to the paged unbounded authority.
  guest.enable_adaptive_memory();
  const auto initial_instructions=guest.registers().instructions;std::string console,reason="instruction_budget";
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
  // Read-only diagnostic: inspect the exact XI/Ether-backed next instruction.
  std::string next_instruction="null";
  try {
    const auto virtual_pc=guest.registers().pc;
    const auto physical_pc=guest.physical_address(virtual_pc,false,true);
    const auto opcode=guest.read(physical_pc,4);
    std::ostringstream details;
    details<<"{\"virtual_pc\":"<<quote(hex(virtual_pc))
           <<",\"physical_pc\":"<<quote(hex(physical_pc))
           <<",\"opcode\":"<<quote(hex(opcode))
           <<",\"uart_ifls\":"<<guest.machine().uart_ifls
           <<",\"registers\":{";
    for(unsigned i=0;i<guest.registers().x.size();++i){
      if(i)details<<',';
      details<<quote("x"+std::to_string(i))<<':'<<quote(hex(guest.registers().x[i]));
    }
    details<<"}}";next_instruction=details.str();
  }catch(const std::exception& error){
    next_instruction="{\"inspection_error\":"+quote(error.what())+"}";
  }catch(...){next_instruction="{\"inspection_error\":\"architectural translation fault\"}";}
  const auto state=guest.snapshot();if(argc>=4){std::ofstream out(argv[3],std::ios::binary);out.write(reinterpret_cast<const char*>(state.data()),state.size());require(bool(out),"Cannot save probe checkpoint");}
  const auto elapsed=std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::steady_clock::now()-begin).count();
  std::cout<<"{\"expected_upstream_linux\":\"6.1/830b3c68c1fb1e9176028d02ef86f3cf76aa2476\",\"initial_instructions\":"<<initial_instructions<<",\"guest\":"<<guest.statistics()
    <<",\"host_elapsed_ns\":"<<elapsed<<",\"checkpoint_bytes\":"<<state.size()<<",\"checkpoint_fnv\":"<<quote(hex(digest(state,state.size())))<<",\"adaptive_classical_storage\":"<<(guest.runtime().memory().limits().max_overrides==0?"true":"false")
    <<",\"stop_reason\":"<<quote(reason)<<",\"next_instruction\":"<<next_instruction<<",\"console\":"<<quote(console)
    <<",\"linux_userspace_init_observed\":"<<(console.find("REVERSE_LINUX_INIT_OK")!=std::string::npos?"true":"false")
    <<",\"linux_boot_complete\":false,\"android_boot\":false}\n";
  return 0;
}catch(const std::exception& error){std::cerr<<error.what()<<'\n';return 1;}}
