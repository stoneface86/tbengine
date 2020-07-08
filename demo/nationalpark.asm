
SECTION "nationalpark_song", ROM0

INCLUDE "tbengine.inc"

PATTERN_SIZE EQU 64

song_natpark::
    DB $48              ; speed (9.0 frames per row, 100 BPM)
    DB 11 - 1           ; order size
    DB PATTERN_SIZE - 1 ; pattern size
    DW natpark_order

natpark_order:
    DW natpark_ch4_tr0, natpark_ch4_tr0, natpark_ch3_tr0, natpark_ch4_tr0
    DW natpark_ch1_tr1, natpark_ch2_tr1, natpark_ch3_tr1, natpark_ch4_tr1
    DW natpark_ch1_tr2, natpark_ch2_tr2, natpark_ch3_tr2, natpark_ch4_tr1
    DW natpark_ch1_tr3, natpark_ch2_tr2, natpark_ch3_tr3, natpark_ch4_tr1
    DW natpark_ch1_tr1, natpark_ch2_tr1, natpark_ch3_tr1, natpark_ch4_tr1
    DW natpark_ch1_tr2, natpark_ch2_tr2, natpark_ch3_tr2, natpark_ch4_tr1
    DW natpark_ch1_tr3, natpark_ch2_tr3, natpark_ch3_tr4, natpark_ch4_tr1
    DW natpark_ch1_tr4, natpark_ch2_tr4, natpark_ch3_tr5, natpark_ch4_tr1
    DW natpark_ch1_tr5, natpark_ch2_tr5, natpark_ch3_tr6, natpark_ch4_tr1
    DW natpark_ch1_tr4, natpark_ch2_tr4, natpark_ch3_tr5, natpark_ch4_tr1
    DW natpark_ch1_tr6, natpark_ch2_tr6, natpark_ch3_tr7, natpark_ch4_tr1


natpark_ch3_tr0:
    tbe_setEnvelope $03
    tbe_setTimbre $20
    tbe_note G#5

    tbe_skip $00
    tbe_note A#5

natpark_ch4_tr0:
    tbe_duration 2
    tbe_note NOTE_REST


natpark_ch4_tr1:
    _pattern_check_reset
    tbe_duration 64
    tbe_note NOTE_REST
    _pattern_check PATTERN_SIZE

natpark_ch1_tr1:
    tbe_setTimbre $40
    tbe_setEnvelope $77
    tbe_duration 6
    tbe_note G#3

    ; --

    tbe_duration 2
    tbe_note F_4

    tbe_duration 1
    tbe_setEnvelope $47
    tbe_note F_4

    tbe_note G#4

    tbe_setEnvelope $57
    tbe_note F_4

    tbe_note G#4

    tbe_setEnvelope $77
    tbe_note F_4

    tbe_note G#4

    tbe_setEnvelope $97
    tbe_note F_4

    tbe_note G#4

    tbe_duration 6
    tbe_setEnvelope $77
    tbe_note A_3

    ; --

    tbe_duration 2
    tbe_note F#4

    tbe_duration 1
    tbe_setEnvelope $47
    tbe_note F#4

    tbe_note A_4

    tbe_setEnvelope $57
    tbe_note F#4

    tbe_note A_4

    tbe_setEnvelope $77
    tbe_note F#4

    tbe_note A_4

    tbe_setEnvelope $97
    tbe_note F#4

    tbe_note A_4

    tbe_duration 6
    tbe_setEnvelope $77
    tbe_note G#3

    ; --

    tbe_duration 2
    tbe_note F_4

    tbe_duration 1
    tbe_setEnvelope $47
    tbe_note C_5

    tbe_note C#5

    tbe_setEnvelope $57
    tbe_note C_5

    tbe_note C#5

    tbe_setEnvelope $77
    tbe_note C_5

    tbe_note C#5

    tbe_setEnvelope $97
    tbe_note C_5

    tbe_note C#5

    tbe_duration 6
    tbe_setEnvelope $77
    tbe_note A_3

    ; --

    tbe_duration 2
    tbe_note C#4

    tbe_duration 1
    tbe_setEnvelope $47
    tbe_note C#5

    tbe_note D#5

    tbe_setEnvelope $57
    tbe_note C#5

    tbe_note D#5

    tbe_setEnvelope $77
    tbe_note C#5

    tbe_note D#5

    tbe_setEnvelope $97
    tbe_note C#5

    tbe_note D#5

    _pattern_check PATTERN_SIZE

