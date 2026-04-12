# FIFO Module — `RTL/FIFO/fifo.v`

**ReSDMAC © 2024 Michael Taylor — CC BY-SA 4.0**

---

## 1. Brief Description

The `fifo` module is a synchronous, 32-bit wide, parameterisable-depth FIFO buffer that sits between the CPU bus and the SCSI peripheral port inside the ReSDMAC DMA controller. It is the central data staging area for all DMA transfers in both directions:

- **CPU → SCSI (write):** The CPU writes 32-bit longwords into the FIFO in 16-bit halves (`LHWORD`/`LLWORD`). The SCSI state machine drains the FIFO one byte at a time via the byte-pointer mechanism.
- **SCSI → CPU (read):** The SCSI state machine fills the FIFO one byte at a time. The CPU drains it as 32-bit longwords.

All internal logic is synchronous to `i_CLK100` (100 MHz). All control inputs that originate in other clock domains or from asynchronous FSM outputs are edge-detected internally so that a single rising edge produces exactly one operation regardless of how long the input is held asserted.

The default configuration is **32 bits wide** and **8 entries deep**, giving a total storage capacity of 32 bytes. Both depth and width are overrideable at instantiation via the `DEPTH` and `WIDTH` parameters.

---

## 2. Ports

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `DEPTH`   | `8`     | Number of longword entries in the FIFO buffer |
| `WIDTH`   | `32`    | Data width in bits. Should remain 32 to match the CPU and SCSI datapaths |

### Inputs

| Port | Width | Description |
|------|-------|-------------|
| `i_CLK100` | 1 | 100 MHz main clock. All registers are clocked on the rising edge |
| `i_RST_FIFO_n` | 1 | Active-low synchronous reset. Clears all pointers, counters, and buffer contents. Driven by `(DMAENA & ~CPUSM_FIFO_RST)` in `RESDMAC.v` |
| `i_A1` | 1 | Byte alignment seed. Loaded into `byte_ptr[1]` on reset to allow DMA transfers that start mid-longword |
| `i_FIFO_ID` | WIDTH | Write data bus. Sourced from the `datapath` module output `o_FIFO_WR_DATA` |
| `i_LLWORD` | 1 | Load Lower Word strobe. When asserted, writes `i_FIFO_ID[15:0]` into the lower two bytes of the current write-pointer slot |
| `i_LHWORD` | 1 | Load Higher Word strobe. When asserted, writes `i_FIFO_ID[31:16]` into the upper two bytes of the current write-pointer slot |
| `i_LBYTE_n` | 1 | Active-low Load Byte strobe. When asserted, writes the single byte of `i_FIFO_ID` selected by `byte_ptr` into the current write-pointer slot |
| `i_INCFIFO` | 1 | Increment full/empty counter (entry added). Issued by CPU_SM after a complete longword has been written |
| `i_DECFIFO` | 1 | Decrement full/empty counter (entry consumed). Issued by CPU_SM after a complete longword has been read |
| `i_INCNI` | 1 | Increment Next-In pointer (advance write pointer). Issued by CPU_SM or SCSI_SM |
| `i_INCNO` | 1 | Increment Next-Out pointer (advance read pointer). Issued by CPU_SM or SCSI_SM |
| `i_INCBO` | 1 | Increment Byte-Out pointer. Issued by SCSI_SM after each byte transferred to/from the SCSI device |

### Outputs

| Port | Width | Description |
|------|-------|-------------|
| `o_FIFO_OD` | WIDTH | Read data bus. Always presents the longword at the current read-pointer location. Sourced directly from the buffer array (combinational) |
| `o_FIFOFULL` | 1 | Asserted when `full_empty_count == DEPTH`. Signals CPU_SM and SCSI_SM to pause DMA |
| `o_FIFOEMPTY` | 1 | Asserted when `full_empty_count == 0`. Signals CPU_SM and SCSI_SM to pause DMA |
| `o_BOEQ0` | 1 | Asserted when `byte_ptr == 0`. Indicates the byte pointer is at the upper-upper byte (MSB) |
| `o_BOEQ3` | 1 | Asserted when `byte_ptr == 3`. Indicates the byte pointer is at the lower-lower byte (LSB) |
| `o_BYTE_PTR` | 2 | Current byte pointer value `[1:0]`. Consumed by the `datapath` module to select which byte lane to route to the SCSI port |

---

## 3. Detailed Operation

### 3.1 Edge Detection

