from cocotb_test.simulator import run
import pytest
import os
import cocotb

hdl_dir = os.path.dirname(__file__)

def test_registers_cntr():
    run(
        toplevel_lang="verilog",
        verilog_sources=[os.path.join("RTL/Registers/", "registers_cntr.v")],
        toplevel="registers_cntr",
        module="cocotb_registers_cntr",
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