// C33 genuine ARM64 0x6f7f1440 USRA stop: full-lane independent bit oracle.
// Tests execute the original XI/Ether guest, NOT a mock Android boot.
#include "minimal_guest.hpp"
#include <array>
#include <iostream>
#include <vector>
using namespace reverse_pc::guest;
namespace {
unsigned long long checks=0,cases=0,rejections=0;
void check(bool yes,const char* why){++checks;if(!yes)throw std::runtime_error(why);}
Bytes elf(const std::vector<std::uint32_t>& words,bool system=false){
 Bytes code;for(auto x:words)put(code,x,4);
 const auto entry=system?0x40080000:0x1000;
 Bytes b{0x7f,'E','L','F',2,1,1,0,0,0,0,0,0,0,0,0};
 put(b,2,2);put(b,183,2);put(b,1,4);put(b,entry);put(b,64);put(b,0);
 put(b,0,4);put(b,64,2);put(b,56,2);put(b,1,2);put(b,0,2);put(b,0,2);put(b,0,2);
 put(b,1,4);put(b,7,4);put(b,0x100);put(b,entry);put(b,entry);
 put(b,code.size());put(b,code.size());put(b,0x100);
 b.resize(0x100);b.insert(b.end(),code.begin(),code.end());return b;
}
std::uint32_t opcode(unsigned bits,bool q,bool uns,unsigned shift,unsigned rn,unsigned rd){
 return 0x0f001400u|(q?0x40000000u:0u)|(uns?0x20000000u:0u)|
        ((2*bits-shift)<<16)|(rn<<5)|rd;
}
std::uint64_t mask(unsigned bits){return bits==64?UINT64_MAX:(UINT64_C(1)<<bits)-1;}
std::uint64_t oracle(std::uint64_t acc,std::uint64_t x,unsigned bits,unsigned amount,bool uns){
 std::uint64_t shifted=0;
 const bool sign=!uns&&bool((x>>(bits-1))&1);
 for(unsigned n=0;n<bits;n++){
  const unsigned index=n+amount;
  const bool bit=index<bits?bool((x>>index)&1):sign;
  if(bit)shifted|=UINT64_C(1)<<n;
 }
 return (acc+shifted)&mask(bits); // CPU wraps independently per lane.
}
MinimalGuest prepared(std::uint64_t low,std::uint64_t high){
 std::vector<std::uint32_t> code{0xd2840002u};
 for(unsigned n=0;n<32;n++)code.push_back(0x3dc00040u|(n<<10)|n); // LDR Qn [x2,#n*16]
 code.insert(code.end(),{0xd2a01803u,0xd51b4403u,0xd2800203u,0xd51b4423u,0xf100045fu,0xd503201fu});
 MinimalGuest g(65536);g.load_elf(elf(code));
 for(unsigned r=0;r<32;r++){
  g.write(0x2000+16*r,low^(std::uint64_t(r)*UINT64_C(0x0102040810204081)),8);
  g.write(0x2008+16*r,high^(std::uint64_t(r)*UINT64_C(0x8040201008040201)),8);
 }
 g.run(38);return g;
}
void execute(MinimalGuest g,unsigned bits,bool q,bool uns,unsigned shift,unsigned rn,unsigned rd,bool restore){
 const auto op=opcode(bits,q,uns,shift,rn,rd);
 g.write(g.registers().pc,op,4);const auto f=g.floating(),cpu=g.registers();
 const auto mem=g.runtime().memory_snapshot(),core=g.runtime().core_snapshot();
 if(restore){
  auto copy=MinimalGuest::from_snapshot(g.snapshot());g.run(1);copy.run(1);
  check(g.snapshot()==copy.snapshot(),"Snapshot restore changed SSRA/USRA result");
 }else g.run(1);
 const auto after=g.floating(),lanes=(q?128u:64u)/bits;
 for(unsigned n=0;n<lanes;n++){
  const auto want=oracle(f.v[rd].lane(n,bits),f.v[rn].lane(n,bits),bits,shift,uns);
  check(after.v[rd].lane(n,bits)==want,"SSRA/USRA lane differs from independent bit-level oracle");
 }
 if(!q)check(after.v[rd].high==0,"64-bit vector must zero the top half");
 check(g.registers().pc==cpu.pc+4&&g.registers().instructions==cpu.instructions+1,"Exactly one instruction must execute");
 check(g.registers().x==cpu.x&&g.registers().nzcv==cpu.nzcv,"USRA modified integer registers or NZCV");
 check(after.fpcr==f.fpcr&&after.fpsr==f.fpsr,"USRA modified FP status/control");
 check(g.runtime().memory_snapshot()==mem&&g.runtime().core_snapshot()==core,"USRA modified XI/Ether memory");
 for(unsigned n=0;n<32;n++)if(n!=rd)
  check(after.v[n].low==f.v[n].low&&after.v[n].high==f.v[n].high,"USRA corrupted unrelated vector");
 ++cases;
}
void suite(){
 check(opcode(64,true,true,1,2,0)==0x6f7f1440u,"Exact observed C33 opcode mismatch");
 const std::array<std::uint64_t,9> edge{0,1,UINT64_MAX,UINT64_C(0x8000000000000000),
  UINT64_C(0x7fffffffffffffff),UINT64_C(0x5555555555555555),
  UINT64_C(0xaaaaaaaaaaaaaaaa),UINT64_C(0xfedcba9876543210),UINT64_C(0x0123456789abcdef)};
 const std::array<std::array<unsigned,2>,7> regs{{{0,0},{2,0},{31,31},{0,31},{31,0},{3,4},{4,3}}};
 for(unsigned bits:{8u,16u,32u,64u})for(bool q:{false,true})for(bool uns:{false,true}){
  if(bits==64&&!q)continue;
  const std::array<unsigned,3> shifts{1u,bits/2,bits};
  for(unsigned amount:shifts)for(unsigned pattern=0;pattern<edge.size();pattern++){
   const auto g=prepared(edge[pattern],edge[(pattern+3)%edge.size()]);
   for(const auto pair:regs)
    execute(g,bits,q,uns,amount,pair[0],pair[1],
      pair[0]==pair[1]||(pattern==0&&pair[0]==2&&pair[1]==0));
  }
 }
 // Genuine C33 failing encoding in a nonzero two-lane state; Rd!=Rn.
 execute(prepared(UINT64_C(0xfffffffffffffffe),UINT64_C(0x8000000000000001)),
   64,true,true,1,2,0,true);
 // Q=0 + 64-bit lanes is an unallocated arrangement. Must reject without any state mutation.
 for(bool uns:{false,true})for(unsigned shift:{1u,32u,64u})for(unsigned rd:{0u,31u}){
  auto bad=prepared(UINT64_MAX,0);
  bad.write(bad.registers().pc,opcode(64,false,uns,shift,2,rd),4);
  const auto before=bad.snapshot();bool rejected=false;
  try{bad.run(1);}catch(const std::exception&){rejected=true;}
  check(rejected&&bad.snapshot()==before,"Unallocated 1D shift accumulation accepted or mutated state");
  ++rejections;
 }
 // FP/SIMD access checks must precede touching vector data in privileged mode.
 for(bool uns:{false,true}){
  MinimalGuest trapped(128*1024*1024);
  trapped.load_elf(elf({opcode(64,true,uns,1,2,0)},true),true);trapped.run(1);
  check(trapped.machine().exceptions==1&&(trapped.machine().esr>>26)==7&&!trapped.floating().nonzero(),"USRA bypassed FP trap");
 }
}
}
int main(){try{suite();
 std::cout<<"{\"checks\":"<<checks<<",\"cases\":"<<cases<<",\"rejected_unallocated\":"<<rejections
          <<",\"observed_opcode\":\"0x6f7f1440\",\"android_boot\":false}\n";
 }catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 1;}}
