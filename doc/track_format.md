# Track Format

This document describes the format of a track, or pattern data for a single
channel.

Some definitions:
 * Row: a single row in a track, possibly containing a note and some effects
 * Track: music data for a channel, as an array of rows
 * Pattern: A set of 4 tracks, one for each channel 

Tracks in the driver are made up of a stream of rows. A row is made up of any
number of commands and is ended by a note byte. Empty rows are not stored, but
are represented by "duration", or the number of empty rows between two rows.

## Row format

A row is a stream of bytes with the following format:

`[Command [param]] [duration] <note>`

Commands and durations are optional, but every row must end with a note byte.
Each byte format will be defined below

### Note byte

The note byte is used to trigger a note/cut for the row. Triggering a note
sets the note's frequency into the channel's frequency register or NR43 for
the noise channel.

```
8   7                     0
+---+---------------------+
| 0 |          Note index |
+---+---------------------+
```

Note indices range from 0-83 for notes and 84-85 for rest/cut.

Valid note indices:
 * CH1, CH2, CH3: 0-85, inclusive
 * CH4: 0-59 and 84-85, inclusive

Note: CH4 can only use octaves 2-6

There are two special note indices, hold and cut.
 * `NOTE_HOLD` "holds" the current note. It is essentially a no-op, used when
   you have effects set on a row but no note to trigger. It is also used when a
   duration exceeds 64.
 * `NOTE_CUT` silences the channel via NR51

## Command byte

The command byte is used to execute a command or effect. Some commands require
a parameter. For commands with a parameter, the parameter enable bit (P) is set
and the parameter is the next byte in stream. The parameter is defaulted to 0
if P is reset, so for any command with parameter=0, this byte can be omitted.

```
8   7   6   5             0
+---+---+---+-------------+
| 1 | 0 | P |   Cmd index |
+---+---+---+-------------+
```

### Example:

the pitch slide up effect (1xx) has command index 7

when xx is nonzero: `$A7 $xx`

when xx is zero: `$87`

## Duration byte

The duration byte specifies how long the row runs for, or the number of empty
rows until the next one. Durations are optional, as the last one specified is
used if the duration is omitted. By default, the duration for all channels is
0 (1 row).

```
8   7   6                0
+---+---+-----------------+
| 1 | 1 |        Duration |
+---+---+-----------------+
```

Durations range from 0-63 (or 1-64 rows). If a row's duration exceeds 64 rows,
then extra NOTE_REST rows will need to be added to the track.

## Summary

 * `$00 - $7F`: Note byte
 * `$80 - $BF`: Command byte w/ optional parameter byte
 * `$C0 - $FF`: Duration byte

# Example

For this example, we have a track with 8 rows:

```
C-4 P81 V02 EF1
... ... ... ...
E-4 ... ... ...
F#5 101 ... ...
... ... ... ...
... 100 ... ...
--- ... ... ...
```

The equivalent track data assembly source follows:
```asm
trackdata:
    tbe_setTune $81
    tbe_setTimbre $02
    tbe_setEnvelope $F1
    tbe_duration 2
    tbe_note C_4

    tbe_duration 1
    tbe_note E_4

    tbe_pitchSlideUp $01
    tbe_duration 2
    tbe_note F#5

    tbe_pitchSlideUp $00
    tbe_duration 1
    tbe_note NOTE_REST

    tbe_note NOTE_CUT
```
Note: the durations for each row totaled should equal the size of a pattern,
if it is less a buffer overrun will occur.

Raw data version:
```asm
trackdata:
    DB $AB, $81
    DB $AF, $02
    DB $AE, $F1
    DB $C1
    DB $18

    DB $C0
    DB $1C

    DB $A7, $01
    DB $C1
    DB $2A

    DB $87              ; pitchSlideUp command, param = 0
    DB $C0              ; duration = 1
    DB $54

    DB $55              ; no duration, same as previous (1)
```

The example track will require 18 bytes in the ROM.

# Optimizing space

The space requirements for a track depends on the total number of set rows,
more rows = more space needed. If space is limited, here are a couple tricks
to save space when writing music data:
 * Use less commands. Most commands require a parameter which takes 2 bytes
   total per effect
 * Use instruments instead of commands to set timbre/envelope etc. Instrument
   settings are applied on every note trigger and you only need to set an
   instrument once for it to persist.
 * Having the same duration between rows reduces the need for a duration byte
   every row.
 * Avoid redundant commands, ie you do not need to turn pitch slide off when
   setting arpeggio, it will be done automatically. 
 * Reuse tracks when possible.

