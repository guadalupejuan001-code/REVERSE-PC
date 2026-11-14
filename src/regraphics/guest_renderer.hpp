#pragma once

#include "guest_triangle_work.hpp"
#include <EGL/egl.h>
#include <GLES2/gl2.h>
#include <GLES2/gl2ext.h>
#include <algorithm>
#include <array>
#include <chrono>
#include <cstring>
#include <limits>
#include <optional>
#include <stdexcept>
#include <string>
#include <string_view>
#include <vector>

namespace regraphics {

struct GuestRenderReceipt {
  std::uint64_t cpu_wall_ns = 0;
  std::optional<std::uint64_t> gpu_query_ns;
  std::uint64_t vertex_bytes = 0;
  bool hardware_reported = false;
  std::string renderer;
};

// REgraphics GLES renderer for an ordered list of guest clip-space triangles.
// The context, program and buffers are reused across frames on one VM thread.
class GuestRenderer {
 public:
  GuestRenderer() = default;
  GuestRenderer(const GuestRenderer&) = delete;
  GuestRenderer& operator=(const GuestRenderer&) = delete;
  ~GuestRenderer() {
    if (display_ == EGL_NO_DISPLAY || !initialized_) return;
    eglMakeCurrent(display_, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
    if (surface_ != EGL_NO_SURFACE) eglDestroySurface(display_, surface_);
    if (context_ != EGL_NO_CONTEXT) eglDestroyContext(display_, context_);
    eglTerminate(display_);
  }

  GuestRenderReceipt render(const xgpu::GuestTrianglePlan& plan, unsigned width, unsigned height,
                            std::uint32_t clear_rgba, std::vector<std::uint8_t>& bgra,
                            bool preserve_alpha = false) {
    using Clock = std::chrono::steady_clock;
    if (width == 0 || height == 0 || width > 1920 || height > 1080)
      throw std::invalid_argument("REgraphics guest target dimensions");
    if (plan.vertices.size() > xgpu::GuestTriangleWork::max_vertices || plan.vertices.size() % 3)
      throw std::invalid_argument("REgraphics guest vertex count");
    const auto started = Clock::now();
    open(width, height);
    require(eglMakeCurrent(display_, surface_, surface_, context_), "bind guest target");
    struct Unbind {
      EGLDisplay display;
      ~Unbind() { eglMakeCurrent(display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT); }
    } unbind{display_};
    if (!program_) initialize_program();

    glViewport(0, 0, width, height);
    glUseProgram(program_);
    glDisable(GL_BLEND);
    glDisable(GL_DITHER);
    glDisable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    glDepthMask(GL_TRUE);
    glClearColor(channel(clear_rgba, 0), channel(clear_rgba, 8), channel(clear_rgba, 16),
                 channel(clear_rgba, 24));
    glClearDepthf(1);
    glBindBuffer(GL_ARRAY_BUFFER, buffer_);
    const auto bytes = plan.vertices.size() * sizeof(xgpu::GuestVertex);
    if (bytes) {
      glBufferData(GL_ARRAY_BUFFER, static_cast<GLsizeiptr>(bytes), plan.vertices.data(), GL_STREAM_DRAW);
      glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, sizeof(xgpu::GuestVertex), nullptr);
      glVertexAttribPointer(1, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(xgpu::GuestVertex),
                            reinterpret_cast<const void*>(offsetof(xgpu::GuestVertex, rgba)));
      glEnableVertexAttribArray(0);
      glEnableVertexAttribArray(1);
    }
    check_gl("upload guest geometry");
    if (timer_) {
      GLint discarded = GL_FALSE;
      glGetIntegerv(GL_GPU_DISJOINT_EXT, &discarded);
      begin_(GL_TIME_ELAPSED_EXT, timer_);
    }
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    if (bytes) glDrawArrays(GL_TRIANGLES, 0, static_cast<GLsizei>(plan.vertices.size()));
    if (timer_) end_(GL_TIME_ELAPSED_EXT);
    check_gl("draw guest geometry");

    const auto pitch = std::size_t(width) * 4;
    rgba_.resize(pitch * height);
    bgra.resize(rgba_.size());
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, rgba_.data());
    check_gl("read guest color attachment");
    std::optional<std::uint64_t> elapsed;
    if (timer_) {
      GLint disjoint = GL_FALSE;
      GLuint ready = 0;
      glGetIntegerv(GL_GPU_DISJOINT_EXT, &disjoint);
      available_(timer_, GL_QUERY_RESULT_AVAILABLE_EXT, &ready);
      if (!disjoint && ready) {
        GLuint64 value = 0;
        result_(timer_, GL_QUERY_RESULT_EXT, &value);
        glGetIntegerv(GL_GPU_DISJOINT_EXT, &disjoint);
        if (!disjoint) elapsed = value;
      }
      check_gl("guest elapsed-time query");
    }
    for (unsigned y = 0; y < height; ++y) {
      const auto* source = rgba_.data() + (height - y - 1) * pitch;
      auto* destination = bgra.data() + y * pitch;
      for (std::size_t x = 0; x < pitch; x += 4) {
        destination[x] = source[x + 2];
        destination[x + 1] = source[x + 1];
        destination[x + 2] = source[x];
        destination[x + 3] = preserve_alpha ? source[x + 3] : 0; // VBE reserves the fourth byte.
      }
    }
    return {static_cast<std::uint64_t>(
                std::chrono::duration_cast<std::chrono::nanoseconds>(Clock::now() - started).count()),
            elapsed, bytes, hardware_reported_, name_};
  }

