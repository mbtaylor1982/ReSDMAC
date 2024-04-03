#!/usr/bin/env python
"""Examples of using the vcd2json module."""
import os
from pathlib import Path
from vcd2json import WaveExtractor

def find_and_process_vcd_files(folder_path):
    """
    Finds .vcd files in the specified folder and processes them.
    """
    for root, dirs, files in os.walk(folder_path):
        for file_name in files:
            if file_name.lower().endswith(".vcd"):
                file_path = os.path.join(root, file_name)
                process_vcd_file(file_path)

def process_vcd_file(file_path):
    """Check the path name of the signal in the VCD file."""
    root, filename = os.path.split(file_path)
    base = os.path.splitext(filename)[0]
    new_filename = base + '.json'
    extractor = WaveExtractor(file_path, os.path.join(root, new_filename), [])
    extractor.execute()


if __name__ == '__main__':
    print('')
    print('Example 1')
    print('----------------------------------------')
    find_and_process_vcd_files('..\\..\\sim_build\\')
