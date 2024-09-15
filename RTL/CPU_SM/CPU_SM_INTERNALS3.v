//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

// 9/12/90 Remove INCNO output because it is the same as DECFIFO

module CPU_SM_INTERNALS3(

    input CLK,              // sCLK
    input CLK45,            // sCLK phase shifted 45 degrees.
    input CLK90,            // sCLK phase shifted 90 degrees.
    input CLK135,           // sCLK phase shifted 135 degrees.
    input nRESET,           // Reset
    input A1,               // DMA address bit
    input nBGRANT,          // bus grant
    input BOEQ3,            // Byte offset = 3. 3 valid bytes are in the current FIFO entry.
    input CYCLEDONE,        // nAS,DSACKx,nSTERM and nBGACK are all high
    input DMADIR,           // DMA direction (low=write to DISK)
    input DMAENA,           // DMA is turned on
    input nDREQ,            // data request from SCSI chip
    input nDSACK0,          // speed critical
    input nDSACK1,          // speed critical
    input FIFOEMPTY,        // FIFOCNT = 0
    input FIFOFULL,         // FIFOCNT = 8
    input FLUSHFIFO,        // Flush the FIFO. When flushed an interrupt should occur.
    input LASTWORD,         // If FLUSHing & FIFOEMPTY & !BOEQ0 then we got 1 last lonely word to send to the CPU
    input DSACK,            // If either DSACKx signal is low on a falling CPUCLK edge, this signal goes valid (speed critical).
    input nSTERM,           // Synchrnous cycle termination
    input nRDFIFO,          // Request to Decrement FIFO CouNTer. From the SCSI state machine.
    input nRIFIFO,          // Request to Increment FIFO CouNTer. From the SCSI state machine.

    output reg INCNI,       // increment pointer to next longword in
    output reg BREQ,        // bus request
    output reg SIZE1,       // size1,size0=00 lword ; =10 word
    output reg PAS,         // pre adress strobe (gets clocked out on falling cpuclk)
    output reg PDS,         // pre data strobe  (gets clocked out on falling cpuclk)
    output reg F2CPUL,      // Send D0-D15 out D0-D15
    output reg F2CPUH,      // Send D16-D31 out D16-D31
    output reg BRIDGEOUT,   // Send D0-D15 out D16-D31
    output reg PLLW,        // pre Latch Low Words. DMA data being written to FIFO. Latch actually occurs on falling edge of CLK
    output reg PLHW,        // pre Latch High Words. DMA data being written to FIFO. Latch actually occurs on falling edge of CLK
    output reg INCFIFO,     // INCrement the FIFO counter.
    output reg DECFIFO,     // DECrement the FIFO counter.
    output reg INCNO,       // increment pointer to next longword out (same output as DECFIFO)
    output reg STOPFLUSH,   // Turn the FLUSHFIFO bit off.
    output reg DIEH,        // Data Input Enable for High word.
    output reg DIEL,        // Data Input Enable for Low word.
    output reg BRIDGEIN,    // Send D16-D31 inputs to D0-D15 input lines
    output reg BGACK        // bus grant acknowledge
);

//only 27 state are actually used.
localparam [5:0]
    s0 = 0,
    s1 = 1,
    s2 = 2,
    s3 = 3,
    s4 = 4,
    //s5 = 5,
    s6 = 6,
    s7 = 7,
    s8 = 8,
    //s9 = 9,
    s10 = 10,
    s11 = 11,
    s12 = 12,
    //s13 = 13,
    //s14 = 14,
    s15 = 15,
    //s16 = 16,
    //s17 = 17,
    //s18 = 18,
    //s19 = 19,
    s20 = 10,
    s21 = 21,
    s22 = 22,
    s23 = 23,
    s24 = 24,
    //s25 = 25,
    s26 = 26,
    s27 = 27,
    s28 = 28,
    //s29 = 29,
    s30 = 30,
    s31 = 31,
    s32 = 32,
    s33 = 33,
    s34 = 34,
    s35 = 35,
    letgo = 36;

reg [5:0] STATE;
wire [5:0] NEXT_STATE;

