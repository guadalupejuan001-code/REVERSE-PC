// Included inside the XI machine owner's namespace. No game equations live here.
// Generic, bounded screen-space triangle coverage with perspective-correct 1/z.
class MachineMeshRaster {
 public:
  static constexpr std::uint16_t max_width = 640, max_height = 360;
  static constexpr std::size_t max_triangles = 4096;
  static constexpr std::size_t max_vertices = 4096;
  static constexpr unsigned max_textures = 8, texture_side = 16;
  // Revision 5: complete XI-owned pixels. It is not XFG4 GPU geometry.
  // Screens up to 3840x2160 are supported by strip rasterization. The older
  // revision 2 and geometry-capture revision 4 remain byte-compatible.
  static constexpr std::uint16_t native_width = 3840, native_height = 2160;
  static constexpr unsigned native_rows_per_strip = 32;
  // Conservative per-region candidates inspired by EtherRenderSpatial.
  // Faces remain authoritative XI; this only removes impossible pixel tests.
  static constexpr unsigned spatial_tile_width = 32;
  static constexpr unsigned spatial_tile_columns = (native_width+spatial_tile_width-1)/spatial_tile_width;
  static constexpr std::size_t native_max_triangles = 32768;
  static constexpr std::size_t native_max_vertices = 16384;
  static constexpr unsigned native_max_textures = 16;
  static constexpr std::uint16_t gpu_width = 3840, gpu_height = 2160;
  static constexpr std::size_t gpu_max_faces = max_triangles*2;
  static constexpr std::uint64_t max_pixel_tests = 8000000;
  // A valid visibility row may alternate material at every pixel. This natural
  // bound encodes every raster image; it must not reject a detailed scene.
  static constexpr unsigned max_foreground_runs = max_width;
  struct Vertex { std::int64_t x, y, z; };
  struct Texcoord { std::int64_t u, v; };
  struct DeferredFace {
    std::array<Vertex,3> p;
    std::array<Texcoord,3> uv;
    std::array<std::uint16_t,3> shades;
    std::int64_t material;
    unsigned count,texture,strength;
    bool gradient,textured;
  };
  struct GpuFace {
    std::array<Vertex,3> p;
    std::array<Texcoord,3> uv;
    std::array<std::uint16_t,3> shade;
    std::uint8_t base,count,texture,strength;
  };

  void begin(std::int64_t width, std::int64_t height,
             std::int64_t revision, std::int64_t background) {
    const bool capture=revision==4;
    const bool native=revision==5;
    if (width < 1 || height < 1 ||
        (capture ? (width!=gpu_width || height!=gpu_height)
          : native ? (width>native_width || height>native_height)
                   : (width>max_width || height>max_height)) ||
        revision < 0 || revision > std::numeric_limits<std::uint32_t>::max() ||
        background < 0 || background > 255)
      throw std::out_of_range("invalid XI mesh dimensions, revision or background");
    gpu_capture_=capture; native_tiled_=native;gpu_faces_.clear();
    deferred_faces_.clear();tile_collecting_=native;tile_row_start_=0;
    tile_row_end_=static_cast<unsigned>(height);
    width_ = static_cast<std::uint16_t>(width);
    height_ = static_cast<std::uint16_t>(height);
    revision_ = static_cast<std::uint32_t>(revision);
    background_ = static_cast<std::uint8_t>(background);
    triangles_ = 0; pixel_tests_ = 0;
    // Deferred 4K: never allocate an 8.3 Mpx 64-bit depth buffer. Only one
    // 32-row scan strip plus the final compact XFB5 image is materialized.
    materials_.assign(gpu_capture_||native?1:std::size_t(width_)*height_,background_);
    inverse_depth_.assign(materials_.size(),0);
    const auto capacity=native?native_max_vertices:max_vertices;
    vertices_.assign(capacity,Vertex{0,0,0});
    vertex_ready_.assign(capacity,0);
    vertex_shades_.assign(capacity,0);
    texcoords_.assign(capacity,Texcoord{0,0});
    texcoord_ready_.assign(capacity,0);
    texture_row_mask_.fill(0);
  }

