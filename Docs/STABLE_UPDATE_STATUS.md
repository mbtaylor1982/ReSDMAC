# Stable update candidate: first implementation

10 November 2026. Base: `2c962083320677074d35721277241d3b500c94e1`, before the 100 MHz conversion. Branch: `stable-update-release`. Hardware version `v1.2` is provisional; artifact identity is `stable-update-rc1`. No tag or GitHub release was created.

## Changes

- Fixed socket data output enable: owned memory reads release the data bus, owned memory writes drive it, and slave selection cannot override DMA direction.
- Added a resolved-bus cocotb regression covering DMA reads/writes, turnaround, CPU reads/writes, ACR exclusion and idle. It forces only sequencer intent to isolate the driver contract; it is not a complete DMA test.
- Fixed the existing register test to drive DS for the already-present DS-qualified write logic. Register RTL was unchanged.
- Kept generated timing diagrams under the simulation build instead of rewriting tracked documentation.
- Pinned the tested container images, added version-format validation, and added a manually triggered candidate workflow with no publication job.
- Added an ADF packager with exact updater-compatible CRCs, per-device size checks, full file readback and a source/tool/payload manifest. Long artifact names are separate from the four-byte hardware version.

## Evidence

The unchanged candidate's cached-toolchain baseline was **7 passed, 1 failed**; the register failure was the omitted testbench DS input. The new bus test then failed on the original output-enable expression with resolved X data. After the fix and testbench correction, the complete suite was **12 passed** (nine RTL launchers and three packaging contract tests).

Quartus Prime 22.1std.2 Lite built all three provisional v1.2 devices with zero errors. The unchanged 10M16 baseline also built successfully. Candidate minimum slack across entries in each STA summary was 0.152 ns (10M02), 0.150 ns (10M04) and 0.151 ns (10M16). These numbers describe constrained paths only.

**Timing sign-off remains open:** the inherited constraints report 66 unconstrained input ports and 62 unconstrained output ports for each device. Positive constrained-path slack is not evidence that the socket timing is complete. Preserve the reports and review the missing I/O budgets before a release decision.

The updater was built from commit `580f7991feb3464782793fa323c86378d0a66408` with the pinned Amiga GCC/amitools image. For the built CFM0 files, the Python CRC implementation was cross-checked against that updater's C function: 10M04 `e2fe4444`, 10M16 `37adcbb8`. This CRC is not zlib/ZIP CRC32.

The candidate ADF contains the updater/license, 10M04 and 10M16 RPD/CRC files, boot files and a candidate ReadMe. All files were extracted from the completed disk and compared byte-for-byte. Separate POFs are supplied for all three devices; there is no 10M02 software-update payload.

Configured image digests are recorded in [toolchain.json](../tools/toolchain.json). Candidate SHA256SUMS, manifest and copied timing reports accompany the ADF under `artifacts/stable-update-rc1/` (generated, ignored by Git).

## Reproduction

Run the pinned test image from the repository root:

```sh
docker run --rm -v "$PWD:/work" -w /work \
  mbtaylor1982/cocotb-iverilog@sha256:b62699a09a7e76ff80cf69932f222395886d661247f63b6a82285df22804cca6 \
  timeout 180s pytest RTL/cocotb tools -q --junitxml=sim_build/test-results.xml
```

For builds use isolated source directories per device; the Quartus Tcl regenerates its project and cannot safely share a build directory between parallel device builds. The command is `quartus_sh -t RESDMAC.tcl -device <full-device-name> -version v1.2` from Quartus/. Pin the Quartus image from toolchain.json.

The candidate workflow assembles the whole chain after all tests and device builds succeed. It requires access to the pinned images and the existing `RESDMAC_UPDATE_REPO` secret for the updater checkout. It has not been run on GitHub in this work; local equivalent build/test/package commands were exercised.

For local packaging, place each device's Quartus outputs in `OutputFiles_<device>_<candidate-id>.zip/` (an artifact directory, despite its historical suffix), then use `python3 tools/package_candidate.py --help` inside the pinned amitools image. Supply the exact source commit and updater commit; use `--working-tree-dirty` if packaging uncommitted code. The output directory must not already exist.

## Remaining gates

1. Complete/review the socket timing constraints and compare with the original baseline.
2. Run full data/address scoreboards and capture one-clock incoming DSACK behavior before deciding whether an acknowledgement-handling patch is needed. No speculative pulse-stretching change has been made.
3. Physically test stock 68030, TF4060 and other promised accelerators, including CyberStorm Mk2 separately.
4. Test updates from actual v0.9 on 10M04/10M16: device detection, old flash access, program, compare, reboot and version check. A valid ADF filesystem does not establish that the installed v0.9 flash interface can perform the upgrade reliably.
5. Decide the supported clock/board matrix and release version after the evidence is reviewed. No hardware was flashed and no configuration is newly certified by this candidate build.
