# cocotb_resdmac.py

import random
import array as arr
import json

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Edge, Timer, ClockCycles, with_timeout, First
from cocotb.types import LogicArray
from cocotb.wavedrom import Wavedrom, trace

WTC_REG_ADR = 0x01
VERSION_REG_ADR = 0x08
DSP_REG_ADR =(0x5c >> 0x2)
FLASH_ADDR_ADR = (0x24 >> 0x2)
FLASH_DATA_ADR = (0x28 >> 0x2)

SCSI_REG_ADR1 = 0x10
SCSI_REG_ADR2 = 0x11
SCSI_REG_ADR3 = 0x12
SCSI_REG_ADR4 = 0x13

SSPB_DATA_ADR = 0x16
CONTR_REG_ADR = 0x02
ISR_REG_ADR = 0x07 
RAMSEY_ACR_REG_ADR = 0x03
ST_DMA_STROBE_ADR  = 0x04
SP_DMA_STROBE_ADR  = 0x0f
FLUSH_STROBE_ADR   = 0x05

TEST_PATTERN1 = 0xAAAAAAAA
TEST_PATTERN2 = 0x55555555
TEST_PATTERN3 = 0x555555
SCSI_TEST_DATA1 = 0x005500AA
SCSI_TEST_DATA2 = 0x5555
SCSI_TEST_DATA5 = 0xAAAA

SCSI_TEST_DATA3 = 0x00AA
SCSI_TEST_DATA4 = 0x00AA00AA

REV_STR = int("v9.9".encode("utf-8").hex(), base= 16)

CONTR_DMA_READ = 0x00
CONTR_DMA_WRITE = 0x02
CONTR_INTENA = 0x04
CONTR_INTDIS = 0x00
CONTR_PRESET = 0x10
CONTR_DMAENA = 0x100

TEST_DATA_ARRAY_LONG1 = arr.array('L', [0x1a1b1c1d, 0x2a2b2c2d, 0x3a3b3c3d, 0x4a4b4c4d, 0x5a5b5c5d, 0x6a6b6c6d, 0x7a7b7c7d, 0x8a8b8c8d])
TEST_DATA_ARRAY_LONG2 = arr.array('L', [0x1a1b1c1d, 0x2a2b2c2d, 0x3a3b3c3d, 0x4a4b4c4d, 0x5a5b5c5d, 0x6a6b6c6d, 0x7a7b7c7d, 0x8a8b8c8d,0x1a1b1c1d, 0x2a2b2c2d, 0x3a3b3c3d, 0x4a4b4c4d, 0x5a5b5c5d, 0x6a6b6c6d, 0x7a7b7c7d, 0x8a8b8c8d,0x1a1b1c1d, 0x2a2b2c2d, 0x3a3b3c3d, 0x4a4b4c4d, 0x5a5b5c5d, 0x6a6b6c6d, 0x7a7b7c7d, 0x8a8b8c8d,0x1a1b1c1d, 0x2a2b2c2d, 0x3a3b3c3d, 0x4a4b4c4d, 0x5a5b5c5d, 0x6a6b6c6d, 0x7a7b7c7d, 0x8a8b8c8d])

TEST_DATA_ARRAY_BYTE1 = arr.array('B', [0x1a,0x1b,0x1c,0x1d, 0x2a,0x2b,0x2c,0x2d, 0x3a,0x3b,0x3c,0x3d, 0x4a,0x4b,0x4c,0x4d, 0x5a,0x5b,0x5c,0x5d, 0x6a,0x6b,0x6c,0x6d, 0x7a,0x7b,0x7c,0x7d, 0x8a,0x8b,0x8c,0x8d])
TEST_DATA_ARRAY_BYTE2 = arr.array('B', [0x1a,0x1b,0x1c,0x1d, 0x2a,0x2b,0x2c,0x2d, 0x3a,0x3b,0x3c,0x3d, 0x4a,0x4b,0x4c,0x4d, 0x5a,0x5b,0x5c,0x5d, 0x6a,0x6b,0x6c,0x6d, 0x7a,0x7b,0x7c,0x7d, 0x8a,0x8b,0x8c,0x8d,0xff,0xfe,0xfd,0xfc])
TEST_DATA_ARRAY_BYTE3 = arr.array('B', [0x1a,0x1b,0x1c,0x1d, 0x2a,0x2b,0x2c,0x2d, 0x3a,0x3b,0x3c,0x3d, 0x4a,0x4b,0x4c,0x4d, 0x5a,0x5b,0x5c,0x5d, 0x6a,0x6b,0x6c,0x6d, 0x7a,0x7b,0x7c,0x7d, 0x8a,0x8b,0x8c,0x8d,0x1a,0x1b,0x1c,0x1d, 0x2a,0x2b,0x2c,0x2d, 0x3a,0x3b,0x3c,0x3d, 0x4a,0x4b,0x4c,0x4d, 0x5a,0x5b,0x5c,0x5d, 0x6a,0x6b,0x6c,0x6d, 0x7a,0x7b,0x7c,0x7d, 0x8a,0x8b,0x8c,0x8d,0x1a,0x1b,0x1c,0x1d, 0x2a,0x2b,0x2c,0x2d, 0x3a,0x3b,0x3c,0x3d, 0x4a,0x4b,0x4c,0x4d, 0x5a,0x5b,0x5c,0x5d, 0x6a,0x6b,0x6c,0x6d, 0x7a,0x7b,0x7c,0x7d, 0x8a,0x8b,0x8c,0x8d,0x1a,0x1b,0x1c,0x1d, 0x2a,0x2b,0x2c,0x2d, 0x3a,0x3b,0x3c,0x3d, 0x4a,0x4b,0x4c,0x4d, 0x5a,0x5b,0x5c,0x5d, 0x6a,0x6b,0x6c,0x6d, 0x7a,0x7b,0x7c,0x7d, 0x8a,0x8b,0x8c,0x8d])

