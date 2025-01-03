# ReSDMAC PIN Assignment

## Copyright (C) 2023  Intel Corporation. All rights reserved

 Your use of Intel Corporation's design tools, logic functions and other software and tools, and any partner logic functions, and any output files from any of the foregoing (including device programming or simulation files), and any associated documentation or information are expressly subject to the terms and conditions of the Intel Program License Subscription Agreement, the Intel Quartus Prime License Agreement, the Intel FPGA IP License Agreement, or other applicable license agreement, including, without limitation, that your use is for the sole purpose of programming logic devices manufactured by Intel and sold by Intel or its authorized distributors.  Please refer to the applicable agreement for further details, at [https://fpgasoftware.intel.com/eula](https://fpgasoftware.intel.com/eula).

 > :large_blue_circle: This is a Quartus Prime output file. It is for reporting purposes only, and is not intended for use as a Quartus Prime input file. This file cannot be used to make Quartus Prime pin assignments - for instructions on how to make pin assignments, please see Quartus Prime help.

### Usage definition

#### NC

- **No Connect**. This pin has no internal connection to the device.

#### DNU

- **DO NOT USE** ==This pin MUST NOT be connected.==

#### VCCINT

- **Dedicated power pin**, which MUST be connected to VCC  (1.2V).

#### VCCIO

**Dedicated power pin**, which MUST be connected to VCC of its bank.

- Bank 1A     3.3V
- Bank 1B     3.3V
- Bank 2      3.3V
- Bank 3      3.3V
- Bank 5      3.3V
- Bank 6      3.3V
- Bank 8      3.3V

#### GND

- **Dedicated ground pin.** Dedicated GND pins MUST be connected to GND. It can also be used to report unused dedicated pins. The connection on the board for unused dedicated pins depends on whether this will be used in a future design. One example is device migration. When     using device migration, refer to the device pin-tables. If it is a GND pin in the pin table or if it will not be used in a future design for another purpose the it MUST be connected to GND. If it is an unused dedicated pin, then it can be connected to a valid signal on the board (low, high, or toggling) if that signal is required for a different revision of the design.

#### GND+

- **Unused input pin.** It can also be used to report unused dual-purpose pins. This pin should be connected to GND. It may also be connected  to a valid signal  on the board  (low, high, or toggling)  if that signal is required for a different revision of the design.

#### GND*

- **Unused  I/O  pin.** Connect each pin marked GND* directly to GND or leave it unconnected.

#### RESERVED

- **Unused I/O pin**, which MUST be left unconnected.
- **RESERVED_INPUT**  Pin is tri-stated and should be connected to the board.
- **RESERVED_INPUT_WITH_WEAK_PULLUP** Pin is tri-stated with internal weak pull-up resistor.
- **RESERVED_INPUT_WITH_BUS_HOLD** Pin is tri-stated with bus-hold circuitry.
- **RESERVED_OUTPUT_DRIVEN_HIGH** Pin is output driven high.

 ---

 Pin directions (input, output or bidir) are based on device operating in user mode.

> `Quartus Prime Version 22.1std.2 Build 922 07/20/2023 SC Lite Edition`
> `CHIP  "RESDMAC"  ASSIGNED TO AN: 10M16SCU169C8G`

