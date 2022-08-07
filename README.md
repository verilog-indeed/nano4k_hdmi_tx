# nano4k_hdmi_tx
Open-source HDMI/DVI transmitter for the Gowin GW1NSR-powered Tang Nano 4K

RTL written in Verilog with some help from Gowin's OSER10 blocks, currently displays a bouncing box screesaver.

Also includes a PAL bar test which you can activate by enabling "pattern_generator_top.v" and disabling "bouncy_box_top.v".

![PAL bar test](media/pal_bar_test.jpg)

Hardwired to a 720x480@60Hz resolution, 24-bit color, currently transmitts a forwards-compatible DVI signal.

Work in Progress: currently working on loading an image from the onboard SPI flash.

![Bouncy box test](media/bouncy.gif)
