; -----------------------------------------------------------------------------
; tbengine
;
; Trackerboy Music/SFX engine for the gameboy.
;
; Copyright (c) 2020-2024 - stoneface86
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;
; -----------------------------------------------------------------------------


;; Naming conventions
;; Labels:
;;  - camelCase
;;  - Start with an underscore if registers other than `af` get clobbered
;;  - Public API routines start with `tbe` and are exported
;; Constants:
;;  - PascalCase
;; Macros:
;;  - camelCase
;; Defines:
;;  - PascalCase
;;  - Start with `Tbe`


INCLUDE "hardware.inc"

; 1 unit of speed is 1.0 frames/row
DEF UnitSpeed EQU $10

; Schedule
RSRESET
DEF ScheduleBitsRemain  RB
DEF ScheduleBufPos      RB
DEF ScheduleBuf         RB
DEF ScheduleData        RW
DEF ScheduleSizeof      RB 0

; Seqenum (Sequence enumerator)
RSRESET
DEF SeqenumNext         RW
DEF SeqenumRemaining    RB
DEF SeqenumRefill       RB
DEF SeqenumSizeof       RB 0

;; channel branch on register b.
;; if b == 0 then jump to .ch1
;; if b == 1 then jump to .ch2 and so on
;; 10 bytes, 5-11 cycles
MACRO chbranch
    inc     b
    dec     b
    jr      z, .ch1
    dec     b
    jr      z, .ch2
    dec     b
    jr      z, .ch3
ENDM

;; nega - negate a
;; 2 bytes, 2 cycles
MACRO nega
    cpl
    inc     a
ENDM

;; negw - negate word
;; 6 bytes, 6 cycles
MACRO negw
    xor     a, a
    sub     a, LOW(\1)
    ld      LOW(\1), a
    sbc     a, a
    sub     a, HIGH(\1)
    ld      HIGH(\1), a
ENDM

;; Set zero flag, clear carry flag
MACRO szfccf
    cp      a, a
ENDM

;; switch bank to the song's current bank
;; If option TbeHookBankEnter is defined, then a user-provided bank switch
;; routine will handle the switch.
MACRO bankenter
    ld      a, [wSongBank]
IF DEF(TbeHookBankEnter)
    call    tbeOnBankEnter
ELSE
    ld      [$2000], a
ENDC
ENDM

;; Exit the current song's bank. By default this does nothing, as the previous
;; bank set before bankenter is unknown. If option TbeHookBankExit is defined,
;; then a user-provided routine will be called.
MACRO bankexit
IF DEF (TbeHookBankExit)
    call    tbeOnBankExit
ENDC
ENDM

; =============================================================================
;                                                                          ROM0
SECTION "tbengine", ROM0

tbeBegin:

tbeThumbprint:
    DB "tbengine - sound driver by stoneface"

;
; Initialize the engine. Call this once before using any tbe routines
;
tbeInit::
    push    af
    push    bc
    push    hl
    ; clear WRAM
    ld      b, tbeWramEnd - tbeWramBegin
    ld      hl, tbeWramBegin
    xor     a, a
    call    _memsetb
    ; set halted
    inc     a
    ld     [wHalted], a

    pop    hl
    pop    bc
    pop    af
    ret

;
; Locks a channel for music playback. Does nothing if the channel is already
; locked.
;
tbeLockChannel::
    ret

;
; Unlocks a channel for custom usage. Music will no longer play on this channel
;
tbeUnlockChannel::
    ret

tbePlaySong::
    ret

tbePlaySfx::
    ret

;
; Updates sound registers, call every vblank or periodically
;
tbeUpdate::
    ld      a, [wHalted]
    or      a, a
    ret     nz                          ; exit early if halted
    
    push    bc

    bankenter

    ld      a, [wTimer]         ; check if timer is active, or timer < 1.0
    and     a, $F0
    jr      nz, .timerInactive
.timerActive: ; start of new row
    call    scheduleNext
    ld      b, a
FOR I, 0, 4
    bit     I, b
    call    nz, parseBytecode
ENDR
    bit     5, b
    jr      z, .updateChannels          ; check if end of schedule
    call    nextPattern                 ; load next pattern
    jr      z, .done                    ; if halted, exit early
.timerInactive:
.updateChannels: ; tick all channels and update all locked ones
    ld      b, 0
    call    updateChannel               ; update CH1
    inc     b
    call    updateChannel               ; update CH2
    inc     b
    call    updateChannel               ; update CH3
    inc     b
    call    updateChannel               ; update CH4

    ld      a, [wPanningDirty]          ; update NR51 if needed
    or      a, a
    call    nz, updateNr51
.timerUpdate:
    ld      a, [wTimerPeriod]           ; b = wTimerPeriod
    ld      b, a
    ld      a, [wTimer]                 ; a = wTimer
    add     a, UnitSpeed                ; increment the timer by unit speed

    cp      a, b                        ; check if wTimer >= wTimerPeriod
    jr      c, .timerNoOverflow