  // XI computes/authors/transforms each distinct camera vertex once. Indexed
  // faces reuse those observations; no world or game equation is introduced.
  void vertex(std::int64_t id,Vertex value) {
    if(materials_.empty())throw std::invalid_argument("meshvertex without meshbegin");
    validate_vertex_id(id);
    if(value.x < -1000000 || value.x>1000000 || value.y < -1000000 || value.y>1000000 ||
       value.z < -1000000 || value.z>1000000)
      throw std::out_of_range("camera-space mesh vertex exceeds bounds");
    vertices_[static_cast<std::size_t>(id)]=value;
    vertex_ready_[static_cast<std::size_t>(id)]=1;
    vertex_shades_[static_cast<std::size_t>(id)]=0;
    texcoord_ready_[static_cast<std::size_t>(id)]=0;
  }

  // Lighting remains an XI calculation. This is a generic scalar attribute,
  // retained at Q8 precision through near clipping and perspective sampling.
  void shade(std::int64_t id,std::int64_t intensity) {
    (void)read(id);
    if(intensity<0 || intensity>255)
      throw std::out_of_range("mesh intensity must be in 0..255");
    vertex_shades_[static_cast<std::size_t>(id)]=static_cast<std::uint16_t>(intensity*256);
  }


  // A bounded 16x16, four-bit tile atlas is authored by XI, not a second
  // shader/game-state authority. Rows are literal lowercase hex characters.
  void texture_row(std::int64_t tile,std::int64_t row,const std::string& hex) {
    if(materials_.empty())throw std::invalid_argument("meshtexrow without meshbegin");
    if(tile<0 || tile>=(native_tiled_?native_max_textures:max_textures) || row<0 || row>=texture_side ||
       hex.size()!=texture_side)
      throw std::out_of_range("invalid XI 16x16 texture tile/row");
    const auto t=static_cast<unsigned>(tile),y=static_cast<unsigned>(row);
    if(texture_row_mask_[t]&(1U<<y))throw std::invalid_argument("duplicate XI texture row");
    std::array<std::uint8_t,texture_side> decoded{};
    for(unsigned x=0;x<texture_side;++x) {
      const char c=hex[x];
      if(c<'0'||(c>'9'&&c<'a')||c>'f')
        throw std::invalid_argument("XI texture texels must be lowercase hex nibbles");
      decoded[x]=static_cast<std::uint8_t>(c<='9'?c-'0':c-'a'+10);
    }
    for(unsigned x=0;x<texture_side;++x)textures_[t][y*texture_side+x]=decoded[x];
    texture_row_mask_[t]=static_cast<std::uint16_t>(texture_row_mask_[t]|(1U<<y));
  }

  void texcoord(std::int64_t id,std::int64_t u,std::int64_t v) {
    (void)read(id);
    if(u<-32768 || u>32767 || v<-32768 || v>32767)
      throw std::out_of_range("XI mesh UV coordinate exceeds bound");
    texcoords_[static_cast<std::size_t>(id)]={u,v};
    texcoord_ready_[static_cast<std::size_t>(id)]=1;
  }

  void copy_texcoord(std::int64_t target,std::int64_t original) {
    (void)read(target);(void)read(original);
    if(!texcoord_ready_[static_cast<std::size_t>(original)])
      throw std::invalid_argument("meshtexcopy source UV unset");
    texcoords_[static_cast<std::size_t>(target)]=texcoords_[static_cast<std::size_t>(original)];
    texcoord_ready_[static_cast<std::size_t>(target)]=1;
  }

  // Perspective-correct UV + interpolated XI lighting -> existing XFS1
  // palette indexes. Does not alter the physical world or scene positions.
  void textured_gradient_face(std::int64_t a,std::int64_t b,std::int64_t c,
                              std::int64_t base,std::int64_t count,
                              std::int64_t tile,std::int64_t strength,
                              std::int64_t focal,std::int64_t cx,
                              std::int64_t cy,std::int64_t near_plane) {
    validate_material(base);
    if(count<2 || count>256 || base+count>256)
      throw std::out_of_range("XI textured ramp outside 8-bit palette");
    if(tile<0 || tile>=(native_tiled_?native_max_textures:max_textures) || strength<1 || strength>16)
      throw std::out_of_range("XI texture tile or strength out of bounds");
    if(texture_row_mask_[static_cast<unsigned>(tile)]!=0xffffU)
      throw std::invalid_argument("XI texture tile rows incomplete");
    const auto va=read(a),vb=read(b),vc=read(c);
    const std::array<std::int64_t,3> ids{{a,b,c}};
    for(auto id:ids)if(!texcoord_ready_[static_cast<std::size_t>(id)])
      throw std::invalid_argument("meshfacegradienttex requires assigned UV coordinates");
    triangle3_impl<true,true>(va,vb,vc,base,focal,cx,cy,near_plane,
      {{vertex_shades_[static_cast<std::size_t>(a)],
        vertex_shades_[static_cast<std::size_t>(b)],
        vertex_shades_[static_cast<std::size_t>(c)]}},
      static_cast<unsigned>(count),
      {{texcoords_[static_cast<std::size_t>(a)],
        texcoords_[static_cast<std::size_t>(b)],
        texcoords_[static_cast<std::size_t>(c)]}},
      static_cast<unsigned>(tile),static_cast<unsigned>(strength));
  }