 private:
  EGLDisplay display_ = EGL_NO_DISPLAY;
  EGLContext context_ = EGL_NO_CONTEXT;
  EGLSurface surface_ = EGL_NO_SURFACE;
  EGLConfig config_{};
  bool initialized_ = false, hardware_reported_ = false;
  unsigned width_ = 0, height_ = 0;
  GLuint program_ = 0, buffer_ = 0, timer_ = 0;
  PFNGLBEGINQUERYEXTPROC begin_ = nullptr;
  PFNGLENDQUERYEXTPROC end_ = nullptr;
  PFNGLGETQUERYOBJECTUIVEXTPROC available_ = nullptr;
  PFNGLGETQUERYOBJECTUI64VEXTPROC result_ = nullptr;
  std::vector<std::uint8_t> rgba_;
  std::string name_;

  static float channel(std::uint32_t rgba, unsigned shift) {
    return static_cast<float>((rgba >> shift) & 255U) / 255.0f;
  }
  static void require(bool value, const char* operation) {
    if (!value) throw std::runtime_error(std::string("REgraphics: ") + operation);
  }
  static void check_gl(const char* operation) { require(glGetError() == GL_NO_ERROR, operation); }

  void open(unsigned width, unsigned height) {
    if (!initialized_) {
      display_ = eglGetDisplay(EGL_DEFAULT_DISPLAY);
      require(display_ != EGL_NO_DISPLAY && eglInitialize(display_, nullptr, nullptr), "initialize EGL");
      initialized_ = true;
    }
    require(eglBindAPI(EGL_OPENGL_ES_API), "bind GLES API");
    if (context_ == EGL_NO_CONTEXT) {
      const EGLint attributes[]{EGL_SURFACE_TYPE, EGL_PBUFFER_BIT, EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
          EGL_RED_SIZE, 8, EGL_GREEN_SIZE, 8, EGL_BLUE_SIZE, 8, EGL_ALPHA_SIZE, 8,
          EGL_DEPTH_SIZE, 24, EGL_SAMPLE_BUFFERS, 0, EGL_NONE};
      EGLint count = 0;
      require(eglChooseConfig(display_, attributes, &config_, 1, &count) && count == 1,
              "choose RGBA8888/depth pbuffer");
      const EGLint options[]{EGL_CONTEXT_CLIENT_VERSION, 2, EGL_NONE};
      context_ = eglCreateContext(display_, config_, EGL_NO_CONTEXT, options);
      require(context_ != EGL_NO_CONTEXT, "create guest GLES context");
    }
    if (surface_ == EGL_NO_SURFACE || width != width_ || height != height_) {
      const EGLint size[]{EGL_WIDTH, static_cast<EGLint>(width), EGL_HEIGHT, static_cast<EGLint>(height), EGL_NONE};
      const auto next = eglCreatePbufferSurface(display_, config_, size);
      require(next != EGL_NO_SURFACE, "create guest color attachment");
      if (surface_ != EGL_NO_SURFACE) eglDestroySurface(display_, surface_);
      surface_ = next;
      width_ = width;
      height_ = height;
    }
  }

