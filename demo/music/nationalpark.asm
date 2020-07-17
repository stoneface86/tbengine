
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
    timbre1 ; setTimbre $40
    setEnvelope $77
    panRight ; setPanning $01
    duration 2
    note NOTE_HOLD
.ch1_main:
    snd_call .ch1_tr_1_2_3 ; tracks 1, 2, 3
    snd_call .ch1_tr_1_2_3
    snd_call .ch1_tr_4
    duration 32
    note NOTE_HOLD

    duration 2
    note A#3

    note D_4

    note F_4

    note G#4

    note D_4

    note F_4

    note A#4

    duration 1
    note D_5

    note C#5

    note D_5

    note NOTE_CUT

    note D_5

    note NOTE_CUT

    note C#5

    note NOTE_CUT

    note D_5

    duration 3
    note NOTE_CUT
    
    duration 1
    note D_5

    duration 3
    note NOTE_CUT

    duration 1
    note D_5

    note NOTE_CUT

    _pattern_check PATTERN_SIZE
    snd_call .ch1_tr_4

    ; track 6
    duration 1
    note E_4

    duration 5
    note F_4

    duration 4
    note D#4

    duration 2
    note NOTE_CUT

    duration 12
    note C_4

    duration 8
    note F_4

    duration 1
    note C#4

    duration 16
    note D_4

    duration 7
    note D_4

    duration 8
    note NOTE_CUT
    _pattern_check PATTERN_SIZE
    snd_jump .ch1_main

.ch1_tr_1_2_3:
    _pattern_check_reset
    ; track 1

    duration 6
    note G#3

    ; --

    duration 2
    note F_4

    duration 1
    setEnvelope $47
    note F_4

    note G#4

    setEnvelope $57
    note F_4

    note G#4

    setEnvelope $77
    note F_4

    note G#4

    setEnvelope $97
    note F_4

    note G#4

    duration 6
    setEnvelope $77
    note A_3

    ; --

    duration 2
    note F#4

    duration 1
    setEnvelope $47
    note F#4

    note A_4

    setEnvelope $57
    note F#4

    note A_4

    setEnvelope $77
    note F#4

    note A_4

    setEnvelope $97
    note F#4

    note A_4

    duration 6
    setEnvelope $77
    note G#3

    ; --

    duration 2
    note F_4

    duration 1
    setEnvelope $47
    note C_5

    note C#5

    setEnvelope $57
    note C_5

    note C#5

    setEnvelope $77
    note C_5

    note C#5

    setEnvelope $97
    note C_5

    note C#5

    duration 6
    setEnvelope $77
    note A_3

    ; --

    duration 2
    note C#4

    duration 1
    setEnvelope $47
    note C#5

    note D#5

    setEnvelope $57
    note C#5

    note D#5

    setEnvelope $77
    note C#5

    note D#5

    setEnvelope $97
    note C#5

    note D#5

    _pattern_check PATTERN_SIZE

    ; track 2

    duration 2
    note C#5

    note A#4

    note C#5

    note A#4

    note C#5

    note A#4

    note C#5

    note A#4

    note C#5

    note A#4

    note C#5

    note A#4

    ; --

    setEnvelope $47
    duration 1
    note C#5

    note D#5

    setEnvelope $57
    note C#5

    note D#5

    setEnvelope $77
    note C#5

    note D#5

    setEnvelope $97
    note C#5

    note D#5

    setEnvelope $77
    duration 2
    note C_5

    note G#4

    note C_5

    note G#4

    note D#5

    note C_5

    note D#5

    note C_5
    
    note D_5

    note A#4

    note D_5
    
    note A#4

    ; --

    setEnvelope $47
    duration 1
    note F_5

    note D#5

    setEnvelope $57
    note D_5

    note D#5

    setEnvelope $77
    note F_5

    note F#5

    setEnvelope $97
    note G#5

    note A#5

    _pattern_check PATTERN_SIZE

    ; track 3

    duration 2
    note C#5

    note A#4

    note C#5

    note A#4

    note C#5

    note A#4

    note C#5

    note A#4

    note C#5

    note A#4

    note C#5

    note A#4

    setEnvelope $47
    duration 1
    note C#5

    note D#5

    setEnvelope $57
    note C#5

    note D#5

    setEnvelope $77
    note C#5

    note D#5

    setEnvelope $97
    note C#5

    note D#5

    duration 2
    note C_5

    note G#4

    note C_5

    note G#4

    note D#5

    note C_5

    note D#5

    note C_5

    note D_5

    note A#4

    note D_5

    note A#4

    note D_5

    note A#4

    note D_5

    note A#4

    _pattern_check PATTERN_SIZE

    ret

