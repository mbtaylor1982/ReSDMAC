# cocotb_resdmac.py

import random
import array as arr

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Edge, Timer, ClockCycles
from cocotb.types import LogicArray

WTC_REG_ADR = 0x01
VERSION_REG_ADR = 0x08

SCSI_REG_ADR1 = 0x10
SCSI_REG_ADR2 = 0x11
SCSI_REG_ADR3 = 0x12
SCSI_REG_ADR4 = 0x13

SSPB_DATA_ADR = 0x16
CONTR_REG_ADR = 0x02
RAMSEY_ACR_REG_ADR = 0x03
ST_DMA_STROBE_ADR  = 0x04
SP_DMA_STROBE_ADR  = 0x0f
FLUSH_STROBE_ADR   = 0x05

TEST_PATTERN1 = 0xAAAAAAAA
TEST_PATTERN2 = 0x55555555
SCSI_TEST_DATA1 = 0x005500AA
SCSI_TEST_DATA2 = 0x5555
SCSI_TEST_DATA5 = 0xAAAA

SCSI_TEST_DATA3 = 0x00AA
SCSI_TEST_DATA4 = 0x00AA00AA

REV_STR = 0x52455631

CONTR_DMA_READ = 0x00
CONTR_DMA_WRITE = 0x02
CONTR_INTENA = 0x04
CONTR_INTDIS = 0x00
CONTR_PRESET = 0x10
CONTR_DMAENA = 0x100

TEST_DATA_ARRAY_LONG = arr.array('L', [0x1a1b1c1d, 0x2a2b2c2d, 0x3a3b3c3d, 0x4a4b4c4d, 0x5a5b5c5d, 0x6a6b6c6d, 0x7a7b7c7d, 0x8a8b8c8d])
TEST_DATA_ARRAY_BYTE = arr.array('B', [0x1a,0x1b,0x1c,0x1d, 0x2a,0x2b,0x2c,0x2d, 0x3a,0x3b,0x3c,0x3d, 0x4a,0x4b,0x4c,0x4d, 0x5a,0x5b,0x5c,0x5d, 0x6a,0x6b,0x6c,0x6d, 0x7a,0x7b,0x7c,0x7d, 0x8a,0x8b,0x8c,0x8d])

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
    
async def FillFIFOFromSCSI(dut, initialValue):
    dut._log.info("Started Filling FIFO From SCSI")
    i = 0
    #load fifo from scsci
    while (dut.FIFOFULL == 0):
        dut._id("_DREQ", extended=False).value = 0
        dut.PDATA_I.value = TEST_DATA_ARRAY_BYTE[i]
        await FallingEdge(dut._id("_DACK", extended=False))
        await FallingEdge(dut._id("_IOR", extended=False))
        dut._log.info("loaded FIFO with value %#x from SCSI", dut.PDATA_I.value)
        dut._id("_DREQ", extended=False).value = 1
        await RisingEdge(dut._id("_DACK", extended=False))
        await ClockCycles(dut.SCLK, 1, True)
        await RisingEdge(dut.SCLK)
        i += 1
    dut.PDATA_I.value = 0
    dut._log.info("Finished Filling FIFO From SCSI")

async def FillFIFOFromMem(dut, initialValue,TermSignal):
    dut._log.info("Started Filling FIFO From Memory")
    i = 0
    #load fifo from memory
    while (dut.FIFOFULL == 0):
        await FallingEdge(dut.AS_O_)
        dut.DATA_I.value = TEST_DATA_ARRAY_LONG[i]
        await ClockCycles(dut.SCLK, 1, True)
        await RisingEdge(dut.SCLK)
        dut._id(TermSignal, extended=False).value = 0
        dut._log.info("loaded FIFO with value %#x from memory", dut.DATA_I.value)
        await RisingEdge(dut.AS_O_)
        dut._id(TermSignal, extended=False).value = 1
        await RisingEdge(dut.SCLK)
        i += 1
    dut.DATA_I.value =0x0
    dut._log.info("Finished Filling FIFO From Memory")

