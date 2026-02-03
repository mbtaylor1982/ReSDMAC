# ReSDMAC Developer Guide

## Purpose of this document
This guide is for new developers working on the ReSDMAC project. It explains:
- What the project is and how the design works at a high level.
- How the RTL is organized and how data flows.
- What each file in the repository is for, grouped by directory.

## Project overview (what this is)
ReSDMAC is a re-implementation of Commodore's SDMAC 390537 chip (as used in the Amiga 3000). The SDMAC is a bus master/DMA controller that bridges the 68030 local bus to a peripheral port (SCSI via WD33C93 in the A3000), includes a small FIFO, and manages bus arbitration and interrupts.

At a high level:
- The **CPU-facing side** handles 68030 bus cycles, DMA bus mastering, and DSACK/termination behavior.
- The **SCSI/peripheral side** drives `_IOR/_IOW/_CSS/_DACK` toward the WD33C93 and handles its DMA requests.
- The **FIFO** buffers data between the CPU/memory side and the peripheral side.
- The **datapath** selects and funnels bytes/words/longwords between buses.
- Registers model SDMAC control/status plus additional ReSDMAC-specific registers.

## High-level architecture

```
             68030 Local Bus
     (ADDR/DATA/_AS/_DS/_DSACK)
                |
            [Registers]
                |
           [CPU_SM FSM] <----> Bus arbitration (_BR/_BG/_BGACK)
                |
             [Datapath] <----> [FIFO] <----> [SCSI_SM FSM]
                |                               |
        CPU/Mem-side data                 WD33C93-side
```

Key modules:
- `RESDMAC.v` ties everything together and implements tri-state bus behavior.
- `CPU_SM` controls host bus cycles and DMA bus mastering.
- `SCSI_SM` controls the WD33C93 interface and FIFO handshaking.
- `datapath` selects and formats data between CPU, FIFO, and peripheral buses.
- `fifo` provides 4-longword buffering and byte-lane control.
- `registers` implements SDMAC register map and ReSDMAC-specific registers.
- `PLL` + `phase_counter` generate a 100 MHz clock and quadrature phases for internal timing.

## Clocks and timing model
- **SCLK** is the CPU clock (16/25 MHz).
- A PLL generates **CLK100** for fine-grained timing.
- `phase_counter` provides 0/90/180/270 phase markers used to model the original SDMAC's internal clocking relationships.

## How the design works (dataflow summary)
- **CPU register access**: The 68030 performs read/write cycles that the `registers` module decodes and serves. The `datapath` multiplexes register data onto the CPU bus when selected.
- **DMA read (SCSI -> memory)**:
  - `SCSI_SM` accepts peripheral data and fills the FIFO.
  - `CPU_SM` requests the bus, performs memory writes, and drains the FIFO.
- **DMA write (memory -> SCSI)**:
  - `CPU_SM` requests the bus, performs memory reads into FIFO.
  - `SCSI_SM` drains FIFO to the WD33C93.
- **Interrupts**: `registers_istr` aggregates interrupt sources and drives `_INT`.

## Repository layout and file index
The list below explains what each file in the repo is for. Generated/IP files are called out explicitly.

### Top-level files
- `README.md`: Project overview, acknowledgements, and links to documentation.
- `License.txt`: CC BY-SA 4.0 license text.
- `CODE_OF_CONDUCT.md`: Community conduct guidelines.
- `.gitignore`: Git ignore patterns for build/test artifacts.

### assets/
- `assets/ReSDMAC_Rev1aFront.png`: Photo/render of Rev1a PCB (front).
- `assets/ReSDMAC_Rev1aBack.png`: Photo/render of Rev1a PCB (back).
- `assets/ReSDMAC_Rev1aPlug.png`: Photo/render of the PLCC plug/receptacle.
- `assets/VCD1.png`: Example timing diagram image (register access).
- `assets/VCD2.png`: Example timing diagram image (DMA cycle).

### Docs/
- `Docs/SDMAC.md`: Consolidated SDMAC spec (registers, map, pinout, timing).
- `Docs/RESDMAC_PINS.md`: ReSDMAC pin mapping notes.
- `Docs/100MHz_Clock_Conversion_Guide.md`: Notes on the 100 MHz clock/phase conversion.
- `Docs/MC68030EC.pdf`: MC68030EC datasheet.
- `Docs/MC68030UM.pdf`: MC68030 user manual.
- `Docs/Images/SDMAC_PACKAGE.png`: SDMAC package illustration.
- `Docs/Images/super-dmac-smd.png`: SDMAC package artwork used in docs.

