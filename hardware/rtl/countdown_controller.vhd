library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Commands are synchronous one-clock pulses produced by countdown_io.
-- Core samples DECREMENT/RELOAD_STROBE on the same edge as this FSM.
entity countdown_controller is
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
end entity countdown_controller;

architecture rtl of countdown_controller is
    type state_type is (PAUSED, RUNNING_STATE, DONE_STATE);
    signal state, next_state : state_type;
begin
    process (CLOCK, RESETN)
    begin
        if RESETN = '0' then
            state <= PAUSED;
        elsif rising_edge(CLOCK) then
            state <= next_state;
        end if;
    end process;

    -- Defaults make every output defined and prevent inferred latches.
    process (state, RESETN, LOAD_STROBE, START_STROBE, PAUSE_STROBE,
             RESET_STROBE, REMAINING, TICK_PULSE)
    begin
        next_state <= state;
        RUNNING <= '0';
        DONE <= '0';
        RELOAD_STROBE <= '0';
        DECREMENT <= '0';

        if RESETN = '1' then
            if state = RUNNING_STATE then
                RUNNING <= '1';
            elsif state = DONE_STATE then
                DONE <= '1';
            end if;

            -- LOAD > RESET > PAUSE > START > tick. The I/O decoder normally
            -- emits only one command; the priority also defines collisions.
            if LOAD_STROBE = '1' then
                next_state <= PAUSED;
            elsif RESET_STROBE = '1' then
                RELOAD_STROBE <= '1';
                next_state <= PAUSED;
            elsif PAUSE_STROBE = '1' then
                -- DONE is sticky: PAUSE cannot acknowledge expiration.
                if state /= DONE_STATE then
                    next_state <= PAUSED;
                end if;
            elsif START_STROBE = '1' then
                if state = PAUSED then
                    if unsigned(REMAINING) = 0 then
                        next_state <= DONE_STATE;
                    else
                        next_state <= RUNNING_STATE;
                    end if;
                end if;
            elsif state = RUNNING_STATE then
                if unsigned(REMAINING) = 0 then
                    next_state <= DONE_STATE;
                elsif TICK_PULSE = '1' then
                    DECREMENT <= '1';
                    if unsigned(REMAINING) = 1 then
                        next_state <= DONE_STATE;
                    end if;
                end if;
            end if;
        end if;
    end process;
end architecture rtl;
