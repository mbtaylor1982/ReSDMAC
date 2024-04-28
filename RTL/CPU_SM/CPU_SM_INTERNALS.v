module CPU_SM_INTERNALS(

    input CLK,              //CLK
    input nRESET,           //Active low reset

    input A1,
    input BGRANT,
    input BOEQ3,
    input CYCLEDONE,
    input DMADIR,
    input DMAENA,
    input DREQ,
    input DSACK0,
    input DSACK1,
    input FIFOEMPTY,
    input FIFOFULL,
    input FLUSHFIFO,
    input LASTWORD,

    output reg INCNI,
    output reg BREQ,
    output reg SIZE1,
    output reg PAS,
    output reg PDS,
    output reg F2CPUL,
    output reg F2CPUH,
    output reg BRIDGEOUT,
    output reg PLLW,
    output reg PLHW,
    output reg INCFIFO,
    output reg DECFIFO,
    output reg INCNO,
    output reg STOPFLUSH,
    output reg DIEH,
    output reg DIEL,
    output reg BRIDGEIN,
    output reg BGACK

);

localparam [4:0]
    s0 = 0,
    s1 = 1,
    s2 = 2,
    s3 = 3,
    s4 = 4,
    s5 = 5,
    s6 = 6,
    s7 = 7,
    s8 = 8,
    s9 = 9,
    s10 = 10,
    s11 = 11,
    s12 = 12,
    s13 = 13,
    s14 = 14,
    s15 = 15,
    s16 = 16,
    s17 = 17,
    s18 = 18,
    s19 = 19,
    s20 = 10,
    s21 = 21,
    s22 = 22,
    s23 = 23,
    s24 = 24,
    s25 = 25,
    s26 = 26,
    s27 = 27,
    s28 = 28,
    s29 = 29,
    s30 = 30,
    s31 = 31;

reg [4:0] state;

wire DMA_RD = DMAEN & ~DMADIR;
wire DMA_WR = DMAEN & DMADIR;

wire a = DMAENA & DMADIR & FIFOEMPTY & nFIFOFULL & FLUSHFIFO & nLASTWORD)
wire b = DMAENA & DMADIR &(FIFOFULL | (FLUSHFIFO & LASTWORD) | (~FIFOEMPTY & FLUSHFIFO))


always @(posedge CLK or negedge nRESET)
begin
    if (~nRESET) begin
        state <= s0;
    end
	else begin
        case (state_reg)
            s0: state_reg <= DMA_RD ? s16 :(a ? s0 : s8)  
            
            S8:

            s16:

            s24: state_reg <= s12;
        endcase
	end

end

task SetOutputDefaults();
    begin
        CPU2S       <= 1'b0;
        INCNI       <= 1'b0;
        SIZE1       <= 1'b0;
        PAS         <= 1'b0;,
        F2CPUL      <= 1'b0;,
        BRIDGEOUT   <= 1'b0;
        PLLW        <= 1'b0;
        PLHW        <= 1'b0;
        INCFIFO     <= 1'b0;
        DECFIFO     <= 1'b0;
        INCNO       <= 1'b0;
        STOPFLUSH   <= 1'b0;
        DIEH        <= 1'b0;
        DIEL        <= 1'b0;
        BRIDGEIN    <= 1'b0;
        BGACK       <= 1'b0;
    end
endtask

always @(*)
begin
    SetOutputDefaults();
    case (state_reg)
        s0: begin

        end
        s2: begin
            if (~BGRANT) BGACK <= 1'b1;
            else if (~CYCLEDONE) BGACK <= 1'b1;
        end
        s8: begin
            if (~BGRANT) BGACK <= 1'b1;
            else if (~CYCLEDONE) BGACK <= 1'b1;
        end
        s5: begin
            BGACK       <= 1'b1;
            BRIDGEIN    <= 1'b1;
        end
        s6: begin
            BRIDGEIN    <= 1'b1;
        end
        s10: begin
            BRIDGEIN    <= 1'b1;
        end
        s13: begin
            BRIDGEIN    <= 1'b1;
        end
        s14: begin
            BRIDGEIN    <= 1'b1;
        end
        s16: begin
            BGACK       <= 1'b1;
        end
        s22: begin
            BRIDGEIN    <= 1'b1;
        end
        s26: begin
            BRIDGEIN    <= 1'b1;
        end
        s30: begin
            BGACK       <= 1'b1;
            BRIDGEIN    <= 1'b1;
        end
        s31: begin
            BRIDGEIN    <= 1'b1;
        end
    endcase
end

endmodule