# cocotb_registers_cntr.py

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


async def write_data(dut, data):
    dut._log.info("Writing 0x%dh to registers_cntr", data)
    await ClockCycles(dut.CLK, 2, True)
    dut.CONTR_WR.value = 1
    dut.MID.value = data
    await ClockCycles(dut.CLK, 6, True)
    dut.CONTR_WR.value = 0
    dut.MID.value = 0
    await ClockCycles(dut.CLK, 1, True)
    

@cocotb.test()
async def registers_cntr_test(dut):
    """Test registers_cntr"""   

    clock = Clock(dut.CLK, 40, units="ns")  # Create a 40ns period clock on port clk
    # Start the clock. Start it low to avoid issues on the first RisingEdge
    cocotb.start_soon(clock.start(start_high=False))
    
    await reset_dut(dut._id("RESET_", extended=False) , 50)
    dut._log.debug("After reset")
    
    assert dut.DMAENA.value == 0 ,"DMAENA != 0  after reset"
    assert dut.DMADIR.value == 0 ,"DMADIR != 0  after reset"
    assert dut.INTENA.value == 0 ,"INTENA != 0  after reset"
    assert dut.PRESET.value == 0 ,"PRESET != 0  after reset"
    
    await write_data(dut, 2)
    assert dut.DMAENA.value == 0 ,"DMAENA != 0  after writing to CTRL reg"
    assert dut.DMADIR.value == 1 ,"DMADIR != 1  after writing to CTRL reg"
    assert dut.INTENA.value == 0 ,"INTENA != 0  after writing to CTRL reg"
    assert dut.PRESET.value == 0 ,"PRESET != 0  after writing to CTRL reg"
    
    await write_data(dut, 4)
    assert dut.DMAENA.value == 0 ,"DMAENA != 0  after writing to CTRL reg"
    assert dut.DMADIR.value == 0 ,"DMADIR != 0  after writing to CTRL reg"
    assert dut.INTENA.value == 1 ,"INTENA != 1  after writing to CTRL reg"
    assert dut.PRESET.value == 0 ,"PRESET != 0  after writing to CTRL reg"
    
    await write_data(dut, 16)
    assert dut.DMAENA.value == 0 ,"DMAENA != 0  after writing to CTRL reg"
    assert dut.DMADIR.value == 0 ,"DMADIR != 0  after writing to CTRL reg"
    assert dut.INTENA.value == 0 ,"INTENA != 0  after writing to CTRL reg"
    assert dut.PRESET.value == 1 ,"PRESET != 1  after writing to CTRL reg"
    
    await write_data(dut, 0)
    assert dut.DMAENA.value == 0 ,"DMAENA != 0  after writing to CTRL reg"
    assert dut.DMADIR.value == 0 ,"DMADIR != 0  after writing to CTRL reg"
    assert dut.INTENA.value == 0 ,"INTENA != 0  after writing to CTRL reg"
    assert dut.PRESET.value == 0 ,"PRESET != 0  after writing to CTRL reg"
    
    await ClockCycles(dut.CLK, 2, True)
    dut.ST_DMA.value = 1
    await ClockCycles(dut.CLK, 2, True)
    dut.ST_DMA.value = 0
    await ClockCycles(dut.CLK, 2, True)
    
    assert dut.DMAENA.value == 1 ,"DMAENA != 1  after writing to CTRL reg"
    assert dut.DMADIR.value == 0 ,"DMADIR != 0  after writing to CTRL reg"
    assert dut.INTENA.value == 0 ,"INTENA != 0  after writing to CTRL reg"
    assert dut.PRESET.value == 0 ,"PRESET != 0  after writing to CTRL reg"
    
    await ClockCycles(dut.CLK, 2, True)
    dut.SP_DMA.value = 1
    await ClockCycles(dut.CLK, 2, True)
    dut.SP_DMA.value = 0
    await ClockCycles(dut.CLK, 2, True)
    
    assert dut.DMAENA.value == 0 ,"DMAENA != 0  after writing to CTRL reg"
    assert dut.DMADIR.value == 0 ,"DMADIR != 0  after writing to CTRL reg"
    assert dut.INTENA.value == 0 ,"INTENA != 0  after writing to CTRL reg"
    assert dut.PRESET.value == 0 ,"PRESET != 0  after writing to CTRL reg"
    
   
