cmake_minimum_required(VERSION 3.12)

# CVBasic build functions for RetroPIPE

include(ExternalProject)
set(PYTHON python3)

# Define a job pool with 1 slot to serialize CVBasic compilation
# This prevents multiple CVBasic instances from conflicting on cvbasic_temporary.asm
set_property(GLOBAL PROPERTY JOB_POOLS cvbasic_pool=1)

# Find CVBasic tools with fallback paths
function(find_cvbasic_tools)
    find_program(CVBASIC_EXECUTABLE cvbasic
        PATHS
            ${CMAKE_SOURCE_DIR}/tools/cvbasic
            ${CMAKE_SOURCE_DIR}/../CVBasic/build/Release
            ENV PATH
        DOC "CVBasic compiler executable"
    )

    find_program(GASM80_EXECUTABLE gasm80
        PATHS
            ${CMAKE_SOURCE_DIR}/tools/cvbasic
            ${CMAKE_SOURCE_DIR}/../gasm80/build/Release
            ENV PATH
        DOC "GASM80 assembler executable"
    )

    if(WIN32)
        find_program(XAS99_SCRIPT xas99.py
            PATHS c:/tools/xdt99
            DOC "XDT99 XAS99 assembler script"
        )
    endif()

    # Set parent scope variables
    set(CVBASIC_FOUND ${CVBASIC_EXECUTABLE} PARENT_SCOPE)
    set(GASM80_FOUND ${GASM80_EXECUTABLE} PARENT_SCOPE)
    set(XAS99_FOUND ${XAS99_SCRIPT} PARENT_SCOPE)

    if(CVBASIC_EXECUTABLE)
        message(STATUS "Found CVBasic: ${CVBASIC_EXECUTABLE}")
    else()
        message(WARNING "CVBasic not found - builds will fail")
    endif()

    if(GASM80_EXECUTABLE)
        message(STATUS "Found GASM80: ${GASM80_EXECUTABLE}")
    else()
        message(WARNING "GASM80 not found - some platform builds will fail")
    endif()

    if(XAS99_SCRIPT)
        message(STATUS "Found XAS99: ${XAS99_SCRIPT}")
    else()
        message(STATUS "XAS99 not found - TI-99 builds will be limited")
    endif()
endfunction()