natpark_ch1_tr2:
    tbe_duration 2
    tbe_note C#5

    tbe_note A#4

    tbe_note C#5

    tbe_note A#4

    tbe_note C#5

    tbe_note A#4

    tbe_note C#5

    tbe_note A#4

    tbe_note C#5

    tbe_note A#4

    tbe_note C#5

    tbe_note A#4

    ; --

    tbe_setEnvelope $47
    tbe_duration 1
    tbe_note C#5

    tbe_note D#5

    tbe_setEnvelope $57
    tbe_note C#5

    tbe_note D#5

    tbe_setEnvelope $77
    tbe_note C#5

    tbe_note D#5

    tbe_setEnvelope $97
    tbe_note C#5

    tbe_note D#5

    tbe_setEnvelope $77
    tbe_duration 2
    tbe_note C_5

    tbe_note G#4

    tbe_note C_5

    tbe_note G#4

    tbe_note D#5

    tbe_note C_5

    tbe_note D#5

    tbe_note C_5
    
    tbe_note D_5

    tbe_note A#4

    tbe_note D_5
    
    tbe_note A#4

    ; --

    tbe_setEnvelope $47
    tbe_duration 1
    tbe_note F_5

    tbe_note D#5

    tbe_setEnvelope $57
    tbe_note D_5

    tbe_note D#5

    tbe_setEnvelope $77
    tbe_note F_5

    tbe_note F#5

    tbe_setEnvelope $97
    tbe_note G#5

    tbe_note A#5

    _pattern_check PATTERN_SIZE

natpark_ch1_tr3:

    tbe_duration 2
    tbe_note C#5

    tbe_note A#4

    tbe_note C#5

    tbe_note A#4

    tbe_note C#5

    tbe_note A#4

    tbe_note C#5

    tbe_note A#4

    tbe_note C#5

    tbe_note A#4

    tbe_note C#5

    tbe_note A#4

    tbe_setEnvelope $47
    tbe_duration 1
    tbe_note C#5

    tbe_note D#5

    tbe_setEnvelope $57
    tbe_note C#5

    tbe_note D#5

    tbe_setEnvelope $77
    tbe_note C#5

    tbe_note D#5

    tbe_setEnvelope $97
    tbe_note C#5

    tbe_note D#5

    tbe_duration 2
    tbe_note C_5

    tbe_note G#4

    tbe_note C_5

    tbe_note G#4

    tbe_note D#5

    tbe_note C_5

    tbe_note D#5

    tbe_note C_5

    tbe_note D_5

    tbe_note A#4

    tbe_note D_5

    tbe_note A#4

    tbe_note D_5

    tbe_note A#4

    tbe_note D_5

    tbe_note A#4

    _pattern_check PATTERN_SIZE

natpark_ch1_tr4:
    tbe_duration 19
    tbe_note NOTE_CUT

    tbe_duration 1
    tbe_note A#5
    tbe_note A#5
    tbe_note NOTE_CUT
    tbe_note A#5
    tbe_note NOTE_CUT
    tbe_note A#5
    tbe_note NOTE_CUT

    tbe_duration 2
    tbe_note A#5

    tbe_duration 23
    tbe_note NOTE_CUT

    tbe_duration 1
    tbe_note A#5
    tbe_note A#5
    tbe_note NOTE_CUT
    tbe_note A#5
    tbe_note NOTE_CUT
    tbe_note A#5
    tbe_note NOTE_CUT

    tbe_duration 2
    tbe_note A#5

    tbe_duration 4
    tbe_note NOTE_CUT

    _pattern_check PATTERN_SIZE

