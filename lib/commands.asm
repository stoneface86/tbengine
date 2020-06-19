; -----------------------------------------------------------------------------
; Command functions

; command calling convention
;  a - channel index (0, 1, 2 or 3)
;  b - parameter 1 (0 if no parameter)
;  hl - program counter (can be modified by commands)
;  all registers except a and hl can be trashed

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

_tbe_cmdFnSetEnvelope:
    cmd_ret

_tbe_cmdFnSetTimbre:
    cmd_ret

_tbe_cmdFnSetPanning:
    cmd_ret

_tbe_cmdFnInstrumentSet:
    cmd_ret

_tbe_cmdFnInstrumentOff:
    cmd_ret

_tbe_cmdFnDelayedCut:
    cmd_ret

_tbe_cmdFnDelayedNote:
    cmd_ret

