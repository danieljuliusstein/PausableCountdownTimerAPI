library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity countdown_controller is
  port (
    CLOCK, RESETN, LOAD_STROBE, START_STROBE, PAUSE_STROBE,
      RESET_STROBE, TICK_PULSE : in std_logic;
    REMAINING : in std_logic_vector(15 downto 0);
    RUNNING, DONE, RELOAD_STROBE, DECREMENT : out std_logic
  );
end entity;

architecture rtl of countdown_controller is
  type state_type is (PAUSED_STATE, RUNNING_STATE, DONE_STATE);
  signal state : state_type := PAUSED_STATE;
  signal reload_reg, dec_reg : std_logic := '0';
begin
  process (CLOCK, RESETN)
  begin
    if RESETN = '0' then
      state <= PAUSED_STATE;
      reload_reg <= '0';
      dec_reg <= '0';
    elsif rising_edge(CLOCK) then
      reload_reg <= '0';
      dec_reg <= '0';

      -- Commands take priority over a coincident timing tick.
      if LOAD_STROBE = '1' then
        state <= PAUSED_STATE;
      elsif RESET_STROBE = '1' then
        reload_reg <= '1';
        state <= PAUSED_STATE;
      elsif PAUSE_STROBE = '1' then
        if state = RUNNING_STATE then state <= PAUSED_STATE; end if;
      elsif START_STROBE = '1' then
        if unsigned(REMAINING) = 0 then
          state <= DONE_STATE;
        else
          state <= RUNNING_STATE;
        end if;
      elsif state = RUNNING_STATE and TICK_PULSE = '1' then
        if unsigned(REMAINING) = 0 then
          state <= DONE_STATE;
        elsif unsigned(REMAINING) = 1 then
          dec_reg <= '1';
          state <= DONE_STATE;
        else
          dec_reg <= '1';
        end if;
      end if;
    end if;
  end process;

  RUNNING <= '1' when state = RUNNING_STATE else '0';
  DONE <= '1' when state = DONE_STATE else '0';
  RELOAD_STROBE <= reload_reg;
  DECREMENT <= dec_reg;
end architecture;
