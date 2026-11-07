-- Role 2: countdown control state machine.
-- SCAFFOLD ONLY: implement state transitions before using on FPGA.
library ieee;
use ieee.std_logic_1164.all;

entity countdown_controller is
    port (
        CLOCK         : in  std_logic;
        RESETN        : in  std_logic;
        LOAD_STROBE   : in  std_logic;
        START_STROBE  : in  std_logic;
        PAUSE_STROBE  : in  std_logic;
        RESET_STROBE  : in  std_logic;
        REMAINING     : in  std_logic_vector(15 downto 0);
        TICK_PULSE    : in  std_logic;
        RUNNING       : out std_logic;
        DONE          : out std_logic;
        RELOAD_STROBE : out std_logic;
        DECREMENT     : out std_logic
    );
end entity countdown_controller;

architecture rtl of countdown_controller is
begin
    -- TODO(Role 2): PAUSED / RUNNING / DONE finite state machine.
    -- TODO(Role 2): on tick with REMAINING=1, decrement and set sticky DONE.
    -- TODO(Role 2): LOAD / RESET / START / PAUSE priority per docs/api-contract.md.
    -- Deliberate inactive stub: this is NOT a working controller.
    RUNNING       <= '0';
    DONE          <= '0';
    RELOAD_STROBE <= '0';
    DECREMENT     <= '0';
end architecture rtl;