#### Docs/Commodore/
- `Docs/Commodore/Commodore_A3000T_Service_Manual.pdf`: Primary service manual reference.
- `Docs/Commodore/A3000 Service Manual-ENG.pdf`: Service manual for A3000.
- `Docs/Commodore/AA3000_Rev2_Schematics.pdf`: AA3000 Rev2 schematics.
- `Docs/Commodore/AA3000_Rev2_Schematics-merge.pdf`: Merged AA3000 Rev2 schematics.
- `Docs/Commodore/SDMAC_RevC.pdf`: SDMAC Rev C schematics.
- `Docs/Commodore/A3000.pdf`: Additional A3000 documentation.
- `Docs/Commodore/a3000p.pdf`: A3000+ related documentation.

#### Docs/WD33C93/
- `Docs/WD33C93/WD33C93B_WesternDigital.pdf`: WD33C93B datasheet.
- `Docs/WD33C93/am33c393a.pdf`: Additional WD33C93-family datasheet.

#### Docs/LinuxCodeA3000SCSI/
- `Docs/LinuxCodeA3000SCSI/a3000.c`: Reference Linux SCSI driver source for behavior.
- `Docs/LinuxCodeA3000SCSI/a3000.h`: Header for A3000 SCSI driver.
- `Docs/LinuxCodeA3000SCSI/wd33c93.c`: Reference WD33C93 driver source.
- `Docs/LinuxCodeA3000SCSI/wd33c93.h`: Header for WD33C93 driver.

#### Docs/TimingDiagrams/
These JSON files are wavedrom inputs generated by cocotb tests.
- `Docs/TimingDiagrams/CONTR_1_Write.json`: CNTR write timing.
- `Docs/TimingDiagrams/WTC_Read.json`: WTC read timing.
- `Docs/TimingDiagrams/WTC_Write.json`: WTC write timing.
- `Docs/TimingDiagrams/VERSION_read.json`: VERSION read timing.
- `Docs/TimingDiagrams/DMA_READ.json`: Example DMA read timing.
- `Docs/TimingDiagrams/DEVICE_REG_Read.json`: DEVICE read timing.
- `Docs/TimingDiagrams/DSP_read.json`: DSP read timing.
- `Docs/TimingDiagrams/FLASH_ADDR_Read.json`: FLASH_ADDR read timing.
- `Docs/TimingDiagrams/FLASH_ADDR_Write.json`: FLASH_ADDR write timing.
- `Docs/TimingDiagrams/FLASHDATA_Read.json`: FLASHDATA read timing.
- `Docs/TimingDiagrams/FLASHDATA_Write.json`: FLASHDATA write timing.
- `Docs/TimingDiagrams/FLASH_CONTROL_Read.json`: FLASH_CONTROL read timing.
- `Docs/TimingDiagrams/FLASH_CONTROL_Write.json`: FLASH_CONTROL write timing.
- `Docs/TimingDiagrams/SSPBDAT_1_read.json`: SSPBDAT read timing.
- `Docs/TimingDiagrams/SSPBDAT_1_Write.json`: SSPBDAT write timing.
- `Docs/TimingDiagrams/SSPBDAT_2_read.json`: SSPBDAT read timing (alt).
- `Docs/TimingDiagrams/SSPBDAT_2_Write.json`: SSPBDAT write timing (alt).
- `Docs/TimingDiagrams/SCSI_ReadAddr1.json`: SCSI read timing (addr1).
- `Docs/TimingDiagrams/SCSI_ReadAddr2.json`: SCSI read timing (addr2).
- `Docs/TimingDiagrams/SCSI_ReadAddr3.json`: SCSI read timing (addr3).
- `Docs/TimingDiagrams/SCSI_ReadAddr4.json`: SCSI read timing (addr4).
- `Docs/TimingDiagrams/SCSI_WriteAddr_1.json`: SCSI write timing (addr1).
- `Docs/TimingDiagrams/SCSI_WriteAddr_2.json`: SCSI write timing (addr2).
- `Docs/TimingDiagrams/SCSI_WriteAddr_3.json`: SCSI write timing (addr3).
- `Docs/TimingDiagrams/SCSI_WriteAddr_4.json`: SCSI write timing (addr4).
- `Docs/TimingDiagrams/test.md`: Small test/notes file for timing diagrams.

