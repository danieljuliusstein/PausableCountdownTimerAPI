# Controller signals and timing for review

The implementation is hardware/rtl/countdown_controller.vhd, entity countdown_controller. The old controller.implement.vhd is only a pointer, not a second design unit.

## Signal meanings

A command strobe is a synchronous one-clock notification from the I/O decoder, not a clock or held switch input.

| Signal | Direction | Meaning |
| --- | --- | --- |
| CLOCK | Input | Shared 10 MHz clock |
| RESETN | Input | Active-low asynchronous system reset |
| LOAD_STROBE | Input | New duration write; core loads it, controller pauses and clears DONE |
| START_STROBE | Input | Start or resume existing remaining value |
| PAUSE_STROBE | Input | Pause without clearing remaining time or sticky DONE |
| RESET_STROBE | Input | Software reload-and-pause command |
| REMAINING | Input | Unsigned 16-bit count carried as std_logic_vector(15 downto 0) |
| TICK_PULSE | Input | Tick due at upcoming rising edge |
| RUNNING | Output | High in RUNNING state; changes on state transition edge |
| DONE | Output | High in DONE state until LOAD, RESET, or hardware reset |
| RELOAD_STROBE | Output | Combinational core reload enable for upcoming edge |
| DECREMENT | Output | Combinational core subtract-one enable for upcoming edge |

## Shared-edge behavior

Commands and REMAINING must be stable before the rising edge. DECREMENT and RELOAD_STROBE are combinational enables, not delayed registered pulses. With REMAINING=1 on a tick, the core decrements to zero on the same edge that the controller enters DONE.

Priority is hardware reset > LOAD > RESET > PAUSE > START > tick. The decoder normally emits only one command. START at zero enters DONE without decrementing. DONE ignores START, PAUSE, and ticks. RESET reloads the saved duration and pauses; LOAD installs a new duration and pauses.

## Core timing proposal requiring team review

The core should derive TICK_PULSE from its current divider and RUNNING before the consuming edge. RUNNING is state/status, not an immediate command inhibit. If a command suppresses DECREMENT while a tick is due, retain the terminal divider count until DECREMENT consumes it (or LOAD/RELOAD clears it). This preserves a tick when PAUSE coincides with expiration.

Before the terminal count, the divider advances through the PAUSE sampling edge, then freezes while paused. LOAD and RELOAD override advancement and clear fractional progress. Repeated START does not reload or reset the divider, but suppresses a coincident decrement under the existing command-over-tick rule. The due tick must be retained.

These are integration expectations for Roles 1, 3, and 4 to review, not proof that the actual core works. No core ports or public register addresses change. Team approvals remain unchanged.

## Verification

Run `sh hardware/sim/run_controller_tests.sh` with GHDL installed. GitHub Actions runs analysis, simulation assertions, and controller synthesis.

The testbench uses a four-clock behavioral core model. It covers load, countdown, fractional pause/resume, repeated commands, final-tick collisions, command priority, sticky DONE, zero duration, unsigned range, and hardware reset. It does not replace the real core or full-system testbench. Quartus, bus isolation, and FPGA behavior remain integration checks.
