module sram_frambuffer_test_top(
    input crystalCLK,
    output [2:0] tmdsChannel_p,
    output tmdsClockChannel_p,
    output [2:0] tmdsChannel_n,
    output tmdsClockChannel_n
);
    wire [23:0] currentPixel; //{R8, G8, B8}
    wire signed [10:0] verticalPix;
    wire signed [11:0] horizontalPix;
    wire multiplierClkOut;
    wire inActiveDisplay;
	wire vsync;

    localparam FRAMEBUFFER_DEPTH = 180 * 120;
    reg[$clog2(FRAMEBUFFER_DEPTH) - 1 : 0] sramAddress;
    wire[5:0] sramRdData;

	//IP-generated SRAM block, use IP config file .ipc to change SRAM contents
	sp_framebuffer sramBuffer(
        .dout(sramRdData), //connected to a bit width converter and then to currentPixel, not registered
        .clk(crystalCLK), //input clk
        .ce(1'b1), //clock enable permanently active
        .reset(1'b0), //reset permanently disabled
        .wre(1'b0), //write enable permanently disabled (reading active low)
        .ad(sramAddress) //15-bit address input, data comes out on sramRdData on the next clock cycle after setting address
    );

    Gowin_PLLVR clock_5x(
        .clkout(multiplierClkOut), //output clkout
        .clkin(crystalCLK) //input clkin
    );
	
    hdmi_tx video_transmitter(
        .pixelClock(crystalCLK),
        .serialClock(multiplierClkOut),
        .inActiveDisplay(inActiveDisplay),
		.vSync(vsync),
        .redByte(currentPixel[23:16]),
        .greenByte(currentPixel[15:8]),
        .blueByte(currentPixel[7:0]),
        .hPosCounter(horizontalPix),
        .vPosCounter(verticalPix),
        .tmds_clk_p(tmdsClockChannel_p),
        .tmds_clk_n(tmdsClockChannel_n),
        .tmds_data_p(tmdsChannel_p),
        .tmds_data_n(tmdsChannel_n)
    );

    rgb6_to_rgb24 colorConverter(
        .i_rgb6Pixel(sramRdData), //RGB222
        .o_rgb24Pixel(currentPixel) //RGB888
    );

	//controls how many times a pixel is repeated horizontally and vertically respectively
    reg[1:0] horizontalCycleCount;
    reg[1:0] verticalCycleCount;

    always@(posedge crystalCLK) begin
        if (inActiveDisplay) begin
            horizontalCycleCount <= horizontalCycleCount + 1;
            if (horizontalCycleCount == 3) begin
                horizontalCycleCount <= 0;
				//finished repeating the pixel column 4 times, advance to next pixel
                sramAddress <= sramAddress + 1;
            end
            if (horizontalPix == (720 - 1)) begin
                verticalCycleCount <= verticalCycleCount + 1;
                if (verticalCycleCount == 3) begin
					//finished repeating the pixel row 4 times
                    verticalCycleCount <= 0;
                end else begin
					//not ready yet to move to next row, return to beginning of current row
                    sramAddress <= sramAddress - (180 - 1);
                end
            end
        end
		if (vsync) begin
			//Reset address back to the beginning of the frame
			sramAddress <= 0;
		end
    end
endmodule