cmake_minimum_required(VERSION 3.13)

# RetroPIPE CMake Build
# Converts the batch-based build to cross-platform CMake

project(retropipe)

# Include CVBasic build functions
include(${CMAKE_SOURCE_DIR}/visrealm_cvbasic.cmake)

set(PYTHON python3)

# Version information (matches build.bat)
set(VERSION "v0-2-0")
string(REPLACE "-" "." FRIENDLYVER "${VERSION}")

# Setup CVBasic toolchain (auto-build or find existing tools)
setup_cvbasic_tools()

# Set up directories
set(SOURCE_DIR "${CMAKE_SOURCE_DIR}/src")
set(ASM_DIR "${CMAKE_BINARY_DIR}/asm")
set(ROMS_DIR "${CMAKE_BINARY_DIR}/roms")
file(MAKE_DIRECTORY "${ASM_DIR}")
file(MAKE_DIRECTORY "${ROMS_DIR}")

# Collect all CVBasic source files for dependency tracking
file(GLOB CVBASIC_SOURCE_FILES
    "${SOURCE_DIR}/*.bas"
    "${SOURCE_DIR}/lib/*.asm"
)

# Collect pletter source files
file(GLOB PLETTER_SOURCE_FILES
    "${SOURCE_DIR}/pletter/*.bas"
)

# Custom function to compress pletter source files
function(compress_pletter_file PLETTER_BAS)
    get_filename_component(BASENAME ${PLETTER_BAS} NAME_WE)
    set(OUTPUT_FILE "${SOURCE_DIR}/${BASENAME}.pletter.bas")

    add_custom_command(
        OUTPUT "${OUTPUT_FILE}"
        COMMAND ${PYTHON} "${CMAKE_SOURCE_DIR}/tools/cvpletter.py" "${PLETTER_BAS}"
        DEPENDS "${PLETTER_BAS}" "${CMAKE_SOURCE_DIR}/tools/cvpletter.py"
        WORKING_DIRECTORY "${SOURCE_DIR}"
        COMMENT "Compressing pletter source: ${BASENAME}.bas"
        VERBATIM
    )
endfunction()

# Compress all pletter files
set(PLETTER_OUTPUTS)
foreach(PLETTER_FILE ${PLETTER_SOURCE_FILES})
    get_filename_component(BASENAME ${PLETTER_FILE} NAME_WE)
    list(APPEND PLETTER_OUTPUTS "${SOURCE_DIR}/${BASENAME}.pletter.bas")
    compress_pletter_file(${PLETTER_FILE})
endforeach()

# Custom target for all pletter compression
add_custom_target(pletter_compression DEPENDS ${PLETTER_OUTPUTS})

# Setup CVBasic project configuration
cvbasic_setup_project(
    SOURCE_FILE "retropipe.bas"
    SOURCE_DIR "${SOURCE_DIR}"
    ASM_DIR "${ASM_DIR}"
    ROMS_DIR "${ROMS_DIR}"
    CART_TITLE "RETROPIPE"
    VERSION "${VERSION}"
    DEPENDENCIES ${CVBASIC_SOURCE_FILES} ${PLETTER_OUTPUTS}
    TOOL_DEPS ${TOOL_DEPENDENCIES}
)

# Define all platform targets (much simpler now!)
cvbasic_add_target(ti99 ti994a --ti994a DESCRIPTION "TI-99/4A")
cvbasic_add_target(coleco cv "" ROM "retropipe_${VERSION}_cv.rom" DESCRIPTION "ColecoVision")
cvbasic_add_target(msx_asc16 msx --msx ROM "retropipe_${VERSION}_msx_asc16.rom" DESCRIPTION "MSX ASCII16")
cvbasic_add_target(msx_konami msx "--msx;-konami" ROM "retropipe_${VERSION}_msx_konami.rom" DESCRIPTION "MSX Konami")
cvbasic_add_target(nabu nabu --nabu ROM "retropipe_${VERSION}.nabu" DESCRIPTION "NABU")
cvbasic_add_target(sg1000 sc3000 --sg1000 ROM "retropipe_${VERSION}_sc3000.sg" DESCRIPTION "SG-1000/SC-3000")
cvbasic_add_target(creativision crv "--creativision;-rom16" ROM "retropipe_${VERSION}_crv.bin" DESCRIPTION "CreatiVision")

# Special NABU MAME target (different defines and ROM name)
cvbasic_add_target(nabu_mame nabu --nabu DEFINES "-DTMS9918_TESTING=1" ROM "000001.nabu" DESCRIPTION "NABU MAME")

# NABU MAME packaging
cvbasic_package_nabu_mame("000001.nabu" "retropipe_${VERSION}_nabu_mame.npz" "${ROMS_DIR}")
add_custom_target(nabu_mame_package DEPENDS "${ROMS_DIR}/retropipe_${VERSION}_nabu_mame.npz")

# Add pletter compression dependency to all targets
add_dependencies(ti99 pletter_compression)
add_dependencies(coleco pletter_compression)
add_dependencies(msx_asc16 pletter_compression)
add_dependencies(msx_konami pletter_compression)
add_dependencies(nabu pletter_compression)
add_dependencies(sg1000 pletter_compression)
add_dependencies(creativision pletter_compression)
add_dependencies(nabu_mame pletter_compression)

# Master target to build all platforms
add_custom_target(all_platforms DEPENDS ti99 coleco msx_asc16 msx_konami nabu sg1000 creativision nabu_mame_package)

# Print build information
message(STATUS "RetroPIPE CMake Configuration")
message(STATUS "Version: ${FRIENDLYVER}")
message(STATUS "CVBasic: ${CVBASIC_EXE}")
message(STATUS "GASM80: ${GASM80_EXE}")
message(STATUS "linkticart.py: ${LINKTICART_SCRIPT}")
if(XAS99_SCRIPT)
    message(STATUS "XAS99: ${XAS99_SCRIPT}")
else()
    message(STATUS "XAS99: NOT FOUND (TI-99 builds will be limited)")
endif()
