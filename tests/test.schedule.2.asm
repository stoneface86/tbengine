INCLUDE "tests/utils.inc"

SECTION "test schedule2", ROM0

INCLUDE "tests/data/emptyWaveTable.inc"
INCLUDE "tests/data/schedule2.inc"

main::
    ld      hl, schedule2
    call    scheduleLoad

    ld      b, $FF
.loop:
    call    scheduleNext
    AssertReg a, %0_1111
    dec     b
    jr      nz, .loop

    call    scheduleNext
    AssertReg a, %1_1111

    xor     a, a
    ret
