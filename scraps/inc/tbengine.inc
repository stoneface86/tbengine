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

; special notes
NOTE_HOLD EQU B_8 + 1           ; "no-op", this occurs when the note column is empty
NOTE_CUT  EQU B_8 + 2           ; turns sound output for the channel off

; the last legal note index
NOTE_LAST EQU NOTE_CUT

; track data format
; rows in a track are made up of a note byte with command bytes and an optional duration byte
; [commands...] [duration] <note>
;
; duration is the number of rows+1 the note is played for. The last duration set is the one
; used if a duration byte is not specified. The duration defaults to 1 row
; Bit 7 - command enable byte

; if bit 7 is reset:
;  bits 0-6: note index
; else:
;  if bit 6 is reset:
;   bits 0-4: command index
;   bit  5: (P) parameter enable
;  else:
;   bits 0-5: duration setting
;
;
; note byte:
;
; +---+-----------------------+
; | 0 | note index            |
; +---+-----------------------+
; 8   7                       0

; command byte:

; +---+---+---+---------------+
; | 1 | 0 | P | command index |
; +---+---+---+---------------+
; 8   7   6   5               0
;
; P: parameter enable, if set a parameter byte follows this command
; command index: index of the command to execute
;
; duration byte:
;
; +---+---+--------------------+
; | 1 | 1 | duration           |
; +---+---+--------------------+
; 8   7   6                    0
;
; duration: 0-63, sets the current duration setting


; $00-$7F: note byte
; $80-$BF: command byte [parameter]
; $C0-$FF: duration byte (sets the default duration for notes)

; Command indices

; flow control
CMD_JUMP                EQU 0
CMD_CALL                EQU 1
CMD_RET                 EQU 2
CMD_LOOP_BEGIN          EQU 3
CMD_LOOP_END            EQU 4
; global settings
CMD_HALT                EQU 5
CMD_TEMPO               EQU 6
CMD_SFX                 EQU 7
CMD_LOCK                EQU 8
; frequency commands
CMD_ARP                 EQU 9
CMD_PITCH_SLIDE_UP      EQU 10
CMD_PITCH_SLIDE_DOWN    EQU 11
CMD_NOTE_SLIDE_UP       EQU 12
CMD_NOTE_SLIDE_DOWN     EQU 13
CMD_TUNE                EQU 14
CMD_PORTAMENTO          EQU 15
CMD_VIBRATO             EQU 16
CMD_VIBRATO_DELAY       EQU 17
; channel settings
CMD_SET_ENVELOPE        EQU 18
CMD_SET_INSTRUMENT      EQU 19
CMD_TIMBRE_0            EQU 20
CMD_TIMBRE_1            EQU 21
CMD_TIMBRE_2            EQU 22
CMD_TIMBRE_3            EQU 23
CMD_PAN_LEFT            EQU 24
CMD_PAN_RIGHT           EQU 25
CMD_PAN_MIDDLE          EQU 26
; note delays
CMD_DELAYED_CUT         EQU 27
CMD_DELAYED_NOTE        EQU 28


; 29/32 commands used


; command sequence
; \1 - command index
; \2 - parameter
cmd: MACRO
    DB $80 | ((\2 != 0) << 5) | (\1)
    IF \2 != 0
        DB \2
    ENDC
ENDM

; -----------------------------------------------------------------------------
; Command Macros
; useful for hand-writing music data

; macros with "__" are just for static error checking, they result in no
; changes to the data emitted

; variable storing the elapsed rows
_ROW_COUNTER SET 0
_ROWS_EXPECTED SET 0
_DURATION SET 1
_LOOP_COUNTER SET 0
_CURRENT_CHANNEL SET 1

; specify the current channel
__channel: MACRO
_CURRENT_CHANNEL SET \1
ENDM

__printSongSize: MACRO
SIZE EQU @ - \1
PRINTLN STRFMT("%s size: %d bytes", "\1", SIZE)
PURGE SIZE
ENDM

;
; start of track data
; \1 - number of rows to check against row counter
;
__track: MACRO
_ROW_COUNTER SET 0
_ROWS_EXPECTED SET \1
ENDM

;
; end entering track data
; checks if the number of entered rows matches the start of the row
;
__trackEnd: MACRO
STATIC_ASSERT WARN, _ROW_COUNTER == _ROWS_EXPECTED, "track length incorrect, expected {d:_ROWS_EXPECTED} got {d:_ROW_COUNTER}"
ENDM


