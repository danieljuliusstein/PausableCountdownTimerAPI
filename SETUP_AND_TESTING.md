# Quartus Setup and API Testing Guide

This project exposes a memory-mapped FPGA API, not a web or REST API. You will
need the course Lab 8 SCOMP starter project and the appropriate Intel/Altera
FPGA board.

## 1. Install the tools

Install:

- Intel Quartus Prime, ideally the version required by the course
- Device support for the FPGA family used by the board
- The Quartus Programmer and USB-Blaster driver
- The course SCOMP assembler
- Optional: GHDL for running the automated simulations

On macOS with Homebrew, GHDL can usually be installed with:

```sh
brew install ghdl
```

## 2. Prepare the Quartus project

Clone or copy this repository, then extract the course starter project into:

```text
hardware/quartus/course-starter/
```

The expected structure is approximately:

```text
PausableCountdownTimerAPI/
├── hardware/
│   ├── quartus/
│   │   ├── course-starter/
│   │   └── countdown_files.qsf
│   └── rtl/
└── software/
```

Open the starter project's `.qpf` file in Quartus. Add the following line to
the starter project's main `.qsf` file:

```tcl
source ../countdown_files.qsf
```

That file adds the following VHDL sources to the project:

- `countdown_core.vhd`
- `countdown_controller.vhd`
- `countdown_io.vhd`
- `countdown_peripheral.vhd`

If the starter project is stored somewhere else, adjust the relative paths in
`hardware/quartus/countdown_files.qsf`.

## 3. Add the peripheral to SCOMP

In Quartus:

1. Run **Processing > Start > Start Analysis & Elaboration**.
2. Fix any missing-file, VHDL-version, or signal-width errors.
3. Open `countdown_peripheral.vhd`.
4. Choose **File > Create/Update > Create Symbol Files for Current File**.
5. Open `SCOMP_System.bdf`.
6. Insert one `countdown_peripheral` symbol.
7. Connect the peripheral as follows:

```text
CLOCK          -> 10 MHz system clock
RESETN         -> active-low reset
IO_ADDR[10..0] -> SCOMP I/O address bus
IO_READ        -> SCOMP I/O read signal
IO_WRITE       -> SCOMP I/O write signal
IO_DATA[15..0] -> shared SCOMP I/O data bus
```

Only `countdown_peripheral` needs to appear in the block diagram. Keep its
internal modules as separate VHDL files.

Confirm that no existing peripheral decodes addresses `0x030` or `0x031`.

## 4. Assemble the demo program

Assemble `software/CountdownDemo.asm` using the course SCOMP assembler.

Use the resulting `.mif` file as the SCOMP program-memory initialization file.
Its filename must match the `init_file` value used by `SCOMP.vhd`.

After installing the program, run a full Quartus compilation and resolve any
reported errors or width mismatches.

## 5. Program the FPGA board

1. Connect the FPGA board over USB and turn it on.
2. Open **Tools > Programmer** in Quartus.
3. Select the USB-Blaster hardware.
4. Add the generated `.sof` file if it is not already listed.
5. Enable **Program/Configure**.
6. Click **Start**.

## 6. Test the API on the board

The demo loads five seconds, represented as `50` deciseconds, at startup.

| Control | Expected behavior |
| --- | --- |
| SW0 | Start or resume |
| SW1 | Pause |
| SW2 | Reset to the most recently loaded duration |
| SW3 | Load 50 deciseconds and pause |
| HEX0 | Show the remaining deciseconds |
| LED1 | Turn on when the timer reaches zero |

Run this smoke test:

1. Press SW3. The display should show `50`.
2. Press SW0. The displayed value should begin decreasing.
3. Press SW1. The displayed value should stop changing.
4. Press SW0 again. The countdown should resume.
5. Press SW2. The value should return to `50` and remain paused.
6. Start the timer and let it expire. It should reach `0`, and LED1 should
   remain on.
7. Press SW2 or SW3. The DONE indication should clear.

## API reference

### Timer value register: `0x030`

| Operation | Behavior |
| --- | --- |
| Read | Return the remaining time in deciseconds |
| Write `N` | Load duration `N`, pause the timer, and clear DONE |

### Timer control/status register: `0x031`

When reading:

| Bit | Meaning |
| --- | --- |
| 0 | Timer is running |
| 1 | Timer has finished |

When writing:

| Value | Command |
| --- | --- |
| `0` | Pause |
| `1` | Start or resume |
| `2` | Reset to the most recently loaded duration |

DONE remains set after the timer reaches zero. Loading a duration or issuing a
reset command clears it.

## 7. Run the automated simulations

Install GHDL, then run the following command from the repository root:

```sh
hardware/sim/run_all_tests.sh
```

The simulations cover:

- Loading a duration
- Countdown timing
- Pause and resume
- Reset
- Expiration and the DONE flag
- Zero-duration behavior
- Invalid commands
- I/O-bus isolation

The tests should exit successfully and report that the controller and
countdown tests passed.

## Troubleshooting

- **Quartus cannot find a VHDL file:** Check the paths in
  `hardware/quartus/countdown_files.qsf` and the location of the course starter
  project.
- **The peripheral does not appear in the symbol picker:** Re-run **Create
  Symbol Files for Current File** with `countdown_peripheral.vhd` open.
- **The FPGA program disappears after power cycling:** A `.sof` programs the
  volatile FPGA configuration; program the board again or follow the board's
  flash-programming procedure.
- **The timer does not count at the right speed:** Confirm that `CLOCK` is
  connected to the expected 10 MHz clock.
- **The I/O bus has multiple-driver errors:** Confirm that the peripheral only
  drives `IO_DATA` during a valid read of address `0x030` or `0x031`.
- **The demo program does not run:** Confirm that the generated `.mif` name
  matches the `init_file` configured in `SCOMP.vhd`, then compile again.
