cmake_minimum_required(VERSION 3.12)

# CVBasic build functions for RetroPIPE

include(ExternalProject)
set(PYTHON python3)

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

        # Set tool paths for external builds
        set(CVBASIC_EXE "${CMAKE_BINARY_DIR}/external/CVBasic/bin/cvbasic" PARENT_SCOPE)
        set(GASM80_EXE "${CMAKE_BINARY_DIR}/external/gasm80/bin/gasm80" PARENT_SCOPE)
        set(XAS99_SCRIPT "${CMAKE_BINARY_DIR}/external/xdt99/xas99.py" PARENT_SCOPE)
        set(LINKTICART_SCRIPT "${CMAKE_BINARY_DIR}/external/CVBasic/linkticart.py" PARENT_SCOPE)

        # Add dependencies to all CVBasic targets
        set(TOOL_DEPENDENCIES CVBasic_external gasm80_external XDT99_external PARENT_SCOPE)

        message(STATUS "CVBasic tools will be built from source")
        message(STATUS "CVBasic version/tag: ${CVBASIC_GIT_TAG}")
        message(STATUS "GASM80 version/tag: ${GASM80_GIT_TAG}")
        message(STATUS "XDT99 version/tag: ${XDT99_GIT_TAG}")
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
# Takes a .nabu file named 000001.nabu and packages it into a .npz (zip) file
function(cvbasic_package_nabu_mame NABU_FILE OUTPUT_NPZ ROMS_DIR)
    add_custom_command(
        OUTPUT "${ROMS_DIR}/${OUTPUT_NPZ}"
        COMMAND ${CMAKE_COMMAND} -E tar "cf" "${ROMS_DIR}/${OUTPUT_NPZ}.tmp.zip" --format=zip "${NABU_FILE}"
        COMMAND ${CMAKE_COMMAND} -E copy "${ROMS_DIR}/${OUTPUT_NPZ}.tmp.zip" "${ROMS_DIR}/${OUTPUT_NPZ}"
        COMMAND ${CMAKE_COMMAND} -E remove "${ROMS_DIR}/${OUTPUT_NPZ}.tmp.zip"
        DEPENDS "${ROMS_DIR}/${NABU_FILE}"
        WORKING_DIRECTORY "${ROMS_DIR}"
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
#   DEPENDENCIES - List of source file dependencies
#   TOOL_DEPS - List of tool dependencies (from setup_cvbasic_tools)
#
function(cvbasic_setup_project)
    cmake_parse_arguments(PROJ "" "SOURCE_FILE;SOURCE_DIR;LIB_DIR;ASM_DIR;ROMS_DIR;CART_TITLE;VERSION" "DEPENDENCIES;TOOL_DEPS" ${ARGN})

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
    set(CVBASIC_PROJECT_DEPENDENCIES "${PROJ_DEPENDENCIES}" PARENT_SCOPE)
    set(CVBASIC_PROJECT_TOOL_DEPS "${PROJ_TOOL_DEPS}" PARENT_SCOPE)
endfunction()

# Simplified CVBasic target builder
# Auto-generates filenames and uses project configuration from cvbasic_setup_project
#
# Usage:
#   cvbasic_add_target(TARGET_NAME PLATFORM PLATFORM_FLAG [DEFINES defines] [ROM rom_output] [ASM asm_output] [DESCRIPTION desc])
#
# Examples:
#   cvbasic_add_target(coleco cv "")
#   cvbasic_add_target(ti99 ti994a --ti994a DESCRIPTION "TI-99/4A")
#   cvbasic_add_target(nabu_mame nabu --nabu DEFINES "-DTMS9918_TESTING=1" ROM "000001.nabu")
#
function(cvbasic_add_target TARGET_NAME PLATFORM PLATFORM_FLAG)
    cmake_parse_arguments(TGT "" "DEFINES;ROM;ASM;DESCRIPTION" "" ${ARGN})

    # Auto-generate filenames if not provided
    if(NOT TGT_ROM)
        # Default ROM naming: projectname_version_platform.ext
        if(PLATFORM STREQUAL "cv")
            set(TGT_ROM "${TARGET_NAME}_${CVBASIC_PROJECT_VERSION}_${PLATFORM}.rom")
        elseif(PLATFORM STREQUAL "ti994a")
            set(TGT_ROM "${TARGET_NAME}_${CVBASIC_PROJECT_VERSION}_ti99_8.bin")
        elseif(PLATFORM STREQUAL "msx")
            set(TGT_ROM "${TARGET_NAME}_${CVBASIC_PROJECT_VERSION}_msx.rom")
        elseif(PLATFORM STREQUAL "nabu")
            set(TGT_ROM "${TARGET_NAME}_${CVBASIC_PROJECT_VERSION}.nabu")
        elseif(PLATFORM STREQUAL "sg1000" OR PLATFORM STREQUAL "sc3000")
            set(TGT_ROM "${TARGET_NAME}_${CVBASIC_PROJECT_VERSION}_${PLATFORM}.sg")
        elseif(PLATFORM STREQUAL "creativision" OR PLATFORM STREQUAL "crv")
            set(TGT_ROM "${TARGET_NAME}_${CVBASIC_PROJECT_VERSION}_crv.bin")
        else()
            set(TGT_ROM "${TARGET_NAME}_${CVBASIC_PROJECT_VERSION}_${PLATFORM}.bin")
        endif()
    endif()

    if(NOT TGT_ASM)
        # Default ASM naming
        get_filename_component(ROM_NAME "${TGT_ROM}" NAME_WE)
        if(PLATFORM_FLAG STREQUAL "--ti994a")
            set(TGT_ASM "${ROM_NAME}.a99")
        else()
            set(TGT_ASM "${ROM_NAME}.asm")
        endif()
    endif()

    if(NOT TGT_DESCRIPTION)
        set(TGT_DESCRIPTION "${PLATFORM}")
    endif()

    # CVBasic compilation
    set(CVBASIC_COMMAND ${CVBASIC_EXE} ${PLATFORM_FLAG})
    if(TGT_DEFINES)
        list(APPEND CVBASIC_COMMAND ${TGT_DEFINES})
    endif()
    list(APPEND CVBASIC_COMMAND "${CVBASIC_PROJECT_SOURCE_FILE}" "${CVBASIC_PROJECT_ASM_DIR}/${TGT_ASM}" "${CVBASIC_PROJECT_LIB_DIR}")

    add_custom_command(
        OUTPUT "${CVBASIC_PROJECT_ASM_DIR}/${TGT_ASM}"
        COMMAND ${CVBASIC_COMMAND}
        DEPENDS ${CVBASIC_PROJECT_DEPENDENCIES} ${CVBASIC_PROJECT_TOOL_DEPS}
        WORKING_DIRECTORY "${CVBASIC_PROJECT_SOURCE_DIR}"
        COMMENT "Compiling CVBasic for ${TGT_DESCRIPTION}"
        VERBATIM
    )

    # Assembly step (platform specific)
    if(PLATFORM_FLAG STREQUAL "--ti994a")
        cvbasic_assemble_ti99("${TGT_ASM}" "${TGT_ROM}" "${CVBASIC_PROJECT_CART_TITLE}" "${CVBASIC_PROJECT_ASM_DIR}" "${CVBASIC_PROJECT_ROMS_DIR}" "${CVBASIC_PROJECT_TOOL_DEPS}")
    else()
        cvbasic_assemble_gasm80("${TGT_ASM}" "${TGT_ROM}" "${CVBASIC_PROJECT_ASM_DIR}" "${CVBASIC_PROJECT_ROMS_DIR}" "${CVBASIC_PROJECT_TOOL_DEPS}")
    endif()

    # Add target
    add_custom_target(${TARGET_NAME} DEPENDS "${CVBASIC_PROJECT_ROMS_DIR}/${TGT_ROM}")
endfunction()
