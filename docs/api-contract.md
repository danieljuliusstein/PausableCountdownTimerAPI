# Proposed countdown I/O API (v0; team agreement required)

## Context

The Lab 8 starter uses a shared 16-bit IO_DATA bus, 11-bit IO_ADDR, IO_READ, IO_WRITE and active-low RESETN. This project adds a new peripheral without replacing the existing timer at address 0x002.

The proposed registers below must be confirmed free in the final Quartus system.

| 11-bit I/O address | IN (read) | OUT (write) |
| --- | --- | --- |
| 0x030 TIMER_VALUE | remaining time as an unsigned 16-bit count of 0.1-second ticks | store duration, set remaining=duration, pause, clear DONE |
| 0x031 TIMER_CONTROL | bit 0 RUNNING; bit 1 DONE; bits 15:2 zero | 0 = PAUSE; 1 = START/RESUME; 2 = RESET to stored duration and PAUSE |

Unknown control values: no effect. Repeated START while already running: no effect. PAUSE while already paused: no effect. Command writes have higher priority than an overlapping timing tick.

## Time semantics

- Default hardware tick period is 0.1 s derived from a 10 MHz SCOMP clock (1,000,000 rising edges per tick).
- Core has a generic TICKS_PER_DECIS=1000000 so simulation can use a small value.
- Pause **freezes fractional progress** toward the next tick; resume continues that progress rather than restarting a tick.
- Loading a new duration or RESET clears fractional tick progress.
- Timer saturates at zero: never wraps around to 0xFFFF.
- DONE becomes 1 when the running countdown expires and remains set until LOAD or RESET.
- Starting with remaining=0 sets DONE; the timer does not count.
- Hardware reset initializes the duration and remaining to 0, RUNNING=0, DONE=0.
- RESET command restores the most recently loaded duration and leaves the timer paused.

## Module-to-module signals

Role 1: countdown_core
- Inputs: CLOCK, RESETN, RUNNING, LOAD_STROBE, LOAD_VALUE, RELOAD_STROBE, DECREMENT.
- Outputs: REMAINING, LOADED_VALUE, TICK_PULSE.
- Runs in 10 MHz clock domain. Generates one-cycle TICK_PULSE only when RUNNING and divider expires. Increments divider only while running.

Role 2: countdown_controller
- Inputs: CLOCK, RESETN, LOAD_STROBE, START_STROBE, PAUSE_STROBE, RESET_STROBE, REMAINING, TICK_PULSE.
- Outputs: RUNNING, DONE, RELOAD_STROBE, DECREMENT.
- LOAD overrides other actions. On a tick, when REMAINING=1, decrement and latch DONE/stop. Implement command/tick priorities as documented.

Role 3: countdown_io and countdown_peripheral wrapper
- Decode address 0x030 / 0x031.
- IO_DATA must be high impedance unless this peripheral is selected for an IN.
- Expose single-transaction command strobes; write TIMER_VALUE passes full unsigned duration.
- On read TIMER_CONTROL return status in low two bits, all other bits zero.
- Instantiates the core and controller using the shared signal contract.

## Assembly examples (conceptual)

~~~asm
LOADI 50
OUT TimerValue       ; 5.0 seconds; paused after load
LOADI 1
OUT TimerControl     ; start
LOADI 0
OUT TimerControl     ; pause
LOADI 1
OUT TimerControl     ; resume
IN TimerValue        ; remaining deciseconds
IN TimerControl      ; status bitfield

TimerValue:   EQU &H030
TimerControl: EQU &H031
~~~

## Integration concerns to test

- Writing the bus may remain asserted across processor cycles: verify one command per OUT, no retriggers or lost writes.
- Verify timing relative to the CPU and internal register sampling; do not derive new clocks from IO_WRITE.
- Validate tristate IO_DATA behavior against SCOMP and existing peripherals.
- Confirm that the course's assembler and RAM MIF setting match the final assembly output.