async def f2s(dut):
    dut._log.info("Started transferring FIFO to SCSI")
    result = arr.array('B')
    await RisingEdge(dut.AS_O_)
    await RisingEdge(dut.SCLK)

    while (dut.FIFOEMPTY == 0):
        dut._id("_DREQ", extended=False).value = 0
        await FallingEdge(dut._id("_DACK", extended=False))
        await FallingEdge(dut._id("_IOW", extended=False))
        result.append(dut.PDATA_O.value & 0x00ff)
        dut._log.info("Transfering value %#x from FIFO to SCSI", dut.PDATA_O.value)
        dut._id("_DREQ", extended=False).value = 1
        await RisingEdge(dut._id("_DACK", extended=False))
        await ClockCycles(dut.SCLK, 1, True)
        await RisingEdge(dut.SCLK)

    are_equal = arrays_are_equal(dut, result, TEST_DATA_ARRAY_BYTE)
    dut._log.info("Finished transferring FIFO to SCSI")
    assert are_equal, "TEST_DATA_ARRAY_BYTE != result"

async def wait_for_bus_release(dut):
    await RisingEdge(dut._id("_BGACK_IO", extended=False))
    await RisingEdge(dut.SCLK)
    await ClockCycles(dut.SCLK, 2, True)

async def wait_for_bus_grant(dut):
    if (dut._id("_BR", extended=False) == 1):
        dut._log.info("waiting BR falling edge")
        await FallingEdge(dut._id("_BR", extended=False))
    if (dut.AS_I_.value == 0):
        dut._log.info("waiting AS rising edge")
        await RisingEdge(dut._id("AS_I_", extended=False))
        await ClockCycles(dut.SCLK, 1, True)
    if (dut.AS_I_.value == 1) and (dut._id("_BGACK_IO", extended=False).value == 1):
        dut._log.info("setting _BG low")
        dut._id("_BG", extended=False).value = 0
    dut._log.info("waiting _BGACK_IO falling edge")    
    await FallingEdge(dut._id("_BGACK_IO", extended=False))
    dut._id("_BG", extended=False).value = 1
    await FallingEdge(dut.SCLK)
    
def arrays_are_equal(dut, arr1, arr2):
    dut._log.info("Started checking array values")
    if len(arr1) != len(arr2):
        dut._log.error("arrays are not equal length")
        return False
    for i in range(len(arr1)):
        if arr1[i] != arr2[i]:
            dut._log.error("Value %#x != expected value %#x",arr1[i], arr2[i])
            return False
    dut._log.info("Finished checking array values")
    return True

