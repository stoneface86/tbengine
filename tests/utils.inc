
DEF __AssertCounter = 1

;;
;; Asserts that a memory address holds the given 8-bit value (byte).
;; Parameters:
;;  \1 - The address to check
;;  \2 - The immediate value to test for
;;
MACRO AssertMemoryB
    ld      a, [\1]
    cp      a, \2
    jr      z, .passed\@
    ld      a, __AssertCounter
    ret
.passed\@:
DEF __AssertCounter += 1
ENDM

;;
;; Asserts that a memory address holds the given 16-bit value (word).
;; Parameters:
;;  \1 - The address to check
;;  \2 - The immediate value to test for
;;
MACRO AssertMemoryW
    ld      a, [\1]
    cp      a, LOW(\2)
    jr      nz, .failed\@
    ld      a, [\1 + 1]
    cp      a, HIGH(\2)
    jr      z, .passed\@
.failed\@:
    ld      a, __AssertCounter
    ret
.passed\@:
DEF __AssertCounter += 1
ENDM

;;
;; Asserts a register has a given value
;; Parameters:
;;  \1 - The register to check (a,b,c,d,e,h,l,bc,de,hl)
;;  \2 - The immediate value to test for
;;
MACRO AssertReg
DEF REG EQUS STRLWR("\1")
IF "{REG}" == "bc" || "{REG}" == "de" || "{REG}" == "hl"
; register pair
    ld      a, LOW(\1)
    cp      a, LOW(\2)
    jr      nz, .failed\@
    ld      a, HIGH(\1)
    cp      a, HIGH(\2)
    jr      z, .passed\@
ELSE
; single register
IF "{REG}" != "a"
    ld      a, \1
ENDC
    cp      a, \2
    jr      z, .passed\@
ENDC
.failed\@:
    ld      a, __AssertCounter
    ret
.passed\@:
DEF __AssertCounter += 1
PURGE REG
ENDM

;;
;; Asserts that a flag is set or reset.
;; Parameters:
;;  \1 - flag to test (c,z,nc,nz)
MACRO AssertFlag
    jr      \1, .passed\@
    ld      a, __AssertCounter
    ret
.passed\@:
DEF __AssertCounter += 1
ENDM

MACRO AssertReset
DEF __AssertCounter = 1
ENDM