  void gradient_face(std::int64_t a,std::int64_t b,std::int64_t c,std::int64_t base,
                     std::int64_t ramp_count,std::int64_t focal,std::int64_t center_x,
                     std::int64_t center_y,std::int64_t near_plane) {
    const auto va=read(a),vb=read(b),vc=read(c);
    validate_material(base);
    if(ramp_count<1 || ramp_count>256 || base+ramp_count>256)
      throw std::out_of_range("mesh palette ramp must fit material range 0..255");
    if(ramp_count==1) { triangle3(va,vb,vc,base,focal,center_x,center_y,near_plane);return; }
    triangle3_impl<true>(va,vb,vc,base,focal,center_x,center_y,near_plane,
      {{vertex_shades_[static_cast<std::size_t>(a)],vertex_shades_[static_cast<std::size_t>(b)],
        vertex_shades_[static_cast<std::size_t>(c)]}},static_cast<unsigned>(ramp_count));
  }

  void face(std::int64_t a,std::int64_t b,std::int64_t c,std::int64_t material,
            std::int64_t focal,std::int64_t center_x,std::int64_t center_y,
            std::int64_t near_plane) {
    if(materials_.empty())throw std::invalid_argument("meshface without meshbegin");
    for(const auto id:{a,b,c}) {
      validate_vertex_id(id);
      if(!vertex_ready_[static_cast<std::size_t>(id)])
        throw std::invalid_argument("meshface references an unset vertex");
    }
    triangle3(vertices_[static_cast<std::size_t>(a)],vertices_[static_cast<std::size_t>(b)],
              vertices_[static_cast<std::size_t>(c)],material,focal,center_x,center_y,near_plane);
  }

  Vertex read(std::int64_t id) const {
    if(materials_.empty())throw std::invalid_argument("meshread without meshbegin");
    validate_vertex_id(id);
    if(!vertex_ready_[static_cast<std::size_t>(id)])
      throw std::invalid_argument("meshread references an unset vertex");
    return vertices_[static_cast<std::size_t>(id)];
  }

  void triangle(Vertex a, Vertex b, Vertex c, std::int64_t material) {
    validate_material(material);
    for (const Vertex v : {a, b, c})
      if (v.x < -32768 || v.x > 32768 || v.y < -32768 || v.y > 32768 ||
          v.z < 1 || v.z > 1000000)
        throw std::out_of_range("mesh vertex exceeds screen/positive-depth bounds");
    count_triangle();
    raster<false>(a,b,c,material);
  }

  // XI supplies the camera transform. This primitive clips the near plane and
  // projects the resulting polygon before using the same coverage/z buffer.
  void triangle3(Vertex a, Vertex b, Vertex c, std::int64_t material,
                 std::int64_t focal,std::int64_t center_x,std::int64_t center_y,
                 std::int64_t near_plane) {
    triangle3_impl<false>(a,b,c,material,focal,center_x,center_y,near_plane,{},1);
  }

