library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity countdown_core is
    generic (
        -- makes the divider configurable so simulation runs quickly
        divider    : positive := 1000000  -- clock cycles per 1/10s (10 MHz * 0.1s = 1M cycles)
    );
    port (
        CLOCK         : in    std_logic;
        RESETN        : in    std_logic; 
        RUNNING       : in    std_logic; 
        LOAD_STROBE   : in    std_logic; 
        LOAD_VALUE    : in    std_logic_vector(15 downto 0);
        RELOAD_STROBE : in    std_logic;
        DECREMENT     : in    std_logic;
        REMAINING     : out   std_logic_vector(15 downto 0);
        LOADED_VALUE  : out   std_logic_vector(15 downto 0);
        TICK_PULSE    : out   std_logic
    );
end entity countdown_core;

architecture behavioral of countdown_core is
    signal current_duration    :    unsigned(15 downto 0);    -- stores a 16-bit loaded/original duration
    signal remaining_duration  :    unsigned(15 downto 0);    -- stores a 16-bit remaining countdown value
    signal tick_progress       :    integer range 0 to divider - 1;
begin
    -- creates a 0.1-second timing event from the SCOMP 10 MHz clock
    TICK_PULSE <= '1' when (RUNNING = '1') and (tick_progress = divider - 1) else '0';
    process(CLOCK, RESETN)
    begin
        -- resets both registers and the divider when RESETN is asserted
        if (RESETN = '0') then
            current_duration <= to_unsigned(0, 16);
            remaining_duration <= to_unsigned(0, 16);
            tick_progress <= 0;
        elsif rising_edge(CLOCK) then
            -- stops advancing the divider when the timer is paused
            if (LOAD_STROBE = '1') or (RELOAD_STROBE = '1') then
                tick_progress <= 0;
            -- resumes with the same fractional progress toward the next tick
            elsif (RUNNING = '1') then
                if (tick_progress = divider - 1) then
                    tick_progress <= 0;
                else
                    tick_progress <= tick_progress + 1;
                end if;
            end if;
            -- on LOAD, replaces both values with the requested duration
            if (LOAD_STROBE = '1') then
                current_duration <= unsigned(LOAD_VALUE);
                remaining_duration <= unsigned(LOAD_VALUE);
            -- on RELOAD, restores remaining to the saved original duration
            elsif (RELOAD_STROBE = '1') then
                remaining_duration <= current_duration;
            -- on a requested decrement, decreases remaining by exactly one
            elsif (DECREMENT = '1') and (RUNNING = '1') then
                -- never decrements below zero or wrap back around
                if (remaining_duration > 0) then
                    remaining_duration <= remaining_duration - 1;
                end if;
            end if;
        end if;
    end process;

    LOADED_VALUE <= std_logic_vector(current_duration);
    REMAINING    <= std_logic_vector(remaining_duration);
                    
end architecture behavioral;
