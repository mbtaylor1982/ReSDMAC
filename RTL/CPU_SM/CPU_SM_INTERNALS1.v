/*ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/*/

`ifdef __ICARUS__ 
  `include "CPU_SM_inputs.v"
  `include "CPU_SM_output.v"
`endif

module CPU_SM_INTERNALS1(

    input CLK,              //CLK
    input nRESET,           //Active low reset

    input A1,
    input BGRANT_,
    input BOEQ3,
    input CYCLEDONE,
    input DMADIR,
    input DMAENA,
    input DREQ_,
    input DSACK0_,
    input DSACK1_,
    input FIFOEMPTY,
    input FIFOFULL,
    input FLUSHFIFO,
    input LASTWORD,
    input DSACK,
    input STERM_,
    input RDFIFO_,
    input RIFIFO_,

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
    output BGACK_d
);


reg [4:0] STATE;
wire [4:0] NEXT_STATE;
wire [62:0] E;

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
    .E            (E)
);

CPU_SM_outputs u_CPU_SM_outputs(
    .DSACK        (DSACK        ),
    .STERM_       (STERM_       ),
    .E            (E            ),
    .RDFIFO_      (RDFIFO_      ),
    .RIFIFO_      (RIFIFO_      ),
    .BGRANT_      (BGRANT_      ),
    .CYCLEDONE    (CYCLEDONE    ),
    .STATE        (STATE        ),
    .INCNI_d      (INCNI_d      ),
    .BREQ_d       (BREQ_d       ),
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
    .STOPFLUSH_d  (STOPFLUSH_d  ),
    .DIEH_d       (DIEH_d       ),
    .DIEL_d       (DIEL_d       ),
    .BRIDGEIN_d   (BRIDGEIN_d   ),
    .BGACK_d      (BGACK_d      ),
    .NEXT_STATE   (NEXT_STATE   )
);

//State Machine
always @(posedge CLK or negedge nRESET) begin
    if (nRESET == 1'b0)
        STATE <= 5'b00000;
    else
        STATE <= NEXT_STATE;
end

endmodule