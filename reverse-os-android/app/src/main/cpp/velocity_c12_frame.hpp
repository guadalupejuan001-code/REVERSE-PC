#pragma once
#include <array>
#include <cstdint>

namespace velocity_c12 {
struct FrameInput {
  std::uint32_t wetness,water_depth_cm,ticks,ambient_mode;
};
struct FrameOutput {
  // Material uniforms consumed by REgraphics: wet, depth, seconds, day, lamps.
  std::array<float,5> values{};
  std::uint64_t steps=0,relation_nodes=0,qssd_revision=0;
  bool shared_source=false,reused=false;
};
// Executes the original GPU-VIRTUAL C12 kernel on the host for each real frame.
FrameOutput evaluate(const FrameInput& input);
}