  static GLuint compile(GLenum type, const char* source) {
    const auto shader = glCreateShader(type);
    glShaderSource(shader, 1, &source, nullptr);
    glCompileShader(shader);
    GLint okay = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &okay);
    if (!okay) {
      std::array<GLchar, 512> log{};
      glGetShaderInfoLog(shader, log.size(), nullptr, log.data());
      glDeleteShader(shader);
      throw std::runtime_error(std::string("REgraphics guest shader: ") + log.data());
    }
    return shader;
  }

  void initialize_program() {
    // D3D z is [0,w], GLES z is [-w,w]. Both use +Y up before viewport.
    constexpr auto vertex = "attribute vec4 position; attribute vec4 color;"
        "varying mediump vec4 rgba; void main(){"
        "gl_Position=vec4(position.xy,2.0*position.z-position.w,position.w);rgba=color;}";
    constexpr auto fragment = "precision mediump float; varying mediump vec4 rgba;"
        "void main(){gl_FragColor=rgba;}";
    GLuint vs = 0, fs = 0, next = 0, buffer = 0;
    try {
      vs = compile(GL_VERTEX_SHADER, vertex);
      fs = compile(GL_FRAGMENT_SHADER, fragment);
      next = glCreateProgram();
      glAttachShader(next, vs);
      glAttachShader(next, fs);
      glBindAttribLocation(next, 0, "position");
      glBindAttribLocation(next, 1, "color");
      glLinkProgram(next);
      GLint linked = 0;
      glGetProgramiv(next, GL_LINK_STATUS, &linked);
      require(linked, "link guest shader");
      glGenBuffers(1, &buffer);
      require(buffer, "allocate guest geometry buffer");
      check_gl("initialize guest shader");
      const auto* renderer = reinterpret_cast<const char*>(glGetString(GL_RENDERER));
      name_ = renderer ? renderer : "";
      std::string_view name = name_;
      hardware_reported_ = name.find("Mali") != name.npos || name.find("Adreno") != name.npos ||
          name.find("PowerVR") != name.npos || name.find("Apple GPU") != name.npos;
      if (name.find("SwiftShader") != name.npos || name.find("llvmpipe") != name.npos ||
          name.find("Software") != name.npos || name.find("Emulator") != name.npos)
        hardware_reported_ = false;
      initialize_timer();
      program_ = next;
      buffer_ = buffer;
    } catch (...) {
      glDeleteBuffers(1, &buffer);
      if (next) glDeleteProgram(next);
      if (vs) glDeleteShader(vs);
      if (fs) glDeleteShader(fs);
      throw;
    }
    glDeleteShader(vs);
    glDeleteShader(fs);
  }

  void initialize_timer() {
    const auto* extensions = reinterpret_cast<const char*>(glGetString(GL_EXTENSIONS));
    if (!extensions || (std::string(" ") + extensions + " ").find(" GL_EXT_disjoint_timer_query ") ==
            std::string::npos) return;
    const auto gen = reinterpret_cast<PFNGLGENQUERIESEXTPROC>(eglGetProcAddress("glGenQueriesEXT"));
    const auto bits = reinterpret_cast<PFNGLGETQUERYIVEXTPROC>(eglGetProcAddress("glGetQueryivEXT"));
    begin_ = reinterpret_cast<PFNGLBEGINQUERYEXTPROC>(eglGetProcAddress("glBeginQueryEXT"));
    end_ = reinterpret_cast<PFNGLENDQUERYEXTPROC>(eglGetProcAddress("glEndQueryEXT"));
    available_ = reinterpret_cast<PFNGLGETQUERYOBJECTUIVEXTPROC>(eglGetProcAddress("glGetQueryObjectuivEXT"));
    result_ = reinterpret_cast<PFNGLGETQUERYOBJECTUI64VEXTPROC>(eglGetProcAddress("glGetQueryObjectui64vEXT"));
    if (!gen || !bits || !begin_ || !end_ || !available_ || !result_) return;
    GLint precision = 0;
    bits(GL_TIME_ELAPSED_EXT, GL_QUERY_COUNTER_BITS_EXT, &precision);
    if (glGetError() == GL_NO_ERROR && precision > 0) {
      gen(1, &timer_);
      if (glGetError() != GL_NO_ERROR) timer_ = 0;
    }
  }
};

}  // namespace regraphics
