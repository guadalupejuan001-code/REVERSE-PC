cmake_minimum_required(VERSION 3.16)
project(REVERSE_PC LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(ETHER_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/deps/mundo-x" CACHE PATH "Pinned Mundo X runtime checkout")
set(EXPECTED_ETHER_SHA "e2778d962af22f6f1a0794058dd4685fc2573966")
option(REVERSE_PC_ALLOW_UNPINNED_ETHER "Research-only: bypass upstream pin" OFF)
if(NOT EXISTS "${ETHER_SOURCE_DIR}/native/include/mundo_x/quantum_runtime.hpp")
  message(FATAL_ERROR "Missing upstream QuantumRuntime. Run scripts/setup-ether.sh")
endif()
find_package(Git REQUIRED)
execute_process(COMMAND "${GIT_EXECUTABLE}" rev-parse HEAD
  WORKING_DIRECTORY "${ETHER_SOURCE_DIR}" OUTPUT_VARIABLE ETHER_HEAD
  OUTPUT_STRIP_TRAILING_WHITESPACE RESULT_VARIABLE SHA_STATUS ERROR_QUIET)
if(NOT SHA_STATUS EQUAL 0)
  message(FATAL_ERROR "Mundo X dependency must be a Git checkout")
endif()
if(NOT REVERSE_PC_ALLOW_UNPINNED_ETHER AND NOT ETHER_HEAD STREQUAL EXPECTED_ETHER_SHA)
  message(FATAL_ERROR "Unreviewed upstream source: ${ETHER_HEAD}; expected ${EXPECTED_ETHER_SHA}")
endif()
add_executable(reverse_pc src/reverse_pc.cpp)
target_include_directories(reverse_pc PRIVATE "${ETHER_SOURCE_DIR}/native/include")
target_compile_definitions(reverse_pc PRIVATE REVERSE_PC_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}")
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  target_compile_options(reverse_pc PRIVATE -O2 -Wall -Wextra -Wpedantic)
endif()
include(CTest)
find_package(Python3 COMPONENTS Interpreter QUIET)
if(BUILD_TESTING AND Python3_Interpreter_FOUND)
  add_test(NAME reverse_pc_two_programs COMMAND "${Python3_EXECUTABLE}"
    "${CMAKE_CURRENT_SOURCE_DIR}/tests/verify.py"
    "$<TARGET_FILE:reverse_pc>" "${CMAKE_CURRENT_BINARY_DIR}/experiment")
  set_tests_properties(reverse_pc_two_programs PROPERTIES TIMEOUT 100)
endif()

# C++-only universality witness, using the same pinned Mundo X upstream as
# the main REVERSE-PC runtime. This is deliberately not a second quantum engine.
add_executable(reverse_pc_universality src/universality_probe.cpp)
target_include_directories(reverse_pc_universality PRIVATE
  "${ETHER_SOURCE_DIR}/native/include")
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  target_compile_options(reverse_pc_universality PRIVATE -O2 -Wall -Wextra -Wpedantic)
endif()
if(BUILD_TESTING)
  add_test(NAME reverse_pc_universality_gates
           COMMAND reverse_pc_universality --self-test)
  add_test(NAME reverse_pc_universality_resources
           COMMAND reverse_pc_universality --profile)
  set_tests_properties(reverse_pc_universality_gates
    reverse_pc_universality_resources PROPERTIES TIMEOUT 150)
endif()
