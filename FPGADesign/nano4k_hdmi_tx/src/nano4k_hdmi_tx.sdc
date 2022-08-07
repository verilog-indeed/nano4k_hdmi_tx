//Copyright (C)2014-2022 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.8 Education
//Created Time: 2022-06-27 14:30:15
create_clock -name crystal_oscillator -period 37.037 -waveform {0 18.518} [get_ports {crystalCLK}]
create_generated_clock -name tmdsFreq -source [get_ports {crystalCLK}] -master_clock crystal_oscillator -multiply_by 10 [get_nets {video_transmitter/tmds_buff[0] video_transmitter/tmds_buff_0[1] video_transmitter/tmds_buff_1[2]}]
create_generated_clock -name pll_10xclock -source [get_ports {crystalCLK}] -master_clock crystal_oscillator -multiply_by 5 [get_pins {video_transmitter/blue_tmds/serializer/FCLK}]