.ch1_tr_4:
    duration 19
    note NOTE_CUT

    duration 1
    note A#5
    note A#5
    note NOTE_CUT
    note A#5
    note NOTE_CUT
    note A#5
    note NOTE_CUT

    duration 2
    note A#5

    duration 23
    note NOTE_CUT

    duration 1
    note A#5
    note A#5
    note NOTE_CUT
    note A#5
    note NOTE_CUT
    note A#5
    note NOTE_CUT

    duration 2
    note A#5

    duration 4
    note NOTE_CUT

    _pattern_check PATTERN_SIZE

    ret




; CH2 =========================================================================

.ch2_entry:
    panLeft ; setPanning $10
    timbre1 ; setTimbre $40
    duration 2
    note NOTE_HOLD
.ch2_main:
    snd_call .ch2_tr_1
    snd_call .ch2_tr_2
    snd_call .ch2_tr_2
    snd_call .ch2_tr_1
    snd_call .ch2_tr_2
    snd_call .ch2_tr_3
    snd_call .ch2_tr_4
    snd_call .ch2_tr_5
    snd_call .ch2_tr_4
    snd_call .ch2_tr_6
    snd_jump .ch2_main

.ch2_tr_1:
    _pattern_check_reset

    setEnvelope $A7
    tempo $48
    
    duration 6
    note C#3
    
    duration 2
    note G#3

    duration 8
    note C#4

    duration 6
    note C#3

    duration 2
    note A_3

    duration 8
    note C#4

    duration 6
    note C#3

    duration 2
    note G#3

    duration 8
    note C#4

    duration 6
    note C#3

    duration 2
    note A_3

    duration 8
    note F#4
    
    _pattern_check PATTERN_SIZE

    ret

.ch2_tr_2:
    duration 6
    note F#2

    duration 2
    note C#3

    duration 8
    note A#3

    duration 6
    note F#2

    duration 2
    note C#3

    duration 8
    note A_3

    duration 6
    note F_2

    duration 2
    note C_3
    
    duration 8
    note G#3

    duration 6
    note A#2

    duration 2
    note F_3
    
    duration 8
    note D_4
    _pattern_check PATTERN_SIZE

    ret

.ch2_tr_3:
    duration 6
    note F#2

    duration 2
    note C#3

    duration 8
    note A#3

    duration 6
    note F#2

    duration 2
    note C#3

    duration 8
    note A_3

    duration 6
    note F_2

    duration 2
    note C_3
    
    duration 8
    note G#3

    duration 6
    note A#2

    duration 2
    note F_3
    
    note NOTE_CUT

    note G#5

    note F#5

    note F_5
    _pattern_check PATTERN_SIZE

    ret

.ch2_tr_4:
    duration 1
    tempo $24
    note E_5

    duration 5
    note F_5

    duration 4
    note F#5

    duration 2
    note NOTE_CUT

    duration 7
    note C#5

    duration 1
    note E_6
    
    note F_6

    note NOTE_CUT

    note F_6

    note NOTE_CUT

    note E_6

    note NOTE_CUT

    duration 2
    note F_6

    note A#4

    note C#5

    duration 1
    note E_5

    duration 5
    note F_5

    duration 4
    note F#5

    duration 2
    note NOTE_CUT

    duration 7
    note D#5

    setEnvelope $87
    duration 1
    note D_6

    note D#6

    note NOTE_CUT

    note D#6

    note NOTE_CUT

    note D_6

    note NOTE_CUT

    duration 2
    note D#6

    setEnvelope $A7
    note D_5

    note C#5
    _pattern_check PATTERN_SIZE

    ret

.ch2_tr_5:
    duration 1
    note B_4

    duration 5
    note C_5

    duration 4
    note G#4

    duration 2
    note NOTE_CUT

    duration 8
    note A#5

    duration 2
    note G#5

    note NOTE_CUT
    
    note F#5

    note NOTE_CUT

    duration 4
    note G#5

    duration 1
    note E_5

    duration 14
    note F_5

    duration 1
    note G_5
    
    note G#5

    note NOTE_CUT

    note G#5

    note NOTE_CUT

    note G_5

    note NOTE_CUT
    
    note G#5

    duration 3
    note NOTE_CUT

    duration 1
    note G#5

    duration 3
    note NOTE_CUT

    duration 1
    note G#5

    note NOTE_CUT
    
    _pattern_check PATTERN_SIZE

    ret

