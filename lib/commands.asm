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

; Stack contents at time of command function call
;           |                 |
;           | ???             |
;        +4 +-----------------+
;           | saved bc        |
;        +2 +-----------------+
;           | channel pointer |
; sp =>  +0 +-----------------+
;           | ???             |

CHPTR_OFFSET EQU 2

_tbe_cmdFnJump:
    ld      e, a
    pop     hl
    ld      a, [hl]
    ld      d, a
    push    de
    cmd_ret

_tbe_cmdFnCall:
; call has two parameters (2 bytes for the call address)
    ld      e, a                        ; parameter is low byte of call address
    pop     hl                          ; get channel pointer from the stack
    ld      a, [hl+]                    ; hl is now the return address
    ld      d, a                        ; de = call address
    push    de                          ; set new channel pointer
    ld      d, HIGH(tbe_wReturn1)       ; de = return address variable
    ld      a, LOW(tbe_wReturn1)
    add     a, b
    add     a, b
    ld      e, a
    ld      a, l                        ; write the return address (hl -> [de])
    ld      [de], a
    inc     de
    ld      a, h
    ld      [de], a
    cmd_ret

_tbe_cmdFnRet:
    ld      h, HIGH(tbe_wReturn1)
    ld      a, LOW(tbe_wReturn1)
    add     a, b
    add     a, b
    ld      l, a
    ld      a, [hl+]                    ; bc = return address
    ld      b, [hl]
    ld      c, a
    pop     de                          ; throw away current channel pointer
    push    bc                          ; update with return address
    cmd_ret

_tbe_cmdFnLoopBegin:
    ld      hl, sp + 0
    ld      d, HIGH(tbe_wLoopReturn1)
    ld      a, LOW(tbe_wLoopReturn1)
    add     a, b
    add     a, b
    ld      e, a
    ld      a, [hl+]
    ld      [de], a
    inc     de
    ld      a, [hl]
    ld      [de], a
    cmd_ret

_tbe_cmdFnLoopEnd:

    ; three outcomes of this command:
    ; [1]: A loop is started, branch taken
    ; [2]: A loop exists, branch taken
    ; [3]: A loop finishes, branch not taken
    ; branch taken = channel pointer gets set to the loop address
    ; branch not taken = channel pointer is incremented by 2 (after loop address)

    ; this command has an extra parameter, the loop address
    ld      c, a                        ; backup parameter (loop count)
    
    ; if we are not in a loop, set one up
    ; otherwise, decrement counter and do branch
    ld      h, HIGH(tbe_wLoopCounter1)
    ld      a, LOW(tbe_wLoopCounter1)
    add     a, b
    ld      l, a
    ld      a, [hl]                     ; a = loop counter
    or      a
    jr      z, .loopNotSet              ; if a is zero then there is no loop currently
    ; in a loop, decrement and do branch
    dec     a
    jr      nz, .branch
    ; [3] counter is zero, stop looping (do not take branch)
    ld      [hl], a                     ; update counter
    ;pop     hl                          ; advance channel pointer by 2 (throw away loop address)
    ;inc     hl                          ; there's probably a better way of doing this
    ;inc     hl
    ;push    hl
    cmd_ret
.loopNotSet:
    ; [1]
    ld      a, c
.branch:
    ; loop, take branch
    ld      [hl], a                     ; update counter
    ld      hl, sp + 0
    ld      d, HIGH(tbe_wLoopReturn1)
    ld      a, LOW(tbe_wLoopReturn1)
    add     a, b
    add     a, b
    ld      e, a
    ld      a, [de]
    inc     de
    ld      [hl+], a
    ld      a, [de]
    ld      [hl], a
    
    ; pop     hl
    ; ld      a, [hl+]
    ; ld      e, a
    ; ld      a, [hl+]
    ; ld      d, a                        ; de = loop address
    ; push    de                          ; update channel pointer
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
    ; don't check if the speed is in range, this will be done statically
    ld      [tbe_wTimerPeriod], a       ; set the new period
    xor     a                           ; clear the current timer
    ld      [tbe_wTimer], a
    cmd_ret

_tbe_cmdFnSfx:
    cmd_ret

_tbe_cmdFnLock:
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

_tbe_cmdFnVibratoDelay:
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

_tbe_cmdFnSetInstrument:
    cmd_ret


_tbe_dTimbreTable:
    DB $00, $00, $00, $00
    DB $40, $40, $20, $08
    DB $80, $80, $40, $08
    DB $C0, $C0, $60, $08

_tbe_cmdFnTimbre0:
    ld      de, _tbe_dTimbreTable
    jr      _tbe_cmdFnTimbre3.setTimbre

_tbe_cmdFnTimbre1:
    ld      de, _tbe_dTimbreTable + 4
    jr      _tbe_cmdFnTimbre3.setTimbre

_tbe_cmdFnTimbre2:
    ld      de, _tbe_dTimbreTable + 8
    jr      _tbe_cmdFnTimbre3.setTimbre

_tbe_cmdFnTimbre3:
    ld      de, _tbe_dTimbreTable + 12
.setTimbre:
    ld      h, 0
    ld      l, b
    add     hl, de
    ld      a, [hl]
    ld      hl, tbe_wTimbre1            ; load timbre variable
    call    _tbe_setChParam             ; store parameter in variable
    ld      c, a
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

_tbe_cmdFnPanLeft:
    ld      a, $10
    jr      _tbe_cmdFnPanMiddle.setPanning

_tbe_cmdFnPanRight:
    ld      a, $01
    jr      _tbe_cmdFnPanMiddle.setPanning

_tbe_cmdFnPanMiddle:
    ld      a, $11
.setPanning:
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
    ld      hl, tbe_wStatus
    set     ENGINE_FLAGS_PANNING, [hl]
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

