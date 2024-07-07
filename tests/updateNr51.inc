
INCLUDE "hardware.inc"

INCLUDE "tests/data/emptyWaveTable.inc"

;;
;; Test implementation for updateNr51 tests.
;; Parameters:
;;  \1 .. \4: initial settings for wPanning1 .. wPanning4
;;  \5: initial value for wLockFlags
;;  \6: initial value for NR51
;;  \7: Expected value in NR51 after calling updateNr51
;;
MACRO testUpdateNr51
main::
    call    soundOn
    ; set panning dirty
    ld  a, 1
    ld  [wPanningDirty], a
    ; set test initial conditions
    ld  a, \1
    ld  [wPanning1], a
    ld  a, \2
    ld  [wPanning2], a
    ld  a, \3
    ld  [wPanning3], a
    ld  a, \4
    ld  [wPanning4], a
    ld  a, \5
    ld  [wLockFlags], a
    ld  a, \6
    ld  [rNR51], a


    ; test
    call    updateNr51

    ; check that wPanningDirty was cleared
    ld      a, [wPanningDirty]
    or      a, a
    ret     nz

    ; check that NR51 was set to our expected value
    ld      a, [rNR51]
    ld      b, \7
    xor     a, b
    ret

ENDM
