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
		movingRight <= 1;
		movingDown <= 1;
    end
	
	//top left corner coordinates
	reg signed [10:0] boxHpos;
	reg signed [10:0] boxVpos;

	localparam boxHeight = 90;
	localparam boxWidth = 120;
	
	wire signed [10:0] rightEdgeCoord = boxHpos + boxWidth;
	wire signed [10:0] bottomEdgeCoord = boxVpos + boxHeight;

	reg movingRight;
	reg movingDown;
	always@(posedge crystalCLK) begin
		if ((verticalPix > boxVpos) && (verticalPix < (bottomEdgeCoord)) && (horizontalPix > boxHpos) && (horizontalPix < (rightEdgeCoord))) begin
			currentPixel <= INDIGO;
		end else begin
			currentPixel <= CYAN;
		end
		if (verticalPix == (480-1) && horizontalPix == (720-1)) begin
			if (movingRight) begin
				if (rightEdgeCoord >= 720) begin
					boxHpos <= 720 - boxWidth - 1;
					movingRight <= 0;
				end else begin
					boxHpos <= boxHpos + 1;
				end
			end else begin
				if (boxHpos <= 0) begin
					boxHpos <= 1;
					movingRight <= 1;
				end else begin
					boxHpos <= boxHpos - 1;
				end
			end

			if (movingDown) begin
				if (bottomEdgeCoord >= 480) begin
					boxVpos <= 480 - boxHeight - 1;
					movingDown <= 0;
				end else begin
					boxVpos <= boxVpos + 1;
				end
			end else begin
				if (boxVpos <= 0) begin
					boxVpos <= 1;
					movingDown <= 1;
				end else begin
					boxVpos <= boxVpos - 1;
				end
			end
		end
	end

endmodule