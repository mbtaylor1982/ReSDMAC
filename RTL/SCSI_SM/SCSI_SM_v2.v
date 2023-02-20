// Copyright 2023 mbtay
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// mealy_regular_template.v

module SCSI_SM_v2 
#( parameter 
		param1 = <value>, 
		param2 = <value>,
)
(
	input wire clk, reset,

    input wire BOEQ3, CPUREQ, DECFIFO, DMADIR, DREQ_, FIFOEMPTY, FIFOFULL, INCFIFO, nAS_,RW,
	output reg CPU2S_o, DACK_o, F2S_o, INCBO_o, INCNI_o, INCNO_o, RDFIFO_o, RE_o,RIFIFO_o,
    S2CPU_o, S2F_o, SCSI_CS_o, WE_o,
    output wire LBYTE_, LS2CPU        
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
    s18 = 17,
    s19 = 19,
    s20 = 20,
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
    
    reg[4:0] state_reg, state_next; 

always(posedge clk, posedge reset)
begin
    if (reset) begin
        state_reg <= s0;
    end
    else begin
        state_reg <= state_next;
    end
end 


always @(*) begin 
    state_next = state_reg; // default state_next
    // default outputs
    output1 = <value>;
    output2 = <value>;
    ...
    case (state_reg)
        s0 : begin
            if (CCPUREQ == 1'b1) begin
                output1 = <value>;
                output2 = <value>;
                ...
                state_next = s8;
            end
            else 
            begin
                if (DMADIR == 1'b0) begin 
                    output1 = <value>;
                    output2 = <value>;
                    ...
                    state_next = s16; 
                end

                if ((~CDREQ_ & ~FIFOFULL & DMADIR & ~RIFIFO_o) == 1'b1) begin
                    output1 = <value>;
                    output2 = <value>;
                    ...
                    state_next = s24; 
                end
            end
            else begin // remain in current state
                state_next = s0; 
            end
        end
        s1 : begin
            ...
        end
    endcase
end  
    
always(posedge clk, posedge reset) begin 
    if (reset) begin
        new_output1 <= ... ;
        new_output2 <= ... ;
    else begin
        new_output1 <= output1; 
        new_output2 <= output2; 
    end
end 
endmodule 