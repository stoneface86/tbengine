; -----------------------------------------------------------------------------
; Command functions

; command calling convention
;  a - parameter (0 if no parameter)
;  b - channel id (0-3)
;  all registers can be trashed, 

cmd_ret: MACRO
    jp      _tbe_parseRow.cmdExit
ENDM

cmd_ret_cc: MACRO
    jp      \1, _tbe_parseRow.cmdExit
ENDM

_tbe_cmdFnGoto:
    ld      a, PATTERN_CMD_JUMP
    jr      _tbe_cmdFnSkip.setPatternCmd

_tbe_cmdFnSkip:
    ld      a, PATTERN_CMD_SKIP
.setPatternCmd:
    ld      [tbe_wPatternCommand], a
    ld      a, b
    ld      [tbe_wPatternParam], a
    cmd_ret

_tbe_cmdFnHalt:
    ld      a, [tbe_wStatus]            ; set the halted bit in status
    set     ENGINE_FLAGS_HALTED, a
    ld      [tbe_wStatus], a
    
    ; TODO: turn sound off

    ; halting occurs immediately
    ; go back to tbe_update using the saved sp
    
    ld      hl, tbe_wStack              ; load the saved sp
    ld      a, [hl+]
    ld      e, a
    ld      a, [hl]
    ld      h, a                        ; hl = sp
    ld      l, e
    ld      sp, hl                      ; update sp
    jp      tbe_update.exit             ; go to end of tbe_update

_tbe_cmdFnTempo:
    ; parameter 1, a - new speed to set
    ; check if a is >= 8 and < $F8
    cp      a, $8
    cmd_ret_cc c                         ; no-op if new speed < $8 (1.0)
    cp      a, $F8
    cmd_ret_cc nc                       ; no-op if new speed >= $F8 (31.0)
    ld      [tbe_wTimerPeriod], a       ; set the new period
    xor     a                           ; clear the current timer
    ld      [tbe_wTimer], a
    cmd_ret

_tbe_cmdFnSfx:
    cmd_ret

_tbe_cmdFnSfxStop:
    cmd_ret

_tbe_cmdFnArp:
    cmd_ret

_tbe_cmdFnPitchSlideUp:
    cmd_ret

_tbe_cmdFnPitchSlideDown:
    cmd_ret

_tbe_cmdFnNoteSlideUp:
    cmd_ret

_tbe_cmdFnNoteSlideDown:
    cmd_ret

_tbe_cmdFnTune:
    cmd_ret

_tbe_cmdFnPortamento:
    cmd_ret

_tbe_cmdFnVibrato:
    cmd_ret

;
; utility function to store envelope/timbre/panning settings in wram
; hl = pointer to setting
; b = channel id
; on return hl points to wRegStatus for the channel id
;
_tbe_setChParam:
    ld      c, a                    ; save parameter into c
    ld      a, b
    add     a, l                    ; offset by channel id
    ld      l, a
    ld      a, c                    ; restore parameter
    ld      [hl], a                 ; store parameter into wram variable

    ld      hl, tbe_wRegStatus1     ; update status
    ld      a, l
    add     a, b
    ld      l, a                    ; hl now points to reg status variable
    ret

_tbe_cmdFnSetEnvelope:
    ld      hl, tbe_wEnvelope1      ; load envelope variable
    call    _tbe_setChParam    
    ;set     1, [hl]                 ; set bit 1 to update envelope on next register write
    ld      a, [hl]
    or      REGSTAT_ENVELOPE | REGSTAT_RETRIGGER
    ld      [hl], a
    cmd_ret

_tbe_cmdFnSetTimbre:
    ld      hl, tbe_wTimbre1
    call    _tbe_setChParam
    set     0, [hl]
    cmd_ret

_tbe_cmdFnSetPanning:
    ld      hl, tbe_wPanning1
    call    _tbe_setChParam
    set     2, [hl]

;     ld      c, $EE                  ; bit mask to clear CH1's panning setting
;     ld      e, b                    ; save b into e
;     inc     b
; .loop:
;     dec     b
;     jr      z, .loopend             ; stop when b == 0
;     rlc     c                       ; rotate mask left
;     rlca                            ; rotate new setting left
;     jr      .loop
; .loopend:
;     ld      d, a
;     ld      a, [tbe_wPanning]
;     and     a, c
;     or      a, d
;     ld      [tbe_wPanning], a

;     ld      hl, tbe_wRegStatus1
;     ld      a, l
;     add     a, e
;     ld      l, a
;     set     2, [hl]
;     ld      b, e
    cmd_ret

_tbe_cmdFnInstrumentSet:
    cmd_ret

_tbe_cmdFnInstrumentOff:
    cmd_ret

_tbe_cmdFnDelayedCut:
    cmd_ret

_tbe_cmdFnDelayedNote:
    cmd_ret

