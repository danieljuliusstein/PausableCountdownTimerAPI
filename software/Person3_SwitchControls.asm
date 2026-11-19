; ==============================================================================
; PERSON 3: SWITCH INPUTS, DEBOUNCING & CONTROL LOGIC
; File: software/Person3_SwitchControls.asm
; Project: PausableCountdownTimerAPI Demonstration
; ==============================================================================
;
; INSTRUCTIONS FOR PERSON 3:
; 1. YOUR ROLE & RESPONSIBILITY:
;    You own the player input interface at I/O address 0x000 (Switches).
;    Your job is to cleanly decode the player's physical button actions:
;       - SW0 (Bit 0): LAUNCH / START (Begins round and hardware countdown)
;       - SW1 (Bit 1): CASH OUT (Locks in CurrentMoney, banks credits, ends round)
;       - SW2 (Bit 2): PAUSE / RESUME (Calls Person 1's Timer_Pause/Timer_Resume)
;       - SW3 (Bit 3): NEW ROUND / REPLAY (Resets round state after Cash Out or Bust)
;
; 2. EDGE DETECTION & DEBOUNCING:
;    The SCOMP CPU runs at 10 MHz. If you poll switches without edge detection,
;    a single human switch flip will trigger thousands of times per second!
;    You must ensure that a switch only registers a command ONCE per press
;    (detecting the rising 0 -> 1 edge, or waiting for release back to 0).
;
; 3. PAUSE INTERLOCK (ANTI-CHEAT):
;    When GamePaused = 1, SW1 (Cash Out) and SW0 (Start) MUST be disabled.
;    A player cannot be allowed to pause time and then cash out risk-free!
;
; 4. SUBROUTINES YOU PROVIDE:
;    - Inputs_Poll:             Reads 0x000, detects new rising edges, updates NewPresses.
;    - Inputs_CheckStart:       Returns AC = 1 if SW0 was newly pressed.
;    - Inputs_CheckCashOut:     Returns AC = 1 if SW1 was pressed AND GamePaused == 0.
;    - Inputs_CheckPauseToggle: Checks SW2; if toggled, flips GamePaused (0 <-> 1)
;                               and calls Timer_Pause or Timer_Resume.
;    - Inputs_CheckReset:       Returns AC = 1 if SW3 was pressed (new round).
;
; ==============================================================================

; --- I/O ADDRESS ---
Switches:        EQU     &H000

; --- SWITCH BIT MASKS ---
SW0_StartMask:   DW      &H0001  ; Bit 0
SW1_CashOutMask: DW      &H0002  ; Bit 1
SW2_PauseMask:   DW      &H0004  ; Bit 2
SW3_ResetMask:   DW      &H0008  ; Bit 3

; --- EDGE DETECTION STORAGE ---
PrevSwitches:    DW      0
CurrSwitches:    DW      0
NewPresses:      DW      0

; ------------------------------------------------------------------------------
; SUBROUTINE: Inputs_Poll
; Action: Reads Switches (0x000). Detects fresh transitions so held switches
;         do not spam commands.
; ------------------------------------------------------------------------------
Inputs_Poll:
        IN      Switches
        STORE   CurrSwitches

        ; If all switches are released (0), clear history:
        LOAD    CurrSwitches
        JZERO   ClearEdgeHistory

        ; If switch is held and was already processed, ignore:
        LOAD    PrevSwitches
        JPOS    NoNewEdgeDetected

        ; New switch activation detected:
        LOAD    CurrSwitches
        STORE   PrevSwitches
        STORE   NewPresses
        RETURN

ClearEdgeHistory:
        LOAD    P3_Zero
        STORE   PrevSwitches
        STORE   NewPresses
        RETURN

NoNewEdgeDetected:
        LOAD    P3_Zero
        STORE   NewPresses
        RETURN

; ------------------------------------------------------------------------------
; SUBROUTINE: Inputs_CheckCashOut
; Returns: AC = 1 if SW1 was pressed AND game is NOT paused, else AC = 0.
; ------------------------------------------------------------------------------
Inputs_CheckCashOut:
        ; Anti-cheat: cannot cash out while game is paused!
        LOAD    GamePaused
        JPOS    DenyCashOut

        LOAD    NewPresses
        AND     SW1_CashOutMask
        JPOS    AllowCashOut
        LOAD    P3_Zero
        RETURN

AllowCashOut:
        LOAD    P3_One
        RETURN

DenyCashOut:
        LOAD    P3_Zero
        RETURN

; ------------------------------------------------------------------------------
; SUBROUTINE: Inputs_CheckPauseToggle
; Action: Checks if SW2 was pressed. If so, toggles GamePaused (0 <-> 1)
;         and calls Person 1's Timer_Pause (0x071 <= 0) or Timer_Resume (0x071 <= 1).
; ------------------------------------------------------------------------------
Inputs_CheckPauseToggle:
        LOAD    NewPresses
        AND     SW2_PauseMask
        JZERO   NoPauseToggleDetected

        ; Toggle state:
        LOAD    GamePaused
        JZERO   TriggerPause

        ; Currently paused -> Unpause:
        LOAD    P3_Zero
        STORE   GamePaused
        CALL    Timer_Resume
        RETURN

TriggerPause:
        LOAD    P3_One
        STORE   GamePaused
        CALL    Timer_Pause
        RETURN

NoPauseToggleDetected:
        RETURN

; ------------------------------------------------------------------------------
; SUBROUTINE: Inputs_CheckStart
; Returns: AC = 1 if SW0 was pressed, else 0.
; ------------------------------------------------------------------------------
Inputs_CheckStart:
        LOAD    NewPresses
        AND     SW0_StartMask
        JPOS    StartFired
        LOAD    P3_Zero
        RETURN

StartFired:
        LOAD    P3_One
        RETURN

; ------------------------------------------------------------------------------
; SUBROUTINE: Inputs_CheckReset
; Returns: AC = 1 if SW3 was pressed, else 0.
; ------------------------------------------------------------------------------
Inputs_CheckReset:
        LOAD    NewPresses
        AND     SW3_ResetMask
        JPOS    ResetFired
        LOAD    P3_Zero
        RETURN

ResetFired:
        LOAD    P3_One
        RETURN

P3_Zero: DW 0
P3_One:  DW 1
