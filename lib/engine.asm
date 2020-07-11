

IF DEF(TBE_ROM0)
SECTION "tbengine", ROM0
ELSE
SECTION "tbengine", ROMX
ENDC

INCLUDE "hardware.inc"
INCLUDE "tbengine.inc"

UNIT_SPEED EQU %00001000    ; unit speed, 1.0 in Q5.3 format
ENGINE_FLAGS_HALTED EQU 0
ENGINE_FLAGS_PANNING EQU 1  ; if set, update music panning

; chflags bit fields
; rowen means that a new row from music data is to be parsed
; if a channel is locked, music will play on it
; lock = 0: locked, music
; lock = 1: unlocked, sound effect / custom
ENGINE_CHFLAGS_ROWEN1   EQU 0   ; bit 0: CH1 row enable (if set)
ENGINE_CHFLAGS_ROWEN2   EQU 1   ; bit 1: CH2 row enable (if set)
ENGINE_CHFLAGS_ROWEN3   EQU 2   ; bit 2: CH3 row enable (if set)
ENGINE_CHFLAGS_ROWEN4   EQU 3   ; bit 3: CH4 row enable (if set)
ENGINE_CHFLAGS_LOCK1    EQU 4   ; bit 4: CH1 lock status, unlocked when set
ENGINE_CHFLAGS_LOCK2    EQU 5   ; bit 5: CH2 lock status, unlocked when set
ENGINE_CHFLAGS_LOCK3    EQU 6   ; bit 6: CH3 lock status, unlocked when set
ENGINE_CHFLAGS_LOCK4    EQU 7   ; bit 7: CH4 lock status, unlocked when set

ENGINE_DEFAULT_ENVELOPE EQU $F0

; NoteControl (NC) flags
ENGINE_NC_CUT       EQU 0   ; cut enable
ENGINE_NC_NOTE      EQU 1   ; note trigger enable
ENGINE_NC_PLAYING   EQU 2   ; playing status
ENGINE_NC_AREN      EQU 3   ; AREN: Auto Retrigger ENable
ENGINE_NC_TRIGGER   EQU 4   ; if set, retrigger channel

; channel retriggers when:
; * note triggers when the envelope is decreasing/increasing
; * the envelope is changed
; * the sweep register is set (CH1 only)

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

updateFreq: MACRO
    ld      a, [tbe_wNoteControl\1]
    bit     ENGINE_NC_PLAYING, a
    jr      z, .updateFreqEnd\1             ; do nothing if we aren't playing
    ld      d, 0
    bit     ENGINE_NC_TRIGGER, a            ; retrigger?
    jr      z, .notrigger\1
    ld      d, $80                          ; yes, d = $80
    res     ENGINE_NC_TRIGGER, a            ; reset trigger flag
    ld      [tbe_wNoteControl\1], a
.notrigger\1:
    ld      hl, tbe_wFreq\1                 ; hl = channel frequency variable
    ld      a, [hl+]                        ; write lower frequency bits
    ld      [rNR\13], a
    ld      a, [hl]
    or      a, d                            ; add retrigger bit
    ld      [rNR\14], a                     ; write upper frequency bits
.updateFreqEnd\1
ENDM

setPanningStatus: MACRO
    ld      a, [tbe_wStatus]
    set     ENGINE_FLAGS_PANNING, a
    ld      [tbe_wStatus], a
ENDM

; =========================================================================== ;
; Exported Routines                                                           ;
; =========================================================================== ;

tbe_begin:

tbe_thumbprint:
    DB "tbengine - sound driver by stoneface"
; TODO put version info here as well

tbe_init::
    push    bc
    push    hl

    ld      bc, tbe_wWramEnd - tbe_wWramBegin
    ld      hl, tbe_wWramBegin
    xor     a
    call    _tbe_memset                     ; zero all wram variables

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
    ;   CH1  CH2  CH3  CH4  ; setting
    ; ----------------------;-------------
    DB  $F0, $F0, $00, $F0  ; Envelope
    DB  $00, $00, $20, $00  ; Timbre
    DB  $00, $00, $00, $00  ; NoteControl
    DB  $00, $00, $00, $00  ; Note
    DB  $00, $00, $00, $00  ; NoteCounter
    DB  $00, $00, $00, $00  ; CutCounter
    ; frequency
    DW  $0000, $0000, $0000, $0000
    ; panning
    DB  $FF, $00
    
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

    ; for each locked channel, re-write settings
    ld      a, [tbe_wChflags]
    ld      e, a
    bit     ENGINE_CHFLAGS_LOCK1, e
    call    z, _tbe_reloadChannel.ch1
    bit     ENGINE_CHFLAGS_LOCK2, e
    call    z, _tbe_reloadChannel.ch2
    bit     ENGINE_CHFLAGS_LOCK3, e
    call    z, _tbe_reloadChannel.ch3
    bit     ENGINE_CHFLAGS_LOCK4, e
    call    z, _tbe_reloadChannel.ch4

    ld      hl, tbe_wStatus
    set     ENGINE_FLAGS_PANNING, [hl]

    pop     hl
    pop     de
    pop     bc
    ret

