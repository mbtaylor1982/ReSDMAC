# cocotb_resdmac.py

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer, ClockCycles
from cocotb.types import LogicArray

WTC_REG_ADR = 0x01
SCSI_REG_ADR = 0x10
SSPB_DATA_ADR = 0x16
CONTR_REG_ADR = 0x02
RAMSEY_ACR_REG_ADR = 0x03
ST_DMA_STROBE_ADR  = 0x04
SP_DMA_STROBE_ADR  = 0x0f
FLUSH_STROBE_ADR   = 0x05

TEST_PATTERN1 = 0xAAAAAAAA
TEST_PATTERN2 = 0x55555555
SCSI_TEST_DATA1 = 0x00550055
SCSI_TEST_DATA2 = 0x5555

SCSI_TEST_DATA3 = 0x00AA
SCSI_TEST_DATA4 = 0x00AA00AA

CONTR_DMA_READ = 0x02
CONTR_DMA_WRITE = 0x00
CONTR_INTENA = 0x04
CONTR_INTDIS = 0x00
CONTR_PRESET = 0x10
CONTR_DMAENA = 0x100



async def reset_dut(reset_n, duration_ns):
    await Timer(duration_ns, units="ns")
    reset_n.value = 0
    await Timer(duration_ns, units="ns")
    reset_n.value = 1
    await Timer(duration_ns, units="ns")
    reset_n._log.debug("Reset complete")
    
async def read_data(dut, addr):
    await RisingEdge(dut.SCLK)
    #s0
    dut._id("_CS", extended=False).value = 0
    dut.ADDR.value = addr
    dut.R_W.value = 1
    await FallingEdge(dut.SCLK)
    #s1
    dut.AS_I_.value = 0
    dut.DS_I_.value = 0
    await RisingEdge(dut.SCLK)
    #s2
    await FallingEdge(dut.SCLK)
    #s3 nothing to do in s4 for a read
    await FallingEdge(dut.dsack_int)
    await RisingEdge(dut.SCLK)
    #s4
    data = dut.DATA_O.value
    await FallingEdge(dut.SCLK)
    #s5
    dut.AS_I_.value = 1
    dut.DS_I_.value = 1
    await RisingEdge(dut.SCLK)
    #Cycle end
    dut.R_W.value = 1
    dut.ADDR.value = 0
    dut._id("_CS", extended=False).value = 1    
    dut._log.info("Read value %#x from addr %#x", data, addr)
    return data

    
async def write_data(dut, addr, data):
    dut._log.info("Write value %#x to addr %#x", data, addr)
    await RisingEdge(dut.SCLK)
    #s0
    dut._id("_CS", extended=False).value = 0
    dut.ADDR.value = addr
    dut.R_W.value = 0
    await FallingEdge(dut.SCLK)
    #s1
    dut.AS_I_.value = 0
    await RisingEdge(dut.SCLK)
    #s2
    dut.DATA_I.value = data
    await FallingEdge(dut.SCLK)
    #s3
    dut.DS_I_.value = 0
    #wait for cycle term signal to assert 
    await FallingEdge(dut.dsack_int)
    await RisingEdge(dut.SCLK)
    #s4 nothing to do in s4 for a write
    await FallingEdge(dut.SCLK)
    #s5
    dut.AS_I_.value = 1
    dut.DS_I_.value = 1
    await RisingEdge(dut.SCLK)
    #Cycle end
    dut.R_W.value = 1
    dut.ADDR.value = 0
    dut.DATA_I.value = 0
    dut._id("_CS", extended=False).value = 1
   
    

