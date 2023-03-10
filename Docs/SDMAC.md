- [1. SDMAC 390537 (Super Direct Memory Access Controller)](#1-sdmac-390537-super-direct-memory-access-controller)
  - [1.1. INTRODUCTION](#11-introduction)
  - [1.2. SDMAC DESCRIPTION](#12-sdmac-description)
  - [1.3. Package and pin-out {#PINOUT}](#13-package-and-pin-out-pinout)
  - [1.4. I/O DEFINITIONS AND LOCATIONS {#IO}](#14-io-definitions-and-locations-io)
    - [1.4.1. SDMAC PERIPHERAL I/O MEMORY MAP](#141-sdmac-peripheral-io-memory-map)
  - [1.5. REGISTER AND COMMAND DESCRIPTIONS {#REG}](#15-register-and-command-descriptions-reg)
    - [1.5.1. DAWR (Address: ```$00```) — write only {#DAWR}](#151-dawr-address-00--write-only-dawr)
    - [1.5.2. WTC (Address: ```$04```) — read/write {#WTC}](#152-wtc-address-04--readwrite-wtc)
    - [1.5.3. CNTR (Address: ```$08```) — read/write {#CNTR}](#153-cntr-address-08--readwrite-cntr)
      - [1.5.3.1. TCEN — Terminal Count Enable, Active High {#TCEN}](#1531-tcen--terminal-count-enable-active-high-tcen)
      - [1.5.3.2. PREST — Peripheral Reset, Active High {#PREST}](#1532-prest--peripheral-reset-active-high-prest)
      - [1.5.3.3. PDMD — Peripheral Device Mode Select {#PDMD}](#1533-pdmd--peripheral-device-mode-select-pdmd)
      - [1.5.3.4. INTEN — Interrupt Enable, Active High {#INTEN}](#1534-inten--interrupt-enable-active-high-inten)
      - [1.5.3.5. DDIR — Device Direction {#DDIR}](#1535-ddir--device-direction-ddir)
      - [1.5.3.6. IO\_DX — IORDY and CSX1 Polarity Select {#IO\_DX}](#1536-io_dx--iordy-and-csx1-polarity-select-io_dx)
    - [1.5.4. ACR (Address: ```$0C```) — read/write {#ACR}](#154-acr-address-0c--readwrite-acr)
      - [1.5.4.1. RAMSEY DMAC SUPPORT](#1541-ramsey-dmac-support)
    - [1.5.5. ST\_DMA (Address: ```$10```) — read/write strobe {#ST\_DMA}](#155-st_dma-address-10--readwrite-strobe-st_dma)
    - [1.5.6. FLUSH (Address: ```$14```) — read/write strobe {#FLUSH}](#156-flush-address-14--readwrite-strobe-flush)
    - [1.5.7. CINT (Address: ```$18```) — read/write strobe {#CINT}](#157-cint-address-18--readwrite-strobe-cint)
    - [1.5.8. ISTR (Address: ```$1C```) — read only {#ISTR}](#158-istr-address-1c--read-only-istr)
      - [1.5.8.1. INTX — XT/AT Interrupt pending, Active High {#INTX}](#1581-intx--xtat-interrupt-pending-active-high-intx)
      - [1.5.8.2. INT\_F — Interrupt Follow, Active High {#INT\_F}](#1582-int_f--interrupt-follow-active-high-int_f)
      - [1.5.8.3. INTS — SCSI Peripheral Interrupt, Active High {#INTS}](#1583-ints--scsi-peripheral-interrupt-active-high-ints)
      - [1.5.8.4. E\_INT — End-Of-Process Interrupt, Active High {#E\_INT}](#1584-e_int--end-of-process-interrupt-active-high-e_int)
      - [1.5.8.5. INT\_P — Interrupt Pending, Active High {#INT\_P}](#1585-int_p--interrupt-pending-active-high-int_p)
      - [1.5.8.6. UE\_INT — Under-Run FIFO Error Interrupt, Active High {#UE\_INT}](#1586-ue_int--under-run-fifo-error-interrupt-active-high-ue_int)
      - [1.5.8.7. OE\_INT — Over-Run FIFO Error Interrupt, Active High {#OE\_INT}](#1587-oe_int--over-run-fifo-error-interrupt-active-high-oe_int)
      - [1.5.8.8. FF\_FLG — FIFO Full Flag, Active High {#FF\_FLG}](#1588-ff_flg--fifo-full-flag-active-high-ff_flg)
      - [1.5.8.9. FE\_FLG — FIFO Empty Flag, Active High {#FE\_FLG}](#1589-fe_flg--fifo-empty-flag-active-high-fe_flg)
    - [1.5.9. RESERVED (Address: ```$20,$24,$28,$2C,$30,$34,$38```) {#RESERVED}](#159-reserved-address-2024282c303438-reserved)
    - [1.5.10. SP\_DMA (Address: ```$3C```) — read/write strobe {#SP\_DMA}](#1510-sp_dma-address-3c--readwrite-strobe-sp_dma)
    - [1.5.11. PORT0 (Address range: ```$40 - $4C```) — read/write {#PORT0}](#1511-port0-address-range-40---4c--readwrite-port0)
    - [1.5.12. PORT1A (Address range: ```$50 - $5C```) — read/write {#PORT1A}](#1512-port1a-address-range-50---5c--readwrite-port1a)
    - [1.5.13. PORT2 (Address range: ```$60 - $6C```) — read/write {#PORT2}](#1513-port2-address-range-60---6c--readwrite-port2)
    - [1.5.14. PORT1B (Address range: ```$70 - $7C```) — read/write {#PORT1B}](#1514-port1b-address-range-70---7c--readwrite-port1b)
  - [1.6. SDMAC TIMING DATA](#16-sdmac-timing-data)
    - [1.6.1. Example timing diagram](#161-example-timing-diagram)


# 1. SDMAC 390537 (Super Direct Memory Access Controller)

## 1.1. INTRODUCTION

The purpose of this specification is to provide a description of Commodore’s 390537 SDMAC,

This includes a description of:

- [Pin-out](#PINOUT)
- [I/O locations](#IO)
- [SDMAC Registers & Commands](#REG)

## 1.2. SDMAC DESCRIPTION

The SDMAC is an 84 pin (PLCC), 2 micron CMOS gate-array designed to enhance the performance of the Amiga A3000 computer and to reduce the cost of adding peripheral devices (i.e. SCSI and XT/AT devices) to the Amiga A3000.

Performance is enhanced by providing the computer with a full-speed 16MHz or 25MHz full 32-bit direct memory access controller that runs on the 68030 local fast bus. Data is transferred between Amiga system memory and a peripheral device by utilization of an internal 4 longword (32 bits/longword) FIFO, direct memory access and built-in byte-to word and byte-to-longword funneling.

Over-all cost of adding peripheral devices to the Amiga is reduced due to the combined functionality of the SDMAC.

The SDMAC provides direct connection from the Amiga’s full 32-bit local fast bus to either a SCSI controller device (i.e. WD33C93A) or an ‘XT/AT’ compatible interface. Besides providing direct memory access and bus arbitration, the SDMAC also contains a 16 byte FIFO (eliminating the need for external static buffering), interrupt control logic,
and byte or word (8 or 16 bit peripheral data) to word or longword (16 or 32 bit Amiga data) funneling.

The SDMAC thus significantly reduces external hardware and manufacturing cost.

## 1.3. Package and pin-out {#PINOUT}

The SDMAC is packaged as PLCC (Plastic Leaded Chip Carrier) with 84 Pins



![PLCC84 SDMAC Package](/Docs/Images/SDMAC_PACKAGE.png)

| Pin    | Direction      | Rev2     | Rev4     | AA3000   | Description                                              |
|--------|----------------|----------|----------|----------|----------------------------------------------------------|
| 1..20  | In/Out         | D0..D19  | D0..D19  | D0..D19  | Processor Data Bus                                       |
| 21     | -              | VCC      | VCC      | VCC      | +5V DC                                                   |
| 22..33 | In/Out         | D20..D31 | D20..D31 | D20..D31 | Processor Data Bus                                       |
| 34     | In             | INTB     | INTB     | INTB     | Pulled up to VCC via 1k. not connected to anything else. |
| 35     | Out Open Drain | _INT     | _INT     | _INT     | Interrupt output (_INT2)                                 |
| 36     | Out            | SIZ1     | SIZ1     | SIZ1     | Transfer Size                                            |
| 37     | In/Out         | R_W      | R_W      | R_W      | Read/Write                                               |
| 38     | In/Out         | _AS      | _AS      | _AS      | Address Strobe                                           |
| 39     | In/Out         | _DS      | _DS      | _DS      | Data Strobe                                              |
| 40     | In/Out         | _DSACK1  | _DSACK1  | _DSACK1  | Data transfer and size acknowledge                       |
| 41     | In/Out         | _DSACK0  | _DSACK0  | _DSACK0  | Data transfer and size acknowledge                       |
| 42     | -              | VSS      | VSS      | VSS      | GND                                                      |
| 43     | In             | _STERM   | _STERM   | _STERM   | Synchronous Termination (bus cycle)                      |
| 44     | In             | SCLK     | SCLK     | SCLK     | Clk input (CPUCLKB) 16/25MHz                             |
| 45     | In             | _CS      | _CS      | _CS      | Chip select (_SCSI)                                      |
| 46     | In             | _RESET   | _RESET   | _RESET   | Reset (connected to _IORST)                              |
| 47     | In             | _BERR    | _BERR    | _BERR    | Bus Error                                                |
| 48..55 | In/Out         | PD0..PD7 | PD0..PD7 | PD0..PD7 | Peripheral device data port (SCSI)                       |
| 56     | In/Out         | NC       | PD8      | CNT      | Peripheral device data port (AA3000/+ i2c)               |
| 57     | In/Out         | NC       | PD9      | SP       | Peripheral device data port (AA3000/+ i2c)               |
| 58     | In/Out         | NC       | PD10     | AP_0     | Peripheral device data port (AA3000/+DSP)                |
| 59     | In/Out         | NC       | PD11     | AP_1     | Peripheral device data port (AA3000/+DSP)                |
| 60     | In/Out         | NC       | PD12     | AP-2     | Peripheral device data port (AA3000/+DSP)                |
| 61     | In/Out         | NC       | PD13     | VSS      | Peripheral device data port (AA3000/+ GND)               |
| 62     | In/Out         | NC       | PD14     | AP_3     | Peripheral device data port (AA3000/+DSP)                |
| 63     | -              | VCC      | VCC      | VCC      | +5V DC                                                   |
| 64     | In/Out         | NC       | PD15     | AP_4     | Peripheral device data port (AA3000/+DSP)                |
| 65     | In             | _DREQ    | _DREQ    | _DREQ    | Peripheral Port Data Request                             |
| 66     | Out            | _DACK    | _DACK    | _DACK    | Peripheral Port Data Acknowledge                         |
| 67     | Out            | _CSS     | _CSS     | _CSS     | Peripheral Port 0 chip select (SCSI)                     |
| 68     | Out            | _IOW     | _IOW     | _IOW     | Peripheral Port Write                                    |
| 69     | Out            | _IOR     | _IOR     | _IOR     | Peripheral Port Read                                     |
| 70     | Out            | _CSX0    | _CSX0    | AP_5     | Peripheral Port 1A chip select (AA3000/+DSP)             |
| 71     | Out            | _CSX1    | _CSX1    | AP_6     | Peripheral Port 2 chip select (AA3000/+DSP)              |
| 72     | In             | _IORDY   | _IORDY   | _IORDY   | IORDY FOR PATA/IDE drives (not used in A3000)            |
| 73     | In             | INTA     | INTA     | INTA     | Peripheral Port 0 interrupt request (SCSI)               |
| 74     | Out            | INC_ADD  | INC_ADD  | AP_7     | A3000 not connected, (AA3000/+ DSP)                      |
| 75     | Out            | _DMAEN   | _DMAEN   | _DMAEN   | Enable Ramsey as address generator for DMA cycle         |
| 76..80 | In             | A2..A6   | A2..A6   | A2..A6   | Processor Address Bus                                    |
| 81     | Out            | _BR      | _BR      | _BR      | Bus Request                                              |
| 82     | In             | _BG      | _BG      | _BG      | Bus Grant                                                |
| 83     | In/Out         | _BGACK   | _BGACK   | _BGACK   | Bus Grant Acknowledge                                    |
| 84     | -              | VSS      | VSS      | VSS      | GND                                                      |

## 1.4. I/O DEFINITIONS AND LOCATIONS {#IO}

The following I/O addresses refer only to offset locations.

### 1.4.1. SDMAC PERIPHERAL I/O MEMORY MAP

> **SDMAC Base Address: ```$00DD0000```**

Note that the address decoding for the SDMAC base address is performed by the FAT GARY gate array, Fat Gary generates the chip select signal _CS (pin 45) for addresses in the range ```$00DD0000 to $00DD3fff```

equation for chip select signal:

```!CS = !FC1 & FC0 & !A31 & !A30 & !A29 & !A28 & !A27 & !A26 & !A25 & !A24 & A23 & A22 & !A21 & A20 & A19 & A18 & !A17 & A16 ```
> :memo: **Note:**  In order to get the chip select signal out to the SDMAC as quickly as possible, it is **NOT** qualified with the address strobe **_AS**

This means the SDMAC is located betweeen addresses ```$00DD0000-$00DD007F``` with access repeated every ```$80``` untill ```$00DD3FFF``` 
| HEX Offset  | Symbolic Name         | Definition                   | Type           |
|-------------|-----------------------|------------------------------|----------------|
| 00          | [DAWR](#DAWR)         | DACK Width Register          | (write only)   |
| 04          | [WTC](#WTC)           | Word Transfer Count Register | (read/write)   |
| 08          | [CNTR](#CNTR)         | Control Register             | (read/write)   |
| 0C          | [ACR](#ACR)           | Address Count Register       | (read/write)   |
| 10          | [ST_DMA](#ST_DMA)     | Start DMA Transfers          | (rd/wr-strobe) |
| 14          | [FLUSH](#FLUSH)       | Flush FIFO                   | (rd/wr-strobe) |
| 18          | [CINT](#CINT)         | Clear Interrupts             | (rd/wr-strobe) |
| 1C          | [ISTR](#ISTR)         | Interrupt Status Register    | (read only)    |
| 20,24,28,2C | [Reserved](#RESERVED) | Undefined                    |                |
| 30,34,38    | [Reserved](#RESERVED) | Undefined                    |                |
| 3C          | [SP_DMA](#SP_DMA)     | Stop DMA Transfers           | (rd/wr-strobe) |
| 40 - 4C     | [PORT0](#PORT0)       | 8 BIT Peripheral Port (SCSI) | (read/write)   |
| 50 - 5C     | [PORT1A](#PORT1A)     | 8 BIT Peripheral Port (XT#0) | (read/write)   |
| 60 - 6C     | [PORT2](#PORT2)       | 8 BIT Peripheral Port (XT#1) | (read/write)   |
| 70 - 7C     | [PORT1B](#PORT1B)     | 16 BIT Peripheral PORT (AT)  | (read/write)   |

> :memo: **NOTE:** [ACR](#ACR) and [WTC](#WTC) are 32 bit registers. All other registers and ports are 8 bits or smaller and are located on the low order data bus (D0-D7) with the exception of [PORT1B](#PORT1B) which is 16 bits and located on the high order data bus (D16-D31).

All registers respond as 32-bits wide (DSACK1 and DSACK0) except [PORT1B](#PORT1B) which responds as 16-bits wide (DSACK0) and [ACR](#ACR) which is in the RAMSEY gate array and requires external cycle termination performed by RAMSEY.

## 1.5. REGISTER AND COMMAND DESCRIPTIONS {#REG}

### 1.5.1. DAWR (Address: ```$00```) — write only {#DAWR}

The **DATA ACKNOWLEDGE WIDTH REGISTER** is used to determine the pulse width of _DACK,_DACK IS the SCSI signal. The pulse width of the signals is specified by the external device manufacturer and determines the data transfer rate to and from the SDMAC to the peripheral device. At reset [DAWR](#DAWR) is initialized to zero. This pulse width is affected by the system clock rate as detailed below.

**Register bit descriptions:**

| Bit          | 7 | .. | 2 | 1   | 0   |
|--------------|---|----|---|-----|-----|
| **Function** | X | .. | X | DW1 | DW0 |

> :memo: **NOTE:** **X** Denotes don’t care.

_DACK (pin 66) pulse width is determined as follows:

| DW1 | DWO | DACK WIDTH (number of system clocks) |
|-----|-----|--------------------------------------|
| 0   | 0   | 1 SCLK period                        |
| 0   | 1   | 2 SCLK period                        |
| 1   | 0   | 3 SCLK period                        |
| 1   | 1   | 4 SCLK period                        |

> :memo: **NOTE:** For A3000 machines, set [DAWR](#DAWR) to 3.

> :memo: **NOTE:** The DAWR register is not present in the Rev 4 SDMAC.

### 1.5.2. WTC (Address: ```$04```) — read/write {#WTC}

The **WORD TRANSFER COUNTER** provides a 24-bit counter addressed as a 32-bit longword for determining the
number of data words (16 bits) to be transferred by the SDMAC. A minimum of one to a maximum of 16 million
data words can be transferred with a single command. The counter must be initialized prior to beginning a transfer and will automatically decrement once per word transferred until it reaches the terminal count value of zero.

**Register bit descriptions:**

| Bit          | 31 | .. | 24 | 23  | .. | 0   |
|--------------|----|----|----|-----|----|-----|
| **Function** | X  | .. | X  | MSB | .. | LSB |

> :memo: **NOTE:** **X** Denotes don’t care.

> :memo: **NOTE:** The WTC register is read only in the Rev 4 SDMAC and will always return the  value $00000004.
### 1.5.3. CNTR (Address: ```$08```) — read/write {#CNTR}

The **CONTROL REGISTER** is an 8 bit register used to set mode and operating parameters of the SDMAC. An external reset will set all register bits to a low state.

**Register bit descriptions:**

| Bit          | 7 | 6 | 5             | 4               | 3             | 2               | 1             | 0               |
|--------------|---|---|---------------|-----------------|---------------|-----------------|---------------|-----------------|
| **Function** | X | X | [TCEN](#TCEN) | [PREST](#PREST) | [PDMD](#PDMD) | [INTEN](#INTEN) | [DDIR](#DDIR) | [IO_DX](#IO_DX) |

> :memo: **NOTE:** **X** Denotes don’t care.

#### 1.5.3.1. TCEN — Terminal Count Enable, Active High {#TCEN}

Setting the Terminal Count Enable will enable terminal count hardware.

If this bit is set, upon reaching a terminal count of zero the SDMAC will:

- Terminates operation
- Releases the bus if it has control
- Set [E_INT](#E_INT) high in the [INTERRUPT STATUS REGISTER](#ISTR)
- Force CSX1 (pin 71) low if the CONTROL REGISTER bit [PDMD](#PDMD) is set low.
- If interrupts are enabled, [INT__P](#INT_P) will also be set high in the [INTERRUPT STATUS REGISTER](#ISTR)
- The external host interrupt pin, INT__2, will go to an active low state

#### 1.5.3.2. PREST — Peripheral Reset, Active High {#PREST}

PREST is intended to be used to control a reset signal for external peripheral devices. Setting PREST high will cause the SDMAC output pins,**_IOW** and **_IOR** to go low.

An active low external reset for peripheral devices can then be derived from **_IOW** and **_IOR** as follows:

> ```External Peripheral Reset = _IOW &_IOR```

> :memo: **NOTE:** The external reset can thus be implemented with one ‘AND’ gate)

#### 1.5.3.3. PDMD — Peripheral Device Mode Select {#PDMD}

The SDMAC is capable of controlling two separate types of peripheral interfaces. These two interfaces are mutually exclusive, only one interface can be active at any given time. When PDMD is set high the interface mode is intended for SCSI controller type devices. When set low the interface mode is intended for direct connect to IBM ‘AT/XT’ type devices.

> ```Thus for PDMD, 1 = SCSI, 0 = XT/AT.```

#### 1.5.3.4. INTEN — Interrupt Enable, Active High {#INTEN}

Setting INTEN will enable the SDMAC to generate external interrupts. If set any internally generated interrupt or an external interrupt on INTA (pin 73) or INTB (pin 34), will set [INT__P](#INT_P) high in the [INTERRUPT STATUS REGISTER](#ISTR) and will force the external host interrupt, INT__2 (pin 35), to an active low state.

#### 1.5.3.5. DDIR — Device Direction {#DDIR}

DDIR is used to define the direction of data transfers to and from peripheral devices. Direction is determined as follows:

> DDIR DIRECTION
1 = Read from host, write to peripheral.
0 = Write to host, read from peripheral.

> **2022-02-20 Mike T:** *I think this is used to control the R_W pin when the SDMAC is acting as a bus master.*

#### 1.5.3.6. IO_DX — IORDY and CSX1 Polarity Select {#IO_DX}

The IO__DX bit is used to define the polarity of the SDMAC pins CSX1 (pin 71) and IORDY (pin 72). If set high, the CSX1 output and IORDY input pin are inverted from their default polarities imposed when the SDMAC is reset.

### 1.5.4. ACR (Address: ```$0C```) — read/write {#ACR}

:warning: **This register is in the RAMSEY gate array NOT the SDMAC.**.

The **ADDRESS COUNT REGISTER** provides a 32 bit address counter for determining the starting address of a DMA transfer and is written as a single 32-bit longword. The counter must be initialized prior to the transfer of data and is incremented by 4 if the SDMAC is transferring to/from a 32-bit memory area or by 2 if the SDMAC is transferring data to/from a 16 bit memory area.
This continues until the terminal count (enabled in the CNTR register) or an external END-OF-PROCESS is reached (INTA active).

This register is actually in the RAMSEY gate array and thus must be used with the RAMSEY chip or a device that emulates the Address Counter function.

> :memo: **NOTE:** The counter can only be preset to a longword aligned boundary (address bits al and aO are always written as 0,0), all other types of non-aligned transfers MUST be done as programmed I/O.

**Register bit descriptions:**

| Bit          | 31  | .. | 0   |
|--------------|-----|----|-----|
| **Function** | MSB | .. | LSB |

#### 1.5.4.1. RAMSEY DMAC SUPPORT

**RAMSEY** contains the address counters used during DMA via the onboard controller. When **_DMAEN** becomes low, the address lines become outputs and provide the DMA addresses.

The DMA address is incremented on the rising edge of **_AS** whenever **_DMAEN** is low.

> Since DMA to both 32 and 16 bit ports are supported, RAMSEY must monitor how the cycle was terminated so that it can increment the address counter by the appropriate amount.

- If **_STERM** transitioned low sometime during the cycle, then the port was **32 bits wide**, and the address is incremented by **4**.

- If **_DSACK0** transitions during the DMA bus cycle, then the port was also **32 bits wide** (_DSACK0 and_DSACK1 are both set low to terminate an asynchronous 32 bit transfer).

- If **neither signal** is seen to transition, then it can be assumed that the cycle was terminated by **_DSACK1**, indicating that the port was **16 bits wide**, and the address is incremented by **2**.

The address counters are preset before DMA is done by writing to the 32 bit register at location ```$OODDOOOC``` (this register is readable as well). The counter can only be preset to a long word aligned boundary (bits 1 and 0 are always written as 0,0).

 >:memo: **Ramsey Rev 04:** The counter can only be preset to an even longword boundary **(bits 1 and 0 are always written as 0,0)**

> :memo: **Ramsey Rev 07:** The counter can only be preset to an even word boundary **(bit 0 is always written as 0)**. If **A1** is high when a cycle terminates, then address is always incremented by **2** regardless of how the cycle terminates.

### 1.5.5. ST_DMA (Address: ```$10```) — read/write strobe {#ST_DMA}

Any write/read to the START DMA location will cause the SDMAC to begin execution. Execution will continue until either a terminal count is reached or an external EOP is generated, as well as, an error condition occurs, or a SP_DMA command.

### 1.5.6. FLUSH (Address: ```$14```) — read/write strobe {#FLUSH}

A write/read to this location will cause the SDMAC to flush what remains in the internal 4 longword FIFO onto the host bus.

The use of FLUSH is needed whenever the SDMAC is not using the Terminal Count mode of DMA transfers which is enabled by the [TCEN](#TCEN) bit of the [control register](#CNTR).

If the Terminal Count mode of DMA transfer is not enabled by the [TCEN](#TCEN) bit then the SDMAC can be free-running (started with ST_DMA) and will continue
until no more data is presented/requested across the SCSI bus.

After an external EOP is generated, a FLUSH command followed by a SP_DMA command terminates the transfer.

> :memo: **NOTE:** This location should **NOT** be strobed if no DMA transfer was started. FLUSH need only be used when reading from the peripheral device.

### 1.5.7. CINT (Address: ```$18```) — read/write strobe {#CINT}

Any write/read to the CLEAR INTERRUPT location will clear all internally or externally generated interrupts and the system interrupt signal, INT__2, if it was generated internally.

> :memo: **NOTE:** CLR_INT has no effect on externally generated interrupts connected to the SDMAC INT2 pin.

### 1.5.8. ISTR (Address: ```$1C```) — read only {#ISTR}

The **Interrupt Status Register** is a 9 bit register used to inform the host of interrupt activity and of internal static conditions.

All internally generated interrupts are set in-active by a hardware reset.

**Register bit descriptions:**

| Bit          | 8             | 7               | 6             | 5               | 4               | 3                 | 2                 | 1                 | 0                 |
|--------------|---------------|-----------------|---------------|-----------------|-----------------|-------------------|-------------------|-------------------|-------------------|
| **Function** | [INTX](#INTX) | [INT_F](#INT_F) | [INTS](#INTS) | [E_INT](#E_INT) | [INT_P](#INT_P) | [UE_INT](#UE_INT) | [OE_INT](#OE_INT) | [FF_FLG](#FF_FLG) | [FE_FLG](#FE_FLG) |

#### 1.5.8.1. INTX — XT/AT Interrupt pending, Active High {#INTX}

This bit is set high whenever the INTB pin (pin 34) is forced low by an XT/AT peripheral device.

If the Interrupt Enable Bit is set high (interrupts enabled) in the CNTR register, INTX will also activate INT__P and cause the external
interrupt signal, INT__2, to go to an active low state on the host bus.

#### 1.5.8.2. INT_F — Interrupt Follow, Active High {#INT_F}

INT__F is used to indicate a pending interrupt condition from the SDMAC or external peripheral device.

It is activated by any of the following interrupt signals: INTX, INTS, E__INT, UE__INT, or OE__INT. INT__F is not effected
by the Interrupt Enable Bit in the CNTR register.

#### 1.5.8.3. INTS — SCSI Peripheral Interrupt, Active High {#INTS}

INTS is used to indicate that an external SCSI peripheral device connected to the INTA pin (pin 73) is attempting to interrupt the host.

An active INTS will activate INT__F. If the Interrupt Enable Bit is set high (interrupts enabled) in the CNTR register, INTS will also activate INT__P and cause the external interrupt signal, INT__2, to go to an active low state on the host bus.

#### 1.5.8.4. E_INT — End-Of-Process Interrupt, Active High {#E_INT}

E__INT is used to indicate that either the SDMAC has reached its Terminal Count or a FLUSH command has completed.

An active E_INT will activate INT__F. If the Interrupt Enable Bit is set high, E__INT will also activate INT__P and cause the external interrupt signal, INT__2, to go to an active low state.

#### 1.5.8.5. INT_P — Interrupt Pending, Active High {#INT_P}

INT__P is used to indicate a pending interrupt condition from the SDMAC or external peripheral device only when interrupts are enabled.

It is activated by any of the following interrupt signals: INTX, INTS, E__INT, UE__INT, or OE__INT. INT__P is only active when the Interrupt Enable Bit is set high.

#### 1.5.8.6. UE_INT — Under-Run FIFO Error Interrupt, Active High {#UE_INT}

UE__INT is used to indicate that the SDMAC internal FIFO has an under-run error.

An active UE__INT will activate INT__F.

If the Interrupt Enable Bit is set high, UE__INT will also activate INT__P and cause the external interrupt signal, INT__2, to go to an active low state.

#### 1.5.8.7. OE_INT — Over-Run FIFO Error Interrupt, Active High {#OE_INT}

OE_INT is used to indicate that the SDMAC internal FIFO has an over-run error.

An active OE__INT will activate

INT__F. If the Interrupt Enable Bit is set high, OE__INT will also activate INT__P and cause the external interrupt signal, INT_2, to go to an active low state.

#### 1.5.8.8. FF_FLG — FIFO Full Flag, Active High {#FF_FLG}

FF__FLG is used to indicate the status of the SDMAC internal FIFO.

Whenever the internal FIFO reaches its full longword count of 4,
FF__FLG will go to an active high state and remain there until at least one longword (32-bits) is removed from the FIFO.

#### 1.5.8.9. FE_FLG — FIFO Empty Flag, Active High {#FE_FLG}

FE__FLG is used to indicate the status of the SDMAC internal FIFO.

Whenever the internal FIFO reaches a longword count of 0, the FE__FLG will go to an active state and remain there until at least one word is entered into the FIFO.

### 1.5.9. RESERVED (Address: ```$20,$24,$28,$2C,$30,$34,$38```) {#RESERVED}

These longword addresses are reserved for future expansion.

### 1.5.10. SP_DMA (Address: ```$3C```) — read/write strobe {#SP_DMA}

Any write/read to the STOP DMA location will cause the SDMAC to abort execution.

Register contents are unaffected by this operation and no interrupts will be generated.

### 1.5.11. PORT0 (Address range: ```$40 - $4C```) — read/write {#PORT0}

PORT0 address range is an internally decoded address range for selecting an external SCSI controller device.

Addressing the SDMAC within this range will cause the SDMAC to generate the appropriate interface signals (i.e. chip select,read, write, etc.) to allow communication with external device.

I/O definitions within this address range is application dependent and depends on how the user has connected the SCSI controller device to the host bus address logic for register selection of internal SCSI controller registers.

> In the A3000 machine the programmer should access (read/write) the 33C93 SCSI registers  as follows:

| Register                               | R/W        | Access   | Address                  | DBUS byte lane    |
|----------------------------------------|------------|----------|--------------------------|-------------------|
| 33C93 Address Register                 | Write only | longword | ```$40```                | D7-D0             |
| 33C93 Auxiliary Status Register (SASR) | Read only  | byte     | ```$41, $45, $49, $4D``` | D23-D16 and D7-D0 |
| 33C93 Register Data (SCMD)             | R/W        | byte     | ```$43, $47, $48, $4F``` | D23-D16 and D7-D0 |

In the A3000 the **33C93** is accessed via indirect addressing mode. This mode is enabled by Connecting **ALE** on the **33C93** to GND.

To access the data registers of the **33C93** first load the **Address Register ```$40```** with the address of the register you wish to access, then the **Register Data ```$43```** can be accessed (read or write). Following every access of the register data, the address register will automatically increment to point to the next register, with exception of the following registers:

- Auxiliary Status Register
- Data Register
- Command Register

### 1.5.12. PORT1A (Address range: ```$50 - $5C```) — read/write {#PORT1A}

PORTIA address range is an internally decoded address range for selecting one of two external 8-bit ‘XT’ compatible devices.

Addressing the SDMAC within this range will cause the SDMAC to generate the appropriate interface signals (i.e. chip select, read, write, etc.) to allow communication with an external device. I/O definitions within this address
range is application dependent.

### 1.5.13. PORT2 (Address range: ```$60 - $6C```) — read/write {#PORT2}

PORT2 address range is an internally decoded address range for selecting a second external 8-bit ‘XT’ compatible device.

Addressing the SDMAC within this range will cause the SDMAC to generate the appropriate interface signals (i.e. chip select, read, write, etc.) to allow communication with an external device. I/O definitions within this address
range is application dependent.

To support a second ‘XT’ device, the IO__DX bit in the CNTR register must be set
to a low state.

### 1.5.14. PORT1B (Address range: ```$70 - $7C```) — read/write {#PORT1B}

PORT1B address range is an internally decoded address range for selecting an external 16-bit ‘AT’ compatible device.

Addressing the SDMAC within this range will cause the SDMAC to generate the appropriate interface signals (i.e. chip select, read, write, etc.) to allow communication with an external device. I/O definitions within this address range
is application dependent.

The IO__DX bit in the CNTR register should be set to a high state.

## 1.6. SDMAC TIMING DATA

This device is intended to run synchronously with the 68030 CPU clock. In the A3000 computer the device runs at either 16 MHz or 25 MHz.
The maximum clock rate for SCLK is 25 MHz.

The SDMAC runs asynchronously with the SCSI peripheral device (in A3000 the WD33C93A runs at 14.3 MHz).

### 1.6.1. Example timing diagram

```wavedrom
{ signal: [
  { name: "clk",         wave: "p.....|..." },
  { name: "Data",        wave: "x.345x|=.x", data: ["head", "body", "tail", "data"] },
  { name: "Request",     wave: "0.1..0|1.0" },
  {},
  { name: "Acknowledge", wave: "1.....|01." }
]}
```
