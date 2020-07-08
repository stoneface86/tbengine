
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

SECTION "Header", ROM0[$100]

EntryPoint:
    di 
    jp Start

REPT $150 - $104
    db 0
ENDR

SECTION "demo code", ROM0

Start:
.waitVBlank
    ld a, [rLY]
    cp 144
    jr c, .waitVBlank

    xor a
    ld [rLCDC], a

    ld hl, $9000
    ld de, FontTiles
    ld bc, FontTilesEnd - FontTiles

.copyFont
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, .copyFont

    ld hl, $9800
    ld de, DemoStr
.copyString
    ld a, [de]
    ld [hli], a
    inc de
    and a
    jr nz, .copyString


    ld a, %11100100
    ld [rBGP], a

    xor a
    ld [rSCY], a
    ld [rSCX], a

    ; sound off
    ld [rNR52], a

    ld a, %10000001
    ld [rLCDC], a

    ; turn on vblank interrupts
    xor a
    ld [rIF], a
    ld  a, %00001
	ld [rIE], a

    ; enable interrupts
	ei

    call    tbe_init
    
    ld      hl, song_rushingheart
    ;ld      hl, song_natpark
    call    tbe_playSong

    call    joypad_init

.gameloop
    call    WaitVBlank

    ld      a, [rSCX]
    dec     a
    ld      [rSCX], a

    ld      a, [rSCY]
    dec     a
    ld      [rSCY], a

    call    tbe_update

    jr      .gameloop


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

WaitVBlank:
	xor a
	ld [wVBlank], a     ; clear vblank flag
.wait
	halt                ; wait for interrupt
	ld a, [wVBlank]
	and a
	jr z, .wait         ; repeat if flag is not set
	ret


SECTION "Font", ROM0

FontTiles:
INCBIN "demo/font.chr"
FontTilesEnd:


SECTION "Demo string", ROM0

DemoStr:
    db "demo", 0

section "vblank wram", wram0

; set if a vblank interrupt occurred
wVBlank:: db
