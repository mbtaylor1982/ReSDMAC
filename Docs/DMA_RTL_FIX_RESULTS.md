# DMA RTL correction and validation

Date: 21 November 2026. Changes are an uncommitted working-tree patch on
`654528af6cf2adc2526a234d503b91b3e8777059`.

**Result: 354/354 DMA scenarios passed; 12/12 pre-existing regressions passed;
all three FPGA variants built with zero errors.** All 59 previously failing
DMA cases now pass. Hardware qualification and socket timing sign-off remain
open.

| Direction | STERM | DSACK32 | DSACK16 |
| --- | ---: | ---: | ---: |
| SCSI to memory | 59/59 | 59/59 | 59/59 |
| Memory to SCSI | 59/59 | 59/59 | 59/59 |

The complete DMA matrix took 470.72 seconds (six pytest launchers). The legacy
smoke test passed in 2.46 seconds; the other eleven regressions passed in
6.63 seconds. The latter two groups were run separately from the DMA matrix.

## Production changes

`RTL/CPU_SM/CPU_SM.v` registers whether a dispatched FIFO entry is a partial
flush tail alongside its other CLK90 registers, with the same asynchronous
`CCRESET_` reset. `RTL/CPU_SM/CPU_SM_INTERNALS.v` computes its next value,
including hold, DMA-disable clear, and entry-dispatch classification. This
classification persists through wait states and
both halves of a DSACK16 longword transfer. Completing a partial entry does
not decrement the count of complete entries, preventing the observed zero
to eight wrap and subsequent destination overrun.

The partial-entry flag also makes the sequencer release the bus after that
tail instead of dispatching the same residual bytes again. Existing pointer
advancement is retained: normal longword/lower-word completion paths advance
the read pointer; the separate upper one/two-byte tail path leaves it unchanged
until STOP resets the FIFO. The flag is cleared on reset or disabled DMA and
reloaded when another entry is selected.

Flush acknowledgement has moved from partial-tail dispatch to the bus-release
state. At that point the final memory response has been accepted and the
registered address/data strobes have been released. The no-data flush path
and memory-to-SCSI prefetch-discard path retain their existing completion logic.

`RTL/Registers/registers.v` qualifies the FIFO-empty input to the interrupt
status register with `!FLUSHFIFO`. Internal sequencers still see raw FIFO
occupancy. Software polling after a flush therefore waits for sequencer
completion, including when the counter was already zero but partial bytes
were still awaiting a bus grant or memory acknowledgement.

The shared FIFO counter, Ramsey D25 ACR snoop, bus acquisition rules, register
addresses and access widths are unchanged. No AmigaOS or Linux changes or
extra software delays are required by these sequences.

## Regression maintenance

The DMA pytest launcher now forces compilation: cocotb-test's cache did not
track indirectly included RTL files. An initial focused run reused an old
binary; its results were discarded and the focused cases rerun after rebuilding.
Generated simulator binaries were cleared before the component regressions.

The legacy smoke test's memory responder previously treated the internal
FLUSH flag as a promise of another AS cycle. Holding FLUSH until completion
exposed that assumption as a hang. Its responder now waits for either AS
assertion or bus release and exits on release. No payload assertion was removed
or relaxed. The external-socket DMA harness already follows bus ownership.

The original 318 scenarios remain. Another 36 scenarios cover:

- Each OS: five STOP/start transfers on one board instance without reset,
  including consecutive and reversed directions, partial tails, FIFO wraparound,
  and alternating longword/word-aligned addresses.
- Each OS and Ramsey revision 04/07: 259-byte interrupted-transfer prefixes,
  a 1.6-us grant delay, a previous bus owner, three memory wait states, and a
  different acknowledgement phase. Revision 07 uses a word-aligned address.

These additions run for both initial directions and all three termination
styles, for **354 DMA scenarios**. Short AmigaOS DMA prefixes represent
interrupted larger requests; normal short requests and odd PIO tails are not
claimed as OS-emulated DMA workloads.

The GitHub test workflow's overall test-command timeout is raised from 180
to 900 seconds to accommodate the expanded matrix. Individual bus and OS-poll
timeouts remain in place; assertions and failure reporting are unchanged.

