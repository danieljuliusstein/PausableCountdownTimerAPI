# Acceptance test plan (Role 4 leads; all roles contribute)

Use a fast divider in simulation by setting TICKS_PER_DECIS to a small positive value (e.g. 4). Test the real 1,000,000 clock cycles/decisecond behavior separately or on board.

| Test | Stimulus | Expected |
| --- | --- | --- |
| Reset | RESETN=0 | loaded=0, remaining=0, RUNNING=0, DONE=0 |
| Load | OUT 50 to 0x030 | remaining=50, paused, DONE cleared |
| Start | OUT 1 to 0x031 | RUNNING=1, count decreases on tick |
| Pause | OUT 0 to 0x031 | RUNNING=0, remaining stable for multiple tick periods |
| Partial tick pause | pause partway through divider cycle | resume preserves fractional tick progress |
| Resume | OUT 1 to 0x031 | counts down from same value |
| Reset command | OUT 2 to 0x031 | restores last loaded duration; paused |
| Expiry | run from 1 tick to zero | remaining=0, RUNNING=0, DONE=1 |
| Sticky done | wait after expiry | stays 0 and DONE stays 1 |
| Reload clears done | load nonzero value | DONE=0 |
| Zero duration | load 0, issue START | no underflow, DONE=1 |
| Non-selected addresses | read/write other address | does not respond or alter state |
| Bus isolation | IO_READ=0 | countdown IO driver is Z |
| Invalid commands | write command other than 0/1/2 | no effect |

Follow up with a Quartus integration test: the existing switches, LEDs, timer and HEX displays must still work. Verify actual I/O clock timing in the Lab 8 SCOMP processor.

**Current state:** testbench is a skeleton; pass/fail has not been demonstrated.