async def reset_dut(reset_n, duration_ns):
    await Timer(duration_ns, units="ns")
    reset_n.value = 0
    await Timer(duration_ns, units="ns")
    reset_n.value = 1
    await Timer(duration_ns, units="ns")
    reset_n._log.debug("Reset complete")

async def read_data(dut, addr, *args, header="", footer="",filename=""):
    await wait_for_bus_release(dut)
    await ClockCycles(dut.SCLK, 4, True)
    if (dut._id("_BGACK_IO", extended=False) == 0):
        dut._log.info("waiting _BGACK_IO rising edge")
        await RisingEdge(dut._id("_BGACK_IO", extended=False))
    #Setup wavedrom trace
    with trace(dut._id("_CS", extended=False),dut.ADDR, dut.DATA_O, dut.R_W, dut.AS_I_, dut.DS_I_, dut._id("_DSACK_IO", extended=False), *args, clk=dut.SCLK) as waves:
        dut.R_W.value = 1
        dut.ADDR.value = 0
        dut._id("_CS", extended=False).value = 1
        await ClockCycles(dut.SCLK, 2, True)
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
        await ClockCycles(dut.SCLK, 4, True)
        datas = waves.dumpj(header=header, footer=footer)
        jdata = json.loads(datas)
        for x, i in enumerate(jdata['signal']):
            if 'data' in i:
                result = convertDecToHex(i['data'])
                jdata['signal'][x]['data'] = result
        if (filename != ""):
            with open(filename, 'w') as json_file:
                json.dump(jdata,json_file, indent=4, sort_keys=False)
        dut._log.info("Read value %#x from addr %#x", data, addr)
        return data

async def write_data(dut, addr, data, *args, header="", footer="",filename=""):
    await wait_for_bus_release(dut)
    if (dut._id("_BGACK_IO", extended=False) == 0):
        dut._log.info("waiting _BGACK_IO rising edge")
        await RisingEdge(dut._id("_BGACK_IO", extended=False))

    dut._log.info("Write value %#x to addr %#x", data, addr)
    #Setup wavedrom trace
    with trace(dut._id("_CS", extended=False),dut.ADDR, dut.DATA_I, dut.R_W, dut.AS_I_, dut.DS_I_, dut._id("_DSACK_IO", extended=False),*args, clk=dut.SCLK) as waves:
        #Set inital values
        dut.R_W.value = 1
        dut.ADDR.value = 0
        dut.DATA_I.value = 0xffffffff
        dut._id("_CS", extended=False).value = 1
        await ClockCycles(dut.SCLK, 2, True)
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
        dut.DATA_I.value =0xffffffff
        dut._id("_CS", extended=False).value = 1
        await ClockCycles(dut.SCLK, 2, True)
        #Write wavedrom to file
        datas = waves.dumpj(header=header, footer=footer)
        data = json.loads(datas)
        for x, i in enumerate(data['signal']):
            if 'data' in i:
                result = convertDecToHex(i['data'])
                data['signal'][x]['data'] = result
        if (filename != ""):
            with open(filename, 'w') as json_file:
                json.dump(data,json_file, indent=4, sort_keys=False)

