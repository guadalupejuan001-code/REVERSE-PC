  // MXIM3 is emitted only by the explicitly unbounded adaptive profile.
  // Historical bounded MXIM1/MXIM2 snapshots retain their exact bytes.
  std::string adaptive_snapshot() const {
    const auto hex_bytes=[](const std::string& bytes){
      constexpr char digits[]="0123456789abcdef";
      std::string out;out.reserve(bytes.size()*2);
      for(unsigned char c:bytes){out.push_back(digits[c>>4]);out.push_back(digits[c&15]);}
      return out;
    };
    std::ostringstream out;out.imbue(std::locale::classic());
    out<<"MXIM3 "<<unsigned(background_)<<'\n';
    overrides_->for_each_page_record([&](std::uint64_t page,
                                           const std::string& bitmap,
                                           const std::string& values){
      out<<"P "<<page<<' '<<hex_bytes(bitmap)<<' '<<hex_bytes(values)<<'\n';
    });
    overrides_->for_each_large_address([&](const auto& entry){
      out<<"O "<<entry.first<<' '<<unsigned(entry.second)<<'\n';
    });
    bindings_->for_each_sorted([&](const auto& entry){
      out<<"Q "<<entry.first<<' '<<entry.second<<'\n';
    });
    return out.str();
  }
  static InverseMemory from_adaptive_snapshot(const std::string& saved,Limits limits){
    const auto unhex=[](const std::string& hex,std::size_t maximum){
      if((hex.size()&1)||hex.size()>maximum*2)
        throw std::invalid_argument("Invalid adaptive Ether hex extent");
      auto nibble=[](char ch)->unsigned{
        if(ch>='0'&&ch<='9')return unsigned(ch-'0');
        if(ch>='a'&&ch<='f')return unsigned(ch-'a'+10);
        throw std::invalid_argument("Invalid adaptive Ether hex digit");
      };
      std::string bytes;bytes.reserve(hex.size()/2);
      for(std::size_t i=0;i<hex.size();i+=2)
        bytes.push_back(char((nibble(hex[i])<<4)|nibble(hex[i+1])));
      return bytes;
    };
    std::istringstream input(saved);input.imbue(std::locale::classic());
    std::string magic,background;
    if(!(input>>magic>>background)||magic!="MXIM3")
      throw std::invalid_argument("Malformed adaptive Ether snapshot");
    InverseMemory result(byte_value(background,"Inverse Memory background"),limits);
    std::string kind,address,payload,extra;
    while(input>>kind>>address>>payload){
      if(kind=="P"){
        if(!(input>>extra))throw std::invalid_argument("Truncated adaptive Ether page");
        std::uint64_t page=0;
        const auto parsed=std::from_chars(address.data(),address.data()+address.size(),page);
        if(parsed.ec!=std::errc()||parsed.ptr!=address.data()+address.size()||
           (address.size()>1&&address[0]=='0'))
          throw std::invalid_argument("Invalid adaptive Ether page number");
        result.overrides_->load_page_record(page,unhex(payload,512),unhex(extra,4096));
        if(limits.max_overrides&&result.overrides_->size()>limits.max_overrides)
          throw std::length_error("Adaptive Ether snapshot override budget exceeded");
      }else if(kind=="O"){
        const auto canonical=result.canonical(address);
        if(!result.overrides_->insert(canonical,byte_value(payload,"Inverse Memory byte")))
          throw std::invalid_argument("Duplicate adaptive Ether override");
        if(limits.max_overrides&&result.overrides_->size()>limits.max_overrides)
          throw std::length_error("Adaptive Ether snapshot override budget exceeded");
      }else if(kind=="Q"){
        const auto canonical=result.canonical(address);
        const auto base=infinite_detail::canonical_address(payload,limits.max_address_digits);
        (void)add_small(base,7,limits.max_address_digits);
        if(result.bindings_->size()==limits.max_quantum_bindings)
          throw std::length_error("Adaptive Ether snapshot quantum binding budget exceeded");
        if(!result.bindings_->insert(canonical,base))
          throw std::invalid_argument("Duplicate adaptive Ether quantum binding");
      }else throw std::invalid_argument("Unknown adaptive Ether snapshot record");
    }
    if(!input.eof())throw std::invalid_argument("Malformed adaptive Ether record stream");
    return result;
  }
