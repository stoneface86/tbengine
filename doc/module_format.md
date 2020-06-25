
# Module format

This document descibes the structure of a module that is understood by this
driver. A module contains songs, instruments and wave data that is used by
the driver.

A module consists of three tables, one for songs, one for instruments and one
for wave data. Each table is just an array of pointers so we can easily lookup
via a byte index.

In order to use the driver, the following labels must be exported in your project.
 * `tbe_songTable`
 * `tbe_instrumentTable`
 * `tbe_waveTable`

These tables must reside in the same bank as the driver, but the data they point
to can reside in other banks (Note: bank-switching is not currently implemented)
 
NOTE: indices are not bounds checked by the driver at run-time, so attempting to
use a non-existent song/instrument/waveform may result in undefined behavior. It
is recommended that you maintain and reference indices with EQUs in your project.

# Example

The following section contains the necessary tables. The module in this example
has two songs, two instruments and three waveforms.

```asm

SECTION "module", ROM0

tbe_songTable::
    DW song0, song1

tbe_instrumentTable::
    DW inst0, inst1

tbe_waveTable::
    DW wave0, wave1, wave2

```
