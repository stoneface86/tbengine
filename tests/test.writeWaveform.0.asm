
SECTION "test writeWaveform 0", ROM0

INCLUDE "tests/writeWaveform.inc"

main::
    call    soundOn
    xor     a, a                ; waveform id = 0
    call    writeWaveform
    ld      hl, waveTriangle
    jp      checkWaveram
