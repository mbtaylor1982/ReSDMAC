# SCSI_SM Module — `RTL/SCSI_SM/SCSI_SM.v`

**ReSDMAC © 2024-2026 Michael Taylor — CC BY-SA 4.0**

---

## 1. Brief Description

`SCSI_SM` is the state machine that controls all communication between the ReSDMAC and the WD33C93A/B SCSI IC. It handles two classes of transfers:

- **CPU direct register access** — the 68030 reads or writes a WD33C93 internal register directly via the peripheral data port. SCSI_SM drives the chip-select (`o_SCSI_CS`), read (`o_RE`), and write (`o_WE`) strobes with timing that satisfies the WD33C93 AC specifications, then signals cycle termination back to the CPU via `o_LS2CPU`.

- **DMA burst transfers** — background byte-by-byte transfers between the FIFO and the WD33C93, triggered by the SCSI `_DREQ` signal. The direction is determined by the CNTR register's DMADIR bit:
  - **SCSI → FIFO (S2F):** SCSI IC drives the bus; SCSI_SM pulses `o_RE` and `o_DACK` to latch each byte into the FIFO via `o_LBYTE_n`.
  - **FIFO → SCSI (F2S):** FIFO provides data; SCSI_SM pulses `o_WE` and `o_DACK` to clock each byte into the WD33C93.

All logic is synchronous to `i_CLK100` (100 MHz). The two asynchronous inputs — `i_DREQ_n_async` and `i_CPUREQ_async` — pass through two-flip-flop synchronisers before use. All outputs are registered to prevent glitches on the SCSI bus.

Timing constants are derived from the WD33C93**A** datasheet (the more conservative variant); these values satisfy both WD33C93A and WD33C93B specifications.

---

## 2. Ports

### Inputs

| Port | Width | Description |
|------|-------|-------------|
| `i_CLK100` | 1 | 100 MHz main clock. All registers clock on the rising edge |
| `i_RESET_n` | 1 | Active-low asynchronous reset. Returns the FSM to `IDLE` and clears all outputs |
| `i_BOEQ3` | 1 | FIFO byte-pointer-equals-3 flag. Asserted when the FIFO byte pointer is at the last byte of a longword. Used to trigger pointer-advance and FIFO occupancy update at end of each 4-byte DMA group |
| `i_CPUREQ_async` | 1 | Asynchronous CPU request for a SCSI register access. Asserted by CPU_SM when the CPU addresses the WD33C93 register space. Synchronised to `i_CLK100` internally |
| `i_DREQ_n_async` | 1 | Active-low asynchronous SCSI data request from the WD33C93. Synchronised to `i_CLK100` internally. When asserted (low) the WD33C93 is ready for a DMA byte transfer |
| `i_DMADIR` | 1 | DMA direction, sourced from the CNTR register via `registers.v` (`o_DMADIR = ~cntr_dmadir`). `0` = CPU→SCSI (FIFO→SCSI DMA); `1` = SCSI→CPU (SCSI→FIFO DMA). Note: this is the bitwise complement of the CNTR register's DMADIR bit |
| `i_FIFOEMPTY` | 1 | FIFO empty flag from the `fifo` module. Prevents F2S DMA when no data is available |
| `i_FIFOFULL` | 1 | FIFO full flag from the `fifo` module. Prevents S2F DMA when no space is available |
| `i_INC_FIFO_ACK` | 1 | Acknowledgment from CPU_SM that it has processed a FIFO increment request. Clears `o_FIFO_INC_PEND` |
| `i_DEC_FIFO_ACK` | 1 | Acknowledgment from CPU_SM that it has processed a FIFO decrement request. Clears `o_FIFO_DEC_PEND` |
| `i_AS_n` | 1 | CPU address strobe, active-low. Rising edge (AS deasserted) is used to detect end of a CPU bus cycle and deassert `dsack` |
| `i_RW` | 1 | CPU read/write signal. `1` = CPU read (triggers S2C); `0` = CPU write (triggers C2S) |

### Outputs

