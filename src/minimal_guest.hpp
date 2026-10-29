#pragma once
// Own bounded AArch64 interpreter with optional single-core EL1 machine.
// This is not yet an Android system emulator.
// Immutable ELF bytes + zero rules + XOR deltas in the existing XI authority.
#include "mundo_x/quantum_runtime.hpp"
#include "rxe.hpp"
#include "minimal_guest_machine.hpp"
#include "minimal_guest_fp.hpp"
#include <algorithm>
#include <array>
#include <cstdint>
#include <iomanip>
#include <memory>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

namespace reverse_pc::guest {
using Bytes = std::vector<std::uint8_t>;
inline void require(bool condition, const std::string& message) {
  if (!condition) throw std::runtime_error(message);
}
inline std::uint64_t get(const Bytes& bytes, std::size_t offset, unsigned size) {
  require(offset <= bytes.size() && size <= bytes.size() - offset, "Guest binary is truncated");
  std::uint64_t value = 0;
  for (unsigned i=0; i<size; ++i) value |= std::uint64_t(bytes[offset+i]) << (i*8);
  return value;
}
inline void put(Bytes& bytes, std::uint64_t value, unsigned size=8) {
  for (unsigned i=0; i<size; ++i) bytes.push_back(std::uint8_t(value >> (i*8)));
}
inline std::uint64_t digest(const Bytes& bytes, std::size_t count) {
  std::uint64_t value=UINT64_C(14695981039346656037);
  for (std::size_t i=0; i<count; ++i) { value^=bytes[i]; value*=UINT64_C(1099511628211); }
  return value;
}
inline std::string hex(std::uint64_t value) {
  std::ostringstream out; out << "0x" << std::hex << value; return out.str();
}
inline std::string quote(const std::string& value) {
  std::ostringstream out; out << '"';
  for (unsigned char c:value) {
    if (c=='"' || c=='\\') out << '\\' << char(c);
    else if (c<32 || c>=127) out << "\\u00" << std::hex << std::setfill('0') << std::setw(2) << unsigned(c) << std::dec;
    else out << char(c);
  }
  out << '"'; return out.str();
}

struct Segment {
  std::uint64_t address, size, file_offset, file_size;
  std::uint32_t flags;
};
struct Registers {
  std::array<std::uint64_t,31> x{};
  std::uint64_t sp=0, pc=0, instructions=0;
  unsigned nzcv=0, exit_code=0;
  bool halted=false;
};
struct RunResult {
  std::uint64_t executed=0;
  bool halted=false;
  bool waiting=false;
  unsigned exit_code=0;
  std::string output, error_output;
};

class MinimalGuest {
 public:
  static constexpr std::uint64_t max_ram=UINT64_C(1)<<48;
  // Preserve the old 16 MiB ELF limit and legacy RVG transport. Real AOSP GKI
  // kernels need a *separate* bounded Linux Image path and recoverable RVG
  // backing, not a second RAM/QuantumRuntime or an unbounded allocation.
  static constexpr std::size_t max_image=16*1024*1024, max_snapshot=48*1024*1024;
  static constexpr std::size_t max_linux_kernel=64*1024*1024;
  static constexpr std::size_t max_linux_initrd=64*1024*1024;
  static constexpr std::size_t max_linux_container=128*1024*1024;
  // Larger host-side checkpoint transport only for explicit adaptive guests;
  // this is still finite and must never be mistaken for infinite physical RAM.
  static constexpr std::size_t max_adaptive_snapshot=256*1024*1024;
  static constexpr std::size_t max_output=65536;

  explicit MinimalGuest(std::uint64_t ram=UINT64_C(1)<<30, std::size_t overrides=65536)
      : ram_(ram), override_limit_(overrides), runtime_(make_runtime(overrides)) {
    require(ram>=65536 && ram<=max_ram, "Guest logical RAM must be 64 KiB..256 TiB");
    registers_.sp=ram & ~UINT64_C(15);
  }
  const Registers& registers() const noexcept { return registers_; }
  const mundo_x::QuantumRuntime& runtime() const noexcept { return runtime_; }
  std::uint64_t logical_ram() const noexcept { return ram_; }
  std::size_t image_bytes() const noexcept { return image_ ? image_->size() : 0; }
  const std::vector<Segment>& segments() const noexcept { return segments_; }
  const MachineState& machine() const noexcept { return machine_; }
  const FloatingState& floating() const noexcept { return floating_; }
  std::uint64_t ram_base() const noexcept { return machine_.enabled?MachineState::ram_base:0; }
  std::uint64_t physical_address(std::uint64_t address,bool writing=false,bool executing=false,bool unprivileged=false) const {return translate(address,writing,executing,unprivileged);}

  // The image is immutable backing, not an eager copy into a RAM array.
  // BSS and all unmodified RAM remain represented by the zero rule.
  void load_elf(Bytes bytes,bool privileged=false) {
    require(!privileged || (ram_>=64*1024*1024 && ram_<=max_ram-MachineState::ram_base),"System RAM must be 64 MiB..48-bit physical range");
    require(bytes.size()>=64 && bytes.size()<=max_image, "Guest ELF image must be 64 bytes..16 MiB");
    require(bytes[0]==0x7f && bytes[1]=='E' && bytes[2]=='L' && bytes[3]=='F', "Not an ELF image");
    require(bytes[4]==2 && bytes[5]==1 && bytes[6]==1, "Only little-endian ELF64 v1 is supported");
    require(get(bytes,16,2)==2 && get(bytes,18,2)==183 && get(bytes,20,4)==1,
            "Guest requires a static ET_EXEC AArch64 ELF; APK and dynamic ELF are not supported");
    require(get(bytes,52,2)==64 && get(bytes,54,2)==56, "Unsupported ELF header layout");
    auto offset=get(bytes,32,8), count=get(bytes,56,2), entry=get(bytes,24,8);
    require(count>0 && count<=64 && offset<=bytes.size() && count*56<=bytes.size()-offset,
            "ELF program header table is invalid");
    std::vector<Segment> candidate;
    bool executable_entry=false;
    for (std::uint64_t i=0;i<count;++i) {
      const auto at=std::size_t(offset+i*56), type=get(bytes,at,4);
      require(type!=2 && type!=3, "ELF dynamic linking/interpreter is not implemented");
      if (type!=1) continue;
      Segment segment{get(bytes,at+16,8),get(bytes,at+40,8),get(bytes,at+8,8),get(bytes,at+32,8),std::uint32_t(get(bytes,at+4,4))};
      require(segment.file_size<=segment.size && segment.file_offset<=bytes.size() &&
              segment.file_size<=bytes.size()-segment.file_offset, "ELF segment file extent is invalid");
      ram_range(segment.address,segment.size,privileged?MachineState::ram_base:0);
      const auto alignment=get(bytes,at+48,8);
      require(alignment<=1 || ((alignment&(alignment-1))==0 &&
              (segment.address&(alignment-1))==(segment.file_offset&(alignment-1))), "ELF segment alignment is invalid");
      if (segment.size) candidate.push_back(segment);
      if ((segment.flags&1) && entry>=segment.address && entry-segment.address<segment.size) executable_entry=true;
    }
    std::sort(candidate.begin(),candidate.end(),[](const Segment& a,const Segment& b){return a.address<b.address;});
    require(!candidate.empty() && executable_entry && entry%4==0, "ELF entry is not aligned inside an executable segment");
    for (std::size_t i=1;i<candidate.size();++i)
      require(candidate[i-1].size<=candidate[i].address-candidate[i-1].address, "Overlapping ELF segments are not supported");
    auto immutable=std::make_shared<const Bytes>(std::move(bytes));
    auto empty=make_runtime(override_limit_);
    image_=std::move(immutable); segments_=std::move(candidate); runtime_=std::move(empty);invalidate_translation_hints();
    machine_=MachineState{};machine_.enabled=privileged;machine_.image_kind=privileged?1:0;floating_=FloatingState{};
    registers_=Registers{}; registers_.pc=entry; registers_.sp=(ram_base()+ram_)&~UINT64_C(15);
    machine_.sp1=registers_.sp;
  }

