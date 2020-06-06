; -----------------------------------------------------------------------------
; WRAM variables

FreqControlStruct: MACRO
fc\1_flags:         DS 1
fc\1_note:          DS 1
fc\1_tune:          DS 1
fc\1_freq:          DS 6 ; frequency buffer 
fc\1_slideSpeed:    DS 1
fc\1_slideTarget:   DS 2
fc\1_slideNote:     DS 1
fc\1_arpParam:      DS 1
fc\1_arpIndex:      DS 1
fc\1_vibCounter:    DS 1
fc\1_vibIndex:      DS 1
fc\1_vibSpeed:      DS 1
fc\1_vibTable:      DS 2
ENDM


SECTION "tbengine_wram", WRAM0

timer:          DS 1        ; current timer value
timerPeriod:    DS 1        ; number of frames per row in Q5.3 format

    FreqControlStruct 1     ; frequency control for CH1
    FreqControlStruct 2     ; CH2
    FreqControlStruct 3     ; CH3

