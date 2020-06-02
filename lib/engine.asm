; 2's complement negation
neg: MACRO
    cpl
    inc     a
ENDM

IF DEF(TBE_ROM0)
SECTION "tbengine", ROM0
ELSE
SECTION "tbengine", ROMX
ENDC

;
; Lookup the current value of the vibrato for a given index
; vibrato indices represent an angle in a sine period
; such that the angle = index/64 * 2pi
;  0 <= index < 16: quadrant I
; 16 <= index < 32: quadrant II
; 32 <= index < 48: quadrant III
; 48 <= index < 64: quadrant IV
;
; params:
;  b - index of sine waveform (0-63)
;  c - extent (0-15)
;
; returns:
;  a - vibrato value (signed)
;
lookupVibrato::
    push    hl
    push    de
    ld      a, b
    and     a, $1F
    jp      z, .exit        ; if the index is 0 or 32, return 0
    ld      h, $0           ; hl <- extent * 16
    ld      l, c
    sla     l
    sla     l
    sla     l
    sla     l
    
    ld      de, VibratoTable
    add     hl, de          ; hl now points to a vibrato table for the given extent
    cp      a, $10          ; check if we are in quadrant I/III
    jp      c, .quad1       ; if a < 32, then index is in quadrant I or III
                            ; quadrant II/IV
    sub     a, $10          ; a = a - 16
    jp      .lookupValue
.quad1:
                            ; quadrant I/III
    neg                     ; a = -a
    add     a, $10          ; a += 16   so a = 16 - a
.lookupValue:
    ld      d, $0
    ld      e, a            ; de = a
    add     hl, de          ; offset the table by our calculated index
    ld      e, [hl]         ; save this for later
    ld      a, b            ; check if the index is in quadrant 3 or 4
    cp      a, $20          ; is a >= 32 (quadrants 3 and 4)
    ld      a, e            ; restore our saved lookup
    jp      c, .exit        ; jump if index was < 32, no need to negate (quads 1 and 2)
    neg                     ; index is >= 32, negate the vibrato value
.exit:
    ; a contains the result so now we can return
    pop     de
    pop     hl
    ret


INCLUDE "lib/tables.asm"
