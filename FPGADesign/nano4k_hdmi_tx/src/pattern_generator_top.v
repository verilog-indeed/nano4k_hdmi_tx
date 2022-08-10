//`include "hdmi_tx.v"
//`include "gowin_pllvr\gowin_pllvr.v"

module pattern_generator_top  (
                                input crystalCLK,
                                output [2:0] tmdsChannel_p,
                                output tmdsClockChannel_p,
                                output [2:0] tmdsChannel_n,
                                output tmdsClockChannel_n
                              );

    localparam	WHITE	= {8'd255 , 8'd255 , 8'd255 };//{R,G,B}
    localparam	YELLOW	= { 8'd255 , 8'd255, 8'd0   };
    localparam	CYAN	= { 8'd0, 8'd255 , 8'd255   };
    localparam	GREEN	= {8'd0   , 8'd255 , 8'd0   };
    localparam	MAGENTA	= {8'd255 , 8'd0   , 8'd255 };
    localparam	RED		= {8'd255, 8'd0   , 8'd0    };
    localparam	BLUE	= { 8'd0   , 8'd0  , 8'd255};
    localparam	BLACK	= {8'd0   , 8'd0   , 8'd0   };

    reg[23:0] currentPixel; //{R8, G8, B8}
    wire signed [10:0] verticalPix;
    wire signed [11:0] horizontalPix;
    wire displayEnable;
    wire multiplierClkOut;
	
    Gowin_PLLVR clock_5x(
        .clkout(multiplierClkOut), //output clkout
        .clkin(crystalCLK) //input clkin
    );
	
    hdmi_tx video_transmitter(
        .pixelClock(crystalCLK),
        .serialClock(multiplierClkOut),
        .redByte(currentPixel[23:16]),
        .greenByte(currentPixel[15:8]),
        .blueByte(currentPixel[7:0]),
        .inActiveDisplay(displayEnable),
        .hPosCounter(horizontalPix),
        .vPosCounter(verticalPix),
        .tmds_clk_p(tmdsClockChannel_p),
        .tmds_clk_n(tmdsClockChannel_n),
        .tmds_data_p(tmdsChannel_p),
        .tmds_data_n(tmdsChannel_n)
    );

    initial begin
        currentPixel <= BLACK;
    end

	always@(*) begin
		if (displayEnable) begin
			//PAL color bar pattern, kind of
			if (horizontalPix < 102 * 4) begin
				if (horizontalPix < 102 * 2) begin
					if (horizontalPix < 102) begin
						currentPixel = WHITE;
					end else begin
						currentPixel = YELLOW;
					end
				end else if(horizontalPix < 102 * 3) begin
					currentPixel = CYAN;
				end else begin
					currentPixel = GREEN;
				end
			end else begin
				if (horizontalPix < 102 * 6) begin
					if (horizontalPix < 102 * 5) begin
						currentPixel = MAGENTA;
					end else begin
						currentPixel = RED;
					end
				end else begin
					currentPixel = BLUE;
				end
			end
		end else begin
			currentPixel <= BLACK;
		end
	end
endmodule