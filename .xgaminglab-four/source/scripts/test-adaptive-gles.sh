#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${XLAB_GL_HEADERS:?Set XLAB_GL_HEADERS to GLES/EGL headers directory}"
mkdir -p build/graphics-probe
python3 scripts/prepare_vendor.py
"${CXX:-g++}" -std=c++20 -O2 -pthread -DREVERSE_PC_HAVE_BOUNDED_PRODUCT_IMPORT=1 \
  -Ibuild/qssd-compat -Ibuild/ether-compat -Ivendor/mundo/native/include \
  -Ivendor/reverse/src -Ivendor/qssd/include -Ivendor/gpu/include -Inative -I"$XLAB_GL_HEADERS" \
  native/x_backend.cpp native/component_lab.cpp native/scene_renderer.cpp tests/adaptive_gles_probe.cpp \
  "${XLAB_EGL_LIBRARY:--lEGL}" "${XLAB_GLES_LIBRARY:--lGLESv2}" \
  -o build/graphics-probe/adaptive-gles-probe
MESA_GLES_VERSION_OVERRIDE=2.0 LIBGL_ALWAYS_SOFTWARE=1 \
  build/graphics-probe/adaptive-gles-probe | tee build/graphics-probe/adaptive-gles-result.json
