
INCLUDE "tbengine.inc"


SECTION "song_stageclear", ROM0

song_stageclear::
    DB $30              ; speed (6.0 frames per row, 150 BPM)
    DW .ch1_main
    DW .ch2_main
    DW .ch3_main
    DW .ch4_main


.ch1_main:
    tbe_duration 16
    tbe_note NOTE_HOLD          ; row 0x00

    tbe_setEnvelope $E0
    tbe_instrumentSet 0
    tbe_duration 1
    tbe_note A_4                ; row 0x10

    tbe_duration 3
    tbe_note A_4                ; row 0x11

    tbe_duration 1
    tbe_note B_4                ; row 0x14

    tbe_duration 3
    tbe_note B_4                ; row 0x15

    tbe_duration 1
    tbe_note C#5                ; row 0x18

    tbe_duration 3
    tbe_note C#5                ; row 0x19

    tbe_duration 1
    tbe_note D#5                ; row 0x1C
    tbe_note C#5                ; row 0x1D
    tbe_note D#5                ; row 0x1E
    tbe_duration 28
    tbe_setEnvelope $E7
    tbe_instrumentOff
    tbe_note E_5                ; row 0x1F

.ch2_main:
    tbe_duration 16
    tbe_note NOTE_HOLD          ; row 0x00

    tbe_setEnvelope $E0
    tbe_instrumentSet 0
    tbe_duration 1
    tbe_note C#5                ; row 0x10

    tbe_duration 3
    tbe_note C#5                ; row 0x11

    tbe_duration 1
    tbe_note D#5                ; row 0x14

    tbe_duration 3
    tbe_note D#5                ; row 0x15

    tbe_duration 1
    tbe_note E_5                ; row 0x18

    tbe_duration 3
    tbe_note E_5                ; row 0x19

    tbe_duration 1
    tbe_note F#5                ; row 0x1C
    tbe_note E_5                ; row 0x1D
    tbe_note F#5                ; row 0x1E
    tbe_duration 27
    tbe_setEnvelope $E7
    tbe_instrumentOff
    tbe_note G#5                ; row 0x1F
    
    tbe_duration 1
    tbe_halt
    tbe_note NOTE_HOLD          ; row 0x3A

.ch3_main:
    tbe_duration 1
    tbe_pitchSlideDown $10
    tbe_setEnvelope $00
    tbe_setTimbre $20
    tbe_note G#5                ; row 0x00

    tbe_instrumentSet 0
    tbe_note NOTE_HOLD          ; row 0x01

    tbe_instrumentOff
    tbe_note G#5                ; row 0x02

    tbe_instrumentSet 0
    tbe_note NOTE_HOLD          ; row 0x03

    tbe_note G#5                ; row 0x04
    
    tbe_pitchSlideDown $0F
    tbe_duration 2
    tbe_note F_5                ; row 0x05

    tbe_duration 1
    tbe_pitchSlideDown $0E
    tbe_instrumentOff
    tbe_note D_5                ; row 0x07

    tbe_instrumentSet 0
    tbe_note NOTE_HOLD          ; row 0x08

    tbe_instrumentOff
    tbe_note D_5                ; row 0x09

    tbe_instrumentSet 0
    tbe_note NOTE_HOLD          ; row 0x0A

    tbe_note D_5                ; row 0x0B

    tbe_pitchSlideDown $10
    tbe_duration 2
    tbe_note C_5                ; row 0x0C

    tbe_pitchSlideDown $11
    tbe_note A#4                ; row 0x0E

    tbe_pitchSlideDown $0
    tbe_duration 1
    tbe_note F#3                ; row 0x10

    tbe_duration 3
    tbe_note F#3                ; row 0x11

    tbe_duration 1
    tbe_note G#3                ; row 0x14

    tbe_duration 3
    tbe_note G#3                ; row 0x15

    tbe_duration 1
    tbe_note A_3                ; row 0x18

    tbe_duration 3
    tbe_note A_3                ; row 0x19

    tbe_duration 1
    tbe_note B_3                ; row 0x1C
    tbe_note A_3                ; row 0x1D
    tbe_note B_3                ; row 0x1E

    tbe_duration 24
    tbe_instrumentOff
    tbe_note B_3                ; row 0x1F

    tbe_duration 4
    tbe_instrumentSet 0
    tbe_note NOTE_HOLD          ; row 0x37

.ch4_main:
    tbe_duration 64
    tbe_note NOTE_HOLD          ; row 0x00

.end:

PRINTT "song_stageclear size: "
PRINTI song_stageclear.end - song_stageclear
PRINTT " bytes \n"
