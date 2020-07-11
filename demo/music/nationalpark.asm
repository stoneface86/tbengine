
SECTION "song_nationalpark", ROM0

INCLUDE "tbengine.inc"

PATTERN_SIZE EQU 64

song_natpark::
    DB $48              ; speed (9.0 frames per row, 100 BPM)
    DW .ch1_entry
    DW .ch2_entry
    DW .ch3_entry
    DW .ch4_entry


; CH1 =========================================================================

.ch1_entry:
    tbe_setTimbre $40
    tbe_setEnvelope $77
    tbe_setPanning $01
    tbe_duration 2
    tbe_note NOTE_HOLD
.ch1_main:
    tbe_call .ch1_tr_1_2_3 ; tracks 1, 2, 3
    tbe_call .ch1_tr_1_2_3
    tbe_call .ch1_tr_4
    tbe_call .ch1_tr_5
    tbe_call .ch1_tr_4
    tbe_call .ch1_tr_6
    tbe_call .ch1_main

.ch1_tr_1_2_3:
    _pattern_check_reset
    ; track 1

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

    ; track 2

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

    ; track 3

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

    tbe_ret

.ch1_tr_4:
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

    tbe_ret

.ch1_tr_5:
    tbe_duration 32
    tbe_note NOTE_HOLD

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

    tbe_ret

.ch1_tr_6:
    tbe_duration 1
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

    tbe_ret


; CH2 =========================================================================

.ch2_entry:
    tbe_setPanning $10
    tbe_setTimbre $40
    tbe_duration 2
    tbe_note NOTE_HOLD
.ch2_main:
    tbe_call .ch2_tr_1
    tbe_call .ch2_tr_2
    tbe_call .ch2_tr_2
    tbe_call .ch2_tr_1
    tbe_call .ch2_tr_2
    tbe_call .ch2_tr_3
    tbe_call .ch2_tr_4
    tbe_call .ch2_tr_5
    tbe_call .ch2_tr_4
    tbe_call .ch2_tr_6
    tbe_call .ch2_main

.ch2_tr_1:
    _pattern_check_reset

    tbe_setEnvelope $A7
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

    tbe_ret

.ch2_tr_2:
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

    tbe_ret

.ch2_tr_3:
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

    tbe_ret

.ch2_tr_4:
    tbe_duration 1
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

    tbe_ret

.ch2_tr_5:
    tbe_duration 1
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

    tbe_ret

.ch2_tr_6:
    tbe_duration 1
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

    tbe_note D_3

    _pattern_check PATTERN_SIZE

    tbe_ret

; CH3 =========================================================================

.ch3_entry:
    tbe_setEnvelope $03
    tbe_note G#5
    tbe_note A#5
.ch3_main:
    tbe_call .ch3_tr_1_2
    tbe_call .ch3_tr_3
    tbe_call .ch3_tr_1_2
    tbe_call .ch3_tr_4
    tbe_call .ch3_tr_5
    tbe_call .ch3_tr_6
    tbe_call .ch3_tr_5
    tbe_call .ch3_tr_7
    tbe_call .ch3_main

.ch3_tr_1_2:
    _pattern_check_reset

    ; Track 1

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

    ; Track 2

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

    tbe_note D#7

    _pattern_check PATTERN_SIZE

    tbe_ret

.ch3_tr_3:
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

    tbe_ret

.ch3_tr_4:
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

    tbe_ret

.ch3_tr_5:
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

    tbe_ret

.ch3_tr_6:
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

    tbe_ret

.ch3_tr_7:
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

    tbe_ret

; CH4 =========================================================================

.ch4_entry:
    tbe_duration 2
    tbe_note NOTE_HOLD
.ch4_main:
    tbe_duration 64
.ch4_nothing:
    tbe_note NOTE_HOLD
    tbe_call .ch4_nothing

.end:

PRINTT "song_natpark size: "
PRINTI song_natpark.end - song_natpark
PRINTT " bytes\n"
