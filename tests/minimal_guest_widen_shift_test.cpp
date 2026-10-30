// Regression for C08's real rejected 0x2f10a442 (UXTL V2.4S,V2.4H).
// ARM USHLL/SSHLL: Q selects the source half; destination is always 128 bits.
#include "minimal_guest.hpp"
#include <bitset>
#include <iostream>
using namespace reverse_pc::guest;
static unsigned checks=0,cases=0;
static void check(bool ok,const char* why){++checks;if(!ok)throw std::runtime_error(why);}
static Bytes program(std::uint32_t opcode,unsigned source=1){
  Bytes code;for(auto w:{0xd2840002u,0x4c407040u|source,opcode})put(code,w,4);
  Bytes b{0x7f,'E','L','F',2,1,1,0,0,0,0,0,0,0,0,0};
  put(b,2,2);put(b,183,2);put(b,1,4);put(b,0x1000);put(b,64);put(b,0);
  put(b,0,4);put(b,64,2);put(b,56,2);put(b,1,2);put(b,0,2);put(b,0,2);put(b,0,2);
  put(b,1,4);put(b,7,4);put(b,0x100);put(b,0x1000);put(b,0x1000);put(b,code.size());put(b,code.size());put(b,0x100);
  b.resize(0x100);b.insert(b.end(),code.begin(),code.end());return b;
}
static std::uint64_t oracle(std::uint64_t x,unsigned bits,unsigned shift,bool unsigned_value){
  std::bitset<64> src(x),out;
  for(unsigned bit=0;bit<2*bits;bit++){
    if(bit<shift)continue;
    const unsigned from=bit-shift;
    out[bit]=from<bits?src[from]:!unsigned_value&&src[bits-1];
  }
  return out.to_ullong();
}
static void trial(unsigned bits,unsigned shift,bool upper,bool unsigned_value,bool alias,unsigned source=1){
  const auto opcode=0x0f00a400u|(unsigned_value?0x20000000u:0)|(upper?0x40000000u:0)|((bits+shift)<<16)|(source<<5)|(alias?source:3);
  const unsigned dest=alias?source:3,lanes=64/bits;
  MinimalGuest g(65536);g.load_elf(program(opcode,source));
  const auto sign=UINT64_C(1)<<(bits-1),mask=(UINT64_C(1)<<bits)-1;
  const std::uint64_t values[]{mask,sign,sign-1,0,1,sign+1,37,mask-1};
  for(unsigned n=0;n<2*lanes;n++)g.write(0x2000+std::uint64_t(n)*(bits/8),values[(n+(upper?3:0))%8],bits/8);
  auto chunked=MinimalGuest::from_snapshot(g.snapshot());
  g.run(2);auto restored=MinimalGuest::from_snapshot(g.snapshot());
  const auto from=g.floating();const auto flags=g.registers().nzcv;
  g.run(1);restored.run(1);chunked.run(3);++cases;
  check(g.snapshot()==restored.snapshot()&&g.snapshot()==chunked.snapshot(),"Widen shift changed across transaction or full-state restore");
  for(unsigned n=0;n<lanes;n++)check(g.floating().v[dest].lane(n,2*bits)==oracle(from.v[source].lane(n+(upper?lanes:0),bits),bits,shift,unsigned_value),"Widened lane differs from independent bit-position oracle");
  for(unsigned n=0;n<32;n++)if(n!=dest)check(g.floating().v[n].low==from.v[n].low&&g.floating().v[n].high==from.v[n].high,"Unrelated vector changed");
  check(g.floating().fpcr==from.fpcr&&g.floating().fpsr==from.fpsr&&g.registers().nzcv==flags,"Non-saturating widening modified status flags");
}
int main(){try{
  trial(16,0,false,true,true,2); // Exact rejected opcode first, aliases source/dest.
  for(unsigned bits:{8u,16u,32u})for(unsigned shift=0;shift<bits;shift++)for(bool upper:{false,true})for(bool u:{false,true})for(bool alias:{false,true})trial(bits,shift,upper,u,alias);
  trial(8,7,true,false,true,31); // V31 is not the zero register.
  for(unsigned encoded=64;encoded<128;encoded++)for(bool upper:{false,true})for(bool u:{false,true}){
    const auto opcode=0x0f00a423u|(upper?0x40000000u:0)|(u?0x20000000u:0)|(encoded<<16);
    MinimalGuest g(65536);g.load_elf(program(opcode));g.run(2);const auto before=g.snapshot();bool rejected=false;
    try{g.run(1);}catch(const std::exception&){rejected=true;}
    check(rejected,"Reserved immh[3] encoding was executed");check(g.snapshot()==before,"Reserved widening instruction committed state");
  }
  std::cout<<"{\"checks\":"<<checks<<",\"instruction_cases\":"<<cases<<",\"exact_C08_opcode\":\"0x2f10a442\",\"signed_and_unsigned\":true,\"all_valid_shifts\":true,\"upper_and_lower_source\":true,\"alias_and_restore\":true,\"reserved_encodings_rejected\":true}\n";
}catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 1;}}
