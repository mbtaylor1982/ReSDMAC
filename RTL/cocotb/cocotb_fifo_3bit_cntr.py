# test_fifo_3bit_cntr.py

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.types import LogicArray

@cocotb.test()
async def fifo_3bit_cntr_test(dut):
    """Test fifo 3bit counter function"""

    # Assert initial output is unknown
    assert LogicArray(dut.COUNT.value) == LogicArray("XXX")
    # Set initial input value to prevent it from floating
    dut.ClKEN.value = 0
    dut.RST_.value = 0

    clock = Clock(dut.CLK, 40, units="ns")  # Create a 10us period clock on port clk
    # Start the clock. Start it low to avoid issues on the first RisingEdge
    cocotb.start_soon(clock.start(start_high=False))
    
    await RisingEdge(dut.CLK)
    assert dut.COUNT.value == 0, "Count was not reset to zero when RST_ = 0"
    dut.RST_.value = 1
    
    await RisingEdge(dut.CLK)
    assert dut.COUNT.value == 0, "Count incremented with clk edge when CLKEN = 0"
        
    dut.ClKEN.value = 1    
    
    for i in range(0,8):
        await RisingEdge(dut.CLK)
        assert dut.COUNT.value == i, "Count was not incremented with clk edge when CLKEN = 1"
    
    
    await RisingEdge(dut.CLK)
    assert dut.COUNT.value == 0, "output COUNT did not return to zero"

    