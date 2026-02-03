# Timing Constraints and CDC Notes (A3000 + ReSDMAC)

This document summarizes **critical timing constraints** and **CDC/metastability risks** derived from:
- `Docs/MC68030EC.pdf` (MC68030 electrical/timing specs)
- `Docs/Commodore/A3000.pdf` (A3000 schematics)
- `Docs/SDMAC.md` (SDMAC background and clocks)
- `Docs/WD33C93/WD33C93B_WesternDigital.pdf` (OCR from scanned PDF)

**Note:** The WD33C93B datasheet is a scanned image; timing values below were extracted via OCR and should be verified against the original tables for absolute accuracy.

## Clock domains in the A3000/SDMAC system
- **SCLK / CPUCLKB**: 68030 bus clock at **16 or 25 MHz** (40 ns period at 25 MHz).
- **WD33C93A SCSI clock**: **~14.3 MHz** in the A3000 (as noted in `Docs/SDMAC.md`).
- **ReSDMAC internal**: `CLK100` from PLL + 0/90/180/270 phase markers.

This means the WD33C93A side is **asynchronous** to SCLK, and any signals crossing from SCSI into SCLK/CLK100 must be treated as CDC.

## Critical MC68030 timing constraints (25 MHz values)
From `Docs/MC68030EC.pdf`, the A3000 25 MHz mode yields these key asynchronous constraints:

1) **Asynchronous input setup to clock low** (spec #47A): **>= 2 ns**  
2) **Asynchronous input hold from clock low** (spec #47B): **>= 8 ns**  

These apply to **asynchronous inputs** such as DSACKx, BERR, HALT, AVEC, and other async inputs (see Fig. 3/4 in the MC68030EC timing section).

3) **DSACKx asserted to Data-In valid** (spec #31): **min 8 ns, max 70 ns**  
This is the data-valid window for asynchronous read cycles when DSACK terminates the cycle.

4) **BG width (asserted/negated)** (spec #39/#39A): **>= 60 ns**  
If the SDMAC is participating in bus arbitration, these minimum widths should be respected.

These values drive timing constraints and interface assumptions for the CPU-side FSM.

## Timing constraints you likely want in implementation
These are expressed as **design intent**; the exact syntax depends on your FPGA tool.

### 1) Primary clock constraints
- `SCLK` = 25 MHz (period 40 ns) and/or 16 MHz (period 62.5 ns)
- `CLK100` = 100 MHz (period 10 ns)

### 2) Asynchronous input timing (relative to SCLK)
The MC68030 treats DSACKx/BERR/HALT/AVEC as **asynchronous inputs**, so the SDMAC must obey:
- **setup >= 2 ns**, **hold >= 8 ns** (25 MHz).

Recommended handling:
- If these signals are sampled synchronously in the FPGA, use **input delay constraints** consistent with the setup/hold window.
- Or, treat them as **asynchronous inputs** with explicit CDC handling (synchronizers or handshake), then apply false paths where appropriate.

### 3) DSACKx-to-data window
For read cycles terminated by DSACKx:
- Data must become valid **8–70 ns after DSACKx assertion** (25 MHz).

This is important if you are modeling read data timing against DSACK in simulation or if you are trying to meet MC68030 bus protocol more strictly in hardware.

## Am33C93A processor indirect + non-burst DMA timing (OCR-extracted)
The A3000 uses **processor read/write indirect addressing** and **non-burst DMA**. The following values are from `Docs/WD33C93/am33c393a.pdf` pages **33** and **35** (OCR). These should be treated as **authoritative for A3000 timing** and verified against the original tables as needed.

### Processor Write — Indirect Addressing (page 33)
- **A0 valid to WE low (tAVWL)**: **min 0 ns**
- **CS low to WE low (tCRWL)**: **min 0 ns**
- **WE pulse width (tWE)**: **min 120 ns**
- **Data valid to WE high (tDVWH)**: **min 70 ns**
- **WE high to WE/RE low (tWWRL)**: **min 100 ns**

### Processor Read — Indirect Addressing (page 33)
- **A0 valid to RE low (tAVRL)**: **min 0 ns**
- **CS low to RE low (tCRRL)**: **min 0 ns**
- **RE pulse width (tRE)**: **min 180 ns**
- **RE low to Data valid (tRLDV)**: **min 180 ns**
- **RE high to Data invalid (tRHDI)**: **min 10 ns, max 40 ns**
- **RE high to RE/WE low (tRWRL)**: **min 100 ns**

### DMA Write — Non-burst (page 35)
- **DACK low to WE low (tDLWL)**: **min 0 ns**
- **DACK+WE low to DRQ high (tDLQH)**: **max 75 ns**
- **WE pulse width (tWHWL)**: **min 50 ns**
- **WE high to WE low (tWHWL)**: **min 100 ns** (table shows WE high to WE low)
- **Data valid to WE high (tDVWH)**: **min 25 ns**
- **WE high to DACK high (tWHDH)**: **min 0 ns**
- **WE high to DATA invalid (tWHDI)**: **min 5 ns**
- **DACK high to DRQ low (tDHQL)**: **min 0 ns**

### DMA Read — Non-burst (page 35)
- **DACK low to RE low (tDLRL)**: **min 0 ns**
- **DACK+RE low to DRQ high (tDLQH)**: **max 75 ns**
- **RE pulse width (tRHQL / tRE)**: **min 80 ns**
- **RE high to RE low (tRHRL)**: **min 100 ns**
- **RE low to Data valid (tRLDV)**: **max 70 ns**
- **RE high to DACK high (tRHDH)**: **min 0 ns**
- **RE high to DATA invalid (tRHDI)**: **min 5 ns, max 40 ns**
- **DACK high to DRQ low (tDHQL)**: **min 0 ns**

These constraints apply directly to `_IOR/_IOW`, `_DACK`, and `_DREQ` timing on the WD33C93A interface.

## WD33C93B DMA interface timing (OCR-extracted)
The WD33C93B timing tables are still useful for bounding SDMAC <-> SCSI DMA handshakes across similar modes. The following values come from **WD33C93B Timing Characteristics, Section 6.1**:

### DMA Write (Figure 6-7)
- **DACK low to WE low (tdiwl)**: **min 0 ns**
- **DACK low to DRQ high (tdigh)**: **max 75 ns**
- **WE pulse width (twr)**: **min 50 ns**
- **WE high to WE low (twhwl)**: **min 100 ns**
- **Data valid to WE high (tdvwh)**: **min 25 ns**
- **WE high to DACK high (twhdh)**: **min 0 ns**
- **DACK high to DRQ low (tdhql)**: **min 0 ns**

### DMA Read (Figure 6-8)
- **DACK low to RE low (tdirl)**: **min 0 ns**
- **DACK low to DRQ high (tdiqgh)**: **max 75 ns**
- **RE pulse width (trd)**: **min 80 ns**
- **RE high to RE low (trhrl)**: **min 100 ns**
- **RE low to Data valid (trldv)**: **max 70 ns**
- **RE high to DACK high (trhdh)**: **min 0 ns**
- **RE high to Data invalid (trhdi)**: **min 5 ns, max 40 ns** (OCR range)
- **DACK high to DRQ low (tdhql)**: **min 0 ns**

### Burst DMA (Figures 6-11, 6-12)
If burst DMA is used, the OCR tables indicate shorter pulse widths:
- **Burst write WE pulse width**: **min 30 ns**
- **Burst read RE pulse width**: **min 30 ns**
- **Burst read DACK low to data valid**: **min 50 ns**

These values imply **minimum pulse widths** for `_IOW/_IOR` (or equivalent WE/RE) and bound how quickly `_DREQ` can toggle relative to `_DACK`.

## CDC / metastability risk assessment (current RTL)

### Signals that are **asynchronous** (need CDC attention)
**SCSI domain -> SCLK/CLK100**
- `_DREQ` (from WD33C93A): async due to 14.3 MHz SCSI clock.
- `INTA` (from WD33C93A): async.
- `PD_PORT` data lines when driven by SCSI: async to SCLK; sampling should be qualified by `_DREQ/_DACK` and `_IOR/_IOW`.

**68030/Bus domain -> CLK100 internal**
- `_DSACK[1:0]`, `_STERM`, `_BERR`, `_BG`, `_BGACK` are **asynchronous** per MC68030 timing model.
- `_AS`, `_DS`, `R_W` are synchronous to SCLK when CPU is master, but become **async to CLK100** unless explicitly synchronized.

### Synchronizers already present in RTL
From `RTL/CPU_SM/CPU_SM.v` and `RTL/SCSI_SM/SCSI_SM.v`:
- `CPU_SM` synchronizes: `aBGRANT_`, `aDMAENA`, `aDREQ_`, `aFLUSHFIFO` into CLK100 domain.
- `SCSI_SM` synchronizes: `DREQ_` into CLK100 domain.

### Potential gaps
These inputs are used synchronously but do **not** appear to be synchronized:
- `INTA` into `registers_istr` (clocked on `SCLK`) — **async**, could benefit from a 2‑FF sync or edge-capture.
- `_DSACK[1:0]`, `_STERM`, `_BERR` sampled inside `CPU_SM` logic — currently latched on phase edges, but still asynchronous to CLK100 and should either:
  - meet MC68030 async setup/hold timing, or
  - be explicitly synchronized/handshaken.

## Recommendations (actionable)
1) **Document the bus timing assumptions** in RTL or docs (SCLK 16/25 MHz, async DSACK/BERR/STERM).  
2) **Add CDC notes or synchronizers** for `INTA` and any async bus inputs used in synchronous logic.  
3) **Apply input delay constraints** for DSACK/BERR/STERM relative to SCLK to align with MC68030 spec (#47A/#47B).  
4) **Use multicycle/false-path constraints** where handshake signals are properly synchronized and not required to meet single-cycle timing.

## WD33C93B timing data verification
Because the WD33C93B values above are OCR-derived, I recommend spot-checking the original tables (Figures 6-7 through 6-12) before treating them as authoritative constraints.
