# Architecture and ownership

~~~text
SCOMP CPU
  | IO_ADDR[10:0], IO_READ, IO_WRITE, IO_DATA[15:0]
  v
countdown_peripheral (Role 3, wiring)
  |
  +-- countdown_io (Role 3)
  |     writes: LOAD_VALUE, LOAD/START/PAUSE/RESET strobes
  |     reads:  REMAINING, RUNNING, DONE
  |
  +-- countdown_controller (Role 2)
  |     states: PAUSED, RUNNING, DONE
  |     outputs: DECREMENT, RELOAD
  |
  +-- countdown_core (Role 1)
        stores loaded and remaining values
        generates 0.1 s tick from 10 MHz while RUNNING

Quartus SCOMP_System integration + simulation (Role 4)
Assembly demonstration / game software (Role 5)
~~~

## Dependency boundaries

The API contract in docs/api-contract.md is the single source of truth. Core never knows about IO addresses, CPU instructions, rockets or balances. Controller never drives the shared bus. I/O never contains countdown timing logic. Person 4 owns .bdf/.qsf edits to avoid merge conflicts.

## First release versus later demo

Version 1 proves a reusable timer with the required commands and flags. A possible version 2 demo is a rocketship risk/reward game using virtual credits; crash probability and payout multipliers belong in assembly, not in this peripheral.