note: MACRO
IF _CURRENT_CHANNEL == 4
    STATIC_ASSERT FATAL, \1 <= B_6 || \1 == NOTE_CUT || \1 == NOTE_HOLD, "illegal note index"
ELSE
    STATIC_ASSERT FATAL, \1 <= NOTE_LAST, "illegal note index"
ENDC
    DB \1
_ROW_COUNTER SET _ROW_COUNTER + _DURATION
_LOOP_COUNTER SET _LOOP_COUNTER + _DURATION
ENDM

duration: MACRO
    STATIC_ASSERT FATAL, (\1) >= 1 && (\1) <= 64, "duration must be between 1 and 64 rows"
    DB $C0 | (\1 - 1)
_DURATION SET \1
ENDM

; snd_jump <addr>
snd_jump: MACRO
    DB $A0 | CMD_JUMP
    DW \1
ENDM


; snd_call <addr>
snd_call: MACRO
    DB $A0 | CMD_CALL
    DW \1
ENDM

; snd_ret
snd_ret: MACRO
    cmd CMD_RET, 0
ENDM

loopBegin: MACRO
_LOOP_COUNTER = 0
    cmd CMD_LOOP_BEGIN, 0
ENDM

; loop <count>
loopEnd: MACRO
_ROW_COUNTER SET _ROW_COUNTER + (_LOOP_COUNTER * \1)
    cmd CMD_LOOP_END, \1
ENDM

; halt
snd_halt: MACRO
    cmd CMD_HALT, 0
ENDM

; tempo <speed>
tempo: MACRO
    STATIC_ASSERT FATAL, \1 >= 8 && \1 < 248, "invalid speed"
    cmd CMD_TEMPO, \1
ENDM

; sfx <sfxId>
sfx: MACRO
    cmd CMD_SFX, \1
ENDM

; lock
lock: MACRO
    cmd CMD_LOCK, 0
ENDM

; arp <param>
arp: MACRO
    STATIC_ASSERT FATAL, _CURRENT_CHANNEL != 4, "cannot use arp on CH4"
    cmd CMD_ARP, \1
ENDM

; pitchSlideUp <param>
pitchSlideUp: MACRO
    STATIC_ASSERT FATAL, _CURRENT_CHANNEL != 4, "cannot use pitchSlideUp on CH4"
    cmd CMD_PITCH_SLIDE_UP, \1
ENDM

pitchSlideDown: MACRO
    STATIC_ASSERT FATAL, _CURRENT_CHANNEL != 4, "cannot use pitchSlideDown on CH4"
    cmd CMD_PITCH_SLIDE_DOWN, \1
ENDM

portamento: MACRO
    STATIC_ASSERT FATAL, _CURRENT_CHANNEL != 4, "cannot use portamento on CH4"
    cmd CMD_PORTAMENTO, \1
ENDM

vibrato: MACRO
    STATIC_ASSERT FATAL, _CURRENT_CHANNEL != 4, "cannot use vibrato on CH4"
    cmd CMD_VIBRATO, \1
ENDM

vibratoDelay: MACRO
    STATIC_ASSERT FATAL, _CURRENT_CHANNEL != 4, "cannot use vibratoDelay on CH4"
    cmd CMD_VIBRATO_DELAY, \1
ENDM

setEnvelope: MACRO
    cmd CMD_SET_ENVELOPE, \1
ENDM

setInstrument: MACRO
    cmd CMD_SET_INSTRUMENT, \1
ENDM

timbre0: MACRO
    cmd CMD_TIMBRE_0, 0
ENDM

timbre1: MACRO
    cmd CMD_TIMBRE_1, 0
ENDM

timbre2: MACRO
    cmd CMD_TIMBRE_2, 0
ENDM

timbre3: MACRO
    cmd CMD_TIMBRE_3, 0
ENDM

panLeft: MACRO
    cmd CMD_PAN_LEFT, 0
ENDM

panRight: MACRO
    cmd CMD_PAN_RIGHT, 0
ENDM

panMiddle: MACRO
    cmd CMD_PAN_MIDDLE, 0
ENDM

delayedNote: MACRO
    cmd CMD_DELAYED_NOTE, \1
ENDM

delayedCut: MACRO
    cmd CMD_DELAYED_CUT, \1
ENDM


ENDC ; IF !DEF(TBENGINE_INC)
