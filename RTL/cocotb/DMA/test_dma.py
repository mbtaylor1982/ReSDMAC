from pathlib import Path

import pytest
from cocotb_test.simulator import run


@pytest.mark.parametrize("termination", ["sterm", "dsack32", "dsack16"])
@pytest.mark.parametrize("direction", ["to_memory", "to_scsi"])
def test_dma(direction, termination):
    here = Path(__file__).resolve().parent
    root = here.parents[2]
    run(
        # Icarus sources include the sequencers/registers indirectly; the
        # simulator cache does not track those include-file dependencies.
        force_compile=True,
        verilog_sources=[str(here / "dma_wrapper.v"), str(root / "RTL/RESDMAC.v")],
        toplevel="dma_wrapper",
        module="cocotb_dma",
        python_search=[str(here)],
        sim_build=str(root / "sim_build" / f"dma_{direction}_{termination}"),
        includes=[str(root / "RTL" / part) for part in
                  ("", "SCSI_SM", "CPU_SM", "datapath", "FIFO", "Registers")],
        timescale="1ns/100ps",
        extra_env={"DMA_DIRECTION": direction, "DMA_TERMINATION": termination},
    )