natpark_ch1_tr5:
    tbe_duration 32
    tbe_note NOTE_REST

    tbe_duration 2
    tbe_note A#3

    tbe_note D_4

    tbe_note F_4

    tbe_note G#4

    tbe_note D_4

    tbe_note F_4

    tbe_note A#4

    tbe_duration 1
    tbe_note D_5

    tbe_note C#5

    tbe_note D_5

    tbe_note NOTE_CUT

    tbe_note D_5

    tbe_note NOTE_CUT

    tbe_note C#5

    tbe_note NOTE_CUT

    tbe_note D_5

    tbe_duration 3
    tbe_note NOTE_CUT
    
    tbe_duration 1
    tbe_note D_5

    tbe_duration 3
    tbe_note NOTE_CUT

    tbe_duration 1
    tbe_note D_5

    tbe_note NOTE_CUT


    _pattern_check PATTERN_SIZE

natpark_ch1_tr6:

    tbe_note E_4

    tbe_duration 5
    tbe_note F_4

    tbe_duration 4
    tbe_note D#4

    tbe_duration 2
    tbe_note NOTE_CUT

    tbe_duration 12
    tbe_note C_4

    tbe_duration 8
    tbe_note F_4

    tbe_duration 1
    tbe_note C#4

    tbe_duration 16
    tbe_note D_4

    tbe_duration 7
    tbe_note D_4

    tbe_duration 8
    tbe_note NOTE_CUT
    _pattern_check PATTERN_SIZE

natpark_ch2_tr1:
    
    tbe_setEnvelope $A7
    tbe_setTimbre $40
    tbe_tempo $48
    tbe_duration 6
    tbe_note C#3
    
    tbe_duration 2
    tbe_note G#3

    tbe_duration 8
    tbe_note C#4

    tbe_duration 6
    tbe_note C#3

    tbe_duration 2
    tbe_note A_3

    tbe_duration 8
    tbe_note C#4

    tbe_duration 6
    tbe_note C#3

    tbe_duration 2
    tbe_note G#3

    tbe_duration 8
    tbe_note C#4

    tbe_duration 6
    tbe_note C#3

    tbe_duration 2
    tbe_note A_3

    tbe_duration 8
    tbe_note F#4
    
    _pattern_check PATTERN_SIZE

natpark_ch2_tr2:
    

    tbe_duration 6
    tbe_note F#2

    tbe_duration 2
    tbe_note C#3

    tbe_duration 8
    tbe_note A#3

    tbe_duration 6
    tbe_note F#2

    tbe_duration 2
    tbe_note C#3

    tbe_duration 8
    tbe_note A_3

    tbe_duration 6
    tbe_note F_2

    tbe_duration 2
    tbe_note C_3
    
    tbe_duration 8
    tbe_note G#3

    tbe_duration 6
    tbe_note A#2

    tbe_duration 2
    tbe_note F_3
    
    tbe_duration 8
    tbe_note D_4
    _pattern_check PATTERN_SIZE

natpark_ch2_tr3:
    

    tbe_duration 6
    tbe_note F#2

    tbe_duration 2
    tbe_note C#3

    tbe_duration 8
    tbe_note A#3

    tbe_duration 6
    tbe_note F#2

    tbe_duration 2
    tbe_note C#3

    tbe_duration 8
    tbe_note A_3

    tbe_duration 6
    tbe_note F_2

    tbe_duration 2
    tbe_note C_3
    
    tbe_duration 8
    tbe_note G#3

    tbe_duration 6
    tbe_note A#2

    tbe_duration 2
    tbe_note F_3
    
    tbe_note NOTE_CUT

    tbe_note G#5

    tbe_note F#5

    tbe_note F_5
    _pattern_check PATTERN_SIZE

