; ==============================================================================
; PERSON 5: MASTER GAME LOOP & INTEGRATION COORDINATOR
; File: software/Person5_RocketGame_Master.asm
; Project: PausableCountdownTimerAPI Demonstration
; ==============================================================================
;
; INSTRUCTIONS FOR PERSON 5:
; 1. YOUR ROLE & RESPONSIBILITY:
;    You are the LEAD INTEGRATOR. You own the master assembly program and the
;    finite state machine (FSM) that ties all 4 teammates' subroutines together:
;       - Person 1 provides: Timer API calls (0x070 and 0x071).
;       - Person 2 provides: 30-value table and crash threshold engine.
;       - Person 3 provides: Switch reading (0x000), debounce, and cash-out input.
;       - Person 4 provides: 10-LED money meter (0x001) and HEX displays (0x004/0x005).
;
; 2. THE GAME LOOP (Survival / Bankruptcy Mechanics):
;    There is NO "Win" screen. The gameplay loop works as follows:
;       - Start of Round: Player has BankedCredits. Pressing SW0 launches the rocket.
;       - During Ascent: The rocket steps through 30 values. Money climbs on LEDs.
;                        Hardware timer decrements at 0x070.
;       - Player Choice: Player can Cash Out (SW1) at any time to bank their profit
;                        and safely live to play another round.
;       - Crash / Timeout: If player gets too greedy and reaches the crash threshold
;                          OR the timer reaches zero (DONE bit = 1), they bust and
;                          lose their stake for that round.
;       - Bankruptcy (Game Over): If BankedCredits reaches 0, player has lost all
;                                 their money. The game halts permanently in lockdown!
;
; 3. INTEGRATION STEP:
;    When your teammates finish testing their routines, you will copy/paste their
;    subroutines directly into the designated slots at the bottom of this file.
;    Then assemble with `scasm.exe` to generate the final MIF for Quartus!
;
; ==============================================================================

        ORG     0

; ==============================================================================
; STATE 0: PROGRAM INITIALIZATION
; ==============================================================================
MainInit:
        LOAD    InitialBank
        STORE   BankedCredits
        LOAD    InitialStake
        STORE   CurrentStake

        ; Initialize custom countdown timer peripheral (Person 1 API)
        CALL    Timer_LoadDuration

; ==============================================================================
; STATE 1: WAIT FOR LAUNCH (SW0)
; ==============================================================================
WaitLaunch:
        ; Display banked credits on HEX displays
        LOAD    BankedCredits
        OUT     Hex2_3
        LOAD    P5_Zero
        OUT     LEDs            ; Turn off LEDs while waiting for launch

        CALL    Inputs_Poll
        CALL    Inputs_CheckStart
        JZERO   WaitLaunch      ; Keep polling until SW0 is pressed

        ; Launch triggered! Start game round:
        CALL    Table_Init              ; Person 2: reset 30-value array index
        CALL    Table_GenCrashThreshold ; Person 2: roll random crash threshold
        CALL    Timer_LoadDuration      ; Person 1: write 60 deciseconds to 0x070
        CALL    Timer_Start             ; Person 1: write 1 to 0x071 (starts countdown)

; ==============================================================================
; STATE 2: GAME RUNNING (Ascending through 30 values)
; ==============================================================================
GameLoop:
        ; 1. Poll inputs and handle Pause toggle (SW2)
        CALL    Inputs_Poll
        CALL    Inputs_CheckPauseToggle

        ; If paused, loop here without advancing time or values:
        LOAD    GamePaused
        JPOS    GameLoop

        ; 2. Check for Cash Out (SW1)
        CALL    Inputs_CheckCashOut
        JPOS    StateCashOut

        ; 3. Read Hardware Timer status from PausableCountdownTimerAPI (0x070/0x071)
        CALL    Timer_PollStatus

        ; Check if countdown expired in hardware (Bit 1 of 0x071 set)
        LOAD    TimerDoneFlag
        JPOS    StateBustTimeout

        ; 4. Check if random crash cutoff index reached
        CALL    Table_CheckCrash
        LOAD    CrashFlag
        JPOS    StateBustCrash

        ; 5. Step to next money value in progression
        CALL    Table_StepNext

        ; 6. Update Visuals (LED money meter and HEX time/score)
        CALL    Display_UpdateLEDMoney
        CALL    Display_UpdateHEX

        JUMP    GameLoop

