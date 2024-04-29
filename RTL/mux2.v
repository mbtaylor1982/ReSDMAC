/*ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/*/

module MUX2(
    input  A,
    input  B,
    input  S,

    output reg Z

);

always @(*) begin

    case (S)
        1'b0 : Z = A;
        1'b1 : Z = B;
        default : Z = 1'bx;
    endcase
end

endmodule 
