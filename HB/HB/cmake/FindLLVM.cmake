if(NOT LLVM_CONFIG_EXECUTABLE)
  find_program(LLVM_CONFIG_EXECUTABLE
        NAMES llvm-config llvm-config-17 llvm-config-16 llvm-config-15
        HINTS
            ${LLVM_ROOT_DIR}/bin
            ENV LLVM_ROOT
            ENV LLVM_DIR
        PATH_SUFFIXES bin
        DOC "Path to llvm-config"
    )
endif()
mark_as_advanced(LLVM_CONFIG_EXECUTABLE)

if(LLVM_CONFIG_EXECUTABLE)
  # Version
  execute_process(
        COMMAND ${LLVM_CONFIG_EXECUTABLE} --version
        OUTPUT_VARIABLE LLVM_VERSION_STRING
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  set(LLVM_VERSION ${LLVM_VERSION_STRING})

  # Include directory
  execute_process(
        COMMAND ${LLVM_CONFIG_EXECUTABLE} --includedir
        OUTPUT_VARIABLE LLVM_INCLUDE_DIRS
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  if(NOT LLVM_INCLUDE_DIRS)
    execute_process(
            COMMAND ${LLVM_CONFIG_EXECUTABLE} --cppflags
            OUTPUT_VARIABLE CPPFLAGS
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    string(REGEX MATCHALL "-I[^ ]+" _incs ${CPPFLAGS})
    set(LLVM_INCLUDE_DIRS)
    foreach(_i ${_incs})
      string(REPLACE "-I" "" _i ${_i})
      list(APPEND LLVM_INCLUDE_DIRS ${_i})
    endforeach()
  endif()

  # C++ flags and definitions
  execute_process(
        COMMAND ${LLVM_CONFIG_EXECUTABLE} --cxxflags
        OUTPUT_VARIABLE LLVM_CXX_FLAGS
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  separate_arguments(LLVM_CXX_FLAGS_LIST UNIX_COMMAND "${LLVM_CXX_FLAGS}")
  set(LLVM_DEFINITIONS)
  foreach(flag ${LLVM_CXX_FLAGS_LIST})
    if(flag MATCHES "^-D")
      string(REGEX REPLACE "^-D" "" def ${flag})
      list(APPEND LLVM_DEFINITIONS ${def})
    endif()
  endforeach()

  # Linker flags
  execute_process(
        COMMAND ${LLVM_CONFIG_EXECUTABLE} --ldflags
        OUTPUT_VARIABLE LLVM_LDFLAGS
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

  # Libraries
  if(LLVM_FIND_COMPONENTS)
    set(LLVM_COMPONENTS ${LLVM_FIND_COMPONENTS})
    foreach(comp ${LLVM_COMPONENTS})
      execute_process(
                COMMAND ${LLVM_CONFIG_EXECUTABLE} --libs ${comp}
                OUTPUT_VARIABLE lib_output
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
      separate_arguments(lib_list UNIX_COMMAND "${lib_output}")
      foreach(lib ${lib_list})
        if(lib MATCHES "^-l" AND NOT lib IN_LIST LLVM_LIBRARIES)
          list(APPEND LLVM_LIBRARIES ${lib})
        endif()
      endforeach()
    endforeach()
    execute_process(
            COMMAND ${LLVM_CONFIG_EXECUTABLE} --system-libs
            OUTPUT_VARIABLE SYS_LIBS
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    separate_arguments(SYS_LIBS_LIST UNIX_COMMAND "${SYS_LIBS}")
    foreach(l ${SYS_LIBS_LIST})
      if(l MATCHES "^-l" AND NOT l IN_LIST LLVM_LIBRARIES)
        list(APPEND LLVM_LIBRARIES ${l})
      endif()
    endforeach()
  else()
    execute_process(
            COMMAND ${LLVM_CONFIG_EXECUTABLE} --libs core support
            OUTPUT_VARIABLE lib_output
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    separate_arguments(lib_list UNIX_COMMAND "${lib_output}")
    set(LLVM_LIBRARIES)
    foreach(lib ${lib_list})
      if(lib MATCHES "^-l")
        list(APPEND LLVM_LIBRARIES ${lib})
      endif()
    endforeach()
    execute_process(
            COMMAND ${LLVM_CONFIG_EXECUTABLE} --system-libs
            OUTPUT_VARIABLE SYS_LIBS
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    separate_arguments(SYS_LIBS_LIST UNIX_COMMAND "${SYS_LIBS}")
    foreach(l ${SYS_LIBS_LIST})
      if(l MATCHES "^-l" AND NOT l IN_LIST LLVM_LIBRARIES)
        list(APPEND LLVM_LIBRARIES ${l})
      endif()
    endforeach()
  endif()

  set(LLVM_FOUND TRUE)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LLVM
    REQUIRED_VARS LLVM_INCLUDE_DIRS LLVM_LIBRARIES LLVM_CONFIG_EXECUTABLE
    VERSION_VAR LLVM_VERSION
    HANDLE_COMPONENTS
)