;
; Reloads a channel with the current music settings
;
_tbe_reloadChannel:
    ;chjumptable
.ch4:
    reload 4
    ret
.ch3:
    reload 3
    ret
.ch2:
    reload 2
    ret
.ch1:
    reload 1
    ret

lockChannel: MACRO
    ld      a, [tbe_wChflags]
    bit     ENGINE_CHFLAGS_LOCK\1, a
    ret     z
    res     ENGINE_CHFLAGS_LOCK\1, a
    ld      [tbe_wChflags], a
    jr      _tbe_reloadChannel.ch\1
ENDM

;
; Force lock a channel. Music will resume playing on this channel. Sound
; registers are reloaded with music settings. If a sound effect was playing on
; this channel, it is stopped. (sound effects automatically lock their channel
; on finish). This routine does nothing if the channel is already locked.
;
tbe_lockChannel::
    chjumptable
.ch4:
    lockChannel 4
.ch3:
    lockChannel 3
.ch2:
    lockChannel 2
.ch1:
    lockChannel 1

;
; Unlock a channel for access to sound registers. The engine will no longer
; update registers for the specified channel when playing music. Warning: using
; this routine does not enforce exclusive access, as the current song is able to
; lock/schedule a sound effect. If you require exclusive access, make sure the
; current song will not lock/unlock the channel (sfx and sfxStop commands)
;
tbe_unlockChannel::
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


;
; Prepares the engine to play a song from the given pointer
; TODO: rewrite using a song id parameter instead of pointer
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
    cp      a, PATTERN_CMD_JUMP             ; check if a == PATTERN_CMD_JUMP
    jr      nz, .skipCmd
    ; jump command
    ld      a, [tbe_wPatternParam]
    call    _tbe_gotoOrder
    jr      .updateCmd
.skipCmd:
    cp      a, PATTERN_CMD_SKIP
    jr      nz, .noCmd
    ; skip command
    ld      a, [tbe_wOrderCount]
    ld      b, a
    ld      a, [tbe_wOrderCounter]
    cp      a, b
    jr      z, .noIncrement                 ; check if the orderCounter == orderCount (last order)
    inc     a                               ; nope, just increment to the next order
    jr      .orderCountDone
.noIncrement:
    xor     a
.orderCountDone:
    call    _tbe_gotoOrder
    ld      a, [tbe_wPatternParam]
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
    
    ld      hl, tbe_wNoteControl4               ; hl = note control variable
    ld      b, 4                                ; b = loop counter
    ld      c, $11 << ENGINE_CHFLAGS_ROWEN4     ; c = lock mask / panning mask
.loopNoteControl:
    ld      a, [tbe_wChflags]
    and     a, c
    jp      nz, .endNoteControl                 ; do nothing if channel is unlocked
    bit     ENGINE_NC_NOTE, [hl]
    jr      z, .nonote
    ld      d, HIGH(tbe_wNoteCounter1)
    ld      a, LOW(tbe_wNoteCounter1 - 1)
    add     a, b
    ld      e, a
    ld      a, [de]
    or      a
    jr      nz, .decNoteCounter
    ; note trigger
ASSERT FATAL, tbe_wNote1 - tbe_wNoteControl1 == 4, "note and note control vars not nearby"
    ld      a, 4
    add     a, l
    ld      e, a
    ld      d, h
    ld      a, [de]                             ; a = note index
    push    hl
    bit     ENGINE_CHFLAGS_LOCK4, c             ; are we CH4?
    jr      z, .freqlookup
    ld      hl, tbe_dNoiseTable
    ld      d, 0
    ld      e, a
    add     hl, de
    ld      a, [hl]                         ; load the noise byte
    ld      d, a
    ld      a, [tbe_wTimbre4]               ; combine with timbre (step-width)
    or      a, d
    ld      [tbe_wFreq4], a                 ; store in the frequency variable
    jr      .lookupDone
.freqlookup:
    ld      h, HIGH(tbe_dNoteTable)
    ld      l, a
    ld      a, LOW(tbe_dNoteTable)
    add     a, l
    add     a, l
    ld      l, a
    ld      d, HIGH(tbe_wFreq1)
    ld      e, b
    dec     e
    ld      a, LOW(tbe_wFreq1)
    add     a, e
    add     a, e
    ld      e, a
    ld      a, [hl+]
    ld      [de], a
    inc     e
    ld      a, [hl]
    ld      [de], a
.lookupDone:
    pop     hl
    ld      a, [hl]
    res     ENGINE_NC_NOTE, a
    set     ENGINE_NC_PLAYING, a
STATIC_ASSERT FATAL, ENGINE_NC_TRIGGER - ENGINE_NC_AREN == 1, "cannot use rlca here"
    ld      d, a                            ; copy AREN bit into TRIGGER bit
    rlca
    and     a, 1 << ENGINE_NC_TRIGGER
    or      a, d
    ld      [hl], a
    ld      a, [tbe_wPanningMask]
    or      a, c
    ld      [tbe_wPanningMask], a
    setPanningStatus
    jr      .nonote
