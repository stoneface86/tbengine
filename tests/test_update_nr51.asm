
INCLUDE "hardware.inc"

SECTION "test update nr51", ROM0

testdata1:
    DB $11
    DB $22
    DB $44
    DB $88
    DB $00 ; all locked
    DB $00 ; NR51 before test
    DB $FF ; NR51 after test

testdata2:
    DB $11
    DB $20
    DB $44
    DB $88
    DB $11 ; CH1 unlocked
    DB $00
    DB $EC

;
; Do the test for update_nr51
; Input:
;  hl - pointer to test data
; Output:
;  z flag is set on success
;
dotest:
    ; set panning dirty (to test that update_nr51 clears it)
    ld      a, 1
    ld      [wPanningDirty], a
    ; set panning settings from test data
    ld      a, [hl+]
    ld      de, wPanning1
    ld      [de], a
    ld      a, [hl+]
    inc     de
    ld      [de], a
    ld      a, [hl+]
    inc     de
    ld      [de], a
    ld      a, [hl+]
    inc     de
    ld      [de], a
    ; set lock flags from test data
    ld      a, [hl+]
    ld      [wLockFlags], a

    ; set NR51 from test data
    ld      a, [hl+]
    ld      [rNR51], a

    ; test
    call    update_nr51

    ; check that wPanningDirty was cleared
    ld      a, [wPanningDirty]
    or      a, a
    ret     nz

    ; check that NR51 was set to our expected value
    ld      a, [rNR51]
    ld      b, a
    ld      a, [hl]
    cp      a, b
    ret

test_update_nr51::

    ld      a, $80
    ld      [rNR52], a

    ld      hl, testdata1
    call    dotest
    ld      a, 1
    ret     nz

    ld      hl, testdata2
    call    dotest
    ld      a, 2
    ret     nz

    xor     a, a
    ld      [rNR52], a
    ret

