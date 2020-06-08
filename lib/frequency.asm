
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

