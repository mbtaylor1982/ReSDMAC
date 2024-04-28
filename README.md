# ReSDMAC

[![build](https://github.com/mbtaylor1982/RE-SDMAC/actions/workflows/build.yml/badge.svg)](https://github.com/mbtaylor1982/RE-SDMAC/actions/workflows/build.yml)
[![test](https://github.com/mbtaylor1982/ReSDMAC/actions/workflows/test.yml/badge.svg)](https://github.com/mbtaylor1982/ReSDMAC/actions/workflows/test.yml)

[![join](https://dcbadge.vercel.app/api/server/PxHb69nY3q)](https://discord.gg/PxHb69nY3q)

## Introduction

This project is an exercise in reverse engineering the Commodore SDMAC 390537 as found in the Amiga 3000

This project was started with nothing more that the descriptions of the SDMAC operations and from the [Amiga 3000T Service manual](Docs/Commodore/Commodore_A3000T_Service_Manual.pdf), the [WD33c93 Datasheets](Docs/WD33C93/WD33C93B_WesternDigital.pdf) and some source code from the Amiga 3000 Linux scsi drivers.

Since then [Partial schmatics](Docs/Commodore/SDMAC%20Partial%20Schmatics/sdmac01.pdf) have been found for what appears to be the SDMAC 390537 Rev 4 (although could be an even more advanced revision with the FIFO expanded to 8 32  bit longwords).

### SDMAC Documentation

To collate togethe the technical details of the SDMAC a markdown document has been created and is [linked here](Docs/SDMAC.md)
This will be updated with timing diagrams, state diagrams schmatic fragments as appropriate.


#### FIFO

The FIFO is implmented with an 8 x 32 bit long word buffer, each long word can be loaded one byte at a time, one word at a time (high or low) or all at once. This is controled by the Byte Pointer and the write strobe sub circuit in within the FIFO. Reading from the FIFO is asynchronous and the longword pointed to by the read (Next Out) pointer is always present on the output data bus of the FIFO.

#### CPU State Machine
TODO:
#### SCSI State Machine!
[Details here](RTL/SCSI_SM/README.md)

#### Resgisters
TODO:
#### Datapath
TODO:


### Pre-Production Board REV 1A.

![ReSDMAC Rev1a Front](assets/ReSDMAC_Rev1aFront.png "ReSDMAC Rev1a Front")

![ReSDMAC Rev1a Back](assets/ReSDMAC_Rev1aBack.png "ReSDMAC Rev1a back")

![ReSDMAC Rev1a Plug](assets/ReSDMAC_Rev1aPlug.png "ReSDMAC Rev1a Plug")

Please click [here](KiCad/bom/ibom.html) for the Interactive BOM.


### Timing Diagrams.
 Below are the VCD files output by the cocotb tests. these can be used to help verify the verilog code.

![Register access timing](assets/VCD1.png "Register access timing")

![DMA cycle timing](assets/VCD2.png "DMA cycle timing")




