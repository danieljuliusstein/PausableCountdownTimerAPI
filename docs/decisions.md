# Open design decisions

- [ ] Confirm proposed addresses 0x030 and 0x031 with group's I/O map.
- [ ] Confirm 0.1 s resolution is adequate for assignment/customer requirements.
- [ ] Confirm whether a zero-valued load sets DONE immediately or only after START (current contract: after START).
- [ ] Confirm whether RESET means reload-and-pause (current contract) or clear-to-zero.
- [ ] Confirm how OUT strobes are sampled on actual SCOMP timing.
- [ ] Confirm the permissions for sharing modified course starter files in this public repository.
- [ ] Select test/simulation environment and board check-off requirements.

When a decision is made, update docs/api-contract.md and the affected modules in the same PR.
