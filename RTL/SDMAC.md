
# SDMAC 390537 (Super Direct Memory Access Controller) 

## INTRODUCTION

The purpose of this specification is to provide a description of Commodore’s 390537  SDMAC, A description of SDMAC Commands, I/O locations and pin-out is included.

## SDMAC DESCRIPTION

The SDMAC is an 84 pin (PLCC), 2 micron CMOS gate-array designed to enhance the performance of the Amiga A3000 computer and to reduce the cost of adding peripheral devices (i.e. SCSI and XT/AT devices) to the Amiga A3000.

Performance is enhanced by providing the computer with a full-speed 16MHz or 25MHz full 32-bit direct memory access controller that runs on the 68030 local fast bus. Data is transferred between Amiga system memory and a peripheral device by utilization of an internal 4 longword (32 bits/longword) FIFO, direct memory access and built-in byte-to word and byte-to-longword funneling.

Over-all cost of adding peripheral devices to the Amiga is reduced due to the combined functionality of the SDMAC.

The SDMAC provides direct connection from the Amiga’s full 32-bit local fast bus to either a SCSI controller device (i.e. WD33C93A) or an ‘XT/AT’ compatible interface. Besides providing direct memory access and bus arbitration, the SDMAC also contains a 16 byte FIFO (eliminating the need for external static buffering), interrupt control logic,
and byte or word (8 or 16 bit peripheral data) to word or longword (16 or 32 bit Amiga data) funneling. 

The SDMAC thus significantly reduces external hardware and manufacturing cost.

## I/O DEFINITIONS AND LOCATIONS

The following I/O addresses refer only to offset locations.

### SDMAC PERIPHERAL I/O MEMORY MAP

> SDMAC Base Address: ```$00DD0000```

Note that the address decoding for the SDMAC base address is done by the FAT GARY gate array and generates the signal selecting the SCSI (pin 45) chip select pin on the SDMAC for addresses from ``` $00DD0000 to $00DD3fff```

