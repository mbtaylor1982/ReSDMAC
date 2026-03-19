# cocotb_fifo.py
#
# Cocotb test suite for the consolidated FIFO module.
# The FIFO is 32-bits wide, 8 entries deep by default, with byte-lane write
# strobes and edge-detected counter control signals.

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

FIFO_DEPTH = 8
FIFO_WIDTH = 32


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

async def reset_dut(dut):
    """Assert synchronous reset for 2 clock cycles then release."""
    dut.i_RST_FIFO_n.value = 0
    await ClockCycles(dut.i_CLK100, 2, True)
    dut.i_RST_FIFO_n.value = 1
    await ClockCycles(dut.i_CLK100, 1, True)


async def init_inputs(dut):
    """Drive all inputs to safe defaults before clock starts."""
    dut.i_RST_FIFO_n.value = 1
    dut.i_LLWORD.value = 0
    dut.i_LHWORD.value = 0
    dut.i_LBYTE_n.value = 1
    dut.i_A1.value = 0
    dut.i_FIFO_ID.value = 0
    dut.i_INCFIFO.value = 0
    dut.i_DECFIFO.value = 0
    dut.i_INCBO.value = 0
    dut.i_INCNO.value = 0
    dut.i_INCNI.value = 0


async def start_clock(dut):
    """Create and start the 100 MHz clock."""
    clock = Clock(dut.i_CLK100, 10, unit="ns")
    cocotb.start_soon(clock.start())
    await RisingEdge(dut.i_CLK100)


async def pulse(dut, signal):
    """Pulse a signal high for 1 cycle, then wait for edge-detection pipeline.

    The FIFO uses a 2-stage shift register for rising-edge detection:
      Posedge 1 after assert : edge_detect captures {0,1} = 2'b01
      Posedge 2 (deasserted) : rise_evt fires, counter/pointer updates
      Posedge 3              : edge_detect returns to 2'b00, ready for reuse
    """
    signal.value = 1
    await RisingEdge(dut.i_CLK100)
    signal.value = 0
    await RisingEdge(dut.i_CLK100)
    await RisingEdge(dut.i_CLK100)


async def write_longword(dut):
    """Write a full 32-bit word using LLWORD + LHWORD strobes, then advance
    the write pointer and FIFO count."""
    dut.i_LLWORD.value = 1
    dut.i_LHWORD.value = 1
    await RisingEdge(dut.i_CLK100)
    dut.i_LLWORD.value = 0
    dut.i_LHWORD.value = 0
    await pulse(dut, dut.i_INCNI)
    await pulse(dut, dut.i_INCFIFO)


async def read_longword(dut):
    """Advance the read pointer and decrement the FIFO count by one entry."""
    await pulse(dut, dut.i_INCNO)
    await pulse(dut, dut.i_DECFIFO)


async def write_byte(dut):
    """Write one byte via LBYTE strobe (byte lane selected by byte_ptr),
    then advance byte_ptr."""
    dut.i_LBYTE_n.value = 0
    await RisingEdge(dut.i_CLK100)
    dut.i_LBYTE_n.value = 1
    await RisingEdge(dut.i_CLK100)
    await pulse(dut, dut.i_INCBO)


def buf_val(dut, idx):
    """Read a FIFO buffer entry by index, returned as int."""
    return int(dut["buffer[%d]" % idx].value)


# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

@cocotb.test()
async def test_reset_a1_high(dut):
    """Reset with A1=1: byte_ptr should initialise to 2 (bit pattern {1,0})."""
    await init_inputs(dut)
    await start_clock(dut)

    dut.i_A1.value = 1
    await reset_dut(dut)

    dut._log.info("Reset A1=1: write_ptr=%d  read_ptr=%d  byte_ptr=%d",
                   int(dut.write_ptr.value), int(dut.read_ptr.value),
                   int(dut.byte_ptr.value))

    assert int(dut.write_ptr.value) == 0, "write_ptr != 0 after reset"
    assert int(dut.read_ptr.value) == 0,  "read_ptr != 0 after reset"
    assert int(dut.byte_ptr.value) == 2,  "byte_ptr != 2 after reset (A1=1)"
    assert int(dut.o_FIFOEMPTY.value) == 1, "FIFOEMPTY != 1 after reset"
    assert int(dut.o_FIFOFULL.value) == 0,  "FIFOFULL != 0 after reset"
    assert int(dut.o_BO0.value) == 0, "BO0 != 0 after reset (A1=1)"
    assert int(dut.o_BO1.value) == 1, "BO1 != 1 after reset (A1=1)"
    assert int(dut.o_BOEQ0.value) == 0, "BOEQ0 should be 0 when byte_ptr=2"
    assert int(dut.o_BOEQ3.value) == 0, "BOEQ3 should be 0 when byte_ptr=2"

    dut._log.info("PASS: reset with A1=1")