always @(*) begin
    case(STATE)
        
        //-- DMA read from FIFO writing to CPU
        
        s0: begin
             casex ({DMAENA, FIFOFULL, DMADIR, FLUSHFIFO, FIFOEMPTY, LASTWORD})
                6'b0xxxxx   : NEXT_STATE <= s0;     // DMA is not turned on
                6'b1010xx   : NEXT_STATE <= s0;     // FIFO not yet full
                6'b101110   : NEXT_STATE <= s0;     //(STOPFLUSH);  Nothing to flush
                6'b10110x   : NEXT_STATE <= s1;     //(BREQ);  flush whatever's there
                6'b101111   : NEXT_STATE <= s1;     //(BREQ);  One last lonely word to send to CPU
                6'b111xxx   : NEXT_STATE <= s1;     //(BREQ);  time to dump the FIFO to CPU
                6'b1x0xxx   : NEXT_STATE <= s20;    //go to DMA write mode
                default     : NEXT_STATE <= STATE;
            endcase
        end
        s1: begin
            casex ({nBGRANT, CYCLEDONE, A1, LASTWORD, BOEQ3}) // wait for the bus
                5'b1xxxx    : NEXT_STATE <= s1;     //(BREQ);
                5'b00xxx    : NEXT_STATE <= s1;     //(BREQ);
                5'b0100x    : NEXT_STATE <= s2;     //(BREQ BGACK); start, lword aligned
                5'b01011    : NEXT_STATE <= s2;     //(BREQ BGACK STOPFLUSH); start, 3 bytes left so write lword
                5'b011xx    : NEXT_STATE <= s6;     //(BREQ BGACK); start, lword unaligned (only happen very first time)
                5'b01010    : NEXT_STATE <= s10;    //(BREQ BGACK STOPFLUSH); start, very last byte/word, so write word
                default     : NEXT_STATE <= STATE;
            endcase
        end
        
        //----- Attempt to write the entire aligned longword -----

        s2: NEXT_STATE <= s3;                       //goto s3(BGACK PAS F2CPUH F2CPUL);
        s3: NEXT_STATE <= nSTERM ? s4 : s15;        //if NOT STERM_ then s15(BGACK F2CPUH F2CPUL DECFIFO) -- first cycle of a CPU access else s4(BGACK PAS PDS F2CPUH F2CPUL);
        s4: begin
            casex ({nSTERM, DSACK, nDSACK1, nDSACK0_}) // wait for cycle to end
                4'b0xxx     : NEXT_STATE <= s15;    //(BGACK F2CPUH F2CPUL DECFIFO);   -- 32 bit cycle terminated
                4'b10xx     : NEXT_STATE <= s4;     //(BGACK PAS PDS F2CPUH F2CPUL);   -- Cycle not yet terminated
                4'b1100     : NEXT_STATE <= s15;    //(BGACK F2CPUH F2CPUL DECFIFO);   -- 32 bit cycle terminated
                4'b1101     : NEXT_STATE <= s6;     //(BGACK F2CPUH F2CPUL);           -- 16 bit cycle terminated, so now write the 2nd word
                default     : NEXT_STATE <= STATE;
                //4'b1110 8 bit ports not supported
                //4'b1111 impossible (I hope...)
            endcase
        end

        //----- Write the 16 bit odd word value -----

        s6: NEXT_STATE <= s7;                       //goto s7(BGACK PAS BRIDGEOUT F2CPUL SIZE1); -- start a CPU cycle (lword unaligned)
        s7: NEXT_STATE <= nSTERM ? s8 : s15;        //if NOT STERM_ then s15(BGACK BRIDGEOUT F2CPUL SIZE1 DECFIFO) -- first cycle of CPU access else s8(BGACK PAS PDS BRIDGEOUT F2CPUL SIZE1);
        s8: begin
            casex ({nSTERM, DSACK, nDSACK1, nDSACK0}) // wait for cycle to end
                4'b0xxx     : NEXT_STATE <= s15;    //(BGACK BRIDGEOUT F2CPUL SIZE1 DECFIFO); -- 32 bit cycle terminated
                4'b10xx     : NEXT_STATE <= s8;     //(BGACK PAS PDS BRIDGEOUT F2CPUL SIZE1); -- Cycle not yet terminated
                4'b1100     : NEXT_STATE <= s15;    //(BGACK BRIDGEOUT F2CPUL SIZE1 DECFIFO); -- 32 bit cycle terminated
                4'b1101     : NEXT_STATE <= s15;    //(BGACK BRIDGEOUT F2CPUL SIZE1 DECFIFO); -- 16 bit cycle terminated
                default     : NEXT_STATE <= STATE;
            endcase
        end
        
        //----- Special case to write last byte or word (not a full longword) to the CPU during a FLUSH of the FIFO -----
        //-- (if only a byte left, then it is padded with an extra byte when the word is written out)

        s10: NEXT_STATE <= s11;                     //goto s11(BGACK PAS F2CPUH F2CPUL SIZE1);
        s11: NEXT_STATE <= nSTERM ? s12 : s15;      //if NOT STERM_ then s15(BGACK F2CPUH F2CPUL SIZE1) -- first cycle of a CPU access else s12(BGACK PAS PDS F2CPUH F2CPUL SIZE1);
        s12: begin
            casex ({nSTERM, DSACK, nDSACK1, nDSACK0}) //wait for cycle to end
                4'b0xxx     : NEXT_STATE <= s15;    //(BGACK F2CPUH F2CPUL SIZE1);          -- 32 bit cycle terminated
                4'b10xx     : NEXT_STATE <= s12;    //(BGACK PAS PDS F2CPUH F2CPUL SIZE1);  -- Cycle not yet terminated
                4'b1100     : NEXT_STATE <= s15;    //(BGACK F2CPUH F2CPUL SIZE1);          -- 32 bit cycle terminated
                4'b1101     : NEXT_STATE <= s15;    //(BGACK F2CPUH F2CPUL SIZE1);          -- 16 bit cycle terminated
                default     : NEXT_STATE <= STATE;
            endcase
        end

        //----- Check if there is anything left to do -----

        s15: begin 
            casex ({FIFOEMPTY, LASTWORD, BOEQ3}) // check if more to do
                3'b10x      : NEXT_STATE <= letgo;   //(BGACK STOPFLUSH);                            -- no more left
                3'b110      : NEXT_STATE <= s11;     //(BGACK PAS F2CPUH F2CPUL SIZE1 STOPFLUSH);    -- very last byte/word to do
                3'b111      : NEXT_STATE <= s3;      //(BGACK PAS F2CPUH F2CPUL STOPFLUSH);          -- very last 3 bytes left,so write LWORD
                3'b0xx      : NEXT_STATE <= s3;      //(BGACK PAS F2CPUH F2CPUL);                    -- start another CPU cycle
                default     : NEXT_STATE <= STATE;
            endcase
        end

        //-- DMA read from CPU writing to FIFO

        //-- How to keep DMA from reading extra data from CPU on its last FIFO fill?? Beats says its OK if it does

        s20: begin
            casex ({DMAENA, DMADIR, FIFOEMPTY, nDREQ})
                4'b0xxx     : NEXT_STATE <= s20;    //DMA is not turned on
                4'b100x     : NEXT_STATE <= s20;    //FIFO not empty yet
                4'b1011     : NEXT_STATE <= s20;    //Don't put data in FIFO 'til SCSI asks for more
                4'b1010     : NEXT_STATE <= s21;    //Time to put data in FIFO
                4'b11xx     : NEXT_STATE <= s0;     //go to DMA read mode
                default     : NEXT_STATE <= STATE;
            endcase
        end

        s21: begin 
            casex ({nBGRANT, CYCLEDONE, A1}) //wait for the bus
                3'b1xx      : NEXT_STATE <= s21;     //(BREQ);
                3'b00x      : NEXT_STATE <= s21;     //(BREQ);
                3'b010      : NEXT_STATE <= s22;     //(BREQ BGACK); -- start, lword aligned
                3'b011      : NEXT_STATE <= s30;     //(BREQ BGACK); -- start, lword unaligned (can only happen very first time)
                default     : NEXT_STATE <= STATE;
            endcase
        end

        //-- Attempt to read the entire aligned longword

        s22: NEXT_STATE <= s23;                     //goto s23(BGACK PAS PDS PLHW PLLW DIEL DIEH); -- start CPU cycle (lword aligned)
        s23: NEXT_STATE <= nSTERM ? s24 : s35;      //if NOT STERM_ then s35(BGACK INCFIFO DIEL DIEH) -- first cycle of a CPU access else s24(BGACK PAS PDS PLHW PLLW DIEL DIEH);

        s24: begin
            casex ({nSTERM, DSACK, nDSACK1, nDSACK0}) //wait for cycle to end
                4'b0xxx     : NEXT_STATE <= s35;    //(BGACK INCFIFO DIEL DIEH);            -- 32 bit cycle terminated
                4'b10xx     : NEXT_STATE <= s24;    //(BGACK PAS PDS PLHW PLLW DIEL DIEH);  -- Cycle not yet terminated
                4'b1100     : NEXT_STATE <= s35;    //(BGACK INCFIFO DIEL DIEH);            -- 32 bit cycle terminated
                4'b1101     : NEXT_STATE <= s26;    //(BGACK DIEH);                         -- 16 bit cycle terminated
                default     : NEXT_STATE <= STATE;
            endcase
        end

        //-- Responded as 16 bits only, so re-Read the 16 bit oddword value from this 16 bit port

        s26: NEXT_STATE <= s27;                     //goto s27(BGACK PAS PDS PLLW SIZE1 DIEH BRIDGEIN); -- start CPU cycle (lword unaligned)
        s27: NEXT_STATE <= s28;                     //goto s28(BGACK PAS PDS PLLW SIZE1 DIEH BRIDGEIN); -- No need to check STERM 'cause if it was a 32 bit port we never could have got here...
        s28: NEXT_STATE <= DSACK ? s35 : s28;       //if NOT DSACK then s28(BGACK PAS PDS PLLW SIZE1 DIEH BRIDGEIN) -- Cycle not yet terminated else s35(BGACK SIZE1 DIEH BRIDGEIN INCFIFO); -- cycle terminated (can assume it was via 16 bit DSACK)

        //-- Special case for very first odd word access of a DMA. We don't know which half of the data bus will have the
        //-- data. If 32 bit port then word will be on D0-D15. If 16 bit port then word will be on D16-D31. Assume it is
        //-- a 32 bit port. If it responds as a 16 bit port, then we have to re-direct the latched input data on D16-D31 to
        //-- D0-D15 and then latch it into the FIFO. This adds a couple of extra cycles before *AS is asserted to begin the
        //-- next DMA read. However, this only happens at worst case 1 time for an entire DMA.

        s30: NEXT_STATE <= s31;                     //goto s31(BGACK PAS PDS PLLW SIZE1 DIEH DIEL); -- start CPU cycle (lword unaligned)
        s31: NEXT_STATE <= nSTERM ? s32 : s35;      //if NOT STERM_ then s35(BGACK SIZE1 DIEH DIEL INCFIFO) -- first cycle of a CPU access else s32(BGACK PAS PDS PLLW SIZE1 DIEH DIEL);
        
        s32: begin
            casex ({nSTERM, DSACK, nDSACK1, nDSACK0}) //wait for cycle to end
                4'b0xxx     : NEXT_STATE <= s35;    //(BGACK SIZE1 DIEH DIEL INCFIFO);      -- 32 bit cycle terminated
                4'b10xx     : NEXT_STATE <= s32;    //(BGACK PAS PDS PLLW SIZE1 DIEH DIEL); -- Cycle not yet terminated
                4'b1100     : NEXT_STATE <= s35;    //(BGACK SIZE1 DIEH DIEL INCFIFO);      -- 32 bit cycle terminated
                4'b1101     : NEXT_STATE <= s33;    //(BGACK PLLW SIZE1);                   -- 16 bit cycle terminated, so gotta bridge & such...
                default     : NEXT_STATE <= STATE;
            endcase
        end
        s33: NEXT_STATE <= s34;                     //goto s34(BGACK PLLW BRIDGEIN);
        s34: NEXT_STATE <= s35;                     //goto s35(BGACK BRIDGEIN INCFIFO);
        s35: NEXT_STATE <= FIFOFULL ? letgo : s23;  //if FIFOFULL then letgo(BGACK INCNI); -- no more room in FIFO else s23(BGACK PAS PDS PLHW PLLW DIEL DIEH INCNI); -- start another CPU cycle

        letgo: NEXT_STATE <= s0;                    //goto s0;

        default : NEXT_STATE <= STATE;
    endcase

