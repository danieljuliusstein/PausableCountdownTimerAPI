; ==============================================================================
; PERSON 1: TIMER API INTERFACE & HARDWARE VERIFICATION
; File: software/Person1_TimerAPI.asm
; Project: PausableCountdownTimerAPI Demonstration
; ==============================================================================
;
; INSTRUCTIONS FOR PERSON 1:
; 1. YOUR ROLE & RESPONSIBILITY:
;    You are the hardware-to-software bridge for the custom countdown peripheral
;    built in this repository (see hardware/rtl/countdown_peripheral.vhd).
;    Your subroutines provide clean API calls that Person 5's master game loop
;    uses to control the hardware timer without running software delay loops.
;
; 2. THE HARDWARE API SPECIFICATION (Memory-Mapped I/O):
;    - Address 0x070 (TimerValue):
;        * WRITE: Loads duration in deciseconds (0.1s units), pauses the timer,
;                 and automatically clears the DONE flag.
;        * READ:  Returns the live remaining time in deciseconds (used by Person 4
;                 to update the HEX countdown display).
;    - Address 0x071 (TimerControl):
;        * WRITE 0: PAUSE command. Freezes the countdown and the 10 MHz tick divider.
;        * WRITE 1: START / RESUME command. Starts or resumes counting down.
;        * WRITE 2: RESET command. Reloads the initial duration and pauses.
;        * READ Bit 0 (Mask 0x0001): RUNNING status (1 = running, 0 = paused).
;        * READ Bit 1 (Mask 0x0002): DONE completion flag (1 = time expired!).
;
; 3. SUBROUTINES YOU PROVIDE:
;    - Timer_LoadDuration: Loads duration (e.g. 60 deciseconds = 6.0s) into 0x070.
;    - Timer_Start:        Writes 1 to 0x071 (begins countdown).
;    - Timer_Pause:        Writes 0 to 0x071 (called on SW2 pause or cash-out).
;    - Timer_Resume:       Writes 1 to 0x071 (resumes from where it left off).
;    - Timer_Reset:        Writes 2 to 0x071 (reloads saved duration).
;    - Timer_PollStatus:   Reads 0x070 into RemainingTicks and checks Bit 1 of 0x071,
;                          setting TimerDoneFlag = 1 if the countdown reached 0.
;
; 4. HARDWARE VERIFICATION (DE10-Lite FPGA):
;    Coordinate testing with Person 4 and Person 5:
;    - Verify that pausing mid-countdown holds the exact decisecond value indefinitely.
;    - Verify that a timeout (DONE = 1) correctly triggers a Bust / Crash.
;
; ==============================================================================

; --- I/O ADDRESS CONSTANTS (Defined in countdown_io.vhd) ---
TimerValue:      EQU     &H070
TimerControl:    EQU     &H071

; --- MASKS & COMMAND VALUES ---
TimerDoneMask:   DW      &H0002  ; Bit 1: DONE status
TimerRunMask:    DW      &H0001  ; Bit 0: RUNNING status

CmdPause:        DW      0       ; 0 = Pause
CmdStart:        DW      1       ; 1 = Start / Resume
CmdReset:        DW      2       ; 2 = Reset

DefaultDuration: DW      60      ; 60 deciseconds = 6.0 seconds per round

; ------------------------------------------------------------------------------
; SUBROUTINE: Timer_LoadDuration
; Action: Writes DefaultDuration (60 deciseconds) to TimerValue (0x070).
;         This resets the hardware countdown and clears DONE in hardware.
; ------------------------------------------------------------------------------
Timer_LoadDuration:
        LOAD    DefaultDuration
        OUT     TimerValue
        RETURN

; ------------------------------------------------------------------------------
; SUBROUTINE: Timer_Start
; Action: Writes START command (1) to TimerControl (0x071).
; ------------------------------------------------------------------------------
Timer_Start:
        LOAD    CmdStart
        OUT     TimerControl
        RETURN

; ------------------------------------------------------------------------------
; SUBROUTINE: Timer_Pause
; Action: Writes PAUSE command (0) to TimerControl (0x071).
;         Used when SW2 is toggled, when player cashes out, or on crash.
; ------------------------------------------------------------------------------
Timer_Pause:
        LOAD    CmdPause
        OUT     TimerControl
        RETURN

; ------------------------------------------------------------------------------
; SUBROUTINE: Timer_Resume
; Action: Writes RESUME command (1) to TimerControl (0x071).
; ------------------------------------------------------------------------------
Timer_Resume:
        LOAD    CmdStart
        OUT     TimerControl
        RETURN

; ------------------------------------------------------------------------------
; SUBROUTINE: Timer_Reset
; Action: Writes RESET command (2) to TimerControl (0x071).
; ------------------------------------------------------------------------------
Timer_Reset:
        LOAD    CmdReset
        OUT     TimerControl
        RETURN

; ------------------------------------------------------------------------------
; SUBROUTINE: Timer_PollStatus
; Action: Reads remaining deciseconds from 0x070 and stores into RemainingTicks.
;         Reads status from 0x071 and checks Bit 1 (DONE).
;         Sets TimerDoneFlag = 1 if expired, or 0 if still counting.
; ------------------------------------------------------------------------------
Timer_PollStatus:
        ; 1. Read live remaining time (deciseconds)
        IN      TimerValue
        STORE   RemainingTicks

        ; 2. Read control register and isolate Bit 1 (DONE)
        IN      TimerControl
        AND     TimerDoneMask
        JZERO   TimerActive

        ; Timer has reached zero:
        LOAD    P1_One
        STORE   TimerDoneFlag
        RETURN

TimerActive:
        LOAD    P1_Zero
        STORE   TimerDoneFlag
        RETURN

; Local helpers:
P1_Zero: DW      0
P1_One:  DW      1
