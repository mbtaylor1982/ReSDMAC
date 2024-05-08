from cocotb_test.simulator import run
import pytest
import os
import cocotb
import logging

hdl_dir = os.path.dirname(__file__)

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

def test_fsm_cpu(caplog):
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

def test_registers_cntr(caplog):
    caplog.set_level(logging.INFO)
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
    
def test_registers_istr(caplog):
    caplog.set_level(logging.INFO)
    run(
        toplevel_lang="verilog",
        verilog_sources=[os.path.join("RTL/Registers/", "registers_istr.v")],
        toplevel="registers_istr",
        module="cocotb_registers_istr",
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

def test_registers_term(caplog):
    caplog.set_level(logging.INFO)
    run(
        toplevel_lang="verilog",
        verilog_sources=[os.path.join("RTL/Registers/", "registers_term.v")],
        toplevel="registers_term",
        module="cocotb_registers_term",
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