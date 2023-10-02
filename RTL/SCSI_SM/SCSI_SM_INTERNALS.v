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

    reg [4:0] state_reg, state_next;

always @(posedge CLK or negedge nRESET)
begin
    if (~nRESET) begin
        state_reg <= IDLE_DMA_RD;
    end
    else begin
        state_reg <= state_next;
    end
end 

always @(*)
begin
    case (state_reg)
        IDLE_DMA_RD: begin
            if (~CDREQ_ & ~FIFOFULL & DMADIR & ~CCPUREQ & ~RIFIFO_o)
                state_next <= S2F_1;
            else if (CCPUREQ)
                state_next <= CPUREQ;
            else if (~DMADIR & ~CCPUREQ)
                state_next <= IDLE_DMA_WR;
        end
        IDLE_DMA_WR: begin
            if (~CDREQ_ & ~FIFOEMPTY & ~DMADIR & ~CCPUREQ & ~RDFIFO_o)
                state_next <= F2S_1;
            else if (CCPUREQ)
                state_next <= CPUREQ;
            else
                state_next <= IDLE_DMA_RD;
        end
        CPUREQ: begin
            if (RW)
                state_next <= S2C_1;
            else
                state_next <= C2S_1;
        end
        //CPU to SCSI
        C2S_1: begin
            state_next <= C2S_2;
        end
        C2S_2: begin
            state_next <= C2S_3;
        end
        C2S_3: begin
            state_next <= C2S_4;
        end
        C2S_4: begin
            state_next <= C2S_5;
        end
        C2S_5: begin
            if (CDSACK_)
                state_next <= IDLE_DMA_RD;
            else
                state_next <= C2S_5;
        end
        //FIFO to SCSI
        F2S_1: begin
            state_next <= F2S_2;
        end
        F2S_2: begin
            state_next <= F2S_3;
        end
        F2S_3: begin
            state_next <= F2S_4;
        end
        F2S_4: begin
            state_next <= IDLE_DMA_WR;
        end
        //SCSI to CPU
        S2C_1: begin
            state_next <= S2C_2;
        end
        S2C_2: begin
            state_next <= S2C_3;
        end
        S2C_3: begin
            state_next <= S2C_4;
        end
        S2C_4: begin
            state_next <= S2C_5;
        end
        S2C_5: begin
            state_next <= S2C_6;
        end
        S2C_6: begin
            if (CDSACK_)
                state_next <= IDLE_DMA_RD;
            else
                state_next <= S2C_6;
        end
        //SCSI to FIFO
        S2F_1: begin
            state_next <= S2F_2;
        end
        S2F_2: begin
            state_next <= S2F_3;
        end
        S2F_3: begin
            state_next <= S2F_4;
        end
        S2F_4: begin
            state_next <= IDLE_DMA_RD;
        end
    endcase

end

task SetOutputDefaults();
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
    end
endtask

always @(*)
begin
    SetOutputDefaults();

    case (state_reg)
        IDLE_DMA_RD: begin
            if (~CDREQ_ & ~FIFOFULL & DMADIR & ~CCPUREQ & ~RIFIFO_o)
                DACK    <= 1'b1;
        end
        IDLE_DMA_WR: begin
            if (~CDREQ_ & ~FIFOEMPTY & ~DMADIR & ~CCPUREQ & ~RDFIFO_o)
                DACK    <= 1'b1;
        end
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
        C2S_4: begin
        end
        C2S_5: begin
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
            WE          <= 1'b1;
            F2S         <= 1'b1;
            DACK        <= 1'b1;
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
            if (FIFOFULL) begin
                INCNI   <= 1'b1;
                INCNO   <= 1'b1;
            end
            else begin
                RE      <= 1'b1;
                S2F     <= 1'b1;
                DACK    <= 1'b1;
            end
        end
        S2F_2: begin
            RE          <= 1'b1;
            RE          <= 1'b1;
            S2F         <= 1'b1;
            DACK        <= 1'b1;
        end
        S2F_3: begin
            RE          <= 1'b1;
            S2F         <= 1'b1;
            DACK        <= 1'b1;
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