# Project timeline — Countdown API + Rocketship Game

**Planning window:** Saturday, November 7 – Saturday, November 21, 2026 (Eastern Time).  
**Official submission deadline:** **Not yet verified**. The dates below are internal targets assuming final submission around November 21. Update once the Canvas due date is confirmed.

## What counts as finished

**Week 1 (Nov 8–14): working API** — The countdown peripheral compiles, is connected to SCOMP, and a short assembly demo proves LOAD, START, PAUSE, RESUME, RESET, remaining-time reads, and DONE. Simulation and an initial board test should pass.

**Week 2 (Nov 15–21): rocketship game** — A playable virtual-credit rocket game uses **the same API**. A countdown governs stages; users can cash out or risk winnings in multiplier rounds; a timer expiration/crash loses the current round's stake; pause freezes both timer and game actions. Present credits/multiplier/stage using the board's displays/LEDs. The game does not belong in timer VHDL.

## Hard checkpoints (ET)

| Due date | Deliverable | Owners | Must be demonstrable |
| --- | --- | --- | --- |
| **Sun Nov 8, 9 PM** | Discuss design, resolve address/command questions, agree MVP game controls | All five | Team agreement on scope |
| **Mon Nov 9, 11:59 PM** | **API contract signed by all five** | All five | All rows in [api-contract.md](api-contract.md) contain typed name, date, Approved |
| **Wed Nov 11, 9 PM** | First core/controller/I/O drafts, simulator setup, assembly demo plan | Persons 1–5 | Source files committed; interface mismatch questions resolved |
| **Fri Nov 13, 9 PM** | Core, controller, I/O wrapper + initial self-checking simulation and assembly countdown demo | Persons 1–5 | Countdown API behaves correctly in simulation and SCOMP integration is underway |
| **Sat Nov 14, 6 PM** | **API freeze / hardware handoff** | All five (Person 4 integration lead) | Quartus compiles; countdown demo works on FPGA or documented blocker with immediate recovery plan |
| **Sun Nov 15, 8 PM** | Freeze rocketship game rules, controls, displays, stage durations, test cases | All five (Person 5 game lead) | Small game design agreed, no new peripheral feature creep |
| **Tue Nov 17, 9 PM** | Playable rocket prototype | Persons 2, 3, 5; Persons 1, 4 support | Launch, countdown, cash out, one crash condition, display response |
| **Thu Nov 19, 9 PM** | Full game feature-complete | All five | Virtual credits, multiplier rounds, greater crash risk, lose-on-crash, pause/resume, replay |
| **Fri Nov 20, 9 PM** | Final verification, documentation, presentation/check-off material | All five (Person 4 test lead) | End-to-end hardware demo + edge cases passing |
| **Sat Nov 21** | Contingency / submission | All five | Submit before **actual** course deadline once confirmed |

**Priority:** If the API slips past Nov 14, simplify the game to one rocket stage + one multiplier stage before adding extra visuals. Protect Nov 20 for debugging and demonstration evidence.

## Role-by-role deadlines

| Role | Week 1: API (by Nov 13–14) | Week 2: Game (by Nov 17–19) |
| --- | --- | --- |
| **1 — Countdown core** | Implement and verify countdown registers, tick divider, mid-tick pause/resume; fix timing issues | Validate repeated stage reloads and timer/zero corner cases; fix VHDL timing bugs; support game timing tests |
| **2 — Controller** | Implement state machine, RESET, DONE and no-underflow semantics; help verify state transitions | Prepare and hand off rocket risk/multiplier assembly routine notes in `software/RocketRisk.asm`; support Person 5's integration |
| **3 — I/O interface** | Implement address decoding, register bus read/write, wrapper; verify bus isolation | Prepare cash-out/button and timer-API interaction routine notes in `software/RocketControls.asm`; help Person 5 merge/test them |
| **4 — Hardware integration & tests** | Integrate VHDL in Quartus; self-checking simulation; FPGA countdown check | Map game feedback to LEDs/HEX, test game on FPGA, collect test evidence, coordinate final fixes |
| **5 — Assembly demo/game** | Build `CountdownDemo.asm` to prove API on board | Own `RocketGame.asm` integration: flight, credits, multiplier stages, risk roll, payout, crash, game over, replay |

**Assembly collaboration note:** The course SCOMP assembler has not been confirmed to support linking/inclusion of separate assembly files. `RocketRisk.asm` and `RocketControls.asm` are **comment-only handoff/staging files**, not standalone modules; Person 5 merges the actual routines into the single final `RocketGame.asm` rather than assuming includes work.

## Completion checklist

### Week 1 — API
- [ ] Five typed name/date approvals in docs/api-contract.md
- [ ] Core + controller + I/O compile and connect
- [ ] Testbench verifies countdown, pause, resume, reset, expiration, address isolation
- [ ] SCOMP assembly demo uses new hardware API successfully
- [ ] Quartus/FPGA countdown proof captured

### Week 2 — Rocketship
- [ ] Rocket stages and cash-out logic implemented using countdown API
- [ ] Virtual credit balance and payouts displayed
- [ ] Multiplier rounds have higher crash probability and higher potential reward
- [ ] Expiration / random crash ends the round and forfeits its stake
- [ ] Pause/resume freezes game decisions and timer
- [ ] Game is replayable and tested on the FPGA
- [ ] Final report/check-off evidence and submission prepared

For full game MVP rules, see [game plan](game-plan.md). For individual assignments, see [role guides](roles/).
