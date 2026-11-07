# Rocketship Game — API demonstration MVP

**Game is a required project demo target for Week 2, not part of the VHDL peripheral.** Use virtual credits only. Final game-specific rules may be adjusted on Nov 15 when the team freezes the mechanics.

## Purpose

Prove that assembly can manage a time-limited game using the countdown API without decrementing time itself. Each round uses LOAD/START, optional PAUSE/RESUME, IN remaining and DONE, and RESET/reload.

## Minimum playable loop

1. Start a round with a small fixed virtual-credit stake and a loaded countdown.
2. The rocket rises while the timer runs; show progress with LEDs or HEX.
3. Before time runs out, player may **CASH OUT** to bank current potential winnings, or **RISK** to enter a higher multiplier stage.
4. Each risk stage performs a pseudorandom crash check; probability increases in higher stages. If it crashes, the stake/current unbanked winnings are lost.
5. If countdown expires, the round ends without payout.
6. PAUSE freezes the hardware countdown *and* disables cash-out/risk decisions until RESUME.
7. Show round result and allow a new round without reprogramming the FPGA.

## Suggested minimal stage design (not yet approved)

| Stage | Example payout multiplier | Example conditional crash chance on advancing |
| --- | --- | --- |
| Launch / first cash-out | 1.5× | 10% |
| Risk round 1 | 3× | 30% |
| Risk round 2 | 6× | 60% |

These illustrative percentages are **gameplay choices**, not hardware requirements. Decide and document how crash probability is generated in SCOMP assembly. Pseudorandomness is fine for a classroom game; do not claim it is secure or a fair gambling system.

## Hardware/software boundary

- **VHDL:** countdown, pause, resume, reset, remaining, DONE only.
- **Assembly:** virtual credits, rocket stage, cash-out, random roll, multiplier, crash and replay.
- **Existing peripherals:** switches for inputs; LEDs/HEX for stage/altitude, remaining and virtual credits. Confirm real display capacity before deciding final UI.
- One developer (Person 5) owns the final assembled game file; Persons 2 and 3 prepare their assigned routine notes, and everyone helps debug and test.

## Acceptance tests

- Pause in the middle of a stage, wait longer than the original stage duration, resume: countdown and stage remain unchanged while paused.
- Cash out before expiration: virtual credits increase by correct rounded payout.
- Lose by timeout: no payout.
- Lose by crash in a multiplier stage: unbanked credits forfeited.
- Survive a multiplier stage: greater potential payout.
- All stages reuse the **same** two timer registers with no rocket-specific VHDL.
