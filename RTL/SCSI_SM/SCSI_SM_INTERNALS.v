//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

module SCSI_SM_INTERNALS(

    input CLK,              //CLK
    input nRESET,           //Active low reset

    input BOEQ3,            //Asserted when transfering Byte 3
    input CCPUREQ,          //Request CPU access to SCSI registers.
    input CDREQ_,           //Data transfer request from SCSI IC.
    input CDSACK_,          //DSACK feedback for cycle termination
    input DMADIR,           //Control Direction Of DMA transfer.
    input FIFOEMPTY,        //FIFOFULL flag
    input FIFOFULL,         //FIFOEMPTY flag
    input RDFIFO_o,
    input RIFIFO_o,
    input RW,               //CPU RW signal

    output reg CPU2S,       //Indicate CPU to SCSI Transfer
    output reg DACK,        //SCSI IC Data request Acknowledge
    output reg F2S,         //Indicate FIFO to SCSI Transfer
    output reg INCBO,       //Increment FIFO Byte Pointer
    output reg INCNI,       //Increment FIFO Next In Pointer
    output reg INCNO,       //Increement FIFO Next Out Pointer
    output reg RDFIFO,      //Read Longword from FIFO
    output reg RE,          //Read indicator to SCSI IC
    output reg RIFIFO,      //Write Longword to FIFO
    output reg S2CPU,       //Indicate SCSI to CPU Transfer
    output reg S2F,         //Indicate SCSI to FIFO Transfer
    output reg SCSI_CS,     //Chip Select for SCSI IC
    output reg WE,          //Write indicator to SCSI IC
    output reg SET_DSACK    //Signal cycle termination for C2S & S2C

);

localparam [4:0]
    IDLE_DMA_RD = 0,  // Idle state / start of DMA read
    CPUREQ      = 8,  // Idle state / start of CPU <-> SCSI transfer
    IDLE_DMA_WR = 16, // Idle state / start of DMA write

    //CPU to SCSI States
    C2S_1   = 17,
    C2S_2   = 26,
    C2S_3   = 6,
    C2S_4   = 22,
    C2S_5   = 14,

    //FIFO to SCSI States
    F2S_1   = 28,
    F2S_2   = 2,
    F2S_3   = 18,
    F2S_4   = 1,

    //SCSI to CPU States
    S2C_1   = 10,
    S2C_2   = 30,
    S2C_3   = 3,
    S2C_4   = 19,
    S2C_5   = 9,
    S2C_6   = 25,

    //SCSI to FIFO States
    S2F_1   = 24,
    S2F_2   = 4,
    S2F_3   = 20,
    S2F_4   = 12;

reg [4:0] state_reg;

wire START_S2F = (~CDREQ_ & ~FIFOFULL & DMADIR & ~CCPUREQ & ~RIFIFO_o);
wire START_F2S = (~CDREQ_ & ~FIFOEMPTY & ~DMADIR & ~CCPUREQ & ~RDFIFO_o);
wire START_DMA_WR = (~DMADIR & ~CCPUREQ);

always @(posedge CLK or negedge nRESET)
begin
    if (~nRESET) begin
        state_reg <= IDLE_DMA_RD;
    end
	else begin
        case (state_reg)
            IDLE_DMA_RD: begin
                case ({START_S2F, CCPUREQ, START_DMA_WR})
                    3'b100  : state_reg <= S2F_1;
                    3'b010  : state_reg <= CPUREQ;
                    3'b001  : state_reg <= IDLE_DMA_WR;
                    default : state_reg <= IDLE_DMA_RD;
                endcase
            end
            IDLE_DMA_WR: begin
                case ({START_F2S, CCPUREQ})
                    2'b10   : state_reg <= F2S_1;
                    2'b01   : state_reg <= CPUREQ;
                    default : state_reg <= IDLE_DMA_RD;
                endcase
            end 
            CPUREQ: state_reg <= RW ? S2C_1 : C2S_1;
            //CPU to SCSI
            C2S_1: state_reg <= C2S_2;
            C2S_2: state_reg <= C2S_3;
            C2S_3: state_reg <= C2S_4;
            C2S_4: state_reg <= C2S_5;
            C2S_5: state_reg <= CDSACK_ ? IDLE_DMA_RD : C2S_5;
           //SCSI to CPU
            S2C_1: state_reg <= S2C_2;
            S2C_2: state_reg <= S2C_3;
            S2C_3: state_reg <= S2C_4;
            S2C_4: state_reg <= S2C_5;
            S2C_5: state_reg <= S2C_6;
            S2C_6: state_reg <= CDSACK_ ? IDLE_DMA_RD : S2C_6;
            //FIFO to SCSI
            F2S_1: begin
                if (CDREQ_)
                    state_reg <= F2S_2;
                else
                    state_reg <= F2S_1;
            end
            F2S_2: state_reg <= F2S_3;
            F2S_3: state_reg <= F2S_4;
            F2S_4: state_reg <= IDLE_DMA_WR;
            //SCSI to FIFO
            S2F_1: begin
                if (CDREQ_)
                    state_reg <= S2F_2;
                else
                    state_reg <= S2F_1;
            end
            S2F_2: state_reg <= S2F_3;
            S2F_3: state_reg <= S2F_4;
            S2F_4: state_reg <= IDLE_DMA_RD;
        endcase
	end

end

always @(*)
begin
    CPU2S       <= 1'b0;
    DACK        <= 1'b0;
    F2S         <= 1'b0;
    INCBO       <= 1'b0;
    INCNI       <= 1'b0;
    INCNO       <= 1'b0;
    RDFIFO      <= 1'b0;
    RE          <= 1'b0;
    RIFIFO      <= 1'b0;
    S2CPU       <= 1'b0;
    S2F         <= 1'b0;
    SCSI_CS     <= 1'b0;
    WE          <= 1'b0;
    SET_DSACK   <= 1'b0;

    case (state_reg)
        IDLE_DMA_RD: if (START_S2F) DACK <= 1'b1;
        IDLE_DMA_WR: if (START_F2S) DACK <= 1'b1;
        CPUREQ: begin
            SCSI_CS     <= 1'b1;
            if (RW) begin
                RE      <= 1'b1;
                S2CPU   <= 1'b1;
            end
            else begin
                WE      <= 1'b1;
                CPU2S   <= 1'b1;
            end
        end
        //CPU to SCSI
        C2S_1: begin
            SCSI_CS     <= 1'b1;
            CPU2S       <= 1'b1;
            WE          <= 1'b1;
        end
        C2S_2: begin
            SCSI_CS     <= 1'b1;
            CPU2S       <= 1'b1;
            WE          <= 1'b1;
        end
        C2S_3: begin
            SCSI_CS     <= 1'b1;
            CPU2S       <= 1'b1;
            SET_DSACK   <= 1'b1;
        end
        //FIFO to SCSI
        F2S_1: begin
            WE          <= 1'b1;
            F2S         <= 1'b1;
            DACK        <= 1'b1;
        end
        F2S_2: begin
            WE          <= 1'b1;
            F2S         <= 1'b1;
            DACK        <= 1'b1;
        end
        F2S_3: begin
            //WE          <= 1'b1;
            F2S         <= 1'b1;
            //DACK        <= 1'b1;
        end
        F2S_4: begin
            F2S         <= 1'b1;
            INCBO       <= 1'b1;
            if (BOEQ3) begin
                INCNO   <= 1'b1;
                RDFIFO  <= 1'b1;
            end
        end
        //SCSI to CPU
        S2C_1: begin
            RE          <= 1'b1;
            S2CPU       <= 1'b1;
            SCSI_CS     <= 1'b1;
        end
        S2C_2: begin
            RE          <= 1'b1;
            S2CPU       <= 1'b1;
            SCSI_CS     <= 1'b1;
        end
        S2C_3: begin
            RE          <= 1'b1;
            S2CPU       <= 1'b1;
            SCSI_CS     <= 1'b1;
            //SET_DSACK   <= 1'b1;
        end
        S2C_4: begin
            RE          <= 1'b1;
            S2CPU       <= 1'b1;
            SCSI_CS     <= 1'b1;
            SET_DSACK   <= 1'b1;  //moved to S2C_3 so DSACK is asserted earlier
        end
        S2C_5: begin
            S2CPU       <= 1'b1;
        end
        S2C_6: begin
            S2CPU       <= 1'b1;
        end
        //SCSI to FIFO
        S2F_1: begin
                RE      <= 1'b1;
                S2F     <= 1'b1;
                DACK    <= 1'b1;
            if (FIFOFULL) begin
                INCNI   <= 1'b1;
                INCNO   <= 1'b1;
            end
           /*  else begin
                RE      <= 1'b1;
                S2F     <= 1'b1;
                DACK    <= 1'b1;
            end */
        end
        S2F_2: begin
            RE          <= 1'b1;
            S2F         <= 1'b1;
            DACK        <= 1'b1;
        end
        S2F_3: begin
            //RE          <= 1'b1;
            S2F         <= 1'b1;
            //DACK        <= 1'b1;
        end
        S2F_4: begin
            INCBO       <= 1'b1;
            S2F         <= 1'b1;
            if (BOEQ3) begin
                INCNI   <= 1'b1;
                RIFIFO  <= 1'b1;
            end
        end
    endcase
end

endmodule