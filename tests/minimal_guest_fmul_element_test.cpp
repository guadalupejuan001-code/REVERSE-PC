// Observed FMUL stop and the allocated FMUL/FMULX S/D indexed-element family.
// Arm architectural state is prepared by guest instructions. On AArch64, the
// independent oracle executes the actual encoding on the host CPU.
#include "minimal_guest.hpp"
#include <cmath>
#include <cstring>
#include <iostream>
#include <map>
#ifdef __aarch64__
#include <sys/mman.h>
#include <unistd.h>
#endif
using namespace reverse_pc::guest;
namespace {
unsigned checks=0,cases=0,native_cases=0;
void check(bool ok,const char* why){++checks;if(!ok)throw std::runtime_error(why);}
Bytes elf(const std::vector<std::uint32_t>& words,bool system=false){
 Bytes code;for(auto x:words)put(code,x,4);const auto entry=system?0x40080000:0x1000;
 Bytes b{0x7f,'E','L','F',2,1,1,0,0,0,0,0,0,0,0,0};
 put(b,2,2);put(b,183,2);put(b,1,4);put(b,entry);put(b,64);put(b,0);
 put(b,0,4);put(b,64,2);put(b,56,2);put(b,1,2);put(b,0,2);put(b,0,2);put(b,0,2);
 put(b,1,4);put(b,7,4);put(b,0x100);put(b,entry);put(b,entry);put(b,code.size());put(b,code.size());put(b,0x100);
 b.resize(0x100);b.insert(b.end(),code.begin(),code.end());return b;
}
void constant(std::vector<std::uint32_t>& code,unsigned rd,std::uint64_t value){
 code.push_back(0xd2800000u|(std::uint32_t(value&65535)<<5)|rd);
 for(unsigned k=1;k<4;k++)code.push_back(0xf2800000u|(k<<21)|(std::uint32_t((value>>(16*k))&65535)<<5)|rd);
}
std::uint64_t raw(double x,unsigned bits){
 if(bits==32){const float f=float(x);std::uint32_t v;std::memcpy(&v,&f,4);return v;}
 std::uint64_t v;std::memcpy(&v,&x,8);return v;
}
using Vectors=std::array<Vector128,32>;
MinimalGuest prepared(const Vectors& values,unsigned fpcr=0,unsigned fpsr=10){
 std::vector<std::uint32_t> code{0xd2840002u};
 for(unsigned r=0;r<32;r++)code.push_back(0x3dc00040u|(r<<10)|r);
 constant(code,3,fpcr);code.push_back(0xd51b4403u);
 constant(code,3,fpsr);code.push_back(0xd51b4423u);
 code.push_back(0xf100045fu);code.push_back(0xd503201fu);
 MinimalGuest g(65536);g.load_elf(elf(code));
 for(unsigned r=0;r<32;r++){g.write(0x2000+r*16,values[r].low,8);g.write(0x2008+r*16,values[r].high,8);}
 g.run(code.size()-1);return g;
}
std::uint32_t encoding(unsigned bits,bool scalar,bool wide,bool extended,unsigned index,unsigned rn,unsigned rm,unsigned rd){
 return (scalar?0x5f809000u:0x0f809000u|(wide?0x40000000u:0))|
  (bits==64?0x00400000u:0)|(extended?0x20000000u:0)|
  ((bits==64?index:index>>1)<<11)|(bits==32?(index&1u)<<21:0)|(rm<<16)|(rn<<5)|rd;
}
void execute(MinimalGuest g,std::uint32_t op,Vector128 expected,unsigned flags,bool restore){
 g.write(g.registers().pc,op,4);const auto cpu=g.registers();const auto fp=g.floating();
 const auto memory=g.runtime().memory_persistent_snapshot(),core=g.runtime().core_snapshot();
 if(restore){auto resumed=MinimalGuest::from_snapshot(g.snapshot());g.run(1);resumed.run(1);check(g.snapshot()==resumed.snapshot(),"Indexed multiply differs after original checkpoint restore");}
 else g.run(1);
 const auto rd=op&31;
 check(g.floating().v[rd].low==expected.low&&g.floating().v[rd].high==expected.high,"Indexed multiply result, selected lane or upper clearing differs");
 check(g.floating().fpsr==(fp.fpsr|flags)&&g.floating().fpcr==fp.fpcr,"Indexed multiply FPCR/FPSR differs");
 check(g.registers().pc==cpu.pc+4&&g.registers().instructions==cpu.instructions+1,"Indexed multiply did not advance exactly one instruction");
 check(g.registers().x==cpu.x&&g.registers().sp==cpu.sp&&g.registers().nzcv==cpu.nzcv,"Indexed multiply changed integer CPU state");
 check(g.runtime().memory_persistent_snapshot()==memory&&g.runtime().core_snapshot()==core,"Indexed multiply changed XI/Ether memory or core");
 for(unsigned r=0;r<32;r++)if(r!=rd)check(g.floating().v[r].low==fp.v[r].low&&g.floating().v[r].high==fp.v[r].high,"Indexed multiply changed another vector register");
 ++cases;
}
void allocated_forms(){
 Vectors actual;actual[5]={0x3f800000,0};check(encoding(32,false,false,false,0,5,1,1)==0x0f8190a1u,"Observed FMUL encoding changed");execute(prepared(actual,0,16),0x0f8190a1u,{0,0},0,true);
 for(unsigned bits:{32u,64u}){
  Vectors values;for(unsigned r=0;r<32;r++)for(unsigned n=0;n<128/bits;n++)values[r].lane(n,bits,raw(1+r+7*n,bits));
  const auto base=prepared(values);
  for(bool scalar:{false,true})for(bool wide:{false,true}){
   if((scalar&&!wide)||(!scalar&&!wide&&bits==64))continue;
   for(bool extended:{false,true})for(unsigned index=0;index<128/bits;index++)
    for(unsigned rn=0;rn<32;rn++)for(unsigned rd:{0u,1u,2u,15u,16u,30u,31u}){
     const unsigned rm=(rd+rn+index)&31;Vector128 expected;
     for(unsigned n=0;n<(scalar?1u:(wide?128u:64u)/bits);n++){
      const auto product=(1+rn+7*n)*(1+rm+7*index);
      expected.lane(n,bits,raw(double(product),bits));
     }
     execute(base,encoding(bits,scalar,wide,extended,index,rn,rm,rd),expected,0,rd==rn||rd==rm);
    }
  }
 }
}
struct Example{std::uint64_t a,b,result;unsigned flags;};
std::vector<Example> examples(unsigned bits,unsigned fpcr,bool extended){
 const auto sign=UINT64_C(1)<<(bits-1),inf=bits==32?UINT64_C(0x7f800000):UINT64_C(0x7ff0000000000000),quiet=bits==32?UINT64_C(0x400000):UINT64_C(0x8000000000000),one=raw(1,bits),two=raw(2,bits),half=raw(0.5,bits),minimum=bits==32?UINT64_C(0x00800000):UINT64_C(0x0010000000000000),maximum=inf-1,nan=inf|quiet,snan=inf|sign|0x12345;const unsigned mode=(fpcr>>22)&3;const bool fz=fpcr&(1u<<24);
 std::vector<Example> result{{0,inf,extended?two:nan,extended?0u:1u},{sign,inf,extended?sign|two:nan,extended?0u:1u},{1,inf,fz?(extended?two:nan):inf,fz?(extended?128u:129u):0u},{minimum,half,fz?0:minimum>>1,fz?8u:0u},{one,one,one,0},{nan|sign|0x54321,one,nan|sign|0x54321,0},{snan,one,snan|quiet,1},{nan|0x54321,snan,snan|quiet,1},{one+1,one+1,one+2+(mode==1?1u:0u),16},{(one+1)|sign,one+1,(one+2+(mode==2?1u:0u))|sign,16},{maximum,two,mode<2?inf:maximum,20},{minimum,minimum,fz?UINT64_C(0):(mode==1?UINT64_C(1):UINT64_C(0)),fz?8u:24u}};
 if(fpcr&(1u<<25))for(auto& e:result)if((e.result&inf)==inf&&(e.result&(quiet*2-1)))e.result=nan;return result;
}
void numeric_examples(){
 for(unsigned bits:{32u,64u})for(bool scalar:{false,true})for(bool wide:{false,true}){
  if((scalar&&!wide)||(!scalar&&!wide&&bits==64))continue;
  for(bool extended:{false,true})for(unsigned mode=0;mode<16;++mode){const unsigned fpcr=((mode&3)<<22)|((mode&4)?1u<<24:0)|((mode&8)?1u<<25:0);const auto samples=examples(bits,fpcr,extended);
   for(unsigned k=0;k<samples.size();++k){const auto& e=samples[k];const unsigned index=(k+mode)%(128/bits);Vectors v;const auto poison=bits==32?UINT64_C(0x7f800001):UINT64_C(0x7ff0000000000001);for(auto& r:v)for(unsigned lane=0;lane<128/bits;++lane)r.lane(lane,bits,poison);for(unsigned lane=0;lane<(scalar?1u:(wide?128u:64u)/bits);++lane)v[3].lane(lane,bits,e.a);v[0].lane(index,bits,e.b);Vector128 out;for(unsigned lane=0;lane<(scalar?1u:(wide?128u:64u)/bits);++lane)out.lane(lane,bits,e.result);execute(prepared(v,fpcr),encoding(bits,scalar,wide,extended,index,3,0,2),out,e.flags,true);}
  }
 }
}
void traps_and_rollback(){
 for(auto op:{0x0f8190a1u,0x2f8190a1u,0x4f8190a1u,0x6f8190a1u,0x5f8190a1u,0x7f8190a1u,0x4fc190a1u,0x5fc190a1u}){MinimalGuest g(128*1024*1024);g.load_elf(elf({op},true),true);g.run(1);check(g.machine().exceptions==1&&(g.machine().esr>>26)==7&&!g.floating().nonzero(),"Indexed multiply bypassed FP access trap");}
 for(auto op:{0x0fc190a1u,0x2fc190a1u,0x4fe190a1u,0x5fe190a1u,0x7fe190a1u,0x4f0190a1u}){MinimalGuest g(65536);g.load_elf(elf({op}));const auto before=g.snapshot();bool rejected=false;try{g.run(1);}catch(const std::exception&){rejected=true;}check(rejected&&g.snapshot()==before,"Reserved indexed multiply modified state");}
}
#ifdef __aarch64__
struct NativeCode {
 void* page=nullptr;std::size_t bytes=0;
 explicit NativeCode(std::uint32_t op){
  bytes=std::size_t(::sysconf(_SC_PAGESIZE));page=::mmap(nullptr,bytes,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
  check(page!=MAP_FAILED,"Cannot allocate native instruction oracle");
  auto* code=static_cast<std::uint32_t*>(page);const unsigned rn=(op>>5)&31,rm=(op>>16)&31,rd=op&31;
  // Only caller-saved V0/V2/V3/V16/V31 are used by the hardware cases.
  unsigned i=0;for(const unsigned r:{rn,rm,rd})code[i++]=0x3dc00000u|(r<<10)|r;
  code[i++]=op;code[i++]=0x3d800020u|rd;code[i++]=0xd65f03c0u;
  __builtin___clear_cache(static_cast<char*>(page),static_cast<char*>(page)+i*4);
  check(::mprotect(page,bytes,PROT_READ|PROT_EXEC)==0,"Cannot publish native instruction oracle");
 }
 ~NativeCode(){if(page&&page!=MAP_FAILED)::munmap(page,bytes);}
 NativeCode(const NativeCode&)=delete;
 Vector128 run(const Vectors& values,unsigned fpcr,unsigned& flags){
  std::uint64_t oldcr,oldsr,sr;
  asm volatile("mrs %0, fpcr\n\tmrs %1, fpsr":"=r"(oldcr),"=r"(oldsr));
  const std::uint64_t cr=fpcr,initial=10;
  asm volatile("msr fpcr, %0\n\tmsr fpsr, %1"::"r"(cr),"r"(initial):"memory");
  Vector128 out;reinterpret_cast<void(*)(const Vector128*,Vector128*)>(page)(values.data(),&out);
  asm volatile("mrs %0, fpsr":"=r"(sr));
  asm volatile("msr fpcr, %0\n\tmsr fpsr, %1"::"r"(oldcr),"r"(oldsr):"memory");
  flags=unsigned(sr);return out;
 }
};
void hardware_oracle(){
 Vectors actual;actual[5]={0x3f800000,0};NativeCode observed(0x0f8190a1u);unsigned actual_flags;const auto actual_result=observed.run(actual,0,actual_flags);execute(prepared(actual),0x0f8190a1u,actual_result,actual_flags,true);++native_cases;
 std::uint64_t seed=0x0f8190a1;auto random=[&](){seed^=seed<<13;seed^=seed>>7;seed^=seed<<17;return seed;};
 for(unsigned bits:{32u,64u})for(bool scalar:{false,true})for(bool wide:{false,true}){
  if((scalar&&!wide)||(!scalar&&!wide&&bits==64))continue;
  for(bool extended:{false,true})for(unsigned index=0;index<128/bits;index++)for(unsigned rm:{0u,1u,16u,31u}){
   const auto op=encoding(bits,scalar,wide,extended,index,3,rm,2);NativeCode native(op);
   for(unsigned mode=0;mode<16;mode++)for(unsigned sample=0;sample<64;sample++){
    const unsigned fpcr=((mode&3)<<22)|((mode&4)?1u<<24:0)|((mode&8)?1u<<25:0);Vectors v;
    const std::uint64_t special32[]{0,0x80000000,1,0x00800000,0x7f800000,0xff800000,0x7fc12345,0x7f812345};
    const std::uint64_t special64[]{0,UINT64_C(0x8000000000000000),1,UINT64_C(0x0010000000000000),UINT64_C(0x7ff0000000000000),UINT64_C(0xfff0000000000000),UINT64_C(0x7ff8000000012345),UINT64_C(0x7ff0000000012345)};
    for(unsigned r:{2u,3u,rm})for(unsigned n=0;n<128/bits;n++)v[r].lane(n,bits,sample<8?(bits==32?special32[(sample+r+n)%8]:special64[(sample+r+n)%8]):random());
    unsigned flags=0;const auto expected=native.run(v,fpcr,flags);execute(prepared(v,fpcr),op,expected,flags,false);++native_cases;
   }
  }
 }
}
#else
void hardware_oracle(){}
#endif
}
int main(){try{allocated_forms();numeric_examples();traps_and_rollback();hardware_oracle();std::cout<<"{\"cases\":"<<cases<<",\"checks\":"<<checks<<",\"native_hardware_cases\":"<<native_cases<<",\"actual_opcode\":\"0x0f8190a1\",\"android_boot\":false}\n";}catch(const std::exception&e){std::cerr<<e.what()<<'\n';return 1;}}
