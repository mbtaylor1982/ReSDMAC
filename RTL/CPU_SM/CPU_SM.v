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

 `ifdef __ICARUS__ 

  `include "RTL/CPU_SM/cpudff1.v"
  `include "RTL/CPU_SM/cpudff2.v"
  `include "RTL/CPU_SM/cpudff3.v"
  `include "RTL/CPU_SM/cpudff4.v"
  `include "RTL/CPU_SM/cpudff5.v"
  `include "RTL/CPU_SM/CPU_SM_inputs.v"  
  `include "RTL/CPU_SM/CPU_SM_output.v"  
`endif

module CPU_SM(
    input A1,
    input aBGRANT_,   
    input aDMAENA,
    input aDREQ_,
    input aFLUSHFIFO,
    input aRESET_,
    input BOEQ0,
    input BOEQ3,
    input CLK,
    input DMADIR,
    input DSACK0_,   
    input DSACK1_,
    input FIFOEMPTY,
    input FIFOFULL,
    input RDFIFO_,
    input RIFIFO_,    
    input STERM_,
    input AS_,
    input BGACK_I_,

    output reg BGACK,
    output reg BREQ,
    output reg BRIDGEIN,
    output reg BRIDGEOUT,
    output reg DECFIFO,
    output reg DIEH,
    output reg DIEL,
    output reg F2CPUH,
    output reg F2CPUL,
    output reg INCFIFO,
    output reg INCNI,
    output reg INCNO,
    output reg PAS,
    output reg PDS,
    output reg PLHW,
    output reg PLLW,
    output reg SIZE1,
    output reg STOPFLUSH
);

reg [4:0] STATE;
wire [4:0] NEXT_STATE;

//clocked inputs
reg BGRANT_;
reg CCRESET_;
reg DMAENA;
reg DREQ_;
reg [1:0] DSACK_LATCHED_;
reg FLUSHFIFO;
reg nCYCLEDONE;

wire aCYCLEDONE_;

wire BBCLK; // CPUCLK Inverted 6 time for delay.
wire BCLK; // CPUCLK inverted 4 times for delay.
wire BGACK_d;
wire BRIDGEOUT_d;

wire cpudff1_d;
wire cpudff2_d;
wire cpudff3_d;
wire cpudff4_d;
wire cpudff5_d;

wire CYCLEDONE;

wire DECFIFO_d;
wire DIEH_d;
wire DIEL_d;
wire DSACK; 

wire E0;
wire E1;
wire E2;
wire E3;
wire E4;
wire E5;
wire E6_d;
wire E7;
wire E8;
wire E9_d;
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
wire E20_d;
wire E21;
wire E22;
wire E23_sd;
wire E24_sd;
wire E25_d;
wire E26;
wire E27;
wire E28_d;
wire E29_sd;
wire E30_d;
wire E31;
wire E32;
wire E33_sd_E38_s;
wire E34;
wire E35;
wire E36_s_E47_s;
wire E37_s_E44_s;
wire E37_s;
wire E39_s;
wire E40_s_E41_s;
wire E42_s;
wire E43_s_E49_sd;
wire E44_s;
wire E45;
wire E46_s_E59_s;
wire E48;
wire E50_d_E52_d;
wire E51_s_E54_sd;
wire E53;
wire E55;
wire E56;
wire E57_s;
wire E58;
wire E60;
wire E61;
wire E62;

wire F2CPUH_d;
wire F2CPUL_d;
wire INCFIFO_d;
wire INCNO_d;
wire nAS_;
wire nBREQ_d;
wire nBRIDGEIN_d;
wire nCLK;
wire nINCNI_d;
wire nSTOPFLUSH_d;
wire PAS_d;
wire PDS_d;
wire PLHW_d;
wire PLLW_d;
wire SIZE1_d;
wire LASTWORD;

CPU_SM_inputs u_CPU_SM_inputs(
    .A1           (A1           ),
    .BGRANT_      (BGRANT_      ),
    .BOEQ3        (BOEQ3        ),
    .CYCLEDONE    (CYCLEDONE    ),
    .DMADIR       (DMADIR       ),
    .DMAENA       (DMAENA       ),
    .DREQ_        (DREQ_        ),
    .DSACK0_      (DSACK0_      ),
    .DSACK1_      (DSACK1_      ),
    .FIFOEMPTY    (FIFOEMPTY    ),
    .FIFOFULL     (FIFOFULL     ),
    .FLUSHFIFO    (FLUSHFIFO    ),
    .LASTWORD     (LASTWORD     ),
    .STATE        (STATE        ),
    .E0           (E0           ),
    .E1           (E1           ),
    .E2           (E2           ),
    .E3           (E3           ),
    .E4           (E4           ),
    .E5           (E5           ),
    .E6_d         (E6_d         ),
    .E7           (E7           ),
    .E8           (E8           ),
    .E9_d         (E9_d         ),
    .E10          (E10          ),
    .E11          (E11          ),
    .E12          (E12          ),
    .E13          (E13          ),
    .E14          (E14          ),
    .E15          (E15          ),
    .E16          (E16          ),
    .E17          (E17          ),
    .E18          (E18          ),
    .E19          (E19          ),
    .E20_d        (E20_d        ),
    .E21          (E21          ),
    .E22          (E22          ),
    .E23_sd       (E23_sd       ),
    .E24_sd       (E24_sd       ),
    .E25_d        (E25_d        ),
    .E26          (E26          ),
    .E27          (E27          ),
    .E28_d        (E28_d        ),
    .E29_sd       (E29_sd       ),
    .E30_d        (E30_d        ),
    .E31          (E31          ),
    .E32          (E32          ),
    .E33_sd_E38_s (E33_sd_E38_s ),
    .E34          (E34          ),
    .E35          (E35          ),
    .E36_s_E47_s  (E36_s_E47_s  ),
    .E37_s_E44_s  (E37_s_E44_s  ),
    .E39_s        (E39_s        ),
    .E40_s_E41_s  (E40_s_E41_s  ),
    .E42_s        (E42_s        ),
    .E43_s_E49_sd (E43_s_E49_sd ),
    .E45          (E45          ),
    .E46_s_E59_s  (E46_s_E59_s  ),
    .E48          (E48          ),
    .E50_d_E52_d  (E50_d_E52_d  ),
    .E51_s_E54_sd (E51_s_E54_sd ),
    .E53          (E53          ),
    .E55          (E55          ),
    .E56          (E56          ),
    .E57_s        (E57_s        ),
    .E58          (E58          ),
    .E60          (E60          ),
    .E61          (E61          ),
    .E62          (E62          )
);
cpudff1 u_cpudff1(
    .DSACK        (DSACK        ),
    .E12          (E12          ),
    .E25_d        (E25_d        ),
    .E26          (E26          ),
    .E27          (E27          ),
    .E32          (E32          ),
    .E48          (E48          ),
    .E50_d_E52_d  (E50_d_E52_d  ),
    .E53          (E53          ),
    .E55          (E55          ),
    .E56          (E56          ),
    .E58          (E58          ),
    .E60          (E60          ),
    .E62          (E62          ),
    .E6_d         (E6_d         ),
    .E43_s_E49_sd (E43_s_E49_sd ),
    .E46_s_E59_s  (E46_s_E59_s  ),
    .E51_s_E54_sd (E51_s_E54_sd ),
    .STERM_       (STERM_       ),
    .E23_sd       (E23_sd       ),
    .E24_sd       (E24_sd       ),
    .E29_sd       (E29_sd       ),
    .E33_sd_E38_s (E33_sd_E38_s ),
    .E36_s_E47_s  (E36_s_E47_s  ),
    .E37_s_E44_s  (E37_s_E44_s  ),
    .E40_s_E41_s  (E40_s_E41_s  ),
    .E57_s        (E57_s        ),
    .cpudff1_d    (cpudff1_d    )
);
cpudff2 u_cpudff2(
    .E1           (E1           ),
    .E11          (E11          ),
    .E16          (E16          ),
    .E17          (E17          ),
    .E26          (E26          ),
    .E27          (E27          ),
    .E31          (E31          ),
    .E32          (E32          ),
    .E35          (E35          ),
    .E55          (E55          ),
    .E58          (E58          ),
    .E61          (E61          ),
    .E25_d        (E25_d        ),
    .E50_d_E52_d  (E50_d_E52_d  ),
    .DSACK        (DSACK        ),
    .STERM_       (STERM_       ),
    .E43_s_E49_sd (E43_s_E49_sd ),
    .E46_s_E59_s  (E46_s_E59_s  ),
    .E51_s_E54_sd (E51_s_E54_sd ),
    .E23_sd       (E23_sd       ),
    .E33_sd_E38_s (E33_sd_E38_s ),
    .E29_sd       (E29_sd       ),
    .E36_s_E47_s  (E36_s_E47_s  ),
    .E57_s        (E57_s        ),
    .E40_s_E41_s  (E40_s_E41_s  ),
    .cpudff2_d    (cpudff2_d    )
);
cpudff3 u_cpudff3(
    .E4           (E4           ),
    .E10          (E10          ),
    .E21          (E21          ),
    .E27          (E27          ),
    .E34          (E34          ),
    .E32          (E32          ),
    .E35          (E35          ),
    .E56          (E56          ),
    .E62          (E62          ),
    .E45          (E45          ),
    .E20_d        (E20_d        ),
    .E28_d        (E28_d        ),
    .E30_d        (E30_d        ),
    .DSACK        (DSACK        ),
    .E50_d_E52_d  (E50_d_E52_d  ),
    .STERM_       (STERM_       ),
    .E36_s_E47_s  (E36_s_E47_s  ),
    .E33_sd_E38_s (E33_sd_E38_s ),
    .E39_s        (E39_s        ),
    .E40_s_E41_s  (E40_s_E41_s  ),
    .E42_s        (E42_s        ),
    .E37_s_E44_s  (E37_s_E44_s  ),
    .E23_sd       (E23_sd       ),
    .E51_s_E54_sd (E51_s_E54_sd ),
    .E46_s_E59_s  (E46_s_E59_s  ),
    .cpudff3_d    (cpudff3_d    )
);
cpudff4 u_cpudff4(
    .E61          (E61          ),
    .E60          (E60          ),
    .E2           (E2           ),
    .E3           (E3           ),
    .E5           (E5           ),
    .E7           (E7           ),
    .E12          (E12          ),
    .E8           (E8           ),
    .E55          (E55          ),
    .E18          (E18          ),
    .E19          (E19          ),
    .E48          (E48          ),
    .E21          (E21          ),
    .E31          (E31          ),
    .E34          (E34          ),
    .E45          (E45          ),
    .E50_d_E52_d  (E50_d_E52_d  ),
    .E9_d         (E9_d         ),
    .E25_d        (E25_d        ),
    .E28_d        (E28_d        ),
    .E30_d        (E30_d        ),
    .DSACK        (DSACK        ),
    .STERM_       (STERM_       ),
    .E51_s_E54_sd (E51_s_E54_sd ),
    .E46_s_E59_s  (E46_s_E59_s  ),
    .E36_s_E47_s  (E36_s_E47_s  ),
    .E33_sd_E38_s (E33_sd_E38_s ),
    .E39_s        (E39_s        ),
    .E40_s_E41_s  (E40_s_E41_s  ),
    .E42_s        (E42_s        ),
    .E43_s_E49_sd (E43_s_E49_sd ),
    .E37_s_E44_s  (E37_s_E44_s  ),
    .E23_sd       (E23_sd       ),
    .E57_s        (E57_s        ),
    .cpudff4_d    (cpudff4_d    )
);
cpudff5 u_cpudff5(
    .E26          (E26          ),
    .E5           (E5           ),
    .E4           (E4           ),
    .E27          (E27          ),
    .E8           (E8           ),
    .E11          (E11          ),
    .E32          (E32          ),
    .E13          (E13          ),
    .E14          (E14          ),
    .E15          (E15          ),
    .E22          (E22          ),
    .E60          (E60          ),
    .E61          (E61          ),
    .E62          (E62          ),
    .E48          (E48          ),
    .E53          (E53          ),
    .E58          (E58          ),
    .E30_d        (E30_d        ),
    .E9_d         (E9_d         ),
    .E28_d        (E28_d        ),
    .DSACK        (DSACK        ),
    .STERM_       (STERM_       ),
    .E36_s_E47_s  (E36_s_E47_s  ),
    .E33_sd_E38_s (E33_sd_E38_s ),
    .E39_s        (E39_s        ),
    .E40_s_E41_s  (E40_s_E41_s  ),
    .E42_s        (E42_s        ),
    .E37_s_E44_s  (E37_s_E44_s  ),
    .E23_sd       (E23_sd       ),
    .E43_s_E49_sd (E43_s_E49_sd ),
    .E57_s        (E57_s        ),
    .cpudff5_d    (cpudff5_d    )
);
CPU_SM_outputs u_CPU_SM_outputs(
    .E32          (E32          ),
    .E48          (E48          ),
    .E2           (E2           ),
    .E3           (E3           ),
    .E4           (E4           ),
    .E5           (E5           ),
    .E7           (E7           ),
    .E8           (E8           ),
    .E10          (E10          ),
    .E11          (E11          ),
    .E12          (E12          ),
    .E16          (E16          ),
    .E17          (E17          ),
    .E18          (E18          ),
    .E19          (E19          ),
    .E0           (E0           ),
    .E21          (E21          ),
    .E26          (E26          ),
    .E27          (E27          ),
    .E56          (E56          ),
    .E55          (E55          ),
    .E35          (E35          ),
    .E61          (E61          ),
    .E50_d_E52_d  (E50_d_E52_d  ),
    .E60          (E60          ),
    .DSACK        (DSACK        ),
    .E43_s_E49_sd (E43_s_E49_sd ),
    .E57_s        (E57_s        ),
    .STERM_       (STERM_       ),
    .E36_s_E47_s  (E36_s_E47_s  ),
    .E33_sd_E38_s (E33_sd_E38_s ),
    .E40_s_E41_s  (E40_s_E41_s  ),
    .E42_s        (E42_s        ),
    .E46_s_E59_s  (E46_s_E59_s  ),
    .E51_s_E54_sd (E51_s_E54_sd ),
    .E62          (E62          ),
    .E58          (E58          ),
    .E53          (E53          ),
    .E25_d        (E25_d        ),
    .E28_d        (E28_d        ),
    .E30_d        (E30_d        ),
    .E23_sd       (E23_sd       ),
    .E29_sd       (E29_sd       ),
    .E45          (E45          ),
    .E34          (E34          ),
    .E24_sd       (E24_sd       ),
    .E37_s        (E37_s        ),
    .E44_s        (E44_s        ),
    .E20_d        (E20_d        ),
    .E39_s        (E39_s        ),
    .E37_s_E44_s  (E37_s_E44_s  ),
    .E6_d         (E6_d         ),
    .E9_d         (E9_d         ),
    .RDFIFO_      (RDFIFO_      ),
    .RIFIFO_      (RIFIFO_      ),
    .BGRANT_      (BGRANT_      ),
    .CYCLEDONE    (CYCLEDONE    ),
    .E31          (E31          ),
    .cpudff1      (STATE[0]     ),
    .cpudff2      (STATE[1]    ),
    .cpudff3      (STATE[2]    ),
    .cpudff4      (STATE[3]    ),
    .cpudff5      (STATE[4]    ),
    
    .nINCNI_d     (nINCNI_d     ),
    .nBREQ_d      (nBREQ_d      ),
    .SIZE1_d      (SIZE1_d      ),
    .PAS_d        (PAS_d        ),
    .PDS_d        (PDS_d        ),
    .F2CPUL_d     (F2CPUL_d     ),
    .F2CPUH_d     (F2CPUH_d     ),
    .BRIDGEOUT_d  (BRIDGEOUT_d  ),
    .PLLW_d       (PLLW_d       ),
    .PLHW_d       (PLHW_d       ),
    .INCFIFO_d    (INCFIFO_d    ),
    .DECFIFO_d    (DECFIFO_d    ),
    .INCNO_d      (INCNO_d      ),
    .nSTOPFLUSH_d (nSTOPFLUSH_d ),
    .DIEH_d       (DIEH_d       ),
    .DIEL_d       (DIEL_d       ),
    .nBRIDGEIN_d  (nBRIDGEIN_d  ),
    .BGACK_d      (BGACK_d      )
);

//clocked reset
always @(posedge nCLK) begin
    CCRESET_ <= aRESET_;   
end

//clocked inputs.
always @(posedge  BBCLK) begin
    BGRANT_ <= aBGRANT_;
    DMAENA <= aDMAENA;
    DREQ_ <= aDREQ_;
    FLUSHFIFO <= aFLUSHFIFO;
    nCYCLEDONE <= aCYCLEDONE_;
end

//clocked outputs
always @(posedge BCLK or negedge CCRESET_) begin
    if (CCRESET_ == 1'b0) begin
        BGACK <= 1'b0;
        PAS <= 1'b0;
        PDS <= 1'b0;
        BREQ <= 1'b0;
        BRIDGEIN <= 1'b0;
        BRIDGEOUT <= 1'b0;
        DECFIFO <= 1'b0;
        DIEH <= 1'b0;
        DIEL <= 1'b0;
        F2CPUH <= 1'b0;
        F2CPUL <= 1'b0;
        INCFIFO <= 1'b0;
        INCNI <= 1'b0;
        INCNO <= 1'b0;
        PLHW <= 1'b0;
        PLLW <= 1'b0;
        SIZE1 <= 1'b0;
        STOPFLUSH <= 1'b0;

    end
    else begin
        BGACK <= BGACK_d;
        BREQ <= ~nBREQ_d;
        BRIDGEIN <= ~nBRIDGEIN_d;
        BRIDGEOUT <= BRIDGEOUT_d;
        DECFIFO <= DECFIFO_d;
        DIEH <= DIEH_d;
        DIEL <= DIEL_d;
        F2CPUH <= F2CPUH_d;
        F2CPUL <= F2CPUL_d;
        INCFIFO <= INCFIFO_d;
        INCNI <= ~nINCNI_d;
        INCNO <= INCNO_d;
        PAS <= PAS_d;
        PDS <= PDS_d;
        PLHW <= PLHW_d;
        PLLW <= PLLW_d;
        SIZE1 <= SIZE1_d;
        STOPFLUSH <= ~nSTOPFLUSH_d;
    end
end

always @(posedge BCLK or negedge CCRESET_) begin
    if (CCRESET_ == 1'b0) 
        STATE <= 5'b00000;
    else 
        STATE <= NEXT_STATE;
end


always @(posedge nCLK or negedge nAS_) begin
    if (nAS_ == 1'b0)
        DSACK_LATCHED_ <= 2'b11;
    else 
        DSACK_LATCHED_ <= {DSACK1_, DSACK0_};
end

assign aCYCLEDONE_ = ~(BGACK_I_ & AS_ & DSACK0_ & DSACK1_ & STERM_);
assign LASTWORD = (~BOEQ0 & aFLUSHFIFO & FIFOEMPTY);

assign NEXT_STATE = {cpudff5_d, cpudff4_d, cpudff3_d, cpudff2_d, cpudff1_d};


assign BBCLK = BCLK; // may need to change this to add delays
assign BCLK = CLK; // may need to change this to add delays
assign CYCLEDONE = ~nCYCLEDONE;
assign DSACK = ~(DSACK_LATCHED_[0] & DSACK_LATCHED_[1]);
assign nAS_ = ~AS_;
assign nCLK = ~CLK;

endmodule