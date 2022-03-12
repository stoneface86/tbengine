
; 2's complement negation
neg: MACRO
    cpl
    inc     a
ENDM

; negate word
_negw: MACRO
    ld      a, HIGH(\1)
    cpl
    ld      HIGH(\1), a
    ld      a, LOW(\1)
    cpl
    ld      LOW(\1), a
    inc     \1
ENDM

; add sign-extended byte to word. the value of register a gets sign-extended into
; the given 16-bit register and is then added to hl
; hl: word
; \1: r16 temporary register
_addsw: MACRO
    ld      LOW(\1), a
    add     a, a
    sbc     a, a
    ld      HIGH(\1), a
    add     hl, \1
ENDM

;
; Seek Struct (SeekS): Seek to a field in a struct pointer using the "this-in-de" pattern
; \1: offset to seek to
;
; depending on the offset, the code emitted will have different cycle counts
;
; offset   bytes  cycles   description
;   0        2       2      hl = de
;   1        3       4      hl = de, increment hl
;  >1        4       5      hl = \1, hl += de
;
seeks: MACRO
    IF \1 < 2
        ; 2 bytes, 2 cycles
        ld      h, d
        ld      l, e
        IF \1 == 1
            inc     hl
        ENDC
    ELSE
        ld      hl, \1
        add     hl, de
    ENDC
ENDM

;
; Jump table logic for b = channel id (0-3)
; b is set to 0 on finish
;
chjumptable: MACRO
; not actually a jump table
; if-else-branch is actually faster and smaller than a jump table
; branching: 5-11 cycles and 10 bytes
; jumptable: 13 cycles and 16 bytes
    inc     b                   ; set zero flag on b
    dec     b
    jr      z, .ch1             ; b = 0: CH1
    dec     b
    jr      z, .ch2             ; b = 1: CH2
    dec     b
    jr      z, .ch3             ; b = 2: CH3
                                ; for b > 2: CH4

; jumptable version
;     ld      hl, .jumptable
;     ld      b, 0
;     add     hl, bc
;     add     hl, bc
;     jp      hl
; .jumptable:
;     jr      .ch1
;     jr      .ch2
;     jr      .ch3
;     jr      .ch4
;
ENDM


;
; Retrigger a channel whilst keeping frequency data unchanged
; For CH3 you should disable/enable NR30 before invoking this macro!
; \1: channel id (1-4)
;
retrigger: MACRO
IF \1 == 4
    ld      a, $80
ELSE
    ld      a, [tbe_wFreq\1 + 1]    ; current frequency (upper bits)
    set     7, a                    ; set bit 7 to restart channel
ENDC
    ld      [rNR\14], a
ENDM

;
; Write envelope setting for a channel, channel is retriggered
; \1: channel id (1-4)
;
writeEnvelope: MACRO

IF \1 == 3
    call    _tbe_writeWave
ELSE
    ld      [rNR\12], a
ENDC
    retrigger \1

ENDM

;
; Writes timbre setting for a channel
; \1: channel id (1-4)
;
writeTimbre: MACRO
IF \1 == 1 || \1 == 2
    ld      [rNR\11], a
ELIF \1 == 3
    ld      [rNR32], a
ELSE
    ld      d, a            ; d = timbre
    ld      a, [rNR43]      ; get current setting
    res     3, a            ; reset bit 3 (step-width)
    or      a, d            ; or with timbre
    ld      [rNR43], a      ; write back
ENDC
ENDM

;
; Reload a channel with music settings
;
reload: MACRO

    ; low frequency
IF \1 == 4
    ld      a, [tbe_wTimbre4]
    ld      b, a
ENDC
    ld      a, [tbe_wFreq\1]
IF \1 == 4
    or      a, b
ENDC
    ld      [rNR\13], a

IF \1 != 4
    ld      a, [tbe_wTimbre\1]
    writeTimbre \1
ENDC
    ld      a, [tbe_wEnvelope\1]
    writeEnvelope \1

    ; TODO panning
ENDM