### RTL/
Core RTL implementation and unit tests.

#### RTL top-level
- `RTL/RESDMAC.v`: Top-level SDMAC module; hooks buses, instantiates submodules, handles tri-states.
- `RTL/PLL.v`: PLL wrapper for generating 100 MHz internal clock from SCLK.
- `RTL/phase_counter.v`: Generates 0/90/180/270 phase markers from CLK100.

#### RTL/CPU_SM/
- `RTL/CPU_SM/CPU_SM.v`: CPU-side FSM wrapper with synchronizers and registered outputs.
- `RTL/CPU_SM/CPU_SM_INTERNALS.v`: FSM internals (core state machine).

#### RTL/SCSI_SM/
- `RTL/SCSI_SM/SCSI_SM.v`: SCSI-side FSM wrapper with synchronizers and registered outputs.
- `RTL/SCSI_SM/SCSI_SM_INTERNALS.v`: FSM internals (core state machine).

#### RTL/FIFO/
- `RTL/FIFO/fifo.v`: Top-level FIFO (data storage and status).
- `RTL/FIFO/fifo_3bit_cntr.v`: 3-bit counter used inside FIFO.
- `RTL/FIFO/fifo_byte_ptr.v`: Byte-pointer logic (which byte within a longword).
- `RTL/FIFO/fifo_full_empty_ctr.v`: Full/empty tracking counter.
- `RTL/FIFO/fifo_write_strobes.v`: Write-strobe generator for FIFO entries.

#### RTL/Registers/
- `RTL/Registers/registers.v`: Register file top module (SDMAC + ReSDMAC regs).
- `RTL/Registers/addr_decoder.v`: Address decode and strobe generation.
- `RTL/Registers/registers_cntr.v`: Control register implementation.
- `RTL/Registers/registers_istr.v`: Interrupt status register implementation.
- `RTL/Registers/registers_term.v`: DSACK termination timing logic.
- `RTL/Registers/registers_flash.v`: Flash/metadata register block.

#### RTL/datapath/
- `RTL/datapath/datapath.v`: Top datapath mux/funnel logic between buses.
- `RTL/datapath/datapath_input.v`: CPU/peripheral input path selection.
- `RTL/datapath/datapath_output.v`: CPU/peripheral output path selection.
- `RTL/datapath/datapath_scsi.v`: SCSI-side data path handling.
- `RTL/datapath/datapath_8b_MUX.v`: 8-bit mux for byte selection.
- `RTL/datapath/datapath_24dec.v`: 24-bit decoder for address/data routing.

#### RTL/cocotb/
Python-based tests that exercise the RTL and generate timing diagrams.
- `RTL/cocotb/cocotb_resdmac.py`: Full-system cocotb test (DMA, regs, SCSI cycles).
- `RTL/cocotb/cocotb_fsm_cpu.py`: CPU FSM-focused cocotb test helpers.
- `RTL/cocotb/test_resdmac.py`: Test entry point (cocotb).

##### RTL/cocotb/FIFO/
- `RTL/cocotb/FIFO/cocotb_fifo.py`: FIFO test utilities.
- `RTL/cocotb/FIFO/cocotb_fifo_3bit_cntr.py`: FIFO counter tests.
- `RTL/cocotb/FIFO/cocotb_fifo_full_empty_ctr.py`: FIFO full/empty tests.
- `RTL/cocotb/FIFO/test_fifo.py`: FIFO test harness.

##### RTL/cocotb/Registers/
- `RTL/cocotb/Registers/cocotb_registers.py`: Register tests/utilities.
- `RTL/cocotb/Registers/cocotb_registers_cntr.py`: CNTR register tests.
- `RTL/cocotb/Registers/cocotb_registers_istr.py`: ISTR register tests.
- `RTL/cocotb/Registers/cocotb_registers_term.py`: DSACK timing tests.
- `RTL/cocotb/Registers/test_registers.py`: Register test harness.

