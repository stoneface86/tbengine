
; Fills a range in memory with a specified byte value.
; hl = destination address
; bc = byte count
; a = byte value
memset:
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
; Adds a signed byte to hl, the byte operand is placed into register bc and sign-extended
;
; Input
;  * a : the byte operand
;  * hl : word operand
; Output
;  * hl : result of hl + a
;
addsw:
    _addsw  bc
    ret
