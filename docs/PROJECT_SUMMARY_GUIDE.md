# ECE 2031 Project Summary Report Guide
**Assignment Compliance & Writing Strategy**  
*Based on `2031_AssignmentSheet_ProjectSummary (1).pdf`*

---

## 1. Key Assignment Parameters

| Parameter | Requirement | Critical Rule |
| :--- | :--- | :--- |
| **Max Word Count** | **650 words maximum** (~2 pages of text) | There is **no minimum**, but exceeding 650 words incurs point penalties. |
| **Total Points** | **150 points** | Intro & Conclusion scored **individually**; Body scored **collectively**. |
| **Due Date** | **Final Instructional Day at 8:00 PM** | Submission on Canvas. |
| **Target Audience** | Future students/engineers inheriting your design | They need to understand peripheral functionality and design trade-offs. |

> [!IMPORTANT]
> **CRITICAL DISTINCTION (DO NOT CONFUSE THIS):**  
> As stated explicitly in the assignment sheet:  
> ***"Note that this is not the application that you created to demonstrate your peripheral."***  
> The Project Summary report is **NOT** a report about the Rocketship Game. The report is about the **Pausable Countdown Timer Peripheral (VHDL + SCOMP I/O API)**. The Rocketship Game is only mentioned briefly as the proof-of-concept verification application.

---

## 2. Word Count Inclusions & Exclusions

| Excluded from 650 Word Count | Included in 650 Word Count |
| :--- | :--- |
| • Title page | • **All body text paragraphs** |
| • Simple labels within figures (e.g., "SCOMP", "Peripheral") | • **Figure captions** (must be concise!) |
| • Table headers and data labels (e.g., "0x070", "IO_ADDR") | • **Descriptive sentences inside table cells** |
| | • **Any source code** (ASM or VHDL) — *recommend omitting raw code!* |
| | • **Appendices** (appendices cannot be used as dumping grounds) |

> [!TIP]
> **Figure Strategy:** Figures and block diagrams **do not count** toward the word limit. Use an architectural block diagram showing the 3 entities (`countdown_core`, `countdown_controller`, `countdown_io`) connected to the SCOMP bus (`IO_DATA`, `IO_ADDR`, `IO_WRITE`, `IO_CYCLE`) to save massive word count.

---

## 3. Four Required Report Sections

The document must be organized into exactly four sections:

### **Section 1: Introduction** *(Individual Work — Graded Individually)*
* **Target Word Budget:** ~120 – 140 words
* **Checklist:**
  - [ ] State document purpose: summarizing the Pausable Countdown Timer peripheral for future SCOMP developers.
  - [ ] Introduce peripheral capabilities: hardware 0.1s decisecond tick, reloadable duration, non-blocking pause/resume, synchronous reset, and completion flag without CPU software delay loops.
  - [ ] Summarize team engineering approach: 5-person modular division (Datapath, Controller, Bus I/O, Verification, and Assembly API Demo).
  - [ ] State whether final product met specifications: successfully integrated into SCOMP memory space at `0x070`/`0x071`, verified via testbench and tested on DE10-Lite FPGA.

### **Section 2: Device Functionality** *(Team Shared Body — Graded Collectively)*
* **Target Word Budget:** ~160 – 180 words
* **Checklist:**
  - [ ] Describe the programmer's interface: memory-mapped I/O at `0x070` (`TIMER_VALUE`) and `0x071` (`TIMER_CONTROL`).
  - [ ] Explain control commands: Write `0` = Pause, Write `1` = Start/Resume, Write `2` = Reset, Write `N` to `0x070` = Load duration and clear `DONE`.
  - [ ] Explain status reads: Read `0x070` returns remaining deciseconds; Read `0x071` returns Bit 0 (`RUNNING`) and Bit 1 (`DONE`).
  - [ ] Highlight special features: Preserves remaining tick progress during pause; automatic pause on reload; zero software polling overhead.
  - [ ] Include a clean I/O Register Table and/or Block Diagram.

### **Section 3: Design Decisions & Implementation** *(Team Shared Body — Graded Collectively)*
* **Target Word Budget:** ~160 – 180 words
* **Checklist:**
  - [ ] Architectural decomposition: explain why datapath counter (`countdown_core`), state control (`countdown_controller`), and bus interface (`countdown_io`) were decoupled.
  - [ ] 0.1-second tick generation: dividing SCOMP's 10 MHz clock by 1,000,000 in hardware rather than using software loops.
  - [ ] Bus isolation: driving `IO_DATA` with high-impedance (`'Z'`) whenever `IO_WRITE = '1'` or `IO_ADDR` does not match `0x070`/`0x071`.
  - [ ] Design modifications: address updates to avoid conflict with standard SCOMP devices; maintaining active-low reset polarity.

### **Section 4: Conclusions** *(Individual Work — Graded Individually)*
* **Target Word Budget:** ~130 – 150 words
* **Checklist:**
  - [ ] Provide critical reflection: did moving timing into hardware simplify assembly programs? (Proven by the responsive rocket demo).
  - [ ] Recommendations for future engineers: e.g., adding hardware interrupt on expiration (`DONE`), configurable prescalers (1ms ticks), or multi-channel timer registers.
  - [ ] Retrospective: what would you optimize or improve if doing this again? (e.g., automated testbench integration earlier, tighter state-transition synchronization).

---

## 4. Word Budget Allocation Summary

| Section | Author Type | Recommended Words |
| :--- | :--- | :---: |
| **1. Introduction** | Individual | ~130 words |
| **2. Device Functionality** | Shared Team Body | ~170 words |
| **3. Design Decisions & Implementation** | Shared Team Body | ~170 words |
| **4. Conclusions** | Individual | ~140 words |
| **Captions & Buffer** | Mixed | ~40 words |
| **Total** | | **~650 words** |

---

## 5. Collaboration Strategy for the Team

1. **Step 1 (Team):** Work together to write and polish Sections 2 & 3 (Device Functionality and Design Decisions). Keep these two sections combined under ~340 words.
2. **Step 2 (Team):** Create the peripheral block diagram and I/O register table.
3. **Step 3 (Individual):** Each of the 5 team members writes their own Section 1 (Intro) and Section 4 (Conclusion) in their own words.
4. **Step 4 (Final Check):** Run a strict word count check on each member's final draft to guarantee it is $\le 650$ words.
