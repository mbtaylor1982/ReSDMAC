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
  input [27:0] E,
  
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

  wire E0;
  wire E1;
  wire E2;
  wire E3;
  wire E4;
  wire E5;
  wire E6;
  wire E7;
  wire E8;
  wire E9;
  wire E10;
  wire E11;
  wire E12;
  wire E13;
  wire E14;
  wire E15;
  wire E16;
  wire E17;
  wire E18;
  wire E19;
  wire E20;
  wire E21;
  wire E22;
  wire E23;
  wire E24;
  wire E25;
  wire E26;
  wire E27;

  assign E0 = E[0];
  assign E1 = E[1];
  assign E2 = E[2];
  assign E3 = E[3];
  assign E4 = E[4];
  assign E5 = E[5];
  assign E6 = E[6];
  assign E7 = E[7];
  assign E8 = E[8];
  assign E9 = E[9];
  assign E10 = E[10];
  assign E11 = E[11];
  assign E12 = E[12];
  assign E13 = E[13];
  assign E14 = E[14];
  assign E15 = E[15];
  assign E16 = E[16];
  assign E17 = E[17];
  assign E18 = E[18];
  assign E19 = E[19];
  assign E20 = E[20];
  assign E21 = E[21];
  assign E22 = E[22];
  assign E23 = E[23];
  assign E24 = E[24];
  assign E25 = E[25];
  assign E26 = E[26];
  assign E27 = E[27];

  
  assign scsidff1_d = (E8 | E9 | E17 | E19 | E23 | E25 | E26); //checked MT
  assign scsidff2_d = (E12 | E13 | E14 | E15 | E16 | E17 | E18 | E22 | E24 | E26 | E27); //checked MT
  assign scsidff3_d = (E0 | E2 | E7 | E14 | E15 | E18 | E20 | E21 | E22 | E27); //checked MT
  assign scsidff4_d = (E0 | E1 | E6 | E12 | E14 | E15 | E19 | E20 | E23 | E24 | E25 | E27); //checked MT 
  assign scsidff5_d = (E1 | E5 | E8 | E11 | E13 | E19 | E21 | E22 | E23 | E24 | E26 | E27); //checked MT

  assign NEXT_STATE = {scsidff5_d, scsidff4_d, scsidff3_d, scsidff2_d, scsidff1_d}; //checked MT
  
  assign DACK = (E0 | E1 | E7 | E9 | E13 | E16 | E20 | E21); //checked MT
  assign INCBO = (E10 | E11); //checked MT
  assign INCNI = (E2 | E4); //checked MT
  assign INCNO = (E2 | E3); //checked MT
  assign RE =  (E7 | E12 | E17 | E20 | E21 | E25 | E26 | E27); //checked MT
  assign WE =  (E8 | E9 | E13 | E16 | E18 | E24); //checked MT
  assign SCSI_CS = ~ (E8 | E12 | E17 | E18 | E22 | E24 | E25 | E26 | E27); //checked MT
  assign SET_DSACK = (E22 | E25); //checked MT
  assign S2F = (E7 | E10 | E20 | E21); //checked MT 
  assign F2S = (E9 | E11 | E13 | E16); //checked MT 
  assign S2CPU = (E12 | E17 | E19 | E23 | E25 | E26 | E27); //checked MT   
  assign CPU2S = (E8 | E18 | E22 | E24); //checked MT 

endmodule