 private:
  template<bool Gradient,bool Textured=false>
  void triangle3_impl(Vertex a,Vertex b,Vertex c,std::int64_t material,
                      std::int64_t focal,std::int64_t center_x,std::int64_t center_y,
                      std::int64_t near_plane,std::array<std::uint16_t,3> intensities,
                      unsigned ramp_count,std::array<Texcoord,3> coords={},
                      unsigned texture_id=0,unsigned texture_strength=0) {
    validate_material(material);
    if(focal<1 || focal>((gpu_capture_||native_tiled_)?8192:2048) || center_x < -32768 || center_x>32768 ||
       center_y < -32768 || center_y>32768 || near_plane<1 || near_plane>10000)
      throw std::out_of_range("invalid XI mesh camera projection");
    for(const Vertex v:{a,b,c})
      if(v.x < -1000000 || v.x>1000000 || v.y < -1000000 || v.y>1000000 ||
         v.z < -1000000 || v.z>1000000)
        throw std::out_of_range("camera-space mesh vertex exceeds bounds");
    count_triangle();
    std::array<Vertex,4> clipped{};
    std::array<std::uint16_t,4> clipped_intensities{};
    std::array<Texcoord,4> clipped_coords{};
    unsigned count=0;
    const std::array<Vertex,3> input{{a,b,c}};
    Vertex previous=c;
    std::uint16_t previous_intensity=0;
    if constexpr(Gradient)previous_intensity=intensities[2];
    Texcoord previous_uv{};
    if constexpr(Textured)previous_uv=coords[2];
    for(unsigned vertex_index=0;vertex_index<3;++vertex_index) {
      const Vertex current=input[vertex_index];
      const bool inside=current.z>=near_plane,was_inside=previous.z>=near_plane;
      if(inside!=was_inside) {
        const auto da=previous.z-near_plane,db=current.z-near_plane;
        const auto denominator=da-db;
        // Symmetric weighted form gives the same integer intersection when
        // adjacent triangles traverse their shared edge in opposite directions.
        clipped[count]={
          static_cast<std::int64_t>((__int128(current.x)*da-__int128(previous.x)*db)/denominator),
          static_cast<std::int64_t>((__int128(current.y)*da-__int128(previous.y)*db)/denominator),
          near_plane};
        if constexpr(Gradient) {
          auto numerator=__int128(intensities[vertex_index])*da-__int128(previous_intensity)*db;
          auto positive_denominator=denominator;
          if(positive_denominator<0) { positive_denominator=-positive_denominator;numerator=-numerator; }
          // Round to the nearest 1/256 intensity; the symmetric weighted form
          // agrees when adjacent faces traverse the same edge oppositely.
          clipped_intensities[count]=static_cast<std::uint16_t>(
            (numerator+positive_denominator/2)/positive_denominator);
        }
        if constexpr(Textured) {
          clipped_coords[count].u=static_cast<std::int64_t>(
            (__int128(coords[vertex_index].u)*da-__int128(previous_uv.u)*db)/denominator);
          clipped_coords[count].v=static_cast<std::int64_t>(
            (__int128(coords[vertex_index].v)*da-__int128(previous_uv.v)*db)/denominator);
        }
        ++count;
      }
      if(inside) {
        clipped[count]=current;
        if constexpr(Gradient)clipped_intensities[count]=intensities[vertex_index];
        if constexpr(Textured)clipped_coords[count]=coords[vertex_index];
        ++count;
      }
      previous=current;
      if constexpr(Gradient)previous_intensity=intensities[vertex_index];
      if constexpr(Textured)previous_uv=coords[vertex_index];
    }
    if(count<3)return;
    for(unsigned i=0;i<count;++i) {
      clipped[i].x=center_x+clipped[i].x*focal/clipped[i].z;
      clipped[i].y=center_y-clipped[i].y*focal/clipped[i].z;
    }
    for(unsigned i=1;i+1<count;++i) {
      if constexpr(Textured)
        raster<true,true>(clipped[0],clipped[i],clipped[i+1],material,
          {{clipped_intensities[0],clipped_intensities[i],clipped_intensities[i+1]}},
          ramp_count,{{clipped_coords[0],clipped_coords[i],clipped_coords[i+1]}},
          texture_id,texture_strength);
      else if constexpr(Gradient)
        raster<true>(clipped[0],clipped[i],clipped[i+1],material,
          {{clipped_intensities[0],clipped_intensities[i],clipped_intensities[i+1]}},ramp_count);
      else raster<false>(clipped[0],clipped[i],clipped[i+1],material);
    }
  }