async def FillFIFOFromSCSI(dut, data):
    dut._log.info("Started Filling FIFO From SCSI")
    for item in data:
        dut._id("_DREQ", extended=False).value = 0
        dut.PDATA_I.value = item
        if (dut._id("_DACK", extended=False) == 1):
            await FallingEdge(dut._id("_DACK", extended=False))
        if (dut._id("_IOR", extended=False) == 1):
            await FallingEdge(dut._id("_IOR", extended=False))
        dut._log.info("loaded FIFO with value %#x from SCSI", dut.PDATA_I.value)
        dut._id("_DREQ", extended=False).value = 1
        if (dut._id("_DACK", extended=False) == 0):
            await RisingEdge(dut._id("_DACK", extended=False))
        await ClockCycles(dut.SCLK, 1, True)
        await RisingEdge(dut.SCLK)
    dut.PDATA_I.value = 0
    dut._log.info("Finished Filling FIFO From SCSI")

async def FillFIFOFromMem(dut, data, TermSignal):
    dut._log.info("Started Filling FIFO From Memory")
    #load fifo from memory
    for item in data:
        if (dut.FIFOFULL == 1):
            dut._log.info("waiting for fifofull == 0")
            await FallingEdge(dut.FIFOFULL)
            await ClockCycles(dut.SCLK, 2, True)
        while (await wait_for_bus_grant(dut) == False):
            dut._log.info("waiting for bus grant")
            await ClockCycles(dut.SCLK, 1, True)
        
        if (dut.AS_O_ == 1):
            await FallingEdge(dut.AS_O_)
            dut.DATA_I.value = item
            await ClockCycles(dut.SCLK, 1, True)
            await RisingEdge(dut.SCLK)
            dut._id(TermSignal, extended=False).value = 0
            dut._log.info("loaded FIFO with value %#x from memory", dut.DATA_I.value)
            if (dut.AS_O_ == 0):
                await RisingEdge(dut.AS_O_)
            dut._id(TermSignal, extended=False).value = 1
            await RisingEdge(dut.SCLK)
            if (TermSignal == "DSK1_IN_"):
                if (dut.AS_O_ == 1):
                    await FallingEdge(dut.AS_O_)
                    dut.DATA_I.value = ((item & 0x0000ffff) << 16) + (item & 0x0000ffff)
                    await ClockCycles(dut.SCLK, 1, True)
                    await RisingEdge(dut.SCLK)
                    dut._id(TermSignal, extended=False).value = 0
                    dut._log.info("loaded FIFO with value %#x from memory", dut.DATA_I.value)
                    if (dut.AS_O_ == 0):
                        await RisingEdge(dut.AS_O_)
                    dut._id(TermSignal, extended=False).value = 1
                    await RisingEdge(dut.SCLK)
                    
    if (dut.FIFOFULL == 0 and dut._id("_BGACK_IO", extended=False) == 0):
        while (dut.FIFOFULL == 0):
            if (dut.AS_O_ == 1):
                await FallingEdge(dut.AS_O_)
                dut.DATA_I.value = 0xaabbccdd
                await ClockCycles(dut.SCLK, 1, True)
                await RisingEdge(dut.SCLK)
                dut._id(TermSignal, extended=False).value = 0
                dut._log.info("loaded FIFO with value %#x from memory", dut.DATA_I.value)
                if (dut.AS_O_ == 0):
                    await RisingEdge(dut.AS_O_)
                dut._id(TermSignal, extended=False).value = 1
                await RisingEdge(dut.SCLK)
                if (TermSignal == "DSK1_IN_"):
                    if (dut.AS_O_ == 1):
                        await FallingEdge(dut.AS_O_)
                        dut.DATA_I.value = ((0xaabbccdd & 0x0000ffff) << 16) + (0xaabbccdd & 0x0000ffff)
                        await ClockCycles(dut.SCLK, 1, True)
                        await RisingEdge(dut.SCLK)
                        dut._id(TermSignal, extended=False).value = 0
                        dut._log.info("loaded FIFO with value %#x from memory", dut.DATA_I.value)
                        if (dut.AS_O_ == 0):
                            await RisingEdge(dut.AS_O_)
                        dut._id(TermSignal, extended=False).value = 1
                        await RisingEdge(dut.SCLK)
        await wait_for_bus_release(dut)
        
    dut.DATA_I.value =0x0
    dut._log.info("Finished Filling FIFO From Memory")

