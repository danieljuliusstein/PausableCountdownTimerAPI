# Pausable Countdown Timer API — ECE 2031

A reusable, memory-mapped countdown peripheral for Georgia Tech's SCOMP processor. The goal is to make time-based assembly programs easier to write by moving countdown, pause/resume, reset, and expiration tracking into VHDL hardware.

## Project schedule and approvals

**Week 1 (November 8–14): finish the reusable countdown API.**  
**Week 2 (November 15–21): implement, test and present the rocketship game.**

- **[Full project timeline and individual deadlines](docs/timeline.md)**
- **[Required five-person API contract sign-off](docs/api-contract.md#required-team-review-and-sign-off)**
- **[Rocketship MVP game plan](docs/game-plan.md)**

These are internal planning dates; the official course due date must still be confirmed.

## Five workstreams

| Role | Owner's focus | Main files |
| --- | --- | --- |
| 1. Countdown core | Duration register, remaining register, 0.1-second tick generation | hardware/rtl/countdown_core.vhd |
| 2. Controller | START, PAUSE, RESUME, RESET and DONE state behavior | hardware/rtl/countdown_controller.vhd |
| 3. SCOMP interface | Memory-mapped reads/writes and peripheral wrapper | hardware/rtl/countdown_io.vhd, hardware/rtl/countdown_peripheral.vhd |
| 4. Integration & verification | Quartus wiring, simulation and hardware tests | hardware/quartus/, hardware/sim/countdown_tb.vhd |
| 5. Assembly demo & game | Countdown API demonstration, then rocketship assembly game | software/CountdownDemo.asm |

Each person starts with the **comment checklist inside their assigned file**, reads [the proposed API contract](docs/api-contract.md) and [their role guide](docs/roles/), and writes their implementation from scratch.

## Proposed public register API

| Address | Read | Write |
| --- | --- | --- |
| 0x030 — TIMER_VALUE | 16-bit remaining deciseconds | Load new duration; clear DONE and pause |
| 0x031 — TIMER_CONTROL | Status bit 0 RUNNING; bit 1 DONE | 0 PAUSE, 1 START/RESUME, 2 RESET (reload and pause) |

These addresses and semantics are proposed until the team and TA approve them.

## Repository layout

~~~text
hardware/
  rtl/                    # Comment-only VHDL assignments (Roles 1–3)
  sim/                    # Comment-only testbench assignment (Role 4)
  quartus/                # Local course-starter integration instructions (Role 4)
software/                 # Comment-only API demo + rocketship assignments (Roles 2, 3, 5)
docs/
  api-contract.md         # Contract + five-person typed sign-off
  timeline.md             # Two-week dated team deadlines
  game-plan.md            # Rocketship MVP requirements
  architecture.md         # Datapath, control and bus boundaries
  test-plan.md            # Required acceptance tests
  decisions.md            # Open design questions
  roles/                  # Individual developer instructions
.github/                  # Pull request template
~~~

## Getting started as a team

1. Review and agree on docs/api-contract.md **before** anyone writes code.
2. Each developer creates their own role branch and begins implementing the commented checklist in their owned file.
3. Person 4 prepares the authorized Lab 8 Quartus starter locally (see hardware/quartus/README.md). Starter files are intentionally not republished here.
4. Develop and review each module using pull requests; coordinate changes to module signals in the API contract.
5. Add the hardware to SCOMP, run simulations, and finally demonstrate loading, countdown, pause/resume, reset and DONE on the FPGA.

The Lab 8 starter uses an 11-bit I/O address, shared 16-bit I/O bus, and 10 MHz processor clock. The proposed API uses 0.1-second ticks. The exact addresses and integration method must be checked against the course project.

## Rocketship game demonstration — Week 2

The rocketship game is **planned for this project** after the reusable timer API is proven in Week 1. A countdown controls each rocket stage; players can cash out or risk their unbanked virtual credits in increasingly risky multiplier rounds. Rocket, credit, and crash mechanics belong in assembly, **never in the timer hardware**. See [the game plan](docs/game-plan.md).

**Public repository note:** Confirm course sharing rules before adding starter files, schematics, or handouts. Do not commit generated Quartus output.
