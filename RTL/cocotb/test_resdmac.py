from cocotb_test.simulator import run
import pytest
import os
import cocotb
import logging

hdl_dir = os.path.dirname(__file__) or '.'
print(hdl_dir)

def test_resdmac(caplog):
    caplog.set_level(logging.INFO)
    run(
        toplevel_lang="verilog",
        verilog_sources=[os.path.join("RTL", "RESDMAC.v")],
        toplevel="RESDMAC",
        module="cocotb_resdmac",
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

""" def test_fsm_cpu(caplog):
    caplog.set_level(logging.INFO)
    run(
        toplevel_lang="verilog",
        verilog_sources=[os.path.join("RTL/CPU_SM", "CPU_SM_INTERNALS1.v")],
        toplevel="CPU_SM_INTERNALS1",
        module="cocotb_fsm_cpu",
        python_search=[hdl_dir],
        timescale="1ns/100ps",
        force_compile="True",
        includes=[ "RTL/",
        "RTL/SCSI_SM",
        "RTL/CPU_SM",
        "RTL/datapath",
        "RTL/FIFO",
        "RTL/Registers"]
    ) """