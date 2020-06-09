; -----------------------------------------------------------------------------
; WRAM variables

SECTION "tbengine_wram", WRAM0

timer:          DS 1        ; current timer value
timerPeriod:    DS 1        ; number of frames per row in Q5.3 format
; low byte of these addresses MUST be <= 0xFC
ch1Pc:          DS 2
ch2Pc:          DS 2
ch3Pc:          DS 2
ch4Pc:          DS 2
ch1Ret:         DS 2        ; return address for channel 1
ch2Ret:         DS 2
ch3Ret:         DS 2
ch4Ret:         DS 2

FreqControl1:   DS FreqControl_SIZEOF
FreqControl2:   DS FreqControl_SIZEOF
FreqControl3:   DS FreqControl_SIZEOF
