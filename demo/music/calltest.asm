
INCLUDE "tbengine.inc"

SECTION "song_calltest", ROM0

song_calltest::
    DB $18              ; speed (3.0 frames per row, 900 BPM)
    DW .ch1_main
    DW .ch2_main
    DW .ch3_main
    DW .ch4_main

.ch1_main:
    duration 1
    timbre1

    loopBegin
        note C_5
        note D#5
        note G#5
        note C_5
    loopEnd 1

    loopBegin
        note D_5
        note F#5
        note A#5
        note D_5
    loopEnd 2
    snd_jump .ch1_main

.ch2_main:
.ch3_main:
.ch4_main:
    loopBegin
    duration 64
    note NOTE_HOLD
    loopEnd 0