.timerOverflow: ; end of row
    sub     a, b                        ; timer overflow, subtract period
.timerNoOverflow:
    ld      [wTimer], a                 ; store back into wTimer
.done:
    bankexit
    pop     bc
    ret


;;
;; Load the schedule enumerator to WRAM using the schedule in [hl]
;;
scheduleLoad:
    push    hl
    push    de
    push    bc
    
    ld      de, wScheduleBits
    ld      a, [hl+]
    ld      [de], a                 ; wScheduleBits = [hl]
    inc     de
    ld      a, 1                    ; wScheduleMask = 1
    ld      [de], a
    inc     de
    ld      b, 8
    call    _memcpyb

    pop     bc
    pop     de
    pop     hl
    ret


;;
;; Gets the next value in the schedule
;; Input:
;;   N/A
;; Output:
;;   a - bitmap of channels that are currently scheduled, bit 0 is ch1,
;;       1 is ch2, etc
;;
scheduleNext:
    push    bc
    push    de
    push    hl

    ld      de, wScheduleMask
    xor     a, a
    ld      b, a                    ; b = result
    ld      a, [de]
    ld      c, a                    ; c = wScheduleMask
    inc     de                      ; de = wScheduleData1

FOR I, 4
    ld      a, [de]
    ld      l, a
    inc     de
    ld      a, [de]
    ld      h, a
IF I != 3
    inc     de
ENDC
    ld      a, c
    and     a, [hl]
    jr      z, .notset\@
    set     I, b
.notset\@:
ENDR

    ld      a, c                    ; rotate the mask to select the next bit
    rlca
    ld      [wScheduleMask], a
    jr      nc, .noRotate
    ; we are done with the current byte, adjust all data pointers to the next
    ; one
FOR I, 1, 5
    ld      hl, wScheduleData{d:I}
    ld      a, [hl+]
    ld      e, a
    ld      d, [hl]
    inc     de
    ld      a, d
    ld      [hl-], a
    ld      [hl], e
ENDR
.noRotate:
    ld      hl, wScheduleBits       ; decrement the bits remaining counter
    ld      a, [hl]
    or      a, a
    jr      z, .atEnd               ; if zero, we are at the end
    dec     a
    ld      [hl], a
    jr      .done
.atEnd:
    set     4, b                    ; indicate end of schedule in bit 4
.done:
    ld      a, b                    ; return value
    pop     hl
    pop     de
    pop     bc
    ret

parseBytecode:
    ret

;;
;; Loads the next pattern in WRAM.
;; Input
;;   N/A
;; Output
;;   z: set if there is no  
;;
nextPattern:
    ret

;;
;; Updates channel registers for a channel.
;; Input
;;   b: The channel to update (0: CH1 .. 3: CH4)
;; Output
;;   N/A
;;
updateChannel:
    ret

; seqenum: sequence enumerator
; bytes 0-1: next pointer
; byte 2: remaining
; byte 3: refill (0 for sequences with no loop index)



;
; In:
;  hl - pointer to sequence enumerator
; Out:
;  a - zero if the sequence has a next value, nonzero otherwise
;
seqenum_has::
    inc     hl
    inc     hl
    ld      a, [hl-]
    dec     hl
    ret

;
; In:
;   hl - pointer to sequence enumerator
; Out:
;   b - the next value
;
seqenum_next::
    push    de
    ld      a, [hl+]    ; de = next
    ld      e, a
    ld      a, [hl+]
    ld      d, a
    ld      a, [de]     ; b = *next
    ld      b, a
    dec     [hl]        ; --seqenum->remaining
    inc     de          ; seqenum->next++
    jr      z, .atend
    dec     hl
    ld      a, d
    ld      [hl-], a
    ld      a, e
    ld      [hl], a
    pop     de
    ret
.atend:
    inc     hl
    ld      a, [hl-]    ; a = seqenum->refill
    or      a, a
    jr      nz, .loop
    dec     hl
    dec     hl
    pop     de
    ret
.loop:
    ld      [hl], a     ; seqenum->remaining = seqenum->refill
    ; seqenum->next -= seqenum->refill
    ; subtract de by a, store into the next pointer
    push    bc
    ld      b, 0
    ld      c, a
    ld      a, e
    sub     a, c
    ld      e, a
    ld      a, d
    sbc     a, b
    ld      d, a
    pop     bc

    dec     hl
    ld      [hl-], a
    ld      a, e
    ld      [hl], a
    pop     de
    ret

; call this to update nr51 if wPanningDirty is set
updateNr51:
    ; for any unlocked channels, we need to leave its flags in nr51 unchanged
    ; so only update nr51 settings for locked channels
    push    af
    push    bc
    push    hl
    ld      hl, wPanning1
    ld      a, [hl+]        ; put CH1 panning into b
    ld      b, a
    ld      a, [hl+]        ; combine with CH2
    or      a, b
    ld      b, a
    ld      a, [hl+]        ; combine with CH3
    or      a, b
    ld      b, a
    ld      a, [hl]         ; combine with CH4
    or      a, b
    ld      b, a            ; b = music panning
    ld      a, [wLockFlags] ; get the lock flags
    ld      c, a
    cpl
    and     a, b            ; ignore unlocked channels
    ld      b, a            ; combine with music panning
    ld      a, [rNR51]
    and     a, c            ; combine with unlocked panning
    or      a, b
    ld      [rNR51], a      ; update nr51

    ; clear dirty flag
    xor     a, a
    ld      [wPanningDirty], a
    pop     hl
    pop     bc
    pop     af
    ret

