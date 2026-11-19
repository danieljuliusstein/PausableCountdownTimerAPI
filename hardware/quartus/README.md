# Quartus setup

The course Lab 8 starter project is not included in this repository. These
instructions assume it is extracted to `hardware/quartus/course-starter/`.

1. Add `source ../countdown_files.qsf` to the starter project's QSF file.
2. Run Analysis and Elaboration and fix any VHDL or width errors.
3. Add `countdown_peripheral` to `SCOMP_System.bdf`. A ready-to-use symbol is
   provided at `../rtl/countdown_peripheral.bsf`. If Quartus does not list it,
   open `countdown_peripheral.vhd` and choose **File > Create/Update > Create
   Symbol Files for Current File**.
4. Connect `CLOCK` to the 10 MHz clock and `RESETN` to the active-low reset.
5. Connect `IO_ADDR[10..0]`, `IO_READ`, `IO_WRITE`, and `IO_DATA[15..0]` to
   the existing SCOMP I/O bus.
6. Confirm that no other peripheral decodes addresses `0x070` or `0x071`.
7. Compile and check for width mismatches or unintended multiple drivers.
8. Assemble `software/CountdownDemo.asm` and use its MIF as the SCOMP memory
   initialization file.

Keep the timer modules separate. `countdown_peripheral` is the only module
that needs to be placed in the block diagram.

## API addresses

| Address | Read | Write |
| --- | --- | --- |
| `0x070` | Remaining time in deciseconds | Load a duration and pause |
| `0x071` | Bit 0 RUNNING, bit 1 DONE | `0` pause, `1` start/resume, `2` reset |

The timer is a bus peripheral only. Switches, LEDs, and HEX displays remain
connected to their existing Lab 8 peripherals and are controlled by the SCOMP
assembly application.

Before programming the FPGA, verify that SW3 loads 50, SW0 starts, SW1 pauses,
and SW2 resets. HEX0 should show the remaining deciseconds and LED1 should
remain on after the timer expires.
