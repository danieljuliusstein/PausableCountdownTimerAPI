# Contributing

This is one SCOMP peripheral with five role owners, not five standalone applications.

1. Agree on docs/api-contract.md **before** changing any entity port declarations, command meanings, or I/O addresses.
2. Branch from main, e.g. role1/countdown-core, role2/controller, role3/io, role4/integration, role5/assembly-demo.
3. Keep changes in your owned module when possible; coordinate changes to shared interfaces in a pull request.
4. Add test evidence in every PR: simulation assertions/waveforms, assembly output, or hardware check-off notes.
5. Ask one teammate working on a dependent module to review before merging.
6. Avoid simultaneous edits to the same Quartus .bdf / .qsf file; Person 4 coordinates these.
7. Do not push generated Quartus output, assembled .mif, or unpublished course-provided files without permission.

## Integration order

API contract -> Role 1 core + Role 2 controller + Role 3 I/O wrapper (parallel) -> Role 4 simulation/Quartus integration -> Role 5 hardware demo.

Roles 4 and 5 should start their test plans and assembly skeletons early, not wait until hardware is finished.

## Definition of done

- Port names and command behavior match docs/api-contract.md.
- Countdown uses the SCOMP 10 MHz clock domain and advances exactly once per 0.1 seconds while running.
- PAUSE preserves both remaining ticks and fractional tick progress.
- RESET reloads the saved duration and pauses.
- DONE is sticky on expiration until reset/load.
- Simulation includes load, run, pause, resume, reset, expiry, zero duration and bus address isolation.
- SCOMP demo can read status/time and uses hardware timing, not software delay loops.
