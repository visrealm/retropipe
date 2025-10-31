# RetroPIPE

A Pipe Dream clone for TMS9918A powered computers written in [CVBasic](https://github.com/visrealm/CVBasic)

Not complete. This is a work in progress.

## Build Status

| Platform | Windows | Linux | macOS |
|----------|---------|-------|-------|
| ROMs | [![](https://github.com/visrealm/retropipe/actions/workflows/build-windows.yml/badge.svg)](https://github.com/visrealm/retropipe/actions/workflows/build-windows.yml) | [![](https://github.com/visrealm/retropipe/actions/workflows/build-linux.yml/badge.svg)](https://github.com/visrealm/retropipe/actions/workflows/build-linux.yml) | [![](https://github.com/visrealm/retropipe/actions/workflows/build-macos.yml/badge.svg)](https://github.com/visrealm/retropipe/actions/workflows/build-macos.yml) |

## Supported devices

* TI-99/4A
* ColecoVision
* MSX
* NABU
* SC-3000/SG-1000

Can be compiled for other targets supported by CVBasic too.

### Video

<p align="left"><img src="img/retropipe.gif" alt="RetroPIPE"></p>

### Play online

You can play the latest released version for the TI-99/4A online courtesy of JS99'er: [RetroPIPE v0.1.2 on JS99'er](https://js99er.net/#/?cartUrl=https:%2F%2Fgithub.com%2Fvisrealm%2Fretropipe%2Freleases%2Fdownload%2Fv0.1.2%2Fretropipe_v0-1-2_ti99_8.bin)

## Building

### Prerequisites

* CMake 3.5 or later
* Python 3 with Pillow (for graphics conversion)
* Git
* C compiler (GCC, Clang, MSVC, etc.)

The build system automatically downloads and builds all required tools from source:
* [CVBasic](https://github.com/nanochess/CVBasic) - Cross-compiler
* [gasm80](https://github.com/visrealm/gasm80) - Z80/8080 assembler
* [XDT99](https://github.com/endlos99/xdt99) - TI-99/4A cross-assembler
* [Pletter](https://github.com/nanochess/Pletter) - Graphics compression

### Quick Start

```bash
# Clone the repository
git clone https://github.com/visrealm/retropipe.git
cd retropipe

# Create build directory
mkdir build
cd build

# Configure
cmake ..

# Build all platforms
cmake --build . --target all_platforms
```

ROMs will be generated in `build/roms/`

### Individual Platform Targets

Build specific platforms:

```bash
cmake --build . --target ti99              # TI-99/4A
cmake --build . --target coleco            # ColecoVision
cmake --build . --target msx_asc16         # MSX (ASCII 16K)
cmake --build . --target msx_konami        # MSX (Konami)
cmake --build . --target nabu              # NABU
cmake --build . --target sg1000            # SG-1000/SC-3000
cmake --build . --target creativision      # CreatiVision
cmake --build . --target nabu_mame_package # NABU (MAME format .npz)
```

### Build Options

```bash
# Use existing tools instead of building from source
cmake .. -DBUILD_TOOLS_FROM_SOURCE=OFF

# Specify tool versions
cmake .. -DCVBASIC_GIT_TAG=v1.0.0 -DGASM80_GIT_TAG=master
```

## License
This code is licensed under the [MIT](https://opensource.org/licenses/MIT "MIT") license

