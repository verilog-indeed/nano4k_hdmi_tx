module rgb8_to_rgb24(
    input wire[7:0] i_rgb8Pixel, //RGB332
    output wire[23:0] o_rgb24Pixel //RGB888
);
    b3_to_b8 redConverter(
        .i_b3(i_rgb8Pixel[7:5]),
        .o_b8(o_rgb24Pixel[23:16])
    );

    b3_to_b8 greenConverter(
        .i_b3(i_rgb8Pixel[4:2]),
        .o_b8(o_rgb24Pixel[15:8])
    );

    b2_to_b8 blueConverter(
        .i_b2(i_rgb8Pixel[1:0]),
        .o_b8(o_rgb24Pixel[7:0])
    );

endmodule

module rgb6_to_rgb24(
    input wire[5:0] i_rgb6Pixel, //RGB222
    output wire[23:0] o_rgb24Pixel //RGB24
);

    b2_to_b8 redConverter(
        .i_b2(i_rgb6Pixel[5:4]),
        .o_b8(o_rgb24Pixel[23:16])
    );

    b2_to_b8 greenConverter(
        .i_b2(i_rgb6Pixel[3:2]),
        .o_b8(o_rgb24Pixel[15:8])
    );
    
    b2_to_b8 blueConverter(
        .i_b2(i_rgb6Pixel[1:0]),
        .o_b8(o_rgb24Pixel[7:0])
    );
endmodule

module b3_to_b8(
    input wire[2:0] i_b3,
    output reg[7:0] o_b8
);
    always@(*) begin
        case (i_b3)
            3'b000: o_b8 = 8'd0;
            3'b001: o_b8 = 8'd36;
            3'b010: o_b8 = 8'd73;
            3'b011: o_b8 = 8'd109;
            3'b100: o_b8 = 8'd146;
            3'b101: o_b8 = 8'd182;
            3'b110: o_b8 = 8'd219;
            3'b111: o_b8 = 8'd255;    
        endcase
    end
endmodule

module b2_to_b8(
    input wire[1:0] i_b2,
    output reg[7:0] o_b8
);
    always@(*) begin
        case(i_b2) 
            2'b00: o_b8 = 8'd0;
            2'b01: o_b8 = 8'd85;
            2'b10: o_b8 = 8'd170;
            2'b11: o_b8 = 8'd255;
        endcase
    end
endmodule
