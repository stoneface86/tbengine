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

; commands are sized from 1-4 bytes containing a control byte and some parameter bytes
;
; The control byte has this structure:
; +----+----+----+----------------------+
; | P1 | P2 | P3 | Command index        |
; +----+----+----+----------------------+
; 8    7    6    5                      0
;
; P1 - parameter 1 enable (if set, a parameter byte follows)
; P2 - parameter 2 enable ^
; P3 - parameter 3 enable ^
;
; parameters are stored in order from 1 to 3. Any parameter not enabled is set to 0
; by using default parameter values, we can omit parameters and save space
;
; examples:
; tbe_play C-2, 0, 0
;  => DB $00        ; 1 byte! C-2 index is actually 0 so we don't need to include it
; tbe_play C-3, 0, 0
;  => DB $80, $0C
;

; Command indices
CMD_PLAY                EQU 0
CMD_CUT                 EQU 1
CMD_RELEASE             EQU 2
CMD_NOP                 EQU 3
CMD_HALT                EQU 4
CMD_CALL                EQU 5
CMD_JUMP                EQU 6
CMD_RET                 EQU 7
CMD_TEMPO               EQU 8
CMD_SFX                 EQU 9
CMD_SFX_STOP            EQU 10
CMD_ARP                 EQU 11
CMD_PITCH_SLIDE_UP      EQU 12
CMD_PITCH_SLIDE_DOWN    EQU 13
CMD_NOTE_SLIDE_UP       EQU 14
CMD_NOTE_SLIDE_DOWN     EQU 15
CMD_TUNE                EQU 16
CMD_PORTAMENTO          EQU 17
CMD_VIBRATO             EQU 18
CMD_SET_ENVELOPE        EQU 19
CMD_SET_TIMBRE          EQU 20
CMD_SET_PANNING         EQU 21
CMD_INSTRUMENT_SET      EQU 22
CMD_INSTRUMENT_OFF      EQU 23
CMD_DELAYED_CUT         EQU 24

; 25/32 commands used


; \1 - command index
; \2 - parameter 1
; \3 - parameter 2
; \4 - parameter 3
_makeCmd: MACRO
    DB ((\2 != 0) << 7) | ((\3 != 0) << 6) | ((\4 != 0) << 5) | (\1)
    IF \2 != 0
        DB \2
    ENDC
    IF \3 != 0
        DB \3
    ENDC
    IF \4 != 0
        DB \4
    ENDC
ENDM

; -----------------------------------------------------------------------------
; Command Macros
; useful for hand-writing music data


; ex: tbe_play C-4, 1, 0
; plays C-4 immediately and stalls for 1 row (plays for 2 rows)
; tbe_play <note> <duration> <delay>
tbe_play: MACRO
    STATIC_ASSERT FATAL, \1 <= B_8, "invalid note index"
    _makeCmd CMD_PLAY, \1, \2, \3
ENDM

; tbe_cut <duration> <delay>
tbe_cut: MACRO
    _makeCmd CMD_CUT, \1, \2, 0
ENDM

; tbe_release <duration> <delay>
tbe_release: MACRO
    _makeCmd CMD_RELEASE, \1, \2, 0
ENDM

; tbe_nop <duration>
tbe_nop: MACRO
    _makeCmd CMD_NOP, \1, 0, 0
ENDM

; tbe_halt
tbe_halt: MACRO
    _makeCmd CMD_HALT, 0, 0, 0
ENDM

; tbe_call <addr/label>
tbe_call: MACRO
    ; 1 parameter as a word, placed into 2 parameters
    ;_makeCmd CMD_CALL, LOW(\1), HIGH(\1), 0
    DB $C0 | CMD_CALL
    DW \1
ENDM

; tbe_jump <addr/label>
tbe_jump: MACRO
    ;_makeCmd CMD_JUMP, LOW(\1), HIGH(\1), 0
    DB $C0 | CMD_JUMP
    DW \1
ENDM

; tbe_ret
tbe_ret: MACRO
    _makeCmd CMD_RET, 0, 0, 0
ENDM

tbe_tempo: MACRO
    STATIC_ASSERT FATAL, \1 >= 8 && \1 < 248, "invalid speed"
    _makeCmd CMD_TEMPO, \1, 0, 0
ENDM

tbe_sfx: MACRO
    _makeCmd CMD_SFX, \1, 0, 0
ENDM

tbe_sfxStop: MACRO
    _makeCmd CMD_SFX_STOP, 0, 0, 0
ENDM

tbe_arp: MACRO
    _makeCmd CMD_ARP, \1, 0, 0
ENDM

tbe_pitchSlideUp: MACRO
    _makeCmd CMD_PITCH_SLIDE_UP, \1, 0, 0
ENDM

tbe_pitchSlideDown: MACRO
    _makeCmd CMD_PITCH_SLIDE_DOWN, \1, 0, 0
ENDM

tbe_portamento: MACRO
    _makeCmd CMD_PORTAMENTO, \1, 0, 0
ENDM

tbe_vibrato: MACRO
    _makeCmd CMD_VIBRATO, \1, 0, 0
ENDM

tbe_setEnvelope: MACRO
    _makeCmd CMD_SET_ENVELOPE, \1, 0, 0
ENDM

tbe_setTimbre: MACRO
    _makeCmd CMD_SET_TIMBRE, \1, 0, 0
ENDM

tbe_setPanning: MACRO
    _makeCmd CMD_SET_PANNING, \1, 0, 0
ENDM

tbe_instrumentSet: MACRO
    _makeCmd CMD_INSTRUMENT_SET, \1, 0, 0
ENDM

tbe_instrumentOff: MACRO
    _makeCmd CMD_INSTRUMENT_OFF, 0, 0, 0
ENDM

tbe_delayedCut: MACRO
    _makeCmd CMD_DELAYED_CUT, \1, 0, 0
ENDM


ENDC ; IF !DEF(TBENGINE_INC)
