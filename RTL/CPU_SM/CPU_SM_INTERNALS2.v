//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

module CPU_SM_INTERNALS2(

    input CLK,              //CLK
    input CLK45,
    input CLK90,              //CLK
    input CLK135,
    input nRESET,           //Active low reset

    //input A1,
    input BGRANT,
    //input BOEQ3,
    input CYCLEDONE,
    input DMADIR,
    input DMAENA,
    input DREQ,
    input DSACK0,
    input DSACK1,
    input FIFOEMPTY,
    input FIFOFULL,
    input FLUSHFIFO,
    //input LASTWORD,
    input DSACK,
    input STERM,
    input RDFIFO,
    input RIFIFO,

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
    IDLE_s0 = 0,

    //DMA read from SCSI write to memory
    DMA_R_BREQ_s8 = 8,
    DMA_R_BGACK_s24 = 24,
    // 32bit transfer
    DMA_R_AS1_s12 = 12,
    DMA_R_DS1_s1 = 1,
        // 16bit transfer
        DMA_R_TERM2_s4 = 4,
        DMA_R_AS2_s17 = 17,
        DMA_R_DS2_s3 = 3,
    //used for both
    DDMA_R_TERM1_s28 = 28,

    //DMA write to SCSI read from memory
    DMA_W_s16 = 16,
    DMA_W_BREQ_s2 = 2,
    DMA_W_BGACK_s18 = 18,
    // 32bit transfer
    DMA_W_ASDS1_s25 = 25,
    DMA_W_ASDS2_s27 = 27,
        // 16bit transfer
        DMA_W_TERM2_s10 = 10,
        DMA_W_ASDS3_s26 = 26,
        DMA_W_ASDS4_s5 = 5,
    //used for both
    DMA_W_TERM1_s11 = 11,

    DMA_CYCLE_END_s23 = 23,


reg [4:0] state;


always @(posedge CLK or negedge nRESET)
begin
    if (~nRESET) begin
        state <= IDLE_s0;
    end
	else begin
        case (state_reg)
            IDLE_s0: begin
                casex({DMAENA, DMADIR, FIFOEMPTY, FIFOFULL, FLUSHFIFO, LASTWORD})
                    6'b110x1x   : state <= DMA_R_BREQ_s8;      //DMA Read: FIFO NOT EMPTY, FLUSH
                    6'b11xx11   : state <= DMA_R_BREQ_s8;      //DMA Read: FLUSH, LASTWORD
                    6'b11x1xx   : state <= DMA_R_BREQ_s8;      //DMA Read: FIFO FULL
                    6'b10xxxx   : state <= DMA_W_s16;          //DMA Write
                    default     : state <= IDLE_s0;            //IDLE
                endcase
            end;
            DMA_R_BREQ_s8: begin
                state <= (CYCLEDONE & BGRANT) ? DMA_R_BGACK_s24 : DMA_R_BREQ_s8;
                //casex({CYCLEDONE, LASTWORD, A1, BGRANT_, BOEQ3})
                //    5'b11001    : state <= DMA_R_BGACK_s24;
                //    5'b1000x    : state <= DMA_R_BGACK_s24;
                //    default     : state <= DMA_R_BREQ_s8;
                //endcase
            end;
            DMA_R_BGACK_s24: state <= DMA_R_AS1_s12;
            DMA_R_AS1_s12: state <= DMA_R_DS1_s1;//STERM_ ? DMA_R_DS1_s1 : DDMA_R_TERM1_s28;
            DMA_R_DS1_s1: begin
                casex({DSACK0, DSACK1, DSACK, STERM})
                    4'bxx01 : state <= DDMA_R_TERM1_s28;   //32 bit STERM
                    4'b1110 : state <= DDMA_R_TERM1_s28;   //32 bit DSACK term
                    4'b1010 : state <= DMA_R_TERM2_s4;     //16 bit DSACK term
                    default : state <= DMA_R_DS1_s1;       //insert wait state
                endcase
            end;
            DMA_R_TERM2_s4: begin
                casex ({DMAENA, DMADIR})
                    2'b10   : state <= DMA_W_BUS_REQ;   //DMA Write
                    default : state <= DMA_R_AS2_s17;   //DMA Read
                endcase
            end;
            DMA_R_AS2_s17: state <= DMA_R_DS2_s3;//STERM_ ? DMA_R_DS2_s3 : DDMA_R_TERM1_s28;
            DMA_R_DS2_s3: begin
                casex ({DSACK0, DSACK1, DSACK, STERM})
                    4'bxx01 : state <= DDMA_R_TERM1_s28;   //32 bit STERM
                    4'b1110 : state <= DMA_R_BGACK_s24;    //32 bit DSACK term
                    4'b1010 : state <= DDMA_R_TERM1_s28;   //16 bit DSACK term
                    default : state <= DMA_R_DS2_s3;       //insert wait state
                endcase
            end;
            DDMA_R_TERM1_s28: begin
                casex ({BOEQ3, FIFOEMPTY, LASTWORD})
                    3'bx0x  : state <= DMA_R_AS1_s12; //KEEP GOING FIFO IS NOT EMPTY
                    3'b111  : state <= DMA_R_AS1_s12;
                    3'b011  : state <= DMA_W_BGACK_s18;
                    3'bx10  : state <= DMA_CYCLE_END_s23;
                    default : state <= DDMA_R_TERM1_s28;
                endcase
            end;
            DMA_W_s16 : begin
                casex ({DMAENA, DMADIR, FIFOEMPTY, DREQ})
                    4'b1011 : state <= DMA_W_BREQ_s2;
                    default : state <= DMA_W_s16 ;
                endcase
            end;
            DMA_W_BREQ_s2: begin
                casex (CYCLEDONE, A1, BGRANT)
                    3'b101  : state <= DMA_W_BGACK_s18;
                    3'b111  : state <= s9;
                    default : state <= DMA_W_BREQ_s2;
                endcase
            end
            DMA_W_BGACK_s18: state <= DMA_W_ASDS1_s25;
            DMA_W_ASDS1_s25: begin
                casex ({DSACK1, DSACK, STERM})
                    3'b1xx  : state <= DMA_W_TERM2_s10;
                    3'bxx1  : state <= DMA_W_TERM1_s11;
                    3'bx00  : state <= DMA_W_ASDS2_s27;
                    3'bxx0  : state <= DMA_W_ASDS2_s27;
                    default : state <= DMA_W_ASDS1_s25;
                endcase
            end;
            DMA_W_ASDS2_s27: begin
                casex ({DSACK1 DSACK, STERM})
                    3'b1xx  : state <= DMA_W_TERM2_s10;
                    3'bxx1  : state <= DMA_W_TERM1_s11;
                    3'bx00  : state <= DMA_W_ASDS2_s27;
                    default : state <= DMA_W_ASDS2_s27;
                endcase
            end;
            DMA_W_TERM2_s10     : state <= DMA_W_ASDS3_s26;
            DMA_W_ASDS3_s26     : state <= DMA_W_ASDS4_s5;
            DMA_W_ASDS4_s5      : state <= DSACK ? DMA_W_TERM1_s11 : DMA_W_ASDS4_s5;
            DMA_W_TERM1_s11     : state <= FIFOFULL ? DMA_CYCLE_END_s23 : DMA_W_ASDS1_s25;
            DMA_CYCLE_END_s23   : state <= IDLE_s0;
	    endcase
    end

end

task SetOutputDefaults();
    begin
        CPU2S       <= 1'b0;
        INCNI       <= 1'b0;
        SIZE1       <= 1'b0;
        PAS         <= 1'b0;
        F2CPUL      <= 1'b0;
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
        IDLE_s0: begin
            casex({DMAENA, DMADIR, FIFOEMPTY, FIFOFULL , FLUSHFIFO , LASTWORD})
                6'b111010   : STOPFLUSH <= 1'b1;       //DMA Read: FIFO EMPTY, FIFO NOT FULL, FLUSH, NOT LASTWORD
                6'b110x1x   : BREQ      <= 1'b1;       //DMA Read: FIFO NOT EMPTY, FLUSH
                6'b11xx11   : BREQ      <= 1'b1;       //DMA Read: FLUSH, LASTWORD
                6'b11x1xx   : BREQ      <= 1'b1;       //DMA Read: FIFO FULL
            endcase
        end
        DMA_R_BREQ_s8: begin
            BREQ    <= 1'b1;
            BGACK   <= (CYCLEDONE & BGRANT) ? 1'b1 : 1'b0;;
        end;
        DMA_R_BGACK_s24: begin
            BGACK       <= 1'b1;
            PAS         <= 1'b1;
            F2CPUL      <= 1'b1;
            F2CPUH      <= 1'b1;
        end;
        DMA_R_AS1_s12: begin
            BGACK       <= 1'b1;
            PAS         <= 1'b1;
            PDS         <= 1'b1;
            F2CPUL      <= 1'b1;
            F2CPUH      <= 1'b1;
        end
        DMA_R_DS1_s1: begin
            BGACK       <= 1'b1;
            PAS         <= ~STERM
            PDS         <= ~STERM
            F2CPUL      <= 1'b1;
            F2CPUH      <= 1'b1;

            DECFIFO     <= STERM;
            INCNO       <= STERM;

        end;
        DMA_R_TERM2_s4: begin
            BGACK       <= 1'b1;
            SIZE1       <= 1'b1;
            PAS         <= 1'b1;
            F2CPUL      <= 1'b1;
            BRIDGEOUT   <= 1'b1;
        end;
        DMA_R_AS2_s17: begin
            BGACK       <= 1'b1;
            SIZE1       <= 1'b1;
            PAS         <= 1'b1;
            PDS         <= 1'b1;
            F2CPUL      <= 1'b1;
            BRIDGEOUT   <= 1'b1;
        end;
        DMA_R_DS2_s3: begin
            BGACK       <= 1'b1;
            PAS         <= ~DSACK
            PDS         <= ~DSACK
            F2CPUL      <= 1'b1;
            F2CPUH      <= 1'b1;

            DECFIFO     <= DSACK;
            INCNO       <= DSACK;


            casex ({DSACK0_, DSACK1_, DSACK, STERM_})
                4'b001x : //32 bit DSACK term
                    begin
                        DECFIFO     <= 1'b1;
                        INCNO       <= 1'b1;
                    end
                4'bx11x : //16 bit DSACK term
                    begin
                        SIZE1       <= 1'b1;
                        F2CPUL      <= 1'b1;
                        BRIDGEOUT   <= 1'b1;
                        DECFIFO     <= 1'b1;
                        INCNO       <= 1'b1;
                    end
                4'bxx01 : //insert wait state
                    begin
                        SIZE1       <= 1'b1;
                        PAS         <= 1'b1;
                        PDS         <= 1'b1;
                        F2CPUL      <= 1'b1;
                        BRIDGEOUT   <= 1'b1;
                    end
                4'bxxx0 : //32 bit STERM
                    begin
                        SIZE1       <= 1'b1;
                        F2CPUL      <= 1'b1;
                        BRIDGEOUT   <= 1'b1;
                        DECFIFO     <= 1'b1;
                        INCNO       <= 1'b1;
                    end
            endcase
        end;
        DDMA_R_TERM1_s28: begin
            BGACK       <= 1'b1;
            INCNO       <= 1'b1;
            DECFIFO     <= 1'b1;
            F2CPUL      <= 1'b1;
            F2CPUH      <= 1'b1;
        end;

        DMA_W_s16is t: begin

        end;
        DMA_W_BREQ_s2: begin
            BREQ <= 1'b1;
            casex (CYCLEDONE, A1, BGRANT_)
                3'b100  : BREQ <= 1'b1;
                3'b110  : BREQ <= 1'b1;
                3'bxx1  : BREQ <= 1'b1;
                3'b0xx  : BREQ <= 1'b1;
            endcase
        end
        DMA_W_BGACK_s18: begin

        end;

        DMA_W_ASDS1_s25: begin

        end;
        DMA_W_ASDS2_s27: begin

        end;
        DMA_W_TERM2_s10: begin
            SIZE1       <= 1'b1;
            PAS         <= 1'b1;
            PDS         <= 1'b1;
            PLLW        <= 1'b1;
            DIEH        <= 1'b1;
            BRIDGEIN    <= 1'b1;
        end
        DMA_W_ASDS3_s26: begin

        end;
        DMA_W_ASDS4_s5: begin
            SIZE1       <= 1'b1;
            DIEH        <= 1'b1;
            BRIDGEIN    <= 1'b1;

            if (DSACK)
                INCFIFO     <= 1'b1;
            else begin
                PAS         <= 1'b1;
                PDS         <= 1'b1;
                PLLW        <= 1'b1;
            end
        end;
        DMA_W_TERM1_s11: begin
            if (FIFOFULL)
                INCNI       <= 1'b1;
            else begin
                INCNI       <= 1'b1;
                PAS         <= 1'b1;
                PDS         <= 1'b1;
                PLLW        <= 1'b1;
                PLHW        <= 1'b1;
                DIEH        <= 1'b1;
                DIEL        <= 1'b1;
            end
        end;

        DMA_CYCLE_END_s23: begin

        end;
    endcase
end

endmodule