# cocotb_registers.py

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer, ClockCycles
from cocotb.types import LogicArray

SSPB_DATA_ADDR = 0x58
TEST_PATTERN1 = 0xAAAAAAAA
TEST_PATTERN2 = 0x55555555

async def reset_dut(reset_n, duration_ns):
    await Timer(duration_ns, units="ns")
    reset_n.value = 0
    await Timer(duration_ns, units="ns")
    reset_n.value = 1
    await Timer(duration_ns, units="ns")
    reset_n._log.debug("Reset complete")
    
async def read_data(dut, addr):
    await RisingEdge(dut.CLK)
    #s0
    dut.DMAC_.value = 0
    dut.ADDR.value = addr
    dut.RW.value = 1
    await FallingEdge(dut.CLK)
    #s1
    dut.AS_.value = 0
    await RisingEdge(dut.CLK)
    #s2
    await FallingEdge(dut.CLK)
    #s3 nothing to do in s4 for a read
    await FallingEdge(dut.REG_DSK_)
    await RisingEdge(dut.CLK)
    #s4
    data = dut.REG_OD.value
    await FallingEdge(dut.CLK)
    #s5
    dut.AS_.value = 1
    await RisingEdge(dut.CLK)
    #Cycle end
    dut.RW.value = 1
    dut.ADDR.value = 0
    dut.DMAC_.value = 1
    await ClockCycles(dut.CLK, 1, True)
    dut._log.info("Read value %#x from addr %#x", data, addr)
    return data

    
async def write_data(dut, addr, data):
    dut._log.info("Write value %#x to addr %#x", data, addr)
    await RisingEdge(dut.CLK)
    #s0
    dut.DMAC_.value = 0
    dut.ADDR.value = addr
    dut.RW.value = 0
    await FallingEdge(dut.CLK)
    #s1
    dut.AS_.value = 0
    await RisingEdge(dut.CLK)
    #s2
    dut.MID.value = data
    await FallingEdge(dut.CLK)
    #s3
    #wait for cycle term signal to assert 
    await FallingEdge(dut.REG_DSK_)
    await RisingEdge(dut.CLK)
    #s4 nothing to do in s4 for a write
    await FallingEdge(dut.CLK)
    #s5
    dut.AS_.value = 1
    await RisingEdge(dut.CLK)
    #Cycle end
    dut.RW.value = 1
    dut.ADDR.value = 0
    dut.MID.value = 0
    dut.DMAC_.value = 1
    await ClockCycles(dut.CLK, 1, True)
    

