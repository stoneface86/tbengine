; -----------------------------------------------------------------------------
; Command functions

; command calling convention
;  a - parameter (0 if no parameter)
;  b - channel id (0-3)
;  all registers can be trashed, end routine with cmd_ret macro

cmd_ret: MACRO
    jp      _tbe_parseRow.cmdExit
ENDM

cmd_ret_cc: MACRO
    jp      \1, _tbe_parseRow.cmdExit
ENDM

_tbe_cmdFnGoto:
    ld      b, PATTERN_CMD_JUMP
    jr      _tbe_cmdFnSkip.setPatternCmd

_tbe_cmdFnSkip:
    ld      b, PATTERN_CMD_SKIP
.setPatternCmd:
    ld      [tbe_wPatternParam], a
    ld      a, b
    ld      [tbe_wPatternCommand], a
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
    ret
    ;jp      tbe_update.exit             ; go to end of tbe_update

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
; OPTIMIZE: This might be worth converting to a macro
;
_tbe_setChParam:
    ld      c, a                    ; save parameter into c
    ld      a, b
    add     a, l                    ; offset by channel id
    ld      l, a
    ld      a, c                    ; restore parameter
    ld      [hl], a                 ; store parameter into wram variable
    ret

_tbe_cmdFnSetEnvelope:
    ld      hl, tbe_wEnvelope1          ; load envelope variable
    call    _tbe_setChParam             ; set it in wram
    ld      a, b
    cp      a, 2
    jr      z, .autoRetriggerEnd        ; update retrigger setting (except for CH3)
    ld      h, HIGH(tbe_wNoteControl1)  ; hl = note control for channel
    ld      a, LOW(tbe_wNoteControl1)
    add     a, b
    ld      l, a
    ld      a, c
    and     a, $7                       ; check period for 0
    jr      z, .setAutoRetrigger
    set     ENGINE_NC_AREN, [hl]        ; nonzero period, enable auto retrigger
    jr      .autoRetriggerEnd
.setAutoRetrigger:
    res     ENGINE_NC_AREN, [hl]        ; zero period (constant volume) disable auto retrigger
.autoRetriggerEnd:
    ld      a, [tbe_wCurrentChLocked]
    or      a
    jr      nz, .exit                   ; do not write envelope if channel is unlocked
    ld      a, c                        ; restore envelope setting
    chjumptable
.ch4:
    writeEnvelope 4
    jr      .exit
.ch3:
    writeEnvelope 3
    jr      .exit
.ch2:
    writeEnvelope 2
    jr      .exit
.ch1:
    writeEnvelope 1
.exit:
    cmd_ret

_tbe_cmdFnSetTimbre:
    ld      hl, tbe_wTimbre1            ; load timbre variable
    call    _tbe_setChParam             ; store parameter in variable
    ld      a, [tbe_wCurrentChLocked]
    or      a
    jr      nz, .exit                   ; do not write timbre if channel is unlocked
    ld      a, c
    chjumptable
    ; it is space-efficient to do jr .exit, instead of 4 cmd_ret
.ch4:
    writeTimbre 4
    jr      .exit           
.ch3:
    writeTimbre 3
    jr      .exit
.ch2:
    writeTimbre 2
    jr      .exit
.ch1:
    writeTimbre 1
.exit:
    cmd_ret

_tbe_cmdFnSetPanning:
    chjumptable
.ch4:
    rrca
    ld      b, $77
    jr      .updatePanning
.ch3:
    rrca
    rrca
    ld      b, $BB
    jr      .updatePanning
.ch2:
    rlca
    ld      b, $DD
    jr      .updatePanning
.ch1:
    ld      b, $EE
.updatePanning:
    ; a = new panning setting for channel
    ; b = mask
    ld      c, a
    ld      a, [tbe_wPanning]
    and     a, b
    or      a, c
    ld      [tbe_wPanning], a
    cmd_ret

_tbe_cmdFnInstrumentSet:
    cmd_ret

_tbe_cmdFnInstrumentOff:
    cmd_ret

_delayCmd: MACRO
    ld      c, a                        ; c = delay in frames
    ld      hl, tbe_wNoteControl1       ; set cut enable in note control
    ld      a, l
    add     a, b
    ld      l, a
    set     \1, [hl]
    ld      hl, \2                      ; store c in cut counter
    ld      a, l
    add     a, b
    ld      l, a
    ld      [hl], c
ENDM


_tbe_cmdFnDelayedCut:
    _delayCmd ENGINE_NC_CUT, tbe_wCutCounter1
    cmd_ret

_tbe_cmdFnDelayedNote:
    _delayCmd ENGINE_NC_NOTE, tbe_wNoteCounter1
    cmd_ret