@cocotb.test()
async def test_reset_a1_low(dut):
    """Reset with A1=0: byte_ptr should initialise to 0."""
    await init_inputs(dut)
    await start_clock(dut)

    dut.i_A1.value = 0
    await reset_dut(dut)

    dut._log.info("Reset A1=0: write_ptr=%d  read_ptr=%d  byte_ptr=%d",
                   int(dut.write_ptr.value), int(dut.read_ptr.value),
                   int(dut.byte_ptr.value))

    assert int(dut.write_ptr.value) == 0, "write_ptr != 0 after reset"
    assert int(dut.read_ptr.value) == 0,  "read_ptr != 0 after reset"
    assert int(dut.byte_ptr.value) == 0,  "byte_ptr != 0 after reset (A1=0)"
    assert int(dut.o_FIFOEMPTY.value) == 1, "FIFOEMPTY != 1 after reset"
    assert int(dut.o_FIFOFULL.value) == 0,  "FIFOFULL != 0 after reset"
    assert int(dut.o_BO0.value) == 0, "BO0 != 0 after reset (A1=0)"
    assert int(dut.o_BO1.value) == 0, "BO1 != 0 after reset (A1=0)"
    assert int(dut.o_BOEQ0.value) == 1, "BOEQ0 should be 1 when byte_ptr=0"
    assert int(dut.o_BOEQ3.value) == 0, "BOEQ3 should be 0 when byte_ptr=0"

    dut._log.info("PASS: reset with A1=0")


@cocotb.test()
async def test_byte_pointer_walk(dut):
    """Verify byte_ptr increments 0->1->2->3->0 and that BOEQ0/BOEQ3/BO0/BO1
    are correct at each position."""
    await init_inputs(dut)
    await start_clock(dut)

    dut.i_A1.value = 0
    await reset_dut(dut)

    expected = [
        # (byte_ptr, BO1, BO0, BOEQ0, BOEQ3)
        (0, 0, 0, 1, 0),
        (1, 0, 1, 0, 0),
        (2, 1, 0, 0, 0),
        (3, 1, 1, 0, 1),
    ]

    for bp, bo1, bo0, boeq0, boeq3 in expected:
        cur_bp = int(dut.byte_ptr.value)
        dut._log.info("byte_ptr=%d  BO1=%d BO0=%d  BOEQ0=%d BOEQ3=%d",
                       cur_bp,
                       int(dut.o_BO1.value), int(dut.o_BO0.value),
                       int(dut.o_BOEQ0.value), int(dut.o_BOEQ3.value))
        assert cur_bp == bp, f"byte_ptr expected {bp}, got {cur_bp}"
        assert int(dut.o_BO1.value) == bo1,   f"BO1 wrong at byte_ptr={bp}"
        assert int(dut.o_BO0.value) == bo0,   f"BO0 wrong at byte_ptr={bp}"
        assert int(dut.o_BOEQ0.value) == boeq0, f"BOEQ0 wrong at byte_ptr={bp}"
        assert int(dut.o_BOEQ3.value) == boeq3, f"BOEQ3 wrong at byte_ptr={bp}"
        await pulse(dut, dut.i_INCBO)

    # After 4 increments byte_ptr should wrap back to 0
    assert int(dut.byte_ptr.value) == 0, "byte_ptr did not wrap to 0 after 4 increments"
    dut._log.info("byte_ptr wrapped to 0 after 4 increments")
    dut._log.info("PASS: byte pointer walk")


