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
    input CDSACK_,          //DSACK 
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
    output reg SET_DSACK
    
);

localparam [4:0] 
    s0 = 0, //IDLE
    s1 = 1,
    s2 = 2,
    s3 = 3,
    s4 = 4,
    s6 = 6,
    s8 = 8,
    s9 = 9,
    s10 = 10,
    s12 = 12,
    s14 = 14,
    s16 = 16,
    s17 = 17,
    s18 = 18,
    s19 = 19,
    s20 = 20,
    s22 = 22,
    s24 = 24,
    s25 = 25,
    s26 = 26,
    s28 = 28,
    s30 = 30;
    
    reg [4:0] state_reg, state_next;

always @(posedge CLK or negedge nRESET)
begin
    if (~nRESET) begin
        state_reg <= s0;
    end
    else begin
        state_reg <= state_next;
    end
end 


always @(posedge CLK) begin 
    // default state_next
    state_next  = state_reg; 
    
    // default outputs
    CPU2S       = 0;   
    DACK        = 0;
    F2S         = 0;
    INCBO       = 0;   
    INCNI       = 0;   
    INCNO       = 0;   
    RDFIFO      = 0;  
    RE          = 0;      
    RIFIFO      = 0;  
    S2CPU       = 0;   
    S2F         = 0;     
    SCSI_CS     = 0; 
    WE          = 0;      
    SET_DSACK   = 0;
    
    case (state_reg)
        s0 : begin
            if (~CDREQ_ & ~FIFOFULL & DMADIR & ~CCPUREQ & ~RIFIFO_o) begin
                DACK = 1;
                state_next = s24;
            end
            else if (CCPUREQ) 
                state_next = s8;
            else if (~DMADIR & ~CCPUREQ)
                state_next = s16; 
        end
        s1 : begin
            F2S     = 1;
            INCBO   = 1;
            INCNO   = BOEQ3;
            RDFIFO  = BOEQ3;
            state_next = s16;    
        end
        s2 : begin
            WE      = 1;
            F2S     = 1;
            DACK    = 1;
            state_next = s18;
        end
        s3 : begin
            RE      = 1;
            S2CPU   = 1;
            SCSI_CS = 1;
            state_next = s19;
        end
        s4 : begin
            RE      = 1;
            S2F     = 1;
            DACK    = 1;
            state_next = s20;
        end
        s6 : begin
            CPU2S       = 1;
            SET_DSACK   = 1;
            SCSI_CS     = 1;
            state_next = s22;
        end
        s8 : begin
            SCSI_CS = 1;

            if (RW) begin
                RE      = 1;
                S2CPU   = 1;
                state_next = s10;
            end 
            else begin
                WE      = 1;
                CPU2S   = 1;
                state_next = s17;
            end
        end
        s9 : begin
            S2CPU = 1;
            state_next = s25;
        end
        s10: begin
            RE      = 1;
            S2CPU   = 1;
            SCSI_CS = 1;
            state_next = s30;
        end 
        s12 : begin
            INCBO   = 1;
            S2F     = 1;
            INCNI   = BOEQ3;
            RIFIFO  = BOEQ3;
            state_next = s0;    
        end
        s14 : begin
            if (CDSACK_)
                state_next = s0;
        end
        s16 : begin
            if (~CDREQ_ & ~FIFOEMPTY & ~DMADIR & ~CCPUREQ & ~RDFIFO_o) begin
                DACK = 1;
                state_next = s28;
            end
            else if (CCPUREQ)
                state_next = s8;            
        end
        s17 : begin
            WE      = 1;
            CPU2S   = 1;
            SCSI_CS = 1;
            state_next = s26;    
        end
        s18 : begin
            WE      = 1;
            F2S     = 1;
            DACK    = 1;
            state_next = s1;    
        end
        s19 : begin
            RE          = 1;
            S2CPU       = 1;
            SET_DSACK   = 1;
            state_next = s9;
        end
        s20 : begin
            RE      = 1;
            S2F     = 1;
            DACK    = 1;
            state_next = s12;
        end
        s22 : begin
            state_next = s14;    
        end
        s24 : begin
            if (FIFOFULL) begin
                INCNI = 1;
                INCNO = 1;    
            end 
            else begin
                RE = 1;
                S2F = 1;
                DACK = 1;
            end   
            state_next = s4;
        end
        s25 : begin
            S2CPU = 1;
            if (CDSACK_)
                state_next = s0;
        end
        s26 : begin
            WE      = 1;
            CPU2S   = 1;
            SCSI_CS = 1;
            state_next = s6;
        end
        s28 : begin
            WE      = 1;
            F2S     = 1;
            DACK    = 1;    
            state_next = s2;
        end
        s30 : begin
            RE          = 1;
            S2CPU       = 1;
            SCSI_CS     = 1;    
            state_next = s3;
        end

    endcase
end  
    

endmodule 