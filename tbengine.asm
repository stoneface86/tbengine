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
