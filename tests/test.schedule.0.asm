
INCLUDE "tests/utils.inc"

SECTION "test schedule 0", ROM0

INCLUDE "tests/data/emptyWaveTable.inc"
INCLUDE "tests/data/schedule0.inc"

main::
    ld      hl, schedule0
    call    scheduleLoad

    call    scheduleNext
    AssertReg   a, %0_0101
    call    scheduleNext
    AssertReg   a, %0_0101
    call    scheduleNext
    AssertReg   a, %0_0101
    call    scheduleNext
    AssertReg   a, %0_0101
    call    scheduleNext
    AssertReg   a, %0_0011
    call    scheduleNext
    AssertReg   a, %0_0011
    call    scheduleNext
    AssertReg   a, %0_0011
    call    scheduleNext
    AssertReg   a, %0_0011
    call    scheduleNext
    AssertReg   a, %1_0101

    xor     a, a
    ret
