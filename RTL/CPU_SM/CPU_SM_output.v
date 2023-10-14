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
    input DSACK,
    input STERM_,
    input RDFIFO_, RIFIFO_, BGRANT_, CYCLEDONE,
    input [4:0] STATE,
    input [62:0]E,


    output INCNI_d,
    output BREQ_d,
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
    output STOPFLUSH_d,
    output DIEH_d,
    output DIEL_d,
    output BRIDGEIN_d,
    output BGACK_d,
    output [4:0] NEXT_STATE
);

//Next-state equations 
assign NEXT_STATE[0] = E[12] | E[26] | E[53] | E[27] | E[32] | E[48] | E[55] | E[56] | E[58] | E[60] | E[62] | (E[6] & DSACK) | (E[25] & DSACK) | (E[50] & DSACK) | (E[50] & ~DSACK) | (E[43] & ~STERM_) | (E[46] & ~STERM_) | (E[51] & ~STERM_) | (E[36] & STERM_) | (E[37] & STERM_) | (E[40] & STERM_) | (E[46] & STERM_) | (E[57] & STERM_) | (E[23] & DSACK & STERM_) | (E[24] & ~DSACK & STERM_) | (E[29] & ~DSACK & STERM_) | (E[33] & ~DSACK & STERM_) | (E[43] & ~DSACK & STERM_) | (E[51] & ~DSACK & STERM_);
assign NEXT_STATE[1] = E[1] | E[11] | E[16] | E[17] | E[26] | E[27] | E[31] | E[32] | E[35] | E[55] | E[58] | E[61] | (E[25] & DSACK) | (E[50] & DSACK) | (E[43]  & ~STERM_) | (E[46]  & ~STERM_) | (E[51]  & ~STERM_) | (E[36] & STERM_) | (E[57] & STERM_) | (E[46] & STERM_) | (E[40] & STERM_) | (E[23] & DSACK & STERM_) | (E[33] & ~DSACK & STERM_) | (E[43] & ~DSACK & STERM_) | (E[51] & ~DSACK & STERM_) | (E[29] & ~DSACK & STERM_);
assign NEXT_STATE[2] = E[4] | E[10] | E[21] | E[27] | E[34] | E[32] | E[35] | E[56] | E[62] | E[45] | (E[20] & DSACK) | (E[28] & DSACK) | (E[30] & DSACK) | (E[50] & ~DSACK) | (E[36] & ~STERM_) | (E[33] & ~STERM_) | (E[39] & ~STERM_) | (E[40] & ~STERM_) | (E[42] & ~STERM_) | (E[37] & ~STERM_) | (E[36] & STERM_) | (E[46] & STERM_) | (E[23] & STERM_ & DSACK) | (E[33] & ~DSACK & STERM_) | (E[51] & ~DSACK & STERM_);
assign NEXT_STATE[3] = E[2] | E[3] | E[5] | E[7] | E[8] | E[12] | E[18] | E[19] | E[21] | E[31] | E[34] | E[45] | E[48] | E[55] | E[60] | E[61] | (E[9] & DSACK) | (E[50] & DSACK) | (E[25] & DSACK) | (E[28] & DSACK) | (E[30] & DSACK) | (E[51] & ~STERM_) | (E[46] & ~STERM_) | (E[36] & ~STERM_) | (E[33] & ~STERM_) | (E[39] & ~STERM_) | (E[40] & ~STERM_) | (E[42] & ~STERM_) | (E[43] & ~STERM_) | (E[37] & ~STERM_) | (E[57] & STERM_) | (E[46] & STERM_) | (E[23] & DSACK & STERM_) | (E[51] & ~DSACK & STERM_) | (E[43] & ~DSACK & STERM_);
assign NEXT_STATE[4] = E[5] | E[4] | E[8] | E[11] | E[26] | E[27] | E[32] | E[13] | E[14] | E[15] | E[22] | E[60] | E[61] | E[62] | E[48] | E[53] | E[58] | (E[9] & DSACK) | (E[30] & DSACK) | (E[28] & DSACK) | (E[36] & ~STERM_) | (E[33] & ~STERM_) | (E[39] & ~STERM_) | (E[40] & ~STERM_) | (E[42] & ~STERM_) | (E[37] & ~STERM_) | (E[23] & DSACK & STERM_) | (E[43] & ~DSACK & & STERM_) | (E[57] & STERM_);

assign INCNI_d = (E[32] | E[48]);
assign BREQ_d = (E[2] | E[3] | E[4] | E[5] | E[7] | E[8] | E[10] | E[11] | E[12] | E[16] | E[17] | E[18] | E[19]);

//SIZE1
wire SIZE1_X, SIZE1_Y, SIZE1_Z;

assign SIZE1_X = (~(E[62] | E[61] | E[58] | E[56] | E[53] | E[26]) & ~((E[25] | E[28] | E[30] | E[50] ) & DSACK) & ~(E[50]  & ~DSACK));
assign SIZE1_Y = (~STERM_ & (E[36] | E[33] | E[40] | E[42] | E[46] | E[51] ));
assign SIZE1_Z = ((~(~(E[23]  & DSACK) & ~(~DSACK & (E[29]  | E[33]  | E[51] ))) |(E[40]  | E[36]  | E[46] )) & STERM_);

assign SIZE1_d = (SIZE1_X | SIZE1_Y | SIZE1_Z);

//PAS
wire PAS_X, PAS_Y;

assign PAS_X = ((E[50] & ~DSACK) | (E[62] | E[61] | E[60] | E[58] | E[56] | E[53] | E[48] | E[45] | E[34] | E[26] | E[21]));

assign PAS_Y =
(
    STERM_ &
    (
        (~DSACK & (E[24] | E[29] | E[33] | E[43] | E[51])) |
        (E[37] | E[40] | E[36] | E[57] | E[46])
    )
);

