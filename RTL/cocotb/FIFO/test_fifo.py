"""ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons
Attribution-ShareAlike 4.0 International. To view a copy of this license,
visit https://creativecommons.org/licenses/by-sa/4.0/

FIFO cocotb test runner.
Each cocotb test is run as a separate simulation so that every test
produces its own VCD waveform file.  Results and waveforms are written
to  test_results/FIFO/  relative to the project root.
"""

from cocotb_test.simulator import run
import pytest
import os
import shutil
import logging

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
HDL_DIR = os.path.dirname(__file__) or '.'
PROJECT_ROOT = os.path.abspath(os.path.join(HDL_DIR, "..", "..", ".."))
RESULTS_DIR = os.path.join(PROJECT_ROOT, "test_results", "FIFO")
SIM_BUILD = os.path.join(RESULTS_DIR, "sim_build")

# The Verilog dump wrapper writes to this fixed name in the CWD
VCD_FIXED_NAME = "fifo_dump.vcd"

VERILOG_SOURCES = [
    os.path.join("RTL", "FIFO", "fifo.v"),
]

INCLUDES = [
    "RTL/",
    "RTL/SCSI_SM",
    "RTL/CPU_SM",
    "RTL/datapath",
    "RTL/FIFO",
    "RTL/Registers",
]

# ---------------------------------------------------------------------------
# List of cocotb test-case names (must match function names in cocotb_fifo.py)
# ---------------------------------------------------------------------------
COCOTB_TESTS = [
    "test_reset_a1_high",
    "test_reset_a1_low",
    "test_byte_pointer_walk",
    "test_byte_lane_isolation",
    "test_halfword_writes",
    "test_fill_by_byte_and_read_back",
    "test_fill_by_longword_and_read_back",
    "test_pointer_wrap_around",
    "test_reset_during_operation",
    "test_full_empty_counter_saturation",
]


# ---------------------------------------------------------------------------
# Parametrised test – one simulation per cocotb testcase
# ---------------------------------------------------------------------------
@pytest.mark.parametrize("testcase", COCOTB_TESTS)
def test_fifo(testcase, caplog):
    caplog.set_level(logging.INFO)

    os.makedirs(RESULTS_DIR, exist_ok=True)

    # Remove stale VCD so we can tell if a new one was generated
    vcd_src = os.path.join(SIM_BUILD, VCD_FIXED_NAME)
    if os.path.exists(vcd_src):
        os.remove(vcd_src)

    run(
        toplevel_lang="verilog",
        verilog_sources=VERILOG_SOURCES,
        toplevel="fifo",
        module="cocotb_fifo",
        testcase=testcase,
        python_search=[HDL_DIR],
        timescale="1ns/100ps",
        sim_build=SIM_BUILD,
        includes=INCLUDES,
    )

    # Move the VCD into the results directory, named after the testcase
    vcd_dst = os.path.join(RESULTS_DIR, f"{testcase}.vcd")
    if os.path.exists(vcd_src):
        shutil.move(vcd_src, vcd_dst)