natpark_ch2_tr4:
    

    tbe_tempo $24
    tbe_note E_5

    tbe_duration 5
    tbe_note F_5

    tbe_duration 4
    tbe_note F#5

    tbe_duration 2
    tbe_note NOTE_CUT

    tbe_duration 7
    tbe_note C#5

    tbe_duration 1
    tbe_note E_6
    
    tbe_note F_6

    tbe_note NOTE_CUT

    tbe_note F_6

    tbe_note NOTE_CUT

    tbe_note E_6

    tbe_note NOTE_CUT

    tbe_duration 2
    tbe_note F_6

    tbe_note A#4

    tbe_note C#5

    tbe_duration 1
    tbe_note E_5

    tbe_duration 5
    tbe_note F_5

    tbe_duration 4
    tbe_note F#5

    tbe_duration 2
    tbe_note NOTE_CUT

    tbe_duration 7
    tbe_note D#5

    tbe_setEnvelope $87
    tbe_duration 1
    tbe_note D_6

    tbe_note D#6

    tbe_note NOTE_CUT

    tbe_note D#6

    tbe_note NOTE_CUT

    tbe_note D_6

    tbe_note NOTE_CUT

    tbe_duration 2
    tbe_note D#6

    tbe_setEnvelope $A7
    tbe_note D_5

    tbe_note C#5
    _pattern_check PATTERN_SIZE


natpark_ch2_tr5:

    

    tbe_note B_4

    tbe_duration 5
    tbe_note C_5

    tbe_duration 4
    tbe_note G#4

    tbe_duration 2
    tbe_note NOTE_CUT

    tbe_duration 8
    tbe_note A#5

    tbe_duration 2
    tbe_note G#5

    tbe_note NOTE_CUT
    
    tbe_note F#5

    tbe_note NOTE_CUT

    tbe_duration 4
    tbe_note G#5

    tbe_duration 1
    tbe_note E_5

    tbe_duration 14
    tbe_note F_5

    tbe_duration 1
    tbe_note G_5
    
    tbe_note G#5

    tbe_note NOTE_CUT

    tbe_note G#5

    tbe_note NOTE_CUT

    tbe_note G_5

    tbe_note NOTE_CUT
    
    tbe_note G#5

    tbe_duration 3
    tbe_note NOTE_CUT

    tbe_duration 1
    tbe_note G#5

    tbe_duration 3
    tbe_note NOTE_CUT

    tbe_duration 1
    tbe_note G#5

    tbe_note NOTE_CUT
    
    _pattern_check PATTERN_SIZE
    

natpark_ch2_tr6:
    

    tbe_note B_4

    tbe_duration 5
    tbe_note C_5

    tbe_duration 4
    tbe_note G#4

    tbe_duration 2
    tbe_note NOTE_CUT

    tbe_duration 12
    tbe_note A#4

    tbe_duration 8
    tbe_note C_5

    tbe_duration 1
    tbe_note A_4

    tbe_duration 27
    tbe_note A#4
    
    tbe_duration 2
    tbe_note D#3

    tbe_duration 1
    tbe_note D_3

    tbe_goto $01
    tbe_note NOTE_REST

    _pattern_check PATTERN_SIZE


natpark_ch3_tr1:
    

    tbe_duration 16
    tbe_note C_6

    tbe_duration 14
    tbe_note C#6

    tbe_duration 1
    tbe_note G#6

    tbe_note A#6

    tbe_duration 16
    tbe_note C_7

    tbe_duration 10
    tbe_note C#7

    tbe_duration 2
    tbe_note C_7

    tbe_note C#7

    tbe_note D#7

    _pattern_check PATTERN_SIZE

natpark_ch3_tr2:
    

    tbe_duration 2
    tbe_note F_7

    tbe_note D#7

    tbe_note C#7

    tbe_duration 10
    tbe_note A#6

    tbe_duration 2
    tbe_note F_7

    tbe_note D#7

    tbe_note C#7

    tbe_duration 9
    tbe_note A_6

    tbe_duration 1
    tbe_note D_7

    tbe_duration 2
    tbe_note D#7

    tbe_note C#7

    tbe_note C_7

    tbe_duration 4
    tbe_note G#6

    tbe_note G#7

    tbe_duration 2
    tbe_note D#7

    tbe_duration 14
    tbe_note F_7

    tbe_duration 1
    tbe_note D_7

    ;tbe_delayedCut 5
    tbe_note D#7

    _pattern_check PATTERN_SIZE

