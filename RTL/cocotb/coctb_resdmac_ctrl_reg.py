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
    dut._log.info("Writing 0x%dh to 0x%dh", data, addr)
    await ClockCycles(dut.SCLK, 2, True)
    dut.ADDR.value = addr
    dut.DATA_I.value = data
    await ClockCycles(dut.SCLK, 1, True)
    dut._id("_AS_IO", extended=False).value = 0
    dut.R_W_IO.value = 0
    dut.DATA_I.value = data
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
    
    dut.TEST.value = 1
    
    await reset_dut(dut._id("_RST", extended=False) , 50)
    dut._log.debug("After reset")
    
    assert dut.u_registers.u_registers_cntr.DMAENA.value == 0 ,"DMAENA != 0  after reset"
    assert dut.u_registers.u_registers_cntr.DMADIR.value == 0 ,"DMADIR != 0  after reset"
    assert dut.u_registers.u_registers_cntr.INTENA.value == 0 ,"INTENA != 0  after reset"
    assert dut.u_registers.u_registers_cntr.PRESET.value == 0 ,"PRESET != 0  after reset"
    
    dut._id("_CS",extended=False).value = 0
    
    await write_data(dut, 2,2)
    assert dut.u_registers.u_registers_cntr.DMAENA.value == 0 ,"DMAENA != 0  after writing to CTRL reg"
    assert dut.u_registers.u_registers_cntr.DMADIR.value == 1 ,"DMADIR != 1  after writing to CTRL reg"
    assert dut.u_registers.u_registers_cntr.INTENA.value == 0 ,"INTENA != 0  after writing to CTRL reg"
    assert dut.u_registers.u_registers_cntr.PRESET.value == 0 ,"PRESET != 0  after writing to CTRL reg"
    
    await write_data(dut, 0x2,4)
    assert dut.u_registers.u_registers_cntr.DMAENA.value == 0 ,"DMAENA != 0  after writing to CTRL reg"
    assert dut.u_registers.u_registers_cntr.DMADIR.value == 0 ,"DMADIR != 0  after writing to CTRL reg"
    assert dut.u_registers.u_registers_cntr.INTENA.value == 1 ,"INTENA != 1  after writing to CTRL reg"
    assert dut.u_registers.u_registers_cntr.PRESET.value == 0 ,"PRESET != 0  after writing to CTRL reg"
    
    await write_data(dut, 0x2,16)
    assert dut.u_registers.u_registers_cntr.DMAENA.value == 0 ,"DMAENA != 0  after writing to CTRL reg"
    assert dut.u_registers.u_registers_cntr.DMADIR.value == 0 ,"DMADIR != 0  after writing to CTRL reg"
    assert dut.u_registers.u_registers_cntr.INTENA.value == 0 ,"INTENA != 0  after writing to CTRL reg"
    assert dut.u_registers.u_registers_cntr.PRESET.value == 1 ,"PRESET != 1  after writing to CTRL reg"
    
    await write_data(dut, 0x2,0)
    assert dut.u_registers.u_registers_cntr.DMAENA.value == 0 ,"DMAENA != 0  after writing to CTRL reg"
    assert dut.u_registers.u_registers_cntr.DMADIR.value == 0 ,"DMADIR != 0  after writing to CTRL reg"
    assert dut.u_registers.u_registers_cntr.INTENA.value == 0 ,"INTENA != 0  after writing to CTRL reg"
    assert dut.u_registers.u_registers_cntr.PRESET.value == 0 ,"PRESET != 0  after writing to CTRL reg"
    
    await write_data(dut, 0x4,0)
    assert dut.u_registers.u_registers_cntr.DMAENA.value == 1 ,"DMAENA != 1  after writing to CTRL reg"
    assert dut.u_registers.u_registers_cntr.DMADIR.value == 0 ,"DMADIR != 0  after writing to CTRL reg"
    assert dut.u_registers.u_registers_cntr.INTENA.value == 0 ,"INTENA != 0  after writing to CTRL reg"
    assert dut.u_registers.u_registers_cntr.PRESET.value == 0 ,"PRESET != 0  after writing to CTRL reg"
    
    await write_data(dut, 0xF,0)
    assert dut.u_registers.u_registers_cntr.DMAENA.value == 0 ,"DMAENA != 0  after writing to CTRL reg"
    assert dut.u_registers.u_registers_cntr.DMADIR.value == 0 ,"DMADIR != 0  after writing to CTRL reg"
    assert dut.u_registers.u_registers_cntr.INTENA.value == 0 ,"INTENA != 0  after writing to CTRL reg"
    assert dut.u_registers.u_registers_cntr.PRESET.value == 0 ,"PRESET != 0  after writing to CTRL reg"
    
   
