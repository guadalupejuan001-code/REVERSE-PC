#include "minimal_guest_counter_demo.hpp"
#include "minimal_guest_pci_demo.hpp"
#include "minimal_guest_system_demo.hpp"
#include <fstream>
#include <filesystem>
#include <iostream>
using namespace reverse_pc::guest;
static unsigned checks=0;static void check(bool v,const char* why){++checks;require(v,why);}
static void write(const std::string& path,const Bytes& b){std::ofstream out(path,std::ios::binary);out.write(reinterpret_cast<const char*>(b.data()),b.size());require(bool(out),"Cannot save counter test evidence");}
int main(){try{
  // Independent Node crypto.createHmac goldens are checked against this
  // complete emitted stream, not just a test of whether numbers vary.
  GuestCounterLatency c;c.enabled=true;c.seed=counter_test_seed();std::vector<unsigned> stream;
  for(unsigned i=0;i<64;i++)stream.push_back(c.next());
  auto encoded=c.save();check(encoded.size()==48,"Counter finite state extent changed");
  auto roundtrip=GuestCounterLatency::restore(encoded);check(roundtrip.reads==64&&roundtrip.seed==c.seed,"Counter source was not restored");
  check(c.next()==roundtrip.next(),"Counter source changed after cache reconstruction");
  encoded[0]=2;bool rejected=false;try{GuestCounterLatency::restore(encoded);}catch(const std::exception&){rejected=true;}
  check(rejected,"Unknown counter source version was accepted");
  auto legacy=MinimalGuest(128*1024*1024,0);legacy.load_linux_image(counter_witness_image());const auto legacy_start=legacy.snapshot();legacy.run(1000);
  check(legacy.registers().halted&&!legacy.machine().counter_latency.enabled,"Historical counter mode changed");
  for(unsigned i=1;i<64;i++)check(legacy.read(0x44000000+i*8,8)-legacy.read(0x44000000+(i-1)*8,8)==2,"Legacy counter timing is not byte-compatible");
  check(MinimalGuest::from_snapshot(legacy_start).snapshot()==legacy_start,"Old machine state changed on restore");
  auto g=counter_witness();const auto source=g.snapshot();const auto result=g.run(1000);
  check(g.registers().halted&&g.machine().counter_latency.reads==64,"Real counter MRS instructions did not execute");
  check(g.registers().x[2]==1000000,"Architectural counter frequency changed");
  check(result.output=="REVERSE: COUNTER LATENCY OK\n","Counter witness UART changed");
  unsigned varied=0;std::uint64_t expected=6;
  for(unsigned i=0;i<64;i++){
    expected+=stream[i];check(g.read(0x44000000+i*8,8)==expected,"Counter latency differs from its persistent stream");
    if(i&&g.read(0x44000000+i*8,8)-g.read(0x44000000+(i-1)*8,8)!=2)++varied;
    expected+=2;
  }
  check(varied>32,"Counter samples did not contain bounded timing variation");
  auto sliced=MinimalGuest::from_snapshot(source);
  for(unsigned i=0;i<200&&!sliced.registers().halted;i++){
    sliced.run(7);const auto middle=sliced.snapshot();sliced=MinimalGuest::from_snapshot(middle);
  }
  check(sliced.snapshot()==g.snapshot(),"Sliced execution and restored cache changed the full guest state");
  check(MinimalGuest::from_snapshot(g.snapshot()).snapshot()==g.snapshot(),"Machine v6 restore was not byte-identical");
  const auto before=g.snapshot();bool duplicate=false;try{g.enable_counter_latency(counter_test_seed());}catch(const std::exception&){duplicate=true;}
  check(duplicate&&g.snapshot()==before,"A running entropy seed was silently replaced");
  const auto statistics=g.statistics();check(statistics.find("counter_samples\":64")!=std::string::npos,"Counter provenance is absent");
  check(g.snapshot()==before,"Read-only counter inspection mutated the guest");
  MinimalGuest system(128*1024*1024,0);system.load_elf(system_demo_elf(),true);system.enable_counter_latency(counter_test_seed());
  const auto timer=system.run(10000);
  check(timer.halted&&timer.exit_code==0&&timer.output=="REVERSE: EL1 MMU IRQ EL0 SVC FAULT OK\n","Counter latency broke actual MMU/timer/IRQ/ERET execution");
  check(MinimalGuest::from_snapshot(system.snapshot()).snapshot()==system.snapshot(),"Non-PCI v6 did not restore");
  MinimalGuest pci(128*1024*1024,0);pci.load_linux_image(pci_graphics_witness_image(),{},"",{},true);pci.enable_counter_latency(counter_test_seed());
  pci.run(1000);check(pci.display_rgb().size()==96*64*3,"PCI display changed with the new clock state");
  check(MinimalGuest::from_snapshot(pci.snapshot()).snapshot()==pci.snapshot(),"PCI v6 did not restore");
  std::filesystem::create_directories("guest-evidence");write("guest-evidence/counter-start.rvg",source);write("guest-evidence/counter-finished.rvg",g.snapshot());
  std::cout<<"{\"checks\":"<<checks<<",\"mode\":\"test-seed-only\",\"samples\":64,\"legacy_unchanged\":true,\"same_state_after_restart\":true,\"expected_finished_sha256\":"<<quote(GuestSha256::hash(g.snapshot()))<<",\"latencies\":[";
  for(unsigned i=0;i<stream.size();i++){if(i)std::cout<<',';std::cout<<stream[i];}
  std::cout<<"],\"android_boot\":false}\n";
}catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 1;}}
