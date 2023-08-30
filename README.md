# SDMAC-Replacement

[![build](https://github.com/mbtaylor1982/RE-SDMAC/actions/workflows/build.yml/badge.svg)](https://github.com/mbtaylor1982/RE-SDMAC/actions/workflows/build.yml)

## Introduction

This project is an exercise in reverse engineering the Commodore SDMAC 390537 as found in the Amiga 3000

This project was started with nothing more that the descriptions of the SDMAC operations and from the [Amiga 3000T Service manual](Docs/Commodore/Commodore_A3000T_Service_Manual.pdf), the [WD33c93 Datasheets](Docs/WD33C93/WD33C93B_WesternDigital.pdf) and some source code from the Amiga 3000 Linux scsi drivers.

Since then [Partial schmatics](Docs/Commodore/SDMAC%20Partial%20Schmatics/sdmac01.pdf) have been found for what appears to be the SDMAC 390537 Rev 4 (although could be an even more advanced revision with the FIFO expanded to 8 32  bit longwords).

### SDMAC Documentation

To collate togethe the technical details of the SDMAC a markdown document has been created and is [linked here](Docs/SDMAC.md)
This will be updated with timing diagrams, state diagrams schmatic fragments as appropriate.
## Plan
### Schmatics
The plan is to recreate the schmatics in [Logisim Evolution](https://github.com/logisim-evolution/logisim-evolution) the schematics are broken down into serveral key modules, these are:

#### FIFO

The FIFO is implmented with an 8 x 32 bit long word buffer, each long word can be loaded one byte at a time, one word at a time (high or low) or all at once. This is controled by the Byte Pointer and the write strobe sub circuit in within the FIFO. Reading from the FIFO is asynchronous and the longword pointed to by the read (Next Out) pointer is always present on the output data bus of the FIFO.

#### CPU State Machine
TODO:
#### SCSI State Machine
TODO:
#### Resgisters
TODO:
#### Datapath
TODO:

### Simulation
Once the schmatics have been transfered to Logisim they can be simulated and the behaviour can be observed and documented.

### Code
When the behaviour is understood for each module will be coded in verilog and relevent test bench code written to verify the code performs the same as the simulation. To write the Code i will be using VS Code and Xilinx ISE to build it using a modified version of [Xilinx-ISE-Makefile](https://github.com/mbtaylor1982/Xilinx-ISE-Makefile)

### Early Prototype Board.

Long before the schmatics where available and early prototype board was created in order to test some early verilog code, below are the deatils for building this.  

**This may not be anything like the finished board as the verilog code may not fit in the CPLD used here**

Eagle CAD prototype and Verilog code to replace the Commodore SDMAC found in the A3000

![SDMAC](/assets/SDMAC_lmqs0c2ja.png)

#Partlist

Exported from SDMAC.sch at 20/02/2022 16:39

EAGLE Version 9.6.2 Copyright (c) 1988-2020 Autodesk, Inc.

Assembly variant: 

| Part | Value               | Device                   | Package      | Library       | Sheet |
| ---- | ------------------- | ------------------------ | ------------ | ------------- | ----- |
| A12  |                     | JP1E                     | JP1          | jumper        | 3     |
| C1   | 10uF                | C_CHIP-0805(2012-METRIC) | CAPC2012X110 | Capacitor     | 3     |
| C10  | 0.1uF               | C_CHIP-0805(2012-METRIC) | CAPC2012X110 | Capacitor     | 3     |
| C11  | 0.1uF               | C_CHIP-0805(2012-METRIC) | CAPC2012X110 | Capacitor     | 3     |
| C12  | 0.1uF               | C_CHIP-0805(2012-METRIC) | CAPC2012X110 | Capacitor     | 3     |
| C13  | 10uF                | T491A106K010AT           | A            | Volks73-Kemet | 3     |
| C3   | 0.1uF               | C_CHIP-0805(2012-METRIC) | CAPC2012X110 | Capacitor     | 3     |
| C4   | 0.1uF               | C_CHIP-0805(2012-METRIC) | CAPC2012X110 | Capacitor     | 3     |
| C5   | 0.1uF               | C_CHIP-0805(2012-METRIC) | CAPC2012X110 | Capacitor     | 3     |
| C6   | 0.1uF               | C_CHIP-0805(2012-METRIC) | CAPC2012X110 | Capacitor     | 3     |
| C7   | 0.1uF               | C_CHIP-0805(2012-METRIC) | CAPC2012X110 | Capacitor     | 3     |
| C8   | 0.1uF               | C_CHIP-0805(2012-METRIC) | CAPC2012X110 | Capacitor     | 3     |
| C9   | 0.1uF               | C_CHIP-0805(2012-METRIC) | CAPC2012X110 | Capacitor     | 3     |
| DMA  |                     | LEDSML0805               | SML0805      | led           | 3     |
| IC1  | SUPER_DMAC_THT      | SUPER_DMAC_THT           | PLCC84_T     | Amiga         | 2     |
| PWR  |                     | LEDSML0805               | SML0805      | led           | 3     |
| R1   | 430                 | R-EU_R0805               | R0805        | rcl           | 3     |
| R2   | 430                 | R-EU_R0805               | R0805        | rcl           | 3     |
| R3   | 430                 | R-EU_R0805               | R0805        | rcl           | 3     |
| R4   | 430                 | R-EU_R0805               | R0805        | rcl           | 3     |
| RD   |                     | LEDSML0805               | SML0805      | led           | 3     |
| SV1  |                     | MA06-1                   | MA06-1       | con-lstb      | 1     |
| U1   | XC95288XL-10TQG144C | XC95288XL-10TQG144C      | 144-TQFP_XIL | XilinxXC95288 | 1     |
| U2   | NCP1117ST33T3G      | NCP1117ST33T3G           | SOT-223      | IC            | 3     |
| WR   |                     | LEDSML0805               | SML0805      | led           | 3     |
