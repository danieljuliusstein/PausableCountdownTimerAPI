; ============================================================
; PERSON 5: ROCKETSHIP GAME — FINAL ASSEMBLY INTEGRATION OWNER
; Status: COMMENT-ONLY TASK SCAFFOLD; NO GAME CODE YET
; Target: playable Nov 17, feature-complete Nov 19, 2026.
; ============================================================
;
; WEEK 2 RESPONSIBILITIES
; [ ] Initialize virtual credit balance and stake.
; [ ] Begin each rocket stage with TIMER_VALUE LOAD + START.
; [ ] Display rocket altitude/stage and remaining time.
; [ ] Handle CASH OUT before expiry and bank virtual payout.
; [ ] Handle RISK to enter multiplier stages.
; [ ] Merge crash/risk assembly logic from Person 2.
; [ ] Merge cash-out, switch and timer I/O from Person 3.
; [ ] Random crash or DONE timeout ends the unbanked round.
; [ ] PAUSE and RESUME freeze timer AND block game decisions.
; [ ] Show results and allow replay, preserving banked credits.
; [ ] Validate on FPGA with Person 4.
;
; Keep countdown timing in VHDL peripheral, NOT software loops.
; API: see docs/api-contract.md.
; IMPORTANT: separate staging .asm files might not be linkable by
; this course assembler. Merge all tested routines into this file.
