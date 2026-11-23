# DMA Verification Test Results

> **Latest:** [DMA RTL correction results](DMA_RTL_FIX_RESULTS.md) record
> **354/354 DMA passes and 12/12 existing regression passes**, after correcting
> partial-entry retirement and software-visible flush completion. This file
> retains the original failure evidence.

> This report preserves the original 186-case stress-test baseline. The later
> [AmigaOS/Linux sequence extension and results](DMA_OS_SEQUENCES.md) expands
> coverage to 318 cases: 259 passed and 59 failed, including premature
> FIFO-empty reporting under immediate OS-style polling. All original passing
> tests remain passing; firmware RTL is unchanged.

**Report date:** 21 November 2026

**Branch:** `stable-update-release`

**Firmware RTL baseline:** `654528af6cf2adc2526a234d503b91b3e8777059`

**Status:** Failed functional qualification; partial FIFO flush overrun remains open.

## Summary

The external-bus DMA harness completed **186 scenarios: 165 passed and 21
failed**. All 12 pre-existing regressions also passed. Every new failure was
a SCSI-to-memory transfer that wrote beyond its permitted padded destination
span when flushing a three-byte tail.

The smallest reproduction transfers three bytes from the peripheral but writes
36 bytes to memory, rather than the expected four bytes including padding.
This is a release blocker because memory beyond the destination buffer can be
overwritten even when the requested payload itself is correct.

No firmware RTL changes were retained. The new failing tests remain enabled;
none are skipped or marked as expected failures. These results do not establish
that any reported GitHub issue is fixed or that this defect caused a particular
reported hardware failure.

## Test environment and counting

| Item | Value |
| --- | --- |
| Simulator environment | Pinned cocotb/Icarus container |
| Container | `mbtaylor1982/cocotb-iverilog@sha256:b62699a09a7e76ff80cf69932f222395886d661247f63b6a82285df22804cca6` |
| Test configuration | Python 3.11.2, cocotb 1.8.0, cocotb-test 0.2.4, pytest 7.4.1, as recorded in `tools/toolchain.json` |
| Socket clock | 25 MHz, 40 ns period |
| Full-suite elapsed time | 90.21 seconds in pytest output |
| Firmware changes | None; harness and documentation changes are working-tree additions relative to the baseline |
| Hardware testing | Not performed in this run |

There are two levels of test results; their counts must not be added together:

| Level | Total | Passed | Failed |
| --- | ---: | ---: | ---: |
| Full pytest suite | 18 | 15 | 3 |
| Existing pytest regressions, included above | 12 | 12 | 0 |
| New DMA pytest launchers, included above | 6 | 3 | 3 |
| Cocotb scenarios inside the six DMA launchers | 186 | 165 | 21 |

Each DMA launcher runs 31 scenarios. A launcher fails if any of those scenarios
fails. Thus the three failed launchers represent the 21 individual failures.

## Coverage

The harness drives the SDMAC's external socket pins through resolved Verilog
buses. It does not force internal sequencer controls or deposit stimulus into
internal data signals.

| Area | Exercised behavior |
| --- | --- |
| Transfer directions | SCSI to memory and memory to SCSI |
| Memory termination | STERM, 32-bit DSACK (`00`), 16-bit DSACK (`01`) |
| Transfer lengths | 1, 2, 3, 4, 15, 16, 17, 31, 32, 33 and 65 bytes |
| Memory latency | Zero or three added wait clocks in the main length matrix |
| Acknowledgement phase | Additional assertion offsets of 1, 11 and 31 ns; the baseline offset is 21 ns |
| Arbitration | Delayed grants and early grants while the previous AS, responder acknowledgement or owner remains active |
| Addressing | Longword-aligned transfers, motherboard fast RAM, and a Ramsey-07 word-aligned start |
| Ramsey ACR | Four 8-bit CPU write cycles and four 8-bit readback cycles |
| Peripheral interface | WD byte handshakes, variable inter-byte gaps and exact read/write counts |
| Data checks | Byte payloads, lane selection, resolved-bus contention and allowed destination span |
| Transaction checks | Transfer direction, ownership, address continuity, final modeled ACR and bounded prefetch |

The 31 scenarios per launcher comprise 22 length/wait combinations, four
busy-bus handoffs, three phase cases, one motherboard fast-RAM case and one
word-aligned case. The STERM phase cases remain aligned to the model's legal
clock-edge response rule; they do not constitute an arbitrary STERM phase sweep.

The arbitration model represents the observable Buster SBR/SBG secondary-master
contract. It is not a complete implementation of Buster's internal arbitration,
fairness or Zorro bus translation. Protocol sources and model boundaries are
documented in [DMA_VERIFICATION.md](DMA_VERIFICATION.md).

## Results by direction and termination

| Direction | Termination | Passed | Failed | Result |
| --- | --- | ---: | ---: | --- |
| SCSI to memory | STERM | 24 | 7 | Fail |
| SCSI to memory | 32-bit DSACK | 24 | 7 | Fail |
| SCSI to memory | 16-bit DSACK | 24 | 7 | Fail |
| Memory to SCSI | STERM | 31 | 0 | Pass |
| Memory to SCSI | 32-bit DSACK | 31 | 0 | Pass |
| Memory to SCSI | 16-bit DSACK | 31 | 0 | Pass |
| **Total** | | **165** | **21** | **Fail** |

All busy-bus arbitration cases and the motherboard fast-RAM cases pass.
Memory-to-SCSI passes all 93 scenarios. This establishes the checked functional
behavior in simulation, not timing sign-off or accelerator compatibility.

## Failing scenarios

Each row below fails under all three memory termination modes, producing
21 failures in total. All are in the SCSI-to-memory direction and fail the
destination-span assertion:

```text
DMA wrote outside the payload/allowed final padding byte
```

| Cocotb test name | Start address | Payload bytes | Added wait clocks | Failure condition |
| --- | --- | ---: | ---: | --- |
| `dma_transfer_005` | `0x00101000` | 3 | 0 | Three-byte final partial longword |
| `dma_transfer_006` | `0x00101000` | 3 | 3 | Three-byte final partial longword |
| `dma_transfer_009` | `0x00101000` | 15 | 0 | Three-byte final partial longword |
| `dma_transfer_010` | `0x00101000` | 15 | 3 | Three-byte final partial longword |
| `dma_transfer_015` | `0x00101000` | 31 | 0 | Three-byte final partial longword |
| `dma_transfer_016` | `0x00101000` | 31 | 3 | Three-byte final partial longword |
| `ramsey07_word_alignment` | `0x00101002` | 17 | 1 | Word-aligned start leaves a three-byte tail |

### Smallest reproduction

| Observation | Expected | Actual |
| --- | --- | --- |
| Peripheral payload | `a4 ed 36` | `a4 ed 36` |
| Peripheral reads | 3 | 3 |
| Memory writes with STERM | One 32-bit write | Nine 32-bit writes |
| Total destination bytes written | 4, including one padding byte | 36 |
| Destination span | `0x00101000` through `0x00101003` | `0x00101000` through `0x00101023` |

The first three destination bytes are correct. The test fails because an
additional 32 bytes are written outside the allowed span. Comparing only the
requested payload would miss this defect.

### Diagnosis and experimental evidence

The waveform shows FIFO occupancy changing from zero to eight when the final
partial entry is decremented. That is consistent with the empty-counter
decrement behavior in `RTL/FIFO/fifo_full_empty_ctr.v` and the extra traversal
of this implementation's eight-longword, 32-byte FIFO.

An isolated source-copy experiment gated the CPU sequencer's FIFO decrement
with `!FIFOEMPTY`. The selected failing 3-byte, 15-byte and word-aligned 17-byte
STERM cases then passed. This supports the empty decrement as the cause, but
the experiment is not a production-ready fix. FIFO occupancy, read-pointer
advancement, flush state and simultaneous peripheral activity must be reviewed
together. The working firmware sources were not modified.

## Ramsey ACR model correction

