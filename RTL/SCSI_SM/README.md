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

The state machine has multiple states (denoted as `s0`, `s1`, `s2`, etc.), each representing a different operational mode. It responds to various input signals (`BOEQ3`, `CCPUREQ`, `CDREQ_`, `CDSACK_`, `DMADIR`, `FIFOEMPTY`, `FIFOFULL`, `RDFIFO_o`, `RIFIFO_o`, `RW`) as well as its internal state and control logic.

Here's a high-level summary of the state transitions and their associated behaviors:

- The state machine starts in an idle state (`s0`).
- Depending on various input conditions, it transitions to different states to perform tasks such as data transfer, control signal manipulation, and communication between the CPU and SCSI interface.
- The state transitions are governed by conditions involving the input signals and specific operational requirements of the SCSI protocol.
- The state machine handles read and write operations between the CPU and the SCSI interface, manages data transfer between the FIFO and SCSI, and controls various signals such as data acknowledgment (`DACK`), chip selects (`SCSI_CS`), read and write indicators (`RE`, `WE`), and more.

Overall, the state machine orchestrates the interactions between the CPU, FIFO, and SCSI interface to facilitate data transfers and protocol control in accordance with the SCSI specifications. It efficiently manages the state transitions and associated control signals to ensure proper communication and data exchange.

## Transfers between CPU and SCSI

1. The state machine starts in the idle state (`s0`).
2. A transfer is initiated  by asserting the `CCPUREQ` signal.
3. The state machine transitions to state `s8` in response to `CCPUREQ`.
4. Depending on the value of the `RW` signal (read or write), the state machine enters different paths:
   - If `RW` is high (indicating a read operation):
     5. The state machine asserts `RE` and `S2CPU`, indicating that data is being transferred from the SCSI interface to the CPU.
     6. The state machine transitions to state `s10` while maintaining `RE` and `S2CPU` signals.
     7. After the transfer is complete, the state machine transitions back to the idle state (`s0`) when the data transfer is acknowledged (`CDSACK_`).
   - If `RW` is low (indicating a write operation):
     5. The state machine asserts `WE` and `CPU2S`, indicating that data is being transferred from the CPU to the SCSI interface.
     6. The state machine transitions to state `s17` while maintaining `WE` and `CPU2S` signals.
     7. After the transfer is complete, the state machine transitions back to the idle state (`s0`) when the data transfer is acknowledged (`CDSACK_`).
    
## Transfer from SCSI to FIFO:

1. The state machine starts in the idle state (`s0`).
2. When there's a data transfer request from the SCSI interface (`CDREQ_`), the FIFO is not full (`~FIFOFULL`), and data is to be read from the SCSI interface (`DMADIR`) the state machine asserts `DACK` to acknowledge the SCSI interface's request for data transfer.
3. The state machine transitions to state `s24`.
4. If the FIFO becomes full (`FIFOFULL`), the state machine increments the next-in and next-out pointers (`INCNI` and `INCNO`) of the FIFO to keep data flowing.if the FIFO is not full then `RE`, `S2F`, and `DACK` are asserted.
5. The state machine transitions to state `s4` and continues to assert `RE`, `S2F`, and `DACK`.
6. The state machine transitions to state `s20` and continues to assert `RE`, `S2F`, and `DACK`.
7. The state machine transitions to state `s12` where the Byte counter is incremented `INCBO`. If the byte count is 3 the next in pointer is also incremented `INCNI`. 
8. The state machine then transitions back to the idle state (`s0`).

## Transfer from FIFO to SCSI:

1. The state machine starts in the idle state (`s0`).
2. When `CCPUREQ` is not asserted and data is to be written to the SCSI interface (`~DMADIR`) the state machine transitions to state `s16`
3. When there's a data transfer request from the SCSI interface (`CDREQ_`), and the FIFO is not empty (`~FIFOEMPTY`), the state machine asserts `DACK` to acknowledge the SCSI interface's request for data transfer and he state machine transitions to state `s28`.
6. In state `s28`, the state machine asserts `WE`, `F2S`, and `DACK` to transfer data from the FIFO to the SCSI interface.
7. The state machine transitions to state `s2` and continues to assert `WE`, `F2S`, and `DACK`
8. The state machine transitions to state `s18` and continues to assert `WE`, `F2S`, and `DACK`
9. The state machine transitions to state `s11` where the Byte counter is incremented `INCBO`. If the byte count is 3 the next out pointer is also incremented `INCNO`. 
10. The state machine then transitions back to the idle state (`s0`).
