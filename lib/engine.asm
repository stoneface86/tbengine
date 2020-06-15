

IF DEF(TBE_ROM0)
SECTION "tbengine", ROM0
ELSE
SECTION "tbengine", ROMX
ENDC

INCLUDE "hardware.inc"

UNIT_SPEED EQU %00001000    ; unit speed, 1.0 in Q5.3 format
ENGINE_FLAGS_HALTED EQU 0

ENGINE_CHFLAGS_ROWEN1 EQU 0 ; bit 0: row enable (if set)
ENGINE_CHFLAGS_ROWEN2 EQU 1
ENGINE_CHFLAGS_ROWEN3 EQU 2
ENGINE_CHFLAGS_ROWEN4 EQU 3

ENGINE_DEFAULT_ENVELOPE EQU $F0

PATTERN_CMD_NONE EQU 0
PATTERN_CMD_SKIP EQU 1
PATTERN_CMD_JUMP EQU 2

                        RSRESET
SongHeader_speed        RB 1
SongHeader_patterns     RB 1
SongHeader_order        RW 1
SongHeader_SIZEOF       RB 0

updateRowCounter: MACRO
    ld      a, [wRowCounter\1]          ; get the row counter for the channel
    or      a                           ; set zero flag
    jr      nz, .decrementRowCounter\1
    ld      a, [wChflags]               ; get the channel flags
    set     \1 - 1, a                   ; set new row for the channel
    ld      [wChflags], a               ; store it back
    jr      .endRowCounter\1
.decrementRowCounter\1:
    dec     a
    ld      [wRowCounter\1], a          ; store the counter
.endRowCounter\1:
ENDM

tbe_begin:
tbe_init::
    push    bc
    push    hl

    ld      bc, tbeWramEnd - tbeWramBegin
    ld      hl, tbeWramBegin
    xor     a
    call    memset

    ; init sound regs
    ld      a, $80
    ld      [rNR52], a                      ; sound ON
    xor     a
    ld      [rNR51], a                      ; mute all terminals
    cpl
    ld      [rNR50], a                      ; enable both terminals, max volume

    ; init channel settings
    call    reset_channels

    pop     hl
    pop     bc
    ret

dDefaultChSettings:
    ; reg status
    DB  $FF, $FF
    ; timbre
    DB  %00010000
    ; envelope
    DB  $F0, $F0, $00, $F0
    ; panning
    DB  $FF
dDefaultChSettingsEnd:

;
; Reset all channel settings to defaults
;
reset_channels:
    push    bc
    push    de
    push    hl

    ld      bc, dDefaultChSettingsEnd - dDefaultChSettings
    ld      hl, dDefaultChSettings
    ld      de, wChannelSettings
    call    memcpy

    pop     hl
    pop     de
    pop     bc
    ret


;
; Prepares the engine to play a song from the given pointer
;
tbe_playSong::
    push    hl
    ld      a, [hl+]                ; get the speed
    ld      [wTimerPeriod], a       ; set the timer period to the speed
    ld      a, [hl+]                ; get and save the pattern count
    ld      [wOrderCount], a
    ld      a, [hl+]
    ld      [wPatternSize], a
    ld      a, [hl+]
    ld      [wOrderTable], a
    ld      [wCurrentOrder], a
    ld      a, [hl+]
    ld      [wOrderTable + 1], a
    ld      [wCurrentOrder + 1], a
    ld      a, $0F                   ; initialize chflags
    ld      [wChflags], a
    ld      a, PATTERN_CMD_JUMP
    ld      [wPatternCommand], a
    xor     a
    ld      [wPatternParam], a
    ld      [wTimer], a              ; reset the timer
    ld      [wOrderCounter], a

    pop     hl
    ret

tbe_playSfx::
    ret


tbe_update::
    ld      a, [wStatus]
    bit     ENGINE_FLAGS_HALTED, a
    ret     nz

    ld      [wStack], sp

    ld      a, [wTimer]                 ; check if timer is active (timer < UNIT_SPEED)
    and     a, %11111000
    jp      nz, .timerNotActive
    ; timer is active (start of new row)
    ; apply the pattern effect (jump/skip)
    ; start the
    ld      a, [wPatternCommand]
    xor     a, PATTERN_CMD_JUMP         ; check if a == PATTERN_CMD_JUMP
    jr      nz, .skipCmd
    ; jump command
    ld      a, [wOrderTable]
    ld      c, a
    ld      a, [wOrderTable + 1]
    ld      b, a
    ; should we error check? buffer overrun will occur if patternParam > orderCount
    ; nah, but if error just halt
    ld      a, [wPatternParam]
    ld      [wOrderCounter], a
    ; an order is 4 pointers or 8 bytes, so we need to multiply patternParam by 8
    ld      h, 0                        ; hl = patternParam
    ld      l, a
    add     hl, hl                      ; shift left 3 times
    add     hl, hl
    add     hl, hl
    add     hl, bc                      ; offset the order table

    ld      de, wCh1Ptr                 ; copy the order to the channel pointers
    ld      b, 0
    ld      c, 8
    call    memcpy

    ld      a, $0F                      ; new row for all channels
    ld      [wChflags], a

    xor     a                           ; reset row counters
    ld      [wRowCounter1], a
    ld      [wRowCounter2], a
    ld      [wRowCounter3], a
    ld      [wRowCounter4], a

    jr      .updateCmd