@cocotb.test()
async def registers_test(dut):
    """Test registers"""
    #set inital value of inputs
    dut.ADDR.value = 0
    dut.DMAC_.value = 1
    dut.AS_.value = 1
    dut.RW.value = 1
    dut.MID.value = 0
    dut.STOPFLUSH.value = 0
    dut.RST_.value = 1
    dut.FIFOEMPTY.value = 1
    dut.FIFOFULL.value = 0
    dut.INTA_I.value = 0

    clock = Clock(dut.CLK, 40, units="ns")  # Create a 40ns period clock on port clk
    # Start the clock. Start it low to avoid issues on the first RisingEdge
    cocotb.start_soon(clock.start(start_high=False))

    await reset_dut(dut.RST_ , 40)
    dut._log.debug("After reset")

    assert dut.REG_OD.value == 0 , "REG_OD != 0x0  after reset"
    assert dut.FLUSHFIFO.value == 0 , "FLUSHFIFO != 0  after reset"
    assert dut.A1.value == 0  , "A1 != 0  after reset"
    assert dut.INT_O_.value == 1, "INT_O_ != 1  after reset"
    assert dut.ACR_WR.value == 0  , "ACR_WR != 0  after reset"
    assert dut.h_0C.value == 0  , "h_0C != 0  after reset"
    assert dut.REG_DSK_.value == 1, "REG_DSK_ != 1  after reset"
    assert dut.WDREGREQ.value == 0  , "WDREGREQ != 0  after reset"
    assert dut.DMAENA.value == 0 ,"DMAENA != 0  after reset"
    assert dut.DMADIR.value == 1 ,"DMADIR != 1  after reset"
    assert dut.INTENA.value == 0 ,"INTENA != 0  after reset"
    assert dut.PRESET.value == 0 ,"PRESET != 0  after reset"
    assert dut.CNTR_O.value == 0 , "CNTR_O != 0x0  after reset"
    assert dut.ISTR_O.value == 1,"ISTR_O != 0x1  after reset"
    assert dut.SSPBDAT.value == 0 , "SSPBDAT != 0x0  after reset"

    await ClockCycles(dut.CLK, 2, True)

    #1 test WTC register
    await write_data(dut, 0x04, TEST_PATTERN1)
    data = await read_data(dut, 0x04)
    assert data == 0x00, 'WTC Register not returning expected data'
    
    #2 test Control register
    #2a check inital values have been reset
    data = await read_data(dut, 0x08)
    assert data == 0x00, 'Control Register not returning expected data'
    assert dut.DMAENA.value == 0, 'Control Register DMAENA != 0'
    assert dut.DMADIR.value == 1, 'Control Register DMADIR != 1'
    assert dut.INTENA.value == 0, 'Control Register INTENA != 0'
    assert dut.PRESET.value == 0, 'Control Register PRESET != 0'
    
    #2b Check we can write to the register and set DMADIR.
    await write_data(dut, 0x08, 0x02)
    data = await read_data(dut, 0x08)
    assert data == 0x02, 'Control Register not returning expected data'
    assert dut.DMAENA.value == 0, 'Control Register DMAENA != 0'
    assert dut.DMADIR.value == 0, 'Control Register DMADIR != 0'
    assert dut.INTENA.value == 0, 'Control Register INTENA != 0'
    assert dut.PRESET.value == 0, 'Control Register PRESET != 0'
    
    #2c Check we can write to the register and set INTENA.
    await write_data(dut, 0x08, 0x04)
    data = await read_data(dut, 0x08)
    assert data == 0x04, 'Control Register not returning expected data'
    assert dut.DMAENA.value == 0, 'Control Register DMAENA != 0'
    assert dut.DMADIR.value == 1, 'Control Register DMADIR != 1'
    assert dut.INTENA.value == 1, 'Control Register INTENA != 1'
    assert dut.PRESET.value == 0, 'Control Register PRESET != 0'
    
    #2d Check we can write to the register and set PRESET.
    await write_data(dut, 0x08, 0x10)
    data = await read_data(dut, 0x08)
    assert data == 0x10, 'Control Register not returning expected data'
    assert dut.DMAENA.value == 0, 'Control Register DMAENA != 0'
    assert dut.DMADIR.value == 1, 'Control Register DMADIR != 1'
    assert dut.INTENA.value == 0, 'Control Register INTENA != 0'
    assert dut.PRESET.value == 1, 'Control Register PRESET != 1'

    #2e Check we can write to the register and set DMADIR, INTENA and PRESET.
    await write_data(dut, 0x08, 0x16)
    data = await read_data(dut, 0x08)
    assert data == 0x16, 'Control Register not returning expected data'
    assert dut.DMAENA.value == 0, 'Control Register DMAENA != 0'
    assert dut.DMADIR.value == 0, 'Control Register DMADIR != 0'
    assert dut.INTENA.value == 1, 'Control Register INTENA != 1'
    assert dut.PRESET.value == 1, 'Control Register PRESET != 1'
    

    #2f Start DMA using write
    await write_data(dut, 0x10, 0x0)
    data = await read_data(dut, 0x08)
    assert data == 0x116, 'Control Register not returning expected data'
    assert dut.DMAENA.value == 1, 'Control Register DMAENA != 1'
    assert dut.DMADIR.value == 0, 'Control Register DMADIR != 0'
    assert dut.INTENA.value == 1, 'Control Register INTENA != 1'
    assert dut.PRESET.value == 1, 'Control Register PRESET != 1'
    
    #2g Stop DMA using write
    await write_data(dut, 0x3c, 0x0)
    data = await read_data(dut, 0x08)
    assert data == 0x16, 'Control Register not returning expected data'
    assert dut.DMAENA.value == 0, 'Control Register DMAENA != 0'
    assert dut.DMADIR.value == 0, 'Control Register DMADIR != 0'
    assert dut.INTENA.value == 1, 'Control Register INTENA != 1'
    assert dut.PRESET.value == 1, 'Control Register PRESET != 1'
    
    #2h Start DMA using read
    await read_data(dut, 0x10)
    data = await read_data(dut, 0x08)
    assert data == 0x116, 'Control Register not returning expected data'
    assert dut.DMAENA.value == 1, 'Control Register DMAENA != 1'
    assert dut.DMADIR.value == 0, 'Control Register DMADIR != 0'
    assert dut.INTENA.value == 1, 'Control Register INTENA != 1'
    assert dut.PRESET.value == 1, 'Control Register PRESET != 1'
    
    #2i Stop DMA using read
    await read_data(dut, 0x3c)
    data = await read_data(dut, 0x08)
    assert data == 0x16, 'Control Register not returning expected data'
    assert dut.DMAENA.value == 0, 'Control Register DMAENA != 0'
    assert dut.DMADIR.value == 0, 'Control Register DMADIR != 0'
    assert dut.INTENA.value == 1, 'Control Register INTENA != 1'
    assert dut.PRESET.value == 1, 'Control Register PRESET != 1'
    
    #2j FLUSH FIFO
    await write_data(dut, 0x08, 0x00) #set DMADIR
    await read_data(dut, 0x14)
    assert dut.FLUSHFIFO.value == 1 , "FLUSHFIFO != 1  after FLUSH"
    dut.STOPFLUSH.value = 1
    await ClockCycles(dut.CLK, 1, True)
    assert dut.FLUSHFIFO.value == 0 , "FLUSHFIFO != 0  after STOPFLUSH"
    dut.STOPFLUSH.value = 0
    
        
    
    #3 test IST register
    await write_data(dut, 0x08, 0x04) #enable ints
    #3a check inital values have been reset
    data = await read_data(dut, 0x1C)
    assert data == 0x01, 'Control Register not returning expected data'
    assert dut.ISTR_O.value == 1,"ISTR_O != 0x1"
    assert dut.INT_O_.value == 1, "INT_O_ != 1"
    
    #3b Check setting FIFO Empty
    dut.FIFOEMPTY.value = 0
    data = await read_data(dut, 0x1C)    
    assert data == 0x00, 'IST Register not returning expected data'
    assert dut.ISTR_O.value == 0x0,"ISTR_O != 0x0"
    assert dut.INT_O_.value == 1, "INT_O_ != 1"    
    
    #3c Check setting FIFO Full
    dut.FIFOFULL.value = 1
    data = await read_data(dut, 0x1C)
    dut.FIFOFULL.value = 0
    assert data == 0x02, 'IST Register not returning expected data'
    assert dut.ISTR_O.value == 0x2,"ISTR_O != 0x2"
    assert dut.INT_O_.value == 1, "INT_O_ != 1"  
    
    #3d Check setting interupt input work with enabled interupts
    dut.INTA_I.value = 1
    data = await read_data(dut, 0x1C)
    dut.INTA_I.value = 0
    assert data == 0xF0, 'IST Register not returning expected data'
    assert dut.ISTR_O.value == 0xF0,"ISTR_O != 0xF0"
    assert dut.INT_O_.value == 0, "INT_O_ != 0"  
    
    #3e diable interupts.
    await write_data(dut, 0x08, 0x00)
    assert dut.INTENA.value == 0, 'Control Register INTENA != 0'
            
    #3f Check setting interupts input is now disabled
    dut.INTA_I.value = 1
    data = await read_data(dut, 0x1C)
    dut.INTA_I.value = 0
    assert data == 0xE0, 'IST Register not returning expected data'
    assert dut.ISTR_O.value == 0xE0, "ISTR_O != 0xE0"
    assert dut.INT_O_.value == 1, "INT_O_ != 1"  
    
    #3g clear interupts
    await read_data(dut, 0x18)
    data = await read_data(dut, 0x1C)
    assert data == 0x00, 'Control Register not returning expected data'
    assert dut.ISTR_O.value == 0x0,"ISTR_O != 0x0"
    assert dut.INT_O_.value == 1, "INT_O_ != 1"
    
    #4a test ACR register ODD
    await write_data(dut, 0x0C, TEST_PATTERN1)
    data = await read_data(dut, 0x0C)
    assert data == 0x00, 'ACR Register not returning expected data'
    assert dut.A1.value == 1  , "A1 != 1  after ACR ODD Write"
    
    #4b test ACR register Even
    await write_data(dut, 0x0C, TEST_PATTERN2)
    data = await read_data(dut, 0x0C)
    assert data == 0x00, 'ACR Register not returning expected data'
    assert dut.A1.value == 0  , "A1 != 0  after ACR Even Write"
    
    
    #5a test SSPBDAT register
    await write_data(dut, SSPB_DATA_ADDR, TEST_PATTERN1)
    data = await read_data(dut, SSPB_DATA_ADDR)
    assert data == TEST_PATTERN1, 'SSPBDAT Register not returning expected data'
    
    #5b test SSPBDAT register
    await write_data(dut, SSPB_DATA_ADDR, TEST_PATTERN2)
    data = await read_data(dut, SSPB_DATA_ADDR)
    assert data == TEST_PATTERN2, 'SSPBDAT Register not returning expected data'

 
