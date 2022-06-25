`include "encoder_serializer.v"

//RGB888, LPCM at 16-bits?
//720x480@60Hz, 858x525 incl blanking, TODO make generalized parameters later?
//Timings defined by CEA-861, handy calculator: https://tomverbeure.github.io/video_timings_calculator

module hdmi_tx(
                   input pixelClock, //crystal oscillator
                   input serialClock, //10x pixel clock
                   input [7:0] redByte,
                   input [7:0] greenByte,
                   input [7:0] blueByte,
                   input [15:0] pcmSample, //TODO format to be determined??
                   output inActiveDisplay,
                   output reg[9:0] hPosCounter,
                   output reg[9:0] vPosCounter,
                   output tmds_clk_p,
//Three transition-minimized (8b10b) differential signaling data channels
                   output [2:0] tmds_data_p 
              );

    /*reg[9:0] hPosCounter;
    reg[9:0] vPosCounter;*/
    wire inActiveDisplay = (hPosCounter < 720) && (vPosCounter < 480);
    
    //horizontal front porch lasts 16 pixel cycles after active display row is finished,
    //horizontal back porch lasts 60 cycles after hSync pulse, 
    //it is also the last 60 cycles before hPosCounter is reset
    wire hSync = (hPosCounter >= (720 + 16)) && (hPosCounter <= (858 - 60));
    
    //vertical front porch lasts 9 line cycles (line freq = pixelClock / 858)
    //vertical back porch lasts 30 line cycles
    wire vSync = (vPosCounter >= (480 + 9)) && (vPosCounter <= (525 - 30));

    //Control bus "CTL" as defined in the DVI/HDMI spec {CTL3, CTL2, CTL1, CTL0}
    reg[3:0] CTL; 

    encoder_serializer blue_tmds(
        .tmdsChannelNumber(2'd0),
        .pixelComponent(blueByte),
        .controlBus({vSync, hSync}),
        .DE(inActiveDisplay),
        .encoderSerialClock(serialClock),
        .tmdsSerialOut(tmds_data_p[0])
    );

    encoder_serializer green_tmds(
        .tmdsChannelNumber(2'd1),
        .pixelComponent(greenByte),
        .controlBus(CTL[1:0]),
        .DE(inActiveDisplay),
        .encoderSerialClock(serialClock),
        .tmdsSerialOut(tmds_data_p[1])
    );

    encoder_serializer red_tmds(
        .tmdsChannelNumber(2'd2),
        .pixelComponent(redByte),
        .controlBus(CTL[3:2]),
        .DE(inActiveDisplay),
        .encoderSerialClock(serialClock),
        .tmdsSerialOut(tmds_data_p[2])
    );

    assign tmds_clk_p = pixelClock;

    always@(posedge pixelClock) begin
        if (hPosCounter == 858) begin
            hPosCounter <= 0;
            if (vPosCounter == 525) begin
                vPosCounter <= 0;
            end else begin
                vPosCounter <= vPosCounter + 1;
            end
        end else begin
            hPosCounter <= hPosCounter + 1;
        end
    end
endmodule