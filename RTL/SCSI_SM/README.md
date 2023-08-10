# SCSI State Machine Details
## STATES
| State | Condition                                             | outputs                   | nextstate |
|-------|-------------------------------------------------------|---------------------------|-----------|
| 0     | !CDREQ_ & !FIFOFULL & DMADIR & !CCPUREQ & !RIFIFO_o   | DACK                      | 24        |
| 0     | !DMADIR                                               |                           | 16        |
| 0     | CCPUREQ                                               |                           | 8         |
| 1     | *State Only*                                          | INCBO, F2S                | 16        |
| 1     | BOEQ3                                                 | INCNO                     | 0         |
| 1     | !DMADIR & !CCPUREQ                                    |                           | 16        |
| 2     | *State Only*                                          | DACK, WE, F2S             | 18        |
| 3     | *State Only*                                          | RE, SCSI_CS, S2CPU        | 19        |
| 4     | *State Only*                                          | DACK, RE, S2F             | 20        |
| 5     | *State Only*                                          | INCBO, F2S                | 16        |
| 5     | *State Only*                                          | DACK, RE, S2F             | 20        |
| 5     | BOEQ3                                                 | INCNO                     | 0         |
| 6     | *State Only*                                          | SCSI_CS, SET_DSACK, CPU2S | 22        |
| 7     | *State Only*                                          | SCSI_CS, SET_DSACK, CPU2S | 22        |
| 7     | *State Only*                                          | RE, SCSI_CS, S2CPU        | 19        |
| 8     | RW                                                    | RE, SCSI_CS, S2CPU        | 10        |
| 8     | !RW                                                   | WE, SCSI_CS, CPU2S        | 17        |
| 9     | !CDSACK_                                              | S2CPU                     | 25        |
| 9     | *State Only*                                          | S2CPU                     | 25        |
| 10    | RW                                                    | RE, SCSI_CS, S2CPU        | 10        |
| 10    | !CDSACK_                                              |                           | 14        |
| 10    | *State Only*                                          | RE, SCSI_CS, S2CPU        | 30        |
| 11    | !CDSACK_                                              |                           | 14        |
| 11    | !CDSACK_                                              | S2CPU                     | 25        |
| 11    | *State Only*                                          | S2CPU                     | 25        |
| 11    | *State Only*                                          | RE, SCSI_CS, S2CPU        | 19        |
| 11    | *State Only*                                          | RE, SCSI_CS, S2CPU        | 30        |
| 12    | *State Only*                                          | INCBO, S2F                | 0         |
| 12    | BOEQ3                                                 | INCNI                     | 0         |
| 13    | *State Only*                                          | INCBO, S2F                | 0         |
| 13    | !CDSACK_                                              | S2CPU                     | 25        |
| 13    | *State Only*                                          | S2CPU                     | 25        |
| 13    | BOEQ3                                                 | INCNI                     | 0         |
| 14    | !CDSACK_                                              |                           | 14        |
| 15    | !CDSACK_                                              |                           | 14        |
| 15    | !CDSACK_                                              | S2CPU                     | 25        |
| 15    | *State Only*                                          | S2CPU                     | 25        |
| 15    | *State Only*                                          | RE, SCSI_CS, S2CPU        | 19        |
| 16    | !CDREQ_ & !FIFOEMPTY & !DMADIR & !CCPUREQ & !RDFIFO_o | DACK                      | 12        |
| 16    | !DMADIR                                               |                           | 16        |
| 16    | CCPUREQ                                               |                           | 8         |
| 17    | *State Only*                                          | WE, SCSI_CS, CPU2S        | 26        |
| 17    | !DMADIR                                               |                           | 16        |
| 18    | *State Only*                                          | DACK, WE, F2S             | 1         |
| 19    | *State Only*                                          | RE, SET_DSACK, S2CPU      | 9         |
| 20    | !CDREQ_ & !FIFOEMPTY & !DMADIR & !CCPUREQ & !RDFIFO_o | DACK                      | 12        |
| 20    | *State Only*                                          | DACK, RE, S2F             | 12        |
| 21    | *State Only*                                          | DACK, RE, S2F             | 12        |
| 21    | *State Only*                                          | WE, SCSI_CS, CPU2S        | 26        |
| 22    | *State Only*                                          |                           | 14        |
| 23    | *State Only*                                          |                           | 14        |
| 23    | *State Only*                                          | RE, SET_DSACK, S2CPU      | 9         |
| 24    | FIFOFULL                                              | INCNI, INCNO              | 4         |
| 24    | !FIFOFULL                                             | DACK, RE, S2F             | 4         |
| 25    | !CDSACK_                                              | S2CPU                     | 25        |
| 26    | *State Only*                                          | WE, SCSI_CS, CPU2S        | 6         |
| 27    | *State Only*                                          | WE, SCSI_CS, CPU2S        | 6         |
| 27    | !CDSACK_                                              | S2CPU                     | 25        |
| 27    | *State Only*                                          | RE, SET_DSACK, S2CPU      | 9         |
| 28    | *State Only*                                          | DACK, WE, F2S             | 2         |
| 29    | *State Only*                                          | DACK, WE, F2S             | 2         |
| 29    | !CDSACK_                                              | S2CPU                     | 25        |
| 30    | *State Only*                                          | RE, SCSI_CS, S2CPU        | 3         |
| 31    | *State Only*                                          | RE, SCSI_CS, S2CPU        | 3         |
| 31    | !CDSACK_                                              | S2CPU                     | 25        |
| 31    | *State Only*                                          | RE, SET_DSACK, S2CPU      | 9         |


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