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
    input E36_s_E47_s, E33_sd_E38_s, E40_s_E41_s, E42_s, E46_s_E59_s, E51_s_E54_sd,
    input E62, E58, E53, E25_d, E28_d, E30_d,
    input E23_sd, E29_sd,
    input E45, E34, E24_sd, E37_s, E44_s,
    input E20_d, E39_s, E37_s_E44_s,
    input E6_d, E9_d, RDFIFO_, RIFIFO_, BGRANT_, CYCLEDONE,
    input E31, cpudff1, cpudff2, cpudff3, cpudff4, cpudff5,

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


//SIZE1
wire SIZE1_X, SIZE1_Y, SIZE1_Z;

assign SIZE1_X = (~((~E62 & ~E61 & ~E58 & ~E56 & ~E53 & ~E26) & ~(~(~E25_d & ~E28_d & ~E30_d & ~E50_d_E52_d) & DSACK) & ~(E50_d_E52_d & ~DSACK)));
assign SIZE1_Y = (~(~STERM_ & ~(~E36_s_E47_s & ~E33_sd_E38_s & ~E40_s_E41_s & ~E42_s & ~E46_s_E59_s & ~E51_s_E54_sd)));
assign SIZE1_Z = (~((~(~(E23_sd & DSACK) & ~(~DSACK & (E29_sd | E33_sd_E38_s | E51_s_E54_sd))) |(E40_s_E41_s | E36_s_E47_s | E46_s_E59_s)) & STERM_));

assign SIZE1_d = (~(SIZE1_X & SIZE1_Y & SIZE1_Z));

//PAS
wire PAS_X, PAS_Y;

assign PAS_X = (~(~(~E62 & ~E61 & ~E60 & ~E58) |~(~E56 & ~E53 & ~E48 & ~E45) | ~(~E34 & ~E26 & ~E21)) & ~(E50_d_E52_d & ~DSACK));
assign PAS_Y = (~(((~DSACK & (E24_sd | E29_sd | E33_sd_E38_s | E43_s_E49_sd | E51_s_E54_sd))|(E37_s-E44_s | E40_s_E41_s | E36_s_E47_s | E57_s | E46_s_E59_s)) & STERM_));

assign PAS_d = (~(PAS_X & PAS_Y));

//PDS
wire PDS_X, PDS_Y;

assign PDS_X = ((~E62 & ~E61 & ~E60 & ~E48 & ~E56) & ~(E50_d_E52_d & ~DSACK));
assign PDS_Y = (~(((~DSACK & (E24_sd | E29_sd | E33_sd_E38_s | E43_s_E49_sd | E51_s_E54_sd))|(E37_s-E44_s | E40_s_E41_s | E36_s_E47_s | E57_s | E46_s_E59_s)) & STERM_));
//assign PDS_Y = PAS_Y; //looks like these are the same equations, possible gate saving.

assign PDS_d = (~(PDS_X & PDS_Y));

//F2CPUL
wire F2CPUL_X, F2CPUL_Y, F2CPUL_Z;

assign F2CPUL_X = ((~E58 & ~E53 & ~E34 & ~E45 & ~E26 & ~E21) & ~(~(~E20_d & ~E30_d & ~E28_d) & DSACK));
assign F2CPUL_Y = (~(~STERM_ & ~(~E36_s_E47_s & ~E33_sd_E38_s & ~E39_s & ~E40_s_E41_s & ~E42_s & ~E37_s_E44_s)));
assign F2CPUL_Z = (~(((~DSACK & (E24_sd | E29_sd | E33_sd_E38_s)) | (E37_s_E44_s | E40_s_E41_s | E36_s_E47_s)) & STERM_));

assign F2CPUL_d = (~(F2CPUL_X & F2CPUL_Y & F2CPUL_Z)); 


//F2CPUH
wire F2CPUH_X, F2CPUH_Y, F2CPUH_Z;

assign F2CPUH_X = ((~E58  & ~E34 & ~E45 & ~E26 & ~E21) & ~(~(~E20_d & ~E28_d) & DSACK));
assign F2CPUH_Y = (~(~STERM_ & ~(~E36_s_E47_s & ~E33_sd_E38_s & ~E39_s & ~E37_s_E44_s)));
assign F2CPUH_Z = (~(((~DSACK & (E24_sd | E33_sd_E38_s)) | (E37_s_E44_s | E36_s_E47_s)) & STERM_));

assign F2CPUH_d = (~(F2CPUH_X & F2CPUH_Y & F2CPUH_Z)); 

//BRIDGEOUT
wire BRIDGEOUT_X, BRIDGEOUT_Y, BRIDGEOUT_Z;

