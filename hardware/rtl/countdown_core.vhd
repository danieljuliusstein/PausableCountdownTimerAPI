-- Role 1: countdown storage and tick generation.
-- SCAFFOLD ONLY: implement the marked logic before using on FPGA.
library ieee;
use ieee.std_logic_1164.all;

entity countdown_core is
    generic (
        TICKS_PER_DECIS : positive := 1000000  -- 10 MHz / 10 Hz
    );
    port (
        CLOCK         : in  std_logic;
        RESETN        : in  std_logic;
        RUNNING       : in  std_logic;
        LOAD_STROBE   : in  std_logic;
        LOAD_VALUE    : in  std_logic_vector(15 downto 0);
        RELOAD_STROBE : in  std_logic;
        DECREMENT     : in  std_logic;
        REMAINING     : out std_logic_vector(15 downto 0);
        LOADED_VALUE  : out std_logic_vector(15 downto 0);
        TICK_PULSE    : out std_logic
    );
end entity countdown_core;

architecture rtl of countdown_core is
begin
    -- TODO(Role 1): implement synchronous loaded and remaining registers.
    -- TODO(Role 1): implement divider, pausing fractional progress when RUNNING=0.
    -- TODO(Role 1): load/reload resets fractional divider; decrement saturates at zero.
    -- Deliberate inactive stub: this is NOT a working countdown implementation.
    REMAINING    <= (others => '0');
    LOADED_VALUE <= (others => '0');
    TICK_PULSE   <= '0';
end architecture rtl;