; hl = source address
; b = bytes to copy
; c = destination ($FF00 + c)

;;
;; Copy memory from address in hl to HRAM address $FF00 + c
;; Input
;;   - b: bytes to copy, note that 0 will copy 256 bytes
;;   - c: destination address in HRAM to copy to
;;   - hl: source address to copy from
;; Output
;;   - b <- 0
;;   - c <- b + c
;;   - hl <- hl + b
;;
_iomemcpy:
    ld      a, [hl+]
    ld      [c], a
    inc     c
    dec     b
    jr      nz, _iomemcpy
    ret

;;
;; Updates waveram with the given waveform from tbeWaveTable. If the index
;; is outside the bounds of tbeWaveTable then this routine does nothing.
;; Otherwise, CH3 DAC is turned off and the WAVERAM is written with the
;; waveform in the table.
;;
;; Input
;;  a - index of waveform to write
;; Output
;;  N/A
;;
writeWaveform:
    push    hl
    push    bc
    ld      l, a                 ; l = waveform index
    ld      bc, tbeWaveTable    ; bc = tbeWaveTable
    ld      a, [bc]              ; a = size of wave table
    cp      a, l                ; make sure we have a valid index
    jr      z, .exit
    jr      c, .exit
    inc     bc
    xor     a, a
    ld      h, a                ; hl = waveform index
REPT 4                          ; hl = hl * 4
    add     hl, hl
ENDR
    add     hl, bc
    ld      [rNR30], a           ; CH3 sound off
    ld      b, 16
    ld      c, _AUD3WAVERAM - $FF00
    call    _iomemcpy
.exit:
    pop     bc
    pop     hl
    ret

_memsetb:
    inc     b
    jr      .decrement
.loop:
    ld      [hl+], a
.decrement:
    dec     b
    jr      nz, .loop
    ret

;;
;; Copy memory from source address, hl, to destination address, de.
;; Input
;;   - b: number of bytes to copy
;;   - de: destination address to copy to
;;   - hl: source address to copy from
;; Output
;;   - b  <- 0
;;   - de <- de + b
;;   - hl <- hl + b
;;
_memcpyb:
    ld      a, [hl+]
    ld      [de], a
    inc     de
    dec     b
    jr      nz, _memcpyb
    ret

;; for calling a subroutine pointed by hl: `call jphl`
;jphl:
;    jp      hl

IF DEF(TbeNoWaveTable)
tbeWaveTable::
    DB 0
ENDC

IF DEF(TbeNoInstrumentTable)
tbeInstrumentTable::
    DB 0
ENDC

tbe_end:
IF DEF(TBE_PRINT_USAGE)
    PRINTLN STRFMT("ROM usage: %d bytes", tbe_end - tbeBegin)
ENDC

; =============================================================================
;                                                                         WRAM0

SECTION "tbengine WRAM", WRAM0
tbeWramBegin:

wHalted:            DS 1
wTimer:             DS 1
wTimerPeriod:       DS 1

wLockFlags:         DS 1

wSongBank:          DS 1
wSongPointer:       DS 2

wScheduleBits:      DS 1
wScheduleMask:      DS 1
wScheduleData1:     DS 2
wScheduleData2:     DS 2
wScheduleData3:     DS 2
wScheduleData4:     DS 2

wStreamPtr1:        DS 2
wStreamPtr2:        DS 2
wStreamPtr3:        DS 2
wStreamPtr4:        DS 2

wDelay1: DS 1

; MACRO InstRuntimeWram
;   wIrArpEnd\1:      DS 2
;   wIrArpNext\1:     DS 2
;   wIrPitchEnd\1:    DS 2
;   wIrPitchNext\1:   DS 2
;   wIrEnvEnd\1:      DS 2
;   wIrEnvNext\1:     DS 2
;   wIrTimbreEnd\1:   DS 2
;   wIrTimbreNext\1:  DS 2
;   wIrPanningEnd\1:  DS 2
;   wIrPanningNext\1: DS 2
; ENDM

; MACRO TrackControlWram
;   wTcEnvelope\1: DS 1
  

; InstRuntimeWram 1
; InstRuntimeWram 2
; InstRuntimeWram 3
; InstRuntimeWram 4


wPanningDirty: DS 1
wPanning1: DS 1
wPanning2: DS 1
wPanning3: DS 1
wPanning4: DS 1



tbeWramEnd:
IF DEF(TBE_PRINT_USAGE)
    PRINTLN STRFMT("RAM usage: %d bytes", tbeWramEnd - tbeWramBegin)
ENDC
