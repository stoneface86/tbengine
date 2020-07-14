; Artist: OmegaBagel (twitter: @omega_bagel)

INCLUDE "tbengine.inc"


SECTION "song_rushingheart", ROM0


PATTERN_SIZE EQU 64

song_rushingheart::
    DB $11              ; speed (2.125 frames per row, ~420 BPM)
    DW .ch1_main
    DW .ch2_main
    DW .ch3_main
    DW .ch4_main

.ch1_main:
    tbe_call .ch1_tr0
    tbe_call .ch1_main ; sloppy, will be replaced with loop command when implemented

.ch2_main:
    tbe_call .ch2_tr0
    tbe_call .ch2_tr1
    tbe_call .ch2_tr0
    tbe_call .ch2_tr2
    tbe_call .ch2_main

.ch3_main:
    tbe_call .ch3_tr0
    tbe_call .ch3_main

.ch4_main:
    tbe_call .ch4_tr0
    tbe_call .ch4_tr1
    tbe_call .ch4_tr0
    tbe_call .ch4_tr2
    tbe_call .ch4_main

; CH1 =========================================================================

.ch1_tr0:
    tbe_timbre1
    tbe_setEnvelope $A7
    tbe_duration 7
    tbe_note G_3

    tbe_duration 1
    tbe_note NOTE_CUT
    tbe_duration 3
    tbe_note G_3

    tbe_duration 1
    tbe_note NOTE_CUT
    tbe_duration 3
    tbe_note D_4

    tbe_duration 1
    tbe_note NOTE_CUT
    tbe_duration 3
    tbe_note D_4

    tbe_duration 1
    tbe_note NOTE_CUT
    tbe_duration 3
    tbe_note C#4

    tbe_duration 1
    tbe_note NOTE_CUT
    tbe_duration 3
    tbe_note C#4

    tbe_duration 1
    tbe_note NOTE_CUT
    tbe_duration 3
    tbe_note D_4

    tbe_duration 1
    tbe_note NOTE_CUT
    tbe_duration 3
    tbe_note D_4

    tbe_duration 1
    tbe_note NOTE_CUT
    tbe_duration 3
    tbe_note G_4

    tbe_duration 1
    tbe_note NOTE_CUT
    tbe_duration 3
    tbe_note G_4

    tbe_duration 1
    tbe_note NOTE_CUT
    tbe_duration 4
    tbe_note D_4

    tbe_duration 1
    tbe_note A_4

    tbe_duration 6
    tbe_note A#4

    tbe_duration 1
    tbe_note NOTE_CUT
    tbe_duration 7
    tbe_note A_4

    tbe_duration 1
    tbe_note NOTE_CUT

    tbe_ret

    _pattern_check PATTERN_SIZE

; CH2 =========================================================================

.ch2_tr0:
    tbe_timbre1
    tbe_setEnvelope $57
    tbe_duration 8
    tbe_note G_5

    tbe_duration 4
    tbe_note NOTE_CUT

    tbe_timbre0
    tbe_setEnvelope $77
    tbe_note F_3

    tbe_duration 6
    tbe_note G_3

    tbe_duration 2
    tbe_note NOTE_CUT

    tbe_duration 4
    tbe_note A#3

    tbe_duration 6
    tbe_note C_4

    tbe_duration 2
    tbe_note NOTE_CUT

    tbe_duration 4
    tbe_note F_3
    
    tbe_duration 6
    tbe_note G_3

    tbe_duration 2
    tbe_note NOTE_CUT

    tbe_duration 4
    tbe_note A#2

    tbe_note C_3

    tbe_note F_2

    tbe_note G_2

    tbe_ret

    _pattern_check PATTERN_SIZE

