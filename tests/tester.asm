
; This rom is intended to be run headlessly
; The results of each test is stored in SRAM
; run this in an emulator that supports headless operation, ie bgb:
;   bgb -rom tester.gb -hf

INCLUDE "hardware.inc"

SECTION "test-results", SRAM, BANK[0]
sTesterResults:
sTesterCount:
    DS 1
sTesterData:

TEST_COUNT = 0

MACRO sramOn
    ld      a, $A
    ld      [0], a
ENDM

MACRO sramOff
    xor     a, a
    ld      [0], a
ENDM

;
; Macro for specifying a test case. The argument \1 is the test case name. You
; must supply a routine that has the name test_\1 and returns nonzero in the
; A register on error.
;
MACRO testcase

PUSHS

SECTION FRAGMENT "test-names", ROM0
str_\1:
    DB "\1", 0

POPS

TEST_COUNT = TEST_COUNT + 1

    call    clearregs          ; clear registers before starting the test
    call    test_\1            ; call the unit test routine
    ld      de, str_\1
    call    storeResult
ENDM

SECTION "header", ROM0[$100]
    di
    jp start

    DS $150 - @, 0

SECTION "code", ROM0

start:
    xor     a, a
    ld      [rNR52], a
.waitVBlank:
    ld      a, [rLY]
    cp      144
    jr      c, .waitVBlank

    xor     a, a
    ld      [rLCDC], a
    ld      [rNR52], a

main:

    ; select SRAM bank 0
    ld      a, 1
    ld      [$6000], a
    xor     a, a
    ld      [$4000], a

    ; clear SRAM (probably not necessary)
    sramOn
    ld      hl, $A000
    ld      bc, $2000
.clearSRAM:
    xor     a, a
    ld      [hl+], a
    dec     bc
    ld      a, b
    or      a, c
    jr      nz, .clearSRAM
    sramOff

    ; initialize results pointer
    ld      a, LOW(sTesterData)
    ld      [wResultsPointer], a
    ld      a, HIGH(sTesterData)
    ld      [wResultsPointer+1], a


    ; ======================== TEST CASES =====================================

    testcase seqenum
    testcase seqenum_loop
    testcase update_nr51

    ; ======================== TEST CASES =====================================

    sramOn

    ld      a, TEST_COUNT
    ld      [sTesterCount], a

    sramOff

    ; end of program, debugger breakpoint
    ; the emulator should stop execution here
    ld      b, b

.die:
    halt
    nop
    jr      .die

clearregs:
    xor      a, a
    ld       b, a
    ld       c, a
    ld       d, a
    ld       e, a
    ld       h, a
    ld       l, a
    ret

storeResult:
    ld       b, a                   ; put result in b
    sramOn

    ld       a, [wResultsPointer]
    ld       l, a
    ld       a, [wResultsPointer+1]
    ld       h, a

    ld       a, b
    ld       [hl+], a               ; store result code
.copyName:
    ld       a, [de]
    inc      de
    ld       [hl+], a
    or       a, a
    jr       nz, .copyName

    ld       a, l
    ld       [wResultsPointer], a
    ld       a, h
    ld       [wResultsPointer+1], a

    sramOff
    ret

SECTION "tester wram", WRAM0

wResultsPointer:
    DS 2
