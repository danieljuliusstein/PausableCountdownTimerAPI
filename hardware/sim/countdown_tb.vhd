library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.env.all;

entity countdown_tb is
end entity;

architecture test of countdown_tb is
  constant CLOCK_PERIOD : time := 10 ns;
  constant TIMER_VALUE_ADDR : std_logic_vector(10 downto 0) :=
    std_logic_vector(to_unsigned(16#030#, 11));
  constant TIMER_CONTROL_ADDR : std_logic_vector(10 downto 0) :=
    std_logic_vector(to_unsigned(16#031#, 11));
  constant UNUSED_ADDR : std_logic_vector(10 downto 0) :=
    std_logic_vector(to_unsigned(16#032#, 11));
  constant Z_WORD : std_logic_vector(15 downto 0) := (others => 'Z');

  signal clock : std_logic := '0';
  signal resetn : std_logic := '0';
  signal io_addr : std_logic_vector(10 downto 0) := (others => '0');
  signal io_read, io_write : std_logic := '0';
  signal io_data : std_logic_vector(15 downto 0);
  signal cpu_data : std_logic_vector(15 downto 0) := (others => 'Z');
begin
  -- the CPU and the peripheral both connect to this resolved bus
  io_data <= cpu_data;

  clock <= not clock after CLOCK_PERIOD / 2;

  timer : entity work.countdown_peripheral
    generic map (
      TICKS_PER_DECIS => 4
    )
    port map (
      CLOCK => clock,
      RESETN => resetn,
      IO_ADDR => io_addr,
      IO_READ => io_read,
      IO_WRITE => io_write,
      IO_DATA => io_data
    );

  process
    -- waiting this way keeps every bus change between rising edges
    procedure wait_clocks(constant count : in positive) is
    begin
      for i in 1 to count loop
        wait until rising_edge(clock);
      end loop;
      wait for 1 ns;
    end procedure;

    procedure write_io(
      constant address_value : in std_logic_vector(10 downto 0);
      constant data_value : in std_logic_vector(15 downto 0);
      constant held_cycles : in positive := 1
    ) is
    begin
      io_addr <= address_value;
      cpu_data <= data_value;
      io_read <= '0';
      io_write <= '1';
      wait_clocks(held_cycles);

      io_write <= '0';
      cpu_data <= (others => 'Z');
      wait_clocks(1);
    end procedure;

    procedure read_io(
      constant address_value : in std_logic_vector(10 downto 0);
      variable data_value : out std_logic_vector(15 downto 0)
    ) is
    begin
      io_addr <= address_value;
      cpu_data <= (others => 'Z');
      io_write <= '0';
      io_read <= '1';
      wait for 1 ns;
      data_value := io_data;

      io_read <= '0';
      wait for 1 ns;
    end procedure;

    procedure check_value(
      constant expected : in natural;
      constant message_text : in string
    ) is
      variable value_read : std_logic_vector(15 downto 0);
    begin
      read_io(TIMER_VALUE_ADDR, value_read);
      assert value_read = std_logic_vector(to_unsigned(expected, 16))
        report message_text
        severity error;
    end procedure;

    procedure check_status(
      constant expected_running : in std_logic;
      constant expected_done : in std_logic;
      constant message_text : in string
    ) is
      variable status_read : std_logic_vector(15 downto 0);
      variable expected_status : std_logic_vector(15 downto 0);
    begin
      expected_status := (others => '0');
      expected_status(0) := expected_running;
      expected_status(1) := expected_done;
      read_io(TIMER_CONTROL_ADDR, status_read);
      assert status_read = expected_status
        report message_text
        severity error;
    end procedure;

    variable value_read : std_logic_vector(15 downto 0);
    variable paused_value : std_logic_vector(15 downto 0);
  begin
    -- reset starts with an empty timer that is paused and not done
    cpu_data <= (others => 'Z');
    io_read <= '0';
    io_write <= '0';
    resetn <= '0';
    wait_clocks(2);
    resetn <= '1';
    wait_clocks(1);
    check_value(0, "reset did not clear the remaining value");
    check_status('0', '0', "reset did not clear the timer status");

    -- nobody should drive the bus when there is no selected read
    assert io_data = Z_WORD
      report "IO_DATA was driven while IO_READ was low"
      severity error;
    io_addr <= UNUSED_ADDR;
    io_read <= '1';
    wait for 1 ns;
    assert io_data = Z_WORD
      report "the peripheral drove IO_DATA for an unused address"
      severity error;
    io_read <= '0';

    -- loading also proves that a write held high is only accepted once
    write_io(TIMER_VALUE_ADDR, x"0005", 3);
    check_value(5, "loading five did not update the remaining value");
    check_status('0', '0', "loading a value did not leave the timer paused");

    -- invalid commands and other addresses are supposed to do nothing
    write_io(TIMER_CONTROL_ADDR, x"1234");
    write_io(UNUSED_ADDR, x"0001");
    check_value(5, "an invalid or unselected write changed the timer");
    check_status('0', '0', "an invalid or unselected write changed status");

    -- start the timer and make sure it counts instead of staying at five
    write_io(TIMER_CONTROL_ADDR, x"0001");
    check_status('1', '0', "START did not put the timer in the running state");
    wait_clocks(8);
    read_io(TIMER_VALUE_ADDR, value_read);
    assert unsigned(value_read) < 5 and unsigned(value_read) > 0
      report "the running timer did not count down"
      severity error;

    -- pause must keep both the count and its partial tick progress
    write_io(TIMER_CONTROL_ADDR, x"0000");
    check_status('0', '0', "PAUSE did not stop the timer");
    read_io(TIMER_VALUE_ADDR, paused_value);
    wait_clocks(12);
    read_io(TIMER_VALUE_ADDR, value_read);
    assert value_read = paused_value
      report "the remaining value changed while the timer was paused"
      severity error;

    -- resuming should continue from the same value
    write_io(TIMER_CONTROL_ADDR, x"0001");
    wait_clocks(8);
    read_io(TIMER_VALUE_ADDR, value_read);
    assert unsigned(value_read) < unsigned(paused_value)
      report "RESUME did not continue the countdown"
      severity error;

    -- reset restores the last value that was loaded and pauses again
    write_io(TIMER_CONTROL_ADDR, x"0002");
    check_value(5, "RESET did not restore the loaded value");
    check_status('0', '0', "RESET did not pause and clear DONE");

    -- running long enough must stop exactly at zero without wrapping
    write_io(TIMER_CONTROL_ADDR, x"0001");
    wait_clocks(40);
    check_value(0, "the timer did not stop at zero");
    check_status('0', '1', "expiration did not set DONE and clear RUNNING");
    wait_clocks(12);
    check_value(0, "the expired timer wrapped below zero");
    check_status('0', '1', "DONE did not stay set after expiration");

    -- a new load clears DONE, including when the new value is zero
    write_io(TIMER_VALUE_ADDR, x"0000");
    check_status('0', '0', "a new load did not clear DONE");
    write_io(TIMER_CONTROL_ADDR, x"0001");
    check_value(0, "starting at zero caused an underflow");
    check_status('0', '1', "starting at zero did not set DONE");

    report "all countdown tests passed" severity note;
    finish;
  end process;
end architecture;
