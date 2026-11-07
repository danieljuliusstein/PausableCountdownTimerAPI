; ============================================================
; PERSON 3: ROCKET INPUTS / CASH-OUT / TIMER I/O HANDOFF
; Status: COMMENT-ONLY TASK SCAFFOLD; NO CODE YET
; Target: hand off to Person 5 by Tue Nov 17, 2026.
; ============================================================
;
; [ ] Decide switch mapping for LAUNCH, PAUSE, RESUME,
;     CASH OUT, RISK, and replay with Person 5 and Person 4.
; [ ] Design switch edge detection for held buttons.
; [ ] Prepare SCOMP assembly routine(s) to LOAD/START/PAUSE/
;     RESUME the new timer and read REMAINING/DONE.
; [ ] Prepare CASH OUT input behavior and payout event signal.
; [ ] Ensure PAUSE prevents cash-out/risk decisions.
; [ ] Define RAM flags/inputs/outputs shared with Person 5.
; [ ] Check that no VHDL/peripheral changes are needed.
; [ ] Help integrate routines into software/RocketGame.asm.
;
; This is a staging/handoff file, NOT a standalone assembled
; binary. Person 5 merges tested routines into RocketGame.asm.
