// Included inside reverse_pc::guest after MinimalGuest's declaration.
inline bool MinimalGuest::fp_instruction(std::uint32_t i,std::uint64_t pc,RunResult& result){
  const unsigned rd=i&31,rn=(i>>5)&31,rm=(i>>16)&31,type=(i>>22)&3;
  const unsigned bits=type==0?32:type==1?64:type==3?16:0;
  auto scalar=[&](unsigned index){return floating_.v[index].lane(0,bits);};
  auto valid_float=[&](){return bits==32||bits==64;};
  auto word_size=[&](){const auto opcode=(i>>22)&3,size=i>>30;return opcode&2?(size==0?16u:0u):(1u<<size);};
  if((i&0xffe0fc00u)==0x5e000400u){ // DUP element to scalar B/H/S/D, including MOV Dd,Vn.D[index].
    const unsigned immediate=(i>>16)&31;if(!immediate)return false;
    unsigned size=0;while(!(immediate&(1u<<size)))++size;if(size>3)return false;
    const unsigned lane_bits=8u<<size,index=immediate>>(size+1);
    fp_access();const auto value=floating_.v[rn].lane(index,lane_bits);fp_set(rd,value,lane_bits);return true;
  }
  // LD1/ST1 multiple structures: one through four consecutive V registers,
  // no offset or post-index. Transfers use the encoded element size, so
  // unaligned byte structures do not inherit a 16-byte scalar alignment rule.
  if((i&0xbf200000u)==0x0c000000u){
    const bool post=i&0x00800000u,load=i&0x00400000u,wide=i&0x40000000u;
    const unsigned operation=(i>>12)&15,element_bytes=1u<<((i>>10)&3),vector_bytes=wide?16:8;
    const unsigned count=operation==7?1:operation==10?2:operation==6?3:operation==2?4:0;
    if(!count||(!post&&rm))return false;
    fp_access();const auto base=reg(rn,64,true),increment=post?(rm==31?std::uint64_t(count*vector_bytes):reg(rm)):0;
    std::array<Vector128,4> values{};
    for(unsigned n=0;n<count;n++)for(unsigned offset=0;offset<vector_bytes;offset+=element_bytes)
      check_access(base+std::uint64_t(n)*vector_bytes+offset,element_bytes,!load);
    if(load){
      for(unsigned n=0;n<count;n++)for(unsigned offset=0;offset<vector_bytes;offset+=element_bytes)
        values[n].lane(offset/element_bytes,element_bytes*8,cpu_read(base+std::uint64_t(n)*vector_bytes+offset,element_bytes,result));
      for(unsigned n=0;n<count;n++)floating_.v[(rd+n)&31]=values[n];
    }else{
      for(unsigned n=0;n<count;n++)values[n]=floating_.v[(rd+n)&31];
      for(unsigned n=0;n<count;n++)for(unsigned offset=0;offset<vector_bytes;offset+=element_bytes)
        cpu_write(base+std::uint64_t(n)*vector_bytes+offset,values[n].lane(offset/element_bytes,element_bytes*8),element_bytes,result);
    }
    if(post)set(rn,base+increment,64,true);return true;
  }
  // Scalar and Q memory operations use the same physical XI/Ether bytes.
  if((i&0x3b000000)==0x39000000 && (i&0x04000000)){
    const auto bytes=word_size();if(!bytes)return false;fp_access();
    const auto address=reg(rn,64,true)+std::uint64_t((i>>10)&4095)*bytes;
    if(i&0x00400000)floating_.v[rd]=fp_load(address,bytes,result);else fp_store(address,floating_.v[rd],bytes,result);return true;
  }
  if((i&0x3b000000)==0x18000000 && (i&0x04000000)){
    const auto opcode=i>>30;if(opcode==3)return false;fp_access();
    floating_.v[rd]=fp_load(pc+std::uint64_t(signed_field((i>>5)&0x7ffff,19))*4,4u<<opcode,result);return true;
  }
  if((i&0x3b200000)==0x38000000 && (i&0x04000000)){
    const auto bytes=word_size(),mode=(i>>10)&3;if(!bytes||mode==2)return false;fp_access();
    const auto base=reg(rn,64,true),updated=base+std::uint64_t(signed_field((i>>12)&511,9)),address=mode==1?base:updated;
    if(i&0x00400000)floating_.v[rd]=fp_load(address,bytes,result);else fp_store(address,floating_.v[rd],bytes,result);
    if(mode)set(rn,updated,64,true);return true;
  }
  if((i&0x3b200c00)==0x38200800 && (i&0x04000000)){
    const auto bytes=word_size(),option=(i>>13)&7;if(!bytes||!(option&2))return false;fp_access();
    auto offset=reg(rm,option&1?64:32);if(option==6&&(offset&0x80000000))offset|=UINT64_C(0xffffffff00000000);
    if(i&0x1000){unsigned scale=0;while((1u<<scale)<bytes)++scale;offset<<=scale;}
    const auto address=reg(rn,64,true)+offset;
    if(i&0x00400000)floating_.v[rd]=fp_load(address,bytes,result);else fp_store(address,floating_.v[rd],bytes,result);return true;
  }
  if((i&0x3a000000)==0x28000000 && (i&0x04000000)){
    const auto opcode=i>>30,second=(i>>10)&31,mode=(i>>23)&3;if(opcode==3)return false;
    const bool load=i&0x00400000;if(load&&rd==second)return false;fp_access();const unsigned bytes=4u<<opcode;
    const auto base=reg(rn,64,true),updated=base+std::uint64_t(signed_field((i>>15)&127,7))*bytes,address=mode==1?base:updated;
    check_access(address,bytes,!load);check_access(address+bytes,bytes,!load);
    if(load){const auto first=fp_load(address,bytes,result),last=fp_load(address+bytes,bytes,result);floating_.v[rd]=first;floating_.v[second]=last;}
    else{fp_store(address,floating_.v[rd],bytes,result);fp_store(address+bytes,floating_.v[second],bytes,result);}
    if(mode==1||mode==3)set(rn,updated,64,true);return true;
  }
  ArmFloat fp(floating_);
  if((i&0xff201fe0)==0x1e201000){ // FMOV immediate
    if(!valid_float())return false;fp_access();const unsigned imm=(i>>13)&255,e=bits==32?8:11,f=bits-e-1;
    const unsigned repeat=(imm>>6)&1;
    const auto exponent=(std::uint64_t(!repeat)<<(e-1))|(repeat?((UINT64_C(1)<<(e-3))-1)<<2:0)|((imm>>4)&3);
    fp_set(rd,(std::uint64_t(imm>>7)<<(bits-1))|(exponent<<f)|(std::uint64_t(imm&15)<<(f-4)),bits);return true;
  }
  if((i&0x7f20fc00)==0x1e200000){ // Integer/FP transfers and conversions
    const auto op=(i>>16)&7,mode=(i>>19)&3,integer_bits=(i>>31)?64u:32u;fp_access();
    if(op==6||op==7){
      if(mode==1&&type==2&&integer_bits==64){if(op==6)set(rd,floating_.v[rn].high);else floating_.v[rd].high=reg(rn);return true;}
      if(mode||!valid_float()||integer_bits!=bits)return false;
      if(op==6)set(rd,scalar(rn),integer_bits);else fp_set(rd,reg(rn,integer_bits),bits);return true;
    }
    if(!valid_float())return false;
    if(op==2||op==3){if(mode)return false;fp_set(rd,fp.from_int(bits,reg(rn,integer_bits),op==2,integer_bits),bits);return true;}
    if(op==0||op==1||op==4||op==5){
      if(op>=4&&mode)return false;const unsigned rounds[]{softfloat_round_near_even,softfloat_round_max,softfloat_round_min,softfloat_round_minMag};
      set(rd,fp.to_int(bits,scalar(rn),!(op&1),integer_bits,op>=4?unsigned(softfloat_round_near_maxMag):rounds[mode]),integer_bits);return true;
    }
    return false;
  }
  if((i&0xff200c00)==0x1e200800){ // FP two-source
    const auto operation=(i>>12)&15;if(!valid_float()||operation>8)return false;fp_access();fp_set(rd,fp.binary(operation,bits,scalar(rn),scalar(rm)),bits);return true;
  }
  if((i&0xff207c00)==0x1e204000){ // FP one-source, format conversion, rounding
    const auto operation=(i>>15)&63;fp_access();
    if(operation==4||operation==5||operation==7){const unsigned destination=operation==4?32:operation==5?64:16;
      if(!bits||bits==destination)return false;const auto value=fp.convert(bits,destination,scalar(rn));fp_set(rd,value,destination);return true;}
    if(!valid_float())return false;auto value=scalar(rn);
    if(operation==0)fp_set(rd,value,bits);
    else if(operation==1)fp_set(rd,value&~ArmFloat::sign(bits),bits);
    else if(operation==2)fp_set(rd,value^ArmFloat::sign(bits),bits);
    else if(operation==3)fp_set(rd,fp.sqrt(bits,value),bits);
    else if(operation>=8&&operation<=15&&operation!=13){
      const unsigned rounds[]{softfloat_round_near_even,softfloat_round_max,softfloat_round_min,softfloat_round_minMag,softfloat_round_near_maxMag};
      fp_set(rd,fp.round_integral(bits,value,operation<=12?rounds[operation-8]:fp.rounding(),operation==14),bits);
    }else return false;return true;
  }
  if((i&0xff20fc07)==0x1e202000){ // FCMP/FCMPE, register or zero
    if(!valid_float()||((i&8)&&rm))return false;fp_access();registers_.nzcv=fp.compare(bits,scalar(rn),i&8?0:scalar(rm),bool(i&16));return true;
  }
  if((i&0xff200c00)==0x1e200400){ // FCCMP/FCCMPE
    if(!valid_float())return false;fp_access();registers_.nzcv=condition((i>>12)&15)?fp.compare(bits,scalar(rn),scalar(rm),bool(i&16)):i&15;return true;
  }
  if((i&0xff200c00)==0x1e200c00){ // FCSEL preserves raw source bits, raises no FP arithmetic flags.
    if(!valid_float())return false;fp_access();fp_set(rd,scalar(condition((i>>12)&15)?rn:rm),bits);return true;
  }
  if((i&0xff000000)==0x1f000000){ // FMADD/FMSUB/FNMADD/FNMSUB
    if(!valid_float())return false;fp_access();const bool negative_addend=i&0x00200000,negative_product=negative_addend!=bool(i&0x8000);
    fp_set(rd,fp.fma(bits,scalar(rn),scalar(rm),scalar((i>>10)&31),negative_product,negative_addend),bits);return true;
  }
  const bool q=i&0x40000000,u=i&0x20000000;
  const unsigned width=q?128:64,size=(i>>22)&3,element=8u<<size;
  auto commit=[&](Vector128 value){if(!q)value.high=0;floating_.v[rd]=value;};
  const auto right_shift=[&](std::uint64_t x,unsigned amount,unsigned lane_bits,bool signed_value){
    const bool negative=signed_value&&bool(x&(UINT64_C(1)<<(lane_bits-1)));
    if(amount>=lane_bits)return negative?low_mask(lane_bits):UINT64_C(0);
    if(!amount)return x;
    return (x>>amount)|(negative?(low_mask(lane_bits)^low_mask(lane_bits-amount)):UINT64_C(0));
  };
  // immh=0000 selects modified immediates, not a reserved shift. Let the
  // MOVI/MVNI/ORR/BIC decoder below handle those shared opcode patterns.
  const bool shift_immediate=(i&0x00780000u)!=0;
  const auto immediate_shift=i&0x9f80fc00u;
  if(shift_immediate&&(immediate_shift==0x0f000400u||immediate_shift==0x0f005400u||(immediate_shift==0x0f004400u&&u))){ // S/USHR, SHL, SLI or SRI.
    const unsigned encoded=(i>>16)&127;if(encoded<8)return false;
    unsigned lane_bits=8;while(lane_bits*2<=encoded)lane_bits*=2;
    if(lane_bits==64&&!q)return false;
    const bool left=immediate_shift==0x0f005400u;
    const bool insert=(left&&u)||immediate_shift==0x0f004400u;
    const unsigned amount=left?encoded-lane_bits:2*lane_bits-encoded;
    fp_access();const auto source=floating_.v[rn],old=floating_.v[rd];Vector128 value;
    for(unsigned n=0;n<width/lane_bits;n++){
      const auto x=source.lane(n,lane_bits);
      auto result=left?x<<amount:right_shift(x,amount,lane_bits,!u);
      if(insert){const auto preserve=left?low_mask(amount):low_mask(lane_bits)^low_mask(lane_bits-amount);result|=old.lane(n,lane_bits)&preserve;}
      value.lane(n,lane_bits,result);
    }commit(value);return true;
  }
  if(shift_immediate&&immediate_shift==0x0f00a400u){ // SSHLL/USHLL and upper-half variants (SXTL/UXTL at shift zero).
    const unsigned encoded=(i>>16)&127;if(encoded>=64)return false; // immh[3] is reserved.
    unsigned narrow=8;while(narrow*2<=encoded)narrow*=2;
    const unsigned amount=encoded-narrow,lanes=64/narrow,first=q?lanes:0;
    fp_access();const auto source=floating_.v[rn];Vector128 value;
    for(unsigned n=0;n<lanes;n++){
      auto x=source.lane(first+n,narrow);
      if(!u&&(x&(UINT64_C(1)<<(narrow-1))))x|=~low_mask(narrow);
      value.lane(n,2*narrow,x<<amount); // Unsigned arithmetic also handles negative signed inputs without UB.
    }
    // Q selects the source half; the widened destination is always 128 bits.
    floating_.v[rd]=value;return true;
  }
  if((i&0x9f20fc00u)==0x0e204400u){ // SSHL/USHL: the signed low byte determines each lane's shift.
    if(size==3&&!q)return false;fp_access();const auto source=floating_.v[rn],shifts=floating_.v[rm];Vector128 value;
    for(unsigned n=0;n<width/element;n++){
      const auto x=source.lane(n,element);const unsigned byte=unsigned(shifts.lane(n,element)&255);
      const int amount=byte<128?int(byte):int(byte)-256;
      value.lane(n,element,amount<0?right_shift(x,unsigned(-amount),element,!u):unsigned(amount)>=element?0:x<<unsigned(amount));
    }commit(value);return true;
  }
  if((i&0xbf3ffc00u)==0x0e212800u){ // XTN/XTN2: truncate each lane to half its width, without saturation.
    if(size==3)return false; // size=11 is unallocated; reject before touching any state.
    fp_access();const auto source=floating_.v[rn];Vector128 value;
    for(unsigned n=0;n<64/element;n++)value.lane(n,element,source.lane(n,2*element));
    // Capture all source lanes first, including when Rd==Rn. Q selects the
    // destination half, not the source half; XTN2 preserves the old low 64 bits.
    if(q)floating_.v[rd].high=value.low;else floating_.v[rd]={value.low,0};return true;
  }
  if((i&0x9f3ffc00u)==0x0e202800u){ // SADDLP/UADDLP, widening pairwise addition.
    if(size==3)return false;fp_access();const auto source=floating_.v[rn];Vector128 value;
    for(unsigned n=0;n<width/(2*element);n++){
      auto x=source.lane(2*n,element),y=source.lane(2*n+1,element);
      if(!u){const auto sign=UINT64_C(1)<<(element-1);if(x&sign)x|=~low_mask(element);if(y&sign)y|=~low_mask(element);}
      value.lane(n,element*2,x+y);
    }commit(value);return true;
  }
  if(shift_immediate&&(i&0xbf80f400u)==0x0f008400u){ // SHRN/RSHRN and upper-half variants.
    const unsigned encoded=(i>>16)&127;if(encoded<8||encoded>=64)return false;
    unsigned narrow=8;while(narrow*2<=encoded)narrow*=2;
    const unsigned shift=2*narrow-encoded;const bool rounded=i&0x800;
    fp_access();const auto source=floating_.v[rn];Vector128 result;
    for(unsigned n=0;n<64/narrow;n++){
      const auto x=source.lane(n,2*narrow);
      const auto carry=rounded&&((x&((UINT64_C(1)<<shift)-1))>=(UINT64_C(1)<<(shift-1)));
      result.lane(n,narrow,(x>>shift)+unsigned(carry));
    }
    if(q)floating_.v[rd].high=result.low;else floating_.v[rd]={result.low,0};return true;
  }
  if((i&0xbf3ffc00u)==0x0e209800u){ // CMEQ vector, immediate zero.
    if(size==3&&!q)return false;fp_access();const auto source=floating_.v[rn];Vector128 value;
    for(unsigned n=0;n<width/element;n++)value.lane(n,element,source.lane(n,element)==0?UINT64_MAX:0);
    commit(value);return true;
  }
  const auto pairwise=i&0x9f20fc00u;
  if(pairwise==0x0e20bc00u||pairwise==0x0e20a400u||pairwise==0x0e20ac00u){ // ADDP, S/UMAXP, S/UMINP.
    const bool add=pairwise==0x0e20bc00u,minimum=pairwise==0x0e20ac00u;
    if((add&&u)||(size==3&&(!q||!add)))return false;
    fp_access();const auto a=floating_.v[rn],b=floating_.v[rm];Vector128 value;const unsigned lanes=width/element;
    for(unsigned n=0;n<lanes;n++){
      const auto& source=n<lanes/2?a:b;const auto at=(n%(lanes/2))*2;
      const auto x=source.lane(at,element),y=source.lane(at+1,element);
      const auto sign=UINT64_C(1)<<(element-1),xx=u?x:x^sign,yy=u?y:y^sign;
      value.lane(n,element,add?x+y:minimum?(xx<yy?x:y):(xx>yy?x:y));
    }commit(value);return true;
  }
  if((i&0x9f20fc00)==0x0e201c00){ // AND/BIC/ORR/ORN/EOR/BSL/BIT/BIF
    fp_access();const auto a=floating_.v[rn],b=floating_.v[rm],d=floating_.v[rd];Vector128 value;
    auto logic=[&](std::uint64_t x,std::uint64_t y,std::uint64_t old){
      if(!u){switch(size){case 0:return x&y;case 1:return x&~y;case 2:return x|y;default:return x|~y;}}
      switch(size){case 0:return x^y;case 1:return (old&x)|(~old&y);case 2:return (old&~y)|(x&y);default:return (old&y)|(x&~y);}
    };value.low=logic(a.low,b.low,d.low);value.high=logic(a.high,b.high,d.high);commit(value);return true;
  }
  const auto same=i&0x9f20fc00;
  if(same==0x0e208400||same==0x0e209c00||same==0x0e208c00||same==0x0e203400||same==0x0e203c00){
    if((element==64&&!q)||(same==0x0e209c00&&(u||size==3))||(same==0x0e208c00&&!u))return false;
    fp_access();const auto a=floating_.v[rn],b=floating_.v[rm];Vector128 value;
    for(unsigned lane=0;lane<width/element;++lane){const auto x=a.lane(lane,element),y=b.lane(lane,element);std::uint64_t out=0;
      if(same==0x0e208400)out=u?x-y:x+y;
      else if(same==0x0e209c00)out=x*y;
      else if(same==0x0e208c00)out=x==y?UINT64_MAX:0;
      else{const auto sign=UINT64_C(1)<<(element-1);const auto ordered_x=u?x:x^sign,ordered_y=u?y:y^sign;
        out=(same==0x0e203400?ordered_x>ordered_y:ordered_x>=ordered_y)?UINT64_MAX:0;}
      value.lane(lane,element,out);
    }commit(value);return true;
  }
  if((i&0x9fe08400)==0x0e000400){ // DUP/INS/UMOV/SMOV
    const auto imm5=(i>>16)&31,imm4=(i>>11)&15;if(!imm5)return false;
    unsigned shift=0;while(!(imm5&(1u<<shift)))++shift;const auto lane_bits=8u<<shift,index=imm5>>(shift+1);
    if(shift>3)return false;fp_access();const auto source=floating_.v[rn];auto value=floating_.v[rd];
    if(u){ // INS from a vector lane; source index has the same element size.
      if(!q||((i>>10)&1)==0||(imm4&((1u<<shift)-1)))return false;
      value.lane(index,lane_bits,source.lane(imm4>>shift,lane_bits));floating_.v[rd]=value;return true;
    }
    if(imm4==0||imm4==1){ // DUP from vector lane or general register.
      if(lane_bits==64&&!q)return false;if(imm4==1&&imm5!=(1u<<shift))return false;
      const auto repeated=imm4==1?reg(rn,lane_bits==64?64:32):source.lane(index,lane_bits);value={};
      for(unsigned n=0;n<width/lane_bits;++n)value.lane(n,lane_bits,repeated);commit(value);return true;
    }
    if(imm4==3){if(!q)return false;value.lane(index,lane_bits,reg(rn,lane_bits==64?64:32));floating_.v[rd]=value;return true;}
    if(imm4==5||imm4==7){ // Signed/unsigned extraction into W/X.
      if((imm4==7&&(lane_bits==64)!=q)||(imm4==5&&(lane_bits==64||(!q&&lane_bits==32))))return false;
      auto extracted=source.lane(index,lane_bits);
      if(imm4==5&&extracted&(UINT64_C(1)<<(lane_bits-1)))extracted|=~low_mask(lane_bits);
      set(rd,extracted,q?64:32);return true;
    }return false;
  }
  if((i&0x9ff80400)==0x0f000400){ // MOVI/MVNI/ORR/BIC vector immediate; FMOV vector immediate.
    const auto cmode=(i>>12)&15,imm=(((i>>16)&7)<<5)|((i>>5)&31);std::uint64_t expanded=0;
    if(cmode<8){const auto word=std::uint64_t(imm)<<(8*(cmode>>1));expanded=word|(word<<32);}
    else if(cmode<12){const auto half=std::uint64_t(imm)<<(8*((cmode>>1)&1));expanded=half|(half<<16)|(half<<32)|(half<<48);}
    else if(cmode==12||cmode==13){const unsigned shift=8*(cmode-11);const auto word=(std::uint64_t(imm)<<shift)|((UINT64_C(1)<<shift)-1);expanded=word|(word<<32);}
    else if(cmode==14){if(u){for(unsigned n=0;n<8;++n)if(imm&(1u<<n))expanded|=UINT64_C(255)<<(8*n);}
      else expanded=std::uint64_t(imm)*UINT64_C(0x0101010101010101);}
    else{if(u&&!q)return false;const unsigned e=u?11:8,f=u?52:23,repeat=(imm>>6)&1;
      const auto exp=(std::uint64_t(!repeat)<<(e-1))|(repeat?((UINT64_C(1)<<(e-3))-1)<<2:0)|((imm>>4)&3);
      expanded=(std::uint64_t(imm>>7)<<(u?63:31))|(exp<<f)|(std::uint64_t(imm&15)<<(f-4));if(!u)expanded|=expanded<<32;}
    fp_access();auto value=floating_.v[rd];
    if(cmode<12&&(cmode&1)){if(u){value.low&=~expanded;value.high&=~expanded;}else{value.low|=expanded;value.high|=expanded;}}
    else{if(u&&cmode<14)expanded=~expanded;value={expanded,expanded};}
    commit(value);return true;
  }
  if((i&0xbfe08400)==0x2e000000){ // EXT concatenates at byte offset; sources may alias the destination.
    const auto offset=(i>>11)&15,bytes=width/8;if(offset>=bytes)return false;fp_access();
    const auto a=floating_.v[rn],b=floating_.v[rm];Vector128 value;
    for(unsigned n=0;n<bytes;++n)value.lane(n,8,n+offset<bytes?a.lane(n+offset,8):b.lane(n+offset-bytes,8));commit(value);return true;
  }
  if((i&0xbf208c00)==0x0e000800){ // UZP/TRN/ZIP, either half.
    const auto operation=(i>>12)&7;if((operation&3)==0||(element==64&&!q))return false;fp_access();
    const auto a=floating_.v[rn],b=floating_.v[rm];const unsigned lanes=width/element,part=operation>>2;Vector128 value;
    for(unsigned n=0;n<lanes;++n){std::uint64_t out=0;
      if((operation&3)==1)out=n<lanes/2?a.lane(2*n+part,element):b.lane(2*(n-lanes/2)+part,element);
      else if((operation&3)==2)out=(n&1?b:a).lane((n/2)*2+part,element);
      else out=(n&1?b:a).lane(n/2+part*(lanes/2),element);
      value.lane(n,element,out);
    }commit(value);return true;
  }
  if((i&0xbfe08c00)==0x0e000000){ // TBL/TBX, one through four 128-bit table registers.
    const auto length=((i>>13)&3)+1;const bool extension=i&0x1000;fp_access();
    const auto indices=floating_.v[rm],old=floating_.v[rd];Vector128 value;
    for(unsigned n=0;n<width/8;++n){const auto index=unsigned(indices.lane(n,8));
      value.lane(n,8,index<16*length?floating_.v[(rn+index/16)&31].lane(index%16,8):extension?old.lane(n,8):0);}
    commit(value);return true;
  }
  if((i&0x9ffffc00)==0x0e205800){ // CNT or NOT, byte vectors.
    fp_access();const auto a=floating_.v[rn];Vector128 value;
    if(u)value={~a.low,~a.high};
    else for(unsigned n=0;n<width/8;n++){
      auto byte=a.lane(n,8);unsigned count=0;for(unsigned bit=0;bit<8;bit++)count+=unsigned((byte>>bit)&1);
      value.lane(n,8,count);
    }
    commit(value);return true;
  }
  const auto reverse=i&0xbf3ffc00u;
  if(reverse==0x0e200800u||reverse==0x2e200800u||reverse==0x0e201800u){ // REV64, REV32, REV16.
    const unsigned block_bits=reverse==0x0e200800u?64:reverse==0x2e200800u?32:16;
    if(element>=block_bits)return false;fp_access();const auto a=floating_.v[rn];Vector128 value;const auto per_word=block_bits/element;
    for(unsigned n=0;n<width/element;++n)value.lane(n,element,a.lane((n/per_word)*per_word+per_word-1-n%per_word,element));commit(value);return true;
  }
  if((i&0xbf3ffc00)==0x0e31b800){ // ADDV
    if(size==3||(size==2&&!q))return false;fp_access();const auto a=floating_.v[rn];std::uint64_t total=0;
    for(unsigned n=0;n<width/element;++n)total+=a.lane(n,element);fp_set(rd,total,element);return true;
  }
  const auto vector_fp=i&0xbf20fc00;const unsigned fp_bits=(i&0x00400000)?64:32;
  if(vector_fp==0x0e20d400||vector_fp==0x2e20dc00||vector_fp==0x2e20fc00||vector_fp==0x0e20cc00||
     vector_fp==0x0e20f400||vector_fp==0x0e20c400||vector_fp==0x0e20e400||vector_fp==0x2e20e400||vector_fp==0x2e20ec00){
    if(fp_bits==64&&!q)return false;fp_access();const auto a=floating_.v[rn],b=floating_.v[rm],old=floating_.v[rd];Vector128 value;
    const bool variant=i&0x00800000;
    for(unsigned n=0;n<width/fp_bits;++n){const auto x=a.lane(n,fp_bits),y=b.lane(n,fp_bits);std::uint64_t out;
      if(vector_fp==0x0e20d400)out=fp.binary(variant?3:2,fp_bits,x,y);
      else if(vector_fp==0x2e20dc00){if(variant)return false;out=fp.binary(0,fp_bits,x,y);}
      else if(vector_fp==0x2e20fc00){if(variant)return false;out=fp.binary(1,fp_bits,x,y);}
      else if(vector_fp==0x0e20cc00)out=fp.fma(fp_bits,x,y,old.lane(n,fp_bits),variant,false);
      else if(vector_fp==0x0e20f400||vector_fp==0x0e20c400)out=fp.binary((vector_fp==0x0e20c400?6u:4u)+unsigned(variant),fp_bits,x,y);
      else{ // FCMEQ/FCMGE/FCMGT and absolute comparisons. Unordered always yields false.
        const bool absolute=vector_fp==0x2e20ec00;const auto xx=absolute?x&~ArmFloat::sign(fp_bits):x,yy=absolute?y&~ArmFloat::sign(fp_bits):y;
        const auto flags=fp.compare(fp_bits,xx,yy,vector_fp!=0x0e20e400);
        bool yes=vector_fp==0x0e20e400?flags==6:variant?flags==2:flags==2||flags==6;out=yes?UINT64_MAX:0;
      }value.lane(n,fp_bits,out);
    }commit(value);return true;
  }
  const auto vector_unary=i&0xbfbffc00;
  if(vector_unary==0x2ea1f800||vector_unary==0x0ea0f800||vector_unary==0x2ea0f800){ // FSQRT/FABS/FNEG
    if(fp_bits==64&&!q)return false;fp_access();const auto a=floating_.v[rn];Vector128 value;
    for(unsigned n=0;n<width/fp_bits;++n){const auto x=a.lane(n,fp_bits);
      value.lane(n,fp_bits,vector_unary==0x2ea1f800?fp.sqrt(fp_bits,x):vector_unary==0x0ea0f800?x&~ArmFloat::sign(fp_bits):x^ArmFloat::sign(fp_bits));}
    commit(value);return true;
  }
  return false;
}