### Quartus/
Quartus project files for building the FPGA bitstream.
- `Quartus/RESDMAC.qpf`: Quartus project file.
- `Quartus/RESDMAC.qsf`: Quartus project settings (pin assignments, constraints).
- `Quartus/RESDMAC.out.sdc`: Timing constraints.
- `Quartus/RESDMAC.tcl`: Project/flow helper script.
- `Quartus/RESDMAC.srf`: Quartus report file.
- `Quartus/RESDMAC_10M02SCU169C8G.cof`: Config file for 10M02 device.
- `Quartus/RESDMAC_10M04SCU169C8G.cof`: Config file for 10M04 device.
- `Quartus/RESDMAC_10M16SCU169C8G.cof`: Config file for 10M16 device.

#### Quartus/IP/
**Generated IP** for on-chip flash interface. Do not hand-edit; regenerate via Qsys/Platform Designer.
- `Quartus/IP/flash_interface_10M02SCU169C8G.qsys`: Qsys system for 10M02 device.
- `Quartus/IP/flash_interface_10M04SCU169C8G.qsys`: Qsys system for 10M04 device.
- `Quartus/IP/flash_interface_10M16SCU169C8G.qsys`: Qsys system for 10M16 device.
- `Quartus/IP/flash_interface_10M02SCU169C8G.sopcinfo`: System descriptor (10M02).
- `Quartus/IP/flash_interface_10M04SCU169C8G.sopcinfo`: System descriptor (10M04).
- `Quartus/IP/flash_interface_10M16SCU169C8G.sopcinfo`: System descriptor (10M16).
- `Quartus/IP/Common/attpll.v`: Common PLL IP wrapper.
- `Quartus/IP/Common/attpll.qip`: Quartus IP file for PLL.

##### Quartus/IP/flash_interface_* subdirectories
All files under:
- `Quartus/IP/flash_interface_10M02SCU169C8G/`
- `Quartus/IP/flash_interface_10M04SCU169C8G/`
- `Quartus/IP/flash_interface_10M16SCU169C8G/`

are **generated** outputs of the Qsys flash interface (Verilog, SystemVerilog, SDC, reports, simulation models). These include:
- `*.v`, `*.sv`: Generated RTL for the flash interface and interconnect.
- `*.qip`, `*.cmp`, `*.bsf`, `*.spd`, `*.html`: Quartus/EDA integration files.
- `*.rpt`, `*_generation*.rpt`: Generation reports.
- `simulation/*`: Simulation models and tool setup scripts.
- `synthesis/*`: Synthesis output and submodules.

### KiCad/
PCB and schematic sources.
- `KiCad/ReSDMAC.sch`: Schematic for the ReSDMAC board.
- `KiCad/ReSDMAC.kicad_pcb`: PCB layout file.
- `KiCad/ReSDMAC.pro`: KiCad project file.
- `KiCad/ReSDMAC_FPGA.sch`: FPGA-specific schematic sheet.
- `KiCad/ReSDMAC_schematic_rev1a.pdf`: Exported schematic PDF.
- `KiCad/sym-lib-table`: Symbol library table.
- `KiCad/fp-lib-table`: Footprint library table.
- `KiCad/ReSDMAC.pretty/*.kicad_mod`: Custom footprints used on the PCB.
- `KiCad/packages3d/*.step`: 3D models for PCB visualization.

### disk/
Amiga disk files (used for test/bring-up workflows).
- `disk/Startup-Sequence`: Boot script.
- `disk/Disk.info`: Amiga icon metadata.
- `disk/system-configuration`: System configuration file.

### .github/ and tooling
CI and developer setup.
- `.github/`: GitHub Actions workflows and repo metadata.
- `.devcontainer/`: Dev container configuration.
- `.vscode/`: VS Code settings/tasks.
- `.pytest_cache/`: Local pytest cache (can be ignored).
- `sim_build/`: Local simulation build output (tool-generated).
- `.claude/`: Claude-related project metadata.

## Tips for new contributors
- Start with `Docs/SDMAC.md` to understand the register map and bus behavior.
- Then read `RTL/RESDMAC.v` to see the top-level wiring.
- From there, dive into `RTL/CPU_SM/CPU_SM_INTERNALS.v` and `RTL/SCSI_SM/SCSI_SM_INTERNALS.v`.
- The cocotb tests in `RTL/cocotb/` are a good executable spec of expected behavior.
