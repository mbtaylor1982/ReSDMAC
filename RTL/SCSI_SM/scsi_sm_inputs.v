 /*
// 
// Copyright (C) 2022  Mike Taylor
// This file is part of RE-SDMAC <https://github.com/mbtaylor1982/RE-SDMAC>.
// 
// RE-SDMAC is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// RE-SDMAC is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with dogtag.  If not, see <http://www.gnu.org/licenses/>.
 */

module scsi_sm_inputs(
  input [4:0] STATE,   
  input BOEQ3,
  input CCPUREQ,
  input CDREQ_,
  input CDSACK_,
  input DMADIR,
  input FIFOEMPTY,
  input FIFOFULL,
  input RDFIFO_o,
  input RIFIFO_o,
  input RW,

  output [27:0] E
);
  wire scsidff1_q;
  wire scsidff2_q;
  wire scsidff3_q;
  wire scsidff4_q;
  wire scsidff5_q; 
  
  wire nscsidff1_q;
  wire nscsidff2_q;
  wire nscsidff3_q;
  wire nscsidff4_q;
  wire nscsidff5_q;  

  wire nCDSACK_;
  wire nDMADIR;
  wire nFIFOEMPTY;
  wire nFIFOFULL;
  wire nCCPUREQ;
  wire nCDREQ_;
  wire nRW;

  assign scsidff1_q = STATE[0];
  assign scsidff2_q = STATE[1];
  assign scsidff3_q = STATE[2];
  assign scsidff4_q = STATE[3];
  assign scsidff5_q = STATE[4];

  assign nscsidff1_q = ~ scsidff1_q;
  assign nscsidff2_q = ~ scsidff2_q;
  assign nscsidff3_q = ~ scsidff3_q;
  assign nscsidff4_q = ~ scsidff4_q;
  assign nscsidff5_q = ~ scsidff5_q;    

  assign nCDSACK_   = ~CDSACK_;
  assign nDMADIR    = ~DMADIR;
  assign nFIFOEMPTY = ~FIFOEMPTY;
  assign nFIFOFULL  = ~FIFOFULL;
  assign nCCPUREQ   = ~CCPUREQ;
  assign nCDREQ_    = ~CDREQ_;
  assign nRW        = ~RW;

  assign E[0]  = (nCDREQ_ & nFIFOEMPTY & nDMADIR & nCCPUREQ & ~RDFIFO_o & nscsidff1_q & nscsidff2_q & nscsidff4_q & scsidff5_q); //checked MT
  assign E[1]  = (nCDREQ_ & nFIFOFULL & DMADIR & nCCPUREQ & ~RIFIFO_o & nscsidff1_q & nscsidff2_q & nscsidff3_q & nscsidff4_q & nscsidff5_q); //checked MT
  assign E[2]  = (FIFOFULL & nscsidff1_q & nscsidff2_q & nscsidff3_q & scsidff4_q & scsidff5_q); //checked MT
  assign E[3]  = (BOEQ3 & scsidff1_q & nscsidff2_q & nscsidff4_q & nscsidff5_q); //checked MT
  assign E[4]  = (BOEQ3 & nscsidff2_q & scsidff3_q & scsidff4_q & nscsidff5_q); //checked MT
  assign E[5]  = (nDMADIR & nCCPUREQ & nscsidff2_q & nscsidff3_q & nscsidff4_q); //checked MT
  assign E[6]  = (CCPUREQ & nscsidff1_q & nscsidff2_q & nscsidff3_q & nscsidff4_q); //checked MT
  assign E[7]  = (nFIFOFULL & nscsidff1_q & nscsidff2_q & nscsidff3_q & scsidff4_q & scsidff5_q); //checked MT
  assign E[8]  = (nRW & nscsidff1_q & nscsidff2_q & nscsidff3_q & scsidff4_q & nscsidff5_q); //checked MT
  assign E[9]  = (nscsidff1_q & scsidff2_q & nscsidff3_q & nscsidff4_q & scsidff5_q); //checked MT
  assign E[10] = (nscsidff2_q & scsidff3_q & scsidff4_q & nscsidff5_q); //checked MT
  assign E[11] = (scsidff1_q & nscsidff2_q & nscsidff4_q & nscsidff5_q); //checked MT
  assign E[12] = (RW & nscsidff1_q & nscsidff3_q & scsidff4_q & nscsidff5_q); //checked MT
  assign E[13] = (nscsidff1_q & scsidff2_q & nscsidff3_q & nscsidff4_q & nscsidff5_q); //checked MT
  assign E[14] = (nCDSACK_ & scsidff2_q & scsidff4_q & nscsidff5_q); //checked MT
  assign E[15] = (scsidff2_q & scsidff3_q & nscsidff4_q & scsidff5_q); //checked MT
  assign E[16] = (nscsidff2_q & scsidff3_q & scsidff4_q & scsidff5_q); //checked MT
  assign E[17] = (scsidff2_q & scsidff3_q & scsidff4_q & scsidff5_q); //checked MT
  assign E[18] = (scsidff2_q & nscsidff3_q & scsidff4_q & scsidff5_q); //checked MT
  assign E[19] = (nCDSACK_ & scsidff1_q & scsidff4_q); //checked MT
  assign E[20] = (nscsidff2_q & scsidff3_q & nscsidff4_q & scsidff5_q); //checked MT
  assign E[21] = (nscsidff2_q & scsidff3_q & nscsidff4_q & nscsidff5_q); //checked MT
  assign E[22] = (scsidff2_q & scsidff3_q & nscsidff4_q & nscsidff5_q); //checked MT
  assign E[23] = (scsidff1_q & scsidff4_q & nscsidff5_q); //checked MT
  assign E[24] = (scsidff1_q & nscsidff2_q & nscsidff4_q & scsidff5_q); //checked MT
  assign E[25] = (scsidff1_q & scsidff2_q & scsidff5_q); //checked MT
  assign E[26] = (scsidff1_q & scsidff2_q & nscsidff5_q); //checked MT
  assign E[27] = (scsidff2_q & nscsidff3_q & scsidff4_q & nscsidff5_q); //checked MT

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
//E13 = 00010; = s2 CPUREQ
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

/* outputs for each state
s0 = e1 e5 e6
s1 = e3 e5 e11
s2 = e13
s3 = e26
s4 = e21
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
    
endmodule
