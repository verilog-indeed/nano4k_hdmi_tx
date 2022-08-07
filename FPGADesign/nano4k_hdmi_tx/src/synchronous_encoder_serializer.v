module synchronous_encoder_serializer(
                //unique identifier for each channel, determines value of island guardbands (HDMI)
                          input wire[1:0] tmdsChannelNumber,
                //D[7:0] in the DVI standard
                          input wire[7:0] pixelComponent, 
                //{C1,C0} in the DVI standard, can either be VSYNC,HSYNC or bits from the CTL[3:0] preamble signal
                          input wire[1:0] controlBus,
                //Display Enable (1 for active display period, 0 for blanking period)
                //TODO: should be raised one pixelClock cycle BEFORE data starts?
                          input wire DE,
                          input pixelClock,
                //TMDS serialization clock, must be 5x the pixel clock
                          input wire encoderSerialClock,
                //Serial 10-bit TMDS encoded, DC balanced output
                          output tmdsSerialOut
						  );

    reg[7:0] currentSubPixel;
	reg[9:0] tmdsCharacterOut;
    reg[8:0] encoderStage1;
    wire[3:0] onesIn_currentSubPixel;

    num_of_ones ones_in_pixel(
        .onesFrom(currentSubPixel),
        .result(onesIn_currentSubPixel)
    );

    wire[3:0] onesIn_encoderStage1;
    num_of_ones ones_in_tmds_stage1(
        .onesFrom(encoderStage1[7:0]),
        .result(onesIn_encoderStage1)
    );

    wire[4:0] onesInTmdsBuffer_2x = onesIn_encoderStage1 << 1;
	wire[4:0] onesInTmdsBuffer_2x_minus_8 = onesInTmdsBuffer_2x - 5'd8;
	wire[4:0] tmdsCharacterBuff_bit_8_2x = encoderStage1[8] << 1;
	wire[4:0] disparityCounterCompensation = onesInTmdsBuffer_2x_minus_8 - tmdsCharacterBuff_bit_8_2x;

	reg displayEnable;
	reg displayEnable_xfer;

    reg[4:0] disparityCounter;
    reg stage1Ready;
    integer tmdsBitIndex;
    reg stage2Ready;
    reg[9:0] encoderStage2;
	reg[2:0] idleCounter;
    always@(posedge encoderSerialClock) begin
        if (displayEnable == 1) begin
			if (stage1Ready == 0) begin //Video island period
				//1-Transition minimization
				encoderStage1[0] = currentSubPixel[0]; 
				//k-th bit of the TMDS character is the (k-1) TMDS bit XOR'ed/XNOR'ed with the k-th bit of the pixel byte
				if (onesIn_currentSubPixel > 4 || (onesIn_currentSubPixel == 4 && currentSubPixel[0] == 0)) begin
					//XNOR will result in less transitions
					for (tmdsBitIndex = 1; tmdsBitIndex <= 7; tmdsBitIndex = tmdsBitIndex + 1)
					begin
						//blocking assignment to prevent flopping and having this block take multiple clock cycles to correct itself
						encoderStage1[tmdsBitIndex] = currentSubPixel[tmdsBitIndex] ^~ encoderStage1[tmdsBitIndex - 1];
					end
					//~XNOR bit flag set
					encoderStage1[8] = 0; 
				end else begin
					//XOR will result in less transitions
					for (tmdsBitIndex = 1; tmdsBitIndex <= 7; tmdsBitIndex = tmdsBitIndex + 1)
					begin
						encoderStage1[tmdsBitIndex] = currentSubPixel[tmdsBitIndex] ^ encoderStage1[tmdsBitIndex - 1];
					end
					//XOR bit flag set
					encoderStage1[8] = 1; 
				end
				stage1Ready <= 1;
			end else if (stage2Ready == 0) begin
				encoderStage2[8:0] <= encoderStage1;
				
				if (disparityCounter == 0 || (onesIn_encoderStage1 == 4)) begin
					//No previous DC bias recorded or encoded pixel data already balanced,
					// keep balance by canceling out the XOR/XNOR operation flag.
					encoderStage2[9] <= ~encoderStage1[8]; 
					if (encoderStage1[8] == 0) begin
						encoderStage2[7:0] <= ~encoderStage1[7:0];
						disparityCounter <= disparityCounter - onesInTmdsBuffer_2x_minus_8;
					end else begin
						disparityCounter <= disparityCounter + onesInTmdsBuffer_2x_minus_8;
					end
				end else begin
					//Previous DC bias exists and current data isn't balacned
					if (($signed(disparityCounter) > 0 && ((onesInTmdsBuffer_2x) > 5'd8)) ||
						($signed(disparityCounter) < 0 && ((onesInTmdsBuffer_2x) < 5'd8))) begin
						//If we have positive DC bias AND We are still sending more ones than zeroes
						//OR if we have negative DC bias AND we are still sending more zeroes (negatives) than ones
						encoderStage2[9] <= 1;
						encoderStage2[7:0] <= ~encoderStage1[7:0];
						disparityCounter <= disparityCounter - disparityCounterCompensation;
					end else begin
						encoderStage2[9] <= 0;
						disparityCounter <= disparityCounter + disparityCounterCompensation;
					end
				end
				
				/*
				//slightly faster butchering of DC balancing, for testing
				encoderStage2[8:0] <= encoderStage1;
				//No previous DC bias recorded or encoded pixel data already balanced,
				// keep balance by canceling out the XOR/XNOR operation flag.
				encoderStage2[9] <= ~encoderStage1[8]; 
				if (encoderStage1[8] == 0) begin
					encoderStage2[7:0] <= ~encoderStage1[7:0];
					disparityCounter <= disparityCounter - onesInTmdsBuffer_2x_minus_8;
				end else begin
					disparityCounter <= disparityCounter + onesInTmdsBuffer_2x_minus_8;
				end
				*/
				stage2Ready <= 1;
			end else begin
				idleCounter <= idleCounter + 1;
				if (idleCounter == 3) begin
					stage1Ready <= 0;
					stage2Ready <= 0;
					idleCounter <= 0;
				end
			end
        end else begin
			//Control period
            disparityCounter[4:0] <= 0;
            case(controlBus)
                2'b00: encoderStage2[9:0] <= 10'b1101010100;
                2'b01: encoderStage2[9:0] <= 10'b0010101011;
                2'b10: encoderStage2[9:0] <= 10'b0101010100;
                2'b11: encoderStage2[9:0] <= 10'b1010101011;
            endcase;
        end
    end

	always@(posedge pixelClock) begin
		currentSubPixel <= pixelComponent;

		//delay display activation by 2-cycles to account for the 2-cycle initial delay of the serializer block
		{displayEnable, displayEnable_xfer} <= {displayEnable_xfer, DE};

		tmdsCharacterOut <= encoderStage2;
	end

    OSER10 serializer(
        .Q(tmdsSerialOut),
        .D0(tmdsCharacterOut[0]),
        .D1(tmdsCharacterOut[1]),
        .D2(tmdsCharacterOut[2]),
        .D3(tmdsCharacterOut[3]),
        .D4(tmdsCharacterOut[4]),
        .D5(tmdsCharacterOut[5]),
        .D6(tmdsCharacterOut[6]),
        .D7(tmdsCharacterOut[7]),
        .D8(tmdsCharacterOut[8]),
        .D9(tmdsCharacterOut[9]),
        .PCLK(pixelClock),
        .FCLK(encoderSerialClock)
    );
    defparam serializer.GSREN = "false";
    defparam serializer.LSREN = "false";

    initial begin
		displayEnable <= 0;
		displayEnable_xfer <= 0;
		idleCounter <= 0;
		currentSubPixel <= 0;
        tmdsCharacterOut <= 0;
        encoderStage1 <= 0;
        encoderStage2 <= 0;
		stage1Ready <= 0;
		stage2Ready <= 0;
        disparityCounter <= 0;
    end	
endmodule