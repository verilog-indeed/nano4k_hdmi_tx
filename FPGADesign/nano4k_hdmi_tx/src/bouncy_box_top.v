module bouncy_box_top(
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

	localparam INDIGO = {8'd75   , 8'd0   , 8'd130   };

    reg[23:0] currentPixel; //{R8, G8, B8}
    wire[9:0] verticalPix;
    wire[9:0] horizontalPix;
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
        .pcmSample(16'b0),
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
		boxHpos <= 240;
		boxVpos <= 160;
    end
	
	//top left corner coordinates
	reg[9:0] boxHpos;
	reg[9:0] boxVpos;

	localparam boxHeight = 160;
	localparam boxWidth = 240;

	always@(posedge crystalCLK) begin
		if ((verticalPix > boxVpos) && (verticalPix < (boxVpos + boxHeight)) && (horizontalPix > boxHpos) && (horizontalPix < (boxHpos + boxHeight))) begin
			currentPixel <= INDIGO;
		end else begin
			currentPixel <= CYAN;
		end
		if (verticalPix == 480 && horizontalPix == 720) begin
			boxHpos <= boxHpos + 1;
		end
	end

endmodule