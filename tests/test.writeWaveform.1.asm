
SECTION "test writeWaveform 1", ROM0

INCLUDE "tests/writeWaveform.inc"

main::
    call    soundOn
    ld      a, 1                ; waveform id = 0
    call    writeWaveform
    ld      hl, waveRectangle
    jp      checkWaveram
