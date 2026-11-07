# Role 4 — Quartus integration and verification

Own hardware/quartus/ and hardware/sim/countdown_tb.vhd.

Implement:
- Prepare a legal local copy of the Lab 8 Quartus starter in hardware/quartus/course-starter/.
- Add the new VHDL sources to Quartus and generate peripheral symbol if required.
- Connect CLOCK (10 MHz), RESETN and I/O bus/address/read/write signals to the shared SCOMP system.
- Implement self-checking simulation for docs/test-plan.md, preferably with TICKS_PER_DECIS=4.
- Confirm non-selected peripherals do not drive the shared bus.
- Verify on FPGA and collect check-off results, waveform captures or photos as allowed.

IMPORTANT: starter files intentionally excluded from public repo pending course sharing permissions. Do not blindly overwrite SCOMP.vhd, existing TIMER.vhd, or its IP settings.

Done when simulations and board demo work and no older peripheral is broken.