async def XferFIFO2SCSI(dut,bytes):
    dut._id("_DREQ", extended=False).value = 0
    dut._log.info("Started transferring FIFO to SCSI")    

    i = 0
    while i < bytes:
        if (dut._id("_DACK", extended=False) == 1):
            await FallingEdge(dut._id("_DACK", extended=False))
        if (dut._id("_IOW", extended=False) == 1):
            await FallingEdge(dut._id("_IOW", extended=False))
        await ClockCycles(dut.SCLK, 1, True)
        dut._log.info("Transfering value %#x from FIFO to SCSI", dut.PDATA_O.value)
        dut._id("_DREQ", extended=False).value = 1
        if (dut._id("_DACK", extended=False) == 0):
            await RisingEdge(dut._id("_DACK", extended=False))
        await ClockCycles(dut.SCLK, 1, True)
        await RisingEdge(dut.SCLK)
        dut._id("_DREQ", extended=False).value = 0
        await ClockCycles(dut.SCLK, 1, True)
        i += 1
    dut._id("_DREQ", extended=False).value = 1
    dut._log.info("Finished transferring FIFO to SCSI")

async def XferFIFO2Mem(dut,TermSignal):
    while (dut.DMAENA == 1):
        if (await wait_for_bus_grant(dut)):
            dut._log.info("Started transferring FIFO to Memory")
            #result = arr.array('L')
            while (dut.FIFOEMPTY == 0 or dut.FLUSHFIFO == 1):
                if (dut.AS_O_ == 1):
                    await FallingEdge(dut.AS_O_)
                #result.append(dut.DATA_O.value)
                dut._log.info("Transfering value %#x from FIFO to Memory", dut.DATA_O.value)
                await ClockCycles(dut.SCLK, 2, True)
                dut._id(TermSignal, extended=False).value = 0
                if (dut.AS_O_ == 0):
                    await RisingEdge(dut.AS_O_)
                dut._id(TermSignal, extended=False).value = 1
                await RisingEdge(dut.SCLK)
            await wait_for_bus_release(dut)
    #are_equal = arrays_are_equal(dut, result, TEST_DATA_ARRAY_LONG)
    dut._log.info("Finished transferring FIFO to Memory")
    #assert are_equal, "TEST_DATA_ARRAY_LONG != result"

async def wait_for_bus_grant(dut):
    try:
        if (dut._id("_BGACK_IO", extended=False) == 1):
            dut._log.info("wait_for_bus_grant")
            if (dut._id("_BR", extended=False) == 1):
                dut._log.info("waiting BR falling edge")
                await  with_timeout(FallingEdge(dut._id("_BR", extended=False)),1000,'ns')
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
        return True
    except cocotb.result.SimTimeoutError:
        dut._log.debug("timeout: waiting_for_bus_grant")
        return False

async def wait_for_bus_release(dut):
    dut._log.info("wait_for_bus_release")
    if (dut._id("_BGACK_IO", extended=False) == 0):
        dut._log.info("waiting _BGACK_IO rising edge")
        await RisingEdge(dut._id("_BGACK_IO", extended=False))
        await RisingEdge(dut.SCLK)
    await ClockCycles(dut.SCLK, 2, True)
    
async def wait_for_FIFO_empty(dut):
    dut._log.info("wait_for_FIFO_empty")
    data = 0
    while (data & 1 != 1):
        data = await read_data(dut, ISR_REG_ADR)
        dut._log.info("FIFO_empty = %#x", data)
    await RisingEdge(dut.SCLK)


def convertDecToHex(decData):
    # split dec string
    el = decData.split()
    # hexify it
    el = list(map(lambda x: hex(int(x)), el))
    # back to string
    s = ' '.join(str(x) for x in el)
    return s

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

async def DriveAddrBusForDMA(dut, addr):
    
    address = addr
    if (dut._id("_DMAEN", extended=False) == 1):
        #dut._log.info("waiting _DMAEN falling edge")
        await FallingEdge(dut._id("_DMAEN", extended=False))
    dut.ADDR.value = ((address & 0x7c) >> 2)

    while (dut._id("_DMAEN", extended=False) == 0):
        IncAmount = 2
        if (dut.AS_I_.value == 1):
            #dut._log.info("waiting AS falling edge")
            await FallingEdge(dut._id("AS_I_", extended=False))
        
        STERM = FallingEdge(dut._id("_STERM", extended=False))
        DSACK0 = FallingEdge(dut.DSK0_IN_)
        DSACK1 = FallingEdge(dut.DSK1_IN_)
        t_ret = await First(STERM, DSACK0, DSACK1)
        
        if (t_ret == STERM or t_ret == DSACK0):
            IncAmount = 4
            
        if (dut.AS_I_.value == 0):
            #dut._log.info("waiting AS rising edge")
            await RisingEdge(dut._id("AS_I_", extended=False))
            address += IncAmount
            dut.ADDR.value = ((address & 0x7c) >> 2)

