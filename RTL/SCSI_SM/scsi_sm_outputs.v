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
  input [27:0] E_,
  
  output DACK,
  output INCBO,
  output INCNI,
  output INCNO,
  output RE,
  output WE,
  output SCSI_CS,
  output SET_DSACK,
  output S2F,
  output F2S,
  output S2CPU,
  output CPU2S,
  output [4:0] NEXT_STATE
);

  wire scsidff1_d;
  wire scsidff2_d;
  wire scsidff3_d;
  wire scsidff4_d;
  wire scsidff5_d;

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

  assign E0_ = E_[0];
  assign E1_ = E_[1];
  assign E2_ = E_[2];
  assign E3_ = E_[3];
  assign E4_ = E_[4];
  assign E5_ = E_[5];
  assign E6_ = E_[6];
  assign E7_ = E_[7];
  assign E8_ = E_[8];
  assign E9_ = E_[8];
  assign E10_ = E_[10];
  assign E11_ = E_[11];
  assign E12_ = E_[12];
  assign E13_ = E_[13];
  assign E14_ = E_[14];
  assign E15_ = E_[15];
  assign E16_ = E_[16];
  assign E17_ = E_[17];
  assign E18_ = E_[18];
  assign E19_ = E_[19];
  assign E20_ = E_[20];
  assign E21_ = E_[21];
  assign E22_ = E_[22];
  assign E23_ = E_[23];
  assign E24_ = E_[24];
  assign E25_ = E_[25];
  assign E26_ = E_[26];
  assign E27_ = E_[27];


  assign scsidff1_d = ~ (E17_ & E19_ & E23_ & E25_ & E26_ & E8_ & E9_);
  assign scsidff2_d = ~ (~ (E12_ & E13_ & E14_ & E15_ & E16_ & E17_) | ~ (E18_ & E22_ & E24_ & E26_ & E27_));
  assign scsidff3_d = ~ (~ (E0_ & E14_ & E2_ & E7_) | ~ (E15_ & E18_ & E20_ & E21_ & E22_ & E27_));
  assign scsidff4_d = ~ (~ (E0_ & E12_ & E14_ & E15_ & E1_ & E6_) | ~ (E19_ & E20_ & E23_ & E24_ & E25_ & E27_));
  assign scsidff5_d = ~ (~ (E11_ & E13_ & E19_ & E1_ & E5_ & E8_) | ~ (E21_ & E22_ & E23_ & E24_ & E26_ & E27_));

  assign NEXT_STATE = {scsidff5_d, scsidff4_d, scsidff3_d, scsidff2_d, scsidff1_d};
  
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

endmodule