| Pin Name/Usage                                 | Location | Dir.   | I/O Standard          | Voltage   | I/O Bank | User Assignment |
| ---------------------------------------------- | -------- | ------ | --------------------- | --------- | -------- | --------------- |
| GND                                            | A1       | gnd    |                       |           |          |
| CSX0                                           | A2       | input  | 3.3-V LVTTL           |           | 8        | Y               |
| CSX1                                           | A3       | input  | 3.3-V LVTTL           |           | 8        | Y               |
| IORDY                                          | A4       | input  | 3.3-V LVTTL           |           | 8        | Y               |
| DATA_IO[0]                                     | A5       | bidir  | 3.3-V LVTTL           |           | 8        | Y               |
| _BGACK_IO                                      | A6       | bidir  | 3.3-V LVTTL           |           | 8        | Y               |
| INTA                                           | A7       | input  | 3.3-V LVTTL           |           | 8        | Y               |
| INC_ADD                                        | A8       | input  | 3.3-V LVTTL           |           | 8        | Y               |
| _DMAEN                                         | A9       | output | 3.3-V LVTTL           |           | 8        | Y               |
| _BR                                            | A10      | output | 3.3-V LVTTL           |           | 8        | Y               |
| ADDR[2]                                        | A11      | input  | 3.3-V LVTTL           |           | 8        | Y               |
| ADDR[4]                                        | A12      | input  | 3.3-V LVTTL           |           | 6        | Y               |
| GND                                            | A13      | gnd    |                       |           |          |
| JP                                             | B1       | input  | 3.3-V LVTTL           |           | 1A       | Y               |
| _IOR                                           | B2       | output | 3.3-V LVTTL           |           | 8        | Y               |
| RESERVED_INPUT                                 | B3       |        |                       |           | 8        |
| PD_PORT[14]                                    | B4       | bidir  | 3.3-V LVTTL           |           | 8        | Y               |
| PD_PORT[12]                                    | B5       | bidir  | 3.3-V LVTTL           |           | 8        | Y               |
| PD_PORT[10]                                    | B6       | bidir  | 3.3-V LVTTL           |           | 8        | Y               |
| _BG                                            | B7       | input  | 3.3-V LVTTL           |           | 8        | Y               |
| GND                                            | B8       | gnd    |                       |           |          |
| PD_PORT[7]                                     | B9       | bidir  | 3.3-V LVTTL           |           | 8        | Y               |
| ADDR[6]                                        | B10      | input  | 3.3-V LVTTL           |           | 8        | Y               |
| ADDR[5]                                        | B11      | input  | 3.3-V LVTTL           |           | 6        | Y               |
| ADDR[3]                                        | B12      | input  | 3.3-V LVTTL           |           | 6        | Y               |
| PD_PORT[2]                                     | B13      | bidir  | 3.3-V LVTTL           |           | 6        | Y               |
| _CSS                                           | C1       | output | 3.3-V LVTTL           |           | 1A       | Y               |
| _IOW                                           | C2       | output | 3.3-V LVTTL           |           | 1A       | Y               |
| GND                                            | C3       | gnd    |                       |           |          |
| ~ALTERA_nSTATUS~ / RESERVED_INPUT              | C4       | input  | 3.3 V Schmitt Trigger |           | 8        | N               |
| ~ALTERA_CONF_DONE~ / RESERVED_INPUT            | C5       | input  | 3.3 V Schmitt Trigger |           | 8        | N               |
| VCCIO8                                         | C6       | power  |                       | 3.3V      | 8        |
| VCCIO8                                         | C7       | power  |                       | 3.3V      | 8        |
| VCCIO8                                         | C8       | power  |                       | 3.3V      | 8        |
| PD_PORT[8]                                     | C9       | bidir  | 3.3-V LVTTL           |           | 8        | Y               |
| PD_PORT[6]                                     | C10      | bidir  | 3.3-V LVTTL           |           | 8        | Y               |
| PD_PORT[4]                                     | C11      | bidir  | 3.3-V LVTTL           |           | 6        | Y               |
| PD_PORT[0]                                     | C12      | bidir  | 3.3-V LVTTL           |           | 6        | Y               |
| PD_PORT[1]                                     | C13      | bidir  | 3.3-V LVTTL           |           | 6        | Y               |
| _DACK                                          | D1       | output | 3.3-V LVTTL           |           | 1A       | Y               |
| GND                                            | D2       | gnd    |                       |           |          |
| VCCA3                                          | D3       | power  |                       | 3.0V/3.3V |          |
| VCCA3                                          | D4       | power  |                       | 3.0V/3.3V |          |
| GND                                            | D5       | gnd    |                       |           |          |
| PD_PORT[11]                                    | D6       | bidir  | 3.3-V LVTTL           |           | 8        | Y               |
| RESERVED_INPUT                                 | D7       |        |                       |           | 8        |
| PIN_D8                                         | D8       | input  | 3.3-V LVTTL           |           | 8        | Y               |
| RESERVED_INPUT                                 | D9       |        |                       |           | 6        |
| VCCA2                                          | D10      | power  |                       | 3.0V/3.3V |          |
| RESERVED_INPUT                                 | D11      |        |                       |           | 6        |
| PD_PORT[3]                                     | D12      | bidir  | 3.3-V LVTTL           |           | 6        | Y               |
| _CS                                            | D13      | input  | 3.3-V LVTTL           |           | 6        | Y               |
| RESERVED_INPUT                                 | E1       |        |                       |           | 1A       |
| GND                                            | E2       | gnd    |                       |           |          |
| PD_PORT[15]                                    | E3       | bidir  | 3.3-V LVTTL           |           | 1A       | Y               |
| RESERVED_INPUT                                 | E4       |        |                       |           | 1A       |
| RESERVED_INPUT                                 | E5       |        |                       |           | 1B       |
| RESERVED_INPUT                                 | E6       |        |                       |           | 8        |
| ~ALTERA_nCONFIG~ / RESERVED_INPUT              | E7       | input  | 3.3 V Schmitt Trigger |           | 8        | N               |
| RESERVED_INPUT                                 | E8       |        |                       |           | 8        |
| RESERVED_INPUT                                 | E9       |        |                       |           | 6        |
| RESERVED_INPUT                                 | E10      |        |                       |           | 6        |
| GND                                            | E11      | gnd    |                       |           |          |
| RESERVED_INPUT                                 | E12      |        |                       |           | 6        |
| RESERVED_INPUT                                 | E13      |        |                       |           | 6        |
| _DREQ                                          | F1       | input  | 3.3-V LVTTL           |           | 1A       | Y               |
| VCCIO1A                                        | F2       | power  |                       | 3.3V      | 1A       |
| GND                                            | F3       | gnd    |                       |           |          |
| PD_PORT[13]                                    | F4       | bidir  | 3.3-V LVTTL           |           | 1B       | Y               |
| ~ALTERA_TDI~ / RESERVED_INPUT_WITH_WEAK_PULLUP | F5       | input  | 3.3 V Schmitt Trigger |           | 1B       | N               |
| ~ALTERA_TDO~                                   | F6       | output | 3.3-V LVTTL           |           | 1B       | N               |
| VCC_ONE                                        | F7       | power  |                       | 3.0V/3.3V |          |
| RESERVED_INPUT                                 | F8       |        |                       |           | 6        |
| PD_PORT[9]                                     | F9       | bidir  | 3.3-V LVTTL           |           | 6        | Y               |
| PD_PORT[5]                                     | F10      | bidir  | 3.3-V LVTTL           |           | 6        | Y               |
| VCCIO6                                         | F11      | power  |                       | 3.3V      | 6        |
| _BERR                                          | F12      | input  | 3.3-V LVTTL           |           | 6        | Y               |
| SCLK                                           | F13      | input  | 3.3-V LVTTL           |           | 6        | Y               |
| ~ALTERA_TMS~ / RESERVED_INPUT_WITH_WEAK_PULLUP | G1       | input  | 3.3 V Schmitt Trigger |           | 1B       | N               |
| ~ALTERA_TCK~ / RESERVED_INPUT                  | G2       | input  | 3.3 V Schmitt Trigger |           | 1B       | N               |
| VCCIO1B                                        | G3       | power  |                       | 3.3V      | 1B       |
| RESERVED_INPUT                                 | G4       |        |                       |           | 1B       |
| RESERVED_INPUT                                 | G5       |        |                       |           | 2        |
| VCC_ONE                                        | G6       | power  |                       | 3.0V/3.3V |          |
| GND                                            | G7       | gnd    |                       |           |          |
| VCC_ONE                                        | G8       | power  |                       | 3.0V/3.3V |          |
| INTB                                           | G9       | input  | 3.3-V LVTTL           |           | 6        | Y               |
| RESERVED_INPUT                                 | G10      |        |                       |           | 6        |
| VCCIO6                                         | G11      | power  |                       | 3.3V      | 6        |
| RESERVED_INPUT                                 | G12      |        |                       |           | 5        |
| _RST                                           | G13      | input  | 3.3-V LVTTL           |           | 5        | Y               |
| RESERVED_INPUT                                 | H1       |        |                       |           | 1B       |
| DATA_IO[22]                                    | H2       | bidir  | 3.3-V LVTTL           |           | 1B       | Y               |
| RESERVED_INPUT                                 | H3       |        |                       |           | 1B       |
| RESERVED_INPUT                                 | H4       |        |                       |           | 2        |
| RESERVED_INPUT                                 | H5       |        |                       |           | 2        |
| RESERVED_INPUT                                 | H6       |        |                       |           | 2        |
| VCC_ONE                                        | H7       | power  |                       | 3.0V/3.3V |          |
| RESERVED_INPUT                                 | H8       |        |                       |           | 5        |
| RESERVED_INPUT                                 | H9       |        |                       |           | 5        |
| RESERVED_INPUT                                 | H10      |        |                       |           | 5        |
| VCCIO5                                         | H11      | power  |                       | 3.3V      | 5        |
| GND                                            | H12      | gnd    |                       |           |          |
| _AS_IO                                         | H13      | bidir  | 3.3-V LVTTL           |           | 5        | Y               |
| DATA_IO[19]                                    | J1       | bidir  | 3.3-V LVTTL           |           | 2        | Y               |
| DATA_IO[21]                                    | J2       | bidir  | 3.3-V LVTTL           |           | 2        | Y               |
| VCCIO2                                         | J3       | power  |                       | 3.3V      | 2        |
| GND                                            | J4       | gnd    |                       |           |          |
| RESERVED_INPUT                                 | J5       |        |                       |           | 3        |
| RESERVED_INPUT                                 | J6       |        |                       |           | 3        |
| RESERVED_INPUT                                 | J7       |        |                       |           | 3        |
| RESERVED_INPUT                                 | J8       |        |                       |           | 3        |
| RESERVED_INPUT                                 | J9       |        |                       |           | 5        |
| RESERVED_INPUT                                 | J10      |        |                       |           | 5        |
| VCCIO5                                         | J11      | power  |                       | 3.3V      | 5        |
| RESERVED_INPUT                                 | J12      |        |                       |           | 5        |
| R_W_IO                                         | J13      | bidir  | 3.3-V LVTTL           |           | 5        | Y               |
| DATA_IO[20]                                    | K1       | bidir  | 3.3-V LVTTL           |           | 2        | Y               |
| DATA_IO[18]                                    | K2       | bidir  | 3.3-V LVTTL           |           | 2        | Y               |
| VCCIO2                                         | K3       | power  |                       | 3.3V      | 2        |
| VCCA1                                          | K4       | power  |                       | 3.0V/3.3V |          |
| RESERVED_INPUT                                 | K5       |        |                       |           | 3        |
| RESERVED_INPUT                                 | K6       |        |                       |           | 3        |
| RESERVED_INPUT                                 | K7       |        |                       |           | 3        |
| DATA_IO[29]                                    | K8       | bidir  | 3.3-V LVTTL           |           | 3        | Y               |
| VCCA4                                          | K9       | power  |                       | 3.0V/3.3V |          |
| _DSACK_IO[0]                                   | K10      | bidir  | 3.3-V LVTTL           |           | 5        | Y               |
| RESERVED_INPUT                                 | K11      |        |                       |           | 5        |
| _DSACK_IO[1]                                   | K12      | bidir  | 3.3-V LVTTL           |           | 5        | Y               |
| _DS_IO                                         | K13      | bidir  | 3.3-V LVTTL           |           | 5        | Y               |
| DATA_IO[17]                                    | L1       | bidir  | 3.3-V LVTTL           |           | 2        | Y               |
| DATA_IO[23]                                    | L2       | bidir  | 3.3-V LVTTL           |           | 2        | Y               |
| RESERVED_INPUT                                 | L3       |        |                       |           | 2        |
| DATA_IO[24]                                    | L4       | bidir  | 3.3-V LVTTL           |           | 3        | Y               |
| DATA_IO[25]                                    | L5       | bidir  | 3.3-V LVTTL           |           | 3        | Y               |
| VCCIO3                                         | L6       | power  |                       | 3.3V      | 3        |
| VCCIO3                                         | L7       | power  |                       | 3.3V      | 3        |
| VCCIO3                                         | L8       | power  |                       | 3.3V      | 3        |
| GND                                            | L9       | gnd    |                       |           |          |
| _STERM                                         | L10      | input  | 3.3-V LVTTL           |           | 3        | Y               |
| RESERVED_INPUT                                 | L11      |        |                       |           | 3        |
| DATA_IO[7]                                     | L12      | bidir  | 3.3-V LVTTL           |           | 5        | Y               |
| _INT                                           | L13      | output | 3.3-V LVTTL           |           | 5        | Y               |
| DATA_IO[16]                                    | M1       | bidir  | 3.3-V LVTTL           |           | 2        | Y               |
| DATA_IO[15]                                    | M2       | bidir  | 3.3-V LVTTL           |           | 2        | Y               |
| DATA_IO[1]                                     | M3       | bidir  | 3.3-V LVTTL           |           | 2        | Y               |
| DATA_IO[26]                                    | M4       | bidir  | 3.3-V LVTTL           |           | 3        | Y               |
| DATA_IO[27]                                    | M5       | bidir  | 3.3-V LVTTL           |           | 3        | Y               |
| GND                                            | M6       | gnd    |                       |           |          |
| DATA_IO[28]                                    | M7       | bidir  | 3.3-V LVTTL           |           | 3        | Y               |
| DATA_IO[30]                                    | M8       | bidir  | 3.3-V LVTTL           |           | 3        | Y               |
| DATA_IO[31]                                    | M9       | bidir  | 3.3-V LVTTL           |           | 3        | Y               |
| DATA_IO[13]                                    | M10      | bidir  | 3.3-V LVTTL           |           | 3        | Y               |
| DATA_IO[11]                                    | M11      | bidir  | 3.3-V LVTTL           |           | 3        | Y               |
| DATA_IO[8]                                     | M12      | bidir  | 3.3-V LVTTL           |           | 3        | Y               |
| _SIZ1                                          | M13      | output | 3.3-V LVTTL           |           | 3        | Y               |
| GND                                            | N1       | gnd    |                       |           |          |
| RESERVED_INPUT                                 | N2       |        |                       |           | 2        |
| RESERVED_INPUT                                 | N3       |        |                       |           | 2        |
| DATA_IO[2]                                     | N4       | bidir  | 3.3-V LVTTL           |           | 3        | Y               |
| DATA_IO[3]                                     | N5       | bidir  | 3.3-V LVTTL           |           | 3        | Y               |
| DATA_IO[4]                                     | N6       | bidir  | 3.3-V LVTTL           |           | 3        | Y               |
| DATA_IO[5]                                     | N7       | bidir  | 3.3-V LVTTL           |           | 3        | Y               |
| DATA_IO[14]                                    | N8       | bidir  | 3.3-V LVTTL           |           | 3        | Y               |
| DATA_IO[6]                                     | N9       | bidir  | 3.3-V LVTTL           |           | 3        | Y               |
| DATA_IO[12]                                    | N10      | bidir  | 3.3-V LVTTL           |           | 3        | Y               |
| DATA_IO[10]                                    | N11      | bidir  | 3.3-V LVTTL           |           | 3        | Y               |
| DATA_IO[9]                                     | N12      | bidir  | 3.3-V LVTTL           |           | 3        | Y               |
| GND                                            | N13      | gnd    |                       |           |          |
