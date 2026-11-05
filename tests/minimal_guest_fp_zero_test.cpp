// Independent raw IEEE classification and physical AArch64 comparisons against zero.
#include "minimal_guest.hpp"
#include <cfenv>
#include <cstring>
#include <iostream>
#ifdef __aarch64__
#include <sys/mman.h>
#include <unistd.h>
#endif
using namespace reverse_pc::guest;
namespace {
unsigned cases=0,checks=0,native_cases=0;
void check(bool ok,const char* message){++checks;if(!ok)throw std::runtime_error(message);}
Bytes elf(const std::vector<std::uint32_t>& words,bool system=false){
 Bytes code;for(auto x:words)put(code,x,4);const auto entry=system?0x40080000:0x1000;
 Bytes b{0x7f,'E','L','F',2,1,1,0,0,0,0,0,0,0,0,0};
 put(b,2,2);put(b,183,2);put(b,1,4);put(b,entry);put(b,64);put(b,0);put(b,0,4);
 put(b,64,2);put(b,56,2);put(b,1,2);put(b,0,2);put(b,0,2);put(b,0,2);
 put(b,1,4);put(b,7,4);put(b,0x100);put(b,entry);put(b,entry);put(b,code.size());put(b,code.size());put(b,0x100);
 b.resize(0x100);b.insert(b.end(),code.begin(),code.end());return b;
}
void constant(std::vector<std::uint32_t>& c,unsigned r,std::uint64_t x){
 c.push_back(0xd2800000u|(std::uint32_t(x&65535)<<5)|r);
 for(unsigned n=1;n<4;++n)c.push_back(0xf2800000u|(n<<21)|(std::uint32_t((x>>(16*n))&65535)<<5)|r);
}
using Vectors=std::array<Vector128,32>;
MinimalGuest prepared(const Vectors& v,unsigned fpcr=0,unsigned fpsr=10){
 std::vector<std::uint32_t> c{0xd2840002u};for(unsigned r=0;r<32;++r)c.push_back(0x3dc00040u|(r<<10)|r);
 constant(c,3,fpcr);c.push_back(0xd51b4403u);constant(c,3,fpsr);c.push_back(0xd51b4423u);c.push_back(0xf100045fu);c.push_back(0xd503201fu);
 MinimalGuest g(65536);g.load_elf(elf(c));for(unsigned r=0;r<32;++r){g.write(0x2000+r*16,v[r].low,8);g.write(0x2008+r*16,v[r].high,8);}g.run(c.size()-1);return g;
}
struct Form{std::uint32_t base;unsigned bits,lanes;};
const Form forms[]{{0x5ea0d800u,32,1},{0x5ee0d800u,64,1},{0x0ea0d800u,32,2},{0x4ea0d800u,32,4},{0x4ee0d800u,64,2}};
const std::uint32_t operations[]{0,0x20001000u,0x1000u,0x20000000u,0x3000u};
std::uint32_t encoding(Form f,unsigned operation,unsigned rn,unsigned rd){return (f.base^operations[operation])|(rn<<5)|rd;}
std::pair<std::uint64_t,unsigned> reference(unsigned bits,std::uint64_t x,unsigned operation,unsigned fpcr){
 const auto sign=UINT64_C(1)<<(bits-1),exp=bits==32?UINT64_C(0x7f800000):UINT64_C(0x7ff0000000000000),frac=bits==32?UINT64_C(0x7fffff):UINT64_C(0xfffffffffffff),quiet=bits==32?UINT64_C(0x400000):UINT64_C(0x8000000000000);unsigned flags=0;
 if((fpcr&(1u<<24))&&!(x&exp)&&(x&frac)){x&=sign;flags|=128;}
 const bool nan=(x&exp)==exp&&(x&frac);if(nan)return {0,flags|((operation!=0||!(x&quiet))?1u:0u)};
 const bool zero=!(x&~sign),negative=bool(x&sign)&&!zero,positive=!negative&&!zero;
 const bool result=operation==0?zero:operation==1?positive||zero:operation==2?positive:operation==3?negative||zero:negative;
 return {result?(bits==32?UINT64_C(0xffffffff):UINT64_MAX):0,flags};
}
Vector128 reference(Form f,unsigned op,const Vectors& v,unsigned rn,unsigned fpcr,unsigned& flags){
 Vector128 out;flags=0;for(unsigned lane=0;lane<f.lanes;++lane){auto x=reference(f.bits,v[rn].lane(lane,f.bits),op,fpcr);out.lane(lane,f.bits,x.first);flags|=x.second;}return out;
}
void execute(MinimalGuest g,std::uint32_t op,Vector128 out,unsigned flags,bool restore){
 g.write(g.registers().pc,op,4);const auto cpu=g.registers();const auto fp=g.floating();const auto memory=g.runtime().memory_persistent_snapshot(),core=g.runtime().core_snapshot();
 if(restore){auto other=MinimalGuest::from_snapshot(g.snapshot());g.run(1);other.run(1);check(g.snapshot()==other.snapshot(),"FP zero comparison changed across original checkpoint restore");}else g.run(1);
 const unsigned rd=op&31;check(g.floating().v[rd].low==out.low&&g.floating().v[rd].high==out.high,"FP zero comparison value, lane, alias, or upper clearing differs");
 check(g.floating().fpcr==fp.fpcr&&g.floating().fpsr==(fp.fpsr|flags),"FP zero comparison FPCR or cumulative FPSR differs");
 check(g.registers().pc==cpu.pc+4&&g.registers().instructions==cpu.instructions+1,"FP zero comparison instruction progress differs");
 check(g.registers().x==cpu.x&&g.registers().sp==cpu.sp&&g.registers().nzcv==cpu.nzcv,"FP zero comparison changed integer registers");
 check(g.runtime().memory_persistent_snapshot()==memory&&g.runtime().core_snapshot()==core,"FP zero comparison changed XI/Ether memory or core");
 for(unsigned r=0;r<32;++r)if(r!=rd)check(g.floating().v[r].low==fp.v[r].low&&g.floating().v[r].high==fp.v[r].high,"FP zero comparison changed another SIMD register");++cases;
}
const std::uint64_t edge32[]{0,0x80000000,1,0x80000001,0x007fffff,0x00800000,0x3f800000,0xbf800000,0x33800000,0xb3800000,0x3f800001,0x7f7fffff,0xff7fffff,0x7f800000,0xff800000,0x7fc12345,0xffc23456,0x7f812345,0xff823456};
const std::uint64_t edge64[]{0,UINT64_C(0x8000000000000000),1,UINT64_C(0x8000000000000001),UINT64_C(0x000fffffffffffff),UINT64_C(0x0010000000000000),UINT64_C(0x3ff0000000000000),UINT64_C(0xbff0000000000000),UINT64_C(0x3ca0000000000000),UINT64_C(0xbca0000000000000),UINT64_C(0x3ff0000000000001),UINT64_C(0x7fefffffffffffff),UINT64_C(0xffefffffffffffff),UINT64_C(0x7ff0000000000000),UINT64_C(0xfff0000000000000),UINT64_C(0x7ff8000000012345),UINT64_C(0xfff8000000023456),UINT64_C(0x7ff0000000012345),UINT64_C(0xfff0000000023456)};
void allocated(){
 Vectors actual;actual[4]={0x34324241,0};execute(prepared(actual,0,16),0x2ea0d824u,{UINT64_MAX,0},0,true);
 for(auto f:forms)for(unsigned op=0;op<5;++op){Vectors v;for(unsigned r=0;r<32;++r)for(unsigned lane=0;lane<128/f.bits;++lane)v[r].lane(lane,f.bits,(f.bits==32?edge32:edge64)[(r+lane)%19]);const auto base=prepared(v);
  for(unsigned rn=0;rn<32;++rn)for(unsigned rd=0;rd<32;++rd){unsigned flags;const auto expected=reference(f,op,v,rn,0,flags);execute(base,encoding(f,op,rn,rd),expected,flags,rn==rd);}}
}
void numeric(){
 for(auto f:forms)for(unsigned op=0;op<5;++op)for(unsigned mode=0;mode<16;++mode)for(unsigned sample=0;sample<19;++sample){
  const unsigned cr=((mode&3)<<22)|((mode&4)?1u<<24:0)|((mode&8)?1u<<25:0);Vectors v;const auto poison=f.bits==32?UINT64_C(0x7f800001):UINT64_C(0x7ff0000000000001);
  for(auto& reg:v)for(unsigned lane=0;lane<128/f.bits;++lane)reg.lane(lane,f.bits,poison);for(unsigned lane=0;lane<f.lanes;++lane)v[31].lane(lane,f.bits,(f.bits==32?edge32:edge64)[(sample+lane*3)%19]);
  unsigned flags;const auto expected=reference(f,op,v,31,cr,flags);execute(prepared(v,cr),encoding(f,op,31,mode&1?31:0),expected,flags,sample==0);
 }
}
void traps(){
 for(auto f:forms)for(unsigned op=0;op<5;++op){MinimalGuest g(128*1024*1024);g.load_elf(elf({encoding(f,op,1,0)},true),true);g.run(1);check(g.machine().exceptions==1&&(g.machine().esr>>26)==7&&!g.floating().nonzero(),"FP zero comparison bypassed access trap");}
 for(unsigned op=0;op<5;++op){const auto bad=encoding({0x0ee0d800u,64,1},op,1,0);MinimalGuest g(65536);g.load_elf(elf({bad}));const auto before=g.snapshot();bool rejected=false;try{g.run(1);}catch(const std::exception&){rejected=true;}check(rejected&&g.snapshot()==before,"Reserved 1D FP comparison changed state");}
}
#ifdef __aarch64__
struct Native {
 void* page;std::size_t bytes;
 explicit Native(std::uint32_t op){bytes=std::size_t(::sysconf(_SC_PAGESIZE));page=::mmap(nullptr,bytes,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);check(page!=MAP_FAILED,"Native FABD allocation failed");auto* c=static_cast<std::uint32_t*>(page);unsigned n=0;for(unsigned r:{(op>>5)&31,(op>>16)&31,op&31})c[n++]=0x3dc00000u|(r<<10)|r;c[n++]=op;c[n++]=0x3d800020u|(op&31);c[n++]=0xd65f03c0u;__builtin___clear_cache(static_cast<char*>(page),static_cast<char*>(page)+n*4);check(::mprotect(page,bytes,PROT_READ|PROT_EXEC)==0,"Native FABD publication failed");}
 ~Native(){::munmap(page,bytes);}Native(const Native&)=delete;
 Vector128 run(const Vectors& v,unsigned fpcr,unsigned& flags){std::uint64_t oldcr,oldsr,sr;asm volatile("mrs %0, fpcr\n\tmrs %1, fpsr":"=r"(oldcr),"=r"(oldsr));const std::uint64_t cr=fpcr,initial=10;asm volatile("msr fpcr, %0\n\tmsr fpsr, %1"::"r"(cr),"r"(initial):"memory");Vector128 out;reinterpret_cast<void(*)(const Vector128*,Vector128*)>(page)(v.data(),&out);asm volatile("mrs %0, fpsr":"=r"(sr));asm volatile("msr fpcr, %0\n\tmsr fpsr, %1"::"r"(oldcr),"r"(oldsr):"memory");flags=unsigned(sr);return out;}
};
void hardware(){
 Vectors actual;actual[4]={0x34324241,0};Native observed(0x2ea0d824u);unsigned observed_flags;const auto observed_result=observed.run(actual,0,observed_flags);execute(prepared(actual),0x2ea0d824u,observed_result,observed_flags,true);++native_cases;
 std::uint64_t seed=0x2ea0d824;auto random=[&](){seed^=seed<<13;seed^=seed>>7;seed^=seed<<17;return seed;};
 for(auto f:forms)for(unsigned op=0;op<5;++op)for(unsigned rn:{0u,16u,31u})for(unsigned rd:{0u,2u}){const auto code=encoding(f,op,rn,rd);Native native(code);for(unsigned mode=0;mode<16;++mode)for(unsigned sample=0;sample<64;++sample){const unsigned cr=((mode&3)<<22)|((mode&4)?1u<<24:0)|((mode&8)?1u<<25:0);Vectors v;for(auto& reg:v)reg={random(),random()};if(sample<19)for(unsigned lane=0;lane<128/f.bits;++lane)v[rn].lane(lane,f.bits,(f.bits==32?edge32:edge64)[(sample+lane*3)%19]);unsigned flags;auto out=native.run(v,cr,flags);execute(prepared(v,cr),code,out,flags,false);++native_cases;}}
}
#else
void hardware(){}
#endif
}
int main(){try{allocated();numeric();traps();hardware();std::cout<<"{\"cases\":"<<cases<<",\"checks\":"<<checks<<",\"native_hardware_cases\":"<<native_cases<<",\"actual_opcode\":\"0x2ea0d824\",\"android_boot\":false}\n";}catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 1;}}
