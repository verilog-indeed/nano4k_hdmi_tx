//`include "num_of_ones.v"

module encoder_serializer(
                //unique identifier for each channel, determines value of island guardbands (HDMI)
                          input wire[1:0] tmdsChannelNumber,
                //D[7:0] in the DVI standard
                          input wire[7:0] pixelComponent, 
                //{C1,C0} in the DVI standard, can either be VSYNC,HSYNC or bits from the CTL[3:0] preamble signal
                          input wire[1:0] controlBus,
                //Display Enable (1 for active display period, 0 for blanking period)
                          input wire DE,
                          input pixelClock,
                //TMDS serialization clock, must be 5x the pixel clock
                          input wire encoderSerialClock,
                //Serial 10-bit TMDS encoded, DC balanced output
                          output tmdsSerialOut
						  );

    reg[9:0] tmdsCharacterBuff;
    reg[9:0] tmdsCharacterOut;
    reg[4:0] disparityCounter;
    
    wire[3:0] onesInPixelComponent;
    num_of_ones ones_in_pixel(
        .onesFrom(pixelComponent),
        .result(onesInPixelComponent)
    );

    wire[3:0] onesInTmdsBuffer;
    num_of_ones ones_in_tmds_buffer(
        .onesFrom(tmdsCharacterBuff[7:0]),
        .result(onesInTmdsBuffer)
    );

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
        tmdsCharacterOut_xfer_pipe <= 0;
        tmdsCharacterOut <= 0;
        tmdsCharacterBuff <= 0;
        disparityCounter <= 0;
        //serialCycleCount <=0;
    end

    integer tmdsBitIndex;
    always@(*) begin
        if (DE == 1) begin //Video island period
            //1-Transition minimization
            tmdsCharacterBuff[0] = pixelComponent[0]; 
            //k-th bit of the TMDS character is the (k-1) TMDS bit XOR'ed/XNOR'ed with the k-th bit of the pixel byte
            if (onesInPixelComponent > 4 || (onesInPixelComponent == 4 && pixelComponent[0] == 0)) begin
                //XNOR will result in less transitions
                for (tmdsBitIndex = 1; tmdsBitIndex <= 7; tmdsBitIndex = tmdsBitIndex + 1)
                begin
                    tmdsCharacterBuff[tmdsBitIndex] = pixelComponent[tmdsBitIndex] ^~ tmdsCharacterBuff[tmdsBitIndex - 1];
                end
                //~XNOR bit flag set
                tmdsCharacterBuff[8] = 0; 
            end else begin
                //XOR will result in less transitions
                for (tmdsBitIndex = 1; tmdsBitIndex <= 7; tmdsBitIndex = tmdsBitIndex + 1)
                begin
                    tmdsCharacterBuff[tmdsBitIndex] = pixelComponent[tmdsBitIndex] ^ tmdsCharacterBuff[tmdsBitIndex - 1];
                end
                //XOR bit flag set
                tmdsCharacterBuff[8] = 1; 
            end

            //2-DC balacning
            if (disparityCounter == 0 || (onesInTmdsBuffer == 4)) begin
                //No previous DC bias recorded or encoded pixel data already balanced,
                // keep balance by canceling out the XOR/XNOR operation flag.
                tmdsCharacterBuff[9] = ~tmdsCharacterBuff[8]; 
                if (tmdsCharacterBuff[8] == 0) begin
                    tmdsCharacterBuff[7:0] = ~tmdsCharacterBuff[7:0];
                    disparityCounter = disparityCounter - onesInTmdsBuffer_2x_minus_8;
                end else begin
                    disparityCounter = disparityCounter + onesInTmdsBuffer_2x_minus_8;
                end
            end else begin
                //Previous DC bias exists and current data isn't balacned
                if (($signed(disparityCounter) > 0 && ((onesInTmdsBuffer_2x) > 5'd8)) ||
                    ($signed(disparityCounter) < 0 && ((onesInTmdsBuffer_2x) < 5'd8))) begin
                    //If we have positive DC bias AND We are still sending more ones than zeroes
                    //OR if we have negative DC bias AND we are still sending more zeroes (negatives) than ones
                    tmdsCharacterBuff[9] = 1;
                    tmdsCharacterBuff[7:0] = ~tmdsCharacterBuff[7:0];
                    disparityCounter = disparityCounter - disparityCounterCompensation;
                end else begin
                    tmdsCharacterBuff[9] = 0;
                    disparityCounter = disparityCounter + disparityCounterCompensation;
                end
            end
        end else begin //Control island period
            disparityCounter[7:0] = 0;
            case(controlBus)
                2'b00: tmdsCharacterBuff[9:0] = 10'b1101010100;
                2'b01: tmdsCharacterBuff[9:0] = 10'b0010101011;
                2'b10: tmdsCharacterBuff[9:0] = 10'b0101010100;
                2'b11: tmdsCharacterBuff[9:0] = 10'b1010101011;
            endcase;
        end
    end
	
	wire[4:0] onesInTmdsBuffer_2x = onesInTmdsBuffer << 1;
	wire[4:0] onesInTmdsBuffer_2x_minus_8 = onesInTmdsBuffer_2x - 5'd8;
	wire[4:0] tmdsCharacterBuff_bit_8_2x = tmdsCharacterBuff[8] << 1;
	wire[4:0] disparityCounterCompensation = onesInTmdsBuffer_2x_minus_8 - tmdsCharacterBuff_bit_8_2x;

    reg[9:0] tmdsCharacterOut_xfer_pipe;
    always@(posedge pixelClock) begin
        tmdsCharacterOut_xfer_pipe <= tmdsCharacterBuff;
        tmdsCharacterOut <= tmdsCharacterOut_xfer_pipe;
    end
/*
    reg[3:0] serialCycleCount;
    
    always@(posedge encoderSerialClock) begin
		//Shift the next TMDS character bit into the serial output
        {tmdsCharacterOut, tmdsSerialOut} <= {tmdsCharacterOut, tmdsSerialOut} >> 1;
        if (serialCycleCount == 9) begin
			//10-bit transfer finish, load new TMDS character
            serialCycleCount <= 0;
			tmdsCharacterOut <= tmdsCharacterBuff;
        end else begin
            serialCycleCount <= serialCycleCount + 1;
        end
    end
*/
endmodule