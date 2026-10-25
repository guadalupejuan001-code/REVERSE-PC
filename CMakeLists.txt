cmake_minimum_required(VERSION 3.16)
project(REVERSE_PC LANGUAGES CXX)
find_package(Threads REQUIRED)
link_libraries(Threads::Threads)
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
# The checkout stays byte-for-byte pinned. An explicit, hash-checked local
# compatibility extension fixes product-import limits and reuses metadata
# only inside QuantumRuntime's unpublished whole-program candidate.
find_package(Python3 COMPONENTS Interpreter REQUIRED)
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
  "${CMAKE_CURRENT_SOURCE_DIR}/scripts/prepare-ether-compat.py"
  "${CMAKE_CURRENT_SOURCE_DIR}/scripts/ether_integration.py")
execute_process(COMMAND "${Python3_EXECUTABLE}"
  "${CMAKE_CURRENT_SOURCE_DIR}/scripts/prepare-ether-compat.py"
  "${ETHER_SOURCE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/ether-compat"
  RESULT_VARIABLE COMPAT_STATUS)
if(NOT COMPAT_STATUS EQUAL 0)
  message(FATAL_ERROR "Failed to prepare reviewed Ether compatibility extension")
endif()
include_directories(BEFORE "${CMAKE_CURRENT_BINARY_DIR}/ether-compat")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/src")
# New overlay headers can shadow previously tracked upstream include paths.
# A script fingerprint in compile flags invalidates those existing objects too.
file(SHA256 "${CMAKE_CURRENT_SOURCE_DIR}/scripts/prepare-ether-compat.py" ETHER_COMPAT_SCRIPT_SHA)
file(SHA256 "${CMAKE_CURRENT_SOURCE_DIR}/scripts/ether_integration.py" ETHER_INTEGRATION_SHA)
add_compile_definitions(REVERSE_PC_INTEGRATION_SHA="${ETHER_INTEGRATION_SHA}" REVERSE_PC_HAVE_BOUNDED_PRODUCT_IMPORT=1
  REVERSE_PC_ETHER_EXTENSION_SHA="${ETHER_COMPAT_SCRIPT_SHA}")
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


# New adaptive product/block factorization over the original pinned Reduced backend.
# The existing runtime and universality executable are intentionally unchanged.
add_executable(reverse_pc_factorized src/factorization_benchmark.cpp)
target_include_directories(reverse_pc_factorized PRIVATE
  "${ETHER_SOURCE_DIR}/native/include")
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  target_compile_options(reverse_pc_factorized PRIVATE -O2 -Wall -Wextra -Wpedantic)
endif()
if(BUILD_TESTING)
  add_test(NAME reverse_pc_factorized_differential
    COMMAND reverse_pc_factorized --self-test)
  add_test(NAME reverse_pc_factorized_speed_and_precision
    COMMAND reverse_pc_factorized --benchmark)
  set_tests_properties(reverse_pc_factorized_differential
    reverse_pc_factorized_speed_and_precision PROPERTIES TIMEOUT 180)
endif()


# Characterization-only architecture audit (no changes to either engine).
add_executable(reverse_pc_architecture_audit tests/architecture_bottleneck_probe.cpp)
target_include_directories(reverse_pc_architecture_audit PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}/src"
  "${ETHER_SOURCE_DIR}/native/include")
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  target_compile_options(reverse_pc_architecture_audit PRIVATE
    -O2 -Wall -Wextra -Wpedantic)
endif()
if(BUILD_TESTING)
  add_test(NAME reverse_pc_architecture_characterization
    COMMAND reverse_pc_architecture_audit)
  set_tests_properties(reverse_pc_architecture_characterization PROPERTIES TIMEOUT 120)
endif()

