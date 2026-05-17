# tests/CMakeLists.txt
include(FetchContent)
FetchContent_Declare(
    Catch2
    GIT_REPOSITORY https://github.com/catchorg/Catch2.git
    GIT_TAG v3.4.0
)
FetchContent_MakeAvailable(Catch2)

add_executable(test_hb
    test_lexer.cpp
    test_parser.cpp
    test_higher_runtime.cpp
    test_lower_runtime.cpp
)
target_link_libraries(test_hb PRIVATE hb_core Catch2::Catch2WithMain)
target_include_directories(test_hb PRIVATE ../include)
file(COPY fixtures DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
add_test(NAME hb_tests COMMAND test_hb)
