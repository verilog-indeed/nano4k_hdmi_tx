//`include "encoder_serializer.v"

//RGB888, LPCM at 16-bits?
//720x480@60Hz, 858x525 incl blanking, TODO make generalized parameters later?
//Timings defined by CEA-861, handy calculator: https://tomverbeure.github.io/video_timings_calculator

module hdmi_tx(
                   input pixelClock, //crystal oscillator
                   input serialClock, //5x pixel clock
                   input [7:0] redByte,
                   input [7:0] greenByte,
                   input [7:0] blueByte,
                   input [15:0] pcmSample, //TODO format to be determined??
                   output wire inActiveDisplay,
                   output reg[9:0] hPosCounter,
                   output reg[9:0] vPosCounter,
                   output tmds_clk_p,
                   output tmds_clk_n,
//Three transition-minimized (8b10b) differential signaling data channels, 2x the serialClock
                   output [2:0] tmds_data_p,
                   output [2:0] tmds_data_n
              );

    /*reg[9:0] hPosCounter;
    reg[9:0] vPosCounter;*/
    assign inActiveDisplay = (hPosCounter < 720) && (vPosCounter < 480);
    
    //horizontal front porch lasts 16 pixel cycles after active display row is finished,
    //horizontal back porch lasts 60 cycles after hSync pulse, 
    //it is also the last 60 cycles before hPosCounter is reset
    wire hSync = (hPosCounter >= (720 + 16)) && (hPosCounter <= (858 - 60));
    
    //vertical front porch lasts 9 line cycles (line freq = pixelClock / 858)
    //vertical back porch lasts 30 line cycles
    wire vSync = (vPosCounter >= (480 + 9)) && (vPosCounter <= (525 - 30));

    //Control bus "CTL" as defined in the DVI/HDMI spec {CTL3, CTL2, CTL1, CTL0}
    reg[3:0] CTL; 

    wire [2:0] tmds_buff;

    encoder_serializer blue_tmds(
        .tmdsChannelNumber(2'd0),
        .pixelComponent(blueByte),
        .controlBus({vSync, hSync}),
        .DE(inActiveDisplay),
        .pixelClock(pixelClock),
        .encoderSerialClock(serialClock),
        .tmdsSerialOut(tmds_buff[0])
    );

    encoder_serializer green_tmds(
        .tmdsChannelNumber(2'd1),
        .pixelComponent(greenByte),
        .controlBus(CTL[1:0]),
        .DE(inActiveDisplay),
        .pixelClock(pixelClock),
        .encoderSerialClock(serialClock),
        .tmdsSerialOut(tmds_buff[1])
    );

    encoder_serializer red_tmds(
        .tmdsChannelNumber(2'd2),
        .pixelComponent(redByte),
        .controlBus(CTL[3:2]),
        .DE(inActiveDisplay),
        .pixelClock(pixelClock),
        .encoderSerialClock(serialClock),
        .tmdsSerialOut(tmds_buff[2])
    );
/*
	wire pClock;
	OSER10 pclock_serializer(
        .Q(pClock),
        .D0(1),
        .D1(1),
        .D2(1),
        .D3(1),
        .D4(1),
        .D5(0),
        .D6(0),
        .D7(0),
        .D8(0),
        .D9(0),
        .PCLK(pixelClock),
        .FCLK(serialClock)
    );
    defparam pclock_serializer.GSREN = "false";
    defparam pclock_serializer.LSREN = "false";
*/
    TLVDS_OBUF clockLVDS(
        .I(pixelClock),
		//.I(serialClock),
        .O(tmds_clk_p),
        .OB(tmds_clk_n)
    );
    
    genvar channelNum;
    generate
        for(channelNum = 0; channelNum <= 2; channelNum = channelNum + 1) 
        begin: tlvds_buffer_gen
            TLVDS_OBUF tlvds_inst (
                .I(tmds_buff[channelNum]),
                .O(tmds_data_p[channelNum]),
                .OB(tmds_data_n[channelNum])
            );
        end
    endgenerate
 
    initial begin
        CTL <= 4'b0;
        hPosCounter <= 0;
        vPosCounter <= 0;
    end
    
    wire vPixelClk = hPosCounter < 430;
    
    always@(posedge vPixelClk) begin
        if (vPosCounter == 525) begin
            vPosCounter <= 0;
        end else begin
            vPosCounter <= vPosCounter + 1;
        end
    end

    always@(posedge pixelClock) begin
        if (hPosCounter == 858) begin
        //if (vPixelClk == 1) begin
            hPosCounter <= 0;
            /*if (vPosCounter == 525) begin
                vPosCounter <= 0;
            end else begin
                vPosCounter <= vPosCounter + 1;
            end*/
        end else begin
            hPosCounter <= hPosCounter + 1;
        end
    end
endmodule