"""ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/"""

# cocotb_fsm_cpu.py

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Edge, FallingEdge, RisingEdge, Timer, ClockCycles
from cocotb.types import LogicArray

async def reset_dut(reset_n, duration_ns):
    await Timer(duration_ns, units="ns")
    reset_n.value = 0
    await Timer(duration_ns, units="ns")
    reset_n.value = 1
    await Timer(duration_ns, units="ns")

async def monitor_dut(dut):
    while True:
        await Edge(dut.NEXT_STATE)
        # Check if the value has changed
        #dut._log.info(f"State will change from {dut.STATE.value} to {dut.NEXT_STATE.value} on next clock cycle")
        #dut._log.info("State will change from %#x to %#x on next clock cycle", dut.STATE.value, dut.NEXT_STATE.value)
        
async def check_output_values(dut):
    await ClockCycles(dut.CLK, 1, True)
    inputs = "%i|%i|%i|%i|%i|%i|%i|%i|%i|%i|%i|%i|%i|%i|%i|%i|%i" % (dut.A1.value,dut.BGRANT_.value,dut.BOEQ3.value,dut.CYCLEDONE.value,dut.DMADIR.value,dut.DMAENA.value,dut.DREQ_.value,dut.DSACK.value,dut.DSACK0_.value,dut.DSACK1_.value,dut.FIFOEMPTY.value,dut.FIFOFULL.value,dut.FLUSHFIFO.value,dut.LASTWORD.value, dut.RDFIFO_.value, dut.RIFIFO_.value, dut.STERM_.value)
    outputs = "%i|%i|%i|%i|%i|%i|%i|%i|%i|%i|%i|%i|%i|%i|%i|%i|%i|%i" % (dut.BGACK_d.value,dut.BREQ_d.value,dut.BRIDGEIN_d.value,dut.BRIDGEOUT_d.value,dut.DECFIFO_d.value,dut.DIEH_d.value,dut.DIEL_d.value,dut.F2CPUH_d.value,dut.F2CPUL_d.value,dut.INCFIFO_d.value,dut.INCNI_d.value,dut.INCNO_d.value,dut.PAS_d.value,dut.PDS_d.value,dut.PLHW_d.value,dut.PLLW_d.value,dut.SIZE1_d.value,dut.STOPFLUSH_d.value)
    line = "%i|%s|%i|%s" % (dut.STATE.value,inputs,dut.NEXT_STATE.value,outputs)
    dut._log.info("%s\n",line)

    dut.A1.value = 0
    dut.BGRANT_.value = 1
    dut.BOEQ3.value = 0
    dut.CYCLEDONE.value = 0
    dut.DMADIR.value = 0
    dut.DMAENA.value = 0
    dut.DREQ_.value = 1
    dut.DSACK.value = 0
    dut.DSACK0_.value = 1
    dut.DSACK1_.value = 1
    dut.FIFOEMPTY.value = 0
    dut.FIFOFULL.value = 0
    dut.FLUSHFIFO.value = 0
    dut.LASTWORD.value = 0
    dut.RDFIFO_.value = 1
    dut.RIFIFO_.value = 1
    dut.STERM_.value = 1
    return line

