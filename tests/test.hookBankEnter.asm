
DEF TestBank EQU 4

DEF DummyData1 EQU $BE
DEF DummyData2 EQU $EF

DEF TestFailedHookNotCalled EQU 1
DEF TestFailedBankSwitched EQU 2

SECTION "test hookBankEnter", ROM0

tbeOnBankEnter::
    cp      a, TestBank
    ret     nz
    ld      a, 1
    ld      [wOnBankEnterCalled], a
    ret


main::
    ld      [wOnBankEnterCalled], a

    call    tbeInit
    ld      a, TestBank
    ld      [wSongBank], a
    call    tbeUpdate
    ; check if the bank switched by tbeUpdate
    ld      hl, dummyData
    ld      a, [hl+]
    cp      a, DummyData1
    jr      nz .failBankSwitched
    ld      a, [hl]
    cp      a, DummyData2
    jr      nz, .failBankSwitched
    ; check if the hook was called
    ld      a, [wOnBankEnterCalled]
    or      a, a
    jr      z, .failHookNotCalled
.passed:
    xor     a, a
    ret
.failBankSwitched:
    ld      a, TestFailedBankSwitched
    ret
.failHookNotCalled:
    ld      a, TestFailedHookNotCalled
    ret


SECTION "dummy bank data", ROMX, BANK[1]

dummyData:
    DB DummyData1, DummyData2

SECTION "test wram", WRAM0

wOnBankEnterCalled: DS 1