| Port | Width | Description |
|------|-------|-------------|
| `o_SCSI_CS` | 1 | Chip select to WD33C93. Asserted only during CPU register accesses (C2S/S2C). **Not** asserted during DMA transfers — the WD33C93 does not require CS during DMA |
| `o_WE` | 1 | Write enable to WD33C93. Asserted during C2S (CPU→SCSI register write) and F2S (FIFO→SCSI DMA write) |
| `o_RE` | 1 | Read enable to WD33C93. Asserted during S2C (SCSI→CPU register read) and S2F (SCSI→FIFO DMA read) |
| `o_DACK` | 1 | DMA acknowledge to WD33C93. Asserted during F2S and S2F strobe states. Also participates in `o_LBYTE_n` generation |
| `o_SCSI_CS`, `o_WE`, `o_RE` map to `_CSS`, `_IOW`, `_IOR` at the top level via inversion in `RESDMAC.v` | | |
| `o_CPU2S` | 1 | Indicates an active CPU→SCSI register write cycle. Used by `datapath` to route CPU data to the SCSI port |
| `o_S2CPU` | 1 | Indicates an active SCSI→CPU register read cycle. Used by `datapath` to route SCSI data to the CPU data bus |
| `o_F2S` | 1 | Indicates an active FIFO→SCSI DMA transfer. Used by `datapath` to select the correct byte from the FIFO for the SCSI port |
| `o_S2F` | 1 | Indicates an active SCSI→FIFO DMA transfer. Used by `datapath` to route the incoming SCSI byte to the FIFO write data path |
| `o_LBYTE_n` | 1 | Active-low load-byte strobe to the FIFO. Asserted when `o_DACK & o_RE` are both asserted simultaneously (S2F_STROBE only). Causes the FIFO to write the current SCSI byte into the byte lane selected by its byte pointer |
| `o_INCBO` | 1 | Increment FIFO byte pointer. Asserted in the `*_UPDATE` states after each byte DMA transfer |
| `o_INCNI` | 1 | Increment FIFO next-in (write) pointer. Asserted in S2F_UPDATE when `i_BOEQ3` is true — signals a complete longword has been written into the FIFO |
| `o_INCNO` | 1 | Increment FIFO next-out (read) pointer. Asserted in F2S_UPDATE when `i_BOEQ3` is true — signals a complete longword has been consumed from the FIFO |
| `o_FIFO_INC_PEND` | 1 | FIFO increment request pending. Set at end of each S2F 4-byte group; cleared when CPU_SM acknowledges via `i_INC_FIFO_ACK`. Guards against SCSI_SM outrunning CPU_SM occupancy tracking |
| `o_FIFO_DEC_PEND` | 1 | FIFO decrement request pending. Set at end of each F2S 4-byte group; cleared when CPU_SM acknowledges via `i_DEC_FIFO_ACK` |
| `o_LS2CPU` | 1 | Latch SCSI-to-CPU data / CPU cycle termination. Driven by `~dsack`. Asserted once the SCSI register access is complete, signalling `datapath` to present SCSI data on the CPU bus and telling `RESDMAC.v` to drive DSACK |

---

## 3. Detailed Operation

### 3.1 Input Synchronisation

`i_DREQ_n_async` and `i_CPUREQ_async` originate in asynchronous clock domains (WD33C93 SCSI clock ~14.3 MHz, and the 68030 bus respectively). Both pass through `sync_2ff` two-flip-flop synchronisers before the state machine sees them:

```verilog
sync_2ff u_sync_dreq   (.clk(i_CLK100), .async_in(i_DREQ_n_async), .sync_out(dreq_n));
sync_2ff u_sync_cpureq (.clk(i_CLK100), .async_in(i_CPUREQ_async), .sync_out(cpu_req));
```

This introduces a worst-case two-cycle (20 ns) latency from assertion to recognition — negligible against the WD33C93's timing requirements (minimum RE/WE pulses ≥ 60–200 ns).

### 3.2 State Encoding

States use a **one-hot** encoding with one bit per state. Quartus infers one-hot encoding natively for MAX 10 devices, resulting in minimal LUT depth for next-state logic and an efficient register-per-state structure.

```
15 states → 15-bit state register
IDLE, C2S_SETUP/XFER/WAIT/HOLD, S2C_SETUP/XFER/WAIT/HOLD,
F2S_STROBE/HOLD/UPDATE, S2F_STROBE/LATCH/UPDATE
```

