
INCLUDE "hardware.inc"

tbeWaveTable::
    DB 2
waveTriangle:
    DB $01, $23, $45, $67, $89, $AB, $CD, $EF, \
       $FE, $DC, $BA, $98, $76, $54, $32, $10
waveRectangle:
    DB $00, $00, $00, $00, $00, $AA, $AA, $AA, \
       $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA

;; checks if the WAVERAM has the same data pointed by [hl]
;; if so, a is set to 1, 0 otherwise
checkWaveram:
    push    bc
    push    de
    push    hl
    ld      c, _AUD3WAVERAM - $FF00
    ld      b, 16
.loop:
    ld      a, [hl+]
    ld      d, a
    ldh     a, [c]
    cp      a, d
    jr      nz, .notEqual
    inc     c
    dec     b
    jr      nz, .loop
    xor     a, a
    jr      .done
.notEqual:
    ld      a, 1
.done:
    pop     hl
    pop     de
    pop     bc
    ret
