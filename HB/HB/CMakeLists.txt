# Корневой CMakeLists.txt
cmake_minimum_required(VERSION 3.16)
project(hb VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

option(HB_BUILD_TESTS "Build tests" ON)
option(HB_ENABLE_COMPILER "Enable compiler backends" ON)

add_library(hb_core
    src/frontend/lexer.cpp
    src/frontend/parser.cpp
    src/frontend/ast.cpp
    src/mode/mode_manager.cpp
    src/mode/constraints.cpp
    src/runtime/environment.cpp
    src/runtime/interpreter.cpp
    src/runtime/value.cpp
    src/runtime/higher/evaluator.cpp
    src/runtime/lower/evaluator.cpp
    src/runtime/lower/checker.cpp
    src/utils/error.cpp
    src/utils/logger.cpp
)
target_include_directories(hb_core PUBLIC include)

add_executable(hb src/main.cpp)
target_link_libraries(hb PRIVATE hb_core)

if(HB_ENABLE_COMPILER)
  find_package(LLVM QUIET COMPONENTS core support native)
  if(LLVM_FOUND)
    message(STATUS "LLVM found (${LLVM_VERSION}), enabling llvm_backend")
    add_library(hb_compiler
            src/compiler/ir.cpp
            src/compiler/codegen/llvm_backend.cpp
        )
    target_include_directories(hb_compiler PUBLIC include)
    target_link_libraries(hb_compiler PUBLIC hb_core ${LLVM_LIBRARIES})
    target_compile_definitions(hb_compiler PRIVATE ${LLVM_DEFINITIONS})
    target_compile_options(hb_compiler PRIVATE ${LLVM_CXX_FLAGS})
    target_include_directories(hb_compiler SYSTEM PRIVATE ${LLVM_INCLUDE_DIRS})
    target_link_libraries(hb PRIVATE hb_compiler)
  else()
    message(STATUS "LLVM not found, building without compiler")
  endif()
endif()

if(HB_BUILD_TESTS)
  enable_testing()
  add_subdirectory(tests)
endif()