### 3.3 Transfer Start Conditions

Four mutually exclusive start signals are evaluated in `IDLE`:

```verilog
wire start_s2f = (~cpu_req & ~dreq_n & ~i_FIFOFULL  &  i_DMADIR & ~o_FIFO_INC_PEND);
wire start_f2s = (~cpu_req & ~dreq_n & ~i_FIFOEMPTY & ~i_DMADIR & ~o_FIFO_DEC_PEND);
wire start_s2c = ( cpu_req &  dreq_n &  i_RW );
wire start_c2s = ( cpu_req &  dreq_n & ~i_RW );
```

**Priority** (via `casez`):

| Priority | Condition | Transition |
|----------|-----------|------------|
| 1 (highest) | `start_s2f` | → `S2F_STROBE` |
| 2 | `start_f2s` | → `F2S_STROBE` |
| 3 | `start_s2c` (CPU read, `?` mask) | → `S2C_SETUP` |
| 4 | `start_c2s` (CPU write, `?` mask) | → `C2S_SETUP` |

CPU register access (`s2c`, `c2s`) uses don't-care (`?`) bits so it pre-empts an in-progress DMA check — CPU accesses are never starved by DMA activity.

DMA transfers guard against races: `start_s2f` blocks while `o_FIFO_INC_PEND` is set (waiting for CPU_SM to acknowledge the previous increment); `start_f2s` similarly guards on `o_FIFO_DEC_PEND`.

### 3.4 Wait-State Counter

A single 8-bit `wait_state_counter` times every state's minimum dwell:

```verilog
if (next_state != state_reg)
    wait_state_counter <= 8'd0;   // reset on state change
else
    wait_state_counter <= wait_state_counter + 1;
```

Each state transition guard reads as `wait_state_counter >= N_CYCLES`, so the state is held for exactly `N_CYCLES + 1` clock cycles (N+1 because the counter starts at 0 on entry and the comparison fires when count equals N).

### 3.5 CPU→SCSI Register Write (C2S)

Triggered when `cpu_req=1`, `dreq_n=1`, `RW=0`.

```
C2S_SETUP (5 cycles = 50 ns)  — CS, WE, CPU2S asserted; address/data setup time
     │
C2S_XFER  (7 cycles = 70 ns)  — CS, WE, CPU2S asserted; WE strobe body
     │                            Total WE pulse = 50+70 = 120 ns (meets tWE ≥ 120 ns)
C2S_WAIT  (poll dsack_n, min 4 cycles = 40 ns)
     │                          — waits until dsack_n goes high (CPU cycle ack'd)
C2S_HOLD  (10 cycles = 100 ns) — all signals deasserted; CS/WE recovery
     │
    IDLE
```

`datapath` routes `i_CPU_DATA` to the SCSI peripheral port while `o_CPU2S` is asserted.

### 3.6 SCSI→CPU Register Read (S2C)

Triggered when `cpu_req=1`, `dreq_n=1`, `RW=1`.

```
S2C_SETUP (18 cycles = 180 ns) — CS, RE asserted; wait for data valid (tRLDV = 180 ns)
     │
S2C_XFER  (2 cycles = 20 ns)  — CS, RE, S2CPU asserted; datapath latches SCSI data
     │
S2C_WAIT  (poll dsack_n, min 4 cycles = 40 ns)
     │                          — dsack asserted here (comb_set_dsack), o_LS2CPU goes low
C2S_HOLD  (10 cycles = 100 ns) — recovery; RE/CS deasserted
     │
    IDLE
```

`o_S2CPU` asserted in `S2C_XFER` tells `datapath_scsi` to copy the SCSI bus byte into its output latch for the CPU. `o_LS2CPU` (= `~dsack`) going low terminates the CPU bus cycle and drives `_DSACK` in `RESDMAC.v`.

### 3.7 FIFO→SCSI DMA (F2S)

Triggered when `cpu_req=0`, `dreq_n=0` (DREQ active), `i_DMADIR=0`, `~i_FIFOEMPTY`, `~o_FIFO_DEC_PEND`.

One byte is transferred per pass through F2S. The FIFO byte pointer selects which of the four bytes in the current FIFO longword is presented.