# Restore the pending PR #5 audit without its obsolete CMake/workflow context.
add_executable(reverse_pc_rigorous_reduced tests/rigor_reduced.cpp)
target_include_directories(reverse_pc_rigorous_reduced PRIVATE "${ETHER_SOURCE_DIR}/native/include")
add_executable(reverse_pc_refactorization tests/refactorization.cpp)
target_include_directories(reverse_pc_refactorization PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src" "${ETHER_SOURCE_DIR}/native/include")
if(BUILD_TESTING)
  add_test(NAME reverse_pc_rigorous_reduced COMMAND reverse_pc_rigorous_reduced)
  add_test(NAME reverse_pc_refactorization COMMAND reverse_pc_refactorization)
  set_tests_properties(reverse_pc_rigorous_reduced reverse_pc_refactorization PROPERTIES TIMEOUT 180)
  if(Python3_Interpreter_FOUND)
    add_test(NAME reverse_pc_rigorous_cli COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/tests/rigor_cli.py" "$<TARGET_FILE:reverse_pc>" "${CMAKE_CURRENT_BINARY_DIR}/rigor_data")
    set_tests_properties(reverse_pc_rigorous_cli PROPERTIES TIMEOUT 180)
  endif()
endif()

add_executable(reverse_pc_resource_probe tests/resource_probe.cpp)
target_include_directories(reverse_pc_resource_probe PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src" "${ETHER_SOURCE_DIR}/native/include")

add_executable(reverse_pc_history_transfer tests/history_transfer.cpp)
target_include_directories(reverse_pc_history_transfer PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src" "${ETHER_SOURCE_DIR}/native/include")
if(BUILD_TESTING)
  add_test(NAME reverse_pc_history_transfer COMMAND reverse_pc_history_transfer)
  set_tests_properties(reverse_pc_history_transfer PROPERTIES TIMEOUT 180)
endif()

# Compile the exact same test source twice; upstream has include precedence
# only in the reference target, so it remains a separate original-code oracle.
add_executable(reverse_pc_runtime_reference tests/runtime_contract.cpp)
target_include_directories(reverse_pc_runtime_reference BEFORE PRIVATE "${ETHER_SOURCE_DIR}/native/include")
add_executable(reverse_pc_runtime_contract tests/runtime_contract.cpp)
target_include_directories(reverse_pc_runtime_contract PRIVATE "${ETHER_SOURCE_DIR}/native/include")
if(BUILD_TESTING)
  add_test(NAME reverse_pc_xi_runtime_equivalence COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/tests/compare_runtime.py" "$<TARGET_FILE:reverse_pc_runtime_reference>" "$<TARGET_FILE:reverse_pc_runtime_contract>")
  set_tests_properties(reverse_pc_xi_runtime_equivalence PROPERTIES TIMEOUT 180)
endif()

add_executable(reverse_pc_state_transfer tests/current_state_transfer.cpp)
target_include_directories(reverse_pc_state_transfer PRIVATE "${ETHER_SOURCE_DIR}/native/include")
if(BUILD_TESTING)
  add_test(NAME reverse_pc_state_transfer COMMAND reverse_pc_state_transfer)
  set_tests_properties(reverse_pc_state_transfer PROPERTIES TIMEOUT 240)
endif()

# Rebuild the immediately previous main with its exact verified extensions,
# rather than calling the unoptimized raw upstream a "previous main" baseline.
option(REVERSE_PC_BUILD_PREVIOUS_MAIN_REFERENCE "Build comparison/migration reference from preserved git history" ${BUILD_TESTING})
if(REVERSE_PC_BUILD_PREVIOUS_MAIN_REFERENCE)
  set(REVERSE_PC_PREVIOUS_MAIN "0d8926bd65b01877eeef6e3172259284f8944a88")
  execute_process(COMMAND "${GIT_EXECUTABLE}" show "${REVERSE_PC_PREVIOUS_MAIN}:scripts/prepare-ether-compat.py" WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" OUTPUT_VARIABLE PREVIOUS_COMPAT RESULT_VARIABLE PREVIOUS_STATUS)
  if(NOT PREVIOUS_STATUS EQUAL 0)
    message(FATAL_ERROR "Previous-main reference needs git history; fetch it or disable REVERSE_PC_BUILD_PREVIOUS_MAIN_REFERENCE")
  endif()
  file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/previous-main-compat.py" "${PREVIOUS_COMPAT}")
  execute_process(COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_BINARY_DIR}/previous-main-compat.py" "${ETHER_SOURCE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/previous-main-compat" RESULT_VARIABLE PREVIOUS_STATUS)
  if(NOT PREVIOUS_STATUS EQUAL 0)
    message(FATAL_ERROR "Previous-main compatibility verification failed")
  endif()
  execute_process(COMMAND "${GIT_EXECUTABLE}" show "${REVERSE_PC_PREVIOUS_MAIN}:src/reverse_pc.cpp" WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" OUTPUT_VARIABLE PREVIOUS_CLI RESULT_VARIABLE PREVIOUS_STATUS)
  if(NOT PREVIOUS_STATUS EQUAL 0)
    message(FATAL_ERROR "Previous CLI source unavailable")
  endif()
  file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/previous-main-cli.cpp" "${PREVIOUS_CLI}")
  add_executable(reverse_pc_previous_cli "${CMAKE_CURRENT_BINARY_DIR}/previous-main-cli.cpp")
  target_compile_definitions(reverse_pc_previous_cli PRIVATE REVERSE_PC_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}")
  target_include_directories(reverse_pc_previous_cli BEFORE PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/previous-main-compat" "${ETHER_SOURCE_DIR}/native/include")
endif()

add_executable(reverse_pc_integrated_correctness tests/integrated_correctness.cpp)
target_include_directories(reverse_pc_integrated_correctness PRIVATE "${ETHER_SOURCE_DIR}/native/include")
if(BUILD_TESTING)
  add_test(NAME reverse_pc_integrated_correctness COMMAND reverse_pc_integrated_correctness)
  set_tests_properties(reverse_pc_integrated_correctness PROPERTIES TIMEOUT 300)
endif()


if(BUILD_TESTING)
  if(TARGET reverse_pc_previous_cli)
    add_test(NAME reverse_pc_integrated_cli COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/tests/integrated_cli.py" "$<TARGET_FILE:reverse_pc>" "${CMAKE_CURRENT_BINARY_DIR}/integrated-cli" "$<TARGET_FILE:reverse_pc_previous_cli>")
  else()
    add_test(NAME reverse_pc_integrated_cli COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/tests/integrated_cli.py" "$<TARGET_FILE:reverse_pc>" "${CMAKE_CURRENT_BINARY_DIR}/integrated-cli")
  endif()
  set_tests_properties(reverse_pc_integrated_cli PROPERTIES TIMEOUT 600)
endif()
