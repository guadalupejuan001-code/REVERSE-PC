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
  guest.write(0x40010008,0x40000745,8);fault(guest,0x40080000,false,true,13,"EL1 executed a region writable by EL0");
  guest.write(0x40010008,UINT64_C(0x0020000040000705),8);fault(guest,0x40080000,false,true,13,"Privileged execute-never ignored");
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
  check(user.physical_address(0x80080000,false,true)==0x40080000,"EL0 read-only code alias denied");
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
void cross_page_access(){
  auto guest=initial();for(unsigned i=0;i<60&&!(guest.machine().sctlr&1);++i)guest.run(1);
  guest.write(0x40010018,0x40011003,8);guest.write(0x40011000,0x40012003,8);
  guest.write(0x40012000,0x40030703,8);guest.write(0x40012008,0x40050703,8);
  guest.write(0x400a0000,0xf9000020,4);guest.write(0x400a0004,0xf9400022,4); // STR X0,[X1]; LDR X2,[X1]
  auto enter=[](MinimalGuest& target,std::uint64_t address,std::uint64_t value){
    auto state=target.snapshot();auto patch=[&](std::size_t at,std::uint64_t n){for(unsigned i=0;i<8;++i)state[at+i]=std::uint8_t(n>>(i*8));};
    patch(24,0x400a0000);patch(72,value);patch(80,address);patch(state.size()-8,digest(state,state.size()-8));target=MinimalGuest::from_snapshot(state);
  };
  enter(guest,0xc0000ffc,UINT64_C(0x123456789abcdef0));guest.run(2);
  check(guest.read(0x40030ffc,4)==0x9abcdef0&&guest.read(0x40050000,4)==0x12345678,"Cross-page store assumed physically adjacent pages");
  check(guest.registers().x[2]==UINT64_C(0x123456789abcdef0),"Cross-page load joined the wrong physical pages");
  guest.write(0x400a0000,0x69400820,4);enter(guest,0xc0000ffc,0);guest.run(1); // LDPSW X0,X2,[X1]
  check(guest.registers().x[0]==UINT64_C(0xffffffff9abcdef0)&&guest.registers().x[2]==0x12345678,"LDPSW did not sign-extend separate mapped pages");
  guest.write(0x400a0000,0xf9000020,4);
  guest.write(0x40012008,0x40050783,8);enter(guest,0xc0000ffc,UINT64_MAX);guest.run(1);
  check(guest.machine().exceptions==1&&guest.machine().far==0xc0001000&&(guest.machine().esr&63)==15,"Cross-page permission fault has incorrect address/status");
  check(guest.read(0x40030ffc,4)==0x9abcdef0&&guest.read(0x40050000,4)==0x12345678,"Faulting cross-page store changed an earlier byte");
  // Changing the page table must affect the very next access: there is no
  // retained translation cache that can hide a permission or alias change.
  guest.write(0x40012008,0x40060703,8);enter(guest,0xc0000ffc,UINT64_C(0x0badcafe00000000));guest.run(2);
  check(guest.read(0x40060000,4)==0x0badcafe&&guest.read(0x40050000,4)==0x12345678,"Access-local mapping reuse became a stale persistent TLB");
}

