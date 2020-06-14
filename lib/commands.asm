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
    ld      [patternCommand], a
    ld      a, b
    ld      [patternParam], a
    ret

cmdFnHalt:
    ld      a, [status]             ; set the halted bit in status
    set     ENGINE_FLAGS_HALTED, a
    ld      [status], a
    add     sp, 2                   ; throw away return address
    jp      tbeUpdate.exit          ; stop everything

cmdFnTempo:
    ; parameter 1, a - new speed to set
    ; check if a is >= 8 and < $F8
    cp      a, $8
    ret     c                   ; no-op if new speed < $8 (1.0)
    cp      a, $F8
    ret     nc                  ; no-op if new speed >= $F8 (31.0)
    ld      [timerPeriod], a    ; set the new period
    xor     a                   ; clear the current timer
    ld      [timer], a
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

cmdFnDurationSet:
    ret

