// Independent byte permutation and physical AArch64 SHLL/SHLL2 encodings.
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
void execute(MinimalGuest g,std::uint32_t op,Vector128 out,unsigned flags,bool restore){
 g.write(g.registers().pc,op,4);const auto cpu=g.registers();const auto fp=g.floating();const auto memory=g.runtime().memory_persistent_snapshot(),core=g.runtime().core_snapshot();
 if(restore){auto other=MinimalGuest::from_snapshot(g.snapshot());g.run(1);other.run(1);check(g.snapshot()==other.snapshot(),"Shift left long changed across original checkpoint restore");}else g.run(1);
 const unsigned rd=op&31;check(g.floating().v[rd].low==out.low&&g.floating().v[rd].high==out.high,"Shift left long value, lane, alias, or upper clearing differs");
 check(g.floating().fpcr==fp.fpcr&&g.floating().fpsr==(fp.fpsr|flags),"Shift left long FPCR or cumulative FPSR differs");
 check(g.registers().pc==cpu.pc+4&&g.registers().instructions==cpu.instructions+1,"Shift left long instruction progress differs");
 check(g.registers().x==cpu.x&&g.registers().sp==cpu.sp&&g.registers().nzcv==cpu.nzcv,"Shift left long changed integer registers");
 check(g.runtime().memory_persistent_snapshot()==memory&&g.runtime().core_snapshot()==core,"Shift left long changed XI/Ether memory or core");
 for(unsigned r=0;r<32;++r)if(r!=rd)check(g.floating().v[r].low==fp.v[r].low&&g.floating().v[r].high==fp.v[r].high,"Shift left long changed another SIMD register");++cases;
}
struct Form{unsigned size;bool upper;};
const Form forms[]{{0,false},{0,true},{1,false},{1,true},{2,false},{2,true}};
std::uint32_t encoding(Form f,unsigned rn,unsigned rd){return 0x2e213800u|(f.size<<22)|(f.upper?0x40000000u:0)|(rn<<5)|rd;}
// Place each selected source element in the high bytes of a zeroed destination
// element. This oracle does not use the decoder's lane/shift arithmetic.
Vector128 reference(Form f,Vector128 source){
 std::array<unsigned char,16> input{},output{};for(unsigned n=0;n<16;++n)input[n]=static_cast<unsigned char>((n<8?source.low:source.high)>>(8*(n&7)));
 const unsigned bytes=1u<<f.size,first=f.upper?8:0;for(unsigned element=0;element<8/bytes;++element)for(unsigned n=0;n<bytes;++n)output[(2*element+1)*bytes+n]=input[first+element*bytes+n];
 Vector128 result;for(unsigned n=0;n<8;++n){result.low|=std::uint64_t(output[n])<<(8*n);result.high|=std::uint64_t(output[n+8])<<(8*n);}return result;
}
const Vector128 patterns[]{{0,0},{UINT64_MAX,UINT64_MAX},{UINT64_C(0x0123456789abcdef),UINT64_C(0xfedcba9876543210)},{UINT64_C(0x8000800080008000),UINT64_C(0x0080008000800080)},{UINT64_C(0x7f8000017fc12345),UINT64_C(0x7ff0000000000001)},{UINT64_C(0xaaaaaaaa55555555),UINT64_C(0x55555555aaaaaaaa)},{UINT64_C(1),UINT64_C(0x8000000000000000)},{UINT64_C(0x8000000000000000),UINT64_C(1)},{UINT64_C(0x25800000000),0},{0,UINT64_C(0x0000032000000258)}};
void allocated(){
 Vectors actual;actual[1]={UINT64_C(0x25800000000),0};execute(prepared(actual,0,16),0x2ea13821u,{0,UINT64_C(0x25800000000)},0,true);
 for(auto f:forms){Vectors v;for(unsigned r=0;r<32;++r)v[r]={UINT64_C(0x0123456789abcdef)^std::uint64_t(r)*UINT64_C(0x0101010101010101),UINT64_C(0xfedcba9876543210)^std::uint64_t(r)*UINT64_C(0x0303030303030303)};const auto base=prepared(v);for(unsigned rn=0;rn<32;++rn)for(unsigned rd=0;rd<32;++rd)execute(base,encoding(f,rn,rd),reference(f,v[rn]),0,rn==rd);}
}
void numeric(){
 for(auto f:forms)for(unsigned mode=0;mode<16;++mode)for(auto p:patterns)for(unsigned rn:{0u,16u,31u}){const unsigned cr=((mode&3)<<22)|((mode&4)?1u<<24:0)|((mode&8)?1u<<25:0);Vectors v;for(auto& value:v)value={UINT64_MAX,UINT64_MAX};v[rn]=p;execute(prepared(v,cr),encoding(f,rn,mode&1?rn:2),reference(f,p),0,true);}
}
void traps(){
 for(auto f:forms){MinimalGuest g(128*1024*1024);g.load_elf(elf({encoding(f,1,0)},true),true);g.run(1);check(g.machine().exceptions==1&&(g.machine().esr>>26)==7&&!g.floating().nonzero(),"SHLL bypassed SIMD access trap");}
 for(bool upper:{false,true}){MinimalGuest g(65536);g.load_elf(elf({encoding({3,upper},1,0)}));const auto before=g.snapshot();bool rejected=false;try{g.run(1);}catch(const std::exception&){rejected=true;}check(rejected&&g.snapshot()==before,"Reserved SHLL size modified state");}
}
#ifdef __aarch64__
struct Native {
 void* page;std::size_t bytes;
 explicit Native(std::uint32_t op){bytes=std::size_t(::sysconf(_SC_PAGESIZE));page=::mmap(nullptr,bytes,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);check(page!=MAP_FAILED,"Native FABD allocation failed");auto* c=static_cast<std::uint32_t*>(page);unsigned n=0;for(unsigned r:{(op>>5)&31,(op>>16)&31,op&31})c[n++]=0x3dc00000u|(r<<10)|r;c[n++]=op;c[n++]=0x3d800020u|(op&31);c[n++]=0xd65f03c0u;__builtin___clear_cache(static_cast<char*>(page),static_cast<char*>(page)+n*4);check(::mprotect(page,bytes,PROT_READ|PROT_EXEC)==0,"Native FABD publication failed");}
 ~Native(){::munmap(page,bytes);}Native(const Native&)=delete;
 Vector128 run(const Vectors& v,unsigned fpcr,unsigned& flags){std::uint64_t oldcr,oldsr,sr;asm volatile("mrs %0, fpcr\n\tmrs %1, fpsr":"=r"(oldcr),"=r"(oldsr));const std::uint64_t cr=fpcr,initial=10;asm volatile("msr fpcr, %0\n\tmsr fpsr, %1"::"r"(cr),"r"(initial):"memory");Vector128 out;reinterpret_cast<void(*)(const Vector128*,Vector128*)>(page)(v.data(),&out);asm volatile("mrs %0, fpsr":"=r"(sr));asm volatile("msr fpcr, %0\n\tmsr fpsr, %1"::"r"(oldcr),"r"(oldsr):"memory");flags=unsigned(sr);return out;}
};
void hardware(){
 Vectors actual;actual[1]={UINT64_C(0x25800000000),0};Native observed(0x2ea13821u);unsigned observed_flags;const auto observed_result=observed.run(actual,0,observed_flags);execute(prepared(actual),0x2ea13821u,observed_result,observed_flags,true);++native_cases;
 std::uint64_t seed=0x2ea13821;auto random=[&](){seed^=seed<<13;seed^=seed>>7;seed^=seed<<17;return seed;};
 for(auto f:forms)for(unsigned rn:{0u,16u,31u})for(unsigned rd:{0u,2u}){const auto code=encoding(f,rn,rd);Native native(code);for(unsigned mode=0;mode<16;++mode)for(unsigned sample=0;sample<256;++sample){const unsigned cr=((mode&3)<<22)|((mode&4)?1u<<24:0)|((mode&8)?1u<<25:0);Vectors v;for(auto& r:v)r={random(),random()};if(sample<10)v[rn]=patterns[sample];unsigned flags;const auto out=native.run(v,cr,flags);execute(prepared(v,cr),code,out,flags,false);++native_cases;}}
}
#else
void hardware(){}
#endif
}
int main(){try{allocated();numeric();traps();hardware();std::cout<<"{\"cases\":"<<cases<<",\"checks\":"<<checks<<",\"native_hardware_cases\":"<<native_cases<<",\"actual_opcode\":\"0x2ea13821\",\"android_boot\":false}\n";}catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 1;}}
