
; include everything here for the library

INCLUDE "lib/macros.asm"
INCLUDE "lib/engine.asm"
INCLUDE "lib/commands.asm"
INCLUDE "lib/frequency.asm"
INCLUDE "lib/tables.asm"
INCLUDE "lib/utils.asm"
tbe_end:

INCLUDE "lib/wram.asm"

PRINTT "ROM usage: "
PRINTI tbe_end - tbe_begin
PRINTT "\nRAM usage: "
PRINTI tbe_wWramEnd - tbe_wWramBegin
PRINTT "\n"