 private:
  void validate_vertex_id(std::int64_t id) const {
    if(id<0 || id>=static_cast<std::int64_t>(native_tiled_?native_max_vertices:max_vertices))
      throw std::out_of_range(native_tiled_?
        "XI native mesh vertex id out of range (0..16383)":
        "mesh vertex id must be in 0..4095");
  }
  void validate_material(std::int64_t material) const {
    if (materials_.empty()) throw std::invalid_argument("mesh triangle without meshbegin");
    if (material < 0 || material > 255)
      throw std::out_of_range("mesh material must be in 0..255");
  }
  void count_triangle() {
    if (triangles_ >= (native_tiled_?native_max_triangles:max_triangles))
      throw std::length_error("XI mesh triangle budget exceeded");
    ++triangles_;
  }
  template<bool Gradient,bool Textured=false>
  void raster(Vertex a,Vertex b,Vertex c,std::int64_t material,
              std::array<std::uint16_t,3> intensities={},unsigned ramp_count=1,
              std::array<Texcoord,3> coords={},unsigned texture_id=0,
              unsigned texture_strength=0) {
    if(native_tiled_ && tile_collecting_) {
      if(!edge(a,b,c.x,c.y))return;
      if(deferred_faces_.size()>=native_max_triangles*2)
        throw std::length_error("XI native face budget exceeded");
      deferred_faces_.push_back({{{a,b,c}},coords,intensities,material,
        ramp_count,texture_id,texture_strength,Gradient,Textured});
      return;
    }
    if(gpu_capture_) {
      if(!edge(a,b,c.x,c.y))return;
      if(gpu_faces_.size()>=gpu_max_faces)
        throw std::length_error("XI 4K GPU triangle transport budget exceeded");
      GpuFace face{{{a,b,c}},coords,intensities,
        static_cast<std::uint8_t>(material),
        static_cast<std::uint8_t>(Gradient?ramp_count:1),
        static_cast<std::uint8_t>(Textured?texture_id:0),
        static_cast<std::uint8_t>(Textured?texture_strength:0)};
      gpu_faces_.push_back(face);return;
    }
    // Pixel centers are half-integers. Doubled screen coordinates make the
    // top-left fill convention exact and avoid floating-point edge cracks.
    a.x *= 2; a.y *= 2; b.x *= 2; b.y *= 2; c.x *= 2; c.y *= 2;
    auto area = edge(a, b, c.x, c.y);
    if (!area) return;
    if (area < 0) {
      std::swap(b,c);area=-area;
      if constexpr(Gradient)std::swap(intensities[1],intensities[2]);
      if constexpr(Textured)std::swap(coords[1],coords[2]);
    }
    const auto left = std::max<std::int64_t>(0, std::min({a.x, b.x, c.x}) / 2);
    const auto right = std::min<std::int64_t>(width_ - 1, std::max({a.x, b.x, c.x}) / 2);
    const auto top = std::max<std::int64_t>(tile_row_start_, std::min({a.y, b.y, c.y}) / 2);
    const auto bottom = std::min<std::int64_t>(tile_row_end_ - 1, std::max({a.y, b.y, c.y}) / 2);
    if (left > right || top > bottom) return;
    // Ether's spatial principle, translated to XI's exact top-left triangle
    // raster: reject a 32x32 tile only when one oriented triangle edge is
    // strictly outside every pixel center in its rectangle. Since edge
    // functions are affine, their maximum lies at one of the four corners.
    // A conservative tile rejection therefore cannot remove a visible pixel.
    // Keep small faces on the original direct path: indexing costs more there.
    std::array<std::uint8_t,spatial_tile_columns> candidates{};
    // Compile-time reference switch exists only to verify pixel-level parity
    // with the previous XI renderer. The production build keeps this enabled.
#ifdef REGRAPHICS_DISABLE_SPATIAL_CANDIDATES
    const bool use_spatial = false;
#else
    const bool use_spatial = native_tiled_ && !tile_collecting_ &&
      right-left>=128 && bottom-top>=8;
#endif
    std::uint64_t eligible_columns=0;
    if(use_spatial){
      const std::array<Vertex,3> triangle{{a,b,c}};
      const std::array<bool,3> inclusive{{top_left(b,c),top_left(c,a),top_left(a,b)}};
      for(auto tile=static_cast<unsigned>(left)/spatial_tile_width;
          tile<=static_cast<unsigned>(right)/spatial_tile_width;++tile){
        const auto x0=std::max<std::int64_t>(left,std::int64_t(tile)*spatial_tile_width);
        const auto x1=std::min<std::int64_t>(right,(std::int64_t(tile)+1)*spatial_tile_width-1);
        const auto lx=2*x0+1,rx=2*x1+1,ty=2*top+1,by=2*bottom+1;
        bool possible=true;
        for(unsigned e=0;e<3;++e){
          const auto& from=triangle[(e+1)%3];
          const auto& to=triangle[(e+2)%3];
          const auto m=std::max({edge(from,to,lx,ty),edge(from,to,rx,ty),
                                 edge(from,to,lx,by),edge(from,to,rx,by)});
          if(m<0 || (m==0&&!inclusive[e])){possible=false;break;}
        }
        candidates[tile]=possible?1:0;
        if(possible)eligible_columns+=static_cast<std::uint64_t>(x1-x0+1);
      }
      if(!eligible_columns)return;
    }
    const auto work=(use_spatial?eligible_columns:static_cast<std::uint64_t>(right-left+1))*
      static_cast<std::uint64_t>(bottom-top+1);
    // Work budget scales with actual resolution instead of a 640x360 constant.
    const std::uint64_t budget=native_tiled_?
      std::uint64_t(width_)*height_*64 : max_pixel_tests;
    if (work > budget - pixel_tests_)
      throw std::length_error("XI mesh pixel-work budget exceeded");
    pixel_tests_ += work;
    constexpr std::uint64_t reciprocal_scale = UINT64_C(1) << 40;
    const auto za = reciprocal_scale / static_cast<std::uint64_t>(a.z);
    const auto zb = reciprocal_scale / static_cast<std::uint64_t>(b.z);
    const auto zc = reciprocal_scale / static_cast<std::uint64_t>(c.z);
    std::uint64_t ia=0,ib=0,ic=0;
    if constexpr(Gradient) {
      ia=za*intensities[0];ib=zb*intensities[1];ic=zc*intensities[2];
    }
    std::array<std::int64_t,3> iu{},iv{};
    if constexpr(Textured) {
      iu={{std::int64_t(za)*coords[0].u,std::int64_t(zb)*coords[1].u,
           std::int64_t(zc)*coords[2].u}};
      iv={{std::int64_t(za)*coords[0].v,std::int64_t(zb)*coords[1].v,
           std::int64_t(zc)*coords[2].v}};
    }
    const bool t0 = top_left(b,c), t1 = top_left(c,a), t2 = top_left(a,b);
    const auto px = 2*left+1, py = 2*top+1;
    auto row0 = edge(b,c,px,py), row1 = edge(c,a,px,py), row2 = edge(a,b,px,py);
    const auto dx0 = -2*(c.y-b.y), dx1 = -2*(a.y-c.y), dx2 = -2*(b.y-a.y);
    const auto dy0 = 2*(c.x-b.x), dy1 = 2*(a.x-c.x), dy2 = 2*(b.x-a.x);
    for (auto y=top; y<=bottom; ++y) {
      auto w0=row0,w1=row1,w2=row2;
      auto at=std::size_t(y-tile_row_start_)*width_+static_cast<std::size_t>(left);
      for (auto x=left; x<=right; ++x,++at) {
        if(use_spatial && !candidates[static_cast<unsigned>(x)/spatial_tile_width]){
          // Jump across an entire impossible 2D region. Advance affine edge
          // values by precisely the skipped pixel count, preserving bitwise
          // coverage and barycentric interpolation at the next candidate.
          const auto stop=std::min<std::int64_t>(right+1,
            (x/spatial_tile_width+1)*spatial_tile_width);
          const auto delta=stop-x;
          x+=delta-1;at+=static_cast<std::size_t>(delta-1);
          w0+=dx0*delta;w1+=dx1*delta;w2+=dx2*delta;
          continue;
        }
        if ((w0>0 || (w0==0 && t0)) && (w1>0 || (w1==0 && t1)) &&
            (w2>0 || (w2==0 && t2))) {
          // Reciprocal camera depth is affine in projected screen space.
          // Wide accumulation covers the bounded coordinate extremes exactly.
          const __int128 numerator=__int128(w0)*za+__int128(w1)*zb+__int128(w2)*zc;
          const auto depth=static_cast<std::uint64_t>(numerator/area);
          // Equal depth is deterministic under triangle submission reordering.
          if constexpr(Gradient) {
            // Do the extra division only for fragments that can win depth.
            if(depth>=inverse_depth_[at]) {
              const __int128 weighted_intensity=__int128(w0)*ia+__int128(w1)*ib+__int128(w2)*ic;
              const auto intensity=static_cast<std::uint64_t>((weighted_intensity+numerator/2)/numerator);
              std::uint64_t shaded=intensity;
              if constexpr(Textured) {
                const auto wu=__int128(w0)*iu[0]+__int128(w1)*iu[1]+__int128(w2)*iu[2];
                const auto wv=__int128(w0)*iv[0]+__int128(w1)*iv[1]+__int128(w2)*iv[2];
                const auto u=static_cast<std::int64_t>(wu/numerator);
                const auto v=static_cast<std::int64_t>(wv/numerator);
                const unsigned tile_x=static_cast<unsigned>(std::uint64_t(u)&15U);
                const unsigned tile_y=static_cast<unsigned>(std::uint64_t(v)&15U);
                const int delta=int(textures_[texture_id][tile_y*texture_side+tile_x])-8;
                // XI light intensity is Q8: 0..(255*256), not 0..255.
                const std::int64_t mixed=static_cast<std::int64_t>(intensity)+
                  std::int64_t(delta)*std::int64_t(texture_strength)*256;
                shaded=static_cast<std::uint64_t>(std::max<std::int64_t>(0,
                  std::min<std::int64_t>(65280,mixed)));
              }
              const auto color=static_cast<std::uint8_t>(material+
                (shaded*(ramp_count-1)+32640)/65280);
              if(depth>inverse_depth_[at] || color<materials_[at]) {
                inverse_depth_[at]=depth;materials_[at]=color;
              }
            }
          }else{
            if (depth>inverse_depth_[at] ||
                (depth==inverse_depth_[at] && material<materials_[at])) {
              inverse_depth_[at]=depth;
              materials_[at]=static_cast<std::uint8_t>(material);
            }
          }
        }
        w0+=dx0;w1+=dx1;w2+=dx2;
      }
      row0+=dy0;row1+=dy1;row2+=dy2;
    }
  }

