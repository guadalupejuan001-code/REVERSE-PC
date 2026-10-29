#pragma once
#include "guest_boot_cycle.hpp"

namespace reverse_pc::guest {
// C06's reviewed original-init proof, not a user-supplied success boolean.
// Both artifacts are immutable pins. Any later checkpoint needs a separately
// validated provenance chain; it cannot reuse this proof for different bytes.
inline constexpr const char* android_c06_checkpoint_sha256="4c20cd09e353f82b032c17636ae2d72cec6988df5a5b00afbd756464c4dcd575";
inline constexpr const char* android_c06_report_sha256="ec12937b7c33a3aff439f3c388bbd32b1f538e08667d0f83e61736489666bdbf";
inline constexpr const char* android_c06_counter_seed_sha256="3079c6396c3fdcdaea106572f5da7c1a26a81efb32f64e8d39de7521dd5a1c75";
inline constexpr const char* android_original_init_code="9f2403d51d0080d21e0080d2e003009104000014000000000000000000000000ff0301d1fd7b03a9fdc30091281500f0291500f02a1500f02b1500f02c1500f0";

inline void android_c06_check_artifacts(const Bytes& state,const Bytes& report){
  require(GuestSha256::hash(report)==android_c06_report_sha256,"Different verified Android init report");
  require(GuestSha256::hash(state)==android_c06_checkpoint_sha256,"Different verified Android init checkpoint");
}
inline BootCycleEntryProof android_c06_entry_proof(const MinimalGuest& guest){
  require(guest.registers().instructions==UINT64_C(6250795356)&&guest.registers().pc==0x2a4004&&guest.machine().enabled&&!guest.machine().el,"Not the C06 original init boundary");
  const auto& clock=guest.machine().counter_latency;
  require(clock.enabled&&clock.instructions_per_tick==64&&clock.subtick==60,"Different proven counter cadence or phase");
  require(GuestSha256::hash(Bytes(clock.seed.begin(),clock.seed.end()))==android_c06_counter_seed_sha256,"Different proven counter stream");
  std::ostringstream code;code<<std::hex<<std::setfill('0');
  for(unsigned i=0;i<64;i++)code<<std::setw(2)<<unsigned(guest.read8(guest.physical_address(0x2a4000+i,false,true)));
  require(code.str()==android_original_init_code,"Original init entry bytes changed after the proof");
  return {android_c06_checkpoint_sha256,UINT64_C(6250795356),0x2a4004};
}
} // namespace reverse_pc::guest
