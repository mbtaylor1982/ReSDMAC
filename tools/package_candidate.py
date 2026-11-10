#!/usr/bin/env python3
"""Assemble and read back an unpublished firmware update disk.

Requires xdftool from amitools. CRC matches the pinned updater's crc32(0,...),
not zlib/ZIP CRC32. No flash, network, tag, or release operations are performed.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

DEVICES = ("10M02SCU169C8G", "10M04SCU169C8G", "10M16SCU169C8G")
CFM0_BYTES = {"10M04SCU169C8G": 143360, "10M16SCU169C8G": 270336}


def updater_crc(data):
    crc = 0
    for value in data:
        crc ^= value << 24
        for _ in range(8):
            crc = ((crc << 1) ^ (0x04C11DB7 if crc & 0x80000000 else 0)) & 0xFFFFFFFF
    return crc


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def validate_identity(version, candidate):
    if not re.fullmatch(r"v[0-9]\.[0-9]", version):
        raise ValueError("Hardware version must be exactly vN.N")
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_.-]{0,39}", candidate):
        raise ValueError("Candidate ID must be a short filename-safe identifier")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--firmware-root", required=True, type=Path)
    parser.add_argument("--updater", required=True, type=Path)
    parser.add_argument("--updater-license", required=True, type=Path)
    parser.add_argument("--updater-ref", required=True)
    parser.add_argument("--hardware-version", required=True)
    parser.add_argument("--candidate-id", required=True)
    parser.add_argument("--source-commit", required=True)
    parser.add_argument("--working-tree-dirty", action="store_true")
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    validate_identity(args.hardware_version, args.candidate_id)
    if not re.fullmatch(r"[0-9a-f]{40}", args.updater_ref):
        raise ValueError("Updater ref must be an immutable full commit SHA")
    if not re.fullmatch(r"[0-9a-f]{40}", args.source_commit):
        raise ValueError("Source commit must be a full commit SHA")
    root = Path(__file__).resolve().parents[1]
    output = args.output.resolve()
    # Refuse reuse rather than accidentally publishing stale device payloads.
    if output.exists():
        raise ValueError(f"Output already exists: {output}")
    args.updater.read_bytes()
    args.updater_license.read_bytes()
    inputs = {}
    for device in DEVICES:
        directory = args.firmware_root / f"OutputFiles_{device}_{args.candidate_id}.zip"
        inputs[device] = directory
        if not (directory / "RESDMAC.pof").is_file():
            raise ValueError(f"Missing POF for {device}")
        if device in CFM0_BYTES:
            payload = directory / "resdmac_cfm0_auto.rpd"
            if payload.stat().st_size != CFM0_BYTES[device]:
                raise ValueError(f"Unexpected {device} CFM0 size")

    output.mkdir(parents=True)
    manifest = {
        "candidate": args.candidate_id,
        "hardware_version": args.hardware_version,
        "source_commit": args.source_commit,
        "working_tree_dirty": args.working_tree_dirty,
        "configured_toolchain": json.loads((root / "tools/toolchain.json").read_text()),
        "updater_commit": args.updater_ref,
        "crc": "normal 0x04C11DB7, init=0, refin=false, refout=false, xorout=0",
        "hardware_validation": "NOT PERFORMED",
        "files": {},
        "build_inputs_sha256": {},
    }
    for folder in ("RTL", "Quartus"):
        for path in sorted((root / folder).rglob("*")):
            if path.suffix in (".v", ".sv", ".vh", ".tcl", ".sdc", ".qip", ".qsys", ".cof") and path.is_file():
                if not any(part in ("cocotb", "sim_build", "db", "incremental_db", "__pycache__") or part.startswith("output_files_") for part in path.parts):
                    manifest["build_inputs_sha256"][str(path.relative_to(root))] = sha256(path)

    with tempfile.TemporaryDirectory(prefix="resdmac-adf-") as temp:
        stage = Path(temp)
        disk_files = {"C/resdmac": args.updater, "Updater.LICENSE": args.updater_license}
        for device, directory in inputs.items():
            pof = output / f"RESDMAC_{device}_{args.candidate_id}.pof"
            shutil.copyfile(directory / "RESDMAC.pof", pof)
            for suffix in (".sta.summary", ".sta.rpt", ".fit.summary", ".map.summary"):
                report = directory / ("RESDMAC" + suffix)
                if report.is_file():
                    shutil.copyfile(report, output / (device + suffix))
            if device in CFM0_BYTES:
                short = device[:5]
                rpd = output / f"{short}_update.rpd"
                shutil.copyfile(directory / "resdmac_cfm0_auto.rpd", rpd)
                crc_file = output / (rpd.name + ".crc32")
                crc_file.write_text(f"{updater_crc(rpd.read_bytes()):08x}\n")
                disk_files[rpd.name] = rpd
                disk_files[crc_file.name] = crc_file
        for name in ("S/Startup-Sequence", "Devs/system-configuration", "Disk.info"):
            disk_files[name] = root / "disk" / Path(name).name
        readme = stage / "ReadMe"
        readme.write_text(
            f"ReSDMAC {args.candidate_id} / hardware {args.hardware_version}\n\n"
            "UNVALIDATED CANDIDATE: hardware and v0.9 upgrade testing remain open.\n"
            "10M04 and 10M16 only for in-system updates; 10M02 needs external programming.\n"
            "Check your FPGA variant before selecting an image.\n"
            "Keep CRC sidecars with their RPD files. Preserve an external recovery image.\n"
            "Write: resdmac -w 10M04_update.rpd (or 10M16_update.rpd)\n"
            "Verify: resdmac -c 10M04_update.rpd (or 10M16_update.rpd)\n"
            "Do not reboot until readback comparison succeeds.\n"
            f"Updater source commit: {args.updater_ref}\n")
        disk_files["ReadMe"] = readme
        adf = output / f"ReSDMAC_Utils_{args.candidate_id}.adf"

        def xdf(*command):
            subprocess.run(["xdftool", str(adf), *map(str, command)], check=True,
                           stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        # Amiga volume names are limited to 30 characters.
        xdf("format", "ReSDMAC_" + args.candidate_id[:22])
        for directory in ("C", "S", "Devs"):
            xdf("makedir", directory)
        for name, path in disk_files.items():
            xdf("write", path.resolve(), name)
        xdf("boot", "install")
        for index, (name, path) in enumerate(disk_files.items()):
            extracted = stage / f"readback-{index}"
            xdf("read", name, extracted)
            if extracted.read_bytes() != path.read_bytes():
                raise ValueError(f"ADF readback mismatch: {name}")
        manifest["adf_verified_files"] = {name: sha256(path) for name, path in disk_files.items()}

    for path in sorted(output.iterdir()):
        manifest["files"][path.name] = {"bytes": path.stat().st_size, "sha256": sha256(path)}
    (output / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    (output / "SHA256SUMS").write_text("".join(
        f"{sha256(path)}  {path.name}\n" for path in sorted(output.iterdir()) if path.is_file()))
    print(f"Candidate assembled and all ADF files read back: {output}")


if __name__ == "__main__":
    main()
