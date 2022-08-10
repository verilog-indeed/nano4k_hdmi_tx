//`include "encoder_serializer.v"

//RGB888
//720x480@59.94Hz, 858x525 incl blanking, TODO make generalized parameters later?
//Timings defined by CEA-861, handy calculator: https://tomverbeure.github.io/video_timings_calculator

module hdmi_tx #(
//tweak parameters to get custom resolutions, get parameters from the calculator linked above
				horizontalResolution = 720,
				verticalResolution = 480,

				horizontalFrontPorch = 16,
				horizontalSyncPulse = 62,
				horizontalBackPorch = 60,

				verticalFrontPorch = 9,
				verticalSyncPulse = 6,
				verticalBackPorch = 30
				)(
                   input pixelClock, 
                   input serialClock, //5x pixel clock
                   output wire inActiveDisplay,
				   output wire hSync,
				   output wire vSync,

                   input [7:0] redByte,
                   input [7:0] greenByte,
                   input [7:0] blueByte,



				//one bit extra because of signed coordinates
                   output reg signed[$clog2(horizontalResolution):0] hPosCounter, //default is 11-bit wide 
                   output reg signed[$clog2(verticalResolution):0] vPosCounter, //default is 10-bit wide

                   output tmds_clk_p,
                   output tmds_clk_n,
//Three transition-minimized (8b10b) differential signaling data channels, 2x the serialClock (10x the pixelClock)
                   output [2:0] tmds_data_p,
                   output [2:0] tmds_data_n
              );
    // horizontal timings
    localparam signed H_START  = 0 - horizontalFrontPorch - horizontalSyncPulse - horizontalBackPorch; // horizontal start
    localparam signed HSYNC_START = H_START + horizontalFrontPorch;    // sync start
    localparam signed HSYNC_END = HSYNC_START + horizontalSyncPulse;  // sync end
    localparam signed HACTIVE_START = 0;                           // active start
    localparam signed HACTIVE_END = horizontalResolution - 1;      // active end

    // vertical timings
    localparam signed V_START  = 0 - verticalFrontPorch - verticalSyncPulse - verticalBackPorch; // vertical start
    localparam signed VSYNC_START = V_START + verticalFrontPorch;     // sync start
    localparam signed VSYNC_END = VSYNC_START + verticalSyncPulse;  // sync end
    localparam signed VACTIVE_START = 0;                           // active start
    localparam signed VACTIVE_END = verticalResolution - 1;      // active end


    assign inActiveDisplay = (hPosCounter >= HACTIVE_START && hPosCounter <= HACTIVE_END) 
						&& (vPosCounter >= VACTIVE_START && vPosCounter <= VACTIVE_END);
    

    assign hSync = (hPosCounter > HSYNC_START) && (hPosCounter <= HSYNC_END);    
    assign vSync = (vPosCounter > VSYNC_START) && (vPosCounter <= VSYNC_END);
    //assign hSync = (hPosCounter >= (720 + 16)) && (hPosCounter <= (858 - 60));
    //assign vSync = (vPosCounter >= (480 + 9)) && (vPosCounter <= (525 - 30));


    //Control bus "CTL" as defined in the DVI/HDMI spec {CTL3, CTL2, CTL1, CTL0}
    reg[3:0] CTL; 

    wire [2:0] tmds_buff;

    synchronous_encoder_serializer blue_tmds(
        .tmdsChannelNumber(2'd0),
        .pixelComponent(blueByte),
        .controlBus({vSync, hSync}),
        .DE(inActiveDisplay),
        .pixelClock(pixelClock),
        .encoderSerialClock(serialClock),
        .tmdsSerialOut(tmds_buff[0])
    );

    synchronous_encoder_serializer green_tmds(
        .tmdsChannelNumber(2'd1),
        .pixelComponent(greenByte),
        .controlBus(CTL[1:0]),
        .DE(inActiveDisplay),
        .pixelClock(pixelClock),
        .encoderSerialClock(serialClock),
        .tmdsSerialOut(tmds_buff[1])
    );

    synchronous_encoder_serializer red_tmds(
        .tmdsChannelNumber(2'd2),
        .pixelComponent(redByte),
        .controlBus(CTL[3:2]),
        .DE(inActiveDisplay),
        .pixelClock(pixelClock),
        .encoderSerialClock(serialClock),
        .tmdsSerialOut(tmds_buff[2])
    );

	//rederive pixel clock from serial clock by recreating the waveform
	//this helps resynchronize the tmds data stream and tmds clock channel
	wire pClock;
	OSER10 pclock_serializer(
        .Q(pClock),
        .D0(1'b1),
        .D1(1'b1),
        .D2(1'b1),
        .D3(1'b1),
        .D4(1'b1),
        .D5(1'b0),
        .D6(1'b0),
        .D7(1'b0),
        .D8(1'b0),
        .D9(1'b0),
        .PCLK(pixelClock),
        .FCLK(serialClock)
    );
    defparam pclock_serializer.GSREN = "false";
    defparam pclock_serializer.LSREN = "false";


    TLVDS_OBUF clockLVDS(
        .I(pClock),
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
        hPosCounter <= H_START;
        vPosCounter <= V_START;
    end
    
    always@(posedge pixelClock) begin
        if (hPosCounter == HACTIVE_END) begin
            hPosCounter <= H_START;
			if (vPosCounter == VACTIVE_END) begin
            	vPosCounter <= V_START;
			end else begin
				vPosCounter <= vPosCounter + 1;
			end
        end else begin
            hPosCounter <= hPosCounter + 1;
        end
    end
endmodule