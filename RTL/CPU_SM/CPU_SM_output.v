//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

module CPU_SM_outputs (
    input DSACK,
    input nSTERM,
    input nRDFIFO,
    input nRIFIFO,
    input nBGRANT,
    input CYCLEDONE,
    input [4:0] STATE,
    input [62:0]E,


    output INCNI,
    output BREQ,
    output SIZE1,
    output PAS,
    output PDS,
    output F2CPUL,
    output F2CPUH,
    output BRIDGEOUT,

    output PLLW,
    output PLHW,
    output INCFIFO,
    output DECFIFO,
    output INCNO,
    output STOPFLUSH,
    output DIEH,
    output DIEL,
    output BRIDGEIN,
    output BGACK,
    output [4:0] NEXT_STATE
);

//Next-state equations 
//0 = LSB
assign NEXT_STATE[0] = E[12] | E[26] | E[53] | E[27] | E[32] | E[48] | E[55] | E[56] | E[58] | E[60] | E[62] | (E[6] & DSACK) | (E[25] & DSACK) | (E[50] & DSACK) | (E[50] & ~DSACK) | (E[43] & ~nSTERM) | (E[46] & ~nSTERM) | (E[51] & ~nSTERM) | (E[36] & nSTERM) | (E[37] & nSTERM) | (E[40] & nSTERM) | (E[46] & nSTERM) | (E[57] & nSTERM) | (E[23] & DSACK & nSTERM) | (E[24] & ~DSACK & nSTERM) | (E[29] & ~DSACK & nSTERM) | (E[33] & ~DSACK & nSTERM) | (E[43] & ~DSACK & nSTERM) | (E[51] & ~DSACK & nSTERM);

assign NEXT_STATE[1] = E[1] | E[11] | E[16] | E[17] | E[26] | E[27] | E[31] | E[32] | E[35] | E[55] | E[58] | E[61] | (E[25] & DSACK) | (E[50] & DSACK) | (E[43]  & ~nSTERM) | (E[46]  & ~nSTERM) | (E[51]  & ~nSTERM) | (E[36] & nSTERM) | (E[57] & nSTERM) | (E[46] & nSTERM) | (E[40] & nSTERM) | (E[23] & DSACK & nSTERM) | (E[33] & ~DSACK & nSTERM) | (E[43] & ~DSACK & nSTERM) | (E[51] & ~DSACK & nSTERM) | (E[29] & ~DSACK & nSTERM);

assign NEXT_STATE[2] = E[4] | E[10] | E[21] | E[27] | E[34] | E[32] | E[35] | E[56] | E[62] | E[45] | (E[20] & DSACK) | (E[28] & DSACK) | (E[30] & DSACK) | (E[50] & ~DSACK) | (E[36] & ~nSTERM) | (E[33] & ~nSTERM) | (E[39] & ~nSTERM) | (E[40] & ~nSTERM) | (E[42] & ~nSTERM) | (E[37] & ~nSTERM) | (E[36] & nSTERM) | (E[46] & nSTERM) | (E[23] & nSTERM & DSACK) | (E[33] & ~DSACK & nSTERM) | (E[51] & ~DSACK & nSTERM);

assign NEXT_STATE[3] = E[2] | E[3] | E[5] | E[7] | E[8] | E[12] | E[18] | E[19] | E[21] | E[31] | E[34] | E[45] | E[48] | E[55] | E[60] | E[61] | (E[9] & DSACK) | (E[50] & DSACK) | (E[25] & DSACK) | (E[28] & DSACK) | (E[30] & DSACK) | (E[51] & ~nSTERM) | (E[46] & ~nSTERM) | (E[36] & ~nSTERM) | (E[33] & ~nSTERM) | (E[39] & ~nSTERM) | (E[40] & ~nSTERM) | (E[42] & ~nSTERM) | (E[43] & ~nSTERM) | (E[37] & ~nSTERM) | (E[57] & nSTERM) | (E[46] & nSTERM) | (E[23] & DSACK & nSTERM) | (E[51] & ~DSACK & nSTERM) | (E[43] & ~DSACK & nSTERM);

assign NEXT_STATE[4] = E[5] | E[4] | E[8] | E[11] | E[26] | E[27] | E[32] | E[13] | E[14] | E[15] | E[22] | E[60] | E[61] | E[62] | E[48] | E[53] | E[58] | (E[9] & DSACK) | (E[30] & DSACK) | (E[28] & DSACK) | (E[36] & ~nSTERM) | (E[33] & ~nSTERM) | (E[39] & ~nSTERM) | (E[40] & ~nSTERM) | (E[42] & ~nSTERM) | (E[37] & ~nSTERM) | (E[23] & DSACK & nSTERM) | (E[43] & ~DSACK & & nSTERM) | (E[57] & nSTERM);