.decNoteCounter:
    dec     a
    ld      [de], a
.nonote:
    bit     ENGINE_NC_CUT, [hl]
    jr      z, .nocut
    ld      d, HIGH(tbe_wCutCounter1)
    ld      a, LOW(tbe_wCutCounter1 - 1)
    add     a, b
    ld      e, a
    ld      a, [de]
    or      a
    jr      nz, .decCutCounter
    ; note cut
    ld      a, [hl]
    and     a, LOW(~((1 << ENGINE_NC_CUT) | (1 << ENGINE_NC_PLAYING)))
    ld      [hl], a
    ld      a, c
    cpl                                         ; cut, so invert bits to clear
    ld      d, a
    ld      a, [tbe_wPanningMask]
    and     a, d                                ; clear bits
    ld      [tbe_wPanningMask], a
    setPanningStatus
    jr      .nocut
.decCutCounter:
    dec     a
    ld      [de], a
.nocut:
    ; ld      d, [hl]
    ; bit     ENGINE_NC_PLAYING, d
    ; jr      z, .endNoteControl
    ; ; TODO update frequency

.endNoteControl:
    rrc     c
    dec     l
    dec     b
    jp      nz, .loopNoteControl

    ld      hl, tbe_wStatus                 ; check status if panning bit is set
    ld      a, [hl]
    bit     ENGINE_FLAGS_PANNING, a
    jr      z, .panningUpdateEnd
    res     ENGINE_FLAGS_PANNING, a         ; reset panning bit
    ld      [hl], a                         ; update status
    call    _tbe_writePanning               ; write panning to NR51
.panningUpdateEnd:

    updateFreq 1
    updateFreq 2
    updateFreq 3
    updateFreq 4


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
;    jr      nz, .reloadPatternCounter
    ret     nz
    ld      a, PATTERN_CMD_SKIP                 ; skip to the next pattern
    ld      [tbe_wPatternCommand], a
    xor     a                                   ; clear the param (so we start at row 0)
    ld      [tbe_wPatternParam], a
;.reloadPatternCounter:
;    ld      a, [tbe_wPatternSize] 
;    jr      .writePatternCounter
.decrementPatternCounter:
    dec     a
;.writePatternCounter:
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

ASSERT FATAL, (tbe_wCutCounter1 - tbe_wNoteCounter1) == 4, "Note and cut counters not aligned"
    ld      hl, tbe_wNoteCounter1   ; reset note and cut counters
    ld      a, l
    add     a, b
    ld      l, a
    xor     a
    ld      [hl], a                 ; clear note counter
    inc     l
    inc     l
    inc     l
    inc     l
    ld      [hl], a                 ; clear cut counter

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
    push    bc
    jp      hl                      ; goto command
.cmdExit:                           ; command will return here when finished
    pop     bc
    pop     hl
    

    jr      .getbyte                ; keep going
.notebyte:
    ld      c, a                    ; c = note index, save for later
    
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

    ld      hl, tbe_wNoteControl1   ; hl = note control flags
    ld      a, l
    add     a, b
    ld      l, a
    ld      a, c                    ; restore note index
    cp      a, NOTE_CUT             ; check for a cut
    jr      nz, .notcut
    ; schedule note cut
    set     ENGINE_NC_CUT, [hl]     ; set cut enable
    jr      .endnote
.notcut:
    cp      a, NOTE_HOLD            ; check for hold
    jr      z, .endnote             ; if hold do nothing
    ; schedule note trigger
    set     ENGINE_NC_NOTE, [hl]    ; set note enable
    ld      hl, tbe_wNote1          ; set note variable
    ld      a, l
    add     a, b
    ld      l, a
    ld      [hl], c
.endnote:
    pop     de
    pop     bc
    ret

;
; Setups up channel pointers to a given index in the order table
; a: order index
;
_tbe_gotoOrder:
    ld      [tbe_wOrderCounter], a
    ld      d, a

    ld      a, [tbe_wOrderTable]            ; bc = order table
    ld      c, a
    ld      a, [tbe_wOrderTable + 1]
    ld      b, a

    ; an order is 4 pointers or 8 bytes, so we need to multiply patternParam by 8
    ld      h, 0                            ; hl = order index
    ld      l, d
    add     hl, hl                          ; shift left 3 times
    add     hl, hl
    add     hl, hl
    add     hl, bc                          ; offset the order table
    ld      de, tbe_wCh1Ptr                 ; copy the order to the channel pointers
    ld      b, 0
    ld      c, 8
    call    _tbe_memcpy

    ld      a, [tbe_wChflags]
    or      a, $0F                          ; new row for all channels
    ld      [tbe_wChflags], a

    xor     a                               ; reset row counters and durations
    ld      hl, tbe_wRowCounter1
    REPT 8
    ld      [hl+], a
    ENDR

    ld      a, [tbe_wPatternSize]
    ld      [tbe_wPatternCounter], a

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

