

IF DEF(TBE_ROM0)
SECTION "tbengine", ROM0
ELSE
SECTION "tbengine", ROMX
ENDC

INCLUDE "hardware.inc"

UNIT_SPEED EQU %00001000    ; unit speed, 1.0 in Q5.3 format
ENGINE_FLAGS_HALTED EQU 0

; chflags bit fields
; rowen means that a new row from music data is to be parsed
; if a channel is locked, music will not play on it
ENGINE_CHFLAGS_ROWEN1   EQU 0 ; bit 0: CH1 row enable (if set)
ENGINE_CHFLAGS_ROWEN2   EQU 1 ; bit 1: CH2 row enable (if set)
ENGINE_CHFLAGS_ROWEN3   EQU 2 ; bit 2: CH3 row enable (if set)
ENGINE_CHFLAGS_ROWEN4   EQU 3 ; bit 3: CH4 row enable (if set)
ENGINE_CHFLAGS_LOCK1    EQU 4 ; bit 4: CH1 lock status
ENGINE_CHFLAGS_LOCK2    EQU 5 ; bit 5: CH2 lock status
ENGINE_CHFLAGS_LOCK3    EQU 6 ; bit 6: CH3 lock status
ENGINE_CHFLAGS_LOCK4    EQU 7 ; bit 7: CH4 lock status

ENGINE_DEFAULT_ENVELOPE EQU $F0

; pattern commands, applied at the start of a new row (timer active)
PATTERN_CMD_NONE EQU 0
PATTERN_CMD_SKIP EQU 1
PATTERN_CMD_JUMP EQU 2

                        RSRESET
SongHeader_speed        RB 1
SongHeader_patterns     RB 1
SongHeader_order        RW 1
SongHeader_SIZEOF       RB 0

parseRow: MACRO
    ld      a, 1 << (3 + \1)                ; channel lock mask
    and     c                               ; and with flags
    ld      [tbe_wCurrentChLocked], a       ; store in the variable for later use
    bit     (\1 - 1), c
    call    nz, _tbe_parseRow
    inc     b
ENDM

tbe_begin:
tbe_init::
    push    bc
    push    hl

    ld      bc, tbe_wWramEnd - tbe_wWramBegin
    ld      hl, tbe_wWramBegin
    xor     a
    call    _tbe_memset

    ; init sound regs
    ld      a, $80
    ld      [rNR52], a                      ; sound ON
    xor     a
    ld      [rNR51], a                      ; mute all terminals
    cpl
    ld      [rNR50], a                      ; enable both terminals, max volume

    ; init channel settings
    call    _tbe_reset_channels

    pop     hl
    pop     bc
    ret

tbe_dDefaultChSettings:
    ; envelope
    DB  $F0, $F0, $00, $F0
    ; timbre
    DB  $00, $00, $20, $00
    ; panning
    DB  $FF
    ; frequency
    DW $0000, $0000, $0000, $0000
tbe_dDefaultChSettingsEnd:

;
; Reset all channel settings to defaults
;
_tbe_reset_channels:
    push    bc
    push    de
    push    hl

    ld      bc, tbe_dDefaultChSettingsEnd - tbe_dDefaultChSettings
    ld      hl, tbe_dDefaultChSettings
    ld      de, tbe_wChannelSettings
    call    _tbe_memcpy

    pop     hl
    pop     de
    pop     bc
    ret

;
; Lock a channel for access to sound registers. The engine will no longer
; update registers for the specified channel.
;
tbe_lockChannel::
    ld      a, [tbe_wChflags]
    chjumptable
.ch4:
    set     ENGINE_CHFLAGS_LOCK4, a
    ld      b, $77
    ld      c, rNR41 - $FF00 - 1
    jr      .clearchannels
.ch3:
    set     ENGINE_CHFLAGS_LOCK3, a
    ld      b, $BB
    ld      c, rNR30 - $FF00
    jr      .clearchannels
.ch2:
    set     ENGINE_CHFLAGS_LOCK2, a
    ld      b, $DD
    ld      c, rNR21 - $FF00 - 1
    jr      .clearchannels
.ch1:
    set     ENGINE_CHFLAGS_LOCK1, a
    ld      b, $EE
    ld      c, rNR10 - $FF00
.clearchannels:
    ld      [tbe_wChflags], a
    ld      a, [rNR51]
    and     a, b
    ld      [rNR51], a
    xor     a
    ld      b, 4
.loop:
    ld      [c], a
    inc     c
    dec     b
    jr      nz, .loop
    ld      a, $80
    ld      [c], a
    
    ret

tbe_unlockChannel::
    ret