; ==============================================================================
; STATE 3: CASH-OUT SUCCESS (Player banked the round profit!)
; ==============================================================================
StateCashOut:
        CALL    Timer_Pause             ; Write 0 to 0x071 (freeze timer API)
        LOAD    BankedCredits
        ADD     CurrentMoney            ; Add locked-in profit to bank
        STORE   BankedCredits
        CALL    Display_AnimCashOut     ; Full LED flash celebration
        JUMP    StateReplay

; ==============================================================================
; STATE 4: BUST / CRASH / TIMEOUT (Player loses round stake)
; ==============================================================================
StateBustTimeout:
StateBustCrash:
        CALL    Timer_Pause             ; Write 0 to 0x071 (halt timer)
        LOAD    BankedCredits
        SUB     CurrentStake            ; Forfeit round stake
        STORE   BankedCredits
        CALL    Display_AnimCrash       ; Hazard alternating LED strobe

        ; Check for Bankruptcy (Game Over):
        LOAD    BankedCredits
        JPOS    StateReplay             ; If credits remain, allow new round
        JZERO   StateBankrupt           ; Exactly 0 -> Bankrupt!
        JUMP    StateBankrupt           ; Negative -> Bankrupt!

; ==============================================================================
; STATE 5: REPLAY / NEW ROUND (SW3)
; ==============================================================================
StateReplay:
        CALL    Inputs_Poll
        CALL    Inputs_CheckReset
        JZERO   StateReplay             ; Wait until SW3 is toggled

        CALL    Timer_Reset             ; Write 2 to 0x071 (reset timer API)
        JUMP    WaitLaunch              ; Return to launch screen with new bank

; ==============================================================================
; STATE 6: BANKRUPTCY / GAME OVER (Lost all money!)
; ==============================================================================
StateBankrupt:
        CALL    Display_AnimBankrupt    ; Turn off all LEDs, display 0000 on HEX
HaltForever:
        JUMP    HaltForever             ; Halts permanently until board reset!

; ==============================================================================
; SHARED RAM VARIABLES (Allocated once for all team routines)
; ==============================================================================
BankedCredits:   DW     100             ; Starting bankroll
CurrentStake:    DW     10              ; Stake per round
CurrentValueIdx: DW     0               ; Index into 30-value array (0..29)
CurrentMoney:    DW     0               ; Value looked up from array
CrashThreshold:  DW     24              ; Randomized crash cutoff
RemainingTicks:  DW     0               ; Deciseconds read from 0x070
TimerDoneFlag:   DW     0               ; Bit 1 of 0x071 (1 = done)
GamePaused:      DW     0               ; 0 = active, 1 = paused
CrashFlag:       DW     0               ; 1 = crashed, 0 = safe
PRNG_Seed:       DW     &HACE1          ; PRNG LFSR seed

InitialBank:     DW     100
InitialStake:    DW     10
P5_Zero:         DW     0

; ==============================================================================
; INTEGRATION SLOTS (Paste routines from Persons 1, 2, 3, 4 below)
; ==============================================================================

; --- [SLOT 1: PERSON 1 TIMER API SUBROUTINES (0x070 & 0x071)] ---
; (Paste subroutines from Person1_TimerAPI.asm here)

; --- [SLOT 2: PERSON 2 30-VALUE ARRAY & CRASH THRESHOLD SUBROUTINES] ---
; (Paste subroutines from Person2_MultiplierTable.asm here)

; --- [SLOT 3: PERSON 3 SWITCH CONTROLS & EDGE DETECTION (0x000)] ---
; (Paste subroutines from Person3_SwitchControls.asm here)

; --- [SLOT 4: PERSON 4 LED MONEY METER (0x001) & HEX DRIVERS (0x004/0x005)] ---
; (Paste subroutines from Person4_DisplaysLEDs.asm here)