```
F2S_STROBE (6 cycles = 60 ns)  — WE, F2S, DACK asserted; WE pulse (tWR ≥ 50 ns ✓)
     │                            CS is NOT asserted (WD33C93 doesn't require CS in DMA)
F2S_HOLD   (4 cycles = 40 ns)  — F2S held; WE/DACK deasserted; data hold
     │
F2S_UPDATE (4 cycles = 40 ns)  — F2S, INCBO asserted; byte pointer advances
     │                            if i_BOEQ3: INCNO + FIFO_DEC_PEND set
    IDLE
```

After four passes through F2S (`i_BOEQ3` fires on the fourth), the FIFO read pointer advances (`o_INCNO`) and a decrement request is signalled (`o_FIFO_DEC_PEND`). SCSI_SM holds off new F2S transfers until CPU_SM acknowledges via `i_DEC_FIFO_ACK`.

### 3.8 SCSI→FIFO DMA (S2F)

Triggered when `cpu_req=0`, `dreq_n=0` (DREQ active), `i_DMADIR=1`, `~i_FIFOFULL`, `~o_FIFO_INC_PEND`.

One byte is received per pass through S2F.

```
S2F_STROBE (8 cycles = 80 ns)  — RE, S2F, DACK asserted; RE pulse (tRD ≥ 80 ns ✓)
     │                            o_LBYTE_n = ~(DACK & RE) → asserted here → FIFO writes byte
S2F_LATCH  (4 cycles = 40 ns)  — S2F held; RE/DACK deasserted; data hold
     │
S2F_UPDATE (4 cycles = 40 ns)  — S2F, INCBO asserted; byte pointer advances
     │                            if i_BOEQ3: INCNI + FIFO_INC_PEND set
    IDLE
```

`o_LBYTE_n` is generated by the registered output stage as `~(comb_dack & comb_re)` — it is low only during `S2F_STROBE`. This one-cycle-delayed assertion (registered output) ensures the SCSI data bus has settled before the FIFO is strobed.

After four passes (`i_BOEQ3`), the FIFO write pointer advances (`o_INCNI`) and an increment request is signalled (`o_FIFO_INC_PEND`). SCSI_SM holds off new S2F transfers until CPU_SM acknowledges via `i_INC_FIFO_ACK`.

### 3.9 DSACK / LS2CPU Generation

```verilog
// In output register always block:
if (i_AS_n)          dsack <= 1'b1;  // CPU cycle ended → deassert dsack
else if (comb_set_dsack) dsack <= 1'b0;  // C2S_WAIT or S2C_WAIT → assert dsack

assign dsack_n  = ~dsack;
assign o_LS2CPU = dsack_n;
```

`o_LS2CPU` goes low when the SCSI register access is complete (entry into WAIT state). `RESDMAC.v` uses `~(REG_DSK_ & LS2CPU)` to assert the `_DSACK` bus signals, terminating the CPU bus cycle. `dsack` self-clears when `i_AS_n` rises at the end of each CPU cycle, resetting for the next access.

`o_LS2CPU` additionally gates the `datapath_scsi` RX latch enable — it prevents stale SCSI data from propagating to the CPU bus outside a valid S2C cycle.

### 3.10 FIFO Occupancy Handshake

The FIFO module tracks occupancy via a separate `full_empty_count` counter (not coupled to pointer updates). SCSI_SM notifies CPU_SM of occupancy changes through a request/acknowledge handshake:

```
S2F completes 4 bytes:  o_FIFO_INC_PEND ← 1
    CPU_SM processes:   i_INC_FIFO_ACK  → 1 for one cycle
    SCSI_SM clears:     o_FIFO_INC_PEND ← 0
    Next S2F allowed.

F2S completes 4 bytes:  o_FIFO_DEC_PEND ← 1
    CPU_SM processes:   i_DEC_FIFO_ACK  → 1 for one cycle
    SCSI_SM clears:     o_FIFO_DEC_PEND ← 0
    Next F2S allowed.
```

This prevents SCSI_SM from issuing a second occupancy change before the first has been applied to `full_empty_count`, which would cause occupancy tracking to drift.

---

## 4. State Machine Diagram