natpark_ch3_tr3:
    tbe_duration 2
    tbe_note F_7

    tbe_note D#7

    tbe_note C#7

    tbe_duration 10
    tbe_note A#6

    tbe_duration 2
    tbe_note F_7

    tbe_note D#7

    tbe_note C#7

    tbe_duration 10
    tbe_note A_6

    tbe_duration 2
    tbe_note D#7

    tbe_note C#7
    
    tbe_note C_7

    tbe_duration 4
    tbe_note G#6

    tbe_note A#6

    tbe_duration 2
    tbe_note C_7

    tbe_duration 14
    tbe_note A#6

    tbe_duration 1
    tbe_note G#5
    
    tbe_note A#5

    _pattern_check PATTERN_SIZE

natpark_ch3_tr4:
    tbe_duration 2
    tbe_note F_7

    tbe_note D#7

    tbe_note C#7

    tbe_duration 10
    tbe_note A#6

    tbe_duration 2
    tbe_note F_7

    tbe_note D#7

    tbe_note C#7

    tbe_duration 10
    tbe_note A_6

    tbe_duration 2
    tbe_note D#7

    tbe_note C#7
    
    tbe_note C_7

    tbe_duration 4
    tbe_note G#6

    tbe_note A#6

    tbe_duration 2
    tbe_note C_7

    tbe_duration 8
    tbe_note A#6

    tbe_note D_5

    _pattern_check PATTERN_SIZE

natpark_ch3_tr5:
    tbe_setEnvelope $04
    tbe_duration 6
    tbe_note F#3

    tbe_duration 4
    tbe_note C#4

    tbe_duration 2
    tbe_note NOTE_CUT

    tbe_duration 8
    tbe_note A#4

    tbe_duration 2
    tbe_note C#4

    tbe_note NOTE_CUT

    tbe_note A#4

    tbe_duration 6
    tbe_note C#4

    tbe_note F#3

    tbe_duration 4
    tbe_note C#4

    tbe_duration 2
    tbe_note NOTE_CUT

    tbe_duration 8
    tbe_note A_4

    tbe_duration 2
    tbe_note C#4

    tbe_note NOTE_CUT

    tbe_note A_4

    tbe_duration 6
    tbe_note C#4

    _pattern_check PATTERN_SIZE

natpark_ch3_tr6:
    tbe_duration 6
    tbe_note F_3

    tbe_duration 4
    tbe_note C_3

    tbe_duration 2
    tbe_note NOTE_CUT

    tbe_duration 8
    tbe_note G#3

    tbe_duration 2
    tbe_note C_3

    tbe_note NOTE_CUT

    tbe_note G#4

    tbe_duration 6
    tbe_note C_4

    tbe_note A#3

    tbe_duration 4
    tbe_note F_4

    tbe_duration 2
    tbe_note NOTE_CUT

    tbe_duration 8
    tbe_note D_5

    tbe_duration 2
    tbe_note F_4

    tbe_note NOTE_CUT

    tbe_note D_5

    tbe_duration 6
    tbe_note F_4

    _pattern_check PATTERN_SIZE

natpark_ch3_tr7:
    tbe_duration 6
    tbe_note F_3

    tbe_duration 4
    tbe_note C_3

    tbe_duration 2
    tbe_note NOTE_CUT

    tbe_duration 8
    tbe_note G#3

    tbe_duration 2
    tbe_note C_3

    tbe_note NOTE_CUT

    tbe_note G#4

    tbe_duration 6
    tbe_note C_4

    tbe_note A#3

    tbe_duration 4
    tbe_note F_4

    tbe_duration 2
    tbe_note NOTE_CUT

    tbe_duration 8
    tbe_note D_5

    tbe_duration 2
    tbe_note F_4

    tbe_note NOTE_CUT

    tbe_note D_5

    tbe_duration 2
    tbe_note F_4

    tbe_setEnvelope $03
    tbe_note G#5

    tbe_note A#5

    _pattern_check PATTERN_SIZE

song_natpark_end:

PRINTT "song_natpark size: "
PRINTI song_natpark_end - song_natpark
PRINTT "\n"
