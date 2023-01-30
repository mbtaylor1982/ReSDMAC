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

  output E0,
  output E1,
  output E2,
  output E3,
  output E4,
  output E5,
  output E6_d,
  output E7,
  output E8,
  output E9_d,
  output E10,
  output E11,
  output E12,
  output E13,
  output E14,
  output E15,
  output E16,
  output E17,
  output E18,
  output E19,
  output E20_d,
  output E21,
  output E22,
  output E23_sd,
  output E24_sd,
  output E25_d,
  output E26,
  output E27,
  output E28_d,
  output E29_sd,
  output E30_d,
  output E31,
  output E32,
  output E33_sd_E38_s,
  output E34,
  output E35,
  output E36_s_E47_s,
  output E37_s_E44_s,
  output E39_s,
  output E40_s_E41_s,
  output E42_s,
  output E43_s_E49_sd,
  output E45,
  output E46_s_E59_s,
  output E48,
  output E50_d_E52_d,
  output E51_s_E54_sd,
  output E53,
  output E55,
  output E56,
  output E57_s,
  output E58,
  output E60,
  output E61,
  output E62,
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

  assign E0             = ((STATE == 5'd0) & DMAENA & DMADIR & FIFOEMPTY & nFIFOFULL & FLUSHFIFO & nLASTWORD);//s0
  assign E1             = (((STATE == 5'd16) | (STATE == 5'd20)) & DMAENA & nDMADIR & FIFOEMPTY & nDREQ_);//s16 or s20
  assign E2             = ((STATE == 5'd0) & DMAENA & DMADIR & nFIFOEMPTY & FLUSHFIFO);//s0

  assign E3             = ((STATE == 5'd0) & DMAENA & DMADIR & FLUSHFIFO & LASTWORD);//s0

  assign E4             = ((STATE == 5'd8) & CYCLEDONE & LASTWORD & nA1 & nBGRANT_ & nBOEQ3);//s8
  
  assign E5             = ((STATE == 5'd8) & CYCLEDONE & LASTWORD & nA1 & nBGRANT_ & BOEQ3);//s8
  assign E6_d           = ((STATE == 5'd28) & nDSACK0_ & nDSACK1_);//s28
  assign E7             = ((STATE == 5'd0) & DMADIR & DMAENA & FIFOFULL);//s0
  assign E8             = ((STATE == 5'd8) & CYCLEDONE & nLASTWORD & nA1 & nBGRANT_);//s8
  assign E9_d           = (((STATE == 5'd1) | (STATE == 5'd3)) & nDSACK0_ & nDSACK1_);//s1 or s3
  assign E10            = ((STATE == 5'd8) & CYCLEDONE & A1 & nBGRANT_);//s8
  assign E11            = ((STATE == 5'd2) & CYCLEDONE & nA1 & nBGRANT_);//s2
  assign E12            = ((STATE == 5'd2) & CYCLEDONE & A1 & nBGRANT_);//s2
  assign E13            = (((STATE == 5'd0) | (STATE == 5'd4)) & nDMADIR & DMAENA);//s0 or s4
  assign E14            = (((STATE == 5'd16) | (STATE == 5'd18) | (STATE == 5'd20) | (STATE == 5'd22)) & nDMADIR & DREQ_);//s16, s18, s20, s22
  assign E15            = (((STATE == 5'd16) | (STATE == 5'd18) | (STATE == 5'd20) | (STATE == 5'd22)) & nDMADIR & nFIFOEMPTY);//s16, s18, s20, s22
  assign E16            = ((STATE == 5'd2) & BGRANT_);//s2
  assign E17            = ((STATE == 5'd2) & nCYCLEDONE);//s2
  assign E18            = ((STATE == 5'd8) & BGRANT_);//s8
  
  assign E19            = ((STATE == 5'd8) & nCYCLEDONE);//s8

  assign E20_d          = ((STATE == 5'd1) & nDSACK1_);//s1
  assign E21            = (((STATE == 5'd28) | (STATE == 5'd29)) & BOEQ3 & FIFOEMPTY & LASTWORD);//s28 or 29
  assign E22            = (((STATE == 5'd16) | (STATE == 5'd18) | (STATE == 5'd20) | (STATE == 5'd22)) & nDMAENA);//s16, s18, s20, s22
  assign E23_sd         = (((STATE == 5'd14) | (STATE == 5'd15)) & DSACK0_ & nDSACK1_);//s14 or s15
  assign E24_sd         = (STATE == 5'd1);//s1
  assign E25_d          = (((STATE == 5'd14) | (STATE == 5'd15)) & nDSACK0_ & nDSACK1_);//s14 or s15
  assign E26            = (((STATE == 5'd28) | (STATE == 5'd29))& nBOEQ3 & FIFOEMPTY & LASTWORD);//s28 or 29
  assign E27            = (((STATE == 5'd28) | (STATE == 5'd29)) & FIFOEMPTY & nLASTWORD);//s28 or 29
  assign E28_d          = ((STATE == 5'd7) & nDSACK1_);//s7
  assign E29_sd         = (STATE == 5'd3);//s3
  assign E30_d          = ((STATE == 5'd3) & nDSACK1_);//s3
  assign E31            = (((STATE == 5'd25) | (STATE == 5'd27)) & nDSACK1_);//s25 or s27
  assign E32            = ((STATE == 5'd11) & FIFOFULL);//s11
  assign E33_sd_E38_s   = ((STATE == 5'd7));//s7
  assign E34            = (((STATE == 5'd28) | (STATE == 5'd29)) & nFIFOEMPTY); //s28 or s29
  assign E35            = (STATE == 5'd30)  | (STATE == 5'd31);//s30 or s31
  assign E36_s_E47_s    = (STATE == 5'd19);//s19
  assign E37_s_E44_s    = (STATE == 5'd12)  | (STATE == 5'd13);//s12 or s13
  assign E39_s          = (STATE == 5'd1);//s1
  assign E40_s_E41_s    = (STATE == 5'd17);//s17
  assign E42_s          = (STATE == 5'd3);//s3
  assign E43_s_E49_sd   = (STATE == 5'd25)  | (STATE == 5'd29);//s25 or s29
  assign E45            = (STATE == 5'd24);//s24
  assign E46_s_E59_s    = (STATE == 5'd21)  | (STATE == 5'd29);//s21 or s29
  assign E48            = ((STATE == 5'd11) & nFIFOFULL );//s11
  assign E50_d_E52_d    = (STATE == 5'd5)   | (STATE == 5'd13);//s5 or s13
  assign E51_s_E54_sd   = (STATE == 5'd14)  | (STATE == 5'd15);//s14 or s15
  assign E53            = (STATE == 5'd4);//s4
  assign E55            = (STATE == 5'd6)   | (STATE == 5'd14) | (STATE == 5'd22) | (STATE == 5'd30);//s6, s14, s22, s30
  assign E56            = (STATE == 5'd26)  | (STATE == 5'd30);//s26 or s30
  assign E57_s          = (STATE == 5'd25)  | (STATE == 5'd29);//s25 or s29 
  assign E58            = (STATE == 5'd20)  | (STATE == 5'd22);//s20 or s22
  assign E60            = (STATE == 5'd18)  | (STATE == 5'd22);//s18 or s22
  assign E61            = (STATE == 5'd10)  | (STATE == 5'd14);//s10 or 14
  assign E62            = (STATE == 5'd9)   | (STATE == 5'd13);//s9 or s13
  
endmodule
