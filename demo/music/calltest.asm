
INCLUDE "tbengine.inc"

SECTION "song_calltest", ROM0

song_calltest::
    DB $18              ; speed (3.0 frames per row, 900 BPM)
    DW .ch1_main
    DW .ch2_main
    DW .ch3_main
    DW .ch4_main

.ch1_main:
    tbe_duration 1
    tbe_timbre1
.loop1:
    tbe_note C_5
    tbe_note D#5
    tbe_note G#5
    tbe_note C_5
    tbe_loop 1, .loop1
.loop2:
    tbe_note D_5
    tbe_note F#5
    tbe_note A#5
    tbe_note D_5
    tbe_loop 2, .loop2
    tbe_jump .ch1_main

.ch2_main:
.ch3_main:
.ch4_main:
    tbe_duration 64
    tbe_note NOTE_HOLD
    tbe_jump .ch2_main
