# tbengine

Trackerboy engine, a Music/SFX engine for the gameboy. This repository contains the source code for the driver.
For the tracker program see [trackerboy][trackerboy-link]. WIP!

# Project structure

* `inc/` - include directory
* `demo/` - code for building the demo ROM
* `lib/` - code for the driver, split up into separate assembly files
* `build/` - default build directory, assembled files/ROMs will be built here

# Building

You will need the RGBDS toolchain and GNU Make in order to build. If RGBDS is not in your path you must
configure the makefile by adding a `user.mk` file with path overrides for each RGBDS program. The `user.mk`
file is for user-specific configuration and is not tracked by git.

To build the demo:
```sh
make
```
This will build the library and demo ROM in the configured build directory (default is `build/`)

To build the driver as a single assembly file:
```sh
make lib
```
This will concatenate all assembly files for the driver into one file ($(BUILD_DIR)/tbengine.asm) for use in other
projects. This file will eventually be available to download in the releases section once it is somewhat usable.
The only dependency for this library is hardware.inc, so make sure it is in your include path when assembling.

You can load the library to either ROM0 or ROMX. Default is ROMX. To load to ROM0, define TBE_ROM0 when assembling.

# Versioning

This project uses Semantic Versioning v2.0.0

# License

This project is licensed under the MIT License - See [LICENSE](LICENSE) for more details

[trackerboy-link]: https://github.com/stoneface86/trackerboy
