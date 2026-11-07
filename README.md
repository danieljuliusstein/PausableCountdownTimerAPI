# Pausable Countdown Timer API — ECE 2031

A reusable, memory-mapped countdown peripheral for Georgia Tech's SCOMP processor. The goal is to make time-based assembly programs easier to write by moving countdown, pause/resume, reset, and expiration tracking into VHDL hardware.

**Status: scaffold only.** The interfaces and responsibilities are defined, but the core, controller, I/O interface, integration, and demonstration need to be implemented. Do not treat this branch as a working FPGA design.

## Five workstreams

| Role | Owner's focus | Main files |
| --- | --- | --- |
| 1. Countdown core | Duration register, remaining register, 0.1-second tick generation | hardware/rtl/countdown_core.vhd |
| 2. Controller | START, PAUSE, RESUME, RESET and DONE state behavior | hardware/rtl/countdown_controller.vhd |
| 3. SCOMP interface | Memory-mapped reads/writes and peripheral wrapper | hardware/rtl/countdown_io.vhd, hardware/rtl/countdown_peripheral.vhd |
| 4. Integration & verification | Quartus wiring, simulation and hardware tests | hardware/quartus/, hardware/sim/ |
| 5. Assembly API demo | Switches, HEX displays, countdown API demonstration | software/ |

Read [the API contract](docs/api-contract.md) before editing VHDL, then see your individual [role instructions](docs/roles/) and [contribution guidelines](CONTRIBUTING.md).

## Proposed public register API

| Address | Read | Write |
| --- | --- | --- |
| 0x030 — TIMER_VALUE | 16-bit remaining deciseconds | Load a new duration; clear DONE and pause |
| 0x031 — TIMER_CONTROL | Status bit 0 RUNNING; bit 1 DONE | 0 PAUSE, 1 START/RESUME, 2 RESET (reload and pause) |

Example: write 50 to TIMER_VALUE for 5 seconds, write 1 to TIMER_CONTROL to start, 0 to pause, 1 to resume. These addresses and semantics are **proposed** until the team and TA approve them.

## Repository layout

~~~text
hardware/
  rtl/                    # Roles 1, 2, 3; shared VHDL interfaces
  sim/                    # Role 4; VHDL testbench
  quartus/                # Role 4; course starter copied locally
software/                 # Role 5; SCOMP assembly demo
docs/
  api-contract.md         # Contract shared by all roles
  architecture.md         # Datapath, control and bus boundaries
  test-plan.md            # Required acceptance tests
  roles/                  # Individual developer tasks
.github/                  # Pull request template
~~~

## Local setup

1. Clone the repository and read docs/api-contract.md with your group.
2. Person 4: copy the **authorized Lab 8 starter project** into hardware/quartus/ locally (see its README). The starter files are intentionally not republished here.
3. Implement the skeletons by role; open separate pull requests to main.
4. Add the countdown peripheral to the Quartus SCOMP system and register VHDL files.
5. Assemble software/CountdownDemo.asm to the MIF file expected by the processor; verify against the actual CPU RAM init_file reference.
6. Simulate before testing on the FPGA.

The starter Lab 8 system uses an 11-bit I/O address, a shared 16-bit tri-state I/O data bus, and a 10 MHz clock. This scaffold uses the same bus shape and a parameterized divider for simulation. No Quartus/GHDL build has been run against these unfinished modules.

## Demo scope

First: demonstrate loading, countdown, pause/resume, reset, and DONE using switches/LEDs/HEX displays. Later: apply exactly this API to a virtual-credit rocketship risk/reward game. The VHDL peripheral must remain independent of the game.

**Course materials:** This repository is public. Confirm course sharing rules before committing starter source, schematics, or handouts. Do not commit generated Quartus caches.
