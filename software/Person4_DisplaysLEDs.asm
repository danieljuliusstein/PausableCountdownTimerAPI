; ==============================================================================
; PERSON 4: LED MONEY DISPLAY & HEX VISUAL FEEDBACK
; File: software/Person4_DisplaysLEDs.asm
; Project: PausableCountdownTimerAPI Demonstration
; ==============================================================================
;
; INSTRUCTIONS FOR PERSON 4:
; 1. YOUR ROLE & RESPONSIBILITY:
;    You own the visual feedback on the DE10-Lite FPGA board:
;       - Address 0x001 (LEDs): 10 red LEDs showing the climbing money thermometer!
;       - Address 0x004 (Hex0_1): 7-segment displays for remaining deciseconds.
;       - Address 0x005 (Hex2_3): 7-segment displays for current money or banked credits.
;
; 2. THERMOMETER LED MONEY METER:
;    There are 30 steps in Person 2's value progression and 10 LEDs.
;    Every 3 steps should illuminate an additional LED from bottom to top:
;       Index 0..2   -> 1 LED   (&H0001)
;       Index 3..5   -> 2 LEDs  (&H0003)
;       Index 6..8   -> 3 LEDs  (&H0007)
;       Index 9..11  -> 4 LEDs  (&H000F)
;       Index 12..14 -> 5 LEDs  (&H001F)
;       Index 15..17 -> 6 LEDs  (&H003F)
;       Index 18..20 -> 7 LEDs  (&H007F)
;       Index 21..23 -> 8 LEDs  (&H00FF)
;       Index 24..26 -> 9 LEDs  (&H01FF)
;       Index 27..29 -> 10 LEDs (&H03FF)  (MAXIMUM MULTIPLIER!)
;
; 3. WIN, CRASH & BANKRUPTCY ANIMATIONS:
;    - Cash Out Success: Flash all 10 LEDs to celebrate banking the money!
;    - Crash / Timeout:  Alternating hazard strobe (&H02AA vs &H0155).
;    - Bankruptcy / Game Over: Turn all LEDs OFF (&H0000), output zeros to HEX.
;
; 4. SUBROUTINES YOU PROVIDE:
;    - Display_UpdateLEDMoney: Translates CurrentValueIdx into the 10-LED thermometer.
;    - Display_UpdateHEX:      Outputs RemainingTicks to Hex0_1 and CurrentMoney to Hex2_3.
;    - Display_AnimCashOut:    Flashes LEDs upon successful cash-out.
;    - Display_AnimCrash:      Outputs hazard pattern upon crash or timer expiration.
;    - Display_AnimBankrupt:   Clears all LEDs and displays 0 on HEX when bank is lost.
;
; ==============================================================================

; --- I/O ADDRESSES ---
LEDs:           EQU     &H001
Hex0_1:         EQU     &H004
Hex2_3:         EQU     &H005

; ------------------------------------------------------------------------------
; SUBROUTINE: Display_UpdateLEDMoney
; Action: Looks up thermometer pattern matching CurrentValueIdx and writes to LEDs.
; ------------------------------------------------------------------------------
Display_UpdateLEDMoney:
        LOAD    CurrentValueIdx
        SUB     Step27
        JPOS    ShowLED_10
        JZERO   ShowLED_10

        LOAD    CurrentValueIdx
        SUB     Step24
        JPOS    ShowLED_9
        JZERO   ShowLED_9

        LOAD    CurrentValueIdx
        SUB     Step21
        JPOS    ShowLED_8
        JZERO   ShowLED_8

        LOAD    CurrentValueIdx
        SUB     Step18
        JPOS    ShowLED_7
        JZERO   ShowLED_7

        LOAD    CurrentValueIdx
        SUB     Step15
        JPOS    ShowLED_6
        JZERO   ShowLED_6

        LOAD    CurrentValueIdx
        SUB     Step12
        JPOS    ShowLED_5
        JZERO   ShowLED_5

        LOAD    CurrentValueIdx
        SUB     Step9
        JPOS    ShowLED_4
        JZERO   ShowLED_4

        LOAD    CurrentValueIdx
        SUB     Step6
        JPOS    ShowLED_3
        JZERO   ShowLED_3

        LOAD    CurrentValueIdx
        SUB     Step3
        JPOS    ShowLED_2
        JZERO   ShowLED_2

        ; Default (Steps 0..2): 1 LED
        LOAD    LED_Bar1
        OUT     LEDs
        RETURN

ShowLED_10:
        LOAD    LED_Bar10
        OUT     LEDs
        RETURN
ShowLED_9:
        LOAD    LED_Bar9
        OUT     LEDs
        RETURN
ShowLED_8:
        LOAD    LED_Bar8
        OUT     LEDs
        RETURN
ShowLED_7:
        LOAD    LED_Bar7
        OUT     LEDs
        RETURN
ShowLED_6:
        LOAD    LED_Bar6
        OUT     LEDs
        RETURN
ShowLED_5:
        LOAD    LED_Bar5
        OUT     LEDs
        RETURN
ShowLED_4:
        LOAD    LED_Bar4
        OUT     LEDs
        RETURN
ShowLED_3:
        LOAD    LED_Bar3
        OUT     LEDs
        RETURN
ShowLED_2:
        LOAD    LED_Bar2
        OUT     LEDs
        RETURN

; ------------------------------------------------------------------------------
; SUBROUTINE: Display_UpdateHEX
; Action: Outputs RemainingTicks to Hex0_1 and CurrentMoney to Hex2_3.
; ------------------------------------------------------------------------------
Display_UpdateHEX:
        LOAD    RemainingTicks
        OUT     Hex0_1
        LOAD    CurrentMoney
        OUT     Hex2_3
        RETURN

; ------------------------------------------------------------------------------
; SUBROUTINE: Display_AnimCashOut
; Action: Full LED bar illumination for banking round earnings.
; ------------------------------------------------------------------------------
Display_AnimCashOut:
        LOAD    LED_Bar10
        OUT     LEDs
        RETURN

; ------------------------------------------------------------------------------
; SUBROUTINE: Display_AnimCrash
; Action: Hazard strobe for a crash or countdown timeout.
; ------------------------------------------------------------------------------
Display_AnimCrash:
        LOAD    HazardPattern1
        OUT     LEDs
        RETURN

; ------------------------------------------------------------------------------
; SUBROUTINE: Display_AnimBankrupt
; Action: Turns all LEDs off and writes 0 to HEX displays (Game Over!).
; ------------------------------------------------------------------------------
Display_AnimBankrupt:
        LOAD    P4_Zero
        OUT     LEDs
        OUT     Hex0_1
        OUT     Hex2_3
        RETURN

; --- LED THERMOMETER PATTERNS ---
LED_Bar1:       DW      &H0001
LED_Bar2:       DW      &H0003
LED_Bar3:       DW      &H0007
LED_Bar4:       DW      &H000F
LED_Bar5:       DW      &H001F
LED_Bar6:       DW      &H003F
LED_Bar7:       DW      &H007F
LED_Bar8:       DW      &H00FF
LED_Bar9:       DW      &H01FF
LED_Bar10:      DW      &H03FF

HazardPattern1: DW      &H02AA  ; Alternating LEDs (1010101010)
HazardPattern2: DW      &H0155  ; Alternating LEDs (0101010101)

; Step constants:
Step3:          DW      3
Step6:          DW      6
Step9:          DW      9
Step12:         DW      12
Step15:         DW      15
Step18:         DW      18
Step21:         DW      21
Step24:         DW      24
Step27:         DW      27
P4_Zero:        DW      0