async def DMA_READ(dut, data, addr, termsig):
    with trace(dut.ADDR, dut.DATA_O, dut.R_W, dut.AS_I_, dut.DS_I_, dut._id("_STERM", extended=False),dut.DSK0_IN_,dut.DSK1_IN_,dut._id("_BR", extended=False),dut._id("_BG", extended=False),dut._id("_BGACK_IO", extended=False),dut._id("_DREQ", extended=False),dut._id("_DACK", extended=False),dut._id("_IOR", extended=False),dut.PDATA_I, clk=dut.SCLK) as waves:
        dut._log.info("Starting DMA read to addr %#x", addr)
        await reset_dut(dut._id("_RST", extended=False), 40)
        DrvAddr = cocotb.start_soon(DriveAddrBusForDMA(dut, addr))
        #Setup DMA Direction to Read from SCSI write to Memory
        await write_data(dut, CONTR_REG_ADR, (CONTR_DMA_READ | CONTR_INTENA))
        #Set Destination address
        await write_data(dut, RAMSEY_ACR_REG_ADR, addr)
        #start DMA
        await read_data(dut, ST_DMA_STROBE_ADR)
        S2F = cocotb.start_soon(FillFIFOFromSCSI(dut, data))
        F2M = cocotb.start_soon(XferFIFO2Mem(dut, termsig))
        #wait for scsi to fifo data transfer to finish
        await S2F
        #Flush any data remaining in the fifo to memory
        await read_data(dut, FLUSH_STROBE_ADR)
        await wait_for_FIFO_empty(dut)
        #stop DMA
        await read_data(dut, SP_DMA_STROBE_ADR)
        #wait for any DMA cycles transfering from fifo to memory
        await F2M
        await DrvAddr
        datas = waves.dumpj(header="DMA READ", footer="")
        jdata = json.loads(datas)
        for x, i in enumerate(jdata['signal']):
            if 'data' in i:
                result = convertDecToHex(i['data'])
                jdata['signal'][x]['data'] = result
        with open("../Docs/TimingDiagrams/DMA_READ.json", 'w') as json_file:
            json.dump(jdata,json_file, indent=4, sort_keys=False)

async def DMA_WRITE(dut, data, addr, termsig):
    dut._log.info("Starting DMA write to addr %#x", addr)
    await reset_dut(dut._id("_RST", extended=False), 40)
    DrvAddr = cocotb.start_soon(DriveAddrBusForDMA(dut, addr))
    #Setup DMA Direction to Read from SCSI write to Memory
    await write_data(dut, CONTR_REG_ADR, (CONTR_DMA_WRITE | CONTR_INTENA))
    #Set Destination address
    await write_data(dut, RAMSEY_ACR_REG_ADR, addr)
    #start DMA
    await read_data(dut, ST_DMA_STROBE_ADR)
    datalengthbytes = len(data)*4
    M2F = cocotb.start_soon(FillFIFOFromMem(dut, data, termsig))
    dut._log.info("transfering %i bytes to scsi", datalengthbytes)
    f2sTask = cocotb.start_soon(XferFIFO2SCSI(dut,datalengthbytes))
    await f2sTask
    await ClockCycles(dut.SCLK, 2, True)
    #Flush any data remaining in the fifo to memory
    await read_data(dut, FLUSH_STROBE_ADR)
    #stop DMA
    await read_data(dut, SP_DMA_STROBE_ADR)
    await M2F
    await DrvAddr