@cocotb.test()
async def test_byte_lane_isolation(dut):
    """Write one byte at each byte_ptr position and verify only the target
    byte lane is written; other lanes stay zero."""
    await init_inputs(dut)
    await start_clock(dut)

    dut.i_A1.value = 0
    await reset_dut(dut)

    # Input data has distinct values in each byte lane
    dut.i_FIFO_ID.value = 0xAABBCCDD

    # byte_ptr=0 -> writes bits [31:24] (UUWS lane)
    dut._log.info("Writing byte at byte_ptr=0 (upper byte lane [31:24])")
    dut.i_LBYTE_n.value = 0
    await RisingEdge(dut.i_CLK100)
    dut.i_LBYTE_n.value = 1
    await RisingEdge(dut.i_CLK100)

    val = buf_val(dut, 0)
    dut._log.info("  buffer[0] = 0x%08X (expect 0xAA000000)", val)
    assert val == 0xAA000000, f"byte_ptr=0 wrote wrong lanes: 0x{val:08X}"

    # byte_ptr=1 -> writes bits [23:16] (UMWS lane)
    await pulse(dut, dut.i_INCBO)
    dut._log.info("Writing byte at byte_ptr=1 (lane [23:16])")
    dut.i_LBYTE_n.value = 0
    await RisingEdge(dut.i_CLK100)
    dut.i_LBYTE_n.value = 1
    await RisingEdge(dut.i_CLK100)

    val = buf_val(dut, 0)
    dut._log.info("  buffer[0] = 0x%08X (expect 0xAABB0000)", val)
    assert val == 0xAABB0000, f"byte_ptr=1 wrote wrong lanes: 0x{val:08X}"

    # byte_ptr=2 -> writes bits [15:8] (LMWS lane)
    await pulse(dut, dut.i_INCBO)
    dut._log.info("Writing byte at byte_ptr=2 (lane [15:8])")
    dut.i_LBYTE_n.value = 0
    await RisingEdge(dut.i_CLK100)
    dut.i_LBYTE_n.value = 1
    await RisingEdge(dut.i_CLK100)

    val = buf_val(dut, 0)
    dut._log.info("  buffer[0] = 0x%08X (expect 0xAABBCC00)", val)
    assert val == 0xAABBCC00, f"byte_ptr=2 wrote wrong lanes: 0x{val:08X}"

    # byte_ptr=3 -> writes bits [7:0] (LLWS lane)
    await pulse(dut, dut.i_INCBO)
    dut._log.info("Writing byte at byte_ptr=3 (lane [7:0])")
    dut.i_LBYTE_n.value = 0
    await RisingEdge(dut.i_CLK100)
    dut.i_LBYTE_n.value = 1
    await RisingEdge(dut.i_CLK100)

    val = buf_val(dut, 0)
    dut._log.info("  buffer[0] = 0x%08X (expect 0xAABBCCDD)", val)
    assert val == 0xAABBCCDD, f"byte_ptr=3 wrote wrong lanes: 0x{val:08X}"

    dut._log.info("PASS: byte lane isolation")


@cocotb.test()
async def test_halfword_writes(dut):
    """Test LHWORD and LLWORD independently to verify they each write
    only their respective 16-bit half."""
    await init_inputs(dut)
    await start_clock(dut)

    dut.i_A1.value = 0
    await reset_dut(dut)

    dut.i_FIFO_ID.value = 0x12345678

    # LHWORD writes upper half [31:16]
    dut._log.info("Asserting LHWORD only (upper half)")
    dut.i_LHWORD.value = 1
    await RisingEdge(dut.i_CLK100)
    dut.i_LHWORD.value = 0
    await RisingEdge(dut.i_CLK100)

    val = buf_val(dut, 0)
    dut._log.info("  buffer[0] = 0x%08X (expect 0x12340000)", val)
    assert val == 0x12340000, f"LHWORD wrote wrong lanes: 0x{val:08X}"

    # LLWORD writes lower half [15:0]
    dut._log.info("Asserting LLWORD only (lower half)")
    dut.i_LLWORD.value = 1
    await RisingEdge(dut.i_CLK100)
    dut.i_LLWORD.value = 0
    await RisingEdge(dut.i_CLK100)

    val = buf_val(dut, 0)
    dut._log.info("  buffer[0] = 0x%08X (expect 0x12345678)", val)
    assert val == 0x12345678, f"LLWORD wrote wrong lanes: 0x{val:08X}"

    dut._log.info("PASS: half-word writes")


