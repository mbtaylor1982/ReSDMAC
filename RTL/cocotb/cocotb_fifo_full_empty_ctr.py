"""ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/"""

# test_fifo_full_empty_ctr.py

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Edge, ClockCycles
from cocotb.types import LogicArray

@cocotb.test()
async def fifo_full_empty_test(dut):
    """Test fifo full.empty counter function"""

    # Set initial input value to prevent it from floating
    dut.RST_.value = 0
    dut.INC.value = 0
    dut.DEC.value = 0
    

    clock = Clock(dut.CLK, 40, units="ns")  # Create a 10us period clock on port clk
    # Start the clock. Start it low to avoid issues on the first RisingEdge
    cocotb.start_soon(clock.start(start_high=False))

    await ClockCycles(dut.CLK, 2, True)
    assert dut.FULL.value == 0, "FULL was not reset to zero when RST_ = 0"
    assert dut.EMPTY.value == 1, "EMPTY was not reset to zero when RST_ = 1"
    dut.RST_.value = 1

    await ClockCycles(dut.CLK, 2, True)

    dut._log.info("--**Starting inc Test**--")

    dut.INC.value = 1

    for i in range(0,8):
        dut._log.info("Preinc counter iteration  %#x FULL = %#x, EMPTY = %#x", i, dut.FULL.value, dut.EMPTY.value)
        if i == 0:
            assert dut.EMPTY.value == 1, "EMPTY was not set before first INC"
        else:
            assert dut.EMPTY.value == 0, "EMPTY was not reset with clk edge when INC = 1"
        if i == 8:
            assert dut.FULL.value == 1, "FULL was not reset with clk edge when INC = 1 and count = 8"
        else:
            assert dut.FULL.value == 0, "FULL was set with clk edge when INC = 1 but count < 8"
        await ClockCycles(dut.CLK, 1, True)
        dut._log.info("Postinc counter iteration  %#x FULL = %#x, EMPTY = %#x", i, dut.FULL.value, dut.EMPTY.value)

    dut._log.info("--**Starting Dec Test**--")

    dut.INC.value = 0
    dut.DEC.value = 1

    for i in range(0,8):
        dut._log.info("PreDec counter iteration %#x FULL = %#x, EMPTY = %#x", i, dut.FULL.value, dut.EMPTY.value)
        if i == 0:
            assert dut.FULL.value == 1, "FULL was not set before first dec"
        else:
            assert dut.FULL.value == 0, "FULL was not reset with clk edge when DEC = 1"
        if i == 8:
            assert dut.EMPTY.value == 1, "EMPTY was not reset with clk edge when DEC = 1 and count = 8"
        else:
            assert dut.EMPTY.value == 0, "EMPTY was set with clk edge when DEC = 1 but count < 8"
        await ClockCycles(dut.CLK, 1, True)
        dut._log.info("PostDec counter iteration %#x FULL = %#x, EMPTY = %#x", i, dut.FULL.value, dut.EMPTY.value)