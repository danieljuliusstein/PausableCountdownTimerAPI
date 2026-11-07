-- Role 4: self-checking peripheral-level testbench.
-- This test is expected to FAIL until Roles 1-3 implement their stubs.
library ieee;
use ieee.std_logic_1164.all;

entity countdown_tb is
end entity countdown_tb;

architecture tb of countdown_tb is
    signal clock_s : std_logic := '0';
    signal resetn_s : std_logic := '0';
    signal addr_s : std_logic_vector(10 downto 0) := (others => '0');
    signal read_s : std_logic := '0';
    signal write_s : std_logic := '0';
    signal data_s : std_logic_vector(15 downto 0);
    signal host_data_s : std_logic_vector(15 downto 0) := (others => 'Z');
begin
    clock_s <= not clock_s after 5 ns;
    data_s <= host_data_s;

    dut : entity work.countdown_peripheral
        generic map (TICKS_PER_DECIS => 4)
        port map (
            CLOCK => clock_s, RESETN => resetn_s,
            IO_ADDR => addr_s, IO_READ => read_s,
            IO_WRITE => write_s, IO_DATA => data_s
        );

    stimulus : process
        procedure write_register(
            constant address : in std_logic_vector(10 downto 0);
            constant value   : in std_logic_vector(15 downto 0)
        ) is
        begin
            wait until falling_edge(clock_s);
            addr_s <= address;
            host_data_s <= value;
            write_s <= '1';
            wait until falling_edge(clock_s);
            write_s <= '0';
            host_data_s <= (others => 'Z');
        end procedure;
    begin
        wait for 20 ns;
        wait until falling_edge(clock_s);
        resetn_s <= '1';

        write_register("00000110000", x"0005");  -- 0x030: five ticks
        wait until falling_edge(clock_s);
        addr_s <= "00000110000";
        read_s <= '1';
        wait for 1 ns;
        assert data_s = x"0005"
            report "FAIL: loading duration must initialize remaining"
            severity failure;
        read_s <= '0';

        -- TODO(Role 4): assert start, pause mid-tick, resume, reset,
        -- expiration, sticky DONE, bus isolation, and invalid commands.
        report "Initial load test complete; implement all remaining cases"
            severity note;
        wait;
    end process;
end architecture tb;
