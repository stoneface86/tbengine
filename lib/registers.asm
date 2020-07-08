; routines for updating sound registers
;

;
; Sets the wave ram from the given waveform index
; a: index in tbe_waveTable to set waveform
;
_tbe_writeWave:
    ld      hl, tbe_waveTable           ; lookup the waveform
    ld      b, 0                        ; bc = wave id
    ld      c, a
    add     hl, bc                      ; offset table by id
    add     hl, bc
    ld      a, [hl+]                    ; get pointer at id
    ld      c, a
    ld      a, [hl]
    ld      h, a
    ld      l, c
    xor     a                           ; CH3 sound off
    ld      [rNR30], a

    ld      b, 16                       ; copy to wave ram
    ld      c, _AUD3WAVERAM - $FF00
    call    _tbe_iomemcpy

    ld      a, $80                      ; CH3 sound on
    ld      [rNR30], a
    ret


;
; writes music panning settings to NR51. All locked channels will have their
; panning settings written to NR51.
;
_tbe_writePanning:
    ld      a, [tbe_wPanning]
    ld      b, a
    ld      a, [tbe_wChflags]
    and     a, $F0                      ; set lower nibble to the upper nibble
    ld      c, a
    swap    a
    or      a, c
    ld      c, a
    cpl
    and     a, b
    ld      b, a
    ld      a, [rNR51]
    and     a, c
    or      a, b
    ld      [rNR51], a


    ret

_tbe_writeSweep:
    ld      [rNR10], a
    retrigger 1
    ret
