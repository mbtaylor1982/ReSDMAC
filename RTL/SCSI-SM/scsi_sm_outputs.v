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

module scsi_sm_outputs  (
  input E0_,
  input E1_,
  input E2_,
  input E3_,
  input E4_,
  input E5_,
  input E6_,
  input E7_,
  input E8_,
  input E10_,
  input E9_,
  input E11_,
  input E12_,
  input E13_,
  input E14_,
  input E15_,
  input E16_,
  input E17_,
  input E18_,
  input E19_,
  input E20_,
  input E21_,
  input E22_,
  input E23_,
  input E24_,
  input E25_,
  input E26_,
  input E27_,

  output scsidff1_d,
  output scsidff2_d,
  output scsidff3_d,
  output scsidff4_d,
  output scsidff5_d,
  output DACK,
  output INCBO,
  output INCNI,
  output INCNO,
  output RE,
  output WE,
  output SCSI_CS,
  output SET_DSACK,
  output RIFIFO_d,
  output RDFIFO_d,
  output S2F,
  output F2S,
  output S2CPU,
  output CPU2S
);
  assign scsidff1_d = ~ (E17_ & E19_ & E23_ & E25_ & E26_ & E8_ & E9_);
  assign scsidff2_d = ~ (~ (E12_ & E13_ & E14_ & E15_ & E16_ & E17_) | ~ (E18_ & E22_ & E24_ & E26_ & E27_));
  assign scsidff3_d = ~ (~ (E0_ & E14_ & E2_ & E7_) | ~ (E15_ & E18_ & E20_ & E21_ & E22_ & E27_));
  assign scsidff4_d = ~ (~ (E0_ & E12_ & E14_ & E15_ & E1_ & E6_) | ~ (E19_ & E20_ & E23_ & E24_ & E25_ & E27_));
  assign scsidff5_d = ~ (~ (E11_ & E13_ & E19_ & E1_ & E5_ & E8_) | ~ (E21_ & E22_ & E23_ & E24_ & E26_ & E27_));
  
  assign DACK = ~ (E0_ & E13_ & E16_ & E1_ & E20_ & E21_ & E7_ & E9_);
  assign INCBO = ~ (E10_ & E11_);
  assign INCNI = ~ (E2_ & E4_);
  assign INCNO = ~ (E2_ & E3_);
  assign RE = ~ (E12_ & E17_ & E20_ & E21_ & E25_ & E26_ & E27_ & E7_);
  assign WE = ~ (E13_ & E16_ & E18_ & E24_ & E8_ & E9_);
  assign SCSI_CS = ~ (~ (E12_ & E17_ & E18_ & E8_) | ~ (E22_ & E24_ & E25_ & E26_ & E27_));
  assign SET_DSACK = ~ (E22_ & E25_);
  assign S2F = ~ (E10_ & E20_ & E21_ & E7_);
  assign F2S = ~ (E11_ & E13_ & E16_ & E9_);
  assign S2CPU = ~ (E12_ & E17_ & E19_ & E23_ & E25_ & E26_ & E27_);
  assign CPU2S = ~ (E18_ & E22_ & E24_ & E8_);
  assign RIFIFO_d = E4_;
  assign RDFIFO_d = E3_;
endmodule
