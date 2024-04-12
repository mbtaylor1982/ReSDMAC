# cocotb_fifo.py

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer, ClockCycles
from cocotb.types import LogicArray


async def reset_dut(reset_n, duration_ns):
    await Timer(duration_ns, units="ns")
    reset_n.value = 0
    await Timer(duration_ns, units="ns")
    reset_n.value = 1
    await Timer(duration_ns, units="ns")
    reset_n._log.debug("Reset complete")

async def custom_clock(signal,period,units,phaseshift):
    signal.value = 0
    period_half_cycle = Timer(period/2, units=units)
    await Timer((phaseshift * period)/360, units=units)
    while True:
        signal.value = 1
        await period_half_cycle
        signal.value = 0
        await period_half_cycle

@cocotb.test()
async def fifo_test(dut):
    """Test fifo"""
    #set inital value of inputs
    dut.RST_FIFO_.value = 1
    dut.LLWORD.value = 0        #Load Lower Word strobe from CPU sm
    dut.LHWORD.value = 0        #Load Higher Word strobe from CPU sm
    dut.LBYTE_.value = 1        #Load Byte strobe from SCSI SM = !(DACK.o & RE.o)
    dut.H_0C.value = 0          #Address Decode for $0C ACR register
    dut.ACR_WR.value = 0        #indicate write to ACR?
    dut.MID25.value = 0         #think this may be checking A1 in the ACR to make sure BYTE PTR is initialised to the correct value.
    dut.FIFO_ID.value = 0       #FIFO Data Input
    dut.INCFIFO.value = 0       #Inc FIFO from CPU sm
    dut.DECFIFO.value = 0       #Dec FIFO from CPU sm
    dut.INCBO.value = 0         #Inc Byte Pointer from SCSI SM.
    dut.INCNO.value = 0         #Inc Next Out (Write Pointer)
    dut.INCNI.value = 0         #Inc Next In (Read Pointer)

    clock = Clock(dut.CLK, 40, units="ns")  # Create a 40ns period clock on port clk
    clock90 = custom_clock(dut.CLK90, 40, "ns", 90)
    clock135 = custom_clock(dut.CLK135, 40, "ns", 135)
    await cocotb.start(clock.start())
    await cocotb.start(clock90)
    await cocotb.start(clock135)

    await reset_dut(dut.RST_FIFO_ , 40)
    dut._log.debug("After reset")

    assert dut.WRITE_PTR.value == 0 ,"WRITE_PTR != 0  after reset"
    assert dut.READ_PTR.value == 0 ,"READ_PTR != 0  after reset"
    assert dut.BYTE_PTR.value == 3 ,"BYTE_PTR != 3  after reset"
    assert dut.FIFOEMPTY.value == 1 ,"FIFOEMPTY != 1  after reset"
    assert dut.FIFOFULL.value == 0 ,"FIFOFULL != 0  after reset"
    assert dut.BO0.value == 1 ,"BO0 != 1  after reset"
    assert dut.BO1.value == 1 ,"BO1 != 1  after reset"
    assert dut.BOEQ0.value == 0 ,"BOEQ0 != 0  after reset"
    assert dut.BOEQ3.value == 1 ,"BOEQ3 != 1  after reset"

    await ClockCycles(dut.CLK, 2, True)    
    
    #test filling and emptying FIFO a byte at a time
    dut.FIFO_ID.value = 0x11121314
    m = 8
    for j in range (0, m):
        n = 4
        for i in range (0, n):
            await ClockCycles(dut.CLK, 1, True) 
            dut.LBYTE_.value = 0
            await ClockCycles(dut.CLK, 1, True) 
            dut.LBYTE_.value = 1
            await ClockCycles(dut.CLK, 1, True) 
            dut.INCBO.value = 1
            await ClockCycles(dut.CLK, 1, True) 
            dut.INCBO.value = 0
        assert dut.BOEQ3.value == 1 ,"BOEQ3 != 1  after long word transfered"        
        dut.INCNI.value = 1
        dut.INCFIFO.value = 1
        await ClockCycles(dut.CLK, 1, True)  
        dut.INCNI.value = 0
        dut.INCFIFO.value = 0
        dut.FIFO_ID.value = dut.FIFO_ID.value + 0x10101010
        await ClockCycles(dut.CLK, 1, True)
        assert dut.FIFOEMPTY.value == 0 ,"FIFOEMPTY != 0  after  long word transfered"
    assert dut.FIFOFULL.value == 1 ,"FIFOFULL != 1  after population"
    
    dut.FIFO_ID.value = 0x00000000  

    while (dut.FIFOEMPTY.value != 1):
        n = 4
        for i in range (0, n):
            dut.INCBO.value = 1
            await ClockCycles(dut.CLK, 2, True) 
            dut.INCBO.value = 0
            await ClockCycles(dut.CLK, 2, True) 
        dut.INCNO.value = 1
        dut.DECFIFO.value = 1
        await ClockCycles(dut.CLK, 1, True)  
        dut.INCNO.value = 0
        dut.DECFIFO.value = 0
        await ClockCycles(dut.CLK, 1, True)
    assert dut.FIFOEMPTY.value == 1 ,"FIFOEMPTY != 1  after flush"
    
        
        
    #test filling and emptying FIFO a longword at a time
    dut.FIFO_ID.value = 0x11121314
    while (dut.FIFOFULL.value != 1):
        dut.LLWORD.value = 1
        dut.LHWORD.value = 1 
        await ClockCycles(dut.CLK, 1, True)  
        dut.LLWORD.value = 0
        dut.LHWORD.value = 0
        dut.INCNI.value = 1
        dut.INCFIFO.value = 1
        await ClockCycles(dut.CLK, 1, True)  
        dut.INCNI.value = 0
        dut.INCFIFO.value = 0
        dut.FIFO_ID.value = dut.FIFO_ID.value + 0x10101010
        await ClockCycles(dut.CLK, 1, True)
    dut.FIFO_ID.value = 0x00000000  

    while (dut.FIFOEMPTY.value != 1):
        dut.INCNO.value = 1
        dut.DECFIFO.value = 1
        await ClockCycles(dut.CLK, 1, True)  
        dut.INCNO.value = 0
        dut.DECFIFO.value = 0
        await ClockCycles(dut.CLK, 1, True)

