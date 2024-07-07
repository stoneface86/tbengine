
SECTION "test writeWaveform badindex", ROM0

INCLUDE "tests/writeWaveform.inc"

main::
    call    soundOn
    ; copy current waveram to wWaveramTemp
    ld      c, _AUD3WAVERAM - $FF00
    ld      hl, wWaveramTemp
    ld      b, 16
.loop:
    ld      a, [c]
    ld      [hl+], a
    inc     c
    dec     b
    jr      nz, .loop

    ; call writeWaveform with an invalid id
    ld      a, 23
    call    writeWaveform

    ; make sure the waveram was not modified
    ld      hl, wWaveramTemp
    jp      checkWaveram

SECTION "test wram", WRAM0

wWaveramTemp: DS 16
