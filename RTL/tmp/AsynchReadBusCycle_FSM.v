module Asynch_Read_Cycle_FSM(RW, _AS, _DS, _RST, Clk, ADDR);

localparam IDLE = 3'b111;
localparam S0 = 3'b000;
localparam S1 = 3'b001;
localparam S2 = 3'b010;
localparam S3 = 3'b011;
localparam S4 = 3'b100;
localparam S5 = 3'b101;  

input Clk, _RST;
output _AS, _DS, RW;
output [31:0] ADDR;

reg [3:0] State = IDLE;

reg _AS, _DS, RW;
reg [31:0] ADDR;

  
always @(Clk or negedge _RST)
begin
    if( _RST == 1'b0 ) begin
        State <= IDLE;
    end else begin
        case(State)
            IDLE: begin 
                _AS <= 1'b1;
                _DS <= 1'b1;
                ADDR <= 32'h00000000;
                RW <= 1'b0;
                State <= S0;
            end
            S0: begin
                ADDR <= 32'h00DD000;
                RW <= 1'b1;
                _AS <= 1'b0;
                State <= S1;
            end
            S1: begin
                _DS <= 1'b0;
                State <= S2;
            end
            S2: begin
                State <= S3;
            end
            S3: begin
                State <= S4;
            end
            S4: begin
                //Latch Incoming Data at end of S4.
                State <= S5;    
            end
            S5: begin
              State <= IDLE;
              _AS <= 1'b1;
              _DS <= 1'b1;
            end
        endcase
   end
end

endmodule