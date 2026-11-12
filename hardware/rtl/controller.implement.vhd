-- Implementation of countdown_controller

library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.stud_logic.arith.all;

entity controller is 
  port(
    clock  :        in    std_logic;
    resetn :        in    std_logic;
    load_strobe  :  in    std_logic;
    start_strobe:   in    std_logic;
    pause_strobe:   in    std_logic;
    reset_strobe:   in    std_logic;
    remaining:      in;  -- NOT SURE
    tick_pulse:     in    std_logic;
    running:        out   std_logic;
    done:           out   std_logic;
    reload_strobe:  out   std_logic;
    decrement:      out   std_logic;
  );
end controller;

architecture behavior of controller is
    type state_type is (
      clear, fetch, decode,
      paused, running, done
    );

    signal state : state_type;

begin
  
  process(clock, resetn)
  begin
  if (resetn = '0') then
    state <= paused;
  elsif (rising_edge(clock)) then
    case state is
      when paused =>
        
      when 
        
