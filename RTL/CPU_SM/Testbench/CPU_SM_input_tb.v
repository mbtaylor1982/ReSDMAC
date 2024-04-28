`timescale 1ns/100ps

`ifdef __ICARUS__ 
    `include "RTL/CPU_SM/CPU_SM_inputs.v"
    `include "RTL/CPU_SM/CPU_SM_Output.v"
    `include "RTL/CPU_SM/cpudff1.v"
    `include "RTL/CPU_SM/cpudff2.v"
    `include "RTL/CPU_SM/cpudff3.v"
    `include "RTL/CPU_SM/cpudff4.v"
    `include "RTL/CPU_SM/cpudff5.v"
`endif 


module CPU_SM_inputs_TB;

  // Define module outputs
  wire [62:0] E;
  wire [62:0] nE;

  wire [4:0] NEXT_STATE;

  wire cpudff1_d;
  wire cpudff2_d;
  wire cpudff3_d;
  wire cpudff4_d;
  wire cpudff5_d;
  
  reg A1;
  reg BGRANT_;
  reg BOEQ3;
  reg CYCLEDONE;
  reg DMADIR;
  reg DMAENA;
  reg DREQ_;
  reg DSACK0_;
  reg DSACK1_;
  reg FIFOEMPTY;
  reg FIFOFULL;
  reg FLUSHFIFO;
  reg LASTWORD;

cpudff1 u_cpudff1(
    .DSACK        (DSACK        ),
    .nDSACK       (nDSACK       ),
    .STERM_       (STERM_       ),
    .nSTERM_      (nSTERM_      ),
    .nE           (nE           ),
    .E            (E            ),
    .cpudff1_d    (cpudff1_d    )
);

cpudff2 u_cpudff2(
    .DSACK        (DSACK        ),
    .nDSACK       (nDSACK       ),
    .STERM_       (STERM_       ),
    .nSTERM_      (nSTERM_      ),
    .nE           (nE           ),
    .E            (E            ),
    .cpudff2_d    (cpudff2_d    )
);

cpudff3 u_cpudff3(
    .DSACK        (DSACK        ),
    .nDSACK       (nDSACK       ),
    .STERM_       (STERM_       ),
    .nSTERM_      (nSTERM_      ),
    .nE           (nE           ),
    .E            (E            ),
    .cpudff3_d    (cpudff3_d    )
);

cpudff4 u_cpudff4(
    .DSACK        (DSACK        ),
    .nDSACK       (nDSACK       ),
    .STERM_       (STERM_       ),
    .nSTERM_      (nSTERM_      ),
    .nE           (nE           ),
    .E            (E            ),
    .cpudff4_d    (cpudff4_d    )
);

cpudff5 u_cpudff5(
    .DSACK        (DSACK        ),
    .nDSACK       (nDSACK       ),
    .STERM_       (STERM_       ),
    .nSTERM_      (nSTERM_      ),
    .nE           (nE           ),
    .E            (E            ),
    .cpudff5_d    (cpudff5_d    )
);



  // Instantiate CPU_SM_inputs module
  CPU_SM_inputs uut (
    .A1(A1), 
    .BGRANT_(BGRANT_), 
    .BOEQ3(BOEQ3), 
    .CYCLEDONE(CYCLEDONE), 
    .DMADIR(DMADIR), 
    .DMAENA(DMAENA), 
    .DREQ_(DREQ_),
    .DSACK0_(DSACK0_), 
    .DSACK1_(DSACK1_), 
    .FIFOEMPTY(FIFOEMPTY), 
    .FIFOFULL(FIFOFULL), 
    .FLUSHFIFO(FLUSHFIFO), 
    .LASTWORD(LASTWORD),

    .STATE(STATE), 

    .E(E),
    .nE(nE)
  );

  integer i, j;
  reg [4:0] STATE;
  
  initial begin

  
    for (i = 0; i < 32; i = i + 1) begin
        #10;  // Wait a few simulation time units
        A1 <= 1'b0;
        BGRANT_ <= 1'b1;
        BOEQ3 <= 1'b0;
        CYCLEDONE <= 1'b0;
        DMADIR <= 1'b0;
        DMAENA <= 1'b0;
        DREQ_ <= 1'b0;
        DSACK0_ <= 1'b1;
        DSACK1_ <= 1'b1;
        FIFOEMPTY <= 1'b0;
        FIFOFULL <= 1'b0;
        FLUSHFIFO <= 1'b0;
        LASTWORD <= 1'b0;

      
      
      STATE = i;
      
      // Simulate the module's logic
      #10;

      case (STATE)

        0: begin
            for (j = 0; j < 6; j = j +1) begin
            #10;
                case (j)
                    1:begin
                        DMAENA <= 1'b1;  
                        DMADIR <= 1'b1;  
                        FIFOEMPTY <= 1'b1;  
                        FIFOFULL <= 1'b0;  
                        FLUSHFIFO <= 1'b1;  
                        LASTWORD <= 1'b0;    
                    end
                    2:begin
                        DMAENA <= 1'b1; 
                        DMADIR <= 1'b1; 
                        FIFOEMPTY <= 1'b0; 
                        FLUSHFIFO <= 1'b1;   
                    end
                    3:begin
                        DMAENA <= 1'b1; 
                        DMADIR <= 1'b1; 
                        FLUSHFIFO <= 1'b1;
                        LASTWORD <= 1'b1;    
                    end
                    4:begin
                        DMADIR <= 1'b1;
                        DMAENA <= 1'b1;
                        FIFOFULL <= 1'b1;    
                    end
                    5: begin
                        DMADIR  <= 1'b0;   
                        DMAENA  <= 1'b1;
                    end
                endcase
                #10;
                $display("STATE: %d", STATE);
                if (A1) $display("A1");
                if (~BGRANT_) $display("BGRANT_");
                if (BOEQ3) $display("BOEQ3");
                if (CYCLEDONE) $display("CYCLEDONE");
                if (DMADIR) $display("DMADIR");
                if (DMAENA) $display("DMAENA");
                if (DREQ_) $display("DREQ_");
                if (~DSACK0_) $display("DSACK0_");
                if (~DSACK1_) $display("DSACK1_");
                if (FIFOEMPTY) $display("FIFOEMPTY");
                if (FIFOFULL) $display("FIFOFULL");
                if (FLUSHFIFO) $display("FLUSHFIFO");
                if (LASTWORD) $display("LASTWORD");
                $display("NEXTSTATE: %d", NEXT_STATE);
                $display("E: %h", E);
                $display("----------");
            end
        end
        1: begin
            for (j = 0; j < 3; j = j +1) begin
                #10;
                case (j)
                    1:begin
                        DSACK1_ <= 1'b0;  
                    end
                    2:begin
                        DSACK1_ <= 1'b0; 
                        DSACK0_ <= 1'b0; 
                    end
                endcase 
                #10;
                $display("STATE: %d", STATE);
                if (A1) $display("A1");
                if (~BGRANT_) $display("BGRANT_");
                if (BOEQ3) $display("BOEQ3");
                if (CYCLEDONE) $display("CYCLEDONE");
                if (DMADIR) $display("DMADIR");
                if (DMAENA) $display("DMAENA");
                if (DREQ_) $display("DREQ_");
                if (~DSACK0_) $display("DSACK0_");
                if (~DSACK1_) $display("DSACK1_");
                if (FIFOEMPTY) $display("FIFOEMPTY");
                if (FIFOFULL) $display("FIFOFULL");
                if (FLUSHFIFO) $display("FLUSHFIFO");
                if (LASTWORD) $display("LASTWORD");
                $display("NEXTSTATE: %d", NEXT_STATE);
                $display("E: %h", E);
                $display("----------");  
            end
        end
      endcase 
      $display("----------"); 
    end
    $finish;  // End the simulation
  end

  assign NEXT_STATE = {cpudff5_d, cpudff4_d, cpudff3_d, cpudff2_d, cpudff1_d};






endmodule
