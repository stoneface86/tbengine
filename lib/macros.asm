
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
