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

  output [62:0]E
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
  wire nDMAENA;

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

  assign  E[0]            = ((STATE == 5'd0) & DMAENA & DMADIR & FIFOEMPTY & nFIFOFULL & FLUSHFIFO & nLASTWORD);//s0
  assign  E[1]            = (((STATE == 5'd16) | (STATE == 5'd20)) & DMAENA & nDMADIR & FIFOEMPTY & nDREQ_);//s16 or s20
  assign  E[2]            = ((STATE == 5'd0) & DMAENA & DMADIR & nFIFOEMPTY & FLUSHFIFO);//s0
  assign  E[3]            = ((STATE == 5'd0) & DMAENA & DMADIR & FLUSHFIFO & LASTWORD);//s0
  assign  E[4]            = ((STATE == 5'd8) & CYCLEDONE & LASTWORD & nA1 & nBGRANT_ & nBOEQ3);//s8
  assign  E[5]            = ((STATE == 5'd8) & CYCLEDONE & LASTWORD & nA1 & nBGRANT_ & BOEQ3);//s8
  assign  E[6]            = ((STATE == 5'd28) & nDSACK0_ & nDSACK1_);//s28
  assign  E[7]            = ((STATE == 5'd0) & DMADIR & DMAENA & FIFOFULL);//s0
  assign  E[8]            = ((STATE == 5'd8) & CYCLEDONE & nLASTWORD & nA1 & nBGRANT_);//s8
  assign  E[9]            = (((STATE == 5'd1) | (STATE == 5'd3)) & nDSACK0_ & nDSACK1_);//s1 or s3
  assign  E[10]           = ((STATE == 5'd8) & CYCLEDONE & A1 & nBGRANT_);//s8
  assign  E[11]           = ((STATE == 5'd2) & CYCLEDONE & nA1 & nBGRANT_);//s2
  assign  E[12]           = ((STATE == 5'd2) & CYCLEDONE & A1 & nBGRANT_);//s2
  assign  E[13]           = (((STATE == 5'd0) | (STATE == 5'd4)) & nDMADIR & DMAENA);//s0 or s4
  assign  E[14]           = (((STATE == 5'd16) | (STATE == 5'd18) | (STATE == 5'd20) | (STATE == 5'd22)) & nDMADIR & DREQ_);//s16, s18, s20, s22
  assign  E[15]           = (((STATE == 5'd16) | (STATE == 5'd18) | (STATE == 5'd20) | (STATE == 5'd22)) & nDMADIR & nFIFOEMPTY);//s16, s18, s20, s22
  assign  E[16]           = ((STATE == 5'd2) & BGRANT_);//s2
  assign  E[17]           = ((STATE == 5'd2) & nCYCLEDONE);//s2
  assign  E[18]           = ((STATE == 5'd8) & BGRANT_);//s8
  assign  E[19]           = ((STATE == 5'd8) & nCYCLEDONE);//s8
  assign  E[20]           = ((STATE == 5'd1) & nDSACK1_);//s1
  assign  E[21]           = (((STATE == 5'd28) | (STATE == 5'd29)) & BOEQ3 & FIFOEMPTY & LASTWORD);//s28 or 29
  assign  E[22]           = (((STATE == 5'd16) | (STATE == 5'd18) | (STATE == 5'd20) | (STATE == 5'd22)) & nDMAENA);//s16, s18, s20, s22
  assign  E[23]           = (((STATE == 5'd14) | (STATE == 5'd15)) & DSACK0_ & nDSACK1_);//s14 or s15
  assign  E[24]           = (STATE == 5'd1);//s1
  assign  E[25]           = (((STATE == 5'd14) | (STATE == 5'd15)) & nDSACK0_ & nDSACK1_);//s14 or s15
  assign  E[26]           = (((STATE == 5'd28) | (STATE == 5'd29))& nBOEQ3 & FIFOEMPTY & LASTWORD);//s28 or 29
  assign  E[27]           = (((STATE == 5'd28) | (STATE == 5'd29)) & FIFOEMPTY & nLASTWORD);//s28 or 29
  assign  E[28]           = ((STATE == 5'd7) & nDSACK1_);//s7
  assign  E[29]           = (STATE == 5'd3);//s3
  assign  E[30]           = ((STATE == 5'd3) & nDSACK1_);//s3
  assign  E[31]           = (((STATE == 5'd25) | (STATE == 5'd27)) & nDSACK1_);//s25 or s27
  assign  E[32]           = ((STATE == 5'd11) & FIFOFULL);//s11
  assign  E[33]           = ((STATE == 5'd7));//s7   //E33_sd_E38_s
  assign  E[34]           = (((STATE == 5'd28) | (STATE == 5'd29)) & nFIFOEMPTY); //s28 or s29
  assign  E[35]           = (STATE == 5'd30) | (STATE == 5'd31);//s30 or s31
  assign  E[36]           = (STATE == 5'd19);//s19 //E36_s_E47_s
  assign  E[37]           = (STATE == 5'd12) | (STATE == 5'd13);//s12 or s13 //E37_s_E44_s
  assign  E[39]           = (STATE == 5'd1);//s1
  assign  E[40]           = (STATE == 5'd17);//s17 //E40_s_E41_s
  assign  E[42]           = (STATE == 5'd3);//s3
  assign  E[43]           = (STATE == 5'd25) | (STATE == 5'd27);//s25 or s27 //E43_s_E49_sd
  assign  E[45]           = (STATE == 5'd24);//s24
  assign  E[46]           = (STATE == 5'd21) | (STATE == 5'd29);//s21 or s29 //E46_s_E59_s
  assign  E[48]           = ((STATE == 5'd11) & nFIFOFULL );//s11
  assign  E[50]           = (STATE == 5'd5) | (STATE == 5'd13);//s5 or s13 //E50_d_E52_d
  assign  E[51]           = (STATE == 5'd14) | (STATE == 5'd15);//s14 or s15 //E51_s_E54_sd
  assign  E[53]           = (STATE == 5'd4);//s4
  assign  E[55]           = (STATE == 5'd6) | (STATE == 5'd14) | (STATE == 5'd22) | (STATE == 5'd30);//s6, s14, s22, s30
  assign  E[56]           = (STATE == 5'd26) | (STATE == 5'd30);//s26 or s30
  assign  E[57]           = (STATE == 5'd25) | (STATE == 5'd29);//s25 or s29
  assign  E[58]           = (STATE == 5'd20) | (STATE == 5'd22);//s20 or s22
  assign  E[60]           = (STATE == 5'd18) | (STATE == 5'd22);//s18 or s22
  assign  E[61]           = (STATE == 5'd10) | (STATE == 5'd14);//s10 or 14
  assign  E[62]           = (STATE == 5'd9) | (STATE == 5'd13);//s9 or s13

endmodule
