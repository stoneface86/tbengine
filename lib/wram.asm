; -----------------------------------------------------------------------------
; WRAM variables

SECTION "tbengine_wram", WRAM0, ALIGN[6]

tbeWramBegin:
status:         DS 1
timer:          DS 1        ; current timer value
timerPeriod:    DS 1        ; number of frames per row in Q5.3 format

orderCount:     DS 1        ; number of patterns in order less 1
orderPtr:       DS 2        ; pointer to pattern order table

; bits 0-3: new row for CH1-4
chflags:        DS 1

; channel pointers, these point to the current row being played
ch1Ptr:         DS 2
ch2Ptr:         DS 2
ch3Ptr:         DS 2
ch4Ptr:         DS 2

rowCounter1:    DS 1
rowCounter2:    DS 1
rowCounter3:    DS 1
rowCounter4:    DS 1

; number of rows remaining in the pattern
; when this overflows, it's time to load the next pattern
patternCounter: DS 1
; size, in rows - 1, of a pattern
; the patternCounter is reloaded with this variable when a new pattern plays
patternSize:    DS 1

; pattern command
; 00 - do nothing
; 01 - pattern goto
; 10 - pattern skip, start at row
patternCommand: DS 1
patternParam:   DS 1


FreqControl1:   DS FreqControl_SIZEOF
FreqControl2:   DS FreqControl_SIZEOF
FreqControl3:   DS FreqControl_SIZEOF

tbeWramEnd:
