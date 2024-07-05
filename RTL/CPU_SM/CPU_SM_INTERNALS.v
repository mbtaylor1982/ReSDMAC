//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

module CPU_SM_INTERNALS(

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
    DMA_R_s1 = 1,
    s2 = 2,
    s3 = 3,
    DMA_R_s4 = 4,
    s5 = 5,
    s6 = 6,
    s7 = 7,
    DMA_R_BUS_REQ = 8,
    s9 = 9,
    s10 = 10,
    s11 = 11,
    DMA_R_s12 = 12,
    s13 = 13,
    s14 = 14,
    s15 = 15,
    DMA_W_DMA_W_BUS_REQ = 16,
    s17 = 17,
    s18 = 18,
    s19 = 19,
    s20 = 10,
    s21 = 21,
    s22 = 22,
    s23 = 23,
    DMA_R_s24 = 24,
    s25 = 25,
    s26 = 26,
    s27 = 27,
    DMA_R_s28 = 28,
    s29 = 29,
    s30 = 30,
    s31 = 31;

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
                    6'b111010   : state <= IDLE_s0;             //DMA Read: FIFO EMPTY, FIFO NOT FULL, FLUSH, NOT LASTWORD
                    6'b110x1x   : state <= DMA_R_BUS_REQ;       //DMA Read: FIFO NOT EMPTY, FLUSH
                    6'b11xx11   : state <= DMA_R_BUS_REQ;       //DMA Read: FLUSH, LASTWORD
                    6'b11x1xx   : state <= DMA_R_BUS_REQ;       //DMA Read: FIFO FULL
                    6'b10xxxx   : state <= DMA_W_DMA_W_BUS_REQ; //DMA Write
                    default     : state <= IDLE_s0;             //IDLE
                endcase
            end
            DMA_R_s1: begin
                casex({DSACK0_, DSACK1_, DSACK, STERM_})
                    4'b001x : state <= DMA_R_s24;    //32 bit DSACK term
                    4'bx1xx : state <= DMA_R_s4;     //16 bit DSACK term
                    4'bxx01 : state <= DMA_R_s1;     //insert wait state
                    4'bxxx0 : state <= DMA_R_s28;    //32 bit STERM
                    default : state <= DMA_R_s1;     //insert wait state
                endcase
            end;
            s2: begin
                casex (CYCLEDONE, A1, BGRANT_)
                    3'b100  : state <= s18;
                    3'b110  : state <= s9;
                    3'bxx1  : state <= s2;
                    3'b0xx  : state <= s2;
                    default : state <= s2;
                endcase
            end
            s3: begin
                casex ({DSACK0_, DSACK1_, DSACK, STERM_})
                    4'b001x : state <= s24;          //32 bit DSACK term
                    4'bx11x : state <= s28;          //16 bit DSACK term
                    4'bxx01 : state <= s3;           //insert wait state
                    4'bxxx0 : state <= DMA_R_s28;    //32 bit STERM
                    default : state <= s3;           //insert wait state
                endcase
            end;
            DMA_R_s4: begin
                casex ({DMAENA, DMADIR})
                    2'b10   : state <= DMA_W_BUS_REQ;   //DMA Write
                    default : state <= s17;             //DMA Read
                endcase
            end;
            s5: state <= DSACK ? s11 : s5;
            s6: state <= s11;
            s7: begin
                 casex ({DSACK1_ DSACK, STERM_})
                    3'b01x  : state <= s28;
                    3'bxx0  : state <= s28;
                    3'bx01  : state <= s7;
                    default : state <= s7;
                endcase
            end;
            DMA_R_BUS_REQ: begin
                casex({CYCLEDONE, LASTWORD, A1, BGRANT_, BOEQ3})
                    5'b11000    : state <= s20;
                    5'b11001    : state <= DMA_R_s24;
                    5'b1000x    : state <= DMA_R_s24;
                    5'b1x10x    : state <= s4;
                    5'b1x10x    : state <= DMA_R_BUS_REQ;
                    5'b0xxxx    : state <= DMA_R_BUS_REQ;
                    default     : state <= DMA_R_BUS_REQ;
                endcase
            end;
            s9: state <= s21;
            s10: state <= s26;
            s11: state <= FIFOFULL ? s23 : s25;
            DMA_R_s12: state <= STERM_ ? DMA_R_s1 : s28;
            s13: begin
            end;
            s14: state <= STERM_ ? s31 : s27;
            s15: begin
                casex ({DSACK0_, DSACK1_, DSACK, STERM_})
                    4'b1011 :  state <= s31; //16 bit (word) DSACK transfer
                    4'b001x :  state <= s10; //32 bit (longword) DSACK transfer
                    4'bxxx0 :  state <= s11; //32 bit (longword) STERM transfer
                    4'bxx01 :  state <= s15; //Wait
                    default :  state <= s15; //Wait
                endcase
            end;
            DMA_W_BUS_REQ: begin
                casex ({DMAENA, DMADIR, FIFOEMPTY, DREQ_})
                    4'b1010 : state <= s2;
                    4'bx0x1 : state <= DMA_W_BUS_REQ;
                    4'bx00x : state <= DMA_W_BUS_REQ;
                    4'b0xxx : state <= DMA_W_BUS_REQ;
                    default : state <= DMA_W_BUS_REQ;
                endcase
            end;
            DMA_R_s17: state <= STERM_ ? s3 : DMA_R_s28;
            s18: state <= s25;
            s19: state <= STERM_ ? s7 : s28;
            s20: state <= s19;
            s21: state <= STERM_ ? s15 : s11;
            s22: begin
            
            end
            s23: state <= IDLE_s0;
            DMA_R_s24: state <= DMA_R_s12;
            s25: begin
                casex ({DSACK1_, DSACK, STERM_ })
                    3'b0xx  : state <= s10;
                    3'bxx0  : state <= s11;
                    3'bx01  : state <= s27;
                    3'bxx1  : state <= s27;
                    default : state <= s25;
                endcase
            end;
            s26: state <= s5;
            s27: begin
                casex ({DSACK1_ DSACK, STERM_})
                    3'b0xx  : state <= s10;
                    3'bxx0  : state <= s11;
                    3'bx01  : state <= s27;
                    default : state <= s27;
                endcase
            end;
            DMA_R_s28: begin
                casex ({BOEQ3, FIFOEMPTY, LASTWORD})
                    3'bx0x  : state <= DMA_R_s12; //KEEP GOING FIFO IS NOT EMPTY
                    3'b111  : state <= DMA_R_s12;
                    3'b011  : state <= s18;
                    3'bx10  : state <= s23;
                    default : state <= DMA_R_s28;
                endcase
            
            end;
            s29: begin
            
            end;
            s30: begin

            end
            s31: state <= s6;
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
        s0: begin
            casex({DMAENA, DMADIR, FIFOEMPTY, FIFOFULL , FLUSHFIFO , LASTWORD})
                6'b111010   : STOPFLUSH <= 1'b1;       //DMA Read: FIFO EMPTY, FIFO NOT FULL, FLUSH, NOT LASTWORD
                6'b110x1x   : BREQ      <= 1'b1;       //DMA Read: FIFO NOT EMPTY, FLUSH
                6'b11xx11   : BREQ      <= 1'b1;       //DMA Read: FLUSH, LASTWORD
                6'b11x1xx   : BREQ      <= 1'b1;       //DMA Read: FIFO FULL
            endcase
        end
        s1: begin
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
        s2: begin
            BREQ <= 1'b1;
            casex (CYCLEDONE, A1, BGRANT_)
                3'b100  : BREQ <= 1'b1;
                3'b110  : BREQ <= 1'b1;
                3'bxx1  : BREQ <= 1'b1;
                3'b0xx  : BREQ <= 1'b1;
            endcase
        end
        s3: begin
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
        s4: begin
            SIZE1       <= 1'b1;
            PAS         <= 1'b1;
            F2CPUL      <= 1'b1;
            BRIDGEOUT   <= 1'b1;
        end;
        s5: begin
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
        s6: begin
            INCFIFO     <= 1'b1;
            BRIDGEIN    <= 1'b1;
        end;
        s7: begin
            casex ({DSACK1_ DSACK, STERM_})
                3'b01x  :
                    begin
                        SIZE1       <= 1'b1;
                        F2CPUL      <= 1'b1;
                        F2CPUH      <= 1'b1;
                    end
                3'bxx0  :
                    begin
                        SIZE1       <= 1'b1;
                        F2CPUL      <= 1'b1;
                        F2CPUH      <= 1'b1;
                    end
                3'bx01  :
                    begin
                        SIZE1       <= 1'b1;
                        PAS         <= 1'b1;
                        PDS         <= 1'b1;
                        F2CPUL      <= 1'b1;
                        F2CPUH      <= 1'b1;
                    end
            endcase
        end;
        DMA_R_BUS_REQ: begin
            casex({CYCLEDONE, LASTWORD, A1, BGRANT_, BOEQ3})
                5'b11000    : STOPFLUSH   <= 1'b1;
                5'b11001    : STOPFLUSH   <= 1'b1;
                5'b1000x    : BREQ        <= 1'b1;
                5'b1x10x    : BREQ        <= 1'b1;
                5'b1x10x    : BREQ        <= 1'b1;
                5'b0xxxx    : BREQ        <= 1'b1;
            endcase
        end;
        s9: begin
            SIZE1       <= 1'b1;
            PAS         <= 1'b1;
            PDS         <= 1'b1;
            PLLW        <= 1'b1;
            DIEH        <= 1'b1;
            DIEL        <= 1'b1;
        end;
        s10: begin
            SIZE1       <= 1'b1;
            PAS         <= 1'b1;
            PDS         <= 1'b1;
            PLLW        <= 1'b1;
            DIEH        <= 1'b1;
            BRIDGEIN    <= 1'b1;
        end
        s11: begin
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
        s12: begin
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
        s13: begin
            SIZE1       <= 1'b1;
            PAS         <= 1'b1;
            PDS         <= 1'b1;
            PLLW        <= 1'b1;
            DIEH        <= 1'b1;
            DIEL        <= 1'b1;
            BRIDGEIN    <= 1'b1;

            casex ({DSACK, STERM_})
                2'bx1:
                    begin
                        PAS         <= 1'b1;
                        PDS         <= 1'b1;
                        F2CPUL      <= 1'b1;
                        F2CPUH      <= 1'b1;
                    end
                2'bx0:
                    begin
                        INCNO       <= 1'b1;
                        DECFIFO     <= 1'b1;
                    end
                2'b0x:
                    begin
                        SIZE1       <= 1'b1;
                        PAS         <= 1'b1;
                        PDS         <= 1'b1;
                        PLLW        <= 1'b1;
                        DIEH        <= 1'b1;
                    end
                2'b1x:
                    begin
                        SIZE1       <= 1'b1;
                        INCFIFO     <= 1'b1;
                        DIEH        <= 1'b1;
                    end
            endcase
        end;
        s14: begin
        
        end;
        s15: begin
        
        end;
        DMA_W_BUS_REQ: begin
        
        end;
        s17: begin
        
        end;
        s18: begin
        
        end;
        s19: begin
        
        end;
        s20: begin
                
        end
        s21: begin
        end;
        s22: begin
          
        end
        s23: begin
        
        end;
        s24: begin
        
        end;
        s25: begin
        
        end;
        s26: begin
        
        end;
        s27: begin
        
        end;
        s28: begin
        
        end;
        s29: begin
        
        end;
        s30: begin

        end
        s31: begin

        end
    endcase
end

endmodule