 private:
  // Temporal strip bins. The same perspective/z/texture raster() is reused;
  // there is no second engine or approximation of XI triangles.
  std::string finish_native_pixels() {
    const std::size_t expected=std::size_t(width_)*height_;
    if(expected>std::size_t(3840)*2160)throw std::length_error("XI native pixel output bound");
    const unsigned strips=(height_+native_rows_per_strip-1)/native_rows_per_strip;
    std::vector<std::vector<std::size_t>> bin(strips);
    for(std::size_t i=0;i<deferred_faces_.size();++i){
      const auto& face=deferred_faces_[i];
      const auto ymin=std::min({face.p[0].y,face.p[1].y,face.p[2].y});
      const auto ymax=std::max({face.p[0].y,face.p[1].y,face.p[2].y});
      if(ymax<0 || ymin>=height_)continue;
      // Extend the coarse bins one row beyond the triangle's boundaries
      // to account for integer center rounding, then raster does exact tests.
      const auto low=std::max<std::int64_t>(0,ymin-1);
      const auto high=std::min<std::int64_t>(height_-1,ymax+1);
      for(auto band=unsigned(low)/native_rows_per_strip;
          band<=unsigned(high)/native_rows_per_strip;++band)bin[band].push_back(i);
    }
    std::string out("XFB5",4);
    append16(out,width_);append16(out,height_);append32(out,5);
    append32(out,static_cast<std::uint32_t>(expected));
    out.reserve(16+expected);
    tile_collecting_=false;
    for(unsigned band=0;band<strips;++band){
      tile_row_start_=band*native_rows_per_strip;
      tile_row_end_=std::min<unsigned>(height_,tile_row_start_+native_rows_per_strip);
      const auto elements=std::size_t(width_)*(tile_row_end_-tile_row_start_);
      materials_.assign(elements,background_);
      inverse_depth_.assign(elements,0);
      for(auto index:bin[band]){
        const auto& face=deferred_faces_[index];
        const auto& p=face.p;
        if(face.textured)raster<true,true>(p[0],p[1],p[2],face.material,
          face.shades,face.count,face.uv,face.texture,face.strength);
        else if(face.gradient)raster<true,false>(p[0],p[1],p[2],face.material,
          face.shades,face.count);
        else raster<false,false>(p[0],p[1],p[2],face.material);
      }
      out.append(reinterpret_cast<const char*>(materials_.data()),materials_.size());
    }
    tile_collecting_=true;
    tile_row_start_=0;tile_row_end_=height_;
    materials_.assign(1,background_);inverse_depth_.assign(1,0);
    if(out.size()!=16+expected)throw std::logic_error("XI native raster pixel count mismatch");
    return out;
  }

