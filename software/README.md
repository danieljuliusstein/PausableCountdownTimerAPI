# SCOMP assembly API demonstration (Role 5)

This directory is for the **reusable peripheral demonstration**, not the full rocketship game.

Suggested switch plan (confirm with group):
- SW0: START/RESUME
- SW1: PAUSE
- SW2: RESET/reload
- SW3: LOAD 5.0 seconds

Show remaining ticks on the right HEX digits and DONE on an LED. Preserve existing Lab 8 switch/HEX I/O addresses 0x000/0x004/0x005, and LED address 0x001.

Implementation notes:
- Add switch-release or edge detection to avoid reissuing a command each poll.
- Read TIMER_VALUE at 0x030 and TIMER_CONTROL at 0x031.
- Use a bit mask to extract DONE (bit 1).
- The hardware counts independently: do not run an assembly decrement or delay loop for elapsed time.
- Assemble with the course's scasm.cfg and confirm output .mif matches the SCOMP RAM init_file.
