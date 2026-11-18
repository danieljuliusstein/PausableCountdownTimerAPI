# Pausable Countdown Timer

This project adds a memory-mapped countdown timer to the ECE 2031 SCOMP
processor. The timer counts in tenths of a second and supports loading,
starting, pausing, resuming, and resetting without a software delay loop.

## I/O interface

| Address | Read | Write |
| --- | --- | --- |
| `0x070` | Remaining time in deciseconds | Load a new duration |
| `0x071` | Bit 0: running, bit 1: done | `0`: pause, `1`: start/resume, `2`: reset |

Loading a value pauses the timer and clears DONE. Reset restores the most
recently loaded value and pauses the timer. DONE remains set after the timer
reaches zero until a load or reset command is issued.

## Source files

- `countdown_core.vhd` stores the duration and generates the 0.1-second tick.
- `countdown_controller.vhd` handles the running, paused, and done states.
- `countdown_io.vhd` implements SCOMP address decoding and the shared data bus.
- `countdown_peripheral.vhd` connects the three modules.
- `CountdownDemo.asm` provides a switch-controlled hardware demo.

## Simulation

With GHDL installed, run:

```sh
hardware/sim/run_all_tests.sh
```

The tests cover loading, countdown, pause/resume, reset, expiration,
zero-duration behavior, invalid commands, and bus isolation.

## Demo controls

| Switch | Action |
| --- | --- |
| SW0 | Start or resume |
| SW1 | Pause |
| SW2 | Reset to the loaded duration |
| SW3 | Load 5.0 seconds |

The remaining decisecond count is shown on HEX0 and DONE is shown on LED1.
Quartus setup notes are in `hardware/quartus/README.md`.
