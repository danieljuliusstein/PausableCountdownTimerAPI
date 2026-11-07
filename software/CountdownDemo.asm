; Role 5: SCOMP assembly demo starter.
; SCAFFOLD ONLY — no game and no working control loop yet.
; Goal: demonstrate hardware LOAD, START, PAUSE, RESUME, RESET and DONE.
;
; Proposed I/O values (see docs/api-contract.md):
;   TimerValue   0x030 : WRITE duration / READ remaining
;   TimerControl 0x031 : WRITE 0 pause, 1 start/resume, 2 reset
;                       READ bit 0 RUNNING, bit 1 DONE
;
ORG 0
Init:
    ; Initial 5-second count (50 deciseconds).
    LOADI 50
    OUT TimerValue

MainLoop:
    ; TODO(Role 5): read Switches and edge-detect buttons.
    ; TODO(Role 5): issue PAUSE/START/RESET based on switches.
    ; TODO(Role 5): read current remaining time and write to Hex0.
    ; TODO(Role 5): read DONE status and display on LED.
    ; Do not count down in software.
    JUMP MainLoop

; Lab 8 existing peripherals:
Switches:     EQU &H000
LEDs:         EQU &H001
Hex0:         EQU &H004
Hex1:         EQU &H005

; New countdown peripheral:
TimerValue:   EQU &H030
TimerControl: EQU &H031