```
                              ┌─────────────────────────────┐
                              │             IDLE            │
                              │  (evaluate start conditions) │
                              └──┬────┬────┬────────────────┘
               start_s2f (DMA)  │    │    │   start_f2s (DMA)
        DREQ=1, DMADIR=1        │    │    │   DREQ=1, DMADIR=0
        FIFO not full           │    │    │   FIFO not empty
              ┌─────────────────┘    │    └─────────────────┐
              │       start_s2c      │      start_c2s       │
              │       cpu_req=1      │      cpu_req=1        │
              │       dreq_n=1       │      dreq_n=1         │
              │       RW=1           │      RW=0             │
              │     ┌────────────────┘  ┌───────────────┐   │
              │     │                   │               │   │
              ▼     ▼                   ▼               ▼   ▼
         S2F_STROBE  S2C_SETUP      C2S_SETUP      F2S_STROBE
         (80ns RE)   (180ns RE)     (50ns WE)      (60ns WE)
              │           │              │               │
         S2F_LATCH   S2C_XFER       C2S_XFER       F2S_HOLD
         (40ns hold) (20ns +S2CPU)  (70ns WE)      (40ns hold)
              │           │              │               │
         S2F_UPDATE  S2C_WAIT       C2S_WAIT       F2S_UPDATE
         +INCBO      (poll dsack)   (poll dsack)   +INCBO
         if BOEQ3:        │              │         if BOEQ3:
           INCNI+INC_PEND │              │           INCNO+DEC_PEND
              │      S2C_HOLD       C2S_HOLD            │
              │      (100ns)        (100ns)             │
              └──────────┴──────────────┴───────────────┘
                                   │
                                  IDLE
```

---

## 5. Timing Reference

All timings assume `i_CLK100` = 100 MHz (10 ns/cycle). Values are conservative for WD33C93**A**; WD33C93B is faster and satisfied by the same constants.

| Constant | Value | Cycles | Time | Specification |
|----------|-------|--------|------|---------------|
| `C2S_SETUP_CYCLES` | 4 | 5 | 50 ns | Address/data setup before WE |
| `C2S_XFER_CYCLES` | 6 | 7 | 70 ns | WE body (total WE = 120 ns, tWE ≥ 120 ns) |
| `S2C_SETUP_CYCLES` | 17 | 18 | 180 ns | RE low before data valid (tRLDV = 180 ns) |
| `S2C_XFER_CYCLES` | 1 | 2 | 20 ns | Data valid sample window |
| `DSACK_MIN_WAIT` | 3 | 4 | 40 ns | Minimum before polling `dsack_n` |
| `CPU_HOLD_CYCLES` | 9 | 10 | 100 ns | CS/WE/RE recovery (tWHWL / tRHRL ≥ 100 ns) |
| `F2S_STROBE_CYCLES` | 5 | 6 | 60 ns | WE DMA pulse (tWR ≥ 50 ns) |
| `S2F_STROBE_CYCLES` | 7 | 8 | 80 ns | RE DMA pulse (tRD ≥ 80 ns) |
| `DMA_HOLD_CYCLES` | 3 | 4 | 40 ns | Data hold after WE/RE deassert |
| `DMA_UPDATE_CYCLES` | 3 | 4 | 40 ns | INCBO/INCNO/INCNI pulse width |

### WD33C93A vs WD33C93B differences

| Parameter | WD33C93A | WD33C93B | Constants used |
|-----------|----------|----------|----------------|
| tRLDV (RE low to data valid) | 180 ns | 162 ns | 180 ns (A) |
| tRHCH / tWHCH (hold after deassert) | 0 ns | -5 ns | 0 ns (A) |

The A-spec constants satisfy both devices. No code changes are needed to support B.

---

## 6. Integration with ReSDMAC

### 6.1 Signal Connections in `RESDMAC.v`

