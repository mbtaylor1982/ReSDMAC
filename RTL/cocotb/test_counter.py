from cocotb_test.simulator import run
import pytest
import os
import cocotb

hdl_dir = os.path.dirname(__file__)

def test_ounter():
    run(
        toplevel_lang="verilog",
        verilog_sources=[os.path.join("RTL/FIFO/", "fifo_3bit_cntr.v")],
        toplevel="fifo_3bit_cntr",            # top level HDL
        module="cocotb_fifo_3bit_cntr",        # name of cocotb test module
        python_search=[hdl_dir],
        timescale="1ns/100ps",
        force_compile="True"
    )