# Role 5 — Assembly API demonstration

Own software/CountdownDemo.asm and software/README.md.

Implement a small standalone demo **before** attempting rocketship gameplay:
- Load a 5.0-second duration using OUT 0x030.
- START, PAUSE, RESUME and RESET through OUT 0x031 using switches.
- Read back remaining time (IN 0x030) and RUNNING/DONE status (IN 0x031).
- Display time on HEX and DONE on an LED.
- Debounce / edge-detect switches so one hold is not interpreted as repeated actions.
- Ensure no software timer decrement or delay loop drives elapsed time.

Later, optionally develop a virtual-credit rocketship game as a separate program while keeping the same VHDL API.

Done when a tester can pause mid-countdown, leave it frozen, resume, and observe DONE.