.ch2_tr_6:
    duration 1
    note B_4

    duration 5
    note C_5

    duration 4
    note G#4

    duration 2
    note NOTE_CUT

    duration 12
    note A#4

    duration 8
    note C_5

    duration 1
    note A_4

    duration 27
    note A#4
    
    duration 2
    note D#3

    note D_3

    _pattern_check PATTERN_SIZE

    ret

; CH3 =========================================================================

.ch3_entry:
    setEnvelope $03
    note G#5
    note A#5
.ch3_main:
    snd_call .ch3_tr_1_2
    snd_call .ch3_tr_3
    snd_call .ch3_tr_1_2
    snd_call .ch3_tr_4
    snd_call .ch3_tr_5
    snd_call .ch3_tr_6
    snd_call .ch3_tr_5
    snd_call .ch3_tr_7
    snd_jump .ch3_main

.ch3_tr_1_2:
    _pattern_check_reset

    ; Track 1

    duration 16
    note C_6

    duration 14
    note C#6

    duration 1
    note G#6

    note A#6

    duration 16
    note C_7

    duration 10
    note C#7

    duration 2
    note C_7

    note C#7

    note D#7

    _pattern_check PATTERN_SIZE

    ; Track 2

    duration 2
    note F_7

    note D#7

    note C#7

    duration 10
    note A#6

    duration 2
    note F_7

    note D#7

    note C#7

    duration 9
    note A_6

    duration 1
    note D_7

    duration 2
    note D#7

    note C#7

    note C_7

    duration 4
    note G#6

    note G#7

    duration 2
    note D#7

    duration 14
    note F_7

    duration 1
    note D_7

    note D#7

    _pattern_check PATTERN_SIZE

    ret

.ch3_tr_3:
    duration 2
    note F_7

    note D#7

    note C#7

    duration 10
    note A#6

    duration 2
    note F_7

    note D#7

    note C#7

    duration 10
    note A_6

    duration 2
    note D#7

    note C#7
    
    note C_7

    duration 4
    note G#6

    note A#6

    duration 2
    note C_7

    duration 14
    note A#6

    duration 1
    note G#5
    
    note A#5

    _pattern_check PATTERN_SIZE

    ret

.ch3_tr_4:
    duration 2
    note F_7

    note D#7

    note C#7

    duration 10
    note A#6

    duration 2
    note F_7

    note D#7

    note C#7

    duration 10
    note A_6

    duration 2
    note D#7

    note C#7
    
    note C_7

    duration 4
    note G#6

    note A#6

    duration 2
    note C_7

    duration 8
    note A#6

    note D_5

    _pattern_check PATTERN_SIZE

    ret

.ch3_tr_5:
    setEnvelope $04
    duration 6
    note F#3

    duration 4
    note C#4

    duration 2
    note NOTE_CUT

    duration 8
    note A#4

    duration 2
    note C#4

    note NOTE_CUT

    note A#4

    duration 6
    note C#4

    note F#3

    duration 4
    note C#4

    duration 2
    note NOTE_CUT

    duration 8
    note A_4

    duration 2
    note C#4

    note NOTE_CUT

    note A_4

    duration 6
    note C#4

    _pattern_check PATTERN_SIZE

    ret

.ch3_tr_6:
    duration 6
    note F_3

    duration 4
    note C_3

    duration 2
    note NOTE_CUT

    duration 8
    note G#3

    duration 2
    note C_3

    note NOTE_CUT

    note G#4

    duration 6
    note C_4

    note A#3

    duration 4
    note F_4

    duration 2
    note NOTE_CUT

    duration 8
    note D_5

    duration 2
    note F_4

    note NOTE_CUT

    note D_5

    duration 6
    note F_4

    _pattern_check PATTERN_SIZE

    ret

.ch3_tr_7:
    duration 6
    note F_3

    duration 4
    note C_3

    duration 2
    note NOTE_CUT

    duration 8
    note G#3

    duration 2
    note C_3

    note NOTE_CUT

    note G#4

    duration 6
    note C_4

    note A#3

    duration 4
    note F_4

    duration 2
    note NOTE_CUT

    duration 8
    note D_5

    duration 2
    note F_4

    note NOTE_CUT

    note D_5

    duration 2
    note F_4

    setEnvelope $03
    note G#5

    note A#5

    _pattern_check PATTERN_SIZE

    ret

; CH4 =========================================================================

.ch4_entry:
    duration 2
    note NOTE_HOLD
.ch4_main:
    duration 64
    loopBegin
        note NOTE_HOLD
    loopEnd 0

.end:

PRINTT "song_natpark size: "
PRINTI song_natpark.end - song_natpark
PRINTT " bytes\n"