| HEX Location | Symbolic Name | Definition | Type |
|--------------|---------------|------------|------|
|00| [DAWR](#DAWR) | DACK Width Register | (write only) |
|04| [WTC](#WTC) | Word Transfer Count Register | (read/write) |
|08| [CNTR](#CNTR) | Control Register | (read/write) |               
|0C [^1] | [ACR](#ACR) | Address Count Register | (read/write) |
|10| [ST_DMA](#ST_DMA) | Start DMA Transfers | (rd/wr-strobe) |
|14| [FLUSH](#FLUSH) | Flush FIFO | (rd/wr-strobe) |
|18| [CINT](#CINT) | Clear Interrupts | (rd/wr-strobe) |
|1C| [ISTR](#ISTR) | Interrupt Status Register | (read only) |
|20,24,28,2C| [Reserved](#RESERVED) |
|30,34,38| [Reserved](#RESERVED) |
|3C| [SP_DMA](#SP_DMA) | Stop DMA Transfers |(rd/wr-strobe) |
|40 - 4C| [PORT0](#PORT0) |  8 BIT Peripheral Port (SCSI)| (read/write)|
|50 - 5C| [PORT1A](#PORT1A) |  8 BIT Peripheral Port (XT#0)| (read/write)|
|60 - 6C| [PORT2](#PORT2) | 8 BIT Peripheral Port (XT#1)| (read/write)|
|70 - 1C| [PORT1B](#PORT1B) |  16 BIT Peripheral PORT (AT)| (read/write)|

**NOTE:** ACR and WTC are 32 bit registers. All other registers and ports are 8 bits or smaller and are located on the low order data bus (D0-D7) with the exception of PORT1B which is 16 bits and located on the high order data bus (D16-D31).

All registers respond as 32-bits wide (DSACK1 and DSACK0) except PORT IB which responds as 16-bits wide (DSACK0) and ACR which is in the RAMSEY gate array and requires external cycle termination performed by RAMSEY.

[^1]:This Address Counter Register is in the RAMSEY gate array. Please see the RAMSEY chip specification for more information.

## REGISTER AND COMMAND DESCRIPTIONS

### DAWR (Address: $00) — write only {#DAWR}

The DATA ACKNOWLEDGE WIDTH REGISTER is used to determine the pulse width of SDACK and XDACK.
SDACK and XDACK are the SCSI and ‘XT’ peripheral handshaking signals respectively. The pulse width of these
signals is specified by the external device manufacturer and determines the data transfer rate to and from the SDMAC
to the peripheral device. At reset DAWR is initialized to zero. This pulse width is affected by the system clock rate
as detailed below.
Bit7 — x
Bit2 — x
Bitl — DW1
BitO — DWO
NOTE: x denotes don’t care.

SDACK (pin 66) or XDACK (controls pin 71, CSX1) width is determined as follows:
DW1
00
1
1
DWO DACK WIDTH (number of system clocks)
0 1 SCLK period
1 2 SCLK period
0 3 SCLK period
1 4 SCLK period
NOTE: For A3000 machines, set DAWR to 3.

### WTC (Address: $04) — read/write {#WTC}

The WORD TRANSFER COUNTER provides a 24-bit counter addressed as a 32-bit longword for determining the
number of data words (16 bits) to be transferred by the SDMAC. A minimum of one to a maximum of 16 million
data words can be transferred with a single command. The counter must be initialized prior to beginning a transfer
and will automatically decrement once per word transferred until it reaches the terminal count value of zero.
Bit31 — x
Bit24 — x
Bit23 — MSB
I I
BitO — LSB
NOTE: x denotes don’t care.

### CNTR (Address: $08) — read/write {#CNTR}

The CONTROL REGISTER is an 8 bit register used to set mode and operating parameters of the SDMAC. An external
reset will set all register bits to a low state.
Register bit descriptions:
Bit7 — x
Bit6 — x
Bit5 — TCEN
Bit4 — PREST
Bit3 — PDMD
Bit2 — INTEN
Bitl — DDIR
BitO — IO__DX

##### TCEN — Terminal Count Enable, Active High

Activating the TCEN will enable terminal count hardware. If set high, upon reaching a terminal count of zero the
SDMAC terminates operation, releases the bus if it has control, sets E__INT high in the INTERRUPT STATUS
REGISTER, and forces CSX1 (pin 71) low if the CONTROL REGISTER bit PDMD is set low. If interrupts are enabled,
INT__P will also be set high in the INTERRUPT STATUS REGISTER, and the external host interrupt pin, INT__2,
will go to an active low state.

##### PREST — Peripheral Reset, Active High

PREST is intended to be used to control a reset signal for external peripheral devices. Setting PREST high will cause
the SDMAC output p in s,__IOW a n d __IOR to go low. An active low external reset for peripheral devices can then
be derived from __IOW a n d __IOR as follows:
(The external reset can thus be implemented with one ‘AND’ gate)
External Peripheral Reset = __IOW & __IOR

##### PDMD — Peripheral Device Mode Select

The SDMAC is capable of controlling two separate types of peripheral interfaces. These two interfaces are mutually
exclusive, only one interface can be active at any given time. When PDMD is set high the interface mode is intended
for SCSI controller type devices. When set low the interface mode is intended for direct connect to IBM ‘AT/XT’
type devices. Thus for PDMD, 1 =SCSI, 0 = XT/AT.

##### INTEN — Interrupt Enable, Active High

Activating the INTEN will enable the SDMAC to generate external interrupts. If set high, any internally generated
interrupt or an external interrupt on INTA (pin 73) or INTB (pin 34), will set INT_P high in the INTERRUPT STATUS
REGISTER and will force the external host interrupt, INT__2 (pin 35), to an active low state.

##### DDIR — Device Direction

DDIR is used to define the direction of data transfers to and from peripheral devices. Direction is determined as follows:
DDIR DIRECTION
1 Read from host, write to peripheral.
0 Write to host, read from peripheral.

##### IO _D X — IORDY and CSX1 Polarity Select

The IO__DX bit is used to define the polarity of the SDMAC pins CSX1 (pin 71) and IORDY (pin 72). If set high,
the CSX1 output and IORDY input pin are inverted from their default polarities imposed when the SDMAC is reset.

### ACR (Address: $0C) — read/write {#ACR}

The ADDRESS COUNT REGISTER provides a 32 bit address counter for determining the starting address of a DMA
transfer and is written as a single 32-bit longword. The counter must be initialized prior to the transfer of data and
is incremented by 4 if the SDMAC is transferring to/from a 32-bit memory area or by 2 if the SDMAC is transferring
data to/from a 16 bit memory area. This continues until the terminal count (enabled in the CNTR register) or an
external END-OF-PROCESS is reached (INTA active). This register is actually in the RAMSEY gate array and thus
must be used with the RAMSEY chip or a device that emulates the Address Counter function.
NOTE: The counter can only be preset to a longword aligned boundary (address bits al and aO are always written
as 0,0), all other types of non-aligned transfers MUST be done as programmed I/O.
Bit31 — MSB
I I
BitO — LSB

### ST_DMA (Address: $10) — read/write strobe {#ST_DMA}

Any write/read to the START DMA location will cause the SDMAC to begin execution. Execution will continue until
either a terminal count is reached or an external EOP is generated, as well as, an error condition occurs, or a SP__DMA
command.

### FLUSH (Address: $14) — read/write strobe {#FLUSH}

A write/read to this location will cause the SDMAC to flush what remains in the internal 4 longword FIFO onto
the host bus. The use of FLUSH is needed whenever the SDMAC is not using the Terminal Count mode of DMA
transfers which is enabled by the TCEN bit of the control register (CNTR). If the Terminal Count mode of DMA
transfer is not enabled by the TCEN bit then the SDMAC can be free-running (started with ST__DMA) and will continue
until no more data is presented/requested across the SCSI bus. After an external EOP is generated, a FLUSH
command followed by a SP_DMA command terminates the transfer. Note that this location should not be strobed
if no DMA transfer was started. FLUSH need only be used when reading from the peripheral device.

### CINT (Address: $18) — read/write strobe {#CINT}

Any write/read to the CLEAR INTERRUPT location will clear all internally or externally generated interrupts and
the system interrupt signal, INT__2, if it was generated internally. CLR__INT has no effect on externally generated
interrupts connected to the SDMAC INT2 pin.

### ISTR (Address: $1C) — read only {#ISTR}

The Interrupt Status Register is a 9 bit register used to inform the host of interrupt activity and of internal static conditions.
All internally generated interrupts are set in-active by a hardware reset.
Bit8 — INTX
Bit7 — INT__F
Bit6 — INTS
Bit5 — E__INT
Bit4 — INT__P
Bit3 — UE__INT
Bit2 — OE__INT
Bitl — FF__FLG
BitO — FE__FLG

##### INTX — XT/AT Interrupt pending, Active High

This bit is set high whenever the INTB pin (pin 34) is forced low by an XT/AT peripheral device. If the Interrupt
Enable Bit is set high (interrupts enabled) in the CNTR register, INTX will also activate INT__P and cause the external
interrupt signal, INT__2, to go to an active low state on the host bus.

##### INT_F — Interrupt Follow, Active High

INT__F is used to indicate a pending interrupt condition from the SDMAC or external peripheral device. It is activated
by any of the following interrupt signals: INTX, INTS, E__INT, UE__INT, or OE__INT. INT__F is not effected
by the Interrupt Enable Bit in the CNTR register.

##### INTS — SCSI Peripheral Interrupt, Active High

INTS is used to indicate that an external SCSI peripheral device connected to the INTA pin (pin 73) is attempting
to interrupt the host. An active INTS will activate INT__F. If the Interrupt Enable Bit is set high (interrupts enabled)
in the CNTR register, INTS will also activate INT__P and cause the external interrupt signal, INT__2, to go to an
active low state on the host bus.

##### E_INT — End-Of-Process Interrupt, Active High
E__INT is used to indicate that either the SDMAC has reached its Terminal Count or a FLUSH command has completed.
An active E_INT will activate INT__F. If the Interrupt Enable Bit is set high, E__INT will also activate INT__P
and cause the external interrupt signal, INT__2, to go to an active low state.

##### INT_P — Interrupt Pending, Active High

INT__P is used to indicate a pending interrupt condition from the SDMAC or external peripheral device only when
interrupts are enabled. It is activated by any of the following interrupt signals: INTX, INTS, E__INT, UE__INT,
or OE__INT. INT__P is only active when the Interrupt Enable Bit is set high.

##### UE_INT — Under-Run FIFO Error Interrupt, Active High

UE__INT is used to indicate that the SDMAC internal FIFO has an under-run error. An active UE__INT will activate
INT__F. If the Interrupt Enable Bit is set high, UE__INT will also activate INT__P and cause the external interrupt
signal, INT__2, to go to an active low state.

##### OE_INT — Over-Run FIFO Error Interrupt, Active High

OE_INT is used to indicate that the SDMAC internal FIFO has an over-run error. An active OE__INT will activate
INT__F. If the Interrupt Enable Bit is set high, OE__INT will also activate INT__P and cause the external interrupt
signal, INT_2, to go to an active low state.

##### FF_FLG — FIFO Full Flag, Active High

FF__FLG is used to indicate the status of the SDMAC internal FIFO. Whenever the internal FIFO reaches its full
longword count of 4, FF__FLG will go to an active high state and remain there until at least one longword (32-bits)
is removed from the FIFO.

##### FE_FLG — FIFO Empty Flag, Active High

FE__FLG is used to indicate the status of the SDMAC internal FIFO. Whenever the internal FIFO reaches a longword
count of 0, the FE__FLG will go to an active state and remain there until at least one word is entered into the FIFO.

#### RESERVED (Address: $20,24,28,2C,30,34,38) {#RESERVED}

These longword addresses are reserved for future expansion.

### SP_DMA (Address: $3C) — read/write strobe {#SP_DMA}

Any write/read to the STOP DMA location will cause the SDMAC to abort execution. Register contents are uneffected
by this operation and no interrupts will be generated.

### PORT0 (Address range: $40 - $4C) — read/write {#PORT0}

PORT0 address range is an internally decoded address range for selecting an external SCSI controller device. Addressing
the SDMAC within this range will cause the SDMAC to generate the appropriate interface signals (i.e. chip select,
read, write, etc.) to allow communication with external device. I/O definitions within this address range is application
dependent and depends on how the user has connected the SCSI controller device to the host bus address logic for
register selection of internal SCSI controller registers. In the A3000 machine the programmer should access (read/write)
the SCMD register as a byte at $43 and access (read/write) the SASR register as a longword at $40 (data in D7-D0).
The SDMAC will also allow the programmer to read the SASR register as a byte at $41 (with data on both D23-D16
and D7-D0) due to the internal and external connections in the SDMAC and the A3000.

### PORT1A (Address range: $50 - $5C) — read/write {#PORT1A}

PORTIA address range is an internally decoded address range for selecting one of two external 8-bit ‘XT’ compatible
devices. Addressing the SDMAC within this range will cause the SDMAC to generate the appropriate interface signals
(i.e. chip select, read, write, etc.) to allow communication with an external device. I/O definitions within this address
range is application dependent.

### PORT2 (Address range: $60 - $6C) — read/write {#PORT2}

PORT2 address range is an internally decoded address range for selecting a second external 8-bit ‘XT’ compatible
device. Addressing the SDMAC within this range will cause the SDMAC to generate the appropriate interface signals
(i.e. chip select, read, write, etc.) to allow communication with an external device. I/O definitions within this address
range is application dependent. To support a second ‘XT’ device, the IO__DX bit in the CNTR register must be set
to a low state.

### PORT1B (Address range: $70 - $7C) — read/write {#PORT1B}

PORT1B address range is an internally decoded address range for selecting an external 16-bit ‘AT’ compatible device.
Addressing the SDMAC within this range will cause the SDMAC to generate the appropriate interface signals (i.e.
chip select, read, write, etc.) to allow communication with an external device. I/O definitions within this address range
is application dependent. The IO__DX bit in the CNTR register should be set to a high state.

## SDMAC TIMING DATA

This device is intended to run synchronously with the 68030 CPU clock. In the A3000 computer the device runs at
either 16 MHz or 25 MHz. The maximum clock rate for SCLK is 25 MHz. The SDMAC runs asynchronously with
the SCSI peripheral device (in A3000 the WD33C93A runs at 14.3 MHz).