@cocotb.test()
async def test_fill_by_byte_and_read_back(dut):
    """Fill the FIFO one byte at a time and verify each entry via o_FIFO_OD
    on read-back."""
    await init_inputs(dut)
    await start_clock(dut)

    dut.i_A1.value = 0
    await reset_dut(dut)

    # Fill all 8 entries byte-by-byte
    data_in = 0xA1B1C1D1
    written_values = []

    dut._log.info("--- Filling FIFO byte-by-byte (%d entries) ---", FIFO_DEPTH)
    entry = 0
    while int(dut.o_FIFOFULL.value) != 1:
        dut.i_FIFO_ID.value = data_in
        for _ in range(4):
            await write_byte(dut)

        wr_ptr = int(dut.write_ptr.value)
        val = buf_val(dut, wr_ptr)
        dut._log.info("  entry[%d]: wrote 0x%08X, buffer=0x%08X", entry, data_in, val)
        assert val == data_in, \
            f"entry[{entry}]: expected 0x{data_in:08X}, got 0x{val:08X}"

        written_values.append(data_in)

        # Advance write pointer and FIFO count
        await pulse(dut, dut.i_INCNI)
        await pulse(dut, dut.i_INCFIFO)

        data_in = (data_in + 0x01010101) & 0xFFFFFFFF
        entry += 1
        await ClockCycles(dut.i_CLK100, 1, True)
        assert int(dut.o_FIFOEMPTY.value) == 0, "FIFOEMPTY asserted mid-fill"

    assert int(dut.o_FIFOFULL.value) == 1, "FIFOFULL not asserted after filling all entries"
    dut._log.info("FIFO full after %d entries", entry)

    # Read back and verify each entry via o_FIFO_OD
    dut._log.info("--- Reading back via o_FIFO_OD ---")
    for idx, expected in enumerate(written_values):
        od_val = int(dut.o_FIFO_OD.value)
        dut._log.info("  entry[%d]: o_FIFO_OD=0x%08X (expect 0x%08X)", idx, od_val, expected)
        assert od_val == expected, \
            f"entry[{idx}]: o_FIFO_OD expected 0x{expected:08X}, got 0x{od_val:08X}"
        await read_longword(dut)

    assert int(dut.o_FIFOEMPTY.value) == 1, "FIFOEMPTY not asserted after reading all entries"
    dut._log.info("PASS: fill by byte and read back via o_FIFO_OD")


@cocotb.test()
async def test_fill_by_longword_and_read_back(dut):
    """Fill the FIFO one longword at a time using LLWORD+LHWORD and verify
    each entry via o_FIFO_OD on read-back."""
    await init_inputs(dut)
    await start_clock(dut)

    dut.i_A1.value = 0
    await reset_dut(dut)

    data_in = 0xA1B1C1D1
    written_values = []

    dut._log.info("--- Filling FIFO longword-at-a-time (%d entries) ---", FIFO_DEPTH)
    entry = 0
    while int(dut.o_FIFOFULL.value) != 1:
        dut.i_FIFO_ID.value = data_in
        await write_longword(dut)
        written_values.append(data_in)
        dut._log.info("  entry[%d]: wrote 0x%08X", entry, data_in)
        data_in = (data_in + 0x01010101) & 0xFFFFFFFF
        entry += 1

    assert int(dut.o_FIFOFULL.value) == 1, "FIFOFULL not asserted"
    dut._log.info("FIFO full after %d entries", entry)

    # Read back
    dut._log.info("--- Reading back via o_FIFO_OD ---")
    for idx, expected in enumerate(written_values):
        od_val = int(dut.o_FIFO_OD.value)
        dut._log.info("  entry[%d]: o_FIFO_OD=0x%08X (expect 0x%08X)", idx, od_val, expected)
        assert od_val == expected, \
            f"entry[{idx}]: o_FIFO_OD expected 0x{expected:08X}, got 0x{od_val:08X}"
        await read_longword(dut)

    assert int(dut.o_FIFOEMPTY.value) == 1, "FIFOEMPTY not asserted after flush"
    dut._log.info("PASS: fill by longword and read back via o_FIFO_OD")


@cocotb.test()
async def test_pointer_wrap_around(dut):
    """Fill and drain the FIFO twice to exercise write_ptr and read_ptr
    wrapping past the depth boundary (index 7 -> 0)."""
    await init_inputs(dut)
    await start_clock(dut)

    dut.i_A1.value = 0
    await reset_dut(dut)

    for cycle in range(2):
        dut._log.info("--- Wrap cycle %d: filling ---", cycle)
        data_in = 0x10 * (cycle + 1)
        for entry in range(FIFO_DEPTH):
            dut.i_FIFO_ID.value = data_in + entry
            await write_longword(dut)

        wr_ptr = int(dut.write_ptr.value)
        dut._log.info("  write_ptr after %d writes: %d (expect 0 after wrap)",
                       FIFO_DEPTH, wr_ptr)
        assert wr_ptr == 0, f"write_ptr did not wrap: {wr_ptr}"
        assert int(dut.o_FIFOFULL.value) == 1, "FIFOFULL not asserted"

        dut._log.info("--- Wrap cycle %d: draining ---", cycle)
        for entry in range(FIFO_DEPTH):
            await read_longword(dut)

        rd_ptr = int(dut.read_ptr.value)
        dut._log.info("  read_ptr after %d reads: %d (expect 0 after wrap)",
                       FIFO_DEPTH, rd_ptr)
        assert rd_ptr == 0, f"read_ptr did not wrap: {rd_ptr}"
        assert int(dut.o_FIFOEMPTY.value) == 1, "FIFOEMPTY not asserted"

    dut._log.info("PASS: pointer wrap-around")


