#pragma once
#include "rvpc2.hpp"
#include <utility>
namespace reverse_pc {
// Generic immutable observation mailbox. Source parsing stays cached when only
// view controls change. Byte writes affect this private candidate only.
inline std::string observe_geometry(const std::vector<std::uint8_t>& snapshot,
    const std::string& source,const std::vector<std::pair<std::uint32_t,std::uint8_t>>& inputs){
  if(inputs.size()>32)throw std::length_error("Geometry observation input budget");
  auto runtime=rvpc2::restore(snapshot);
  std::vector<std::pair<std::string,std::uint8_t>> mailbox;
  for(const auto& input:inputs)mailbox.emplace_back(std::to_string(input.first),input.second);
  const auto frame=runtime.execute(source,false,mailbox);
  if(frame.size()<4||frame.compare(0,4,"XFG4")!=0)
    throw std::invalid_argument("Geometry observation requires XI XFG4 output");
  return frame;
}
}
