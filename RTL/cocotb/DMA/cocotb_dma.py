"""DMA scoreboards driven exclusively through the SDMAC socket."""
import os

import cocotb
from cocotb.regression import TestFactory

from board import Board, memory_byte


async def dma_transfer(dut, length=32, address=0x00101000, waits=0, handoff="idle",
                       ack_phase=21, ramsey=7, profile=None, grant_delay=None):
    direction = os.environ["DMA_DIRECTION"]
    termination = os.environ["DMA_TERMINATION"]
    to_memory = direction == "to_memory"
    board = Board(dut, termination, wait_states=waits,
                  grant_delay=80 + waits * 40 if grant_delay is None else grant_delay,
                  handoff=handoff, ack_phase=ack_phase, ramsey=ramsey)
    name = f"{direction}_{termination}_{address:08x}_{length}_{waits}_{handoff}_{ack_phase}_{ramsey}"
    if profile:
        name = f"{profile}_{name}"
    try:
        await board.start()
        expected = bytes(memory_byte(address + i) for i in range(length))
        if profile:
            await board.start_os_dma(profile, address, to_memory)
        else:
            await board.cpu(0x08, 0x04 if to_memory else 0x06)
            await board.cpu(0x0C, address)
            assert await board.cpu(0x0C) == address, "Ramsey ACR readback"
            await board.cpu(0x10)
        await board.peripheral(expected, to_memory)
        if profile:
            completed = await board.finish_os_dma(profile, to_memory)
            if to_memory:
                assert all(completed.get(address + i) == byte for i, byte in enumerate(expected)), \
                    "OS observed FIFO-empty before payload reached memory"
        else:
            await board.finish()
        assert board.peripheral_reads == (length if to_memory else 0), "Peripheral read count"
        assert board.peripheral_writes == (0 if to_memory else length), "Peripheral write count"
        assert board.grants > 0, "No DMA ownership observed"
        assert board.cycles, "No memory transactions observed"
        if handoff != "idle":
            assert board.handoffs == board.grants, "Busy-bus handoff was not exercised"
        assert all(c["read"] == int(not to_memory) for c in board.cycles), "Wrong DMA direction"
        # Independent transaction walk: no lost/duplicated cycles, widths or addresses.
        next_address = address
        for cycle in board.cycles:
            assert cycle["address"] == next_address, "DMA address discontinuity"
            assert cycle["count"] in (2, 4)
            next_address += 2 if cycle["port"] == 2 or (ramsey == 7 and next_address & 2) else 4
        assert board.acr == next_address, "Final Ramsey ACR does not match completed cycles"
        if to_memory:
            actual = bytes(board.memory.get(address + i, 0xFF) for i in range(length))
            assert actual == expected, f"Memory payload mismatch: {actual.hex()} != {expected.hex()}"
            # SDMAC flushes whole words; one final padding byte has unspecified value.
            padded = (length + 1) & ~1
            assert set(board.memory) == set(range(address, address + padded)), \
                "DMA wrote outside the payload/allowed final padding byte"
        else:
            # Prefetch is legal; its count is not the peripheral transfer count.
            transferred = sum(c["count"] for c in board.cycles)
            assert length <= transferred <= ((length + 3) & ~3) + 32, \
                "Memory prefetch exceeds payload plus the implemented 32-byte FIFO"
    finally:
        board.close(name)


factory = TestFactory(dma_transfer)
factory.add_option("length", [1, 2, 3, 4, 15, 16, 17, 31, 32, 33, 65])
factory.add_option("waits", [0, 3])
factory.generate_tests()

# Check Buster's secondary channel independently of memory termination style.
arbitration = TestFactory(dma_transfer)
arbitration.add_option("handoff", ["as", "dsack", "sterm", "owner"])
arbitration.generate_tests(prefix="arbitration_")

# DSACK arrival is asynchronous; retain it through AS release at every phase.
phases = TestFactory(dma_transfer)
phases.add_option("ack_phase", [1, 11, 31])
phases.generate_tests(prefix="phase_")

@cocotb.test()
async def motherboard_fast_ram(dut):
    await dma_transfer(dut, length=33, address=0x07001000, waits=1, ramsey=4)


@cocotb.test()
async def ramsey07_word_alignment(dut):
    await dma_transfer(dut, length=17, address=0x00101002, waits=1)


async def os_completed_dma(dut, profile, length):
    """Completed DMA portions; programmed-I/O tails are outside this harness."""
    await dma_transfer(dut, profile=profile, length=length, waits=1)


completed = TestFactory(os_completed_dma)
completed.add_option("profile", ["amiga", "linux"])
completed.add_option("length", [256, 258, 512, 514])
completed.generate_tests()


async def os_interrupted_dma(dut, profile, transferred):
    """A 512-byte WD request ceases DREQ early at a phase change/disconnect.

    SDMAC has no programmed byte count in these driver paths. Its observable
    input is exactly this prefix of WD byte handshakes followed by OS cleanup.
    WD command/interrupt decoding and residual accounting are not emulated.
    """
    assert transferred < 512
    await dma_transfer(dut, profile=profile, length=transferred, waits=1)


interrupted = TestFactory(os_interrupted_dma)
interrupted.add_option("profile", ["amiga", "linux"])
interrupted.add_option("transferred", [1, 2, 3, 255, 257, 259])
interrupted.generate_tests()


async def linux_odd_dma(dut, length):
    # The Linux a3000.c path does not round the requested length down.
    await dma_transfer(dut, profile="linux", length=length, waits=3)


linux_odd = TestFactory(linux_odd_dma)
linux_odd.add_option("length", [257, 259])
linux_odd.generate_tests()


async def os_restart_dma(dut, profile):
    """STOP/start without reset, including consecutive and reversed directions."""
    board = Board(dut, os.environ["DMA_TERMINATION"], wait_states=1)
    initial = os.environ["DMA_DIRECTION"] == "to_memory"
    try:
        await board.start()
        for index, (length, to_memory) in enumerate(
                [(3, initial), (2, initial), (65, not initial),
                 (258, initial), (259, not initial)]):
            address = 0x101000 + index * 0x1000 + (2 if index % 2 else 0)
            expected = bytes(memory_byte(address + i) for i in range(length))
            before_memory = set(board.memory)
            before_cycles = len(board.cycles)
            before_reads, before_writes = board.peripheral_reads, board.peripheral_writes
            await board.start_os_dma(profile, address, to_memory)
            await board.peripheral(expected, to_memory)
            completed = await board.finish_os_dma(profile, to_memory)
            assert board.peripheral_reads - before_reads == (length if to_memory else 0)
            assert board.peripheral_writes - before_writes == (0 if to_memory else length)
            cycles = board.cycles[before_cycles:]
            assert cycles and all(c["read"] == int(not to_memory) for c in cycles)
            next_address = address
            for cycle in cycles:
                assert cycle["address"] == next_address, "Restart address discontinuity"
                next_address += 2 if cycle["port"] == 2 or next_address & 2 else 4
            assert board.acr == next_address
            if to_memory:
                assert all(completed.get(address + i) == b for i, b in enumerate(expected)), \
                    "Restart FIFO-empty preceded payload completion"
                assert set(board.memory) - before_memory == set(range(address, address + ((length + 1) & ~1))), \
                    "Restart wrote outside payload/padding"
            else:
                assert set(board.memory) == before_memory
                assert length <= sum(c["count"] for c in cycles) <= ((length + 3) & ~3) + 32
    finally:
        board.close(f"{profile}_restart_{os.environ['DMA_DIRECTION']}")


restarts = TestFactory(os_restart_dma)
restarts.add_option("profile", ["amiga", "linux"])
restarts.generate_tests()


async def os_delayed_grant(dut, profile, ramsey):
    await dma_transfer(dut, length=259, address=0x07001000 + (2 if ramsey == 7 else 0),
                       waits=3, handoff="owner", ack_phase=11, ramsey=ramsey,
                       profile=profile, grant_delay=1600)


delayed = TestFactory(os_delayed_grant)
delayed.add_option("profile", ["amiga", "linux"])
delayed.add_option("ramsey", [4, 7])
delayed.generate_tests()
