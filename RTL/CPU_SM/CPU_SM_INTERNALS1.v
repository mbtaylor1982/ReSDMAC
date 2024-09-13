//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

`ifdef __ICARUS__ 
  `include "CPU_SM_inputs.v"
  `include "CPU_SM_output.v"
`endif

module CPU_SM_INTERNALS1(

    input CLK,
    input CLK45,
    input CLK90,              //CLK
    input CLK135,
    input nRESET,             //Active low reset
    input A1,
    input nBGRANT,
    input BOEQ3,
    input CYCLEDONE,
    input DMADIR,
    input DMAENA,
    input nDREQ,
    input nDSACK0,
    input nDSACK1,
    input FIFOEMPTY,
    input FIFOFULL,
    input FLUSHFIFO,
    input LASTWORD,
    input DSACK,
    input nSTERM,
    input nRDFIFO,
    input nRIFIFO,

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
    output BGACK
);


reg [4:0] STATE;
wire [4:0] NEXT_STATE;
wire [62:0] E;

CPU_SM_inputs u_CPU_SM_inputs(
    .CLK90        (CLK90        ),
    .nRST         (nRESET       ),
    .A1           (A1           ),
    .nBGRANT      (nBGRANT      ),
    .BOEQ3        (BOEQ3        ),
    .CYCLEDONE    (CYCLEDONE    ),
    .DMADIR       (DMADIR       ),
    .DMAENA       (DMAENA       ),
    .nDREQ        (nDREQ        ),
    .nDSACK0      (nDSACK0      ),
    .nDSACK1      (nDSACK1      ),
    .FIFOEMPTY    (FIFOEMPTY    ),
    .FIFOFULL     (FIFOFULL     ),
    .FLUSHFIFO    (FLUSHFIFO    ),
    .LASTWORD     (LASTWORD     ),
    .STATE        (STATE        ),
    .E            (E)
);

CPU_SM_outputs u_CPU_SM_outputs(
    .DSACK      (DSACK          ),
    .nSTERM     (nSTERM         ),
    .E          (E              ),
    .nRDFIFO    (nRDFIFO        ),
    .nRIFIFO    (nRIFIFO        ),
    .nBGRANT    (nBGRANT        ),
    .CYCLEDONE  (CYCLEDONE      ),
    .STATE      (STATE          ),
    .INCNI      (INCNI          ),
    .BREQ       (BREQ           ),
    .SIZE1      (SIZE1          ),
    .PAS        (PAS            ),
    .PDS        (PDS            ),
    .F2CPUL     (F2CPUL         ),
    .F2CPUH     (F2CPUH         ),
    .BRIDGEOUT  (BRIDGEOUT      ),
    .PLLW       (PLLW           ),
    .PLHW       (PLHW           ),
    .INCFIFO    (INCFIFO        ),
    .DECFIFO    (DECFIFO        ),
    .INCNO      (INCNO          ),
    .STOPFLUSH  (STOPFLUSH      ),
    .DIEH       (DIEH           ),
    .DIEL       (DIEL           ),
    .BRIDGEIN   (BRIDGEIN       ),
    .BGACK      (BGACK          ),
    .NEXT_STATE (NEXT_STATE     )
);

//State Machine
always @(posedge CLK90 or negedge nRESET) begin
    if (~nRESET)
        STATE <= 5'b00000;
    else
        STATE <= NEXT_STATE;
end

endmodule