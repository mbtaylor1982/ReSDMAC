# cocotb_registers_istr.py

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
async def registers_istr_test(dut):
    """Test registers_istr"""

    dut.ISTR_RD_.value = 1
    dut.CLR_INT_.value = 1
    dut.RESET_.value = 1
    dut.INTA_I.value = 0
    dut.INTENA.value = 0
    dut.FIFOFULL.value = 0
    dut.FIFOEMPTY.value = 1

    clock = Clock(dut.CLK, 40, units="ns")  # Create a 40ns period clock on port clk
    # Start the clock. Start it low to avoid issues on the first RisingEdge
    cocotb.start_soon(clock.start(start_high=False))

    await reset_dut(dut.RESET_ , 25)
    dut._log.debug("After reset")

    assert dut.INT_F.value == 0 ,"INT_F != 0  after reset"
    assert dut.INTS.value == 0 ,"INTS != 0  after reset"
    assert dut.E_INT.value == 0 ,"E_INT != 0  after reset"
    assert dut.INT_P.value == 0 ,"INT_P != 0  after reset"
    assert dut.FF.value == 0 ,"FF != 0  after reset"
    assert dut.FE.value == 1 ,"FE != 1  after reset"
    assert dut.INT_O_.value == 1, "INT_O_ != 1  after reset"
    assert dut.ISTR_O.value == 1,"ISTR_O != 0x1  after reset"

    dut.INTENA.value = 1
    await ClockCycles(dut.CLK, 2, True)
    dut.INTA_I.value = 1
    await ClockCycles(dut.CLK, 2, True)
    dut.ISTR_RD_.value = 0
    await ClockCycles(dut.CLK, 2, True)
    
    assert dut.INT_F.value == 1 ,"INT_F != 1  after interrupt"
    assert dut.INTS.value == 1 ,"INTS != 1  after interrupt"
    assert dut.E_INT.value == 1 ,"E_INT != 1  after interrupt"
    assert dut.INT_P.value == 1 ,"INT_P != 1  after interrupt"
    assert dut.INT_O_.value == 0, "INT_O_ != 0  after interrupt"
    assert dut.ISTR_O.value == 0xF1,"ISTR_O != 0xF1  after interrupt"
    
    dut.INTA_I.value = 0
    dut.ISTR_RD_.value = 1
    await ClockCycles(dut.CLK, 2, True)

    await reset_dut(dut.CLR_INT_ , 40)
    dut._log.debug("After CLR_INT_")
    await ClockCycles(dut.CLK, 1, True)

    assert dut.INT_F.value == 0 ,"INT_F != 0  after CLR_INT_"
    assert dut.INTS.value == 0 ,"INTS != 0  after CLR_INT_"
    assert dut.E_INT.value == 0 ,"E_INT != 0  after CLR_INT_"
    assert dut.INT_P.value == 0 ,"INT_P != 0  after CLR_INT_"
    assert dut.INT_O_.value == 1, "INT_O_ != 1  after CLR_INT_"

    dut.INTENA.value = 0
    await ClockCycles(dut.CLK, 2, True)
    dut.INTA_I.value = 1
    await ClockCycles(dut.CLK, 2, True)
    dut.ISTR_RD_.value = 0
    await ClockCycles(dut.CLK, 2, True)

    assert dut.INT_F.value == 1  ,"INT_F != 1  after (disabled) interrupt"
    assert dut.INTS.value == 1 ,"INTS != 1  after (disabled) interrupt"
    assert dut.E_INT.value == 1 ,"E_INT != 1  after (disabled) interrupt"
    assert dut.INT_P.value == 0 ,"INT_P != 0  after (disabled) interrupt"
    assert dut.INT_O_.value == 1, "INT_O_ != 1  after (disabled) interrupt"
    assert dut.ISTR_O.value == 0xE1,"ISTR_O != 0xE1  after (disabled) interrupt"
    
    dut.ISTR_RD_.value = 1
    dut.INTA_I.value = 0
    await ClockCycles(dut.CLK, 2, True)
    
    await reset_dut(dut.CLR_INT_ , 40)
    dut._log.debug("After CLR_INT_")
    await ClockCycles(dut.CLK, 1, True)
    
    assert dut.INT_F.value == 0 ,"INT_F != 0  after CLR_INT_"
    assert dut.INTS.value == 0 ,"INTS != 0  after CLR_INT_"
    assert dut.E_INT.value == 0 ,"E_INT != 0  after CLR_INT_"
    assert dut.INT_P.value == 0 ,"INT_P != 0  after CLR_INT_"
    assert dut.INT_O_.value == 1, "INT_O_ != 1  after CLR_INT_"

    
    await ClockCycles(dut.CLK, 2, True)
    dut.FIFOFULL.value = 1
    dut.FIFOEMPTY.value = 0
    await ClockCycles(dut.CLK, 2, True)
    dut.ISTR_RD_.value = 0
    await ClockCycles(dut.CLK, 2, True)

    assert dut.FF.value == 1 ,"FF != 1  after Fifo input"
    assert dut.FE.value == 0 ,"FE != 0  after Fifo input"
    assert dut.ISTR_O.value == 0x02,"ISTR_O != 0x02  after Fifo input"
    
    dut.ISTR_RD_.value = 1
    dut.FIFOFULL.value = 0
    dut.FIFOEMPTY.value = 1
    await ClockCycles(dut.CLK, 2, True)

