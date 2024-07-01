# ReSDMAC

[![build](https://github.com/mbtaylor1982/RE-SDMAC/actions/workflows/build.yml/badge.svg)](https://github.com/mbtaylor1982/RE-SDMAC/actions/workflows/build.yml)
[![test](https://github.com/mbtaylor1982/ReSDMAC/actions/workflows/test.yml/badge.svg)](https://github.com/mbtaylor1982/ReSDMAC/actions/workflows/test.yml)  
[![join](https://dcbadge.vercel.app/api/server/PxHb69nY3q)](https://discord.gg/PxHb69nY3q)  


Dev | Role | Donate
---------|----------|---------
 [Mike Taylor](https://github.com/mbtaylor1982) | Verilog Code | [![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/L3L4XGH2R) 
 [Jorgen Bilander](https://github.com/jbilander) | PCB Design | [![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/)

### Status

>:red_circle:  **This project is still a work in progress and the code and hardware design is likely to change. this is why there are no instructions on how to build or program the board yet.**

### Introduction

This project is an exercise in reverse engineering the Commodore SDMAC 390537 as found in the Amiga 3000

This project was started with nothing more that the descriptions of the SDMAC operations and from the [Amiga 3000T Service manual](Docs/Commodore/Commodore_A3000T_Service_Manual.pdf), the [WD33c93 Datasheets](Docs/WD33C93/WD33C93B_WesternDigital.pdf) and some source code from the Amiga 3000 Linux scsi drivers.

Since then Partial schmatics surfaced with some pages missing. I've done my best to add the missing pages back and the can be found here [SDMAC_Rev4.pdf](Docs/Commodore/sdmac_Rev4.pdf)

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

***

BOM Rev. 1A
---------
Reference  | Name/Value   | Package | Notes
-|-|-|-|
U1 | 10M04SCU169C8G | BGA-169 11.0x11.0mm_Layout13x13 | FPGA Intel MAX 10 [10M04SCU169C8G](https://www.mouser.com/ProductDetail/989-10M04SCU169C8G)
U2 | LM1117-3.3 | SOT-223 | Low-Dropout Linear Regulator 3.3 Volt
U3-U6 | SN74CBTD16210 | TSSOP-48 6.1x12.5mm_P0.5mm | 20-BIT FET Bus switch with level shifting, high-speed TTL-compatible. [74CBTD16210DGGR](https://www.mouser.com/ProductDetail/595-74CBTD16210DGGR)
U7 | Winslow PLCC-84 Plug | PLCC-84 Plug | Optionally use a home made plug (stacked PCBs)
U8 | PLCC-84_TH_pin_holes | TH_plug_pins | Pins to use with homemade plug, 1.27mm pitch Long Pin 1x40P or 1x50P [Aliexpress](https://www.aliexpress.com/item/32894911767.html) Cut to length after soldering.
RN1 | CAY16-103J4LF RES ARRAY 4 Resistors 10k Ω | 1206 | [CAY16-103J4LF](https://www.mouser.com/ProductDetail/652-CAY16-103J4LF)
RN2 | CAY16-103J4LF RES ARRAY 4 Resistors 10k Ω | 1206 | --"--
C1-3 | Capacitor 10uF | 1206 | 
C4,C5,C8,C11 | Capacitor 1uF | 0805 | 
C6,C7,C9,C10 | Capacitor 0.1uF = 100nF | 0805 | 
C12-C19 | Capacitor 0.01uF = 10nF | 0603 |
C20 | Capacitor 0.1uF = 100nF | 0603 |
C21-C24 | Capacitor 0.01uF = 10nF | 0603 |
JTAG | SMT Pin Header Male | SMT 2 x 5 Pin 2.0mm pitch |

***

When ordering from JLCPCB select:

Specify Layer Sequence: Yes

    L1(Top layer):    F_Cu.gbr
    L2(Inner layer1): GND_Cu.gbr
    L3(Inner layer2): VCC_Cu.gbr
    L4(Bottom layer): B_Cu.gbr

Remove Order Number: 

    Specify a location

This will notify JLC where to put the order number, they will replace the "JLCJLCJLCJLC" silkscreen label.

***

### Pre-Production Board REV 1A.

![ReSDMAC Rev1a Front](assets/ReSDMAC_Rev1aFront.png "ReSDMAC Rev1a Front")

![ReSDMAC Rev1a Back](assets/ReSDMAC_Rev1aBack.png "ReSDMAC Rev1a back")

![ReSDMAC Rev1a Plug](assets/ReSDMAC_Rev1aPlug.png "ReSDMAC Rev1a Plug")

Please click [here](KiCad/bom/ibom.html) for the Interactive BOM.


### Timing Diagrams.
 Below are the VCD files output by the cocotb tests. these can be used to help verify the verilog code.

![Register access timing](assets/VCD1.png "Register access timing")
![DMA cycle timing](assets/VCD2.png "DMA cycle timing")

### Acknowledgements
Thankyou to all the people who have helped with this project especially:

- [Stefan Skotte aka Screemo](https://github.com/stefanskotte) For the long term loan of a REV 2 SDMAC.
- [Andy aka trixster1979](https://github.com/trixster1979) For the long term loan of a REV 4 SDMAC.
- [Matt Harlum Liv2](https://github.com/LIV2) for checking over the my code and interpretation of the FSM schematics.
- [Chris Hooper aka CDH](https://github.com/cdhooper) For providing various adaptor PCBs and breakout boards, also for writing the [SDMAC test program](https://github.com/cdhooper/amiga_sdmac_test).
- [Jorgen Bilander](https://github.com/jbilander) For adapting the [ReAgnus](https://github.com/jbilander/ReAgnus) design to suit the SDMAC, and also for crating the [ReSDMAC-devboard](https://github.com/jbilander/ReSDMAC-devboard)
- [Stephen Leary AKA Terriblefire](https://github.com/terriblefire/) For publishing the verilog code for his projects and inspiring me to learn verilog and take on this project way back in 2021

#### Honourable mentions
others that have helped out with words of encouragement and general support.
 - [John Hertell aka Chucky](https://github.com/ChuckyGang)
 - [Wrangler](https://github.com/Wrangler491)
 - [shanshe](https://github.com/shanshe)
 - [Stefan Reinauer](https://github.com/reinauer)

***
[![CC BY-SA 4.0][cc-by-sa-shield]][cc-by-sa] 

This work is licensed under a
[Creative Commons Attribution-ShareAlike 4.0 International License][cc-by-sa].

[![CC BY-SA 4.0][cc-by-sa-image]][cc-by-sa]

[cc-by-sa]: http://creativecommons.org/licenses/by-sa/4.0/
[cc-by-sa-image]: https://licensebuttons.net/l/by-sa/4.0/88x31.png
[cc-by-sa-shield]: https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg
  
