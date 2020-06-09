
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

    ld a, $80
    ld [rNR52], a   ; sound on
    ld a, $11
    ld [rNR51], a   ; enable both terminals for CH1
    ld a, $FF
    ld [rNR50], a   ; both terminals on at max volume

    ld a, $80
    ld [rNR11], a   ; Duty = 02 (50%)
    ld a, $F0
    ld [rNR12], a   ; envelope = constant volume F
    ld a, $80
    ld [rNR14], a   ; start playing sound

    ld hl, FreqControl1
    call fc_reset
    
    ld hl, FreqControl1
    ld a, $47
    call fc_setVibrato

    ld hl, FreqControl1 + 4 ; hack, explicitly set frequency
    ld a, $7
    ld [hl], a

    ld      hl, FreqControl1    

.gameloop
    call    WaitVBlank

    ; vibrato example, (demo purposes only, will be moved to library)
    ; this is what effect 441 will sound like

    call    fc_step

    call    fc_frequency
    ld      a, c            ; set the new frequency
    ld      [rNR13], a
    ld      a, b
    ld      [rNR14], a

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
