
# tbengine

Trackerboy engine, a Music/SFX engine for the gameboy. This repository contains
the source code for the driver. For the tracker program see [trackerboy]. WIP!

## Project structure

* `inc/` - include directory
* `scraps/` - scrapped code for the driver, kept for archival purposes
* `tests/` - tester ROM and unit test source
* `build/` - default build directory, assembled files/ROMs will be built here
* `tbengine.asm` - driver source code

## Building

The provided Makefile builds the tester ROM and demo ROM. You will need the
RGBDS toolchain and GNU Make in order to build. If RGBDS is not in your path
you need to provide an RGBDS variable containing the path to the rgbds
executables including a trailing slash.

To build the demo and tester ROMs:
```sh
make
```
This will build the ROMs in the configured build directory (default is
`build/`).

To build just the demo:
```sh
make demo
```

Or the tester:
```sh
make test
```

## Usage

TBD. This driver is still under development and an API has not been formally
defined yet. Check back later.

## Contributing

Any contributions are welcomed at this point in time. Submit a pull request or
feel free to contact me on discord, my tag is stoneface#7646.

## Versioning

This project uses Semantic Versioning v2.0.0

## License

This project is licensed under the MIT License - See [LICENSE](LICENSE) for
more details.

[trackerboy]: https://github.com/stoneface86/trackerboy