  // Linux Image boot, always backed by the single original XI/Ether runtime.
  // RVI1 stays byte-for-byte for historical Linux checkpoints; RVI2 stores
  // the exact optional Android bootargs in the immutable image so resuming
  // can never silently regenerate a different FDT.
  void load_linux_image(const Bytes& kernel,const Bytes& initrd={},
                        const std::string& bootargs={}) {
    require(ram_>=64*1024*1024 && ram_<=max_ram-MachineState::ram_base,
            "System RAM must be 64 MiB..48-bit physical range");
    require(kernel.size()>=64 && kernel.size()<=max_linux_kernel &&
            get(kernel,56,4)==0x644d5241,
            "Expected an uncompressed AArch64 Linux Image (up to 64 MiB)");
    require(bootargs.size()<=1024 &&
            std::all_of(bootargs.begin(),bootargs.end(),[](unsigned char c){
              return c>=32&&c<=126;
            }),"Guest kernel bootargs must be <=1024 printable ASCII bytes");
    const auto offset=get(kernel,8,8),effective=get(kernel,16,8),flags=get(kernel,24,8);
    require(!(flags&1) && ((flags>>1)&3)<=1,
            "Only little-endian 4 KiB-page Linux Images are supported");
    const auto extent=std::max<std::uint64_t>(kernel.size(),effective);
    require(offset<ram_/2 && extent<=ram_/2-offset,
            "Linux Image does not fit the lower half of system RAM");
    require(offset%4==0 && initrd.size()<=max_linux_initrd &&
            initrd.size()<=ram_/2-2*1024*1024,
            "Linux Image/initrd placement is invalid");
    const auto kernel_address=MachineState::ram_base+offset;
    const auto initrd_address=MachineState::ram_base+ram_/2;
    const auto tree_address=MachineState::ram_base+ram_-2*1024*1024;
    const auto tree=guest_device_tree(ram_,initrd_address,initrd.size(),bootargs);
    const bool extended=!bootargs.empty();
    const std::size_t prefix=extended?40:32;
    require(prefix+kernel.size()+tree.size()+initrd.size()+bootargs.size()<=max_linux_container,
            "Combined Linux Image/DTB/initrd/bootargs exceeds 128 MiB host image budget");
    Bytes container{'R','V','I',std::uint8_t(extended?'2':'1'),13,10,26,10};
    put(container,kernel.size());put(container,tree.size());put(container,initrd.size());
    if(extended)put(container,bootargs.size());
    container.insert(container.end(),kernel.begin(),kernel.end());
    container.insert(container.end(),tree.begin(),tree.end());
    container.insert(container.end(),initrd.begin(),initrd.end());
    if(extended)container.insert(container.end(),bootargs.begin(),bootargs.end());
    auto immutable=std::make_shared<const Bytes>(std::move(container));
    auto empty=make_runtime(override_limit_);
    std::vector<Segment> segments{
      {kernel_address,extent,prefix,kernel.size(),5},
      {tree_address,tree.size(),prefix+kernel.size(),tree.size(),4}
    };
    if(!initrd.empty())
      segments.push_back({initrd_address,initrd.size(),
                          prefix+kernel.size()+tree.size(),initrd.size(),4});
    std::sort(segments.begin(),segments.end(),
              [](const Segment& a,const Segment& b){return a.address<b.address;});
    image_=std::move(immutable);segments_=std::move(segments);invalidate_translation_hints();
    runtime_=std::move(empty);machine_=MachineState{};
    machine_.enabled=true;machine_.image_kind=2;floating_=FloatingState{};
    registers_=Registers{};registers_.pc=kernel_address;
    registers_.x[0]=tree_address;registers_.sp=MachineState::ram_base+ram_;
    machine_.sp1=registers_.sp;
  }
  void console_input(const std::string& text) {
    require(machine_.enabled,"Serial input requires the system machine");
    require(text.size()<=4096-machine_.receive.size(),"Serial input queue exceeds 4096 bytes");
    machine_.receive+=text;
  }

  std::uint8_t read8(std::uint64_t address) const {
    range(address,1);
#ifdef REVERSE_PC_NUMERIC_READ_REFERENCE
    const auto key=std::to_string(address);
    const auto delta=byte_transaction_?byte_transaction_->read(key):runtime_.memory().read(key,runtime_.core());
#else
    const auto delta=byte_transaction_?byte_transaction_->read(address):runtime_.memory().read_numeric(address,runtime_.core());
#endif
    require(delta.deterministic, "Guest read reached an unresolved quantum byte; explicit observation required");
    return backing(address)^delta.value;
  }
  std::uint64_t read(std::uint64_t address,unsigned size) const {
    require(size==1 || size==2 || size==4 || size==8, "Invalid guest word size"); range(address,size);
    std::uint64_t value=0;
    for (unsigned i=0;i<size;++i) value|=std::uint64_t(read8(address+i))<<(8*i);
    return value;
  }
  void write(std::uint64_t address,std::uint64_t value,unsigned size) {
    require(size==1 || size==2 || size==4 || size==8, "Invalid guest word size"); range(address,size);
    invalidate_translation_hints();
    auto store=[&](mundo_x::QuantumRuntime::ByteAccess& bytes){
      for(unsigned i=0;i<size;++i)bytes.store(std::to_string(address+i),std::uint8_t(value>>(i*8))^backing(address+i));
    };
    // The whole execution block owns a private native-byte transaction. Public
    // standalone stores still receive their own all-or-nothing transaction.
    if(byte_transaction_)store(*byte_transaction_);else runtime_.transact_bytes(store);
    machine_.exclusive_address=UINT64_MAX;machine_.exclusive_size=0;
  }
  std::string apply_xi_delta(const std::string& source) { invalidate_translation_hints();auto output=runtime_.execute(source);machine_.exclusive_address=UINT64_MAX;machine_.exclusive_size=0;return output; }
  std::string apply_rxe_delta(const Bytes& image) { invalidate_translation_hints();auto output=reverse_pc::rxe::execute(runtime_,image);machine_.exclusive_address=UINT64_MAX;machine_.exclusive_size=0;return output; }

  // Explicit opt-in: migrate a legacy RVG to the same QuantumRuntime and
  // InverseMemory with adaptive classical storage and no count-only ceiling.
  // Legacy checkpoints remain byte-identical unless this is invoked.
  void enable_adaptive_memory() {
    if (!override_limit_) return;
    auto candidate=make_runtime(0);
    candidate.restore(runtime_.core_snapshot(),runtime_.memory_persistent_snapshot());
    runtime_=std::move(candidate);
    invalidate_translation_hints();
    override_limit_=0; // sentinel: constrained by actual host resources only
  }

