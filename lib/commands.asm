; -----------------------------------------------------------------------------
; Command functions

; command calling convention
;  a - channel index (0, 1, 2 or 3)
;  b - parameter 1 (0 if no parameter)
;  hl - program counter (can be modified by commands)
;  all registers except a and hl can be trashed

cmdFnGoto:
    ld      a, PATTERN_CMD_JUMP
    jr      cmdFnSkip.setPatternCmd

cmdFnSkip:
    ld      a, PATTERN_CMD_SKIP
.setPatternCmd:
    ld      [wPatternCommand], a
    ld      a, b
    ld      [wPatternParam], a
    ret

cmdFnHalt:
    ld      a, [wStatus]            ; set the halted bit in status
    set     ENGINE_FLAGS_HALTED, a
    ld      [wStatus], a
    
    ; TODO: turn sound off

    ; halting occurs immediately
    ; go back to tbe_update using the saved sp
    
    ld      hl, wStack              ; load the saved sp
    ld      a, [hl+]
    ld      e, a
    ld      a, [hl]
    ld      h, a                    ; hl = sp
    ld      l, e
    ld      sp, hl                  ; update sp
    jp      tbe_update.exit         ; go to end of tbe_update

cmdFnTempo:
    ; parameter 1, a - new speed to set
    ; check if a is >= 8 and < $F8
    cp      a, $8
    ret     c                       ; no-op if new speed < $8 (1.0)
    cp      a, $F8
    ret     nc                      ; no-op if new speed >= $F8 (31.0)
    ld      [wTimerPeriod], a       ; set the new period
    xor     a                       ; clear the current timer
    ld      [wTimer], a
    ret

cmdFnSfx:
    ret

cmdFnSfxStop:
    ret

cmdFnArp:
    ret

cmdFnPitchSlideUp:
    ret

cmdFnPitchSlideDown:
    ret

cmdFnNoteSlideUp:
    ret

cmdFnNoteSlideDown:
    ret

cmdFnTune:
    ret

cmdFnPortamento:
    ret

cmdFnVibrato:
    ret

cmdFnSetEnvelope:
    ret

cmdFnSetTimbre:
    ret

cmdFnSetPanning:
    ret

cmdFnInstrumentSet:
    ret

cmdFnInstrumentOff:
    ret

cmdFnDelayedCut:
    ret

cmdFnDelayedNote:
    ret

