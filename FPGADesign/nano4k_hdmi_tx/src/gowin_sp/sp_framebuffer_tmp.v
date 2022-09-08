//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: V1.9.8.05
//Part Number: GW1NSR-LV4CQN48PC6/I5
//Device: GW1NSR-4C
//Created Time: Thu Sep 08 01:24:38 2022

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    sp_framebuffer your_instance_name(
        .dout(dout_o), //output [5:0] dout
        .clk(clk_i), //input clk
        .oce(oce_i), //input oce
        .ce(ce_i), //input ce
        .reset(reset_i), //input reset
        .wre(wre_i), //input wre
        .ad(ad_i), //input [14:0] ad
        .din(din_i) //input [5:0] din
    );

//--------Copy end-------------------