@cocotb.test()
async def fsm_cpu_test(dut):
    """test_fsm_cpuU"""

    #set inital value of inputs
    dut.A1.value = 0
    dut.BGRANT_.value = 1
    dut.BOEQ3.value = 0
    dut.CYCLEDONE.value = 0
    dut.DMADIR.value = 0
    dut.DMAENA.value = 0
    dut.DREQ_.value = 1
    dut.DSACK.value = 0
    dut.DSACK0_.value = 1
    dut.DSACK1_.value = 1
    dut.FIFOEMPTY.value = 0
    dut.FIFOFULL.value = 0
    dut.FLUSHFIFO.value = 0
    dut.LASTWORD.value = 0
    dut.RDFIFO_.value = 1
    dut.RIFIFO_.value = 1
    dut.STERM_.value = 1


    cocotb.start_soon(monitor_dut(dut))
    clock = Clock(dut.CLK, 40, units="ns")  # Create a 40ns period clock on port clk
    # Start the clock. Start it low to avoid issues on the first RisingEdge
    cocotb.start_soon(clock.start(start_high=False))

    await reset_dut(dut.nRESET, 40)
    dut._log.info("After reset")

    await ClockCycles(dut.CLK, 1, True)
    
    
    header = "State|A1|BGRANT_|BOEQ3|CYCLEDONE|DMADIR|DMAENA|DREQ_|DSACK|DSACK0_|DSACK1_|FIFOEMPTY|FIFOFULL|FLUSHFIFO|LASTWORD|RDFIFO_|RIFIFO_|STERM_|NextState|BGACK_d|BREQ_d|BRIDGEIN_d|BRIDGEOUT_d|DECFIFO_d|DIEH_d|DIEL_d|F2CPUH_d|F2CPUL_d|INCFIFO_d|INCNI_d|INCNO_d|PAS_d|PDS_d|PLHW_d|PLLW_d|SIZE1_d|STOPFLUSH_d"
    seperator = "-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-"
    dut._log.info("Generating State table\n%s\n%s\n",header,seperator) 
    
    table = [header, seperator]
     
    dut.STATE.value = 0
    dut.DMAENA.value = 1
    dut.DMADIR.value = 1
    dut.FLUSHFIFO.value = 1
    dut.FIFOEMPTY.value = 1
    dut.FIFOFULL.value = 0
    dut.LASTWORD.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 0
    dut.DMAENA.value = 1
    dut.DMADIR.value = 1
    dut.FLUSHFIFO.value = 1
    dut.FIFOEMPTY.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 0
    dut.DMAENA.value = 1
    dut.DMADIR.value = 1
    dut.FLUSHFIFO.value = 1
    dut.LASTWORD.value = 1    
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 0
    dut.DMAENA.value = 1
    dut.DMADIR.value = 1
    dut.FIFOFULL.value = 1
    table.append(await check_output_values(dut))

    dut.STATE.value = 0
    dut.DMAENA.value = 1
    dut.DMADIR.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 1
    dut.DSACK0_.value = 0
    dut.DSACK1_.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 1
    dut.DSACK1_.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 2
    dut.CYCLEDONE.value = 1
    dut.A1.value = 0
    dut.BGRANT_.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 2
    dut.CYCLEDONE.value = 1
    dut.A1.value = 1
    dut.BGRANT_.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 2
    dut.BGRANT_.value = 1
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 2
    dut.CYCLEDONE.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 3
    dut.DSACK0_.value = 0
    dut.DSACK1_.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 3
    dut.DSACK1_.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 3
    dut.DSACK0_.value = 1
    dut.DSACK1_.value = 1
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 4
    dut.DMAENA.value = 1
    dut.DMADIR.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 5
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 6
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 7
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 7
    dut.DSACK1_.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 8
    dut.CYCLEDONE.value = 1
    dut.LASTWORD.value = 1
    dut.A1.value = 0
    dut.BGRANT_.value = 0
    dut.BOEQ3.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 8
    dut.CYCLEDONE.value = 1
    dut.LASTWORD.value = 1
    dut.A1.value = 0
    dut.BGRANT_.value = 0
    dut.BOEQ3.value = 1
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 8
    dut.CYCLEDONE.value = 1
    dut.LASTWORD.value = 0
    dut.A1.value = 0
    dut.BGRANT_.value = 0
    table.append(await check_output_values(dut))

    dut.STATE.value = 8
    dut.CYCLEDONE.value = 1
    dut.A1.value = 1
    dut.BGRANT_.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 8
    dut.BGRANT_.value = 1
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 8
    dut.CYCLEDONE.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 9
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 10
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 11
    dut.FIFOFULL.value = 1
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 11
    dut.FIFOFULL.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 12
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 13
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 14
    dut.DSACK0_.value = 1
    dut.DSACK1_.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 14
    dut.DSACK0_.value = 0
    dut.DSACK1_.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 15
    dut.DSACK0_.value = 1
    dut.DSACK1_.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 15
    dut.DSACK0_.value = 0
    dut.DSACK1_.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 16
    dut.DMAENA.value = 1
    dut.DMADIR.value = 0
    dut.FIFOEMPTY.value = 1
    dut.DREQ_.value = 0
    table.append(await check_output_values(dut))

    dut.STATE.value = 16
    dut.DMADIR.value = 0
    dut.DREQ_.value = 1
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 16
    dut.DMADIR.value = 0
    dut.FIFOEMPTY.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 16
    dut.DMAENA.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 17
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 18
    dut.DMADIR.value = 0
    dut.DREQ_.value = 1
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 18
    dut.DMADIR.value = 0
    dut.FIFOEMPTY.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 18
    dut.DMAENA.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 19
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 20
    dut.DMAENA.value = 1
    dut.DMADIR.value = 0
    dut.FIFOEMPTY.value = 1
    dut.DREQ_.value = 0
    table.append(await check_output_values(dut))

    dut.STATE.value = 20
    dut.DMADIR.value = 0
    dut.DREQ_.value = 1
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 20
    dut.DMADIR.value = 0
    dut.FIFOEMPTY.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 20
    dut.DMAENA.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 21
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 22
    dut.DMADIR.value = 0
    dut.DREQ_.value = 1
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 22
    dut.DMADIR.value = 0
    dut.FIFOEMPTY.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 22
    dut.DMAENA.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 23
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 24
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 25
    dut.DSACK1_.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 25
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 26
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 27
    dut.DSACK1_.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 27
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 28
    dut.DSACK1_.value = 0
    dut.DSACK0_.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 28
    dut.BOEQ3.value = 1
    dut.FIFOEMPTY.value = 1
    dut.LASTWORD.value = 1
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 28
    dut.BOEQ3.value = 0
    dut.FIFOEMPTY.value = 1
    dut.LASTWORD.value = 1
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 28
    dut.FIFOEMPTY.value = 1
    dut.LASTWORD.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 28
    dut.FIFOEMPTY.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 29
    dut.BOEQ3.value = 1
    dut.FIFOEMPTY.value = 1
    dut.LASTWORD.value = 1
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 29
    dut.BOEQ3.value = 0
    dut.FIFOEMPTY.value = 1
    dut.LASTWORD.value = 1
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 29
    dut.FIFOEMPTY.value = 1
    dut.LASTWORD.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 29
    dut.FIFOEMPTY.value = 0
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 30
    table.append(await check_output_values(dut))
    
    dut.STATE.value = 31
    table.append(await check_output_values(dut))
    
    with open('CPU_FSM_StateTable.md', 'w') as outfile:
        outfile.write('\n'.join(str(i) for i in table))
    
    
    
    

