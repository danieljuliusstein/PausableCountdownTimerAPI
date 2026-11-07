# Role 1 — Countdown core

Own hardware/rtl/countdown_core.vhd.

Implement:
- One 16-bit loaded-duration register and one 16-bit remaining register.
- Countdown saturation at zero with one DECREMENT pulse per tick.
- A divider based on CLOCK=10 MHz (default TICKS_PER_DECIS=1000000).
- TICK_PULSE only while RUNNING; freeze divider progress while paused.
- LOAD updates both registers and resets the divider; RELOAD restores stored duration and clears fraction.
- Reset initializes all state to zero.

Coordinate with Role 2 on tick timing, priorities and zero/expiry semantics, and with Role 4 on simulation.

Done when the Role 4 testbench covers load, pause mid-tick, resume, reset and no underflow.
