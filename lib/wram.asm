; -----------------------------------------------------------------------------
; WRAM variables

SECTION "tbengine_wram", WRAM0

tbeWramBegin:
wStatus:            DS 1
wTimer:             DS 1        ; current timer value
wTimerPeriod:       DS 1        ; number of frames per row in Q5.3 format

wOrderCount:        DS 1        ; number of patterns in order less 1
wOrderCounter:      DS 1
wOrderTable:        DS 2        ; pointer to pattern order table
wCurrentOrder:      DS 2        ; pointer to the current order

; bits 0-3: new row for CH1-4
; bits 4-7: lock status for CH1-4
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

; persistent row durations (default is 0)
wRowDuration1:      DS 1
wRowDuration2:      DS 1
wRowDuration3:      DS 1
wRowDuration4:      DS 1

; stack pointer when tbe_update is called
wStack:             DS 2

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


; register data
; music updates the data here first and then to registers if the channel is
; unlocked (A locked channel has a sound effect playing on it)

wChannelSettings:

; flags for determining which registers need updating

; bit 0: write timbre
; bit 1: write envelope
; bit 2: write panning
; bit 3: retrigger
wRegStatus12:       DS 1
wRegStatus34:       DS 1

; timbre for square is duty, wave volume for wave and step width for noise
; bit 0-1: ch1 duty (12.5%, 25%, 50%, 75%)
; bit 2-3: ch2 duty (12.5%, 25%, 50%, 75%)
; bit 4-5: ch3 volume (0%, 100%, 50%, 25%)
; bit 6: ch4 step width (15-bit, 7-bit)
wTimbre:            DS 1

; envelope settings for channels 1, 2 and 4
; for channel 3 the envelope is the waveform id
wEnvelope1:         DS 1
wEnvelope2:         DS 1
wEnvelope3:         DS 1
wEnvelope4:         DS 1

; channel panning, exact format as NR51
wChannelSettingsEnd:
wPanning:           DS 1


tbeWramEnd:
