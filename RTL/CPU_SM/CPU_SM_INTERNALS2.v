//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

module CPU_SM_INTERNALS2(

    input CLK,              //CLK
    input CLK45,
    input CLK90,              //CLK
    input CLK135,
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
    input DSACK,
    input STERM,
    input RDFIFO_,
    input RIFIFO_,

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
    DMA_R_BREQ = 8,
    DMA_R_BGACK = 24,
    // 32bit transfer
    DMA_R_AS1 = 12,
    DMA_R_DS1 = 1,
        // 16bit transfer
        DMA_R_TERM2 = 4,
        DMA_R_AS2 = 17,
        DMA_R_DS2 = 3,
    //used for both
    DMA_R_TERM1 = 28,

    //DMA write to SCSI read from memory
    DMA_W = 16,
    DMA_W_BREQ = 2,
    DMA_W_BGACK = 18,
    // 32bit transfer
    DMA_W_ASDS1 = 25,
    DMA_W_ASDS2 = 27,
        // 16bit transfer
        DMA_W_TERM2 = 10,
        DMA_W_ASDS3 = 26,
        DMA_W_ASDS4 = 5,
    //used for both
    DMA_W_TERM1 = 11,

    DMA_CYCLE_END = 23,


reg [4:0] state;


always @(posedge CLK or negedge nRESET)
begin
    if (~nRESET) begin
        state <= IDLE_s0;
    end
	else begin
        case (state_reg)
            IDLE_s0: begin
                casex({DMAENA, DMADIR, FIFOEMPTY, FIFOFULL , FLUSHFIFO , LASTWORD})
                    6'b110x1x   : state <= DMA_R_BREQ;      //DMA Read: FIFO NOT EMPTY, FLUSH
                    6'b11xx11   : state <= DMA_R_BREQ;      //DMA Read: FLUSH, LASTWORD
                    6'b11x1xx   : state <= DMA_R_BREQ;      //DMA Read: FIFO FULL
                    6'b10xxxx   : state <= DMA_W;           //DMA Write
                    default     : state <= IDLE_s0;         //IDLE
                endcase
            end;
            DMA_R_BREQ: begin
                casex({CYCLEDONE, LASTWORD, A1, BGRANT_, BOEQ3})
                    5'b11001    : state <= DMA_R_BGACK;
                    5'b1000x    : state <= DMA_R_BGACK;
                    default     : state <= DMA_R_BREQ;
                endcase
            end;
            DMA_R_BGACK: state <= DMA_R_AS1;
            DMA_R_AS1: state <= DMA_R_DS1;//STERM_ ? DMA_R_DS1 : DMA_R_TERM1;
            DMA_R_DS1: begin
                casex({DSACK0_, DSACK1_, DSACK, STERM_})
                    4'bxx00 : state <= DMA_R_TERM1;     //32 bit STERM
                    4'b0011 : state <= DMA_R_TERM1;     //32 bit DSACK term
                    4'b0111 : state <= DMA_R_TERM2;     //16 bit DSACK term
                    default : state <= DMA_R_DS1;       //insert wait state
                endcase
            end;
            DMA_R_TERM2: begin
                casex ({DMAENA, DMADIR})
                    2'b10   : state <= DMA_W_BUS_REQ;   //DMA Write
                    default : state <= DMA_R_AS2;       //DMA Read
                endcase
            end;
            DMA_R_AS2: state <= DMA_R_DS2;//STERM_ ? DMA_R_DS2 : DMA_R_TERM1;
            DMA_R_DS2: begin
                casex ({DSACK0_, DSACK1_, DSACK, STERM_})
                    4'bxx00 : state <= DMA_R_TERM1;     //32 bit STERM
                    4'b0011 : state <= DMA_R_BGACK;     //32 bit DSACK term
                    4'b0111 : state <= DMA_R_TERM1;     //16 bit DSACK term
                    default : state <= DMA_R_DS2;       //insert wait state
                endcase
            end;
            DMA_R_TERM1: begin
                casex ({BOEQ3, FIFOEMPTY, LASTWORD})
                    3'bx0x  : state <= DMA_R_AS1; //KEEP GOING FIFO IS NOT EMPTY
                    3'b111  : state <= DMA_R_AS1;
                    3'b011  : state <= DMA_W_BGACK;
                    3'bx10  : state <= DMA_CYCLE_END;
                    default : state <= DMA_R_TERM1;
                endcase
            end;
            DMA_W: begin
                casex ({DMAENA, DMADIR, FIFOEMPTY, DREQ_})
                    4'b1010 : state <= DMA_W_BREQ;
                    default : state <= DMA_W;
                endcase
            end;
            DMA_W_BREQ: begin
                casex (CYCLEDONE, A1, BGRANT_)
                    3'b100  : state <= DMA_W_BGACK;
                    3'b110  : state <= s9;
                    3'bxx1  : state <= DMA_W_BREQ;
                    3'b0xx  : state <= DMA_W_BREQ;
                    default : state <= DMA_W_BREQ;
                endcase
            end
            DMA_W_BGACK: state <= DMA_W_ASDS1;
            DMA_W_ASDS1: begin
                casex ({DSACK1_, DSACK, STERM_ })
                    3'b0xx  : state <= DMA_W_TERM2;
                    3'bxx0  : state <= DMA_W_TERM1;
                    3'bx01  : state <= DMA_W_ASDS2;
                    3'bxx1  : state <= DMA_W_ASDS2;
                    default : state <= DMA_W_ASDS1;
                endcase
            end;
            DMA_W_ASDS2: begin
                casex ({DSACK1_ DSACK, STERM_})
                    3'b0xx  : state <= DMA_W_TERM2;
                    3'bxx0  : state <= DMA_W_TERM1;
                    3'bx01  : state <= DMA_W_ASDS2;
                    default : state <= DMA_W_ASDS2;
                endcase
            end;
            DMA_W_TERM2: state <= DMA_W_ASDS3;
            DMA_W_ASDS3: state <= DMA_W_ASDS4;
            DMA_W_ASDS4: state <= DSACK ? DMA_W_TERM1 : DMA_W_ASDS4;
            DMA_W_TERM1: state <= FIFOFULL ? DMA_CYCLE_END : DMA_W_ASDS1;
            DMA_CYCLE_END: state <= IDLE_s0;
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
        DMA_R_BREQ: begin
            casex({CYCLEDONE, LASTWORD, A1, BGRANT_, BOEQ3})
                5'b11000    : STOPFLUSH   <= 1'b1;
                5'b11001    : STOPFLUSH   <= 1'b1;
                5'b1000x    : BREQ        <= 1'b1;
                5'b1x10x    : BREQ        <= 1'b1;
                5'b1x10x    : BREQ        <= 1'b1;
                5'b0xxxx    : BREQ        <= 1'b1;
            endcase
        end;
        DMA_R_BGACK: begin

        end;
        DMA_R_AS1: begin
            if (STERM_)
            begin
                PAS         <= 1'b1;
                PDS         <= 1'b1;
                F2CPUL      <= 1'b1;
                F2CPUH      <= 1'b1;
            end
            else begin
                INCNO       <= 1'b1;
                DECFIFO     <= 1'b1;
            end
        end
        DMA_R_DS1: begin
            casex({DSACK0_, DSACK1_, DSACK, STERM_})
                4'b001x : //32 bit DSACK term
                    begin
                        INCNO   <= 1'b1;
                        DECFIFO <= 1'b1;
                    end
                4'bx1xx : //16 bit DSACK term
                    begin
                        F2CPUL <= 1'b1;
                        F2CPUH <= 1'b1;
                    end
                4'bxx01 : //Wait state
                    begin
                        PAS <= 1'b1;
                        PDS <= 1'b1;
                        F2CPUL <= 1'b1;
                        F2CPUH <= 1'b1;
                    end
                4'bxxx0 : //32 bit STERM
                    begin
                        F2CPUL  <= 1'b1;
                        F2CPUH  <= 1'b1;
                        INCNO   <= 1'b1;
                        DECFIFO <= 1'b1;
                    end
            endcase
        end;
        DMA_R_TERM2: begin
            SIZE1       <= 1'b1;
            PAS         <= 1'b1;
            F2CPUL      <= 1'b1;
            BRIDGEOUT   <= 1'b1;
        end;



        DMA_W_BREQ: begin
            BREQ <= 1'b1;
            casex (CYCLEDONE, A1, BGRANT_)
                3'b100  : BREQ <= 1'b1;
                3'b110  : BREQ <= 1'b1;
                3'bxx1  : BREQ <= 1'b1;
                3'b0xx  : BREQ <= 1'b1;
            endcase
        end
        DMA_R_DS2: begin
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
       
        DMA_W_ASDS4: begin
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

        
        DMA_W_TERM2: begin
            SIZE1       <= 1'b1;
            PAS         <= 1'b1;
            PDS         <= 1'b1;
            PLLW        <= 1'b1;
            DIEH        <= 1'b1;
            BRIDGEIN    <= 1'b1;
        end
        DMA_W_TERM1: begin
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
       
       
        DMA_W_BUS_REQ: begin
        
        end;
        DMA_R_AS2: begin
        
        end;
        DMA_W_BGACK: begin
        
        end;
        DMA_CYCLE_END: begin
        
        end;
       
        DMA_W_ASDS1: begin
        
        end;
        DMA_W_ASDS3: begin
        
        end;
        DMA_W_ASDS2: begin
        
        end;
        DMA_R_TERM1: begin
        
        end;

    endcase
end

endmodule