void unprivileged_memory_access(){
  auto guest=initial();
  for(unsigned i=0;i<60 && !(guest.machine().sctlr&1);++i)guest.run(1);
  check((guest.machine().sctlr&1)!=0&&guest.machine().el==1,
        "Unprivileged test did not start at EL1 with MMU");
  // Map 0xC0000000 and the next 4 KiB to distinct physical pages.
  guest.write(0x40010018,0x40011003,8);
  guest.write(0x40011000,0x40012003,8);
  guest.write(0x40012000,0x40030703,8); // First page EL1 only.
  guest.write(0x40012008,0x40050703,8); // Second page EL1 only.
  // Exact independently assembled AArch64 STTR/LDTR opcodes.
  constexpr std::uint32_t sttr=0xf8000820,ldtr=0xf8400822;
  constexpr std::uint32_t privileged_str=0xf9000020;
  guest.write(0x400a0000,sttr,4);
  auto enter=[](MinimalGuest& target,std::uint64_t address,std::uint64_t value){
    auto state=target.snapshot();
    auto patch=[&](std::size_t at,std::uint64_t n){
      for(unsigned i=0;i<8;++i)state[at+i]=std::uint8_t(n>>(i*8));
    };
    patch(24,0x400a0000);patch(72,value);patch(80,address);
    patch(state.size()-8,digest(state,state.size()-8));
    target=MinimalGuest::from_snapshot(state);
  };
  const auto initial_state=guest.snapshot();
  constexpr std::uint64_t payload=UINT64_C(0x123456789abcdef0);
  enter(guest,0xc0000ffc,payload);
  const auto core=guest.runtime().core_snapshot();
  guest.run(1);
  check(guest.machine().exceptions==1&&guest.machine().far==0xc0000ffc &&
        (guest.machine().esr&63)==15 && ((guest.machine().esr>>26)&63)==0x25,
        "STTR failed to enforce user permission with an EL1 data abort");
  check(guest.read(0x40030ffc,4)==0 && guest.read(0x40050000,4)==0,
        "Faulting unprivileged store partially modified protected memory");
  check(guest.runtime().core_snapshot()==core,
        "Unprivileged permission fault changed quantum state");

  auto normal=MinimalGuest::from_snapshot(initial_state);
  normal.write(0x400a0000,privileged_str,4);
  enter(normal,0xc0000ffc,payload);normal.run(1);
  check(normal.machine().exceptions==0 &&
        normal.read(0x40030ffc,4)==0x9abcdef0 &&
        normal.read(0x40050000,4)==0x12345678,
        "Ordinary EL1 store was unexpectedly restricted to EL0 permissions");

  auto partial=MinimalGuest::from_snapshot(initial_state);
  partial.write(0x40012000,0x40030743,8); // EL0 may write first page only.
  enter(partial,0xc0000ffc,payload);partial.run(1);
  check(partial.machine().exceptions==1&&partial.machine().far==0xc0001000 &&
        (partial.machine().esr&63)==15 &&
        partial.read(0x40030ffc,4)==0 && partial.read(0x40050000,4)==0,
        "Cross-page STTR did not roll back after EL0 permission fault");

  auto allowed=MinimalGuest::from_snapshot(initial_state);
  allowed.write(0x40012000,0x40030743,8);
  allowed.write(0x40012008,0x40050743,8);
  enter(allowed,0xc0000ffc,payload);
  const auto before_store=allowed.snapshot();
  allowed.run(1);
  check(allowed.machine().exceptions==0&&allowed.machine().el==1 &&
        allowed.registers().x[1]==0xc0000ffc &&
        allowed.read(0x40030ffc,4)==0x9abcdef0 &&
        allowed.read(0x40050000,4)==0x12345678,
        "STTR did not write user pages or changed the base register");
  auto resume=MinimalGuest::from_snapshot(allowed.snapshot());
  check(resume.snapshot()==allowed.snapshot(),
        "STTR snapshot differs after restoration");
  resume.write(0x400a0000,ldtr,4);
  enter(resume,0xc0000ffc,0);
  resume.run(1);
  check(resume.registers().x[2]==payload&&resume.machine().exceptions==0,
        "LDTR failed to load from user pages");
  auto denied=MinimalGuest::from_snapshot(initial_state);
  denied.write(0x400a0000,ldtr,4);
  enter(denied,0xc0000ffc,0);denied.run(1);
  check(denied.machine().exceptions==1&&denied.machine().far==0xc0000ffc,
        "LDTR ignored user-read access permissions");
  check(MinimalGuest::from_snapshot(before_store).snapshot()==before_store,
        "User-access regression changed legacy RVG checkpoint encoding");
}

