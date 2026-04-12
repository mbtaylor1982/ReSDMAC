from cocotb_test.simulator import run
import pytest
import os
import cocotb
import logging

hdl_dir = os.path.dirname(__file__) or '.'
print(hdl_dir)

def test_registers(caplog):
    caplog.set_level(logging.INFO)
    run(
        toplevel_lang="verilog",
        verilog_sources=[os.path.join("RTL/Registers/", "registers.v")],
        toplevel="registers",
        module="cocotb_registers",
        python_search=[hdl_dir],
        timescale="1ns/100ps",
        force_compile="True",
        includes=[ "RTL/",
        "RTL/SCSI_SM",
        "RTL/CPU_SM",
        "RTL/datapath",
        "RTL/FIFO",
        "RTL/Registers"]
    )
