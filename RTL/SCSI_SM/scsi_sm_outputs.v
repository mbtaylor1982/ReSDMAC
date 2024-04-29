/*ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/*/

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
  //Next-state equations 
  assign NEXT_STATE[0] = (E[8] | E[9] | E[17] | E[19] | E[23] | E[25] | E[26]);
  assign NEXT_STATE[1] = (E[12] | E[13] | E[14] | E[15] | E[16] | E[17] | E[18] | E[22] | E[24] | E[26] | E[27]);
  assign NEXT_STATE[2] = (E[0] | E[2] | E[7] | E[14] | E[15] | E[18] | E[20] | E[21] | E[22] | E[27]);
  assign NEXT_STATE[3] = (E[0] | E[1] | E[6] | E[12] | E[14] | E[15] | E[19] | E[20] | E[23] | E[24] | E[25] | E[27]);
  assign NEXT_STATE[4] = (E[1] | E[5] | E[8] | E[11] | E[13] | E[19] | E[21] | E[22] | E[23] | E[24] | E[26] | E[27]);
  
  //Output equations
  assign DACK       = (E[0] | E[1] | E[7] | E[9] | E[13] | E[16] | E[20] | E[21]);
  assign INCBO      = (E[10] | E[11]);
  assign INCNI      = (E[2] | E[4]);
  assign INCNO      = (E[2] | E[3]);
  assign RE         = (E[7] | E[12] | E[17] | E[20] | E[21] | E[25] | E[26] | E[27]);
  assign WE         = (E[8] | E[9] | E[13] | E[16] | E[18] | E[24]);
  assign SCSI_CS    = (E[8] | E[12] | E[17] | E[18] | E[22] | E[24] | E[25] | E[26] | E[27]);
  assign SET_DSACK  = (E[22] | E[25]);
  assign S2F        = (E[7] | E[10] | E[20] | E[21]);
  assign F2S        = (E[9] | E[11] | E[13] | E[16]);
  assign S2CPU      = (E[12] | E[17] | E[19] | E[23] | E[25] | E[26] | E[27]);
  assign CPU2S      = (E[8] | E[18] | E[22] | E[24]);

endmodule