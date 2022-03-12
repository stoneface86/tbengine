
; Fills a range in memory with a specified byte value.
; hl = destination address
; bc = byte count
; a = byte value
_tbe_memset:
    inc     c
    inc     b
    jr      .start
.repeat:
    ld      [hl+], a
.start:
    dec     c
    jr      nz, .repeat
    dec     b
    jr      nz, .repeat
    ret

;
; Copy data from a source address to a destination address
; hl = source address
; de = destination address
; bc = number of bytes to copy
;
_tbe_memcpy:
    ld      a, [hl+]
    ld      [de], a
    inc     de
    dec     bc
    ld      a, b
    or      c
    jr      nz, _tbe_memcpy
    ret

; same as _tbe_memcpy but uses the ldio instruction
; hl = source address
; b = bytes to copy
; c = destination ($FF00 + c)
_tbe_iomemcpy:
    ld      a, [hl+]
    ld      [c], a
    inc     c
    dec     b
    ld      a, b
    or      a
    jr      nz, _tbe_iomemcpy
    ret


;
; Adds a signed byte to hl, the byte operand is placed into register bc and sign-extended
;
; Input
;  * a : the byte operand
;  * hl : word operand
; Output
;  * hl : result of hl + a
;
_tbe_addsw:
    _addsw  bc
    ret
