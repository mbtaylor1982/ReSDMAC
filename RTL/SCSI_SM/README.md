# SCSI State Machine Details

## STATES

| State | Condistion                                          | Next State | Outputs                    |
|-------|-----------------------------------------------------|------------|----------------------------|
| 0     | !CDREQ_ & !FIFOFULL & DMADIR & !CCPUREQ & !RIFIFO_o | 24         | DACK                       |
| 0     | !DMADIR & !CCPUREQ                                  | 16         |                            |
| 0     | CCPUREQ                                             | 8          |                            |
| 1     | BOEQ3                                               | 0          | INCNO                      |
| 1     | !DMADIR & !CCPUREQ                                  | 16         |                            |
| 1     | STATE ONLY                                          | 16         | INCBO F2S                  |
| 2     | STATE ONLY                                          | 18         | DACK WE F2S                |
| 3     | STATE ONLY                                          | 19         | RE SCSI_CS S2CPU           |
| 4     | STATE ONLY                                          | 20         | DACK RE S2F                |
| 5     | BOEQ3                                               | 0          | INCNO                      |
| 5     | STATE ONLY                                          | 16         | INCBO F2S                  |
| 5     | STATE ONLY                                          | 20         | DACK RE S2F                |
| 6     | STATE ONLY                                          | 22         | SCSI_CS SET_DSACK CPU2S    |
| 7     | STATE ONLY                                          | 19         | RE SCSI_CS SET_DSACK S2CPU |
| 8     | !RW                                                 | 17         | WE SCSI_CS CPU2S           |
| 8     | RW                                                  | 10         | RE SCSI_CS S2CPU           |
| 9     | nCDSACK_                                            | 17         | S2CPU                      |
| 9     | STATE ONLY                                          | 25         | S2CPU                      |
| 10    | RW                                                  | 10         | RE SCSI_CS S2CPU           |
| 10    | nCDSACK_                                            | 14         |                            |
| 10    | STATE ONLY                                          | 30         | RE SCSI_CS S2CPU           |
| 11    | nCDSACK_                                            | 14         |                            |
| 11    | nCDSACK_                                            | 17         | S2CPU                      |
| 11    | STATE ONLY                                          | 25         | S2CPU                      |
| 11    | STATE ONLY                                          | 19         | RE SCSI_CS S2CPU           |
| 11    | STATE ONLY                                          | 30         | RE SCSI_CS S2CPU           |
| 12    | BOEQ3                                               | 0          | INCNI                      |
| 12    | STATE ONLY                                          | 0          | INCBO S2F                  |

| 13    | BOEQ3                                               | 0          | INCNI                      |
| 13    | STATE ONLY                                          | 0          | INCBO S2F                  |
| 13    | nCDSACK_                                            | 17         | S2CPU                      |
| 13    | STATE ONLY                                          | 25         | S2CPU                      |

| 14    | nCDSACK_                                            | 14         |                            |
| 15    | nCDSACK_                                            | 31         | S2CPU                      |
| 15    | STATE ONLY                                          | 27         | RE SCSI_CS S2CPU           |
| 16    | !CDREQ_ !FIFOEMPTY !DMADIR !CCPUREQ !RDFIFO_o       | 28         | DACK                       |
| 16    | !DMADIR & !CCPUREQ                                  | 16         |                            |
| 16    | CCPUREQ                                             | 8          |                            |
| 17    | !DMADIR & !CCPUREQ                                  | 16         |                            |
| 17    | STATE ONLY                                          | 26         | WE SCSI_CS CPU2S           |
| 18    | STATE ONLY                                          | 1          | DACK WE F2S                |
| 19    | STATE ONLY                                          | 9          | RE SCSI_CS SET_DSACK S2CPU |
| 20    | !CDREQ_ !FIFOEMPTY !DMADIR !CCPUREQ !RDFIFO_o       | 28         | DACK                       |
| 20    | STATE ONLY                                          | 12         | DACK RE S2F                |
| 21    | STATE ONLY                                          | 30         | DACK RE S2F WE SCSI_CS CPU2S|
| 22    | STATE ONLY                                          | 14         |                            |
| 23    | STATE ONLY                                          | 15         | RE SCSI_CS SET_DSACK S2CPU |
| 24    | FIFOFULL                                            | 24         | DACK                       |
| 24    | !FIFOFULL                                           | 4          | RE DACK S2F                |
| 25    | nCDSACK_                                            | 17         | S2CPU                      |
| 26    | STATE ONLY                                          | 6          | WE SCSI_CS CPU2S           |
| 27    | STATE ONLY                                          | 14         | WE SCSI_CS CPU2S           |
| 27    | nCDSACK_                                            | 31         | S2CPU                      |
| 28    | STATE ONLY                                          | 2          | DACK WE F2S                |
| 29    | STATE ONLY                                          | 2          | DACK WE F2S                |
| 29    | nCDSACK_                                            | 19         | S2CPU                      |
| 30    | STATE ONLY                                          | 3          | RE SCSI_CS S2CPU           |
| 31    | nCDSACK_                                            | 27         | S2CPU                      |
| 31    | STATE ONLY                                          | 11         | RE SCSI_CS SET_DSACK S2CPU |


