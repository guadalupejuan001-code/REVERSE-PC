"""Optional PRISMA cuboids in the pinned Ether Render X spatial observer.

The upstream checkout, sphere ABI, MIL bridge and core are unchanged. The
hash-checked build overlay extends the existing planner and sparse observer;
it does not introduce another candidate planner or rasterizer.
"""
def configure(expected, replacements):
    expected['ether_render_spatial.hpp'] = 'ec2f91ba21ebc8337e7e03b16ef22e0a6f39e64a531f1503e6315fb209148399'
    replacements['ether_render_spatial.hpp'] = [
        ('    std::array<double,3> color{{1.,1.,1.}};', '''    std::array<double,3> color{{1.,1.,1.}};
    // Optional oriented cube. radius remains its conservative bounding sphere.
    // Zero half-size preserves every historical sphere contract.
    double cube_half=0.,yaw=0.,pitch=0.,alpha=1.;
    int direction=-1;
    bool hot=false;
    int material=0; // 0 legacy; 1 prism, 2 alloy, 3 luminous lens.'''),
        ('  void add_body(const Body& b) {', '''  void set_screen_center(double x,double y){
    if(!std::isfinite(x)||!std::isfinite(y)||x<0.||x>1.||y<0.||y>1.)
      throw std::invalid_argument("invalid spatial screen center");
    center_x_=x;center_y_=y;dirty_=true;++revision_;
  }

  void add_body(const Body& b) {'''),
        ('    for(const auto c:b.color)if(!std::isfinite(c)||c<0.||c>1.)', '''    if(!std::isfinite(b.cube_half)||b.cube_half<0.||
       !std::isfinite(b.yaw)||!std::isfinite(b.pitch)||
       !std::isfinite(b.alpha)||b.alpha<0.||b.alpha>1.||
       b.direction < -1||b.direction>3||b.material<0||b.material>3||
       (b.cube_half>0.&&b.radius+1e-12<std::sqrt(3.)*b.cube_half))
      throw std::invalid_argument("invalid spatial cube/material");
    for(const auto c:b.color)if(!std::isfinite(c)||c<0.||c>1.)'''),
        ('    radius2_.resize(bodies_.size());near_.resize(bodies_.size());', '''    radius2_.resize(bodies_.size());near_.resize(bodies_.size());
    axes_x_.resize(bodies_.size());axes_y_.resize(bodies_.size());
    axes_z_.resize(bodies_.size());box_origin_.resize(bodies_.size());'''),
        ('      near_[i]=std::max(0.,length(c)-b.radius);', '''      near_[i]=std::max(0.,length(c)-b.radius);
      const double cy=std::cos(b.yaw),sy=std::sin(b.yaw);
      const double cx=std::cos(b.pitch),sx=std::sin(b.pitch);
      axes_x_[i]={cy,sx*sy,-cx*sy};axes_y_[i]={0.,cx,sx};
      axes_z_[i]={sy,-sx*cy,cx*cy};
      const auto origin=mul(c,-1.);
      box_origin_[i]={dot(origin,axes_x_[i]),dot(origin,axes_y_[i]),dot(origin,axes_z_[i])};'''),
        ('''      const double along=dot(offsets_[i],ray);
      const double h2=radius2_[i]-(squared_[i]-along*along);
      if(h2<0.)continue;
      const double root=std::sqrt(h2);
      double depth=along-root;if(depth<=1e-6)depth=along+root;
      if(depth<=1e-6||depth>=best.depth)continue;''', '''      const double depth=intersect(i,ray);
      if(!std::isfinite(depth)||depth<=1e-6||depth>=best.depth)continue;'''),
        ('''    const double along=dot(offsets_[i],ray);
    const double h2=radius2_[i]-(squared_[i]-along*along);
    if(h2<0.)return std::numeric_limits<double>::infinity();
    const double root=std::sqrt(h2);
    double depth=along-root;if(depth<=1e-6)depth=along+root;
    return depth>1e-6?depth:std::numeric_limits<double>::infinity();''', '''    return intersect(i,ray);'''),
        ('(2.*(static_cast<double>(row)+.5)/height_-1.)*tan_half_',
         '(2.*(static_cast<double>(row)+.5)/height_-2.*center_y_)*tan_half_'),
        ('(lo/scale_x+1.)*.5*width_-.5', '(lo/scale_x*.5+center_x_)*width_-.5'),
        ('(hi/scale_x+1.)*.5*width_-.5', '(hi/scale_x*.5+center_x_)*width_-.5'),
        ('    if(right<-1.||left>1.||top<-1.||bottom>1.)return;', '''    left+=2.*center_x_-1.;right+=2.*center_x_-1.;
    bottom+=2.*center_y_-1.;top+=2.*center_y_-1.;
    if(right<-1.||left>1.||top<-1.||bottom>1.)return;'''),
        ('2.*(static_cast<double>(x)+.5)/static_cast<double>(width_)-1.',
         '2.*(static_cast<double>(x)+.5)/static_cast<double>(width_)-2.*center_x_'),
        ('2.*(static_cast<double>(y)+.5)/static_cast<double>(height_)-1.',
         '2.*(static_cast<double>(y)+.5)/static_cast<double>(height_)-2.*center_y_'),
        ('    const auto normal=normalize(sub(point,hit->center));', '''    if(hit->cube_half>0.)return shade_cube(best,*hit,point);
    const auto normal=normalize(sub(point,hit->center));'''),
        ('''      const double along=dot(offsets_[i],ray);
      const double h2=radius2_[i]-(squared_[i]-along*along);
      if(h2<0.)continue;
      const double root=std::sqrt(h2);
      double depth=along-root;if(depth<=1e-6)depth=along+root;
      if(depth<=1e-6)continue;''', '''      const double depth=intersect(i,ray);
      if(!std::isfinite(depth)||depth<=1e-6)continue;'''),
        ('  void hash(Pixel p){', '''  double intersect(std::size_t i,Vec3 ray)const{
    const auto& b=bodies_[i];
    if(b.cube_half==0.){
      const double along=dot(offsets_[i],ray);
      const double h2=radius2_[i]-(squared_[i]-along*along);
      if(h2<0.)return std::numeric_limits<double>::infinity();
      const double root=std::sqrt(h2);
      double t=along-root;if(t<=1e-6)t=along+root;
      return t>1e-6?t:std::numeric_limits<double>::infinity();
    }
    const auto o=box_origin_[i];
    const std::array<double,3> origin{{o.x,o.y,o.z}};
    const std::array<double,3> direction{{dot(ray,axes_x_[i]),dot(ray,axes_y_[i]),dot(ray,axes_z_[i])}};
    double near=-std::numeric_limits<double>::infinity(),far=std::numeric_limits<double>::infinity();
    for(unsigned axis=0;axis<3;++axis){
      if(std::abs(direction[axis])<1e-12){
        if(std::abs(origin[axis])>b.cube_half)return std::numeric_limits<double>::infinity();
        continue;
      }
      double a=(-b.cube_half-origin[axis])/direction[axis],z=(b.cube_half-origin[axis])/direction[axis];
      if(a>z)std::swap(a,z);
      near=std::max(near,a);far=std::min(far,z);
      if(near>far)return std::numeric_limits<double>::infinity();
    }
    const double t=near>1e-6?near:far;
    return t>1e-6?t:std::numeric_limits<double>::infinity();
  }
  Pixel shade_cube(Pixel p,const Body& b,Vec3 point)const{
    const auto i=static_cast<std::size_t>(&b-bodies_.data());
    const auto v=sub(point,b.center);const double h=b.cube_half;
    const std::array<double,3> local{{dot(v,axes_x_[i])/h,dot(v,axes_y_[i])/h,dot(v,axes_z_[i])/h}};
    unsigned axis=0;for(unsigned a=1;a<3;++a)if(std::abs(local[a])>std::abs(local[axis]))axis=a;
    const std::array<Vec3,3> basis{{axes_x_[i],axes_y_[i],axes_z_[i]}};
    const auto normal=mul(basis[axis],local[axis]<0.?-1.:1.);
    static const auto light=normalize(Vec3{-.37,-.54,.76});
    double luminance=.20+.42*std::max(0.,dot(normal,light));
    bool edge=false;for(unsigned a=0;a<3;++a)if(a!=axis&&std::abs(local[a])>.945)edge=true;
    bool arrow=false;
    if(axis==2&&local[2]>0.&&b.direction>=0){
      const double a=b.direction*std::acos(-1.)*.5,c=std::cos(a),s=std::sin(a);
      const double x=local[0]*c+local[1]*s,y=-local[0]*s+local[1]*c;
      auto distance=[&](double ax,double ay,double bx,double by){
        const double dx=bx-ax,dy=by-ay,t=std::max(0.,std::min(1.,((x-ax)*dx+(y-ay)*dy)/(dx*dx+dy*dy)));
        return std::hypot(x-ax-t*dx,y-ay-t*dy);
      };
      arrow=std::min({distance(-.33,.06,0.,-.30),distance(0.,-.30,.33,.06),distance(0.,-.30,0.,.43)})<.045;
    }
    if(edge)luminance=b.hot?1.:.88;
    if(arrow)luminance=1.;
    // Keep material zero BIT-FOR-BIT compatible with the original X Render
    // cuboid shading. New materials only change the resolved surface color;
    // candidate region planning, depth, exact box intersection and IDs stay.
    if(b.material!=0){
      const auto toward=sub(Vec3{0.,0.,4.8},point);
      const auto view=length(toward)>1e-9?normalize(toward):normal;
      const double nv=std::max(0.,std::min(1.,dot(normal,view)));
      const double nd=std::max(0.,dot(normal,light));
      const double fr=std::pow(1.-nv,5.);
      const auto halfway=normalize(Vec3{light.x+view.x,light.y+view.y,light.z+view.z});
      const double spec=std::pow(std::max(0.,dot(normal,halfway)),b.material==2?35.:18.);
      const unsigned u=(axis+1)%3,w=(axis+2)%3;
      if(b.material==1){ // stylized faceted glass, NOT physical ray refraction
        const double facets=.5+.5*std::cos((local[u]*1.4+local[w]*.9)*10.);
        luminance=.16+.31*nd+.15*facets+.30*fr+.28*spec;
        if(edge)luminance=b.hot?1.12:.91;
      }else if(b.material==2){ // brushed alloy with view-dependent glints
        const double grain=.5+.5*std::cos(local[u]*46.);
        luminance=.16+.44*nd+.23*spec*(.74+.26*grain)+.12*fr;
        if(edge)luminance=.71+.14*spec;
      }else if(b.material==3){ // recessed concert lens and constrained core
        const double radial=std::hypot(local[u],local[w]);
        const double halo=std::exp(-radial*radial*2.7);
        luminance=.12+.22*nd+.70*halo+.15*fr+.18*spec;
        if(edge)luminance=.28+.18*nd;
      }
      if(arrow)luminance=1.12;
    }
    auto channel=[&](double color){
      double value=color*luminance*gains_[b.id];
      if(arrow&&b.hot)value=value*.45+.55;
      return static_cast<std::uint32_t>(std::lround(std::max(0.,std::min(1.,value))*255.));
    };
    p.rgba=(static_cast<std::uint32_t>(std::lround(b.alpha*255.))<<24)|
           (channel(b.color[0])<<16)|(channel(b.color[1])<<8)|channel(b.color[2]);
    return p;
  }
  void hash(Pixel p){'''),
        ('  double tan_half_=0.,aspect_=1.;', '  double tan_half_=0.,aspect_=1.,center_x_=.5,center_y_=.5;'),
        ('  std::vector<Vec3> offsets_;', '  std::vector<Vec3> offsets_,axes_x_,axes_y_,axes_z_,box_origin_;'),
    ]
