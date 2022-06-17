//RGB888, LPCM at 16-bits?

module hdmi_tx_top(input clk, //crystal oscillator
                   input [7:0] redByte,
                   input [7:0] greenByte,
                   input [7:0] blueByte,
                   input [15:0] pcmSample, //TODO format to be determined??

                   output tmds_clk_p,
                   output tmds_clk_n,
//Three transisiton-minimized (8b10b) differential signaling data channels
                   output [2:0] tmds_data_p, 
                   output [2:0] tmds_data_n);
endmodule;