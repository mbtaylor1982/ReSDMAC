# Stable branch builds and utility disk

## Workflow behaviour

Every push to `stable-update-release` (the current branch) or `stable-release`
starts the candidate workflow. It runs the complete RTL and Python test suite
and builds 10M02, 10M04 and 10M16 firmware. Builds run independently so a test
failure does not prevent synthesis evidence being collected.

Only when the tests and all three builds pass does `make_adf.yml` assemble
the utility disk. The disk uses the current run's firmware artifacts, never
firmware downloaded from an older release. Stable push builds identify artifacts
with the run ID and attempt; the four-byte hardware version remains `v1.2`.
Manual candidate runs can choose a different version and artifact identity.
Pushes do not create a public release. Existing tag releases remain drafts.

The ADF artifact contains the disk, its SHA-256 checksum, and a checksum list
of the disk contents. The separate device artifacts contain programming files
and reports. 10M02 has no in-system update image on the disk.

## Keep the original direct ADF workflow

The implementation extends the original `make_adf.yml`: release-download
actions, shell staging, and explicit `xdftool` commands. It does not introduce
a new Python packaging or tool-compilation layer. The existing Python CRC helper
is reused to check firmware sidecars against the updater's CRC algorithm.
The older `tools/package_candidate.py` remains unchanged for local use.

Pinned release versions are directly visible in the workflow:

| Tool | Repository | Release | Download |
| --- | --- | --- | --- |
| Firmware updater | [ReSDMAC_Update_Tool](https://github.com/mbtaylor1982/ReSDMAC_Update_Tool) | release_0.3 | ReSDMAC.zip |
| Device test | [amiga_devtest](https://github.com/cdhooper/amiga_devtest) | v2.0 | devtest*.lha |
| Register test | [amiga_sdmac_test](https://github.com/cdhooper/amiga_sdmac_test) | release_1.1 | sdmac |

The SDMAC release currently supplies a standalone binary, not a ZIP. Devtest
supplies an LhA archive. Documentation and licences absent from those assets
are obtained from the same source tags. Tool binaries must have an Amiga HUNK
header; firmware must have the expected CFM0 sizes and matching CRC sidecars.
Every file is extracted from the finished ADF and compared byte-for-byte with
its staged input. Disk overflow, missing files and CRC mismatches fail the job.

The disk contains instructions and provenance; nothing flashes firmware or
runs destructive tests automatically. It is a utility disk, not a complete
Workbench installation. Bootability on the target ROM and tool runtime behaviour
still need an Amiga hardware check.

## Renovate

`renovate.json` scans the three annotated release tags with a custom regex
manager using the GitHub releases datasource. It understands both `release_N.N`
and `vN.N` naming. Updates open grouped PRs against `stable-update-release`;
automerge is disabled. The GitHub Actions manager also updates action references.
This follows Renovate's [custom regex manager documentation](https://docs.renovatebot.com/modules/manager/regex/).

Workflow dependency coverage also includes:

- Checkout, artifact upload/download, release-downloader and action-gh-release.
  Renovate groups their updates and proposes immutable action SHA pins.
- Quartus, cocotb/Icarus, Amiga/ADF tools and KiCad container images.
  Renovate groups container updates and proposes digest pinning for the currently
  unpinned KiCad image. The other images retain their existing digests, with an
  explicit `latest` tracking tag so new digests can be proposed for review.
- The three corresponding image references in `tools/toolchain.json`, through
  a Docker regex manager, in the same PR as the workflow image updates.

Adding `latest` before an existing digest does not change the image executed:
the digest still selects it. No container upgrade was applied in this change.
The package versions recorded inside `toolchain.json` describe the container;
they are not installation requirements. Review these metadata values when a
container update changes its bundled tools rather than updating them independently.
Local reusable workflow paths are repository files, not external dependencies.
GitHub's `ubuntu-latest` runner label continues to follow GitHub's managed image.
Container/action coverage uses Renovate's [GitHub Actions manager](https://docs.renovatebot.com/modules/manager/github-actions/).

Install/enable the Renovate GitHub App for this repository and make the config
available on the repository's default branch. Renovate must also have permission
to read updater releases if that repository is private. This is separate from
the Actions `RESDMAC_UPDATE_REPO` secret, which needs read access to the updater
release assets. Existing Docker Hub secrets remain in use for firmware/tests.
No app installation or repository settings were changed locally.

Utility/workflow PRs run the same ADF workflow with synthetic firmware of the
correct sizes. This checks archive layout, licences, disk capacity and readback
with the proposed tool releases. The fixture disk is never uploaded as firmware.
The normal RTL regression also runs for PRs targeting the stable branches.
Fork PRs cannot access the private updater secret; do not switch to
`pull_request_target` to work around that restriction.

Release tags are version pins, not immutable asset hashes. BuildInfo records the
chosen versions and the artifact includes hashes of the actual packaged files.
Review upstream changes and test on an Amiga before accepting a tool update.

## Verification and outstanding checks

- Local actionlint validation passed.
- Renovate's official configuration validator passed under Node 24. On Windows
  it used its JavaScript regex fallback because native RE2 was unavailable;
  the extraction pattern was also checked to match exactly the three tool pins.
- Existing packaging/CRC unit tests passed (3/3). A deliberately incorrect
  firmware CRC was rejected before disk creation.
- Local ADF assembly/readback passed with real published devtest 2.0 and SDMAC
  1.1 binaries, an updater built from the release_0.3 commit, and synthetic
  firmware. This validates packaging, not firmware operation.
- The private updater release metadata confirms `ReSDMAC.zip` exists.
  Authenticated asset download and the complete hosted workflow still need the
  first GitHub Actions run after these changes are pushed.
- This workflow-only update includes no RTL, timing constraints or experimental
  timing tests. It runs the existing committed regression. Separate local timing
  work remains outside this commit and will be integrated and validated later.