async def XferFIFO2Mem(dut,TermSignal):
    dut._log.info("Started transferring FIFO to Memory")
    result = arr.array('L')
    while (dut.FIFOEMPTY == 0):
        await FallingEdge(dut.AS_O_)
        result.append(dut.DATA_O.value)
        dut._log.info("Transfering value %#x from FIFO to Memory", dut.DATA_O.value)
        await ClockCycles(dut.SCLK, 2, True)
        dut._id(TermSignal, extended=False).value = 0
        await RisingEdge(dut.AS_O_)
        dut._id(TermSignal, extended=False).value = 1
        if dut.INCNO.value == 1:
            dut.ADDR.value = dut.ADDR.value ^ 1
        await RisingEdge(dut.SCLK)
    are_equal = arrays_are_equal(dut, result, TEST_DATA_ARRAY_LONG)
    dut._log.info("Finished transferring FIFO to Memory")
    #assert are_equal, "TEST_DATA_ARRAY_LONG != result"
   
    

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
    dut._id("_BR", extended=False).value = 1
    dut._id("_RST", extended=False).value = 1
    dut._id("_BG", extended=False).value = 1
    dut._id("_DREQ", extended=False).value = 1
    dut._id("_STERM", extended=False).value = 1
    dut._id("_DREQ", extended=False).value = 1
    dut._id("_BGACK_IO", extended=False).value = 1
    dut._id("_BERR", extended=False).value = 1
    dut._id("_DSACK_I", extended=False).value = 3
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
    await write_data(dut, SCSI_REG_ADR1, SCSI_TEST_DATA1)
    assert dut._id("_CSS", extended=False).value == 0 , "_CSS not asserted when writing to SCSI IC"
    #assert dut._id("_IOW", extended=False).value == 0 , "_IOW not asserted when writing to SCSI IC"
    assert dut.PDATA_O.value == SCSI_TEST_DATA5 , "PDATA_O not returning expected data value"
    await RisingEdge(dut._id("_CSS", extended=False))
    
    #2 Test write to SCSI 
    await write_data(dut, SCSI_REG_ADR2, SCSI_TEST_DATA1)
    assert dut._id("_CSS", extended=False).value == 0 , "_CSS not asserted when writing to SCSI IC"
    #assert dut._id("_IOW", extended=False).value == 0 , "_IOW not asserted when writing to SCSI IC"
    assert dut.PDATA_O.value == SCSI_TEST_DATA5 , "PDATA_O not returning expected data value"
    await RisingEdge(dut._id("_CSS", extended=False))
    
    #2 Test write to SCSI 
    await write_data(dut, SCSI_REG_ADR3, SCSI_TEST_DATA1)
    assert dut._id("_CSS", extended=False).value == 0 , "_CSS not asserted when writing to SCSI IC"
    #assert dut._id("_IOW", extended=False).value == 0 , "_IOW not asserted when writing to SCSI IC"
    assert dut.PDATA_O.value == SCSI_TEST_DATA2 , "PDATA_O not returning expected data value"
    await RisingEdge(dut._id("_CSS", extended=False))
    
    #2 Test write to SCSI 
    await write_data(dut, SCSI_REG_ADR4, SCSI_TEST_DATA1)
    assert dut._id("_CSS", extended=False).value == 0 , "_CSS not asserted when writing to SCSI IC"
    #assert dut._id("_IOW", extended=False).value == 0 , "_IOW not asserted when writing to SCSI IC"
    assert dut.PDATA_O.value == SCSI_TEST_DATA2 , "PDATA_O not returning expected data value"
    await RisingEdge(dut._id("_CSS", extended=False))
    
   
    #3 Test read from scsi
    dut.PDATA_I.value = SCSI_TEST_DATA3
    data = await read_data(dut, SCSI_REG_ADR1)
    assert data == SCSI_TEST_DATA4, "Error reading scsi data"
    assert dut._id("_CSS", extended=False).value == 0 , "_CSS not asserted when reading from SCSI IC"
    assert dut._id("_IOR", extended=False).value == 0 , "_IOR not asserted when reading from SCSI IC"
    await RisingEdge(dut._id("_CSS", extended=False))
    await RisingEdge(dut._id("_IOR", extended=False))
    dut.PDATA_I.value = 0x00
    
    #3 Test read from scsi
    dut.PDATA_I.value = SCSI_TEST_DATA3
    data = await read_data(dut, SCSI_REG_ADR2)
    assert data == SCSI_TEST_DATA4, "Error reading scsi data"
    assert dut._id("_CSS", extended=False).value == 0 , "_CSS not asserted when reading from SCSI IC"
    assert dut._id("_IOR", extended=False).value == 0 , "_IOR not asserted when reading from SCSI IC"
    await RisingEdge(dut._id("_CSS", extended=False))
    await RisingEdge(dut._id("_IOR", extended=False))
    dut.PDATA_I.value = 0x00
    
    #3 Test read from scsi
    dut.PDATA_I.value = SCSI_TEST_DATA3
    data = await read_data(dut, SCSI_REG_ADR3)
    assert data == SCSI_TEST_DATA4, "Error reading scsi data"
    assert dut._id("_CSS", extended=False).value == 0 , "_CSS not asserted when reading from SCSI IC"
    assert dut._id("_IOR", extended=False).value == 0 , "_IOR not asserted when reading from SCSI IC"
    await RisingEdge(dut._id("_CSS", extended=False))
    await RisingEdge(dut._id("_IOR", extended=False))
    dut.PDATA_I.value = 0x00
    
    #3 Test read from scsi
    dut.PDATA_I.value = SCSI_TEST_DATA3
    data = await read_data(dut, SCSI_REG_ADR4)
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
    
    #6a Test VERRSION register
    data = await read_data(dut, VERSION_REG_ADR)
    assert data == REV_STR, 'Version Register not returning expected data'
    
    #7 Test DMA READ (from scsi to memory) 32 bit sterm cycle
    await reset_dut(dut._id("_RST", extended=False), 40)
    #Setup DMA Direction to Read from SCSI write to Memory
    await write_data(dut, CONTR_REG_ADR, (CONTR_DMA_READ | CONTR_INTENA))
    #Set Destination address
    await write_data(dut, RAMSEY_ACR_REG_ADR, 0x00000000)
    dut.ADDR.value = 0x00000000
    #start DMA
    await read_data(dut, ST_DMA_STROBE_ADR)
           
    await FillFIFOFromSCSI(dut, 0x0001)
    await wait_for_bus_grant(dut)
    await XferFIFO2Mem(dut, "_STERM")
    await wait_for_bus_release(dut)
    
    dut.AS_I_.value = 1
    dut.DS_I_.value = 1
    dut.R_W.value = 1
    #stop DMA
    await read_data(dut, SP_DMA_STROBE_ADR)
    #Flush
    await read_data(dut, FLUSH_STROBE_ADR)
    
    #8 Test DMA READ (from scsi to memory) 16 bit DSACK1 cycle
    await reset_dut(dut._id("_RST", extended=False), 40)
    #Setup DMA Direction to Read from SCSI write to Memory
    await write_data(dut, CONTR_REG_ADR, (CONTR_DMA_READ | CONTR_INTENA))
    #Set Destination address
    await write_data(dut, RAMSEY_ACR_REG_ADR, 0x00000000)
    dut.ADDR.value = 0x00000000
    #start DMA
    await read_data(dut, ST_DMA_STROBE_ADR)
    #Perform DMA Xfer
    await FillFIFOFromSCSI(dut, 0x0021)
    await wait_for_bus_grant(dut)
    await XferFIFO2Mem(dut, "DSK1_IN_")
    await wait_for_bus_release(dut)
    
    dut.AS_I_.value = 1
    dut.DS_I_.value = 1
    dut.R_W.value = 1
    #stop DMA
    await read_data(dut, SP_DMA_STROBE_ADR)
    #Flush
    await read_data(dut, FLUSH_STROBE_ADR)
    
    #8 Test DMA READ (from scsi to memory) 16 bit DSACK1 cycle
    await reset_dut(dut._id("_RST", extended=False), 40)
    #Setup DMA Direction to Read from SCSI write to Memory
    await write_data(dut, CONTR_REG_ADR, (CONTR_DMA_READ | CONTR_INTENA))
    #Set Destination address
    await write_data(dut, RAMSEY_ACR_REG_ADR, 0x02000000)
    dut.ADDR.value = 0x00000000
    #start DMA
    await read_data(dut, ST_DMA_STROBE_ADR)
    #Perform DMA Xfer
    await FillFIFOFromSCSI(dut, 0x0021)
    await wait_for_bus_grant(dut)
    await XferFIFO2Mem(dut, "DSK1_IN_")
    await wait_for_bus_release(dut)
    
    dut.AS_I_.value = 1
    dut.DS_I_.value = 1
    dut.R_W.value = 1
    #stop DMA
    await read_data(dut, SP_DMA_STROBE_ADR)
    #Flush
    await read_data(dut, FLUSH_STROBE_ADR)
    
    
    #9 Test DMA READ (from scsi to memory) 32 bit DSACK cycle
    await reset_dut(dut._id("_RST", extended=False), 40)
    #Setup DMA Direction to Read from SCSI write to Memory
    await write_data(dut, CONTR_REG_ADR, (CONTR_DMA_READ | CONTR_INTENA))
    #Set Destination address
    await write_data(dut, RAMSEY_ACR_REG_ADR, 0x00000000)
    dut.ADDR.value = 0x00000000
    #start DMA
    await read_data(dut, ST_DMA_STROBE_ADR)
    #Perform DMA Xfer
    await FillFIFOFromSCSI(dut, 0x0031)
    await wait_for_bus_grant(dut)
    while (dut.FIFOEMPTY == 0):
        await FallingEdge(dut.AS_O_)
        await ClockCycles(dut.SCLK, 2, True)
        dut._id("_DSACK_I", extended=False).value = 0
        await RisingEdge(dut.AS_O_)
        dut._id("_DSACK_I", extended=False).value = 3
        await RisingEdge(dut.SCLK)
    await wait_for_bus_release(dut)
    
    dut.AS_I_.value = 1
    dut.DS_I_.value = 1
    dut.R_W.value = 1
    #stop DMA
    await read_data(dut, SP_DMA_STROBE_ADR)
    
    
    
    #9a Test DMA READ (from scsi to memory) 32 bit sterm cycle with flush
    #await reset_dut(dut._id("_RST", extended=False), 40)
    #Setup DMA Direction to Read from SCSI write to Memory
    #await write_data(dut, CONTR_REG_ADR, (CONTR_DMA_READ | CONTR_INTENA))
    #Set Destination address
    #await write_data(dut, RAMSEY_ACR_REG_ADR, 0x00000000)
    #dut.ADDR.value = 0x00000000
    #start DMA
    #await read_data(dut, ST_DMA_STROBE_ADR)
           
    #dut._log.info("Started Filling FIFO From SCSI")
    #i = 0
    #load fifo from scsci
    #while (i <= 14):
    #    dut._id("_DREQ", extended=False).value = 0
    #    dut.PDATA_I.value = TEST_DATA_ARRAY_BYTE[i]
    #    await FallingEdge(dut._id("_DACK", extended=False))
    #    await FallingEdge(dut._id("_IOR", extended=False))
    #    dut._log.info("loaded FIFO with value %#x from SCSI", dut.PDATA_I.value)
    #    dut._id("_DREQ", extended=False).value = 1
    #    await RisingEdge(dut._id("_DACK", extended=False))
    #    await ClockCycles(dut.SCLK, 1, True)
    #    await RisingEdge(dut.SCLK)
    #    i += 1
    #dut.PDATA_I.value = 0
    #dut._log.info("Finished Filling FIFO From SCSI")
    #Flush
    #await read_data(dut, FLUSH_STROBE_ADR)
    
    #await wait_for_bus_grant(dut)
    #await XferFIFO2Mem(dut, "_STERM")
    #await wait_for_bus_release(dut)
    
    #dut.AS_I_.value = 1
    #dut.DS_I_.value = 1
    #dut.R_W.value = 1
    #stop DMA
    #await read_data(dut, SP_DMA_STROBE_ADR)
    
    #10 Test DMA WRITE (from memory to SCSI) 32 bit sterm cycle
    await reset_dut(dut._id("_RST", extended=False), 40)
    #Setup DMA Direction to Read from SCSI write to Memory
    await write_data(dut, CONTR_REG_ADR, (CONTR_DMA_WRITE | CONTR_INTENA))
    #Set Destination address
    await write_data(dut, RAMSEY_ACR_REG_ADR, 0x00000000)
    dut.ADDR.value = 0x00000000
    #start DMA
    await read_data(dut, ST_DMA_STROBE_ADR)
    
    dut._id("_DREQ", extended=False).value = 0
    f2sTask = cocotb.start_soon(f2s(dut))
    await wait_for_bus_grant(dut)
    await FillFIFOFromMem(dut, 0x11121314, "_STERM")
    await wait_for_bus_release(dut)    
    await f2sTask
    
    dut._id("_DREQ", extended=False).value = 0
    f2sTask = cocotb.start_soon(f2s(dut))
    await wait_for_bus_grant(dut)
    await FillFIFOFromMem(dut, 0x11121314, "_STERM")
    await wait_for_bus_release(dut)    
    await f2sTask
    
    dut.AS_I_.value = 1
    dut.DS_I_.value = 1
    dut.R_W.value = 1
    #stop DMA
    await read_data(dut, SP_DMA_STROBE_ADR)
    #Flush
    await read_data(dut, FLUSH_STROBE_ADR)
    
   