@cocotb.test()
async def test_reset_during_operation(dut):
    """Write data into the FIFO, then assert reset and verify everything
    clears back to the initial state."""
    await init_inputs(dut)
    await start_clock(dut)

    dut.i_A1.value = 0
    await reset_dut(dut)

    # Write 4 entries
    dut._log.info("Writing 4 entries before mid-operation reset")
    for i in range(4):
        dut.i_FIFO_ID.value = 0xDEAD0000 + i
        await write_longword(dut)

    dut._log.info("  full_empty_count=%d  write_ptr=%d",
                   int(dut.full_empty_count.value), int(dut.write_ptr.value))
    assert int(dut.o_FIFOEMPTY.value) == 0, "FIFO should not be empty"
    assert int(dut.full_empty_count.value) == 4, "count should be 4"

    # Reset
    dut._log.info("Asserting reset")
    await reset_dut(dut)

    dut._log.info("  After reset: full_empty_count=%d  write_ptr=%d  read_ptr=%d",
                   int(dut.full_empty_count.value),
                   int(dut.write_ptr.value),
                   int(dut.read_ptr.value))

    assert int(dut.write_ptr.value) == 0, "write_ptr not cleared"
    assert int(dut.read_ptr.value) == 0,  "read_ptr not cleared"
    assert int(dut.full_empty_count.value) == 0, "full_empty_count not cleared"
    assert int(dut.o_FIFOEMPTY.value) == 1, "FIFOEMPTY not asserted after reset"
    assert int(dut.o_FIFOFULL.value) == 0,  "FIFOFULL asserted after reset"

    # Verify all buffer entries cleared
    for i in range(FIFO_DEPTH):
        val = buf_val(dut, i)
        assert val == 0, f"buffer[{i}] = 0x{val:08X} after reset, expected 0"

    dut._log.info("PASS: reset during operation")


@cocotb.test()
async def test_full_empty_counter_saturation(dut):
    """Verify the full/empty counter correctly reports FIFOFULL at depth
    and FIFOEMPTY at zero, and that the counter tracks inc/dec accurately."""
    await init_inputs(dut)
    await start_clock(dut)

    dut.i_A1.value = 0
    await reset_dut(dut)

    dut._log.info("--- Incrementing full/empty counter to DEPTH ---")
    for i in range(FIFO_DEPTH):
        count = int(dut.full_empty_count.value)
        dut._log.info("  count=%d  FIFOFULL=%d  FIFOEMPTY=%d",
                       count, int(dut.o_FIFOFULL.value), int(dut.o_FIFOEMPTY.value))
        assert count == i, f"count expected {i}, got {count}"
        if i == 0:
            assert int(dut.o_FIFOEMPTY.value) == 1, "FIFOEMPTY should be 1 at count=0"
        else:
            assert int(dut.o_FIFOEMPTY.value) == 0, f"FIFOEMPTY should be 0 at count={i}"
        assert int(dut.o_FIFOFULL.value) == 0, f"FIFOFULL should be 0 at count={i}"

        dut.i_FIFO_ID.value = i
        await write_longword(dut)

    count = int(dut.full_empty_count.value)
    dut._log.info("  count=%d  FIFOFULL=%d", count, int(dut.o_FIFOFULL.value))
    assert count == FIFO_DEPTH, f"count should be {FIFO_DEPTH} when full"
    assert int(dut.o_FIFOFULL.value) == 1, "FIFOFULL should be 1"
    assert int(dut.o_FIFOEMPTY.value) == 0, "FIFOEMPTY should be 0 when full"

    dut._log.info("--- Decrementing full/empty counter to zero ---")
    for i in range(FIFO_DEPTH):
        await read_longword(dut)
        remaining = FIFO_DEPTH - 1 - i
        count = int(dut.full_empty_count.value)
        dut._log.info("  after dec %d: count=%d (expect %d)", i + 1, count, remaining)
        assert count == remaining, f"count expected {remaining}, got {count}"

    assert int(dut.o_FIFOEMPTY.value) == 1, "FIFOEMPTY should be 1 at count=0"
    assert int(dut.o_FIFOFULL.value) == 0,  "FIFOFULL should be 0 at count=0"
    dut._log.info("PASS: full/empty counter saturation")
