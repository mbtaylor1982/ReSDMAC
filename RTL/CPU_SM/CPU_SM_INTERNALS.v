//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

module CPU_SM_INTERNALS(

    input CLK,              //CLK
    input nRESET,           //Active low reset

    input A1,
    input BGRANT,
    input BOEQ3,
    input CYCLEDONE,
    input DMADIR,
    input DMAENA,
    input DREQ,
    input DSACK0,
    input DSACK1,
    input FIFOEMPTY,
    input FIFOFULL,
    input FLUSHFIFO,
    input LASTWORD,
    input DSACK,
    input STERM,

    output reg INCNI,
    output reg BREQ,
    output reg SIZE1,
    output reg PAS,
    output reg PDS,
    output reg F2CPUL,
    output reg F2CPUH,
    output reg BRIDGEOUT,
    output reg PLLW,
    output reg PLHW,
    output reg INCFIFO,
    output reg DECFIFO,
    output reg INCNO,
    output reg STOPFLUSH,
    output reg DIEH,
    output reg DIEL,
    output reg BRIDGEIN,
    output reg BGACK

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
    s18 = 18,
    s19 = 19,
    s20 = 10,
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

reg [4:0] state;

//State 0 input conditions
wire s0a = DMAENA & DMADIR & FIFOEMPTY & ~FIFOFULL & FLUSHFIFO & ~LASTWORD; //E0
wire s0b = DMAENA & DMADIR & ~FIFOEMPTY & FLUSHFIFO; //E2
wire s0c = DMAENA & DMADIR & FLUSHFIFO & LASTWORD; //E3
wire s0d = DMADIR & DMAENA & FIFOFULL; //e7
wire s0e = ~DMADIR & DMAENA; //e13

//State 1 input conditions
wire s1a = DSACK0 & DSACK1 & DSACK//e9
wire s1b = DSACK1 //e20
wire s1c = ~DSACK & ~STERM //e24
wire s1d = STERM//e39

//State 2 input conditions
wire s2a = CYCLEDONE & ~A1 & ~BGRANT_//e11
wire s2b = CYCLEDONE & A1 & ~BGRANT_//e12
wire s2c = BGRANT_//e16
wire s2d = ~CYCLEDONE//e17

//State 3 input conditions
wire s3a = ~DSACK & STERM_//e29
wire s3b = ~DSACK1_ & DSACK //e30
wire s3c = ~STERM_//e42

//State 4 input conditions
wire s4a = nDMADIR & DMAENA//e13
wire s4b = //e53

//State 5 input conditions
wire s5a = DSACK//e50
wire s5b = ~DSACK//e50

//State 6 has no sub states

//State 7 input conditions
wire s7a = DSACK & ~DSACK1_//e28
wire s7b = ~STERM_//e33
wire s7c = ~DSACK & STERM_//e33

//State 8 input conditions
wire s8a = CYCLEDONE & LASTWORD & ~A1 & ~BGRANT_ & ~BOEQ3;//E4
wire s8b = CYCLEDONE & LASTWORD & ~A1 & ~BGRANT_ & BOEQ3;//E5
wire s8c = CYCLEDONE & ~LASTWORD & ~A1 & ~BGRANT_;//E8
wire s8d = CYCLEDONE & A1 & ~BGRANT_;//E10
wire s8e = BGRANT_;//E18
wire s8f = ~CYCLEDONE;//E19

//State 9 & 10 have no sub states

//State 11 input conditions

wire s11a = FIFOFULL; //E32
wire s11b = ~FIFOFULL; //E48

//State 12
wire s12a = STERM_;//E37
wire s12b = ~STERM_;//E37

//state 13
//E37 E50 E62
wire s13a = STERM_;//E37
wire s13b = ~STERM_;//E37
wire s13c = DSACK//e50
wire s13d = ~DSACK//e50


always @(posedge CLK or negedge nRESET)
begin
    if (~nRESET) begin
        state <= s0;
    end
	else begin
       case (state_reg)
        s0: begin
            if (s0a) begin
                state <= s0;
            end;
            if (s0b) begin
                state <= s8;
            end;
             if (s0c) begin
                state <= s8;
            end;
            if (s0d) begin
                state <= s8;
            end;
            if (s0e) begin
                state <= s16;
            end;
        end
        s1: begin
            if (s1a) begin
                state <= s24;
            end;
            if (s1b) begin
                state <= s4;
            end;
             if (s1c) begin
                state <= s1;
            end;
            if (s1d) begin
                state <= s28;
            end;
        end;
        s2: begin
             if (s2a) begin
                state <= s18;
            end;
            if (s2b) begin
                state <= s9;
            end;
             if (s2c) begin
                state <= s2;
            end;
            if (s2d) begin
                state <= s2;
            end;
          
        end
        s3: begin
            if (s3a) begin
                state <= s3;
            end;
            if (s3b) begin
                state <= s28;
            end;
             if (s3c) begin
                state <= s28;
            end;
        end;
        s4: begin
            if (s4a) begin
                state <= s16;
            end;
            if (s4b) begin
                state <= s17;
            end;
        end;
        s5: begin
            if (s5a) begin
                state <= s11;
            end;
            if (s5b) begin
                state <= s5;
            end;
        end;
        s6: begin
            state <= s11;
        end;
        s7: begin
            if (s7a) begin //DSACK & ~DSACK1_ e28
                state <= s28;
            end; 
            if (s7b) begin //~STERM e33
                state <= s28;
            end;
            if (s7c) begin // ~DSACK & STERM_ e33
                state <= s7;
            end;  
        
        end;
        s8: begin
            if (s8a) begin 
                state <= s20;
            end; 
            if (s8b) begin 
                state <= s24;
            end;
            if (s8c) begin 
                state <= s24;
            end;
            if (s8d) begin 
                state <= s4;
            end;  
            if (s8e) begin 
                state <= s8;
            end;  
            if (s8f) begin 
                state <= s8;
            end;  
        
        end;
        s9: begin
            state <= s21;
        end;
        s10: begin
            state <= s26;        
        end
        s11: begin
            if (s11a) begin 
                state <= s23;
            end;  
            if (s11b) begin 
                state <= s25;
            end;  
        end;
        s12: begin
            if (s12a) begin 
                state <= s1;
            end;  
            if (s12b) begin 
                state <= s28;
            end;
          
        end
        s13: begin
            if (s13a) begin
                state <= s21;
            end;
            if (s13b) begin
                state <= s29;
            end;
             if (s13c) begin
                state <= s31;
            end;
            if (s13d) begin
                state <= s21;
            end;
            else begin
                state <= s21; 
            end;
        
        end;
        s14: begin
        
        end;
        s15: begin
        
        end;
        s16: begin
        
        end;
        s17: begin
        
        end;
        s18: begin
        
        end;
        s19: begin
        
        end;
        s20: begin
                
        end
        s21: begin
        end;
        s22: begin
          
        end
        s23: begin
        
        end;
        s24: begin
        
        end;
        s25: begin
        
        end;
        s26: begin
        
        end;
        s27: begin
        
        end;
        s28: begin
        
        end;
        s29: begin
        
        end;
        s30: begin

        end
        s31: begin

        end
	end

end

task SetOutputDefaults();
    begin
        CPU2S       <= 1'b0;
        INCNI       <= 1'b0;
        SIZE1       <= 1'b0;
        PAS         <= 1'b0;
        F2CPUL      <= 1'b0;
        BRIDGEOUT   <= 1'b0;
        PLLW        <= 1'b0;
        PLHW        <= 1'b0;
        INCFIFO     <= 1'b0;
        DECFIFO     <= 1'b0;
        INCNO       <= 1'b0;
        STOPFLUSH   <= 1'b0;
        DIEH        <= 1'b0;
        DIEL        <= 1'b0;
        BRIDGEIN    <= 1'b0;
        BGACK       <= 1'b0;
    end
endtask

always @(*)
begin
    SetOutputDefaults();
    case (state_reg)
        s0: begin
            if (s0a) begin
                STOPFLUSH <= 1'b1;
            end
            if (s0b | s0c | s0d) begin
                BREQ <= 1'b1;
            end
        end
        s1: begin
            if(s1a) begin
                INCNO   <= 1'b1;
                DECFIFO <= 1'b1;
            end;
            if(s1b) begin
                F2CPUL <= 1'b1;
                F2CPUH <= 1'b1;
            end;
            if(s1c) begin
                PAS <= 1'b1;
                PDS <= 1'b1;
                F2CPUL <= 1'b1;
                F2CPUH <= 1'b1;
            end;
            if (s1d) begin
                F2CPUL  <= 1'b1;
                F2CPUH  <= 1'b1;
                INCNO   <= 1'b1;
                DECFIFO <= 1'b1;
            end
        end;
        s2: begin
            if(s2a) begin
                BREQ <= 1'b1;
            end;
            if(s2b) begin
                BREQ <= 1'b1;
            end;
            if(s2c) begin
                BREQ <= 1'b1;
            end;
            if (s2d) begin
             BREQ <= 1'b1;
            end
          
        end
        s3: begin
            if(s3a) begin
                SIZE1       <= 1'b1;
                PAS         <= 1'b1;
                PDS         <= 1'b1;
                F2CPUL      <= 1'b1;
                BRIDGEOUT   <= 1'b1;
            end;
            if(s3b) begin
                SIZE1       <= 1'b1;
                F2CPUL      <= 1'b1;
                BRIDGEOUT   <= 1'b1;
                INCNO       <= 1'b1;
                DECFIFO     <= 1'b1;
                
            end;
            if(s3c) begin
                SIZE1       <= 1'b1;
                F2CPUL      <= 1'b1;
                BRIDGEOUT   <= 1'b1;
                INCNO       <= 1'b1;
                DECFIFO     <= 1'b1;
            end;
        
        end;
        s4: begin
            if (s4a) begin
                //nothing to change on outputs
            end;
            if (s4b) begin
                SIZE1       <= 1'b1; // not sure on this one
                PAS         <= 1'b1;
                F2CPUL      <= 1'b1;
                BRIDGEOUT   <= 1'b1;
            end;
        
        end;
        s5: begin
            if (s5a) begin //DSACK
                SIZE1       <= 1'b1;
                BRIDGEIN    <= 1'b1;   
            end;
            if (s5b) begin //~DSACK
                SIZE1       <= 1'b1;
                PAS         <= 1'b1;
                PDS         <= 1'b1;
                INCFIFO     <= 1'b1;
                DIEH        <= 1'b1;
                BRIDGEIN    <= 1'b1;
            end;        
        end;
        s6: begin
            BRIDGEIN    <= 1'b1;
        end;
        s7: begin
            if (s7a) begin //DSACK & ~DSACK1_ e28
                SIZE1       <= 1'b1;
              
            end;
            if (s7b) begin //~STERM e33
                SIZE1       <= 1'b1;
                F2CPUL      <= 1'b1;
                F2CPUH      <= 1'b1;   
            end;   
            if (s7c) begin // ~DSACK & STERM_ e33
                SIZE1       <= 1'b1;
                PAS         <= 1'b1;
                PDS         <= 1'b1;
                F2CPUL      <= 1'b1;
                F2CPUH      <= 1'b1; 
            end;       
        end;
        s8: begin
            if (s8a) begin 
                BREQ        <= 1'b1;
                STOPFLUSH   <= 1'b1;
            end; 
            if (s8b) begin 
                BREQ        <= 1'b1;
                STOPFLUSH   <= 1'b1;
            end;
            if (s8c) begin 
                BREQ        <= 1'b1;
            end;
            if (s8d) begin 
                BREQ        <= 1'b1;
            end;  
            if (s8e) begin 
                BREQ        <= 1'b1;
            end;  
            if (s8f) begin 
                BREQ        <= 1'b1;
            end; 
        
        end;
        s9: begin
            SIZE1       <= 1'b1;
            PAS         <= 1'b1;
            PDS         <= 1'b1;
            PLLW        <= 1'b1;
            DIEH        <= 1'b1;
            DIEL        <= 1'b1;
        end;
        s10: begin
            SIZE1       <= 1'b1;
            PAS         <= 1'b1;
            PDS         <= 1'b1;
            PLLW        <= 1'b1;
            DIEH        <= 1'b1;
            BRIDGEIN    <= 1'b1;
        end
        s11: begin
            if (s11a) begin 
                INCNI       <= 1'b1;
            end;  
            if (s11b) begin 
                INCNI       <= 1'b1;
                PAS         <= 1'b1;
                PDS         <= 1'b1;
                PLLW        <= 1'b1;
                PLHW        <= 1'b1;
                DIEH        <= 1'b1;
                DIEL        <= 1'b1;
            end;  
        end;
        s12: begin
            if (s12a) begin
                PAS         <= 1'b1;
                PDS         <= 1'b1;
                F2CPUL      <= 1'b1;
                F2CPUH      <= 1'b1;
            end;
            if (s12b) begin
                F2CPUL      <= 1'b1;
                F2CPUH      <= 1'b1;
                INCNO       <= 1'b1;
                DECFIFO     <= 1'b1;
            end;
        end
        s13: begin
            SIZE1       <= 1'b1;
            PAS         <= 1'b1;
            PDS         <= 1'b1;
            PLLW        <= 1'b1;
            DIEH        <= 1'b1;
            DIEL        <= 1'b1;

            if (s13a) begin
                PAS         <= 1'b1;
                PDS         <= 1'b1;
                F2CPUL      <= 1'b1;
                F2CPUH      <= 1'b1;
            end;
            if (s13b) begin
                F2CPUL      <= 1'b1;
                F2CPUH      <= 1'b1;
                INCNO       <= 1'b1;
                DECFIFO     <= 1'b1;
            end;
             if (s13c) begin
                SIZE1       <= 1'b1;
                INCFIFO     <= 1'b1;
                BRIDGEIN    <= 1'b1;
                DIEH        <= 1'b1;
            end;
            if (s13d) begin
                SIZE1       <= 1'b1;
                PAS         <= 1'b1;
                PDS         <= 1'b1;
                PLLW        <= 1'b1;
                BRIDGEIN    <= 1'b1;
                DIEH        <= 1'b1;
            end;
        end;
        s14: begin
        
        end;
        s15: begin
        
        end;
        s16: begin
        
        end;
        s17: begin
        
        end;
        s18: begin
        
        end;
        s19: begin
        
        end;
        s20: begin
                
        end
        s21: begin
        end;
        s22: begin
          
        end
        s23: begin
        
        end;
        s24: begin
        
        end;
        s25: begin
        
        end;
        s26: begin
        
        end;
        s27: begin
        
        end;
        s28: begin
        
        end;
        s29: begin
        
        end;
        s30: begin

        end
        s31: begin

        end
    endcase
end

endmodule