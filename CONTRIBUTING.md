# Contributing

This is one SCOMP peripheral split across five roles. **All .vhd and .asm files currently contain comments only**; each assigned developer is expected to write the real implementation.

1. Agree on docs/api-contract.md before adding entities, port declarations, command logic or I/O addresses.
2. Branch from main after the scaffold PR is merged, e.g. role1/countdown-core, role2/controller, role3/io, role4/integration, role5/assembly-demo.
3. Read the in-file comments for your role, then implement the checklist. Coordinate shared ports and signal naming in a PR.
4. Add test evidence in every PR: simulation assertions/waveforms, assembly output, or hardware check-off notes.
5. Ask someone working on a dependent module to review before merging.
6. Avoid simultaneous edits to the same Quartus .bdf / .qsf; Person 4 coordinates these.
7. Do not push generated Quartus output, assembled .mif, or unpublished course-provided files without permission.

## Integration order

API contract -> Role 1 core + Role 2 controller + Role 3 I/O interface (parallel) -> Role 4 simulation/Quartus integration -> Role 5 working assembly demo.

Roles 4 and 5 can prepare verification scenarios and demo design while hardware is being implemented.

## Definition of done

- Functional implementations replace the comment-only assignments.
- Ports and command behavior match docs/api-contract.md.
- Hardware maintains 0.1-second tick timing, including pause/resume fraction preservation.
- RESET reloads the saved duration and pauses.
- DONE is sticky on expiration until reset/load.
- Simulation covers load, run, pause, resume, reset, expiry, zero duration and address isolation.
- SCOMP demo can read status/time and uses hardware timing rather than software delays.
