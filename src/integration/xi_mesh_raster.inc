// Included inside the XI machine owner's namespace. No game equations live here.
// Generic, bounded screen-space triangle coverage with perspective-correct 1/z.
class MachineMeshRaster {
 public:
  static constexpr std::uint16_t max_width = 640, max_height = 360;
  static constexpr std::size_t max_triangles = 4096;
  static constexpr std::size_t max_vertices = 4096;
  static constexpr std::uint64_t max_pixel_tests = 8000000;
  // A valid visibility row may alternate material at every pixel. This natural
  // bound encodes every raster image; it must not reject a detailed scene.
  static constexpr unsigned max_foreground_runs = max_width;
  struct Vertex { std::int64_t x, y, z; };

  void begin(std::int64_t width, std::int64_t height,
             std::int64_t revision, std::int64_t background) {
    if (width < 1 || width > max_width || height < 1 || height > max_height ||
        revision < 0 || revision > std::numeric_limits<std::uint32_t>::max() ||
        background < 0 || background > 255)
      throw std::out_of_range("invalid XI mesh dimensions, revision or background");
    width_ = static_cast<std::uint16_t>(width);
    height_ = static_cast<std::uint16_t>(height);
    revision_ = static_cast<std::uint32_t>(revision);
    background_ = static_cast<std::uint8_t>(background);
    triangles_ = 0; pixel_tests_ = 0;
    materials_.assign(std::size_t(width_) * height_, background_);
    inverse_depth_.assign(materials_.size(), 0);
    vertices_.assign(max_vertices,Vertex{0,0,0});
    vertex_ready_.assign(max_vertices,0);
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
    raster(a,b,c,material);
  }

  // XI supplies the camera transform. This primitive clips the near plane and
  // projects the resulting polygon before using the same coverage/z buffer.
  void triangle3(Vertex a, Vertex b, Vertex c, std::int64_t material,
                 std::int64_t focal,std::int64_t center_x,std::int64_t center_y,
                 std::int64_t near_plane) {
    validate_material(material);
    if(focal<1 || focal>2048 || center_x < -32768 || center_x>32768 ||
       center_y < -32768 || center_y>32768 || near_plane<1 || near_plane>10000)
      throw std::out_of_range("invalid XI mesh camera projection");
    for(const Vertex v:{a,b,c})
      if(v.x < -1000000 || v.x>1000000 || v.y < -1000000 || v.y>1000000 ||
         v.z < -1000000 || v.z>1000000)
        throw std::out_of_range("camera-space mesh vertex exceeds bounds");
    count_triangle();
    std::array<Vertex,4> clipped{};
    unsigned count=0;
    const std::array<Vertex,3> input{{a,b,c}};
    Vertex previous=c;
    for(const Vertex current:input) {
      const bool inside=current.z>=near_plane,was_inside=previous.z>=near_plane;
      if(inside!=was_inside) {
        const auto da=previous.z-near_plane,db=current.z-near_plane;
        const auto denominator=da-db;
        // Symmetric weighted form gives the same integer intersection when
        // adjacent triangles traverse their shared edge in opposite directions.
        clipped[count++]={
          static_cast<std::int64_t>((__int128(current.x)*da-__int128(previous.x)*db)/denominator),
          static_cast<std::int64_t>((__int128(current.y)*da-__int128(previous.y)*db)/denominator),
          near_plane};
      }
      if(inside)clipped[count++]=current;
      previous=current;
    }
    if(count<3)return;
    for(unsigned i=0;i<count;++i) {
      clipped[i].x=center_x+clipped[i].x*focal/clipped[i].z;
      clipped[i].y=center_y-clipped[i].y*focal/clipped[i].z;
    }
    for(unsigned i=1;i+1<count;++i)raster(clipped[0],clipped[i],clipped[i+1],material);
  }

