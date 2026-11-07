; ===============================================================
; PERSON 5: SCOMP ASSEMBLY API DEMONSTRATION
; File ownership: software/CountdownDemo.asm
; Status: ASSIGNMENT COMMENTS ONLY; NO IMPLEMENTATION YET
; ===============================================================
;
; GOAL
; Write a small program demonstrating the reusable countdown API.
; Do NOT build the rocketship game yet. This is the API proof of use.
;
; EXISTING LAB 8 I/O ADDRESSES
; Switches = 0x000; LEDs = 0x001; HEX0 = 0x004; HEX1 = 0x005.
;
; PROPOSED NEW ADDRESSES (CHECK docs/api-contract.md)
; TimerValue   = 0x030: OUT duration, IN remaining.
; TimerControl = 0x031: OUT 0 pause, 1 start/resume, 2 reset.
;                        IN bit 0 RUNNING, bit 1 DONE.
;
; FEATURES TO IMPLEMENT
; [ ] On startup, load a five-second duration (50 deciseconds).
; [ ] Use a switch input to START the countdown.
; [ ] Use another switch input to PAUSE the countdown.
; [ ] Use a switch input to RESUME without reloading.
; [ ] Use a switch input to RESET to the originally loaded time.
; [ ] Read TIMER_VALUE and show remaining time on HEX displays.
; [ ] Read TIMER_CONTROL and show DONE on an LED.
; [ ] Prevent held switches from repeatedly firing commands.
; [ ] Use the hardware peripheral for all timing; no software
;     decrement loop and no counting iterations as time.
;
; DEMO ACCEPTANCE
; [ ] The display counts down while timer is RUNNING.
; [ ] The displayed time stays unchanged while PAUSED.
; [ ] RESUME continues from the frozen time.
; [ ] RESET restores the saved duration.
; [ ] DONE becomes visible at zero and stays asserted.
;
; COORDINATION
; [ ] Confirm final register addresses and command codes with Person 3.
; [ ] Coordinate switch/display pin mapping with Person 4.
; [ ] Assemble to the MIF expected by the actual SCOMP starter files.
; [ ] Later reuse the SAME API in the optional rocketship game.
;
; BEFORE IMPLEMENTING
; Read docs/api-contract.md and docs/roles/05-assembly-demo.md.
