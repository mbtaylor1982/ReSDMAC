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
