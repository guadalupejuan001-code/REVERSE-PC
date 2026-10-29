#pragma once
// File transport for the original XI/Ether guest. The checkpoint remains
// authoritative; the caller publishes a separate candidate atomically.
#include "minimal_guest.hpp"
#include <chrono>
#include <fstream>
#include <sstream>

namespace reverse_pc::guest {
inline Bytes guest_read_file(const std::string& path,std::size_t limit){
  std::ifstream input(path,std::ios::binary|std::ios::ate);
  require(bool(input),"Cannot open guest file");const auto length=input.tellg();
  require(length>0&&std::uint64_t(length)<=limit,"Guest file exceeds transport budget");
  Bytes data(static_cast<std::size_t>(length));input.seekg(0);
  input.read(reinterpret_cast<char*>(data.data()),std::streamsize(data.size()));
  require(bool(input),"Cannot read complete guest file");return data;
}
inline std::string guest_file_operation(const std::string& input,const std::string& candidate,
                                      unsigned operation,std::uint64_t steps=0,
                                      const std::string& text={},
                                      std::shared_ptr<const GuestBlockImage> disk={}){
  require(operation<=5,"Unsupported guest file operation");
  require(operation==0||(!candidate.empty()&&candidate!=input),"Guest output must be a separate candidate");
  if(operation==1)require(steps>0&&steps<=250000,"Guest block must be 1..250000 instructions");
  if(operation==2)require(text.size()<=65536,"Guest XI program exceeds 64 KiB");
  if(operation==3)require(text.size()<=4096,"Guest console input exceeds 4096 bytes");
  const auto begin=std::chrono::steady_clock::now();
  auto guest=[&]{
    if(operation==4){MinimalGuest result(128*1024*1024,0);
      result.load_linux_image(guest_read_file(input,MinimalGuest::max_linux_kernel));return result;}
    return MinimalGuest::from_snapshot(guest_read_file(input,MinimalGuest::max_adaptive_snapshot),disk);
  }();
  if(operation==5){const auto rgb=guest.display_rgb();if(!rgb.empty()){std::ofstream frame(candidate,std::ios::binary|std::ios::trunc);frame.write(reinterpret_cast<const char*>(rgb.data()),std::streamsize(rgb.size()));frame.close();require(bool(frame),"Cannot write guest frame");}return "{\"guest\":"+guest.statistics()+",\"display_ready\":"+(rgb.empty()?"false":"true")+",\"frame_bytes\":"+std::to_string(rgb.size())+"}";}
  RunResult run;std::string xi_output;
  if(operation==1)run=guest.run(steps);
  if(operation==2)xi_output=guest.apply_xi_delta(text);
  if(operation==3)guest.console_input(text);
  std::size_t size=0;
  if(operation){
    const auto saved=guest.snapshot();size=saved.size();
    std::ofstream output(candidate,std::ios::binary|std::ios::trunc);
    require(bool(output),"Cannot open guest candidate");
    output.write(reinterpret_cast<const char*>(saved.data()),std::streamsize(saved.size()));
    output.close();require(bool(output),"Cannot write complete guest candidate");
  }else{std::ifstream original(input,std::ios::binary|std::ios::ate);size=std::size_t(original.tellg());}
  std::ostringstream report;report<<"{\"guest\":"<<guest.statistics()<<",\"snapshot_bytes\":"<<size;
  if(operation==1)report<<",\"executed_this_run\":"<<run.executed
    <<",\"stdout\":"<<quote(run.output)<<",\"stderr\":"<<quote(run.error_output)
    <<",\"stop_reason\":"<<quote(run.halted?"halted":run.waiting?"waiting_for_device_or_interrupt":"instruction_budget");
  if(operation==2)report<<",\"xi_output\":"<<quote(xi_output);
  report<<",\"host_elapsed_ns\":"<<std::chrono::duration_cast<std::chrono::nanoseconds>(
    std::chrono::steady_clock::now()-begin).count()<<"}";return report.str();
}
} // namespace reverse_pc::guest