end

always @(*) begin
    case(STATE)
        
        //-- DMA read from FIFO writing to CPU
        
        s0: begin
             casex ({DMAENA, FIFOFULL, DMADIR, FLUSHFIFO, FIFOEMPTY, LASTWORD})
                6'b101110   : STOPFLUSH <= 1'b1;     //(STOPFLUSH);  Nothing to flush
                6'b10110x   : BREQ      <= 1'b1;     //(BREQ);  flush whatever's there
                6'b101111   : BREQ      <= 1'b1;     //(BREQ);  One last lonely word to send to CPU
                6'b111xxx   : BREQ      <= 1'b1;     //(BREQ);  time to dump the FIFO to CPU
            endcase
        end

        s1: begin
            BREQ      <= 1'b1;
            casex ({nBGRANT, CYCLEDONE, A1, LASTWORD, BOEQ3}) // wait for the bus
                5'b0100x    : BGACK <= 1'b1;        //(BREQ BGACK); start, lword aligned
                5'b011xx    : BGACK <= 1'b1;        //(BREQ BGACK); start, lword unaligned (only happen very first time)
                5'b0101x    : begin                 //(BREQ BGACK STOPFLUSH);
                    BGACK       <= 1'b1;
                    STOPFLUSH   <= 1'b1;
                end
            endcase
        end
        
        //----- Attempt to write the entire aligned longword -----

        s2: begin //(BGACK PAS F2CPUH F2CPUL);
            BGACK       <= 1'b1;
            PAS         <= 1'b1;
            F2CPUH      <= 1'b1;
            F2CPUL      <= 1'b1;
        end

        s3: begin
            BGACK       <= 1'b1;
            F2CPUL      <= 1'b1;
            F2CPUH      <= 1'b1;
            if(nSTERM) begin //else s4(BGACK PAS PDS F2CPUH F2CPUL);
                PAS     <= 1'b1;
                PDS     <= 1'b1;
            end
            else begin //if NOT STERM_ then s15(BGACK F2CPUH F2CPUL DECFIFO)
                DECFIFO <= 1'b1;
            end
        end

        s4: begin
            BGACK       <= 1'b1;
            F2CPUL      <= 1'b1;
            F2CPUH      <= 1'b1;
            casex ({nSTERM, DSACK, nDSACK1, nDSACK0_}) // wait for cycle to end
                4'b10xx     : begin             //(BGACK F2CPUH F2CPUL PAS PDS );   -- Cycle not yet terminated
                   PAS  <= 1'b1;
                   PDS  <= 1'b1;
                end
                4'b1100     : DECFIFO <= 1'b1;    //(BGACK F2CPUH F2CPUL DECFIFO);   -- 32 bit cycle terminated
                4'b0xxx     : DECFIFO <= 1'b1;    //(BGACK F2CPUH F2CPUL DECFIFO);   -- 32 bit cycle terminated
            endcase
        end

        //----- Write the 16 bit odd word value -----

        s6: begin //goto s7(BGACK PAS BRIDGEOUT F2CPUL SIZE1); -- start a CPU cycle (lword unaligned)
            BGACK       <= 1'b1;
            PAS         <= 1'b1;
            BRIDGEOUT   <= 1'b1;
            F2CPUL      <= 1'b1;
            SIZE1       <= 1'b1;
        end

        s7: begin
            BGACK       <= 1'b1;
            BRIDGEOUT   <= 1'b1;
            F2CPUL      <= 1'b1;
            SIZE1       <= 1'b1;
            if (nSTERM) begin       //else s8(BGACK PAS PDS BRIDGEOUT F2CPUL SIZE1);
                PAS     <= 1'b1;
                PDS     <= 1'b1;
            end else begin          //if NOT STERM_ then s15(BGACK BRIDGEOUT F2CPUL SIZE1 DECFIFO)
                DECFIFO <= 1'b1;
            end
        end

        s8: begin
            casex ({nSTERM, DSACK, nDSACK1, nDSACK0}) // wait for cycle to end
                4'b10xx     : NEXT_STATE <= s8;     //(BGACK BRIDGEOUT F2CPUL SIZE1 PAS PDS); -- Cycle not yet terminated
                4'b1101     : NEXT_STATE <= s15;    //(BGACK BRIDGEOUT F2CPUL SIZE1 DECFIFO); -- 16 bit cycle terminated
                4'b0xxx     : NEXT_STATE <= s15;    //(BGACK BRIDGEOUT F2CPUL SIZE1 DECFIFO); -- 32 bit cycle terminated
                4'b1100     : NEXT_STATE <= s15;    //(BGACK BRIDGEOUT F2CPUL SIZE1 DECFIFO); -- 32 bit cycle terminated
                default     : NEXT_STATE <= STATE;
            endcase
        end
        
        //----- Special case to write last byte or word (not a full longword) to the CPU during a FLUSH of the FIFO -----
        //-- (if only a byte left, then it is padded with an extra byte when the word is written out)

        s10: NEXT_STATE <= s11;                     //goto s11(BGACK PAS F2CPUH F2CPUL SIZE1);
        s11: NEXT_STATE <= nSTERM ? s12 : s15;      //if NOT STERM_ then s15(BGACK F2CPUH F2CPUL SIZE1) -- first cycle of a CPU access else s12(BGACK PAS PDS F2CPUH F2CPUL SIZE1);
        s12: begin
            casex ({nSTERM, DSACK, nDSACK1, nDSACK0}) //wait for cycle to end
                4'b0xxx     : NEXT_STATE <= s15;    //(BGACK F2CPUH F2CPUL SIZE1);          -- 32 bit cycle terminated
                4'b10xx     : NEXT_STATE <= s12;    //(BGACK PAS PDS F2CPUH F2CPUL SIZE1);  -- Cycle not yet terminated
                4'b1100     : NEXT_STATE <= s15;    //(BGACK F2CPUH F2CPUL SIZE1);          -- 32 bit cycle terminated
                4'b1101     : NEXT_STATE <= s15;    //(BGACK F2CPUH F2CPUL SIZE1);          -- 16 bit cycle terminated
                default     : NEXT_STATE <= STATE;
            endcase
        end

        //----- Check if there is anything left to do -----

        s15: begin 
            casex ({FIFOEMPTY, LASTWORD, BOEQ3}) // check if more to do
                3'b10x      : NEXT_STATE <= letgo;   //(BGACK STOPFLUSH);                            -- no more left
                3'b110      : NEXT_STATE <= s11;     //(BGACK PAS F2CPUH F2CPUL SIZE1 STOPFLUSH);    -- very last byte/word to do
                3'b111      : NEXT_STATE <= s3;      //(BGACK PAS F2CPUH F2CPUL STOPFLUSH);          -- very last 3 bytes left,so write LWORD
                3'b0xx      : NEXT_STATE <= s3;      //(BGACK PAS F2CPUH F2CPUL);                    -- start another CPU cycle
                default     : NEXT_STATE <= STATE;
            endcase
        end

        //-- DMA read from CPU writing to FIFO

        //-- How to keep DMA from reading extra data from CPU on its last FIFO fill?? Beats says its OK if it does

        s20: begin
            casex ({DMAENA, DMADIR, FIFOEMPTY, nDREQ})
                4'b0xxx     : NEXT_STATE <= s20;    //DMA is not turned on
                4'b100x     : NEXT_STATE <= s20;    //FIFO not empty yet
                4'b1011     : NEXT_STATE <= s20;    //Don't put data in FIFO 'til SCSI asks for more
                4'b1010     : NEXT_STATE <= s21;    //Time to put data in FIFO
                4'b11xx     : NEXT_STATE <= s0;     //go to DMA read mode
                default     : NEXT_STATE <= STATE;
            endcase
        end

        s21: begin 
            casex ({nBGRANT, CYCLEDONE, A1}) //wait for the bus
                3'b1xx      : NEXT_STATE <= s21;     //(BREQ);
                3'b00x      : NEXT_STATE <= s21;     //(BREQ);
                3'b010      : NEXT_STATE <= s22;     //(BREQ BGACK); -- start, lword aligned
                3'b011      : NEXT_STATE <= s30;     //(BREQ BGACK); -- start, lword unaligned (can only happen very first time)
                default     : NEXT_STATE <= STATE;
            endcase
        end

        //-- Attempt to read the entire aligned longword

        s22: NEXT_STATE <= s23;                     //goto s23(BGACK PAS PDS PLHW PLLW DIEL DIEH); -- start CPU cycle (lword aligned)
        s23: NEXT_STATE <= nSTERM ? s24 : s35;      //if NOT STERM_ then s35(BGACK INCFIFO DIEL DIEH) -- first cycle of a CPU access else s24(BGACK PAS PDS PLHW PLLW DIEL DIEH);

        s24: begin
            casex ({nSTERM, DSACK, nDSACK1, nDSACK0}) //wait for cycle to end
                4'b0xxx     : NEXT_STATE <= s35;    //(BGACK INCFIFO DIEL DIEH);            -- 32 bit cycle terminated
                4'b10xx     : NEXT_STATE <= s24;    //(BGACK PAS PDS PLHW PLLW DIEL DIEH);  -- Cycle not yet terminated
                4'b1100     : NEXT_STATE <= s35;    //(BGACK INCFIFO DIEL DIEH);            -- 32 bit cycle terminated
                4'b1101     : NEXT_STATE <= s26;    //(BGACK DIEH);                         -- 16 bit cycle terminated
                default     : NEXT_STATE <= STATE;
            endcase
        end

        //-- Responded as 16 bits only, so re-Read the 16 bit oddword value from this 16 bit port

        s26: NEXT_STATE <= s27;                     //goto s27(BGACK PAS PDS PLLW SIZE1 DIEH BRIDGEIN); -- start CPU cycle (lword unaligned)
        s27: NEXT_STATE <= s28;                     //goto s28(BGACK PAS PDS PLLW SIZE1 DIEH BRIDGEIN); -- No need to check STERM 'cause if it was a 32 bit port we never could have got here...
        s28: NEXT_STATE <= DSACK ? s35 : s28;       //if NOT DSACK then s28(BGACK PAS PDS PLLW SIZE1 DIEH BRIDGEIN) -- Cycle not yet terminated else s35(BGACK SIZE1 DIEH BRIDGEIN INCFIFO); -- cycle terminated (can assume it was via 16 bit DSACK)

        //-- Special case for very first odd word access of a DMA. We don't know which half of the data bus will have the
        //-- data. If 32 bit port then word will be on D0-D15. If 16 bit port then word will be on D16-D31. Assume it is
        //-- a 32 bit port. If it responds as a 16 bit port, then we have to re-direct the latched input data on D16-D31 to
        //-- D0-D15 and then latch it into the FIFO. This adds a couple of extra cycles before *AS is asserted to begin the
        //-- next DMA read. However, this only happens at worst case 1 time for an entire DMA.

        s30: NEXT_STATE <= s31;                     //goto s31(BGACK PAS PDS PLLW SIZE1 DIEH DIEL); -- start CPU cycle (lword unaligned)
        s31: NEXT_STATE <= nSTERM ? s32 : s35;      //if NOT STERM_ then s35(BGACK SIZE1 DIEH DIEL INCFIFO) -- first cycle of a CPU access else s32(BGACK PAS PDS PLLW SIZE1 DIEH DIEL);
        
        s32: begin
            casex ({nSTERM, DSACK, nDSACK1, nDSACK0}) //wait for cycle to end
                4'b0xxx     : NEXT_STATE <= s35;    //(BGACK SIZE1 DIEH DIEL INCFIFO);      -- 32 bit cycle terminated
                4'b10xx     : NEXT_STATE <= s32;    //(BGACK PAS PDS PLLW SIZE1 DIEH DIEL); -- Cycle not yet terminated
                4'b1100     : NEXT_STATE <= s35;    //(BGACK SIZE1 DIEH DIEL INCFIFO);      -- 32 bit cycle terminated
                4'b1101     : NEXT_STATE <= s33;    //(BGACK PLLW SIZE1);                   -- 16 bit cycle terminated, so gotta bridge & such...
                default     : NEXT_STATE <= STATE;
            endcase
        end
        s33: NEXT_STATE <= s34;                     //goto s34(BGACK PLLW BRIDGEIN);
        s34: NEXT_STATE <= s35;                     //goto s35(BGACK BRIDGEIN INCFIFO);
        s35: NEXT_STATE <= FIFOFULL ? letgo : s23;  //if FIFOFULL then letgo(BGACK INCNI); -- no more room in FIFO else s23(BGACK PAS PDS PLHW PLLW DIEL DIEH INCNI); -- start another CPU cycle

        letgo: NEXT_STATE <= s0;                    //goto s0;

        default : NEXT_STATE <= STATE;
    endcase

end


//State Machine
always @(posedge CLK90 or negedge nRESET) begin
    if (~nRESET)
        STATE <= 5'b00000;
    else
        STATE <= NEXT_STATE;
end

endmodule