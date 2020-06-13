

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
    ld      [orderPtr], a
    ld      a, [hl+]
    ld      [orderPtr + 1], a
    ld      a, $0F                  ; initialize chflags
    ld      [chflags], a
    ld      a, PATTERN_CMD_JUMP
    ld      [patternCommand], a
    xor     a
    ld      [patternParam], a
    ld      [timer], a              ; reset the timer

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
    ld      a, [orderPtr]
    ld      c, a
    ld      a, [orderPtr + 1]
    ld      b, a
    ; should we error check? buffer overrun will occur if patternParam > orderCount
    ; nah, but if error just halt
    ld      a, [patternParam]
    ; an order is 4 pointers or 8 bytes, so we need to multiply patternParam by 8
    ld      h, 0                    ; hl = patternParam
    ld      l, a
    add     hl, hl                  ; shift left 3 times
    add     hl, hl
    add     hl, hl
    add     hl, bc                  ; offset the order table

    ld      de, ch1Ptr
    ld      b, 0
    ld      c, 8
    call    memcpy

    jr      .updateCmd
.skipCmd:
    xor     a, PATTERN_CMD_SKIP ^ PATTERN_CMD_JUMP
    jr      nz, .noCmd
    ; skip command
.updateCmd:
    xor     a
    ld      [patternCommand], a
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

