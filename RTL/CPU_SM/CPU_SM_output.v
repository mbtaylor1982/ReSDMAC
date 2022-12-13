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
module CPU_SM_outputs (
    input E32, E48,
    input E2, E3, E4, E5, E7, E8, 
    input E10, E11, E12, E16, E17, E18,
    input E19,
    input E0, E21, E26, E27,
    input E56, E55, E35, E61, E50_d_E52_d,
    input E60, DSACK, E43_s_E49_sd, E57_s, STERM_,


    output nINCNI_d,
    output nBREQ_d,
    output SIZE1_d,
    output PAS_d,
    output PDS_d,
    output F2CPUL_d,
    output F2CPUH_d,
    output BRIDGEOUT_d,

    output PLLW_d,
    output PLHW_d,
    output INCFIFO_d,
    output DECFIFO_d,
    output INCNO_d,
    output nSTOPFLUSH_d,
    output DIEH_d,
    output DIEL_d,
    output nBRIDGEIN_d,
    output BGACK_d
);

assign nINCNI_d = (~(E32 | E48)); 
//assign INCNI_d = (E32 | E48);
assign nBREQ_d = (~((E2 | E3 | E4 | E5 | E7 | E8) | (E10 | E11 | E12 | E16 | E17 | E18) | E19)); 
//assign BREQ_d = ((E2 | E3 | E4 | E5 | E7 | E8) | (E10 | E11 | E12 | E16 | E17 | E18) | E19);
//assign SIZE1_d = ;
//assign PAS_d =  ;
//assign PDS_d = ;
//assign F2CPUL_d = ; 
//assign F2CPUH_d = ;
//assign BRIDGEOUT_d = ;
//assign PLLW_d = ;
assign PLHW_d = ~(~(E48 | E60) & (~(((~DSACK & E43_s_E49_sd) | E57_s) & STERM_)));
//assign INCFIFO_d = ;
//assign DECFIFO_d = ;
//assign INCNO_d = ;
assign nSTOPFLUSH_d = (~E0 & ~E4 & ~E5 & ~E21 & ~E26 & ~E27); 
//assign STOPFLUSH_d = (E0 | E4 | E5 | E21 | E26 | E27);
//assign DIEH_d = ;
//assign DIEL_d = ;
assign nBRIDGEIN_d = (~(~E56 & ~E55 & ~E35 & ~E61 & ~E50_d_E52_d));
//assign BRIDGEIN_d = ~(E56 | E55 | E35 | E61 | E50_d_E52_d);
//assign BGACK_d = ;

endmodule