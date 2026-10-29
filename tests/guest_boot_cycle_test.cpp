#include "guest_boot_cycle.hpp"
#include "guest_file_session.hpp"
#include "minimal_guest_pci_demo.hpp"
#include "minimal_guest_system_demo.hpp"
#include <iostream>
using namespace reverse_pc::guest;
static unsigned checks=0;
static void check(bool value,const char* why){++checks;require(value,why);}
static MinimalGuest graphics(){MinimalGuest g(128*1024*1024,0);g.load_linux_image(pci_graphics_witness_image(),{},"",{},true);return g;}
static MinimalGuest user_entry(){
  // Real MSR/ERET transition and a NOP at EL0, derived from the existing
  // independently assembled SPSR.SSBS witness. This fixture is not Android.
  const std::uint32_t code[]{0xd2820000u,0xd5184000u,0xd2800301u,0xf2a80101u,0xd5184021u,0xd69f03e0u,0xd503201fu};
  auto image=system_demo_elf();image.resize(256);for(auto word:code)put(image,word,4);
  for(unsigned i=0;i<8;i++){image[96+i]=std::uint8_t(std::uint64_t(sizeof(code))>>(8*i));image[104+i]=image[96+i];}
  MinimalGuest g(128*1024*1024,0);g.load_elf(image,true);return g;
}
int main(){try{
  auto direct=graphics();direct.run(1000);auto split=graphics();split.run(200);
  const auto input=split.snapshot();split=MinimalGuest::from_snapshot(input);
  BootCycleLimits limits;limits.instructions=1000;limits.wall_ms=30000;limits.chunk=37;limits.checkpoint_instructions=70;
  std::vector<Bytes> saves;const auto report=run_boot_cycle(split,limits,[&](const MinimalGuest& g,const BootCycleReport&){saves.push_back(g.snapshot());});
  check(report.initial_instructions==200,"Cycle restarted the CPU");check(report.reason=="halted","Real graphics program did not halt");
  check(split.snapshot()==direct.snapshot(),"Resumed and direct complete snapshots differ");check(split.display_rgb()==direct.display_rgb(),"Resumed display differs");
  check(report.console=="REVERSE: PCI GPU 2D OK\n","UART continuation differs");check(saves.size()>=4,"Periodic instruction saves did not occur");
  check(!report.first_user_instruction_verified,"Bare-metal graphics was called userspace");
  for(const auto& state:saves){const auto restored=MinimalGuest::from_snapshot(state);check(restored.snapshot()==state,"Periodic state does not restore exactly");}
  auto bounded=graphics();limits.instructions=103;const auto bounded_report=run_boot_cycle(bounded,limits);
  check(bounded.registers().instructions==103&&bounded_report.reason=="instruction_budget","Instruction boundary was exceeded");
  auto paused=graphics();const auto paused_state=paused.snapshot();const auto paused_report=run_boot_cycle(paused,limits,{},{},{},[]{return true;});
  check(paused_report.reason=="host_interrupted"&&paused.snapshot()==paused_state,"Host stop changed the guest");
  auto bad_image=pci_graphics_witness_image();for(unsigned i=0;i<4;i++)bad_image[256+13*4+i]=255;
  MinimalGuest bad(128*1024*1024,0);bad.load_linux_image(bad_image,{},"",{},true);
  auto exact=bad;exact.run(14);const auto exact_state=exact.snapshot();limits.instructions=100;
  const auto failed=run_boot_cycle(bad,limits);
  check(failed.reason=="architectural_stop"&&!failed.error.empty(),"Unsupported transition was concealed");
  check(bad.snapshot()==exact_state,"Fault localization changed the successful prefix");
  auto rejected=bad;bool threw=false;try{rejected.run(1);}catch(const std::exception&){threw=true;}
  check(threw&&rejected.snapshot()==exact_state,"Faulting instruction was committed");
  auto late_image=pci_graphics_witness_image();bool found_hvc=false;
  for(unsigned at=256;at<4096;at+=4)if(get(late_image,at,4)==0xd4000002){
    for(unsigned i=0;i<4;i++)late_image[at+i]=255;found_hvc=true;break;
  }
  check(found_hvc,"Graphics witness lost its real poweroff instruction");
  MinimalGuest late(128*1024*1024,0);late.load_linux_image(late_image,{},"",{},true);auto late_reference=late;late_reference.run(527);
  limits.instructions=1000;limits.chunk=1000;const auto late_report=run_boot_cycle(late,limits);
  check(late_report.reason=="architectural_stop"&&late.snapshot()==late_reference.snapshot(),"Fault rollback/localization lost DMA or device state");
  check(late_report.console=="REVERSE: PCI GPU 2D OK\n","Fault localization lost the successful UART prefix");
  check(late.display_rgb()==direct.display_rgb(),"Fault localization changed the actual presented pixels");
  auto entry=user_entry(),entry_reference=entry;entry_reference.run(7);limits.instructions=7;
  const auto entry_report=run_boot_cycle(entry,limits,{},[](MinimalGuest& g){
    require(!g.machine().el&&g.registers().pc==0x40080018,"The real ERET entry was missed");g.run(1);return g.registers().pc==0x4008001c;
  });
  check(entry_report.first_user_instruction_verified,"Verified first userspace opcode was not recorded");
  check(entry.snapshot()==entry_reference.snapshot(),"Entry observation changed CPU state or exceeded its budget");
  auto milestone=user_entry();limits.instructions=1000;limits.stop_after_first_user_instruction=true;
  std::vector<Bytes> milestone_saves;
  const auto milestone_report=run_boot_cycle(milestone,limits,[&](const MinimalGuest& g,const BootCycleReport&){milestone_saves.push_back(g.snapshot());},[](MinimalGuest& g){
    require(!g.machine().el&&g.registers().pc==0x40080018,"Milestone missed the ERET boundary");g.run(1);return g.registers().pc==0x4008001c;
  });
  check(milestone_report.first_user_instruction_verified&&milestone_report.reason=="first_user_instruction_verified","Verified first-instruction stop was not reported");
  check(milestone.snapshot()==entry_reference.snapshot(),"Milestone executed beyond the single verified userspace instruction");
  check(milestone_saves.size()==2&&milestone_saves.back()==entry_reference.snapshot(),"Milestone did not save the exact verified boundary");
  bool needs_verifier=false;try{run_boot_cycle(milestone,limits);}catch(const std::exception&){needs_verifier=true;}
  check(needs_verifier&&milestone.snapshot()==entry_reference.snapshot(),"Milestone stop without a verifier was accepted");
  limits.stop_after_first_user_instruction=false;
  auto unverified=user_entry();unverified.run(6);const auto boundary=unverified.snapshot();
  const auto unverified_report=run_boot_cycle(unverified,limits,{},[](MinimalGuest& trial){trial.run(1);return false;});
  check(unverified_report.reason=="unverified_userspace_entry"&&!unverified_report.first_user_instruction_verified,"Unverified entry was accepted");
  check(unverified.snapshot()==boundary,"Failed entry verifier committed a partial transition");
  const auto faulted_entry=run_boot_cycle(unverified,limits,{},[](MinimalGuest&)->bool{throw MachineFault{0x96000004,0x1234};});
  check(faulted_entry.reason=="unverified_userspace_entry"&&!faulted_entry.first_user_instruction_verified,"Architectural observation fault escaped its boundary");
  check(unverified.snapshot()==boundary,"Architectural observation fault changed the CPU");
  const auto root=std::filesystem::path("evidence/c04/cycle-journal-test-"+std::to_string(::getpid()));
  std::filesystem::create_directories(root.parent_path());BootCycleJournal journal(root);
  journal.publish(bad,failed);journal.publish(split,report);journal.publish(bounded,bounded_report);
  check(journal.sequence()==3,"Journal generation was lost");check(!std::filesystem::exists(root/"generation-1"),"Journal retained unbounded history");
  check(std::filesystem::exists(root/"generation-2")&&std::filesystem::exists(root/"generation-3"),"Journal lost a complete generation");
  const auto newest=guest_read_file((root/"generation-3/checkpoint.rvg").string(),MinimalGuest::max_adaptive_snapshot);
  check(newest==bounded.snapshot(),"Latest journal checkpoint differs");
  const auto pointer_bytes=guest_read_file((root/"latest.json").string(),4096);const std::string pointer(pointer_bytes.begin(),pointer_bytes.end());
  check(pointer.find("generation-3")!=std::string::npos&&pointer.find(GuestSha256::hash(newest))!=std::string::npos,"Journal pointer is not bound to the state");
  std::filesystem::create_directory(root/".pending-4");std::ofstream(root/".pending-4/checkpoint.rvg")<<"incomplete";
  check(guest_read_file((root/"latest.json").string(),4096)==pointer_bytes,"Unfinished generation replaced the last complete state");
  bool protected_output=false;try{BootCycleJournal same(root);}catch(const std::exception&){protected_output=true;}
  check(protected_output&&guest_read_file((root/"generation-3/checkpoint.rvg").string(),MinimalGuest::max_adaptive_snapshot)==newest,"Existing journal output was overwritten");
  std::filesystem::remove_all(root);
  std::cout<<"{\"checks\":"<<checks<<",\"exact_resume\":true,\"persisted_pixels\":true,\"fault_prefix_preserved\":true,\"atomic_generation_pointer\":true,\"android_boot\":false}\n";
}catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 1;}}
