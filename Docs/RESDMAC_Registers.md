# ReSDMAC Additional Registers

This document describes the **ReSDMAC-specific** registers that extend the original SDMAC register map. For the baseline SDMAC registers and bus behavior, see `Docs/SDMAC.md`.

## Addressing
- **Base address**: `0x00DD0000` (decoded by Fat Gary, same as SDMAC).
- **Offsets below** are **byte offsets** from the SDMAC base.
- Accesses are **longword** cycles unless otherwise noted.

## Register summary

| Offset | Name         | R/W  | Width | Notes |
|-------:|--------------|:----:|:-----:|-------|
| 0x20   | VERSION      | R/W  | 32    | ASCII version string (4 chars). |
| 0x24   | FLASH_ADDR   | R/W  | 24    | Flash address register (low 24 bits). |
| 0x28   | FLASH_DATA   | R/W  | 32    | Flash data window (read/write). |
| 0x2C   | DEVICE       | R    | 5     | FPGA device code (10M02/10M04/10M16). |
| 0x58   | SSPBDAT      | R/W  | 32    | Test register (fake SSPB data). |
| 0x5C   | DSP          | R    | 8     | Latched DSP/port status bits. |

## 1. VERSION (offset `0x20`)
**Type:** read/write  
**Width:** 32 bits  

This register holds a 4-character ASCII version tag. On reset it is initialized from the build-time `DEF_VERSION` macro (e.g., `"v9.9"`). The register is also writable for test or bring-up workflows.

**Register layout:**

| Bits | Description |
|------|-------------|
| 31:0 | 4 ASCII characters (big-endian byte order as stored in the register). |

## 2. FLASH_ADDR (offset `0x24`)
**Type:** read/write
**Width:** 24 bits

Address register for the flash window at `FLASH_DATA`. Only the low 24 bits are stored.

**Register layout:**

| Bits | Description |
|------|-------------|
| 23:0 | Flash address |
| 31:24 | Reserved/unused |

**Flash Address Map:**

The On-Chip Flash IP provides two memory-mapped regions:

| Region | Address Range | Size | Description |
|--------|---------------|------|-------------|
| Flash Data | `0x000000` – `0x0C5FFF` | ~788 KB | User flash memory data region |
| Flash CSR | `0x080000` – `0x080007` | 8 bytes | Control and Status Registers |

**Notes:**

- The Flash Data region provides access to the UFM (User Flash Memory)
- The Flash CSR region contains the control and status registers for flash operations (erase, program, protection)
- Addresses written to `FLASH_ADDR` should target the appropriate region based on the desired operation

## 3. FLASH_DATA (offset `0x28`)
**Type:** read/write
**Width:** 32 bits

Data window into on-chip flash. The address used for the access is taken from `FLASH_ADDR`. Reads and writes are acknowledged by the flash interface in hardware builds.

## 4. DEVICE (offset `0x2C`)
**Type:** read-only  
**Width:** 5 bits (returned in low bits of the 32-bit read)  

Identifies the FPGA variant used to build the bitstream. This is derived from the `DEVICE` build macro.

**Register layout:**

| Bits | Description |
|------|-------------|
| 4:0  | Device code: `2` = 10M02, `4` = 10M04, `16` = 10M16 |
| 31:5 | Reserved/zero |

## 5. SSPBDAT (offset `0x58`)
**Type:** read/write  
**Width:** 32 bits  

A **test-only** register used as a fake “Synchronous Serial Peripheral Bus Data” register. It is used by cocotb and external test tools to validate bus timing and register behavior. It does not map to a real SDMAC function.

## 6. DSP (offset `0x5C`)
**Type:** read-only  
**Width:** 8 bits (returned in low byte)  

Latched snapshot of the **A3000+ / SDMAC Rev4** DSP-related pins (AP_0..AP_7). The value is captured on read.

**Bit layout (A3000+ / SDMAC Rev4):**

| Bit | AP_x | SDMAC Rev4 pin function (from `Docs/SDMAC.md`) |
|-----|------|-----------------------------------------------|
| 7   | AP_7 | `INC_ADD` (pin 74)                            |
| 6   | AP_6 | `CSX1` (pin 71)                               |
| 5   | AP_5 | `CSX0` (pin 70)                               |
| 4   | AP_4 | `PD15` (pin 64)                               |
| 3   | AP_3 | `PD14` (pin 62)                               |
| 2   | AP_2 | `PD12` (pin 60)                               |
| 1   | AP_1 | `PD11` (pin 59)                               |
| 0   | AP_0 | `PD10` (pin 58)                               |

**Implementation note:** The RTL packs these bits as `{INC_ADD, CSX1, CSX0, PDATA_I[15], PDATA_I[14], PDATA_I[12], PDATA_I[11], PDATA_I[10]}` to match the AP_7..AP_0 ordering above.
