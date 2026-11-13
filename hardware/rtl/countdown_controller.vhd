library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity countdown_controller is
  port (
    -- these are the commands coming from the IO part
    CLOCK, RESETN, LOAD_STROBE, START_STROBE, PAUSE_STROBE,
      RESET_STROBE, TICK_PULSE : in std_logic;
    -- the controller checks this so it knows when the timer is done
    REMAINING : in std_logic_vector(15 downto 0);
    -- these tell the other parts what the controller wants to do
    RUNNING, DONE, RELOAD_STROBE, DECREMENT : out std_logic
  );
end entity;

architecture rtl of countdown_controller is
  -- the timer can only be in one of these three states
  type state_type is (PAUSED_STATE, RUNNING_STATE, DONE_STATE);
  signal state : state_type := PAUSED_STATE;

  -- these are one-clock pulses, so they get cleared every cycle
  signal reload_reg, dec_reg : std_logic := '0';
begin
  process (CLOCK, RESETN)
  begin
    -- reset puts everything back into the paused state
    if RESETN = '0' then
      state <= PAUSED_STATE;
      reload_reg <= '0';
      dec_reg <= '0';
    elsif rising_edge(CLOCK) then
      -- default these to zero so each command only lasts one clock
      reload_reg <= '0';
      dec_reg <= '0';

      -- load has the highest priority and also clears the done state
      if LOAD_STROBE = '1' then
        state <= PAUSED_STATE;

      -- reset tells the core to copy the original loaded value back
      elsif RESET_STROBE = '1' then
        reload_reg <= '1';
        state <= PAUSED_STATE;

      -- pausing does not change the remaining time
      elsif PAUSE_STROBE = '1' then
        if state = RUNNING_STATE then state <= PAUSED_STATE; end if;

      -- starting at zero goes straight to done instead of underflowing
      elsif START_STROBE = '1' then
        if unsigned(REMAINING) = 0 then
          state <= DONE_STATE;
        else
          state <= RUNNING_STATE;
        end if;

      -- every tick asks the core to subtract one from the count
      elsif state = RUNNING_STATE and TICK_PULSE = '1' then
        if unsigned(REMAINING) = 0 then
          state <= DONE_STATE;
        elsif unsigned(REMAINING) = 1 then
          -- this is the last decrement, so stop and set done too
          dec_reg <= '1';
          state <= DONE_STATE;
        else
          dec_reg <= '1';
        end if;
      end if;
    end if;
  end process;

  -- turn the current state into the two status bits software reads
  RUNNING <= '1' when state = RUNNING_STATE else '0';
  DONE <= '1' when state = DONE_STATE else '0';
  RELOAD_STROBE <= reload_reg;
  DECREMENT <= dec_reg;
end architecture;
