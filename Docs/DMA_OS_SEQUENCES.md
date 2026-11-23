# A3000 operating-system DMA sequence tests

> The results below preserve the pre-fix RTL baseline. The subsequent
> [RTL correction and validation](DMA_RTL_FIX_RESULTS.md) passes all 318 cases
> plus 36 restart/delayed-grant cases: **354/354 DMA scenarios and 12/12 existing
> regressions**, with successful builds for all three FPGA variants.

These tests extend the external-socket DMA harness without changing firmware RTL.
The original 186 DMA scenarios remain intact. Another 132 scenarios exercise
A3000 AmigaOS and Linux compatibility register sequences:
53 scenarios per direction/termination combination, 318 in total.

## Compatibility profiles

The AmigaOS profile models byte-register access, flushing in both directions,
immediate FIFO-empty polling and stopping DMA. These are behavioral test
scenarios for the A3000 SDMAC interface, not a full operating-system emulation.

Linux sources inspected on 2026-11-21:
[a3000.c](https://github.com/torvalds/linux/blob/master/drivers/scsi/a3000.c),
[a3000.h](https://github.com/torvalds/linux/blob/master/drivers/scsi/a3000.h).
The relevant routines are `dma_setup()` and `dma_stop()`; these links track
upstream master rather than an immutable revision.

## Implemented sequences

Offsets below are relative to `$00DD0000`. ACR remains a logical longword
access implemented as four Ramsey byte-port cycles, with DSACK=10.

| Operation | AmigaOS | Linux |
| --- | --- | --- |
| CNTR setup | Byte at `$0B`, `$0C` read / `$0E` write | Word at `$0A`, same values |
| ACR setup | Longword at `$0C` | Longword at `$0C` |
| Start | Byte zero at `$13` | Word one at `$12` |
| Before cleanup | No extra CNTR write | Word CNTR `$08` read / `$0A` write, disabling interrupts |
| Flush | Byte zero at `$17`, both directions | Word one at `$16`, SCSI-to-memory only |
| Poll | Byte `$1F`, bit 0 | Word `$1E`, bit 0, only after flush |
| Clear interrupt | No CINT write | Word one at `$1A` |
| Stop | Byte zero at `$3F` | Word one at `$3E` |
| Restore control | No extra write | Word `$0C` at `$0A` |

Read/write in this table means SCSI read/write: a read moves data into memory.
The cleanup scenarios begin with DMA active.
Register transactions complete in order, representing the ordering required
by Linux's barriers. There is no artificial 2-us settling delay before the
first status poll. Subsequent unsuccessful polls have a 40-ns instruction gap
to allow arbitration; this is a transaction model, not CPU instruction timing.

The SDMAC socket exposes A[6:2], not CPU A[1:0] or CPU transfer size. Software
access width and full offset are recorded in JSON, with byte/word operands on
the corresponding low data lane. This does not verify a complete 68030
dynamic-sizing implementation for all CPU peripherals.

## Scenarios and checks

Every new scenario runs in both directions with STERM, DSACK32 and DSACK16.

- Each OS: completed DMA lengths 256, 258, 512 and 514, with one memory wait
  state. These exercise FIFO wraparound and complete/partial final entries.
- Each OS: an intended 512-byte request stops requesting bytes after
  1, 2, 3, 255, 257 or 259 byte handshakes, then runs OS cleanup. These represent
  the SDMAC-visible boundary of a phase change or disconnect.
- Linux: completed odd-length DMA requests of 257 and 259 bytes, with three
  memory wait states. The A3000 Linux driver does not trim the odd DMA byte.

The AmigaOS compatibility profile uses completed DMA portions of at least
256 bytes with even lengths. Short completed DMA requests remain hardware
stress cases in the original suite. Interrupted larger requests exercise
partial FIFO handling; programmed-I/O tails are outside this harness.

All original payload, memory-span, address-walk, peripheral-count, ownership
and bounded-prefetch checks are retained. An additional memory snapshot at
the first observed FIFO-empty status checks that the full received payload
was already committed before the software stop sequence. Extra writes remain
failures even when all requested payload bytes are correct.

Per-scenario JSON includes `software_cycles`: profile, full register offset,
width, write value, sampled result and completion time. The existing ACR,
memory transaction and peripheral handshake records are retained.

## Scope and execution

These are SDMAC tests driven by OS compatibility register transactions. They do not
boot either OS, emulate WD command registers/interrupt decoding, execute PIO
tails, or verify SCSI residual accounting, cache maintenance or reconnection.
Phase changes and disconnects have the same modeled SDMAC boundary: DREQ
ceases and software performs cleanup. Each scenario starts from reset.

Run the full regression using the pinned simulator image documented in
`DMA_TEST_RESULTS.md`, with:

```text
pytest RTL/cocotb tools -q --tb=short --junitxml=sim_build/dma-os-results.xml
```

The original 12 pytest tests remain regression gates. Simulator result XML,
JSON and waveforms are generated under `sim_build/dma_*`; these directories
are reused on reruns, so preserve artifacts when comparing runs.

## Results, 21 November 2026

Full regression completed in 357.68 seconds against unchanged firmware RTL
`654528af6cf2adc2526a234d503b91b3e8777059`, using the pinned simulator image
`mbtaylor1982/cocotb-iverilog@sha256:b62699a09a7e76ff80cf69932f222395886d661247f63b6a82285df22804cca6`.

| Direction | Termination | Passed | Failed |
| --- | --- | ---: | ---: |
| SCSI to memory | STERM | 35 | 18 |
| SCSI to memory | DSACK32 | 35 | 18 |
| SCSI to memory | DSACK16 | 30 | 23 |
| Memory to SCSI | STERM | 53 | 0 |
| Memory to SCSI | DSACK32 | 53 | 0 |
| Memory to SCSI | DSACK16 | 53 | 0 |
| **Total** | | **259** | **59** |

All 12 pre-existing pytest regressions passed. The original DMA cases retained
their 165 passes and 21 failures; no previously passing case regressed.
Of the 132 added OS-sequence cases, 94 passed and 38 failed. At launcher level,
pytest reported 15 passes and 3 failures because each direction/termination
matrix is one pytest test containing 53 cocotb cases.

The added failures divide into:

- **32 premature FIFO-empty observations:** the payload was not fully committed
  when software saw FIFO-empty. With either OS sequence, interrupted transfers
  of 1, 2, 3 or 255 bytes fail in STERM/DSACK32. In DSACK16, both profiles fail
  all six interrupted lengths and the completed 258-byte case; Linux's completed
  257/259-byte odd cases also fail this check.
- **6 destination overruns:** both profiles' 259-byte interrupted transfers,
  and Linux's completed 259-byte transfer, overrun in STERM/DSACK32.

For the 1/2/3-byte interrupted cases, the first status read reports empty and
STOP follows without any memory transaction. The DSACK16 completed 258-byte
case records only 256 bytes written. These are observable failures under the
modeled arbitration timing, not proof of the exact behavior on every physical
A3000 or of the cause of a particular GitHub issue.

The immediate-poll results show that fixing only the empty-counter decrement
is insufficient as a verification goal: software must also see FIFO-empty
only when the received payload is safely committed. Neither firmware behavior
has been changed or hidden with an expected-failure marker.

Artifacts: `sim_build/dma-os.log`, `sim_build/dma-os-results.xml`, and the latest
per-matrix cocotb XML: SCSI-to-memory STERM `drk4cmw4_results.xml`, DSACK32
`4yt75iui_results.xml`, DSACK16 `vswi0j5u_results.xml`; memory-to-SCSI STERM
`5k179zr4_results.xml`, DSACK32 `mbxatrm6_results.xml`, DSACK16
`yk32kv3b_results.xml`.
