

IF DEF(TBE_ROM0)
SECTION "tbengine", ROM0
ELSE
SECTION "tbengine", ROMX
ENDC

UNIT_SPEED EQU %00001000    ; unit speed, 1.0 in Q5.3 format
ENGINE_FLAGS_HALTED EQU 0

PATTERN_CMD_NONE EQU 0
PATTERN_CMD_SKIP EQU 1
PATTERN_CMD_JUMP EQU 2

                        RSRESET
SongHeader_speed        RB 1
SongHeader_patterns     RB 1
SongHeader_order        RW 1
SongHeader_SIZEOF       RB 0

updateRowCounter: MACRO
    ld      a, [rowCounter\1]           ; get the row counter for the channel
    or      a                           ; set zero flag
    jr      nz, .decrementRowCounter\1
    ld      a, [chflags]                ; get the channel flags
    set     \1 - 1, a                   ; set new row for the channel
    ld      [chflags], a                ; store it back
    jr      .endRowCounter\1
.decrementRowCounter\1:
    dec     a
    ld      [rowCounter\1], a           ; store the counter
.endRowCounter\1:
ENDM

tbe_begin:
tbeInit::
    push    bc
    push    hl

    ld      bc, tbeWramEnd - tbeWramBegin
    ld      hl, tbeWramBegin
    xor     a
    call    memset

    ;xor     a
    ;ld      [status], a
    ;ld      [timer], a
    ; ld      a, $30
    ; ld      [timerPeriod], a
    ; ld      a, 63
    ; ld      [patternSize], a
    ; ld      [patternCounter], a

    ; ld      a, $0F
    ; ld      [chflags], a

    pop     hl
    pop     bc
    ret


;
; Prepares the engine to play a song from the given pointer
;
tbePlaySong::
    push    hl
    ld      a, [hl+]                ; get the speed
    ld      [timerPeriod], a        ; set the timer period to the speed
    ld      a, [hl+]                ; get and save the pattern count
    ld      [orderCount], a
    ld      a, [hl+]
    ld      [patternSize], a
    ld      a, [hl+]
    ld      [orderTable], a
    ld      [currentOrder], a
    ld      a, [hl+]
    ld      [orderTable + 1], a
    ld      [currentOrder + 1], a
    ld      a, $0F                  ; initialize chflags
    ld      [chflags], a
    ld      a, PATTERN_CMD_JUMP
    ld      [patternCommand], a
    xor     a
    ld      [patternParam], a
    ld      [timer], a              ; reset the timer
    ld      [orderCounter], a

    pop     hl
    ret

tbePlaySfx::
    ret


tbeUpdate::
    ld      a, [status]
    bit     ENGINE_FLAGS_HALTED, a
    ret     nz

    ld      a, [timer]              ; check if timer is active (timer < UNIT_SPEED)
    and     a, %11111000
    jr      nz, .timerNotActive
    ; timer is active (start of new row)
    ; apply the pattern effect (jump/skip)
    ; start the
    ld      a, [patternCommand]
    xor     a, PATTERN_CMD_JUMP     ; check if a == PATTERN_CMD_JUMP
    jr      nz, .skipCmd
    ; jump command
    ld      a, [orderTable]
    ld      c, a
    ld      a, [orderTable + 1]
    ld      b, a
    ; should we error check? buffer overrun will occur if patternParam > orderCount
    ; nah, but if error just halt
    ld      a, [patternParam]
    ld      [orderCounter], a
    ; an order is 4 pointers or 8 bytes, so we need to multiply patternParam by 8
    ld      h, 0                    ; hl = patternParam
    ld      l, a
    add     hl, hl                  ; shift left 3 times
    add     hl, hl
    add     hl, hl
    add     hl, bc                  ; offset the order table

    ld      de, ch1Ptr              ; copy the order to the channel pointers
    ld      b, 0
    ld      c, 8
    call    memcpy

    ld      a, $0F                  ; new row for all channels
    ld      [chflags], a

    xor     a                       ; reset row counters
    ld      [rowCounter1], a
    ld      [rowCounter2], a
    ld      [rowCounter3], a
    ld      [rowCounter4], a

    jr      .updateCmd
.skipCmd:
    xor     a, PATTERN_CMD_SKIP ^ PATTERN_CMD_JUMP
    jr      nz, .noCmd
    ; skip command
    ld      a, [orderCounter]
    ld      b, a
    ld      a, [orderCount]
    xor     a, b
    jr      z, .noIncrement         ; check if the orderCounter == orderCount (last order)
    inc     b                       ; nope, just increment to the next order
    ld      a, [currentOrder]       ; hl = currentOrder
    ld      l, a
    ld      a, [currentOrder + 1]
    ld      h, a
    ld      d, 0
    ld      e, 8
    add     hl, de                  ; point hl to the next one
    ld      a, b
    jr      .updateOrderVars
.noIncrement:                       ; end of order, go back to the start (0)
    ld      a,  [orderTable]        ; currentOrder = orderTable
    ld      l, a
    ld      a, [orderTable + 1]
    ld      h, a
    xor     a                       ; orderCounter = 0
.updateOrderVars:
    ld      [orderCounter], a       ; update orderCounter and currentOrder
    ld      a, l
    ld      [currentOrder], a
    ld      a, h
    ld      [currentOrder + 1], a
    ld      a, [patternParam]
    or      a
    call    nz, fastforward

.updateCmd:
    xor     a
    ld      [patternCommand], a     ; reset pattern command variable
.noCmd:

.timerNotActive:

    ld      a, [timerPeriod]        ; b = timerPeriod
    ld      b, a
    ld      a, [timer]              ; a = timer
    add     a, UNIT_SPEED           ; increment the timer
    ld      c, a                    ; save if timer does not overflow
    sub     a, b                    ; timer -= timerPeriod
    jr      c, .incrementTimer      ; the timer overflowed if z or nc
    jr      .updateTimer
.incrementTimer:
    ld      a, c
.updateTimer:
    ld      [timer], a              ; update timer
    ; if we didn't overflow, we need to decrement the row counters
    jr      c, .exit

    ; since timer >= timerPeriod, we have finished a row (timer overflowed)
    ; update all counters
    updateRowCounter 1
    updateRowCounter 2
    updateRowCounter 3
    updateRowCounter 4

    ld      a, [patternCounter]                     ; check if patternCounter == 0
    or      a
    jr      nz, .decrementPatternCounter
    ; pattern ended, load next one in the order
    ld      a, [patternCommand]                     ; check if patternCommand == 0 (no command set)
    or      a
    jr      nz, .reloadPatternCounter
    ld      a, PATTERN_CMD_SKIP                     ; skip to the next pattern
    ld      [patternCommand], a
    xor     a                                       ; clear the param (so we start at row 0)
    ld      [patternParam], a
.reloadPatternCounter:
    ld      a, [patternSize]                        ; 
    jr      .writePatternCounter
.decrementPatternCounter:
    dec     a
.writePatternCounter:
    ld      [patternCounter], a
    
.exit:
    ret


;
; Adjusts row counters and channel pointers to start playing at a given row. The
; pattern is stepped through without applying effects so that we can start playing
; from a given row
; a - the row to start at
;
fastforward:
    ; TODO
    ret

