# Song data format

```
; ROM0
tbe_songTable::
  ; bank, pointer

tbe_waveformTable::
  ; DS 16

tbe_instrumentTable:: array[N, ptr Instrument]
  ; bank

Instrument:
  sequences: array[5, ptr Sequence]


Song:
  speed: u8
  patternTable: ptr ptr Pattern

Pattern
  schedule: ptr Schedule
  track1: ptr TrackBytecode
  track2: ptr TrackBytecode
  track3: ptr TrackBytecode
  track4: ptr TrackBytecode
  next: ptr Pattern


s0:
  DB $60 ; speed
  DW s0pn


s0pn:
s0p0:
  DW s0t0, s0t1, s0t2, s0t3, s0p1
s0p1:
  DW s0t0, s0t0, s0t0, s0t0, s0p0

sched0:
  DB $02, $FF, $0F

cmd0

s0t0:
  DW sched0
  DW s0cmd0
```

## label naming

`s<songnum><datatype><instance>`

examples:
  s0pn: pattern table for song 0
  s1p1: pattern #1 for song 1


# Bytecode

Driver bytecode is a stream of commands with each command having the following
syntax:

`[delay <frames>] [effects...] <note>`

## note

A note byte ends a command and is one of the following:
0 .. 83: index of the note to play (0 is C-2, 83 is B-8)
84: note cut
85: rest or no op

## effects

Effect commands are >= 128, or have bit 7 set. Note that the delay effect
must appear first to work properly!

delay <frames> - `$80 <frames>`




Available effects:
speed <speed>         ; Fxx
volume <volume>       ; Jxy
delay <frames>        ; Gxx
duration <frames>     ; Sxx
envelope <value>      ; Exx
timbre0               ; V00
timbre1               ; V01
timbre2               ; V02
timbre3               ; V03
panning0              ; I00
panning1              ; I01
panning2              ; I02
panning3              ; I03
sweep <value>         ; Hxx
lock                  ; L00

# Schedules

A **schedule** is a variable length bit vector, where a set bit in the vector
indicates when a row of track data should be performed. 

For example, a pattern of 8 rows only needs 1 byte for each track's schedule.
If a track in this pattern only has rows 2 and 6 set, then the schedule becomes
`%00100010`

## Data format

A schedule for a pattern is a byte containing the size, in bits-1, and four
pointers to the schedule data, with the first being CH1 and last being CH4.

The schedule data is encoded as a stream bytes with the first byte being the
length of the schedule (encoded as n-1 bits) and the remainder as the schedule
data. Any unused bits in the last byte of the stream should be zero.

Little-endian is used, so the first element in the schedule is the LSB.

Example:
```
mySchedule:
  DB $09        ; 9 bits, 2 bytes
  DB %01010101  ; bits 0-7
  DB %00000001  ; bit 8
```

In the above example, `mySchedule` has bytecode for the following row numbers:
0, 2, 4, 6 and 8.

The driver only needs to access a schedule sequentially, so enumerating the
schedule can be done by keeping the current byte in WRAM, testing its 0th bit
and then shifting it right. After every 8 accesses, the buffer is updated with
the next byte in the schedule