assign INCNI = (E[32] | E[48]);
assign BREQ = (E[2] | E[3] | E[4] | E[5] | E[7] | E[8] | E[10] | E[11] | E[12] | E[16] | E[17] | E[18] | E[19]);

//SIZE1
wire SIZE1_X, SIZE1_X1, SIZE1_X2, SIZE1_X3; 
wire SIZE1_Y; 
wire SIZE1_Z, SIZE1_Z1, SIZE1_Z2, SIZE1_Z3;

//assign SIZE1_X =((~E[62] & ~E[61] & ~E[58] & ~E[56] & ~E[53] & ~E[26])  & ~(~(~E[25] & ~E[28] & ~E[30] & ~E[50]) & DSACK) &  ~(E[50] & ~DSACK));
//assign SIZE1_Y = ~(~(~E[36] & ~E[33] & ~E[40] & ~E[42] & ~E[46] & ~E[51]) & ~STERM)
//assign SIZE1_Z = ~((~(~(E[23] & DSACK) & ~(~DSACK & (E[29]| E[33] | E[51]))) | (E[40] | E[36] | E[46])) & STERM);

assign SIZE1_X1 = (E[62] | E[61] | E[58] | E[56] | E[53] | E[26]);
assign SIZE1_X2 = ((E[25] | E[28] | E[30] | E[50]) & DSACK);
assign SIZE1_X3 = (E[50] & ~DSACK);
assign SIZE1_X = (SIZE1_X1| SIZE1_X2 | SIZE1_X3);

assign SIZE1_Y = ((E[36] | E[33] | E[40] | E[42] | E[46] | E[51]) & ~nSTERM);

assign SIZE1_Z1 = (E[40] | E[36] | E[46]);
assign SIZE1_Z2 = (E[23] & DSACK);
assign SIZE1_Z3 = ((E[29]| E[33] | E[51]) & ~DSACK);
assign SIZE1_Z = (SIZE1_Z1 | SIZE1_Z2 | SIZE1_Z3) & nSTERM;

assign SIZE1 = (SIZE1_X | SIZE1_Y | SIZE1_Z);

//PAS
wire PAS_X, PAS_Y;

assign PAS_X = ((E[50] & ~DSACK) | (E[62] | E[61] | E[60] | E[58] | E[56] | E[53] | E[48] | E[45] | E[34] | E[26] | E[21]));

assign PAS_Y =
(
    nSTERM &
    (
        (~DSACK & (E[24] | E[29] | E[33] | E[43] | E[51])) |
        (E[37] | E[40] | E[36] | E[57] | E[46])
    )
);

assign PAS = PAS_X | PAS_Y;

//PDS
wire PDS_X, PDS_Y;

assign PDS_X = ((E[50]  & ~DSACK) | E[48] | E[56] | E[60] | E[61] | E[62]);

/*
assign PDS_Y =
(
    nSTERM &
    (
        (~DSACK & (E[24] | E[29] | E[33] | E[43] | E[51])) |
        (E[37] | E[40] | E[36] | E[57] | E[46])
    )
);
*/

assign PDS_Y = PAS_Y; //looks like these are the same equations, possible gate saving.

assign PDS = PDS_X | PDS_Y;

//F2CPUL
wire F2CPUL_X, F2CPUL_Y, F2CPUL_Z;

assign F2CPUL_X = ((E[58] | E[53] | E[34] | E[45] | E[26] | E[21]) | ((E[20] | E[30] | E[28]) & DSACK));
assign F2CPUL_Y = (~nSTERM & (E[36] | E[33] | E[39] | E[40] | E[42] | E[37]));
assign F2CPUL_Z = (((~DSACK & (E[24]  | E[29]  | E[33] )) | (E[37] | E[40]  | E[36] )) & nSTERM);

assign F2CPUL = (F2CPUL_X | F2CPUL_Y | F2CPUL_Z);


//F2CPUH
wire F2CPUH_X, F2CPUH_Y, F2CPUH_Z;

assign F2CPUH_X = ((E[58] | E[34] | E[45] | E[26] | E[21]) | ((E[20] | E[28]) & DSACK));
assign F2CPUH_Y = (~nSTERM & (E[36] | E[33] | E[39] | E[37]));
assign F2CPUH_Z = (((~DSACK & (E[24]  | E[33] )) | (E[37] | E[36] )) & nSTERM);

assign F2CPUH = (F2CPUH_X | F2CPUH_Y | F2CPUH_Z);

//BRIDGEOUT
wire BRIDGEOUT_X, BRIDGEOUT_Y, BRIDGEOUT_Z;
assign BRIDGEOUT_X = (E[30] & DSACK);
assign BRIDGEOUT_Y = (E[42] & ~nSTERM);
assign BRIDGEOUT_Z = (E[29] & ~DSACK & nSTERM) ;
assign BRIDGEOUT = (E[40] | E[53] |BRIDGEOUT_X | BRIDGEOUT_Y | BRIDGEOUT_Z );