## Validation artifacts

The corrected three-byte stress reproduction writes four memory bytes instead
of 36. The AmigaOS DSACK16 258-byte reproduction now writes all 258 bytes;
its immediate status polls return not-empty, then empty. The Linux one-byte
interrupted STERM reproduction similarly polls not-empty, then empty, and
writes the required padded two-byte word before STOP.

- `sim_build/dma-fix-targeted.log`: four focused cases per matrix, after rebuild.
- `sim_build/dma-rtl-fix.log` and `dma-rtl-fix-results.xml`: complete DMA matrix.
- `sim_build/dma-fix-legacy.log`: legacy smoke regression.
- `sim_build/dma-fix-components.log` and `dma-fix-components-results.xml`:
  remaining bus, FIFO, register and packaging regressions.
- `sim_build/rtl-fix-build-10M02.log`, `rtl-fix-build-10M04.log`,
  `rtl-fix-build-10M16.log`: Quartus build logs.
- `sim_build/rtl_fix_builds/<device>/Quartus/output_files_<device>/`: isolated
  build outputs and synthesis, fitter and timing reports, built with `v9.9`
  as a development identifier, not a release version.

Simulator and Quartus image digests are pinned in `tools/toolchain.json`.
No firmware has been flashed or published by this work.

Per-matrix cocotb XML files in their corresponding `sim_build/dma_*`
directories: SCSI-to-memory STERM `go28wsm3_results.xml`, DSACK32
`v3xocejp_results.xml`, DSACK16 `1rlgfn8l_results.xml`; memory-to-SCSI STERM
`1qf9c8ob_results.xml`, DSACK32 `xb7bz0h9_results.xml`, DSACK16
`e57f91do_results.xml`. Each contains 59 passing cases and no failures.

## FPGA builds

All three isolated builds completed with zero errors using Quartus Prime
22.1std.2 Lite. Warnings remain in the inherited project/constraints.

| Device | Logic elements | Registers | Minimum reported STA slack |
| --- | ---: | ---: | ---: |
| 10M02SCU169C8G | 871 / 2,304 | 506 | 0.151 ns |
| 10M04SCU169C8G | 1,619 / 4,032 | 909 | 0.150 ns |
| 10M16SCU169C8G | 1,626 / 15,840 | 913 | 0.151 ns |

The previously documented candidate minimum slacks were 0.152, 0.150 and
0.151 ns respectively. These are minima across reported constrained checks,
not socket timing margins. Each new report still lists **66 unconstrained
input ports and 62 unconstrained output ports**. Timing sign-off and testing
with unmodified AmigaOS/Linux on physical hardware remain release gates.

## Register-placement refactor, 21 November 2026

The partial-entry register and asynchronous reset were moved into the existing
CLK90 register block in `CPU_SM.v`. `CPU_SM_INTERNALS.v` retains the combinational
next-value logic, including explicit hold and DMA-disable clear. Its current
value is fed back from the wrapper; no clock stage or external interface was
added. The state machine's own state register was not moved.

After this refactor, **354/354 DMA cases and 12/12 existing regressions passed
again**. The three termination groups ran independently in parallel, each
covering both directions: STERM 189.88 seconds, DSACK32 188.29 seconds and
DSACK16 198.92 seconds. The twelve other regressions took 11.09 seconds.
Logs and launcher JUnit files are `sim_build/dma-style-{sterm,dsack32,dsack16,
components}.log` and the corresponding `*-results.xml` files.

All three FPGA builds again completed with zero errors. Current build outputs
are in `sim_build/rtl_style_builds/<device>/Quartus/output_files_<device>/`,
with logs `sim_build/rtl-style-build-{10M02,10M04,10M16}.log`. The 10M02 fit
uses 875 logic elements (four more than the initial fix); the 10M04 and 10M16
counts remain 1,619 and 1,626. Register counts and minimum reported slacks
are unchanged from the table above. The same 66 input/62 output unconstrained
port counts remain; this refactor does not constitute hardware timing sign-off.
