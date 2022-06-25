`include "hdmi_tx.v"
`include "gowin_pllvr\gowin_pllvr.v"

module pattern_generator_top  (
                                input crystalCLK,
                                output tmdsChannel0_p,
                                output tmdsChannel1_p,
                                output tmdsChannel2_p,
                                output tmdsClockChannel_p
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
    wire[9:0] verticalPix;
    wire[8:0] horizontalPix;
    wire displayEnable;
    wire multiplierClkOut;

    Gowin_PLLVR clock_10x(
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
        .tmds_data_p({tmdsChannel2_p,
                      tmdsChannel1_p,
                      tmdsChannel0_p})
    );

    always@(posedge crystalCLK) begin
        if (displayEnable == 1) begin
            //PAL color bar pattern, kind of
            if (horizontalPix < 102)
                currentPixel <= WHITE;
            else if(horizontalPix < 102 * 2)
                currentPixel <= YELLOW;
            else if(horizontalPix < 102 * 3)
                currentPixel <= CYAN;
            else if(horizontalPix < 102 * 4)
                currentPixel <= GREEN;
            else if(horizontalPix < 102 * 5)
                currentPixel <= MAGENTA;
            else if(horizontalPix < 102 * 6)
                currentPixel <= RED;
            else
                currentPixel <= BLUE;
        end else begin
            currentPixel <= 24'b0;
        end
    end
endmodule