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
  input cpudff1_q,
  input cpudff2_q,
  input cpudff3_q,
  input cpudff4_q,
  input cpudff5_q,
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
  output E62
);
  wire ncpudff1_q;
  wire ncpudff2_q;
  wire ncpudff3_q;
  wire ncpudff4_q;
  wire ncpudff5_q;

  wire nA1;
  wire nBGRANT_;
  wire nCYCLEDONE;
  wire nDMADIR;
  wire nDSACK0_;
  wire nDSACK1_;
  wire nFIFOEMPTY;
  wire nFIFOFULL;
  wire nLASTWORD;
  
  assign nA1 = ~ A1;
  assign nBGRANT_ = ~ BGRANT_;
  assign nCYCLEDONE = ~ CYCLEDONE;
  assign nDMADIR = ~ DMADIR;
  assign nDSACK0_ = ~ DSACK0_;
  assign nDSACK1_ = ~ DSACK1_;
  assign nFIFOEMPTY = ~ FIFOEMPTY;
  assign nFIFOFULL = ~ FIFOFULL;
  assign nLASTWORD = ~ LASTWORD;

  assign ncpudff1_q = ~ cpudff1_q;
  assign ncpudff2_q = ~ cpudff2_q;
  assign ncpudff3_q = ~ cpudff3_q;
  assign ncpudff4_q = ~ cpudff4_q;
  assign ncpudff5_q = ~ cpudff5_q;
  
  assign E0 = ~ (~ (DMADIR & FIFOEMPTY & nFIFOFULL & FLUSHFIFO) | ~ (DMAENA & nLASTWORD & ncpudff3_q & 1'b1) | ~ (ncpudff1_q & ncpudff2_q & ncpudff4_q & ncpudff5_q));//checked MT
  assign E1 = (nDMADIR & DMAENA & ~DREQ_ & FIFOEMPTY & ncpudff1_q & ncpudff2_q & ncpudff4_q & cpudff5_q);//checked MT
  assign E2 = ~ (~ (DMADIR & DMAENA & nFIFOEMPTY & FLUSHFIFO) | ~ (ncpudff1_q & ncpudff2_q & ncpudff4_q & ncpudff5_q) | cpudff3_q);//checked MT
  assign E3 = ~ (~ (DMADIR & DMAENA & FLUSHFIFO & LASTWORD) | (ncpudff1_q & ncpudff2_q & ncpudff4_q & cpudff5_q) | cpudff3_q);//Checked MT
  assign E4 = ~ (~ (~ BOEQ3 & ncpudff1_q & ncpudff3_q & ncpudff5_q) | ~ (nA1 & CYCLEDONE & nBGRANT_ &  LASTWORD) | ~ (ncpudff2_q & cpudff4_q)); //Checked MT
  assign E5 = ~ (~ (nA1 & CYCLEDONE & nBGRANT_ &  LASTWORD) | ~ (ncpudff2_q & cpudff4_q) | ~ (BOEQ3 & ncpudff1_q & ncpudff3_q & ncpudff5_q));//Checked MT
  assign E6_d = (nDSACK0_ & nDSACK1_ & cpudff1_q & cpudff2_q & ncpudff3_q & cpudff4_q & cpudff5_q);//Checked MT
  assign E7 = (DMADIR & DMAENA & FIFOFULL & ncpudff1_q & ncpudff2_q & ncpudff3_q & ncpudff4_q & ncpudff5_q);//Checked MT
  assign E8 = ~ (~ (nA1 & nBGRANT_ & CYCLEDONE & ncpudff3_q) | LASTWORD | ~ (ncpudff1_q & ncpudff2_q & cpudff4_q & ncpudff5_q));//Checked MT
  assign E9_d = (nDSACK0_ & nDSACK1_ & cpudff1_q & ncpudff3_q & ncpudff4_q & ncpudff5_q);//checked MT
  assign E10 = (A1 & nBGRANT_ & CYCLEDONE & ncpudff1_q & ncpudff2_q & ncpudff3_q & cpudff4_q & ncpudff5_q);//Checked MT
  assign E11 = (nA1 & nBGRANT_ & CYCLEDONE & ncpudff1_q & cpudff2_q & ncpudff3_q & ncpudff4_q & ncpudff5_q);//Checked MT
  assign E12 = (A1 & nBGRANT_ & CYCLEDONE & ncpudff1_q & cpudff2_q & ncpudff3_q & ncpudff4_q & ncpudff5_q);//Checked MT
  assign E13 = (nDMADIR & DMAENA & ncpudff1_q & ncpudff2_q & ncpudff4_q & ncpudff5_q);//Checked MT
  assign E14 = (nDMADIR & DREQ_ & ncpudff1_q & ncpudff4_q & cpudff5_q);//Checked MT
  assign E15 = ~ (DMADIR | FIFOEMPTY | ~ (ncpudff1_q & ncpudff4_q & cpudff5_q));//Checked MT
  assign E16 = (BGRANT_ & ncpudff1_q & cpudff2_q & ncpudff3_q & ncpudff4_q & ncpudff5_q);//Checked MT
  assign E17 = (nCYCLEDONE & ncpudff1_q & cpudff2_q & ncpudff3_q & ncpudff4_q & ncpudff5_q);//Checked MT
  assign E18 = (BGRANT_ & ncpudff1_q & ncpudff2_q & ncpudff3_q & cpudff4_q & ncpudff5_q);//Checked MT
  assign E19 = (nCYCLEDONE & ncpudff1_q & ncpudff2_q & ncpudff3_q & cpudff4_q & ncpudff5_q);//Checked MT
  assign E20_d = (nDSACK1_ & cpudff1_q & ncpudff2_q & ncpudff3_q & ncpudff4_q & ncpudff5_q);//Checked MT
  assign E21 = ~ (~ (BOEQ3 & FIFOEMPTY & LASTWORD) | cpudff2_q | ~ (cpudff3_q & cpudff4_q & cpudff5_q)); //Checked MT
  assign E22 = (~ DMAENA & ncpudff1_q & ncpudff4_q & cpudff5_q);//Checked MT
  assign E23_sd = (DSACK0_ & nDSACK1_ & cpudff2_q & cpudff3_q & cpudff4_q & ncpudff5_q);//Checked MT
  assign E24_sd = ~ (~ (cpudff1_q & ncpudff2_q & ncpudff3_q) | cpudff4_q | cpudff5_q);//Checked MT
  assign E25_d = (nDSACK0_ & nDSACK1_ & cpudff2_q & cpudff3_q & cpudff4_q & ncpudff5_q);//Checked MT
  assign E26 = ~ (BOEQ3 | ~ (FIFOEMPTY & LASTWORD & ncpudff2_q) | ~ (cpudff3_q & cpudff4_q & cpudff5_q));//Checked MT
  assign E27 = (FIFOEMPTY & nLASTWORD & ncpudff2_q & cpudff3_q & cpudff4_q & cpudff5_q);//Checked MT
  
  assign E28_d = (nDSACK1_ & cpudff1_q & cpudff2_q & cpudff3_q & ncpudff4_q & ncpudff5_q);//Checked MT
  assign E29_sd = (cpudff1_q & cpudff2_q & ncpudff3_q & ncpudff4_q & ncpudff5_q);//Checked MT
  assign E30_d = (nDSACK1_ & cpudff1_q & cpudff2_q & ncpudff3_q & ncpudff4_q & ncpudff5_q);//Checked MT
  assign E31 = (nDSACK1_ & cpudff1_q & ncpudff3_q & cpudff4_q & cpudff5_q);//Checked MT
  assign E32 = (FIFOFULL & cpudff1_q & cpudff2_q & ncpudff3_q & cpudff4_q & ncpudff5_q);//Checked MT
  assign E33_sd_E38_s = (cpudff1_q & cpudff2_q & cpudff3_q & ncpudff4_q & ncpudff5_q);//Checked MT
  assign E34 = (nFIFOEMPTY & ncpudff2_q & cpudff3_q & cpudff4_q & cpudff5_q);//Checked MT
  assign E35 = (cpudff2_q & cpudff3_q & cpudff4_q & cpudff5_q);//Checked MT
  assign E36_s_E47_s = (cpudff1_q & cpudff2_q & ncpudff3_q & ncpudff4_q & cpudff5_q);//Checked MT
  assign E37_s_E44_s = (ncpudff2_q & cpudff3_q & cpudff4_q & ncpudff5_q);//Checked MT
  assign E39_s = (cpudff1_q & ncpudff2_q & ncpudff3_q & ncpudff4_q & ncpudff5_q);//Checked MT
  assign E40_s_E41_s = (cpudff1_q & ncpudff2_q & ncpudff3_q & ncpudff4_q & cpudff5_q);//Checked MT
  assign E42_s = (cpudff1_q & cpudff2_q & ncpudff3_q & ncpudff4_q & ncpudff5_q);//Checked MT
  assign E43_s_E49_sd = (cpudff1_q & ncpudff3_q & cpudff4_q & cpudff5_q);//Checked MT
  assign E45 = (ncpudff1_q & ncpudff2_q & ncpudff3_q & cpudff4_q & cpudff5_q);//Checked MT
  assign E46_s_E59_s = (cpudff1_q & ncpudff2_q & cpudff3_q & cpudff5_q);//Checked MT
  assign E48 = (nFIFOFULL & cpudff1_q & cpudff2_q & ncpudff3_q & cpudff4_q & ncpudff5_q);//Checked MT
  assign E50_d_E52_d = (cpudff1_q & ncpudff2_q & cpudff3_q & ncpudff5_q);//Checked MT
  assign E51_s_E54_sd = (cpudff2_q & cpudff3_q & cpudff4_q & ncpudff5_q);//Checked MT
  assign E53 = (ncpudff1_q & ncpudff2_q & cpudff3_q & ncpudff4_q & ncpudff5_q);//Checked MT
  assign E55 = (ncpudff1_q & cpudff2_q & cpudff3_q);//Checked MT
  assign E56 = (ncpudff1_q & cpudff2_q & cpudff4_q & cpudff5_q);//Checked MT
  assign E57_s = (cpudff1_q & ncpudff2_q & cpudff4_q & cpudff5_q);//Checked MT
  assign E58 = (ncpudff1_q & cpudff3_q & ncpudff4_q & cpudff5_q);//Checked MT
  assign E60 = (ncpudff1_q & cpudff2_q & ncpudff4_q & cpudff5_q);//Checked MT
  assign E61 = (ncpudff1_q & cpudff2_q & cpudff4_q & ncpudff5_q);//Checked MT
  assign E62 = (cpudff1_q & ncpudff2_q & cpudff4_q & ncpudff5_q);//Checked MT
  
endmodule
