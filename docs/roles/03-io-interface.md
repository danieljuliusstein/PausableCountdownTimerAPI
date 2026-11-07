# Role 3 — Memory-mapped I/O and wrapper

Own hardware/rtl/countdown_io.vhd and hardware/rtl/countdown_peripheral.vhd.

Implement:
- Address 0x030 TIMER_VALUE (R remaining; W duration).
- Address 0x031 TIMER_CONTROL (R RUNNING/DONE bitmask; W 0 PAUSE, 1 START/RESUME, 2 RESET).
- IO_DATA tri-state read drive only when selected; no driving during writes.
- Clean synchronous command/LOAD strobes.
- Instantiation and wiring of Roles 1 and 2 in the wrapper.
- No extra SCOMP CPU instructions or changes to game logic.

Coordinate with Role 4 on .bdf signal names, Quartus symbol generation and bus direction.

Done when reads/writes route correctly with no address collisions or bus contention.
