-- Implementation of countdown_controller

library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.stud_logic.arith.all;

entity SCOMP is 
  port(
    clock  :  in    std_logic;
    resetn :  in    std_logic;
  );
end SCOMP;

architecture a of SCOMP is
    type state_type is (
      init, fetch, decode,
    
    );

  begin
  process(clock, resetn)
  begin

