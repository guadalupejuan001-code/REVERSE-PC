#pragma once

// REVERSE-PC owns RVPC2. Mundo X supplies the PC/x86 implementation;
// GPU-VIRTUAL plans physical work and qSSD versions the same emitted plan.
// Every guest XI request and byte in the Ether memory aperture is redirected
// to the EXISTING REVERSE RVPC2 authority by the caller's real callbacks.
// This translation unit never includes the legacy QuantumRuntime C++ class:
// modern Mundo X and the pinned REVERSE engine have different core versions.
#include "pc_machine.hpp"
#include "trabajo_fisico.hpp"
#include "qssd/graphics_work_state.hpp"

#include <array>
#include <cstdint>
#include <functional>
#include <memory>
#include <mutex>
#include <optional>
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
        else if (c < 127) out << char(c);
        else out << '?';
    }
  }
  return out.str() + '"';
}

struct Authority {
  std::function<std::string(const std::string&)> execute_xi;
  std::function<std::uint8_t(const std::string&)> read_byte;
  std::function<void(const std::string&,std::uint8_t)> write_byte;
};

class Fabric final {
 public:
  // Large LOGICAL video/guest aperture; sparse physical pages are bounded.
  Fabric() : pc_(std::size_t(2048)*1024*1024,
                 std::size_t(384)*1024*1024) {
    auto original_input = std::move(pc_.cpu.in_hook);
    auto original_output = std::move(pc_.cpu.out_hook);
    pc_.cpu.in_hook = [this, original_input=std::move(original_input)](std::uint16_t port, unsigned width) {
      if (port == cosmic_pc::PcQuantumDevice::data_port ||
          port == cosmic_pc::PcQuantumDevice::control_port)
        return std::optional<std::uint32_t>(port_input(port, width));
      return original_input(port,width);
    };
    pc_.cpu.out_hook = [this, original_output=std::move(original_output)](std::uint16_t port,unsigned width,std::uint32_t value) {
      if (port == cosmic_pc::PcQuantumDevice::data_port ||
          port == cosmic_pc::PcQuantumDevice::control_port) {
        port_output(port,width,value);
        return true;
      }
      return original_output(port,width,value);
    };
    if (pc_.cpu.memory.has_window()) {
      pc_.cpu.memory.attach_window(cosmic_pc::PcMachine::kEtherMemoryPhysicalBase,
        cosmic_pc::PcMachine::kEtherMemoryBytes,
        [this](std::uint64_t offset) {
          if (!authority_ || !authority_->read_byte)
            throw std::runtime_error("REVERSE RVPC2 memory authority unavailable");
          return authority_->read_byte(std::to_string(
              cosmic_pc::PcMachine::kEtherMemoryLogicalByteBase+offset));
        },
        [this](std::uint64_t offset,std::uint8_t value) {
          if (!authority_ || !authority_->write_byte)
            throw std::runtime_error("REVERSE RVPC2 memory authority unavailable");
          authority_->write_byte(std::to_string(
              cosmic_pc::PcMachine::kEtherMemoryLogicalByteBase+offset),value);
        });
    }
  }
  Fabric(const Fabric&) = delete;
  Fabric& operator=(const Fabric&) = delete;

  std::string apply(const std::string& action, const std::string& argument,
                    Authority& authority) {
    std::lock_guard<std::mutex> guard(mutex_);
    if (authority_ != nullptr) throw std::logic_error("REVERSE Fabric recursive invocation");
    struct Scoped {
      Fabric& self;
      Scoped(Fabric& f, Authority& a):self(f){self.authority_=&a;}
      ~Scoped(){self.authority_=nullptr;}
    } scope(*this,authority);

    if (action == "inspect") {}
    else if (action == "boot_x86") { pc_.boot_demo(); reset_port(); }
    else if (action == "boot_x64") { pc_.boot_long_mode_demo(); reset_port(); }
    else if (action == "boot_quantum") { pc_.boot_quantum_demo(); reset_port(); }
    else if (action == "boot_quantum_x64") { pc_.boot_quantum_demo(true); reset_port(); }
    else if (action == "boot_video") { pc_.boot_graphics_demo(1280,720); reset_port(); }
    else if (action == "run") pc_.run(50000);
    else if (action == "step") pc_.run(1);
    else if (action == "reset") { pc_.reset(); reset_port(); }
    else if (action == "key") {
      const auto n=static_cast<std::uint64_t>(std::stoull(argument));
      if (n>127) throw std::invalid_argument("ASCII key value out of range");
      pc_.key(static_cast<std::uint8_t>(n),0);
    } else if (action == "xi") {
      if (!authority.execute_xi) throw std::runtime_error("RVPC2 XI authority unavailable");
      if (argument.size() > 256*1024)
        throw std::length_error("REVERSE XI source exceeds 256 KiB");
      last_output_ = authority.execute_xi(argument);
    } else if (action == "plan_gpu_qssd") {
      plan_video();
    } else {
      throw std::invalid_argument("Unknown REVERSE Fabric action");
    }
    // Plans and immutable qSSD revisions are refreshed on real guest frames.
    if (action == "run" || action == "step" || action == "boot_x86" ||
        action == "boot_x64" || action == "boot_quantum" ||
        action == "boot_quantum_x64" || action == "boot_video" ||
        action == "reset") plan_video();
    return report(action);
  }

 private:
  static constexpr std::uint16_t data_port = 0x5850, control_port = 0x5851;
  static constexpr std::size_t max_request = 65536;
  struct Port {
    std::string input, response;
    std::size_t cursor=0;
    bool error=false, overflow=false;
    std::uint64_t submitted=0;
  } port_;