Every control input that increments or decrements a counter (`i_INCBO`, `i_INCNI`, `i_INCNO`, `i_INCFIFO`, `i_DECFIFO`) passes through a two-stage edge detector before it takes effect:

```
always @(posedge i_CLK100)
    incbo_edge_detect <= {incbo_edge_detect[0], i_INCBO};

wire incbo_rise_evt = (incbo_edge_detect == 2'b01);
```

This means:
- The operation fires **one clock cycle after** the input rises.
- If the input is held high for N cycles, the operation fires exactly **once** — on the cycle after the initial rise.
- This protects all counters and pointers from glitch- or hold-induced double-counting even when the driving FSM holds its output asserted across multiple 100 MHz cycles.

### 3.2 Write Byte Selection (`byte_ptr` and write strobes)

The 2-bit `byte_ptr` register determines which byte lane of the current write-pointer entry is targeted by a `i_LBYTE_n` assertion:

| `byte_ptr` | Byte lane written | Bit range |
|------------|-------------------|-----------|
| `2'b00`    | Upper-upper (B0)  | `[31:24]` |
| `2'b01`    | Upper-mid (B1)    | `[23:16]` |
| `2'b10`    | Lower-mid (B2)    | `[15:8]`  |
| `2'b11`    | Lower-lower (B3)  | `[7:0]`   |

The four internal byte-write strobes are:

```verilog
assign uuws = (!byte_ptr[1] & !byte_ptr[0] & !i_LBYTE_n) | i_LHWORD;
assign umws = (!byte_ptr[1] &  byte_ptr[0] & !i_LBYTE_n) | i_LHWORD;
assign lmws = ( byte_ptr[1] & !byte_ptr[0] & !i_LBYTE_n) | i_LLWORD;
assign llws = ( byte_ptr[1] &  byte_ptr[0] & !i_LBYTE_n) | i_LLWORD;
```

Key observations:
- `i_LHWORD` simultaneously asserts `uuws` and `umws`, writing both upper bytes in one cycle — used when the CPU writes a 32-bit longword in two 16-bit halves.
- `i_LLWORD` simultaneously asserts `lmws` and `llws`, writing both lower bytes.
- `i_LBYTE_n` (active-low) writes only the single byte addressed by `byte_ptr` — used for byte-by-byte SCSI transfers.

Each strobe enables a separate byte-lane write to `buffer[write_ptr]` so that partial writes never corrupt already-written lanes.

### 3.3 Byte Pointer Initialisation and Byte Alignment (`i_A1`)

On reset, `byte_ptr` is loaded with `{i_A1, 1'b0}`:

| `i_A1` | Initial `byte_ptr` | First SCSI byte targets |
|--------|--------------------|-------------------------|
| `0`    | `2'b00`            | `[31:24]` (MSB first)   |
| `1`    | `2'b10`            | `[15:8]` (mid-word)     |

`i_A1` reflects bit 25 of the ACR (Address Control Register). A DMA transfer whose start address is not longword-aligned has `A1=1`, so the FIFO pre-positions the byte pointer to the correct starting byte within the first longword. This matches the behaviour of the original Commodore SDMAC.

### 3.4 Full/Empty Tracking

The occupancy counter `full_empty_count` is a saturating counter maintained separately from the read/write pointers:

- Incremented by `i_INCFIFO` (rising-edge detected) — issued by CPU_SM when a new longword has been fully written into the FIFO.
- Decremented by `i_DECFIFO` (rising-edge detected) — issued by CPU_SM when a longword has been fully consumed.
- On underflow (count already 0), it wraps to `DEPTH` (by design — prevents counter going negative in unsigned arithmetic).
- On overflow (count already `DEPTH`), it wraps to 0.

```
o_FIFOFULL  = (full_empty_count == DEPTH)
o_FIFOEMPTY = (full_empty_count == 0)
```

> **Important:** `INCFIFO`/`DECFIFO` are the *occupancy* signals. They are distinct from `INCNI`/`INCNO`, which advance the *address* pointers. The CPU_SM is responsible for issuing them in the correct order and combination; they are not automatically coupled to pointer updates inside the FIFO.

### 3.5 Read/Write Pointers

- **Write pointer** (`write_ptr`): incremented by a rising edge on `i_INCNI` (Next-In). Wraps naturally via integer overflow at `2^cntr_bits`.
- **Read pointer** (`read_ptr`): incremented by a rising edge on `i_INCNO` (Next-Out). Wraps naturally.
- Both are `$clog2(DEPTH)` bits wide.
- `o_FIFO_OD` is a direct combinational read of `buffer[read_ptr]` — there is no output register, so data is available immediately when the read pointer settles.

