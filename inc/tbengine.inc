IF !DEF(TBENGINE_INC)
TBENGINE_INC SET 1

; note indices
C_2 EQU 0
C#2 EQU 1
D_2 EQU 2
D#2 EQU 3
E_2 EQU 4
F_2 EQU 5
F#2 EQU 6
G_2 EQU 7
G#2 EQU 8
A_2 EQU 9
A#2 EQU 10
B_2 EQU 11
C_3 EQU 12
C#3 EQU 13
D_3 EQU 14
D#3 EQU 15
E_3 EQU 16
F_3 EQU 17
F#3 EQU 18
G_3 EQU 19
G#3 EQU 20
A_3 EQU 21
A#3 EQU 22
B_3 EQU 23
C_4 EQU 24
C#4 EQU 25
D_4 EQU 26
D#4 EQU 27
E_4 EQU 28
F_4 EQU 29
F#4 EQU 30
G_4 EQU 31
G#4 EQU 32
A_4 EQU 33
A#4 EQU 34
B_4 EQU 35
C_5 EQU 36
C#5 EQU 37
D_5 EQU 38
D#5 EQU 39
E_5 EQU 40
F_5 EQU 41
F#5 EQU 42
G_5 EQU 43
G#5 EQU 44
A_5 EQU 45
A#5 EQU 46
B_5 EQU 47
C_6 EQU 48
C#6 EQU 49
D_6 EQU 50
D#6 EQU 51
E_6 EQU 52
F_6 EQU 53
F#6 EQU 54
G_6 EQU 55
G#6 EQU 56
A_6 EQU 57
A#6 EQU 58
B_6 EQU 59
C_7 EQU 60
C#7 EQU 61
D_7 EQU 62
D#7 EQU 63
E_7 EQU 64
F_7 EQU 65
F#7 EQU 66
G_7 EQU 67
G#7 EQU 68
A_7 EQU 69
A#7 EQU 70
B_7 EQU 71
C_8 EQU 72
C#8 EQU 73
D_8 EQU 74
D#8 EQU 75
E_8 EQU 76
F_8 EQU 77
F#8 EQU 78
G_8 EQU 79
G#8 EQU 80
A_8 EQU 81
A#8 EQU 82
B_8 EQU 83

; commands

; if the command index is > 16, the command has a length
; these commands stall for an x number of rows before another command is run
; Bits 0-1: type (play, cut, release, nop)
; Bit    2: tick delay enable
; Bit    3: length enable
;
; <command> [duration] [delay] [params...]

; play note, duration, delay
CMD_PLAY EQU 0
; cut <tickDelay>
CMD_CUT EQU 1

CMD_RELEASE EQU 2

; do nothing
; nop
CMD_NOP EQU 3

; for commands >= 16, these change settings and do not stall

; tbe_halt
CMD_HALT EQU 16

; tbe_call <label>
CMD_CALL EQU 17

; tbe_jump <label>
CMD_JUMP EQU 18

; tbe_ret
CMD_RET EQU 19

; tbe_tempo <tempo>
CMD_TEMPO EQU 17

; set envelope
; set_envelope <envelope>

; set timbre
; set_timbre <timbre>

; set panning
; set_panning <panning>

; arpeggio
; arpeggio <param>

;

; \1 - command index
; \2 - duration
; \3 - delay
lengthCmd: MACRO
    STATIC_ASSERT \2 >= 1, "invalid duration", FAIL
    DB ((\2 == 1) << 3) | ((\3 != 0) << 2) | \1
    IF \2 > 1
        DB \2
    ENDC
    IF \3 != 0
        DB \3
    ENDC
ENDM

; ex: notePlay C-4, 1, 0
notePlay: MACRO
    STATIC_ASSERT \1 <= B_8, "invalid note index", FAIL
    lengthCmd CMD_PLAY, \2, \3
    DB \1
ENDM

noteCut: MACRO
    lengthCmd CMD_CUT, \1, \2
ENDM

noteNop: MACRO
    lengthCmd CMD_NOP, \1, 0
ENDM

noteRelease: MACRO
    lengthCmd CMD_RELEASE, \1, \2
ENDM


ENDC
