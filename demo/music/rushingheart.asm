; Artist: OmegaBagel (twitter: @omega_bagel)

INCLUDE "tbengine.inc"


SECTION "song_rushingheart", ROM0


PATTERN_SIZE EQU 64

DRUM_3 EQU C_6
DRUM_C EQU C_7
DRUM_7 EQU F_6

song_rushingheart::
    DB $11              ; speed (2.125 frames per row, ~420 BPM)
    DW .ch1_main
    DW .ch2_main
    DW .ch3_main
    DW .ch4_main

.ch1_main:
    timbre1
    setEnvelope $A7
    duration 7
    note G_3

    duration 1
    note NOTE_CUT
    duration 3
    note G_3

    duration 1
    note NOTE_CUT
    duration 3
    note D_4

    duration 1
    note NOTE_CUT
    duration 3
    note D_4

    duration 1
    note NOTE_CUT
    duration 3
    note C#4

    duration 1
    note NOTE_CUT
    duration 3
    note C#4

    duration 1
    note NOTE_CUT
    duration 3
    note D_4

    duration 1
    note NOTE_CUT
    duration 3
    note D_4

    duration 1
    note NOTE_CUT
    duration 3
    note G_4

    duration 1
    note NOTE_CUT
    duration 3
    note G_4

    duration 1
    note NOTE_CUT
    duration 4
    note D_4

    duration 1
    note A_4

    duration 6
    note A#4

    duration 1
    note NOTE_CUT
    duration 7
    note A_4

    duration 1
    note NOTE_CUT

    snd_jump .ch1_main

    _pattern_check PATTERN_SIZE

    DW .ch2_tr0
.ch2_main:
    snd_call .ch2_tr0
    timbre1
    setEnvelope $57
    duration 12
    note G_5

    timbre0
    setEnvelope $77
    duration 4
    note F_3

    duration 6
    note G_3

    duration 2
    note NOTE_CUT

    duration 4
    note A#3

    duration 6
    note C_4

    duration 2
    note NOTE_CUT

    duration 4
    note F_3
    
    duration 6
    note G_3

    duration 2
    note NOTE_CUT

    duration 4
    note C_3

    note A#2

    note G_2

    note F_2

    _pattern_check PATTERN_SIZE
    snd_call .ch2_tr0
    timbre1
    setEnvelope $57
    duration 8
    note G_5

    duration 4
    note NOTE_CUT

    timbre0
    setEnvelope $77
    note F_3

    duration 6
    note G_3

    duration 2
    note NOTE_CUT

    duration 2
    note C_4
    
    note D_4

    note C_4

    note A#3

    duration 4
    note G_3

    duration 2
    note C_4

    note D_4

    note C_4

    note A#3

    duration 4
    note G_3

    duration 2
    note C_4
    
    note D_4

    note C_4

    note A#3

    note G_3

    note F_3
    
    note C_3

    note A#2
    _pattern_check PATTERN_SIZE

    snd_jump .ch2_main

.ch3_main:
    setEnvelope $00
    duration 12
    note G_3

    duration 52
    note NOTE_CUT

    snd_jump .ch3_main

    _pattern_check PATTERN_SIZE

.ch4_main:
    snd_call .ch4_tr0
    setEnvelope $B1
    duration 4
    
    loopBegin
        note DRUM_3
    loopEnd 2

    duration 8

    loopBegin
        note DRUM_C
    loopEnd 4

    duration 4
    note DRUM_C

    note DRUM_3

    note DRUM_7

    ;_pattern_check PATTERN_SIZE
    snd_call .ch4_tr0
    setEnvelope $B1
    duration 4
    note DRUM_3

    note DRUM_3

    note DRUM_3

    duration 8
    note DRUM_C

    note DRUM_C

    note DRUM_C

    note DRUM_C

    note DRUM_C

    duration 4
    note DRUM_7

    duration 2
    note DRUM_7

    note DRUM_7

    note DRUM_7

    note DRUM_7


    _pattern_check PATTERN_SIZE
    snd_jump .ch4_main

; CH2 =========================================================================

.ch2_tr0:
    timbre1
    setEnvelope $57
    duration 8
    note G_5

    duration 4
    note NOTE_CUT

    timbre0
    setEnvelope $77
    note F_3

    duration 6
    note G_3

    duration 2
    note NOTE_CUT

    duration 4
    note A#3

    duration 6
    note C_4

    duration 2
    note NOTE_CUT

    duration 4
    note F_3
    
    duration 6
    note G_3

    duration 2
    note NOTE_CUT

    duration 4
    note A#2

    note C_3

    note F_2

    note G_2

    ret

    _pattern_check PATTERN_SIZE





; CH4 =========================================================================



.ch4_tr0:
    setEnvelope $B1
    duration 4
    note DRUM_3

    note DRUM_3

    note DRUM_3

    duration 8
    note DRUM_C

    note DRUM_C

    note DRUM_C

    note DRUM_C

    note DRUM_C

    duration 4
    note DRUM_C

    note DRUM_7

    note DRUM_C

    ret

    _pattern_check PATTERN_SIZE



.end:

PRINTT "song_rushingheart size: "
PRINTI song_rushingheart.end - song_rushingheart
PRINTT " bytes\n"
