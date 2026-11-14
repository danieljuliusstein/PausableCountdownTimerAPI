-- I'll do this file (Tyler)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity countdown_core is
    port (
        CLOCK         : in  std_logic;
        RESETN        : in  std_logic; -- asynchronous system reset, active low
        LOAD_STROBE   : in  std_logic; -- duration write; core loads independently
        START_STROBE  : in  std_logic; -- START and RESUME share this command
        PAUSE_STROBE  : in  std_logic;
        RESET_STROBE  : in  std_logic; -- software reset: reload saved duration
        REMAINING     : in  std_logic_vector(15 downto 0);
        TICK_PULSE    : in  std_logic; -- core's tick-due indication before edge
        RUNNING       : out std_logic; -- state/status; see timing notes
        DONE          : out std_logic;
        RELOAD_STROBE : out std_logic; -- request core reload on this edge
        DECREMENT     : out std_logic  -- request core subtract one on this edge
    );
end entity countdown_core;

architecture behavioral of countdown_core is
    begin
        process(CLOCK)
            if rising_edge(CLOCK) then
                tick_reg <= '0';
            


-- ===============================================================
-- PERSON 1: COUNTDOWN CORE
-- File ownership: hardware/rtl/countdown_core.vhd
-- Status: ASSIGNMENT COMMENTS ONLY; NO IMPLEMENTATION YET
-- ===============================================================
--
-- GOAL
-- Build the reusable hardware that stores the countdown duration
-- and decreases the remaining value once per 0.1-second interval.
-- This module must NOT know anything about rockets or game rules.
--
-- REQUIRED BEHAVIOR
-- [ ] Store a 16-bit loaded/original duration.
-- [ ] Store a separate 16-bit remaining countdown value.
-- [ ] On LOAD, replace both values with the requested duration.
-- [ ] On RELOAD, restore remaining to the saved original duration.
-- [ ] Create a 0.1-second timing event from the SCOMP 10 MHz clock.
-- [ ] Make the divider configurable so simulation runs quickly.
-- [ ] Stop advancing the divider when the timer is paused.
-- [ ] Resume with the same fractional progress toward the next tick.
-- [ ] On a requested decrement, decrease remaining by exactly one.
-- [ ] Never decrement below zero or wrap back around.
-- [ ] Reset both registers and the divider when RESETN is asserted.
--
-- INTERFACE TO DISCUSS WITH PEOPLE 2 AND 3
-- [X] Inputs: CLOCK, RESETN, RUNNING, LOAD_STROBE, LOAD_VALUE,
--            RELOAD_STROBE, DECREMENT.
-- [X] Outputs: REMAINING, LOADED_VALUE, TICK_PULSE.
-- [ ] Agree on the timing of TICK_PULSE and DECREMENT before coding.
-- [ ] Decide command precedence when a new LOAD coincides with a tick.
--
-- TESTS / ACCEPTANCE
-- [ ] Loading 50 means 50 tenths of a second remaining.
-- [ ] Countdown only changes while RUNNING.
-- [ ] Pausing midway through a tick preserves both count and fraction.
-- [ ] Reload restores the saved duration; zero never underflows.
-- [ ] Hand the tests and timing assumptions to Person 4.
--
-- BEFORE IMPLEMENTING
-- Read docs/api-contract.md and docs/roles/01-countdown-core.md.
-- Do not rename shared ports without updating the team contract.
