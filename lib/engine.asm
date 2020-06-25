

IF DEF(TBE_ROM0)
SECTION "tbengine", ROM0
ELSE
SECTION "tbengine", ROMX
ENDC

INCLUDE "hardware.inc"

UNIT_SPEED EQU %00001000    ; unit speed, 1.0 in Q5.3 format
ENGINE_FLAGS_HALTED EQU 0

ENGINE_CHFLAGS_ROWEN1   EQU 0 ; bit 0: CH1 row enable (if set)
ENGINE_CHFLAGS_ROWEN2   EQU 1 ; bit 1: CH2 row enable (if set)
ENGINE_CHFLAGS_ROWEN3   EQU 2 ; bit 2: CH3 row enable (if set)
ENGINE_CHFLAGS_ROWEN4   EQU 3 ; bit 3: CH4 row enable (if set)
ENGINE_CHFLAGS_LOCK1    EQU 4 ; bit 4: CH1 lock status
ENGINE_CHFLAGS_LOCK2    EQU 5 ; bit 5: CH2 lock status
ENGINE_CHFLAGS_LOCK3    EQU 6 ; bit 6: CH3 lock status
ENGINE_CHFLAGS_LOCK4    EQU 7 ; bit 7: CH4 lock status

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
    ld      a, [tbe_wRowCounter\1]          ; get the row counter for the channel
    or      a                               ; set zero flag
    jr      nz, .decrementRowCounter\1
    ld      a, [tbe_wChflags]               ; get the channel flags
    set     \1 - 1, a                       ; set new row for the channel
    ld      [tbe_wChflags], a               ; store it back
    jr      .endRowCounter\1
.decrementRowCounter\1:
    dec     a
    ld      [tbe_wRowCounter\1], a          ; store the counter
.endRowCounter\1:
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
    ; status
    DB  $0F, $0F, $0F, $0F
    ; envelope
    DB  $F0, $F0, $00, $F0
    ; timbre
    DB  $00, $00, $20, $00
    ; panning
    DB  $03, $03, $03, $03
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


tbe_update::
    ld      a, [tbe_wStatus]
    bit     ENGINE_FLAGS_HALTED, a
    ret     nz

    ld      [tbe_wStack], sp

    ld      a, [tbe_wTimer]                 ; check if timer is active (timer < UNIT_SPEED)
    and     a, %11111000
    jp      nz, .timerNotActive
    ; timer is active (start of new row)
    ; apply the pattern effect (jump/skip)
    ; start the
    ld      a, [tbe_wPatternCommand]
    xor     a, PATTERN_CMD_JUMP             ; check if a == PATTERN_CMD_JUMP
    jr      nz, .skipCmd
    ; jump command
    ld      a, [tbe_wOrderTable]
    ld      c, a
    ld      a, [tbe_wOrderTable + 1]
    ld      b, a
    ; should we error check? buffer overrun will occur if patternParam > orderCount
    ; nah, but if error just halt
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
    bit     ENGINE_CHFLAGS_ROWEN1, c
    call    nz, _tbe_parseRow
    inc     b
    bit     ENGINE_CHFLAGS_ROWEN2, c
    call    nz, _tbe_parseRow
    inc     b
    bit     ENGINE_CHFLAGS_ROWEN3, c
    call    nz, _tbe_parseRow
    inc     b
    bit     ENGINE_CHFLAGS_ROWEN4, c
    call    nz, _tbe_parseRow
    ld      a, c
    and     a, $F0                          ; reset all rowen flags
    ld      [tbe_wChflags], a

.timerNotActive:

    ld      a, [tbe_wTimerPeriod]           ; b = timerPeriod
    ld      b, a
    ld      a, [tbe_wTimer]                 ; a = timer
    add     a, UNIT_SPEED                   ; increment the timer
    ld      c, a                            ; save if timer does not overflow
    sub     a, b                            ; timer -= timerPeriod
    jr      c, .incrementTimer              ; the timer overflowed if z or nc
    jr      .updateTimer
.incrementTimer:
    ld      a, c