.skipCmd:
    xor     a, PATTERN_CMD_SKIP ^ PATTERN_CMD_JUMP
    jr      nz, .noCmd
    ; skip command
    ld      a, [wOrderCounter]
    ld      b, a
    ld      a, [wOrderCount]
    xor     a, b
    jr      z, .noIncrement             ; check if the orderCounter == orderCount (last order)
    inc     b                           ; nope, just increment to the next order
    ld      a, [wCurrentOrder]          ; hl = currentOrder
    ld      l, a
    ld      a, [wCurrentOrder + 1]
    ld      h, a
    ld      d, 0
    ld      e, 8
    add     hl, de                      ; point hl to the next one
    ld      a, b
    jr      .updateOrderVars
.noIncrement:                           ; end of order, go back to the start (0)
    ld      a,  [wOrderTable]           ; currentOrder = orderTable
    ld      l, a
    ld      a, [wOrderTable + 1]
    ld      h, a
    xor     a                           ; orderCounter = 0
.updateOrderVars:
    ld      [wOrderCounter], a          ; update orderCounter and currentOrder
    ld      a, l
    ld      [wCurrentOrder], a
    ld      a, h
    ld      [wCurrentOrder + 1], a
    ld      a, [wPatternParam]
    or      a
    call    nz, fastforward

.updateCmd:
    xor     a
    ld      [wPatternCommand], a        ; reset pattern command variable
.noCmd:

    ld      a, [wChflags]
    ld      c, a
    ld      b, 0
    bit     ENGINE_CHFLAGS_ROWEN1, c
    call    nz, parseRow
    inc     b
    bit     ENGINE_CHFLAGS_ROWEN2, c
    call    nz, parseRow
    inc     b
    bit     ENGINE_CHFLAGS_ROWEN3, c
    call    nz, parseRow
    inc     b
    bit     ENGINE_CHFLAGS_ROWEN4, c
    call    nz, parseRow
    ld      a, c
    and     a, $F0                      ; reset all rowen flags
    ld      [wChflags], a

.timerNotActive:

    ld      a, [wTimerPeriod]           ; b = timerPeriod
    ld      b, a
    ld      a, [wTimer]                 ; a = timer
    add     a, UNIT_SPEED               ; increment the timer
    ld      c, a                        ; save if timer does not overflow
    sub     a, b                        ; timer -= timerPeriod
    jr      c, .incrementTimer          ; the timer overflowed if z or nc
    jr      .updateTimer
.incrementTimer:
    ld      a, c
.updateTimer:
    ld      [wTimer], a              ; update timer
    ; if we didn't overflow, we need to decrement the row counters
    jr      c, .exit

    ; since timer >= timerPeriod, we have finished a row (timer overflowed)
    ; update all counters
    updateRowCounter 1
    updateRowCounter 2
    updateRowCounter 3
    updateRowCounter 4

    ld      a, [wPatternCounter]            ; check if patternCounter == 0
    or      a
    jr      nz, .decrementPatternCounter
    ; pattern ended, load next one in the order
    ld      a, [wPatternCommand]            ; check if patternCommand == 0 (no command set)
    or      a
    jr      nz, .reloadPatternCounter
    ld      a, PATTERN_CMD_SKIP             ; skip to the next pattern
    ld      [wPatternCommand], a
    xor     a                               ; clear the param (so we start at row 0)
    ld      [wPatternParam], a
.reloadPatternCounter:
    ld      a, [wPatternSize] 
    jr      .writePatternCounter
.decrementPatternCounter:
    dec     a
.writePatternCounter:
    ld      [wPatternCounter], a
    
.exit:
    ret


;
; Parse a row for the given channel
;  b - channel id
;
parseRow:
    ASSERT FATAL, LOW(wCh1Ptr) <= $F8, "low byte of wCh1Ptr must be <= $F8"
    push    bc
    push    de
    ld      hl, wCh1Ptr         ; hl = channel pointer
    ld      a, b                ; offset hl by channel id * 2
    rla
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
    bit     7, a                ; do we have a note?
    jr      z, .notebyte        ; if reset we have a note byte (which ends the row)
    bit     6, a                ; do we have a duration?
    jr      z, .cmdbyte         ; if reset we have a command byte
    ; duration byte
    and     a, $3F              ; mask the duration
    ld      c, a                ; c = duration
    ld      de, wRowDuration1   ; de = row duration variable
    ld      a, e
    add     a, b                ; offset by channel id
    ld      e, a
    ld      a, c
    ld      [de], a             ; update duration
    jr      .getbyte            ; get next byte
.cmdbyte
    ld      d, a                ; c = command byte
    bit     5, a                ; check for parameter
    jr      z, .noparam
    ld      a, [hl+]
    jr      .paramdone
.noparam:
    xor     a
.paramdone:
    ld      c, a
    ld      a, d

    and     a, $1F              ; a = command index
    rla
    push    hl
    ld      hl, CommandTable
    ld      d, 0
    ld      e, a
    add     hl, de
    ld      a, [hl+]
    ld      e, a
    ld      a, [hl]
    ld      h, a
    ld      l, e
    
    ld      a, c
    call    _jp_hl
    pop     hl

    jr      .getbyte
.notebyte:
    ; TODO: do something with the note (a)
    pop     de
    ld      a, l
    ld      [de], a
    inc     e
    ld      a, h
    ld      [de], a
    ld      de, wRowDuration1
    ld      a, e
    add     a, b
    ld      e, a
    ld      hl, wRowCounter1
    ld      a, l
    add     a, b
    ld      l, a
    ld      a, [de]
    ld      [hl], a
    pop     de
    pop     bc
    ret

_jp_hl:
    jp      hl

;
; Adjusts row counters and channel pointers to start playing at a given row. The
; pattern is stepped through without applying effects so that we can start playing
; from a given row
; a - the row to start at
;
fastforward:
    ; TODO implement fast forward
    ret

