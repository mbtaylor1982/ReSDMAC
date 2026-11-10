#!/usr/bin/env python3
"""Write the CRC sidecar expected by the Amiga updater."""
import argparse
from pathlib import Path
from package_candidate import updater_crc

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("payload", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    args.output.write_text(f"{updater_crc(args.payload.read_bytes()):08x}\n")
