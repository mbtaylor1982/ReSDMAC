# test_fifo_3bit_cntr.py

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, ClockCycles, Timer
from cocotb.types import LogicArray

async def reset_dut(dut,reset_n):
    await ClockCycles(dut.CLK, 1, True)
    reset_n.value = 0
    await ClockCycles(dut.CLK, 2, True)
    reset_n.value = 1
    await ClockCycles(dut.CLK, 1, True)
    reset_n._log.debug("Reset complete")

@cocotb.test()
async def test_reset(dut):
    # Assert initial output is unknown
    assert LogicArray(dut.COUNT.value) == LogicArray("XXX")
    # Set initial input value to prevent it from floating
    dut.ClKEN.value = 0
    dut.RST_.value = 1

    clock = Clock(dut.CLK, 40, units="ns")  # Create a 40ns period clock on port clk
    # Start the clock. Start it low to avoid issues on the first RisingEdge
    cocotb.start_soon(clock.start(start_high=False))
    
    await reset_dut(dut, dut.RST_)
    assert dut.COUNT.value == 0, "Count was not reset to zero when RST_ = 0"

@cocotb.test()
async def test_enable(dut):
    dut.ClKEN.value = 0
    dut.RST_.value = 1
    
    clock = Clock(dut.CLK, 40, units="ns")  # Create a 40ns period clock on port clk
    cocotb.start_soon(clock.start(start_high=False))
    await reset_dut(dut, dut.RST_)
    
    await ClockCycles(dut.CLK, 1, True)
    assert dut.COUNT.value == 0, "Count incremented with clk edge when CLKEN = 0"


@cocotb.test()
async def test_count(dut):
    dut.ClKEN.value = 1
    dut.RST_.value = 1

    clock = Clock(dut.CLK, 40, units="ns")  # Create a 40ns period clock on port clk
    cocotb.start_soon(clock.start(start_high=False))
    await reset_dut(dut, dut.RST_)
    
    await FallingEdge(dut.CLK)
    dut.ClKEN.value = 1
    await RisingEdge(dut.CLK)
    
    assert dut.COUNT.value == 1, "Count was not 1 after one clock cycle with ClKEN = 1"
    await FallingEdge(dut.CLK)
    count = 0x1
    while(dut.COUNT.value != 0):
        await RisingEdge(dut.CLK)
        count = count + 0x1
        assert dut.COUNT.value == count, "Count was not incremented with clk edge when CLKEN = 1"
        await FallingEdge(dut.CLK)
    assert dut.COUNT.value == 0, "output COUNT did not return to zero"

    