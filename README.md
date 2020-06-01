# tbengine

Trackerboy engine, a Music/SFX engine for the gameboy. This repository contains the source code for the driver.
For the tracker program see [trackerboy][trackerboy-link].

# Project structure

* `inc/` - include directory
* `demo/` - code for building the demo ROM
* `build/` - assembled files/ROMs will be built here

# Building

You will need RGBDS and Make in order to build. If RGBDS is not in your path you must configure
the makefile by adding a `user.mk` file with path overrides for each RGBDS program.

To build:
```sh
make
```
This will build the library and demo ROM in the configured build directory (default is `build/`)


# Versioning

This project uses Semantic Versioning v2.0.0

# License

This project is licensed under the MIT License - See [LICENSE](LICENSE) for more details

[trackerboy-link]: https://github.com/stoneface86/trackerboy
