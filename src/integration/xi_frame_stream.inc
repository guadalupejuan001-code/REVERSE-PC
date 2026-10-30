// XI Frame Stream v1. Included inside mundo_x::infinite_program_detail.
// This code is a bounded binary TRANSPORT encoder, never a geometry or pixel
// renderer. Every drawable descriptor and ordering rule originate in XI.
// XFS1 packet: 40-byte header then 28-byte records (little endian).
// Header: magic(4), headerBytes(4), width(4), height(4), revision(8),
//         background ARGB(4), recordCount(4), FNV1a-64 checksum(8).
// Record: kind(4), a(4), b(4), c(4), d(4), ARGB(4), depth(4).
// kind=1: a=y,b=x0,c=x1,d=0 (inclusive span).
// kind=2: a=x,b=y,c=width,d=height (rectangular tile).
// Material is opaque 0xAARRGGBB color. Smaller depth wins; at equal depth,
// later records win. The host may expand records but cannot change geometry.
struct XIFrameStream {
  static constexpr std::size_t header_bytes=40, record_bytes=28;
  bool started=false,ended=false;
  std::uint32_t width=0,height=0,count=0;
  std::uint64_t revision=0;
  std::string bytes;

  static std::uint32_t u32(std::int64_t value,const char* field){
    if(value<0||static_cast<std::uint64_t>(value)>0xffffffffULL)
      throw std::out_of_range(std::string("frame stream ")+field+" outside uint32");
    return static_cast<std::uint32_t>(value);
  }
  static std::uint32_t positive(std::int64_t value,const char* field){
    const auto n=u32(value,field);
    if(n==0)throw std::out_of_range(std::string("frame stream ")+field+" must be positive");
    return n;
  }
  static std::uint64_t nonnegative(std::int64_t value,const char* field){
    if(value<0)throw std::out_of_range(std::string("frame stream ")+field+" must be nonnegative");
    return static_cast<std::uint64_t>(value);
  }
  void put32(std::uint32_t value){
    for(unsigned i=0;i<4;++i)bytes.push_back(static_cast<char>((value>>(i*8))&255u));
  }
  void put64(std::uint64_t value){
    for(unsigned i=0;i<8;++i)bytes.push_back(static_cast<char>((value>>(i*8))&255u));
  }
  void update32(std::size_t position,std::uint32_t value){
    for(unsigned i=0;i<4;++i)bytes[position+i]=static_cast<char>((value>>(i*8))&255u);
  }
  void update64(std::size_t position,std::uint64_t value){
    for(unsigned i=0;i<8;++i)bytes[position+i]=static_cast<char>((value>>(i*8))&255u);
  }
  void begin(std::int64_t raw_width,std::int64_t raw_height,
             std::int64_t raw_revision,std::int64_t raw_background){
    if(started)throw std::invalid_argument("frame stream already started");
    width=positive(raw_width,"width");height=positive(raw_height,"height");
    revision=nonnegative(raw_revision,"revision");
    const auto bg=u32(raw_background,"background ARGB");
    started=true;
    bytes.append("XFS1",4);put32(static_cast<std::uint32_t>(header_bytes));
    put32(width);put32(height);put64(revision);put32(bg);
    put32(0);put64(0);
  }
  void require_open()const{
    if(!started||ended)throw std::invalid_argument("frame stream is not open");
  }
  void put_record(std::uint32_t kind,std::uint32_t a,std::uint32_t b,
                  std::uint32_t c,std::uint32_t d,std::uint32_t argb,
                  std::uint32_t depth,std::size_t output_room){
    require_open();
    if(count==0xffffffffu)throw std::length_error("frame stream record counter overflow");
    // Control serialized output as well as raw bytes, including JSON overhead.
    const auto future=bytes.size()+record_bytes;
    if(output_room<256||4*((future+2)/3)>output_room-256)
      throw std::length_error("frame stream exceeds output transport budget");
    put32(kind);put32(a);put32(b);put32(c);put32(d);put32(argb);put32(depth);
    ++count;
  }
  void span(std::int64_t raw_y,std::int64_t raw_left,std::int64_t raw_right,
            std::int64_t raw_argb,std::int64_t raw_depth,
            std::size_t output_room){
    require_open();
    const auto y=u32(raw_y,"span y"),left=u32(raw_left,"span left");
    const auto right=u32(raw_right,"span right");
    const auto argb=u32(raw_argb,"span ARGB"),depth=u32(raw_depth,"span depth");
    if(y>=height||left>right||right>=width)
      throw std::out_of_range("frame span outside viewport");
    put_record(1,y,left,right,0,argb,depth,output_room);
  }
  void tile(std::int64_t raw_x,std::int64_t raw_y,
            std::int64_t raw_width,std::int64_t raw_height,
            std::int64_t raw_argb,std::int64_t raw_depth,
            std::size_t output_room){
    require_open();
    const auto x=u32(raw_x,"tile x"),y=u32(raw_y,"tile y");
    const auto w=positive(raw_width,"tile width"),h=positive(raw_height,"tile height");
    const auto argb=u32(raw_argb,"tile ARGB"),depth=u32(raw_depth,"tile depth");
    if(x>=width||y>=height||w>width-x||h>height-y)
      throw std::out_of_range("frame tile outside viewport");
    put_record(2,x,y,w,h,argb,depth,output_room);
  }
  static std::string base64(const std::string& source){
    constexpr char alphabet[]=
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    std::string out;
    out.reserve(4*((source.size()+2)/3));
    for(std::size_t i=0;i<source.size();i+=3){
      const auto a=static_cast<std::uint8_t>(source[i]);
      const bool two=i+1<source.size(),three=i+2<source.size();
      const auto b=two?static_cast<std::uint8_t>(source[i+1]):0u;
      const auto c=three?static_cast<std::uint8_t>(source[i+2]):0u;
      const auto packed=(std::uint32_t(a)<<16)|(std::uint32_t(b)<<8)|c;
      out.push_back(alphabet[(packed>>18)&63u]);
      out.push_back(alphabet[(packed>>12)&63u]);
      out.push_back(two?alphabet[(packed>>6)&63u]:'=');
      out.push_back(three?alphabet[packed&63u]:'=');
    }
    return out;
  }
  std::string finish(std::size_t output_room){
    require_open();
    update32(28,count);
    // Hash all packet bytes with the 8-byte checksum field set to zero.
    std::uint64_t digest=14695981039346656037ULL;
    for(std::size_t i=0;i<bytes.size();++i){
      const auto value=(i>=32&&i<40)?0u:static_cast<std::uint8_t>(bytes[i]);
      digest^=value;digest*=1099511628211ULL;
    }
    update64(32,digest);
    const auto b64=base64(bytes);
    const auto result=std::string("{\"type\":\"xi_frame_stream\",\"format\":\"XFS1\",\"encoding\":\"base64\",\"width\":")
      +std::to_string(width)+",\"height\":"+std::to_string(height)
      +",\"revision\":"+std::to_string(revision)
      +",\"records\":"+std::to_string(count)+",\"payload\":\""+b64+"\"}\n";
    if(result.size()>output_room)
      throw std::length_error("frame stream exceeds output transport budget");
    ended=true;
    return result;
  }
};
