"""Resolved-bus regression for DMA direction, slave access and turnaround."""
import cocotb
from cocotb.triggers import Timer


async def settle():
    # This combinational isolation test has no clock-dependent expectations.
    await Timer(1, units="ns")


@cocotb.test(timeout_time=1, timeout_unit="us")
async def test_data_bus_direction(dut):
    dut.external_data.value = 0xAAAAAAAA
    dut.external_enable.value = 1
    dut.device_data.value = 0x55555555

    # Memory owns the read data even while the DMA controller owns control.
    dut.owner.value = 1
    dut.dma_to_memory.value = 0
    for selected in (0, 1):
        dut.cs_n.value = selected
        await settle()
        assert int(dut.data_bus.value) == 0xAAAAAAAA, "DMA read data contention"

    # With the responder released, the only remaining driver is weak pullup.
    dut.external_enable.value = 0
    await settle()
    assert int(dut.data_bus.value) == 0xFFFFFFFF, "DMA read did not release data"

    dut.dma_to_memory.value = 1
    await settle()
    assert int(dut.data_bus.value) == 0x55555555, "DMA write must drive data"
    assert int(dut.rw.value) == 0

    # Change direction while owned; stale output enable must not survive.
    dut.dma_to_memory.value = 0
    dut.external_enable.value = 1
    await settle()
    assert int(dut.data_bus.value) == 0xAAAAAAAA, "Write/read turnaround contention"

    dut.owner.value = 0
    dut.cs_n.value = 0
    dut.external_read.value = 0
    await settle()
    assert int(dut.data_bus.value) == 0xAAAAAAAA, "CPU register write contention"

    dut.external_enable.value = 0
    dut.external_read.value = 1
    await settle()
    assert int(dut.data_bus.value) == 0x55555555, "CPU register read must drive"

    dut.acr_select.value = 1
    await settle()
    assert int(dut.data_bus.value) == 0xFFFFFFFF, "Ramsey ACR read must release"

    dut.acr_select.value = 0
    dut.cs_n.value = 1
    await settle()
    assert int(dut.data_bus.value) == 0xFFFFFFFF, "Unselected device must release"