 public:
  std::string finish() {
    if (materials_.empty()) throw std::invalid_argument("meshend without meshbegin");
    if(native_tiled_)return finish_native_pixels();
    if(gpu_capture_){
      // Bounded XFG4 packet: 16-byte header, 2048 tile nibbles, then 60
      // bytes per triangle. Geometry and lighting originate in XI.
      std::string out("XFG4",4);
      append16(out,width_);append16(out,height_);append32(out,4);
      append32(out,static_cast<std::uint32_t>(gpu_faces_.size()));
      for(unsigned tile=0;tile<max_textures;++tile)
        for(auto nibble:textures_[tile])out.push_back(char(nibble));
      for(const auto& f:gpu_faces_){
        for(const auto& p:f.p){append32(out,static_cast<std::uint32_t>(p.x));
          append32(out,static_cast<std::uint32_t>(p.y));
          append32(out,static_cast<std::uint32_t>(p.z));}
        for(const auto& uv:f.uv){append16(out,static_cast<std::uint16_t>(uv.u));
          append16(out,static_cast<std::uint16_t>(uv.v));}
        for(auto value:f.shade)append16(out,value);
        out.push_back(char(f.base));out.push_back(char(f.count));
        out.push_back(char(f.texture));out.push_back(char(f.strength));
        append16(out,0);
      }
      return out;
    }
    std::string output("XFS1",4);
    output.push_back(char(1));output.push_back(char(0));
    append16(output,width_);append16(output,height_);append32(output,revision_);append16(output,0);
    for (unsigned y=0;y<height_;++y) {
      span(output,y,0,width_-1,background_,100);
      unsigned x=0,runs=0;
      const auto base=std::size_t(y)*width_;
      while (x<width_) {
        const auto material=materials_[base+x];
        const unsigned first=x++;
        while (x<width_ && materials_[base+x]==material) ++x;
        if (material==background_) continue;
        if (++runs>max_foreground_runs)
          throw std::length_error("XI mesh foreground-run budget exceeded");
        // These intervals are the final visibility solution, left-to-right and
        // disjoint. Depth1 is a presentation marker, not a second z test.
        span(output,y,first,x-1,material,1);
      }
    }
    output.push_back(char(3));output.push_back(char(0));append16(output,0);append32(output,revision_);
    return output;
  }