;
; Prepares the engine to play a song from the given pointer
;
tbe_playSong::
    push    hl
    ld      a, [hl+]                    ; get the speed
    ld      [tbe_wTimerPeriod], a       ; set the timer period to the speed
    ld      a, [hl+]                    ; get and save the pattern count
    ld      [tbe_wOrderCount], a
    ld      a, [hl+]
    ld      [tbe_wPatternSize], a
    ld      a, [hl+]
    ld      [tbe_wOrderTable], a
    ld      [tbe_wCurrentOrder], a
    ld      a, [hl+]
    ld      [tbe_wOrderTable + 1], a
    ld      [tbe_wCurrentOrder + 1], a
    ld      a, $0F                      ; initialize chflags
    ld      [tbe_wChflags], a
    ld      a, PATTERN_CMD_JUMP         ; setup a jump to pattern 0 to initialize chptrs
    ld      [tbe_wPatternCommand], a
    xor     a
    ld      [tbe_wPatternParam], a
    ld      [tbe_wTimer], a             ; reset the timer
    ld      [tbe_wOrderCounter], a

    pop     hl
    ret

tbe_playSfx::
    ret

; NOTE: the engine does not error check music data, attempting to play
; incorrect music data may result in undefined behavior

tbe_update::
    ld      a, [tbe_wStatus]
    bit     ENGINE_FLAGS_HALTED, a
    ret     nz

    ld      [tbe_wStack], sp

    ld      a, [tbe_wTimer]                 ; check if timer is active (timer < UNIT_SPEED)
    and     a, %11111000
    jp      nz, .timerNotActive

; TIMER ACTIVE ---- (start of new row) ----------------------------------------

    ; apply the pattern effect (jump/skip)
    ld      a, [tbe_wPatternCommand]
    xor     a, PATTERN_CMD_JUMP             ; check if a == PATTERN_CMD_JUMP
    jr      nz, .skipCmd
    ; jump command
    ld      a, [tbe_wOrderTable]
    ld      c, a
    ld      a, [tbe_wOrderTable + 1]
    ld      b, a
    ; NOTE: buffer overrun will occur if patternParam > orderCount
    ld      a, [tbe_wPatternParam]
    ld      [tbe_wOrderCounter], a
    ; an order is 4 pointers or 8 bytes, so we need to multiply patternParam by 8
    ld      h, 0                            ; hl = patternParam
    ld      l, a
    add     hl, hl                          ; shift left 3 times
    add     hl, hl
    add     hl, hl
    add     hl, bc                          ; offset the order table

    ld      de, tbe_wCh1Ptr                 ; copy the order to the channel pointers
    ld      b, 0
    ld      c, 8
    call    _tbe_memcpy

    ld      a, $0F                          ; new row for all channels
    ld      [tbe_wChflags], a

    xor     a                               ; reset row counters
    ld      [tbe_wRowCounter1], a
    ld      [tbe_wRowCounter2], a
    ld      [tbe_wRowCounter3], a
    ld      [tbe_wRowCounter4], a

    jr      .updateCmd
.skipCmd:
    xor     a, PATTERN_CMD_SKIP ^ PATTERN_CMD_JUMP
    jr      nz, .noCmd
    ; skip command
    ld      a, [tbe_wOrderCounter]
    ld      b, a
    ld      a, [tbe_wOrderCount]
    xor     a, b
    jr      z, .noIncrement                 ; check if the orderCounter == orderCount (last order)
    inc     b                               ; nope, just increment to the next order
    ld      a, [tbe_wCurrentOrder]          ; hl = currentOrder
    ld      l, a
    ld      a, [tbe_wCurrentOrder + 1]
    ld      h, a
    ld      d, 0
    ld      e, 8
    add     hl, de                          ; point hl to the next one
    ld      a, b
    jr      .updateOrderVars
.noIncrement:                               ; end of order, go back to the start (0)
    ld      a,  [tbe_wOrderTable]           ; currentOrder = orderTable
    ld      l, a
    ld      a, [tbe_wOrderTable + 1]
    ld      h, a
    xor     a                               ; orderCounter = 0
.updateOrderVars:
    ld      [tbe_wOrderCounter], a          ; update orderCounter and currentOrder
    ld      a, l
    ld      [tbe_wCurrentOrder], a
    ld      a, h
    ld      [tbe_wCurrentOrder + 1], a
    ld      a, [tbe_wPatternParam]
    or      a
    call    nz, _tbe_fastforward

.updateCmd:
    xor     a
    ld      [tbe_wPatternCommand], a        ; reset pattern command variable
.noCmd:

    ld      a, [tbe_wChflags]
    ld      c, a
    ld      b, 0
    parseRow 1
    parseRow 2
    parseRow 3
    parseRow 4
    ld      a, c
    and     a, $F0                          ; reset all rowen flags
    ld      [tbe_wChflags], a

.timerNotActive:

; UPDATE CHANNELS -------------------------------------------------------------

    ; TODO channel update logic

; UPDATE TIMER ----------------------------------------------------------------
    ld      a, [tbe_wTimerPeriod]           ; b = timerPeriod
    ld      b, a
    ld      a, [tbe_wTimer]                 ; a = timer
    add     a, UNIT_SPEED                   ; increment the timer

    cp      a, b                            ; check if timer >= timerPeriod
    jr      c, .noOverflow
