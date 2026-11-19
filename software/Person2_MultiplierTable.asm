; ==============================================================================
; PERSON 2: 30-VALUE PROGRESSION TABLE & PRNG CRASH ENGINE
; File: software/Person2_MultiplierTable.asm
; Project: PausableCountdownTimerAPI Demonstration
; ==============================================================================
;
; INSTRUCTIONS FOR PERSON 2:
; 1. YOUR ROLE & RESPONSIBILITY:
;    You own the mathematical engine of the game:
;       a) An array of 30 increasing values in RAM representing climbing money.
;       b) The step-advance and lookup mechanism.
;       c) A 16-bit pseudo-random number generator (PRNG) to roll an unpredictable
;          crash threshold index for each round.
;
; 2. GAME MECHANIC CONTEXT (Survival / Push-Your-Luck):
;    There is NO "Win" screen. As the rocket ascends, the round's potential money
;    climbs through your 30 values. If the player cashes out (SW1), they bank the
;    current value. But if they wait too long and reach your randomized CrashThreshold,
;    the rocket crashes and they lose their stake!
;
; 3. SCOMP ARCHITECTURAL TIP:
;    SCOMP does NOT have hardware multiplication or division instructions.
;    By pre-calculating the 30 money values and storing them directly as DW constants,
;    your code runs instantaneously without complex division routines!
;
; 4. SUBROUTINES YOU PROVIDE:
;    - Table_Init:              Resets CurrentValueIdx to 0, loads initial money,
;                               and clears CrashFlag.
;    - Table_GenCrashThreshold: Uses PRNG_Seed to generate a random index between
;                               8 and 30, stored into CrashThreshold.
;    - Table_CheckCrash:        Compares CurrentValueIdx to CrashThreshold.
;                               If reached, sets CrashFlag = 1.
;    - Table_StepNext:          Advances CurrentValueIdx (0..29) and updates CurrentMoney.
;
; ==============================================================================

; ------------------------------------------------------------------------------
; SUBROUTINE: Table_Init
; Action: Resets CurrentValueIdx to 0, sets CurrentMoney to Value_00,
;         and clears CrashFlag.
; ------------------------------------------------------------------------------
Table_Init:
        LOAD    P2_Zero
        STORE   CurrentValueIdx
        STORE   CrashFlag
        LOAD    Value_00
        STORE   CurrentMoney
        RETURN

; ------------------------------------------------------------------------------
; SUBROUTINE: Table_GenCrashThreshold
; Action: Updates PRNG_Seed using a 16-bit LFSR / LCG algorithm.
;         Masks the result to a range between 8 and 30, storing into CrashThreshold.
; ------------------------------------------------------------------------------
Table_GenCrashThreshold:
        LOAD    PRNG_Seed
        SHIFT   1               ; Shift left
        ADD     PRNG_Seed       ; Multiply by 3
        ADD     P2_One          ; Add 1
        STORE   PRNG_Seed

        AND     Mask31          ; Extract lowest 5 bits (0 to 31)
        ADD     MinCrashOffset  ; Offset by 8 to guarantee at least a short climb
        SUB     MaxCap          ; Check if exceeds 30
        JPOS    CapThreshold
        ADD     MaxCap
        STORE   CrashThreshold
        RETURN

CapThreshold:
        LOAD    MaxCrashVal
        STORE   CrashThreshold
        RETURN

; ------------------------------------------------------------------------------
; SUBROUTINE: Table_CheckCrash
; Action: Compares CurrentValueIdx to CrashThreshold.
;         If CurrentValueIdx >= CrashThreshold, sets CrashFlag = 1.
; ------------------------------------------------------------------------------
Table_CheckCrash:
        LOAD    CurrentValueIdx
        SUB     CrashThreshold
        JPOS    TriggerCrash
        JZERO   TriggerCrash
        RETURN

TriggerCrash:
        LOAD    P2_One
        STORE   CrashFlag
        RETURN

; ------------------------------------------------------------------------------
; SUBROUTINE: Table_StepNext
; Action: Increments CurrentValueIdx. Caps at 29. Looks up pre-computed payout.
; ------------------------------------------------------------------------------
Table_StepNext:
        LOAD    CurrentValueIdx
        ADD     P2_One
        STORE   CurrentValueIdx
        ; Look up corresponding value from table (Person 2 completes table branch):
        ; Starter scaffold uses direct pointer or value mapping
        RETURN

; --- PRNG & THRESHOLD CONSTANTS ---
Mask31:         DW      &H001F
MinCrashOffset: DW      8
MaxCap:         DW      30
MaxCrashVal:    DW      28
P2_Zero:        DW      0
P2_One:         DW      1

; --- PRE-COMPUTED 30-VALUE PAYOUT PROGRESSION ---
; Starting from 10 credits wager, multiplying up to 50x:
Value_00: DW  10
Value_01: DW  11
Value_02: DW  12
Value_03: DW  14
Value_04: DW  16
Value_05: DW  18
Value_06: DW  21
Value_07: DW  24
Value_08: DW  28
Value_09: DW  32
Value_10: DW  37
Value_11: DW  43
Value_12: DW  50
Value_13: DW  58
Value_14: DW  67
Value_15: DW  77
Value_16: DW  88
Value_17: DW  101
Value_18: DW  115
Value_19: DW  131
Value_20: DW  149
Value_21: DW  169
Value_22: DW  191
Value_23: DW  216
Value_24: DW  244
Value_25: DW  275
Value_26: DW  310
Value_27: DW  350
Value_28: DW  400
Value_29: DW  500