  RunResult run(std::uint64_t budget,bool stop_before_el0=false) {
    require(image_!=nullptr, "No ELF guest is loaded");
    require(budget>0 && budget<=1000000, "Guest run budget must be 1..1000000 instructions");
    auto candidate=*this; // Immutable image and unchanged Ether shards are shared.
    RunResult result;
    candidate.runtime_.transact_bytes([&](mundo_x::QuantumRuntime::ByteAccess& bytes){
    candidate.byte_transaction_=&bytes;
    struct Reset {mundo_x::QuantumRuntime::ByteAccess*& pointer;~Reset(){pointer=nullptr;}} reset{candidate.byte_transaction_};
    while (result.executed<budget && !candidate.registers_.halted) {
      // Optional host observation boundary. Preserve the exact ERET result
      // and stop before executing any EL0 instruction; no guest state flag
      // is fabricated or added to the persistent CPU.
      if(stop_before_el0&&candidate.machine_.enabled&&!candidate.machine_.el)break;
      if(candidate.machine_.enabled && candidate.machine_.waiting){
        if(candidate.machine_.next_irq()==1023 && !candidate.machine_.event){
          // Deterministic virtual time may advance only while the CPU waits.
          auto deadline=UINT64_MAX;
          if((candidate.machine_.cntp_ctl&3)==1 && candidate.machine_.cntp_cval>candidate.machine_.ticks)deadline=candidate.machine_.cntp_cval;
          if((candidate.machine_.cntv_ctl&3)==1 && candidate.machine_.cntv_cval>candidate.machine_.ticks)deadline=std::min(deadline,candidate.machine_.cntv_cval);
          if(deadline!=UINT64_MAX)candidate.machine_.ticks=deadline;
        }
        if(candidate.machine_.next_irq()==1023 && !candidate.machine_.event)break;
        candidate.machine_.waiting=false;
      }
      if(candidate.machine_.enabled && !(candidate.machine_.daif&0x80) && candidate.machine_.next_irq()!=1023){
        candidate.exception(0,0,candidate.registers_.pc,true);
        candidate.advance();
      }else try{candidate.step(result);}
      catch(const MachineFault& fault){
        candidate.exception(fault.syndrome,fault.address,candidate.registers_.pc,false);candidate.advance();
      }
      ++result.executed;
    }
    });
    result.halted=candidate.registers_.halted; result.exit_code=candidate.registers_.exit_code;
    result.waiting=candidate.machine_.enabled&&candidate.machine_.waiting;
    *this=std::move(candidate);
    return result;
  }

  Bytes snapshot() const {
    const auto core=runtime_.core_snapshot(), memory=runtime_.memory_persistent_snapshot();
    const auto system=machine_.enabled?machine_.save():Bytes{};
    const auto fp=floating_.save();
    Bytes result{'R','V','G',std::uint8_t(!fp.empty()?'3':machine_.enabled?'2':'1'),13,10,26,10};
    put(result,ram_); put(result,override_limit_); put(result,registers_.pc); put(result,registers_.sp);
    put(result,registers_.instructions); put(result,registers_.nzcv); put(result,registers_.halted?1:0); put(result,registers_.exit_code);
    for (auto value:registers_.x) put(result,value);
    put(result,image_bytes()); put(result,core.size()); put(result,memory.size());
    if(machine_.enabled||!fp.empty())put(result,system.size());
    if(!fp.empty())put(result,fp.size());
    if (image_) result.insert(result.end(),image_->begin(),image_->end());
    result.insert(result.end(),core.begin(),core.end()); result.insert(result.end(),memory.begin(),memory.end());
    result.insert(result.end(),system.begin(),system.end());
    result.insert(result.end(),fp.begin(),fp.end());
    require(result.size()+8<=(override_limit_?max_snapshot:max_adaptive_snapshot),
            "Guest snapshot exceeds configured host transport capacity");
    put(result,digest(result,result.size())); return result;
  }
  static MinimalGuest from_snapshot(const Bytes& bytes) {
    const unsigned version=bytes.size()>=4?unsigned(bytes[3]):0;
    require(version=='1'||version=='2'||version=='3',"Unsupported guest checkpoint version");
    const Bytes magic{'R','V','G',std::uint8_t(version),13,10,26,10};
    const auto max_input_bytes=bytes.size()>=24 && get(bytes,16,8)==0 ?
        max_adaptive_snapshot:max_snapshot;
    require(bytes.size()>=8+8*(8+31+3)+8 && bytes.size()<=max_input_bytes &&
            std::equal(magic.begin(),magic.end(),bytes.begin()), "Invalid guest snapshot header/size");
    require(get(bytes,bytes.size()-8,8)==digest(bytes,bytes.size()-8), "Guest snapshot checksum mismatch");
    std::size_t at=8;
    auto take=[&](){auto value=get(bytes,at,8);at+=8;return value;};
    const auto ram=take(), overrides=take(); MinimalGuest candidate(ram,std::size_t(overrides));
    Registers cpu; cpu.pc=take(); cpu.sp=take(); cpu.instructions=take();
    const auto flags=take(), halted=take(), status=take();
    require(flags<=15 && halted<=1 && status<=255, "Invalid guest CPU snapshot fields");
    cpu.nzcv=unsigned(flags); cpu.halted=halted!=0; cpu.exit_code=unsigned(status);
    for (auto& value:cpu.x) value=take();
    const auto image_size=take(), core_size=take(), memory_size=take(),system_size=version!='1'?take():0,fp_size=version=='3'?take():0;
    const bool system=system_size!=0;
    // An RVG2/3 system snapshot can contain a Linux RVI1 larger than the
    // historical ELF limit. MachineState image_kind below still rejects
    // oversized ELF payloads; this check must not block valid GKI restores.
    require(image_size<=(system?max_linux_container:max_image) &&
            core_size<=max_input_bytes && memory_size<=max_input_bytes &&
            system_size<=8192 && fp_size<=532 && (version!='2'||system) && (version!='3'||fp_size>=20) &&
            image_size+core_size+memory_size+system_size+fp_size==bytes.size()-at-8, "Guest snapshot extents are invalid");
    MachineState machine;
    if(system)machine=MachineState::restore(Bytes(bytes.end()-8-std::size_t(fp_size)-std::size_t(system_size),bytes.end()-8-std::size_t(fp_size)));
    if(image_size){
      const Bytes image(bytes.begin()+at,bytes.begin()+at+std::size_t(image_size));
      if(system&&machine.image_kind==2){
        const Bytes signature{'R','V','I',0,13,10,26,10};
        require(image.size()>=32 &&
                std::equal(signature.begin(),signature.begin()+3,image.begin()) &&
                (image[3]=='1'||image[3]=='2') &&
                std::equal(signature.begin()+4,signature.end(),image.begin()+4),
                "Invalid Linux Image container");
        const bool extended=image[3]=='2';
        const std::size_t prefix=extended?40:32;
        require(image.size()>=prefix,"Truncated Linux boot profile header");
        const auto kernel_size=get(image,8,8),tree_size=get(image,16,8),
                   initrd_size=get(image,24,8),
                   bootargs_size=extended?get(image,32,8):0;
        require(kernel_size<=max_linux_kernel&&tree_size<=65536&&
                initrd_size<=max_linux_initrd &&
                (!extended || (bootargs_size>0&&bootargs_size<=1024)) &&
                kernel_size+tree_size+initrd_size+bootargs_size==image.size()-prefix,
                "Invalid Linux Image container extents");
        const std::size_t k=std::size_t(kernel_size),
                          t=std::size_t(tree_size),
                          rd=std::size_t(initrd_size);
        const std::string args=extended ?
          std::string(image.begin()+prefix+k+t+rd,image.end()):std::string{};
        candidate.load_linux_image(
          Bytes(image.begin()+prefix,image.begin()+prefix+k),
          Bytes(image.begin()+prefix+k+t,image.begin()+prefix+k+t+rd),args);
        require(*candidate.image_==image,
                "Linux Image device tree or boot profile does not match this machine");
      }else candidate.load_elf(image,system);
    }
    require(!system||image_size,"System snapshot is missing its boot image");
    at+=std::size_t(image_size);
    const std::string core(bytes.begin()+at,bytes.begin()+at+std::size_t(core_size)); at+=std::size_t(core_size);
    const std::string memory(bytes.begin()+at,bytes.begin()+at+std::size_t(memory_size));
    candidate.runtime_.restore(core,memory);
    require(cpu.pc%4==0 && (system || (cpu.pc<=ram && (cpu.halted || cpu.pc<ram))), "Invalid guest PC in snapshot");
    if(system){candidate.machine_=std::move(machine);candidate.validate_system_configuration();}
    if(fp_size)candidate.floating_=FloatingState::restore(Bytes(bytes.end()-8-std::size_t(fp_size),bytes.end()-8));
    candidate.registers_=cpu; return candidate;
  }
  std::string statistics() const {
    const auto memory=runtime_.memory().stats();
    const auto core=runtime_.core().stats();
    std::ostringstream out;
    out << "{\"machine\":" << quote(machine_.enabled?"reverse-aarch64-system-v1":"reverse-aarch64-el0-v1") << ",\"state_model\":\"immutable-image-xor-inverse-ether\""
        << ",\"logical_ram_bytes\":" << ram_ << ",\"immutable_image_bytes\":" << image_bytes()
        << ",\"delta_background_byte\":" << unsigned(memory.background_byte)
        << ",\"delta_overrides\":" << memory.overrides << ",\"max_delta_overrides\":" << override_limit_
        << ",\"quantum_bindings\":" << memory.quantum_bindings << ",\"memory_revision\":" << memory.revision
        << ",\"active_qubits\":" << core.active_qubits << ",\"core_revision\":" << core.revision
        << ",\"pc\":" << quote(hex(registers_.pc)) << ",\"sp\":" << quote(hex(registers_.sp))
        << ",\"instructions\":" << registers_.instructions << ",\"halted\":" << (registers_.halted?"true":"false")
        << ",\"exit_code\":" << registers_.exit_code
        << ",\"system_mode\":" << (machine_.enabled?"true":"false") << ",\"exception_level\":" << (machine_.enabled?machine_.el:0)
        << ",\"mmu_enabled\":" << (machine_.enabled&&(machine_.sctlr&1)?"true":"false")
        << ",\"ram_base\":" << quote(hex(ram_base())) << ",\"exceptions\":" << machine_.exceptions
        << ",\"virtual_ticks\":" << machine_.ticks << ",\"waiting\":" << (machine_.waiting?"true":"false")
        << ",\"fp_simd\":\"bounded-armv8-subset\",\"fpcr\":" << floating_.fpcr << ",\"fpsr\":" << floating_.fpsr
        << ",\"nonzero_vector_registers\":" << floating_.nonzero()
        << ",\"android_boot\":\"not_implemented\""
        << ",\"wild_rift\":\"not_supported\",\"hardware_acceleration\":false}";
    return out.str();
  }

