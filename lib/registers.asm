; routines for updating sound registers
;



;
; a - timbre to write
; b - channel id (0-3)
;
_tbe_writeTimbre:
    chjumptable
.ch4:
    ld      d, a            ; d = timbre
    ld      a, [rNR43]      ; get current setting
    res     3, a            ; reset bit 3 (step-width)
    or      a, d            ; or with timbre
    ld      [rNR43], a      ; write back
    ret
.ch3:
    ld      [rNR32], a
    ret
.ch2:
    ld      [rNR21], a
    ret
.ch1:
    ld      [rNR11], a
    ret



_tbe_writeEnvelope:
    chjumptable
.ch4:
    ld      [rNR42], a
    ret
.ch3:
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
.ch2:
    ld      [rNR22], a
    ret
.ch1:
    ld      [rNR12], a
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



; _tbe_writeTimbre\1:
;     ld      a, [tbe_wTimbre\1]
; IF \1 == 1
;     ld      [rNR11], a
; ELIF \1 == 2
;     ld      [rNR21], a
; ELIF \1 == 3
;     ld      [rNR32], a
; ELSE
;     ld      d, a
;     ld      a, [rNR43]
;     res     3, a
;     or      a, d
;     ld      [rNR43], a
; ENDC
;     ret

; _tbe_writeEnvelope\1::
; IF \1 == 3
;     ; wave channel envelope is the waveform id
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
; ELSE
;     ld      [rNR\12], a
; ENDC
;     ret
