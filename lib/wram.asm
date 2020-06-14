; -----------------------------------------------------------------------------
; WRAM variables

SECTION "tbengine_wram", WRAM0, ALIGN[6]

tbeWramBegin:
wStatus:            DS 1
wTimer:             DS 1        ; current timer value
wTimerPeriod:       DS 1        ; number of frames per row in Q5.3 format

wOrderCount:        DS 1        ; number of patterns in order less 1
wOrderCounter:      DS 1
wOrderTable:        DS 2        ; pointer to pattern order table
wCurrentOrder:      DS 2        ; pointer to the current order

; bits 0-3: new row for CH1-4
wChflags:           DS 1

; channel pointers, these point to the current row being played
wCh1Ptr:            DS 2
wCh2Ptr:            DS 2
wCh3Ptr:            DS 2
wCh4Ptr:            DS 2

wRowCounter1:       DS 1
wRowCounter2:       DS 1
wRowCounter3:       DS 1
wRowCounter4:       DS 1

; number of rows remaining in the pattern
; when this overflows, it's time to load the next pattern
wPatternCounter:    DS 1
; size, in rows - 1, of a pattern
; the patternCounter is reloaded with this variable when a new pattern plays
wPatternSize:       DS 1

; pattern command
; 00 - do nothing
; 01 - pattern goto
; 10 - pattern skip, start at row
wPatternCommand:    DS 1
wPatternParam:      DS 1

wFreqControl1:      DS FreqControl_SIZEOF
wFreqControl2:      DS FreqControl_SIZEOF
wFreqControl3:      DS FreqControl_SIZEOF

tbeWramEnd:
