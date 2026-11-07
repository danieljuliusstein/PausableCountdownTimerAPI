# Role 5 — Assembly API demonstration and rocketship game

Own `software/CountdownDemo.asm`, `software/RocketGame.asm` and `software/README.md`. Coordinate assembly handoffs from Persons 2 and 3.

## Week 1: API demo (by Nov 14)

Implement a small standalone demo **before** rocketship gameplay:
- Load a 5.0-second duration with OUT 0x030.
- START, PAUSE, RESUME and RESET using OUT 0x031 and switches.
- Read remaining and RUNNING/DONE with IN 0x030/0x031.
- Display remaining on HEX and DONE on an LED.
- Edge-detect held switches and use no software decrement loop.

## Week 2: Rocketship game (playable Nov 17; feature-complete Nov 19)

Implement the final assembled `RocketGame.asm`:
- launch countdown / rocket stages;
- bank balance, virtual stake, cash-out, and payout;
- multiplier stages, increased crash risk, crash/timeout outcomes;
- pause and resume that stop game action as well as hardware countdown;
- result display and replay.

Integrate Person 2's risk algorithm and Person 3's controls/IO work. Do not assume the assembler supports cross-file includes; merge and assemble a standalone game program.

Final check: timeout, cash out, risk success/failure, pause, restart all work on FPGA.

See [timeline](../timeline.md), [game plan](../game-plan.md) and [API contract](../api-contract.md).