; TIMER OVERFLOW ---- (end of row) --------------------------------------------
    sub     a, b                            ; timer overflow, subtract period
    ld      [tbe_wTimer], a                 ; store into timer

    ; since timer >= timerPeriod, we have finished a row (timer overflowed)
    ; update row counters
    ld      hl, tbe_wRowCounter4            ; start with CH4
    ld      b, 4                            ; loop counter
    ld      c, 1 << ENGINE_CHFLAGS_ROWEN4   ; bit mask for chflags
.loopRowCounter:
    ld      a, [hl]                         ; get the row counter for the channel
    or      a                               ; set zero flag
    jr      nz, .decrementRowCounter
    ld      a, [tbe_wChflags]               ; get the channel flags
    or      a, c                            ; set new row for the channel
    ld      [tbe_wChflags], a               ; store it back
    jr      .endRowCounter
.decrementRowCounter:
    dec     a
    ld      [hl], a                         ; store the counter
.endRowCounter:
    rrc     c                               ; decrement mask
    dec     l                               ; decrement pointer
    dec     b                               ; decrement counter
    jr      nz, .loopRowCounter

    ; update pattern counter
    ld      a, [tbe_wPatternCounter]            ; check if patternCounter == 0
    or      a
    jr      nz, .decrementPatternCounter
    ; pattern ended, load next one in the order unless a goto/skip is already scheduled
    ld      a, [tbe_wPatternCommand]            ; check if patternCommand == 0 (no command set)
    or      a
    jr      nz, .reloadPatternCounter
    ld      a, PATTERN_CMD_SKIP                 ; skip to the next pattern
    ld      [tbe_wPatternCommand], a
    xor     a                                   ; clear the param (so we start at row 0)
    ld      [tbe_wPatternParam], a
.reloadPatternCounter:
    ld      a, [tbe_wPatternSize] 
    jr      .writePatternCounter
.decrementPatternCounter:
    dec     a
.writePatternCounter:
    ld      [tbe_wPatternCounter], a
    ret
.noOverflow:
    ; the timer didn't overflow so we are still in the current row
    ld      [tbe_wTimer], a
    ret


;
; Parse a row for the given channel
;  b - channel id
;
_tbe_parseRow:
    push    bc
    push    de
    ld      hl, tbe_wCh1Ptr         ; hl = channel pointer
    ld      a, b                    ; offset hl by channel id * 2
    rlca
    add     a, l
    ld      l, a
    push    hl
    ld      a, [hl+]
    ld      d, a
    ld      a, [hl]
    ld      h, a
    ld      l, d
    

.getbyte:
    ld      a, [hl+]
    bit     7, a                    ; do we have a note?
    jr      z, .notebyte            ; if reset we have a note byte (which ends the row)
    bit     6, a                    ; do we have a duration?
    jr      z, .cmdbyte             ; if reset we have a command byte
    ; duration byte
    and     a, $3F                  ; mask the duration
    ld      c, a                    ; c = duration
    ld      de, tbe_wRowDuration1   ; de = row duration variable
    ld      a, e
    add     a, b                    ; offset by channel id
    ld      e, a
    ld      a, c
    ld      [de], a                 ; update duration
    jr      .getbyte                ; get next byte
.cmdbyte
    ld      d, a                    ; d = command byte
    bit     5, a                    ; check for parameter
    jr      z, .noparam
    ld      a, [hl+]                ; next byte is the parameter
    jr      .paramdone
.noparam:
    xor     a                       ; no parameter, default to 0
.paramdone:
    ld      c, a                    ; c = parameter
    ld      a, d                    ; restore command byte

    and     a, $1F                  ; a = command index
    rla                             ; multiply by 2
    push    hl                      ; save hl for later

ASSERT FATAL, LOW(tbe_dCommandTable) == 0, "command table is mis-aligned"
    ; lookup the command
    ld      h, HIGH(tbe_dCommandTable)
    ld      l, a

    ld      a, [hl+]
    ld      e, a
    ld      a, [hl]
    ld      h, a                    ; hl = pointer to command function
    ld      l, e
    
    ld      a, c                    ; restore parameter
    jp      hl                      ; goto command
.cmdExit:                           ; command will return here when finished
    pop     hl

    jr      .getbyte                ; keep going
.notebyte:
    ; TODO: do something with the note (a)
    pop     de                      ; de = channel pointer variable (was saved early on)
    ld      a, l                    ; update channel pointer
    ld      [de], a
    inc     e
    ld      a, h
    ld      [de], a
    ld      de, tbe_wRowDuration1   ; set the row counter
    ld      a, e
    add     a, b
    ld      e, a
    ld      hl, tbe_wRowCounter1
    ld      a, l
    add     a, b
    ld      l, a
    ld      a, [de]
    ld      [hl], a
    pop     de
    pop     bc
    ret

;
; Adjusts row counters and channel pointers to start playing at a given row. The
; pattern is stepped through without applying effects so that we can start playing
; from a given row
; a - the row to start at
;
_tbe_fastforward:
    ; TODO implement fast forward
    ret

