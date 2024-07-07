;;
;; Sample data for a schedule
;;
;; schedule2 - A schedule of 256 bits, or the maximum allowed. Every bit is set.
;; Note that all channels use the same data stream.
;;

schedule2:
    DB 256 - 1
    DW .ch1, .ch2, .ch3, .ch4

;;     CH1 CH2 CH3 CH4
;; 00   X   X   X   X
;; ..
;; FF   X   X   X   X

.ch1:
.ch2:
.ch3:
.ch4:
REPT 32
    DB $FF
ENDR
