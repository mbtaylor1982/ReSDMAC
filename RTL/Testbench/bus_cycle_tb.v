`timescale 1ns/100ps

`include "AsynchReadBusCycle_FSM.v"
module bus_cycle_tb; 

//inputs
reg [5:0] DIN; 
reg Clk; 
reg _RST;

//Outputs
wire [31:0] ADDR;
wire _AS;
wire _DS;
wire RW;

Asynch_Read_Cycle_FSM dut(
    .Clk (Clk),
    ._RST (_RST),
    ._AS (_AS),
    ._DS (_DS),
    .RW (RW),
    .ADDR (ADDR[31:0])
);

initial begin
    $dumpfile("bus_cycle.vcd");
    $dumpvars(0, bus_cycle_tb);
    Clk = 0;
    _RST = 1;
    repeat(8) 
        #10 Clk = ~Clk;
    repeat(8) 
        #10 Clk = ~Clk;
    #10  $finish;
end

endmodule