//Depend on state only E9-E11, E13, E15-E18, E20-E27
//Depend on State and input E0-E8, E12, E14, E19,

//STATE INFORMATION
//E0  = 10x00; s16 or s20 when CDREQ_ FIFOEMPTY DMADIR CCPUREQ RDFIFO_o = 0 
//E1  = 00000; s0 when CDREQ_ FIFOFULL nDMADIR  CCPUREQ RIFIFO_o =0
//E2  = 11000; s24 when FIFOFULL=1
//E3  = 00x01; = s1 or s5 when BOEQ3 = 1
//E4  = 0110x; s12 or s13 when BOEQ3 = 1   
//E5  = x000x; S0, s1, s16, s17, when nDMADIR=1 and CCPUREQ = 0
//E6  = x0000; s0 or s16 when CCPUREQ = 1
//E7  = 11000; s24 when FIFOFULL=0
//E8  = 01000; s8 when RW=0
//E9  = 10010; = s18
//E10 = 0110x; s12 or s13
//E11 = 00x01; s1 or s5
//E12 = 010x0; s8 or s10 when RW=1
//E13 = 00010; = s2     
//E14 = 01x1x; s10, s11, s14, s15 when nCDSACK_ = 1
//E15 = 1011x; = s22 or s23
//E16 = 1110x; s28 or s29
//E17 = 1111x; s30 or s31
//E18 = 1101x; s26 or s27
//E19 = x1xx1; s9, s11, s13, s15, s25, s27, s29 s31 when nCDSACK_=1
//E20 = 1010x; s20 or s21
//E21 = 0010x; s4 or s5
//E22 = 0011x; s6 or s7
//E23 = 01xx1; s9, s11, s13 or s15
//E24 = 10x01; s17 or s21
//E25 = 1xx11; s19, s23, s27 or  s31
//E26 = 0xx11; s3, s7, s11, or s15
//E27 = 0101x; s10 or s11

//NEXTSTATE
/*
E0  = NS-12       / DACK
E1  = NS-24       / DACK
E2  = NS-4        / INCNI INCNO
E3  = NO CHANGE   / INCNO
E4  = NO CHANGE   / INCNI
E5  = NS-16
E6  = NS-8
E7  = NS-4        / RE DACK S2F
E8  = NS-17       / WE SCSI_CS CPU2S
E9  = NS-1        / DACK WE F2S
E10 = NO CHANGE   / INCBO S2F
E11 = NS-16       / INCBO F2S

E12 = NS-10       / RE SCSI_CS S2CPU

E13 = NS-18       / DACK WE F2S
E14 = NS-14       / 
E15 = NS-14       /
E16 = NS-2        / DACK WE F2S

E17 = NS-3        / RE SCSI_CS S2CPU

E18 = NS-6        / WE SCSI_CS CPU2S
E19 = NS-17       / S2CPU
E20 = NS-12       / DACK RE S2F
E21 = NS-20       / DACK RE S2F
E22 = NS-22       / SCSI_CS SET_DSACK CPU2S
E23 = NS-25       / S2CPU
E24 = NS-26       / WE SCSI_CS CPU2S

E25 = NS-9        / RE SCSI_CS SET_DSACK S2CPU

E26 = NS-19       / RE SCSI_CS S2CPU
E27 = NS-30       / RE SCSI_CS S2CPU


State Sequence
------------------------------------------------------
|Read SCSI Reg  | 0, 16, 8, 10, 30, 3, 19, 9, 25, 0  |
|Write SCSI Reg | 0, 16, 8, 17, 26, 6, 22, 14, 0     |
------------------------------------------------------


*/
/* outputs for each state
s0 = e1 e5 e6
s1 = e3 e5 e11
s2 = e13
s3 = e26
s4 = e21
s5 = e3 e11 e21
s6 = e22
s7 = e26
s8 = e8 e12
s9 = e19 e23
s10 = e12 e14 e27
s11 = e14 e19 e23 e26 e27 
s12 = e4 e10
s13 = e4 e10 e19 e23
s14 = e14
s15 = e14 e19 e23 e26
s16 = e0 e5 e6
s17 = e5 e24
s18 = e9
s19 = e25
s20 = e0 e20
s21 = e20 e24
s22 = e15
s23 = e15 e25
s24 = e2 e7
s25 = e19
s26 = e18
s27 = e18 e19 e15
s28 = e16
s29 = e16 e19
s30 = e17
s31 = e17 e19 e25
*/