assign PAS_d = PAS_X | PAS_Y;

//PDS
wire PDS_X, PDS_Y;

assign PDS_X = ((E[50]  & ~DSACK) | E[48] | E[56] | E[60] | E[61] | E[62]);

/*
assign PDS_Y =
(
    STERM_ &
    (
        (~DSACK & (E[24] | E[29] | E[33] | E[43] | E[51])) |
        (E[37] | E[40] | E[36] | E[57] | E[46])
    )
);
*/

assign PDS_Y = PAS_Y; //looks like these are the same equations, possible gate saving.

assign PDS_d = PDS_X | PDS_Y;

//F2CPUL
wire F2CPUL_X, F2CPUL_Y, F2CPUL_Z;

assign F2CPUL_X = (~(E[58] | E[53] | E[34] | E[45] | E[26] | E[21]) & ~((E[20] | E[30] | E[28]) & DSACK));
assign F2CPUL_Y = (~(~STERM_ & (E[36] | E[33] | E[39] | E[40] | E[42] | E[37])));
assign F2CPUL_Z = (~(((~DSACK & (E[24]  | E[29]  | E[33] )) | (E[37] | E[40]  | E[36] )) & STERM_));

assign F2CPUL_d = (~(F2CPUL_X & F2CPUL_Y & F2CPUL_Z)); 


//F2CPUH
wire F2CPUH_X, F2CPUH_Y, F2CPUH_Z;

assign F2CPUH_X = (~(E[58] | E[34] | E[45] | E[26] | E[21]) & ~((E[20] | E[28]) & DSACK));
assign F2CPUH_Y = (~(~STERM_ & (E[36] | E[33] | E[39] | E[37])));
assign F2CPUH_Z = (~(((~DSACK & (E[24]  | E[33] )) | (E[37] | E[36] )) & STERM_));

assign F2CPUH_d = (~(F2CPUH_X & F2CPUH_Y & F2CPUH_Z)); 

//BRIDGEOUT
wire BRIDGEOUT_X, BRIDGEOUT_Y, BRIDGEOUT_Z;

assign BRIDGEOUT_X = (~E[53]  & ~(E[30]  & DSACK));
assign BRIDGEOUT_Y = (~(~STERM_ & (E[42] | E[40])));
assign BRIDGEOUT_Z = (~(((~DSACK & E[29] )| E[40] ) & STERM_));

assign BRIDGEOUT_d = (~(BRIDGEOUT_X & BRIDGEOUT_Y & BRIDGEOUT_Z));

//PLLW
wire PLLW_X, PLLW_Y;

assign PLLW_X = (~(E[35] | E[56] | E[48] | E[60] | E[61] | E[62]) & ~(E[50]  & ~DSACK));
assign PLLW_Y = (~((~(~(E[23]  & DSACK) & ~(~DSACK & (E[43]  | E[51] )))|(E[57]  | E[46] )) & STERM_));

assign PLLW_d = (~(PLLW_X & PLLW_Y));

//PLHW
assign PLHW_d = ~(~(E[48]  | E[60] ) & (~(((~DSACK & E[43] ) | E[57] ) & STERM_)));

//FIFO COUNTER STROBES
wire AA,BB,CC,DD,EE,FF;

assign AA = (~((E[51] | E[46] | E[43] ) & ~STERM_));
assign BB = (~(DSACK & (E[50] | E[25] | E[6])) & ~E[55] );
assign CC = (~((E[9] | E[30]) & DSACK));
assign DD = (~(~STERM_ & (E[39] | E[40] | E[37] | E[42])));
assign EE = (~(AA & BB & ~RDFIFO_));
assign FF = (~(CC & DD & ~RIFIFO_));

assign INCFIFO_d = (~(AA & BB & FF));
assign DECFIFO_d = (~(CC & DD & EE));
assign INCNO_d = (~(CC & DD));

assign STOPFLUSH_d = (E[0] | E[4] | E[5] | E[21] | E[26] | E[27]);


//DIEH
wire DIEH_X, DIEH_Y, DIEH_Z;

assign DIEH_X = ~((E[61] | E[60] | E[62] | E[31] | E[56] | E[48]) | ((E[25] | E[50]) & DSACK) | (E[50]  & ~DSACK));
assign DIEH_Y = (~(~STERM_ & (E[43] | E[46] | E[51])));
assign DIEH_Z = (~(((~DSACK & (E[51]  | E[43] )) |(E[46]  | E[57] )) & STERM_));

assign DIEH_d = (~(DIEH_X & DIEH_Y & DIEH_Z));

//DIEL
wire DIEL_X, DIEL_Y, DIEL_Z;

assign DIEL_X = ~((E[62] | E[60] | E[48]) | ((E[25] | E[6]) & DSACK));
assign DIEL_Y = (~(~STERM_ & (E[43] | E[46]  | E[51] )));
assign DIEL_Z = (~(((~DSACK & (E[51]  | E[43] )) |(E[46]  | E[57] )) & STERM_));

assign DIEL_d = (~DIEL_X | ~DIEL_Y | ~DIEL_Z);

assign BRIDGEIN_d = (E[56]  | E[55]  | E[35]  | E[61]  | E[50] );

//BGACK
wire S2ORS8, BGACK_W, BGACK_X;
assign S2ORS8 = ((STATE == 5'd2) | (STATE == 5'd8));

assign BGACK_W = (~CYCLEDONE & ~BGRANT_ & S2ORS8);
assign BGACK_X = (BGRANT_ & S2ORS8);

assign BGACK_d = ~((STATE == 5'd0) | (STATE == 5'd16) | (STATE == 5'd30) | BGACK_W | BGACK_X);

endmodule