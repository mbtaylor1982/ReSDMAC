# ReSDMAC

![CC BY-SA 4.0][cc-by-sa-shield]

![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/mbtaylor1982/resdmac/build.yml)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/mbtaylor1982/resdmac/test.yml?label=tests)
![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/mbtaylor1982/ReSDMAC)

![GitHub Release](https://img.shields.io/github/v/release/mbtaylor1982/resdmac?sort=date&display_name=release)
![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/mbtaylor1982/resdmac/total)

[![join](https://dcbadge.limes.pink/api/server/https://discord.gg/NezUTSZwJ8)](https://discord.gg/NezUTSZwJ8)

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/L3L4XGH2R)

***

##

### Introduction

This project is has been a community effort with the PCB design by [Jorgen Bilander](https://github.com/jbilander) and the code by [Mike Taylor](https://github.com/mbtaylor1982). It has been exercise in reverse engineering the Commodore SDMAC 390537 as found in the Amiga 3000

This project was started with nothing more that the descriptions of the SDMAC operations and from the [Amiga 3000T Service manual](Docs/Commodore/Commodore_A3000T_Service_Manual.pdf), the [WD33c93 Datasheets](Docs/WD33C93/WD33C93B_WesternDigital.pdf) and some source code from the Amiga 3000 Linux scsi drivers.

Since then schematics for what appears to be the Rev 3(C) surfaced along with the original finite state machine descriptions:

- [SDMAC_RevC.pdf](Docs/Commodore/SDMAC_RevC.pdf)
- [Original Statemachine documentation](https://github.com/mbtaylor1982/ReSDMAC/issues/8)

### SDMAC Documentation

To collate together the technical details of the SDMAC a markdown document has been created and is [linked here](Docs/SDMAC.md)

### Pre-Production Board REV 1A

![ReSDMAC Rev1a Front](assets/ReSDMAC_Rev1aFront.png "ReSDMAC Rev1a Front")

![ReSDMAC Rev1a Back](assets/ReSDMAC_Rev1aBack.png "ReSDMAC Rev1a back")

![ReSDMAC Rev1a Plug](assets/ReSDMAC_Rev1aPlug.png "ReSDMAC Rev1a Plug")

### Timing Diagrams

 Below are the VCD files output by the cocotb tests. these have been used to help verify the verilog code.

![Register access timing](assets/VCD1.png "Register access timing")
![DMA cycle timing](assets/VCD2.png "DMA cycle timing")

### Acknowledgements

Thankyou to all the people who have helped with this project especially:

- [Andy aka trixster1979](https://github.com/trixster1979) For the long term loan of a REV 4 SDMAC and dedicated testing of this on the AA3000+
- [Chris Hooper aka CDH](https://github.com/cdhooper) For providing various adaptor PCBs and breakout boards, also for writing the [SDMAC test program](https://github.com/cdhooper/amiga_sdmac_test).
- [Jorgen Bilander](https://github.com/jbilander) For adapting the [ReAgnus](https://github.com/jbilander/ReAgnus) design to suit the SDMAC, and also for crating the [ReSDMAC-devboard](https://github.com/jbilander/ReSDMAC-devboard)
- [Matt Harlum Liv2](https://github.com/LIV2) for checking over the my code and interpretation of the FSM schematics.
- [Matthias Heinrichs](https://github.com/MHeinrichs) For providing the Original Statemachine documentation
- [Stefan Reinauer](https://github.com/reinauer) For his excellent work showcasing this at Amiwest 2024
- [Stefan Skotte aka Screemo](https://github.com/stefanskotte) For the long term loan of a REV 2 SDMAC.
- [Stephen Leary AKA Terriblefire](https://github.com/terriblefire/) For publishing the verilog code for his projects and inspiring me to learn verilog and take on this project way back in 2021

#### Honourable mentions

Others that have helped out with words of encouragement and general support.

- [John Hertell aka Chucky](https://github.com/ChuckyGang)
- [shanshe](https://github.com/shanshe)
- [Wrangler](https://github.com/Wrangler491)

***
This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License][cc-by-sa].
[![CC BY-SA 4.0][cc-by-sa-image]][cc-by-sa]

[cc-by-sa]: http://creativecommons.org/licenses/by-sa/4.0/

[cc-by-sa-image]: https://licensebuttons.net/l/by-sa/4.0/88x31.png

[cc-by-sa-shield]: https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg
