# SCOMP assembly demonstration + rocketship game (Role 5 lead)

**Week 1 (by Nov 14):** finish `CountdownDemo.asm` and demonstrate the generic countdown API. Do **not** postpone this to work on the game.

**Week 2 (by Nov 19):** build `RocketGame.asm` as a complete standalone SCOMP game using the unchanged countdown API. Persons 2 and 3 will draft risk/multiplier and controls/cash-out routines in their comment-only staging files; Person 5 is responsible for merging real code into the final game file.

## Countdown API demo controls (to confirm with group)
- SW0: START/RESUME
- SW1: PAUSE
- SW2: RESET/reload
- SW3: LOAD 5.0 seconds

Show remaining ticks on the right HEX digits and DONE on an LED. Preserve existing Lab 8 switch/HEX I/O addresses 0x000/0x004/0x005, and LED address 0x001.

Implementation notes:
- Add switch-release or edge detection to avoid issuing commands repeatedly.
- Read TIMER_VALUE at 0x030 and TIMER_CONTROL at 0x031.
- Use a mask to extract DONE (bit 1).
- Hardware counts independently: do not implement elapsed-time counting in assembly.
- Assemble with the course assembler and confirm output .mif matches the SCOMP RAM init_file.
- SCOMP assembler support for multi-file linking/INCLUDE has not been verified: final game should work as one assembly program.

See [game plan](../docs/game-plan.md) and [timeline](../docs/timeline.md).
