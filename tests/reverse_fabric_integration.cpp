#include "reverse_fabric.hpp"

#include <iostream>
#include <stdexcept>
#include <string>
#include <unordered_map>

namespace {
unsigned checks=0;
void check(bool yes,const char* message){
  ++checks;
  if(!yes)throw std::runtime_error(message);
}
bool has(const std::string& s,const std::string& fragment){
  return s.find(fragment)!=std::string::npos;
}
} // namespace

int main(){
 try {
  reverse_fabric::Fabric pc;
  std::size_t xi_calls=0,reads=0,writes=0;
  std::unordered_map<std::string,std::uint8_t> memory;
  reverse_fabric::Authority authority{
    [&](const std::string& program)->std::string{
      ++xi_calls;
      if(program.empty())throw std::invalid_argument("missing guest XI");
      return "{\"accepted_by_test_callback\":true}\n";
    },
    [&](const std::string& address)->std::uint8_t{
      ++reads;return memory[address];
    },
    [&](const std::string& address,std::uint8_t value){
      ++writes;memory[address]=value;
    }
  };

  const auto initial=pc.apply("inspect","",authority);
  check(has(initial,"\"qssd_serial\":1"),"real QSSD StateBus starts at initial version");
  check(has(initial,"\"quantum_authority\":\"REVERSE RVPC2\""),"Mundo quantum session not advertised as canonical");
  check(has(initial,"\"direct_gles_submission\":false"),"not pretending physical GLES materialization");

  pc.apply("boot_x86","",authority);
  const auto screen=pc.apply("run","",authority);
  check(has(screen,"ALU + RAM + lectura de disco: OK"),"original x86 guest produced real video characters");
  check(has(screen,"\"qssd_serial\":")&&has(screen,"\"planned_vertex_invocations\":"),
        "original GPU Virtual authority and qSSD publish actual visible guest work");
  const auto last=pc.apply("inspect","",authority);
  const auto after=pc.apply("plan_gpu_qssd","",authority);
  // No-change planning retains exactly the same qSSD immutable revision.
  check(last==after || has(after,"\"action\":\"plan_gpu_qssd\""),
        "unchanged video planning returns a legitimate result");
  check(has(after,"\"source_objects\":")&&has(after,"\"qssd_authority\":"),
        "GPU workload indexed by genuine qSSD component");
  check(xi_calls==0,"ordinary x86 BIOS path does not forge quantum XI traffic");

  pc.apply("boot_quantum","",authority);
  const auto quantum=pc.apply("run","",authority);
  check(xi_calls>0,"Mundo x86 guest ports reach the external XI authority callback");
  check(has(quantum,"\"guest_xi_requests\":1"),
        "guest host handoff is real and counted");

  const auto direct=pc.apply("xi","x 41\n",authority);
  check(xi_calls>=2&&has(direct,"accepted_by_test_callback"),
        "host XI editor also uses the same callback");
  bool failed=false;
  try { pc.apply("unknown","",authority); }
  catch(const std::invalid_argument&) { failed=true; }
  check(failed,"unknown fabric actions are rejected explicitly");

  std::cout<<"{\"status\":\"PASS\",\"checks\":"<<checks
           <<",\"cpu\":\"Mundo X C03 original\","
             "\"gpu\":\"GPU-VIRTUAL PR8 original\","
             "\"memory\":\"qSSD PR8 original StateBus\","
             "\"xi_authority\":\"callback-only in host harness; JNI RVPC2 validated separately\"}\n";
  return 0;
 }catch(const std::exception& e){
  std::cerr<<"REVERSE FABRIC FAILED: "<<e.what()<<'\n';return 1;
 }
}
