"""ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/"""

from cocotb_test.simulator import run
import pytest
import os
import cocotb
import logging

hdl_dir = os.path.dirname(__file__) or '.'
print(hdl_dir)

def test_fifo_full_empty_ctr():
    run(
        toplevel_lang="verilog",
        verilog_sources=[os.path.join("RTL/FIFO/", "fifo_full_empty_ctr.v")],
        toplevel="fifo__full_empty_ctr",
        module="cocotb_fifo_full_empty_ctr",
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
    
def test_fifo_3bit_cntr():
    run(
        toplevel_lang="verilog",
        verilog_sources=[os.path.join("RTL/FIFO/", "fifo_3bit_cntr.v")],
        toplevel="fifo_3bit_cntr",
        module="cocotb_fifo_3bit_cntr",
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

def test_FIFO(caplog):
    caplog.set_level(logging.INFO)
    run(
        toplevel_lang="verilog",
        verilog_sources=[os.path.join("RTL/FIFO/", "fifo.v")],
        toplevel="fifo",
        module="cocotb_fifo",
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