assign BRIDGEOUT_X = (~E53 & ~(E30_d & DSACK));
assign BRIDGEOUT_Y = (~(~STERM_ & ~(~E42_s & ~E40_s_E41_s)));
assign BRIDGEOUT_Z = (~(((~DSACK & E29_sd)| E40_s_E41_s) & STERM_));

assign BRIDGEOUT_d = (~(BRIDGEOUT_X & BRIDGEOUT_Y & BRIDGEOUT_Z));

//PLLW
wire PLLW_X, PLLW_Y;

assign PLLW_X = ((~E35 & ~E56 & ~E48 & ~E60 & ~E61 & ~E62) & ~(E50_d_E52_d & ~DSACK));
assign PLLW_Y = (~((~(~(E23_sd & DSACK) & ~(~DSACK & (E43_s_E49_sd | E51_s_E54_sd)))|(E57_s | E46_s_E59_s)) & STERM_));

assign PLLW_d = (~(PLLW_X & PLLW_Y));

assign PLHW_d = ~(~(E48 | E60) & (~(((~DSACK & E43_s_E49_sd) | E57_s) & STERM_)));


//FIFO COUNTER STROBES
wire A,B,C,D,E,F;

assign A = (~(~(~E51_s_E54_sd & ~E46_s_E59_s & ~E43_s_E49_sd) & ~STERM_));
assign B = (~(DSACK & ~(~E50_d_E52_d & ~E25_d & ~E6_d)) & ~E55);
assign C = (~(~(~E9_d  & ~E30_d) & DSACK));
assign D = (~(~STERM_ & ~(~E39_s & ~E40_s_E41_s& ~E37_s_E44_s& ~E42_s)));
assign E = (~(A & B & ~RDFIFO_));
assign F = (~(C & D & ~RIFIFO_));

assign INCFIFO_d = (~(A & B & F));
assign DECFIFO_d = (~(C & D & E));
assign INCNO_d = (~(C & D));

assign nSTOPFLUSH_d = (~E0 & ~E4 & ~E5 & ~E21 & ~E26 & ~E27); 
//assign STOPFLUSH_d = (E0 | E4 | E5 | E21 | E26 | E27);

//DIEH
wire DIEH_X, DIEH_Y, DIEH_Z;

assign DIEH_X = ((~E61 & ~E60 & ~E62 & ~E31 & ~E56 & ~E48) & ~(~(~E25_d & ~E50_d_E52_d) & DSACK) & ~(E50_d_E52_d & ~DSACK));
assign DIEH_Y = (~(~STERM_ & ~(~E43_s_E49_sd & ~E46_s_E59_s & ~E51_s_E54_sd)));
assign DIEH_Z = (~(((~DSACK & (E51_s_E54_sd | E43_s_E49_sd)) |(E46_s_E59_s | E57_s)) & STERM_));

assign DIEH_d = (~(DIEH_X & DIEH_Y & DIEH_Z));

//DIEL
wire DIEL_X, DIEL_Y, DIEL_Z;

assign DIEL_X = ((~E62 & ~E60 & ~E48) & ~(~(~E25_d & ~E6_d) & DSACK));
assign DIEL_Y = (~(~STERM_ & ~(~E43_s_E49_sd & ~E46_s_E59_s & ~E51_s_E54_sd)));
assign DIEL_Z = (~(((~DSACK & (E51_s_E54_sd | E43_s_E49_sd)) |(E46_s_E59_s | E57_s)) & STERM_));

assign DIEL_d = (~(DIEL_X & DIEL_Y & DIEL_Z));

assign nBRIDGEIN_d = (~(~E56 & ~E55 & ~E35 & ~E61 & ~E50_d_E52_d));
//assign BRIDGEIN_d = ~(E56 | E55 | E35 | E61 | E50_d_E52_d);

//BGACK
wire BGACK_V, BGACK_W, BGACK_X, BGACK_Y, BGACK_Z;

assign BGACK_V = (~(cpudff5 | cpudff3 | cpudff1) & (cpudff4 ^ cpudff2));
assign BGACK_W = (~(CYCLEDONE | BGRANT_) & BGACK_V);
assign BGACK_X = (BGRANT_ & BGACK_V);
assign BGACK_Y = (~(cpudff1 | cpudff2 | cpudff3 | cpudff4));
assign BGACK_Z = (~cpudff1 & cpudff2 & cpudff3 & cpudff4 & cpudff5);

assign BGACK_d = (~(BGACK_W | BGACK_X | BGACK_Y | BGACK_Z));

endmodule