  void reset_port() {port_.input.clear();port_.response.clear();port_.cursor=0;port_.error=port_.overflow=false;}
  void fail(const std::string& msg) noexcept {
    port_.error=true;
    try{port_.response="{\"ok\":false,\"error\":"+json_string(msg)+"}\n";}
    catch(...){port_.response="{\"ok\":false}\n";}
    port_.cursor=0;
    port_.input.clear();
  }
  std::uint32_t port_input(std::uint16_t port,unsigned width) {
    if(width!=1) {fail("XI port requires byte-sized I/O");return 0;}
    if(port==control_port) {
      const auto unread=port_.response.size()>port_.cursor;
      return 0x80u | (unread ? 1u : 0u) | (port_.error ? 2u : 0u) |
             (port_.overflow ? 4u : 0u);
    }
    if(port_.cursor>=port_.response.size())return 0;
    return static_cast<std::uint8_t>(port_.response[port_.cursor++]);
  }
  void port_output(std::uint16_t port,unsigned width,std::uint32_t value) {
    if(width!=1){fail("XI port requires byte-sized I/O");return;}
    if(port==data_port) {
      if(port_.input.size()>=max_request) {
        port_.overflow=true;fail("XI port request exceeds 65536 bytes");
      } else if(!port_.overflow) port_.input.push_back(char(value&255));
      return;
    }
    if(value==1){reset_port();return;}
    if(value!=2){fail("Unknown XI device command");return;}
    ++port_.submitted;
    if(port_.overflow){fail("XI port overflow; clear the channel");return;}
    try{
      if(!authority_ || !authority_->execute_xi)
        throw std::runtime_error("REVERSE RVPC2 authority unavailable");
      port_.response=authority_->execute_xi(port_.input);
      port_.input.clear();port_.cursor=0;port_.error=false;
    }catch(const std::exception& e){fail(e.what());}
    catch(...){fail("RVPC2 XI guest transaction rejected");}
  }

  void plan_video() {
    std::array<std::uint8_t,4000> video{};
    pc_.copy_vga_text(video.data(),video.size());
    std::uint64_t hash=UINT64_C(14695981039346656037);
    for(auto byte:video){hash^=byte;hash*=UINT64_C(1099511628211);}
    if(have_video_&&hash==previous_video_hash_)return;
    std::vector<xgpu::PhysicalCandidate> objects;
    objects.reserve(2000);
    for(std::uint32_t i=0;i<2000;++i){
      const std::uint8_t glyph=video[2*i],color=video[2*i+1];
      if(glyph<=32 || glyph>=127)continue;
      xgpu::PhysicalCandidate c;
      c.id=i;
      c.transform_revision=1;
      c.material_revision=(std::uint64_t(glyph)<<8)|color;
      c.mesh=0;
      c.camera_visible=true;
      c.shadow_visible=false;
      c.camera_diameter_px=8.0f;
      objects.push_back(c);
    }
    // First consume the original GPU-VIRTUAL work plan; then publish it into
    // QSSD's shared StateBus. This is the actual REVERSE display's VGA input.
    const auto plan=gpu_.plan(objects,{6},++video_revision_,true,true,true);
    graphics_.publish(plan,video_revision_,0);
    previous_video_hash_=hash;
    have_video_=true;
  }

  std::string report(const std::string& action) const {
    auto info=pc_.json();
    const auto last=info.rfind(",\"quantum\":");
    if(last==std::string::npos)throw std::logic_error("Mundo X PC JSON contract changed");
    info.erase(last);
    info.append(",\"quantum_authority\":\"REVERSE RVPC2\","
                "\"quantum_internal_mundo_x_disabled\":true,"
                "\"ether_memory_owner\":\"REVERSE RVPC2\"}");
    const auto lease=graphics_.snapshot();
    const auto& plan=lease->value->plan;
    std::ostringstream out;
    out << "{\"ok\":true,\"origin\":\"REVERSE-PC\","
        << "\"components\":\"Mundo X C03;GPU-VIRTUAL PR8;qSSD PR8\","
        << "\"action\":"<<json_string(action)
        << ",\"pc\":"<<info
        << ",\"screen\":"<<json_string(pc_.screen())
        << ",\"xi_output\":"<<json_string(last_output_)
        << ",\"guest_xi_requests\":"<<port_.submitted
        << ",\"guest_xi_error\":"<<(port_.error?"true":"false")
        << ",\"gpu_qssd\":{"
        << "\"source\":\"physical-work planner on actual VGA memory\","
        << "\"qssd_authority\":"<<lease->authority
        << ",\"qssd_serial\":"<<lease->serial
        << ",\"dependency_revision\":"<<lease->value->dependency_revision
        << ",\"source_objects\":"<<plan.source_objects
        << ",\"camera_candidates\":"<<plan.camera_candidates
        << ",\"reused_objects\":"<<plan.reused_objects
        << ",\"changed_objects\":"<<plan.changed_objects
        << ",\"planned_instance_bytes\":"<<plan.planned_instance_bytes
        << ",\"baseline_instance_bytes\":"<<plan.baseline_instance_bytes
        << ",\"planned_vertex_invocations\":"<<plan.planned_vertex_invocations
        << ",\"completed_physical_revision\":"<<lease->value->completed_revision
        << ",\"direct_gles_submission\":false}}";
    return out.str();
  }

  mutable std::mutex mutex_;
  cosmic_pc::PcMachine pc_;
  xgpu::PhysicalWorkAuthority gpu_;
  qssd::GraphicsWorkMemory<xgpu::PhysicalWorkPlan> graphics_;
  Authority* authority_=nullptr;
  bool have_video_=false;
  std::uint64_t previous_video_hash_=0,video_revision_=0;
  std::string last_output_;
};
} // namespace reverse_fabric
