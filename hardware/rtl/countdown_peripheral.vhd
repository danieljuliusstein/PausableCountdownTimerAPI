library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This is a wrapper that connects countdown_io, countdown_controller and countdown_core
-- into one SCOMP peripheral at I/O addresses 0x030 / 0x031.
-- This is purely structural and has no processes or logic


entity countdown_peripheral is
    generic (
        -- Since the clock cycles every .1 s with 10 MHz, we get 1000000 ticks per cycle.
        -- Goes into the countdown_core
        TICKS_PER_DECIS : positive := 1000000
    );
    port (
        -- What gets connected to the SCOMP
        CLOCK    : in std_logic;  
        RESETN   : in std_logic;
        IO_ADDR  : in std_logic_vector(10 downto 0);
        IO_READ  : in std_logic; 
        IO_WRITE : in std_logic; 
        IO_DATA  : inout std_logic_vector(15 downto 0) 
    );
end entity countdown_peripheral;

architecture structural of countdown_peripheral is

    -- Wires that are driven by countdown_io
    signal load_strobe  : std_logic;
    signal start_strobe : std_logic;
    signal pause_strobe : std_logic;
    signal reset_strobe : std_logic;
    signal load_value   : std_logic_vector(15 downto 0);

    -- Wires that are driven by countdown_controller
    signal running       : std_logic;
    signal done          : std_logic;
    signal reload_strobe : std_logic;
    signal decrement     : std_logic;

    -- Wires that are driven by countdown_core
    signal remaining  : std_logic_vector(15 downto 0);
    signal tick_pulse : std_logic;

begin

    

end architecture structural;



-- ===============================================================
-- PERSON 3: PERIPHERAL TOP-LEVEL WRAPPER
-- File ownership: hardware/rtl/countdown_peripheral.vhd
-- Status: ASSIGNMENT COMMENTS ONLY; NO IMPLEMENTATION YET
-- ===============================================================
--
-- GOAL
-- Connect the three independently developed modules into one
-- SCOMP peripheral that Person 4 can place in the Quartus system.
--
-- REQUIRED BEHAVIOR
-- [ ] Instantiate Person 1's countdown_core.
-- [ ] Instantiate Person 2's countdown_controller.
-- [ ] Instantiate your countdown_io register/bus interface.
-- [ ] Wire duration, remaining time, tick and command signals.
-- [ ] Expose SCOMP clock, reset, address, read, write and data bus.
-- [ ] Support a configurable tick-divider generic for fast tests.
-- [ ] Keep rocket game calculations and assembly logic OUT of VHDL.
--
-- INTEGRATION HANDOFF TO PERSON 4
-- [ ] Agree on top-level port names and bit widths.
-- [ ] Confirm SCOMP uses 10 MHz CLOCK and active-low RESETN.
-- [ ] Explain whether IO_DATA is driven or tri-stated on each read.
-- [ ] Provide a Quartus-compatible peripheral symbol/interface.
-- [ ] Document any shared interface changes in api-contract.md.
--
-- TESTS / ACCEPTANCE
-- [ ] All three hardware modules connect with no width mismatch.
-- [ ] Register commands affect countdown only as specified.
-- [ ] Reading remaining and status does not alter timer state.
--
-- BEFORE IMPLEMENTING
-- Read docs/api-contract.md and docs/roles/03-io-interface.md.
