option (ENABLE_OPENCL "Use OpenCL optimizations" ON)

set (OPENCL_AMDSDK /opt/AMDAPPSDK-3.0 CACHE PATH "Installation path for the installed AMD OpenCL SDK, if used")

# Options used when building the project
find_library (LIB_OPENCL OpenCL)
if (NOT LIB_OPENCL)
    # Attempt with AMD's OpenCL SDK
    find_library (LIB_OPENCL OpenCL PATHS ${OPENCL_AMDSDK}/lib/x86_64/)
    if (NOT LIB_OPENCL)
        set (ENABLE_OPENCL OFF)
    else ()
        # Found, set the required include path.
        set (OPENCL_INCLUDE_PATH ${OPENCL_AMDSDK}/include CACHE PATH "AMD OpenCL SDK Header include path")
        set (OPENCL_COMPILATION_OPTIONS
            -Wno-ignored-attributes
            -Wno-deprecated-declarations
            CACHE STRING "AMD OpenCL SDK Compilation Option Requirements")
        message ("OpenCL support found in the AMD SDK")
    endif ()
endif ()

message ("OpenCL Support is: ${ENABLE_OPENCL}")

if (ENABLE_OPENCL)
    message ("    libOpenCL: ${LIB_OPENCL}")
    message ("    Includes:  ${OPENCL_INCLUDE_PATH}")
    message ("    Options:   ${OPENCL_COMPILATION_OPTIONS}")
endif ()

if (ENABLE_OPENCL)
    target_compile_definitions (qrack PUBLIC CL_HPP_TARGET_OPENCL_VERSION=200)
    target_compile_definitions (qrack PUBLIC CL_HPP_MINIMUM_OPENCL_VERSION=100)

    # Include the necessary options and libraries to link against
    target_include_directories (qrack PUBLIC ${PROJECT_BINARY_DIR} ${OPENCL_INCLUDE_PATH})
    target_compile_options (qrack PUBLIC ${OPENCL_COMPILATION_OPTIONS})
    target_link_libraries (unittest ${LIB_OPENCL})
    target_link_libraries (benchmarks ${LIB_OPENCL})

    # Build the OpenCL command files
    find_program (XXD_BIN xxd)
    file (GLOB_RECURSE COMPILABLE_RESOURCES "src/qengine/*.cl")
    foreach (INPUT_FILE ${COMPILABLE_RESOURCES})
        get_filename_component (INPUT_NAME ${INPUT_FILE} NAME)
        get_filename_component (INPUT_BASENAME ${INPUT_FILE} NAME_WE)
        get_filename_component (INPUT_DIR ${INPUT_FILE} DIRECTORY)

        set (OUTPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/include/${INPUT_BASENAME}cl.hpp)

        message (" Creating XXD Rule for ${INPUT_FILE} -> ${OUTPUT_FILE}")
        add_custom_command (
            WORKING_DIRECTORY ${INPUT_DIR}
            OUTPUT ${OUTPUT_FILE}
            COMMAND ${XXD_BIN} -i ${INPUT_NAME} > ${OUTPUT_FILE}
            COMMENT "Building OpenCL Commands in ${INPUT_FILE}"
            )
        list (APPEND COMPILED_RESOURCES ${OUTPUT_FILE})
    endforeach ()

    # Add the OpenCL objects to the library
    target_sources (qrack PRIVATE
        ${COMPILED_RESOURCES}
        src/common/oclengine.cpp
        src/qengine/opencl.cpp
        src/qengine/opencl_multi.cpp
        )

else (ENABLE_OPENCL)
    target_compile_definitions (qrack PUBLIC ENABLE_OPENCL=0)
endif (ENABLE_OPENCL)
