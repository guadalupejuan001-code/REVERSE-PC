#include "minimal_guest_system_demo.hpp"
#include <functional>
#include <iostream>
using namespace reverse_pc::guest;
namespace {
unsigned checks=0;
void check(bool condition,const char* message){++checks;if(!condition)throw std::runtime_error(message);}
void fails(const std::function<void()>& action,const char* message){bool rejected=false;try{action();}catch(const std::exception&){rejected=true;}check(rejected,message);}
void fault(const MinimalGuest& machine,std::uint64_t address,bool writing,bool executing,unsigned status,const char* message){
  bool rejected=false;try{machine.physical_address(address,writing,executing);}catch(const MachineFault& result){rejected=(result.syndrome&63)==status&&result.address==address;}
  check(rejected,message);
}
MinimalGuest initial(){MinimalGuest result(128*1024*1024);result.load_elf(system_demo_elf(),true);return result;}
void boot_and_restore(){
  auto whole=initial();const auto all=whole.run(10000);
  check(all.halted&&all.exit_code==0,"Bare-metal system did not shut down through PSCI");
  check(all.output=="REVERSE: EL1 MMU IRQ EL0 SVC FAULT OK\n","System witness did not verify its own architecture");
  check(whole.machine().exceptions==4&&whole.registers().x[23]==1&&whole.registers().x[24]==1,"IRQ/SVC/permission-abort transitions failed");
  check(whole.read(0x40009000,8)==0&&whole.read(0x40009008,8)==42,"Denied store changed RAM or successful store was lost");
  check(whole.runtime().memory().stats().overrides==9,"System witness materialized redundant RAM state");
  check(whole.snapshot()[3]=='2',"System mode did not use versioned machine snapshot");
  auto sliced=initial();std::string output;
  for(unsigned i=0;i<200&&!sliced.registers().halted;++i){const auto run=sliced.run(7);output+=run.output;sliced=MinimalGuest::from_snapshot(sliced.snapshot());}
  check(output==all.output&&sliced.snapshot()==whole.snapshot(),"System checkpoint changed interrupts, timer time, PC, output or memory");
  auto reset=initial();const auto pristine=reset.snapshot();auto broken=system_demo_elf();broken[18]=62;
  fails([&]{reset.load_elf(broken,true);},"Wrong ISA system ELF accepted");check(reset.snapshot()==pristine,"Invalid system ELF replaced active state");
  auto corrupt=pristine;corrupt.back()^=1;fails([&]{MinimalGuest::from_snapshot(corrupt);},"Corrupt machine checkpoint accepted");
}
void translation(){
  auto guest=initial();for(unsigned i=0;i<60&&!(guest.machine().sctlr&1);++i)guest.run(1);
  check(guest.machine().sctlr&1,"Witness never enabled the MMU");
  check(guest.physical_address(0x40080000,false,true)==0x40080000,"TTBR0 identity mapping failed");
  check(guest.physical_address(UINT64_C(0xffffff8040080000),false,true)==0x40080000,"TTBR1 upper canonical mapping failed");
  fault(guest,UINT64_C(0x0100000040080000),false,false,0,"Noncanonical virtual address accepted");
  fault(guest,0x80009000,true,false,13,"Read-only block allowed a write");
  guest.write(0x40010008,0x40000345,8);fault(guest,0x40080000,false,false,9,"Missing access flag accepted");
  guest.write(0x40010008,UINT64_C(0x0020000040000745),8);fault(guest,0x40080000,false,true,13,"Privileged execute-never ignored");
  guest.write(0x40010008,0x40011003,8);guest.write(0x40011000,0x40000745,8);
  check(guest.physical_address(0x40001234)==0x40001234,"Level-2 table/block walk failed");
  guest.write(0x40011000,0x40012003,8);guest.write(0x40012008,0x40001747,8);
  check(guest.physical_address(0x40001234)==0x40001234,"Level-3 4 KiB page walk failed");
  fault(guest,0x40002234,false,false,7,"Unmapped level-3 page accepted");
  guest.write(0x40010008,UINT64_C(0x4000000040011003),8); // APTable read-only restriction.
  fault(guest,0x40001234,true,false,15,"Table permission restriction ignored");
  auto user=initial();for(unsigned i=0;i<150&&user.machine().el;++i)user.run(1);
  check(user.machine().el==0,"ERET did not enter EL0");
  fault(user,MachineState::uart_base,false,false,13,"EL0 accessed privileged device mapping");
  check(user.physical_address(0x40080000)==0x40080000,"EL0 user-accessible RAM denied");
}
void shared_quantum_authority(){
  auto guest=initial();guest.apply_xi_delta("#!reverse-pc-machine-v1\nset r0 0\nlabel loop\nh $r0\nadd r0 1\ncmp r0 4096\njlt loop\nhalt\n");
  check(guest.runtime().core().stats().active_qubits==4096,"Existing XI 4096-qubit capability was not preserved");
  const auto core=guest.runtime().core_snapshot();auto run=guest.run(10000);
  check(run.halted&&guest.runtime().core_snapshot()==core,"Classical ARM64 execution altered the existing quantum state");
  guest.apply_xi_delta("mem_read 1073778696\n");
  check(guest.read8(0x40009008)==42,"XI and ARM64 did not share the same InverseMemory authority");
  check(MinimalGuest::from_snapshot(guest.snapshot()).runtime().core_snapshot()==core,"System checkpoint lost the original quantum authority");
}
void exclusives(){
  const std::uint32_t code[]{0xd2880001,0xf2a80001,0xd2800520,0xf9000020,0xc85f7c20,0x91000400,0xc8027c20,
    0xc85f7c23,0xd5033f5f,0xc8047c23,0xc8dffc25,0xd2800b06,0xc89ffc26,0xc8dffc27,0xd2800100,0xf2b08000,0xd4000002};
  auto image=system_demo_elf();image.resize(256);
  for(auto instruction:code)put(image,instruction,4);
  for(unsigned i=0;i<8;++i){image[96+i]=std::uint8_t((sizeof(code))>>(8*i));image[104+i]=image[96+i];}
  MinimalGuest guest(128*1024*1024);guest.load_elf(image,true);guest.run(5);
  check(guest.machine().exclusive_size==8,"LDXR did not establish an exclusive monitor");
  auto restored=MinimalGuest::from_snapshot(guest.snapshot());check(restored.snapshot()==guest.snapshot(),"Exclusive monitor was lost in checkpoint");
  restored.run(100);check(restored.registers().x[2]==0&&restored.registers().x[4]==1,"STXR success/CLREX failure status is incorrect");
  check(restored.registers().x[5]==42&&restored.registers().x[7]==88&&restored.read(0x40004000,8)==88,"Exclusive/acquire/release data values differ");
  guest.apply_xi_delta("mem_store 1073758208 99\n");guest.run(100);
  check(guest.registers().x[2]==1&&guest.registers().x[5]==99,"XI write did not invalidate the same exclusive monitor");
}
void image_boot_protocol(){
  Bytes kernel(64);auto patch=[&](std::size_t at,std::uint64_t value,unsigned size){for(unsigned i=0;i<size;++i)kernel[at+i]=std::uint8_t(value>>(i*8));};
  patch(0,0x14000010,4);patch(8,0x80000,8);patch(16,128,8);patch(24,2,8);patch(56,0x644d5241,4);
  put(kernel,0xd2800100,4);put(kernel,0xf2b08000,4);put(kernel,0xd4000002,4); // PSCI SYSTEM_OFF
  MinimalGuest guest(128*1024*1024);guest.load_linux_image(kernel,Bytes{1,2,3,4});
  check(guest.read(guest.registers().x[0],4)==0xedfe0dd0,"Boot x0 does not point at a valid big-endian FDT magic");
  check(guest.read(0x44000000,4)==0x04030201,"Initrd backing address is wrong");
  check(guest.runtime().memory().stats().overrides==0,"Image boot materialized physical RAM");
  auto restored=MinimalGuest::from_snapshot(guest.snapshot());check(restored.snapshot()==guest.snapshot(),"Image/DTB/initrd checkpoint is not exact");
  check(restored.run(10).halted,"Image-format protocol fixture did not execute at its physical entry");
  const auto before=guest.snapshot();kernel[56]^=1;fails([&]{guest.load_linux_image(kernel);},"Invalid Linux Image accepted");
  check(guest.snapshot()==before,"Invalid Image replaced current machine");
  const auto original=guest.machine().receive;guest.console_input("hello\n");
  check(MinimalGuest::from_snapshot(guest.snapshot()).machine().receive=="hello\n","Serial input queue was not persistent");
  const auto queued=guest.snapshot();fails([&]{guest.console_input(std::string(4096,'x'));},"Serial queue budget ignored");check(guest.snapshot()==queued,"Rejected serial input changed machine");
  MachineState machine;machine.enabled=true;machine.image_kind=1;machine.mdscr=0x1000;
  check(MachineState::restore(machine.save()).mdscr==0x1000,"MDSCR trap-control state did not persist");
  machine.mdscr=0;auto legacy=machine.save();legacy[0]=1;legacy.erase(legacy.end()-16,legacy.end()-8);
  check(MachineState::restore(legacy).save()==machine.save(),"Previous RVG2 machine-state v1 no longer restores");
}
}
int main(){try{boot_and_restore();translation();shared_quantum_authority();exclusives();image_boot_protocol();
  std::cout<<"{\"checks\":"<<checks<<",\"system\":\"own-EL1-MMU-IRQ-EL0-SVC\",\"existing_quantum_qubits\":4096,\"android_boot\":\"not_implemented\"}\n";return 0;
}catch(const std::exception& error){std::cerr<<error.what()<<'\n';return 1;}}
