#pragma once

// REVERSE is the application/desktop; the modern Mundo X PC, GPU-VIRTUAL and
// qSSD modules stay upstream-owned and run behind an isolated, opt-in boundary.
// Deliberately NEVER include the legacy REVERSE rvpc2.hpp in this translation
// unit: RVPC2 and modern Mundo X sessions have different state authorities.
#include "pc_machine.hpp"
#include "trabajo_fisico.hpp"
#include "qssd/graphics_work_state.hpp"

#include <array>
#include <cstdint>
#include <memory>
#include <mutex>
#include <sstream>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

namespace reverse_fabric {
inline std::string json_string(const std::string& value) {
  std::ostringstream out;
  out << '"';
  constexpr char digits[] = "0123456789abcdef";
  for (unsigned char c : value) {
    switch (c) {
      case '"': out << "\\\""; break;
      case '\\': out << "\\\\"; break;
      case '\n': out << "\\n"; break;
      case '\r': out << "\\r"; break;
      case '\t': out << "\\t"; break;
      default:
        if (c < 32) out << "\\u00" << digits[c >> 4] << digits[c & 15];
        else if (c < 127) out << static_cast<char>(c);
        else out << '?';  // Terminal screen is rendered as ASCII by PcMachine.
    }
  }
  return out.str() + '"';
}

// This is an active compute bridge, not merely a list of pinned repositories.
// The guest runs on the ORIGINAL Mundo X C03 PcMachine; XI C01/C02 are its
// original opt-in algorithms; GPU-VIRTUAL #8 plans visible work; qSSD #8
// versions and retains the real plan. REVERSE RVPC2/BBY Q are never rewritten.
class Fabric final {
 public:
  Fabric() : pc_(16 * 1024 * 1024) {}
  Fabric(const Fabric&) = delete;
  Fabric& operator=(const Fabric&) = delete;

  std::string execute(const std::string& action, const std::string& program = {}) {
    std::lock_guard<std::mutex> lock(mutex_);
    if (action == "inspect") return report("inspect");
    if (action == "boot_x86") pc_.boot_demo();
    else if (action == "boot_x64") pc_.boot_long_mode_demo();
    else if (action == "boot_quantum") pc_.boot_quantum_demo();
    else if (action == "boot_quantum_x64") pc_.boot_quantum_demo(true);
    else if (action == "boot_video") pc_.boot_graphics_demo(1280,720);
    else if (action == "step") pc_.run(5000);
    else if (action == "run") pc_.run(50000);
    else if (action == "reset") pc_.reset();
    else if (action == "c01_on") pc_.quantum_autonomous_enable(true);
    else if (action == "c01_off") pc_.quantum_autonomous_enable(false);
    else if (action == "xi") {
      if (program.size() > cosmic_pc::PcQuantumDevice::max_request_bytes)
        throw std::length_error("Mundo PC XI editor max 65536 bytes");
      pc_.quantum_command(program);
    } else if (action == "c02_benchmark") {
      pc_.quantum_workers_benchmark(program);
    } else if (action == "plan_gpu_qssd") {
      plan_from_guest_text();
    } else {
      throw std::invalid_argument("Unknown REVERSE Fabric action");
    }
    return report(action);
  }

 private:
  std::string report(const std::string& action) const {
    const auto view = graphics_.snapshot();
    const auto& plan = view->value->plan;
    std::ostringstream out;
    out << "{\"ok\":true,\"source\":\"MundoX-PC/C03+GPU-VIRTUAL/8+QSSD/8\""
        << ",\"action\":" << json_string(action)
        << ",\"reverse_state\":\"RVPC2 untouched: separate Mundo X PC authority\""
        << ",\"pc\":" << pc_.json()
        << ",\"screen\":" << json_string(pc_.screen())
        << ",\"graphics\":{\"qssd_serial\":" << view->serial
        << ",\"qssd_authority\":" << view->authority
        << ",\"dependency_revision\":" << view->value->dependency_revision
        << ",\"completed_physical_revision\":" << view->value->completed_revision
        << ",\"plan_revision\":" << plan.revision
        << ",\"source_objects\":" << plan.source_objects
        << ",\"camera_candidates\":" << plan.camera_candidates
        << ",\"reused_objects\":" << plan.reused_objects
        << ",\"changed_objects\":" << plan.changed_objects
        << ",\"planned_vertex_invocations\":" << plan.planned_vertex_invocations
        << ",\"baseline_vertex_invocations\":" << plan.baseline_vertex_invocations
        << ",\"planned_instance_bytes\":" << plan.planned_instance_bytes
        << ",\"baseline_instance_bytes\":" << plan.baseline_instance_bytes
        << ",\"input\":\"actual VGA guest text bytes; CPU-side planning only\""
        << ",\"physical_render_submitted\":false}}";
    return out.str();
  }

  void plan_from_guest_text() {
    // Input is read from real guest video memory. No fake 369-billion objects
    // or framebuffer/pixel performance claim. This planner does not own GLES.
    std::array<std::uint8_t,4000> video{};
    pc_.copy_vga_text(video.data(), video.size());
    std::uint64_t hash = 14695981039346656037ULL;
    for (auto byte : video) { hash ^= byte; hash *= 1099511628211ULL; }
    if (have_video_ && hash == previous_video_hash_) return; // qSSD lease reused
    std::vector<xgpu::PhysicalCandidate> candidates;
    candidates.reserve(2000);
    for (std::size_t i = 0; i < 2000; ++i) {
      const auto character = video[2*i], attribute = video[2*i+1];
      if (character < 33 || character > 126) continue;
      xgpu::PhysicalCandidate item;
      item.id = i;
      item.transform_revision = 1;
      item.material_revision = (std::uint64_t(character) << 8) | attribute;
      item.mesh = 0;
      item.camera_visible = true;
      item.shadow_visible = false;
      item.camera_diameter_px = 8.0f;
      candidates.push_back(item);
    }
    // A single quad of 6 vertices is the declared comparison workload.
    // This is planning only: the Android WebView still performs its rendering.
    const auto plan = gpu_.plan(candidates, {6}, ++dependency_revision_,
                                true, true, true);
    graphics_.publish(plan, dependency_revision_, 0 /* no physical submit */);
    have_video_ = true;
    previous_video_hash_ = hash;
  }

  mutable std::mutex mutex_;
  cosmic_pc::PcMachine pc_;
  xgpu::PhysicalWorkAuthority gpu_;
  qssd::GraphicsWorkMemory<xgpu::PhysicalWorkPlan> graphics_;
  bool have_video_ = false;
  std::uint64_t previous_video_hash_ = 0, dependency_revision_ = 0;
};
}  // namespace reverse_fabric
