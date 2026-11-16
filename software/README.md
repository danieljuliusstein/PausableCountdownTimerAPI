# Countdown demo

`CountdownDemo.asm` demonstrates the timer using the SCOMP switches, LEDs, and
HEX display. It loads 50 deciseconds at startup and reads the remaining value
directly from the hardware timer.

Assemble the source with the course SCOMP assembler. Make sure the generated
MIF filename matches the `init_file` used by `SCOMP.vhd`.
