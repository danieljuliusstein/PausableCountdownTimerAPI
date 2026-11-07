-- Role 3: SCOMP bus interface, addresses 0x030 and 0x031.
-- SCAFFOLD ONLY: decode and strobe logic intentionally not implemented.
library ieee;
use ieee.std_logic_1164.all;

entity countdown_io is
    port (
        CLOCK        : in    std_logic;
        RESETN       : in    std_logic;
        IO_ADDR      : in    std_logic_vector(10 downto 0);
        IO_READ      : in    std_logic;
        IO_WRITE     : in    std_logic;
        IO_DATA      : inout std_logic_vector(15 downto 0);
        REMAINING    : in    std_logic_vector(15 downto 0);
        RUNNING      : in    std_logic;
        DONE         : in    std_logic;
        LOAD_STROBE  : out   std_logic;
        LOAD_VALUE   : out   std_logic_vector(15 downto 0);
        START_STROBE : out   std_logic;
        PAUSE_STROBE : out   std_logic;
        RESET_STROBE : out   std_logic
    );
end entity countdown_io;

architecture rtl of countdown_io is
begin
    -- TODO(Role 3): selected READ must drive IO_DATA with remaining/status.
    -- TODO(Role 3): selected WRITE must pulse commands and capture load value.
    -- TODO(Role 3): leave IO_DATA high impedance at all other times.
    -- Deliberate inactive stub: this interface does NOT respond to I/O yet.
    IO_DATA      <= (others => 'Z');
    LOAD_STROBE  <= '0';
    LOAD_VALUE   <= (others => '0');
    START_STROBE <= '0';
    PAUSE_STROBE <= '0';
    RESET_STROBE <= '0';
end architecture rtl;