void eret_ssbs_saved_status(){
  // Independently assembled AArch64 sequence:
  // MOV X0,#0x1000; MSR SPSR_EL1,X0; load ELR_EL1=0x40080018;
  // ERET; NOP at the EL0 target. The bit 12 SPSR marker is SSBS.
  const std::uint32_t code[]{
    0xd2820000u,0xd5184000u,0xd2800301u,0xf2a80101u,
    0xd5184021u,0xd69f03e0u,0xd503201fu
  };
  auto image=system_demo_elf();image.resize(256);
  for(const auto instruction:code)put(image,instruction,4);
  for(unsigned i=0;i<8;++i){
    image[96+i]=std::uint8_t(std::uint64_t(sizeof(code))>>(8*i));
    image[104+i]=image[96+i];
  }
  MinimalGuest witness(128*1024*1024);witness.load_elf(image,true);
  const auto before=witness.snapshot();
  witness.run(5);
  check(witness.machine().spsr==0x1000&&witness.machine().el==1,
        "The SSBS ERET witness did not set its saved process status");
  const auto checkpoint=witness.snapshot();
  auto restored=MinimalGuest::from_snapshot(checkpoint);
  check(restored.snapshot()==checkpoint,"SPSR with SSBS flag altered RVG history");
  restored.run(1);
  check(restored.machine().el==0&&restored.registers().pc==0x40080018 &&
        restored.machine().spsr==0x1000,
        "SPSR.SSBS was not accepted for the actual EL0 exception return");
  check(restored.registers().sp==restored.machine().sp0,
        "SSBS return did not restore the EL0 stack");
  restored.run(1);
  check(restored.machine().el==0&&restored.registers().pc==0x4008001c,
        "Target EL0 instruction did not execute after ERET");
  // A genuinely unsupported SPSR bit must still fail atomically.
  auto invalid=image;
  constexpr std::uint32_t mov_reserved=0xd2840000u; // MOV X0,#0x2000: reserved bit 13
  for(unsigned i=0;i<4;++i)invalid[256+i]=std::uint8_t(mov_reserved>>(i*8));
  MinimalGuest bad(128*1024*1024);bad.load_elf(invalid,true);
  bad.run(5);const auto saved=bad.snapshot();
  fails([&]{bad.run(1);},"Reserved SPSR bits were silently permitted");
  check(bad.snapshot()==saved,"Failed ERET violated atomic rollback");
  check(MinimalGuest::from_snapshot(before).snapshot()==before,
        "Previous guest checkpoint was changed by SSBS support");
}
void identification(){
  auto image=system_demo_elf();image.resize(260);const std::uint32_t instruction=0xd53800c0; // MRS X0,REVIDR_EL1
  for(unsigned i=0;i<4;++i)image[256+i]=std::uint8_t(instruction>>(8*i));
  for(unsigned i=0;i<8;++i){image[96+i]=std::uint8_t(UINT64_C(4)>>(8*i));image[104+i]=image[96+i];}
  MinimalGuest guest(128*1024*1024);guest.load_elf(image,true);guest.run(1);
  check(guest.registers().x[0]==0&&guest.machine().exceptions==0,"Software implementation revision is not readable");
  for(auto id:{0xc024u,0xc025u}){
    const auto op=0xd5200000u|(id<<5);for(unsigned i=0;i<4;++i)image[256+i]=std::uint8_t(op>>(8*i));
    guest.load_elf(image,true);guest.run(1);check(guest.registers().x[0]==0,"Absent SVE/SME feature incorrectly advertised");
  }
}
void uart_fifo_configuration(){
  // The pinned Linux 6.1 kernel writes IFLS via STRH W8,[X9] (0x79000128).
  for(bool halfword:{false,true}){
    const std::uint32_t code[]{
      0xd2a12001,0x52800240,                 // X1=PL011, W0=0x12
      halfword?0x79006820u:0xb9003420u,     // STRH/STR W0,[X1,#0x34]
      halfword?0x79406822u:0xb9403422u,     // LDRH/LDR W2,[X1,#0x34]
      0xd2800100,0xf2b08000,0xd4000002     // PSCI SYSTEM_OFF
    };
    auto image=system_demo_elf();image.resize(256);
    for(auto instruction:code)put(image,instruction,4);
    for(unsigned i=0;i<8;++i){image[96+i]=std::uint8_t(std::uint64_t(sizeof(code))>>(8*i));image[104+i]=image[96+i];}
    MinimalGuest guest(128*1024*1024);guest.load_elf(image,true);
    const auto baseline=guest.snapshot();
    check(guest.machine().uart_ifls==0,"Legacy machine default IFLS changed");
    guest.run(4);
    check(guest.machine().uart_ifls==0x12&&guest.registers().x[2]==0x12,
          "PL011 halfword/word IFLS write/readback failed");
    check(guest.machine().save()[0]==3,"Configured PL011 did not version its machine checkpoint");
    const auto restored=MinimalGuest::from_snapshot(guest.snapshot());
    check(restored.machine().uart_ifls==0x12&&restored.snapshot()==guest.snapshot(),
          "PL011 IFLS checkpoint was not exact");
    auto finish=restored;
    check(finish.run(3).halted,"Configured PL011 guest failed to shut down");
    MinimalGuest legacy(128*1024*1024);legacy.load_elf(image,true);
    check(legacy.machine().save()[0]==2&&legacy.snapshot()==baseline,
          "Legacy machine checkpoint bytes changed");
    check(MinimalGuest::from_snapshot(legacy.snapshot()).snapshot()==legacy.snapshot(),
          "Legacy PL011 checkpoint changed");
    auto invalid=image;constexpr std::uint32_t reserved=0x528000e0; // MOV W0,#7
    for(unsigned i=0;i<4;++i)invalid[260+i]=std::uint8_t(reserved>>(8*i));
    MinimalGuest reject(128*1024*1024);reject.load_elf(invalid,true);reject.run(2);
    const auto before=reject.snapshot();
    fails([&]{reject.run(1);},"Reserved PL011 FIFO trigger accepted");
    check(reject.snapshot()==before,"Rejected PL011 configuration changed CPU/device state");
  }
}
void interrupt_priority_initialization(){
  auto image=system_demo_elf();image.resize(256);const std::uint32_t code[]{0xd2801a01,0xf2a10021,0xb900003f,0xb9400020,0xd2800020,0xb9000020};
  for(auto instruction:code)put(image,instruction,4);
  for(unsigned i=0;i<8;++i){image[96+i]=std::uint8_t(std::uint64_t(sizeof(code))>>(8*i));image[104+i]=image[96+i];}
  MinimalGuest guest(128*1024*1024);guest.load_elf(image,true);guest.run(5);
  check(guest.machine().active_irqs[0]==0&&guest.machine().active_irqs[1]==0,"APR initialization created active interrupts");
  const auto before=guest.snapshot();fails([&]{guest.run(1);},"Unimplemented manual active-priority write accepted");
  check(guest.snapshot()==before,"Rejected APR write changed CPU/device state");
}
}
int main(){try{boot_and_restore();translation();shared_quantum_authority();exclusives();image_boot_protocol();cross_page_access();unprivileged_memory_access();eret_ssbs_saved_status();identification();uart_fifo_configuration();interrupt_priority_initialization();
  std::cout<<"{\"checks\":"<<checks<<",\"system\":\"own-EL1-MMU-IRQ-EL0-SVC\",\"existing_quantum_qubits\":4096,\"android_boot\":\"not_implemented\"}\n";return 0;
}catch(const std::exception& error){std::cerr<<error.what()<<'\n';return 1;}}
