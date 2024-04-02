from cocotb_test.simulator import run
import pytest
import os
import cocotb

hdl_dir = os.path.dirname(__file__)

def test_ReSDMAC_ctrl_reg():
    run(
        toplevel_lang="verilog",
        verilog_sources=[os.path.join("RTL/", "RESDMAC.v")],
        toplevel="RESDMAC",
        module="coctb_resdmac_ctrl_reg",
        python_search=[hdl_dir],
        timescale="1ns/100ps",
        force_compile="True",
        includes=[ "RTL/",
        "RTL/SCSI_SM",
        "RTL/CPU_SM",
        "RTL/datapath",
        "RTL/FIFO",
        "RTL/Registers"],
        waves="1"
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