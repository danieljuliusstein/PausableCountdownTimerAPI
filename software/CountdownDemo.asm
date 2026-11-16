; Pausable countdown API demonstration for SCOMP.
;
; Controls (commands fire once, after all switches are released):
;   SW0 = START/RESUME
;   SW1 = PAUSE
;   SW2 = RESET to the saved duration
;   SW3 = LOAD 5.0 seconds (50 deciseconds)
;
; The remaining decisecond count is written to HEX0. DONE is copied to
; LED1, matching status bit 1. All elapsed-time counting is done in VHDL.

        ORG     0

Init:
        LOAD    FiveSeconds
        OUT     TimerValue

; Refresh outputs continuously. A command is accepted only after the
; switches have returned to zero, so a held switch cannot repeat it.
Released:
        IN      TimerValue
        OUT     Hex0

        IN      TimerControl
        AND     DoneMask
        OUT     LEDs

        IN      Switches
        JZERO   Released

        AND     LoadMask
        JPOS    DoLoad

        IN      Switches
        AND     ResetMask
        JPOS    DoReset

        IN      Switches
        AND     PauseMask
        JPOS    DoPause

        IN      Switches
        AND     StartMask
        JPOS    DoStart

; Ignore undefined/multiple-switch input until it is released.
WaitRelease:
        IN      TimerValue
        OUT     Hex0
        IN      TimerControl
        AND     DoneMask
        OUT     LEDs
        IN      Switches
        JZERO   Released
        JUMP    WaitRelease

DoLoad:
        LOAD    FiveSeconds
        OUT     TimerValue
        JUMP    WaitRelease

DoReset:
        LOAD    ResetCommand
        OUT     TimerControl
        JUMP    WaitRelease

DoPause:
        LOAD    PauseCommand
        OUT     TimerControl
        JUMP    WaitRelease

DoStart:
        LOAD    StartCommand
        OUT     TimerControl
        JUMP    WaitRelease

; Data constants
FiveSeconds:   DW      50
PauseCommand:  DW      0
StartCommand:  DW      1
ResetCommand:  DW      2
StartMask:     DW      &H0001
PauseMask:     DW      &H0002
ResetMask:     DW      &H0004
LoadMask:      DW      &H0008
DoneMask:      DW      &H0002

; I/O constants. These match the Lab 8 map documented for this project.
Switches:      EQU     &H000
LEDs:          EQU     &H001
Hex0:          EQU     &H004
Hex1:          EQU     &H005
TimerValue:    EQU     &H030
TimerControl:  EQU     &H031