### 3.6 Reset Behaviour

When `i_RST_FIFO_n` is de-asserted (low):
- `write_ptr`, `read_ptr` → `0`
- `full_empty_count` → `0`
- `byte_ptr` → `{i_A1, 1'b0}`
- All `buffer` entries → `{WIDTH{1'b0}}`
- All edge-detect shift registers → `0` (implicitly, as they are reset via the synchronous path)

Note that `i_RST_FIFO_n` in `RESDMAC.v` is driven by `(DMAENA & ~CPUSM_FIFO_RST)`, so the FIFO is held in reset whenever DMA is disabled or the CPU_SM requests a flush.

---

## 4. Integration with ReSDMAC

### 4.1 Position in the Datapath

```
CPU 68030 Bus
     │
  [datapath]  ←── CPU_SM (LHWORD/LLWORD/LBYTE_n strobes)
     │  ↑
     │  └─ o_FIFO_WR_DATA (i_FIFO_ID)
     │
  [fifo]  ─── o_FIFO_OD ──→ [datapath] ──→ CPU Bus / SCSI Port
     ▲
     │
  [SCSI_SM] ── INCBO / INCNI / INCNO
  [CPU_SM]  ── INCFIFO / DECFIFO / INCNI / INCNO
```

### 4.2 DMA Write (CPU → SCSI)

1. CPU_SM acquires the bus and reads a 32-bit word from memory.
2. `datapath` drives `o_FIFO_WR_DATA`.
3. CPU_SM asserts `LHWORD` then `LLWORD` on consecutive cycles (latched through `LLW`/`LHW` registers clocked on `negedge SCLK`), writing both halves into the current `write_ptr` slot.
4. CPU_SM asserts `INCNI` to advance `write_ptr`, then `INCFIFO` to signal a new entry.
5. SCSI_SM observes `~o_FIFOEMPTY`, drives `INCBO` after each byte is transferred to the WD33C93A via `_IOW`.
6. When `o_BOEQ3` is asserted (all 4 bytes of the entry transferred), SCSI_SM asserts `INCNO` to advance `read_ptr` and `DECFIFO` to decrement occupancy.

### 4.3 DMA Read (SCSI → CPU)

1. SCSI_SM observes `~o_FIFOFULL`.
2. Each byte arriving from the WD33C93A via `_IOR` is written through `datapath` into `i_FIFO_ID` with `i_LBYTE_n` asserted. SCSI_SM asserts `INCBO` after each byte.
3. After 4 bytes (`o_BOEQ3`), SCSI_SM asserts `INCNI` and `INCFIFO`.
4. CPU_SM observes `~o_FIFOEMPTY`, reads `o_FIFO_OD` through `datapath`, and writes to memory.
5. CPU_SM asserts `INCNO` and `DECFIFO` after consuming the longword.

### 4.4 BOEQ0 and BOEQ3 as Handshake Signals

`o_BOEQ0` and `o_BOEQ3` are used by CPU_SM and SCSI_SM as handshake boundaries:

| Signal | Meaning in context |
|--------|--------------------|
| `o_BOEQ3` | Last byte of a longword has been handled; pointers can advance |
| `o_BOEQ0` | Byte pointer has wrapped to the start; a new longword slot is ready |

SCSI_SM uses `o_BOEQ3` as a trigger to issue `INCNO`/`DECFIFO` (read direction) or `INCNI`/`INCFIFO` (write direction).

---

## 5. Timing Diagrams

### 5.1 CPU Writes One Longword (LHWORD + LLWORD)

```
CLK100   _|‾|_|‾|_|‾|_|‾|_
LHWORD   __|‾‾‾|_____________   (drives uuws + umws)
LLWORD   ______|‾‾‾|_________   (drives lmws + llws)
INCNI    __________|‾‾‾|_____   rising edge → write_ptr++
INCFIFO  ____________|‾‾‾|___   rising edge (delayed 1 cycle) → count++
```

### 5.2 SCSI Drains One Longword (4 × LBYTE_n)

```
CLK100   _|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_
byte_ptr  [00]  [01]  [10]  [11]
LBYTE_n  _|__|__|__|__|__|__|__|_____________
INCBO    ___|‾‾|___|‾‾|___|‾‾|_____________   → byte_ptr++ after each
BOEQ3    ________________________|‾‾‾‾‾‾‾|_   when byte_ptr == 3
INCNO    __________________________|‾‾‾|____   → read_ptr++
DECFIFO  ____________________________|‾‾‾|__   → count--
```

