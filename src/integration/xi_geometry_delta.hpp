#pragma once
#include <cstdint>
#include <cstring>
#include <limits>
#include <stdexcept>
#include <string>
#include <vector>

namespace reverse_pc {
// Exact transport, not a second geometry owner. One retained XI frame and a
// one-bit-per-32-bit-word change mask; no hashes or lossy comparisons decide reuse.
class XiGeometryDelta {
 public:
  static constexpr std::size_t max_frame_bytes=2064+8192*60,header_bytes=44;
  struct Stats {std::uint64_t frames=0,delta_frames=0,reused_frames=0,wire_bytes=0,frame_bytes=0;};
  std::vector<std::uint8_t> repeat(const std::string& output,std::uint64_t publication){
    if(previous_.empty()||output.size()>65536||publication>INT64_MAX||serial_>=INT64_MAX)
      throw std::length_error("XI retained geometry transport bounds");
    std::vector<std::uint8_t> packet;packet.reserve(header_bytes+output.size());packet.insert(packet.end(),{'X','G','D','1'});
    auto put32=[&](std::uint32_t n){for(unsigned s=0;s<32;s+=8)packet.push_back(std::uint8_t(n>>s));};
    auto put64=[&](std::uint64_t n){for(unsigned s=0;s<64;s+=8)packet.push_back(std::uint8_t(n>>s));};
    put32(output.size());put32(previous_.size());put64(publication);put64(serial_+1);put64(serial_);put32(2);put32(0);
    packet.insert(packet.end(),output.begin(),output.end());++serial_;++stats_.frames;++stats_.delta_frames;++stats_.reused_frames;
    stats_.wire_bytes+=packet.size();stats_.frame_bytes+=previous_.size();return packet;
  }
  std::vector<std::uint8_t> encode(const std::string& output,std::string frame,std::uint64_t publication){
    if(output.size()>65536||frame.size()<2064||frame.size()>max_frame_bytes||frame.size()%4||
       frame.compare(0,4,"XFG4")||publication>INT64_MAX||serial_>=INT64_MAX)
      throw std::length_error("XI geometry delta transport bounds");
    const auto words=frame.size()/4,mask_bytes=(words+7)/8;
    std::vector<std::uint8_t> mask(mask_bytes,0);std::size_t changed=0;
    if(!previous_.empty())for(std::size_t i=0;i<words;++i){
      if(i*4+4>previous_.size()||std::memcmp(frame.data()+i*4,previous_.data()+i*4,4)){
        mask[i/8]|=std::uint8_t(1U<<(i%8));++changed;
      }
    }
    const bool delta=!previous_.empty()&&mask_bytes+changed*4<frame.size();
    const auto body_bytes=delta?mask_bytes+changed*4:frame.size();
    std::vector<std::uint8_t> packet;packet.reserve(header_bytes+output.size()+body_bytes);
    packet.insert(packet.end(),{'X','G','D','1'});
    auto put32=[&](std::uint32_t n){for(unsigned s=0;s<32;s+=8)packet.push_back(std::uint8_t(n>>s));};
    auto put64=[&](std::uint64_t n){for(unsigned s=0;s<64;s+=8)packet.push_back(std::uint8_t(n>>s));};
    put32(output.size());put32(frame.size());put64(publication);put64(serial_+1);
    put64(delta?serial_:0);put32(delta?1:0);put32(body_bytes);
    packet.insert(packet.end(),output.begin(),output.end());
    if(delta){
      packet.insert(packet.end(),mask.begin(),mask.end());
      for(std::size_t i=0;i<words;++i)if(mask[i/8]&(1U<<(i%8)))
        packet.insert(packet.end(),frame.data()+i*4,frame.data()+i*4+4);
    }else packet.insert(packet.end(),frame.begin(),frame.end());
    ++serial_;++stats_.frames;stats_.delta_frames+=delta;
    stats_.wire_bytes+=packet.size();stats_.frame_bytes+=frame.size();
    previous_=std::move(frame);return packet;
  }
  Stats stats()const{return stats_;}
 private:
  std::string previous_;
  std::uint64_t serial_=0;
  Stats stats_;
};
}
