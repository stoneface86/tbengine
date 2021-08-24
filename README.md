# tbengine

Trackerboy engine, a Music/SFX engine for the gameboy. This repository contains the source code for the driver.
For the tracker program see [trackerboy][trackerboy-link]. WIP!

# Project structure

* `inc/` - include directory
* `demo/` - code for building the demo ROM
* (deprecated) ~~`lib/` - code for the driver, split up into separate assembly files~~
* `build/` - default build directory, assembled files/ROMs will be built here

# Building

You will need the RGBDS toolchain and GNU Make in order to build. If RGBDS is not in your path you must
configure the makefile by adding a `user.mk` file with path overrides for each RGBDS program. The `user.mk`
file is for user-specific configuration and is not tracked by git.

To build the demo:
```sh
make
```
This will build the driver and demo ROM in the configured build directory (default is `build/`)

To build just the driver:
```sh
make lib
```

# Usage

Assemble and link [tbengine.asm](./tbengine.asm) with your project. The driver will require some
space in ROM0 and WRAM0.

Always initialize the library first with `tbe_init`
```asm
    call    tbe_init
```

Then you can begin playing a song by calling `tbe_playSong`
```asm
    ld      hl, samplesong
    call    tbe_playSong
```

Finally, call `tbe_update` once every vblank to update the sound registers
```asm
gameloop:
    call    wait_vblank

    ; your game logic

    call    tbe_update
    jr      gameloop
```

If desired, the timer can be used instead of vblank for updating music. Keep in
mind that tempo/speed will depend on the framerate you set. For vblank this is
always ~59.7 fps.

# Contributing

Any contributions are welcomed at this point in time. Submit a pull request or
feel free to contact me on discord, my tag is stoneface#7646.

# Versioning

This project uses Semantic Versioning v2.0.0

# License

This project is licensed under the MIT License - See [LICENSE](LICENSE) for more details

[trackerboy-link]: https://github.com/stoneface86/trackerboy
