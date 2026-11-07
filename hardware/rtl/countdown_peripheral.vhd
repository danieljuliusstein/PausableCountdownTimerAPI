-- Role 3: structural wrapper for the three role-owned modules.
-- Port naming follows Lab 8 SCOMP peripheral conventions.
library ieee;
use ieee.std_logic_1164.all;

entity countdown_peripheral is
    generic (
        TICKS_PER_DECIS : positive := 1000000
    );
    port (
        CLOCK    : in    std_logic;
        RESETN   : in    std_logic;
        IO_ADDR  : in    std_logic_vector(10 downto 0);
        IO_READ  : in    std_logic;
        IO_WRITE : in    std_logic;
        IO_DATA  : inout std_logic_vector(15 downto 0)
    );
end entity countdown_peripheral;

architecture structural of countdown_peripheral is
    signal remaining_s, loaded_s, load_value_s : std_logic_vector(15 downto 0);
    signal load_s, start_s, pause_s, reset_s : std_logic;
    signal reload_s, decrement_s, tick_s : std_logic;
    signal running_s, done_s : std_logic;
begin
    bus_interface : entity work.countdown_io
        port map (
            CLOCK => CLOCK, RESETN => RESETN, IO_ADDR => IO_ADDR,
            IO_READ => IO_READ, IO_WRITE => IO_WRITE, IO_DATA => IO_DATA,
            REMAINING => remaining_s, RUNNING => running_s, DONE => done_s,
            LOAD_STROBE => load_s, LOAD_VALUE => load_value_s,
            START_STROBE => start_s, PAUSE_STROBE => pause_s,
            RESET_STROBE => reset_s
        );

    timer_control : entity work.countdown_controller
        port map (
            CLOCK => CLOCK, RESETN => RESETN, LOAD_STROBE => load_s,
            START_STROBE => start_s, PAUSE_STROBE => pause_s,
            RESET_STROBE => reset_s, REMAINING => remaining_s,
            TICK_PULSE => tick_s, RUNNING => running_s, DONE => done_s,
            RELOAD_STROBE => reload_s, DECREMENT => decrement_s
        );

    timer_core : entity work.countdown_core
        generic map (TICKS_PER_DECIS => TICKS_PER_DECIS)
        port map (
            CLOCK => CLOCK, RESETN => RESETN, RUNNING => running_s,
            LOAD_STROBE => load_s, LOAD_VALUE => load_value_s,
            RELOAD_STROBE => reload_s, DECREMENT => decrement_s,
            REMAINING => remaining_s, LOADED_VALUE => loaded_s,
            TICK_PULSE => tick_s
        );
end architecture structural;
