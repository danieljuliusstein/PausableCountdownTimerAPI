library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This is a wrapper that connects countdown_io, countdown_controller and countdown_core
-- into one SCOMP peripheral at I/O addresses 0x030 / 0x031.
-- This is purely structural and has no processes or logic


entity countdown_peripheral is
    generic (
        -- The clock cycles 10MHz or 10000000 per second, 
        -- so .1 second = 10000000/10 = 1000000 cycles
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
    -- We instantiate the three modules and connect them together with the signals defined above. 
    cdio_inst : entity work.countdown_io
        port map (
            CLOCK => CLOCK,
            RESETN => RESETN,
            IO_ADDR => IO_ADDR,
            IO_READ => IO_READ,
            IO_WRITE => IO_WRITE,
            IO_DATA => IO_DATA,
            REMAINING => remaining,
            RUNNING => running,
            DONE => done,
            LOAD_STROBE => load_strobe,
            START_STROBE => start_strobe,
            PAUSE_STROBE => pause_strobe,
            RESET_STROBE => reset_strobe,
            LOAD_VALUE => load_value
        );

    cdctrl_inst : entity work.countdown_controller
        port map (
            CLOCK => CLOCK,
            RESETN => RESETN,
            LOAD_STROBE => load_strobe,
            START_STROBE => start_strobe,
            PAUSE_STROBE => pause_strobe,
            RESET_STROBE => reset_strobe,
            REMAINING => remaining,
            TICK_PULSE => tick_pulse,
            RUNNING => running,
            DONE => done,
            RELOAD_STROBE => reload_strobe,
            DECREMENT => decrement
        );
    
    cdcore_inst : entity work.countdown_core
        generic map (
            divider => TICKS_PER_DECIS
        )
        port map (
            CLOCK  => CLOCK,
            RESETN => RESETN,
            RUNNING => running,
            LOAD_STROBE => load_strobe,
            LOAD_VALUE => load_value,
            RELOAD_STROBE => reload_strobe,
            DECREMENT => decrement,
            REMAINING => remaining,
            LOADED_VALUE => open, -- unused output bc its not needed
            TICK_PULSE => tick_pulse
        );

end architecture structural;



-- ===============================================================
-- PERSON 3: PERIPHERAL TOP-LEVEL WRAPPER
-- File ownership: hardware/rtl/countdown_peripheral.vhd
-- Status: IMPLEMENTED
-- ===============================================================
--
-- GOAL
-- Connect the three independently developed modules into one
-- SCOMP peripheral that Person 4 can place in the Quartus system.
--
-- REQUIRED BEHAVIOR
-- [x] Instantiate Person 1's countdown_core.
-- [x] Instantiate Person 2's countdown_controller.
-- [x] Instantiate your countdown_io register/bus interface.
-- [x] Wire duration, remaining time, tick and command signals.
-- [x] Expose SCOMP clock, reset, address, read, write and data bus.
-- [x] Support a configurable tick-divider generic for fast tests.
-- [x] Keep rocket game calculations and assembly logic OUT of VHDL.
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
