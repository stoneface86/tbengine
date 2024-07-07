
# tbengine

Trackerboy engine, a Music/SFX engine for the gameboy. This repository contains
the source code for the driver. For the tracker program see [trackerboy]. WIP!

## Project structure

* `inc/` - include directory
* `scraps/` - scrapped code for the driver, kept for archival purposes
* `tests/` - tester ROM and unit test source
* `build/` - default build directory, assembled files/ROMs will be built here
* `tbengine.asm` - driver source code

## Testing

Unit tests are provided in this repo and can be run by compiling and running 
[tbengine.nim](./tbengine.nim)
```
nim test
```

Each unit test is compiled as a separate ROM, which tests a specific part of
tbengine.asm. The result of the test is stored in the first byte of the ROM's
SRAM, with zero indicating a pass and nonzero indicating a failure.

In order to build and run the tests you will need the following programs in your PATH:
- [Nim](https://nim-lang.org/)
- [ninja](https://ninja-build.org/)
- [RGBDS](https://github.com/gbdev/rgbds)
- [bgb](https://bgb.bircd.org/)

### Debugging

For debugging a single unit test, use:
```
nim debug <testname>
```
This task will open the bgb emulator with a breakpoint at the entry point, $100.
From there you can use the debugger as needed.

## Options

The following definitions can be provided when assembling to override default
behavior of the driver:
- `TbeNoBankSwitch`: if present then the driver will not handle bank switching.
                     You will be required to switch to bank the song is located
                     in before calling `tbeUpdate`.
- `TbeNoWaveTable`: if present then an empty wave table will be provided.
- `TbeNoInstrumentTable`: if present then an empty instrument table will be provided.
- `TbePrintUsage`: ROM and WRAM used by the driver will be printed when assembled.

### Hooks

User-provided routines can be specified to override certain behaviors of the
driver. To use a hook you must assemble with its corresponding define, and
provide a callable routine with the label `tbeOn[HookName]`. Your provided hook
routines should reside in `ROM0`, as tbengine will not switch banks prior to
calling.

Available hook defines:
- `TbeHookBankEnter`: If set, then the driver will switch to the song's bank
                      before updating using the provided routine
                      `tbeOnBankEnter`. The bank number will be stored in
                      the `a` register when calling the routine. If not set,
                      then the driver will change banks by writing the bank
                      number to `[$2000]`.
- `TbeHookBankExit`: If set, then the driver will call the user provided routine
                     `tbeOnBankExit` before returning from `tbeUpdate`. If not
                     set, then the driver does nothing.

You should use the bank enter/exit hooks if you are using a custom MBC that
does not switch banks in typical fashion and/or if you would like to integrate
your custom bank switch handling with the driver.

## Usage

To use tbengine in your project, you just need to assemble and link 
`tbengine.asm`, along with your compiled module data. See below for required
dependencies. Compiling module data can be done via
[tbc](https://github.com/stoneface86/tbc), using the tbengine export command
(Coming soon).

Requirements:
- [hardware.inc](https://github.com/gbdev/hardware.inc) must be in your INCLUDE
  path, rev 4.0 and up. (Latest available is recommended).
- [RGBDS](https://github.com/gbdev/rgbds) v0.5.0 and up

The engine must be initialized before using any of its API routines
```asm
call    tbeInit         ; call this once during game startup
```

Afterwards, you can start to play a song by calling `tbePlaySong`
```asm
ld      a, 2
call    tbePlaySong     ; play song #2
```

In order for the engine to update sound registers, you should call `tbeUpdate`
periodically. You are responsible for the tickrate, as the driver only updates
for a single **tick** when you call `tbeUpdate`. How you achieve this is your
choice: vblank gives you a steady ~60Hz tickrate, and other rates can be
achieved by using the timer interrupt or by dividing vblanks.
```asm
; game logic...
call    tbeUpdate
```

## Contributing

Any contributions are welcomed at this point in time. Submit a pull request or
feel free to contact me on discord, my tag is stoneface86.

## Versioning

This project uses Semantic Versioning v2.0.0

## License

This project is licensed under the MIT License - See [LICENSE](LICENSE) for
more details.

[trackerboy]: https://github.com/stoneface86/trackerboy
