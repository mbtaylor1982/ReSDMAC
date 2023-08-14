## SCSI FSM State Transition Table

| Current State | Inputs                                                   | Next State | Outputs                                                 |
|---------------|----------------------------------------------------------|------------|---------------------------------------------------------|
| s0            | ~CDREQ_, ~FIFOFULL, DMADIR, ~CCPUREQ, ~RIFIFO_o         | s24        | DACK = 1                                               |
| s0            | CCPUREQ                                                  | s8         |                                                         |
| s0            | ~DMADIR, ~CCPUREQ                                        | s16        |                                                         |
| s1            |                                                          | s16        | F2S = 1, INCBO = 1, INCNO = BOEQ3, RDFIFO = BOEQ3       |
| s2            |                                                          | s18        | WE = 1, F2S = 1, DACK = 1                               |
| s3            |                                                          | s19        | RE = 1, S2CPU = 1, SCSI_CS = 1                         |
| s4            |                                                          | s20        | RE = 1, S2F = 1, DACK = 1                               |
| s6            |                                                          | s22        | CPU2S = 1, SET_DSACK = 1, SCSI_CS = 1                   |
| s8            | RW                                                       | s10        | RE = 1, S2CPU = 1, SCSI_CS = 1                         |
| s8            | ~RW                                                      | s17        | WE = 1, CPU2S = 1, SCSI_CS = 1                         |
| s9            |                                                          | s25        | S2CPU = 1                                              |
| s10           |                                                          | s30        | RE = 1, S2CPU = 1, SCSI_CS = 1                         |
| s12           |                                                          | s0         | INCBO = 1, S2F = 1, INCNI = BOEQ3, RIFIFO = BOEQ3      |
| s14           | CDSACK_                                                  | s0         |                                                         |
| s16           | ~CDREQ_, ~FIFOEMPTY, ~DMADIR, ~CCPUREQ, ~RDFIFO_o       | s28        | DACK = 1                                               |
| s16           | CCPUREQ                                                  | s8         |                                                         |
| s17           |                                                          | s26        | WE = 1, CPU2S = 1, SCSI_CS = 1                         |
| s18           |                                                          | s1         | WE = 1, F2S = 1, DACK = 1                               |
| s19           |                                                          | s9         | RE = 1, S2CPU = 1, SET_DSACK = 1                       |
| s20           |                                                          | s12        | RE = 1, S2F = 1, DACK = 1                               |
| s22           |                                                          | s14        |                                                         |
| s24           | FIFOFULL                                                 | s4         | INCNI = 1, INCNO = 1, RE = 1, S2F = 1, DACK = 1        |
| s24           | ~FIFOFULL                                                | s4         | RE = 1, S2F = 1, DACK = 1                               |
| s25           | CDSACK_                                                  | s0         |                                                         |
| s26           |                                                          | s6         | WE = 1, CPU2S = 1, SCSI_CS = 1                         |
| s28           |                                                          | s2         | WE = 1, F2S = 1, DACK = 1                               |
| s30           |                                                          | s3         | RE = 1, S2CPU = 1, SCSI_CS = 1                         |

## Summary

The state machine has multiple states (denoted as `s0`, `s1`, `s2`, etc.), each representing a different operational mode. It responds to various input signals, including control signals from the SCSI interface (`BOEQ3`, `CCPUREQ`, `CDREQ_`, `CDSACK_`, `DMADIR`, `FIFOEMPTY`, `FIFOFULL`, `RDFIFO_o`, `RIFIFO_o`, `RW`) as well as its internal state and control logic.

Here's a high-level summary of the state transitions and their associated behaviors:

- The state machine starts in an idle state (`s0`).
- Depending on various input conditions, it transitions to different states to perform tasks such as data transfer, control signal manipulation, and communication between the CPU and SCSI interface.
- The state transitions are governed by conditions involving the input signals and specific operational requirements of the SCSI protocol.
- The state machine handles read and write operations between the CPU and the SCSI interface, manages data transfer between the FIFO and SCSI, and controls various signals such as data acknowledgment (`DACK`), chip selects (`SCSI_CS`), read and write indicators (`RE`, `WE`), and more.

Overall, the state machine orchestrates the interactions between the CPU, FIFO, and SCSI interface to facilitate data transfers and protocol control in accordance with the SCSI specifications. It efficiently manages the state transitions and associated control signals to ensure proper communication and data exchange.
