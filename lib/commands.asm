; -----------------------------------------------------------------------------
; Command functions

; command calling convention
;  a - channel index (0, 1, 2 or 3)
;  b - parameter 1 (0 if no parameter)
;  hl - program counter (can be modified by commands)
;  all registers except a and hl can be trashed

cmdFnGoto:
    ret

cmdFnSkip:
    ret

cmdFnHalt:
    ret

; cmdFnCall:
;     ; parameters 1+2 (bc) -> address to call
;     push    af
;     ld      d, h                ; de = current pc
;     ld      e, l
;     ld      hl, ch1Ret          ; hl = return address variable
;     add     a, l                ; offset by channel id
;     ld      l, a
;     ld      a, d
;     ld      [hl+], a            ; store de to the variable
;     ld      [hl], e
;     ld      h, d                ; restore hl
;     ld      l, e
;     pop     af                  ; restore a
;     ; fall-through to jump command

; cmdFnJump:
;     ; parameters 1+2 (bc) -> address to jump to
;     ld      l, b                ; set hl = bc (engine stores hl as the program counter)
;     ld      h, c
;     ret 

; cmdFnRet:
;     ; since the engine will store hl into the program counter variable, we
;     ; just need to set hl to the return address variable
;     ld      hl, ch1Ret          ; hl = return address variable
;     add     a, l
;     ld      a, [hl+]            ; store into registers a and b
;     ld      b, [hl]
;     ld      h, b                ; store back into hl
;     ld      l, a
;     ret

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