 private:
  std::uint64_t ram_;
  std::size_t override_limit_;
  mundo_x::QuantumRuntime runtime_;
  std::shared_ptr<const Bytes> image_;
  std::vector<Segment> segments_;
  Registers registers_;
  MachineState machine_;
  FloatingState floating_;
  mundo_x::QuantumRuntime::ByteAccess* byte_transaction_=nullptr; // Never persisted; scoped to run().
  // Nonpersistent address hints only: never guest bytes or a second RAM.
  // Every memory mutation invalidates them, including XI/RXE and page-table
  // stores. The complete translation controls and access mode are keys.
  struct TranslationHint {
    std::uint64_t generation=0,page=0,physical=0,ttbr0=0,ttbr1=0,tcr=0,sctlr=0;
    unsigned mode=0;
  };
  std::uint64_t translation_generation_=1;
  mutable std::array<TranslationHint,64> translation_hints_{};
  void invalidate_translation_hints() {
    if(++translation_generation_==0){translation_hints_={};translation_generation_=1;}
  }

  static mundo_x::QuantumRuntime make_runtime(std::size_t overrides) {
    // 0 disables the arbitrary override *count* cap; allocation, address,
    // snapshot, and host memory availability are still real finite limits.
    mundo_x::InverseMemory::Limits memory; memory.max_overrides=overrides;
    return mundo_x::QuantumRuntime(mundo_x::InfiniteCore::Background::Zero,mundo_x::InfiniteCore::Limits{},memory);
  }
  void range(std::uint64_t address,std::uint64_t size) const {
    ram_range(address,size,ram_base());
  }
  void ram_range(std::uint64_t address,std::uint64_t size,std::uint64_t base) const {
    // Error formatting was previously eager even for *valid* accesses.
    // During a real AOSP kernel boot this constructed a hex stream on
    // millions of XI/Ether memory reads. Preserve exactly the same
    // short-circuit bounds check; create its text only on an actual fault.
    if(!(address>=base && address-base<=ram_ && size<=ram_-(address-base)))
      throw std::runtime_error("Guest address outside logical RAM: "+hex(address));
  }
  std::uint8_t backing(std::uint64_t address) const {
    auto found=std::upper_bound(segments_.begin(),segments_.end(),address,
        [](std::uint64_t value,const Segment& segment){return value<segment.address;});
    if (found==segments_.begin()) return 0;
    const auto& segment=*--found;
    const auto relative=address-segment.address;
    return relative<segment.file_size ? (*image_)[std::size_t(segment.file_offset+relative)] : 0;
  }
  static std::int64_t signed_field(std::uint64_t value,unsigned bits) {
    const auto sign=UINT64_C(1)<<(bits-1);
    return (value&sign) ? -std::int64_t((UINT64_C(1)<<bits)-value) : std::int64_t(value);
  }
  static std::uint64_t mask(unsigned bits) { return bits==64 ? UINT64_MAX : UINT64_C(0xffffffff); }
  static std::uint64_t low_mask(unsigned bits){return bits==64?UINT64_MAX:(UINT64_C(1)<<bits)-1;}
  static std::pair<std::uint64_t,std::uint64_t> bit_masks(unsigned n,unsigned last,unsigned rotation,unsigned bits,bool immediate){
    const unsigned encoded=(n<<6)|((~last)&63);unsigned length=0;
    for(unsigned i=0;i<7;++i)if(encoded&(1u<<i))length=i;
    require(length>=1,"Invalid AArch64 bit mask");const unsigned element=1u<<length,levels=element-1;
    require(element<=bits && (!immediate||(last&levels)!=levels),"Reserved AArch64 bit mask");
    const unsigned r=rotation&levels,s=last&levels;auto w=low_mask(s+1),t=low_mask(((s-r)&levels)+1);
    if(r)w=((w>>r)|(w<<(element-r)))&low_mask(element);
    std::uint64_t write_mask=0,top_mask=0;
    for(unsigned i=0;i<bits;i+=element){write_mask|=w<<i;top_mask|=t<<i;}
    return {write_mask,top_mask};
  }
  std::uint64_t reg(unsigned index,unsigned bits=64,bool stack=false) const {
    return (index==31 ? (stack?registers_.sp:0) : registers_.x[index])&mask(bits);
  }
  void set(unsigned index,std::uint64_t value,unsigned bits=64,bool stack=false) {
    value&=mask(bits);
    if (index!=31) registers_.x[index]=value;
    else if (stack) registers_.sp=value;
  }
  void flags(std::uint64_t a,std::uint64_t b,std::uint64_t result,unsigned bits,bool subtract) {
    const auto sign=UINT64_C(1)<<(bits-1); a&=mask(bits); b&=mask(bits); result&=mask(bits);
    const bool carry=subtract ? a>=b : a>mask(bits)-b;
    const bool overflow=((subtract?(a^b):~(a^b))&(a^result)&sign)!=0;
    registers_.nzcv=(result&sign?8:0)|(result==0?4:0)|(carry?2:0)|(overflow?1:0);
  }
  bool condition(unsigned code) const {
    const bool n=registers_.nzcv&8,z=registers_.nzcv&4,c=registers_.nzcv&2,v=registers_.nzcv&1;
    const std::array<bool,8> values{z,c,n,v,c&&!z,n==v,!z&&(n==v),true};
    const bool value=values[code>>1]; return (code&1) && code!=15 ? !value : value;
  }
  static std::uint64_t shift(std::uint64_t value,unsigned amount,unsigned kind,unsigned bits) {
    value&=mask(bits); require(amount<bits,"Invalid AArch64 shift");
    if (!amount) return value;
    if (kind==0) return (value<<amount)&mask(bits);
    if (kind==1) return value>>amount;
    if (kind==2) return (value>>amount)|((value&(UINT64_C(1)<<(bits-1)))?(mask(bits)^(mask(bits)>>amount)):0);
    return ((value>>amount)|(value<<(bits-amount)))&mask(bits);
  }
  void step(RunResult& result);
  void advance(){require(registers_.instructions!=UINT64_MAX,"Guest instruction counter overflow");++registers_.instructions;
    if(machine_.enabled){require(machine_.ticks!=UINT64_MAX,"Guest virtual timer overflow");++machine_.ticks;}}
  void validate_system_configuration() const;
  std::uint64_t translate(std::uint64_t address,bool writing=false,bool executing=false,bool unprivileged=false) const;
  std::uint64_t cpu_read(std::uint64_t address,unsigned size,RunResult& result,bool executing=false,bool unprivileged=false);
  void cpu_write(std::uint64_t address,std::uint64_t value,unsigned size,RunResult& result,bool unprivileged=false);
  void check_access(std::uint64_t address,unsigned size,bool writing,bool executing=false,bool unprivileged=false) const;
  std::array<std::uint64_t,16> resolve_access(std::uint64_t address,unsigned size,bool writing,bool executing=false,bool unprivileged=false) const;
  std::uint64_t device_read(std::uint64_t address,unsigned size);
  void device_write(std::uint64_t address,std::uint64_t value,unsigned size,RunResult& result);
  bool device_address(std::uint64_t address) const;
  std::uint64_t system_read(unsigned id) const;
  void system_write(unsigned id,std::uint64_t value);
  void exception(std::uint64_t syndrome,std::uint64_t address,std::uint64_t return_pc,bool irq);
  void select_stack(unsigned el,unsigned selected);
  void fp_access() const {
    if(machine_.enabled){const auto mode=(machine_.cpacr>>20)&3;
      if(mode==0||mode==2||(mode==1&&!machine_.el))throw MachineFault{(UINT64_C(7)<<26)|(1u<<25),0};}
  }
  void fp_set(unsigned reg,std::uint64_t value,unsigned bits){floating_.v[reg]={value&(bits==64?UINT64_MAX:low_mask(bits)),0};}
  Vector128 fp_load(std::uint64_t address,unsigned bytes,RunResult& result){
    check_access(address,bytes,false);Vector128 value;value.low=cpu_read(address,std::min(bytes,8u),result);
    if(bytes==16)value.high=cpu_read(address+8,8,result);return value;
  }
  void fp_store(std::uint64_t address,const Vector128& value,unsigned bytes,RunResult& result){
    check_access(address,bytes,true);cpu_write(address,value.low,std::min(bytes,8u),result);
    if(bytes==16)cpu_write(address+8,value.high,8,result);
  }
  bool fp_instruction(std::uint32_t instruction,std::uint64_t pc,RunResult& result);
};

#include "minimal_guest_system.inc"
#include "minimal_guest_simd.inc"

inline void MinimalGuest::step(RunResult& result) {
  auto& cpu=registers_;
  require(cpu.pc%4==0,"Unaligned AArch64 instruction address");
  const auto pc=cpu.pc;
  const auto instruction=std::uint32_t(cpu_read(pc,4,result,true));
  auto next=pc+4;
  const unsigned bits=(instruction>>31)?64:32, rd=instruction&31, rn=(instruction>>5)&31, rm=(instruction>>16)&31;
  auto unsupported=[&](){throw std::runtime_error("Unsupported AArch64 instruction "+hex(instruction)+" at "+hex(pc));};
  if (instruction==0xd503201f || instruction==0xd503203f || instruction==0xd503229f || instruction==0xd503241f ||
      instruction==0xd503245f || instruction==0xd503249f || instruction==0xd50324df ||
      instruction==0xd50320ff || instruction==0xd503233f || instruction==0xd503237f ||
      instruction==0xd50323bf || instruction==0xd50323ff) {
    // NOP/YIELD, CSDB (Consume Speculative Data Barrier), and BTI hints.
    // This software CPU performs no speculative memory reads, so CSDB adds
    // no effect beyond preserving program order. ID registers omit BTI; the
    // architecturally backwards-compatible BTI/PAuth HINT encodings are NOPs.
    // PAuth/BTI features are not advertised; authenticated branch opcodes are
    // not accepted as ordinary branches.
  }
  else if (instruction==0xd503205f || instruction==0xd503207f || instruction==0xd503209f || instruction==0xd50320bf) {
    require(machine_.enabled,"Wait/event instructions require the system machine");
    if(instruction==0xd503205f){if(machine_.event)machine_.event=false;else machine_.waiting=true;}
    if(instruction==0xd503207f)machine_.waiting=true;
    if(instruction==0xd503209f||instruction==0xd50320bf)machine_.event=true;
  }
  else if ((instruction&0xfffff0ff)==0xd503309f || (instruction&0xfffff0ff)==0xd50330bf || instruction==0xd5033fdf) {
    // DSB/DMB/ISB: a single core with synchronous coherent memory has no pending operations.
  }
  else if ((instruction&0xfffff0ff)==0xd50340df || (instruction&0xfffff0ff)==0xd50340ff) {
    require(machine_.enabled,"DAIF requires system mode");if(!machine_.el)throw MachineFault{1u<<25,0};
    const auto field=((instruction>>8)&15)<<6;
    if(instruction&32)machine_.daif&=~field;else machine_.daif|=field;
  }
  else if ((instruction&0xfffffeff)==0xd50040bf) {
    require(machine_.enabled,"SPSel requires system mode");if(!machine_.el)throw MachineFault{1u<<25,0};select_stack(1,(instruction>>8)&1);
  }
  else if ((instruction&0xfff00000)==0xd5300000) { set(rd,system_read((instruction>>5)&65535)); }
  else if ((instruction&0xfff00000)==0xd5100000) { system_write((instruction>>5)&65535,reg(rd)); }
  else if (instruction==0xd69f03e0) { // ERET EL1 -> EL1h/EL1t/EL0t
    require(machine_.enabled,"ERET requires system mode");if(!machine_.el)throw MachineFault{1u<<25,0};
    const auto saved=machine_.spsr,mode=saved&31;
    // Bit 12 is SPSR_EL1.SSBS. Linux can set it in an EL0 saved frame even
    // when this sequential CPU does not advertise speculative execution or
    // FEAT_SSBS. Accept the bit as an inert architectural marker; do not
    // interpret it as a change in privilege or erase the other reserved-bit
    // checks. A user return remains an EL0 return, never an EL1 shortcut.
    require((mode==0||mode==4||mode==5) && !(saved&~UINT64_C(0xf00013df)),"Unsupported ERET processor state");
    require(!(machine_.elr&3),"Unaligned ERET target");
    next=machine_.elr;select_stack(mode?1:0,mode==5?1:0);machine_.daif=unsigned(saved)&0x3c0;cpu.nzcv=unsigned(saved>>28)&15;
    machine_.exclusive_address=UINT64_MAX;machine_.exclusive_size=0;
  }
  else if ((instruction&0xfff80000)==0xd5080000) { // selected SYS operations
    require(machine_.enabled,"SYS requires system mode");if(!machine_.el)throw MachineFault{1u<<25,0};
    const auto op1=(instruction>>16)&7,crn=(instruction>>12)&15,crm=(instruction>>8)&15,op2=(instruction>>5)&7;
    if(crn==8 && (op1==0) && (crm==3||crm==7) && op2<=7){invalidate_translation_hints();}
    else if(crn==7 && ((op1==0&&(crm==1||crm==5||crm==6||crm==10||crm==11||crm==14)) || (op1==3&&(crm==5||crm==10||crm==11||crm==14)))){ /* coherent cache maintenance */ }
    else if(crn==7&&op1==0&&crm==8&&op2<=3){
      try{const auto physical=translate(reg(rd),op2&1);machine_.par=physical&~UINT64_C(4095);}
      catch(const MachineFault& fault){machine_.par=1|((fault.syndrome&63)<<1);}
    }
    else if(crn==7&&op1==3&&crm==4&&op2==1){const auto address=reg(rd)&~UINT64_C(63);check_access(address,8,true);check_access(address+56,8,true);
      for(unsigned i=0;i<64;i+=8)cpu_write(address+i,0,8,result);}
    else unsupported();
  }
  else if ((instruction&0xffe0001f)==0xd4000002 || (instruction&0xffe0001f)==0xd4000003) { // HVC/SMC PSCI subset
    require(machine_.enabled&&machine_.el,"PSCI requires system mode EL1");require(((instruction>>5)&65535)==0,"Only PSCI call immediate zero is supported");
    const auto function=reg(0,32);
    if(function==0x84000000)set(0,0x10000);
    else if(function==0x84000008){cpu.halted=true;cpu.exit_code=0;}
    else if(function==0x8400000a)set(0,(reg(1,32)==0x84000008||reg(1,32)==0x84000000||reg(1,32)==0x8400000a)?0:UINT64_MAX);
    else set(0,UINT64_MAX); // PSCI_NOT_SUPPORTED
  }
  else if (fp_instruction(instruction,pc,result)) { /* shared vector/FP register bank */ }
  else if ((instruction&0x1f800000)==0x12800000) { // MOVN/MOVZ/MOVK
    const unsigned opcode=(instruction>>29)&3, position=((instruction>>21)&3)*16;
    if (opcode==1 || position>=bits) unsupported();
    const auto value=std::uint64_t((instruction>>5)&0xffff)<<position;
    set(rd,opcode==0?~value:opcode==2?value:(reg(rd,bits)&~(UINT64_C(0xffff)<<position))|value,bits);
  }
  else if ((instruction&0x1f000000)==0x11000000 && !(instruction&0x00800000)) { // ADD/SUB immediate
    const bool subtract=instruction&0x40000000, update=instruction&0x20000000;
    const auto a=reg(rn,bits,true), b=std::uint64_t((instruction>>10)&4095)<<((instruction&0x00400000)?12:0);
    const auto value=(subtract?a-b:a+b)&mask(bits);
    if (update) flags(a,b,value,bits,subtract);
    set(rd,value,bits,!update);
  }
  else if ((instruction&0x1f200000)==0x0b000000) { // ADD/SUB shifted register
    const unsigned kind=(instruction>>22)&3, amount=(instruction>>10)&63;
    if (kind==3 || amount>=bits) unsupported();
    const bool subtract=instruction&0x40000000, update=instruction&0x20000000;
    const auto a=reg(rn,bits), b=shift(reg(rm,bits),amount,kind,bits), value=(subtract?a-b:a+b)&mask(bits);
    if (update) flags(a,b,value,bits,subtract);
    set(rd,value,bits);
  }
  else if ((instruction&0x1f200000)==0x0b200000) { // ADD/SUB extended register
    const unsigned option=(instruction>>13)&7,amount=(instruction>>10)&7,extent=8u<<(option&3);
    if(amount>4 || (bits==32&&(option&3)==3))unsupported();
    auto b=reg(rm)&low_mask(extent);
    if((option&4)&&(b&(UINT64_C(1)<<(extent-1))))b|=~low_mask(extent);
    b=(b<<amount)&mask(bits);const auto a=reg(rn,bits,true);
    const bool subtract=instruction&0x40000000,update=instruction&0x20000000;
    const auto value=(subtract?a-b:a+b)&mask(bits);
    if(update)flags(a,b,value,bits,subtract);set(rd,value,bits,!update);
  }
  else if ((instruction&0x1fe0fc00)==0x1a000000) { // ADC/ADCS/SBC/SBCS
    const bool subtract=instruction&0x40000000,update=instruction&0x20000000;
    const auto a=reg(rn,bits),b=subtract?(~reg(rm,bits)&mask(bits)):reg(rm,bits),carry=std::uint64_t((cpu.nzcv>>1)&1);
    const auto partial=(a+b)&mask(bits),value=(partial+carry)&mask(bits);
    if(update){const auto sign=UINT64_C(1)<<(bits-1);cpu.nzcv=(value&sign?8:0)|(value==0?4:0)|
      ((partial<a||value<partial)?2:0)|((~(a^b)&(a^value)&sign)?1:0);}
    set(rd,value,bits);
  }
  else if ((instruction&0x1f800000)==0x12000000) { // logical immediate
    const unsigned opcode=(instruction>>29)&3;
    const auto masks=bit_masks((instruction>>22)&1,(instruction>>10)&63,(instruction>>16)&63,bits,true);
    const auto a=reg(rn,bits),b=masks.first,value=(opcode==0||opcode==3)?a&b:opcode==1?a|b:a^b;
    set(rd,value,bits,opcode!=3);
    if(opcode==3)cpu.nzcv=(value&(UINT64_C(1)<<(bits-1))?8:0)|(value==0?4:0);
  }
  else if ((instruction&0x1f000000)==0x0a000000) { // logical shifted register
    const unsigned opcode=(instruction>>29)&3, amount=(instruction>>10)&63;
    if (amount>=bits) unsupported();
    const auto a=reg(rn,bits);
    auto b=shift(reg(rm,bits),amount,(instruction>>22)&3,bits);
    if (instruction&0x00200000) b=(~b)&mask(bits);
    const auto value=(opcode==0||opcode==3)?a&b:opcode==1?a|b:a^b;
    set(rd,value,bits);
    if (opcode==3) cpu.nzcv=(value&(UINT64_C(1)<<(bits-1))?8:0)|(value==0?4:0);
  }
  else if ((instruction&0x1f000000)==0x10000000) { // ADR/ADRP
    const auto immediate=signed_field((((instruction>>5)&0x7ffff)<<2)|((instruction>>29)&3),21);
    const bool page=instruction&0x80000000;
    set(rd,(page?(pc&~UINT64_C(4095)):pc)+std::uint64_t(immediate)*(page?4096:1));
  }
  else if ((instruction&0x1fe00800)==0x1a800000) { // CSEL/CSINC/CSINV/CSNEG
    auto value=reg(rn,bits);
    if(!condition((instruction>>12)&15)){value=reg(rm,bits);if(instruction&0x40000000)value=~value;if(instruction&0x400)++value;}
    set(rd,value,bits);
  }
  else if ((instruction&0x1fe00410)==0x1a400000 && (instruction&0x20000000)) { // CCMP/CCMN, immediate/register
    if(condition((instruction>>12)&15)){
      const auto a=reg(rn,bits),b=(instruction&0x800)?std::uint64_t(rm):reg(rm,bits);const bool subtract=instruction&0x40000000;
      flags(a,b,(subtract?a-b:a+b)&mask(bits),bits,subtract);
    }else cpu.nzcv=instruction&15;
  }
  else if ((instruction&0x7c000000)==0x14000000) { // B/BL
    if (instruction&0x80000000) set(30,next);
    next=pc+std::uint64_t(signed_field(instruction&0x3ffffff,26))*4;
  }
  else if ((instruction&0xff000010)==0x54000000) { // B.cond
    if (condition(instruction&15)) next=pc+std::uint64_t(signed_field((instruction>>5)&0x7ffff,19))*4;
  }
  else if ((instruction&0x7e000000)==0x34000000) { // CBZ/CBNZ
    if ((reg(rd,bits)!=0)==bool(instruction&0x01000000)) next=pc+std::uint64_t(signed_field((instruction>>5)&0x7ffff,19))*4;
  }
  else if ((instruction&0x7e000000)==0x36000000) { // TBZ/TBNZ
    const unsigned bit=((instruction>>31)<<5)|((instruction>>19)&31);
    if (bool((reg(rd)>>bit)&1)==bool(instruction&0x01000000)) next=pc+std::uint64_t(signed_field((instruction>>5)&0x3fff,14))*4;
  }
  else if ((instruction&0xfffffc1f)==0xd61f0000 || (instruction&0xfffffc1f)==0xd63f0000 ||
           (instruction&0xfffffc1f)==0xd65f0000) { // BR/BLR/RET
    if (rn==31) unsupported();
    const auto target=reg(rn);
    if ((instruction&0xfffffc1f)==0xd63f0000) set(30,next);
    next=target;
  }
  else if ((instruction&0xffe0001f)==0xd4000001) { // SVC #0; minimal Linux ABI shim
    if(machine_.enabled){exception((UINT64_C(0x15)<<26)|(1u<<25)|((instruction>>5)&65535),0,next,false);advance();return;}
    require(((instruction>>5)&0xffff)==0,"Only SVC #0 is supported by the guest ABI shim");
    const auto service=reg(8);
    if (service==93 || service==94) { cpu.halted=true; cpu.exit_code=unsigned(reg(0)&255); }
    else if (service==64) {
      const auto fd=reg(0), address=reg(1), count=reg(2);
      if (fd!=1 && fd!=2) set(0,UINT64_MAX-8); // -EBADF
      else {
        require(count<=max_output && result.output.size()+result.error_output.size()<=max_output-count,
                "Guest output budget exceeded");
        range(address,count);
        auto& destination=fd==1?result.output:result.error_output;
        for (std::uint64_t i=0;i<count;++i) destination.push_back(char(read8(address+i)));
        set(0,count);
      }
    } else throw std::runtime_error("Unsupported guest syscall "+std::to_string(service)+" at "+hex(pc));
  }
  else if ((instruction&0xfffff0ff)==0xd503305f) { // CLREX
    machine_.exclusive_address=UINT64_MAX;machine_.exclusive_size=0;
  }
  else if ((instruction&0x3f9f7c00)==0x089f7c00) { // LDAR/STLR
    const unsigned size=1u<<(instruction>>30);const auto address=reg(rn,64,true);
    if(address&(size-1)){
      require(machine_.enabled,"Unaligned acquire/release access");
      throw MachineFault{(std::uint64_t(machine_.el?0x25:0x24)<<26)|(1u<<25)|((instruction&0x00400000)?0u:64u)|0x21,address};
    }
    if(instruction&0x00400000)set(rd,cpu_read(address,size,result),size==8?64:32);
    else cpu_write(address,reg(rd),size,result);
  }
  else if ((instruction&0xbfa00000)==0x88200000) { // LDXP/LDAXP/STXP/STLXP
    require(machine_.enabled,"Exclusive pair instructions require system mode");
    const bool load=instruction&0x00400000;
    const unsigned size=(instruction&0x40000000)?8:4,total=2*size;
    const unsigned second=(instruction>>10)&31,status=(instruction>>16)&31;
    if((load&&(status!=31||rd==second))||
       (!load&&(status==rd||status==second||(rn!=31&&status==rn))))unsupported();
    const auto address=reg(rn,64,true);
    if(address&(total-1))
      throw MachineFault{(std::uint64_t(machine_.el?0x25:0x24)<<26)|
                         (1u<<25)|(load?0u:64u)|0x21,address};
    // Validate the entire pair before publishing either register or byte.
    // The same XI/Ether authority owns both halves; there is no pair RAM.
    const auto physical=resolve_access(address,total,!load);
    if(load){
      const auto first=read(physical[0],size),last=read(physical[size],size);
      set(rd,first,size==8?64:32);set(second,last,size==8?64:32);
      machine_.exclusive_address=physical[0];machine_.exclusive_size=total;
    }else{
      const bool success=machine_.exclusive_size==total&&
                         machine_.exclusive_address==physical[0];
      const auto first=reg(rd),last=reg(second);
      if(success){
        // Pin the already checked physical extent for the whole atomic
        // instruction, even if its first half changes a page-table entry.
        invalidate_translation_hints();
        auto store=[&](mundo_x::QuantumRuntime::ByteAccess& bytes){
          for(unsigned i=0;i<total;++i){
            const auto value=std::uint8_t((i<size?first:last)>>(8*(i%size)));
            bytes.store(std::to_string(physical[i]),value^backing(physical[i]));
          }
        };
        if(byte_transaction_)store(*byte_transaction_);else runtime_.transact_bytes(store);
      }
      set(status,success?0:1,32);
      machine_.exclusive_address=UINT64_MAX;machine_.exclusive_size=0;
    }
    // Acquire/release variants retain program order in this coherent,
    // synchronous single-core machine, as do the existing LDAR/STLR paths.
  }
  else if ((instruction&0x3f207c00)==0x08007c00) { // LDXR/LDAXR/STXR/STLXR, single register
    require(machine_.enabled,"Exclusive instructions currently require system mode");
    const unsigned size=1u<<(instruction>>30),status=(instruction>>16)&31;const auto address=reg(rn,64,true);
    if(address&(size-1))throw MachineFault{(std::uint64_t(machine_.el?0x25:0x24)<<26)|(1u<<25)|((instruction&0x00400000)?0u:64u)|0x21,address};
    if(instruction&0x00400000){set(rd,cpu_read(address,size,result),size==8?64:32);machine_.exclusive_address=translate(address);machine_.exclusive_size=size;}
    else{
      check_access(address,size,true);const bool success=machine_.exclusive_size==size&&machine_.exclusive_address==translate(address,true);
      if(success)cpu_write(address,reg(rd),size,result);set(status,success?0:1,32);machine_.exclusive_address=UINT64_MAX;machine_.exclusive_size=0;
    }
  }
  else if ((instruction&0x3b000000)==0x39000000 && !(instruction&0x04000000)) { // LDR/STR unsigned offset
    const unsigned size=1u<<(instruction>>30), opcode=(instruction>>22)&3;
    if ((opcode>=2&&size==8)||(opcode==3&&size==4)) { if(opcode==2&&size==8){/* PRFM is a hint. */}else unsupported(); }
    else {
    const auto address=reg(rn,64,true)+std::uint64_t((instruction>>10)&4095)*size;
    if (opcode){auto value=cpu_read(address,size,result);if(opcode>=2 && (value&(UINT64_C(1)<<(size*8-1))))value|=~low_mask(size*8);set(rd,value,opcode==2||size==8?64:32);}
    else cpu_write(address,reg(rd),size,result);
    }
  }
  else if ((instruction&0x3b200c00)==0x38200800 && !(instruction&0x04000000)) { // register offset integer LDR/STR
    const unsigned size=1u<<(instruction>>30),opcode=(instruction>>22)&3,option=(instruction>>13)&7;
    if((option&2)==0 || (opcode>=2&&size==8)||(opcode==3&&size==4))unsupported();
    auto offset=reg(rm,option&1?64:32);
    if(option==6 && (offset&0x80000000))offset|=UINT64_C(0xffffffff00000000);
    if(instruction&0x1000)offset<<=instruction>>30;
    const auto address=reg(rn,64,true)+offset;
    if(opcode){auto value=cpu_read(address,size,result);if(opcode>=2&&(value&(UINT64_C(1)<<(size*8-1))))value|=~low_mask(size*8);set(rd,value,opcode==2||size==8?64:32);}
    else cpu_write(address,reg(rd),size,result);
  }
  else if ((instruction&0x3b000000)==0x18000000 && !(instruction&0x04000000)) { // LDR literal/LDRSW
    const unsigned opcode=instruction>>30;
    if (opcode==3) unsupported();
    auto value=cpu_read(pc+std::uint64_t(signed_field((instruction>>5)&0x7ffff,19))*4,opcode==1?8:4,result);
    if (opcode==2 && (value&0x80000000)) value|=UINT64_C(0xffffffff00000000);
    set(rd,value,opcode==0?32:64);
  }
  else if ((instruction&0x3b200000)==0x38000000 && !(instruction&0x04000000)) { // LDUR/STUR, LDTR/STTR, pre/post-index
    const unsigned size=1u<<(instruction>>30), opcode=(instruction>>22)&3, mode=(instruction>>10)&3;
    // Mode 2 is the architected unprivileged LDTR/STTR family. In EL1 with
    // UAO==0 it observes EL0 page permissions, without lowering the current
    // exception level or changing the EL1 data-abort syndrome.
    const bool unprivileged=(mode==2),writeback=(mode==1||mode==3);
    if ((opcode>=2&&size==8)||(opcode==3&&size==4) || (writeback && rn!=31 && rn==rd)) unsupported();
    const auto base=reg(rn,64,true), updated=base+std::uint64_t(signed_field((instruction>>12)&511,9));
    const auto address=mode==1?base:updated;
    if (opcode){auto value=cpu_read(address,size,result,false,unprivileged);if(opcode>=2&&(value&(UINT64_C(1)<<(size*8-1))))value|=~low_mask(size*8);set(rd,value,opcode==2||size==8?64:32);}
    else cpu_write(address,reg(rd),size,result,unprivileged);
    if (writeback) set(rn,updated,64,true);
  }
  else if ((instruction&0x3a000000)==0x28000000 && !(instruction&0x04000000)) { // LDP/STP/LDPSW integers
    const unsigned opcode=instruction>>30, second=(instruction>>10)&31, mode=(instruction>>23)&3;
    const bool load=instruction&0x00400000, writeback=mode==1||mode==3;
    if (opcode==3 || (opcode==1&&(!load||mode==0)) || (load&&rd==second) || (writeback && rn!=31 && (rn==rd || rn==second))) unsupported();
    const unsigned size=opcode==2?8:4;
    const auto base=reg(rn,64,true), updated=base+std::uint64_t(signed_field((instruction>>15)&127,7))*size;
    const auto address=mode==1?base:updated;check_access(address,size, !load);check_access(address+size,size,!load);
    if (load) {
      auto first_value=cpu_read(address,size,result), second_value=cpu_read(address+size,size,result);
      if(opcode==1){if(first_value&0x80000000)first_value|=UINT64_C(0xffffffff00000000);if(second_value&0x80000000)second_value|=UINT64_C(0xffffffff00000000);}
      set(rd,first_value,opcode==1?64:size*8); set(second,second_value,opcode==1?64:size*8);
    } else { cpu_write(address,reg(rd),size,result); cpu_write(address+size,reg(second),size,result); }
    if (writeback) set(rn,updated,64,true);
  }
  else if ((instruction&0x1f800000)==0x13000000) { // SBFM/BFM/UBFM, all valid bitfield masks
    const unsigned opcode=(instruction>>29)&3, rotation=(instruction>>16)&63, last=(instruction>>10)&63;
    if (((instruction>>22)&1)!=(bits==64) || rotation>=bits || last>=bits || opcode==3) unsupported();
    const auto masks=bit_masks((instruction>>22)&1,last,rotation,bits,false);const auto value=reg(rn,bits);
    auto bottom=shift(value,rotation,3,bits)&masks.first;std::uint64_t top=0;
    if(opcode==0)top=(value&(UINT64_C(1)<<last))?mask(bits):0;
    if(opcode==1){top=reg(rd,bits);bottom=(top&~masks.first)|bottom;}
    const auto output=(top&~masks.second)|(bottom&masks.second);
    set(rd,output,bits);
  }
  else if ((instruction&0x1f800000)==0x13800000) { // EXTR
    const unsigned amount=(instruction>>10)&63;if(amount>=bits || ((instruction>>22)&1)!=(bits==64))unsupported();
    set(rd,amount?((reg(rm,bits)>>amount)|(reg(rn,bits)<<(bits-amount))):reg(rm,bits),bits);
  }
  else if ((instruction&0x7fe0f000)==0x1ac02000) { // LSLV/LSRV/ASRV/RORV
    set(rd,shift(reg(rn,bits),unsigned(reg(rm,bits))&(bits-1),(instruction>>10)&3,bits),bits);
  }
  else if ((instruction&0x7fff0000)==0x5ac00000) { // RBIT/REV16/REV32/REV/CLZ/CLS
    const unsigned opcode=(instruction>>10)&63;auto value=reg(rn,bits);std::uint64_t output=0;
    if(opcode==0){for(unsigned i=0;i<bits;++i)output|=((value>>i)&1)<<(bits-1-i);}
    else if(opcode<=3){
      const unsigned group=1u<<(opcode+3);if(group>bits)unsupported();
      for(unsigned start=0;start<bits;start+=group)for(unsigned byte=0;byte<group/8;++byte)
        output|=((value>>(start+8*byte))&255)<<(start+group-8*(byte+1));
    }else if(opcode==4||opcode==5){
      if(opcode==5&&(value&(UINT64_C(1)<<(bits-1))))value=(~value)&mask(bits);
      for(unsigned i=bits;i>0&&!(value&(UINT64_C(1)<<(i-1)));--i)++output;
      if(opcode==5)--output;
    }else unsupported();
    set(rd,output,bits);
  }
  else if ((instruction&0x7fe0fc00)==0x1ac00800 || (instruction&0x7fe0fc00)==0x1ac00c00) { // UDIV/SDIV
    const auto a=reg(rn,bits), b=reg(rm,bits); std::uint64_t value=0;
    if (b) {
      if (instruction&0x400) {
        const auto sign=UINT64_C(1)<<(bits-1);
        const bool negative_a=a&sign, negative_b=b&sign;
        const auto abs_a=negative_a?((~a+1)&mask(bits)):a, abs_b=negative_b?((~b+1)&mask(bits)):b;
        value=abs_a/abs_b; if (negative_a!=negative_b) value=~value+1;
      } else value=a/b;
    }
    set(rd,value,bits);
  }
  else if ((instruction&0xff600000)==0x9b200000) { // SMADDL/UMADDL/SMSUBL/UMSUBL
    auto a=reg(rn,32),b=reg(rm,32);
    if(!(instruction&0x00800000)){if(a&0x80000000)a|=UINT64_C(0xffffffff00000000);if(b&0x80000000)b|=UINT64_C(0xffffffff00000000);}
    const auto product=a*b,accumulator=reg((instruction>>10)&31);
    set(rd,(instruction&0x8000)?accumulator-product:accumulator+product);
  }
  else if ((instruction&0xff60fc00)==0x9b407c00) { // SMULH/UMULH, upper half of a 128-bit product
    const auto a=reg(rn),b=reg(rm),a0=a&0xffffffff,b0=b&0xffffffff,a1=a>>32,b1=b>>32;
    const auto p0=a0*b0,p1=a0*b1,p2=a1*b0,p3=a1*b1;
    const auto middle=(p0>>32)+(p1&0xffffffff)+(p2&0xffffffff);
    auto high=p3+(p1>>32)+(p2>>32)+(middle>>32);
    if(!(instruction&0x00800000)){if(a>>63)high-=b;if(b>>63)high-=a;}
    set(rd,high);
  }
  else if ((instruction&0x7fe00000)==0x1b000000) { // MADD/MSUB, including MUL alias
    const auto product=reg(rn,bits)*reg(rm,bits), accumulator=reg((instruction>>10)&31,bits);
    set(rd,(instruction&0x8000)?accumulator-product:accumulator+product,bits);
  }
  else { unsupported(); }
  require(next%4==0,"Guest branch target is unaligned");if(!machine_.enabled)range(next,cpu.halted?0:4);
  cpu.pc=next;advance();
}
} // namespace reverse_pc::guest