Ramsey's ACR is a 32-bit register accessed through an **8-bit physical data
port on D[31:24]**. A CPU longword access therefore consists of four byte-port
cycles at `0x00DD000C` through `0x00DD000F`, acknowledged with DSACK1:0=`10`.
The last cycle places the low address byte on D[31:24], making A1 visible on
D25. The RTL expression `A1 <= MID[25]` is correct.

The final results in this report use that corrected model. They exclude
earlier invalid single-cycle, 32-bit ACR stimulus. The new wrapper also selects
the hardware acknowledgement branch instead of the legacy simulation shortcut
that acknowledges ACR inside SDMAC.

Motherboard fast-RAM transfers pass without an RTL change. Word-aligned
memory-to-SCSI transfers pass too. The remaining word-aligned SCSI-to-memory
failure is a flush overrun, not evidence of an ACR snooping defect.

## Checks that the harness detects faults

These experiments used isolated source copies and were separate from the
186-scenario baseline run.

| Deliberately introduced fault | Detection |
| --- | --- |
| Restore the old data-output-enable expression | Unresolved memory-read data caused by bus contention |
| Select an incorrect FIFO byte for SCSI output | First-byte mismatch: `ed` instead of `a4` |
| Ignore the previous-cycle-clear condition | Unresolved AS during an early grant |
| Change ACR alignment snooping from D25 to D1 | Word-aligned SCSI payload mismatch |

These checks demonstrate that the relevant assertions can detect those faults;
they do not prove complete coverage of all DMA failure modes.

## Reproduction commands

Run from the repository root. These examples use PowerShell.

### Full existing and DMA suite

```powershell
docker run --rm --pull=never -v "${PWD}:/work" -w /work `
  mbtaylor1982/cocotb-iverilog@sha256:b62699a09a7e76ff80cf69932f222395886d661247f63b6a82285df22804cca6 `
  timeout 180s pytest RTL/cocotb tools -q --tb=short --junitxml=sim_build/dma-review-results.xml
```

### Smallest failing STERM scenario

```powershell
docker run --rm --pull=never -e TESTCASE=dma_transfer_005 -v "${PWD}:/work" -w /work `
  mbtaylor1982/cocotb-iverilog@sha256:b62699a09a7e76ff80cf69932f222395886d661247f63b6a82285df22804cca6 `
  pytest RTL/cocotb/DMA -q -k 'to_memory and sterm'
```

The pinned image must already be available locally when using `--pull=never`.
Both commands are expected to return a nonzero exit status against this
unchanged firmware baseline because the flush regression remains unresolved.

## Evidence files

| Evidence | Location |
| --- | --- |
| Full-suite JUnit summary | `sim_build/dma-review-results.xml` |
| Full-suite captured output | `sim_build/dma-final.log` |
| Per-configuration cocotb JUnit | `sim_build/dma_<direction>_<termination>/*_results.xml` |
| Waveforms | `sim_build/dma_<direction>_<termination>/dma.vcd` |
| Per-scenario transaction records | `sim_build/dma_<direction>_<termination>/*.json` |
| Fault-injection experiment output | `sim_build/dma-probes.log` |
| Harness source | `RTL/cocotb/DMA/` |
| Protocol research and model design | [DMA_VERIFICATION.md](DMA_VERIFICATION.md) |

Generated evidence is ignored by Git and can be overwritten by later runs.
Preserve a copy with the exact source revision before using it for release
qualification. This report summarizes the saved full-suite run; generating
the report did not rerun the tests.

## Next actions and qualification limits

1. Correct three-byte-tail flush handling, reviewing occupancy and pointer
   changes together rather than only preventing counter wrap.
2. Retain all failing scenarios and rerun the full matrix after the correction.
   Require exact payloads, permitted write spans and correct transfer counts.
3. Extend coverage for simultaneous FIFO activity, interrupted transfers,
   active-transfer reset and bus-error behavior.
4. Rebuild the three FPGA variants and continue socket timing and hardware
   qualification before calling the firmware stable.

This run does not cover complete Zorro translation, cache coherency, full WD
interrupt/command sequencing, or a complete accelerator implementation. No
new Quartus timing sign-off, hardware flashing, v0.9 upgrade validation or
GitHub issue closure follows from these simulation results alone.
