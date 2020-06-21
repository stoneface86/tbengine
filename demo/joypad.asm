
INCLUDE "hardware.inc"

SECTION "joypad", ROM0

debounce: MACRO
    REPT 4                          ; increase if debouncing occurs
    ld      a, [rP1]
    ENDR
ENDM

; pressed: ~prev | current
; released: ~(~prev & current)

joypad_init::
    push    hl
    ld      a, $FF
    ld      hl, wJoypadState
    REPT 3
    ld      [hl+], a
    ENDR
    pop     hl
    ret
    

joypad_read::
    ld      c, $F0                  ; mask to set the upper bits to 1
    ld      a, P1F_GET_BTN          ; read button states
    ld      [rP1], a
    debounce
    or      a, c                    ; mask
    ld      b, a                    ; save for later
    swap    b                       ; button states are in the upper bits
    ld      a, P1F_GET_DPAD         ; read dpad state
    ld      [rP1], a
    debounce
    or      a, c                    ; mask
    and     b                       ; combine dpad states with button states
    ld      b, a                    ; b = current joypad state
    ld      a, [wJoypadState]       ; a = last joypad state
    cpl                             ; compliment and OR with the current
    ld      c, a                    ; c = ~previous
    or      b
    ld      [wJoypadPressed], a     ; store into pressed variable

    ld      a, c                    ; a = ~previous
    and     b                       ; and it with the current state
    cpl                             ; compliment again
    ld      [wJoypadReleased], a    ; store into released
    
    ld      a, b
    ld      [wJoypadState], a       ; store current in wram variable
    ret




SECTION "joypad_wram", WRAM0

; these variables are active LOW, meaning that 0 = down/pressed/released

; layout
; bit 7: start
; bit 6: select
; bit 5: b
; bit 4: a
; bit 3: down
; bit 2: up
; bit 1: left
; bit 0: right


; contains the states of all buttons currently held down
wJoypadState::      DS 1

; contains which buttons were pressed (up -> down) for the current frame
wJoypadPressed::    DS 1

; contains which buttons were released (down -> up) for the current frame
wJoypadReleased::   DS 1
