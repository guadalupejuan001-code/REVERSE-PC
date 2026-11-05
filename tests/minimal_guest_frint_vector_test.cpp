// Independent bit-level integral rounding and physical AArch64 FRINT encodings.
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
struct Form{unsigned bits,lanes;bool wide;};
const Form forms[]{{32,2,false},{32,4,true},{64,2,true}};
const std::uint32_t operations[]{0x0e218800u,0x0ea18800u,0x0e219800u,0x0ea19800u,0x2e218800u,0x2e219800u,0x2ea19800u};
std::uint32_t encoding(Form f,unsigned operation,unsigned rn,unsigned rd){return operations[operation]|(f.bits==64?0x400000u:0)|(f.wide?0x40000000u:0)|(rn<<5)|rd;}
std::uint64_t raw_integer(std::uint64_t value,unsigned bits){if(bits==32){const float f=float(value);std::uint32_t v;std::memcpy(&v,&f,4);return v;}const double d=double(value);std::uint64_t v;std::memcpy(&v,&d,8);return v;}
std::pair<std::uint64_t,unsigned> reference(unsigned bits,std::uint64_t x,unsigned operation,unsigned fpcr){
 const unsigned fraction=bits==32?23u:52u,bias=bits==32?127u:1023u;const auto sign=UINT64_C(1)<<(bits-1),exponent=bits==32?UINT64_C(0x7f800000):UINT64_C(0x7ff0000000000000),frac=(UINT64_C(1)<<fraction)-1,quiet=UINT64_C(1)<<(fraction-1),magnitude=x&~sign;const bool negative=x&sign;
 if((magnitude&exponent)==exponent){if(!(magnitude&frac))return {x,0};return {fpcr&(1u<<25)?exponent|quiet:x|quiet,magnitude&quiet?0u:1u};}
 if((fpcr&(1u<<24))&&!(magnitude&exponent)&&(magnitude&frac))return {x&sign,128};
 if(!magnitude)return {x,0};const int e=int((magnitude&exponent)>>fraction)-int(bias);if(e>=int(fraction))return {x,0};
 const unsigned mode=operation<5?operation:(fpcr>>22)&3;unsigned round=mode;
 // Operations are nearest-even, +inf, -inf, zero, ties-away, current-exact, current.
 std::uint64_t integral=0,remainder=0,half=0;
 if(e<0){remainder=1;const auto half_raw=std::uint64_t(bias-1)<<fraction;if(round==0||round==4)integral=magnitude>half_raw||(round==4&&magnitude==half_raw)?1:0;else if(round==1)integral=!negative;else if(round==2)integral=negative;}
 else{const unsigned shift=fraction-unsigned(e);const auto significand=(UINT64_C(1)<<fraction)|(magnitude&frac);integral=significand>>shift;remainder=significand&((UINT64_C(1)<<shift)-1);half=UINT64_C(1)<<(shift-1);if(remainder){const bool up=round==0?remainder>half||(remainder==half&&(integral&1)):round==4?remainder>=half:round==1?!negative:round==2?negative:false;if(up)++integral;}}
 return {raw_integer(integral,bits)|(x&sign),operation==5&&remainder?16u:0u};
}
Vector128 reference(Form f,unsigned op,const Vectors& v,unsigned rn,unsigned fpcr,unsigned& flags){Vector128 out;flags=0;for(unsigned lane=0;lane<f.lanes;++lane){const auto x=reference(f.bits,v[rn].lane(lane,f.bits),op,fpcr);out.lane(lane,f.bits,x.first);flags|=x.second;}return out;}
void execute(MinimalGuest g,std::uint32_t op,Vector128 out,unsigned flags,bool restore){
 g.write(g.registers().pc,op,4);const auto cpu=g.registers();const auto fp=g.floating();const auto memory=g.runtime().memory_persistent_snapshot(),core=g.runtime().core_snapshot();
 if(restore){auto other=MinimalGuest::from_snapshot(g.snapshot());g.run(1);other.run(1);check(g.snapshot()==other.snapshot(),"Vector integral rounding changed across original checkpoint restore");}else g.run(1);
 const unsigned rd=op&31;check(g.floating().v[rd].low==out.low&&g.floating().v[rd].high==out.high,"Vector integral rounding value, lane, alias, or upper clearing differs");
 check(g.floating().fpcr==fp.fpcr&&g.floating().fpsr==(fp.fpsr|flags),"Vector integral rounding FPCR or cumulative FPSR differs");
 check(g.registers().pc==cpu.pc+4&&g.registers().instructions==cpu.instructions+1,"Vector integral rounding instruction progress differs");
 check(g.registers().x==cpu.x&&g.registers().sp==cpu.sp&&g.registers().nzcv==cpu.nzcv,"Vector integral rounding changed integer registers");
 check(g.runtime().memory_persistent_snapshot()==memory&&g.runtime().core_snapshot()==core,"Vector integral rounding changed XI/Ether memory or core");
 for(unsigned r=0;r<32;++r)if(r!=rd)check(g.floating().v[r].low==fp.v[r].low&&g.floating().v[r].high==fp.v[r].high,"Vector integral rounding changed another SIMD register");++cases;
}
const std::uint64_t edge32[]{0,0x80000000,1,0x80000001,0x007fffff,0x00800000,0x3f000000,0xbf000000,0x3e800000,0xbe800000,0x3f400000,0xbf400000,0x3fc00000,0xbfc00000,0x40200000,0xc0200000,0x3f7fffff,0x3f800001,0x4affffff,0x4b000000,0x7f7fffff,0x7f800000,0xff800000,0x7fc12345,0x7f812345};
const std::uint64_t edge64[]{0,UINT64_C(0x8000000000000000),1,UINT64_C(0x8000000000000001),UINT64_C(0x000fffffffffffff),UINT64_C(0x0010000000000000),UINT64_C(0x3fe0000000000000),UINT64_C(0xbfe0000000000000),UINT64_C(0x3fd0000000000000),UINT64_C(0xbfd0000000000000),UINT64_C(0x3fe8000000000000),UINT64_C(0xbfe8000000000000),UINT64_C(0x3ff8000000000000),UINT64_C(0xbff8000000000000),UINT64_C(0x4004000000000000),UINT64_C(0xc004000000000000),UINT64_C(0x3fefffffffffffff),UINT64_C(0x3ff0000000000001),UINT64_C(0x432fffffffffffff),UINT64_C(0x4330000000000000),UINT64_C(0x7fefffffffffffff),UINT64_C(0x7ff0000000000000),UINT64_C(0xfff0000000000000),UINT64_C(0x7ff8000000012345),UINT64_C(0x7ff0000000012345)};
void allocated(){
 Vectors actual;execute(prepared(actual,0,16),0x0e219821u,{0,0},0,true);
 for(auto f:forms)for(unsigned op=0;op<7;++op){Vectors v;for(unsigned r=0;r<32;++r)for(unsigned lane=0;lane<128/f.bits;++lane)v[r].lane(lane,f.bits,(f.bits==32?edge32:edge64)[(r+lane)%25]);const auto base=prepared(v);
  for(unsigned rn=0;rn<32;++rn)for(unsigned rd=0;rd<32;++rd){unsigned flags;const auto expected=reference(f,op,v,rn,0,flags);execute(base,encoding(f,op,rn,rd),expected,flags,rn==rd);}}
}
void numeric(){
 for(auto f:forms)for(unsigned op=0;op<7;++op)for(unsigned mode=0;mode<16;++mode)for(unsigned sample=0;sample<25;++sample){const unsigned cr=((mode&3)<<22)|((mode&4)?1u<<24:0)|((mode&8)?1u<<25:0);Vectors v;const auto poison=f.bits==32?UINT64_C(0x7f800001):UINT64_C(0x7ff0000000000001);for(auto& r:v)for(unsigned lane=0;lane<128/f.bits;++lane)r.lane(lane,f.bits,poison);for(unsigned lane=0;lane<f.lanes;++lane)v[31].lane(lane,f.bits,(f.bits==32?edge32:edge64)[(sample+lane*3)%25]);unsigned flags;const auto expected=reference(f,op,v,31,cr,flags);execute(prepared(v,cr),encoding(f,op,31,mode&1?31:0),expected,flags,sample==0);}
}
void traps(){
 for(auto f:forms)for(unsigned op=0;op<7;++op){MinimalGuest g(128*1024*1024);g.load_elf(elf({encoding(f,op,1,0)},true),true);g.run(1);check(g.machine().exceptions==1&&(g.machine().esr>>26)==7&&!g.floating().nonzero(),"FRINT bypassed FP access trap");}
 for(unsigned op=0;op<7;++op){const auto bad=encoding({64,1,false},op,1,0);MinimalGuest g(65536);g.load_elf(elf({bad}));const auto before=g.snapshot();bool rejected=false;try{g.run(1);}catch(const std::exception&){rejected=true;}check(rejected&&g.snapshot()==before,"Reserved 1D FRINT changed state");}
}
#ifdef __aarch64__
struct Native {
 void* page;std::size_t bytes;
 explicit Native(std::uint32_t op){bytes=std::size_t(::sysconf(_SC_PAGESIZE));page=::mmap(nullptr,bytes,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);check(page!=MAP_FAILED,"Native FABD allocation failed");auto* c=static_cast<std::uint32_t*>(page);unsigned n=0;for(unsigned r:{(op>>5)&31,(op>>16)&31,op&31})c[n++]=0x3dc00000u|(r<<10)|r;c[n++]=op;c[n++]=0x3d800020u|(op&31);c[n++]=0xd65f03c0u;__builtin___clear_cache(static_cast<char*>(page),static_cast<char*>(page)+n*4);check(::mprotect(page,bytes,PROT_READ|PROT_EXEC)==0,"Native FABD publication failed");}
 ~Native(){::munmap(page,bytes);}Native(const Native&)=delete;
 Vector128 run(const Vectors& v,unsigned fpcr,unsigned& flags){std::uint64_t oldcr,oldsr,sr;asm volatile("mrs %0, fpcr\n\tmrs %1, fpsr":"=r"(oldcr),"=r"(oldsr));const std::uint64_t cr=fpcr,initial=10;asm volatile("msr fpcr, %0\n\tmsr fpsr, %1"::"r"(cr),"r"(initial):"memory");Vector128 out;reinterpret_cast<void(*)(const Vector128*,Vector128*)>(page)(v.data(),&out);asm volatile("mrs %0, fpsr":"=r"(sr));asm volatile("msr fpcr, %0\n\tmsr fpsr, %1"::"r"(oldcr),"r"(oldsr):"memory");flags=unsigned(sr);return out;}
};
void hardware(){
 Vectors actual;Native observed(0x0e219821u);unsigned observed_flags;const auto observed_result=observed.run(actual,0,observed_flags);execute(prepared(actual),0x0e219821u,observed_result,observed_flags,true);++native_cases;
 std::uint64_t seed=0x0e219821;auto random=[&](){seed^=seed<<13;seed^=seed>>7;seed^=seed<<17;return seed;};
 for(auto f:forms)for(unsigned op=0;op<7;++op)for(unsigned rn:{0u,16u,31u})for(unsigned rd:{0u,2u}){const auto code=encoding(f,op,rn,rd);Native native(code);for(unsigned mode=0;mode<16;++mode)for(unsigned sample=0;sample<64;++sample){const unsigned cr=((mode&3)<<22)|((mode&4)?1u<<24:0)|((mode&8)?1u<<25:0);Vectors v;for(auto& r:v)r={random(),random()};if(sample<25)for(unsigned lane=0;lane<128/f.bits;++lane)v[rn].lane(lane,f.bits,(f.bits==32?edge32:edge64)[(sample+lane*3)%25]);unsigned flags;const auto out=native.run(v,cr,flags);execute(prepared(v,cr),code,out,flags,false);++native_cases;}}
}
#else
void hardware(){}
#endif
}
int main(){try{allocated();numeric();traps();hardware();std::cout<<"{\"cases\":"<<cases<<",\"checks\":"<<checks<<",\"native_hardware_cases\":"<<native_cases<<",\"actual_opcode\":\"0x0e219821\",\"android_boot\":false}\n";}catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 1;}}
