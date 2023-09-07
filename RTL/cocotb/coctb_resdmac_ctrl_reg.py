# coctb_resdmac_ctrl_reg.py

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, ClockCycles
from cocotb.types import LogicArray

async def reset_dut(reset_n, duration_ns):
    reset_n.value = 0
    await Timer(duration_ns, units="ns")
    reset_n.value = 1
    reset_n._log.debug("Reset complete")


async def write_data(dut, addr, data):
    dut._log.info("Writing 0x%0h to 0x%0h", data, addr)
    await ClockCycles(dut.SCLK, 2, True)
    dut.ADDR.value = addr
    dut.DATA_IO.value = data
    await ClockCycles(dut.SCLK, 1, True)
    dut._id("_AS_IO", extended=False).value = 0
    dut.R_W_IO.value = 0
    await ClockCycles(dut.SCLK, 1, True)
    dut._id("_DS_IO", extended=False).value = 0
    await ClockCycles(dut.SCLK, 2, True)
    dut.R_W_IO.value = 1
    dut._id("_AS_IO", extended=False).value = 1
    dut._id("_DS_IO", extended=False).value = 1
    await ClockCycles(dut.SCLK, 2, True)
    dut.ADDR.value = 0
    dut.DATA_IO.value = 0
    await ClockCycles(dut.SCLK, 1, True)
    

@cocotb.test()
async def resdmac_ctrl_reg_test(dut):
    """Test resdmac_ctrl_reg"""   

    clock = Clock(dut.SCLK, 40, units="ns")  # Create a 40ns period clock on port clk
    # Start the clock. Start it low to avoid issues on the first RisingEdge
    cocotb.start_soon(clock.start(start_high=False))
    
    await reset_dut(dut._id("_RST", extended=False) , 50)
    dut._log.debug("After reset")
    
    await write_data(dut, 0x3,0x00000006)
    

    
   
