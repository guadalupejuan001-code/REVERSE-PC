#pragma once
// Experimental AArch64 EL0 guest. This is not an Android system emulator.
// Immutable ELF bytes + zero rules + XOR deltas in the existing XI authority.
#include "mundo_x/quantum_runtime.hpp"
#include "rxe.hpp"
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
  unsigned exit_code=0;
  std::string output, error_output;
};

class MinimalGuest {
 public:
  static constexpr std::uint64_t max_ram=UINT64_C(1)<<48;
  static constexpr std::size_t max_image=16*1024*1024, max_snapshot=48*1024*1024;
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

  // The image is immutable backing, not an eager copy into a RAM array.
  // BSS and all unmodified RAM remain represented by the zero rule.
  void load_elf(Bytes bytes) {
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
      range(segment.address,segment.size);
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
    image_=std::move(immutable); segments_=std::move(candidate); runtime_=std::move(empty);
    registers_=Registers{}; registers_.pc=entry; registers_.sp=ram_&~UINT64_C(15);
  }

  std::uint8_t read8(std::uint64_t address) const {
    range(address,1);
    const auto delta=runtime_.memory().read(std::to_string(address),runtime_.core());
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
    std::string program;
    for (unsigned i=0;i<size;++i) {
      const auto byte=std::uint8_t(value>>(i*8))^backing(address+i);
      program+="mem_store "+std::to_string(address+i)+" "+std::to_string(byte)+"\n";
    }
    // A multi-byte store uses the existing all-or-nothing XI transaction.
    runtime_.execute(program);
  }
  std::string apply_xi_delta(const std::string& source) { return runtime_.execute(source); }
  std::string apply_rxe_delta(const Bytes& image) { return reverse_pc::rxe::execute(runtime_,image); }

  RunResult run(std::uint64_t budget) {
    require(image_!=nullptr, "No ELF guest is loaded");
    require(budget>0 && budget<=1000000, "Guest run budget must be 1..1000000 instructions");
    auto candidate=*this; // Immutable image and unchanged Ether shards are shared.
    RunResult result;
    while (result.executed<budget && !candidate.registers_.halted) {
      candidate.step(result);
      ++result.executed;
    }
    result.halted=candidate.registers_.halted; result.exit_code=candidate.registers_.exit_code;
    *this=std::move(candidate);
    return result;
  }

