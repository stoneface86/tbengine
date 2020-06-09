; ----------------------------------------------------------------------------
; Frequency

; frequency control structure
; A frequency control handles frequency effects as well as calculation

                        RSRESET
FreqControl_flags       RB 1        ; flags
FreqControl_note        RB 1        ; current note
FreqControl_tune        RB 1        ; pitch offset (signed)
FreqControl_freq        RW 3        ; frequency buffer/chord
FreqControl_slideSpeed  RB 1        ; speed of a pitch/note slide or portamento (pitch units/frame)
FreqControl_slideTarget RW 1        ; target frequency of a slide
FreqControl_slideNote   RB 1        ; note to slide to
FreqControl_arpParam    RB 1        ; semitone offsets for the arpeggio "chord"
FreqControl_arpIndex    RB 1        ; index in the frequency buffer to use as base
FreqControl_vibCounter  RB 1        ; current value of the vibrato
FreqControl_vibIndex    RB 1        ; current index/angle of the vibrato waveform
FreqControl_vibSpeed    RB 1        ; speed of the vibrato
FreqControl_vibTable    RB 2        ; pointer to the current vibrato table (extent)
FreqControl_SIZEOF      RB 0

FC_FLAG_NOTE_SET    EQU 0   ; bit 0: set if a new note was set
FC_FLAG_VIBRATO     EQU 5   ; bit 5: set if vibrato is enabled

;
; Clamps a given frequency to 0-2047
;
; Input
;   * bc - frequency
;
; Output
;   * bc - clamped frequency
;
clampFrequency:
    ; first clamp to 0 if the frequency is negative
    ; then clamp to $7FF if any of the upper 6 bits are set

    bit     7, b                ; if the MSB of bc is set, we have a negative
    jp      z, .clampToMax
    ld      bc, 0               ; we have a negative, bc = 0
    ret
.clampToMax:
    ld      a, b
    and     a, %11111000        ; a > $7 if the result of this AND is nonzero
    ret     z                   ; no need to clamp if zero
    ld      bc, $7FF            ; clamp to maximum frequency
    ret

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
;  hl - pointer to a vibrato table
;
; returns:
;  a - vibrato value (signed)
;
lookupVibrato::
    ld      a, b
    and     a, $1F
    ret     z               ; if the index is 0 or 32, return 0

    push    hl
    push    de
    
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

;
; Reset the FreqControl struct to the default state
;
; Input:
;  * hl : pointer to FreqControl struct
; Output:
;  * n/a
;
fc_reset:
    push    bc
    ld      bc, FreqControl_SIZEOF
    xor     a, a
    call    memset                  ; reset results in all fields set to 0
    pop     bc
    ret

;
; Get the current frequency for the given frequency control
;
; Input:
;  * hl : pointer to FreqControl struct
; Output:
;  * bc = current frequency
;
fc_frequency:
    push    de                      ; save de
    ld      d, h                    ; this-in-de (put pointer to FreqControl in de)
    ld      e, l


    seeks   FreqControl_arpIndex
    ld      a, [hl]                 ; get the arpeggio index to offset the freq buffer
    sla     a                       ; double it (frequencies are words)
    ld      c, a                    ; bc = arpIndex * 2
    ld      b, 0

    seeks   FreqControl_freq
    add     hl, bc                  ; offset freq pointer by the arpeggio index
    ld      a, [hl+]                ; bc = freq
    ld      c, a
    ld      b, [hl]
    seeks   FreqControl_tune        ; get the pitch offset
    ld      a, [hl]                 ; d = tune
    ld      h, b                    ; hl = bc
    ld      l, c
    call    addsw                   ; hl += a (frequency is now offset by tune)
    ld      b, h                    ; bc = hl
    ld      c, l

    seeks   FreqControl_flags
    ld      a, [hl]
    bit     FC_FLAG_VIBRATO, a
    jp      z, .skipVibrato         ; do not add vibCounter if bit is reset
    ld      hl, FreqControl_vibCounter
    add     hl, de
    ld      a, [hl]                 ; a = vibCounter
    ld      h, b
    ld      l, c
    call    addsw                   ; hl += a (frequency is now offset by vibCounter)
    ld      b, h                    ; bc = hl
    ld      c, l
.skipVibrato:

    call    clampFrequency          ; clamp if necessary

    ; restore hl
    ld      h, d
    ld      l, e
    pop     de
    ret

fc_setNote:
    set     FC_FLAG_NOTE_SET, [hl]  ; update flags
    inc     hl                      ; hl points to note
    ld      [hl], a                 ; set note
    ret

fc_setVibrato:
    ret

