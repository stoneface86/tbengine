
; the tester ROM gets its own assembled version instead of using the Demo's
IF !DEF(TBE_PRINT_USAGE)
TBE_PRINT_USAGE EQU 1
ENDC
INCLUDE "tbengine.asm"
