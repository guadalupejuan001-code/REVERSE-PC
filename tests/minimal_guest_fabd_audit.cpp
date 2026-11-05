// Independent host-IEEE oracle and optional actual AArch64 encodings for FABD.
// Build with -frounding-math. No emulator FP arithmetic is used by the oracle.
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
const Form forms[]{{0x7ea0d400u,32,1},{0x7ee0d400u,64,1},{0x2ea0d400u,32,2},{0x6ea0d400u,32,4},{0x6ee0d400u,64,2}};
std::uint32_t encoding(Form f,unsigned rn,unsigned rm,unsigned rd){return f.base|(rm<<16)|(rn<<5)|rd;}
std::pair<std::uint64_t,unsigned> reference(unsigned bits,std::uint64_t a,std::uint64_t b,unsigned fpcr){
 const auto sign=UINT64_C(1)<<(bits-1),exp=bits==32?UINT64_C(0x7f800000):UINT64_C(0x7ff0000000000000),frac=bits==32?UINT64_C(0x7fffff):UINT64_C(0xfffffffffffff),quiet=bits==32?UINT64_C(0x400000):UINT64_C(0x8000000000000);
 unsigned flags=0;
 for(auto* x:{&a,&b})if((fpcr&(1u<<24))&&!(*x&exp)&&(*x&frac)){*x&=sign;flags|=128;}
 auto nan=[&](std::uint64_t x){return (x&exp)==exp&&(x&frac);};
 auto snan=[&](std::uint64_t x){return nan(x)&&!(x&quiet);};
 if(nan(a)||nan(b)){
  if(snan(a)||snan(b))flags|=1;const auto value=snan(a)?a:snan(b)?b:nan(a)?a:b;
  return {fpcr&(1u<<25)?exp|quiet:(value|quiet)&~sign,flags};
 }
 if((a&~sign)==exp&&(b&~sign)==exp&&((a^b)&sign)==0)return {exp|quiet,flags|1};
 if((a&~sign)==exp||(b&~sign)==exp)return {exp,flags};
 std::fenv_t old;check(std::fegetenv(&old)==0,"Host IEEE environment unavailable");
 const int modes[]{FE_TONEAREST,FE_UPWARD,FE_DOWNWARD,FE_TOWARDZERO};check(std::fesetround(modes[(fpcr>>22)&3])==0,"Cannot set host IEEE rounding");std::feclearexcept(FE_ALL_EXCEPT);
 std::uint64_t result=0;
 if(bits==32){std::uint32_t aa=std::uint32_t(a),bb=std::uint32_t(b),out;float x,y;std::memcpy(&x,&aa,4);std::memcpy(&y,&bb,4);volatile float vx=x,vy=y;const float diff=vx-vy;std::memcpy(&out,&diff,4);result=out;}
 else{double x,y;std::memcpy(&x,&a,8);std::memcpy(&y,&b,8);volatile double vx=x,vy=y;const double diff=vx-vy;std::memcpy(&result,&diff,8);}
 const int raised=std::fetestexcept(FE_ALL_EXCEPT);std::fesetenv(&old);
 if(raised&FE_INVALID)flags|=1;if(raised&FE_DIVBYZERO)flags|=2;if(raised&FE_OVERFLOW)flags|=4;if(raised&FE_UNDERFLOW)flags|=8;if(raised&FE_INEXACT)flags|=16;
 if((fpcr&(1u<<24))&&!(result&exp)&&(result&frac)){result=0;flags|=8;}
 return {result&~sign,flags};
}
Vector128 reference(Form f,const Vectors& v,unsigned rn,unsigned rm,unsigned fpcr,unsigned& flags){
 Vector128 out;flags=0;for(unsigned lane=0;lane<f.lanes;++lane){auto x=reference(f.bits,v[rn].lane(lane,f.bits),v[rm].lane(lane,f.bits),fpcr);out.lane(lane,f.bits,x.first);flags|=x.second;}return out;
}
void execute(MinimalGuest g,std::uint32_t op,Vector128 out,unsigned flags,bool restore){
 g.write(g.registers().pc,op,4);const auto cpu=g.registers();const auto fp=g.floating();const auto memory=g.runtime().memory_persistent_snapshot(),core=g.runtime().core_snapshot();
 if(restore){auto other=MinimalGuest::from_snapshot(g.snapshot());g.run(1);other.run(1);check(g.snapshot()==other.snapshot(),"FABD changed across original checkpoint restore");}else g.run(1);
 const unsigned rd=op&31;check(g.floating().v[rd].low==out.low&&g.floating().v[rd].high==out.high,"FABD value, lane, alias, or upper clearing differs");
 check(g.floating().fpcr==fp.fpcr&&g.floating().fpsr==(fp.fpsr|flags),"FABD FPCR or cumulative FPSR differs");
 check(g.registers().pc==cpu.pc+4&&g.registers().instructions==cpu.instructions+1,"FABD instruction progress differs");
 check(g.registers().x==cpu.x&&g.registers().sp==cpu.sp&&g.registers().nzcv==cpu.nzcv,"FABD changed integer registers");
 check(g.runtime().memory_persistent_snapshot()==memory&&g.runtime().core_snapshot()==core,"FABD changed XI/Ether memory or core");
 for(unsigned r=0;r<32;++r)if(r!=rd)check(g.floating().v[r].low==fp.v[r].low&&g.floating().v[r].high==fp.v[r].high,"FABD changed another SIMD register");++cases;
}
std::uint64_t raw(double x,unsigned bits){if(bits==32){const float f=float(x);std::uint32_t n;std::memcpy(&n,&f,4);return n;}std::uint64_t n;std::memcpy(&n,&x,8);return n;}
const std::uint64_t edge32[]{0,0x80000000,1,0x80000001,0x007fffff,0x00800000,0x3f800000,0xbf800000,0x33800000,0xb3800000,0x3f800001,0x7f7fffff,0xff7fffff,0x7f800000,0xff800000,0x7fc12345,0xffc23456,0x7f812345,0xff823456};
const std::uint64_t edge64[]{0,UINT64_C(0x8000000000000000),1,UINT64_C(0x8000000000000001),UINT64_C(0x000fffffffffffff),UINT64_C(0x0010000000000000),UINT64_C(0x3ff0000000000000),UINT64_C(0xbff0000000000000),UINT64_C(0x3ca0000000000000),UINT64_C(0xbca0000000000000),UINT64_C(0x3ff0000000000001),UINT64_C(0x7fefffffffffffff),UINT64_C(0xffefffffffffffff),UINT64_C(0x7ff0000000000000),UINT64_C(0xfff0000000000000),UINT64_C(0x7ff8000000012345),UINT64_C(0xfff8000000023456),UINT64_C(0x7ff0000000012345),UINT64_C(0xfff0000000023456)};
void allocated(){
 Vectors actual;actual[0]={0x41c00000,0};actual[1]={0x41f00000,0};execute(prepared(actual,0,16),0x7ea1d400u,{0x40c00000,0},0,true);
 for(auto f:forms){Vectors v;for(unsigned r=0;r<32;++r)for(unsigned lane=0;lane<128/f.bits;++lane)v[r].lane(lane,f.bits,raw(double(r*7+lane)/16,f.bits));const auto base=prepared(v);
  for(unsigned rn=0;rn<32;++rn)for(unsigned rm=0;rm<32;++rm)for(unsigned rd:{rn,rm,(rn+rm)&31}){unsigned flags;auto out=reference(f,v,rn,rm,0,flags);execute(base,encoding(f,rn,rm,rd),out,flags,rn==rd&&rm%8==0);}}
}
void numeric(){
 for(auto f:forms)for(unsigned mode=0;mode<16;++mode)for(unsigned ai=0;ai<19;++ai)for(unsigned bi=0;bi<19;++bi){
  const unsigned cr=((mode&3)<<22)|((mode&4)?1u<<24:0)|((mode&8)?1u<<25:0);Vectors v;for(unsigned r=0;r<32;++r)v[r]={UINT64_MAX-r,UINT64_MAX-r};
  const auto* edge=f.bits==32?edge32:edge64;for(unsigned l=0;l<128/f.bits;++l){v[0].lane(l,f.bits,edge[(ai+l*3)%19]);v[31].lane(l,f.bits,edge[(bi+l*5)%19]);}
  unsigned flags;const auto out=reference(f,v,0,31,cr,flags);execute(prepared(v,cr),encoding(f,0,31,0),out,flags,false);
 }
 // This distinguishes rounding the signed subtraction before taking abs.
 for(unsigned bits:{32u,64u})for(unsigned mode=0;mode<4;++mode){const auto negone=raw(-1,bits),half=bits==32?UINT64_C(0x33800000):UINT64_C(0x3ca0000000000000);const auto r=reference(bits,negone,half,mode<<22);check(r.first==raw(1,bits)+(mode==2?1:0)&&r.second==16,"Host rounding oracle does not preserve signed subtraction");}
}
void traps(){
 for(auto f:forms){MinimalGuest g(128*1024*1024);g.load_elf(elf({encoding(f,1,2,0)},true),true);g.run(1);check(g.machine().exceptions==1&&(g.machine().esr>>26)==7&&!g.floating().nonzero(),"FABD bypassed FP access trap");}
 for(auto op:{0x2ee1d420u,0x7ec11420u,0x2ec11420u,0x6ec11420u}){MinimalGuest g(65536);g.load_elf(elf({op}));const auto before=g.snapshot();bool rejected=false;try{g.run(1);}catch(const std::exception&){rejected=true;}check(rejected&&g.snapshot()==before,"Unsupported FABD shape changed state");}
}
#ifdef __aarch64__
struct Native {
 void* page;std::size_t bytes;
 explicit Native(std::uint32_t op){bytes=std::size_t(::sysconf(_SC_PAGESIZE));page=::mmap(nullptr,bytes,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);check(page!=MAP_FAILED,"Native FABD allocation failed");auto* c=static_cast<std::uint32_t*>(page);unsigned n=0;for(unsigned r:{(op>>5)&31,(op>>16)&31,op&31})c[n++]=0x3dc00000u|(r<<10)|r;c[n++]=op;c[n++]=0x3d800020u|(op&31);c[n++]=0xd65f03c0u;__builtin___clear_cache(static_cast<char*>(page),static_cast<char*>(page)+n*4);check(::mprotect(page,bytes,PROT_READ|PROT_EXEC)==0,"Native FABD publication failed");}
 ~Native(){::munmap(page,bytes);}Native(const Native&)=delete;
 Vector128 run(const Vectors& v,unsigned fpcr,unsigned& flags){std::uint64_t oldcr,oldsr,sr;asm volatile("mrs %0, fpcr\n\tmrs %1, fpsr":"=r"(oldcr),"=r"(oldsr));const std::uint64_t cr=fpcr,initial=10;asm volatile("msr fpcr, %0\n\tmsr fpsr, %1"::"r"(cr),"r"(initial):"memory");Vector128 out;reinterpret_cast<void(*)(const Vector128*,Vector128*)>(page)(v.data(),&out);asm volatile("mrs %0, fpsr":"=r"(sr));asm volatile("msr fpcr, %0\n\tmsr fpsr, %1"::"r"(oldcr),"r"(oldsr):"memory");flags=unsigned(sr);return out;}
};
void hardware(){
 std::uint64_t seed=0x7ea1d400;auto random=[&](){seed^=seed<<13;seed^=seed>>7;seed^=seed<<17;return seed;};
 for(auto f:forms)for(unsigned rn:{0u,16u,31u})for(unsigned rm:{0u,16u,31u})for(unsigned rd:{0u,2u}){const auto op=encoding(f,rn,rm,rd);Native native(op);for(unsigned mode=0;mode<16;++mode)for(unsigned sample=0;sample<64;++sample){const unsigned cr=((mode&3)<<22)|((mode&4)?1u<<24:0)|((mode&8)?1u<<25:0);Vectors v;for(auto& x:v)x={random(),random()};if(sample<19){const auto* edge=f.bits==32?edge32:edge64;for(unsigned l=0;l<128/f.bits;++l){v[rn].lane(l,f.bits,edge[(sample+l)%19]);v[rm].lane(l,f.bits,edge[(sample+l*3+7)%19]);}}
  unsigned flags;const auto out=native.run(v,cr,flags);execute(prepared(v,cr),op,out,flags,false);++native_cases;}}
}
#else
void hardware(){}
#endif
}
int main(){try{allocated();numeric();traps();hardware();std::cout<<"{\"cases\":"<<cases<<",\"checks\":"<<checks<<",\"native_hardware_cases\":"<<native_cases<<",\"actual_opcode\":\"0x7ea1d400\",\"oracle\":\"independent-host-IEEE-and-AArch64-if-native\",\"android_boot\":false}\n";}catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 1;}}
