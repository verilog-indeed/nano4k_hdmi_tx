module gw_gao(
    \video_transmitter/blue_tmds/tmdsCharacterOut[9] ,
    \video_transmitter/blue_tmds/tmdsCharacterOut[8] ,
    \video_transmitter/blue_tmds/tmdsCharacterOut[7] ,
    \video_transmitter/blue_tmds/tmdsCharacterOut[6] ,
    \video_transmitter/blue_tmds/tmdsCharacterOut[5] ,
    \video_transmitter/blue_tmds/tmdsCharacterOut[4] ,
    \video_transmitter/blue_tmds/tmdsCharacterOut[3] ,
    \video_transmitter/blue_tmds/tmdsCharacterOut[2] ,
    \video_transmitter/blue_tmds/tmdsCharacterOut[1] ,
    \video_transmitter/blue_tmds/tmdsCharacterOut[0] ,
    \horizontalPix[9] ,
    \horizontalPix[8] ,
    \horizontalPix[7] ,
    \horizontalPix[6] ,
    \horizontalPix[5] ,
    \horizontalPix[4] ,
    \horizontalPix[3] ,
    \horizontalPix[2] ,
    \horizontalPix[1] ,
    \horizontalPix[0] ,
    crystalCLK,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input \video_transmitter/blue_tmds/tmdsCharacterOut[9] ;
input \video_transmitter/blue_tmds/tmdsCharacterOut[8] ;
input \video_transmitter/blue_tmds/tmdsCharacterOut[7] ;
input \video_transmitter/blue_tmds/tmdsCharacterOut[6] ;
input \video_transmitter/blue_tmds/tmdsCharacterOut[5] ;
input \video_transmitter/blue_tmds/tmdsCharacterOut[4] ;
input \video_transmitter/blue_tmds/tmdsCharacterOut[3] ;
input \video_transmitter/blue_tmds/tmdsCharacterOut[2] ;
input \video_transmitter/blue_tmds/tmdsCharacterOut[1] ;
input \video_transmitter/blue_tmds/tmdsCharacterOut[0] ;
input \horizontalPix[9] ;
input \horizontalPix[8] ;
input \horizontalPix[7] ;
input \horizontalPix[6] ;
input \horizontalPix[5] ;
input \horizontalPix[4] ;
input \horizontalPix[3] ;
input \horizontalPix[2] ;
input \horizontalPix[1] ;
input \horizontalPix[0] ;
input crystalCLK;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire \video_transmitter/blue_tmds/tmdsCharacterOut[9] ;
wire \video_transmitter/blue_tmds/tmdsCharacterOut[8] ;
wire \video_transmitter/blue_tmds/tmdsCharacterOut[7] ;
wire \video_transmitter/blue_tmds/tmdsCharacterOut[6] ;
wire \video_transmitter/blue_tmds/tmdsCharacterOut[5] ;
wire \video_transmitter/blue_tmds/tmdsCharacterOut[4] ;
wire \video_transmitter/blue_tmds/tmdsCharacterOut[3] ;
wire \video_transmitter/blue_tmds/tmdsCharacterOut[2] ;
wire \video_transmitter/blue_tmds/tmdsCharacterOut[1] ;
wire \video_transmitter/blue_tmds/tmdsCharacterOut[0] ;
wire \horizontalPix[9] ;
wire \horizontalPix[8] ;
wire \horizontalPix[7] ;
wire \horizontalPix[6] ;
wire \horizontalPix[5] ;
wire \horizontalPix[4] ;
wire \horizontalPix[3] ;
wire \horizontalPix[2] ;
wire \horizontalPix[1] ;
wire \horizontalPix[0] ;
wire crystalCLK;
wire tms_pad_i;
wire tck_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire tms_i_c;
wire tck_i_c;
wire tdi_i_c;
wire tdo_o_c;
wire [9:0] control0;
wire gao_jtag_tck;
wire gao_jtag_reset;
wire run_test_idle_er1;
wire run_test_idle_er2;
wire shift_dr_capture_dr;
wire update_dr;
wire pause_dr;
wire enable_er1;
wire enable_er2;
wire gao_jtag_tdi;
wire tdo_er1;

IBUF tms_ibuf (
    .I(tms_pad_i),
    .O(tms_i_c)
);

IBUF tck_ibuf (
    .I(tck_pad_i),
    .O(tck_i_c)
);

IBUF tdi_ibuf (
    .I(tdi_pad_i),
    .O(tdi_i_c)
);

OBUF tdo_obuf (
    .I(tdo_o_c),
    .O(tdo_pad_o)
);

GW_JTAG  u_gw_jtag(
    .tms_pad_i(tms_i_c),
    .tck_pad_i(tck_i_c),
    .tdi_pad_i(tdi_i_c),
    .tdo_pad_o(tdo_o_c),
    .tck_o(gao_jtag_tck),
    .test_logic_reset_o(gao_jtag_reset),
    .run_test_idle_er1_o(run_test_idle_er1),
    .run_test_idle_er2_o(run_test_idle_er2),
    .shift_dr_capture_dr_o(shift_dr_capture_dr),
    .update_dr_o(update_dr),
    .pause_dr_o(pause_dr),
    .enable_er1_o(enable_er1),
    .enable_er2_o(enable_er2),
    .tdi_o(gao_jtag_tdi),
    .tdo_er1_i(tdo_er1),
    .tdo_er2_i(1'b0)
);

gw_con_top  u_icon_top(
    .tck_i(gao_jtag_tck),
    .tdi_i(gao_jtag_tdi),
    .tdo_o(tdo_er1),
    .rst_i(gao_jtag_reset),
    .control0(control0[9:0]),
    .enable_i(enable_er1),
    .shift_dr_capture_dr_i(shift_dr_capture_dr),
    .update_dr_i(update_dr)
);

ao_top_0  u_la0_top(
    .control(control0[9:0]),
    .trig0_i({\horizontalPix[9] ,\horizontalPix[8] ,\horizontalPix[7] ,\horizontalPix[6] ,\horizontalPix[5] ,\horizontalPix[4] ,\horizontalPix[3] ,\horizontalPix[2] ,\horizontalPix[1] ,\horizontalPix[0] }),
    .data_i({\video_transmitter/blue_tmds/tmdsCharacterOut[9] ,\video_transmitter/blue_tmds/tmdsCharacterOut[8] ,\video_transmitter/blue_tmds/tmdsCharacterOut[7] ,\video_transmitter/blue_tmds/tmdsCharacterOut[6] ,\video_transmitter/blue_tmds/tmdsCharacterOut[5] ,\video_transmitter/blue_tmds/tmdsCharacterOut[4] ,\video_transmitter/blue_tmds/tmdsCharacterOut[3] ,\video_transmitter/blue_tmds/tmdsCharacterOut[2] ,\video_transmitter/blue_tmds/tmdsCharacterOut[1] ,\video_transmitter/blue_tmds/tmdsCharacterOut[0] ,\horizontalPix[9] ,\horizontalPix[8] ,\horizontalPix[7] ,\horizontalPix[6] ,\horizontalPix[5] ,\horizontalPix[4] ,\horizontalPix[3] ,\horizontalPix[2] ,\horizontalPix[1] ,\horizontalPix[0] }),
    .clk_i(crystalCLK)
);

endmodule
