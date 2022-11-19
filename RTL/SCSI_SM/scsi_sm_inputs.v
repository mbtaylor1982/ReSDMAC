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
  input scsidff1_q,
  input scsidff2_q,
  input scsidff3_q,
  input scsidff4_q,
  input scsidff5_q,  
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

  output E0_,
  output E1_,
  output E2_,
  output E3_,
  output E4_,
  output E5_,
  output E6_,
  output E7_,
  output E8_,
  output E9_,
  output E10_,
  output E11_,
  output E12_,
  output E13_,
  output E14_,
  output E15_,
  output E16_,
  output E17_,
  output E18_,
  output E19_,
  output E20_,
  output E21_,
  output E22_,
  output E23_,
  output E24_,
  output E25_,
  output E26_,
  output E27_
);
  wire nCDSACK_;
  wire nDMADIR;
  
  wire nscsidff1_q;
  wire nscsidff2_q;
  wire nscsidff3_q;
  wire nscsidff4_q;
  wire nscsidff5_q;
    
  assign nCDSACK_ = ~ CDSACK_;
  assign nDMADIR = ~ DMADIR;

  assign nscsidff1_q = ~ scsidff1_q;
  assign nscsidff2_q = ~ scsidff2_q;
  assign nscsidff3_q = ~ scsidff3_q;
  assign nscsidff4_q = ~ scsidff4_q;
  assign nscsidff5_q = ~ scsidff5_q;

  assign E1_ = ~ (~ (CCPUREQ | CDREQ_ | nDMADIR | FIFOFULL | RIFIFO_o | scsidff1_q | scsidff2_q | scsidff4_q) & nscsidff3_q & nscsidff5_q);
  assign E0_ = ~ (~ (CCPUREQ | CDREQ_ | DMADIR | FIFOEMPTY | RDFIFO_o | scsidff1_q | scsidff2_q | scsidff4_q) & scsidff5_q);
  assign E2_ = ~ (FIFOFULL & nscsidff1_q & nscsidff2_q & nscsidff3_q & scsidff4_q & scsidff5_q);
  assign E3_ = ~ (BOEQ3 & scsidff1_q & nscsidff2_q & nscsidff4_q & nscsidff5_q);
  assign E4_ = ~ (BOEQ3 & nscsidff2_q & scsidff3_q & scsidff4_q & nscsidff5_q);
  assign E5_ = ~ (~ CCPUREQ & nDMADIR & nscsidff2_q & nscsidff3_q & nscsidff4_q);
  assign E6_ = ~ (CCPUREQ & nscsidff1_q & nscsidff2_q & nscsidff3_q & nscsidff4_q);
  assign E7_ = ~ (~ FIFOFULL & nscsidff1_q & nscsidff2_q & nscsidff3_q & scsidff4_q & scsidff5_q);
  assign E8_ = ~ (~ RW & nscsidff1_q & nscsidff2_q & nscsidff3_q & scsidff4_q & nscsidff5_q);
  assign E9_ = ~ (nscsidff1_q & scsidff2_q & nscsidff3_q & nscsidff4_q & scsidff5_q);
  assign E10_ = ~ (nscsidff2_q & scsidff3_q & scsidff4_q & nscsidff5_q);
  assign E11_ = ~ (scsidff1_q & nscsidff2_q & nscsidff4_q & nscsidff5_q);
  assign E12_ = ~ (RW & nscsidff1_q & nscsidff3_q & scsidff4_q & nscsidff5_q);
  assign E13_ = ~ (nscsidff1_q & scsidff2_q & nscsidff3_q & nscsidff4_q & nscsidff5_q);
  assign E14_ = ~ (nCDSACK_ & scsidff2_q & scsidff4_q & nscsidff5_q);
  assign E15_ = ~ (scsidff2_q & scsidff3_q & nscsidff4_q & scsidff5_q);
  assign E16_ = ~ (nscsidff2_q & scsidff3_q & scsidff4_q & scsidff5_q);
  assign E17_ = ~ (scsidff2_q & scsidff3_q & scsidff4_q & scsidff5_q);
  assign E18_ = ~ (scsidff2_q & nscsidff3_q & scsidff4_q & scsidff5_q);
  assign E19_ = ~ (nCDSACK_ & scsidff1_q & scsidff4_q);
  assign E20_ = ~ (nscsidff2_q & scsidff3_q & nscsidff4_q & scsidff5_q);
  assign E21_ = ~ (nscsidff2_q & scsidff3_q & nscsidff4_q & nscsidff5_q);
  assign E22_ = ~ (scsidff2_q & scsidff3_q & nscsidff4_q & nscsidff5_q);
  assign E23_ = ~ (scsidff1_q & scsidff4_q & nscsidff5_q);
  assign E24_ = ~ (scsidff1_q & nscsidff2_q & nscsidff4_q & scsidff5_q);
  assign E25_ = ~ (scsidff1_q & scsidff2_q & scsidff5_q);
  assign E26_ = ~ (scsidff1_q & scsidff2_q & nscsidff5_q);
  assign E27_ = ~ (scsidff2_q & nscsidff3_q & scsidff4_q & nscsidff5_q);
  
endmodule