.updateTimer:
    ld      [tbe_wTimer], a                 ; update timer
    ; if we didn't overflow, we need to decrement the row counters
    jr      c, .exit

    ; since timer >= timerPeriod, we have finished a row (timer overflowed)
    ; update all counters
    updateRowCounter 1
    updateRowCounter 2
    updateRowCounter 3
    updateRowCounter 4

    ld      a, [tbe_wPatternCounter]            ; check if patternCounter == 0
    or      a
    jr      nz, .decrementPatternCounter
    ; pattern ended, load next one in the order
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
    
.exit:
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

; generate_templates: MACRO

; _tbe_writeTimbre\1:
;     ld      a, [tbe_wTimbre\1]
; IF \1 == 1
;     ld      [rNR11], a
; ELIF \1 == 2
;     ld      [rNR21], a
; ELIF \1 == 3
;     ld      [rNR32], a
; ELSE
;     ld      d, a
;     ld      a, [rNR43]
;     res     3, a
;     or      a, d
;     ld      [rNR43], a
; ENDC
;     ret

; _tbe_writeEnvelope\1::
; IF \1 == 3
;     ; wave channel envelope is the waveform id
;     ld      hl, tbe_waveTable           ; lookup the waveform
;     ld      b, 0                        ; bc = wave id
;     ld      c, a
;     add     hl, bc                      ; offset table by id
;     add     hl, bc
;     ld      a, [hl+]                    ; get pointer at id
;     ld      c, a
;     ld      a, [hl]
;     ld      h, a
;     ld      l, c
;     xor     a                           ; CH3 sound off
;     ld      [rNR30], a

;     ld      b, 16                       ; copy to wave ram
;     ld      c, _AUD3WAVERAM - $FF00
;     call    _tbe_iomemcpy

;     ld      a, $80                      ; CH3 sound on
;     ld      [rNR30], a
; ELSE
;     ld      [rNR\12], a
; ENDC
;     ret

; _tbe_writePanning\1:
;     ret

; _tbe_writeRegisters\1:
;     ld      a, [tbe_wRegStatus\1]       ; get our status
;     or      a
;     ret     z                           ; exit early if nothing to do
;     ld      e, a                        ; keep the status in e
;     bit     REGSTAT_TIMBRE, e           ; do we need to write timbre?
;     jr      z, .timbre_done
; .timbre_done:
;     bit     REGSTAT_ENVELOPE, e
;     jr      z, .envelope_done
;     ld      a, [tbe_wTimbre\1]
;     IF \1 == 1
;         ld      [rNR11], a
;     ELIF \1 == 2
;         ld      [rNR21], a
;     ELIF \1 == 3
;         ld      [rNR32], a
;     ELSE
;         ld      d, a
;         ld      a, [rNR43]
;         res     3, a
;         or      a, d
;         ld      [rNR43], a
;     ENDC
; .envelope_done:
;     bit     REGSTAT_PANNING, e
;     jr      z, .panning_done
; .panning_done:
; .retrigger_done:
;     bit     REGSTAT_ENVELOPE, e
;     call    nz, _tbe_writeEnvelope\1
;     bit     REGSTAT_PANNING, e
;     call    nz, _tbe_writePanning\1


;     ret

; ENDM

; ; template code generation for all channels
;     generate_templates 1
;     generate_templates 2
;     generate_templates 3
;     generate_templates 4
    

;
; a - timbre to write
; b - channel id
;
; _tbe_writeTimbre:

; .ch1:
;     ld      c, rNR11 - $FF00
;     jr      .write
; .ch2:
;     ld      c, rNR21 - $FF00
;     jr      .write
; .ch3:
;     ld      c, rNR32 - $FF00
;     jr      .write
; .ch4:
;     ld      c, rNR43 - $FF00
;     ld      d, a
;     ld      a, [c]
;     res     3, a
;     or      a, d
; .write:
;     ld      [c], a
;     ret

;
; Adjusts row counters and channel pointers to start playing at a given row. The
; pattern is stepped through without applying effects so that we can start playing
; from a given row
; a - the row to start at
;
_tbe_fastforward:
    ; TODO implement fast forward
    ret

