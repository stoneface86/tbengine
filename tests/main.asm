;; Unit tester runtime
;;
;; This file contains the code for a ROM that runs a single unit test. After
;; the hardware is initialized, the unit test's entry point of main is called
;; which should perform a single test. When the test is finished, the result
;; should be stored in the `a` register, which will then be stored in the
;; cartridge's SRAM.
;;

INCLUDE "hardware.inc"


SECTION "intVblank", ROM0[$40]
    reti
SECTION "intLcdc", ROM0[$48]
    reti
SECTION "intTimer", ROM0[$50]
    reti
SECTION "intSerial", ROM0[$58]
    reti
SECTION "intJoypad", ROM0[$60]
    reti

SECTION "header", ROM0[$100]
    di
    jp start

    DS $150 - @, 0

SECTION "tester runtime", ROM0

start:
.waitVBlank:
    ld      a, [rLY]
    cp      144
    jr      c, .waitVBlank

    xor     a, a
    ld      [rNR52], a
    ld      [rSCY], a
    ld      [rSCX], a

    ; SP at high WRAM
    ld      sp, $D000

    ; clear registers
    xor     a, a
    ld      b, a
    ld      c, a
    ld      d, a
    ld      e, a
    ld      h, a
    ld      l, a

    ; call test entry point
    call    main

    ; store main return code in SRAM
    ld      b, a            ; b = return code
    ld      a, $A           ; SRAM on
    ld      [0], a
    
    ld      a, b            ; store code
    ld      [_SRAM], a

    xor     a, a            ; SRAM off
    ld      [0], a

    ; debugger breakpoint, execution stops here
    ld      b, b
.fin:
    halt
    nop
    jr      .fin

;; UTILITIES

soundOn::
    push     af
    ld       a, $80
    ld       [rNR52], a
    pop      af
    ret

soundOff::
    push     af
    xor      a, a
    ld       [rNR52], a
    pop      af
    ret