  Bytes snapshot() const {
    const auto core=runtime_.core_snapshot(), memory=runtime_.memory_persistent_snapshot();
    Bytes result{'R','V','G','1',13,10,26,10};
    put(result,ram_); put(result,override_limit_); put(result,registers_.pc); put(result,registers_.sp);
    put(result,registers_.instructions); put(result,registers_.nzcv); put(result,registers_.halted?1:0); put(result,registers_.exit_code);
    for (auto value:registers_.x) put(result,value);
    put(result,image_bytes()); put(result,core.size()); put(result,memory.size());
    if (image_) result.insert(result.end(),image_->begin(),image_->end());
    result.insert(result.end(),core.begin(),core.end()); result.insert(result.end(),memory.begin(),memory.end());
    require(result.size()+8<=max_snapshot, "Guest snapshot exceeds 48 MiB");
    put(result,digest(result,result.size())); return result;
  }
  static MinimalGuest from_snapshot(const Bytes& bytes) {
    const Bytes magic{'R','V','G','1',13,10,26,10};
    require(bytes.size()>=8+8*(8+31+3)+8 && bytes.size()<=max_snapshot &&
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
    const auto image_size=take(), core_size=take(), memory_size=take();
    require(image_size<=max_image && core_size<=max_snapshot && memory_size<=max_snapshot &&
            image_size+core_size+memory_size==bytes.size()-at-8, "Guest snapshot extents are invalid");
    if (image_size) candidate.load_elf(Bytes(bytes.begin()+at,bytes.begin()+at+std::size_t(image_size)));
    at+=std::size_t(image_size);
    const std::string core(bytes.begin()+at,bytes.begin()+at+std::size_t(core_size)); at+=std::size_t(core_size);
    const std::string memory(bytes.begin()+at,bytes.begin()+at+std::size_t(memory_size));
    candidate.runtime_.restore(core,memory);
    require(cpu.pc%4==0 && cpu.pc<=ram && (cpu.halted || cpu.pc<ram), "Invalid guest PC in snapshot");
    candidate.registers_=cpu; return candidate;
  }
  std::string statistics() const {
    const auto memory=runtime_.memory().stats();
    std::ostringstream out;
    out << "{\"machine\":\"reverse-aarch64-el0-v1\",\"state_model\":\"immutable-image-xor-inverse-ether\""
        << ",\"logical_ram_bytes\":" << ram_ << ",\"immutable_image_bytes\":" << image_bytes()
        << ",\"delta_background_byte\":" << unsigned(memory.background_byte)
        << ",\"delta_overrides\":" << memory.overrides << ",\"max_delta_overrides\":" << override_limit_
        << ",\"quantum_bindings\":" << memory.quantum_bindings << ",\"memory_revision\":" << memory.revision
        << ",\"pc\":" << quote(hex(registers_.pc)) << ",\"sp\":" << quote(hex(registers_.sp))
        << ",\"instructions\":" << registers_.instructions << ",\"halted\":" << (registers_.halted?"true":"false")
        << ",\"exit_code\":" << registers_.exit_code << ",\"android_boot\":\"not_implemented\""
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

  static mundo_x::QuantumRuntime make_runtime(std::size_t overrides) {
    require(overrides>0 && overrides<=1048576, "Guest override limit must be 1..1048576");
    mundo_x::InverseMemory::Limits memory; memory.max_overrides=overrides;
    return mundo_x::QuantumRuntime(mundo_x::InfiniteCore::Background::Zero,mundo_x::InfiniteCore::Limits{},memory);
  }
  void range(std::uint64_t address,std::uint64_t size) const {
    require(address<=ram_ && size<=ram_-address, "Guest address outside logical RAM: "+hex(address));
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
};

inline void MinimalGuest::step(RunResult& result) {
  auto& cpu=registers_;
  require(cpu.pc%4==0,"Unaligned AArch64 instruction address");
  const auto pc=cpu.pc;
  const auto instruction=std::uint32_t(read(pc,4));
  auto next=pc+4;
  const unsigned bits=(instruction>>31)?64:32, rd=instruction&31, rn=(instruction>>5)&31, rm=(instruction>>16)&31;
  auto unsupported=[&](){throw std::runtime_error("Unsupported AArch64 instruction "+hex(instruction)+" at "+hex(pc));};
  if (instruction==0xd503201f) { /* NOP */ }
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
  else if ((instruction&0x3b000000)==0x39000000 && !(instruction&0x04000000)) { // LDR/STR unsigned offset
    const unsigned size=1u<<(instruction>>30), opcode=(instruction>>22)&3;
    if (opcode>1) unsupported();
    const auto address=reg(rn,64,true)+std::uint64_t((instruction>>10)&4095)*size;
    if (opcode) set(rd,read(address,size),size==8?64:32);
    else write(address,reg(rd),size);
  }
  else if ((instruction&0x3b000000)==0x18000000 && !(instruction&0x04000000)) { // LDR literal/LDRSW
    const unsigned opcode=instruction>>30;
    if (opcode==3) unsupported();
    auto value=read(pc+std::uint64_t(signed_field((instruction>>5)&0x7ffff,19))*4,opcode==1?8:4);
    if (opcode==2 && (value&0x80000000)) value|=UINT64_C(0xffffffff00000000);
    set(rd,value,opcode==0?32:64);
  }
  else if ((instruction&0x3b200000)==0x38000000 && !(instruction&0x04000000)) { // LDUR/STUR and pre/post-index
    const unsigned size=1u<<(instruction>>30), opcode=(instruction>>22)&3, mode=(instruction>>10)&3;
    if (opcode>1 || mode==2 || (mode && rn!=31 && rn==rd)) unsupported();
    const auto base=reg(rn,64,true), updated=base+std::uint64_t(signed_field((instruction>>12)&511,9));
    const auto address=mode==1?base:updated;
    if (opcode) set(rd,read(address,size),size==8?64:32);
    else write(address,reg(rd),size);
    if (mode) set(rn,updated,64,true);
  }
  else if ((instruction&0x3a000000)==0x28000000 && !(instruction&0x04000000)) { // LDP/STP integers
    const unsigned opcode=instruction>>30, second=(instruction>>10)&31, mode=(instruction>>23)&3;
    const bool load=instruction&0x00400000, writeback=mode==1||mode==3;
    if ((opcode!=0 && opcode!=2) || (writeback && rn!=31 && (rn==rd || rn==second))) unsupported();
    const unsigned size=opcode==2?8:4;
    const auto base=reg(rn,64,true), updated=base+std::uint64_t(signed_field((instruction>>15)&127,7))*size;
    const auto address=mode==1?base:updated; range(address,size*2);
    if (load) {
      const auto first_value=read(address,size), second_value=read(address+size,size);
      set(rd,first_value,size*8); set(second,second_value,size*8);
    } else { write(address,reg(rd),size); write(address+size,reg(second),size); }
    if (writeback) set(rn,updated,64,true);
  }
  else if ((instruction&0x1f800000)==0x13000000) { // common bitfield aliases: shifts and extensions
    const unsigned opcode=(instruction>>29)&3, rotation=(instruction>>16)&63, last=(instruction>>10)&63;
    if (((instruction>>22)&1)!=(bits==64) || rotation>=bits || last>=bits || opcode==1 || opcode==3) unsupported();
    const auto value=reg(rn,bits); std::uint64_t output=0;
    if (last==bits-1) output=shift(value,rotation,opcode==0?2:1,bits);
    else if (opcode==2 && rotation==last+1) output=(value<<(bits-rotation))&mask(bits);
    else if (rotation==0) {
      const auto extent=last+1;
      const auto low=extent==64?UINT64_MAX:((UINT64_C(1)<<extent)-1);
      output=value&low;
      if (opcode==0 && (output&(UINT64_C(1)<<last))) output|=mask(bits)^low;
    } else { unsupported(); }
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
  else if ((instruction&0x7fe00000)==0x1b000000) { // MADD/MSUB, including MUL alias
    const auto product=reg(rn,bits)*reg(rm,bits), accumulator=reg((instruction>>10)&31,bits);
    set(rd,(instruction&0x8000)?accumulator-product:accumulator+product,bits);
  }
  else { unsupported(); }
  require(next%4==0,"Guest branch target is unaligned"); range(next,cpu.halted?0:4);
  require(cpu.instructions!=UINT64_MAX,"Guest instruction counter overflow");
  cpu.pc=next; ++cpu.instructions;
}
} // namespace reverse_pc::guest
