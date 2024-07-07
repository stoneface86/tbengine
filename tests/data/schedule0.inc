;;
;; Sample data for a schedule
;;
;; schedule0 - a schedule of 9 bits, separate data streams.
;;

schedule0:
    DB 9 - 1
    DW .ch1, .ch2, .ch3, .ch4

;;     CH1 CH2 CH3 CH4
;; 00   X       X
;; 01   X       X
;; 02   X       X
;; 03   X       X
;; 04   X   X
;; 05   X   X
;; 06   X   X
;; 07   X   X
;; 08   X   X
;; 09   X       X

.ch1:
    DB %1111_1111, %1
.ch2:
    DB %1111_0000, %0
.ch3:
    DB %0000_1111, %1
.ch4:
    DB %0000_0000, %0
