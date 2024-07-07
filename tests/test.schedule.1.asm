INCLUDE "tests/utils.inc"

SECTION "test scheduleLoad", ROM0

INCLUDE "tests/data/emptyWaveTable.inc"
INCLUDE "tests/data/schedule1.inc"

main::
    ld      hl, schedule1
    call    scheduleLoad

    call    scheduleNext
    AssertReg   a, %0_0111
    call    scheduleNext
    AssertReg   a, %0_1101
    call    scheduleNext
    AssertReg   a, %0_0011
    call    scheduleNext
    AssertReg   a, %1_0001

    xor     a, a
    ret
