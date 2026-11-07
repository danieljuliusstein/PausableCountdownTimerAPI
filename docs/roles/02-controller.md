# Role 2 — Pause/resume controller

Own hardware/rtl/countdown_controller.vhd.

Implement:
- Explicit PAUSED/RUNNING/DONE state behavior.
- START/RESUME and PAUSE commands.
- RESET command: pulse RELOAD_STROBE and return to PAUSED.
- LOAD clears sticky DONE and pauses.
- On expiry, drive final DECREMENT, latch DONE, stop.
- Ignore invalid commands (the I/O layer handles decoding).

Coordinate with Role 1 on remaining/decrement synchronization and command priority. Provide state-transition simulation cases to Role 4.

Done when controller tests show idempotent START/PAUSE, sticky DONE and reset/reload.
