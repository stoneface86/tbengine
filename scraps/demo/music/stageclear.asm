
INCLUDE "tbengine.inc"


SECTION "song_stageclear", ROM0

song_stageclear::
    DB $30              ; speed (6.0 frames per row, 150 BPM)
    DW .ch1_main
    DW .ch2_main
    DW .ch3_main
    DW .ch4_main


.ch1_main:
    duration 16
    note NOTE_HOLD          ; row 0x00

    setEnvelope $E0
    setInstrument 0
    duration 1
    note A_4                ; row 0x10

    duration 3
    note A_4                ; row 0x11

    duration 1
    note B_4                ; row 0x14

    duration 3
    note B_4                ; row 0x15

    duration 1
    note C#5                ; row 0x18

    duration 3
    note C#5                ; row 0x19

    duration 1
    note D#5                ; row 0x1C
    note C#5                ; row 0x1D
    note D#5                ; row 0x1E
    duration 28
    setEnvelope $E7
    note E_5                ; row 0x1F

.ch2_main:
    duration 16
    note NOTE_HOLD          ; row 0x00

    setEnvelope $E0
    setInstrument 0
    duration 1
    note C#5                ; row 0x10

    duration 3
    note C#5                ; row 0x11

    duration 1
    note D#5                ; row 0x14

    duration 3
    note D#5                ; row 0x15

    duration 1
    note E_5                ; row 0x18

    duration 3
    note E_5                ; row 0x19

    duration 1
    note F#5                ; row 0x1C
    note E_5                ; row 0x1D
    note F#5                ; row 0x1E
    duration 27
    setEnvelope $E7
    note G#5                ; row 0x1F
    
    duration 1
    snd_halt
    note NOTE_HOLD          ; row 0x3A

.ch3_main:
    duration 1
    pitchSlideDown $10
    setEnvelope $00
    note G#5                ; row 0x00

    setInstrument 0
    note NOTE_HOLD          ; row 0x01

    note G#5                ; row 0x02

    setInstrument 0
    note NOTE_HOLD          ; row 0x03

    note G#5                ; row 0x04
    
    pitchSlideDown $0F
    duration 2
    note F_5                ; row 0x05

    duration 1
    pitchSlideDown $0E

    note D_5                ; row 0x07

    setInstrument 0
    note NOTE_HOLD          ; row 0x08


    note D_5                ; row 0x09

    setInstrument 0
    note NOTE_HOLD          ; row 0x0A

    note D_5                ; row 0x0B

    pitchSlideDown $10
    duration 2
    note C_5                ; row 0x0C

    pitchSlideDown $11
    note A#4                ; row 0x0E

    pitchSlideDown $0
    duration 1
    note F#3                ; row 0x10

    duration 3
    note F#3                ; row 0x11

    duration 1
    note G#3                ; row 0x14

    duration 3
    note G#3                ; row 0x15

    duration 1
    note A_3                ; row 0x18

    duration 3
    note A_3                ; row 0x19

    duration 1
    note B_3                ; row 0x1C
    note A_3                ; row 0x1D
    note B_3                ; row 0x1E

    duration 24
    note B_3                ; row 0x1F

    duration 4
    setInstrument 0
    note NOTE_HOLD          ; row 0x37

.ch4_main:
    duration 64
    note NOTE_HOLD          ; row 0x00

.end:

    __printSongSize song_stageclear
