/*ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/*/

module datapath_8b_MUX( 
    input [7:0] A,
    input [7:0] B,
    input [7:0] C,
    input [7:0] D,
    input [7:0] E,
    input [7:0] F,

    input [5:0] S,

    output reg [7:0] Z
    
);

always @(A,B,C,D,E,F,S) begin

    case (S)
        6'b000001 : Z = A;
        6'b000010 : Z = B;
        6'b000100 : Z = C;
        6'b001000 : Z = D;
        6'b010000 : Z = E;
        6'b100000 : Z = F;
        default : Z = 8'b00000000; 
    endcase
    
end

endmodule
