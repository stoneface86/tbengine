
INCLUDE "tbengine.inc"


SECTION "sample song data", ROM0

tbe_waveTable::
    DW wave_triangle
    DW wave_square
    DW wave_saw
    DW wave_curved

wave_triangle:
    DB $01, $23, $45, $67, $89, $AB, $CD, $EF, $FE, $DC, $BA, $98, $76, $54, $32, $10

; ~60% duty
wave_square:
    DB $00, $00, $00, $00, $00, $00, $0A, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA

; double period, same frequency range as CH1/CH2
wave_saw:
    DB $01, $23, $45, $67, $89, $AB, $CD, $EF, $01, $23, $45, $67, $89, $AB, $CD, $EF

wave_curved:
    DB $02, $46, $8A, $CE, $EF, $FF, $FE, $EE, $DD, $CB, $A9, $87, $65, $43, $22, $11

sampleSong::
    DB $30              ; speed (6.0 frames per row, 150 BPM)
    DB $1 - 1           ; order size
    DB 64 - 1           ; pattern size
    DW sampleSong_order

sampleSong_order:
    DW sampleSong_ch1_track0, sampleSong_ch2_track0, sampleSong_ch3_track0, sampleSong_ch4_track0



sampleSong_ch1_track0:
    tbe_duration 16
    tbe_note NOTE_REST          ; row 0x00

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

sampleSong_ch2_track0:
    tbe_duration 16
    tbe_note NOTE_REST          ; row 0x00

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
    tbe_note NOTE_REST          ; row 0x3A

sampleSong_ch3_track0:
    tbe_duration 1
    tbe_pitchSlideDown $10
    tbe_note G#5                ; row 0x00

    tbe_instrumentSet 0
    tbe_note NOTE_REST          ; row 0x01

    tbe_instrumentOff
    tbe_note G#5                ; row 0x02

    tbe_instrumentSet 0
    tbe_note NOTE_REST          ; row 0x03

    tbe_note G#5                ; row 0x04
    
    tbe_pitchSlideDown $0F
    tbe_duration 24
    tbe_note F_5                ; row 0x05

    tbe_duration 1
    tbe_pitchSlideDown $0E
    tbe_instrumentOff
    tbe_note D_5                ; row 0x07

    tbe_instrumentSet 0
    tbe_note NOTE_REST          ; row 0x08

    tbe_instrumentOff
    tbe_note D_5                ; row 0x09

    tbe_instrumentSet 0
    tbe_note NOTE_REST          ; row 0x0A

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
    tbe_note NOTE_REST          ; row 0x37

    

sampleSong_ch4_track0:
    tbe_duration 64
    tbe_note NOTE_REST          ; row 0x00

sampleSong_end:

; PRINTT "Sample song size: "
; PRINTI sampleSong_end - sampleSong
; PRINTT "\n"