| SCSI_SM port | RESDMAC.v signal | Source/Destination |
|---|---|---|
| `i_CLK100` | `CLK100` | PLL output |
| `i_RESET_n` | `S_RESET` | Synchronised global reset |
| `i_BOEQ3` | `BOEQ3` | `fifo.o_BOEQ3` |
| `i_CPUREQ_async` | `WDREGREQ` | `registers.o_WDREGREQ` (decoded from CPU address) |
| `i_DREQ_n_async` | `DREQ_` | `(~DMAENA \| _DREQ)` — gated by DMA enable |
| `i_DMADIR` | `DMADIR` | `registers.o_DMADIR` |
| `i_FIFOEMPTY` | `FIFOEMPTY` | `fifo.o_FIFOEMPTY` |
| `i_FIFOFULL` | `FIFOFULL` | `fifo.o_FIFOFULL` |
| `i_INC_FIFO_ACK` | `INCFIFO` | `CPU_SM.INCFIFO` |
| `i_DEC_FIFO_ACK` | `DECFIFO` | `CPU_SM.DECFIFO` |
| `i_AS_n` | `AS_I_` | CPU address strobe (input) |
| `i_RW` | `R_W` | CPU R/W signal |
| `o_RE` | `RE` | → `_IOR = ~(PRESET \| RE)` |
| `o_WE` | `WE` | → `_IOW = ~(PRESET \| WE)` |
| `o_SCSI_CS` | `SCSI_CS` | → `_CSS = ~SCSI_CS` |
| `o_DACK` | `DACK_o` | → `_DACK = ~DACK_o` |
| `o_LBYTE_n` | `LBYTE_` | → `fifo.i_LBYTE_n` |
| `o_LS2CPU` | `LS2CPU` | → `dsack_int = (REG_DSK_ & LS2CPU)` (inverted logic) |

### 6.2 DREQ Gating

`_DREQ` from the WD33C93 is gated in `RESDMAC.v` before reaching SCSI_SM:

```verilog
assign DREQ_ = (~DMAENA | _DREQ);
```

When DMA is disabled (`DMAENA=0`), `DREQ_` is forced high (inactive), preventing SCSI_SM from ever starting a DMA transfer. SCSI_SM still handles CPU direct-register accesses in this state because `start_s2c`/`start_c2s` check `dreq_n` (the synchronised form of `DREQ_`) being **high**, not DMADIR.

### 6.3 PRESET Override

`_IOR` and `_IOW` in `RESDMAC.v` include a `PRESET` term:

```verilog
assign _IOR = ~(PRESET | RE);
assign _IOW = ~(PRESET | WE);
```

`PRESET` (from the CNTR register) forces both `_IOR` and `_IOW` low simultaneously to reset the WD33C93. This is independent of SCSI_SM state — the state machine continues to run during PRESET assertion.

---

## 7. Timing Diagrams

### 7.1 CPU Register Write (C2S): 68030 writes one byte to WD33C93

```
CLK100       _|‾|_|‾|_|‾|_|‾|_|‾| ... |‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_
state        |    C2S_SETUP (5c)   | C2S_XFER (7c)  |WAIT|   HOLD   |
o_SCSI_CS    __|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|____________________
o_WE         __|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|____________________
o_CPU2S      __|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|____________________
_IOW         ‾‾|_______________________________|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
dsack        ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|__|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
             ← 50ns →←      70ns      →← 40+ →
                                     ↑ dsack assert on C2S_WAIT entry
```

### 7.2 SCSI→FIFO DMA (S2F): WD33C93 sends one byte into FIFO

```
CLK100       _|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_| ... |‾|_|‾|_|‾|_|‾|_|‾|_|‾|_
state        |      S2F_STROBE (8c)              | S2F_LATCH (4c) |UPDATE(4c)|
o_RE         __|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|__________________________
o_DACK       __|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|__________________________
o_LBYTE_n    ‾‾|_______________________________|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
o_S2F        __|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|__________
o_INCBO      ___________________________________________________|‾‾‾‾‾‾‾|__
             ← 80ns RE pulse →←  40ns hold  →← 40ns update →
                       ↑ FIFO latches byte while RE & DACK both asserted
```

---

## 8. Output Pipeline Latency

All outputs are registered (one `posedge i_CLK100` delay after the combinational stage). This means:

- A state change computed in the `next_state` logic takes **one cycle** to appear on the `state_reg`.
- The combinational output stage reacts to `state_reg`, producing `comb_*` signals.
- The registered output stage latches `comb_*` on the **next** rising edge.

Therefore, from the moment a start condition is met in `IDLE`, **two clock cycles** pass before the first output (e.g., `o_WE`) appears on the pins. The timing constants (`C2S_SETUP_CYCLES`, etc.) account for this — they specify the dwell in a given state, not the delay from the start condition.