@cocotb.test()
async def RESDMAC_test(dut):
    """Test RESDMAC"""

    print(dir(dut))

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
    await write_data(dut, WTC_REG_ADR, TEST_PATTERN1, header='Write to WTC register', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/WTC_Write.json')
    data = await read_data(dut, WTC_REG_ADR, header='Read to WTC register', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/WTC_Read.json')
    assert data == 0x00, 'WTC Register not returning expected data'

    #2a Test write to SCSI
    writecycle = cocotb.start_soon(write_data(dut, SCSI_REG_ADR1, SCSI_TEST_DATA1, dut._id("_CSS", extended=False),dut._id("_IOW", extended=False), dut.PDATA_O, header='Write to WD33C93 controller', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/SCSI_WriteAddr_1.json'))
    if (dut._id("_IOW", extended=False).value == 1):
        await FallingEdge(dut._id("_IOW", extended=False))
    if (dut._id("_CSS", extended=False).value == 1):
        await FallingEdge(dut._id("_CSS", extended=False))
    await ClockCycles(dut.SCLK, 1, True)
    assert dut.PDATA_O.value == SCSI_TEST_DATA5 , "PDATA_O not returning expected data value"
    await writecycle

    #2b Test write to SCSI 
    writecycle = cocotb.start_soon(write_data(dut, SCSI_REG_ADR2, SCSI_TEST_DATA1, dut._id("_CSS", extended=False),dut._id("_IOW", extended=False), dut.PDATA_O, header='Write to WD33C93 controller', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/SCSI_WriteAddr_2.json'))
    if (dut._id("_IOW", extended=False).value == 1):
        await FallingEdge(dut._id("_IOW", extended=False))
    if (dut._id("_CSS", extended=False).value == 1):
        await FallingEdge(dut._id("_CSS", extended=False))
    await ClockCycles(dut.SCLK, 1, True)
    assert dut.PDATA_O.value == SCSI_TEST_DATA5 , "PDATA_O not returning expected data value"
    await writecycle

    #2c Test write to SCSI
    writecycle = cocotb.start_soon(write_data(dut, SCSI_REG_ADR3, SCSI_TEST_DATA1, dut._id("_CSS", extended=False),dut._id("_IOW", extended=False), dut.PDATA_O, header='Write to WD33C93 controller', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/SCSI_WriteAddr_3.json'))
    if (dut._id("_IOW", extended=False).value == 1):
        await FallingEdge(dut._id("_IOW", extended=False))
    if (dut._id("_CSS", extended=False).value == 1):
        await FallingEdge(dut._id("_CSS", extended=False))
    await ClockCycles(dut.SCLK, 1, True)
    assert dut.PDATA_O.value == SCSI_TEST_DATA2 , "PDATA_O not returning expected data value"
    await writecycle

    #2d Test write to SCSI
    writecycle = cocotb.start_soon(write_data(dut, SCSI_REG_ADR4, SCSI_TEST_DATA1, dut._id("_CSS", extended=False),dut._id("_IOW", extended=False), dut.PDATA_O, header='Write to WD33C93 controller', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/SCSI_WriteAddr_4.json'))
    if (dut._id("_IOW", extended=False).value == 1):
        await FallingEdge(dut._id("_IOW", extended=False))
    if (dut._id("_CSS", extended=False).value == 1):
        await FallingEdge(dut._id("_CSS", extended=False))
    await ClockCycles(dut.SCLK, 1, True)
    assert dut.PDATA_O.value == SCSI_TEST_DATA2 , "PDATA_O not returning expected data value"
    await writecycle

    #3a Test read from scsi
    dut.PDATA_I.value = 0x00
    readcycle = cocotb.start_soon(read_data(dut, SCSI_REG_ADR1, dut._id("_CSS", extended=False),dut._id("_IOR", extended=False), dut.PDATA_I, header='Read From WD33C93 controller', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/SCSI_ReadAddr1.json'))
    if (dut._id("_IOR", extended=False).value == 1):
        await FallingEdge(dut._id("_IOR", extended=False))
    if (dut._id("_CSS", extended=False).value == 1):
        await FallingEdge(dut._id("_CSS", extended=False))
    dut.PDATA_I.value = SCSI_TEST_DATA3
    await RisingEdge(dut.dsack_int)
    assert dut.DATA_O.value == SCSI_TEST_DATA4 , "Error reading scsi data"
    if (dut._id("_IOR", extended=False).value == 0):
        await RisingEdge(dut._id("_IOR", extended=False))
    dut.PDATA_I.value = 0x00
    data = await readcycle
    assert data == SCSI_TEST_DATA4, "Error reading scsi data"

    #3b Test read from scsi
    dut.PDATA_I.value = 0x00
    readcycle = cocotb.start_soon(read_data(dut, SCSI_REG_ADR2, dut._id("_CSS", extended=False),dut._id("_IOR", extended=False), dut.PDATA_I, header='Read From WD33C93 controller', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/SCSI_ReadAddr2.json'))
    if (dut._id("_IOR", extended=False).value == 1):
        await FallingEdge(dut._id("_IOR", extended=False))
    if (dut._id("_CSS", extended=False).value == 1):
        await FallingEdge(dut._id("_CSS", extended=False))
    dut.PDATA_I.value = SCSI_TEST_DATA3
    await RisingEdge(dut.dsack_int)
    assert dut.DATA_O.value == SCSI_TEST_DATA4 , "Error reading scsi data"
    if (dut._id("_IOR", extended=False).value == 0):
        await RisingEdge(dut._id("_IOR", extended=False))
    dut.PDATA_I.value = 0x00
    data = await readcycle
    assert data == SCSI_TEST_DATA4, "Error reading scsi data"

    #3c Test read from scsi
    dut.PDATA_I.value = 0x00
    readcycle = cocotb.start_soon(read_data(dut, SCSI_REG_ADR3, dut._id("_CSS", extended=False),dut._id("_IOR", extended=False), dut.PDATA_I, header='Read From WD33C93 controller', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/SCSI_ReadAddr3.json'))
    if (dut._id("_IOR", extended=False).value == 1):
        await FallingEdge(dut._id("_IOR", extended=False))
    if (dut._id("_CSS", extended=False).value == 1):
        await FallingEdge(dut._id("_CSS", extended=False))
    dut.PDATA_I.value = SCSI_TEST_DATA3
    await RisingEdge(dut.dsack_int)
    assert dut.DATA_O.value == SCSI_TEST_DATA4 , "Error reading scsi data"
    if (dut._id("_IOR", extended=False).value == 0):
        await RisingEdge(dut._id("_IOR", extended=False))
    dut.PDATA_I.value = 0x00
    data = await readcycle
    assert data == SCSI_TEST_DATA4, "Error reading scsi data"

    #3d Test read from scsi
    dut.PDATA_I.value = 0x00
    readcycle = cocotb.start_soon(read_data(dut, SCSI_REG_ADR4, dut._id("_CSS", extended=False),dut._id("_IOR", extended=False), dut.PDATA_I, header='Read From WD33C93 controller', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/SCSI_ReadAddr4.json'))
    if (dut._id("_IOR", extended=False).value == 1):
        await FallingEdge(dut._id("_IOR", extended=False))
    if (dut._id("_CSS", extended=False).value == 1):
        await FallingEdge(dut._id("_CSS", extended=False))
    dut.PDATA_I.value = SCSI_TEST_DATA3
    await RisingEdge(dut.dsack_int)
    assert dut.DATA_O.value == SCSI_TEST_DATA4 , "Error reading scsi data"
    if (dut._id("_IOR", extended=False).value == 0):
        await RisingEdge(dut._id("_IOR", extended=False))
    dut.PDATA_I.value = 0x00
    data = await readcycle
    assert data == SCSI_TEST_DATA4, "Error reading scsi data"

    #4 check we can reset the SCSI IC
    await write_data(dut, CONTR_REG_ADR, CONTR_PRESET, dut._id("_IOR", extended=False), dut._id("_IOW", extended=False), dut.u_registers.u_registers_cntr.CNTR_O, header='Write to CONTR REG to Reset SCSI IC', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/CONTR_1_Write.json')
    assert (dut._id("_IOR", extended=False).value == 0) and (dut._id("_IOW", extended=False).value == 0) , "PRESET did not assert _IOW and _IOR"

    #5 test SSPBDAT register
    await write_data(dut, SSPB_DATA_ADR, TEST_PATTERN1, dut.u_registers.SSPBDAT, header='Write to SSPBDAT REG', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/SSPBDAT_1_Write.json')
    data = await read_data(dut, SSPB_DATA_ADR, dut.u_registers.SSPBDAT, header='Read From SSPBDAT REG', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/SSPBDAT_1_read.json')
    assert data == TEST_PATTERN1, 'SSPBDAT Register not returning expected data'

    #6 test SSPBDAT register
    await write_data(dut, SSPB_DATA_ADR, TEST_PATTERN2, dut.u_registers.SSPBDAT, header='Write to SSPBDAT REG', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/SSPBDAT_2_Write.json')
    data = await read_data(dut, SSPB_DATA_ADR, dut.u_registers.SSPBDAT, header='Read From SSPBDAT REG', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/SSPBDAT_2_read.json')
    assert data == TEST_PATTERN2, 'SSPBDAT Register not returning expected data'

    #7 Test VERRSION register
    data = await read_data(dut, VERSION_REG_ADR, dut.u_registers.VERSION, header='Read From VERSION REG', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/VERSION_read.json')
    assert data == REV_STR, 'Version Register not returning expected data'
    
    #8 Test DSP register
    dut.u_registers.DSP_DATA.value = 0x55
    data = await read_data(dut, DSP_REG_ADR, dut.u_registers.DSP, header='Read From DSP REG', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/DSP_read.json')
    assert data == 0x55, 'DSP Register not returning expected data'
    
    #8 Test FLASH_ADDR register
    await write_data(dut, FLASH_ADDR_ADR, TEST_PATTERN3, dut.u_registers.FLASH_ADDR, header='Write to FLASH_ADDR REG', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/FLASH_ADDR_Write.json')
    data = await read_data(dut, FLASH_ADDR_ADR, dut.u_registers.FLASH_ADDR, header='Read From FLASH_ADDR REG', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/FLASH_ADDR_Read.json')
    assert data == TEST_PATTERN3, 'FLASH_ADDR_ADR Register not returning expected data'
    
    
    #8 Test FLASH_ADDR register
    await write_data(dut, FLASH_ADDR_ADR, TEST_PATTERN3, dut.u_registers.FLASH_ADDR, header='Write to FLASH_ADDR REG', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/FLASH_ADDR_Write.json')
    data = await read_data(dut, FLASH_ADDR_ADR, dut.u_registers.FLASH_ADDR, header='Read From FLASH_ADDR REG', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/FLASH_ADDR_Read.json')
    assert data == TEST_PATTERN3, 'FLASH_ADDR_ADR Register not returning expected data'
    
    await write_data(dut, FLASH_ADDR_ADR, 0x080000, dut.u_registers.FLASH_ADDR, header='Write to FLASH_ADDR REG', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/FLASH_ADDR_Write.json')
    await write_data(dut, FLASH_DATA_ADR, TEST_PATTERN1, dut.u_registers.u_registers_flash.FLASH_CONTROL, header='Write to FLASH_CONTROL', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/FLASH_CONTROL_Write.json')
    data = await read_data(dut, FLASH_DATA_ADR, dut.u_registers.u_registers_flash.FLASH_CONTROL, header='Read From FLASH_CONTROL', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/FLASH_CONTROL_Read.json')
    assert data == TEST_PATTERN1, 'FLASH_CONTROL Register not returning expected data'
    
    
    await write_data(dut, FLASH_ADDR_ADR, 0x24000, dut.u_registers.FLASH_ADDR, header='Write to FLASH_ADDR REG', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/FLASH_ADDR_Write.json')
    await write_data(dut, FLASH_DATA_ADR, TEST_PATTERN2, dut.u_registers.u_registers_flash.FLASHDATA, header='Write to FLASHDATA', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/FLASHDATA_Write.json')
    data = await read_data(dut, FLASH_DATA_ADR, dut.u_registers.u_registers_flash.FLASHDATA, header='Read From FLASHDATA', footer='SCLK:25Mhz (T:40ns)', filename='../Docs/TimingDiagrams/FLASHDATA_Read.json')
    assert data == TEST_PATTERN2, 'FLASHDATA Register not returning expected data'
    
    #9a Test DMA READ (from scsi to memory) 32 bit sterm cycle
    await DMA_READ(dut, TEST_DATA_ARRAY_BYTE1, 0x00000000, "_STERM")
    #9b Test DMA READ (from scsi to memory) 32 bit sterm cycle with left over bytes that need flushing from the fifo
    await DMA_READ(dut, TEST_DATA_ARRAY_BYTE2, 0x00000000, "_STERM")
    #9c Test DMA READ (from scsi to memory) 32 bit sterm cycle with more than one DMA cycle
        #await DMA_READ(dut, TEST_DATA_ARRAY_BYTE3, 0x00000000, "_STERM")
    #9d Test DMA READ (from scsi to memory) 32 bit DSACK0 cycle
        #await DMA_READ(dut, TEST_DATA_ARRAY_BYTE1, 0x00000000, "DSK0_IN_")
    #9e Test DMA READ (from scsi to memory) 16 bit DSACK1 cycle
    await DMA_READ(dut, TEST_DATA_ARRAY_BYTE1, 0x00000000, "DSK1_IN_")
    #9f Test DMA READ (from scsi to memory) 16 bit DSACK1 cycle
    await DMA_READ(dut, TEST_DATA_ARRAY_BYTE3, 0x00000000, "DSK1_IN_")
    #9g Test DMA READ (from scsi to memory) 32 bit unaligend 
    await DMA_READ(dut, TEST_DATA_ARRAY_BYTE1, 0x02000000, "_STERM")
    await DMA_READ(dut, TEST_DATA_ARRAY_BYTE2, 0x02000000, "_STERM")
    
    #10a Test DMA WRITE (from memory to SCSI) 32 bit sterm cycle
    await DMA_WRITE(dut, TEST_DATA_ARRAY_LONG1, 0x00000000, "_STERM")
    #10b Test DMA WRITE (from memory to SCSI) 32 bit sterm cycle unaligned
    await DMA_WRITE(dut, TEST_DATA_ARRAY_LONG1, 0x02000000, "_STERM")
    #10c Test DMA WRITE (from memory to SCSI) 32 bit sterm cycle with more than one DMA cycle
    await DMA_WRITE(dut, TEST_DATA_ARRAY_LONG2, 0x00000000, "_STERM")
    #10d Test DMA WRITE (from memory to SCSI) 16 bit DSACK1 cycle
    await DMA_WRITE(dut, TEST_DATA_ARRAY_LONG1, 0x00000000, "DSK1_IN_")
    #10e Test DMA WRITE (from memory to SCSI) 16 bit DSACK1 cycle
    await DMA_WRITE(dut, TEST_DATA_ARRAY_LONG2, 0x00000000, "DSK1_IN_")

