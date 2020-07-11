
INCLUDE "tbengine.inc"

SECTION "song_calltest", ROM0

song_calltest::
    DB $30              ; speed (6.0 frames per row, 150 BPM)
    DB $1 - 1           ; order size
    DB 64 - 1           ; pattern size
    DW .order

.order:
    DW .ch1_tr0, .ch2_tr0, .ch3_tr0, .ch4_tr0

.sub1:
    tbe_duration 4
    tbe_note C_4

    tbe_note C#4

    tbe_note F_4

    tbe_ret

.ch1_tr0:
    tbe_call .sub1
    tbe_call .sub1

    tbe_duration 40
    tbe_note NOTE_HOLD

.ch2_tr0:
.ch3_tr0:
.ch4_tr0:
    tbe_duration 64
    tbe_note NOTE_HOLD