---

## 9. Simulation and Testing

### 9.1 VCD Dump

```verilog
`ifdef COCOTB_SIM
initial begin
  $dumpfile("scsi_sm_dump.vcd");
  $dumpvars(0, SCSI_SM);
end
`endif
```

### 9.2 Running Tests

```bash
# All tests
docker run --rm -v ${pwd}:/test -w /test -it mbtaylor1982/cocotb-iverilog:latest \
    pytest -o log_cli=true -v

# Targeted SCSI_SM tests (if isolated test file exists)
docker run --rm -v ${pwd}:/test -w /test -it mbtaylor1982/cocotb-iverilog:latest \
    pytest RTL/cocotb/SCSI_SM/ -v
```

### 9.3 Key Test Scenarios

| Scenario | What to verify |
|----------|---------------|
| C2S: single byte write | WE pulse width ≥ 120 ns, CS asserted, dsack fires |
| S2C: single byte read | RE pulse width ≥ 200 ns, S2CPU asserted during XFER, LS2CPU asserted |
| F2S: 4-byte burst | WE pulse per byte, INCBO × 4, INCNO on 4th, FIFO_DEC_PEND set/cleared |
| S2F: 4-byte burst | RE pulse per byte, LBYTE_n per byte, INCNI on 4th, FIFO_INC_PEND set/cleared |
| BOEQ3 boundary | Pointer advances exactly on 4th byte, not before |
| FIFO_*_PEND hold-off | No new DMA starts while PEND is set |
| CPU priority over DMA | S2C/C2S pre-empts S2F/F2S in IDLE |
| DREQ deassertion mid-transfer | Current transfer completes; IDLE re-evaluates |
| PRESET override | `_IOW`/`_IOR` asserted regardless of SM state |
| Reset during transfer | Returns to IDLE with all outputs cleared |

---

## 10. Extension Notes

### Adjusting Timing for Other SCSI ICs
All AC timing values are `localparam` constants at the top of the file, clearly annotated with the specification they satisfy. To support a different SCSI IC, update only these constants — no state machine structure changes are needed.

### Adding a New Transfer Mode
The one-hot state encoding makes adding states straightforward:
1. Add a new `localparam` state bit (extend the `[14:0]` width).
2. Add the start condition to the `IDLE` `casez`.
3. Add state transitions in the next-state `always @(*)`.
4. Add output assignments in the output `always @(*)`.
5. Extend the registered output stage if new output signals are needed.

### Burst Length Beyond 4 Bytes
The 4-byte burst boundary is controlled by `i_BOEQ3` from the FIFO. Changing burst length requires modifying the FIFO's byte pointer width and the `BOEQ3` comparison (`byte_ptr == 3`), not SCSI_SM itself.

### Clock Frequency Changes
If `i_CLK100` changes frequency, recalculate all `localparam` cycle counts as `ceil(time_ns / period_ns) - 1`. The timing table in Section 5 documents the source specification for each constant.

---

## 11. Related Files

| File | Relationship |
|------|-------------|
| `RTL/RESDMAC.v` | Instantiates `SCSI_SM`; drives all connections; maps outputs to `_IOR`/`_IOW`/`_CSS`/`_DACK` pins |
| `RTL/synchroniser.v` | Provides `sync_2ff` — included at top of `SCSI_SM.v` |
| `RTL/FIFO/fifo.v` | Receives `o_LBYTE_n`, `o_INCBO`, `o_INCNI`, `o_INCNO`; provides `i_BOEQ3`, `i_FIFOEMPTY`, `i_FIFOFULL` |
| `RTL/datapath/datapath_scsi.v` | Receives `o_F2S`, `o_S2F`, `o_S2CPU`, `o_CPU2S` to select byte routing |
| `RTL/Registers/registers.v` | Provides `o_WDREGREQ` (→`i_CPUREQ_async`) and `o_DMADIR` |
| `Docs/WD33C93/WD33C93A.txt` | WD33C93A datasheet — primary timing reference |
| `Docs/WD33C93/WD33C93B.txt` | WD33C93B datasheet — timing delta reference |
| `Docs/SDMAC.md` | Original SDMAC register map and DMA protocol reference |