.ch2_tr1:
    tbe_timbre1
    tbe_setEnvelope $57
    tbe_duration 12
    tbe_note G_5

    tbe_timbre0
    tbe_setEnvelope $77
    tbe_duration 4
    tbe_note F_3

    tbe_duration 6
    tbe_note G_3

    tbe_duration 2
    tbe_note NOTE_CUT

    tbe_duration 4
    tbe_note A#3

    tbe_duration 6
    tbe_note C_4

    tbe_duration 2
    tbe_note NOTE_CUT

    tbe_duration 4
    tbe_note F_3
    
    tbe_duration 6
    tbe_note G_3

    tbe_duration 2
    tbe_note NOTE_CUT

    tbe_duration 4
    tbe_note C_3

    tbe_note A#2

    tbe_note G_2

    tbe_note F_2

    tbe_ret

    _pattern_check PATTERN_SIZE

.ch2_tr2:
    tbe_timbre1
    tbe_setEnvelope $57
    tbe_duration 8
    tbe_note G_5

    tbe_duration 4
    tbe_note NOTE_CUT

    tbe_timbre0
    tbe_setEnvelope $77
    tbe_note F_3

    tbe_duration 6
    tbe_note G_3

    tbe_duration 2
    tbe_note NOTE_CUT

    tbe_duration 2
    tbe_note C_4
    
    tbe_note D_4

    tbe_note C_4

    tbe_note A#3

    tbe_duration 4
    tbe_note G_3

    tbe_duration 2
    tbe_note C_4

    tbe_note D_4

    tbe_note C_4

    tbe_note A#3

    tbe_duration 4
    tbe_note G_3

    tbe_duration 2
    tbe_note C_4
    
    tbe_note D_4

    tbe_note C_4

    tbe_note A#3

    tbe_note G_3

    tbe_note F_3
    
    tbe_note C_3

    tbe_note A#2

    tbe_ret

    _pattern_check PATTERN_SIZE

; CH3 =========================================================================

.ch3_tr0:
    tbe_setEnvelope $00
    tbe_duration 12
    tbe_note G_3

    tbe_duration 52
    tbe_note NOTE_CUT

    tbe_ret

    _pattern_check PATTERN_SIZE

; CH4 =========================================================================

DRUM_3 EQU C_6
DRUM_C EQU C_7
DRUM_7 EQU F_6

.ch4_tr0:
    tbe_setEnvelope $B1
    tbe_duration 4
    tbe_note DRUM_3

    tbe_note DRUM_3

    tbe_note DRUM_3

    tbe_duration 8
    tbe_note DRUM_C

    tbe_note DRUM_C

    tbe_note DRUM_C

    tbe_note DRUM_C

    tbe_note DRUM_C

    tbe_duration 4
    tbe_note DRUM_C

    tbe_note DRUM_7

    tbe_note DRUM_C

    tbe_ret

    _pattern_check PATTERN_SIZE

.ch4_tr1:
    tbe_setEnvelope $B1
    tbe_duration 4
    tbe_note DRUM_3

    tbe_note DRUM_3

    tbe_note DRUM_3

    tbe_duration 8
    tbe_note DRUM_C

    tbe_note DRUM_C

    tbe_note DRUM_C

    tbe_note DRUM_C

    tbe_note DRUM_C

    tbe_duration 4
    tbe_note DRUM_C

    tbe_note DRUM_3

    tbe_note DRUM_7

    tbe_ret

    _pattern_check PATTERN_SIZE

.ch4_tr2:
    tbe_setEnvelope $B1
    tbe_duration 4
    tbe_note DRUM_3

    tbe_note DRUM_3

    tbe_note DRUM_3

    tbe_duration 8
    tbe_note DRUM_C

    tbe_note DRUM_C

    tbe_note DRUM_C

    tbe_note DRUM_C

    tbe_note DRUM_C

    tbe_duration 4
    tbe_note DRUM_7

    tbe_duration 2
    tbe_note DRUM_7

    tbe_note DRUM_7

    tbe_note DRUM_7

    tbe_note DRUM_7

    tbe_ret

    _pattern_check PATTERN_SIZE

.end:

PRINTT "song_rushingheart size: "
PRINTI song_rushingheart.end - song_rushingheart
PRINTT " bytes\n"
