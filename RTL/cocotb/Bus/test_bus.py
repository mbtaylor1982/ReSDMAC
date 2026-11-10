from pathlib import Path
from cocotb_test.simulator import run


def test_data_bus_direction():
    here = Path(__file__).resolve().parent
    root = here.parents[2]
    run(
        verilog_sources=[str(here / "bus_wrapper.v"), str(root / "RTL/RESDMAC.v")],
        toplevel="bus_wrapper",
        module="cocotb_bus",
        python_search=[str(here)],
        sim_build=str(root / "sim_build/bus_direction"),
        includes=[str(root / "RTL" / part) for part in
                  ("", "SCSI_SM", "CPU_SM", "datapath", "FIFO", "Registers")],
        timescale="1ns/100ps",
    )
