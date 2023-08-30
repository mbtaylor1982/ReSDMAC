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
#### SCSI State Machine!

TODO:
#### Resgisters
TODO:
#### Datapath
TODO:

### Simulation
Once the schmatics have been transfered to Logisim they can be simulated and the behaviour can be observed and documented.

### Code
When the behaviour is understood for each module will be coded in verilog and relevent test bench code written to verify the code performs the same as the simulation. 

To write the Code i will be using VS Code and Quartus to build using  [Quartus docker image](https://github.com/raetro/sdk-docker-fpga)

### Prototype Board REV D.


#Partlist

| ID  | Name                        | Designator                     | Footprint                                    | Quantity |
| --- | --------------------------- | ------------------------------ | -------------------------------------------- | -------- |
| 1   | 0.1u                        | C1,C2,C3,C4,C5,C6,C7,C8,C9,C10 | C0603                                        | 10       |
| 2   | TP1                         | CLK                            | TESTPAD                                      | 1        |
| 3   | TP3                         | DBOE_                          | TESTPAD                                      | 1        |
| 4   | HDR-M-2.54_1x2              | J1                             | HDR-M-2.54_1X2                               | 1        |
| 5   | TP5                         | OWN                            | TESTPAD                                      | 1        |
| 6   | X5521WV-2X14-C46D46-1220    | P1,P2,P3,P4                    | HDR-TH_28P-P2.54-V-M-R2-C14-S2.54            | 4        |
| 7   | 2N7002-7-F                  | Q1,Q2,Q3,Q4,Q5                 | SOT-23_L2.9-W1.3-P1.90-LS2.4-BR              | 5        |
| 8   | 1k                          | R1,R2,R3                       | R0603                                        | 3        |
| 9   | TP2                         | RST                            | TESTPAD                                      | 1        |
| 10  | TP4                         | RW                             | TESTPAD                                      | 1        |
| 11  | SN74ALVC164245DGGR          | U2,U3,U4,U5,U6                 | TSSOP-48_L12.6-W6.2-P0.50-LS8.1-BL           | 5        |
| 12  | Amiga SDMAC PLCC-TH-REVERSE | U7                             | PLCC-TH-84P-P2.54-R13-C13-W36_SOCKET-REVERSE | 1        |