  const std::vector<std::uint8_t>& materials() const { return materials_; }
  std::uint64_t pixel_tests() const { return pixel_tests_; }

 private:
  static __int128 edge(const Vertex& a,const Vertex& b,std::int64_t x,std::int64_t y) {
    return __int128(b.x-a.x)*(y-a.y)-__int128(b.y-a.y)*(x-a.x);
  }
  static bool top_left(const Vertex& a,const Vertex& b) {
    return b.y<a.y || (b.y==a.y && b.x>a.x);
  }
  static void append16(std::string& out,std::uint16_t n) {
    out.push_back(char(n&255));out.push_back(char(n>>8));
  }
  static void append32(std::string& out,std::uint32_t n) {
    for(unsigned shift=0;shift<32;shift+=8)out.push_back(char((n>>shift)&255));
  }
  void span(std::string& out,unsigned y,unsigned x0,unsigned x1,unsigned material,unsigned depth) const {
    out.push_back(char(2));out.push_back(static_cast<char>(material));
    append16(out,static_cast<std::uint16_t>(y));append16(out,static_cast<std::uint16_t>(x0));
    append16(out,static_cast<std::uint16_t>(x1));append16(out,static_cast<std::uint16_t>(depth));
    append32(out,revision_);
  }
  std::uint16_t width_=0,height_=0;
  std::uint32_t revision_=0;
  std::uint8_t background_=0;
  std::size_t triangles_=0;
  std::uint64_t pixel_tests_=0;
  std::vector<std::uint8_t> materials_;
  std::vector<std::uint64_t> inverse_depth_;
  std::vector<Vertex> vertices_;
  std::vector<std::uint8_t> vertex_ready_;
  bool gpu_capture_=false;
  bool native_tiled_=false,tile_collecting_=false;
  unsigned tile_row_start_=0,tile_row_end_=0;
  std::vector<DeferredFace> deferred_faces_;
  std::vector<GpuFace> gpu_faces_;
  std::vector<std::uint16_t> vertex_shades_;
  std::vector<Texcoord> texcoords_;
  std::vector<std::uint8_t> texcoord_ready_;
  std::array<std::array<std::uint8_t,texture_side*texture_side>,native_max_textures> textures_{};
  std::array<std::uint16_t,native_max_textures> texture_row_mask_{};
};
