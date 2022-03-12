
SECTION "test_seqenum code", ROM0

SEQDATA0 EQU $0
SEQDATA1 EQU $1
SEQDATA2 EQU $2
SEQDATA3 EQU $3


example_sequence:
    DB SEQDATA0, SEQDATA1, SEQDATA2, SEQDATA3

init_enumerator:
    ; initialize the enumerator
    ld      hl, wTestEnum
    ld      a, LOW(example_sequence)
    ld      [wTestEnum], a
    ld      a, HIGH(example_sequence)
    ld      [wTestEnum+1], a
    ld      a, 4
    ld      [wTestEnum+2], a
    ld      a, b
    ld      [wTestEnum+3], a
    ret

;
; common test code for testing the sequence enumerator
;
seqenum_test_common:
    call    seqenum_has         ; assert has
    or      a, a
    ld      a, $1
    ret     z

    call    seqenum_next        ; assert next == 0
    ld      a, SEQDATA0
    cp      a, b
    ld      a, $2
    ret     nz

    call    seqenum_has         ; assert has
    or      a, a
    ld      a, $3
    ret     z

    call    seqenum_next        ; assert next == 1
    ld      a, SEQDATA1
    cp      a, b
    ld      a, $4
    ret     nz

    call    seqenum_has         ; assert has
    or      a, a
    ld      a, $5
    ret     z

    call    seqenum_next        ; assert next == 2
    ld      a, SEQDATA2
    cp      a, b
    ld      a, $6
    ret     nz

    call    seqenum_has         ; assert has
    or      a, a
    ld      a, $7
    ret     z

    call    seqenum_next        ; assert next == 3
    ld      a, SEQDATA3
    cp      a, b
    ld      a, $8
    ret     nz

    xor     a, a
    ret

test_seqenum::
    ld      b, 0
    call    init_enumerator

    ; test
    call    seqenum_test_common
    or      a, a
    ret     nz

    call    seqenum_has         ; assert !has
    or      a, a
    ld      a, $8
    ret     nz

    call    seqenum_has         ; assert !has
    or      a, a
    ld      a, $9
    ret     nz

    call    seqenum_has         ; assert !has
    or      a, a
    ld      a, $A
    ret     nz

    ; test passed
    xor     a, a
    ret

test_seqenum_loop::
    ld      b, 2
    call    init_enumerator

    call    seqenum_test_common
    or      a, a
    ret     nz

    call    seqenum_has          ; assert has
    or      a, a
    ld      a, $8
    ret     z

    call    seqenum_next        ; assert next == 2
    ld      a, SEQDATA2
    cp      a, b
    ld      a, $9
    ret     nz

    call    seqenum_has         ; assert has
    or      a, a
    ld      a, $A
    ret     z

    call    seqenum_next        ; assert next == 3
    ld      a, SEQDATA3
    cp      a, b
    ld      a, $B
    ret     nz

    call   seqenum_has          ; assert has
    or     a, a
    ld     a, $C
    ret    z

    call    seqenum_next        ; assert next == 2
    ld      a, SEQDATA2
    cp      a, b
    ld      a, $D
    ret     nz

    call    seqenum_has         ; assert has
    or      a, a
    ld      a, $E
    ret     z

    call    seqenum_next        ; assert next == 3
    ld      a, SEQDATA3
    cp      a, b
    ld      a, $F
    ret     nz

    xor     a, a
    ret


SECTION "test_seqenum wram", WRAM0

wTestEnum:
    DS 4
