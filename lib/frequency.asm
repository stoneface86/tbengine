
; frequency control structure

FC_FLAG_VIBRATO EQU 5

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
; template macro
; \1 - channel id (1, 2 or 3)
;
fc_generate_code: MACRO

fc\1_reset:
    ld      hl, fc\1_flags
    ld      bc, fc2_flags - fc1_flags   ; jank
    xor     a, a
    call    memset
    ret


;
; Get the current frequency for the channel
;
; Input:
;  * N/A
; Output:
;  * bc = current frequency
;
fc\1_frequency:
    ld      a, [fc\1_arpIndex]      ; get the arpeggio index to offset the freq buffer
    sla     a                       ; double it (frequencies are words)
    ld      c, a                    ; bc = arpIndex * 2
    ld      b, 0

    ld      hl, fc\1_freq
    add     hl, bc                  ; offset freq pointer by the arpeggio index
    ld      a, [hl+]                ; bc = freq
    ld      c, a
    ld      b, [hl]
    ld      hl, fc\1_tune           ; get the pitch offset
    ld      a, [hl]                 ; d = tune
    ld      h, b                    ; hl = bc
    ld      l, c
    call    addsw                   ; hl += a (frequency is now offset by tune)
    

    ld      a, [fc\1_flags]         ; check flags for vibrato
    bit     FC_FLAG_VIBRATO, a
    jp      z, .skipVibrato         ; do not add vibCounter if bit is reset
    ld      a, [fc\1_vibCounter]    ; a = vibCounter
    call    addsw                   ; hl += a (frequency is now offset by vibCounter)
.skipVibrato:

    ld      b, h                    ; bc = hl
    ld      c, l
    call    clampFrequency          ; clamp if necessary

    ret


ENDM


    fc_generate_code 1
    fc_generate_code 2
    fc_generate_code 3