@cocotb.test()
async def RESDMAC_test(dut):
    """Test RESDMAC"""
    
    #set inital value of inputs
    dut.ADDR.value = 0
    dut._id("_CS", extended=False).value = 1
    dut.AS_I_.value = 1
    dut.DS_I_.value = 1
    dut.R_W.value = 1
    dut.DATA_I.value = 0
    dut.BR.value = 0
    dut._id("_RST", extended=False).value = 1
    dut._id("_BG", extended=False).value = 1
    dut._id("_DREQ", extended=False).value = 1
    dut._id("_STERM", extended=False).value = 1
    dut._id("_DREQ", extended=False).value = 1
    dut._id("_BGACK_IO", extended=False).value = 1
    dut._id("_BERR", extended=False).value = 1
    dut.DSACK_I_.value = 3
    dut.INTA.value = 0


    clock = Clock(dut.SCLK, 40, units="ns")  # Create a 40ns period clock on port clk
    # Start the clock. Start it low to avoid issues on the first RisingEdge
    cocotb.start_soon(clock.start(start_high=False))
    
    await reset_dut(dut._id("_RST", extended=False), 40)
    dut._log.debug("After reset")
    dut.AS_I_.value = 1
    dut.DS_I_.value = 1
    dut.R_W.value = 1


    #1 test WTC register
    await write_data(dut, WTC_REG_ADR, TEST_PATTERN1)
    data = await read_data(dut, WTC_REG_ADR)
    assert data == 0x00, 'WTC Register not returning expected data'
    
    #2 Test write to SCSI 
    await write_data(dut, SCSI_REG_ADR, SCSI_TEST_DATA1)
    assert dut._id("_CSS", extended=False).value == 0 , "_CSS not asserted when writing to SCSI IC"
    #assert dut._id("_IOW", extended=False).value == 0 , "_IOW not asserted when writing to SCSI IC"
    assert dut.PDATA_O.value == SCSI_TEST_DATA2 , "PDATA_O not returning expected data value"
    await RisingEdge(dut._id("_CSS", extended=False))
   
    #3 Test read from scsi
    dut.PDATA_I.value = SCSI_TEST_DATA3
    data = await read_data(dut, SCSI_REG_ADR)
    assert data == SCSI_TEST_DATA4, "Error reading scsi data"
    assert dut._id("_CSS", extended=False).value == 0 , "_CSS not asserted when reading from SCSI IC"
    assert dut._id("_IOR", extended=False).value == 0 , "_IOR not asserted when reading from SCSI IC"
    await RisingEdge(dut._id("_CSS", extended=False))
    await RisingEdge(dut._id("_IOR", extended=False))
    dut.PDATA_I.value = 0x00
    
    #4 check we can reset the SCSI IC
    await write_data(dut, CONTR_REG_ADR, CONTR_PRESET)
    assert (dut._id("_IOR", extended=False).value == 0) and (dut._id("_IOW", extended=False).value == 0) , "PRESET did not assert _IOW and _IOR"
    
    #5 test SSPBDAT register
    await write_data(dut, SSPB_DATA_ADR, TEST_PATTERN1)
    data = await read_data(dut, SSPB_DATA_ADR)
    assert data == TEST_PATTERN1, 'SSPBDAT Register not returning expected data'
    
    #6 test SSPBDAT register
    await write_data(dut, SSPB_DATA_ADR, TEST_PATTERN2)
    data = await read_data(dut, SSPB_DATA_ADR)
    assert data == TEST_PATTERN2, 'SSPBDAT Register not returning expected data'
    
    #7 Test DMA READ (from scsi to memory) cycle
    await reset_dut(dut._id("_RST", extended=False), 40)

    #Setup DMA Direction to Read from SCSI write to Memory
    await write_data(dut, CONTR_REG_ADR, (CONTR_DMA_READ | CONTR_INTENA))
    #start DMA
    await read_data(dut, ST_DMA_STROBE_ADR)
    #Set Destination address
    await write_data(dut, RAMSEY_ACR_REG_ADR, 0x00000008)

    dut.PDATA_I.value = 0x0001
    
    #load fifo from scsci
    while (dut.FIFOFULL == 0):
        dut._id("_DREQ", extended=False).value = 0
        await FallingEdge(dut._id("_DACK", extended=False))
        await FallingEdge(dut._id("_IOR", extended=False))
        dut._id("_DREQ", extended=False).value = 1
        await RisingEdge(dut._id("_DACK", extended=False))
        await ClockCycles(dut.SCLK, 2, True)
        dut.PDATA_I.value += 0x0001
    
    #grant bus to SDMAC    
    await RisingEdge(dut._id("BR", extended=False))
    if (dut.AS_I_.value == 1) and (dut._id("_BGACK_IO", extended=False).value == 1):
        dut._id("_BG", extended=False).value = 0
    await FallingEdge(dut._id("_BGACK_IO", extended=False))
    dut._id("_BG", extended=False).value = 1
    
    while (dut.FIFOEMPTY == 0):
        await FallingEdge(dut.AS_O_)
        await ClockCycles(dut.SCLK, 2, True)
        dut._id("_STERM", extended=False).value = 0
        await ClockCycles(dut.SCLK, 1, True)
        dut._id("_STERM", extended=False).value = 1
    
    await ClockCycles(dut.SCLK, 2, True)    
    await FallingEdge(dut.SCLK)
    
    dut.AS_I_.value = 1
    dut.DS_I_.value = 1
    dut.R_W.value = 1
    #stop DMA
    await read_data(dut, SP_DMA_STROBE_ADR)
    
    await read_data(dut, FLUSH_STROBE_ADR)
    
        
    
