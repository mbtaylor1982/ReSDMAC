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
module CPU_SM_inputs (
  input A1,
  input BGRANT_,
  input BOEQ3,
  input CYCLEDONE,
  input DMADIR,
  input DMAENA,
  input DREQ_,
  input DSACK0_,
  input DSACK1_,
  input FIFOEMPTY,
  input FIFOFULL,
  input FLUSHFIFO,
  input LASTWORD,
  input [4:0] STATE, 
 
  output [62:0]E,
  output [62:0]nE
);

  wire nA1;
  wire nBGRANT_;
  wire nCYCLEDONE;
  wire nDMADIR;
  wire nDSACK0_;
  wire nDSACK1_;
  wire nFIFOEMPTY;
  wire nFIFOFULL;
  wire nLASTWORD;
  wire nDREQ_;
  wire nBOEQ3;
   
  assign nA1          = ~A1;
  assign nBGRANT_     = ~BGRANT_;
  assign nCYCLEDONE   = ~CYCLEDONE;
  assign nDMADIR      = ~DMADIR;
  assign nDSACK0_     = ~DSACK0_;
  assign nDSACK1_     = ~DSACK1_;
  assign nFIFOEMPTY   = ~FIFOEMPTY;
  assign nFIFOFULL    = ~FIFOFULL;
  assign nLASTWORD    = ~LASTWORD;
  assign nDREQ_       = ~DREQ_;
  assign nBOEQ3       = ~BOEQ3;
  assign nDMAENA      = ~DMAENA;

  
  assign #3 nE[0]            = ~((STATE == 5'd0) & DMAENA & DMADIR & FIFOEMPTY & nFIFOFULL & FLUSHFIFO & nLASTWORD);//s0
  assign #3 E[0]             = ~nE[0];

  assign #3 nE[1]            = ~(((STATE == 5'd16) | (STATE == 5'd20)) & DMAENA & nDMADIR & FIFOEMPTY & nDREQ_);//s16 or s20
  assign #3 E[1]             = ~nE[1];

  assign #3 nE[2]            = ~((STATE == 5'd0) & DMAENA & DMADIR & nFIFOEMPTY & FLUSHFIFO);//s0
  assign #3 E[2]             = ~nE[2];

  assign #3 nE[3]            = ~((STATE == 5'd0) & DMAENA & DMADIR & FLUSHFIFO & LASTWORD);//s0
  assign #3 E[3]             = ~nE[3];

  assign #3 nE[4]            = ~((STATE == 5'd8) & CYCLEDONE & LASTWORD & nA1 & nBGRANT_ & nBOEQ3);//s8
  assign #3 E[4]             = ~nE[4];
  
  assign #3 nE[5]            = ~((STATE == 5'd8) & CYCLEDONE & LASTWORD & nA1 & nBGRANT_ & BOEQ3);//s8
  assign #3 E[5]             = ~ nE[5];

  assign #3 nE[6]            = ~((STATE == 5'd28) & nDSACK0_ & nDSACK1_);//s28
  assign #3 E[6]             = ~nE[6];
  
  assign #3 nE[7]            = ~((STATE == 5'd0) & DMADIR & DMAENA & FIFOFULL);//s0
  assign #3 E[7]             = ~ nE[7];

  assign #3 nE[8]            = ~((STATE == 5'd8) & CYCLEDONE & nLASTWORD & nA1 & nBGRANT_);//s8
  assign #3 E[8]             = ~nE[8];

  assign #3 nE[9]            = ~(((STATE == 5'd1) | (STATE == 5'd3)) & nDSACK0_ & nDSACK1_);//s1 or s3
  assign #3 E[9]             = ~nE[9];

  assign #3 nE[10]           = ~((STATE == 5'd8) & CYCLEDONE & A1 & nBGRANT_);//s8
  assign #3 E[10]            = ~nE[10];

  assign #3 nE[11]           = ~((STATE == 5'd2) & CYCLEDONE & nA1 & nBGRANT_);//s2
  assign #3 E[11]            = ~nE[11];

  assign #3 nE[12]           = ~((STATE == 5'd2) & CYCLEDONE & A1 & nBGRANT_);//s2
  assign #3 E[12]            = ~nE[12];

  assign #3 nE[13]           = ~(((STATE == 5'd0) | (STATE == 5'd4)) & nDMADIR & DMAENA);//s0 or s4
  assign #3 E[13]            = ~nE[13];

  assign #3 nE[14]           = ~(((STATE == 5'd16) | (STATE == 5'd18) | (STATE == 5'd20) | (STATE == 5'd22)) & nDMADIR & DREQ_);//s16, s18, s20, s22
  assign #3 E[14]            = ~nE[14];

  assign #3 nE[15]           = ~(((STATE == 5'd16) | (STATE == 5'd18) | (STATE == 5'd20) | (STATE == 5'd22)) & nDMADIR & nFIFOEMPTY);//s16, s18, s20, s22
  assign #3 E[15]            = ~nE[15];

  assign #3 nE[16]           = ~((STATE == 5'd2) & BGRANT_);//s2
  assign #3 E[16]            = ~nE[16];

  assign #3 nE[17]           = ~((STATE == 5'd2) & nCYCLEDONE);//s2
  assign #3 E[17]            = ~nE[17];

  assign #3 nE[18]           = ~((STATE == 5'd8) & BGRANT_);//s8
  assign #3 E[18]            = ~nE[18];

  assign #3 nE[19]           = ~((STATE == 5'd8) & nCYCLEDONE);//s8
  assign #3 E[19]            = ~nE[19];

  assign #3 nE[20]           = ~((STATE == 5'd1) & nDSACK1_);//s1
  assign #3 E[20]            = ~nE[20]; 

  assign #3 nE[21]           = ~(((STATE == 5'd28) | (STATE == 5'd29)) & BOEQ3 & FIFOEMPTY & LASTWORD);//s28 or 29
  assign #3 E[21]            = ~nE[21];
    
  //Yes E22 is different to the others, this is how it is in the schematics.
  assign #3 E[22]            = (((STATE == 5'd16) | (STATE == 5'd18) | (STATE == 5'd20) | (STATE == 5'd22)) & nDMAENA);//s16, s18, s20, s22
  assign #3 nE[22]           = ~E[22];
    
  assign #3 nE[23]           = ~(((STATE == 5'd14) | (STATE == 5'd15)) & DSACK0_ & nDSACK1_);//s14 or s15
  assign #3 E[23]            = ~nE[23];

  assign #3 nE[24]           = ~(STATE == 5'd1);//s1
  assign #3 E[24]            = ~nE[24];

  assign #3 nE[25]           = ~(((STATE == 5'd14) | (STATE == 5'd15)) & nDSACK0_ & nDSACK1_);//s14 or s15
  assign #3 E[25]            = ~nE[25];

  assign #3 nE[26]           = ~(((STATE == 5'd28) | (STATE == 5'd29))& nBOEQ3 & FIFOEMPTY & LASTWORD);//s28 or 29
  assign #3 E[26]            = ~nE[26];

  assign #3 nE[27]           = ~(((STATE == 5'd28) | (STATE == 5'd29)) & FIFOEMPTY & nLASTWORD);//s28 or 29
  assign #3 E[27]            = ~nE[27];

  assign #3 nE[28]           = ~((STATE == 5'd7) & nDSACK1_);//s7
  assign #3 E[28]            = ~nE[28];
  
  assign #3 nE[29]           = ~(STATE == 5'd3);//s3
  assign #3 E[29]            = ~nE[29];

  assign #3 nE[30]           = ~((STATE == 5'd3) & nDSACK1_);//s3
  assign #3 E[30]            = ~nE[30];

  assign #3 nE[31]           = ~(((STATE == 5'd25) | (STATE == 5'd27)) & nDSACK1_);//s25 or s27
  assign #3 E[31]            = ~nE[31];

  assign #3 nE[32]           = ~((STATE == 5'd11) & FIFOFULL);//s11
  assign #3 E[32]            = ~nE[32];

  //E33_sd_E38_s
  assign nE[33]              = ~((STATE == 5'd7));//s7
  assign #6 E[33]            = ~nE[33];

  assign #3 nE[34]           = ~(((STATE == 5'd28) | (STATE == 5'd29)) & nFIFOEMPTY); //s28 or s29
  assign #3 E[34]            = ~nE[34];

  assign #3 E[35]            = (STATE == 5'd30)  | (STATE == 5'd31);//s30 or s31
  assign #3 nE[35]           = ~E[35];

  //E36_s_E47_s
  assign nE[36]              = ~(STATE == 5'd19);//s19
  assign #6 E[36]            = ~nE[36];

  //E37_s_E44_s
  assign E[37]               = (STATE == 5'd12)  | (STATE == 5'd13);//s12 or s13
  assign #6 nE[37]           = ~E[37];
  
  assign #3 nE[39]           = ~(STATE == 5'd1);//s1
  assign #3 E[39]            = ~nE[39];

  //E40_s_E41_s
  assign nE[40]              = ~(STATE == 5'd17);//s17
  assign #6 E[40]            = ~nE[40];

  assign #3 nE[42]           = ~(STATE == 5'd3);//s3
  assign #3 E[42]            = ~nE[42];

  //E43_s_E49_sd
  assign E[43]               = (STATE == 5'd25)  | (STATE == 5'd29);//s25 or s29
  assign #6 nE[43]           = ~E[43];
  
  assign #3 nE[45]           = ~(STATE == 5'd24);//s24
  assign #3 E[45]            = ~nE[45];

  //E46_s_E59_s
  assign E[46]               = (STATE == 5'd21)  | (STATE == 5'd29);//s21 or s29
  assign #6 nE[46]           = ~E[46];
  
  assign #3 nE[48]           = ~((STATE == 5'd11) & nFIFOFULL );//s11
  assign #3 E[48]            = ~nE[48];

  //E50_d_E52_d
  assign E[50]               = (STATE == 5'd5)   | (STATE == 5'd13);//s5 or s13
  assign #6 nE[50]           = ~E[50];
  
  //E51_s_E54_sd
  assign E[51]               = (STATE == 5'd14)  | (STATE == 5'd15);//s14 or s15
  assign #6 nE[51]           = ~E[51];
  
  assign #3 nE[53]           = ~(STATE == 5'd4);//s4
  assign #3 E[53]            = ~nE[53];
  
  assign #3 E[55]            = (STATE == 5'd6)   | (STATE == 5'd14) | (STATE == 5'd22) | (STATE == 5'd30);//s6, s14, s22, s30
  assign #3 nE[55]           = ~E[55];

  assign #3 E[56]            = (STATE == 5'd26)  | (STATE == 5'd30);//s26 or s30
  assign #3 nE[56]           = ~E[56];

  assign #3 E[57]            = (STATE == 5'd25)  | (STATE == 5'd29);//s25 or s29 
  assign #3 nE[57]           = ~E[57];

  assign #3 E[58]            = (STATE == 5'd20)  | (STATE == 5'd22);//s20 or s22
  assign #3 nE[58]           = ~E[58];

  assign #3 E[60]            = (STATE == 5'd18)  | (STATE == 5'd22);//s18 or s22
  assign #3 nE[60]           = ~E[60];

  assign #3 E[61]            = (STATE == 5'd10)  | (STATE == 5'd14);//s10 or 14
  assign #3 nE[61]           = ~E[61];

  assign #3 E[62]            = (STATE == 5'd9)   | (STATE == 5'd13);//s9 or s13
  assign #3 nE[62]           = ~E[62];
  
endmodule
