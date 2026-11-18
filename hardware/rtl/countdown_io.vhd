library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity countdown_io is
  port (
    -- these are the signals coming from the shared SCOMP IO bus
    CLOCK, RESETN, IO_READ, IO_WRITE : in std_logic;
    IO_ADDR : in std_logic_vector(10 downto 0);
    IO_DATA : inout std_logic_vector(15 downto 0);

    -- these values come back from the timer for IN instructions
    REMAINING : in std_logic_vector(15 downto 0);
    RUNNING, DONE : in std_logic;

    -- these are one-clock commands for the controller and core
    LOAD_STROBE, START_STROBE, PAUSE_STROBE,
      RESET_STROBE : out std_logic;
    LOAD_VALUE : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of countdown_io is
  -- the timer uses two addresses and leaves all the other ones alone
  constant TIMER_VALUE_ADDR : std_logic_vector(10 downto 0) :=
    std_logic_vector(to_unsigned(16#070#, 11));
  constant TIMER_CONTROL_ADDR : std_logic_vector(10 downto 0) :=
    std_logic_vector(to_unsigned(16#071#, 11));

  -- this remembers a write until IO_WRITE goes low again
  signal write_active : std_logic := '0';

  -- the output registers make every accepted write last one clock
  signal load_reg, start_reg, pause_reg, reset_reg : std_logic := '0';
  signal load_value_reg : std_logic_vector(15 downto 0) := (others => '0');
  signal status_value : std_logic_vector(15 downto 0);
begin
  process (CLOCK, RESETN)
  begin
    -- reset clears any command that may have been waiting
    if RESETN = '0' then
      write_active <= '0';
      load_reg <= '0';
      start_reg <= '0';
      pause_reg <= '0';
      reset_reg <= '0';
      load_value_reg <= (others => '0');
    elsif rising_edge(CLOCK) then
      -- commands default to zero so each one is only a one-clock pulse
      load_reg <= '0';
      start_reg <= '0';
      pause_reg <= '0';
      reset_reg <= '0';

      if IO_WRITE = '0' then
        -- another write can be accepted after the old one is finished
        write_active <= '0';
      elsif write_active = '0' then
        write_active <= '1';

        -- writing the value saves all 16 bits from the bus
        if IO_ADDR = TIMER_VALUE_ADDR then
          load_value_reg <= IO_DATA;
          load_reg <= '1';

        -- only zero, one, and two are valid control commands
        elsif IO_ADDR = TIMER_CONTROL_ADDR then
          case IO_DATA is
            when x"0000" => pause_reg <= '1';
            when x"0001" => start_reg <= '1';
            when x"0002" => reset_reg <= '1';
            when others => null;
          end case;
        end if;
      end if;
    end if;
  end process;

  -- software sees running in bit zero and done in bit one
  status_value <= (15 downto 2 => '0') & DONE & RUNNING;

  -- only this peripheral's selected reads are allowed to drive the bus
  IO_DATA <= REMAINING when IO_READ = '1' and IO_WRITE = '0' and
               IO_ADDR = TIMER_VALUE_ADDR else
             status_value when IO_READ = '1' and IO_WRITE = '0' and
               IO_ADDR = TIMER_CONTROL_ADDR else
             (others => 'Z');

  LOAD_STROBE <= load_reg;
  START_STROBE <= start_reg;
  PAUSE_STROBE <= pause_reg;
  RESET_STROBE <= reset_reg;
  LOAD_VALUE <= load_value_reg;
end architecture;
