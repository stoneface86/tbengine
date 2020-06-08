
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