//PLLW
wire PLLW_X,PLLW_X1,PLLW_X2;
wire PLLW_Y,PLLW_Y1,PLLW_Y2,PLLW_Y3;

assign PLLW_X1 = (E[35] | E[56] | E[48] | E[60] | E[61] | E[62]);
assign PLLW_X2 = (E[50]  & ~DSACK);

assign PLLW_X = (PLLW_X1 | PLLW_X2);

assign PLLW_Y1 = (E[23] & DSACK);
assign PLLW_Y2 = ((E[43] | E[51] ) & ~DSACK);
assign PLLW_Y3 = (E[57] | E[46]);

assign PLLW_Y = ((PLLW_Y1 | PLLW_Y2 | PLLW_Y3) & nSTERM);

assign PLLW = (PLLW_X | PLLW_Y);

//PLHW
wire PLHW_X,PLHW_Y;

assign PLHW_X = (E[48] | E[60]);
assign PLHW_Y = (E[57] | (E[43] & ~DSACK)) & nSTERM;
assign PLHW = (PLHW_X |PLHW_Y);


//FIFO  STROBES
wire STERM_INC,STERM_DEC,DSACK_INC,SCSI_DEC,SCSI_INC,DSACK_DEC,FF;

//INC FIFO for memory reads using STERM or DSACK
assign STERM_INC = ((E[51] | E[46] | E[43]) & ~nSTERM);//s14,s15,s21,s25,s27,s29 and STERM low
assign DSACK_INC = (((E[50] | E[25] | E[6]) & DSACK ) | E[55]);//s5,s13,s14,s15,s28 and DSACK high / OR s6, s14, s22, s30
//INC FIFO when SCSI FSM requests it unless we are decrementing it
assign SCSI_INC = (~nRIFIFO & ~STERM_DEC & ~DSACK_DEC);
//increment fifo counter
assign INCFIFO = (SCSI_INC | STERM_INC | DSACK_INC);

//DEC FIFO for memory writes using STERM or DSACK
assign STERM_DEC = ((E[39] | E[40] | E[37] | E[42]) & ~nSTERM); //s1,s3,s12,s13,s17 and STERM low
assign DSACK_DEC = ((E[9] | E[30]) & DSACK);//(s1 or s3 and nDSACK0_ & nDSACK1_ ) or (s3 and nDSACK1_) with DSACK high
//DEC FIFO when SCSI FSM requests it unless we are incrementing it
assign SCSI_DEC = (~nRDFIFO & ~STERM_INC & ~DSACK_INC);
//decrement fifo counter
assign DECFIFO = (SCSI_DEC | STERM_DEC | DSACK_DEC);

//increment the next output pointer whenever data is removed and fifo Decremented
assign INCNO = (DSACK_DEC | STERM_DEC);

//FLUSH
assign STOPFLUSH = (E[0] | E[4] | E[5] | E[21] | E[26] | E[27]);

//DIEH
wire DIEH_X, DIEH_Y, DIEH_Z;

assign DIEH_X =
(
    (E[61] | E[60] | E[62] | E[31] | E[56] | E[48]) |
    ((E[25] | E[50]) & DSACK) |
    (E[50]  & ~DSACK)
);

assign DIEH_Y = ((E[43] | E[46] | E[51]) & ~nSTERM);

assign DIEH_Z =
(
    (
        ((E[51] | E[43]) & ~DSACK) |
        (E[46] | E[57])
    ) & nSTERM
);

assign DIEH = (DIEH_X | DIEH_Y | DIEH_Z);

//DIEL
wire DIEL_X, DIEL_Y, DIEL_Z;

assign DIEL_X =
(
    (E[62] | E[60] | E[48]) |
    ((E[25] | E[6]) & DSACK)
);

assign DIEL_Y = ((E[43] | E[46] | E[51]) & ~nSTERM);

assign DIEL_Z =
(
    (
        ((E[51] | E[43]) & ~DSACK) |
        (E[46] | E[57])
    ) & nSTERM
);

assign DIEL = (DIEL_X | DIEL_Y | DIEL_Z);

assign BRIDGEIN = (E[56]  | E[55]  | E[35]  | E[61]  | E[50] );

//BGACK
wire S2ORS8, BGACK_W, BGACK_X;
assign S2ORS8 = ((STATE == 5'd2) | (STATE == 5'd8));

assign BGACK_W = (~CYCLEDONE & ~nBGRANT & S2ORS8);
assign BGACK_X = (nBGRANT & S2ORS8);

assign BGACK = ~((STATE == 5'd0) | (STATE == 5'd16) | (STATE == 5'd30) | BGACK_W | BGACK_X);

endmodule