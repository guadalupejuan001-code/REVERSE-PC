#pragma once
#include <array>
#include <cstddef>
#include <cstdint>

namespace velocity_c12 {
inline constexpr std::size_t material_uniform_count=5;
struct FrameInput {
  std::uint32_t wetness,water_depth_cm,ticks,ambient_mode;
};
struct FrameOutput {
  // Material uniforms consumed by REgraphics: wet, depth, seconds, day, lamps.
  std::array<float,material_uniform_count> values{};
  std::uint64_t steps=0,relation_nodes=0;
};
// Executes the original GPU-VIRTUAL C12 kernel on the host for each real frame.
// Each call owns a bounded execution. The pinned upstream API cannot reset or
// retire dispatches, so sharing a persistent Execution would retain job history.
FrameOutput evaluate(const FrameInput& input);
}
