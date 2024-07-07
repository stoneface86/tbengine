;;
;; Sample data for a schedule
;;
;; schedule1 - a schedule of 4 bits, separate data streams.
;;

schedule1:
    DB 4 - 1
    DW .ch1, .ch2, .ch3, .ch4

;;     CH1 CH2 CH3 CH4
;; 00   X   X   X
;; 01   X       X   X
;; 02   X   X    
;; 03   X        

.ch1:
    DB %1111
.ch2:
    DB %0101
.ch3:
    DB %0011
.ch4:
    DB %0010
