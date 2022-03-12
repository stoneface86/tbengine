; -----------------------------------------------------------------------------
; tbengine
;
; Trackerboy Music/SFX engine for the gameboy.
;
; Copyright (c) 2020-2021 - stoneface86
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;
; -----------------------------------------------------------------------------

INCLUDE "hardware.inc"

; =============================================================================
;                                                                          ROM0
SECTION "tbengine", ROM0

tbe_begin:

tbe_thumbprint:
    DB "tbengine - sound driver by stoneface"

;
; Initialize the engine. Call this once before using any tbe_ routines
;
tbe_init::
    ret

;
; Locks a channel for music playback. Does nothing if the channel is already
; locked.
;
tbe_lockChannel::
    ret

;
; Unlocks a channel for custom usage. Music will no longer play on this channel
;
tbe_unlockChannel::
    ret

tbe_playSong::
    ret

tbe_playSfx::
    ret

;
; Updates sound registers, call every vblank or periodically
;
tbe_update::
    ret

; seqenum: sequence enumerator
; bytes 0-1: next pointer
; byte 2: remaining
; byte 3: refill (0 for sequences with no loop index)

;
; In:
;  hl - pointer to sequence enumerator
; Out:
;  a - zero if the sequence has a next value, nonzero otherwise
;
seqenum_has::
    inc     hl
    inc     hl
    ld      a, [hl-]
    dec     hl
    ret

;
; In:
;   hl - pointer to sequence enumerator
; Out:
;   b - the next value
;
seqenum_next::
    push    de
    ld      a, [hl+]    ; de = next
    ld      e, a
    ld      a, [hl+]
    ld      d, a
    ld      a, [de]     ; b = *next
    ld      b, a
    dec     [hl]        ; --seqenum->remaining
    inc     de          ; seqenum->next++
    jr      z, .atend
    dec     hl
    ld      a, d
    ld      [hl-], a
    ld      a, e
    ld      [hl], a
    pop     de
    ret
.atend:
    inc     hl
    ld      a, [hl-]    ; a = seqenum->refill
    or      a, a
    jr      nz, .loop
    dec     hl
    dec     hl
    pop     de
    ret
.loop:
    ld      [hl], a     ; seqenum->remaining = seqenum->refill
    ; seqenum->next -= seqenum->refill
    ; subtract de by a, store into the next pointer
    push    bc
    ld      b, 0
    ld      c, a
    ld      a, e
    sub     a, c
    ld      e, a
    ld      a, d
    sbc     a, b
    ld      d, a
    pop     bc

    dec     hl
    ld      [hl-], a
    ld      a, e
    ld      [hl], a
    pop     de
    ret



tbe_end:
IF DEF(TBE_PRINT_USAGE)
    PRINTLN STRFMT("ROM usage: %d bytes", tbe_end - tbe_begin)
ENDC

; =============================================================================
;                                                                         WRAM0
SECTION "tbengine_wram", WRAM0
tbe_wWramBegin:

tbe_wWramEnd:
IF DEF(TBE_PRINT_USAGE)
    PRINTLN STRFMT("RAM usage: %d bytes", tbe_wWramEnd - tbe_wWramBegin)
ENDC
