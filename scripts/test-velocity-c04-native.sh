#!/usr/bin/env bash
set -euo pipefail
mkdir -p build/velocity-c04/java
python3 scripts/prepare-ether-compat.py deps/mundo-x build/ether-compat
python3 deps/qssd/scripts/prepare_gpu.py deps/gpu-virtual/include build/qssd-gpu-compat
python3 deps/qssd/scripts/prepare_c12.py deps/gpu-virtual/include build/qssd-gpu-compat
node scripts/check-velocity-qssd.cjs deps/qssd
cxx="${CXX:-g++}"
"$cxx" -std=c++17 -O2 -Wall -Wextra -pthread -Ideps/qssd/include deps/qssd/tests/graphics_port.cpp -o build/velocity-c04/qssd-graphics
build/velocity-c04/qssd-graphics
"$cxx" -std=c++20 -O2 -Wall -Wextra -pthread -DREVERSE_PC_HAVE_BOUNDED_PRODUCT_IMPORT=1 -Ibuild/qssd-gpu-compat -Ideps/qssd/include -Ibuild/ether-compat -Ideps/mundo-x/native/include -Isrc -Ideps/gpu-virtual/include -Ireverse-os-android/app/src/main/cpp reverse-os-android/app/src/main/cpp/velocity_c12_frame.cpp reverse-os-android/tests/velocity-c12-frame.cpp -o build/velocity-c04/c12-materials
build/velocity-c04/c12-materials
JAVA_HOME="${JAVA_HOME:-$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")}"
"$cxx" -std=c++17 -O2 -fPIC -shared -pthread -Wall -Wextra -Ideps/qssd/include -I"$JAVA_HOME/include" -I"$JAVA_HOME/include/linux" reverse-os-android/app/src/main/cpp/velocity_qssd_jni.cpp -o build/velocity-c04/libreverse_os.so
javac -d build/velocity-c04/java reverse-os-android/app/src/main/java/x/gpu/virtual/CompactTriangleStream.java reverse-os-android/app/src/main/java/com/reversepc/os/RegraphicsGeometry.java reverse-os-android/app/src/main/java/com/reversepc/os/VelocityQssdGraphicsBridge.java reverse-os-android/tests/VelocityQssdGraphicsBridgeTest.java
java -Djava.library.path=build/velocity-c04 -cp build/velocity-c04/java com.reversepc.os.VelocityQssdGraphicsBridgeTest
