module gw_gao(
    crystalCLK,
    \sramAddress[14] ,
    \sramAddress[13] ,
    \sramAddress[12] ,
    \sramAddress[11] ,
    \sramAddress[10] ,
    \sramAddress[9] ,
    \sramAddress[8] ,
    \sramAddress[7] ,
    \sramAddress[6] ,
    \sramAddress[5] ,
    \sramAddress[4] ,
    \sramAddress[3] ,
    \sramAddress[2] ,
    \sramAddress[1] ,
    \sramAddress[0] ,
    \sramRdData[5] ,
    \sramRdData[4] ,
    \sramRdData[3] ,
    \sramRdData[2] ,
    \sramRdData[1] ,
    \sramRdData[0] ,
    \sramBuffer/ad[14] ,
    \sramBuffer/ad[13] ,
    \sramBuffer/ad[12] ,
    \sramBuffer/ad[11] ,
    \sramBuffer/ad[10] ,
    \sramBuffer/ad[9] ,
    \sramBuffer/ad[8] ,
    \sramBuffer/ad[7] ,
    \sramBuffer/ad[6] ,
    \sramBuffer/ad[5] ,
    \sramBuffer/ad[4] ,
    \sramBuffer/ad[3] ,
    \sramBuffer/ad[2] ,
    \sramBuffer/ad[1] ,
    \sramBuffer/ad[0] ,
    multiplierClkOut,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input crystalCLK;
input \sramAddress[14] ;
input \sramAddress[13] ;
input \sramAddress[12] ;
input \sramAddress[11] ;
input \sramAddress[10] ;
input \sramAddress[9] ;
input \sramAddress[8] ;
input \sramAddress[7] ;
input \sramAddress[6] ;
input \sramAddress[5] ;
input \sramAddress[4] ;
input \sramAddress[3] ;
input \sramAddress[2] ;
input \sramAddress[1] ;
input \sramAddress[0] ;
input \sramRdData[5] ;
input \sramRdData[4] ;
input \sramRdData[3] ;
input \sramRdData[2] ;
input \sramRdData[1] ;
input \sramRdData[0] ;
input \sramBuffer/ad[14] ;
input \sramBuffer/ad[13] ;
input \sramBuffer/ad[12] ;
input \sramBuffer/ad[11] ;
input \sramBuffer/ad[10] ;
input \sramBuffer/ad[9] ;
input \sramBuffer/ad[8] ;
input \sramBuffer/ad[7] ;
input \sramBuffer/ad[6] ;
input \sramBuffer/ad[5] ;
input \sramBuffer/ad[4] ;
input \sramBuffer/ad[3] ;
input \sramBuffer/ad[2] ;
input \sramBuffer/ad[1] ;
input \sramBuffer/ad[0] ;
input multiplierClkOut;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire crystalCLK;
wire \sramAddress[14] ;
wire \sramAddress[13] ;
wire \sramAddress[12] ;
wire \sramAddress[11] ;
wire \sramAddress[10] ;
wire \sramAddress[9] ;
wire \sramAddress[8] ;
wire \sramAddress[7] ;
wire \sramAddress[6] ;
wire \sramAddress[5] ;
wire \sramAddress[4] ;
wire \sramAddress[3] ;
wire \sramAddress[2] ;
wire \sramAddress[1] ;
wire \sramAddress[0] ;
wire \sramRdData[5] ;
wire \sramRdData[4] ;
wire \sramRdData[3] ;
wire \sramRdData[2] ;
wire \sramRdData[1] ;
wire \sramRdData[0] ;
wire \sramBuffer/ad[14] ;
wire \sramBuffer/ad[13] ;
wire \sramBuffer/ad[12] ;
wire \sramBuffer/ad[11] ;
wire \sramBuffer/ad[10] ;
wire \sramBuffer/ad[9] ;
wire \sramBuffer/ad[8] ;
wire \sramBuffer/ad[7] ;
wire \sramBuffer/ad[6] ;
wire \sramBuffer/ad[5] ;
wire \sramBuffer/ad[4] ;
wire \sramBuffer/ad[3] ;
wire \sramBuffer/ad[2] ;
wire \sramBuffer/ad[1] ;
wire \sramBuffer/ad[0] ;
wire multiplierClkOut;
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
    .trig0_i({\sramBuffer/ad[14] ,\sramBuffer/ad[13] ,\sramBuffer/ad[12] ,\sramBuffer/ad[11] ,\sramBuffer/ad[10] ,\sramBuffer/ad[9] ,\sramBuffer/ad[8] ,\sramBuffer/ad[7] ,\sramBuffer/ad[6] ,\sramBuffer/ad[5] ,\sramBuffer/ad[4] ,\sramBuffer/ad[3] ,\sramBuffer/ad[2] ,\sramBuffer/ad[1] ,\sramBuffer/ad[0] }),
    .data_i({crystalCLK,\sramAddress[14] ,\sramAddress[13] ,\sramAddress[12] ,\sramAddress[11] ,\sramAddress[10] ,\sramAddress[9] ,\sramAddress[8] ,\sramAddress[7] ,\sramAddress[6] ,\sramAddress[5] ,\sramAddress[4] ,\sramAddress[3] ,\sramAddress[2] ,\sramAddress[1] ,\sramAddress[0] ,\sramRdData[5] ,\sramRdData[4] ,\sramRdData[3] ,\sramRdData[2] ,\sramRdData[1] ,\sramRdData[0] }),
    .clk_i(multiplierClkOut)
);

endmodule
