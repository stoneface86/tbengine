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
; a - timbre to write
; b - channel id (0-3)
;
; _tbe_writeTimbre:
;     chjumptable
; .ch4:
;     ld      d, a            ; d = timbre
;     ld      a, [rNR43]      ; get current setting
;     res     3, a            ; reset bit 3 (step-width)
;     or      a, d            ; or with timbre
;     ld      [rNR43], a      ; write back
;     ret
; .ch3:
;     ld      [rNR32], a
;     ret
; .ch2:
;     ld      [rNR21], a
;     ret
; .ch1:
;     ld      [rNR11], a
;     ret

;
; Updates the auto retrigger flag for the given note control variable. If an
; envelope setting is increasing/decreasing, then auto retrigger is enabled
; a - envelope
; hl - note control variable
;
; _tbe_updateAutoRetrigger:
;     ld      a, c
;     and     a, $7                       ; check period for 0
;     jr      z, .setAutoRetrigger
;     res     ENGINE_NC_TRIGGER, [hl]     ; nonzero period, enable auto retrigger
;     ret
; .setAutoRetrigger:
;     set     ENGINE_NC_TRIGGER, [hl]     ; zero period (constant volume) disable auto retrigger
;     ret


; _tbe_writeEnvelope:
;     chjumptable
; .ch4:
;     ld      b, a
;     ld      [rNR42], a                  ; set envelope register
;     retrigger 4
;     jr      _tbe_updateAutoRetrigger
; .ch3:
;     ld      hl, tbe_waveTable           ; lookup the waveform
;     ld      b, 0                        ; bc = wave id
;     ld      c, a
;     add     hl, bc                      ; offset table by id
;     add     hl, bc
;     ld      a, [hl+]                    ; get pointer at id
;     ld      c, a
;     ld      a, [hl]
;     ld      h, a
;     ld      l, c
;     xor     a                           ; CH3 sound off
;     ld      [rNR30], a

;     ld      b, 16                       ; copy to wave ram
;     ld      c, _AUD3WAVERAM - $FF00
;     call    _tbe_iomemcpy

;     ld      a, $80                      ; CH3 sound on
;     ld      [rNR30], a
;     retrigger 3
;     ret
; .ch2:
;     ld      b, a
;     ld      [rNR22], a
;     retrigger 2
;     jr      _tbe_updateAutoRetrigger
; .ch1:
;     ld      b, a
;     ld      [rNR12], a
;     retrigger 1
;     jr      _tbe_updateAutoRetrigger

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