---

## 6. Parameters and Sizing

| Configuration | DEPTH | Total capacity | Typical use |
|---------------|-------|----------------|-------------|
| Default       | 8     | 32 bytes       | As instantiated in `RESDMAC.v` |
| Minimal       | 4     | 16 bytes       | Resource-constrained variants |

Changing `DEPTH` automatically adjusts the counter widths via `$clog2`. No other code changes are required, but the driving FSMs (CPU_SM, SCSI_SM) have been tuned against a depth of 8 — reducing depth may require re-tuning their watermark decisions.

`WIDTH` should always remain `32` to match the 32-bit CPU data bus and the `datapath` module interface. It is parameterised primarily for testbench flexibility.

---

## 7. Simulation and Testing

### 7.1 VCD Dump

When compiled with `` `define COCOTB_SIM ``, the module emits a VCD waveform:

```verilog
`ifdef COCOTB_SIM
initial begin
  $dumpfile("fifo_dump.vcd");
  $dumpvars(0, fifo);
end
`endif
```

VCD files are written to `sim_build/` during cocotb simulation runs.

### 7.2 Running the FIFO Tests

```bash
# All FIFO tests with verbose output
docker run --rm -v ${pwd}:/test -w /test -it mbtaylor1982/cocotb-iverilog:latest \
    pytest RTL/cocotb/FIFO/test_fifo.py -v

# Single test function
docker run --rm -v ${pwd}:/test -w /test -it mbtaylor1982/cocotb-iverilog:latest \
    pytest RTL/cocotb/FIFO/test_fifo.py::test_name -v
```

Test results (VCD waveforms + markdown reports) are written to `test_results/FIFO/`.

### 7.3 Key Test Cases to Maintain

When extending or modifying the FIFO, ensure coverage of:

| Scenario | Why it matters |
|----------|---------------|
| Write then read full depth (8 longwords) | Verifies wrap-around of both pointers |
| Fill to `FIFOFULL`, attempt further writes | Ensures FSMs respect `o_FIFOFULL` |
| Drain to `FIFOEMPTY`, attempt further reads | Ensures FSMs respect `o_FIFOEMPTY` |
| SCSI byte-by-byte write with `A1=1` | Verifies mid-longword alignment initialisation |
| `INCFIFO`/`DECFIFO` held across multiple cycles | Verifies edge detection fires exactly once |
| Reset mid-transfer | Verifies all state clears correctly |

---

## 8. Extension Notes

### Adding Depth
Changing `DEPTH` is safe. All counter widths are derived via `$clog2(DEPTH)` and `$clog2(DEPTH+1)`. Ensure `DEPTH` is a power of two to keep pointer wrap-around correct (non-power-of-two depths require explicit modulo logic).

### Increasing Width
`WIDTH` is parameterised but the write-strobe logic is hardcoded for four byte lanes across a 32-bit word. Increasing `WIDTH` beyond 32 would require additional strobe signals and byte-pointer bits.

### Adding an Output Register
The current output (`o_FIFO_OD`) is combinational from `buffer[read_ptr]`. Adding a registered output stage would reduce combinational depth at the cost of one additional cycle of read latency — the CPU_SM and SCSI_SM timing assumptions would need updating.

### Replacing Edge Detection with Handshake
The current edge-detect scheme works well when the driving FSMs are in the same 100 MHz clock domain. If a future design splits CPU_SM into the SCLK domain, replace the two-stage shift-register edge detectors with proper two-flop synchronisers and request/acknowledge handshakes.

---

## 9. Related Files

| File | Relationship |
|------|-------------|
| `RTL/RESDMAC.v` | Instantiates `fifo` as `int_fifo`; drives all control signals |
| `RTL/datapath/datapath.v` | Provides `i_FIFO_ID` (write data) and consumes `o_FIFO_OD` (read data) |
| `RTL/CPU_SM/CPU_SM.v` | Issues `INCFIFO`, `DECFIFO`, `INCNI` (CPU side), `INCNO` (CPU side), `LHWORD`, `LLWORD` |
| `RTL/SCSI_SM/SCSI_SM.v` | Issues `INCBO`, `INCNI` (SCSI side), `INCNO` (SCSI side), `LBYTE_n` |
| `RTL/cocotb/FIFO/test_fifo.py` | cocotb/pytest test suite |
| `Docs/SDMAC.md` | Original SDMAC register map and DMA timing reference |