# Setup CVBasic toolchain - either by finding existing tools or building from source
#
# Version control:
# Use cmake cache variables to specify tool versions:
#   -DCVBASIC_GIT_TAG=v1.2.3    (default: master)
#   -DGASM80_GIT_TAG=v0.9.1     (default: master)
#   -DXDT99_GIT_TAG=3.5.0       (default: master)
#
# Examples:
#   cmake .. -DCVBASIC_GIT_TAG=v1.2.3
#   cmake .. -DGASM80_GIT_TAG=v0.9.1 -DXDT99_GIT_TAG=3.5.0
#
function(setup_cvbasic_tools)
    option(BUILD_TOOLS_FROM_SOURCE "Build CVBasic, gasm80 and XDT99 from source" ON)

    # Tool version/tag configuration
    set(CVBASIC_GIT_TAG "master" CACHE STRING "CVBasic git tag/branch/commit")
    set(GASM80_GIT_TAG "master" CACHE STRING "GASM80 git tag/branch/commit")
    set(XDT99_GIT_TAG "master" CACHE STRING "XDT99 git tag/branch/commit")
    set(PLETTER_GIT_TAG "master" CACHE STRING "Pletter git tag/branch/commit")

    if(BUILD_TOOLS_FROM_SOURCE)
        # Use system default compilers for host builds
        if(WIN32)
            # On Windows, let CMake find the default system compiler
            set(HOST_CMAKE_ARGS "")
        else()
            # On Unix, explicitly specify common compiler paths
            set(HOST_CMAKE_ARGS
                "-DCMAKE_C_COMPILER=gcc"
                "-DCMAKE_CXX_COMPILER=g++"
            )
        endif()

        # Build CVBasic from visrealm fork using separate process to avoid cross-compilation issues
        ExternalProject_Add(CVBasic_external
            GIT_REPOSITORY https://github.com/visrealm/CVBasic.git
            GIT_TAG ${CVBASIC_GIT_TAG}
            CONFIGURE_COMMAND ""
            BUILD_COMMAND ""
            INSTALL_COMMAND
                ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/external/CVBasic/bin &&
                ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>
                    ${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/external/CVBasic -B build &&
                ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>
                    ${CMAKE_COMMAND} --build build --config Release &&
                ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>
                    ${CMAKE_COMMAND} --install build --config Release &&
                ${CMAKE_COMMAND} -E copy_if_different <SOURCE_DIR>/linkticart.py ${CMAKE_BINARY_DIR}/external/CVBasic/
        )

        # Build gasm80 from visrealm fork using separate process to avoid cross-compilation issues
        ExternalProject_Add(gasm80_external
            GIT_REPOSITORY https://github.com/visrealm/gasm80.git
            GIT_TAG ${GASM80_GIT_TAG}
            CONFIGURE_COMMAND ""
            BUILD_COMMAND ""
            INSTALL_COMMAND
                ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/external/gasm80/bin &&
                ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>
                    ${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/external/gasm80 -B build &&
                ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>
                    ${CMAKE_COMMAND} --build build --config Release &&
                ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>
                    ${CMAKE_COMMAND} --install build --config Release
        )

        # Build XDT99 tools (Python-based)
        ExternalProject_Add(XDT99_external
            GIT_REPOSITORY https://github.com/endlos99/xdt99.git
            GIT_TAG ${XDT99_GIT_TAG}
            CONFIGURE_COMMAND ""
            BUILD_COMMAND ""
            INSTALL_COMMAND
                ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> ${CMAKE_BINARY_DIR}/external/xdt99
        )

        # Build Pletter compression tool (simple C file - create CMakeLists.txt on-the-fly)
        file(WRITE ${CMAKE_BINARY_DIR}/pletter_CMakeLists.txt
"cmake_minimum_required(VERSION 3.5)
project(pletter C)
set(CMAKE_C_STANDARD 11)
add_executable(pletter pletter.c)
# Define MAX_PATH for all platforms (MSVC needs 260, Unix typically uses 4096 or PATH_MAX)
if(MSVC)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
    target_compile_definitions(pletter PRIVATE MAX_PATH=260)
else()
    # Linux/macOS/Unix - use PATH_MAX equivalent
    target_compile_definitions(pletter PRIVATE MAX_PATH=4096)
endif()
install(TARGETS pletter RUNTIME DESTINATION bin)
")
        ExternalProject_Add(Pletter_external
            GIT_REPOSITORY https://github.com/nanochess/Pletter.git
            GIT_TAG ${PLETTER_GIT_TAG}
            CONFIGURE_COMMAND ""
            BUILD_COMMAND ""
            INSTALL_COMMAND
                ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/external/pletter/bin &&
                ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/pletter_CMakeLists.txt <SOURCE_DIR>/CMakeLists.txt &&
                ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>
                    ${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/external/pletter -B build &&
                ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>
                    ${CMAKE_COMMAND} --build build --config Release &&
                ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>
                    ${CMAKE_COMMAND} --install build --config Release
        )

        # Set tool paths for external builds
        set(CVBASIC_EXE "${CMAKE_BINARY_DIR}/external/CVBasic/bin/cvbasic" PARENT_SCOPE)
        set(GASM80_EXE "${CMAKE_BINARY_DIR}/external/gasm80/bin/gasm80" PARENT_SCOPE)
        set(XAS99_SCRIPT "${CMAKE_BINARY_DIR}/external/xdt99/xas99.py" PARENT_SCOPE)
        set(LINKTICART_SCRIPT "${CMAKE_BINARY_DIR}/external/CVBasic/linkticart.py" PARENT_SCOPE)
        set(PLETTER_EXE "${CMAKE_BINARY_DIR}/external/pletter/bin/pletter" PARENT_SCOPE)

        # Add dependencies to all CVBasic targets
        set(TOOL_DEPENDENCIES CVBasic_external gasm80_external XDT99_external Pletter_external PARENT_SCOPE)

        message(STATUS "CVBasic tools will be built from source")
        message(STATUS "CVBasic version/tag: ${CVBASIC_GIT_TAG}")
        message(STATUS "GASM80 version/tag: ${GASM80_GIT_TAG}")
        message(STATUS "XDT99 version/tag: ${XDT99_GIT_TAG}")
        message(STATUS "Pletter version/tag: ${PLETTER_GIT_TAG}")
    else()
        # Find required tools (original behavior)
        find_program(CVBASIC_EXE cvbasic PATHS ${CMAKE_SOURCE_DIR}/tools/cvbasic ${CMAKE_SOURCE_DIR}/../CVBasic/build/Release REQUIRED)
        find_program(GASM80_EXE gasm80 PATHS ${CMAKE_SOURCE_DIR}/tools/cvbasic ${CMAKE_SOURCE_DIR}/../gasm80/build/Release REQUIRED)

        # Find linkticart.py in local CVBasic installation or fallback to bundled version
        find_file(LINKTICART_SCRIPT linkticart.py
            PATHS
                ${CMAKE_SOURCE_DIR}/../CVBasic
                ${CMAKE_SOURCE_DIR}/tools/cvbasic
            DOC "CVBasic linkticart.py script"
        )
        if(NOT LINKTICART_SCRIPT)
            set(LINKTICART_SCRIPT "${CMAKE_SOURCE_DIR}/tools/cvbasic/linkticart.py")
        endif()

        # Platform-specific tool paths
        if(WIN32)
            find_program(XAS99_SCRIPT xas99.py PATHS c:/tools/xdt99)
            if(NOT XAS99_SCRIPT)
                message(WARNING "XAS99 not found, TI-99 builds will be skipped")
            endif()
        else()
            find_program(XAS99_SCRIPT xas99.py PATHS /usr/local/bin /opt/xdt99)
            if(NOT XAS99_SCRIPT)
                message(WARNING "XAS99 not found, TI-99 builds will be skipped")
            endif()
        endif()

        set(TOOL_DEPENDENCIES "" PARENT_SCOPE)

        message(STATUS "Using existing CVBasic tools")
        message(STATUS "CVBasic: ${CVBASIC_EXE}")
        message(STATUS "GASM80: ${GASM80_EXE}")
        message(STATUS "linkticart.py: ${LINKTICART_SCRIPT}")
        if(XAS99_SCRIPT)
            message(STATUS "XAS99: ${XAS99_SCRIPT}")
        else()
            message(STATUS "XAS99: NOT FOUND (TI-99 builds will be limited)")
        endif()
    endif()
endfunction()

# Assemble TI-99 assembly file with XAS99 and link to cartridge format
# Creates a custom command that assembles the .a99 file and links it to a .bin cartridge
function(cvbasic_assemble_ti99 ASM_FILE ROM_OUTPUT CART_TITLE ASM_DIR ROMS_DIR TOOL_DEPS)
    if(XAS99_SCRIPT)
        # XAS99 generates .bin file based on assembly filename
        get_filename_component(ASM_NAME "${ASM_FILE}" NAME_WE)
        add_custom_command(
            OUTPUT "${ROMS_DIR}/${ROM_OUTPUT}"
            COMMAND ${PYTHON} "${XAS99_SCRIPT}" -b -R "${ASM_DIR}/${ASM_FILE}"
            COMMAND ${PYTHON} "${LINKTICART_SCRIPT}"
                    "${ASM_DIR}/${ASM_NAME}.bin"
                    "${ROMS_DIR}/${ROM_OUTPUT}"
                    "${CART_TITLE}"
            DEPENDS "${ASM_DIR}/${ASM_FILE}" ${TOOL_DEPS}
            WORKING_DIRECTORY "${ASM_DIR}"
            COMMENT "Assembling TI-99 cartridge: ${ROM_OUTPUT}"
            VERBATIM
        )
    else()
        # Create a dummy target when XAS99 is not available
        add_custom_command(
            OUTPUT "${ROMS_DIR}/${ROM_OUTPUT}"
            COMMAND ${CMAKE_COMMAND} -E echo "XAS99 not available, skipping TI-99 build"
            COMMAND ${CMAKE_COMMAND} -E touch "${ROMS_DIR}/${ROM_OUTPUT}"
            DEPENDS "${ASM_DIR}/${ASM_FILE}"
            COMMENT "Skipping TI-99 build (XAS99 not found)"
        )
    endif()
endfunction()

# Assemble with GASM80 (for most platforms)
function(cvbasic_assemble_gasm80 ASM_FILE ROM_OUTPUT ASM_DIR ROMS_DIR TOOL_DEPS)
    add_custom_command(
        OUTPUT "${ROMS_DIR}/${ROM_OUTPUT}"
        COMMAND ${GASM80_EXE} "${ASM_DIR}/${ASM_FILE}" -o "${ROMS_DIR}/${ROM_OUTPUT}"
        DEPENDS "${ASM_DIR}/${ASM_FILE}" ${TOOL_DEPS}
        WORKING_DIRECTORY "${ASM_DIR}"
        COMMENT "Assembling with GASM80: ${ROM_OUTPUT}"
        VERBATIM
    )
endfunction()

# Package NABU MAME file into .npz format
# Takes a .nabu file and packages it into a .npz (zip) file
function(cvbasic_package_nabu_mame NABU_FILE OUTPUT_NPZ SOURCE_DIR OUTPUT_DIR)
    add_custom_command(
        OUTPUT "${OUTPUT_DIR}/${OUTPUT_NPZ}"
        COMMAND ${CMAKE_COMMAND} -E tar "cf" "${OUTPUT_DIR}/${OUTPUT_NPZ}.tmp.zip" --format=zip "${NABU_FILE}"
        COMMAND ${CMAKE_COMMAND} -E copy "${OUTPUT_DIR}/${OUTPUT_NPZ}.tmp.zip" "${OUTPUT_DIR}/${OUTPUT_NPZ}"
        COMMAND ${CMAKE_COMMAND} -E remove "${OUTPUT_DIR}/${OUTPUT_NPZ}.tmp.zip"
        DEPENDS "${SOURCE_DIR}/${NABU_FILE}"
        WORKING_DIRECTORY "${SOURCE_DIR}"
        COMMENT "Packaging NABU MAME: ${OUTPUT_NPZ}"
        VERBATIM
    )
endfunction()

# Setup CVBasic project configuration
# Call this once at the beginning of your CMakeLists.txt to set project-wide defaults
#
# Parameters:
#   SOURCE_FILE - Main .bas source file
#   SOURCE_DIR - Directory containing source files
#   LIB_DIR - Directory containing library files (optional, defaults to ${SOURCE_DIR}/lib)
#   ASM_DIR - Directory for intermediate assembly files
#   ROMS_DIR - Directory for final ROM files
#   CART_TITLE - Cartridge title (for TI-99 only)
#   VERSION - Version string for ROM filenames (optional)
#   PLETTER_TARGET - Optional pletter compression target to auto-depend on
#   DEPENDENCIES - List of source file dependencies
#   TOOL_DEPS - List of tool dependencies (from setup_cvbasic_tools)
#
function(cvbasic_setup_project)
    cmake_parse_arguments(PROJ "" "SOURCE_FILE;SOURCE_DIR;LIB_DIR;ASM_DIR;ROMS_DIR;CART_TITLE;VERSION;PLETTER_TARGET" "DEPENDENCIES;TOOL_DEPS" ${ARGN})

    # Set defaults
    if(NOT PROJ_LIB_DIR)
        set(PROJ_LIB_DIR "${PROJ_SOURCE_DIR}/lib")
    endif()

    # Store in parent scope
    set(CVBASIC_PROJECT_SOURCE_FILE "${PROJ_SOURCE_FILE}" PARENT_SCOPE)
    set(CVBASIC_PROJECT_SOURCE_DIR "${PROJ_SOURCE_DIR}" PARENT_SCOPE)
    set(CVBASIC_PROJECT_LIB_DIR "${PROJ_LIB_DIR}" PARENT_SCOPE)
    set(CVBASIC_PROJECT_ASM_DIR "${PROJ_ASM_DIR}" PARENT_SCOPE)
    set(CVBASIC_PROJECT_ROMS_DIR "${PROJ_ROMS_DIR}" PARENT_SCOPE)
    set(CVBASIC_PROJECT_CART_TITLE "${PROJ_CART_TITLE}" PARENT_SCOPE)
    set(CVBASIC_PROJECT_VERSION "${PROJ_VERSION}" PARENT_SCOPE)
    set(CVBASIC_PROJECT_PLETTER_TARGET "${PROJ_PLETTER_TARGET}" PARENT_SCOPE)
    set(CVBASIC_PROJECT_DEPENDENCIES "${PROJ_DEPENDENCIES}" PARENT_SCOPE)
    set(CVBASIC_PROJECT_TOOL_DEPS "${PROJ_TOOL_DEPS}" PARENT_SCOPE)
endfunction()

# Simplified CVBasic target builder
# Auto-generates ROM names, ASM names, and descriptions based on platform
#
# Usage:
#   cvbasic_add_target(TARGET_NAME PLATFORM PLATFORM_FLAG [DEFINES defines] [ROM rom_output] [ASM asm_output] [DESCRIPTION desc] [OUTPUT_DIR dir])
#
# Examples:
#   cvbasic_add_target(coleco cv "")
#   cvbasic_add_target(ti99 ti994a --ti994a)
#   cvbasic_add_target(nabu_mame nabu --nabu DEFINES "-DTMS9918_TESTING=1" ROM "000001.nabu" OUTPUT_DIR "${ASM_DIR}")
#
function(cvbasic_add_target TARGET_NAME PLATFORM PLATFORM_FLAG)
    cmake_parse_arguments(TGT "" "DEFINES;ROM;ASM;DESCRIPTION;OUTPUT_DIR" "" ${ARGN})

    # Extract project name from source file
    get_filename_component(PROJECT_NAME "${CVBASIC_PROJECT_SOURCE_FILE}" NAME_WE)

    # Auto-generate ROM name if not provided
    if(NOT TGT_ROM)
        # Map target names to ROM name suffixes
        set(ROM_SUFFIX "${TARGET_NAME}")
        if(TARGET_NAME STREQUAL "coleco")
            set(ROM_SUFFIX "cv")
        elseif(TARGET_NAME STREQUAL "creativision")
            set(ROM_SUFFIX "crv")
        elseif(TARGET_NAME STREQUAL "sg1000")
            set(ROM_SUFFIX "sc3000")
        endif()

        # Build ROM name with platform-specific extension
        if(PLATFORM STREQUAL "cv")
            set(TGT_ROM "${PROJECT_NAME}_${CVBASIC_PROJECT_VERSION}_${ROM_SUFFIX}.rom")
        elseif(PLATFORM STREQUAL "ti994a")
            set(TGT_ROM "${PROJECT_NAME}_${CVBASIC_PROJECT_VERSION}_${ROM_SUFFIX}_8.bin")
        elseif(PLATFORM STREQUAL "msx")
            set(TGT_ROM "${PROJECT_NAME}_${CVBASIC_PROJECT_VERSION}_${ROM_SUFFIX}.rom")
        elseif(PLATFORM STREQUAL "nabu")
            # NABU is special - no suffix for regular nabu target
            if(TARGET_NAME STREQUAL "nabu")
                set(TGT_ROM "${PROJECT_NAME}_${CVBASIC_PROJECT_VERSION}.nabu")
            else()
                set(TGT_ROM "${PROJECT_NAME}_${CVBASIC_PROJECT_VERSION}_${ROM_SUFFIX}.nabu")
            endif()
        elseif(PLATFORM STREQUAL "sg1000" OR PLATFORM STREQUAL "sc3000")
            set(TGT_ROM "${PROJECT_NAME}_${CVBASIC_PROJECT_VERSION}_${ROM_SUFFIX}.sg")
        elseif(PLATFORM STREQUAL "creativision" OR PLATFORM STREQUAL "crv")
            set(TGT_ROM "${PROJECT_NAME}_${CVBASIC_PROJECT_VERSION}_${ROM_SUFFIX}.bin")
        else()
            set(TGT_ROM "${PROJECT_NAME}_${CVBASIC_PROJECT_VERSION}_${ROM_SUFFIX}.bin")
        endif()
    endif()

    # Auto-generate ASM name if not provided
    if(NOT TGT_ASM)
        get_filename_component(ROM_NAME "${TGT_ROM}" NAME_WE)
        if(PLATFORM_FLAG STREQUAL "--ti994a")
            set(TGT_ASM "${ROM_NAME}.a99")
        else()
            set(TGT_ASM "${ROM_NAME}.asm")
        endif()
    endif()

    # Auto-generate description if not provided
    if(NOT TGT_DESCRIPTION)
        # Platform-specific descriptions
        if(PLATFORM STREQUAL "cv")
            set(TGT_DESCRIPTION "ColecoVision")
        elseif(PLATFORM STREQUAL "ti994a")
            set(TGT_DESCRIPTION "TI-99/4A")
        elseif(PLATFORM STREQUAL "msx")
            # Try to infer MSX type from target name
            if(TARGET_NAME MATCHES "konami")
                set(TGT_DESCRIPTION "MSX Konami")
            elseif(TARGET_NAME MATCHES "asc")
                set(TGT_DESCRIPTION "MSX ASCII16")
            else()
                set(TGT_DESCRIPTION "MSX")
            endif()
        elseif(PLATFORM STREQUAL "nabu")
            if(TARGET_NAME MATCHES "mame")
                set(TGT_DESCRIPTION "NABU MAME")
            else()
                set(TGT_DESCRIPTION "NABU")
            endif()
        elseif(PLATFORM STREQUAL "sc3000" OR PLATFORM STREQUAL "sg1000")
            set(TGT_DESCRIPTION "SG-1000/SC-3000")
        elseif(PLATFORM STREQUAL "crv" OR PLATFORM STREQUAL "creativision")
            set(TGT_DESCRIPTION "CreatiVision")
        else()
            set(TGT_DESCRIPTION "${PLATFORM}")
        endif()
    endif()

    # CVBasic compilation
    set(CVBASIC_COMMAND ${CVBASIC_EXE} ${PLATFORM_FLAG})
    if(TGT_DEFINES)
        list(APPEND CVBASIC_COMMAND ${TGT_DEFINES})
    endif()
    list(APPEND CVBASIC_COMMAND "${CVBASIC_PROJECT_SOURCE_FILE}" "${CVBASIC_PROJECT_ASM_DIR}/${TGT_ASM}" "${CVBASIC_PROJECT_LIB_DIR}")

    # Use JOB_POOL to serialize CVBasic executions (avoids cvbasic_temporary.asm conflicts)
    add_custom_command(
        OUTPUT "${CVBASIC_PROJECT_ASM_DIR}/${TGT_ASM}"
        COMMAND ${CVBASIC_COMMAND}
        DEPENDS ${CVBASIC_PROJECT_DEPENDENCIES} ${CVBASIC_PROJECT_TOOL_DEPS}
        WORKING_DIRECTORY "${CVBASIC_PROJECT_SOURCE_DIR}"
        JOB_POOL cvbasic_pool
        COMMENT "Compiling CVBasic for ${TGT_DESCRIPTION}"
        VERBATIM
    )

    # Determine output directory (use custom if specified, otherwise use roms dir)
    if(TGT_OUTPUT_DIR)
        set(ROM_OUTPUT_DIR "${TGT_OUTPUT_DIR}")
    else()
        set(ROM_OUTPUT_DIR "${CVBASIC_PROJECT_ROMS_DIR}")
    endif()

    # Assembly step (platform specific)
    if(PLATFORM_FLAG STREQUAL "--ti994a")
        cvbasic_assemble_ti99("${TGT_ASM}" "${TGT_ROM}" "${CVBASIC_PROJECT_CART_TITLE}" "${CVBASIC_PROJECT_ASM_DIR}" "${ROM_OUTPUT_DIR}" "${CVBASIC_PROJECT_TOOL_DEPS}")
    else()
        cvbasic_assemble_gasm80("${TGT_ASM}" "${TGT_ROM}" "${CVBASIC_PROJECT_ASM_DIR}" "${ROM_OUTPUT_DIR}" "${CVBASIC_PROJECT_TOOL_DEPS}")
    endif()

    # Add target
    add_custom_target(${TARGET_NAME} DEPENDS "${ROM_OUTPUT_DIR}/${TGT_ROM}")

    # Auto-add pletter compression dependency if configured
    if(CVBASIC_PROJECT_PLETTER_TARGET)
        add_dependencies(${TARGET_NAME} ${CVBASIC_PROJECT_PLETTER_TARGET})
    endif()
endfunction()
