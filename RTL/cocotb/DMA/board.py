"""External A3000 socket models. Protocol basis: Docs/DMA_VERIFICATION.md.

This is a transaction-level Buster/CPU boundary and Ramsey address generator,
not an emulation of their internal implementation or analogue timing.
"""
import json
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer
from cocotb.utils import get_sim_time


def value(signal):
    assert signal.value.is_resolvable, f"Unresolved bus {signal._name}: {signal.value}"
    return int(signal.value)


async def wait_for(predicate, description, timeout_ns=100_000):
    deadline = get_sim_time(units="ns") + timeout_ns
    while not predicate():
        assert get_sim_time(units="ns") < deadline, f"Timeout: {description}"
        await Timer(5, units="ns")


def memory_byte(address):
    # Address-dependent, asymmetric bytes expose swapped lanes and stale words.
    return ((address * 73) ^ (address >> 3) ^ (address >> 11) ^ 0xA6) & 255


class Board:
    def __init__(self, dut, termination, wait_states=0, grant_delay=80, ramsey=7,
                 handoff="idle", ack_phase=21):
        self.d = dut
        self.termination = termination
        self.wait_states = wait_states
        self.grant_delay = grant_delay
        self.ramsey = ramsey
        self.handoff = handoff
        self.ack_phase = ack_phase
        self.acr = 0
        self.memory = {}
        self.cycles = []
        self.acr_cycles = []
        self.software_cycles = []
        self.grants = 0
        self.handoffs = 0
        self.peripheral_reads = 0
        self.peripheral_writes = 0
        self.cpu_pending = False
        self.tasks = []

    async def start(self):
        d = self.d
        for name, val in dict(reset_n=0, cpu_enable=0, cpu_as_n=1, cpu_ds_n=1,
                              cpu_rw=1, cpu_data_enable=0, cpu_address=0,
                              memory_enable=0, response_n=3, sterm_n=1,
                              grant_n=1, berr_n=1, other_owner=0,
                              peripheral_enable=0, dreq_n=1, ramsey_address=0).items():
            getattr(d, name).value = val
        self.tasks.append(cocotb.start_soon(Clock(d.clk, 40, units="ns").start()))
        await Timer(200, units="ns")
        d.reset_n.value = 1
        await Timer(200, units="ns")
        for model in (self.arbiter, self.memory_slave, self.monitor):
            self.tasks.append(cocotb.start_soon(model()))

    async def edge(self):
        await RisingEdge(self.d.clk)
        await Timer(1, units="ns")

    async def cpu(self, offset, data=None):
        """Software access, including dynamic sizing of Ramsey's 8-bit port."""
        if offset == 0x0C:
            result = 0
            for lane in range(4):
                # Each response is DSACK=10: the CPU presents the next byte
                # on D[31:24]. The final byte puts A1 on D25 for SDMAC snooping.
                bus_data = None if data is None else (data << (8 * lane)) & 0xFFFFFFFF
                bus = await self.cpu_cycle(offset + lane, bus_data)
                result = (result << 8) | (bus >> 24)
            return result
        return await self.cpu_cycle(offset, data)

    async def cpu_cycle(self, offset, data=None):
        """One external CPU bus cycle; Ramsey ACR responds one byte at a time."""
        d = self.d
        self.cpu_pending = True
        await wait_for(lambda: value(d.dmaen_n) and value(d.grant_n) and value(d.bgack_n),
                       "CPU waiting for DMA bus release")
        await self.edge()
        d.cpu_address.value = 0xDD0000 + offset
        d.cpu_rw.value = int(data is None)
        d.cpu_enable.value = 1
        d.cpu_data_enable.value = int(data is not None)
        if data is not None:
            d.cpu_data.value = data
        await Timer(20, units="ns")
        d.cpu_as_n.value = 0
        if data is None:
            d.cpu_ds_n.value = 0
        else:
            await Timer(40, units="ns")
            d.cpu_ds_n.value = 0
        if 0x0C <= offset <= 0x0F:
            # ACR address is physically in Ramsey; write via the resolved bus.
            await Timer(80, units="ns")
            shift = (0x0F - offset) * 8
            if data is not None:
                byte = value(d.data_bus) >> 24
                self.acr = (self.acr & ~(255 << shift)) | (byte << shift)
                self.acr &= ~3 if self.ramsey == 4 else ~1
                d.ramsey_address.value = self.acr
            else:
                d.memory_mask.value = 0xFF000000
                d.memory_data.value = ((self.acr >> shift) & 255) << 24
                d.memory_enable.value = 1
            d.response_n.value = 2
        await wait_for(lambda: value(d.dsack_n) != 3, f"CPU register {offset:#x}", 3000)
        await self.edge()
        result = value(d.data_bus)
        if 0x0C <= offset <= 0x0F:
            assert value(d.dsack_n) == 2, "ACR must terminate as an 8-bit port"
            self.acr_cycles.append(dict(address=0xDD0000 + offset, read=int(data is None),
                                        byte=result >> 24, response=2))
        await Timer(20, units="ns")
        d.cpu_as_n.value = 1
        d.cpu_ds_n.value = 1
        await Timer(10, units="ns")
        d.response_n.value = 3
        d.memory_enable.value = 0
        d.cpu_data_enable.value = 0
        d.cpu_enable.value = 0
        d.cpu_address.value = 0
        await Timer(80, units="ns")
        self.cpu_pending = False
        return result

    async def os_register(self, profile, offset, data=None):
        """A3000 byte (AmigaOS) / word (Linux) register lane accesses.

        The socket exposes A[6:2], not CPU A[1:0]/SIZ. Record the software
        width and use its low data lane; ACR still uses cpu() dynamic sizing.
        """
        width = 1 if profile == "amiga" else 2
        address = offset + 4 - width
        mask = (1 << (8 * width)) - 1
        # Replicate writes as a 68030 does for a narrow operand. The selected
        # A3000 registers consume the low byte/word of the resolved bus.
        bus_data = None if data is None else (data & mask) * (0x01010101 if width == 1 else 0x00010001)
        result = await self.cpu_cycle(address, bus_data)
        self.software_cycles.append(dict(profile=profile, offset=address, width=width,
                                         write=data, result=result & mask,
                                         time_ns=get_sim_time(units="ns")))
        return result & mask

    async def start_os_dma(self, profile, address, to_memory):
        await self.os_register(profile, 0x08, 0x0C if to_memory else 0x0E)
        await self.cpu(0x0C, address)
        await self.os_register(profile, 0x10, 0 if profile == "amiga" else 1)

    async def finish_os_dma(self, profile, to_memory):
        if profile == "linux":
            await self.os_register(profile, 0x08, 0x08 if to_memory else 0x0A)
        if profile == "amiga" or to_memory:
            await self.os_register(profile, 0x14, 0 if profile == "amiga" else 1)
            for _ in range(1000):
                if (await self.os_register(profile, 0x1C)) & 1:
                    break
                # Inter-instruction opportunity for Buster to grant the bus.
                # No unconditional settling delay before the first status read.
                await Timer(40, units="ns")
            else:
                raise AssertionError("OS FIFO-empty polling timed out")
        completed = dict(self.memory)
        if profile == "linux":
            await self.os_register(profile, 0x18, 1)
        await self.os_register(profile, 0x3C, 0 if profile == "amiga" else 1)
        if profile == "linux":
            await self.os_register(profile, 0x08, 0x0C)
        await wait_for(lambda: value(self.d.dmaen_n), "OS stop releases DMA bus")
        await Timer(200, units="ns")
        return completed

    async def arbiter(self):
        """Buster SBR/SBG channel, with primary-master service latency."""
        d = self.d
        while True:
            await wait_for(lambda: not value(d.br_n), "SDMAC bus request")
            await Timer(self.grant_delay, units="ns")
            await wait_for(lambda: not self.cpu_pending and not value(d.cpu_enable),
                           "primary master completes CPU transaction")
            if self.handoff != "idle":
                # A grant may precede completion of the old master's last cycle.
                # Drive an unrelated address, not the SDMAC register window.
                d.cpu_address.value = 0x00100000
                d.cpu_enable.value = 1
                d.cpu_as_n.value = 0
                d.cpu_ds_n.value = 0
                d.cpu_rw.value = 1
                if self.handoff == "owner":
                    d.other_owner.value = 1
                elif self.handoff == "dsack":
                    d.response_n.value = 0
                elif self.handoff == "sterm":
                    d.sterm_n.value = 0
                await Timer(40, units="ns")
            d.grant_n.value = 0
            if self.handoff != "idle":
                await Timer(160, units="ns")
                assert value(d.dmaen_n), "Accepted grant while previous AS active"
                d.cpu_as_n.value = 1
                d.cpu_ds_n.value = 1
                await Timer(10, units="ns")
                d.cpu_enable.value = 0
                if self.handoff in ("dsack", "sterm", "owner"):
                    await Timer(20, units="ns")
                    assert value(d.dmaen_n), "Accepted grant before previous responder/owner releases"
                d.response_n.value = 3
                d.sterm_n.value = 1
                d.other_owner.value = 0
                self.handoffs += 1
            await wait_for(lambda: not value(d.dmaen_n), "SDMAC accepts SBG")
            assert value(d.bgack_n) == 0
            self.grants += 1
            await wait_for(lambda: value(d.br_n), "SDMAC releases SBR")
            d.grant_n.value = 1
            await wait_for(lambda: value(d.dmaen_n), "SDMAC relinquishes bus")
            await Timer(40, units="ns")

    def read_word(self, address, count):
        return bytes(self.memory.get(a, memory_byte(a)) for a in range(address, address + count))

    async def memory_slave(self):
        d = self.d
        while True:
            await wait_for(lambda: not value(d.dmaen_n) and not value(d.as_n),
                           "next DMA memory cycle")
            address = value(d.address)
            read = value(d.rw)
            assert value(d.bgack_n) == 0, "DMA cycle without BGACK"
            assert value(d.cs_n) == 1, "DMA unexpectedly selects SDMAC register window"
            await wait_for(lambda: not value(d.ds_n), "DMA data strobe", 3000)
            size = 2 if value(d.siz1) else 4
            port = 2 if self.termination == "dsack16" else 4
            count = min(size, port - (address % port))
            assert count in (2, 4), "Only word-aligned 16/32-bit DMA is supported"
            if read:
                base = address & ~(port - 1)
                payload = self.read_word(base, port)
                d.memory_data.value = int.from_bytes(payload, "big") << (16 if port == 2 else 0)
                d.memory_mask.value = 0xFFFF0000 if port == 2 else 0xFFFFFFFF
                d.memory_enable.value = 1
            # Full wait clocks, plus an offset away from sampling edges.
            await Timer(40 * self.wait_states + self.ack_phase, units="ns")
            if self.termination == "sterm":
                # STERM changes after a falling edge, ahead of the next rising edge.
                await FallingEdge(d.clk)
                await Timer(1, units="ns")
            bus = value(d.data_bus)
            if read:
                expected_bus = value(d.memory_data) | (value(d.memory_mask) ^ 0xFFFFFFFF)
                assert bus == expected_bus, "Memory read bus contention"
            else:
                lane = 0 if port == 2 else address % 4
                payload = bus.to_bytes(4, "big")[lane:lane + count]
                for index, byte in enumerate(payload):
                    assert address + index not in self.memory, "Duplicate DMA memory write"
                    self.memory[address + index] = byte
            self.cycles.append(dict(address=address, read=read, size=size, port=port,
                                    count=count, data=bus, time_ns=float(get_sim_time(units="ns"))))
            if self.termination == "sterm":
                d.sterm_n.value = 0
            else:
                d.response_n.value = 1 if port == 2 else 0
            deadline = get_sim_time(units="ns") + 3000
            while not value(d.as_n):
                assert value(d.address) == address, "Address changed during DMA cycle"
                assert value(d.rw) == read, "Direction changed during DMA cycle"
                assert get_sim_time(units="ns") < deadline, "Timeout: DMA cycle terminates"
                await Timer(5, units="ns")
            # Ramsey clocks ACR at AS rising, based on termination seen during cycle.
            increment = 2 if port == 2 or (self.ramsey == 7 and address & 2) else 4
            self.acr = (self.acr + increment) & 0xFFFFFFFF
            d.ramsey_address.value = self.acr
            await Timer(5, units="ns")
            d.response_n.value = 3
            d.sterm_n.value = 1
            d.memory_enable.value = 0
            await Timer(5, units="ns")

    async def monitor(self):
        d = self.d
        was_owned = False
        previous_ior = previous_iow = 1
        while True:
            await Timer(5, units="ns")
            owned = value(d.dmaen_n) == 0
            for signal in (d.as_n, d.ds_n, d.rw, d.bgack_n, d.dsack_n):
                value(signal)
            if owned:
                assert not value(d.cpu_enable), "CPU and SDMAC drive control bus together"
                assert not value(d.other_owner), "SDMAC steals another master's bus"
                assert value(d.bgack_n) == 0
            if owned and not was_owned:
                assert value(d.grant_n) == 0, "Ownership without SBG"
                assert value(d.as_n) and value(d.dsack_n) == 3 and value(d.sterm_n), \
                    "Ownership before previous cycle clears"
            if was_owned and not owned:
                assert value(d.as_n) and value(d.ds_n), "Bus released during DMA cycle"
            if not value(d.as_n) and not value(d.ds_n) and (value(d.dsack_n) != 3 or not value(d.sterm_n)):
                value(d.data_bus)
            ior, iow = value(d.ior_n), value(d.iow_n)
            if previous_ior and not ior:
                assert not value(d.dack_n), "Peripheral read without DACK"
                self.peripheral_reads += 1
            if previous_iow and not iow:
                assert not value(d.dack_n), "Peripheral write without DACK"
                self.peripheral_writes += 1
            previous_ior, previous_iow = ior, iow
            was_owned = owned

    async def peripheral(self, data, to_memory):
        """WD33C93 byte handshakes; output sampled before WE rises."""
        d = self.d
        result = bytearray()
        for index, byte in enumerate(data):
            await Timer(120 + (index % 3) * 20, units="ns")
            d.dreq_n.value = 0
            strobe = d.ior_n if to_memory else d.iow_n
            await wait_for(lambda: not value(d.dack_n) and not value(strobe),
                           f"WD byte {index} handshake")
            if to_memory:
                d.peripheral_data.value = byte
                d.peripheral_enable.value = 1
            await Timer(20, units="ns")
            d.dreq_n.value = 1
            last = None
            deadline = get_sim_time(units="ns") + 3000
            while not value(strobe):
                if not to_memory:
                    last = value(d.peripheral_bus) & 255
                assert get_sim_time(units="ns") < deadline, "WD strobe stuck active"
                await Timer(5, units="ns")
            if not to_memory:
                assert last is not None
                result.append(last)
                assert last == byte, f"SCSI byte {index}: got {last:#04x}, expected {byte:#04x}"
            await Timer(10, units="ns")
            d.peripheral_enable.value = 0
            await wait_for(lambda: value(d.dack_n), "WD DACK releases", 3000)
        return bytes(result)

    async def finish(self):
        await self.cpu(0x14)  # flush memory writes / discard memory-read prefetch
        # Give the pending grant a chance to run. FIFOEMPTY alone does not
        # describe an outstanding partial word or a not-yet-completed bus cycle.
        await Timer(2000, units="ns")
        for _ in range(100):
            if (await self.cpu(0x1C)) & 1:
                break
            await Timer(400, units="ns")
        else:
            raise AssertionError("FIFO did not drain after FLUSH")
        await self.cpu(0x3C)
        await wait_for(lambda: value(self.d.dmaen_n), "final bus release")
        await Timer(200, units="ns")

    def close(self, name):
        Path(f"{name}.json").write_text(json.dumps(dict(cycles=self.cycles, acr=self.acr,
                                                       acr_cycles=self.acr_cycles,
                                                       software_cycles=self.software_cycles,
                                                       peripheral_reads=self.peripheral_reads,
                                                       peripheral_writes=self.peripheral_writes,
                                                       grants=self.grants, handoffs=self.handoffs), indent=2))
        for task in self.tasks:
            task.kill()
