# cocotb_registers_term.py

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, ClockCycles
from cocotb.types import LogicArray

async def reset_dut(reset_n, duration_ns):
    await Timer(duration_ns, units="ns")
    reset_n.value = 0
    await Timer(duration_ns, units="ns")
    reset_n.value = 1
    await Timer(duration_ns, units="ns")
    reset_n._log.debug("Reset complete")

@cocotb.test()
async def registers_term_test(dut):
    """Test registers_term"""

    dut.AS_.value = 1
    dut.DMAC_.value = 1
    dut.WDREGREQ.value = 0
    dut.h_0C.value = 0

    clock = Clock(dut.CLK, 40, units="ns")  # Create a 40ns period clock on port clk
    # Start the clock. Start it low to avoid issues on the first RisingEdge
    cocotb.start_soon(clock.start(start_high=False))

    await reset_dut(dut.AS_ , 40)
    dut._log.debug("After reset")

    assert dut.REG_DSK_.value == 1, "REG_DSK_ != 1 after AS_ Negated"
    
    await ClockCycles(dut.CLK, 2, True)
    
    dut.AS_.value = 0
    dut.DMAC_.value = 0
    await ClockCycles(dut.CLK, 3, True)
    assert dut.REG_DSK_.value == 0, "REG_DSK_ != 0 after 3 clk cycles"
        
    await ClockCycles(dut.CLK, 6, True)
    
    dut.AS_.value = 1
    dut.DMAC_.value = 1
    await ClockCycles(dut.CLK, 3, True)
    assert dut.REG_DSK_.value == 1, "REG_DSK_ != 1 after 3 clk cycles"
    
    
    await ClockCycles(dut.CLK, 2, True)
    
    dut.AS_.value = 0
    dut.DMAC_.value = 0
    dut.WDREGREQ.value = 1
    await ClockCycles(dut.CLK, 3, True)
    assert dut.REG_DSK_.value == 1, "REG_DSK_ != 1 with WDREGREQ after 3 clk cycles"
    dut.AS_.value = 1
    dut.DMAC_.value = 1
    dut.WDREGREQ.value = 0
        
    await ClockCycles(dut.CLK, 2, True)
    
    dut.AS_.value = 0
    dut.DMAC_.value = 0
    dut.h_0C.value = 1
    await ClockCycles(dut.CLK, 3, True)
    assert dut.REG_DSK_.value == 1, "REG_DSK_ != 1 with h_0C after 3 clk cycles"
    dut.AS_.value = 1
    dut.DMAC_.value = 1
    dut.h_0C.value = 0
    await ClockCycles(dut.CLK, 2, True)
