
# Song Format

This document describes the format of the song data that is understood by the
driver.

The following data types are referenced within this document:
 * `sz8` - 8-bit size, unsigned, biased, ranges from 1 to 256
 * `q5.3` - fixed point, ranges from 0.0 to 31.875
 * `u16` - unsigned 16-bit integer, little-endian

## Header

A song begins with a header containing the speed and order of the song.

| Offset | Length | Type | Field Name    |
|--------|--------|------|---------------|
| 0      | 1      | q5.3 | shSpeed       |
| 1      | 1      | sz8  | shOrderSize   |
| 2      | 1      | sz8  | shPatternSize |
| 3      | 2      | u16  | shOrderPtr    |

### shSpeed

The shSpeed field determines the number of frames a row is run for. The speed
is essentially the tempo of the song. Its value is an unsigned fixed point
integer in Q5.3 format (5 bits integral, 3 bits fractional). Valid speeds are
in the range of 1.0 - 30.875 (\$08 - \$F7), inclusive.

For example, a speed of 6.0 (\$30), means that each row runs for 6 frames.
Assuming 4 rows per beat, this gives us a tempo of 150 BPM.

Non-integer speeds will have some rows running for more frames, ie 6.5 (\$34)
will result in every even row getting 7 frames and every odd row getting 6.

### shOrderSize

This field contains the number of entries in the order table less 1. So a size
of 0 means that the order table has 1 entry (An order table can never have 0
entries).

### shPatternSize

This field determines the size of a pattern, in rows. This field is also less 1,
same as order size, as a pattern can never have 0 rows

### shOrderPtr

This field contains a pointer to the order table.

## Order Table

The order table contains the layout of the song. Entries in this table are
called orders. An order has a pointer to a track for each channel, starting
with channel 1. Thus orders are 4 `u16` pointers, or 8 bytes. An order table
must contain at least 1 order and no more than 256 orders.

### Order layout

| Offset | Length | Type | Field Name |
|--------|--------|------|------------|
| 0      | 2      | u16  | orCh1Ptr   |
| 2      | 2      | u16  | orCh2Ptr   |
| 4      | 2      | u16  | orCh3Ptr   |
| 6      | 2      | u16  | orCh4Ptr   |

For those familar with Famitracker, orders work exactly the same as frames.

The engine begins playback at the first order and will loop back to the
first when the order counter is equal to the shOrderSize field.

# Example song

The following defines a song with 1 order, 64-row patterns and a speed of 6.0
frames/row.

```asm
SECTION "sample song data", ROM0

sampleSong:
    DB $30                      ; shSpeed
    DB 1 - 1                    ; shOrderSize
    DB 64 - 1                   ; shPatternSize
    DW sampleSong_order         ; shOrderPtr

sampleSong_order:
    DW sampleSong_ch1_track0    ; orCh1Ptr
    DW sampleSong_ch2_track0    ; orCh2Ptr
    DW sampleSong_ch3_track0    ; orCh3Ptr
    DW sampleSong_ch4_track0    ; orCh4Ptr

; example track data not included here for brevity, see track_format.md for an example
```
