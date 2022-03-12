;
; Unit test ROM
;
; Runs unit tests, plays a sound at the end if any of the tests fail.
; A debugger breakpoint is inserted for each test case on failure. The number
; of tests that failed can be accessed from the wFailCount WRAM variable.
;


INCLUDE "hardware.inc"

; RST vectors

section "rst $10", rom0 [$10]
section "rst $18", rom0 [$18]
section "rst $20", rom0 [$20]
section "rst $28", rom0 [$28]
section "rst $30", rom0 [$30]
section "rst $38", rom0 [$38]

; Interrupts

SECTION	"Vblank", rom0[$0040]
    jp VBlank_isr
SECTION	"LCDC", rom0[$0048]
    reti
SECTION	"Timer_Overflow", rom0[$0050]
    reti
SECTION	"Serial", rom0[$0058]
    reti
SECTION	"p1thru4", rom0[$0060]
    reti

;
; Macro for specifying a test case. The argument \1 is the test case name. You
; must supply a routine that has the name test_\1 and returns nonzero in the
; A register on error.
;
MACRO testcase
    call     clearregs          ; clear registers before starting the test
    call     test_\1            ; call the unit test routine
    or       a, a               ; check if test failed
    jr       z, .nofail\@
    ld       a, [wFailCount]    ; increment fail count
    inc      a
    ld       [wFailCount], a
    ld       b, b               ; debugger breakpoint
.nofail\@:
ENDM

SECTION "Header", ROM0[$100]
    di
    jp start

    DS $150 - @, 0

SECTION "tester code", ROM0

start:
; .waitVBlank:
;     ld      a, [rLY]
;     cp      144
;     jr      c, .waitVBlank

;     xor     a, a
;     ld      [rLCDC], a
    ld      a, %10000001
    ld      [rLCDC], a

    ; sound off
    ld      [rNR52], a

    ; turn on vblank interrupts
    xor a
    ld [rIF], a
    ld  a, %00001
    ld [rIE], a

    ; enable interrupts
    ei

testerMain:

    xor     a, a
    ld      [wFailCount], a

    ; ======================== TEST CASES =====================================

    testcase seqenum
    testcase seqenum_loop

    ; ======================== TEST CASES =====================================

    ; sound on
    ld      a, $80
    ld      [rNR52], a
    ld      a, $33
    ld      [rNR51], a
    ld      a, $77
    ld      [rNR50], a

    ld      a, [wFailCount]
    jr      nz, .failed
    call    all_good
    jr      .loop
.failed:
    call    no_good

    ; sound off
    xor     a, a
    ld      [rNR52], a

    di
.loop:
    halt
    jr      .loop

clearregs:
    xor      a, a
    ld       b, a
    ld       c, a
    ld       d, a
    ld       e, a
    ld       h, a
    ld       l, a
    ret

all_good:
    ; Sfx_ElevatorEnd from pokecrystal/audio/sfx.asm
    ld      a, $80
    ld      [rNR11], a
    ld      a, $F3
    ld      [rNR12], a
    ld      a, $30
    ld      [rNR13], a
    ld      a, $87
    ld      [rNR14], a

    ld      b, 15
    call    waitVblanks

    ld      a, $65
    ld      [rNR12], a
    ld      a, $87
    ld      [rNR14], a

    ld      b, 8
    call    waitVblanks

    ld     a, $F4
    ld     [rNR12], a
    xor    a, a
    ld     [rNR13], a
    ld     a, $87
    ld     [rNR14], a

    ld     b, 15
    call   waitVblanks

    ld     a, $74
    ld     [rNR12], a
    ld     a, $87
    ld     [rNR14], a

    ld     b, 15
    call   waitVblanks

    ld     a, $44
    ld     [rNR12], a
    ld     a, $87
    ld     [rNR14], a

    ld     b, 15
    call   waitVblanks

    ld     a, $24
    ld     [rNR12], a
    ld     a, $87
    ld     [rNR14], a

    ld     b, 15
    call   waitVblanks

    ret 

no_good:
    ; Sfx_Wrong from pokecrystal/audio/sfx.asm
    ld      a, $C0
    ld      [rNR11], a
    ld      [rNR21], a
    ld      a, $5A
    ld      [rNR10], a
    ld      a, $F0
    ld      [rNR12], a
    ld      [rNR22], a
    xor     a, a
    ld      [rNR13], a
    ld      a, $85
    ld      [rNR14], a
    ld      a, $1
    ld      [rNR23], a
    ld      a, $84
    ld      [rNR24], a

    ld      b, 4
    call    waitVblanks

    ld      a, $08
    ld      [rNR10], a
    xor     a, a
    ld      [rNR12], a
    ld      [rNR22], a
    ld      [rNR13], a
    ld      [rNR23], a
    ld      a, $80
    ld      [rNR14], a
    ld      [rNR24], a

    ld      b, 4
    call    waitVblanks

    ld      a, $F0
    ld      [rNR12], a
    ld      [rNR22], a
    xor     a, a
    ld      [rNR13], a
    ld      a, 1
    ld      [rNR23], a
    ld      a, $85
    ld      [rNR14], a
    ld      a, $84
    ld      [rNR24], a

    ld      b, 15
    call    waitVblanks

    xor     a, a
    ld      [rNR12], a
    ld      [rNR13], a
    ld      [rNR22], a
    ld      [rNR23], a
    ld      a, $80
    ld      [rNR14], a
    ld      [rNR24], a

    call    waitVblank
    ret

test_passes:
    ret

test_fails:
    ld      a, $1
    ret

waitVblank:
    push    af
    xor     a, a
    ld      [wVBlank], a
.check:
    halt
    ld      a, [wVBlank]
    or      a, a
    jr      z, .check
    pop     af
    ret

waitVblanks:
    call    waitVblank
    dec     b
    jr      nz, waitVblanks
    ret

VBlank_isr:
    push af
    push bc
    push de
    push hl

    ; set vblank flag
    ld  a, 1
    ld [wVBlank], a

    pop hl
    pop de
    pop bc
    pop af
    reti

SECTION "Tester WRAM", WRAM0

wFailCount: DS 1
wVBlank: DS 1
