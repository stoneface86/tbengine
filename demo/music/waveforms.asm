
SECTION "wavetable", ROM0

tbe_waveTable::
    DW wave_triangle
    DW wave_square
    DW wave_saw
    DW wave_curved
    DW wave_pkmn5

wave_triangle:
    DB $01, $23, $45, $67, $89, $AB, $CD, $EF, $FE, $DC, $BA, $98, $76, $54, $32, $10

; ~60% duty
wave_square:
    DB $00, $00, $00, $00, $00, $00, $0A, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA

; double period, same frequency range as CH1/CH2
wave_saw:
    DB $01, $23, $45, $67, $89, $AB, $CD, $EF, $01, $23, $45, $67, $89, $AB, $CD, $EF

wave_curved:
    DB $02, $46, $8A, $CE, $EF, $FF, $FE, $EE, $DD, $CB, $A9, $87, $65, $43, $22, $11

wave_pkmn5:
    DB $00, $11, $22, $33, $44, $33, $22, $11, $FF, $EE, $CC, $AA, $88, $AA, $CC, $EE
