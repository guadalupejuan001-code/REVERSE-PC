cmake_minimum_required(VERSION 3.16)
project(REVERSE_FABRIC_INTEGRATION LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
find_package(Threads REQUIRED)
get_filename_component(REVERSE_ROOT "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
set(MUNDO "${REVERSE_ROOT}/deps/mundo-x-c03")
set(GPU "${REVERSE_ROOT}/deps/gpu-virtual-c08")
set(QSSD "${REVERSE_ROOT}/deps/qssd-c08")
foreach(source IN ITEMS
  "${MUNDO}/pc-android/native/pc_machine.hpp"
  "${MUNDO}/native/include/mundo_x/autonomous_core_c02.hpp"
  "${GPU}/include/trabajo_fisico.hpp"
  "${QSSD}/include/qssd/graphics_work_state.hpp")
  if(NOT EXISTS "${source}")
    message(FATAL_ERROR "Missing authentic pinned modern component: ${source}")
  endif()
endforeach()
add_executable(reverse_fabric_integration ../reverse_fabric_integration.cpp)
target_include_directories(reverse_fabric_integration PRIVATE
  "${REVERSE_ROOT}/src/fabric" "${MUNDO}/pc-android/native"
  "${MUNDO}/native/include" "${GPU}/include" "${QSSD}/include")
target_link_libraries(reverse_fabric_integration PRIVATE Threads::Threads)
if(MSVC)
  target_compile_options(reverse_fabric_integration PRIVATE /W3)
else()
  target_compile_options(reverse_fabric_integration PRIVATE -Wall -Wextra -Wpedantic)
endif()
enable_testing()
add_test(NAME reverse_fabric_original_components COMMAND reverse_fabric_integration)
set_tests_properties(reverse_fabric_original_components PROPERTIES TIMEOUT 90)