 private:
  static void validate_vertex_id(std::int64_t id) {
    if(id<0 || id>=static_cast<std::int64_t>(max_vertices))
      throw std::out_of_range("mesh vertex id must be in 0..4095");
  }
  void validate_material(std::int64_t material) const {
    if (materials_.empty()) throw std::invalid_argument("mesh triangle without meshbegin");
    if (material < 0 || material > 255)
      throw std::out_of_range("mesh material must be in 0..255");
  }
  void count_triangle() {
    if (triangles_ >= max_triangles)
      throw std::length_error("XI mesh triangle budget exceeded");
    ++triangles_;
  }
  void raster(Vertex a,Vertex b,Vertex c,std::int64_t material) {
    // Pixel centers are half-integers. Doubled screen coordinates make the
    // top-left fill convention exact and avoid floating-point edge cracks.
    a.x *= 2; a.y *= 2; b.x *= 2; b.y *= 2; c.x *= 2; c.y *= 2;
    auto area = edge(a, b, c.x, c.y);
    if (!area) return;
    if (area < 0) { std::swap(b, c); area = -area; }
    const auto left = std::max<std::int64_t>(0, std::min({a.x, b.x, c.x}) / 2);
    const auto right = std::min<std::int64_t>(width_ - 1, std::max({a.x, b.x, c.x}) / 2);
    const auto top = std::max<std::int64_t>(0, std::min({a.y, b.y, c.y}) / 2);
    const auto bottom = std::min<std::int64_t>(height_ - 1, std::max({a.y, b.y, c.y}) / 2);
    if (left > right || top > bottom) return;
    const auto work = static_cast<std::uint64_t>((right-left+1)*(bottom-top+1));
    if (work > max_pixel_tests - pixel_tests_)
      throw std::length_error("XI mesh pixel-work budget exceeded");
    pixel_tests_ += work;
    constexpr std::uint64_t reciprocal_scale = UINT64_C(1) << 40;
    const auto za = reciprocal_scale / static_cast<std::uint64_t>(a.z);
    const auto zb = reciprocal_scale / static_cast<std::uint64_t>(b.z);
    const auto zc = reciprocal_scale / static_cast<std::uint64_t>(c.z);
    const bool t0 = top_left(b,c), t1 = top_left(c,a), t2 = top_left(a,b);
    const auto px = 2*left+1, py = 2*top+1;
    auto row0 = edge(b,c,px,py), row1 = edge(c,a,px,py), row2 = edge(a,b,px,py);
    const auto dx0 = -2*(c.y-b.y), dx1 = -2*(a.y-c.y), dx2 = -2*(b.y-a.y);
    const auto dy0 = 2*(c.x-b.x), dy1 = 2*(a.x-c.x), dy2 = 2*(b.x-a.x);
    for (auto y=top; y<=bottom; ++y) {
      auto w0=row0,w1=row1,w2=row2;
      auto at=std::size_t(y)*width_+static_cast<std::size_t>(left);
      for (auto x=left; x<=right; ++x,++at) {
        if ((w0>0 || (w0==0 && t0)) && (w1>0 || (w1==0 && t1)) &&
            (w2>0 || (w2==0 && t2))) {
          // Reciprocal camera depth is affine in projected screen space.
          // Wide accumulation covers the bounded coordinate extremes exactly.
          const __int128 numerator=__int128(w0)*za+__int128(w1)*zb+__int128(w2)*zc;
          const auto depth=static_cast<std::uint64_t>(numerator/area);
          // Equal depth is deterministic under triangle submission reordering.
          if (depth>inverse_depth_[at] ||
              (depth==inverse_depth_[at] && material<materials_[at])) {
            inverse_depth_[at]=depth;
            materials_[at]=static_cast<std::uint8_t>(material);
          }
        }
        w0+=dx0;w1+=dx1;w2+=dx2;
      }
      row0+=dy0;row1+=dy1;row2+=dy2;
    }
  }

 public:
  std::string finish() const {
    if (materials_.empty()) throw std::invalid_argument("meshend without meshbegin");
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
};
