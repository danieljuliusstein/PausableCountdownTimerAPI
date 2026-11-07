# Quartus / SCOMP Lab 8 integration (Role 4)

The user's Lab 8 archive is named SCOMP_Lab8_Fall25.zip. Its top-level diagram is SCOMP_System.bdf; the starter also contains SCOMP.vhd, TIMER.vhd, clk_div.vhd, I/O peripheral files, PLL IP and project settings.

**This public repository does not republish the course starter files.** Confirm permission to share them. For local development only, extract the starter project into hardware/quartus/course-starter/ (ignored by git), keeping its original relative layout. You can later add only allowed modified files or an integration patch.

Integration checklist:
1. Open SCOMP.qpf from the local extracted starter project.
2. Add ../ or absolute paths to hardware/rtl/countdown_core.vhd, countdown_controller.vhd, countdown_io.vhd, countdown_peripheral.vhd in Quartus settings. If copied to a new project directory, update paths accordingly.
3. Generate a symbol for countdown_peripheral and place it in SCOMP_System.bdf.
4. Wire CLOCK to the 10 MHz SCOMP clock, RESETN to the active-low reset, IO_ADDR[10..0], IO_READ, IO_WRITE, and IO_DATA[15..0] to the existing shared bus.
5. Confirm no other peripheral uses 0x030/0x031.
6. Recompile and check for no multiple-driver or width-mismatch errors.
7. Assemble CountdownDemo.asm and make sure the assembled MIF filename matches the init_file expected by SCOMP.vhd.

Starter inspection notes: SCOMP.vhd in the uploaded version refers to SimpleDemo.mif; ensure a matching generated MIF exists. It also contains an unusual ADD decode literal "0004"; investigate any Quartus syntax error before debugging the peripheral.

Use the local Quartus pin mapping and board setup from the provided starter. Do not commit db/, output_files/, generated PLL simulation output, or instructor-owned source without permission.
