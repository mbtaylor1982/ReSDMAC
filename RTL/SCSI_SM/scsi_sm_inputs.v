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

  output [27:0] E_
);
  wire nCDSACK_;
  wire nDMADIR;

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

  wire E0_;
  wire E1_;
  wire E2_;
  wire E3_;
  wire E4_;
  wire E5_;
  wire E6_;
  wire E7_;
  wire E8_;
  wire E9_;
  wire E10_;
  wire E11_;
  wire E12_;
  wire E13_;
  wire E14_;
  wire E15_;
  wire E16_;
  wire E17_;
  wire E18_;
  wire E19_;
  wire E20_;
  wire E21_;
  wire E22_;
  wire E23_;
  wire E24_;
  wire E25_;
  wire E26_;
  wire E27_;
    
  assign nCDSACK_ = ~ CDSACK_;
  assign nDMADIR = ~ DMADIR;

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

//STATE INFORMATION
//E0  = 00x00; s0 or s4 when CDREQ_ FIFOEMPTY DMADIR CCPUREQ RDFIFO_o = 0
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


  //assign E0_ = ~ (~ (CDREQ_ | FIFOEMPTY | DMADIR | CCPUREQ | RDFIFO_o | scsidff1_q | scsidff2_q | scsidff4_q) & scsidff5_q); //checked MT Original
  //assign E0_ = ~ (~CDREQ_ & ~FIFOEMPTY & ~DMADIR & ~CCPUREQ & ~RDFIFO_o & nscsidff1_q & nscsidff2_q & nscsidff4_q & scsidff5_q); //NAND
  assign E0_  = (CDREQ_ | FIFOEMPTY | DMADIR | CCPUREQ | RDFIFO_o | scsidff1_q | scsidff2_q | scsidff4_q | nscsidff5_q); //OR Only
  
  //assign E1_ = ~ (~ (CDREQ_ | FIFOFULL | nDMADIR | CCPUREQ | RIFIFO_o | scsidff1_q | scsidff2_q | scsidff4_q) & nscsidff3_q & nscsidff5_q); //checked MT Original
  //assign E1_ = ~ (~CDREQ_ & ~FIFOFULL & ~nDMADIR & ~CCPUREQ & ~RIFIFO_o & nscsidff1_q & nscsidff2_q & nscsidff3_q & nscsidff4_q & nscsidff5_q); //NAND
  assign E1_  = (CDREQ_ | FIFOFULL | nDMADIR | CCPUREQ | RIFIFO_o | scsidff1_q | scsidff2_q | scsidff4_q | scsidff3_q | scsidff5_q); //OR Only
  
  assign E2_  = ~ (FIFOFULL & nscsidff1_q & nscsidff2_q & nscsidff3_q & scsidff4_q & scsidff5_q); //checked MT
  assign E3_  = ~ (BOEQ3 & scsidff1_q & nscsidff2_q & nscsidff4_q & nscsidff5_q); //checked MT
  assign E4_  = ~ (BOEQ3 & nscsidff2_q & scsidff3_q & scsidff4_q & nscsidff5_q); //checked MT
  assign E5_  = ~ (nDMADIR & ~ CCPUREQ & nscsidff2_q & nscsidff3_q & nscsidff4_q); //checked MT
  assign E6_  = ~ (CCPUREQ & nscsidff1_q & nscsidff2_q & nscsidff3_q & nscsidff4_q); //checked MT
  assign E7_  = ~ (~ FIFOFULL & nscsidff1_q & nscsidff2_q & nscsidff3_q & scsidff4_q & scsidff5_q); //checked MT
  assign E8_  = ~ (~ RW & nscsidff1_q & nscsidff2_q & nscsidff3_q & scsidff4_q & nscsidff5_q); //checked MT
  assign E9_  = ~ (nscsidff1_q & scsidff2_q & nscsidff3_q & nscsidff4_q & scsidff5_q); //checked MT
  assign E10_ = ~ (nscsidff2_q & scsidff3_q & scsidff4_q & nscsidff5_q); //checked MT
  assign E11_ = ~ (scsidff1_q & nscsidff2_q & nscsidff4_q & nscsidff5_q); //checked MT
  assign E12_ = ~ (RW & nscsidff1_q & nscsidff3_q & scsidff4_q & nscsidff5_q); //checked MT
  assign E13_ = ~ (nscsidff1_q & scsidff2_q & nscsidff3_q & nscsidff4_q & nscsidff5_q); //checked MT
  assign E14_ = ~ (nCDSACK_ & scsidff2_q & scsidff4_q & nscsidff5_q); //checked MT
  assign E15_ = ~ (scsidff2_q & scsidff3_q & nscsidff4_q & scsidff5_q); //checked MT
  assign E16_ = ~ (nscsidff2_q & scsidff3_q & scsidff4_q & scsidff5_q); //checked MT
  assign E17_ = ~ (scsidff2_q & scsidff3_q & scsidff4_q & scsidff5_q); //checked MT
  assign E18_ = ~ (scsidff2_q & nscsidff3_q & scsidff4_q & scsidff5_q); //checked MT
  assign E19_ = ~ (nCDSACK_ & scsidff1_q & scsidff4_q); //checked MT
  assign E20_ = ~ (nscsidff2_q & scsidff3_q & nscsidff4_q & scsidff5_q); //checked MT
  assign E21_ = ~ (nscsidff2_q & scsidff3_q & nscsidff4_q & nscsidff5_q); //checked MT
  assign E22_ = ~ (scsidff2_q & scsidff3_q & nscsidff4_q & nscsidff5_q); //checked MT
  assign E23_ = ~ (scsidff1_q & scsidff4_q & nscsidff5_q); //checked MT
  assign E24_ = ~ (scsidff1_q & nscsidff2_q & nscsidff4_q & scsidff5_q); //checked MT
  assign E25_ = ~ (scsidff1_q & scsidff2_q & scsidff5_q); //checked MT
  assign E26_ = ~ (scsidff1_q & scsidff2_q & nscsidff5_q); //checked MT
  assign E27_ = ~ (scsidff2_q & nscsidff3_q & scsidff4_q & nscsidff5_q); //checked MT

  assign E_[27:0] = {E27_,E26_,E25_,E24_,E23_,E22_,E21_,E20_,E19_,E18_,E17_,E16_,E15_,E14_,E13_,E12_,E11_,E10_,E9_,E8_,E7_,E6_,E5_,E4_,E3_,E2_,E1_,E0_};
  
endmodule
