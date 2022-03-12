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

    ; NR51 gets the result of the following formula
    ;
    ; ((y & z) & ~w) | (x & w)
    ; where
    ;  w: channel lock bits
    ;  x: current value of NR51
    ;  y: tbe_wPanning
    ;  z: tbe_wPanningMask
    ;
    ; when w is 0 (all channels locked) NR51 is set to (y & z)
    ; w determines which bits of NR51 remain unchanged and which bits are set
    ; from the music panning setting

ASSERT FATAL, tbe_wPanningMask - tbe_wPanning == 1, "panning variables not nearby"
    ld      hl, tbe_wPanning
    ld      a, [hl+]
    ld      b, [hl]
    and     a, b
    ld      b, a

    ld      a, [tbe_wChflags]
    and     a, $F0
    jr      z, .allLocked               ; just write y & z if all channels are locked
    ld      c, a
    swap    a
    or      a, c
    ld      c, a                        ; c = w
    cpl
    and     a, b
    ld      b, a                        ; b = (y & z) & ~w
    ld      a, [rNR51]                  ; a = x
    and     a, c                        ; a = x & w
    or      a, b                        ; a = ((y & z) & ~w) | (x & w)
    jr      .write
.allLocked:
    ld      a, b                        ; just write y & z
.write:
    ld      [rNR51], a
    ret

_tbe_writeSweep:
    ld      [rNR10], a
    retrigger 1
    ret
